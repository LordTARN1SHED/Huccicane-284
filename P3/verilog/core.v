module core (clk, reset, inst, D_xmem, ofifo_valid, sfp_out);
    parameter bw = 4;
    parameter psum_bw = 16;
    parameter col = 8;
    parameter row = 8;

    //input and output signals based on given testbench    
    input clk;
    input reset;
    input [34:0] inst;
    input [31:0] D_xmem;
    output ofifo_valid;
    output [127:0] sfp_out;
    
    
    //wire definition
    wire [127:0] sfp_in;
    wire [31:0] l0_in;
    wire [31:0] ififo_in; //
    wire ififo_o_full;
    wire ififo_o_ready;
    wire l0_o_full;
    wire l0_o_ready;
    wire [127:0] ofifo_out;
    wire ofifo_o_full;
    wire ofifo_o_ready;
    wire CEN_xmem;
    wire WEN_xmem;
    wire CEN_pmem;
    wire WEN_pmem;
    wire [10:0] A_pmem;
    wire [10:0] A_xmem;
    
    wire l0_wr;
    wire ififo_wr;
    wire [31:0] sram_out;
    
    assign l0_in = (l0_wr)?sram_out:0;
    assign ififo_in = (ififo_wr)?sram_out:0;
    assign l0_wr = inst[2];
    assign ififo_wr = inst[5];
    
    
    
    //inst[0:3],6,33 already declared in corelet.v;inst[5:4] not used for weight stationary
    assign CEN_pmem = inst[32];
    assign WEN_pmem = inst[31];
    assign A_pmem = inst[30:20];
    assign CEN_xmem = inst[19];
    assign WEN_xmem = inst[18];
    assign A_xmem = inst[17:7];

    //Instantiation
    corelet #(.row(row), .col(col), .bw(bw), .psum_bw(psum_bw)) corelet_instance(
        .clk(clk),
        .reset(reset),
        .ofifo_valid(ofifo_valid),
        .sfp_in(sfp_in),
        .sfp_out(sfp_out),
        .inst(inst),
        .l0_in(l0_in),
        .ififo_in(ififo_in),
        .ififo_o_full(ififo_o_full),
        .ififo_o_ready(ififo_o_ready),
        .l0_o_full(l0_o_full),
        .l0_o_ready(l0_o_ready),
        .ofifo_out(ofifo_out),
        .ofifo_o_full(ofifo_o_full),
        .ofifo_o_ready(ofifo_o_ready),
          .l0_wr(l0_wr),//
          .ififo_wr(ififo_wr));//
    
    sram_32b_w2048 input_sram(
        .CLK(clk), 
        .D(D_xmem), 
        .Q(sram_out),// 
        .CEN(CEN_xmem), 
        .WEN(WEN_xmem), 
        .A(A_xmem));
    

    sram_128b_w2048 psum_sram(
        .CLK(clk), 
        .D(ofifo_out), 
        .Q(sfp_in), 
        .CEN(CEN_pmem), 
        .WEN(WEN_pmem), 
        .A(A_pmem));


endmodule
