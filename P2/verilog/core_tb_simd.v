// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Modified for CSE 240A Part 2: SIMD Verification (ALL FIXES APPLIED)
`timescale 1ns/1ps

module core_tb_simd;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter col = 8;
parameter row = 8;

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

reg simd_en = 1; 

reg [1:0]  inst_w;
reg [bw*row-1:0] D_xmem;
reg [col*psum_bw-1:0] answer;

reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;

wire ofifo_valid;
wire [col*psum_bw-1:0] sfp_out;

integer x_file, x_scan_file;
integer w_file, w_scan_file;
integer acc_file, acc_scan_file;
integer out_file, out_scan_file;
integer t, i, j, k, kij, pass;
integer error;

// Buffers
reg [31:0] w_line_0;
reg [31:0] w_line_1;
reg signed [15:0] hw_act_sum;
reg signed [7:0]  hw_lane0;
reg signed [7:0]  hw_lane1;
reg signed [15:0] ref_val;

assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = simd_en; 
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

  $dumpfile("core_tb_simd.vcd");
  $dumpvars(0,core_tb_simd);

  // File Setup
  // [FIX 2] Force Update acc_address.txt with correct stride (20)
  // Because execution phase writes 20 words per kij step.
  acc_file = $fopen("acc_address.txt", "w"); 
  for(i=0; i<9; i=i+1) $fwrite(acc_file, "%011b\n", i*20);
  $fclose(acc_file);
  acc_file = $fopen("acc_address.txt", "r");

  x_file = $fopen("activationSIMD.txt", "r");
  w_file = $fopen("weightSIMD.txt", "r");
  out_file = $fopen("output_ref_SIMD.txt", "r");

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1; 
  for (i=0; i<10 ; i=i+1) begin #0.5 clk = 1'b0; #0.5 clk = 1'b1; end
  #0.5 clk = 1'b0;   reset = 0; #0.5 clk = 1'b1;
  #0.5 clk = 1'b0;   #0.5 clk = 1'b1;   

  /////// Load Activation to SRAM ///////
  t = 0;
  for (i=0; i<64; i=i+1) begin  
    #0.5 clk = 1'b0;
    if (i < 16) x_scan_file = $fscanf(x_file,"%h", D_xmem); 
    else D_xmem = 0; 

    WEN_xmem = 0; CEN_xmem = 0; 
    if (t>0) A_xmem = A_xmem + 1;
    t = t + 1;
    #0.5 clk = 1'b1;   
  end
  #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0; #0.5 clk = 1'b1; 
  $fclose(x_file);


  for (kij=0; kij<9; kij=kij+1) begin  

    w_scan_file = $fscanf(w_file,"%h", w_line_0);
    w_scan_file = $fscanf(w_file,"%h", w_line_1);

    #0.5 clk = 1'b0;   reset = 1; #0.5 clk = 1'b1;
    for (i=0; i<5 ; i=i+1) begin #0.5 clk = 1'b0; #0.5 clk = 1'b1; end
    #0.5 clk = 1'b0;   reset = 0; #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0;   #0.5 clk = 1'b1;   

    // --- Weight Loading (Pass 0 & 1) ---
    for (pass=0; pass < 2; pass=pass+1) begin
        A_xmem = 11'b10000000000;
        
        // 1. SRAM Load
        for (t=0; t<col; t=t+1) begin 
          #0.5 clk = 1'b0;
          D_xmem = 0; 
          if (pass == 0) D_xmem[3:0] = w_line_0[(t*4) +: 4];
          else           D_xmem[3:0] = w_line_1[(t*4) +: 4];
          WEN_xmem = 0; CEN_xmem = 0; 
          if (t>0 || A_xmem > 11'b10000000000) A_xmem = A_xmem + 1;
          #0.5 clk = 1'b1;  
        end
        #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0; #0.5 clk = 1'b1; 
        
        for (t=0; t<6; t=t+1) begin
          #0.5 clk = 1'b0; D_xmem = 0; WEN_xmem = 0; CEN_xmem = 0; A_xmem = A_xmem + 1;
          #0.5 clk = 1'b1;  
        end

        #0.5 clk = 1'b0;  WEN_xmem = 1;  CEN_xmem = 1; A_xmem = 0; #0.5 clk = 1'b1; 
        for (i=0; i<5 ; i=i+1) begin #0.5 clk = 1'b0; #0.5 clk = 1'b1; end 

        // 2. SRAM -> L0
        A_xmem = 11'b10000000000;
        #0.5 clk = 1'b0; WEN_xmem=1; CEN_xmem=0; #0.5 clk = 1'b1; 
        
        #0.5 clk = 1'b0; #0.5 clk = 1'b1; 

        for (t=0; t<col+4; t=t+1) begin  
          #0.5 clk = 1'b0;  
          l0_wr = 1; // [FIX 1] Always write padding to avoid X
          if (t<col) A_xmem = A_xmem + 1; 
          #0.5 clk = 1'b1;  
        end
        #0.5 clk = 1'b0;  WEN_xmem=1; CEN_xmem=1; A_xmem=0; l0_wr=0; #0.5 clk = 1'b1;
        for (i=0; i<5 ; i=i+1) begin #0.5 clk = 1'b0; #0.5 clk = 1'b1; end 

        // 3. L0 -> PE
        #0.5 clk = 1'b0; l0_rd = 1; #0.5 clk = 1'b1;
        for (t=0; t<col+2; t=t+1) begin
          #0.5 clk = 1'b0; load=1; #0.5 clk = 1'b1;
        end
        #0.5 clk = 1'b0; load = 0; l0_rd = 0; #0.5 clk = 1'b1;
        for (i=0; i<5 ; i=i+1) begin #0.5 clk = 1'b0; #0.5 clk = 1'b1; end 
    end 

    // --- Activation to L0 ---
    A_xmem = 0;
    #0.5 clk = 1'b0; WEN_xmem=1; CEN_xmem=0; #0.5 clk = 1'b1; 
    
    #0.5 clk = 1'b0; #0.5 clk = 1'b1; 

    for (t=0; t < 50; t=t+1) begin  
      #0.5 clk = 1'b0;  l0_wr = 1; 
      A_xmem = A_xmem + 1;         
      #0.5 clk = 1'b1;  
    end
    #0.5 clk = 1'b0;  WEN_xmem=1; CEN_xmem=1; A_xmem=0; l0_wr=0; #0.5 clk = 1'b1;

    // --- Execution ---
    #0.5 clk = 1'b0; l0_rd=1;
    #0.5 clk = 1'b1;
    for (t=0; t < 20; t=t+1) begin
        #0.5 clk = 1'b0; execute=1; #0.5 clk = 1'b1;
    end
    for (t=0; t<row+col+5; t=t+1) begin
        #0.5 clk = 1'b0; #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0;  l0_rd=0; execute=0; #0.5 clk = 1'b1;

    // --- OFIFO Read ---
    #0.5 clk = 1'b0; ofifo_rd=1; #0.5 clk = 1'b1;
    for (t=0; t < 20; t=t+1) begin   
        #0.5 clk = 1'b0;
        WEN_pmem=0; CEN_pmem=0; if (t>0 | A_pmem>0) A_pmem = A_pmem + 1; 
        #0.5 clk = 1'b1;
    end
    #0.5 clk = 1'b0;  ofifo_rd=0; WEN_pmem=1; CEN_pmem=1; #0.5 clk = 1'b1;

    $display("SIMD kij=%d is completed", kij);
  end  
  $fclose(w_file);

  #0.5 clk = 1'b0; #0.5 clk = 1'b1; 

  ////////// Accumulation & Verification /////////
  error = 0;
  $display("############ Verification Start (SIMD) #############");

  for (i=0; i < 8; i=i+1) begin 
    #0.5 clk = 1'b0; #0.5 clk = 1'b1;
    out_scan_file = $fscanf(out_file,"%h", answer);
    
    // 1. Reset SFP Accumulator
    #0.5 clk = 1'b0; reset = 1; #0.5 clk = 1'b1;  
    #0.5 clk = 1'b0; reset = 0; #0.5 clk = 1'b1;

    // 2. [FIX] Calculate address directly, do not read from file
    // Base address calculation: (i * 20) + 10
    // We need to provide the first address before accumulation starts
    
    #0.5 clk = 1'b0;
    acc = 0; 
    CEN_pmem = 0; WEN_pmem = 1; 
    A_pmem = (i * 20) + 10; // Prefetch address for offset 0
    #0.5 clk = 1'b1; 

    // 3. Loop Accumulation (Cycle 0 to 8)
    for (j=0; j<len_kij; j=j+1) begin 
        #0.5 clk = 1'b0;
        acc = 1; // Enable accumulation, capture data requested in the previous cycle

        // Prepare address for "next cycle": Base + (j + 1)
        if (j < len_kij - 1) begin
             A_pmem = (i * 20) + 10 + (j + 1);
        end else begin
             CEN_pmem = 1; // No need to read a new address for the last iteration
        end
        #0.5 clk = 1'b1;
    end

    // 4. Stop Accumulation
    #0.5 clk = 1'b0; acc = 0; #0.5 clk = 1'b1;
    
    // 5. Result Comparison
    hw_lane0 = sfp_out[i*16 +: 8];
    hw_lane1 = sfp_out[(i*16+8) +: 8];
    hw_act_sum = hw_lane0 + hw_lane1;
    ref_val  = answer[i*16 +: 16];

    if (hw_act_sum == ref_val)
         $display("Row %d: Output Matched! :D (HW: %h == Ref: %h)", i, hw_act_sum, ref_val);
    else begin
         $display("Row %d: Output ERROR!!", i); 
         $display("Expected: %h", ref_val);
         $display("Actual Sum: %h (Lane0: %h, Lane1: %h)", hw_act_sum, hw_lane0, hw_lane1);
         error = 1;
    end
    #0.5 clk = 1'b0; #0.5 clk = 1'b1;
  end

  $fclose(acc_file);
  $fclose(out_file);
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