
covergroup I_type_covgrp (input int i, input int imm_diff_val, input opcode_e opcode_o, input cv32e40p_id_sequence_item cov, ref logic signed [31:0] rf [32]);
   // option.name =  (opcode_o == OPCODE_I && i == 0 && imm_diff_val == 0)  ? "ADDI" : 
   //                (opcode_o == OPCODE_I && i == 1 && imm_diff_val == 0)  ? "SLLI" :
   //                (opcode_o == OPCODE_I && i == 2 && imm_diff_val == 0)  ? "SLTI" :
   //                (opcode_o == OPCODE_I && i == 3 && imm_diff_val == 0)  ? "SLTIU" :
   //                (opcode_o == OPCODE_I && i == 4 && imm_diff_val == 0)  ? "XORI" :
   //                (opcode_o == OPCODE_I && i == 5 && imm_diff_val == 0)  ? "SRLI" :
   //                (opcode_o == OPCODE_I && i == 5 && imm_diff_val == 32) ? "SRAI" :
   //                (opcode_o == OPCODE_I && i == 6 && imm_diff_val == 0)  ? "ORI" :
   //                (opcode_o == OPCODE_I && i == 7 && imm_diff_val == 0)  ? "ANDI" :
   //                (opcode_o == OPCODE_LOAD && i == 0)  ? "LB" :
   //                (opcode_o == OPCODE_LOAD && i == 1)  ? "LH" :
   //                (opcode_o == OPCODE_LOAD && i == 2)  ? "LW" :
   //                (opcode_o == OPCODE_LOAD && i == 4)  ? "LBU" :
   //                (opcode_o == OPCODE_LOAD && i == 5)  ? "LHU" :
   //                "Invalid I-TYPE Instruction";
   option.name = $sformatf("OPCODE:%0s Func3:%0d, imm[31:25]:%0d", opcode_o.name(), i, imm_diff_val);
   option.per_instance = 1;
   funct3: coverpoint cov.instr_rdata_i[14:12] iff ((cov.instr_rdata_i[6:0] == opcode_o && cov.instr_rdata_i[31:25] == imm_diff_val) 
                                                      || (cov.instr_rdata_i[6:0] == OPCODE_LOAD) ) {
      bins instr[] = {i};
   }
   rs1: coverpoint cov.instr_rdata_i[19:15] iff(((cov.instr_rdata_i[6:0] == opcode_o && cov.instr_rdata_i[31:25] == imm_diff_val) ||
                                                (cov.instr_rdata_i[6:0] == OPCODE_LOAD)) && cov.instr_rdata_i[14:12] == i) {
      bins rs1[]  = {[31:0]};
   }
   rd: coverpoint cov.instr_rdata_i[11:7] iff(((cov.instr_rdata_i[6:0] == opcode_o && cov.instr_rdata_i[31:25] == imm_diff_val) ||
                                                (cov.instr_rdata_i[6:0] == OPCODE_LOAD)) && cov.instr_rdata_i[14:12] == i) {
      bins rd[] = {[31:1]};
      ignore_bins rd_illegal = {0};
   }
   imm: coverpoint cov.instr_rdata_i[31:20] iff(((cov.instr_rdata_i[6:0] == opcode_o && (((i == 0 || i == 5) && cov.instr_rdata_i[31:25] == imm_diff_val) || (i inside {[1:4]} || i inside{[6:7]}) )) ||
                                                (cov.instr_rdata_i[6:0] == OPCODE_LOAD)) && cov.instr_rdata_i[14:12] == i) {
      bins imm_max   = {2047};
      bins imm_min   = {-2048};
      bins zeros     = {0};
      bins imm       = {[-2047:2046]};
   }
endgroup : I_type_covgrp

//this can be made by handing the I_type covgrp the JALR opcode value as well as an input enum but im choosing to keep it seperate for clarity
covergroup JALR_covgrp (input int i, input cv32e40p_id_sequence_item cov, ref logic signed [31:0] rf [32]);
   option.name =  "JALR";
   option.per_instance = 1;
   funct3: coverpoint cov.instr_rdata_i[14:12] iff (cov.instr_rdata_i[6:0] == OPCODE_JALR) {
      bins instr[] = {i};
   }
   rs1: coverpoint cov.instr_rdata_i[19:15] iff(cov.instr_rdata_i[6:0] == OPCODE_JALR && cov.instr_rdata_i[14:12] == i) {
      bins rs1  = {[31:0]};
   }
   rd: coverpoint cov.instr_rdata_i[11:7] iff(cov.instr_rdata_i[6:0] == OPCODE_JALR && cov.instr_rdata_i[14:12] == i) {
      bins rd = {[31:1]};
      ignore_bins rd_illegal = {0};
   }
   imm: coverpoint cov.instr_rdata_i[31:20] iff(cov.instr_rdata_i[6:0] == OPCODE_JALR && cov.instr_rdata_i[14:12] == i) {
      bins imm_max   = {2047};
      bins imm_min   = {-2048};
      bins zeros     = {0};
      bins imm       = {[-2047:2046]};
   }
endgroup : JALR_covgrp

covergroup R_type_covgrp (input int i, input int func7_val, input opcode_e opcode_o, input cv32e40p_id_sequence_item cov, ref logic signed [31:0] rf [32]);
   // option.name =  (opcode_o == OPCODE_R && func7_val == 0 && i == 0)  ? "ADD" :
   //                (opcode_o == OPCODE_R && func7_val == 32 && i == 0) ? "SUB" :
   //                (opcode_o == OPCODE_R && func7_val == 0 && i == 1)  ? "SLL" :
   //                (opcode_o == OPCODE_R && func7_val == 0 && i == 2)  ? "SLT" :
   //                (opcode_o == OPCODE_R && func7_val == 0 && i == 3)  ? "SLTU" :
   //                (opcode_o == OPCODE_R && func7_val == 0 && i == 4)  ? "XOR" :
   //                (opcode_o == OPCODE_R && func7_val == 0 && i == 5)  ? "SRL" :
   //                (opcode_o == OPCODE_R && func7_val == 32 && i == 5) ? "SRA" :
   //                (opcode_o == OPCODE_R && func7_val == 0 && i == 6)  ? "OR" :
   //                (opcode_o == OPCODE_R && func7_val == 0 && i == 7)  ? "AND" :

   //                (opcode_o == OPCODE_R && func7_val == 1 && i == 0)  ? "MUL" :
   //                (opcode_o == OPCODE_R && func7_val == 1 && i == 1)  ? "MULH" :
   //                (opcode_o == OPCODE_R && func7_val == 1 && i == 2)  ? "MULHSU" :
   //                (opcode_o == OPCODE_R && func7_val == 1 && i == 3)  ? "MULHU" :
   //                (opcode_o == OPCODE_R && func7_val == 1 && i == 4)  ? "DIV" :
   //                (opcode_o == OPCODE_R && func7_val == 1 && i == 5)  ? "DIVU" :
   //                (opcode_o == OPCODE_R && func7_val == 1 && i == 6)  ? "REM" :
   //                (opcode_o == OPCODE_R && func7_val == 1 && i == 7)  ? "REMU" :
   //                "INVALID R-TYPE INSTRUCTION";\
   option.name = $sformatf("Func3:%0d, Func7:%0d", i, func7_val);
   option.per_instance = 1;
   funct3: coverpoint cov.instr_rdata_i[14:12] iff (cov.instr_rdata_i[6:0] == opcode_o && cov.instr_rdata_i[31:25] == func7_val) {
      bins instr[] = {i};
   }
   rs1: coverpoint cov.instr_rdata_i[19:15] iff(cov.instr_rdata_i[6:0] == opcode_o && cov.instr_rdata_i[31:25] == func7_val
                                                && cov.instr_rdata_i[14:12] == i) {
      bins rs1[]  = {[31:0]};
   }
   rs2: coverpoint cov.instr_rdata_i[24:20] iff(cov.instr_rdata_i[6:0] == opcode_o && cov.instr_rdata_i[31:25] == func7_val
                                                && cov.instr_rdata_i[14:12] == i) {
      bins rs2[]  = {[31:0]};
   }
   rd: coverpoint cov.instr_rdata_i[11:7] iff(cov.instr_rdata_i[6:0] == opcode_o && cov.instr_rdata_i[31:25] == func7_val
                                                && cov.instr_rdata_i[14:12] == i) {
      bins rd[] = {[31:1]};
      ignore_bins rd_illegal = {0};
   }
