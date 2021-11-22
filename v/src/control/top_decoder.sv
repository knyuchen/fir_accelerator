/*
   Reg 0: command (start) 0 to flush, 2 to start
   Reg 1: {read_start_addr(32), read_len (32)}
   Reg 2: {write_start_addr(32), write_len (32)}
   Reg 3: configuration
   Reg 4: input tap
   Reg 5: interrupt handling
   Reg 6: status

   Revisions:
     10/13/21:
       First Documentation, take out read / write restart, fix tap loading
*/
module top_decoder_FIR #(
   parameter   AXIL_DATA_WIDTH  = 64,
   parameter   AXI_ADDR_WIDTH  = 32,
   parameter   NUM_REGISTER     = 7, 
   parameter   TOP_LEN_WIDTH     = 32 
) (
   input [AXIL_DATA_WIDTH*NUM_REGISTER - 1 : 0] slv_reg_down,
   output [AXIL_DATA_WIDTH*NUM_REGISTER - 1 : 0] slv_reg_up,
   input  [$clog2(NUM_REGISTER) - 1 : 0]   access_addr,
   input                                    write_valid,
    
   output  logic                          read_start,
   output  logic                          top_read_valid,
   output  logic  [TOP_LEN_WIDTH - 1 : 0] top_read_len,
   output  logic  [AXI_ADDR_WIDTH-1:0]    top_read_addr,

   output  logic                          write_start,
   output  logic                          top_write_valid,
   output  logic  [TOP_LEN_WIDTH - 1 : 0] top_write_len,
   output  logic  [AXI_ADDR_WIDTH-1:0]    top_write_addr,

/*
   custom stuff
*/
   input                                  write_done,
   output  logic                          interrupt_out,
/*
   pulse
*/
   output  FIR_CONT_TO_TILE               cont_to_tile,
   output  FIR_TAP_LOAD                   tap_load,
/*
   needs to be held 
*/
   output  FIR_CONT_TO_IN                 cont_to_in,
   output  FIR_CONT_TO_OUT_RATE           cont_to_out_rate,
   output  FIR_CONT_TO_IN_RATE           cont_to_in_rate,

   input                                   clk,
   input                                   rst_n 
);

   logic  [AXIL_DATA_WIDTH - 1 : 0]  read_command, write_command, general_command;
      
   assign general_command = slv_reg_down[(0+1)*AXIL_DATA_WIDTH-1 : 0*AXIL_DATA_WIDTH];
   assign read_command = slv_reg_down[(1+1)*AXIL_DATA_WIDTH-1 : 1*AXIL_DATA_WIDTH];
   assign write_command = slv_reg_down[(2+1)*AXIL_DATA_WIDTH-1 : 2*AXIL_DATA_WIDTH];

   assign top_read_valid  = write_valid == 1 && access_addr == 1;
   assign top_write_valid = write_valid == 1 && access_addr == 2;

   assign read_start  = write_valid == 1 && access_addr == 0 && general_command == 2;
   assign write_start = write_valid == 1 && access_addr == 0 && general_command == 2;

   assign top_read_len = read_command [TOP_LEN_WIDTH - 1 : 0];
   assign top_read_addr = read_command [32 + AXI_ADDR_WIDTH - 1 : 32];
   assign top_write_len = write_command [TOP_LEN_WIDTH - 1 : 0];
   assign top_write_addr = write_command [32 + AXI_ADDR_WIDTH - 1 : 32];

/*
   custom thing
*/
   logic  [AXIL_DATA_WIDTH - 1 : 0]  config_command, status, interrupt_reg, tap_command;
   logic  [AXIL_DATA_WIDTH - 1 : 0]  interrupt_command, status_w, interrupt_reg_w;
   assign config_command = slv_reg_down[(3+1)*AXIL_DATA_WIDTH-1 : 3*AXIL_DATA_WIDTH];
   assign tap_command = slv_reg_down[(4+1)*AXIL_DATA_WIDTH-1 : 4*AXIL_DATA_WIDTH];
   assign interrupt_command = slv_reg_down[(5+1)*AXIL_DATA_WIDTH-1 : 5*AXIL_DATA_WIDTH];

   FIR_CONT_TO_TILE  cont_to_tile_w;
   FIR_TAP_LOAD                   tap_load_w;
   FIR_CONT_TO_IN                 cont_to_in_w;
   FIR_CONT_TO_OUT_RATE           cont_to_out_rate_w;
   FIR_CONT_TO_IN_RATE           cont_to_in_rate_w;

   FIR_TAIL    tap_count, tap_count_w;

   always_comb begin
      cont_to_in_w = cont_to_in;
      cont_to_tile_w = 0;
      tap_load_w = 0;
      cont_to_out_rate_w = cont_to_out_rate;
      cont_to_in_rate_w = cont_to_in_rate;
      tap_count_w = tap_count;
      if (write_valid == 1 && access_addr == 3) begin
         cont_to_tile_w.valid = 1;
         cont_to_tile_w.mode = config_command[0];
         cont_to_tile_w.num = config_command[8:1];
         cont_to_tile_w.shift = config_command [12:9];
         tap_count_w = config_command[8:1] - 1;          

         cont_to_in_w.mode = config_command[0];
         cont_to_in_w.shift = config_command[12:9];
         cont_to_in_w.delay = config_command [20:13];

         cont_to_in_rate_w.rate = config_command [24:21];
         cont_to_in_rate_w.tail = config_command[8:1] - 2;

         cont_to_out_rate_w.rate = config_command [28:25];
      end
      else if (write_valid == 1 && access_addr == 4) begin
         tap_load_w.valid = 1;
         tap_load_w.count = tap_count;
         tap_load_w.data = tap_command[31:0];
         tap_count_w = tap_count - 1;  
      end
      else if (write_valid == 1 && access_addr == 0 && general_command == 0) begin
         cont_to_tile_w.valid = 1;
         cont_to_tile_w.flush = 1;
         cont_to_in_w.flush = 1;
         cont_to_in_rate_w.flush = 1;
         cont_to_out_rate_w.flush = 1;
      end
      else if (write_valid == 1 && access_addr == 0 && general_command == 2) begin
         cont_to_in_w.flush = 0;
         cont_to_in_rate_w.flush = 0;
         cont_to_out_rate_w.flush = 0;
      end
   end
  
   
   assign interrupt_out = interrupt_reg != 0;    

   always_comb begin
      interrupt_reg_w = interrupt_reg;
      if (write_done == 1 && status == 0) interrupt_reg_w = 1; 
      else if (write_valid == 1 && access_addr == 5) interrupt_reg_w = interrupt_command;
   end 

   assign slv_reg_up = {status, 384'b0}; 

   always_comb begin
      status_w = status;
      if (read_start == 1) status_w = 0;
      else if (write_done == 1) status_w = 1;
   end  

   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         status <= 1;
         interrupt_reg <= 0;
         tap_count <= 0;
         cont_to_tile <= 0;
         tap_load <= 0; 
         cont_to_in <= 0;
         cont_to_out_rate <= 0;
         cont_to_in_rate <= 0;
      end
      else begin
         status <= status_w;
         interrupt_reg <= interrupt_reg_w;
         tap_count <= tap_count_w;
         cont_to_tile <= cont_to_tile_w; 
         tap_load <= tap_load_w;
         cont_to_in <= cont_to_in_w;
         cont_to_out_rate <= cont_to_out_rate_w;
         cont_to_in_rate <= cont_to_in_rate_w;
      end
   end

endmodule
