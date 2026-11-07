`timescale 1ns / 1ps

module hft_top (
    input  logic       sys_clk_50m,  // Pin Y18 (50 MHz)
    output logic       phy_rst_n,    // Pin N15 (Reset PHY YT8531C)
    input  logic       rgmii_rxc,    // Pin V19 (125 MHz RX_CLK)
    input  logic       rgmii_rx_ctl, // Pin R14 (RX_DV)
    input  logic [3:0] rgmii_rxd     // Piny P14, R16, R18, T18
);

		logic sys_cllk_200m;
		logic local_reset;

		clk_wiz_0 u_clock_gen (
			.clk_in1 (sys_clk_50m),
			.clk_out1 (sys_clk_200m),
			.resetn		(1'b1),
			.locked (mmcm_locked)
		);

		assign local_reset = !mmcm_locked;

    // 1. Wybudzenie układu PHY YT8531C-CA po włączeniu zasilania (~20 ms)
    logic [19:0] rst_cnt = '0;
    always_ff @(posedge sys_clk_50m) begin
        if (rst_cnt != 20'hFFFFF) begin
            rst_cnt   <= rst_cnt + 1'b1;
            phy_rst_n <= 1'b0;
        end else begin
            phy_rst_n <= 1'b1;
        end
    end

    // 2. Instancja naszego pierwszego modułu: Odbiornik RGMII -> AXI4-Stream
    logic       rx_clk;
    logic [7:0] rx_data;
    logic       rx_dv;
    logic       rx_er;

    eth_mac_rx u_eth_mac_rx (
				.clk_200m			 (sys_clk_200m),
				.sys_rst			 (local_reset),
        .rgmii_rxc     (rgmii_rxc),
        .rgmii_rx_ctl  (rgmii_rx_ctl),
        .rgmii_rxd     (rgmii_rxd),
        .rx_clk        (rx_clk),
				.rx_dv				 (rx_dv),
				.rx_er				 (rx_er),
				.rx_data			 (rx_data)
    );

endmodule
