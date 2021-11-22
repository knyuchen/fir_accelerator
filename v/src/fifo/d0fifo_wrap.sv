module d0fifo_wrap # (
   parameter WIDTH = 16,
   parameter SIZE  = 32
) 
(
   input                          clk,
   input                          rst_n,
   input                          push,
   input                          pop,
   input         [WIDTH - 1 : 0]  wdata,
   input                          flush,
   output  logic [WIDTH - 1 : 0]  rdata,
   output  logic                  full,
   output  logic                  empty,
   output  logic                  valid
);

   logic al_full, al_empty, ack;
     

   d0fifo #(
      .WIDTH(WIDTH),
      .SIZE(SIZE),
      .FULL(1),
      .EMPTY(1),
      .AL_FULL(0),
      .AL_EMPTY(0),
      .ACK(0),
      .VALID(1),
      .PEEK(0),
      .FLUSH(1)
   )d1(.*);

endmodule
