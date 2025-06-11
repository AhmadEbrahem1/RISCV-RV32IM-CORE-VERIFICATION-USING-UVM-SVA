class R_sequence extends uvm_sequence #(base_sequence_item);

	//Registering the env class in the factory
    `uvm_object_utils(R_sequence)
	int loop_count;
/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "R_sequence");
    super.new(name);
	
endfunction


/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
	cv32e40p_if_sequence_item req;
  
    req = cv32e40p_if_sequence_item::type_id::create("req");
    `uvm_info(get_type_name(), "Running R_sequence instructions", UVM_LOW)

    repeat(loop_count) begin
        start_item(req);
        // ADDI x10, x5, 2035
        assert(req.randomize() with {instr_type  == R_TYPE;
		});
        finish_item(req);
    end

endtask

endclass : R_sequence

