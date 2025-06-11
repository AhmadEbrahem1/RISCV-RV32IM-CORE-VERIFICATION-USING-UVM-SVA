class LB_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);
    `uvm_object_utils(LB_sequence)
    int loop_count;
    
    function new(string name = "LB_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running LB instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == I_TYPE;
                opcode == OPCODE_LOAD;
                funct3 == LB_FUNCT3;
                imm_I inside {[0:2044]};     // to make sure that it hits the approbriate values of memory address min = 0 to max = 4095  
            });
            finish_item(req);
        end
    endtask
endclass : LB_sequence