`timescale 1ns / 1ps

module tb_digital_analyzer ();
  logic       aclk = 1'b0;
	logic				t_valid = 1'b0;
	logic [7:0] t_data = '0;

	logic CH1 = 1'b0;
	logic CH2 = 1'b0;
	logic CH3 = 1'b0;
	logic CH4 = 1'b0;
	logic CH5 = 1'b0;
	logic CH6 = 1'b0;
	logic CH7 = 1'b0;
	logic CH8 = 1'b0;

  // Instancja testowanego modułu (DUT)
  digital_analyzer dut (
    .aclk     (aclk),
		.t_data		(t_data),
		.t_valid	(t_valid),

		.CH1			(CH1),
		.CH2			(CH2),
		.CH3			(CH3),
		.CH4			(CH4),
		.CH5			(CH5),
		.CH6			(CH6),
		.CH7			(CH7),
		.CH8			(CH8)
  );

  // Zegar 125 MHz (okres 8 ns -> zbocze co 4 ns)
  always #4 aclk = ~aclk;

  // Ramka testowa: 8B Preambuła/SFD + 14B Nagłówek Ethernet + 4B Payload = 26 bajtów
  logic [7:0] raw_frame [0:25] = '{
    8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'h55, 8'hD5,
    8'h02, 8'h00, 8'h00, 8'h00, 8'h00, 8'h01,
    8'h00, 8'h0A, 8'hCD, 8'h00, 8'h0B, 8'h49,
    8'h08, 8'h00,
    8'hDE, 8'hAD, 8'hBE, 8'hEF
  };

  initial begin
    repeat (10) @(posedge aclk);

		@(posedge aclk);
		for(int i = 0; i < 26; i++) begin
			@(posedge aclk);
			t_valid <=	1'b1;
			t_data 	<=	raw_frame[i];
		end

		@(posedge aclk);
		t_valid <= 0;
		t_data <= '0;

    repeat (10) @(posedge aclk);
  end

endmodule
