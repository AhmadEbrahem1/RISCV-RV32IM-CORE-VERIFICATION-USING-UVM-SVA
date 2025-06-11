interface cv32e40p_data_memory_if(input clk_i);

  /***************************************
  / Data Memory Interface Signals
  /***************************************/
	logic          data_req_o;
	logic        data_we_o;
	logic [ 3:0] data_be_o;
	logic [31:0] data_addr_o;
	logic [31:0] data_wdata_o;

	bit          data_gnt_i;
	bit          data_rvalid_i;
	bit   [31:0] data_rdata_i;

  /********************************************
  / Data Memory Interface Driving Clocking Block
  /********************************************/
	clocking cb_drv @(posedge clk_i);
		default  output #1step; 
		output	 data_gnt_i, data_rvalid_i, data_rdata_i;
		input	 negedge data_req_o, data_we_o, data_be_o, data_addr_o, data_wdata_o;
	endclocking 
	
  /********************************************
  / Data Memory Interface Monitoring Clocking Block
  /********************************************/
	clocking cb_mon @(posedge clk_i);
		default  output #1step; 
		input	negedge data_gnt_i, data_rvalid_i, data_rdata_i;
		input	negedge data_req_o, data_we_o, data_be_o, data_addr_o, data_wdata_o;
	endclocking 
	
  // ============================================ Related Assertions ===========================================
property req_valid_p;
  @(posedge clk_i)
  $rose(data_req_o) |-> ##[1:$] $rose(data_rvalid_i);
endproperty

property valid_r_data_p;
  @(posedge clk_i)
   $rose(data_rvalid_i) |-> !$isunknown(data_rdata_i) throughout data_rvalid_i;
endproperty

property req_has_valid_ctrl_p;
  @(posedge clk_i)
   $rose(data_req_o) |->  ( !$isunknown(data_addr_o) &&
    !$isunknown(data_we_o) &&
    !$isunknown(data_be_o) &&
    (data_we_o == 0 || !$isunknown(data_wdata_o)) ) throughout data_req_o;
endproperty

req_valid_ap: assert property (req_valid_p) ;
valid_r_data_ap: assert property (valid_r_data_p);
req_has_valid_ctrl_ap: assert property (req_has_valid_ctrl_p);

req_valid_cp: cover property (req_valid_p) ;
valid_r_data_cp: cover property (valid_r_data_p);
req_has_valid_ctrl_cp: cover property (req_has_valid_ctrl_p);
	
endinterface : cv32e40p_data_memory_if
