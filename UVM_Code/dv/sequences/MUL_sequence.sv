
class MUL_sequence extends uvm_sequence #(base_sequence_item);

	//Registering the env class in the factory
    `uvm_object_utils(MUL_sequence)

	int loop_count;
/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "MUL_sequence");
    super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
	cv32e40p_if_sequence_item req;
  
    req = cv32e40p_if_sequence_item::type_id::create("req");
    `uvm_info(get_type_name(), "Running MUL_sequence instructions", UVM_LOW)

    repeat(loop_count) begin
        start_item(req);
        // ADDI x10, x5, 2035
        assert(req.randomize() with {instr_type  == R_TYPE;
		opcode==OPCODE_R ;
		( funct3 == ADD_SUB_MUL_FUNCT3 ||funct3 == SLL_MULH_FUNCT3 || funct3 == SLT_MULHSU_FUNCT3 || funct3 == SLTU_MULHU_FUNCT3 );
		(funct7 == 7'b0000001);
		});
	
        finish_item(req);
end
endtask

endclass : MUL_sequence

