
class Hazard_sequence extends uvm_sequence #(base_sequence_item);

    `uvm_object_utils(Hazard_sequence)

    int loop_count;

    function new(string name = "Hazard_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req1, req2, req3, req4, req5, req6;
        cv32e40p_if_sequence_item req7, req8, req9, req10,req_break;
        logic [4:0] reg_raw, reg_waw, reg_load;
	logic [4:0] target_rd ;

        `uvm_info(get_type_name(), "Running all hazard types in sequence", UVM_LOW)

        repeat (loop_count) begin
            //--------------------------
            // RAW Hazard
            //--------------------------
            req1 = cv32e40p_if_sequence_item::type_id::create("req1");
            start_item(req1);
            assert(req1.randomize() with {
                instr_type == I_TYPE;
				opcode		!= OPCODE_JALR;
				opcode		!= OPCODE_LOAD;
            });
            reg_raw = req1.rd;
            finish_item(req1);

            req2 = cv32e40p_if_sequence_item::type_id::create("req2");
            start_item(req2);
            assert(req2.randomize() with {
                instr_type == I_TYPE;
				opcode		!= OPCODE_JALR;
				opcode		!= OPCODE_LOAD;
                rs1 == reg_raw;
            });
            finish_item(req2);

            //--------------------------
            // WAW Hazard
            //--------------------------
            req3 = cv32e40p_if_sequence_item::type_id::create("req3");
            start_item(req3);
            assert(req3.randomize() with {
                instr_type == I_TYPE;
				opcode		!= OPCODE_JALR;
				opcode		!= OPCODE_LOAD;
            });
			reg_waw = req3.rd;
            finish_item(req3);
			
			
            req4 = cv32e40p_if_sequence_item::type_id::create("req4");
            start_item(req4);
            assert(req4.randomize() with {
                instr_type == I_TYPE;
				opcode		!= OPCODE_JALR;
				opcode		!= OPCODE_LOAD;
                rd == reg_waw;
            });
            finish_item(req4);

            //--------------------------
            // Load-Use Hazard
            //--------------------------


            req5 = cv32e40p_if_sequence_item::type_id::create("req5");
            start_item(req5);
            assert(req5.randomize() with {
                instr_type == I_TYPE;
                opcode == OPCODE_LOAD;
				imm_I %4==0;
				imm_I>=0;
				imm_I <=DATA_MEM_DEPTH;
				rs1 ==0;
            });
			reg_load = req5.rd;
            finish_item(req5);

            req6 = cv32e40p_if_sequence_item::type_id::create("req6");
            start_item(req6);
            assert(req6.randomize() with {
                instr_type == I_TYPE;
				opcode		!= OPCODE_JALR;
				opcode		!= OPCODE_LOAD;
                rs1 		== reg_load;
            });
            finish_item(req6);

            //--------------------------
            // Full Self-Dependency: ADD x1, x1, x1
            //--------------------------

            req7 = cv32e40p_if_sequence_item::type_id::create("req7");
            start_item(req7);
            assert(req7.randomize() with {
                instr_type == R_TYPE;
                rd == rs1;
                rs2 == rs1;
                funct3 == ADD_SUB_MUL_FUNCT3;
                funct7 == 7'b0000000;
            });
            finish_item(req7);

            //--------------------------
            // Back-to-Back Writes to Same Register 
			//ADD  > sub > mul
            //--------------------------
            

            req8 = cv32e40p_if_sequence_item::type_id::create("req8");
            start_item(req8);
            assert(req8.randomize() with {
                instr_type == R_TYPE;
                funct3 == ADD_SUB_MUL_FUNCT3;
                funct7 == 7'b0000000;
            });
			target_rd =req8.rd;
            finish_item(req8);

            req9 = cv32e40p_if_sequence_item::type_id::create("req9");
            start_item(req9);
            assert(req9.randomize() with {
                instr_type == R_TYPE;
                rd == target_rd;
                funct3 == ADD_SUB_MUL_FUNCT3;
                funct7 == 7'b0100000;
            });
            finish_item(req9);

            req10 = cv32e40p_if_sequence_item::type_id::create("req10");
            start_item(req10);
            assert(req10.randomize() with {
                instr_type == R_TYPE;
                rd == target_rd;
                funct3 == ADD_SUB_MUL_FUNCT3;
                funct7 == 7'b0000001;
            });
            finish_item(req10);
			/*
			req_break = cv32e40p_if_sequence_item::type_id::create("break_instr");
			start_item(req_break);
			req_break.instruction = 32'h00100073;
			finish_item(req_break);
		*/
        end
		
		//directed test
		 // ========== LUI x2, 0x00000 ==========
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == U_TYPE;
			opcode == OPCODE_LUI;
			rd == 2;
			imm_U == 20'h00000 >> 12;  // Only upper 20 bits
		});
		finish_item(req10);
		
		 // add 100 to x2
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 2;
			rs1 == 2;
			imm_I == 100;    // add 100 to x2
		});
