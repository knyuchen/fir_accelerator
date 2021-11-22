module test ();
   logic clk, rst_n;
   clk_gen c1 (.*);

   FIR_CONT_TO_TILE  from_cont;

   logic next_ready, ready;

   FIR_TAP_LOAD input_tap;

   FIR_DATA_BUS  from_input, to_output;


   assign next_ready = 1;
  

   initial from_cont = 0;
   initial from_input = 0;
   initial input_tap = 0;

   FIR_comp  ft1 (.*);


   initial begin
      #(`RESET_CYCLE*`CLK_CYCLE)
      #(3*`CLK_CYCLE)
      @(negedge clk)
      from_cont.valid = 1;
      from_cont.num = 6;
      from_cont.mode = 1;
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
      for (integer i = 0; i < 64; i = i + 1) begin
      @(negedge clk)
      from_input.valid = 1;
      from_input.data.data_r = i + 1;
      from_input.data.data_i = 0;
      end
      @(negedge clk)
      from_input = 0;
      #(20*`CLK_CYCLE)
      $finish();
   end

endmodule
