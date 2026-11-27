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

  digital_analyzer dut (
    .aclk     (aclk),
		.t_data		(t_data),
		.t_valid	(t_valid),
		.areset_n(1'b1),

		.CH1			(CH1),
		.CH2			(CH2),
		.CH3			(CH3),
		.CH4			(CH4),
		.CH5			(CH5),
		.CH6			(CH6),
		.CH7			(CH7),
		.CH8			(CH8)
  );

  always #4 aclk = ~aclk;

  logic [7:0] frame [0:15] = '{
    8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'h08,
    8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0E, 8'h0F, 8'h10
  };

  initial begin
    repeat (10) @(posedge aclk);

		@(posedge aclk);
		for(int i = 0; i < 16; i++) begin
			@(posedge aclk);
			t_valid <=	1'b1;
			t_data 	<=	frame[i];
		end

		@(posedge aclk);
		t_valid <= 0;
		t_data <= '0;

    repeat (10) @(posedge aclk);
  end

endmodule
