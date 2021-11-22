/*
  Latency: 3 / 1
  Revisions:
    10/13/21:
      First Documentation
*/
module FIR_PE (
   input                 clk,
   input                 rst_n,
/*
   Configs
*/
   input    FIR_TILE_TO_PE tile_to_pe,
/*
   Input sample (input to output)
*/ 
   input    FIR_DATA_BUS     input_sample, // can be actual sample in cross mode or multiplied sample in auto mode
/*
   Passing Taps (output to input)
*/
   input    FIR_TAP_LOAD   tap_in,
   output   FIR_TAP_LOAD   tap_out,
/*
   Partial Sum (input to output)
*/
   input    FIR_DATA_BUS  from_prev_pe,
   output   FIR_DATA_BUS  to_next_pe
);

   FIR_DATA_BUS to_next_pe_w;
   FIR_DATA_SAMPLE par_out;
   FIR_DATA_SAMPLE tap, tap_w;
   FIR_TAP_LOAD tap_out_w;
/*
   some input gating
*/
// cmult result comes out in the same cycle
   logic real_valid, add_done;
   FIR_DATA_BUS real_in;
/*
  0 latency input gating
*/ 
   assign real_valid = input_sample.valid == 1 && tile_to_pe.flush == 0 && tile_to_pe.enable == 1;
   assign real_in.valid = real_valid;
   assign real_in.data = (real_valid == 1) ? input_sample.data : 0;

   FIR_mac fcm1 (
      .input_sample(real_in),
      .par_in(from_prev_pe.data),
      .mode(tile_to_pe.mode),
      .shift(tile_to_pe.shift),
      .*
   );

   always_comb begin
/*
  always hold data because you don't know when the next stage is going to need it 
*/
      to_next_pe_w.data = to_next_pe.data;
      to_next_pe_w.valid = 0;
      if (tile_to_pe.flush == 1) begin
         to_next_pe_w = 0;
      end
/*
  valid is only useful at the tile's level
*/
      else if (add_done == 1) begin
         to_next_pe_w.data = par_out;
         to_next_pe_w.valid = 1;
      end
/*
   Not enabled, just passing partial sum 
*/
      else if (tile_to_pe.enable == 0) begin
         to_next_pe_w = from_prev_pe;
      end
   end

   always_comb begin
      tap_w = tap;
      tap_out_w = 0;
/*
  count = 0 -> for me, latch tap
       != 0 -> not for me count - 1
*/
      if (tap_in.valid == 1) begin
         if (tap_in.count == 0) tap_w = tap_in.data;
         else begin
            tap_out_w.valid = 1;
            tap_out_w.data = tap_in.data;
            tap_out_w.count = tap_in.count - 1;
         end
      end
   end

   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         to_next_pe <= 0;
         tap <= 0;
         tap_out <= 0;
      end
      else begin
         to_next_pe <= to_next_pe_w;
         tap <= tap_w;
         tap_out <= tap_out_w;
      end
   end
   

endmodule
