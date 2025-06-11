class JAL_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);

    `uvm_object_utils(JAL_sequence)
    int loop_count;
    
    function new(string name = "JAL_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), $sformatf("Running %0d JAL instructions", loop_count), UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == J_TYPE;
                opcode == OPCODE_JAL;
                imm_J % 2 == 0;               // Jumps must be 2-byte aligned
            });
            
            `uvm_info("JAL_SEQ", $sformatf("Generated: JAL x%0d, PC+%0d (0x%0h)", 
                req.rd, $signed(req.imm_J), req.instruction), UVM_HIGH)
            
            finish_item(req);
        end
    endtask

endclass : JAL_sequence