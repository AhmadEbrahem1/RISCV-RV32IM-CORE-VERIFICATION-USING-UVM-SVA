class ShLoad_sequence extends uvm_sequence #(base_sequence_item);

    // Register the sequence class with the factory
    `uvm_object_utils(ShLoad_sequence)

    int loop_count;
    /*******************************************************************************
    * Constructor: Initializes the sequence object
    *********************************************************************************/
    function new(string name = "ShLoad_sequence");
        super.new(name);
    endfunction

    /*********************************************************************
    * Body Task: Create, Randomize & Send HINT/NOP Instructions
    *********************************************************************/
    task body();
        cv32e40p_if_sequence_item req,req1,req2,req3,req4,req5,req6;

        req  = cv32e40p_if_sequence_item::type_id::create("req");
        req1 = cv32e40p_if_sequence_item::type_id::create("req1");
        req2 = cv32e40p_if_sequence_item::type_id::create("req2");
        req3 = cv32e40p_if_sequence_item::type_id::create("req3");
        req4 = cv32e40p_if_sequence_item::type_id::create("req4");
        req5 = cv32e40p_if_sequence_item::type_id::create("req5");
        req6 = cv32e40p_if_sequence_item::type_id::create("req6");

        repeat (loop_count) begin
            // --------- write to any rd as base address  ---------
            start_item(req);
            assert(req.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_I;
                funct3     == ADDI_FUNCT3;
                rs1        == 0;          // x0 (zero register)
                imm_I % 4  == 0;         // Word-aligned
                imm_I inside {[0:DATA_MEM_DEPTH-4]};  // Avoid overflow
                rd inside {[1:31]};       // Valid register
            });
            finish_item(req);


            // --------- write to any rd as data  ---------
            start_item(req1);
            assert(req1.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_I;
                funct3     == ADDI_FUNCT3;
                rs1        == 0;
                rd inside {[1:31]};
                rd != req.rd;             // Avoid overlap
            });
            finish_item(req1);           

            // --------- store half of data to base address plus offset  ---------
            start_item(req2);
            assert(req2.randomize() with {
                instr_type == S_TYPE;
                funct3     == SH_FUNCT3;
                rs1        == req.rd;     // Base address
                rs2        == req1.rd;    // Data to store
                imm_s % 2  == 0;         // byte-aligned
                (req.imm_I + imm_s) inside {[0:DATA_MEM_DEPTH-4]};  // No overflow
            });
            finish_item(req2);


            // --------- load byte of data to target register  ---------
            start_item(req3);
            assert(req3.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_LOAD;
                funct3     == LB_FUNCT3;        
                imm_I      == req2.imm_s;
                rs1        == req.rd;
                rd         != req.rd;
                rd         != 0; 
            });
            finish_item(req3);

            // --------- load half of data to target register  ---------
            start_item(req4);
            assert(req4.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_LOAD;
                funct3     == LH_FUNCT3;
                rs1        == req.rd;     // Same base
                imm_I      == req2.imm_s; // Same offset
                rd inside {[1:31]};
                rd != req.rd && rd != req1.rd;  // Unique target
            });
            finish_item(req4);            


            // --------- load byte(unsigned) of data to target register  ---------
            start_item(req5);
            assert(req5.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_LOAD;
                funct3     == LBU_FUNCT3;        
                imm_I      == req2.imm_s;
                rs1        == req.rd;
                rd         != req.rd;
                rd         != 0;
            });
            finish_item(req5); 

            // --------- load HALF(unsigned) of data to target register  ---------
            start_item(req6);
            assert(req6.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_LOAD;
                funct3     == LHU_FUNCT3;       
                rs1        == req.rd;     // Same base
                imm_I      == req2.imm_s; // Same offset
                rd inside {[1:31]};
                rd != req.rd && rd != req1.rd;  // Unique target
            });
            finish_item(req6);           

        end
    endtask

endclass : ShLoad_sequence
