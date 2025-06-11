`define INF cv32e40p_internal_intf

module observer
import cv32e40p_pkg::*;
(	
    cv32e40p_internal_if.INTERNAL cv32e40p_internal_intf,

    input logic             instr_valid_id,
    input logic   [31:0]    instr_rdata_id,
    input logic             clear_instr_valid,
    input logic             pc_set,
    input logic   [ 3:0]    pc_mux_id,
    input logic   [ 2:0]    exc_pc_mux_id,
    input logic   [ 1:0]    trap_addr_mux,
    input logic             is_fetch_failed_id,
    input logic   [31:0]    pc_id,
    input logic   [31:0]    pc_if, // This is the PC in IF stage, used for branch target calculation
    input logic             halt_if,
    input logic             instr_req_int,
    input logic             id_ready,
    input logic             is_decoding,
    input logic             branch_in_ex,
    input logic   [ 1:0]    ctrl_transfer_insn_in_dec,
    input logic   [31:0]    pc_ex,
    input logic             alu_en_ex,
    input alu_opcode_e      alu_operator_ex,
    input logic   [31:0]    alu_operand_a_ex,
    input logic   [31:0]    alu_operand_b_ex,
    input logic   [31:0]    alu_operand_c_ex,
    input logic   [ 4:0]    bmask_a_ex,
    input logic   [ 4:0]    bmask_b_ex,
    input logic   [ 1:0]    imm_vec_ext_ex,
    input logic   [ 1:0]    alu_vec_mode_ex,
    input logic   [ 5:0]    regfile_waddr_ex,
    input logic             regfile_we_ex,
    input logic   [ 5:0]    regfile_alu_waddr_ex,
    input logic             regfile_alu_we_ex,
    input mul_opcode_e      mult_operator_ex,
    input logic   [31:0]    mult_operand_a_ex,
    input logic   [31:0]    mult_operand_b_ex,
    input logic   [31:0]    mult_operand_c_ex,
    input logic             mult_en_ex,
    input logic             mult_sel_subword_ex,
    input logic   [ 1:0]    mult_signed_mode_ex,
    input logic   [ 4:0]    mult_imm_ex,
    input logic   [31:0]    mult_dot_op_a_ex,
    input logic   [31:0]    mult_dot_op_b_ex,
    input logic   [31:0]    mult_dot_op_c_ex,
    input logic   [ 1:0]    mult_dot_signed_ex,
    input logic             mult_is_clpx_ex,
    input logic   [ 1:0]    mult_clpx_shift_ex,
    input logic             mult_clpx_img_ex,
    input logic   [ 5:0]    regfile_waddr_fw_wb_o,
    input logic             regfile_we_wb,
    input logic             regfile_we_wb_power,
    input logic   [31:0]    regfile_wdata,
    input logic   [31:0]    jump_target_id,
    input logic   [31:0]    jump_target_ex,
    input logic             branch_decision,
    input logic             ex_ready,
    input logic             ex_valid,
    input logic   [ 5:0]    regfile_alu_waddr_fw,
    input logic             regfile_alu_we_fw,
    input logic             regfile_alu_we_fw_power,
    input logic   [31:0]    regfile_alu_wdata_fw
    //input logic   [ 5:0]    regfile_waddr_fw_wb_o
);

    always_comb begin
        // IF to ID
        `INF.instr_valid_id            = instr_valid_id;
        `INF.instr_rdata_id            = instr_rdata_id;
        `INF.clear_instr_valid         = clear_instr_valid;
        `INF.pc_set                    = pc_set;
        `INF.pc_mux_id                 = pc_mux_id;
        `INF.exc_pc_mux_id             = exc_pc_mux_id;
        `INF.trap_addr_mux             = trap_addr_mux;
        `INF.is_fetch_failed_id        = is_fetch_failed_id;
        `INF.pc_id                     = pc_id;
        `INF.halt_if                   = halt_if;
        `INF.instr_req_int             = instr_req_int;
        `INF.id_ready                  = id_ready;
        `INF.pc_if                     = pc_if; // This is the PC in IF stage, used for branch target calculation

        // ID to EX
        `INF.is_decoding               = is_decoding;
        `INF.branch_in_ex              = branch_in_ex;
        `INF.ctrl_transfer_insn_in_dec = ctrl_transfer_insn_in_dec;
        `INF.pc_ex                     = pc_ex;
        `INF.alu_en_ex                 = alu_en_ex;
        `INF.alu_operator_ex           = alu_operator_ex;
        `INF.alu_operand_a_ex          = alu_operand_a_ex;
        `INF.alu_operand_b_ex          = alu_operand_b_ex;
        `INF.alu_operand_c_ex          = alu_operand_c_ex;
        `INF.bmask_a_ex                = bmask_a_ex;
        `INF.bmask_b_ex                = bmask_b_ex;
        `INF.imm_vec_ext_ex            = imm_vec_ext_ex;
        `INF.alu_vec_mode_ex           = alu_vec_mode_ex;
        `INF.regfile_waddr_ex          = regfile_waddr_ex;
        `INF.regfile_we_ex             = regfile_we_ex;
        `INF.regfile_alu_waddr_ex      = regfile_alu_waddr_ex;
        `INF.regfile_alu_we_ex         = regfile_alu_we_ex;

        // Multiplier
        `INF.mult_operator_ex          = mult_operator_ex;
        `INF.mult_operand_a_ex         = mult_operand_a_ex;
        `INF.mult_operand_b_ex         = mult_operand_b_ex;
        `INF.mult_operand_c_ex         = mult_operand_c_ex;
        `INF.mult_en_ex                = mult_en_ex;
        `INF.mult_sel_subword_ex       = mult_sel_subword_ex;
        `INF.mult_signed_mode_ex       = mult_signed_mode_ex;
        //`INF.mult_imm_ex              = mult_imm_ex;
        //`INF.mult_dot_op_a_ex         = mult_dot_op_a_ex;
        //`INF.mult_dot_op_b_ex         = mult_dot_op_b_ex;
        //`INF.mult_dot_op_c_ex         = mult_dot_op_c_ex;
        //`INF.mult_dot_signed_ex       = mult_dot_signed_ex;
        //`INF.mult_is_clpx_ex          = mult_is_clpx_ex;
        //`INF.mult_clpx_shift_ex       = mult_clpx_shift_ex;
        `INF.mult_clpx_img_ex          = mult_clpx_img_ex;

        // Write-back
        `INF.regfile_waddr_fw_wb_o          = regfile_waddr_fw_wb_o;
        `INF.regfile_we_wb             = regfile_we_wb;
        //`INF.regfile_we_wb_power      = regfile_we_wb_power;
        `INF.regfile_wdata             = regfile_wdata;

        // Branch targets
        `INF.jump_target_id            = jump_target_id;
        `INF.jump_target_ex            = jump_target_ex;
        `INF.branch_decision           = branch_decision;

        // Handshake
        `INF.ex_ready                  = ex_ready;
        `INF.ex_valid                  = ex_valid;

        // Forwarding
        `INF.regfile_alu_waddr_fw      = regfile_alu_waddr_fw;
        `INF.regfile_alu_we_fw         = regfile_alu_we_fw;
        //`INF.regfile_alu_we_fw_power  = regfile_alu_we_fw_power;
        `INF.regfile_alu_wdata_fw      = regfile_alu_wdata_fw;
        `INF.regfile_waddr_fw_wb_o     = regfile_waddr_fw_wb_o;
    end

endmodule
