module dma_wrap #(
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ID_WIDTH = 8,
    parameter OUTSTANDING_COUNT = 2,
    parameter TOP_LEN_WIDTH  = 32,
    parameter FIX_LEN        = 64,
    parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8),
    parameter CONFIG_LEN_WIDTH = 9
)
(
/*
    global stuff
*/
    input                                  clk,
    input                                  rst_n,
/*
   from top decoder
*/    
    output   logic                         read_done,
    input                                  read_start,
    input                                  top_read_valid,
    input          [TOP_LEN_WIDTH - 1 : 0] top_read_len,
    input          [AXI_ADDR_WIDTH-1:0]    top_read_addr,

    output   logic                         write_done,
    input                                  write_start,
    input                                  top_write_valid,
    input          [TOP_LEN_WIDTH - 1 : 0] top_write_len,
    input          [AXI_ADDR_WIDTH-1:0]    top_write_addr,
/*
    to internal input stage
*/
    input                                 input_ready,
    output   logic [AXI_DATA_WIDTH-1:0]   data_out,
    output   logic                        valid_out,
    output   logic                        last_out,
/*
    from internal output stage
*/
   output   logic                         output_ready,
   input                                  valid_in,
   input           [AXI_DATA_WIDTH - 1 : 0]  data_in,
/*
    axi read
*/
    output   logic [AXI_ID_WIDTH-1:0]     m_axi_arid,
    output   logic [AXI_ADDR_WIDTH-1:0]   m_axi_araddr,
    output   logic [7:0]                  m_axi_arlen,
    output   logic [2:0]                  m_axi_arsize,
    output   logic [1:0]                  m_axi_arburst,
    output   logic                        m_axi_arlock,
    output   logic [3:0]                  m_axi_arcache,
    output   logic [2:0]                  m_axi_arprot,
    output   logic                        m_axi_arvalid,
    input                                 m_axi_arready,
    input          [AXI_ID_WIDTH-1:0]     m_axi_rid,
    input          [AXI_DATA_WIDTH-1:0]   m_axi_rdata,
    input          [1:0]                  m_axi_rresp,
    input                                 m_axi_rlast,
    input                                 m_axi_rvalid,
    output   logic                        m_axi_rready,
/*
   axi write
*/
    output   logic [AXI_ID_WIDTH-1:0]    m_axi_awid,
    output   logic [AXI_ADDR_WIDTH-1:0]  m_axi_awaddr,
    output   logic [7:0]                 m_axi_awlen,
    output   logic [2:0]                 m_axi_awsize,
    output   logic [1:0]                 m_axi_awburst,
    output   logic                       m_axi_awlock,
    output   logic [3:0]                 m_axi_awcache,
    output   logic [2:0]                 m_axi_awprot,
    output   logic                       m_axi_awvalid,
    input                                m_axi_awready,
    output   logic [AXI_DATA_WIDTH-1:0]  m_axi_wdata,
    output   logic [AXI_STRB_WIDTH-1:0]  m_axi_wstrb,
    output   logic                       m_axi_wlast,
    output   logic                       m_axi_wvalid,
    input                                m_axi_wready,
    input          [AXI_ID_WIDTH-1:0]    m_axi_bid,
    input          [1:0]                 m_axi_bresp,
    input                                m_axi_bvalid,
    output   logic                       m_axi_bready
);

    dma # (.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
           .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
           .AXI_ID_WIDTH(AXI_ID_WIDTH),
           .OUTSTANDING_COUNT(OUTSTANDING_COUNT),
           .TOP_LEN_WIDTH(TOP_LEN_WIDTH),
           .FIX_LEN(FIX_LEN),
           .CONFIG_LEN_WIDTH(CONFIG_LEN_WIDTH)) d1 (.*);

endmodule
