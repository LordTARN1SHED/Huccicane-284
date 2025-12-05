// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Modified for SIMD Support (Restored Full Logic)
module mac (out, a, b, b1, c, simd);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input  unsigned [bw-1:0] a;
input  signed [bw-1:0] b;   // Weight 0
input  signed [bw-1:0] b1;  // Weight 1 (New for SIMD)
input  signed [psum_bw-1:0] c;
input  simd;

wire signed [bw:0] a_pad;
wire signed [psum_bw-1:0] out_vanilla;
wire signed [7:0] out_simd_low;   // 8-bit for lower lane
wire signed [7:0] out_simd_high;  // 8-bit for upper lane
wire signed [bw-1:0] a_low_simd;
wire signed [bw-1:0] a_high_simd;

// Vanilla Mode (4-bit * 4-bit)
assign a_pad = {1'b0, a}; // unsigned to signed extension
assign out_vanilla = a_pad * b + c;

// SIMD Mode (Split: 2-bit * 4-bit)
// a[1:0] is unsigned 2-bit -> extend to 4-bit signed
assign a_low_simd  = {2'b00, a[1:0]}; 
// a[3:2] is unsigned 2-bit -> extend to 4-bit signed
assign a_high_simd = {2'b00, a[3:2]};

// Lane 0: Lower 8 bits calculation
// We must explicitly take c[7:0] and add the product
assign out_simd_low  = (a_low_simd * b)  + c[7:0];

// Lane 1: Upper 8 bits calculation
// We must explicitly take c[15:8] and add the product
assign out_simd_high = (a_high_simd * b1) + c[15:8];

// Output Mux
assign out = simd ? {out_simd_high, out_simd_low} : out_vanilla;

endmodule