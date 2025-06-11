class SRLI_sequence extends uvm_sequence #(base_sequence_item);

	//Registering the env class in the factory
    `uvm_object_utils(SRLI_sequence)
	int loop_count;
/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "SRLI_sequence");
    super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
	cv32e40p_if_sequence_item req;
  
    req = cv32e40p_if_sequence_item::type_id::create("req");
    `uvm_info(get_type_name(), "Running SRLI_sequence instructions", UVM_LOW)

    repeat(loop_count) begin
        start_item(req);
        //SRLI
        assert(req.randomize() with {instr_type  == I_TYPE;
		opcode==OPCODE_I ;
		funct3 == SRLI_SRAI_FUNCT3;
		imm_I[11:5] == 7'b0000000;	
		});
	
        finish_item(req);
	end
	
	
	start_item(req);
        //SRLI by 0 
        assert(req.randomize() with {instr_type  == I_TYPE;
		opcode==OPCODE_I ;
		funct3 == SRLI_SRAI_FUNCT3;
		imm_I[11:5] == 7'b0000000;
		shamt==0;
		});
	
        finish_item(req);
		
		
		start_item(req);
        //SRLI by 31
        assert(req.randomize() with {instr_type  == I_TYPE;
		opcode==OPCODE_I ;
		funct3 == SRLI_SRAI_FUNCT3;
		imm_I[11:5] == 7'b0000000;
		shamt==31;
		});
	
        finish_item(req);
		
		
		
endtask

endclass : SRLI_sequence

