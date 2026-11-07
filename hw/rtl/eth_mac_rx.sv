`timescale 1ns / 1ps

module eth_mac_rx (
		input  logic				sys_clk_200m; // zegar 200MHz dla IDELAY	
		input  logic				sys_rst;
		
    // Wejście RGMII z układu PHY YT8531C-CA
    input  logic       rgmii_rxc,     // Zegar 125 MHz z PHY (Pin V19)
    input  logic       rgmii_rx_ctl,  // Sygnał RX_DV (Pin R14)
    input  logic [3:0] rgmii_rxd,     // Dane DDR 4-bit (Piny P14, R16, R18, T18)

    output logic       rx_clk, // wyjściowy zbuforowany zegar 125MHz dla kolejnych modułów, pewnie FIFO.
		output logic			 rx_dv,  // data valid
		output logic			 rx_er,  // error
		output logic [7:0] rx_data // dane
);

		logic rx_clk_local;
		logic rx_clk_bufio;
		logic rx_clk_bufr;

		// genialne rozwiązanie zaproponowane przez czata. Omija problem RX_CLK
		// podłączonego do pinu typu N.
    IBUF u_ibufds (
        .I (rgmii_rxc),
        .O (rx_clk_local)
    );

		BUFIO u_bufio (
			.I (rx_clk_local),
			.O (rx_clk_bufio)
		);

		BUFR #(
			.BUFR_DIVIDE("BYPASS")
		) u_bufr (
			.I (rx_clk_local),
			.O (rx_clk_bufr),
			.CE (1'b1),
			.CLR (1'b0)
		);

		assign rx_clk = rx_clk_bufr;

		

		logic idelay_ready;

		IDELAYCTRL u_idelayctrl (
			.RDY (idelay_ready),
			.REFCLK (sys_clk_200m),
			.RST (sys_rst)
		);

		logic ctl_delayed;
    logic       ctl_q1, ctl_q2;

		IDELAY2 #(
			.CINVCTRL_SEL("FALSE"),     .DELAY_SRC("IDELAY"),       .HIGH_PERFORMANCE("TRUE"),
      .IDELAY_TYPE("FIXED"),      .IDELAY_VALUE(5'd24),       .PIPE_SEL("FALSE"),
      .SIGNAL_PATTERN("DATA"),    .SRTYPE("SYNC")
		) u_idelay_ctl (
			.CNTVALUEOUT(), .DATAOUT(ctl_delayed), .C(1'b0), .CE(1'b0),
      .CINVCTRL(1'b0), .CLKIN(1'b0), .CNTVALUEIN(5'b0), .DATAIN(1'b0),
      .IDATAIN(rgmii_rx_ctl), .INC(1'b0), .LD(1'b0), .LDPIPEEN(1'b0), .REGRST(1'b0)
		);

    IDDR #(
        .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED"),
				.INIT_Q1 (1'b0),
				.INIT_Q2 (1'b0),
				.SRTYPE ("SYNC")
    ) iddr_ctl (
        .Q1 (ctl_q1),
        .Q2 (ctl_q2),
        .C  (rx_clk_bufio), // taktowanie z dedykowanego zegara do IO. Podobno tak jest lepiej niż z rx_clk, który jest do logiki.
        .CE (1'b1),
        .D  (ctl_delayed),
        .R  (1'b0),
        .S  (1'b0)
    );
		
		logic [3:0] rxd_delayed;
    logic [3:0] q1, q2;

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_iddr_data
						IDELAYE2 #(
                .CINVCTRL_SEL("FALSE"),     .DELAY_SRC("IDELAY"),       .HIGH_PERFORMANCE("TRUE"),
                .IDELAY_TYPE("FIXED"),      .IDELAY_VALUE(5'd24),       .PIPE_SEL("FALSE"),
                .SIGNAL_PATTERN("DATA"),    .SRTYPE("SYNC")
            ) u_idelay_rxd (
                .CNTVALUEOUT(), .DATAOUT(rxd_delayed[i]), .C(1'b0), .CE(1'b0),
                .CINVCTRL(1'b0), .CLKIN(1'b0), .CNTVALUEIN(5'b0), .DATAIN(1'b0),
                .IDATAIN(rgmii_rxd[i]), .INC(1'b0), .LD(1'b0), .LDPIPEEN(1'b0), .REGRST(1'b0)
            );

            IDDR #(
                .DDR_CLK_EDGE ("SAME_EDGE_PIPELINED"),
								.INIT_Q1 (1'b0),
								.INIT_Q2 (1'b0),
								.SRTYPE ("SYNC")
            ) iddr_d (
                .Q1 (q1[i]), // Dolny półbajt (bity 3:0)
                .Q2 (q2[i]), // Górny półbajt (bity 7:4)
                .C  (rx_clk_bufio), // ten sam powód co wyżej
                .CE (1'b1),
                .D  (rxd_delayed[i]),
                .R  (1'b0),
                .S  (1'b0)
            );
        end
    endgenerate

		always_ff @(posedge rx_clk) begin
			rx_dv <= ctl_q1;
			rx_er <= ctl_q1 ^ ctl_q2;
			rx_data <= {q2, q1};
		end

endmodule
