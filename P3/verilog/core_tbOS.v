// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
//1. an extra acc_address.txt is needed to fetch the psum in different input channels and accumulate
//2. extra cycle for acc at the end to fetch the final sfp_out
//3. output.txt format: 
/*   channel8.......channel1
psum1
psum2
...
psum16
128bits (8 numbers) for each row to match the sfp_out
*/
//4. relu operation is needed
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;

reg clk = 0;
reg reset = 1;

wire [34:0] inst_q; //34

reg [2:0]  inst_w_q = 0; //change inst_w
reg [bw*row-1:0] D_xmem_q = 0;
reg CEN_xmem = 1;
reg WEN_xmem = 1;
reg [10:0] A_xmem = 0;
reg CEN_xmem_q = 1;
reg WEN_xmem_q = 1;
reg [10:0] A_xmem_q = 0;
reg CEN_pmem = 1;
reg WEN_pmem = 1;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 1;
reg WEN_pmem_q = 1;
reg [10:0] A_pmem_q = 0;
reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;
reg mode_q = 0;//add mode

reg [2:0]  inst_w; //
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;


reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [9*50:1] stringvar;//
reg [9*50:1] w_file_name;//change into 9
reg [9*50:1] x_file_name;//add
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;
reg mode;//add new signal

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij, ic;
integer error;

assign inst_q[34] = mode_q;//
assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 


core  #(.bw(bw), .col(col), .row(row)) core_instance (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
        .D_xmem(D_xmem_q), 
        .sfp_out(sfp_out), 
	.reset(reset)); 


initial begin 
  mode     = 0;//for output stationary
  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  


  for (kij=0; kij<64; kij=kij+1) begin  // ic loop

    case(kij)   // modify path later
