/*
   next tile : smaller weight number
   weight : start from smaller weight number : next -> prev
   psum   : prev -> next

   delay psum & input sample by one cycle together

   Input Latency:0
   Internal Latency: 4 / 2
   Output Latency: 0   

   Revisions:
     10/13/21:
        First Documentaion, increase d0fifo size to 8
*/
module FIR_tile (
   input            clk,
   input            rst_n,
   input  FIR_CONT_TO_TILE cont_to_tile_in,  // next -> prev
   output FIR_CONT_TO_TILE cont_to_tile_out,
   input  FIR_TAP_LOAD     tap_in,           // next -> prev
   output FIR_TAP_LOAD     tap_out,
   input  FIR_TILE_TO_TILE from_prev_tile,   // prev -> next
   output FIR_TILE_TO_TILE to_next_tile_out,
   input               next_ready,
   output logic        ready
   
);
/*
   Output Buffer at the end
*/
   FIR_TILE_TO_TILE to_next_tile;
   logic   full, empty, valid;
   logic   push, pop;
   logic [2*$bits(FIR_DATA_BUS) - 1 : 0]  wdata, rdata;

   d0fifo_wrap #(.SIZE(8), .WIDTH(2*$bits(FIR_DATA_BUS))) d1 (.*, .flush(cont_to_tile_in.flush == 1));  
   assign ready = empty;
   assign pop = next_ready;
   assign push = to_next_tile.input_sample.valid || to_next_tile.psum.valid;
   assign wdata = to_next_tile ;
   assign to_next_tile_out = rdata;
        


   FIR_TILE_TO_PE tile_to_pe [`FIR_PE_PER_TILE - 1 : 0];
   FIR_TILE_TO_PE tile_to_pe_pre [`FIR_PE_PER_TILE - 1 : 0];
   FIR_DATA_BUS  par [`FIR_PE_PER_TILE : 0];
   FIR_TAP_LOAD  tap [`FIR_PE_PER_TILE : 0];

   FIR_TILE_TO_TILE  to_next_tile_w;
   FIR_CONT_TO_TILE  cont_to_tile_out_w, cont_to_tile_post, cont_to_tile_post_w;

/*
  connecting pipelined tile to tile
*/
   assign par[`FIR_PE_PER_TILE] = from_prev_tile.psum;
   assign tap_out = tap[`FIR_PE_PER_TILE];
   assign tap[0] = tap_in;

   assign to_next_tile_w.input_sample = from_prev_tile.input_sample;
   assign to_next_tile_w.psum  = par[0];

   

   logic [`FIR_PE_PER_TILE - 1 : 0] select, select_w;
   always_ff @ (posedge clk or negedge rst_n) begin
      if (rst_n == 0) begin
         to_next_tile <= 0;
         cont_to_tile_out <= 0;
         cont_to_tile_post <= 0;
         select <= 0;
      end
      else begin
         to_next_tile <= to_next_tile_w;
         cont_to_tile_out <= cont_to_tile_out_w;
         cont_to_tile_post <= cont_to_tile_post_w;
         select <= select_w;
      end
   end
/*
  cont_to_tile_post is to self PE
  cont_to_tile_out is to other tiles
*/
   always_comb begin
      cont_to_tile_post_w = cont_to_tile_post;
      select_w = select;
      cont_to_tile_out_w = 0;
      if (cont_to_tile_in.valid == 1) begin
         if (cont_to_tile_in.flush == 1) begin
            cont_to_tile_post_w.flush = 1;
            select_w = 0;
            
            cont_to_tile_out_w.valid = 1;
            cont_to_tile_out_w.flush = 1;
         end
         else begin
            cont_to_tile_post_w.mode = cont_to_tile_in.mode;
            cont_to_tile_post_w.shift = cont_to_tile_in.shift;
            
            if (cont_to_tile_in.num > `FIR_PE_PER_TILE) begin
               select_w = '1;
               cont_to_tile_out_w.valid = cont_to_tile_in.valid;
               cont_to_tile_out_w.mode = cont_to_tile_in.mode;
               cont_to_tile_out_w.shift = cont_to_tile_in.shift;
               cont_to_tile_out_w.num = cont_to_tile_in.num - `FIR_PE_PER_TILE;
            end
            else begin
               case(cont_to_tile_in.num) 
                  0: select_w = 4'b0000;
                  1: select_w = 4'b0001;
                  2: select_w = 4'b0011;
                  3: select_w = 4'b0111;
                  4: select_w = 4'b1111;
                  default: begin
                  end
/*                  
                  1: select_w = 8'b00000001;
                  2: select_w = 8'b00000011;
                  3: select_w = 8'b00000111;
                  4: select_w = 8'b00001111;
                  5: select_w = 8'b00011111;
                  6: select_w = 8'b00111111;
                  7: select_w = 8'b01111111;
                  8: select_w = 8'b11111111;
                  default: begin
                  end
*/
               endcase
            end 
         end
      end
/*
  flush is a pulse
*/
      else if (cont_to_tile_post.flush == 1) begin
         cont_to_tile_post_w.flush = 0;
      end
   end

   pipe_reg #(.WIDTH($bits(FIR_TILE_TO_PE)), .STAGE(1)) pipe_1 (.in(tile_to_pe_pre[0]), .out(tile_to_pe[0]), .*);
   pipe_reg #(.WIDTH($bits(FIR_TILE_TO_PE)), .STAGE(2)) pipe_2 (.in(tile_to_pe_pre[1]), .out(tile_to_pe[1]), .*);
   pipe_reg #(.WIDTH($bits(FIR_TILE_TO_PE)), .STAGE(3)) pipe_3 (.in(tile_to_pe_pre[2]), .out(tile_to_pe[2]), .*);
   pipe_reg #(.WIDTH($bits(FIR_TILE_TO_PE)), .STAGE(4)) pipe_4 (.in(tile_to_pe_pre[3]), .out(tile_to_pe[3]), .*);
/*
   pipe_reg #(.WIDTH($bits(FIR_TILE_TO_PE)), .STAGE(5)) pipe_5 (.in(tile_to_pe_pre[4]), .out(tile_to_pe[4]), .*);
   pipe_reg #(.WIDTH($bits(FIR_TILE_TO_PE)), .STAGE(6)) pipe_6 (.in(tile_to_pe_pre[5]), .out(tile_to_pe[5]), .*);
   pipe_reg #(.WIDTH($bits(FIR_TILE_TO_PE)), .STAGE(7)) pipe_7 (.in(tile_to_pe_pre[6]), .out(tile_to_pe[6]), .*);
   pipe_reg #(.WIDTH($bits(FIR_TILE_TO_PE)), .STAGE(8)) pipe_8 (.in(tile_to_pe_pre[7]), .out(tile_to_pe[7]), .*);
*/

   genvar i;

   generate 
      for (i = 0; i < `FIR_PE_PER_TILE; i = i + 1) begin

      assign tile_to_pe_pre[i].mode = cont_to_tile_post.mode;
      assign tile_to_pe_pre[i].flush = cont_to_tile_post.flush;
      assign tile_to_pe_pre[i].shift = cont_to_tile_post.shift;
      assign tile_to_pe_pre[i].enable = select[i]; 

      FIR_PE  pp (
         .clk(clk),
         .rst_n(rst_n),
         .input_sample(from_prev_tile.input_sample),
         .tile_to_pe(tile_to_pe[i]),
         .tap_in(tap[i]),
         .tap_out(tap[i+1]),
         .from_prev_pe(par[i+1]),
         .to_next_pe(par[i])
      );

      end 

   endgenerate
endmodule
