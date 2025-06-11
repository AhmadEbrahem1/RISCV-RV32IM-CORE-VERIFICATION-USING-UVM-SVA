class SLTU_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);
    `uvm_object_utils(SLTU_sequence)
    int loop_count;
    
    function new(string name = "SLTU_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running SLTU instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 == SLTU_MULHU_FUNCT3;  // 3'b011
                funct7 == 7'b0000000;         // SLTU specific
            });
            finish_item(req);
        end
    endtask
endclass : SLTU_sequence