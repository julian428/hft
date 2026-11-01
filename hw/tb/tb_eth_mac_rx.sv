`timescale 1ns / 1ps

module tb_eth_mac_rx ();

    logic       rgmii_rxc    = 1'b0;
    logic       rgmii_rx_ctl = 1'b0;
    logic [3:0] rgmii_rxd    = 4'h0;

    logic       rx_clk;
    logic [7:0] m_axis_tdata;
    logic       m_axis_tvalid;
    logic       m_axis_tlast;

    // Instancja testowanego modułu (DUT)
    eth_mac_rx dut (
        .rgmii_rxc     (rgmii_rxc),
        .rgmii_rx_ctl  (rgmii_rx_ctl),
        .rgmii_rxd     (rgmii_rxd),
        .rx_clk        (rx_clk),
        .m_axis_tdata  (m_axis_tdata),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tlast  (m_axis_tlast)
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
    always @(posedge rx_clk) begin
        if (m_axis_tvalid) begin
            $display("[TB] Odebrano Bajt %0d: 0x%02h (oczekiwano: 0x%02h) | tlast=%b",
                     rx_count, m_axis_tdata, raw_frame[rx_count + 8], m_axis_tlast);

            if (m_axis_tdata !== raw_frame[rx_count + 8]) begin
                $error("[TB BLAD] Niezgodnosc danych na bajcie %0d!", rx_count);
            end
            rx_count++;
        end
    end

    initial begin
        repeat (10) @(posedge rgmii_rxc);
        $display("--- START TESTU ETH_MAC_RX ---");

        send_rgmii_frame();

        repeat (10) @(posedge rgmii_rxc);

        if (rx_count == 18)
            $display("--- SUKCES! Odebrano dokladnie 18 bajtow po SFD (0xD5) ---");
        else
            $error("--- BLAD! Odebrano %0d bajtow zamiast 18 ---", rx_count);

        $finish;
    end

endmodule
