// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Modified for Debugging
module sfp (out, in, acc, clk, reset, simd);

  parameter bw = 8;
  parameter psum_bw = 16;

  input clk;
  input acc;
  input reset;
  input simd; // [Fix] Added missing simd port

  input signed [psum_bw-1:0] in;
  output signed [psum_bw-1:0] out;

  reg signed [psum_bw-1:0] psum_q;

  always @(posedge clk) begin
    if (reset) begin
      psum_q <= 0;
    end 
    else begin
      if (acc) begin
        
        if (simd) begin
          // SIMD mode: Two 8-bit independent accumulations to prevent carry from lower bits contaminating higher bits
          psum_q[7:0]  <= psum_q[7:0] + in[7:0];
          psum_q[15:8] <= psum_q[15:8] + in[15:8];
        end 
        else begin
          psum_q <= psum_q + in;
        end
      end 
      else begin
        // ReLU logic
        if (simd) begin
            if (psum_q[7])  psum_q[7:0]  <= 0;
            else            psum_q[7:0]  <= psum_q[7:0];

            if (psum_q[15]) psum_q[15:8] <= 0;
            else            psum_q[15:8] <= psum_q[15:8];
        end 
        else begin
            if (psum_q < 0) psum_q <= 0;
            else            psum_q <= psum_q;
        end
      end
    end
  end

  assign out = psum_q;

endmodule