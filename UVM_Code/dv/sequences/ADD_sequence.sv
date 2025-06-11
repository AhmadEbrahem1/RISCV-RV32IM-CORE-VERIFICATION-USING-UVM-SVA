class ADD_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);

    `uvm_object_utils(ADD_sequence)
    int loop_count;
    
    function new(string name = "ADD_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running ADD instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 == ADD_SUB_MUL_FUNCT3;
                funct7 == 7'b0000000;
            });
            finish_item(req);
        end
    endtask

endclass : ADD_sequence