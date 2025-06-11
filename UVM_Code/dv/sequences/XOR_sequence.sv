class XOR_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);

    `uvm_object_utils(XOR_sequence)
    int loop_count;
    
    function new(string name = "XOR_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running XOR instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 == XOR_FUNCT3;    // XOR has funct3 = 100
                funct7 == 7'b0000000;    // XOR always uses funct7 = 0000000
                rs1 != rs2;              // Optional: Ensure different source regs for more interesting cases
            });
            finish_item(req);
        end
    endtask

endclass : XOR_sequence