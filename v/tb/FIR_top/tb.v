module test ();

    
    
    parameter AXI_DATA_WIDTH = 32;
    parameter AXI_ADDR_WIDTH = 32;
    parameter AXI_ID_WIDTH = 8;
    parameter AXI_MAX_BURST_LEN = 16;
    parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8);
    parameter AXIL_DATA_WIDTH	= 64; 
    parameter AXIL_ADDR_WIDTH	= AXI_ADDR_WIDTH;
    parameter NUM_REGISTER          =   4;
    parameter TOP_LEN_WIDTH    = 20;
    parameter FIX_LEN          = 64;
    parameter CONFIG_LEN_WIDTH = 9;
    parameter OUTSTANDING_COUNT = 2;

/*
    unused signals start
*/

    logic [3:0]  s_axi_awcache, s_axi_arcache;
    logic [2:0]  s_axi_awprot, s_axi_arprot;
    logic        s_axi_awlock, s_axi_arlock;

    logic [AXI_ID_WIDTH - 1 : 0]  s_axi_awid, s_axi_bid, s_axi_arid, s_axi_rid;

   logic  [AXI_ID_WIDTH - 1 : 0]  m_axi_arid, m_axi_rid;
   logic   m_axi_arlock;
   logic  [3:0]  m_axi_arcache;
   logic  [2:0]  m_axi_arprot;
   
   logic  [AXI_ID_WIDTH-1 : 0]  m_axi_awid, m_axi_bid;
   logic  m_axi_awlock;
   logic  [3:0]  m_axi_awcache;
   logic  [2:0]  m_axi_awprot;