0: begin
w_file_name = "./weights/weightOS0.txt"; x_file_name = "./activation/activationOS0.txt"; end
1: begin
w_file_name = "./weights/weightOS1.txt"; x_file_name = "./activation/activationOS1.txt"; end
2: begin
w_file_name = "./weights/weightOS2.txt"; x_file_name = "./activation/activationOS2.txt"; end
3: begin
w_file_name = "./weights/weightOS3.txt"; x_file_name = "./activation/activationOS3.txt"; end
4: begin
w_file_name = "./weights/weightOS4.txt"; x_file_name = "./activation/activationOS4.txt"; end
5: begin
w_file_name = "./weights/weightOS5.txt"; x_file_name = "./activation/activationOS5.txt"; end
6: begin
w_file_name = "./weights/weightOS6.txt"; x_file_name = "./activation/activationOS6.txt"; end
7: begin
w_file_name = "./weights/weightOS7.txt"; x_file_name = "./activation/activationOS7.txt"; end
8: begin
w_file_name = "./weights/weightOS8.txt"; x_file_name = "./activation/activationOS8.txt"; end
9: begin
w_file_name = "./weights/weightOS9.txt"; x_file_name = "./activation/activationOS9.txt"; end
10: begin
w_file_name = "./weights/weightOS10.txt"; x_file_name = "./activation/activationOS10.txt"; end
11: begin
w_file_name = "./weights/weightOS11.txt"; x_file_name = "./activation/activationOS11.txt"; end
12: begin
w_file_name = "./weights/weightOS12.txt"; x_file_name = "./activation/activationOS12.txt"; end
13: begin
w_file_name = "./weights/weightOS13.txt"; x_file_name = "./activation/activationOS13.txt"; end
14: begin
w_file_name = "./weights/weightOS14.txt"; x_file_name = "./activation/activationOS14.txt"; end
15: begin
w_file_name = "./weights/weightOS15.txt"; x_file_name = "./activation/activationOS15.txt"; end
16: begin
w_file_name = "./weights/weightOS16.txt"; x_file_name = "./activation/activationOS16.txt"; end
17: begin
w_file_name = "./weights/weightOS17.txt"; x_file_name = "./activation/activationOS17.txt"; end
18: begin
w_file_name = "./weights/weightOS18.txt"; x_file_name = "./activation/activationOS18.txt"; end
19: begin
w_file_name = "./weights/weightOS19.txt"; x_file_name = "./activation/activationOS19.txt"; end
20: begin
w_file_name = "./weights/weightOS20.txt"; x_file_name = "./activation/activationOS20.txt"; end
21: begin
w_file_name = "./weights/weightOS21.txt"; x_file_name = "./activation/activationOS21.txt"; end
22: begin
w_file_name = "./weights/weightOS22.txt"; x_file_name = "./activation/activationOS22.txt"; end
23: begin
w_file_name = "./weights/weightOS23.txt"; x_file_name = "./activation/activationOS23.txt"; end
24: begin
w_file_name = "./weights/weightOS24.txt"; x_file_name = "./activation/activationOS24.txt"; end
25: begin
w_file_name = "./weights/weightOS25.txt"; x_file_name = "./activation/activationOS25.txt"; end
26: begin
w_file_name = "./weights/weightOS26.txt"; x_file_name = "./activation/activationOS26.txt"; end
27: begin
w_file_name = "./weights/weightOS27.txt"; x_file_name = "./activation/activationOS27.txt"; end
28: begin
w_file_name = "./weights/weightOS28.txt"; x_file_name = "./activation/activationOS28.txt"; end
29: begin
w_file_name = "./weights/weightOS29.txt"; x_file_name = "./activation/activationOS29.txt"; end
30: begin
w_file_name = "./weights/weightOS30.txt"; x_file_name = "./activation/activationOS30.txt"; end
31: begin
w_file_name = "./weights/weightOS31.txt"; x_file_name = "./activation/activationOS31.txt"; end
32: begin
w_file_name = "./weights/weightOS32.txt"; x_file_name = "./activation/activationOS32.txt"; end
33: begin
w_file_name = "./weights/weightOS33.txt"; x_file_name = "./activation/activationOS33.txt"; end
34: begin
w_file_name = "./weights/weightOS34.txt"; x_file_name = "./activation/activationOS34.txt"; end
35: begin
w_file_name = "./weights/weightOS35.txt"; x_file_name = "./activation/activationOS35.txt"; end
36: begin
w_file_name = "./weights/weightOS36.txt"; x_file_name = "./activation/activationOS36.txt"; end
37: begin
w_file_name = "./weights/weightOS37.txt"; x_file_name = "./activation/activationOS37.txt"; end
38: begin
w_file_name = "./weights/weightOS38.txt"; x_file_name = "./activation/activationOS38.txt"; end
39: begin
w_file_name = "./weights/weightOS39.txt"; x_file_name = "./activation/activationOS39.txt"; end
40: begin
w_file_name = "./weights/weightOS40.txt"; x_file_name = "./activation/activationOS40.txt"; end
41: begin
w_file_name = "./weights/weightOS41.txt"; x_file_name = "./activation/activationOS41.txt"; end
42: begin
w_file_name = "./weights/weightOS42.txt"; x_file_name = "./activation/activationOS42.txt"; end
43: begin
w_file_name = "./weights/weightOS43.txt"; x_file_name = "./activation/activationOS43.txt"; end
44: begin
w_file_name = "./weights/weightOS44.txt"; x_file_name = "./activation/activationOS44.txt"; end
45: begin
w_file_name = "./weights/weightOS45.txt"; x_file_name = "./activation/activationOS45.txt"; end
46: begin
w_file_name = "./weights/weightOS46.txt"; x_file_name = "./activation/activationOS46.txt"; end
47: begin
w_file_name = "./weights/weightOS47.txt"; x_file_name = "./activation/activationOS47.txt"; end
48: begin
w_file_name = "./weights/weightOS48.txt"; x_file_name = "./activation/activationOS48.txt"; end
49: begin
w_file_name = "./weights/weightOS49.txt"; x_file_name = "./activation/activationOS49.txt"; end
50: begin
w_file_name = "./weights/weightOS50.txt"; x_file_name = "./activation/activationOS50.txt"; end
51: begin
w_file_name = "./weights/weightOS51.txt"; x_file_name = "./activation/activationOS51.txt"; end
52: begin
w_file_name = "./weights/weightOS52.txt"; x_file_name = "./activation/activationOS52.txt"; end
53: begin
w_file_name = "./weights/weightOS53.txt"; x_file_name = "./activation/activationOS53.txt"; end
54: begin
w_file_name = "./weights/weightOS54.txt"; x_file_name = "./activation/activationOS54.txt"; end
55: begin
w_file_name = "./weights/weightOS55.txt"; x_file_name = "./activation/activationOS55.txt"; end
56: begin
w_file_name = "./weights/weightOS56.txt"; x_file_name = "./activation/activationOS56.txt"; end
57: begin
w_file_name = "./weights/weightOS57.txt"; x_file_name = "./activation/activationOS57.txt"; end
58: begin
w_file_name = "./weights/weightOS58.txt"; x_file_name = "./activation/activationOS58.txt"; end
59: begin
w_file_name = "./weights/weightOS59.txt"; x_file_name = "./activation/activationOS59.txt"; end
60: begin
w_file_name = "./weights/weightOS60.txt"; x_file_name = "./activation/activationOS60.txt"; end
61: begin
w_file_name = "./weights/weightOS61.txt"; x_file_name = "./activation/activationOS61.txt"; end
62: begin
w_file_name = "./weights/weightOS62.txt"; x_file_name = "./activation/activationOS62.txt"; end
63: begin
w_file_name = "./weights/weightOS63.txt"; x_file_name = "./activation/activationOS63.txt"; end
     
    endcase

//step1: load x into memory
     x_file = $fopen(x_file_name, "r");



  // Following three lines are to remove the first three comment lines of the file
  //x_scan_file = $fscanf(x_file,"%s", captured_data);
  //x_scan_file = $fscanf(x_file,"%s", captured_data);
  //x_scan_file = $fscanf(x_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t=0; t<9; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem);WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

$fclose(x_file);






