`timescale 1ns / 1ps

module control_logic(
  input             i_clk,
  input             i_rst,
  input      [7:0]  i_pixel_data,
  input             i_pixel_data_valid,
  output reg [71:0] o_pixel_data,
  output            o_pixel_data_valid,
  output reg        o_intr 
);

reg [8:0]   pixel_counter;
reg [1:0]   current_wrt_buff;
reg [3:0]   line_buff_data_val;
reg [3:0]   line_buff_rd_data;
reg [1:0]   current_rd_buff;
reg [8:0]   rd_counter;
reg [11:0]  tot_pixel_counter;
reg         rd_line_buffer;
reg         rd_state;
wire [23:0] buff_data_0;
wire [23:0] buff_data_1;
wire [23:0] buff_data_2;
wire [23:0] buff_data_3;

localparam IDLE      = 1'b0;
localparam RD_BUFFER = 1'b1;

assign o_pixel_data_valid = rd_line_buffer;

always @(posedge i_clk) begin
  if (i_rst) begin
    tot_pixel_counter <= 0;
  end else begin
    if (i_pixel_data_valid & !rd_line_buffer) begin //data pumping in but data aren't read
      tot_pixel_counter <= tot_pixel_counter + 1;
    end else if (!i_pixel_data_valid & rd_line_buffer) begin // data not pumping in but data are been read
      tot_pixel_counter <= tot_pixel_counter - 1;
    end
  end
end

always @(posedge i_clk) begin
  if (i_rst) begin
    rd_state       <= IDLE;
    rd_line_buffer <= 1'b0;
    o_intr         <= 1'b0;
  end else begin
    case (rd_state) 
      IDLE : begin
        o_intr     <= 1'b0;
        if (tot_pixel_counter >= 1536) begin
          rd_line_buffer <= 1'b1;
          rd_state       <= RD_BUFFER;
        end
      end
      
      RD_BUFFER : begin
        if (rd_counter == 511) begin
          rd_state       <= IDLE;
          rd_line_buffer <= 1'b0;
          o_intr        <= 1'b1;
        end
      end
    endcase 
  end
end

always @(posedge i_clk) begin
  if (i_rst) begin
    pixel_counter <= 0;
  end else begin
    if (i_pixel_data_valid) begin
      pixel_counter <= pixel_counter + 1;
    end 
  end
end

always @(posedge i_clk) begin
  if (i_rst) begin
    current_wrt_buff <= 0;
  end else begin
    if (pixel_counter == 511 & i_pixel_data_valid) begin
      current_wrt_buff <= current_wrt_buff + 1;
    end
  end
end

always @(*) begin
  line_buff_data_val = 4'h0;
  line_buff_data_val[current_wrt_buff] = i_pixel_data_valid;
end

always @(posedge i_clk) begin
  if (i_rst) begin
    rd_counter <= 0;
  end else if (rd_line_buffer) begin
    rd_counter <= rd_counter + 1;
  end
end

always @(posedge i_clk) begin
  if (i_rst) begin
    current_rd_buff <= 0;
  end else begin
    if (rd_counter == 511 & rd_line_buffer) begin
      current_rd_buff <= current_rd_buff + 1;
    end
  end
end

always @(*) begin
  case(current_rd_buff)
    0 : begin
      o_pixel_data = {buff_data_2,buff_data_1,buff_data_0};
    end
    1 : begin
      o_pixel_data = {buff_data_3,buff_data_2,buff_data_1};
    end
    2 : begin
      o_pixel_data = {buff_data_0,buff_data_3,buff_data_2};
    end
    3 : begin
      o_pixel_data = {buff_data_1,buff_data_0,buff_data_3};
    end
  endcase
end

always @(*) begin
  case (current_rd_buff) 
    0 : begin
      line_buff_rd_data[0] = rd_line_buffer;
      line_buff_rd_data[1] = rd_line_buffer;
      line_buff_rd_data[2] = rd_line_buffer;
      line_buff_rd_data[3] = 1'b0;
    end
    1 : begin
      line_buff_rd_data[0] = 1'b0;
      line_buff_rd_data[1] = rd_line_buffer;
      line_buff_rd_data[2] = rd_line_buffer;
      line_buff_rd_data[3] = rd_line_buffer;
    end
    2 : begin
      line_buff_rd_data[0] = rd_line_buffer;
      line_buff_rd_data[1] = 1'b0;
      line_buff_rd_data[2] = rd_line_buffer;
      line_buff_rd_data[3] = rd_line_buffer;
    end  
    3 : begin
      line_buff_rd_data[0] = rd_line_buffer;
      line_buff_rd_data[1] = rd_line_buffer;
      line_buff_rd_data[2] = 1'b0;
      line_buff_rd_data[3] = rd_line_buffer;
    end  
  endcase 
end

line_buffer line_buffer_00(
  .i_clk           (i_clk),
  .i_rst           (i_rst),
  .i_data          (i_pixel_data),
  .i_data_valid    (line_buff_data_val[0]),
  .i_rd_data_rdy   (line_buff_rd_data[0]),
  .o_data          (buff_data_0)
);

line_buffer line_buffer_01(
  .i_clk           (i_clk),
  .i_rst           (i_rst),
  .i_data          (i_pixel_data),
  .i_data_valid    (line_buff_data_val[1]),
  .i_rd_data_rdy   (line_buff_rd_data[1]),
  .o_data          (buff_data_1)
);

line_buffer line_buffer_02(
  .i_clk           (i_clk),
  .i_rst           (i_rst),
  .i_data          (i_pixel_data),
  .i_data_valid    (line_buff_data_val[2]),
  .i_rd_data_rdy   (line_buff_rd_data[2]),
  .o_data          (buff_data_2)
);

line_buffer line_buffer_03(
  .i_clk           (i_clk),
  .i_rst           (i_rst),
  .i_data          (i_pixel_data),
  .i_data_valid    (line_buff_data_val[3]),
  .i_rd_data_rdy   (line_buff_rd_data[3]),
  .o_data          (buff_data_3)
);

endmodule
