/*
  Revisions:
    10/13/21:
      fixed reg_indi
*/
	module AXIL_S_wrap #
	(
		parameter C_S_AXI_DATA_WIDTH	=  64, 
                          C_S_AXI_ADDR_WIDTH	=  32,
                          NUM_REGISTER          =  7
	)
	(
/*
   global stuff
*/
		input         clk,
		input         rst_n,
/*
   axil_interface
*/
		input        [C_S_AXI_ADDR_WIDTH-1 : 0] s_axil_awaddr,
		input        [2 : 0] s_axil_awprot,
		input         s_axil_awvalid,
		output logic  s_axil_awready,
		input        [C_S_AXI_DATA_WIDTH-1 : 0] s_axil_wdata,
		input        [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axil_wstrb,
		input         s_axil_wvalid,
		output logic  s_axil_wready,
		output logic [1 : 0] s_axil_bresp,
		output logic  s_axil_bvalid,
		input         s_axil_bready,
		input        [C_S_AXI_ADDR_WIDTH-1 : 0] s_axil_araddr,
		input        [2 : 0] s_axil_arprot,
		input         s_axil_arvalid,
		output logic  s_axil_arready,
		output logic [C_S_AXI_DATA_WIDTH-1 : 0] s_axil_rdata,
		output logic [1 : 0] s_axil_rresp,
		output logic  s_axil_rvalid,
		input         s_axil_rready,
/*
   downstream interface
*/                
                output logic [NUM_REGISTER*C_S_AXI_DATA_WIDTH - 1 : 0] slv_reg_down,
                input        [NUM_REGISTER*C_S_AXI_DATA_WIDTH - 1 : 0] slv_reg_up,
		output logic [$clog2(NUM_REGISTER) - 1 : 0] access_addr,
                output logic                            read_valid,
                output logic                            write_valid
              
	);
                logic        [NUM_REGISTER - 1 : 0]     reg_indi;

                assign reg_indi = {1'b1, 6'b0};

                AXIL_S # (.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH), .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH), .NUM_REGISTER(NUM_REGISTER))  axil_s (.*);

endmodule 
