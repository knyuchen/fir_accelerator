module FIR_comp (
   input                     clk,
   input                     rst_n,
   input  FIR_DATA_BUS       from_input,
   output FIR_DATA_BUS       to_output,
   input  FIR_TAP_LOAD       input_tap,
   input  FIR_CONT_TO_TILE   from_cont, 
   input               next_ready,
   output logic        ready

);
   // from previous & to next
   FIR_TILE_TO_TILE  ftt [`FIR_TILE_NUM : 0];
   FIR_TAP_LOAD  tap_load [`FIR_TILE_NUM : 0];
   // from next & to previous
   FIR_CONT_TO_TILE  cont_to_tile [`FIR_TILE_NUM : 0];
   
   assign cont_to_tile[0]  = from_cont;
   assign tap_load[0]  = input_tap;
  

   logic [`FIR_TILE_NUM : 0]  ready_pipe;

   assign ready = ready_pipe[`FIR_TILE_NUM];
   assign ready_pipe[0] = next_ready;
 
   assign ftt[`FIR_TILE_NUM].psum  = 0;
   assign ftt[`FIR_TILE_NUM].input_sample = from_input;
   genvar  i;
   generate 

     for (i = 0; i < `FIR_TILE_NUM; i = i + 1) begin
      FIR_tile  tt (
         .clk(clk),
         .rst_n(rst_n),
         .cont_to_tile_in(cont_to_tile[i]),
         .cont_to_tile_out(cont_to_tile[i+1]),
         .tap_in(tap_load[i]),
         .tap_out (tap_load[i+1]),
         .next_ready(ready_pipe[i]),
         .ready(ready_pipe[i+1]),
         .from_prev_tile (ftt[i+1]),
         .to_next_tile_out   (ftt[i])
      );

      end 

   endgenerate


   assign to_output = ftt[0];

endmodule
