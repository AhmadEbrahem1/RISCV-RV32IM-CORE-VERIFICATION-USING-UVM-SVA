// Include necessary packages and macros
// `include "cv32e40p_pkg.sv"

import cv32e40p_pkg::*;

/**
 * UVM sequence item class for cv32e40p ID stage verification
 * This class models all inputs and outputs of the cv32e40p ID stage module
 * for response checking
 */
class cv32e40p_id_sequence_item extends base_sequence_item;
  
  // Module parameters
  parameter N_HWLP          = 2;    // Number of hardware loops
  parameter APU_WOP_CPU     = 6;    // APU operation width
  parameter APU_NARGS_CPU   = 3;    // Number of APU arguments
  parameter APU_NDSFLAGS_CPU = 15;  // Number of APU downstream flags

  //----------------------------------------------------------------------------
  // Control Signals
  //----------------------------------------------------------------------------
  bit fetch_enable_i;       // Enable fetching new instructions
  bit ctrl_busy_o;          // Controller is busy
  bit is_decoding_o;        // Currently decoding an instruction

  //----------------------------------------------------------------------------
  // IF Stage Interface
  //----------------------------------------------------------------------------
  bit        instr_valid_i;   // Instruction is valid
  bit [31:0] instr_rdata_i;   // Instruction data
  bit        instr_req_o;     // Instruction fetch request
  bit        is_compressed_i; // Compressed instruction flag
  bit        illegal_c_insn_i;// Illegal compressed instruction

  //----------------------------------------------------------------------------
  // Jumps and Branches
  //----------------------------------------------------------------------------
  bit        branch_in_ex_o;                // Branch in EX stage
  bit        branch_decision_i;             // Branch decision from EX
  bit [31:0] jump_target_o;                 // Calculated jump target
  bit [1:0]  ctrl_transfer_insn_in_dec_o;   // Control transfer instruction type

  //----------------------------------------------------------------------------
  // IF and ID Stage Signals
  //----------------------------------------------------------------------------
  bit       clear_instr_valid_o;  // Clear instruction valid flag
  bit       pc_set_o;             // Set PC signal
  bit [3:0] pc_mux_o;             // PC mux selector
  bit [2:0] exc_pc_mux_o;         // Exception PC mux selector
  bit [1:0] trap_addr_mux_o;      // Trap address mux selector

  bit        is_fetch_failed_i;    // Fetch failed indication
  bit [31:0] pc_id_i;             // Current PC in ID stage

  //----------------------------------------------------------------------------
  // Pipeline Control Signals
  //----------------------------------------------------------------------------
  bit halt_if_o;     // Halt IF stage
  bit id_ready_o;    // ID stage ready
  bit ex_ready_i;    // EX stage ready
  bit wb_ready_i;    // WB stage ready
  bit id_valid_o;    // ID stage valid
  bit ex_valid_i;    // EX stage valid

  //----------------------------------------------------------------------------
  // Pipeline ID/EX Signals
  //----------------------------------------------------------------------------
  bit [31:0] pc_ex_o;              // PC in EX stage
  bit signed [31:0] alu_operand_a_ex_o;   // ALU operand A
  bit signed [31:0] alu_operand_b_ex_o;   // ALU operand B
  bit signed [31:0] alu_operand_c_ex_o;   // ALU operand C
  bit [4:0]  bmask_a_ex_o;         // Bitmask A
  bit [4:0]  bmask_b_ex_o;         // Bitmask B
  bit [1:0]  imm_vec_ext_ex_o;     // Immediate vector extension
  bit [1:0]  alu_vec_mode_ex_o;    // ALU vector mode

  bit [5:0] regfile_waddr_ex_o;    // Register file write address
  bit       regfile_we_ex_o;       // Register file write enable
  bit [5:0] regfile_alu_waddr_ex_o;// ALU result write address
  bit       regfile_alu_we_ex_o;   // ALU result write enable

  //----------------------------------------------------------------------------
  // ALU Signals
  //----------------------------------------------------------------------------
  bit              alu_en_ex_o;        // ALU enable
  alu_opcode_e     alu_operator_ex_o;  // ALU operation
  bit              alu_is_clpx_ex_o;   // Complex ALU operation
  bit              alu_is_subrot_ex_o; // Subword rotation
  bit [1:0]        alu_clpx_shift_ex_o;// Complex ALU shift amount

  //----------------------------------------------------------------------------
  // Multiplier Signals
  //----------------------------------------------------------------------------
  mul_opcode_e     mult_operator_ex_o;   // Multiplier operation
  bit [31:0]       mult_operand_a_ex_o;  // Multiplier operand A
  bit [31:0]       mult_operand_b_ex_o;  // Multiplier operand B
  bit [31:0]       mult_operand_c_ex_o;  // Multiplier operand C
  bit              mult_en_ex_o;         // Multiplier enable
  bit              mult_sel_subword_ex_o;// Subword selection
  bit [1:0]        mult_signed_mode_ex_o;// Signed mode
  bit [4:0]        mult_imm_ex_o;        // Multiplier immediate

  bit [31:0]       mult_dot_op_a_ex_o;   // Dot product operand A
  bit [31:0]       mult_dot_op_b_ex_o;   // Dot product operand B
  bit [31:0]       mult_dot_op_c_ex_o;   // Dot product operand C
  bit [1:0]        mult_dot_signed_ex_o; // Dot product signed mode
  bit              mult_is_clpx_ex_o;    // Complex multiplication
  bit [1:0]        mult_clpx_shift_ex_o; // Complex multiplication shift
  bit              mult_clpx_img_ex_o;   // Complex multiplication imaginary

  //----------------------------------------------------------------------------
  // Load/Store Unit Signals
  //----------------------------------------------------------------------------
  bit       data_req_ex_o;          // Data request
  bit       data_we_ex_o;           // Data write enable
  bit [1:0] data_type_ex_o;         // Data type (byte/halfword/word)
  bit [1:0] data_sign_ext_ex_o;      // Sign extension mode
  bit [1:0] data_reg_offset_ex_o;    // Register offset
  bit       data_load_event_ex_o;    // Load event
  bit       data_misaligned_ex_o;    // Misaligned access
  bit       prepost_useincr_ex_o;    // Use increment mode
  bit       data_misaligned_i;       // Input misaligned flag
  bit       data_err_i;              // Data error input
  bit       data_err_ack_o;          // Data error acknowledge
  bit [5:0] atop_ex_o;               // Atomic operation

  //----------------------------------------------------------------------------
  // Interrupt Signals
  //----------------------------------------------------------------------------
  bit [31:0] irq_i;            // Interrupt requests
  bit        irq_sec_i;        // Secure interrupt
  bit [31:0] mie_bypass_i;     // MIE CSR bypass
  bit [31:0] mip_o;            // MIP CSR output
  bit        m_irq_enable_i;   // Machine interrupt enable
  bit        u_irq_enable_i;   // User interrupt enable
  bit        irq_ack_o;        // Interrupt acknowledge
  bit [4:0]  irq_id_o;         // Interrupt ID
  bit [4:0]  exc_cause_o;      // Exception cause

  //----------------------------------------------------------------------------
  // Debug Signals
  //----------------------------------------------------------------------------
  bit       debug_mode_o;            // Debug mode active
  bit [2:0] debug_cause_o;          // Debug cause
  bit       debug_csr_save_o;        // Debug CSR save
  bit       debug_req_i;            // Debug request
  bit       debug_single_step_i;     // Single step mode
  bit       debug_ebreakm_i;        // Machine ebreak
  bit       debug_ebreaku_i;        // User ebreak
  bit       trigger_match_i;        // Trigger match
  bit       debug_p_elw_no_sleep_o; // No sleep during elw
  bit       debug_havereset_o;      // Debug module has reset
  bit       debug_running_o;       // Debug running state
  bit       debug_halted_o;        // Debug halted state

  //----------------------------------------------------------------------------
  // Wakeup Signal
  //----------------------------------------------------------------------------
  bit wake_from_sleep_o;  // Wakeup from sleep mode

  //----------------------------------------------------------------------------
  // Forwarding Signals
  //----------------------------------------------------------------------------
  bit [5:0]  regfile_waddr_wb_i;       // WB stage write address
  bit        regfile_we_wb_i;          // WB stage write enable
  bit        regfile_we_wb_power_i;    // WB stage write enable (power)
  bit [31:0] regfile_wdata_wb_i;       // WB stage write data
  bit [5:0]  regfile_alu_waddr_fw_i;   // ALU forward write address
  bit        regfile_alu_we_fw_i;      // ALU forward write enable
  bit        regfile_alu_we_fw_power_i;// ALU forward write enable (power)
  bit [31:0] regfile_alu_wdata_fw_i;   // ALU forward write data

  //----------------------------------------------------------------------------
  // Multiplier Signal
  //----------------------------------------------------------------------------
  bit mult_multicycle_i;  // Multi-cycle multiplication

  //----------------------------------------------------------------------------
  // UVM Field Macros
  //----------------------------------------------------------------------------
  `uvm_object_utils_begin(cv32e40p_id_sequence_item)
    // Control signals
    `uvm_field_int(fetch_enable_i, UVM_ALL_ON)
    `uvm_field_int(ctrl_busy_o, UVM_ALL_ON)
    `uvm_field_int(is_decoding_o, UVM_ALL_ON)

    // IF stage interface
    `uvm_field_int(instr_valid_i, UVM_ALL_ON)
    `uvm_field_int(instr_rdata_i, UVM_ALL_ON)
    `uvm_field_int(instr_req_o, UVM_ALL_ON)
    `uvm_field_int(is_compressed_i, UVM_ALL_ON)
    `uvm_field_int(illegal_c_insn_i, UVM_ALL_ON)

    // Jumps and branches
    `uvm_field_int(branch_in_ex_o, UVM_ALL_ON)
    `uvm_field_int(branch_decision_i, UVM_ALL_ON)
    `uvm_field_int(jump_target_o, UVM_ALL_ON)
    `uvm_field_int(ctrl_transfer_insn_in_dec_o, UVM_ALL_ON)

    // IF and ID stage signals
    `uvm_field_int(clear_instr_valid_o, UVM_ALL_ON)
    `uvm_field_int(pc_set_o, UVM_ALL_ON)
    `uvm_field_int(pc_mux_o, UVM_ALL_ON)
    `uvm_field_int(exc_pc_mux_o, UVM_ALL_ON)
    `uvm_field_int(trap_addr_mux_o, UVM_ALL_ON)
    `uvm_field_int(is_fetch_failed_i, UVM_ALL_ON)
    `uvm_field_int(pc_id_i, UVM_ALL_ON)

    // Stalls
    `uvm_field_int(halt_if_o, UVM_ALL_ON)
    `uvm_field_int(id_ready_o, UVM_ALL_ON)
    `uvm_field_int(ex_ready_i, UVM_ALL_ON)
    `uvm_field_int(wb_ready_i, UVM_ALL_ON)
    `uvm_field_int(id_valid_o, UVM_ALL_ON)
    `uvm_field_int(ex_valid_i, UVM_ALL_ON)

    // Pipeline ID/EX
    `uvm_field_int(pc_ex_o, UVM_ALL_ON)
    `uvm_field_int(alu_operand_a_ex_o, UVM_ALL_ON)
    `uvm_field_int(alu_operand_b_ex_o, UVM_ALL_ON)
    `uvm_field_int(alu_operand_c_ex_o, UVM_ALL_ON)
    `uvm_field_int(bmask_a_ex_o, UVM_ALL_ON)
    `uvm_field_int(bmask_b_ex_o, UVM_ALL_ON)
    `uvm_field_int(imm_vec_ext_ex_o, UVM_ALL_ON)
    `uvm_field_int(alu_vec_mode_ex_o, UVM_ALL_ON)
    `uvm_field_int(regfile_waddr_ex_o, UVM_ALL_ON)
    `uvm_field_int(regfile_we_ex_o, UVM_ALL_ON)
    `uvm_field_int(regfile_alu_waddr_ex_o, UVM_ALL_ON)
    `uvm_field_int(regfile_alu_we_ex_o, UVM_ALL_ON)

    // ALU
    `uvm_field_int(alu_en_ex_o, UVM_ALL_ON)
    `uvm_field_int(alu_is_clpx_ex_o, UVM_ALL_ON)
    `uvm_field_int(alu_is_subrot_ex_o, UVM_ALL_ON)
    `uvm_field_int(alu_clpx_shift_ex_o, UVM_ALL_ON)

    // MUL
    `uvm_field_int(mult_operand_a_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_operand_b_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_operand_c_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_en_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_sel_subword_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_signed_mode_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_imm_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_dot_op_a_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_dot_op_b_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_dot_op_c_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_dot_signed_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_is_clpx_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_clpx_shift_ex_o, UVM_ALL_ON)
    `uvm_field_int(mult_clpx_img_ex_o, UVM_ALL_ON)

    // Load/store unit
    `uvm_field_int(data_req_ex_o, UVM_ALL_ON)
    `uvm_field_int(data_we_ex_o, UVM_ALL_ON)
    `uvm_field_int(data_type_ex_o, UVM_ALL_ON)
    `uvm_field_int(data_sign_ext_ex_o, UVM_ALL_ON)
    `uvm_field_int(data_reg_offset_ex_o, UVM_ALL_ON)
    `uvm_field_int(data_load_event_ex_o, UVM_ALL_ON)
    `uvm_field_int(data_misaligned_ex_o, UVM_ALL_ON)
    `uvm_field_int(prepost_useincr_ex_o, UVM_ALL_ON)
    `uvm_field_int(data_misaligned_i, UVM_ALL_ON)
    `uvm_field_int(data_err_i, UVM_ALL_ON)
    `uvm_field_int(data_err_ack_o, UVM_ALL_ON)
    `uvm_field_int(atop_ex_o, UVM_ALL_ON)

    // Interrupts
    `uvm_field_int(irq_i, UVM_ALL_ON)
    `uvm_field_int(irq_sec_i, UVM_ALL_ON)
    `uvm_field_int(mie_bypass_i, UVM_ALL_ON)
    `uvm_field_int(mip_o, UVM_ALL_ON)
    `uvm_field_int(m_irq_enable_i, UVM_ALL_ON)
    `uvm_field_int(u_irq_enable_i, UVM_ALL_ON)
    `uvm_field_int(irq_ack_o, UVM_ALL_ON)
    `uvm_field_int(irq_id_o, UVM_ALL_ON)
    `uvm_field_int(exc_cause_o, UVM_ALL_ON)

    // Debug
    `uvm_field_int(debug_mode_o, UVM_ALL_ON)
    `uvm_field_int(debug_cause_o, UVM_ALL_ON)
    `uvm_field_int(debug_csr_save_o, UVM_ALL_ON)
    `uvm_field_int(debug_req_i, UVM_ALL_ON)
    `uvm_field_int(debug_single_step_i, UVM_ALL_ON)
    `uvm_field_int(debug_ebreakm_i, UVM_ALL_ON)
    `uvm_field_int(debug_ebreaku_i, UVM_ALL_ON)
    `uvm_field_int(trigger_match_i, UVM_ALL_ON)
    `uvm_field_int(debug_p_elw_no_sleep_o, UVM_ALL_ON)
    `uvm_field_int(debug_havereset_o, UVM_ALL_ON)
    `uvm_field_int(debug_running_o, UVM_ALL_ON)
    `uvm_field_int(debug_halted_o, UVM_ALL_ON)

    // Wakeup
    `uvm_field_int(wake_from_sleep_o, UVM_ALL_ON)

    // Forwarding
    `uvm_field_int(regfile_waddr_wb_i, UVM_ALL_ON)
    `uvm_field_int(regfile_we_wb_i, UVM_ALL_ON)
    `uvm_field_int(regfile_we_wb_power_i, UVM_ALL_ON)
    `uvm_field_int(regfile_wdata_wb_i, UVM_ALL_ON)
    `uvm_field_int(regfile_alu_waddr_fw_i, UVM_ALL_ON)
    `uvm_field_int(regfile_alu_we_fw_i, UVM_ALL_ON)
    `uvm_field_int(regfile_alu_we_fw_power_i, UVM_ALL_ON)
    `uvm_field_int(regfile_alu_wdata_fw_i, UVM_ALL_ON)

    // Multiplier
    `uvm_field_int(mult_multicycle_i, UVM_ALL_ON)
  `uvm_object_utils_end

  //----------------------------------------------------------------------------
  // Constructor
  //----------------------------------------------------------------------------
  // function new(string name = "cv32e40p_id_sequence_item");
  //   super.new(name);
  // endfunction
 
endclass : cv32e40p_id_sequence_item