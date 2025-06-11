class cv32e40p_if_sequence_item extends uvm_sequence_item;

	/**************************
  	/ IF and ID Stage Signals
  	**************************/
	
	parameter DATA_MEM_DEPTH= 4096; //16kb memory // 4076 workd
	parameter INST_MEM_DEPTH= 500;
    // Inputs
    rand bit           instr_gnt_i;
    rand bit           instr_rvalid_i;
    rand bit  [31:0]   instr_rdata_i;
	rand bit           fetch_enable_i;

    // Outputs
    logic       [31:0]  instr_addr_o;
	logic               instr_req_o;
    logic               core_sleep_o;

    // Instruction Fetch 2 Instruction Decode
  	logic                clear_instr_valid;  // Clear instruction valid flag
  	logic                pc_set;             // Set PC signal
  	logic       [ 3:0]   pc_mux;             // PC mux selector
  	logic       [ 2:0]   exc_pc_mux;         // Exception PC mux selector
  	logic       [ 1:0]   trap_addr_mux;      // Trap address mux selector

  	logic                is_fetch_failed_id;    // Fetch failed indication
  	logic       [31:0]   pc_id;              // Current PC in ID stage
	logic 		[31:0]	 pc_if;              // Instruction address output

    logic                instr_valid_id;
    logic       [31:0]   instr_rdata_id;     // Instruction sampled inside IF stage

	logic                id_ready; // Ready signal for IF stage
	logic                halt_if; // Halt IF stage signal
	logic 			     instr_req_int; // Internal instruction request signal

	logic 			     is_decoding; // High as long as Decoding is ON
	logic 		[ 3:0]   pc_mux_id;  // Mux selector for next PC

	// ========== Rand fields ==========
	
	// ========== Rand fields ==========
	
	rand instr_type_e instr_type;
	
	rand opcode_e 			  opcode;
	rand logic 			[ 4:0] rd;
	rand logic 			[ 2:0] funct3;
	rand logic 			[ 4:0] rs1;
	rand logic 			[ 4:0] rs2;
	rand logic 			[ 6:0] funct7;
	rand logic 			[31:0] imm;
	rand logic 			[31:0] instruction;
	
	// Immediate fields
	rand logic signed  	[11:0] imm_I;
	rand logic 			[ 4:0] shamt;
	rand logic signed 	[19:0] imm_U;
	rand logic signed 	[20:0] imm_J;
	rand logic signed 	[12:0] imm_B;
	rand logic signed 	[11:0] imm_s;
	//rand logic signed	[6: 0] imm_s2;
	
	rand int valid_delay;

	// ========== Constraints ==========
	
	constraint c_I_Type {
		(instr_type == I_TYPE) -> {
			opcode inside {OPCODE_I, OPCODE_JALR, OPCODE_LOAD};
			
			(opcode == OPCODE_I) -> {
				funct3 inside {
				ADDI_FUNCT3, SLTI_FUNCT3, SLTIU_FUNCT3,
				XORI_FUNCT3, ORI_FUNCT3, ANDI_FUNCT3,
				SLLI_FUNCT3, SRLI_SRAI_FUNCT3
				};
			}
			
			rd dist {[0:31] := 32};
			(rs1 != rd) dist {1 := 9, 0 := 1};
			imm_I dist {[1:2046] :/ 45,[-2047:-1] :/45,-2048:/5,2047 :/ 3, 0 :/2};

			(funct3 == SLLI_FUNCT3 && opcode==OPCODE_I) -> {
				imm_I[11:5] == 7'b0000000;
				imm_I[4:0] == shamt;}
			(funct3 == SRLI_SRAI_FUNCT3&& opcode==OPCODE_I) -> {
				imm_I[4:0] == shamt;
				imm_I[11:5] inside {7'b0000000, 7'b0100000};}
			(opcode == OPCODE_JALR) -> {
    				funct3 == 3'b000;
    				//(rs1 + imm_I < INST_MEM_DEPTH/2);
				}
			(opcode == OPCODE_LOAD) -> { 
				imm_I %4 ==0;
				funct3 inside {LB_FUNCT3, LH_FUNCT3, LW_FUNCT3,LBU_FUNCT3, LHU_FUNCT3};}
		}
	}
	
	constraint c_R_Type {
    	(instr_type == R_TYPE) -> {
			rd dist {[0:31] := 32};
			opcode == OPCODE_R;
			funct3 inside {ADD_SUB_MUL_FUNCT3, SLL_MULH_FUNCT3, SLT_MULHSU_FUNCT3, SLTU_MULHU_FUNCT3,
			XOR_FUNCT3, SRL_SRA_FUNCT3, OR_FUNCT3, AND_FUNCT3};

			(rs1 != rs2) dist {1 := 9, 0 := 1};
			(funct3 == ADD_SUB_MUL_FUNCT3 ) -> (funct7 inside {7'b0000000, 7'b0100000,7'b0000001});
			(funct3 ==  funct3 == SRL_SRA_FUNCT3) -> (funct7 inside {7'b0000000, 7'b0100000});
			(funct3 == SLL_MULH_FUNCT3 || funct3 == SLT_MULHSU_FUNCT3||funct3 == SLTU_MULHU_FUNCT3) -> (funct7 inside {7'b0000000, 7'b0000001});				
			(funct3 ==  funct3 == XOR_FUNCT3 ||funct3 == OR_FUNCT3||funct3 == AND_FUNCT3)  -> (funct7 inside {7'b0000000, 7'b0000001});
		}
	}

	constraint c_S_Type {
		(instr_type == S_TYPE) -> {
			rd dist {[0:31] := 32};
			opcode == OPCODE_S;
			funct3 inside {SB_FUNCT3, SH_FUNCT3, SW_FUNCT3};
			imm_s [1:0] == 2'b00;
			//{imm_s2, imm_s1} inside {[0:DATA_MEM_DEPTH/5]} ;
		}
	}
	
	constraint c_B_Type {
		(instr_type == B_TYPE) -> {
			rd dist {[0:31] := 32};
			opcode == OPCODE_B;
			funct3 inside {BEQ_FUNCT3, BNE_FUNCT3, BLT_FUNCT3, BGE_FUNCT3, BLTU_FUNCT3, BGEU_FUNCT3};
			imm_B < INST_MEM_DEPTH;
		}
	}
	
	constraint c_U_Type {
		(instr_type == U_TYPE) -> {
			opcode inside {OPCODE_LUI, OPCODE_AUIPC};
			rd != 0;
			(opcode == OPCODE_AUIPC) -> (imm_U < INST_MEM_DEPTH);
		}
	}
	
	constraint c_J_Type {
		(instr_type == J_TYPE) -> {
			rd dist {[1:31] := 31};
			opcode == OPCODE_JAL;
			imm_J< INST_MEM_DEPTH/2;
		}
	}
	
	// ========== Post-randomize logic ==========
	
	function void post_randomize();
		case (instr_type)
			R_TYPE: begin
				instruction = {funct7, rs2, rs1, funct3, rd, opcode};
			end
			I_TYPE: begin
				imm = {{20{imm_I[11]}}, imm_I}; // Sign extend
				instruction = {imm[11:0], rs1, funct3, rd, opcode};
			end
			S_TYPE: begin
				imm = {{20{imm_s[11]}}, imm_s};
				instruction = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
			end
			B_TYPE: begin
				imm = {{19{imm_B[12]}}, imm_B[12], imm_B[10:5], imm_B[4:1], imm_B[11]};
				instruction = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
			end
			U_TYPE: begin
				imm = {imm_U, 12'b0};
				instruction = {imm[31:12], rd, opcode};
			end
			J_TYPE: begin
				imm = {{11{imm_J[20]}}, imm_J[20], imm_J[10:1], imm_J[11], imm_J[19:12], 1'b0};
				instruction = {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
			end
			NOP: begin
				instruction = 32'h00000013; // NOP
			end
		endcase

		decode_instruction();
	endfunction
	
	// ========= Instruction Decode =========
	function void decode_instruction();
		string op_str;

		if (instr_type == I_TYPE) begin
			case (opcode)
				OPCODE_I: begin
					case (funct3)
						ADDI_FUNCT3: op_str = "addi";
						SLTI_FUNCT3: op_str = "slti";
						SLTIU_FUNCT3: op_str = "sltiu";
						XORI_FUNCT3: op_str = "xori";
						ORI_FUNCT3: op_str = "ori";
						ANDI_FUNCT3: op_str = "andi";
						SLLI_FUNCT3: op_str = "slli";
						SRLI_SRAI_FUNCT3: begin
							op_str = (imm_I[11:5] == 7'b0100000) ? "srai" : "srli";
						end
						default: op_str = "unknown_op_imm";
					endcase
					$display("Decoded I-type: %s x%0d, x%0d, %0d  ", op_str, rd, rs1, $signed(imm));
				end
				OPCODE_JALR: begin
					op_str = "jalr";
					$display("Decoded I-type: %s x%0d, %0d(x%0d)", op_str, rd, $signed(imm), rs1);
				end
				OPCODE_LOAD: begin
					case (funct3)
						3'b000: op_str = "lb";
						3'b001: op_str = "lh";
						3'b010: op_str = "lw";
						3'b100: op_str = "lbu";
						3'b101: op_str = "lhu";
						default: op_str = "unknown_load";
					endcase
					$display("Decoded LOAD: %s x%0d, %0d(x%0d)", op_str, rd, $signed(imm), rs1);
				end
				default: $display("Unknown I-type opcode: 0x%0h", opcode);
			endcase
		end
		else if (instr_type == R_TYPE && opcode == OPCODE_R) begin
			case ({funct7, funct3})
			{7'b0000000, ADD_SUB_MUL_FUNCT3}: op_str = "add";
			{7'b0100000, ADD_SUB_MUL_FUNCT3}: op_str = "sub";
			{7'b0000001, ADD_SUB_MUL_FUNCT3}: op_str = "mul";

			{7'b0000000, SLL_MULH_FUNCT3}: op_str = "sll";
			{7'b0000001, SLL_MULH_FUNCT3}: op_str = "mulh";

			{7'b0000000, SLT_MULHSU_FUNCT3}: op_str = "slt";
			{7'b0000001, SLT_MULHSU_FUNCT3}: op_str = "mulhsu";

			{7'b0000000, SLTU_MULHU_FUNCT3}: op_str = "sltu";
			{7'b0000001, SLTU_MULHU_FUNCT3}: op_str = "mulhu";

			{7'b0000000, XOR_FUNCT3}: op_str = "xor";
			{7'b0000001, XOR_FUNCT3}: op_str = "div";

			{7'b0000000, SRL_SRA_FUNCT3}: op_str = "srl";
			{7'b0000001, SRL_SRA_FUNCT3}: op_str = "divu";

			{7'b0100000, SRL_SRA_FUNCT3}: op_str = "sra";

			{7'b0000000, OR_FUNCT3}: op_str = "or";
			{7'b0000001, OR_FUNCT3}: op_str = "rem";

			{7'b0000000, AND_FUNCT3}: op_str = "and";
			{7'b0000001, AND_FUNCT3}: op_str = "remu";

			default: op_str = "unknown_r_type";
			endcase
			$display("Decoded R-type: %s x%0d, x%0d, x%0d", op_str, rd, rs1, rs2);
		end

		else if (instr_type == S_TYPE && opcode == OPCODE_S) begin
			case (funct3)
				SB_FUNCT3: op_str = "sb";
				SH_FUNCT3: op_str = "sh";
				SW_FUNCT3: op_str = "sw";
				default: op_str = "unknown_store";
			endcase
			$display("Decoded STORE: %s x%0d, %0d(x%0d)", op_str, rs2, imm_s, rs1);
		end
		else if (instr_type == B_TYPE && opcode == OPCODE_B) begin
			case (funct3)
				BEQ_FUNCT3: op_str = "beq";
				BNE_FUNCT3: op_str = "bne";
				BLT_FUNCT3: op_str = "blt";
				BGE_FUNCT3: op_str = "bge";
				BLTU_FUNCT3: op_str = "bltu";
				BGEU_FUNCT3: op_str = "bgeu";
				default: op_str = "unknown_branch";
			endcase
			$display("Decoded BRANCH: %s x%0d, x%0d, PC+%0d", op_str, rs1, rs2, $signed(imm));
		end
		else if (instr_type == U_TYPE) begin
			case (opcode)
				OPCODE_LUI: begin
					op_str = "lui";
					$display("Decoded U-type: %s x%0d, 0x%0h", op_str, rd, imm);
				end
				OPCODE_AUIPC: begin
					op_str = "auipc";
					$display("Decoded U-type: %s x%0d, PC+0x%0h", op_str, rd, imm);
				end
				default: $display("Unknown U-type opcode: 0x%0h", opcode);
			endcase
		end
		else if (instr_type == J_TYPE && opcode == OPCODE_JAL) begin
			op_str = "jal";
			$display("Decoded J-type: %s x%0d, PC+%0d", op_str, rd, $signed(imm));
		end
		else if (instr_type == NOP) begin
			$display("Decoded NOP instruction");
		end
		else begin
			$display("Instruction decode not implemented for instr_type: %0d", instr_type);
		end
	endfunction

`uvm_object_utils_begin(cv32e40p_if_sequence_item)
        // Inputs
        `uvm_field_int(instr_gnt_i, UVM_ALL_ON | UVM_NOCOMPARE)// make an enum
        `uvm_field_int(instr_rvalid_i, UVM_ALL_ON | UVM_NOCOMPARE)// make an enum
        `uvm_field_int(instr_rdata_i, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE)
        `uvm_field_int(fetch_enable_i, UVM_ALL_ON)// make an enum
        // Outputs
        `uvm_field_int(instr_addr_o, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(instr_req_o, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
        `uvm_field_int(core_sleep_o, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
        // Instruction Fetch 2 Instruction Decode
        `uvm_field_int(clear_instr_valid, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
        `uvm_field_int(pc_set, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
        `uvm_field_int(pc_mux, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
        `uvm_field_int(exc_pc_mux, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
        `uvm_field_int(trap_addr_mux, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
        `uvm_field_int(is_fetch_failed_id, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
        `uvm_field_int(pc_id, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE | UVM_NOPRINT)
		`uvm_field_int(pc_if, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE | UVM_NOPRINT)
        `uvm_field_int(instr_valid_id, UVM_ALL_ON)
        `uvm_field_int(instr_rdata_id, UVM_ALL_ON | UVM_HEX)
		`uvm_field_int(id_ready, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
		`uvm_field_int(halt_if, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
		`uvm_field_int(instr_req_int, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
		`uvm_field_int(is_decoding, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)// make an enum
        //Control Variables
        `uvm_field_int(valid_delay, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)
        `uvm_field_int(instruction, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE | UVM_NOPRINT)
		
		`uvm_field_enum(instr_type_e, instr_type, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)
		`uvm_field_enum(opcode_e, opcode, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE | UVM_NOPRINT)
        `uvm_field_int(rd, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)
        `uvm_field_int(funct3, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)
        `uvm_field_int(rs1, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)
        `uvm_field_int(rs2, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)
        `uvm_field_int(funct7, UVM_ALL_ON | UVM_NOCOMPARE | UVM_NOPRINT)
        `uvm_field_int(imm, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE | UVM_NOPRINT)
        `uvm_field_int(instruction, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE | UVM_NOPRINT)
    `uvm_object_utils_end

	function new(string name = "cv32e40p_if_sequence_item");
		super.new(name);
	endfunction 

endclass : cv32e40p_if_sequence_item
