module test ();
   logic clk, rst_n;
   clk_gen c1 (.*);

   FIR_CONT_TO_TILE  from_cont;

   logic next_ready, ready;

   FIR_TAP_LOAD input_tap;

   FIR_DATA_BUS  from_input, to_output;


  

   initial from_cont = 0;
   initial input_tap = 0;


   FIR_comp  ft1 (.*);

   logic in_next_ready, in_ready;
   assign in_next_ready = ready;
   FIR_DATA_BUS  data_in, data_out;
   assign from_input = data_out;
   FIR_CONT_TO_IN cont_to_in;

//   initial data_in = 0;
   initial cont_to_in = 0;

   FIR_in fi1 (.*, .next_ready(in_next_ready), .ready(in_ready));

   FIR_CONT_TO_OUT_RATE  cont_rate_out;

   FIR_DATA_BUS  to_dma, to_compute, dma_out;
   logic  dma_ready, out_rate_ready;

   initial cont_rate_out = 0;


   assign next_ready = out_rate_ready;
   out_rate or1 (.*, .from_cont(cont_rate_out), .compute_out(to_output)); 

   assign dma_ready = 1;
   
   FIR_CONT_TO_IN_RATE  cont_rate_in;
   initial cont_rate_in = 0;
   assign data_in = to_compute;
   initial dma_out = 0;
   logic last_in;
   initial last_in = 0;
   logic in_rate_ready;

   in_rate ir1 (.*, .from_cont(cont_rate_in));
    
   initial begin
      #(`RESET_CYCLE*`CLK_CYCLE)
      #(3*`CLK_CYCLE)
      @(negedge clk)
      from_cont.valid = 1;
      from_cont.num = 6;
      from_cont.mode = 0;

      cont_to_in.delay = 0;
      cont_to_in.mode = 0;
      cont_to_in.shift = 0;

      cont_rate_out.rate = 1;
      cont_rate_in.tail = 5;
      @(negedge clk)
      from_cont = 0;
      @(negedge clk)
      @(negedge clk)
      @(negedge clk)
      for (integer j = 6; j > 0; j = j - 1) begin
      @(negedge clk)
      input_tap.valid = 1;
      input_tap.data.data_r = j;
      input_tap.data.data_i = 0;
      input_tap.count = j-1;
      end
      @(negedge clk)
      input_tap = 0;
      @(negedge clk)
      @(negedge clk)
      @(negedge clk)
      for (integer i = 0; i < 63; i = i + 1) begin
      @(negedge clk)
      dma_out.valid = 1;
      dma_out.data.data_r = i + 1;
      dma_out.data.data_i = 0;
      end
      @(negedge clk)
      dma_out.valid = 1;
      dma_out.data.data_r = 64;
      dma_out.data.data_i = 0;
      last_in = 1;
      @(negedge clk)
      dma_out = 0;
      last_in = 0;
      #(200*`CLK_CYCLE)
      $finish();
   end

endmodule
