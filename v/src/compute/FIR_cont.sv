/*
   reg 0 : output status 
      0: not ready
      1: ready
   reg 1 : input config
      [31]    : 1 for is auto
      [30:27] : mult shift
      [26:23] : up sampling rate
      [22:19] : down sampling rate
      [18:11] : tap - 1
      [ 8: 0] : auto delay
   reg 2 : input command
      1 : start
      2 : soft stop
   reg 3 : input tap
*/

module FIR_cont (
   input   FIR_TX_TO_CONT    tx_to_cont,
   input   FIR_RX_TO_CONT    rx_to_cont,
   output logic          is_ready, // to input

   input   FIR_LITE_TO_CONT  from_lite,
   output  FIR_CONT_TO_LITE  to_lite,     

   output CONT_TO_IN     cont_to_in,

   output FIR_TAIL       tail,
   input  FIR_CONT_TO_TILE   from_cont,
   output FIR_UP_RATE    up_rate,
   output FIR_DOWN_RATE  down_rate,

   output FIR_DATA_BUS   input_tap,

   input                 clk,
   input                 rst_n 

);
   // counter
   logic full, empty;
   FIR_HOLD_COUNT local_count, local_count_w;

   assign full = (local_count == (`FIR_HOLD - `FIR_DELAY + cont_to_in.delay));
   assign empty = local_count == 0;

   always_comb begin
      case ({tx_to_cont.valid, rx_to_cont.valid}) 
         2'b10: local_count_w = local_count - 1;
         2'b01: local_count_w = local_count + 1;
         default: local_count_w = local_count;
      endcase
   end
   
   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         local_count <= 0;
      end
      else begin
         local_count <= local_count_w;
      end
   end


   // internal state and status

   logic [1:0]  current_state, current_state_w;

   always_comb begin
      current_state_w = current_state;
      case (current_state)
      0: begin // waiting for input command to say ok
         if (from_lite.config_valid == 2 && from_lite.input_command == 1) begin // start signal
            current_state_w = 1;
         end
      end
      1: begin // running, waiting for host to go soft stop
         if (from_lite.config_valid == 2 && from_lite.input_command == 2) begin // soft stop signal
            current_state_w = 2;
         end
      end
      2: begin // waiting for IP to clear out remaining packet
         if (empty == 1) begin
            current_state_w = 3;
         end
      end
      3: begin
         if (from_lite.config_valid == 2 && from_lite.input_command == 1) begin
            current_state_w = 0;
         end
      end
      default: begin
      end
      endcase
   end
   
   assign cont_to_lite.ready = (current_state == 0);

   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         current_state <= 0;
      end
      else begin
         current_state <= current_state_w;
      end
   end


   // a gate at the input interface
   
   logic is_ready_w;
   assign is_ready_w = (current_state == 1) && (full == 0);

   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         is_ready <= 0;
      end
      else begin
         is_ready <= is_ready_w;
      end
   end
   // settings
   logic [31:0] setting_w, setting;
   logic        is_auto;
   logic [3:0]        shift;
   logic [1:0]  flush, flush_w;
   logic [3:0]  point;
   logic [15:0] enable;


   assign from_cont.enable = enable;
   assign from_cont.flush = flush;
   assign from_cont.shift = shift;
   assign from_cont.is_auto = is_auto;



   assign flush_w = (current_state == 3 && from_lite.config_valid == 2) ? from_lite.input_command [3:2] : 0;
   assign is_auto = setting[31];
//   assign cont_to_comp.ifft = setting[31];
   assign shift = setting[30:27];
   assign up_rate = setting [26:23];
   assign down_rate = setting [22:19];
   assign point = setting[18:11];

   assign cont_to_in.is_auto = is_auto;
   assign cont_to_in.flush   = flush;
   assign cont_to_in.delay   = setting[7:0];
   assign tail = setting[18:11];
   assign cont_to_in.shift = shift;
   always_comb begin
      case (point)
         0:  enable = 16'b1000_0000_0000_0000;
         1:  enable = 16'b1100_0000_0000_0000;
         2:  enable = 16'b1110_0000_0000_0000;
         3:  enable = 16'b1111_0000_0000_0000;
         4:  enable = 16'b1111_1000_0000_0000;
         5:  enable = 16'b1111_1100_0000_0000;
         6:  enable = 16'b1111_1110_0000_0000;
         7:  enable = 16'b1111_1111_0000_0000;
         8:  enable = 16'b1111_1111_1000_0000;
         9:  enable = 16'b1111_1111_1100_0000;
         10: enable = 16'b1111_1111_1110_0000;
         11: enable = 16'b1111_1111_1111_0000;
         12: enable = 16'b1111_1111_1111_1000;
         13: enable = 16'b1111_1111_1111_1100;
         14: enable = 16'b1111_1111_1111_1110;
         15: enable = 16'b1111_1111_1111_1111;
         default: enable = 0;
      endcase
   end


   always_comb begin
      if (current_state == 0 && from_lite.config_valid == 1) begin
         setting_w = from_lite.input_config;
      end
      else begin
         setting_w = setting;
      end
   end

   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         setting <= 0;
         flush <= 0;
      end
      else begin
         setting <= setting_w;
         flush <= flush_w;
      end
   end

   DATA_BUS   input_tap_w;

   assign input_tap_w.valid = current_state == 0 && from_lite.config_valid == 3; 
   assign input_tap_w.data  = (input_tap_w.valid == 1) ? from_lite.config_tap : 0;

   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         input_tap <= 0;
      end
      else begin
         input_tap <= input_tap_w;
      end
   end

endmodule
