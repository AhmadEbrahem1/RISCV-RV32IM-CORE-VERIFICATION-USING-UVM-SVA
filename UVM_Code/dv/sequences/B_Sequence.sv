class B_Sequence extends uvm_sequence #(base_sequence_item);

	//Registering the env class in the factory
    `uvm_object_utils(B_Sequence)
	int loop_count;
/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "B_Sequence");
    super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
	cv32e40p_if_sequence_item req;
   
    req = cv32e40p_if_sequence_item::type_id::create("req");
    `uvm_info(get_type_name(), "Running B_Sequence  instructions", UVM_LOW)

    repeat(loop_count) begin

            // --------- write data to any rd  ---------
            start_item(req);
            assert(req.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_I;
                funct3     == ADDI_FUNCT3;
                rs1        == 0;          // x0 (zero register)
                rd inside {[1:31]};       // Valid register
            });
            finish_item(req);

            // --------- write data to any rd  ---------
            start_item(req);
            assert(req.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_I;
                funct3     == ADDI_FUNCT3;
                rs1        == 0;          // x0 (zero register)
                rd inside {[1:31]};       // Valid register
            });
            finish_item(req);




        start_item(req);
        // ADDI x10, x5, 2035
        assert(req.randomize() with {instr_type  == B_TYPE;
		});
        finish_item(req);
    end

endtask

endclass : B_Sequence

