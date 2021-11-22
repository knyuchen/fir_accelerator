/*
   in rate only do up sampling
   Input Latency: 0
   Internal Latency: 1
   Output Latency: 0
   Revisions:
     10/13/21:
       First Documentation
*/

module in_rate (
    input    clk,
    input    rst_n,
    input   FIR_CONT_TO_IN_RATE  from_cont,
    output  FIR_DATA_BUS  to_compute,
    input   FIR_DATA_BUS  dma_out,
    input                 in_ready,
    input                 last_in,
    output                in_rate_ready 
);
   FIR_DATA_BUS  data_out_pre, data_out_pre_w;

   logic  want_to_pop;

   logic   full, empty, valid;
   logic   push, pop;
   logic [$bits(FIR_DATA_BUS) - 1 : 0]  wdata, rdata;

   d0fifo_wrap #(.SIZE(4), .WIDTH($bits(FIR_DATA_BUS))) d1 (.*, .flush(from_cont.flush == 1));  
   assign in_rate_ready = empty && want_to_pop;
   assign pop = in_ready;
   assign push = data_out_pre.valid;
   assign wdata = data_out_pre;
   assign to_compute = rdata;

   FIR_RATE  real_rate, count, count_w;
   logic [1:0]  flag_w, flag;
   FIR_TAIL  tail_count, tail_count_w;


   assign real_rate = from_cont.rate - 1;

   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         flag <= 0;
         count <= 0;
         tail_count <= 0;
      end
      else begin
         flag <= flag_w;
         count <= count_w;
         tail_count <= tail_count_w;
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
      tail_count_w = tail_count;
      flag_w = flag;
      if (from_cont.flush == 1) begin
         count_w = 0;
         tail_count_w = 0;
         flag_w = 0;
      end
      else begin
      if (flag != 2) begin
         if (from_cont.rate == 0) begin
            want_to_pop = 1;
            data_out_pre_w = dma_out;
            if (last_in == 1) flag_w = 2;
         end
         else begin // up
            if (flag == 0) begin
               want_to_pop = 1;
               if (dma_out.valid == 1) begin
                  flag_w = 1;
                  data_out_pre_w = dma_out;
          // still add zero even if it's the last one
                  if (last_in == 1) flag_w = 3;
               end
            end
            else if (flag == 1 || flag == 3) begin
               data_out_pre_w.valid = 1;
               data_out_pre_w.data = 0;
               if (count == real_rate) begin
                  count_w = 0;
                  if (flag == 1) flag_w = 0;
          // go to tail zero
                  else flag_w = 2;
               end
               else begin
                  count_w = count + 1;
               end 
            end
         end
      end
      else begin
         count_w = 0;
         data_out_pre_w.valid = 1;
         data_out_pre_w.data = 0;
         if (tail_count == from_cont.tail) begin
            tail_count_w = 0;
            flag_w = 0;
         end
         else begin
            tail_count_w = tail_count + 1;
         end 
      end
      end
   end 
endmodule
