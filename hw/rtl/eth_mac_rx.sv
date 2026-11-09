`timescale 1ns / 1ps

module eth_mac_rx (
    // Wejście RGMII z układu PHY YT8531C-CA
    input  logic       rgmii_rxc,     // Zegar 125 MHz z PHY (Pin V19)
    input  logic       rgmii_rx_ctl,  // Sygnał RX_DV (Pin R14)
    input  logic [3:0] rgmii_rxd,     // Dane DDR 4-bit (Piny P14, R16, R18, T18)

		// Są takie śmieszne nazwy bo jednak bedziemy używać AXI4-Stream
    output logic       aclk, // wyjściowy zbuforowany zegar 125MHz dla kolejnych modułów, pewnie FIFO.
		output logic			 t_valid,  // data valid
		output logic [7:0] t_data, // dane
		output logic			 t_last
);

		logic aclk_local;
		logic aclk_bufio;

    IBUF u_ibufds (
        .I (rgmii_rxc),
        .O (aclk_local)
    );

		BUFIO u_bufio (
			.I (aclk_local),
			.O (aclk_bufio)
		);

		BUFR #(
			.BUFR_DIVIDE("BYPASS")
		) u_bufr (
			.I (aclk_local),
			.O (aclk), // BUFR jest do logiki więc dlatego od niego przypisujemy główny zegar.
			.CE (1'b1),
			.CLR (1'b0)
		);

    logic       ctl_q1, ctl_q2;

    IDDR #(
        .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED"),
    ) iddr_ctl (
        .Q1 (ctl_q1),
        .Q2 (ctl_q2),
        .C  (aclk_bufio), // taktowanie z dedykowanego zegara do IO. Podobno tak jest lepiej niż z aclk, który jest do logiki.
        .CE (1'b1),
        .D  (rgmii_rx_ctl),
        .R  (1'b0),
        .S  (1'b0)
    );
		
    logic [3:0] q1, q2;

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_iddr_data
            IDDR #(
                .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED"),
            ) iddr_d (
                .Q1 (q1[i]), // Dolny półbajt (bity 3:0)
                .Q2 (q2[i]), // Górny półbajt (bity 7:4)
                .C  (aclk_bufio), // ten sam powód co wyżej
                .CE (1'b1),
                .D  (rgmii_rxd[i]),
                .R  (1'b0),
                .S  (1'b0)
            );
        end
    endgenerate

		localparam SFD_BYTE = 8'hD5;
		always_ff @(posedge aclk) begin
			t_data <= {q2, q1};
			if((t_data == SFD_BYTE || t_valid) && (ctl_q1 && (ctl_q1 ^ ctl_q2))) begin
				t_valid <= 1'b1;
			end else begin
				t_valid <= 1'b0;
			end
		end

endmodule
