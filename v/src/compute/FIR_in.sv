/*
  Input Latency: 0
  Internal Latency: 2 / 4
  Output Latency: 0
  Revisions:
    10/13/21:
      First Documentation
*/
module  FIR_in (
    input                   clk,
    input                   rst_n,
    input                   next_ready,
    output  logic           ready,
    input   FIR_DATA_BUS    data_in,
    output  FIR_DATA_BUS    data_out,
    input   FIR_CONT_TO_IN  cont_to_in
);

    FIR_DATA_BUS  data_out_pre, data_out_pre_w;
/*
   Output Buffer at the end
*/
   logic   full, empty, valid;
   logic   push, pop;
   logic [$bits(FIR_DATA_BUS) - 1 : 0]  wdata, rdata;

   d0fifo_wrap #(.SIZE(8), .WIDTH($bits(FIR_DATA_BUS))) d1 (.*, .flush(cont_to_in.flush == 1));  
   assign ready = empty;
   assign pop = next_ready;
   assign push = data_out_pre.valid;
   assign wdata = data_out_pre;
   assign data_out = rdata;

   FIR_DATA_BUS  delay_buffer_in, delay_buffer_out;
   FIR_DATA_BUS  real_delayed_in, auto_input_bus; 

   assign delay_buffer_in = (cont_to_in.mode == 1) ? data_in : 0;

   delay_buffer # (.MAX_DELAY(`FIR_DELAY), .WIDTH($bits(FIR_DATA_SAMPLE))) db1 (.*, .data_in(delay_buffer_in.data), .valid_in(delay_buffer_in.valid), .valid_out(delay_buffer_out.valid), .data_out(delay_buffer_out.data), .flush(cont_to_in.flush != 0), .delay(cont_to_in.delay));
/*
  2 cycles to account for the delay in d1spfifo
*/
   pipe_reg #(.WIDTH($bits(FIR_DATA_BUS)), .STAGE(2)) pipe_in   (.in(data_in),    .out(real_delayed_in),    .*);
  
   FIR_DATA_SAMPLE  mult_opa, mult_opb, mult_out;

   logic            mult_valid, mult_done;

//   assign  mult_valid = delay_buffer_out.valid;
   assign  mult_valid = real_delayed_in.valid;

   FIR_SHIFT shift;

   assign shift = cont_to_in.shift;
/*
   delayed buffer out is conjugated
*/
   assign mult_opb = real_delayed_in.data;
   assign mult_opa = delay_buffer_out.data;
 
   pipe_reg #(.WIDTH(1), .STAGE(2)) pipe_mult_valid   (.in(mult_valid),    .out(mult_done),    .*);
   FIR_cmult fcm1 (
      .*,
      .opa(mult_opa),
      .opb(mult_opb),
      .out(mult_out)
   );

   assign auto_input_bus.valid = mult_done;
   assign auto_input_bus.data = mult_out;
 
   assign data_out_pre_w = (cont_to_in.mode == 1) ? auto_input_bus : real_delayed_in;

   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         data_out_pre <= 0;
      end
      else begin
         data_out_pre <= data_out_pre_w;
      end
   end
   

endmodule

