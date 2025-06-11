class BEQ_sequence extends uvm_sequence #(base_sequence_item);

	//Registering the env class in the factory
    `uvm_object_utils(BEQ_sequence)
	int loop_count;
/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "BEQ_sequence");
    super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
	cv32e40p_if_sequence_item req,req1,req2;
   
    req = cv32e40p_if_sequence_item::type_id::create("req");
    req1 = cv32e40p_if_sequence_item::type_id::create("req1");
    req2 = cv32e40p_if_sequence_item::type_id::create("req2");
    `uvm_info(get_type_name(), "Running BEQ_sequence  instructions", UVM_LOW)

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
        start_item(req1);
        assert(req1.randomize() with {
            instr_type == I_TYPE;
            opcode     == OPCODE_I;
            funct3     == ADDI_FUNCT3;
            rs1        == 0;          // x0 (zero register)
            imm_I      == req.imm_I;
            rd inside {[1:31]};       // Valid register
        });
        finish_item(req1);


        start_item(req2);
        assert(req2.randomize() with {
            instr_type  == B_TYPE;
            funct3      == BEQ_FUNCT3;
            rs1         == req.rd;
            rs2         == req1.rd;
            imm_B       == 8; 
		});
        finish_item(req2);
    end

endtask

endclass : BEQ_sequence

