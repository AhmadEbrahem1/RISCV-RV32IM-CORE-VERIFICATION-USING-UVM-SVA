interface cv32e40p_debug_if(input bit clk_i);

    /***************************************
    / Instruction Fetch Stage Signals
    /***************************************/
    bit             debug_req_i;
    bit   [31:0]    dm_halt_addr_i;
    bit   [31:0]    dm_exception_addr_i;
    logic           debug_havereset_o;
    logic           debug_running_o;
    logic           debug_halted_o;
    
  /********************************************
  / Debug Interface Driving Clocking Block
  /********************************************/
	clocking cb_drv @(posedge clk_i);
		default  output #1step; 
		output	 debug_req_i, dm_halt_addr_i, dm_exception_addr_i;
		input	 negedge debug_havereset_o, debug_running_o, debug_halted_o;
	endclocking 
	
  /********************************************
  / Debug Interface Monitoring Clocking Block
  /********************************************/
	clocking cb_mon @(posedge clk_i);
    default  input #1step;
		input	 debug_req_i, dm_halt_addr_i, dm_exception_addr_i;
		input	 debug_havereset_o, debug_running_o, debug_halted_o;
	endclocking 

//********************************************//
// 1. assertion to check that the outputs are not asserted at the same time at any given time (has to be sva file)
// 2. assertion to check that the output havereset asserted only and during the reset assertion (has to be sva file)

endinterface : cv32e40p_debug_if