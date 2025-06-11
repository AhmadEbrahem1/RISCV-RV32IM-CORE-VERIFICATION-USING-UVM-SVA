class JALR_sequence extends uvm_sequence #(base_sequence_item);

    `uvm_object_utils(JALR_sequence)

    int loop_count;
	logic [4:0] that_rd;
    localparam int INST_MEM_DEPTH = 500;

    function new(string name = "JALR_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req1, req2, req3, req4, req5,req6;

        // Create all request objects once, before repeat
        req1 = cv32e40p_if_sequence_item::type_id::create("req1");
        req2 = cv32e40p_if_sequence_item::type_id::create("req2");
        req3 = cv32e40p_if_sequence_item::type_id::create("req3");
        req4 = cv32e40p_if_sequence_item::type_id::create("req4");
        req5 = cv32e40p_if_sequence_item::type_id::create("req5");
		req6 = cv32e40p_if_sequence_item::type_id::create("req6");
        `uvm_info(get_type_name(), "Running JALR sequence test with random fillers", UVM_LOW)

        repeat (loop_count) begin
            // ------------------------------------------
            // Init x1 to x31: ADDI xN, x0, rand
            // ------------------------------------------
            for (int i = 0; i < 32; i++) begin
                start_item(req1);
                assert(req1.randomize() with {
                    instr_type == I_TYPE;
                    opcode     == OPCODE_I;
                    funct3     == ADDI_FUNCT3;
                    rs1        == 0;
                    rd         == i;
					imm_I <300;
                });
                finish_item(req1);
            end

            // ------------------------------------------
            // AUIPC rd, 0 ; rd = PC (random x1–x31)
            // ------------------------------------------
            start_item(req2);
            assert(req2.randomize() with {
                instr_type == U_TYPE;
                opcode     == OPCODE_AUIPC;
                imm_U      == 20'h00000;
				rd inside {[1:31]};
            });
            that_rd = req2.rd;
            finish_item(req2);

            // ------------------------------------------
            // ADDI that_rd, that_rd, imm (imm % 4 == 0)
            // ------------------------------------------
            start_item(req3);
            assert(req3.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_I;
                funct3     == ADDI_FUNCT3;
                rs1        == that_rd;
                rd         == that_rd;
                imm_I inside {[0:196]};
				imm_I % 4 == 0;
            });
            finish_item(req3);

            // ------------------------------------------
            // JALR x5, imm(that_rd)
            // ------------------------------------------
            start_item(req4);
            assert(req4.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_JALR;
                funct3     == 3'b000;
                rs1        == that_rd;
                rd         == 5;
                imm_I      %4== 0;
				imm_I dist { [-120:-4] := 1, [0:196] := 3 };  // -30 inst *4byte for pc 
            });
            finish_item(req4);

            // ------------------------------------------
            // Fill with 100 I-type (NOP/ADDI/XORI)
            // ------------------------------------------
            for (int i = 0; i < INST_MEM_DEPTH-36; i++) begin
                start_item(req5);
                randcase
					// NOP
                    1: assert(req5.randomize() with {
                        instr_type == I_TYPE;
                        opcode     == OPCODE_I;
                        funct3     == ADDI_FUNCT3;
                        rs1        == 0;
                        rd         == 0;
                        imm_I      == 0;
                    }); 
					// immediate
                    1: assert(req5.randomize() with {
                        instr_type inside {I_TYPE,U_TYPE};
						opcode   != OPCODE_LOAD;
						opcode   != OPCODE_JALR;
						 imm_I      < 100;
						 {imm_U, 12'b0}      < 100;
                    }); 
                endcase
                finish_item(req5);
            end
	//testing minimum imm value 
        end
		start_item(req3);
            assert(req3.randomize() with {
                instr_type == U_TYPE;
                opcode     == OPCODE_LUI;
                rs1        == that_rd;
                rd         == that_rd;
                {imm_U, 12'b0} %4 ==0;
				{imm_U, 12'b0}  ==2052;
            });
            finish_item(req3);
			
	    // ------------------------------------------
            // JALR x5, imm(that_rd)
            // ------------------------------------------
            start_item(req4);
            assert(req4.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_JALR;
                funct3     == 3'b000;
                rs1        == that_rd;
                rd         == 5;
                imm_I      ==-2048;
		
            });
            finish_item(req4);

        `uvm_info(get_type_name(), "Finished JALR sequence with jump and random fillers", UVM_LOW)
    endtask

endclass : JALR_sequence



/*
class JALR_sequence extends uvm_sequence #(base_sequence_item);

    `uvm_object_utils(JALR_sequence)

    int loop_count;

    function new(string name = "JALR_sequence");
        super.new(name);
    endfunction

    task body();
        cv32e40p_if_sequence_item req;

        `uvm_info(get_type_name(), "Running JALR sequence test with NOPs", UVM_LOW)

        repeat (loop_count) begin  // <--- repeat the whole sequence loop_count times

            // ------------------------------------------
            // 1. AUIPC x1, 0  ; x1 = PC
            // ------------------------------------------
            req = cv32e40p_if_sequence_item::type_id::create("auipc_req");
            start_item(req);
            assert(req.randomize() with {
                instr_type == U_TYPE;
                opcode     == OPCODE_AUIPC;
                rd         == 1;
                imm_U      == 20'h00000;
            });
            finish_item(req);

            // ------------------------------------------
            // 2. ADDI x1, x1, 20  ; x1 = x1 + 20 → jump target 5 instructions ahead
            // ------------------------------------------
            req = cv32e40p_if_sequence_item::type_id::create("addi_offset_req");
            start_item(req);
            assert(req.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_I;
                funct3     == ADDI_FUNCT3;
                rs1        == 1;
                rd         == 1;
                imm_I      == 20;
            });
            finish_item(req);

            // ------------------------------------------
            // 3. JALR x5, 0(x1)  ; jump to x1, save return addr in x5
            // ------------------------------------------
            req = cv32e40p_if_sequence_item::type_id::create("jalr_req");
            start_item(req);
            assert(req.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_JALR;
                funct3     == 3'b000;
                rs1        == 1;
                rd         == 5;
                imm_I      == 0;
            });
            finish_item(req);

            // ------------------------------------------
            // 4. Fill 5 instructions (20 bytes) with NOPs
            // NOP = addi x0, x0, 0
            // ------------------------------------------
            for (int i = 0; i < 5; i++) begin
                req = cv32e40p_if_sequence_item::type_id::create($sformatf("nop_req_%0d", i));
                start_item(req);
                assert(req.randomize() with {
                    instr_type == I_TYPE;
                    opcode     == OPCODE_I;
                    funct3     == ADDI_FUNCT3;
                    rs1        == 0;
                    rd         == 0;
                    imm_I      == 0;
                });
                finish_item(req);
            end

            // ------------------------------------------
            // 5. Jump Target: ADDI x6, x0, 0x123 ; Marker
            // ------------------------------------------
            req = cv32e40p_if_sequence_item::type_id::create("target_marker_req");
            start_item(req);
            assert(req.randomize() with {
                instr_type == I_TYPE;
                opcode     == OPCODE_I;
                funct3     == ADDI_FUNCT3;
                rs1        == 0;
                rd         == 6;
                imm_I      == 291;  // 0x123
            });
            finish_item(req);

        end // repeat loop_count

        `uvm_info(get_type_name(), "Finished JALR sequence with jump over NOPs", UVM_LOW)
    endtask

endclass : JALR_sequence
*/
