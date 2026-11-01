`timescale 1ns / 1ps

module eth_mac_rx (
    // Wejście RGMII z układu PHY YT8531C-CA
    input  logic       rgmii_rxc,     // Zegar 125 MHz z PHY (Pin V19)
    input  logic       rgmii_rx_ctl,  // Sygnał RX_DV (Pin R14)
    input  logic [3:0] rgmii_rxd,     // Dane DDR 4-bit (Piny P14, R16, R18, T18)

    // Wyjściowy zegar 125 MHz (po buforze BUFG) dla kolejnych modułów
    output logic       rx_clk,

    // Wyjście AXI4-Stream (czyste bajty ramki Ethernet od Bajtu 0 = DST MAC)
    output logic [7:0] m_axis_tdata,
    output logic       m_axis_tvalid,
    output logic       m_axis_tlast
);

    // 1. Bufor zegara odbiorczego 125 MHz
    BUFG u_bufg_rxc (
        .I (rgmii_rxc),
        .O (rx_clk)
    );

    // 2. Rejestry wejściowe DDR (4 bity na posedge + 4 bity na negedge -> 8 bitów)
    logic       ctl_q1, ctl_q2;
    logic [3:0] q1, q2;

    IDDR #(
        .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED")
    ) iddr_ctl (
        .Q1 (ctl_q1),
        .Q2 (ctl_q2),
        .C  (rx_clk),
        .CE (1'b1),
        .D  (rgmii_rx_ctl),
        .R  (1'b0),
        .S  (1'b0)
    );

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_iddr_data
            IDDR #(
                .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED")
            ) iddr_d (
                .Q1 (q1[i]), // Dolny półbajt (bity 3:0)
                .Q2 (q2[i]), // Górny półbajt (bity 7:4)
                .C  (rx_clk),
                .CE (1'b1),
                .D  (rgmii_rxd[i]),
                .R  (1'b0),
                .S  (1'b0)
            );
        end
    endgenerate

    // 3. Rejestry opóźniające o 1 takt (pozwalają wystawić tlast dokładnie na ostatnim bajcie)
    logic [3:0] q1_d = '0, q2_d = '0;
    logic       dv_d = 1'b0;
    wire        dv_now = ctl_q1 & ctl_q2;

    always_ff @(posedge rx_clk) begin
        q1_d <= q1;
        q2_d <= q2;
        dv_d <= dv_now;
    end

    // Dwa możliwe złożenia półbajtów (normalne oraz przesunięte o pół taktu = 4 ns)
    wire [7:0] byte_norm  = {q2_d, q1_d};
    wire [7:0] byte_shift = {q1,   q2_d};

    // 4. Maszyna stanów: szuka SFD (0xD5) i wystawia strumień AXI4-Stream
    logic in_frame     = 1'b0;
    logic nibble_shift = 1'b0;

    always_ff @(posedge rx_clk) begin
        if (!dv_d) begin
            in_frame <= 1'b0;
        end else if (!in_frame) begin
            // Szukamy bajtu SFD (0xD5) kończącego preambułę
            if (byte_norm == 8'hD5) begin
                in_frame     <= 1'b1;
                nibble_shift <= 1'b0;
            end else if (byte_shift == 8'hD5) begin
                in_frame     <= 1'b1;
                nibble_shift <= 1'b1;
            end
        end else if (!dv_now) begin
            // Sygnał dv_now właśnie opadł -> w tym takcie wysyłamy ostatni bajt ramki
            in_frame <= 1'b0;
        end
    end

    assign m_axis_tdata  = nibble_shift ? byte_shift : byte_norm;
    assign m_axis_tvalid = in_frame && dv_d;
    assign m_axis_tlast  = in_frame && dv_d && !dv_now;

endmodule
