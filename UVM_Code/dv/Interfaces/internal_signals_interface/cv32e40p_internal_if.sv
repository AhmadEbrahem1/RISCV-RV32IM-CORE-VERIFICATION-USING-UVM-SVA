interface cv32e40p_internal_if(input bit clk_i);
    
    import cv32e40p_pkg::*;

    /************************************************************
    / Instruction Fetch to Decode Intermediate Signals
    /************************************************************/
    logic             instr_valid_id;
    logic   [31:0]    instr_rdata_id;  // Instruction sampled inside IF stage
	
    logic             clear_instr_valid;  // Clear instruction valid flag
    logic             pc_set;             // Set PC signal
    logic   [ 3:0]    pc_mux_id;             // PC mux selector
    logic   [ 2:0]    exc_pc_mux_id;         // Exception PC mux selector
    logic   [ 1:0]    trap_addr_mux;      // Trap address mux selector

    logic             is_fetch_failed_id;    // Fetch failed indication
    logic   [31:0]    pc_if;         // Instruction address output
    logic   [31:0]    pc_id;             // Current PC in ID stage
    logic             halt_if;           // Halt IF stage
    logic             instr_req_int;     // Instruction request interrupt signal 
    logic             id_ready;          // ID stage ready for new instruction

    /*********************************************************************
    / Instruction Decode to Execute & back to Fetch Intermediate Signals
    /*********************************************************************/
    // From ID to EX to halt EX
    logic              is_decoding;                 // High as long as Decoding is ON
	
    // Jumps and Branches
	logic              branch_in_ex;                // Branch in EX stage
	// logic              branch_decision;             // Branch decision from EX
	// logic       [31:0] jump_target_id;                 // Calculated jump target
	logic       [ 1:0] ctrl_transfer_insn_in_dec;   // Control transfer instruction type

	// Pipeline ID to EX Stage
	logic       [31:0] pc_ex;                       // PC in EX stage
	logic              alu_en_ex;                   // ALU EN
    cv32e40p_pkg::alu_opcode_e       alu_operator_ex;             // Determines the Operation
	logic       [31:0] alu_operand_a_ex;            // ALU operand A
	logic       [31:0] alu_operand_b_ex;            // ALU operand B
	logic       [31:0] alu_operand_c_ex;            // ALU operand C
	logic       [ 4:0] bmask_a_ex;                  // Bi tmask A
	logic       [ 4:0] bmask_b_ex;                  // Bi tmask B
	logic       [ 1:0] imm_vec_ext_ex;              // Immediate vector extension
	logic       [ 1:0] alu_vec_mode_ex;             // ALU vector mode
	
	logic       [ 5:0] regfile_waddr_ex;            // Register file write address
	logic              regfile_we_ex;               // Register file write enable
	logic       [ 5:0] regfile_alu_waddr_ex;        // ALU result write address
	logic              regfile_alu_we_ex;           // ALU result write enable

	// Multiplier Signals to EX Stage
	cv32e40p_pkg::mul_opcode_e       mult_operator_ex;            // Multiplier operation
	logic       [31:0] mult_operand_a_ex;           // Multiplier operand A
	logic       [31:0] mult_operand_b_ex;           // Multiplier operand B
	logic       [31:0] mult_operand_c_ex;           // Multiplier operand C
	logic              mult_en_ex;                  // Multiplier enable
	logic              mult_sel_subword_ex;         // Subword selection
	logic       [ 1:0] mult_signed_mode_ex;         // Signed mode
	logic       [ 4:0] mult_imm_ex;                 // Multiplier immediate
	
	logic       [31:0] mult_dot_op_a_ex;            // Dot product operand A
	logic       [31:0] mult_dot_op_b_ex;            // Dot product operand B
	logic       [31:0] mult_dot_op_c_ex;            // Dot product operand C
	logic       [ 1:0] mult_dot_signed_ex;          // Dot product signed mode
	logic              mult_is_clpx_ex;             // Complex multiplication
	logic       [ 1:0] mult_clpx_shift_ex;          // Complex multiplication shift
	logic              mult_clpx_img_ex;            // Complex multiplication imaginary

    /***************************************
    / Instruction Execute Stage Signals
    /***************************************/
    logic              regfile_we_wb;
    logic       [31:0] regfile_wdata;
    logic              regfile_we_wb_power;

    // Output of EX stage pipeline

    // To IF: Jump and branch target and decision
    logic       [31:0] jump_target_id;              // When a Jump occurs, this indicates which address to JUMP to
    logic       [31:0] jump_target_ex;              // When a Jump occurs, this indicates which address to JUMP to in EXCEPTION
    logic              branch_decision;             // To decide taken or not taken for branch and goes to IF
	
    // Execute Stage Readiness to recieve new data
	logic              ex_ready;                  // EX stage ready for new data
    logic              ex_valid;                  // EX stage gets new data

    /***************************************
    / Write Back Stage Signals
    /***************************************/
    // To ID stage: Forwarding signals

    logic        [ 5:0] regfile_alu_waddr_fw; // Forwarded from EX to ID
    logic               regfile_alu_we_fw;      // Forwarded from EX to ID
    logic               regfile_alu_we_fw_power;    // Forwarded from EX to ID
    logic        [31:0] regfile_alu_wdata_fw;   // Forwarded from EX to ID
    logic        [ 5:0] regfile_waddr_fw_wb_o; // Output of EX pipeline to ID
    /***************************************
    / Load & Store Unit Signals
    /***************************************/
    

    /********************************************************
    / cv32e40p Internal Interface Monitoring Clocking Block
    /********************************************************/
    clocking cb_mon @(posedge clk_i);
        // IF to ID
        input negedge  instr_valid_id;
        input negedge  instr_rdata_id;
        input negedge  clear_instr_valid;
        input negedge  pc_set;
        input negedge  pc_mux_id;
        input negedge  exc_pc_mux_id;
        input negedge  trap_addr_mux;
        input negedge  is_fetch_failed_id;
        input negedge  pc_id;
        input negedge  pc_if;
        input negedge  halt_if;
        input negedge  instr_req_int;
        input negedge  id_ready;

        // ID to EX and control
        input negedge  is_decoding;
        input negedge  branch_in_ex;
        input negedge  ctrl_transfer_insn_in_dec;
        input negedge  pc_ex;
        input negedge  alu_en_ex;
        input negedge  alu_operator_ex;
        input negedge  alu_operand_a_ex;
        input negedge  alu_operand_b_ex;
        input negedge  alu_operand_c_ex;
        input negedge  bmask_a_ex;
        input negedge  bmask_b_ex;
        input negedge  imm_vec_ext_ex;
        input negedge  alu_vec_mode_ex;
        input negedge  regfile_waddr_ex;
        input negedge  regfile_we_ex;
        input negedge  regfile_alu_waddr_ex;
        input negedge  regfile_alu_we_ex;

        // Multiplier
        input negedge  mult_operator_ex;
        input negedge  mult_operand_a_ex;
        input negedge  mult_operand_b_ex;
        input negedge  mult_operand_c_ex;
        input negedge  mult_en_ex;
        input negedge  mult_sel_subword_ex;
        input negedge  mult_signed_mode_ex;
        input negedge  mult_imm_ex;
        input negedge  mult_dot_op_a_ex;
        input negedge  mult_dot_op_b_ex;
        input negedge  mult_dot_op_c_ex;
        input negedge  mult_dot_signed_ex;
        input negedge  mult_is_clpx_ex;
        input negedge  mult_clpx_shift_ex;
        input negedge  mult_clpx_img_ex;

        // Execute Stage
        input negedge  regfile_we_wb;
        input negedge  regfile_wdata;
        input negedge  regfile_we_wb_power;
        input negedge  jump_target_id;
        input negedge  jump_target_ex;
        input negedge  branch_decision;
        input negedge  ex_ready;
        input negedge  ex_valid;

        // Write Back Stage
        input negedge  regfile_alu_waddr_fw;
        input negedge  regfile_alu_we_fw;
        input negedge  regfile_alu_we_fw_power;
        input negedge  regfile_alu_wdata_fw;
        input negedge  regfile_waddr_fw_wb_o;

    endclocking


    // /**********************************************************************
    // / Modeport to dictate the direction of all the signals in the Interface
    // /**********************************************************************/
    //modport INTERNAL (input cb_mon);

	modport INTERNAL (
    output instr_valid_id,
    output instr_rdata_id,
    output clear_instr_valid,
    output pc_set,
    output pc_mux_id,
    output exc_pc_mux_id,
    output trap_addr_mux,
    output is_fetch_failed_id,
    output pc_id,
    output pc_if,
    output halt_if,
    output instr_req_int,
    output id_ready,

    output is_decoding,
    output branch_in_ex,
    output ctrl_transfer_insn_in_dec,

    output pc_ex,
    output alu_en_ex,
    output alu_operand_a_ex,
    output alu_operand_b_ex,
    output alu_operand_c_ex,
    output bmask_a_ex,
    output bmask_b_ex,
    output imm_vec_ext_ex,
    output alu_vec_mode_ex,
	output alu_operator_ex,
	
    output regfile_waddr_ex,
    output regfile_we_ex,

    output mult_operand_a_ex,
    output mult_operand_b_ex,
    output mult_operand_c_ex,
    output mult_en_ex,
    output mult_sel_subword_ex,
    output mult_signed_mode_ex,
	output mult_clpx_img_ex,
	output mult_operator_ex,
	output regfile_alu_we_ex,
	output regfile_waddr_fw_wb_o,
	
    output regfile_we_wb,
    output regfile_wdata,

    output jump_target_id,
    output jump_target_ex,
    output branch_decision,

    output ex_ready,
    output ex_valid,
    output regfile_alu_waddr_ex,
    output regfile_alu_waddr_fw,
    output regfile_alu_we_fw,
    output regfile_alu_wdata_fw
);




endinterface : cv32e40p_internal_if
