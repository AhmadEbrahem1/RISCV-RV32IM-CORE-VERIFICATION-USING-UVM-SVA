class cv32e40p_data_memory_sequence_item extends uvm_sequence_item;

  /**********************************************
  / Data Members (Outputs rand, inputs non-rand)
  /**********************************************/
	rand bit        data_gnt_i;
	rand bit        data_rvalid_i;
	rand bit [31:0] data_rdata_i;
	
	logic           data_req_o;
	logic           data_we_o;
	logic    [ 3:0] data_be_o; 
	logic    [31:0] data_addr_o;
	logic    [31:0] data_wdata_o;

	rand bit ready_for_req;
	rand int gnt_delay;
	rand int valid_delay;
	int outstanding_tx; 

    //Registering the class in factory& alongside its properties
    `uvm_object_utils_begin(cv32e40p_data_memory_sequence_item)
        //inputs
        `uvm_field_int(data_gnt_i, UVM_ALL_ON | UVM_NOCOMPARE) // make an enum
        `uvm_field_int(data_rvalid_i, UVM_ALL_ON | UVM_NOCOMPARE) // make an enum
        `uvm_field_int(data_rdata_i, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE)
        //outputs
        `uvm_field_int(data_req_o, UVM_ALL_ON) // make an enum
        `uvm_field_int(data_we_o, UVM_ALL_ON) // make an enum
        `uvm_field_int(data_be_o, UVM_ALL_ON) // make an enum
        `uvm_field_int(data_addr_o, UVM_ALL_ON)
        `uvm_field_int(data_wdata_o, UVM_ALL_ON)
        //control
        `uvm_field_int(valid_delay, UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(ready_for_req, UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(gnt_delay, UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(outstanding_tx, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_object_utils_end
	
  /*************
  / Constraints
  /*************/
  // constraint delay_bounds {
  //   delay inside {[0:2]};
  // }
 
  // constraint error_dist {
  //   slv_err dist {0 := 80, 1 := 20};
  // }
 
  /*********************************
  / Externed Methods to be used 
  /*********************************/
 
endclass : cv32e40p_data_memory_sequence_item