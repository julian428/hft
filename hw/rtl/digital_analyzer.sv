`timescale 1ns / 1ps

module digital_analyzer #(
	parameter MEMORY_SIZE=128
) (
	input logic aclk,
	input logic [7:0] t_data = 8'b0,
	input logic t_valid,
	
	output logic CH1,
	output logic CH2,
	output logic CH3,
	output logic CH4,
	output logic CH5,
	output logic CH6,
	output logic CH7,
	output logic CH8,

	output logic t_ready
);

logic slow_pulse = 1'b0; // impuls co 25 cykli zegara aclk
logic [4:0] slow_pulse_cnt = 5'd24;

always_ff @(posedge aclk) begin
	if(slow_pulse_cnt == 0) begin
		slow_pulse <= 1'b1;
		slow_pulse_cnt <= 5'd24;
	end else begin
		slow_pulse_cnt <= slow_pulse_cnt - 1'b1;
		slow_pulse <= 1'b0;
	end
end

logic [7:0] mem [MEMORY_SIZE-1:0];
logic [$clog2(MEMORY_SIZE)-1:0] wr_ptr = '0, rd_ptr = '0;

assign t_ready = wr_ptr < MEMORY_SIZE;

always_ff @(posedge aclk) begin
	// odczyt
	if(slow_pulse && (wr_ptr != rd_ptr)) begin
			rd_ptr <= rd_ptr + 1'b1;
			CH1 <= mem[rd_ptr][7];
			CH2 <= mem[rd_ptr][6];
			CH3 <= mem[rd_ptr][5];
			CH4 <= mem[rd_ptr][4];
			CH5 <= mem[rd_ptr][3];
			CH6 <= mem[rd_ptr][2];
			CH7 <= mem[rd_ptr][1];
			CH8 <= mem[rd_ptr][0];
	end

	// zapis
	if(t_ready && t_valid) begin
		mem[wr_ptr] <= t_data;
		wr_ptr <= wr_ptr + 1'b1;
	end

	// reset
	if(~t_ready && (wr_ptr == rd_ptr)) begin
		wr_ptr <= '0;
		rd_ptr <= '0;
	end
end

endmodule