/*
    unused signals end
*/
  
    
    logic          [AXI_ADDR_WIDTH-1:0]  m_axi_awaddr;
    logic          [7:0]                 m_axi_awlen;
    logic          [2:0]                 m_axi_awsize;
    logic          [1:0]                 m_axi_awburst;
    
    logic                                m_axi_awvalid;
    logic                                m_axi_awready;
    logic          [AXI_DATA_WIDTH-1:0]  m_axi_wdata;
    logic          [AXI_STRB_WIDTH-1:0]  m_axi_wstrb;
    logic                                m_axi_wlast;
    logic                                m_axi_wvalid;
    logic                                m_axi_wready;
    
    logic          [1:0]                 m_axi_bresp;
    logic                                m_axi_bvalid;
    logic                                m_axi_bready;

    logic                                clk;
    logic                                rst_n;


    logic           [AXI_ADDR_WIDTH-1:0]  m_axi_araddr;
    logic           [7:0]                 m_axi_arlen;
    logic           [2:0]                 m_axi_arsize;
    logic           [1:0]                 m_axi_arburst;
    
    logic                                 m_axi_arvalid;
    logic                                m_axi_arready;
    
    logic          [AXI_DATA_WIDTH-1:0]  m_axi_rdata;
    logic          [1:0]                 m_axi_rresp;
    logic                                m_axi_rlast;
    logic                                m_axi_rvalid;
    logic                                 m_axi_rready;
    

    parameter DATA_WIDTH = AXI_DATA_WIDTH;
    parameter ADDR_WIDTH = 32;
    parameter STRB_WIDTH = (DATA_WIDTH/8);
   
   logic            [ADDR_WIDTH-1:0]  s_axi_awaddr;
   logic            [7:0]             s_axi_awlen;
   logic            [2:0]             s_axi_awsize;
   logic            [1:0]             s_axi_awburst;
   logic                              s_axi_awvalid;
   logic                               s_axi_awready;

   logic            [DATA_WIDTH-1:0]  s_axi_wdata;
   logic            [STRB_WIDTH-1:0]  s_axi_wstrb;
   logic                              s_axi_wlast;
   logic                              s_axi_wvalid;
   logic                               s_axi_wready;

   logic             [1:0]             s_axi_bresp;
   logic                               s_axi_bvalid;
   logic                              s_axi_bready;

   logic            [ADDR_WIDTH-1:0]  s_axi_araddr;
   logic            [7:0]             s_axi_arlen;
   logic            [2:0]             s_axi_arsize;
   logic            [1:0]             s_axi_arburst;
   logic                              s_axi_arvalid;
   logic                               s_axi_arready;

   logic             [DATA_WIDTH-1:0]  s_axi_rdata;
   logic             [1:0]             s_axi_rresp;
   logic                               s_axi_rlast;
   logic                               s_axi_rvalid;
   logic                              s_axi_rready;

   assign s_axi_awaddr = m_axi_awaddr;
   assign s_axi_awlen = m_axi_awlen;
   assign s_axi_awsize = m_axi_awsize;
   assign s_axi_awburst = m_axi_awburst;
   assign s_axi_awvalid = m_axi_awvalid;
   assign m_axi_awready = s_axi_awready;

   assign s_axi_wdata = m_axi_wdata;
   assign s_axi_wstrb = m_axi_wstrb;
   assign s_axi_wlast = m_axi_wlast;
   assign s_axi_wvalid = m_axi_wvalid;
   assign m_axi_wready = s_axi_wready;

   assign m_axi_bresp = s_axi_bresp;
   assign m_axi_bvalid = s_axi_bvalid;
   assign s_axi_bready = m_axi_bready;

   assign s_axi_araddr = m_axi_araddr;
   assign s_axi_arlen = m_axi_arlen;
   assign s_axi_arsize = m_axi_arsize;
   assign s_axi_arburst = m_axi_arburst;
   assign s_axi_arvalid = m_axi_arvalid;
   assign m_axi_arready = s_axi_arready;

   assign m_axi_rdata = s_axi_rdata;
   assign m_axi_rresp = s_axi_rresp;
   assign m_axi_rlast = s_axi_rlast;
   assign m_axi_rvalid = s_axi_rvalid;
   assign s_axi_rready = m_axi_rready;
   
    localparam C_S_AXI_DATA_WIDTH	= 64; 
    localparam C_S_AXI_ADDR_WIDTH	= 32;
    logic        [C_S_AXI_ADDR_WIDTH-1 : 0] s_axil_awaddr;
    logic        [2 : 0] s_axil_awprot;
    logic         s_axil_awvalid;
    logic  s_axil_awready;
    logic        [C_S_AXI_DATA_WIDTH-1 : 0] s_axil_wdata;
    logic        [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axil_wstrb;
    logic         s_axil_wvalid;
    logic  s_axil_wready;
    logic [1 : 0] s_axil_bresp;
    logic  s_axil_bvalid;
    logic         s_axil_bready;
    logic        [C_S_AXI_ADDR_WIDTH-1 : 0] s_axil_araddr;
    logic        [2 : 0] s_axil_arprot;
    logic         s_axil_arvalid;
    logic  s_axil_arready;
    logic [C_S_AXI_DATA_WIDTH-1 : 0] s_axil_rdata;
    logic [1 : 0] s_axil_rresp;
    logic  s_axil_rvalid;
    logic         s_axil_rready;
   
    logic  interrupt_out;


    task initial_input ();
        begin
            s_axil_awaddr = 0;
            s_axil_awvalid =0;
            s_axil_wvalid = 0;
            s_axil_bready = 0; 
            s_axil_arvalid = 0; 
            s_axil_rready = 0;
            s_axil_wdata = 0;
            s_axil_wstrb  = '1;
            s_axil_araddr = 0;
        end
    endtask : initial_input
 
    task input_config();
        input [3:0] addr;
        input [63:0] data;
        begin
            @(negedge clk)
            s_axil_wvalid = 1;
            s_axil_awvalid = 1;
            s_axil_awaddr = {25'd0,addr,{3'b0}};
            @(negedge clk)
            s_axil_awaddr = 0;
            s_axil_wdata = data;
            @(negedge clk)
            s_axil_wvalid = 0;
            s_axil_awvalid = 0;
            s_axil_bready = 1;
            s_axil_wdata = 0;
            @(negedge clk)
            s_axil_bready = 0;
        end
    endtask : input_config
   FIR_top d1(.*);

   axi_ram_wrap # (.DATA_WIDTH(AXI_DATA_WIDTH), .FILE_NUM(4), .EFF_ADDR_WIDTH (10)) arw (.*);

   clk_gen c1 (.*);

   logic  [15:0]  fake_j, fake_k;

   initial begin
      initial_input();
      #(`RESET_CYCLE*`CLK_CYCLE)
      #(3*`CLK_CYCLE)

      input_config(0, 0);
      
      input_config(1, {30'd23, 2'd0,  32'd46});
      input_config(2, {30'd100, 2'd0,  32'd52});
                          // out_rate, in_rate, delay, shift, tap, auto
      input_config(3, {35'b0, 4'b0,    4'b0,    8'd3, 4'd2, 8'd7, 1'd1});
      
      input_config(0, 2);

      wait (interrupt_out == 1)
         input_config (5, 0);
      wait (interrupt_out == 0)
      
      #(20*`CLK_CYCLE)
      
      input_config(0, 0);
      
      input_config(1, {30'd13, 2'd0,  32'd51});
      input_config(2, {30'd200, 2'd0,  32'd67});
                          // out_rate, in_rate, delay, shift, tap, auto
      input_config(3, {35'b0, 4'b0,    4'b0,    8'd0, 4'd6, 8'd17, 1'd0});
      
      for (integer j = 0; j < 17; j = j + 1) begin
         fake_j = 17 - j;
         fake_k = 14 - j;
         input_config (4, {32'd0, fake_j, fake_k});
      end 
      
      input_config(0, 2);

      wait (interrupt_out == 1)
         input_config (5, 0);
      wait (interrupt_out == 0)
      
      #(20*`CLK_CYCLE)
/*      
      input_config(0, 0);
      
      input_config(1, {30'd1, 2'd0,  32'd20});
      input_config(2, {30'd100, 2'd0,  32'd21});
                          // out_rate, in_rate, delay, shift, tap, auto
      input_config(3, {35'b0, 4'b0,    4'b0,    8'd1, 4'd0, 8'd2, 1'd1});
      
      input_config(0, 2);

      wait (interrupt_out == 1)
         input_config (5, 0);
      wait (interrupt_out == 0)
      
      #(20*`CLK_CYCLE)

      input_config(0, 0);

      input_config(1, {30'd1, 2'd0,  32'd40});
      input_config(2, {30'd100, 2'd0,  32'd52});
                         // out_rate, in_rate, delay, shift, tap,   auto
      input_config(3, {35'b0, 4'b0,   4'b0,    8'd0,  4'd0,  8'd13, 1'd0});
      
      for (integer j = 0; j < 13; j = j + 1) begin
         fake_j = 13 - j;
         input_config (4, {32'd0, fake_j, 16'd0});
      end 

      input_config(0, 2);
      
      wait (interrupt_out == 1)
         input_config (5, 0);
      wait (interrupt_out == 0)
      
      #(20*`CLK_CYCLE)
      
      input_config(0, 0);
      
      input_config(1, {30'd10, 2'd0,  32'd20});
      input_config(2, {30'd100, 2'd0,  32'd25});
                         // out_rate, in_rate, delay, shift, tap,   auto
      input_config(3, {35'b0, 4'b0,   4'b0,    8'd0,  4'd0,  8'd6, 1'd0});
                         // out_rate, out_mode, in_rate, in_mode, delay, shift, tap, auto
//      input_config(3, {33'b0, 5'b0,             5'b0,              8'd0, 4'd0, 8'd6, 1'd0});
      
      for (integer j = 0; j < 6; j = j + 1) begin
         fake_j = 13 - j;
         input_config (4, {32'd0, fake_j, 16'd0});
      end 

      input_config(0, 2);
      
      wait (interrupt_out == 1)
         input_config (5, 0);
      wait (interrupt_out == 0)
      
      #(20*`CLK_CYCLE)

      input_config(0, 0);
      
      input_config(1, {30'd10, 2'd0,  32'd20});
      input_config(2, {30'd100, 2'd0,  32'd9});
                         // out_rate, in_rate, delay, shift, tap, auto
      input_config(3, {35'b0, 4'd2,   4'd0,    8'd0, 4'd0, 8'd6, 1'd0});
      
      for (integer j = 0; j < 6; j = j + 1) begin
         fake_j = 13 - j;
         input_config (4, {32'd0, fake_j, 16'd0});
      end 

      input_config(0, 2);
      
      wait (interrupt_out == 1)
         input_config (5, 0);
      wait (interrupt_out == 0)
      
      #(20*`CLK_CYCLE)
*/
//      #(500*`CLK_CYCLE)
      $finish;
   end
endmodule
