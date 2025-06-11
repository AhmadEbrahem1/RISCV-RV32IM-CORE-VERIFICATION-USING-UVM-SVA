class LHU_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);
    `uvm_object_utils(LHU_sequence)
    int loop_count;
    
    function new(string name = "LHU_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running LHU instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == I_TYPE;
                opcode == OPCODE_LOAD;
                funct3 == LHU_FUNCT3;        // 3'b101
                imm_I inside {[0:2044]};
                imm_I % 4 == 0;              // Halfword-aligned
            });
            finish_item(req);
        end
    endtask
endclass : LHU_sequence