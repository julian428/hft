`timescale 1ns / 1ps

module tb_eth_mac_rx ();
    logic       rgmii_rxc    = 1'b0;
    logic       rgmii_rx_ctl = 1'b0;
    logic [3:0] rgmii_rxd    = 4'h0;

    logic       aclk;
		logic				t_valid;
		logic [7:0] t_data;
		logic				t_last;

    // Instancja testowanego modułu (DUT)
    eth_mac_rx dut (
        .rgmii_rxc     (rgmii_rxc),
        .rgmii_rx_ctl  (rgmii_rx_ctl),
        .rgmii_rxd     (rgmii_rxd),
        .aclk        	 (aclk),
				.t_valid			 (t_valid),
				.t_data			 	 (t_data),
				.t_last				 (t_last)
    );

    // Zegar 125 MHz (okres 8 ns -> zbocze co 4 ns)
    always #4 rgmii_rxc = ~rgmii_rxc;

    // Ramka testowa: 8B Preambuła/SFD + 14B Nagłówek Ethernet + 4B Payload = 26 bajtów
    logic [7:0] raw_frame [0:25] = '{
        // Preambuła (7B) + SFD (1B) -> powinny zostać ODRZUCONE przez moduł!
        8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'hD5,
        // Bajty 0..5: Destination MAC
        8'h02, 8'h00, 8'h00, 8'h00, 8'h00, 8'h01,
        // Bajty 6..11: Source MAC
        8'h00, 8'h0A, 8'hCD, 8'h00, 8'h0B, 8'h49,
        // Bajty 12..13: EtherType (0x0800 = IPv4)
        8'h08, 8'h00,
        // Bajty 14..17: Przykładowy payload (4 bajty)
        8'hDE, 8'hAD, 8'hBE, 8'hEF
    };

    // Zadanie nadające bajty w standardzie RGMII DDR (4 bity na posedge, 4 bity na negedge)
    task automatic send_rgmii_frame();
        for (int i = 0; i < 26; i++) begin
            @(posedge rgmii_rxc);
            rgmii_rx_ctl <= 1'b1;
            rgmii_rxd    <= raw_frame[i][3:0]; // Dolne 4 bity

            @(negedge rgmii_rxc);
            rgmii_rx_ctl <= 1'b1;
            rgmii_rxd    <= raw_frame[i][7:4]; // Górne 4 bity
        end
        @(posedge rgmii_rxc);
        rgmii_rx_ctl <= 1'b0;
        rgmii_rxd    <= 4'h0;
    endtask

    // Proces odbiorczy weryfikujący wyjście AXI4-Stream
    int rx_count = 0;
    always @(posedge aclk) begin
			if(t_valid) begin
        $display("[TB] Odebrano Bajt %0d: 0x%02h (oczekiwano: 0x%02h)",
                 rx_count, t_data, raw_frame[rx_count + 8]);
        rx_count++;
			end
    end

    initial begin
        repeat (10) @(posedge rgmii_rxc);
        $display("--- START TESTU ETH_MAC_RX ---");

        send_rgmii_frame();

        repeat (10) @(posedge rgmii_rxc);

        $display("--- Odebrano %0d bajtow po SFD (0xD5) ---", rx_count);

        $finish;
    end

endmodule
