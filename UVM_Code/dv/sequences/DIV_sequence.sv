class DIV_sequence extends uvm_sequence #(cv32e40p_if_sequence_item);

    `uvm_object_utils(DIV_sequence)
    int loop_count;
    
    function new(string name = "DIV_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;
        
        req = cv32e40p_if_sequence_item::type_id::create("req");
        `uvm_info(get_type_name(), "Running DIV instructions", UVM_LOW)

        repeat(loop_count) begin
            start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 inside {XOR_FUNCT3,SRL_SRA_FUNCT3 } ;
                funct7 == 7'b0000001;
            });
            finish_item(req);
        end
		
		
			
			// lui -2^31 into x5
			
			// LUI x5, 0x80000 → loads 0x80000 << 12 = 0x80000000 into x5
			start_item(req);
			assert(req.randomize() with {
				instr_type  == U_TYPE;
				opcode      == OPCODE_LUI;
				rd          == 5;
				imm_U       == 20'h80000; // upper 20 bits of 0x80000000
			});
			finish_item(req);
			// addi x31, x0, -1
		start_item(req);
		assert(req.randomize() with {
			instr_type  == I_TYPE;
			opcode      == OPCODE_I;
			funct3      == ADDI_FUNCT3;
			rd          == 31;
			rs1         == 0;
			imm_I       == 12'hFFF; // -1 in 12-bit signed (2's comp)
		});
		finish_item(req);
			
			// div Overflow x5 / x31
			start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 inside {XOR_FUNCT3 } ;
                funct7 == 7'b0000001;
				rs1==5;
				rs2==31;
				rd!=5;
				rd!=31;
            });
            finish_item(req);
			// divu Overflow x5 / x31
			start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 inside {SRL_SRA_FUNCT3 } ;
                funct7 == 7'b0000001;
				rs1==5;
				rs2==31;
				rd!=5;
				rd!=31;
				
            });
            finish_item(req);
			
			//DIV by 0 
		start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 inside {XOR_FUNCT3 } ;
                funct7 == 7'b0000001;
				rs2==0;
				rs1==5;
				rd!=5;
				rd!=31;
				
            });
            finish_item(req);
		//DIVU by 0 
		start_item(req);
            assert(req.randomize() with {
                instr_type == R_TYPE;
                opcode == OPCODE_R;
                funct3 inside {SRL_SRA_FUNCT3 } ;
                funct7 == 7'b0000001;
				rs2==0;
				rs1==5;
				rd!=5;
				rd!=31;
				
            });
            finish_item(req);
			
		
    endtask

endclass : DIV_sequence