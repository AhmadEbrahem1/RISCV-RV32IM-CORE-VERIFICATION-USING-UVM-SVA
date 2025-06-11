interface cv32e40p_instruction_memory_if(input bit clk_i);

    /***************************************
    / Instruction Fetch Stage Signals
    /***************************************/
    logic   rst_n;

    bit           instr_gnt_i;
    bit           instr_rvalid_i;
    bit   [31:0]    instr_rdata_i;
    bit           fetch_enable_i;

    logic           instr_req_o;
    logic           core_sleep_o;
	logic [31:0]    instr_addr_o;

    /****************************************************
    / Instruction Fetch Interface Driving Clocking Block
    /***************************************************/
	// Driving Clocking Block: sample on negedge, drive after posedge
	clocking cb_drv @( posedge clk_i);
		default  output #1step; 
		output  instr_gnt_i, instr_rvalid_i, instr_rdata_i, fetch_enable_i;
		input   negedge instr_req_o, instr_addr_o, core_sleep_o;
	endclocking
	
	/******************************************************
	* Instruction Fetch Interface Monitoring Clocking Block
	******************************************************/
	clocking cb_mon @( posedge clk_i);
		default  output #1step; 
		input  instr_req_o, instr_addr_o, core_sleep_o;
		input  instr_gnt_i, instr_rvalid_i, instr_rdata_i, fetch_enable_i;
	endclocking

  // ============================================ Related Assertions ===========================================

	//flow of req-rsp
	 property req_trigg_p;
		@(posedge clk_i)
		$rose(instr_req_o) |->  ##[1:3] $rose(instr_rvalid_i); 
	endproperty
	
	//req only occurs at gnt 
	 property req_gnt_p ;
		@(posedge clk_i)
		instr_req_o |->  instr_gnt_i;
	endproperty
	
	//gnt is always 1 
	property always_granted_p;
		@(posedge clk_i) instr_gnt_i;
	endproperty
	
	//aligned addres
	property  aligned_address_p ;
		@(posedge clk_i)
		instr_req_o |-> (instr_addr_o[1:0] == 2'b00);
	endproperty

	req_trigg_ap:			assert property (req_trigg_p);
	req_gnt_ap:				assert property (req_gnt_p);
	always_granted_ap: 		assert property (always_granted_p);
	aligned_address_ap :	assert property (aligned_address_p);

	req_trigg_cp:			cover property (req_trigg_p);
	req_gnt_cp:				cover property (req_gnt_p);
	always_granted_cp: 		cover property (always_granted_p);
	aligned_address_cp :	cover property (aligned_address_p);

endinterface : cv32e40p_instruction_memory_if
