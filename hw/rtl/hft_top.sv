`timescale 1ns / 1ps

module hft_top (
    input  logic       sys_clk_50m,  // Pin Y18 (50 MHz)
    output logic       phy_rst_n,    // Pin N15 (Reset PHY YT8531C)
    input  logic       rgmii_rxc,    // Pin V19 (125 MHz RX_CLK)
    input  logic       rgmii_rx_ctl, // Pin R14 (RX_DV)
    input  logic [3:0] rgmii_rxd,     // Piny P14, R16, R18, T18

		output logic			 led
);
    // Wybudzenie układu PHY YT8531C-CA po włączeniu zasilania (~20 ms)
    logic [19:0] rst_cnt = '0;
    always_ff @(posedge sys_clk_50m) begin
        if (rst_cnt != 20'hFFFFF) begin
            rst_cnt   <= rst_cnt + 1'b1;
            phy_rst_n <= 1'b0;
        end else begin
            phy_rst_n <= 1'b1;
        end
    end

    logic       aclk;
    logic [7:0] t_data;
    logic       t_valid;
    logic       t_last;

    eth_mac_rx u_eth_mac_rx (
        .rgmii_rxc     (rgmii_rxc),
        .rgmii_rx_ctl  (rgmii_rx_ctl),
        .rgmii_rxd     (rgmii_rxd),
        .aclk        	 (aclk),
				.t_valid			 (tt_valid),
				.t_data			 	 (t_data),
				.t_last				 (t_last)
    );

		always_ff @(posedge aclk) begin
			if(t_valid) led <= 1'b1;
		end

endmodule
