module corelet (clk, reset, ofifo_valid, sfp_in, sfp_out, inst, l0_in, l0_o_full, l0_o_ready,  ofifo_out, ofifo_o_full, ofifo_o_ready, simd);             
    parameter row=8;
    parameter col=8;
    parameter bw=4;
    parameter psum_bw=16;

    //Input and Output declaration
    input clk;
    input reset;
    input [33:0] inst;
    input [row*bw-1:0] l0_in;
    input [psum_bw*col-1:0] sfp_in;    
    input simd; // 1. Add SIMD input port

    output l0_o_full;
    output l0_o_ready;
    output ofifo_o_full; 
    output ofifo_o_ready;
    output ofifo_valid;
    output [col*psum_bw-1:0] ofifo_out;
    output [psum_bw*col-1:0] sfp_out; 

    //Wire declaration
    wire [psum_bw*col-1:0] mac_out_s;   
    wire [row*bw-1:0] mac_in_w;         
    wire [1:0] mac_inst_w;
    wire [col-1:0] mac_valid;  
    wire l0_wr;                         
    wire l0_rd;                         
    wire ofifo_rd;                     
    wire acc;                           
    assign acc = inst[33];
    assign ofifo_rd = inst[6];
    assign l0_rd = inst[3];
    assign l0_wr = inst[2];
    assign mac_inst_w = inst[1:0];

    //Instantiation
   l0 #(.row(row), .bw(bw)) l0_instance(
        .clk(clk),
        .wr(l0_wr),
        .rd(l0_rd),
        .reset(reset),
        .in(l0_in),
        .out(mac_in_w),  
        .o_full(l0_o_full),
        .o_ready(l0_o_ready)
    );

    mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance(
        .clk(clk),
        .reset(reset),
        .out_s(mac_out_s),
        .in_w(mac_in_w),
        .inst_w(mac_inst_w),
        .in_n(), //no data from the north in weight stationary mode
        .valid(mac_valid),
        .simd(simd) // 2. Pass SIMD to mac_array
    );

    ofifo #(.col(col), .bw(psum_bw)) ofifo_instance(
        .clk(clk),
        .wr(mac_valid),   
        .rd(ofifo_rd),
        .reset(reset),
        .in(mac_out_s),  
        .out(ofifo_out),
        .o_full(ofifo_o_full),
        .o_ready(ofifo_o_ready),
        .o_valid(ofifo_valid)     
    );

    generate
    genvar i;
    for (i=1; i<col+1; i=i+1) begin : sfp_num
        sfp #(.bw(bw), .psum_bw(psum_bw)) sfp_instance(
            .clk(clk),
            .acc(acc),
            .reset(reset),
            .simd(simd), // 3. Pass SIMD to each SFP module
            .in(sfp_in[psum_bw*i-1: psum_bw*(i-1)]),
            .out(sfp_out[psum_bw*i-1: psum_bw*(i-1)]));
    end
    endgenerate

endmodule