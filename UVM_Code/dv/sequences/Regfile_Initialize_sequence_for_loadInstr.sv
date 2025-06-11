class Regfile_Initialize_sequence_for_loadInstr extends uvm_sequence #(cv32e40p_if_sequence_item);
    `uvm_object_utils(Regfile_Initialize_sequence_for_loadInstr)
    
    function new(string name = "Regfile_Initialize_sequence_for_loadInstr");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Initializing all 31 registers with valid base addresses for 4KB memory", UVM_LOW)

        // Initialize x1-x31 with ADDI instructions with random signed immediate
        for (int i = 1; i <= 31; i++) begin
            start_item(req);

            assert(req.randomize() with {
                instr_type == I_TYPE;
		        opcode     == OPCODE_I ;
		        funct3     == ADDI_FUNCT3;
                rd         == i;
                rs1        == 0;
                imm_I      == 2044;
                });

            `uvm_info("REG_INIT", $sformatf("ADDI x%0d, x0, %0d (Instr: 0x%08h)", 
                req.rd, $signed(req.imm_I), req.instruction), UVM_HIGH)

            finish_item(req);
        end
    endtask
endclass : Regfile_Initialize_sequence_for_loadInstr
