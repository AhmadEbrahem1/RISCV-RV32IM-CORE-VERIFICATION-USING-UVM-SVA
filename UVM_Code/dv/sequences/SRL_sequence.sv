class SRL_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);
    `uvm_object_utils(SRL_sequence)
    int loop_count;
    
    function new(string name = "SRL_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running SRL instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 == SRL_SRA_FUNCT3;   // 3'b101
                funct7 == 7'b0000000;       // SRL specific
            });
            finish_item(req);
        end
    endtask
endclass : SRL_sequence