module corelet (clk, reset, ofifo_valid, sfp_in, sfp_out, inst, l0_in, ififo_in,ififo_o_full,ififo_o_ready, l0_o_full, l0_o_ready,  ofifo_out, ofifo_o_full, ofifo_o_ready,l0_wr,ififo_wr);             
    parameter row=8;
    parameter col=8;
    parameter bw=4;
    parameter psum_bw=16;

    //Input and Output declaration
    input clk;
    input reset;
    input [34:0] inst;//add mode selection
    input [row*bw-1:0] l0_in;
    input [col*bw-1:0] ififo_in;//add input from north
    input [psum_bw*col-1:0] sfp_in;   
    output l0_o_full;
    output l0_o_ready;
    output ififo_o_full;//
    output ififo_o_ready;//full and ready signal for ififo
    output ofifo_o_full; 
    output ofifo_o_ready;
    output ofifo_valid;
    output [col*psum_bw-1:0] ofifo_out;
    output [psum_bw*col-1:0] sfp_out; 

    //Wire declaration
    wire [psum_bw*col-1:0] mac_out_s;   
    wire [row*bw-1:0] mac_in_w;
    wire [col*bw-1:0] mac_in_n;//add input from north         
    wire [2:0] mac_inst_w;  //add mode selection          
    wire [col-1:0] mac_valid;  
    input l0_wr;                         
    wire l0_rd; 
    input ififo_wr;//
    wire ififo_rd;//ififo_rd and wr                        
    wire ofifo_rd;                     
    wire acc; 
    assign mac_inst_w[2] = inst[34];//mode selection,1 for transferring psum                          
    assign acc = inst[33];
    assign ofifo_rd = inst[6];
    assign l0_rd = inst[3];
    //assign l0_wr = inst[2];
    assign ififo_rd = inst[4];
    //assign ififo_wr = inst[4];///
    assign mac_inst_w[1:0] = inst[1:0];

    

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
     // add ififo instatiation
     l0 #(.row(col), .bw(bw)) ififo_instance(
        .clk(clk),
        .wr(ififo_wr),
        .rd(ififo_rd),
        .reset(reset),
        .in(ififo_in),
        .out(mac_in_n),  
        .o_full(ififo_o_full),
        .o_ready(ififo_o_ready)
    );  

    mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance(
        .clk(clk),
        .reset(reset),
        .out_s(mac_out_s),
        .in_w(mac_in_w),
        .inst_w(mac_inst_w),
        .in_n(mac_in_n), 
        .valid(mac_valid)
    );

    

    ofifo #(.col(col), .bw(psum_bw)) ofifo_instance(
        .clk(clk),
        .wr(mac_valid),   //write into ofifo when loading psum,cannot load weight into them
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
            //.relu(relu),
            .reset(reset),
            .in(sfp_in[psum_bw*i-1: psum_bw*(i-1)]),
            .out(sfp_out[psum_bw*i-1: psum_bw*(i-1)]));
    end
    endgenerate



endmodule
