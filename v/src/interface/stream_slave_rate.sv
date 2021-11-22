/*
   rate : up sample rate
   tail : N tap --> tail = N - 1
   last_in directly goes to stream master
   stream_out goes to FIR_in

   V000V000V000_00000
   for rate = 3, tail = 5
*/

module stream_slave_rate # (
   parameter  LAST_PIPE            = 10
)
(
   input   S_AXIS_ACLK,
// AXI4Stream sink: Reset
   input   S_AXIS_ARESETN,
// Ready to accept data in
   output logic  S_AXIS_TREADY,
// Data in
   input  [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
// Byte qualifier
   input  [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
// Indicates boundary of last packet
   input   S_AXIS_TLAST,
// Data is in valid
   input   S_AXIS_TVALID,

   input   FIR_UP_RATE    rate,

   input   FIR_TAIL       tail,

   input                  is_ready,
   output  FIR_DATA_BUS   stream_out,
   output  logic          last_in

);

   FIR_DATA_BUS stream_out_w;
   logic is_pop, input_valid, tlast_in;
   logic [$bits(FIR_DATA_SAMPLE) - 1 : 0]  input_data;
   AXIS_S #(.C_S_AXIS_TDATA_WIDTH($bits(FIR_DATA_SAMPLE)), .QUOTA(2)) ass (.*);
   localparam   VALUE = 0, ZERO = 1, LAST_ZERO = 2, TAIL = 3; 
  
   FIR_UP_RATE  count, count_w;
   FIR_TAIL     tail_count, tail_count_w;
   logic  [1:0]      flag, flag_w;
   logic        valid_pop;
   logic        pop_value, pop_zero, pop_last;

   assign valid_pop = is_pop == 1 && input_valid == 1;

   logic [LAST_PIPE - 1 : 0] last_pipe;
   assign last_in       = last_pipe[LAST_PIPE - 1];

   integer i;

   always_comb begin
      stream_out_w = 0;
      if (pop_value == 1) begin
         stream_out_w.data = input_data;
         stream_out_w.valid = 1; 
      end
      else if (pop_zero == 1) begin
         stream_out_w.valid = 1; 
      end
   end

   
   always_comb begin
      flag_w = flag;
      is_pop = 0;
      pop_value = 0;
      pop_zero  = 0;
      pop_last  = 0;
      case (flag) 
         VALUE: begin
            is_pop = 1;
            if (valid_pop == 1) begin
               pop_value = 1;
               if (tlast_in == 1) begin
                  if (rate == 0) begin
                     if (tail == 0) begin
                        pop_last = 1;
                     end
                     else begin
                        flag_w = TAIL;
                        tail_count_w = tail_count + 1;
                     end
                  end
                  else begin
                     flag_w = LAST_ZERO;
                  end
               end
               else begin
                  if (rate != 0) begin
                     flag_w = ZERO;
                     count_w = count + 1;
                  end
               end 
            end
         end
         ZERO: begin
            pop_zero = 1;
            if (count == rate) begin
               count_w = 0;
               flag_w = VALUE;
            end
            else begin
               count_w = count + 1;
            end
         end
         LAST_ZERO: begin
            pop_zero = 1;
            if (count == rate) begin
               if (tail == 0) begin
                  pop_last = 1;
                  flag_w = VALUE;
               end
               else begin
                  count_w = 0;
                  flag_w = TAIL;
                  tail_count_w = tail_count + 1;
               end
            end
            else begin
               count_w = count + 1;
            end
         end
         TAIL: begin
            pop_zero = 1;
            if (tail_count == tail) begin
               pop_last = 1;
               flag_w = VALUE;
               tail_count_w = 0;
            end
            else begin
               tail_count_w = tail_count + 1;
            end
         end
      endcase
   end
   integer i;
   always_ff @(posedge S_AXIS_ACLK or negedge S_AXIS_ARESETN) begin
      if (S_AXIS_ARESETN == 0) begin
         last_pipe <= 0;
         stream_out <= 0;
         flag <= 0;
         count <= 0;
         tail_count <= 0; 
      end
      else begin
         last_pipe[0] <= pop_last;
         for (i = 1; i < LAST_PIPE; i = i + 1) begin
            last_pipe [i] <= last_pipe [i-1];
         end
         flag <= flag_w;
         stream_out <= stream_out_w;
         count <= count_w;
         tail_count <= tail_count_w;
      end
   end
endmodule
