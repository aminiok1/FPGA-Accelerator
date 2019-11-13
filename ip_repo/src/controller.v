`timescale 1 ns / 1 ps

	module controller #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

        parameter ITERATION_COUNT = 100
		// Parameters of Axi Master Bus Interface M00_AXI
	/*	
		parameter  C_M00_AXI_START_DATA_VALUE	= 32'hAA000000,
		parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M00_AXI_DATA_WIDTH	= 32,
		parameter integer C_M00_AXI_TRANSACTIONS_NUM	= 4,

		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
		*/
	)
	(
		// Users to add ports here
		input wire clk,
		input wire rst,
		input wire start,
		
		input wire op_vec_done,
		input wire mac_done,
		input wire st_done,
		
		input wire terminate,
		
        output reg done,
        
        output reg scale,
        output reg op_sel,
        output reg in_1_sel,
        output wire [31:0] alpha,
        output wire [31:0] rho_inv,
        output wire [31:0] rho,

        output reg [1:0] in_2_sel,
        output reg op_vec_start,
        
        output reg [15:0]st_ctr,
        output reg mac_start,
        output reg st_start,
        output reg td_start
		// User ports ends
		// Do not modify the ports beyond this line

/*
		// Ports of Axi Master Bus Interface M00_AXI
		input wire  m00_axi_init_axi_txn,
		output wire  m00_axi_error,
		output wire  m00_axi_txn_done,
		input wire  m00_axi_aclk,
		input wire  m00_axi_aresetn,
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
		output wire [2 : 0] m00_axi_awprot,
		output wire  m00_axi_awvalid,
		input wire  m00_axi_awready,
		output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
		output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
		output wire  m00_axi_wvalid,
		input wire  m00_axi_wready,
		input wire [1 : 0] m00_axi_bresp,
		input wire  m00_axi_bvalid,
		output wire  m00_axi_bready,
		output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
		output wire [2 : 0] m00_axi_arprot,
		output wire  m00_axi_arvalid,
		input wire  m00_axi_arready,
		input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
		input wire [1 : 0] m00_axi_rresp,
		input wire  m00_axi_rvalid,
		output wire  m00_axi_rready,

		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
		*/
	);
	
	// Add user logic here

    // States for the FSM
    reg [4:0] c_state, r_state;
    reg [31:0] c_itr_ctr, r_itr_ctr;
    reg [15:0] c_ctr, r_ctr;

    // Op_vec module handshake signals
    reg c_done, r_done;
    reg c_scale, r_scale;
    reg c_op_sel, r_op_sel;
    reg c_in_1_sel, r_in_1_sel;
    reg [1:0] c_in_2_sel, r_in_2_sel;
    reg c_op_vec_start, r_op_vec_start;
	
	// MAC unit start signal
	reg c_mac_start, r_mac_start;
	
	// Termination detector start signal
	reg c_td_start, r_td_start;

	// Soft Threshold unit start signal
	reg c_st_start, r_st_start;
	
	// Counter used to hold start signal high for a few cycles
	reg [/*7*/31:0] c_counter, r_counter;

    reg c_td_done, r_td_done;
    	
    // Define the states of the FSM
    localparam  IDLE            =   5'd0,   // This is the initial/idle state   
                Z_U             =   5'd1,   // Calculates z - u and passes the result to MAC unit
                Z_U_WAIT_1      =   5'd2,   // Wait for the accelerator to finish
                Z_U_WAIT_2      =   5'd3,   // Wait for the accelerator to finish
                MAC             =   5'd4,   // Initiates the MAC unit
                MAC_WAIT_1      =   5'd5,   // Wait for the MAC unit to finish
                MAC_WAIT_2      =   5'd6,   // Wait for the MAC unit to finish
                Q_ADD           =   5'd7,   // Calculates MAC + q
                Q_ADD_WAIT_1    =   5'd8,   // Wait
                Q_ADD_WAIT_2    =   5'd9,   // Wait
                X_HAT           =   5'd10,  // Calculates x^ = alpha * x + (1-alpha) * z
                X_HAT_WAIT_1    =   5'd11,  // Wait
                X_HAT_WAIT_2    =   5'd12,  // Wait
                ST              =   5'd13,  // Soft threshold unit
                ST_WAIT_1       =   5'd14,  // Wait
                ST_WAIT_2       =   5'd15,  // Wait
                DONE            =   5'd16;
                
    // Define operands for the op vec module
               // Operand 1
    localparam READ_BRAM_Z  =   2'd0,
               READ_MAC     =   2'd1,
               
               // Operand 2
               READ_FEEDBACK    =   2'd0,
               READ_BRAM_U      =   2'd1,
               READ_BRAM_Q      =   2'd2;
    
    // Defaine Operations for op vec module
    localparam ADD  =   1'd0,
               SUB  =   1'd1;
               
    assign alpha = 32'h3F800000;
    assign rho_inv = 32'h3F800000;
    assign rho = 32'h3F800000;
    
    always @(*) begin
    
        c_state = r_state;
        
        c_itr_ctr = r_itr_ctr;
        c_ctr = r_ctr;
        
        c_done = r_done;
        c_td_done = r_td_done;
        
        c_op_vec_start = r_op_vec_start;
        c_mac_start = r_mac_start;
        c_st_start = r_st_start;
        c_td_start = r_td_start;
        
        c_scale = r_scale;
        c_op_sel = r_op_sel;
        c_in_1_sel = r_in_1_sel;
        c_in_2_sel = r_in_2_sel;
        
        c_counter = r_counter;
        
        case (r_state)
            
            IDLE: begin
            
                c_done = 1'b0;
                
                if (start == 1'b1) begin    
                    c_td_start = 1'b1;
                    c_state = Z_U;
                    c_itr_ctr = r_itr_ctr + 'd1;
                    c_ctr = r_ctr + 'd1;
                end                
            end
            
            Z_U: begin
            
                c_in_1_sel = READ_BRAM_Z;
                c_in_2_sel = READ_BRAM_U;
                c_op_vec_start = 1'b1;
                
                c_scale = 1'b0;
                
                c_op_sel = SUB;
                
                c_counter = 'd0;
                
                c_state = Z_U_WAIT_1;
                c_ctr = r_ctr + 'd1;
                               
            end
            
            Z_U_WAIT_1: begin
                
                if ( (r_counter + 'd1) < 'd4) begin
                    c_counter = r_counter + 'd1;
                end
        
                else begin
                    c_state = Z_U_WAIT_2;
                    c_op_vec_start = 1'b0;
                    c_ctr = r_ctr + 'd1;
                       
                end
                
            end
            
            Z_U_WAIT_2: begin   
               
                if (op_vec_done == 1'b1) begin 
                    c_state = MAC;
                    c_ctr = r_ctr + 'd1;
                 end
                 
            end
            
            MAC: begin
            
                c_mac_start = 1'b1;
                
                c_counter = 'd0;
                
                c_state = MAC_WAIT_1;
                c_ctr = r_ctr + 'd1;
                
            end
            
            MAC_WAIT_1: begin
               
                if ( (r_counter + 'd1) < 'd4) begin
                    c_counter = r_counter + 'd1;
                end
        
                else begin
               //     c_mac_start = 1'b0;
                    c_state = MAC_WAIT_2;
                    c_ctr = r_ctr + 'd1;
                end
                
            end
            
            MAC_WAIT_2: begin
                
                if (mac_done == 1'b1) begin 
                    c_mac_start = 1'b0;
                    c_state = Q_ADD;
                    c_ctr = r_ctr + 'd1;
                 end
            end
            
            Q_ADD: begin
            
                c_in_1_sel = READ_MAC;
                c_in_2_sel = READ_BRAM_Q;
                c_op_vec_start = 1'b1;
               
                c_scale = 1'b0;
                c_op_sel = ADD;
                
                c_counter = 'd0;
                
                c_state = Q_ADD_WAIT_1;
                c_ctr = r_ctr + 'd1;
                
            end
            Q_ADD_WAIT_1: begin
                
                if ( (r_counter + 'd1) < 'd4) begin
                        c_counter = r_counter + 'd1;
                end
        
                else begin
                    c_state = Q_ADD_WAIT_2;
                    c_op_vec_start = 1'b0;
                    c_ctr = r_ctr + 'd1;
                end
                
            end
            
            Q_ADD_WAIT_2: begin
                
                if (op_vec_done == 1'b1) begin
                    c_state = X_HAT;
                    c_ctr = r_ctr + 'd1;
                end
                
            end
            
            X_HAT: begin
            
                c_in_1_sel = READ_BRAM_Z;
                c_in_2_sel = READ_FEEDBACK;
                c_op_vec_start = 1'b1;
                
                c_op_sel = ADD;
                c_scale = 1'b1;
                
                c_counter = 'd0;
                
                c_state = X_HAT_WAIT_1;
                c_ctr = r_ctr + 'd1;
                
            end
            
            X_HAT_WAIT_1: begin
                if ( (r_counter + 'd1) < 'd4) begin
                    c_counter = r_counter + 'd1;
                end
    
                else begin
                    c_op_vec_start = 1'b0;
                    c_state = X_HAT_WAIT_2;
                    c_ctr = r_ctr + 'd1;
                end
            
            end
            
            X_HAT_WAIT_2: begin
             
                if (op_vec_done == 1'b1) begin
                    c_state = ST;
                    c_ctr = r_ctr + 'd1;
                end
                
            end
            
            ST: begin
                
                c_st_start = 1'b1;
                
                c_counter = 'd0;
                
                c_state = ST_WAIT_1;
                c_ctr = r_ctr + 'd1;
                
            end
            
            ST_WAIT_1: begin
            
                if ( (r_counter + 'd1) < 'd4) begin
                    c_counter = r_counter + 'd1;
                end
    
                else begin
                   // c_st_start = 1'b0;
                    c_state = ST_WAIT_2;
                    c_ctr = r_ctr + 'd1;
                end
                
            end
            
            ST_WAIT_2: begin
            
                if (st_done == 1'b1) begin 
                    c_st_start = 1'b0;
                    c_state = DONE;
                    c_ctr = r_ctr + 'd1;
                end
            
            end
            
            DONE: begin
                 
               if (r_itr_ctr < 32'd100 && r_td_done == 1'b0) begin
                    c_state = IDLE;
                    c_ctr = r_ctr + 'd1;
               end
               
               else begin
                    c_done = 1'b1;
                    c_itr_ctr = 32'd100;    // redundant, since r_td_done stays high 
               end
               
            end
            
            default: begin
            
                c_state = IDLE;
            
            end
        
        endcase
        
     end    //always
     
     always @(posedge clk) begin
     
        if (terminate == 1'b1)
            r_td_done <= 1'b1;
        else
            r_td_done <= (rst == 1'b0) ? 'd0 : c_td_done;
     end
     
     always @(posedge clk) begin
   
        // Active low reset
        r_state <= (rst == 1'b0)? 'd0 : c_state;
        
        done <= (rst == 1'b0) ? 'd0 : r_done;
        r_done <= (rst == 1'b0) ? 'd0 : c_done;
                
        st_ctr <= (rst == 1'b0) ? 'd0 : r_ctr;
        r_ctr <= (rst == 1'b0) ? 'd0 : c_ctr;
        
        r_itr_ctr <= (rst == 1'b0) ? 'd0 : c_itr_ctr;
        
        r_op_vec_start <= (rst == 1'b0) ? 'd0 : c_op_vec_start;
        op_vec_start <= (rst == 1'b0) ? 'd0 : r_op_vec_start;
        
        r_mac_start <= (rst == 1'b0) ? 'd0 : c_mac_start;
        mac_start <= (rst == 1'b0) ? 'd0 : r_mac_start;
       
        r_td_start <= (rst == 1'b0) ? 'd0 : c_td_start;
        td_start <= (rst == 1'b0) ? 'd0 : r_td_start;
        
        r_st_start <= (rst == 1'b0) ? 'd0 : c_st_start;
        st_start <= (rst == 1'b0) ? 'd0 : r_st_start;
        
        r_scale <= (rst == 1'b0) ? 'd0 : c_scale; 
        r_op_sel <= (rst == 1'b0) ? 'd0 : c_op_sel;
        r_in_1_sel <= (rst == 1'b0) ? 'd0 : c_in_1_sel;
        r_in_2_sel <= (rst == 1'b0) ? 'd0 : c_in_2_sel;
        
        scale <= (rst == 1'b0) ? 'd0 : r_scale; 
        op_sel <= (rst == 1'b0) ? 'd0 : r_op_sel;
        in_1_sel <= (rst == 1'b0) ? 'd0 : r_in_1_sel;
        in_2_sel <= (rst == 1'b0) ? 'd0 : r_in_2_sel;
        
        r_counter <= (rst == 1'b0) ? 'd0 : c_counter;
        
     end
     
	// User logic ends
	/*
// Instantiation of Axi Bus Interface M00_AXI
	controller_v1_0_M00_AXI # ( 
		.C_M_START_DATA_VALUE(C_M00_AXI_START_DATA_VALUE),
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M00_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_ADDR_WIDTH(C_M00_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M00_AXI_DATA_WIDTH),
		.C_M_TRANSACTIONS_NUM(C_M00_AXI_TRANSACTIONS_NUM)
	) controller_v1_0_M00_AXI_inst (
		.INIT_AXI_TXN(m00_axi_init_axi_txn),
		.ERROR(m00_axi_error),
		.TXN_DONE(m00_axi_txn_done),
		.M_AXI_ACLK(m00_axi_aclk),
		.M_AXI_ARESETN(m00_axi_aresetn),
		.M_AXI_AWADDR(m00_axi_awaddr),
		.M_AXI_AWPROT(m00_axi_awprot),
		.M_AXI_AWVALID(m00_axi_awvalid),
		.M_AXI_AWREADY(m00_axi_awready),
		.M_AXI_WDATA(m00_axi_wdata),
		.M_AXI_WSTRB(m00_axi_wstrb),
		.M_AXI_WVALID(m00_axi_wvalid),
		.M_AXI_WREADY(m00_axi_wready),
		.M_AXI_BRESP(m00_axi_bresp),
		.M_AXI_BVALID(m00_axi_bvalid),
		.M_AXI_BREADY(m00_axi_bready),
		.M_AXI_ARADDR(m00_axi_araddr),
		.M_AXI_ARPROT(m00_axi_arprot),
		.M_AXI_ARVALID(m00_axi_arvalid),
		.M_AXI_ARREADY(m00_axi_arready),
		.M_AXI_RDATA(m00_axi_rdata),
		.M_AXI_RRESP(m00_axi_rresp),
		.M_AXI_RVALID(m00_axi_rvalid),
		.M_AXI_RREADY(m00_axi_rready)
	);

// Instantiation of Axi Bus Interface S00_AXIS
	controller_v1_0_S00_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
	) controller_v1_0_S00_AXIS_inst (
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid)
	);

// Instantiation of Axi Bus Interface M00_AXIS
	controller_v1_0_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
	) controller_v1_0_M00_AXIS_inst (
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready)
	);

*/
	endmodule
