
class NOP_sequence extends uvm_sequence #(base_sequence_item);

    // Register the sequence class with the factory
    `uvm_object_utils(NOP_sequence)

    int loop_count;

    /*******************************************************************************
    * Constructor: Initializes the sequence object
    *********************************************************************************/
    function new(string name = "NOP_sequence");
        super.new(name);
    endfunction

    /*********************************************************************
    * Body Task: Create, Randomize & Send HINT/NOP Instructions
    *********************************************************************/
    task body();
        cv32e40p_if_sequence_item req;

        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running extended NOP/HINT_sequence instructions", UVM_LOW)

        repeat (loop_count) begin
            start_item(req);

            assert(req.randomize() with {
                rd == 5'd0;
				// HINT instructions : act as NOP 
                
                     // ADDI x0, x0, 0 (classic NOP)
                        instr_type == I_TYPE;
                        opcode     == OPCODE_I;
                        funct3     == ADDI_FUNCT3;
                        rs1        == 0;
			 rd        == 0;
                        imm_I      == 12'd0;
            });

            finish_item(req);
        end
    endtask

endclass : NOP_sequence
