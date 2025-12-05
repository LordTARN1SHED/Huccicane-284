// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
//1. an extra acc_address.txt is needed to fetch the psum within the same 3*3 kernel and accumulate
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

wire [33:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
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

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col-1:0] answer;


reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*30:1] w_file_name;
wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;

integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij;
integer error;

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

  x_file = $fopen("./activation/activation.txt", "r");   // modify path later
  // Following three lines are to remove the first three comment lines of the file
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);
  x_scan_file = $fscanf(x_file,"%s", captured_data);

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 

  /*for (i=0; i<10 ; i=i+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;  
  end*/

  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1; 

  #0.5 clk = 1'b0;   
  #0.5 clk = 1'b1;  
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t=0; t<len_nij; t=t+1) begin  
    #0.5 clk = 1'b0;  x_scan_file = $fscanf(x_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
    #0.5 clk = 1'b1;   
  end

  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
  #0.5 clk = 1'b1; 

  $fclose(x_file);
  /////////////////////////////////////////////////


  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    case(kij)   // modify path later
     0: w_file_name = "./weights/weight0.txt";
     1: w_file_name = "./weights/weight1.txt";
     2: w_file_name = "./weights/weight2.txt";
     3: w_file_name = "./weights/weight3.txt";
     4: w_file_name = "./weights/weight4.txt";
     5: w_file_name = "./weights/weight5.txt";
     6: w_file_name = "./weights/weight6.txt";
     7: w_file_name = "./weights/weight7.txt";
     8: w_file_name = "./weights/weight8.txt";
     /*0: w_file_name = "weight_itile0_otile0_kij0.txt";
     1: w_file_name = "weight_itile0_otile0_kij1.txt";
     2: w_file_name = "weight_itile0_otile0_kij2.txt";
     3: w_file_name = "weight_itile0_otile0_kij3.txt";
     4: w_file_name = "weight_itile0_otile0_kij4.txt";
     5: w_file_name = "weight_itile0_otile0_kij5.txt";
     6: w_file_name = "weight_itile0_otile0_kij6.txt";
     7: w_file_name = "weight_itile0_otile0_kij7.txt";
     8: w_file_name = "weight_itile0_otile0_kij8.txt";*/
    endcase
    

    w_file = $fopen(w_file_name, "r");
    // Following three lines are to remove the first three comment lines of the file
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);
    w_scan_file = $fscanf(w_file,"%s", captured_data);

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

    for (t=0; t<col; t=t+1) begin   // load into xmem
      #0.5 clk = 1'b0;  w_scan_file = $fscanf(w_file,"%32b", D_xmem); WEN_xmem = 0; CEN_xmem = 0; if (t>0) A_xmem = A_xmem + 1;
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0;
    #0.5 clk = 1'b1; 
    /////////////////////////////////////
    /*for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end*/


    /////// Kernel data writing to L0 ///////
    A_xmem = 11'b10000000000;

    #0.5 clk = 1'b0; WEN_xmem=1; CEN_xmem=0; // xmem read operation
    #0.5 clk = 1'b1;

    for (t=0; t<col; t=t+1) begin  
      #0.5 clk = 1'b0;  l0_wr = 1; if (t>0) A_xmem = A_xmem + 1; 
      #0.5 clk = 1'b1;  
    end

    #0.5 clk = 1'b0;  WEN_xmem=1;  CEN_xmem=1; A_xmem=0;
    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0;  l0_wr=0;
    #0.5 clk = 1'b1;

   /*for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end*/
    /////////////////////////////////////
  


    /////// Kernel loading to PEs ///////
    #0.5 clk = 1'b0; l0_rd = 1;
    #0.5 clk = 1'b1;

    for (t=0; t<col; t=t+1) begin
      #0.5 clk = 1'b0;  load=1;  // load weight into mac_array
      #0.5 clk = 1'b1;
    end
    /////////////////////////////////////
  


    ////// provide some intermission to clear up the kernel loading ///
    #0.5 clk = 1'b0;  load = 0; l0_rd = 0;
    #0.5 clk = 1'b1;  


    /*for (i=0; i<10 ; i=i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;  
    end*/
    /////////////////////////////////////
