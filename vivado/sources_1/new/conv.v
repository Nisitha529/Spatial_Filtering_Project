`timescale 1ns / 1ps

module convolution(
  input             i_clk,
  input      [71:0] i_pixel_data,
  input             i_pixel_data_valid,
  output reg [7:0]  o_convolved_data,
  output reg        o_convolved_data_valid
);

integer i;
reg [7:0]  kernel [8:0];
reg [15:0] multiplied_data [8:0];
reg [15:0] sum_data_intmd;
reg [15:0] sum_data;
reg        mult_data_valid;
reg        sum_data_valid;
reg        convolved_data_valid;

initial begin
  for (i = 0; i <9; i = i + 1) begin
    kernel[i] = 1;
  end
end

always @(posedge i_clk) begin
  for (i = 0; i < 9; i = i + 1) begin
    multiplied_data[i] <= kernel[i] * i_pixel_data[i*8+:8]; 
  end
  mult_data_valid <= i_pixel_data_valid;
end

always @(*) begin
  for (i = 0; i<9; i= i + 1) begin
    sum_data_intmd = sum_data_intmd + multiplied_data[i];
  end
end

always @(posedge i_clk) begin
  sum_data       <= sum_data_intmd;
  sum_data_valid <= mult_data_valid;  
  sum_data_intmd <= 0;
end

always @(posedge i_clk) begin
  o_convolved_data       <= sum_data / 9;
  o_convolved_data_valid <= sum_data_valid;
end 

endmodule
