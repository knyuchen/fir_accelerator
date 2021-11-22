
	module FIR_lite_slave #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter C_S_AXI_DATA_WIDTH	= 32, 
                          C_S_AXI_ADDR_WIDTH	= 9
	)
	(
		// Users to add ports here

		// SIDM - Begin
		
		
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output logic  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output logic  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output logic [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output logic  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output logic  S_AXI_ARREADY,
		// Read data (issued by slave)
		output logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output logic [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output logic  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY,
                
                output  FIR_LITE_TO_CONT from_lite,
                input   FIR_CONT_TO_LITE to_lite      
	);

   localparam NUM_REGISTER = 4;
                logic [NUM_REGISTER*C_S_AXI_DATA_WIDTH - 1 : 0] slv_reg_down;
                logic    [NUM_REGISTER*C_S_AXI_DATA_WIDTH - 1 : 0] slv_reg_up;
	        logic [C_S_AXI_ADDR_WIDTH-1 : 0] access_addr;
                logic                            read_valid;
                logic                            write_valid;
                logic        [NUM_REGISTER - 1 : 0]     reg_indi;
             assign reg_indi = 4'b0001;
   AXIL_S #(.NUM_REGISTER(4)) a1 (.*);
             assign slv_reg_up [1*C_S_AXI_DATA_WIDTH - 1 : 0*C_S_AXI_DATA_WIDTH] = to_lite.ready;
             assign slv_reg_up [2*C_S_AXI_DATA_WIDTH - 1 : 1*C_S_AXI_DATA_WIDTH] = 0;
             assign slv_reg_up [3*C_S_AXI_DATA_WIDTH - 1 : 2*C_S_AXI_DATA_WIDTH] = 0;
             assign slv_reg_up [4*C_S_AXI_DATA_WIDTH - 1 : 3*C_S_AXI_DATA_WIDTH] = 0;

             assign from_lite.input_config = slv_reg_up [2*C_S_AXI_DATA_WIDTH - 1 : 1*C_S_AXI_DATA_WIDTH];
             assign from_lite.input_command = slv_reg_up [3*C_S_AXI_DATA_WIDTH - 1 : 2*C_S_AXI_DATA_WIDTH];
             assign from_lite.config_tap = slv_reg_up [4*C_S_AXI_DATA_WIDTH - 1 : 3*C_S_AXI_DATA_WIDTH];
             always_comb begin
                from_lite.config_valid = 0;
                if (write_valid == 1) from_lite.config_valid = access_addr[1:0];
             end 
endmodule
