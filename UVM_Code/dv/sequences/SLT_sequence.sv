class SLT_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);
    `uvm_object_utils(SLT_sequence)
    int loop_count;
    
    function new(string name = "SLT_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running SLT instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 == SLT_MULHSU_FUNCT3;  // 3'b010
                funct7 == 7'b0000000;
            });
            finish_item(req);
        end
    endtask
endclass : SLT_sequence