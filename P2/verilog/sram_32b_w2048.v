// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Modified with BOUNDARY CHECK
module sram_32b_w2048 (CLK, D, Q, CEN, WEN, A);
  input  CLK;
  input  WEN;
  input  CEN;
  input  [31:0] D;
  input  [10:0] A;
  output [31:0] Q;
  parameter num = 2048;

  reg [31:0] memory [num-1:0];
  reg [10:0] add_q;

  // Initialize memory to all 0 to avoid X
  integer i;
  initial begin
      for (i=0; i<num; i=i+1) begin
          memory[i] = 32'b0; 
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
  end

endmodule