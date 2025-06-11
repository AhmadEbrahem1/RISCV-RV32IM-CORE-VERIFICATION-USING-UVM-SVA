package rv32im_pkg;
import cv32e40p_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

	typedef enum {I_TYPE, R_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE, NOP} instr_type_e;

	// ===== Enums for opcodes =====
	typedef enum logic [6:0] {
		OPCODE_I        = 7'b0010011,
		OPCODE_JALR     = 7'b1100111,
		OPCODE_LOAD     = 7'b0000011,
	    OPCODE_R        = 7'b0110011,
		OPCODE_S        = 7'b0100011,
		OPCODE_B        = 7'b1100011,
		OPCODE_LUI      = 7'b0110111,
		OPCODE_AUIPC    = 7'b0010111,
		OPCODE_JAL      = 7'b1101111
	} opcode_e;
	
	// ===== Enums for funct3 per instruction type =====
	
	typedef enum logic [2:0] {
		ADDI_FUNCT3   = 3'b000,
		SLTI_FUNCT3   = 3'b010,
		SLTIU_FUNCT3  = 3'b011,
		XORI_FUNCT3   = 3'b100,
		ORI_FUNCT3    = 3'b110,
		ANDI_FUNCT3   = 3'b111,
		SLLI_FUNCT3   = 3'b001,
		SRLI_SRAI_FUNCT3 = 3'b101
	} funct3_I_e;
	
	typedef enum logic [2:0] {
		ADD_SUB_MUL_FUNCT3   = 3'b000,
		SLL_MULH_FUNCT3      = 3'b001,
		SLT_MULHSU_FUNCT3    = 3'b010,
		SLTU_MULHU_FUNCT3    = 3'b011,
		XOR_FUNCT3           = 3'b100,
		SRL_SRA_FUNCT3       = 3'b101,
		OR_FUNCT3            = 3'b110,
		AND_FUNCT3           = 3'b111
	} funct3_R_e;
	
	typedef enum logic [2:0] {
		SB_FUNCT3 = 3'b000,
		SH_FUNCT3 = 3'b001,
		SW_FUNCT3 = 3'b010
	} funct3_S_e;
	
	typedef enum logic [2:0] {
		BEQ_FUNCT3  = 3'b000,
		BNE_FUNCT3  = 3'b001,
		BLT_FUNCT3  = 3'b100,
		BGE_FUNCT3  = 3'b101,
		BLTU_FUNCT3 = 3'b110,
		BGEU_FUNCT3 = 3'b111
	} funct3_B_e;

	typedef enum logic [2:0] {
		LB_FUNCT3   = 3'b000,
		LH_FUNCT3   = 3'b001,
		LW_FUNCT3   = 3'b010,
		LBU_FUNCT3  = 3'b100,
		LHU_FUNCT3  = 3'b101
	} funct3_L_e;

	/************************************
	*************Agents Configs**********
	************************************/
	`include "cv32e40p_data_memory_if_agent_config.sv"
	`include "cv32e40p_debug_if_agent_config.sv"
	`include "cv32e40p_id_agent_config.sv"
	`include "cv32e40p_ie_agent_config.sv"
	`include "cv32e40p_if_agent_config.sv"
	`include "cv32e40p_interrupt_if_agent_config.sv"
	`include "cv32e40p_rst_agent_config.sv"

	`include "cv32e40p_env_config.sv"
	`include "cv32e40p_test_config.sv"
	`include "cv32e40p_Regfile_config.sv"
	/************************************
	***********Sequence Items********
	************************************/
	`include "base_sequence_item.sv"
	`include "cv32e40p_rst_sequence_item.sv"
	`include "cv32e40p_if_sequence_item.sv"
	`include "cv32e40p_interrupt_sequence_item.sv"
	`include "cv32e40p_id_sequence_item.sv"
	`include "cv32e40p_ie_sequence_item.sv"
	`include "cv32e40p_debug_sequence_item.sv"
	`include "cv32e40p_data_memory_sequence_item.sv"

	/************************************
	********** Agent Components*******
	************************************/
	//data_memory_agent
	`include "cv32e40p_data_memory_if_driver.sv"
	`include "cv32e40p_data_memory_if_monitor.sv"
	`include "cv32e40p_data_memory_if_sequencer.sv"

	//dbg_if_agent
	`include "cv32e40p_debug_if_driver.sv"
	`include "cv32e40p_debug_if_monitor.sv"
	`include "cv32e40p_debug_if_sequencer.sv"

	//id_stage_agent
	`include "cv32e40p_id_monitor.sv"

	//ie_stage_agent
	`include "cv32e40p_ie_monitor.sv"

	//if_stage_agent
	`include "cv32e40p_if_driver.sv"
	`include "cv32e40p_if_monitor.sv"
	`include "cv32e40p_if_sequencer.sv"

	//isr_if_agent
	`include "cv32e40p_interrupt_driver.sv"
	`include "cv32e40p_interrupt_monitor.sv"
	`include "cv32e40p_interrupt_sequencer.sv"

	//RST_agent
	`include "cv32e40p_rst_driver.sv"
	`include "cv32e40p_rst_monitor.sv"
	`include "cv32e40p_rst_sequencer.sv"

	/************************************
	********Scoreboard Components********
	************************************/
	`include "cv32e40p_if_predictor.sv"
	`include "cv32e40p_if_comparator.sv"
	`include "cv32e40p_if_checker.sv"

	`include "cv32e40p_ie_predictor.sv"
	`include "cv32e40p_ie_comparator.sv"
	`include "cv32e40p_ie_checker.sv"

	`include "cv32e40p_id_predictor.sv"
	`include "cv32e40p_id_comparator.sv"
	`include "cv32e40p_id_checker.sv"

	`include "cv32e40p_data_memory_predictor.sv"
	`include "cv32e40p_data_memory_comparator.sv"
	`include "cv32e40p_data_memory_checker.sv"

	`include "cv32e40p_lsu_predictor.sv"
	`include "cv32e40p_lsu_comparator.sv"
	`include "cv32e40p_lsu_checker.sv"

	`include "cv32e40p_debug_if_predictor.sv"
	`include "cv32e40p_debug_if_comparator.sv"
	`include "cv32e40p_debug_if_checker.sv"
	/************************************
	********Environment Components******
	************************************/
	`include "cv32e40p_data_memory_if_agent.sv"
	`include "cv32e40p_debug_if_agent.sv"
	`include "cv32e40p_id_agent.sv"
	`include "cv32e40p_ie_agent.sv"
	`include "cv32e40p_if_agent.sv"
	`include "cv32e40p_interrupt_agent.sv"
	`include "cv32e40p_rst_agent.sv"
	`include "scoreboard.sv"
	`include "subscriber.sv"

	/************************************
	**********Virtual Sequencer**********
	************************************/
	`include "virtual_sequencer.sv"
	/************************************
	************Test Components*********
	************************************/

	/************************************
	***************Sequences************
	************************************/
	`include "rst_sequence.sv"
	`include "ADDI_sequence.sv"
	`include "ANDI_sequence.sv"
	`include "ORI_sequence.sv"
	`include "SLLI_sequence.sv"
	`include "SLTI_sequence.sv"
	`include "SLTIU_sequence.sv"
	`include "SRAI_sequence.sv"
	`include "SRLI_sequence.sv"
	`include "XORI_sequence.sv"
	`include "data_mem_slave_sequence.sv"
	`include "B_Sequence.sv"
	`include "R_sequence.sv"
	`include "S_sequence.sv"
	`include "U_sequence.sv"
	`include "MUL_sequence.sv"
	`include "NOP_sequence.sv"
	`include "Hazard_sequence.sv"
	`include "JALR_sequence.sv"

	`include "ADD_sequence.sv"
	`include "AND_sequence.sv"
	`include "SUB_sequence.sv"
	`include "XOR_sequence.sv"
	`include "OR_sequence.sv"
	`include "SLL_sequence.sv"
	`include "SRL_sequence.sv"
	`include "SRA_sequence.sv"
	`include "SLT_sequence.sv"
	`include "SLTU_sequence.sv"
	`include "SwLoad_sequence.sv"
	`include "ShLoad_sequence.sv"
	`include "SbLoad_sequence.sv"

	`include "LB_sequence.sv"
	`include "LBU_sequence.sv"
	`include "LH_sequence.sv"
	`include "LHU_sequence.sv"
	`include "LW_sequence.sv"

	`include "JAL_sequence.sv"

	`include "DIV_sequence.sv"
	`include "REM_sequence.sv"
	`include "BEQ_sequence.sv"
	`include "BNE_sequence.sv"
	`include "BLT_sequence.sv"
	`include "BGE_sequence.sv"
	`include "BLTU_sequence.sv"
	`include "BGEU_sequence.sv"

	`include "lui_sequence.sv"
	`include "auipc_sequence.sv"

	`include "Regfile_Initialize_sequence.sv"
	`include "Regfile_Initialize_sequence_for_loadInstr.sv"

	/************************************
	***********Environment**************
	************************************/
	`include "cv32e40p_env.sv"
	/************************************
	***********Virtual Sequences********
	************************************/
	`include "base_v_seq.sv"
	`include "R_type_std_vseq.sv"
	`include "M_Extension_vseq.sv"
	`include "I_type_std_vseq.sv"
	`include "I_type_store_load_vseq.sv"
	`include "S_type_vseq.sv"
	`include "B_type_vseq.sv"
	`include "U_type_vseq.sv"
	`include "JALR_vseq.sv"
	`include "Hazard_vseq.sv"

	/************************************
	****************Tests****************
	************************************/
	`include "base_test.sv"
	`include "U_type_test.sv"
	`include "B_type_test.sv"
	`include "M_Extension_test.sv"
	`include "R_type_std_test.sv"
	`include "I_type_std_test.sv"
	`include "I_type_store_load_test.sv"
	`include "S_type_test.sv"
	`include "JALR_test.sv"
	`include "Hazard_test.sv"


endpackage : rv32im_pkg
