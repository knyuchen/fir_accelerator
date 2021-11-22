module test ();
   logic clk, rst_n;
   clk_gen c1 (.*);

   FIR_CONT_TO_TILE  cont_to_tile_in, cont_to_tile_out;

   logic next_ready, ready;

   FIR_TAP_LOAD tap_in, tap_out;

   FIR_TILE_TO_TILE  from_prev_tile, to_next_tile_out;


   assign next_ready = 1;
   assign scaling = 0;
  

   initial from_prev_tile = 0;
   initial cont_to_tile_in = 0;
   initial tap_in = 0;

   FIR_tile  ft1 (.*);


   initial begin
      #(`RESET_CYCLE*`CLK_CYCLE)
      #(3*`CLK_CYCLE)
      @(negedge clk)
      cont_to_tile_in.valid = 1;
      cont_to_tile_in.num = 2;
      cont_to_tile_in.mode = 0;
      @(negedge clk)
      cont_to_tile_in = 0;
      @(negedge clk)
      @(negedge clk)
      @(negedge clk)
      @(negedge clk)
      tap_in.valid = 1;
      tap_in.data = {16'd2, 16'd0};
      tap_in.count = 1;
      @(negedge clk)
      tap_in.valid = 1;
      tap_in.data = {16'd3, 16'd0};
      tap_in.count = 0;
      @(negedge clk)
      tap_in = 0;
      @(negedge clk)
      @(negedge clk)
      @(negedge clk)
      for (integer i = 0; i < 64; i = i + 1) begin
      @(negedge clk)
      from_prev_tile.input_sample.valid = 1;
      from_prev_tile.input_sample.data.data_r = i + 1;
      from_prev_tile.input_sample.data.data_i = 0;
      end
      @(negedge clk)
      from_prev_tile = 0;
      #(20*`CLK_CYCLE)
      $finish();
   end

endmodule
