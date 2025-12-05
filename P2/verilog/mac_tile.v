// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Modified for SIMD Support (Added b_q1 for Weight 1)
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, simd);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; 
output [bw-1:0] out_e; 
input  [1:0] inst_w; // [1]:execute, [0]:kernel loading
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
input  simd;

reg [bw-1:0] b_q;   // Weight 0 Register
reg [bw-1:0] b_q1;  // Weight 1 Register (New)
reg [bw-1:0] a_q;
reg [1:0] inst_q;
reg load_ready_q;
reg [psum_bw-1:0] c_q;
reg load_phase;     // Toggle to switch between W0 and W1 loading

wire [psum_bw-1:0] mac_out;

assign out_s = mac_out;
assign out_e = a_q;
assign inst_e = inst_q;

// [mac_tile.v] Replace the always @(posedge clk) block with this:
always @(posedge clk) begin
 if (reset) begin
   inst_q[1:0] <= 2'b00;
   load_ready_q <= 1;
   load_phase <= 0; 
   a_q <= 0;
   b_q <= 0;
   b_q1 <= 0;
   c_q <= 0;
 end
 else begin
   inst_q[1] <= inst_w[1];
   c_q <= in_n;

   if (inst_w[1:0] != 2'b00) begin
     a_q <= in_w;
   end
   

   // --- 核心加载逻辑 ---
   if (inst_w[0] && load_ready_q) begin
     if (load_phase == 0) begin
        b_q <= in_w;
        if (simd) load_phase <= 1;
        else      load_ready_q <= 0;
     end
     else begin
        b_q1 <= in_w;
        load_ready_q <= 0;
        load_phase <= 0;
     end
   end
   
   if (!load_ready_q) begin
     inst_q[0] <= inst_w[0];
   end
 end
end

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a(a_q), 
        .b(b_q),
        .b1(b_q1),    // Connect Weight 1
        .c(c_q),
        .simd(simd),
        .out(mac_out)
);

endmodule