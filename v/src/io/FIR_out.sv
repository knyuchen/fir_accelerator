module FIR_out (
   input               clk,
   input               rst_n, 
   input   FIR_DATA_BUS    data_in,    // from IP
   output  FIR_DATA_BUS    data_out,   // to output interface
   output  FIR_TX_TO_CONT  tx_to_cont,    // to controller, when pop one data controller count -1
   input               is_ready,    // from output interface
   input               tlast_in,
   output   logic      last_out
);
   

   logic   [$bits(FIR_DATA_SAMPLE : 0]  rdata, wdata;
   logic                                full, empty; 
   logic                                push, pop;
   logic                                valid, ack;

   fifo #(.DEPTH(32), .WIDTH($bits(FIR_DATA_SAMPLE) + 1), .QUOTA(2)) f0 (.*); 

   FIR_DATA_BUS  data_out_w;
   logic         last_out_w;

   assign data_out_w.valid = valid;
   assign data_out_w.data  = rdata[$bits(FIR_DATA_SAMPLE) : 1];
   assign last_out_w       = rdata[0];

   assign wdata = {data_in.data, tlast_in};
   assign tx_to_cont.valid = data_out.valid;
   assign pop = is_ready;
   assign push = data_in.valid;

 
endmodule  