//////////////////step2:load weight into memory
    w_file = $fopen(w_file_name, "r");
    
    // Following three lines are to remove the first three comment lines of the file
    //w_scan_file = $fscanf(w_file,"%s", captured_data);
   // w_scan_file = $fscanf(w_file,"%s", captured_data);
    //w_scan_file = $fscanf(w_file,"%s", captured_data);

    #0.5 clk = 1'b0;   reset = 1;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;   reset = 0;
    #0.5 clk = 1'b1; 

    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   

    /////// Kernel data writing to memory ///////

    A_xmem = 11'b10000000000;

    for (t=0; t<9; t=t+1) begin   // load into xmem,9 rows of data
      #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1; 
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////
    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
   


///////step3: Kernel data writing to ififo ///////
    A_xmem = 11'b10000000000;

    #0.5 clk = 1'b0; WEN_xmem=1; CEN_xmem=0; // xmem read operation
    #0.5 clk = 1'b1;

    for (t=0; t<9; t=t+1) begin  
      #0.5 clk = 1'b0;  ififo_wr = 1; if (t>0) A_xmem = A_xmem + 1; 
             //$time, A_xmem,D_xmem);
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem=1;  CEN_xmem=1; A_xmem=0;
    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0;  ififo_wr=0;
    #0.5 clk = 1'b1; 

    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////
  


  
  


    ////// provide some intermission to clear up the kernel loading ///
    #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;  


    for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end
    /////////////////////////////////////



    /////// step4: Activation data writing to L0 ///////
    A_xmem = 0;
    #0.5 clk = 1'b0; WEN_xmem=1; CEN_xmem=0; // xmem read operation
    #0.5 clk = 1'b1;

    for (t=0; t<9; t=t+1) begin  
      #0.5 clk = 1'b0;  l0_wr = 1; if (t>0) A_xmem = A_xmem + 1; //$display("Time=%0t, Writing to ififo: A_xmem=%0h, data=%b",$time, A_xmem,D_xmem);
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem=1;  CEN_xmem=1; A_xmem=0;
    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0;  l0_wr=0;
    #0.5 clk = 1'b1;
    /////////////////////////////////////



    ///////step5: Execution ///////
    #0.5 clk = 1'b0; l0_rd=1;ififo_rd=1;
    #0.5 clk = 1'b1;


    for (t=0; t<9; t=t+1) begin
        #0.5 clk = 1'b0; execute=1;
        #0.5 clk = 1'b1;
    end

   
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0;  l0_rd=0; execute=0;ififo_rd=0;load=1;
    #0.5 clk = 1'b1; 
    
    
    //////step6:write psum into ofifo
   
    for (t=0; t<16; t=t+1) begin  //  drain cycles to let the final computations complete
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0;  load=0;
    #0.5 clk = 1'b1;
    //////// OFIFO READ psum////////
    
    #0.5 clk = 1'b0; ofifo_rd=1; 
    #0.5 clk = 1'b1;

    for (t=0; t<8; t=t+1) begin   // Store to pmem
        #0.5 clk = 1'b0; WEN_pmem=0; CEN_pmem=0; if (t>0 | A_pmem>0) A_pmem = A_pmem + 1; 
        #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0;  ofifo_rd=0; WEN_pmem=1; CEN_pmem=1;
    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;


    /////////////////////////////////////


    $display("input channel=%d is completed", kij);

  end  // end of kij loop
/////////////////////////
  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1; 

  ////////// Accumulation /////////
  acc_file = $fopen("acc_address_OS.txt", "r");  //fetch address 
  out_file = $fopen("./output/Output_afterreluOS.txt", "r");   // need to modify file path

  // Following three lines are to remove the first three comment lines of the file
  //out_scan_file = $fscanf(out_file,"%s", answer); 
  //out_scan_file = $fscanf(out_file,"%s", answer); 
  //out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<8+1; i=i+1) begin 

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 

    if (i>0) begin
     out_scan_file = $fscanf(out_file,"%128b", answer); // reading from out file to answer
       if (sfp_out == answer)
         $display("%2d-th output featuremap Data matched! :D", i); 

       else begin
         $display("%2d-th output featuremap Data ERROR!!", i); 
         $display("sfpout: %128b", sfp_out);
         $display("answer: %128b", answer);
         error = 1;
       end
    end
   
 
    #0.5 clk = 1'b0; reset = 1;
    #0.5 clk = 1'b1;  
    #0.5 clk = 1'b0; reset = 0; 
    #0.5 clk = 1'b1;  

    for (j=0; j<64+1; j=j+1) begin 

      #0.5 clk = 1'b0;   
        if (j<64) begin CEN_pmem = 0; WEN_pmem = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); end
                       else  begin CEN_pmem = 1; WEN_pmem = 1; end

        if (j>0)  acc = 1;  
      #0.5 clk = 1'b1;   
    end

    #0.5 clk = 1'b0; acc = 0;
    #0.5 clk = 1'b1;

    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;

  end


  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  $fclose(acc_file);
  //////////////////////////////////

  for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end

  #10 $finish;

end

always @ (posedge clk) begin
   mode_q     <= mode;// add mode signal
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
end


endmodule




