/*
   rate change stream master

   downsample --> send into AXIS_M

   throw N then give 1, last sample must go out

   reason that guarantees not data loss:
      1. output buffer only ouput when it sees is_ready (not full)
      2. the process of is_ready and buffer_out is pipelined, but it is taken care of by QUOTA
*/

module stream_master_rate (
   input   M_AXIS_ACLK,
   input   M_AXIS_ARESETN,
		// Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
   output logic  M_AXIS_TVALID,
		// TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
   output logic [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		// TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
   output logic [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		// TLAST indicates the boundary of a packet.
   output logic  M_AXIS_TLAST,
		// TREADY indicates that the slave can accept a transfer in the current cycle.
   input         M_AXIS_TREADY,

   input  FIR_DATA_BUS   buffer_out,
 
   input                 last_in,
 
   input  FIR_DOWN_RATE           rate,

   output logic  is_ready
   
);

   logic  last_out, in_valid;
   logic  [$bits(FIR_DATA_SAMPLE) - 1 : 0] in_data;

   AXIS_M #(.C_M_AXIS_TDATA_WIDTH($bits(FIR_DATA_SAMPLE)), .QUOTA(2)) asm (.*);

   FIR_DOWN_RATE  count, count_w;
   logic          flag, flag_w;
   logic          can_output;

   assign in_data = (can_output == 1) ? buffer_out.data : 0;
   assign in_valid = (can_output == 1) ? buffer_out.valid : 0;

   assign last_out = last_in;

   localparam THROW = 0, PASS = 1;

   always_comb begin
      count_w = count;
      flag_w = flag;
      can_output = 0;
      in_valid = 0;
      if (rate == 0) begin
         can_output = 1;
      end
      else begin
         if (flag == THROW) begin //throw away stage
            if (buffer_out.valid == 1) begin // data comes in
               if (last_in == 1) begin // it is last
                  can_output = 1;
               end
               else begin // not last
                  if (count == rate) begin // still don't output, but output on the next sample
                     count_w = 0;
                     flag_w = 1;
                  end
                  else begin 
                     count_w = count + 1;
                  end
               end
            end
         end
         else begin  // output stage
            if (buffer_out.valid == 1) begin // data comes in
               flag_w = 0;
               can_output = 1;
            end
         end
      end
   end

   always_ff @ (posedge M_AXIS_ACLK or negedge M_AXIS_ARESETN) begin
      if (M_AXIS_ARESETN == 0) begin
         flag  <= THROW;
         count <= 0;
      end
      else begin
         flag  <= flag_w;
         count <= count_w;
      end
   end

endmodule
