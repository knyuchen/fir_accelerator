/*
  Operation is triggered by input_sample.valid
  Output with {add_done, par_out}
  
  Cross Latency: 2 cycles
  Auto Latency: 0 cycles

  Revisions:
    10/13/21:
      First Documentation, interchanged mult opa / opb
*/
module FIR_mac (
   input  FIR_DATA_BUS   input_sample,
   input  FIR_DATA_SAMPLE tap,
   input  FIR_DATA_SAMPLE par_in,
   input                  mode, // 0 for cross, 1 for auto 
   output FIR_DATA_SAMPLE par_out,
   output logic           add_done,
   input  FIR_SHIFT             shift, 
   input                  clk,
   input                  rst_n
);

   FIR_DATA_SAMPLE  mult_opa, mult_opb, add_opa, add_opb;
   FIR_DATA_SAMPLE  mult_out, add_out;

   logic  mult_valid, mult_done, add_valid;

   assign mult_valid = input_sample.valid == 1 && mode == 0;
   assign add_valid = (mode == 0) ?  mult_done : input_sample.valid;

   assign mult_opa = (mult_valid == 1) ? tap : 0;
   assign mult_opb = (mult_valid == 1) ? input_sample.data : 0;

   assign add_opa = (add_valid == 0) ? 0 : ((mode == 0) ? mult_out : input_sample.data);

   assign add_opb = (add_valid == 1) ? par_in : 0;
/*
  2 cycles for mult
  0 cycles for add
*/
   pipe_reg #(.WIDTH(1), .STAGE(2)) pipe_mult_valid   (.in(mult_valid),    .out(mult_done),    .*);
   pipe_reg #(.WIDTH(1), .STAGE(0)) pipe_add_valid   (.in(add_valid),    .out(add_done),    .*);

   FIR_cmult fcm1 (
      .*,
      .opa(mult_opa),
      .opb(mult_opb),
      .out(mult_out)
   );

   FIR_cadd fca1 (
      .*,
      .opa(add_opa),
      .opb(add_opb),
      .out(add_out)
   );

   assign par_out = add_out;

endmodule
