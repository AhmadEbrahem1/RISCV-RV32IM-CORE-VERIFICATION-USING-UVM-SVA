class SUB_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);

    `uvm_object_utils(SUB_sequence)
    int loop_count;
    
    function new(string name = "SUB_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running SUB instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 == ADD_SUB_MUL_FUNCT3;  // Same funct3 as ADD
                funct7 == 7'b0100000;          // SUB has funct7 = 0100000
            });
            finish_item(req);
        end
    endtask

endclass : SUB_sequence