endgroup : R_type_covgrp

covergroup S_type_covgrp (input int i, input cv32e40p_id_sequence_item cov, ref logic signed [31:0] rf [32]);
   // option.name =  (i == 0) ? "SB" : 
   //                (i == 1) ? "SH" :
   //                (i == 2) ? "SW" :
   //                "INVALID S-TYPE Instruction";
   option.name = $sformatf("Func3:%0d", i);
   option.per_instance = 1;
   funct3: coverpoint cov.instr_rdata_i[14:12] iff (cov.instr_rdata_i[6:0] == OPCODE_S) {
      bins instr[] = {i};
   }
   rs1: coverpoint cov.instr_rdata_i[19:15] iff(cov.instr_rdata_i[6:0] == OPCODE_S) {
      bins rs1[]  = {[31:0]};
   }
   rs2: coverpoint cov.instr_rdata_i[24:20] iff(cov.instr_rdata_i[6:0] == OPCODE_S) {
      bins rs2[]  = {[31:0]};
   }
   imm: coverpoint {cov.instr_rdata_i[11:5],cov.instr_rdata_i[4:0]} iff(cov.instr_rdata_i[6:0] == OPCODE_S && cov.instr_rdata_i[14:12] == i) {
      bins imm_max   = {4092};
      bins imm_min   = {0};
      bins zeros     = {0};
      bins imm       = {[4091:1]} with ((item % 2**i) == 0);
   }
   // rs1_add_imm: coverpoint ({cov.instr_rdata_i[11:5], cov.instr_rdata_i[4:0]} + rf[cov.instr_rdata_i[19:15]]) iff(cov.instr_rdata_i[6:0] == OPCODE_S && cov.instr_rdata_i[14:12] == i) {
   //    bins imm_max   = {4092};
   //    bins imm_min   = {0};
   //    bins zeros     = {0};
   //    bins imm       = {[4091:1]} with ((item % 2**i) == 0);
   // }    
endgroup : S_type_covgrp

covergroup B_type_covgrp (input int i, input cv32e40p_id_sequence_item cov, ref logic signed [31:0] rf [32]);
   // option.name =  (i == 0) ? "BEQ" : 
   //                (i == 1) ? "BNE" :
   //                (i == 4) ? "BLT" :
   //                (i == 5) ? "BGE" :
   //                (i == 6) ? "BLTU" :
   //                (i == 7) ? "BGEU" :
   //                "INVALID_B_TYPE";
   option.name = $sformatf("Func3:%0d", i);
   option.per_instance = 1;
   funct3: coverpoint cov.instr_rdata_i[14:12] iff (cov.instr_rdata_i[6:0] == OPCODE_B) {
      bins instr[] = {i};
   }
   rs1: coverpoint cov.instr_rdata_i[19:15] iff(cov.instr_rdata_i[6:0] == OPCODE_B) {
      bins rs1[]  = {[31:0]};
   }
   rs2: coverpoint cov.instr_rdata_i[24:20] iff(cov.instr_rdata_i[6:0] == OPCODE_B) {
      bins rs2[]  = {[31:0]};
   }
   imm: coverpoint {cov.instr_rdata_i[12], cov.instr_rdata_i[10:5], cov.instr_rdata_i[4:1], cov.instr_rdata_i[11]} 
                              iff(cov.instr_rdata_i[6:0] == OPCODE_B && cov.instr_rdata_i[14:12] == i) {
      bins imm_max   = {4092};
      bins imm_min   = {0};
      bins zeros     = {0};
      bins imm       = {[4091:1]} with (item % 4 == 0);
   }   
endgroup : B_type_covgrp

covergroup U_type_covgrp (input int i, input opcode_e U_OPCODE, input cv32e40p_id_sequence_item cov, ref logic signed [31:0] rf [32]);
   // option.name =  (U_OPCODE == OPCODE_LUI)   ? "LUI" : 
   //                (U_OPCODE == OPCODE_AUIPC) ? "AUIPC" :
   //                "INVALID U-TYPE Instruction";
   option.name = $sformatf("Opcode:%0b", U_OPCODE);
   option.per_instance = 1;
   rd: coverpoint cov.instr_rdata_i[11:7] iff(cov.instr_rdata_i[6:0] == U_OPCODE) {
      bins rd[]               = {[31:1]};
      ignore_bins rd_illegal = {0};
   }
   imm: coverpoint {cov.instr_rdata_i[31:12]} iff(cov.instr_rdata_i[6:0] == U_OPCODE) {
      bins imm_max   = {524_287};
      bins imm_min   = {-524_288};
      bins zeros     = {0};
      bins imm       = {[-524_287:524_286]};
   }
endgroup : U_type_covgrp

covergroup J_type_covgrp (input int i, input cv32e40p_id_sequence_item cov, ref logic signed [31:0] rf [32]);
   option.name = "JAL";
   option.per_instance = 1;
   rd: coverpoint cov.instr_rdata_i[11:7] iff(cov.instr_rdata_i[6:0] == OPCODE_JAL) {
      bins rd[]  = {[31:0]};
   }
   imm: coverpoint {cov.instr_rdata_i[20], cov.instr_rdata_i[10:1], cov.instr_rdata_i[11], cov.instr_rdata_i[19:12]} 
                              iff(cov.instr_rdata_i[6:0] == OPCODE_JAL) {
      bins imm_max   = {1_048_572};
      bins imm_min   = {0};
      bins zeros     = {0};
      bins imm       = {[1_048_571:1]} with (item % 4 == 0);
   }   
endgroup : J_type_covgrp