// ============================================================
   // ============================================================
    // Alpha 3 Fix: Single-Loop Full Parallelism (Super Loop)
    // 解决了 Manual Clock 的冲突问题，同时实现读写并行
    // ============================================================
    
    // 1. 初始化
    #0.5 clk = 1'b0; 
    A_xmem = 0; WEN_xmem = 1; CEN_xmem = 0; // 准备读 SRAM (Input)
    l0_wr = 0; l0_rd = 0; execute = 0; ofifo_rd = 0;
    #0.5 clk = 1'b1;

    // 2. 超级循环：总时长 = 计算所需时长 + 启动延迟
    // 我们让 Consumer (计算) 比 Producer (写入) 晚 2 个周期启动 (Lag=2)
    // 总时长覆盖：Write(38) 和 Read/Exec(54) 的重叠部分
    for (t=0; t<56; t=t+1) begin
        #0.5 clk = 1'b0; 
        
        // --- 任务 A: Producer (写入 L0) ---
        // 也就是原来的第一个循环，在前 38 个周期运行
        if (t < 38) begin
            l0_wr = 1;
            if (t > 0) A_xmem = A_xmem + 1; // 地址递增
        end else begin
            l0_wr = 0; // 写完了，停手
            WEN_xmem = 1; CEN_xmem = 1; A_xmem = 0; // 关掉 SRAM
        end

        // --- 任务 B: Consumer (读取 L0 & 计算) ---
        // 也就是原来的第二个循环，但在 t=2 时就提前启动 (Lag=2)
        if (t >= 2) begin
            l0_rd = 1; // 开始读 FIFO
            
            // 相对时间 k = t - 2
            // 原逻辑：if(k>0) execute=1 -> 对应 t > 2
            if (t > 2) execute = 1; 
            
            // 原逻辑：if(k>16) ofifo_rd=1 -> 对应 t > 18
            if (t > 18) ofifo_rd = 1;
            
            // 原逻辑：if(k>17) 写回 PMEM -> 对应 t > 19
            if (t > 19) begin
                WEN_pmem = 0; CEN_pmem = 0;
                // 原逻辑：if(k>18 || A_pmem>0) -> 对应 t > 20
                if (t > 20 || A_pmem > 0) A_pmem = A_pmem + 1;
            end
        end 
        
        #0.5 clk = 1'b1;
    end

    // 3. 善后清理
    #0.5 clk = 1'b0; 
    l0_rd=0; execute=0; ofifo_rd=0; WEN_pmem=1; CEN_pmem=1;
    #0.5 clk = 1'b1;

  


    $display("kij=%d is completed", kij);

  end  // end of kij loop

  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1; 

  ////////// Accumulation /////////
  acc_file = $fopen("./acc_address.txt", "r");  //SFP  
  out_file = $fopen("./output/output_after_relu.txt", "r");   // need to modify file path

  // Following three lines are to remove the first three comment lines of the file
  //out_scan_file = $fscanf(out_file,"%s", answer); 
  //out_scan_file = $fscanf(out_file,"%s", answer); 
  //out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<len_onij+1; i=i+1) begin 

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

    for (j=0; j<len_kij+1; j=j+1) begin 

      #0.5 clk = 1'b0;   
        if (j<len_kij) begin CEN_pmem = 0; WEN_pmem = 1; acc_scan_file = $fscanf(acc_file,"%11b", A_pmem); end
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
$display("Total Cycles: %d", $time);
  end

  $fclose(acc_file);
  //////////////////////////////////

  /*for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
  end*/

  #10 $finish;

end

always @ (posedge clk) begin
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