finish_item(req10);
		// ========== ADDI x3, x0, 42 ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 3;
			rs1 == 0;
			imm_I == 42;
		});
		finish_item(req10);
		
		// ========== ADDI x4, x0, 100 ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 4;
			rs1 == 0;
			imm_I == 100;
		});
		finish_item(req10);
		
		// ========== SW x3, 0(x2) ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == S_TYPE;
			opcode == OPCODE_S;
			funct3 == SW_FUNCT3;
			rs1 == 2;   // base
			rs2 == 3;   // value
			imm_s == 0;
		});
		finish_item(req10);
		
		// ========== SW x4, 4(x2) ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == S_TYPE;
			opcode == OPCODE_S;
			funct3 == SW_FUNCT3;
			rs1 == 2;
			rs2 == 4;
			imm_s == 4;
		});
		finish_item(req10);
		
		// ========== LW x5, 0(x2) ==========
	
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_LOAD;
			funct3 == LW_FUNCT3;
			rd == 5;
			rs1 == 2;
			imm_I == 0;
		});
		finish_item(req10);
		
		// ========== LW x6, 4(x2) ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_LOAD;
			funct3 == LW_FUNCT3;
			rd == 6;
			rs1 == 2;
			imm_I == 4;
		});
		finish_item(req10);
		
		// ========== BEQ x5, x3, label_equal ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == B_TYPE;
			opcode == OPCODE_B;
			funct3 == BEQ_FUNCT3;
			rs1 == 5;
			rs2 == 3;
			imm_B == 8;  // Assume 8-byte offset to label_equal
		});
		finish_item(req10);
		
		// ========== ADDI x7, x0, 1 (should be skipped) ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 7;
			rs1 == 0;
			imm_I == 1;
		});
		finish_item(req10);
		//label_equal:
		// ========== BNE x6, x3, label_not_equal ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == B_TYPE;
			opcode == OPCODE_B;
			funct3 == BNE_FUNCT3;
			rs1 == 6;
			rs2 == 3;
			imm_B == 8;  // Assume 8-byte offset to label_not_equal
		});
		finish_item(req10);
		
		// ========== ADDI x7, x0, 2 (should be skipped) ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 7;
			rs1 == 0;
			imm_I == 2;
		});
		finish_item(req10);
		//label_not_equal:
		// ========== ADDI x7, x0, 3 ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 7;
			rs1 == 0;
			imm_I == 3;
		});
		finish_item(req10);
		
		// ========== ADDI x10, x0, 8 ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 10;
			rs1 == 0;
			imm_I == 8;
		});
		finish_item(req10);
		
		// ========== AUIPC x2, 0 ==========
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == U_TYPE;
			opcode == OPCODE_AUIPC;
			rd == 2;
			imm_U == 20'd0;   // x2 = PC + 0 at this instruction
		});
		finish_item(req10);
		// ========== JALR x1, 12(x2) ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_JALR;
			funct3 == 3'b000;
			rd == 1;
			rs1 == 2;        // base x2
			imm_I == 12;      // offset from x2
		});
		finish_item(req10);
		
		// ========== ADDI x7, x0, 9 (should be skipped) ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 7;
			rs1 == 0;
			imm_I == 9;
		});
		finish_item(req10);
		
		// ========== ADDI x8, x0, 99 (landed here from JALR) ==========
		
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 8;
			rs1 == 0;
			imm_I == 99;
		});
		finish_item(req10);
		
		// ========== JALR x0, 16(x1) (return from jump) ==========
	
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_JALR;
			funct3 == 3'b000;
			rd == 0;
			rs1 == 1;
			imm_I == 16;
		});
		finish_item(req10);
		
		
		
		// misalignment test:
		

		// LUI   x2, 0x10000       # x2 = 0x10000000 (base address)
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == U_TYPE;
			opcode == OPCODE_LUI;
			rd == 2;
			imm_U == 20'h10000; // upper immediate = 0x10000
		});
		finish_item(req10);
		
		// ADDI  x3, x0, 42        # x3 = 42 (test data)
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 3; rs1 == 0;
			imm_I == 42;
		});
		finish_item(req10); 
		
		// ADDI  x4, x0, 3         # x4 = 3 (misaligned offset)
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 4; rs1 == 0;
			imm_I == 3; // misaligned offset
		});
		finish_item(req10);
		// ADD   x5, x2, x4        # x5 = x2 + x4 = 0x10000003 (misaligned address)
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == R_TYPE;
			opcode == OPCODE_R;
			funct3 == ADD_SUB_MUL_FUNCT3;
			funct7 == 7'b0000000;
			rd == 5; rs1 == 2; rs2 == 4;
		});
		finish_item(req10);
		
		// SW    x3, 0(x5)         # Store x3 (42) to mem at 0x10000003 (misaligned addr)
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == S_TYPE;
			opcode == OPCODE_S;
			funct3 == SW_FUNCT3;
			rs1 == 5; rs2 == 3;
			imm_s == 0; // offset 0 from x5
		});
		finish_item(req10);
		
		// JALR  x1, 3(x2)          # Jump to x2 + 3 (0x10000003) - misaligned jump
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_JALR;
			funct3 == 3'b000;
			rd == 1; rs1 == 2;
			imm_I == 3; // misaligned target
		});
		finish_item(req10);
		
		// ADDI  x6, x0, 99        # x6 = 99, should be skipped if jump taken or trap occurs
		start_item(req10);
		assert(req10.randomize() with {
			instr_type == I_TYPE;
			opcode == OPCODE_I;
			funct3 == ADDI_FUNCT3;
			rd == 6; rs1 == 0;
			imm_I == 99;
		});
		finish_item(req10);

		
    endtask

endclass : Hazard_sequence

