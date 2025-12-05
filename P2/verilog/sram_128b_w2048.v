// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Modified for Debugging & Initialization
module sram_128b_w2048 (CLK, D, Q, CEN, WEN, A);

  input  CLK;
  input  WEN;
  input  CEN; 
  input  [127:0] D;
  input  [10:0] A;
  output [127:0] Q;
  parameter num = 2048;

  reg [127:0] memory [num-1:0];
  reg [10:0] add_q;

  integer i;
  initial begin
      for (i=0; i<num; i=i+1) begin
          memory[i] = 128'b0;
      end
  end

  assign Q = memory[add_q];

  always @ (posedge CLK) begin
   if (!CEN && WEN) begin // read 
      add_q <= A;
   end
   if (!CEN && !WEN) begin // write
      memory[A] <= D; 
   end
   if (!CEN && !WEN) begin // write
      memory[A] <= D;
   end
  end

endmodule