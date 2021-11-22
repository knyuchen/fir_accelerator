module FIR_top # (
    parameter AXI_DATA_WIDTH = 32,
    parameter AXI_ADDR_WIDTH = 32,
    parameter AXI_ID_WIDTH = 8,
    parameter AXIL_DATA_WIDTH	= 64, 
    parameter NUM_REGISTER          =   7,
    parameter TOP_LEN_WIDTH   = 32,
    parameter AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8),
    parameter AXIL_ADDR_WIDTH	= AXI_ADDR_WIDTH
)
(
    input             clk,
    input             rst_n,
// AXI READ Master    
    output   logic [AXI_ID_WIDTH-1:0]    m_axi_arid,
    output   logic [AXI_ADDR_WIDTH-1:0]  m_axi_araddr,
    output   logic [7:0]                 m_axi_arlen,
    output   logic [2:0]                 m_axi_arsize,
    output   logic [1:0]                 m_axi_arburst,
    output   logic                       m_axi_arlock,
    output   logic [3:0]                 m_axi_arcache,
    output   logic [2:0]                 m_axi_arprot,
    output   logic                       m_axi_arvalid,
    input                                m_axi_arready,
    input          [AXI_ID_WIDTH-1:0]    m_axi_rid,
    input          [AXI_DATA_WIDTH-1:0]  m_axi_rdata,
    input          [1:0]                 m_axi_rresp,
    input                                m_axi_rlast,
    input                                m_axi_rvalid,
    output   logic                       m_axi_rready,
// AXI WRITE Master    
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
    output   logic                       m_axi_bready,
// axi-lite slave		
    input        [AXIL_ADDR_WIDTH-1 : 0] s_axil_awaddr,
    input        [2 : 0] s_axil_awprot,
    input         s_axil_awvalid,
    output logic  s_axil_awready,
    input        [AXIL_DATA_WIDTH-1 : 0] s_axil_wdata,
    input        [(AXIL_DATA_WIDTH/8)-1 : 0] s_axil_wstrb,
    input         s_axil_wvalid,
    output logic  s_axil_wready,
    output logic [1 : 0] s_axil_bresp,
    output logic  s_axil_bvalid,
    input         s_axil_bready,
    input        [AXIL_ADDR_WIDTH-1 : 0] s_axil_araddr,
    input        [2 : 0] s_axil_arprot,
    input         s_axil_arvalid,
    output logic  s_axil_arready,
    output logic [AXIL_DATA_WIDTH-1 : 0] s_axil_rdata,
    output logic [1 : 0] s_axil_rresp,
    output logic  s_axil_rvalid,
    input         s_axil_rready,
/*
    interrupt
*/
    output logic   interrupt_out

);
  logic [NUM_REGISTER*AXIL_DATA_WIDTH - 1 : 0] slv_reg_down;
  logic [NUM_REGISTER*AXIL_DATA_WIDTH - 1 : 0] slv_reg_up;
  logic [$clog2(NUM_REGISTER) - 1 : 0] access_addr;
  logic                            read_valid;
  logic                            write_valid;

   AXIL_S_wrap axil (.*);
   logic                             read_start;
   logic                             read_restart;
   logic                             top_read_valid;
   logic     [TOP_LEN_WIDTH - 1 : 0] top_read_len;
   logic     [AXI_ADDR_WIDTH-1:0]    top_read_addr;

   logic                             write_start;
   logic                             write_restart;
   logic                             top_write_valid;
   logic     [TOP_LEN_WIDTH - 1 : 0] top_write_len;
   logic     [AXI_ADDR_WIDTH-1:0]    top_write_addr;

   logic write_done, read_done;
   FIR_CONT_TO_TILE  cont_to_tile;
   FIR_TAP_LOAD  tap_load;
   FIR_CONT_TO_IN  cont_to_in;
   FIR_CONT_TO_OUT_RATE cont_to_out_rate;
   FIR_CONT_TO_IN_RATE cont_to_in_rate;

   top_decoder_FIR td1 (.*);
   
   logic                                 input_ready;
   logic [AXI_DATA_WIDTH-1:0]   data_out;
   logic                        valid_out;
   logic                        last_out;
    
   logic                         output_ready;
   logic                                  valid_in;
   logic           [AXI_DATA_WIDTH - 1 : 0]  data_in;

   dma_wrap dm1 (.*);

   FIR_DATA_BUS to_compute, dma_out;

   assign dma_out.valid = valid_out; 
   assign dma_out.data = data_out; 
   logic  in_ready;

   in_rate ir1 (.*, .from_cont(cont_to_in_rate), .last_in(last_out), .in_rate_ready(input_ready));
   
   logic compute_ready;
   FIR_DATA_BUS to_filter, to_output;

   FIR_in fi1 (.*, .next_ready(compute_ready), .ready(in_ready), .data_in(to_compute), .data_out(to_filter));
   
   logic out_rate_ready;

   FIR_comp fc1 (.*, .from_input(to_filter), .input_tap(tap_load), .from_cont(cont_to_tile), .next_ready(out_rate_ready), .ready(compute_ready));

   FIR_DATA_BUS to_dma;

   assign valid_in = to_dma.valid;
   assign data_in = to_dma.data;
   out_rate or1 (.*, .from_cont(cont_to_out_rate), .compute_out(to_output), .dma_ready(output_ready));
   
endmodule
