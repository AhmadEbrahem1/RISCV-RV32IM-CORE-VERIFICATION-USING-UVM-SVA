class SLLI_sequence extends uvm_sequence #(base_sequence_item);

	//Registering the env class in the factory
    `uvm_object_utils(SLLI_sequence)
	int loop_count;
/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "SLLI_sequence");
    super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
	cv32e40p_if_sequence_item req;
  
    req = cv32e40p_if_sequence_item::type_id::create("req");
    `uvm_info(get_type_name(), "Running SLLI_sequence instructions", UVM_LOW)

    repeat(loop_count) begin
		//SLLI
        start_item(req);
        assert(req.randomize() with {instr_type  == I_TYPE;
		opcode==OPCODE_I ;
		funct3 == SLLI_FUNCT3;});
	
        finish_item(req);
end
		
		
		//SLLI by 0
        start_item(req);
        assert(req.randomize() with {instr_type  == I_TYPE;
		opcode==OPCODE_I ;
		funct3 == SLLI_FUNCT3;
		shamt==0;});
	
        finish_item(req);
		//SLLI by 31
        start_item(req);
        assert(req.randomize() with {instr_type  == I_TYPE;
		opcode==OPCODE_I ;
		funct3 == SLLI_FUNCT3;
		shamt==31;});
	
        finish_item(req);
		
endtask

endclass : SLLI_sequence

