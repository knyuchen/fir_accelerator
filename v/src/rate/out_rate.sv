/*
   out rate only does downsampling
   Input Latency: 0
   Internal Latency: 1
   Output Latency: 0 
   Revisions:
     10/13/21:
        First Documentation

   
*/
module out_rate (
    input    clk,
    input    rst_n,
    input   FIR_CONT_TO_OUT_RATE  from_cont,
    output  FIR_DATA_BUS  to_dma,
    input   FIR_DATA_BUS  compute_out,
    input                 dma_ready,
    output                out_rate_ready 
);
   FIR_DATA_BUS  data_out_pre, data_out_pre_w;

   logic  want_to_pop;

   logic   full, empty, valid;
   logic   push, pop;
   logic [$bits(FIR_DATA_BUS) - 1 : 0]  wdata, rdata;

   d0fifo_wrap #(.SIZE(4), .WIDTH($bits(FIR_DATA_BUS))) d1 (.*, .flush(from_cont.flush == 1));  
   assign out_rate_ready = empty && want_to_pop;
   assign pop = dma_ready;
   assign push = data_out_pre.valid;
   assign wdata = data_out_pre;
   assign to_dma = rdata;

   FIR_RATE  real_rate, count, count_w;
   logic flag_w, flag;

   assign real_rate = from_cont.rate - 1;

   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         flag <= 0;
         count <= 0;
      end
      else begin
         flag <= flag_w;
         count <= count_w;
      end
   end
   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         data_out_pre <= 0;
      end
      else begin
         data_out_pre <= data_out_pre_w;
      end
   end
   always_comb begin
      want_to_pop = 0;
      data_out_pre_w = 0;
      count_w = count;
      flag_w = flag;
      if (from_cont.flush == 1) begin
         count_w = 0;
         flag_w = 0;
      end
      else begin
      if (from_cont.rate == 0) begin
         want_to_pop = 1;
         data_out_pre_w = compute_out;
      end
      else begin // down
         want_to_pop = 1;
         if (flag == 0) begin
            if (compute_out.valid == 1) begin
               flag_w = 1;
               data_out_pre_w = compute_out;
            end
         end
         else begin
            if (compute_out.valid == 1) begin
               if (count == real_rate) begin
                  count_w = 0;
                  flag_w = 0;
               end
               else begin
                  count_w = count + 1;
               end 
            end
         end
      end
      end
   end 
endmodule
