// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
//change inst_w
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, valid);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [2:0] inst_w;
  input  [bw*col-1:0] in_n;
  output [col-1:0] valid;

  wire [row*col-1:0] valid_temp;
  wire [(row+1)*col*psum_bw-1:0] temp;
  reg [row*3-1:0] inst_w_temp;

  assign valid = valid_temp[col*row-1:col*row-8];
  assign temp[psum_bw*col-1:0] = (inst_w[2])?0: {12'b0,in_n[31:28],12'b0,in_n[27:24],12'b0,in_n[23:20],12'b0,in_n[19:16],12'b0,in_n[15:12],12'b0,in_n[11:8],12'b0,in_n[7:4],12'b0,in_n[3:0]};//pad 0 bits to weight
  assign out_s = temp[psum_bw*col*9-1:psum_bw*col*8];
  generate
  genvar i;
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw), .col(col)) mac_row_instance (
      .clk(clk), 
      .out_s(temp[(i+1)*col*psum_bw-1:i*col*psum_bw]), 
      .in_w(in_w[bw*i-1:bw*(i-1)]), 
      .in_n(temp[i*psum_bw*col-1:(i-1)*psum_bw*col]), 
      .valid(valid_temp[col*i-1:col*(i-1)]), 
      .inst_w(inst_w_temp[3*i-1:3*(i-1)]), 
      .reset(reset)
      );
  end
  endgenerate
  always @ (posedge clk) begin
      inst_w_temp[2:0] <= inst_w;
      inst_w_temp[5:3] <= inst_w_temp[2:0];
      inst_w_temp[8:6] <= inst_w_temp[5:3];
      inst_w_temp[11:9] <= inst_w_temp[8:6];
      inst_w_temp[14:12] <= inst_w_temp[11:9];
      inst_w_temp[17:15] <= inst_w_temp[14:12];
      inst_w_temp[20:18] <= inst_w_temp[17:15]; 
      inst_w_temp[23:21] <= inst_w_temp[20:18];
  
 
  end



endmodule
