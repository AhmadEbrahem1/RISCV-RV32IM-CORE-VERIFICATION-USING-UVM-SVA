class OR_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);

    `uvm_object_utils(OR_sequence)
    int loop_count;
    
    function new(string name = "OR_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running OR instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 == OR_FUNCT3;     // OR has funct3 = 110
                funct7 == 7'b0000000;    // OR always uses funct7 = 0000000
                rs1 != 0;                // x0 is hardwired to zero
                rs2 != 0;                // x0 is hardwired to zero
                rd  != 0;                // Prevent writes to x0
            });
            finish_item(req);
        end
    endtask

endclass : OR_sequence