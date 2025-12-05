module mac_tile (
    input clk, 
    output [psum_bw-1:0] out_s, 
    input [bw-1:0] in_w, 
    output [bw-1:0] out_e, 
    input [psum_bw-1:0] in_n,
    input [2:0] inst_w,      
    output [2:0] inst_e,
    input reset
);

parameter bw = 4;
parameter psum_bw = 16;

reg [bw-1:0] b_q;      // weight stationary: weight; output stationary: weight
reg [bw-1:0] a_q;      // weight stationary: activation; output stationary: activation
reg [2:0] inst_q;
reg load_ready_q;
reg shift_ready_q;
reg [psum_bw-1:0] c_q; // partial sum
wire [psum_bw-1:0] mac_out;

reg [psum_bw-1:0] c_qq;




assign out_s = inst_q[2]?mac_out:(inst_q[1:0]==2'b10)?{{12{b_q[bw-1]}},b_q[bw-1:0]}:(inst_q[1:0]==2'b01)?c_q:0;//10:execution;01:load psum to the output port
assign out_e = a_q;
assign inst_e = inst_q;

always @(posedge clk) begin
    if (reset) begin
        inst_q <= 3'b000;
        load_ready_q <= 1;
        shift_ready_q <= 1;
        a_q <= 0;
        b_q <= 0;
        c_q <= 0;
        c_qq <= 0;
       
    end
    else begin
        
        inst_q[2:1] <= inst_w[2:1];
        if (inst_w[2]) begin  // Weight Stationary Mode,use the same code in step3
            //inst_q[1] <= inst_w[1];
            c_q <= in_n;
            if (inst_w[1:0] != 2'b00) begin
                a_q <= in_w;
            end
            if (inst_w[0] && load_ready_q) begin
                b_q <= in_w;
                load_ready_q <= 0;
            end
            if (!load_ready_q) begin
                inst_q[0] <= inst_w[0];
            end
        end
       else begin  // Output Stationary Mode,10 execute,01 move
            inst_q[0] <= inst_w[0];
            if (inst_w[1:0] == 2'b10) begin
                //c_q <= mac_out;     
                a_q <= in_w;        // activation flows from left
                // weight flows from top
                b_q <=in_n;
                
            end
            else if (inst_w[1:0] ==2'b01)begin//load psum from north
                 c_qq <= in_n;
                 if (shift_ready_q)begin
                     shift_ready_q <= 0;
                 end
                 else begin
                 c_q <= c_qq;//delay for one cycle for out_s to catch it
                 end
             
            end
        
        end
    end
  
    if (inst_w == 3'b010)begin
        c_q <= mac_out;
    end
   

end

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
    .a(a_q),
    .b(b_q),
    .c(c_q),
    .out(mac_out)
);

endmodule


