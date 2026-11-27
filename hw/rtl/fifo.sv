`timescale 1ns / 1ps

module fifo #(
	parameter MEMORY_SIZE=128
) (
	input logic aclk,
	input logic areset_n = 1'b0,
	input logic [7:0] t_data = 8'b0,
	input logic t_valid = 1'b0,
	input logic t_read = 1'b0,

	output logic t_full, // 1 if full
	output logic t_empty, // 1 if empty
	output logic [7:0] o_data
);

logic [7:0] mem [MEMORY_SIZE-1:0];
logic [$clog2(MEMORY_SIZE)-1:0] wr_ptr = '0, rd_ptr = '0;
logic last_read = 1'b1;

logic last_t_read = 1'b0;
logic	t_read_edge;
assign t_read_edge = ~last_t_read && t_read;

always_comb begin
    if(wr_ptr == rd_ptr) begin
        t_full = ~last_read;
        t_empty = last_read;
    end else begin
        t_full = 1'b0;
        t_empty = 1'b0;
    end
end

always_ff @(posedge aclk) begin
	if(!areset_n) begin
		wr_ptr <= '0;
		rd_ptr <= '0;
		last_read <= 1'b1;
		o_data <= 8'b0;
	end else begin
		last_t_read <= t_read;
		if(t_valid && !t_full) begin
			wr_ptr <= wr_ptr + 1'b1;
			mem[wr_ptr] <= t_data;
			last_read <= 1'b0;
		end
	
		if(t_read_edge && !t_empty) begin
			rd_ptr <= rd_ptr + 1'b1;
			o_data <= mem[rd_ptr];
			last_read <= 1'b1;
		end else if(t_read_edge) begin
			o_data <= 8'b0;
		end
	end		
end
endmodule
