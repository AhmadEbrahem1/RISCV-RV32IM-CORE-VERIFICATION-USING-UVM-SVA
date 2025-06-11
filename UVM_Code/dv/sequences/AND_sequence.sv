class AND_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);

    `uvm_object_utils(AND_sequence)
    int loop_count;
    
    function new(string name = "AND_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running AND instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 == AND_FUNCT3;    // AND has funct3 = 111
                funct7 == 7'b0000000;    // AND always uses funct7 = 0000000
            });
            finish_item(req);
        end
    endtask

endclass : AND_sequence