/***********************************************************************
/ subscriber - inestantiates predictor and comparator and connects them, 
/ also keeps track of the incorrect and correct comparisons of items
/**********************************************************************/ 
class subscriber extends uvm_component;

   /********************************
   / Declare TLM component for reset
   *********************************/
   uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_n_ap;
   uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_p_ap;

   /**************************************
   / Declare TLM Analaysis FIFOs for reset
   ***************************************/
   uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_n_fifo;
   uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_p_fifo;

   //TLM Connections for all agents' Input Monitors
   uvm_analysis_export#(cv32e40p_if_sequence_item) if_stage_ap_in;
   uvm_analysis_export#(cv32e40p_id_sequence_item) id_stage_ap_in;
   uvm_analysis_export#(cv32e40p_ie_sequence_item) ie_stage_ap_in;
   uvm_analysis_export#(cv32e40p_data_memory_sequence_item) data_memory_ap_in;
   uvm_analysis_export#(cv32e40p_interrupt_sequence_item) isr_if_ap_in;
   uvm_analysis_export#(cv32e40p_debug_sequence_item) dbg_if_ap_in;

   //TLM Connections for all agents' Output Monitors
   uvm_analysis_export#(cv32e40p_if_sequence_item) if_stage_ap_out;
   uvm_analysis_export#(cv32e40p_id_sequence_item) id_stage_ap_out;
   uvm_analysis_export#(cv32e40p_ie_sequence_item) ie_stage_ap_out;
   uvm_analysis_export#(cv32e40p_data_memory_sequence_item) data_memory_ap_out;
   uvm_analysis_export#(cv32e40p_interrupt_sequence_item) isr_if_ap_out;
   uvm_analysis_export#(cv32e40p_debug_sequence_item) dbg_if_ap_out;

   //TLM FIFOs for all agents' Input Monitors
   uvm_tlm_analysis_fifo#(cv32e40p_if_sequence_item) if_stage_fifo_in;
   uvm_tlm_analysis_fifo#(cv32e40p_id_sequence_item) id_stage_fifo_in;
   uvm_tlm_analysis_fifo#(cv32e40p_ie_sequence_item) ie_stage_fifo_in;
   uvm_tlm_analysis_fifo#(cv32e40p_data_memory_sequence_item) data_memory_fifo_in;
   uvm_tlm_analysis_fifo#(cv32e40p_interrupt_sequence_item) isr_if_fifo_in;
   uvm_tlm_analysis_fifo#(cv32e40p_debug_sequence_item) dbg_if_fifo_in;

   //TLM FIFOs for all agents' Output Monitors
   uvm_tlm_analysis_fifo#(cv32e40p_if_sequence_item) if_stage_fifo_out;
   uvm_tlm_analysis_fifo#(cv32e40p_id_sequence_item) id_stage_fifo_out;
   uvm_tlm_analysis_fifo#(cv32e40p_ie_sequence_item) ie_stage_fifo_out;
   uvm_tlm_analysis_fifo#(cv32e40p_data_memory_sequence_item) data_memory_fifo_out;
   uvm_tlm_analysis_fifo#(cv32e40p_interrupt_sequence_item) isr_if_fifo_out;
   uvm_tlm_analysis_fifo#(cv32e40p_debug_sequence_item) dbg_if_fifo_out;

   // Input Sequence Items
   cv32e40p_if_sequence_item if_s_req_i;
   cv32e40p_id_sequence_item id_s_req_i;
   cv32e40p_ie_sequence_item ie_s_req_i;
   cv32e40p_data_memory_sequence_item data_memory_req_i;
   cv32e40p_debug_sequence_item dbg_if_req_i;
   cv32e40p_interrupt_sequence_item isr_if_req_i;

   // Output Sequence Items
   cv32e40p_id_sequence_item id_s_req_o;
   cv32e40p_ie_sequence_item ie_s_req_o;
   cv32e40p_data_memory_sequence_item data_memory_req_o;
   cv32e40p_debug_sequence_item dbg_if_req_o;
   cv32e40p_interrupt_sequence_item isr_if_req_o;

   // Needed Sequence Items & Covergroup Instances
   cv32e40p_id_sequence_item input_cov_copied;
   
   // RegFile Config, to hand to the covgroup instances
   cv32e40p_Regfile_config regfile_cfg;

   // Test Name to parametarize the Subscriber
   local string test_name;

   // Sampled Transaction Counter
   int trans_count;

   //=========================================================== "I" Extension Covergrps Instances =======================================//
   //I Type covergrp instances
   I_type_covgrp I_type_f7_0_inst[7:0];
   I_type_covgrp I_type_f7_32_inst;
   I_type_covgrp I_type_load_inst[4:0];
   JALR_covgrp   I_type_jalr_inst;  

   //R Type covergrp instances
   R_type_covgrp R_type_f7_0_inst[7:0];
   R_type_covgrp R_type_f7_32_inst[1:0];

   //S Type covergrp instances
   S_type_covgrp S_type_inst[2:0];
   
   //B Type covergrp instances
   B_type_covgrp B_type_inst[5:0];

   //U Type covergrp instances
   U_type_covgrp U_type_inst[1:0];

   //J Type covergrp instances
   J_type_covgrp J_type_inst;

   //=========================================================== "M" Extension Covergrps Instances =======================================//
   R_type_covgrp R_type_f7_1_inst[7:0];
   
   // Register with factory
   `uvm_component_utils(subscriber)
	
   
     // Extract common fields
	logic [6:0] opcode;
	logic [4:0] rd_addr, rs1_addr, rs2_addr;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [31:0] imm,rd,rs1,rs2;
	logic [4:0] shamt;
	
   logic signed [31:0] imm_I, imm_S, imm_B, imm_U, imm_J;
   logic [31:0] instr;
   logic is_addi, is_slti, is_sltiu, is_xori, is_ori, is_andi,is_jalr;
   logic is_slli, is_srli, is_srai;
   logic is_sb,is_sh,is_sw;
   logic is_mul,is_mulh,is_mulhsu,is_mulhu;

cv32e40p_pkg:: alu_opcode_e        alu_operator_ex;
	logic        [31:0] alu_operand_a_ex; 
	logic        [31:0] alu_operand_b_ex;
	logic        [31:0] alu_operand_c_ex;
	logic               alu_en_ex;
	
	cv32e40p_pkg::mul_opcode_e        mult_operator_ex;
	logic        [31:0] mult_operand_a_ex;
	logic        [31:0] mult_operand_b_ex;
	logic        [31:0] mult_operand_c_ex;
	logic               mult_en_ex;
	

	//Ex cov groups
	covergroup cg_mul_covgroup ;
	
	// Operand A
	coverpoint mult_operand_a_ex iff (mult_en_ex ) {
		bins all_ones = {32'hFFFFFFFF};
		
	}
	
	// Operand B
	coverpoint mult_operand_b_ex iff(mult_en_ex ) {
		bins all_ones = {32'hFFFFFFFF};
		
	}
	
	// Cross: All ones × All ones
	cross mult_operand_a_ex, mult_operand_b_ex iff (mult_en_ex ) {
		bins all_ones_x_all_ones = binsof(mult_operand_a_ex.all_ones) && binsof(mult_operand_b_ex.all_ones) ;
	}

	endgroup:cg_mul_covgroup
	covergroup cg_div_covgroup ;
	
	// Dividend
	coverpoint alu_operand_b_ex iff (alu_en_ex && alu_operator_ex== ALU_DIV) {
		bins signed_min = {32'h80000000}; // -2^31
		
	}
	
	// Divisor
	coverpoint alu_operand_a_ex iff (alu_en_ex && alu_operator_ex== ALU_DIV) {
		bins zero    = {32'd0};
		bins neg_one = {32'hFFFFFFFF}; // -1
		
	}
	
	// Cross: Signed overflow case
	cross alu_operand_a_ex, alu_operand_b_ex iff(alu_en_ex && alu_operator_ex== ALU_DIV) {
		bins by_Zero = binsof(alu_operand_b_ex) && binsof(alu_operand_a_ex.zero); // b/0
		bins signed_of = binsof(alu_operand_b_ex.signed_min) && binsof(alu_operand_a_ex.neg_one); //-2^31/-1
		
	}
	endgroup :cg_div_covgroup
	covergroup cg_divU_covgroup ;
		
		// Dividend
		coverpoint alu_operand_b_ex iff (alu_en_ex && alu_operator_ex== ALU_DIVU) {
			bins signed_min = {32'h80000000}; // -2^31
		
		}
		
		// Divisor
		coverpoint alu_operand_a_ex iff (alu_en_ex && alu_operator_ex== ALU_DIVU) {
			bins zero    = {32'd0};
			bins neg_one = {32'hFFFFFFFF}; // -1
			
		}
		
		// Cross: Signed overflow case
		cross alu_operand_a_ex, alu_operand_b_ex iff(alu_en_ex && alu_operator_ex== ALU_DIVU) {
			bins by_Zero = binsof(alu_operand_b_ex) && binsof(alu_operand_a_ex.zero); // b/0
			bins signed_of = binsof(alu_operand_b_ex.signed_min) && binsof(alu_operand_a_ex.neg_one); //-2^31/-1
			
		}
		endgroup: cg_divU_covgroup
	covergroup cg_rem_covgroup ;
	
	// Dividend
	coverpoint alu_operand_b_ex iff (alu_en_ex && alu_operator_ex== ALU_REM) {
		bins signed_min = {32'h80000000}; // optional to match div
		
	}
	
	// Divisor
	coverpoint alu_operand_a_ex iff (alu_en_ex && alu_operator_ex== ALU_REM ) {
		bins zero    = {32'd0};
		bins neg_one = {32'hFFFFFFFF};
		
	}
	
	// Cross: Same overflow case for REM (result is 0 per spec)
	cross alu_operand_a_ex, alu_operand_b_ex iff (alu_en_ex && alu_operator_ex== ALU_REM) {
		bins by_Zero = binsof(alu_operand_b_ex) &&	binsof(alu_operand_a_ex.zero) ;
		bins signed_of = binsof(alu_operand_b_ex.signed_min) &&	binsof(alu_operand_a_ex.neg_one) ;
	}
	
	endgroup:cg_rem_covgroup
	covergroup cg_remU_covgroup ;
	
	// Dividend
	coverpoint alu_operand_b_ex iff (alu_en_ex && alu_operator_ex== ALU_REMU) {
		bins signed_min = {32'h80000000}; // optional to match div
		
	}
	
	// Divisor
	coverpoint alu_operand_a_ex iff (alu_en_ex && alu_operator_ex== ALU_REMU ) {
		bins zero    = {32'd0};
		bins neg_one = {32'hFFFFFFFF};
		
	}
	
	// Cross: Same overflow case for REM (result is 0 per spec)
	cross alu_operand_a_ex, alu_operand_b_ex iff (alu_en_ex && alu_operator_ex== ALU_REMU) {
		bins by_Zero = binsof(alu_operand_b_ex) &&	binsof(alu_operand_a_ex.zero) ;
		bins signed_of = binsof(alu_operand_b_ex.signed_min) &&	binsof(alu_operand_a_ex.neg_one) ;
	}
	
	endgroup:cg_remU_covgroup
	covergroup cg_shift_covgroup ;
 

  // Operand A = Value to shift
  //A >> or << b[4:0]
	cp_A:coverpoint alu_operand_a_ex iff (alu_en_ex && (alu_operator_ex inside {
		ALU_SRA, ALU_SRL, ALU_SLL, ALU_ROR })) {
		bins all_values = {[-2147483648 : 2147483647]};  // full 32-bit signed range
	}
	
	// Operand B = Shift amount (only lower 5 bits are used in RV32)
	cp_shamt: coverpoint alu_operand_b_ex[4:0] iff (alu_en_ex && (alu_operator_ex inside {
		ALU_SRA, ALU_SRL, ALU_SLL, ALU_ROR })) {
		bins shift_0  = {5'd0};
		bins shift_31 = {5'd31};
		//bins others   = default;
	}
	
	// Cross operand and shift amount
	cross cp_A, cp_shamt iff (alu_en_ex &&
		(alu_operator_ex inside {ALU_SRA, ALU_SRL, ALU_SLL, ALU_ROR})) {
		bins shift_zero = binsof(cp_A.all_values) && binsof(cp_shamt.shift_0) ;
								
		bins shift_max = binsof(cp_A.all_values) && binsof(cp_shamt.shift_31) ;
	}
	
	endgroup:cg_shift_covgroup



covergroup I_Type_ADDI;
	rd_cov:coverpoint rd_addr iff (is_addi) {
		bins zero = {0};                // rd is x0 (result discarded)
		bins nonzero[3] = {[1:31]};        // valid rd destination
   }
	rs1_cov:coverpoint rs1_addr iff (is_addi) {
		bins zero = {0};                // rs1 is x0
		bins nonzero[3] = {[1:31]};
   }
   imm_I_cov:coverpoint imm_I iff (is_addi) {
		bins zero     = {0};                 // mv
		bins pos[10]      = {[1:2046]};
		bins neg[10]      = {[-2047:-1]};
		bins min_imm  = {-2048};
		bins max_imm  = {2047};
   }
   // Useful cross for observing when rd == rs1
  rd_rs1_cross: cross rd_cov,rs1_cov  iff (is_addi) {
		option.cross_auto_bin_max = 0;
		bins same_0   		= binsof(rd_cov.zero) && binsof(rs1_cov.zero); // rd == rs1
		bins same_others    = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr); // rd == rs1 
		bins diff_x0 		= binsof(rd_cov.zero) && binsof(rs1_cov.nonzero); // rd == rs1
   }
   
   
  
endgroup:I_Type_ADDI

covergroup I_Type_SLTI;
	rd_cov:coverpoint rd_addr iff (is_slti) {
		bins zero = {0};                // rd is x0 (result discarded)
		bins nonzero[3] = {[1:31]};        // valid rd destination
   }
	rs1_cov:coverpoint rs1_addr iff (is_slti) {
		bins zero = {0};                // rs1 is x0
		bins nonzero[3] = {[1:31]};
   }
/*
	rs1_val_cov: coverpoint rs1_val iff (is_slti) {
		bins zero = {0};     
		bins nonzero = default;
	
	
	}*/
   imm_I_cov:coverpoint imm_I iff (is_slti) {
		bins zero     = {0};                 // mv
		bins pos      = {[1:2046]};
		bins neg      = {[-2047:-1]};
		bins min_imm  = {-2048};
		bins max_imm  = {2047};
   }
   // Useful cross for observing when rd == rs1
   rd_rs1_cross: cross rd_cov,rs1_cov  iff (is_slti) {
		option.cross_auto_bin_max = 0;
		bins same_0   		= binsof(rd_cov.zero) && binsof(rs1_cov.zero); // rd == rs1
		bins same_others    = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr); // rd == rs1 
		bins diff_x0 		= binsof(rd_cov.zero) && binsof(rs1_cov.nonzero); // rd == rs1
   }
   /*imm_rs1_val_cross: cross imm_I_cov,rs1_val_cov  iff (is_slti) {
		bins same     = binsof(imm_I_cov) intersect binsof(rs1_val_cov); // imm == rs1=0 & -ve values 
   }*/
   

endgroup:I_Type_SLTI

covergroup I_Type_SLTIU;
	rd_cov:coverpoint rd_addr iff (is_sltiu) {
		bins zero = {0};                // rd is x0 (result discarded)
		bins nonzero[3] = {[1:31]};        // valid rd destination
   }
	rs1_cov:coverpoint rs1_addr iff (is_sltiu) {
		bins zero = {0};                // rs1 is x0
		bins nonzero[3] = {[1:31]};
   }
	/*rs1_val_cov: coverpoint rs1_val iff (is_sltiu) {
		bins zero = {0};     
		bins nonzero = default;
	
	
	}*/
   imm_I_cov:coverpoint imm_I iff (is_sltiu) {
		bins zero     = {0};                 // mv
		bins pos      = {[1:2046]};
		bins neg      = {[-2047:-1]};
		bins min_imm  = {-2048};
		bins max_imm  = {2047};
   }
   // Useful cross for observing when rd == rs1
   rd_rs1_cross: cross rd_cov,rs1_cov  iff (is_sltiu) {
		option.cross_auto_bin_max = 0;
		
		bins same_others    = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr); // rd == rs1 
		bins diff_x0 		= binsof(rd_cov.zero) && binsof(rs1_cov.nonzero); // rd == rs1
   }
   /*imm_rs1_val_cross: cross imm_I_cov,rs1_val_cov  iff (is_sltiu) {
		bins same     = binsof(imm_I_cov) intersect binsof(rs1_val_cov); // imm == rs1=0 
   }*/
   

endgroup:I_Type_SLTIU

covergroup I_Type_ANDI;
	rd_cov:coverpoint rd_addr iff (is_andi) {
		bins zero = {0};                // rd is x0 (result discarded)
		bins nonzero[3] = {[1:31]};        // valid rd destination
   }
	rs1_cov:coverpoint rs1_addr iff (is_andi) {
		bins zero = {0};                // rs1 is x0
		bins nonzero[3] = {[1:31]};
   }
	/*rs1_val_cov: coverpoint rs1_val iff (is_andi) {
		bins zero = {0};     
		bins nonzero = default;
	
	
	}*/
   imm_I_cov:coverpoint imm_I iff (is_andi) {
		bins zero     = {0};                 // mv
		bins pos      = {[1:2046]};
		bins neg      = {[-2047:-1]};
		bins min_imm  = {-2048};
		bins max_imm  = {2047};
   }
   // Useful cross for observing when rd == rs1
   rd_rs1_cross: cross rd_cov,rs1_cov  iff (is_andi) {
		option.cross_auto_bin_max = 0;
		
		bins same_others    = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr); // rd == rs1 
		bins diff_x0 		= binsof(rd_cov.zero) && binsof(rs1_cov.nonzero); // rd == rs1
   }
   /*imm_rs1_val_cross: cross imm_I_cov,rs1_val_cov  iff (is_andi) {
		bins same     = binsof(imm_I_cov) intersect binsof(rs1_val_cov); // imm == rs1=0 
   }*/
   

endgroup:I_Type_ANDI

covergroup I_Type_ORI;
	rd_cov:coverpoint rd_addr iff (is_ori) {
		bins zero = {0};                // rd is x0 (result discarded)
		bins nonzero[3] = {[1:31]};        // valid rd destination
   }
	rs1_cov:coverpoint rs1_addr iff (is_ori) {
		bins zero = {0};                // rs1 is x0
		bins nonzero[3] = {[1:31]};
   }
	/*rs1_val_cov: coverpoint rs1_val iff (is_ori) {
		bins zero = {0};     
		bins nonzero = default;
	
	
	}*/
   imm_I_cov:coverpoint imm_I iff (is_ori) {
		bins zero     = {0};                 // mv
		bins pos      = {[1:2046]};
		bins neg      = {[-2047:-1]};
		bins min_imm  = {-2048};
		bins max_imm  = {2047};
   }
   // Useful cross for observing when rd == rs1
   rd_rs1_cross: cross rd_cov,rs1_cov  iff (is_ori) {
		option.cross_auto_bin_max = 0;
		
		bins same_others    = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr); // rd == rs1 
		bins diff_x0 		= binsof(rd_cov.zero) && binsof(rs1_cov.nonzero); // rd == rs1
   }
   /*imm_rs1_val_cross: cross imm_I_cov,rs1_val_cov  iff (is_ori) {
		bins same     = binsof(imm_I_cov) intersect binsof(rs1_val_cov); // imm == rs1=0 
   }*/
   

endgroup:I_Type_ORI

covergroup I_Type_XORI;
	rd_cov:coverpoint rd_addr iff (is_xori) {
		bins zero = {0};                // rd is x0 (result discarded)
		bins nonzero[3] = {[1:31]};        // valid rd destination
   }
	rs1_cov:coverpoint rs1_addr iff (is_xori) {
		bins zero = {0};                // rs1 is x0
		bins nonzero[3] = {[1:31]};
   }
	/*rs1_val_cov: coverpoint rs1_val iff (is_xori) {
		bins zero = {0};     
		bins nonzero = default;
	
	
	}*/
   imm_I_cov:coverpoint imm_I iff (is_xori) {
		bins zero     = {0};                 // mv
		bins pos      = {[1:2046]};
		bins neg      = {[-2047:-1]};
		bins min_imm  = {-2048};
		bins max_imm  = {2047};
   }
   // Useful cross for observing when rd == rs1
   rd_rs1_cross: cross rd_cov,rs1_cov  iff (is_xori) {
		option.cross_auto_bin_max = 0;
		bins same_0   		= binsof(rd_cov.zero) && binsof(rs1_cov.zero); // rd == rs1
		bins same_others    = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr); // rd == rs1 
		bins diff_x0 		= binsof(rd_cov.zero) && binsof(rs1_cov.nonzero); // rd == rs1
   }
   /*imm_rs1_val_cross: cross imm_I_cov,rs1_val_cov  iff (is_xori) {
		bins same     = binsof(imm_I_cov) intersect binsof(rs1_val_cov); // imm == rs1=0 
   }*/
   

endgroup:I_Type_XORI

covergroup I_Type_SLLI;
   
   rd_cov:coverpoint rd_addr iff (is_slli) {
		bins zero = {0};                // rd is x0 (result discarded)
		bins nonzero[3] = {[1:31]};        // valid rd destination
   }
	rs1_cov:coverpoint rs1_addr iff (is_slli) {
		bins zero = {0};                // rs1 is x0
		bins nonzero[3] = {[1:31]};
   }

   /*rs1_val_cov: coverpoint rs1_val iff (is_slli) {
      bins zero    = {0};
      bins nonzero = default;            // automatically bins all other values
   }*/

   shamt_cov: coverpoint shamt iff (is_slli) {
      bins low     = {[0:3]};            // small shift
      bins mid     = {[4:15]};           // medium shift
      bins high    = {[16:31]};          // high shift (edge testing)
      bins zero    = {0};                // no shift at all
      bins max     = {31};               // max shift
   }

   rd_rs1_cross: cross rd_cov,rs1_cov  iff (is_slli) {
		option.cross_auto_bin_max = 0;
		bins same_0   		= binsof(rd_cov.zero) && binsof(rs1_cov.zero); // rd == rs1
		bins same_others    = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr); // rd == rs1 
		bins diff_x0 		= binsof(rd_cov.zero) && binsof(rs1_cov.nonzero); // rd == rs1
   }

endgroup: I_Type_SLLI

covergroup I_Type_SRLI;

   rd_cov:coverpoint rd_addr iff (is_srli) {
		bins zero = {0};                // rd is x0 (result discarded)
		bins nonzero[3] = {[1:31]};        // valid rd destination
   }
	rs1_cov:coverpoint rs1_addr iff (is_srli) {
		bins zero = {0};                // rs1 is x0
		bins nonzero[3] = {[1:31]};
   }

   /*rs1_val_cov: coverpoint rs1_val iff (is_srli) {
      bins zero    = {0};
      bins nonzero = default;
   }*/

   shamt_cov: coverpoint shamt iff (is_srli) {
      bins zero = {0};
      bins low  = {[1:3]};
      bins mid  = {[4:15]};
      bins high = {[16:30]};
      bins max  = {31};
   }

   rd_rs1_cross: cross rd_cov,rs1_cov  iff (is_srli) {
		option.cross_auto_bin_max = 0;
		bins same_0   		= binsof(rd_cov.zero) && binsof(rs1_cov.zero); // rd == rs1
		bins same_others    = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr); // rd == rs1 
		bins diff_x0 		= binsof(rd_cov.zero) && binsof(rs1_cov.nonzero); // rd == rs1
   }

endgroup: I_Type_SRLI

covergroup I_Type_SRAI;

   rd_cov:coverpoint rd_addr iff (is_srai) {
		bins zero = {0};                // rd is x0 (result discarded)
		bins nonzero[3] = {[1:31]};        // valid rd destination
   }
	rs1_cov:coverpoint rs1_addr iff (is_srai) {
		bins zero = {0};                // rs1 is x0
		bins nonzero[3] = {[1:31]};
   }
   /*rs1_val_cov: coverpoint rs1_val iff (is_srai) {
      bins zero    = {0};
      bins pos     = {[1:$]};
      bins neg     = {[-(2**31): -1]};
   }
*/
   shamt_cov: coverpoint shamt iff (is_srai) {
      bins zero = {0};
      bins low  = {[1:3]};
      bins mid  = {[4:15]};
      bins high = {[16:30]};
      bins max  = {31};
   }

   rd_rs1_cross: cross rd_cov,rs1_cov  iff (is_srai) {
		option.cross_auto_bin_max = 0;
		bins same_0   		= binsof(rd_cov.zero) && binsof(rs1_cov.zero); // rd == rs1
		bins same_others    = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr); // rd == rs1 
		bins diff_x0 		= binsof(rd_cov.zero) && binsof(rs1_cov.nonzero); // rd == rs1
   }

endgroup: I_Type_SRAI

covergroup I_Type_JALR;

   // Destination register (rd)
   rd_cov: coverpoint rd_addr iff (is_jalr) {
      //bins zero = {0};                // rd is x0 (return address discarded)
      bins nonzero = {[1:31]};     // valid rd destination
   }

   // Source register (rs1)
   rs1_cov: coverpoint rs1_addr iff (is_jalr) {
      //bins zero = {0};                // base address is x0
      bins nonzero = {[1:31]};
   }

   // Immediate value (offset, must be word-aligned)
   imm_I_cov: coverpoint imm_I iff (is_jalr) {
      //bins zero     = {0};
      bins pos      = {[1:2046]};
     // bins neg      = {[-2047:-1]};
      //bins min_imm  = {-2048};


      // Ignore values that are not 4-byte aligned
      bins not_aligned = {[-2048:2047]} iff (imm_I % 4 != 0);
   }

   // Cross to track rd and rs1 interaction
   rd_rs1_cross: cross rd_cov, rs1_cov iff (is_jalr) {
      option.cross_auto_bin_max = 0;

      //bins same_0        = binsof(rd_cov.zero) && binsof(rs1_cov.zero);           // rd == rs1 == 0
      //bins same_others   = binsof(rd_cov.nonzero) && binsof(rs1_cov.nonzero) iff (rd_addr == rs1_addr);                            // rd == rs1
      bins diff          = binsof(rd_cov) && binsof(rs1_cov) iff (rd_addr != rs1_addr); // rd != rs1
   }

endgroup : I_Type_JALR

covergroup S_Type_SB;

   rs1_cov: coverpoint rs1_addr iff (is_sb) {
      bins all[3] = {[0:31]};
   }
	
   rs2_cov: coverpoint rs2_addr iff (is_sb) {
		//bins zero = {0};                
		bins nonzero[3] = {[1:31]};
   }

   imm_cov: coverpoint imm_S iff (is_sb ) {
		//bins zero     = {0};
		bins pos      = {[1:2046]};
		bins neg      = {[-2047:-1]};
		//bins min_imm  = {-2048};	  
		bins not_word_aligned = {[-2048:2047]} iff (imm_S % 4 != 0);
  
}


   //cross rs1_cov, rs2_cov iff (is_sb);

endgroup: S_Type_SB

covergroup S_Type_SH;

   
   rs1_cov: coverpoint rs1_addr iff (is_sh) {
      bins all[3] = {[0:31]};
   }
	
   rs2_cov: coverpoint rs2_addr iff (is_sh) {
		//bins zero = {0};                
		bins nonzero[3] = {[1:31]};
   }

   imm_cov: coverpoint imm_S iff (is_sh) {
		//bins zero     = {0};
		bins pos      = {[1:2046]};
		bins neg      = {[-2047:-1]};
		//bins min_imm  = {-2048};
		bins not_word_aligned = {[-2048:2047]} iff (imm_S % 4 != 0);
  
}


   //cross rs1_cov, rs2_cov iff (is_sh);

endgroup: S_Type_SH

covergroup S_Type_SW;

   
   rs1_cov: coverpoint rs1_addr iff (is_sw) {
      bins all[3] = {[0:31]};
   }
	
   rs2_cov: coverpoint rs2_addr iff (is_sw) {
		//bins zero = {0};                
		bins nonzero[3] = {[1:31]};
   }

   imm_cov: coverpoint imm_S iff (is_sw) {
		//bins zero     = {0};
		bins pos      = {[1:2046]};
		bins neg      = {[-2047:-1]};
		//bins min_imm  = {-2048};
	  
		bins not_word_aligned = {[-2048:2047]} iff (imm_S % 4 != 0);
  
}


   //rs1_rs2_cross: cross rs1_cov, rs2_cov iff (is_sw);

endgroup: S_Type_SW

covergroup R_Type_MUL;

   rs1_cov: coverpoint rs1_addr iff (is_mul || is_mulh || is_mulhsu || is_mulhu) {
      bins x0     = {0};
      bins others[3] = {[1:31]};
   }

   rs2_cov: coverpoint rs2_addr iff (is_mul || is_mulh || is_mulhsu || is_mulhu) {
      bins x0     = {0};
      bins others[3] = {[1:31]};
   }

   rd_cov: coverpoint rd_addr iff (is_mul || is_mulh || is_mulhsu || is_mulhu) {
      bins x0     = {0};
      bins others[3] = {[1:31]};
   }

   mul_type: coverpoint funct3 iff (opcode == OPCODE_R && funct7 == 7'b0000001) {
      bins mul     = {3'b000};
      bins mulh    = {3'b001};
      bins mulhsu  = {3'b010};
      bins mulhu   = {3'b011};
   }

   cross_rs1_rd_same: cross rs1_cov, rd_cov iff (is_mul || is_mulh || is_mulhsu || is_mulhu) {
      bins same = binsof(rs1_cov.others) && binsof(rd_cov.others) iff (rs1_addr == rd_addr);
      bins diff = binsof(rs1_cov.others) && binsof(rd_cov.others) iff (rs1_addr != rd_addr);
     // bins x0_same = binsof(rs1_cov.x0) && binsof(rd_cov.x0); // both zero
   }

   cross_multype_rd: cross mul_type, rd_cov {
      bins mul_discarded = binsof(mul_type.mul) && binsof(rd_cov.x0);  // mul result discarded
   }

endgroup : R_Type_MUL


/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name, uvm_component parent);
   super.new(name, parent);

   if(!(uvm_config_db#(string)::get(this,"","test_name",test_name)))
      `uvm_fatal(get_type_name(), "Couldn't get TEST_NAME")

   input_cov_copied = new();

    //cov groups
   I_Type_ADDI   = new();
   I_Type_SLTI   = new();
   I_Type_SLTIU  = new();
   I_Type_ANDI   = new();
   I_Type_ORI    = new();
   I_Type_XORI   = new();
   I_Type_SLLI   = new();
   I_Type_SRLI   = new();
   I_Type_SRAI   = new();
   S_Type_SB     = new();
   S_Type_SH     = new();
   S_Type_SW     = new();
   R_Type_MUL    = new();
   I_Type_JALR = new();
   cg_mul_covgroup  = new();
	cg_div_covgroup  = new();
	cg_divU_covgroup  = new();
	cg_rem_covgroup  = new();
	cg_remU_covgroup  = new();
	cg_shift_covgroup  = new();

   // case(test_name)

   //    //=========================================================== "I" Extension Covergrps Instances =======================================//
   //    "I_type_std_test": begin
   //       // I-TYPE std Covgrp Construction
   //       foreach(I_type_f7_0_inst[i]) I_type_f7_0_inst[i]  = new(i, 0, OPCODE_I, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //       I_type_f7_32_inst = new(5, 32, OPCODE_I, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //    end

   //    "I_type_load_test": begin
   //       // I-TYPE LOAD Covgrp Construction
   //       foreach(I_type_load_inst[i]) begin
   //          if(i < 3) begin
   //             I_type_load_inst[i] = new(i, 0, OPCODE_LOAD, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //          end
   //          else begin
   //             I_type_load_inst[i] = new(i+1, 0, OPCODE_LOAD, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);      
   //          end
   //       end      
   //    end

   //    "JALR_type_test": begin
   //       // I-TYPE JALR Covgrp Construction
   //       I_type_jalr_inst = new(0, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //    end

   //    "R_type_std_test": begin
   //       // R-TYPE Covgrp Construction (I Extension)
   //       foreach(R_type_f7_0_inst[i]) R_type_f7_0_inst[i]   = new(i, 0, OPCODE_R, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //       R_type_f7_32_inst[0] = new(0, 32, OPCODE_R, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //       R_type_f7_32_inst[1] = new(5, 32, OPCODE_R, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //    end

   //    "S_type_test": begin
   //       // S-TYPE Covgrp Construction
   //       foreach(S_type_inst[i]) S_type_inst[i] = new(i, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //    end

   //    "B_type_test": begin
   //       // B-TYPE Covgrp Construction
   //       foreach(B_type_inst[i]) begin
   //          if(i < 2) begin
   //             B_type_inst[i] = new(i, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //          end
   //          else begin
   //             B_type_inst[i] = new(i+2, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);      
   //          end
   //       end
   //    end

   //    "U_type_test": begin
   //       // U-TYPE Covgrp Construction
   //       U_type_inst[0]    = new(0, OPCODE_LUI, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //       U_type_inst[1]    = new(0, OPCODE_AUIPC, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //    end

   //    "J_type_test": begin
   //       // J-TYPE Covgrp Construction
   //       J_type_inst       = new(0, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //    end

   //    //=========================================================== "M" Extension Covergrps Instances =======================================//
   //    "M_Extension_test": begin
   //       // R-TYPE Covgrp Construction (M Extension)
   //       foreach(R_type_f7_1_inst[i])  R_type_f7_1_inst[i] = new(i, 1, OPCODE_R, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   //    end

   // endcase

   //=========================================================== "I" Extension Covergrps Instances =======================================//
   // I-TYPE Covgrp Construction
   foreach(I_type_f7_0_inst[i]) I_type_f7_0_inst[i]  = new(i, 0, OPCODE_I, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   I_type_f7_32_inst = new(5, 32, OPCODE_I, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   foreach(I_type_load_inst[i]) begin
      if(i < 3) begin
         I_type_load_inst[i] = new(i, 0, OPCODE_LOAD, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
      end
      else begin
         I_type_load_inst[i] = new(i+1, 0, OPCODE_LOAD, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);      
      end
   end
   I_type_jalr_inst = new(0, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);

   // R-TYPE Covgrp Construction (I Extension)
   foreach(R_type_f7_0_inst[i]) R_type_f7_0_inst[i]   = new(i, 0, OPCODE_R, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   R_type_f7_32_inst[0] = new(0, 32, OPCODE_R, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   R_type_f7_32_inst[1] = new(5, 32, OPCODE_R, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);

   // S-TYPE Covgrp Construction
   foreach(S_type_inst[i]) S_type_inst[i] = new(i, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);

   // B-TYPE Covgrp Construction
   foreach(B_type_inst[i]) begin
      if(i < 2) begin
         B_type_inst[i] = new(i, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
      end
      else begin
         B_type_inst[i] = new(i+2, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);      
      end
   end
   
   // U-TYPE Covgrp Construction
   U_type_inst[0]    = new(0, OPCODE_LUI, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   U_type_inst[1]    = new(0, OPCODE_AUIPC, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);
   
   // J-TYPE Covgrp Construction
   J_type_inst       = new(0, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);

   //=========================================================== "M" Extension Covergrps Instances =======================================//
   // R-TYPE Covgrp Construction (M Extension)
   foreach(R_type_f7_1_inst[i])  R_type_f7_1_inst[i] = new(i, 1, OPCODE_R, input_cov_copied, cv32e40p_Regfile_config::regfile_mirror);

endfunction : new

/*********************************************************
/ Build Phase : Has Creators, Getters & possible overrides
**********************************************************/
function void build_phase(uvm_phase phase);
   super.build_phase(phase);
   `uvm_info(get_full_name(), "Build phase", UVM_LOW)

   // Create rst analysis exports
   RST_n_ap = new("RST_n_ap",this);
   RST_p_ap = new("RST_p_ap",this);

   // Create rst FIFOs
   RST_n_fifo = new("RST_n_fifo",this);
   RST_p_fifo = new("RST_p_fifo",this);

   //TLM Connections for all agents' Input Monitors
   if_stage_ap_in      = new("if_stage_ap_in", this);
   id_stage_ap_in      = new("id_stage_ap_in", this);
   ie_stage_ap_in      = new("ie_stage_ap_in", this);
   data_memory_ap_in   = new("data_memory_ap_in", this);
   isr_if_ap_in        = new("isr_if_ap_in", this);
   dbg_if_ap_in        = new("dbg_if_ap_in", this);

   //TLM Connections for all agents' Output Monitors
   if_stage_ap_out     = new("if_stage_ap_out", this);
   id_stage_ap_out     = new("id_stage_ap_out", this);
   ie_stage_ap_out     = new("ie_stage_ap_out", this);
   data_memory_ap_out  = new("data_memory_ap_out", this);
   isr_if_ap_out       = new("isr_if_ap_out", this);
   dbg_if_ap_out       = new("dbg_if_ap_out", this);

   //TLM FIFOs for all agents' Input Monitors
   if_stage_fifo_in      = new("if_stage_fifo_in", this);
   id_stage_fifo_in      = new("id_stage_fifo_in", this);
   ie_stage_fifo_in      = new("ie_stage_fifo_in", this);
   data_memory_fifo_in   = new("data_memory_fifo_in", this);
   isr_if_fifo_in        = new("isr_if_fifo_in", this);
   dbg_if_fifo_in        = new("dbg_if_fifo_in", this);

   //TLM FIFOs for all agents' Output Monitors
   if_stage_fifo_out     = new("if_stage_fifo_out", this);
   id_stage_fifo_out     = new("id_stage_fifo_out", this);
   ie_stage_fifo_out     = new("ie_stage_fifo_out", this);
   data_memory_fifo_out  = new("data_memory_fifo_out", this);
   isr_if_fifo_out       = new("isr_if_fifo_out", this);
   dbg_if_fifo_out       = new("dbg_if_fifo_out", this);

   if (! uvm_config_db#(cv32e40p_Regfile_config)::get(this, "", "regfile_cfg", regfile_cfg) )
      `uvm_fatal(get_type_name(), "Could not get Regfile config")

endfunction: build_phase

/****************************************
/ Connect Phase : Has TLM Connections
******************************************/
function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   `uvm_info(get_full_name(), "Connect phase", UVM_LOW)

   //Connect RST Agent to Subscriber FIFOs
   RST_n_ap.connect(RST_n_fifo.analysis_export);
   RST_p_ap.connect(RST_p_fifo.analysis_export);
   
   // Connect All agents' (except RST_agent) inputs & outputs to Subscriber
   if_stage_ap_in.connect(if_stage_fifo_in.analysis_export);
   if_stage_ap_out.connect(if_stage_fifo_out.analysis_export);

   id_stage_ap_in.connect(id_stage_fifo_in.analysis_export);
   id_stage_ap_out.connect(id_stage_fifo_out.analysis_export);

   ie_stage_ap_in.connect(ie_stage_fifo_in.analysis_export);
   ie_stage_ap_out.connect(ie_stage_fifo_out.analysis_export);

   data_memory_ap_in.connect(data_memory_fifo_in.analysis_export);
   data_memory_ap_out.connect(data_memory_fifo_out.analysis_export);

   dbg_if_ap_in.connect(dbg_if_fifo_in.analysis_export);
   dbg_if_ap_out.connect(dbg_if_fifo_out.analysis_export);

   isr_if_ap_in.connect(isr_if_fifo_in.analysis_export);
   isr_if_ap_out.connect(isr_if_fifo_out.analysis_export);
    
endfunction : connect_phase

/****************************************************************************************************
/ Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
*****************************************************************************************************/
task main_phase(uvm_phase phase);
   cv32e40p_rst_sequence_item rst_seq_item;
   super.main_phase(phase);
   `uvm_info(get_full_name(), "Main phase", UVM_LOW)
   forever begin
      fork
         RST_n_fifo.get(rst_seq_item);
         collect_cov();
      join
      disable fork;
      RST_p_fifo.get(rst_seq_item);
   end
endtask : main_phase

/****************************************************************************************************
/ Collect Cov : Task to sample needed inputs & outputs then sample them with cov grps accordingly
*****************************************************************************************************/
task collect_cov();
	forever begin
	fork
	
	
	begin
		//get insrtruction
      id_stage_fifo_in.get(id_s_req_i);
		//input_cov_copied.copy(id_s_req_i);
      
      // Incrementing Transaction Count to keep track of the number of sampled transactions
      trans_count++;

      // DECODE:
      instr       = id_s_req_i.instr_rdata_i; // shorthand
      opcode  	   = instr[6:0];
      rd_addr 	   = instr[11:7];       // address of rd
      rs1_addr 	= instr[19:15];     // address of rs1
      rs2_addr 	= instr[24:20];     // address of rs2  
      funct3  	   = instr[14:12];
      funct7  	   = instr[31:25];
      shamt       = instr[24:20];

      // I-type (ADDI, LW, JALR, etc.)
      imm_I = {{20{instr[31]}}, instr[31:20]};
      
      // S-type (SW, SH, SB)
      imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      
      // B-type (BEQ, BNE, etc.)
      imm_B = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
      
      // U-type (LUI, AUIPC)
      imm_U = {instr[31:12], 12'b0}; // already aligned
      
      // J-type (JAL)
      imm_J = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
      
      // Basic I-type ALU instructions
      is_addi  = (opcode == OPCODE_I && funct3 == ADDI_FUNCT3);
      is_slti  = (opcode == OPCODE_I && funct3 == SLTI_FUNCT3);
      is_sltiu = (opcode == OPCODE_I && funct3 == SLTIU_FUNCT3);
      is_xori  = (opcode == OPCODE_I && funct3 == XORI_FUNCT3);
      is_ori   = (opcode == OPCODE_I && funct3 == ORI_FUNCT3);
      is_andi  = (opcode == OPCODE_I && funct3 == ANDI_FUNCT3);
      is_jalr  =  (opcode == OPCODE_JALR );
	  if(is_jalr)
		$display("a7asssssssssssaa jalr is %h %d ",instr,imm_I);
      // Shift instructions (SLLI, SRLI, SRAI) require funct7 check
      is_slli  = (opcode == OPCODE_I && funct3 == SLLI_FUNCT3 && funct7 == 7'b0000000);
      is_srli  = (opcode == OPCODE_I && funct3 == SRLI_SRAI_FUNCT3 && funct7 == 7'b0000000);
      is_srai  = (opcode == OPCODE_I && funct3 == SRLI_SRAI_FUNCT3 && funct7 == 7'b0100000);

      is_sb = (opcode == OPCODE_S && funct3 == SB_FUNCT3);
      is_sh = (opcode == OPCODE_S && funct3 == SH_FUNCT3);
      is_sw = (opcode == OPCODE_S && funct3 == SW_FUNCT3);

      is_mul     = (opcode == OPCODE_R && funct7 == 7'b0000001 && funct3 == ADD_SUB_MUL_FUNCT3);
      is_mulh    = (opcode == OPCODE_R && funct7 == 7'b0000001 && funct3 == 3'b001);
      is_mulhsu  = (opcode == OPCODE_R && funct7 == 7'b0000001 && funct3 == 3'b010);
      is_mulhu   = (opcode == OPCODE_R && funct7 == 7'b0000001 && funct3 == 3'b011);

      //sample cov_groups
      I_Type_ADDI.sample();
      I_Type_SLTI.sample();
      I_Type_SLTIU.sample();
      I_Type_ANDI.sample();
      I_Type_ORI.sample();
      I_Type_XORI.sample();
      I_Type_SLLI.sample();
      I_Type_SRLI.sample();
      I_Type_SRAI.sample();
      S_Type_SB.sample();
      S_Type_SH.sample();
      S_Type_SW.sample();
      R_Type_MUL.sample();
      I_Type_JALR.sample();
	end
	begin
		ie_stage_fifo_in.get(ie_s_req_i);
		
			mult_operator_ex  = ie_s_req_i.mult_operator_ex;
			mult_operand_a_ex = ie_s_req_i.mult_operand_a_ex;
			mult_operand_b_ex = ie_s_req_i.mult_operand_b_ex;
			mult_operand_c_ex = ie_s_req_i.mult_operand_c_ex;
			mult_en_ex        = ie_s_req_i.mult_en_ex;
			
			alu_operator_ex   = ie_s_req_i.alu_operator_ex;
			alu_operand_a_ex  = ie_s_req_i.alu_operand_a_ex;
			alu_operand_b_ex  = ie_s_req_i.alu_operand_b_ex;
			alu_operand_c_ex  = ie_s_req_i.alu_operand_c_ex;
			alu_en_ex         = ie_s_req_i.alu_en_ex;
			cg_mul_covgroup.sample();
			cg_div_covgroup.sample();
			cg_divU_covgroup.sample();
			cg_rem_covgroup.sample();
			cg_remU_covgroup.sample();
			cg_shift_covgroup.sample();
	
	end
	
	join
      
	
	  
	  
	  
      
	
			
		
		
		
	
	
		
   
      // case(test_name)
      //    //=========================================================== "I" Extension Covergrps Instances =======================================//
      //    "I_type_std_test": begin
      //       // I-TYPE std Covgrp Sampling
      //       foreach(I_type_f7_0_inst[i])  I_type_f7_0_inst[i].sample();
      //       I_type_f7_32_inst.sample();
      //    end

      //    "I_type_load_test": begin
      //       // I-TYPE LOAD Covgrp Sampling
      //       foreach(I_type_load_inst[i])  I_type_load_inst[i].sample();   
      //    end

      //    "JALR_type_test": begin
      //       // I-TYPE JALR Covgrp Sampling
      //       I_type_jalr_inst.sample();      
      //    end

      //    "R_type_std_test": begin
      //       // R-TYPE Covgrp Sampling (I Extension)
      //       foreach(R_type_f7_0_inst[i])  R_type_f7_0_inst[i].sample();
      //       foreach(R_type_f7_32_inst[i]) R_type_f7_32_inst[i].sample();
      //    end

      //    "S_type_test": begin
      //       // S-TYPE Covgrp Sampling
      //       foreach(S_type_inst[i])       S_type_inst[i].sample();
      //    end

      //    "B_type_test": begin
      //       // B-TYPE Covgrp Sampling
      //       foreach(B_type_inst[i])       B_type_inst[i].sample();
      //    end

      //    "U_type_test": begin
      //       // U-TYPE Covgrp Sampling
      //       foreach(U_type_inst[i])       U_type_inst[i].sample();
      //    end

      //    "J_type_test": begin
      //       // J-TYPE Covgrp Sampling
      //       J_type_inst.sample();
      //    end

      //    //=========================================================== "M" Extension Covergrps Instances =======================================//
      //    "M_Extension_test": begin
      //       // R-TYPE Covgrp Sampling (M Extension)
      //       foreach(R_type_f7_1_inst[i]) R_type_f7_1_inst[i].sample();
      //    end
      // endcase

      //=========================================================== "I" Extension Covergrps Instances =======================================//
      // I-TYPE Covgrp Sampling
      foreach(I_type_f7_0_inst[i])  I_type_f7_0_inst[i].sample();
      I_type_f7_32_inst.sample();
      I_type_jalr_inst.sample();
      foreach(I_type_load_inst[i])  I_type_load_inst[i].sample();

      // R-TYPE Covgrp Sampling (I Extension)
      foreach(R_type_f7_0_inst[i])  R_type_f7_0_inst[i].sample();
      foreach(R_type_f7_32_inst[i]) R_type_f7_32_inst[i].sample();

      // S-TYPE Covgrp Sampling
      foreach(S_type_inst[i])       S_type_inst[i].sample();

      // B-TYPE Covgrp Sampling
      foreach(B_type_inst[i])       B_type_inst[i].sample();

      // U-TYPE Covgrp Sampling
      foreach(U_type_inst[i])       U_type_inst[i].sample();

      // J-TYPE Covgrp Sampling
      J_type_inst.sample();

      //=========================================================== "M" Extension Covergrps Instances =======================================//
      // R-TYPE Covgrp Sampling (M Extension)
      foreach(R_type_f7_1_inst[i]) R_type_f7_1_inst[i].sample();
   end
endtask


/***************************************************************************************************
// Final Phase: used to report when the subscriber finishes its operation before the simulation ends
/***************************************************************************************************/
function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info(get_type_name(), "subscriber is stopping.", UVM_LOW)
endfunction

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
   `uvm_info(get_type_name(), $sformatf("Received transactions: %0d", trans_count), UVM_MEDIUM)

   `uvm_info(get_type_name(), "\nCoverage Report:", UVM_LOW)
   `uvm_info(get_type_name(), $sformatf("TEST_NAME = %s", test_name), UVM_LOW)

   case(test_name)

      //=========================================================== "I" Extension Covergrps Instances =======================================//
      "I_type_std_test": begin
         // I-TYPE std Covgrp Sampling
         `uvm_info(get_type_name(), $sformatf("'I' I-TYPE: F7:0 STD    Coverage: %.2f%%", I_type_f7_0_inst[0].get_coverage()), UVM_LOW)   
         `uvm_info(get_type_name(), $sformatf("'I' I-TYPE: F7:32 STD   Coverage: %.2f%%", I_type_f7_32_inst.get_coverage()), UVM_LOW)   
      end

      "I_type_load_test": begin
         // I-TYPE LOAD Covgrp Sampling
         `uvm_info(get_type_name(), $sformatf("'I' I-TYPE: LOAD        Coverage: %.2f%%", I_type_load_inst[0].get_coverage()), UVM_LOW)           
      end

      "JALR_test": begin
         // I-TYPE JALR Covgrp Sampling
         `uvm_info(get_type_name(), $sformatf("'I' I-TYPE: JALR        Coverage: %.2f%%", I_type_jalr_inst.get_coverage()), UVM_LOW)           
      end

      "R_type_std_test": begin
         // R-TYPE Covgrp Sampling (I Extension)
         `uvm_info(get_type_name(), $sformatf("'I' R-TYPE: F7:0 STD    Coverage: %.2f%%", R_type_f7_0_inst[0].get_coverage()), UVM_LOW)   
         `uvm_info(get_type_name(), $sformatf("'I' R-TYPE: F7:32 STD   Coverage: %.2f%%", R_type_f7_32_inst[0].get_coverage()), UVM_LOW)   
      end

      "S_type_test": begin
         // S-TYPE Covgrp Sampling
         `uvm_info(get_type_name(), $sformatf("'I' S-TYPE:             Coverage: %.2f%%", S_type_inst[0].get_coverage()), UVM_LOW)           
      end

      "B_type_test": begin
         // B-TYPE Covgrp Sampling
         `uvm_info(get_type_name(), $sformatf("'I' B-TYPE:             Coverage: %.2f%%", B_type_inst[0].get_coverage()), UVM_LOW)           
      end

      "U_type_test": begin
         // U-TYPE Covgrp Sampling
         `uvm_info(get_type_name(), $sformatf("'I' U-TYPE:             Coverage: %.2f%%", U_type_inst[0].get_coverage()), UVM_LOW)           
      end

      "J_type_test": begin
         // J-TYPE Covgrp Sampling
         `uvm_info(get_type_name(), $sformatf("'I' J-TYPE:             Coverage: %.2f%%", J_type_inst.get_coverage()), UVM_LOW)           
      end

      //=========================================================== "M" Extension Covergrps Instances =======================================//
      "M_Extension_test": begin
         // R-TYPE Covgrp Sampling (M Extension)
         `uvm_info(get_type_name(), $sformatf("'M' R-TYPE:             Coverage: %.2f%%", R_type_f7_1_inst[0].get_coverage()), UVM_LOW)           
      end
   endcase

   `uvm_info(get_type_name(), $sformatf("Total Coverage: %.2f%%", $get_coverage()), UVM_LOW)  
      
endfunction : report_phase

endclass : subscriber

