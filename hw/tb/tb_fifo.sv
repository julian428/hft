`timescale 1ns / 1ps

module tb_fifo ();
  logic       aclk = 1'b0;
  logic				pulse = 1'b0;
  logic				t_read = 1'b0;
	logic				t_valid = 1'b0;
	logic				t_full = 1'b0;
	logic				areset_n = 1'b1;
	logic [7:0] t_data = '0;
	logic [7:0] o_data = '0;

  fifo #(
  	.MEMORY_SIZE(4)
  ) dut (
    .aclk(aclk),
		.t_data(t_data),
		.t_valid(t_valid),
		.areset_n(areset_n),
		.t_read(pulse),
		.o_data(o_data),
		.t_full(t_full)
  );

  always #4 aclk = ~aclk;
  always #100 begin
  	pulse = 1'b1;
  	#8 pulse = 1'b0;
  end

  logic [7:0] test_frame [0:15] = '{
    8'h01, 8'h02, 8'h03, 8'h04, 8'h05, 8'h06, 8'h07, 8'h08,
    8'h09, 8'h0A, 8'h0B, 8'h0C, 8'h0D, 8'h0E, 8'h0F, 8'h10
  };

  initial begin
		@(posedge aclk);
		for(int i = 0; i < 16;) begin
			@(posedge aclk);
			t_valid <=	1'b1;
			t_data 	<=	test_frame[i];
			
			if(!t_full) i++;
		end

		@(posedge aclk);
		t_valid <= 0;
		t_data <= '0;

    repeat (100) @(posedge aclk);
  end

endmodule
