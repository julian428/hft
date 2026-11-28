`timescale 1ns / 1ps

module digital_analyzer #(
  parameter MEMORY_SIZE = 128
) (
  input logic       aclk,
  input logic [7:0] t_data = 8'b0,
  input logic       t_valid,
  input logic       areset_n = 1'b0,

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

  logic       slow_pulse = 1'b0;  // impuls co 25 cykli zegara aclk
  logic [4:0] slow_pulse_cnt = 5'd24;

  always_ff @(posedge aclk) begin
    if (slow_pulse_cnt == 0) begin
      slow_pulse     <= 1'b1;
      slow_pulse_cnt <= 5'd24;
    end else begin
      slow_pulse_cnt <= slow_pulse_cnt - 1'b1;
      slow_pulse     <= 1'b0;
    end
  end

  fifo #(
    .MEMORY_SIZE(MEMORY_SIZE)
  ) u_fifo (
    .aclk    (aclk),
    .areset_n(areset_n),
    .t_data  (t_data),
    .t_valid (t_valid),
    .t_read  (slow_pulse),

    .o_data({CH8, CH7, CH6, CH5, CH4, CH3, CH2, CH1})
  );

endmodule
