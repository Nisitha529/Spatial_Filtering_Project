`timescale 1ns / 1ps

module line_buffer(
  input         i_clk,
  input         i_rst,
  input  [7:0]  i_data,
  input         i_data_valid,
  input         i_rd_data_rdy,
  output [23:0] o_data);
  
  reg [7:0] line_mem [511:0];
  reg [8:0] wr_ptr;
  reg [8:0] rd_ptr;
  
  always @(posedge i_clk) begin
    if (i_data_valid) begin
      line_mem[wr_ptr] <= i_data;
    end
  end
  
  always @(posedge i_clk) begin
    if (i_rst) begin
      wr_ptr <= 'd0;
    end else if (i_data_valid) begin
      wr_ptr <= wr_ptr + 'd1;
    end
  end
  
  always @(posedge i_clk) begin
    if (i_rst) begin
      rd_ptr <= 'd0;
    end else if (i_rd_data_rdy) begin
      rd_ptr <= rd_ptr + 'd1;
    end
  end
  
  assign o_data = {line_mem[rd_ptr], line_mem[rd_ptr + 1], line_mem[rd_ptr + 2]};
  
endmodule
