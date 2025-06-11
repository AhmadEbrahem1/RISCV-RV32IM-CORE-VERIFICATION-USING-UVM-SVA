import cv32e40p_pkg::*;
class cv32e40p_ie_sequence_item extends base_sequence_item;


    // Declare the properties of the sequence item
	typedef enum logic [6:0] {

    ALU_ADD   = 7'b0011000,
    ALU_SUB   = 7'b0011001,
    ALU_ADDU  = 7'b0011010,
    ALU_SUBU  = 7'b0011011,
    ALU_ADDR  = 7'b0011100,
    ALU_SUBR  = 7'b0011101,
    ALU_ADDUR = 7'b0011110,
    ALU_SUBUR = 7'b0011111,

    ALU_XOR = 7'b0101111,
    ALU_OR  = 7'b0101110,
    ALU_AND = 7'b0010101,

    // Shifts
    ALU_SRA = 7'b0100100,
    ALU_SRL = 7'b0100101,
    ALU_ROR = 7'b0100110,
    ALU_SLL = 7'b0100111,

    // bit manipulation
    ALU_BEXT  = 7'b0101000,
    ALU_BEXTU = 7'b0101001,
    ALU_BINS  = 7'b0101010,
    ALU_BCLR  = 7'b0101011,
    ALU_BSET  = 7'b0101100,
    ALU_BREV  = 7'b1001001,

    // Bit counting
    ALU_FF1 = 7'b0110110,
    ALU_FL1 = 7'b0110111,
    ALU_CNT = 7'b0110100,
    ALU_CLB = 7'b0110101,

    // Sign-/zero-extensions
    ALU_EXTS = 7'b0111110,
    ALU_EXT  = 7'b0111111,

    // Comparisons
    ALU_LTS = 7'b0000000,
    ALU_LTU = 7'b0000001,
    ALU_LES = 7'b0000100,
    ALU_LEU = 7'b0000101,
    ALU_GTS = 7'b0001000,
    ALU_GTU = 7'b0001001,
    ALU_GES = 7'b0001010,
    ALU_GEU = 7'b0001011,
    ALU_EQ  = 7'b0001100,
    ALU_NE  = 7'b0001101,

    // Set Lower Than operations
    ALU_SLTS  = 7'b0000010,
    ALU_SLTU  = 7'b0000011,
    ALU_SLETS = 7'b0000110,
    ALU_SLETU = 7'b0000111,

    // Absolute value
    ALU_ABS   = 7'b0010100,
    ALU_CLIP  = 7'b0010110,
    ALU_CLIPU = 7'b0010111,

    // Insert/extract
    ALU_INS = 7'b0101101,

    // min/max
    ALU_MIN  = 7'b0010000,
    ALU_MINU = 7'b0010001,
    ALU_MAX  = 7'b0010010,
    ALU_MAXU = 7'b0010011,

    // div/rem
    ALU_DIVU = 7'b0110000,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    ALU_DIV  = 7'b0110001,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    ALU_REMU = 7'b0110010,  // bit 0 is used for signed mode, bit 1 is used for remdiv
    ALU_REM  = 7'b0110011,  // bit 0 is used for signed mode, bit 1 is used for remdiv

    ALU_SHUF  = 7'b0111010,
    ALU_SHUF2 = 7'b0111011,
    ALU_PCKLO = 7'b0111000,
    ALU_PCKHI = 7'b0111001

  } alu_opcode_e;



  typedef enum logic [2:0] {

    MUL_MAC32 = 3'b000,
    MUL_MSU32 = 3'b001,
    MUL_I     = 3'b010,
    MUL_IR    = 3'b011,
    MUL_DOT8  = 3'b100,
    MUL_DOT16 = 3'b101,
    MUL_H     = 3'b110

  } mul_opcode_e;
  
    // Declare the properties of the sequence item
	// Declare the properties of the sequence item
	// from interface 
	cv32e40p_pkg:: alu_opcode_e        alu_operator_ex;
	logic signed       [31:0] alu_operand_a_ex; 
	logic signed       [31:0] alu_operand_b_ex;
	logic signed       [31:0] alu_operand_c_ex;
	logic               alu_en_ex;
	
	cv32e40p_pkg::mul_opcode_e        mult_operator_ex;
	logic        [31:0] mult_operand_a_ex;
	logic        [31:0] mult_operand_b_ex;
	logic        [31:0] mult_operand_c_ex;
	logic               mult_en_ex;
	logic               mult_sel_subword_ex;
	logic        [ 1:0] mult_signed_mode_ex;
	logic        [ 4:0] mult_imm_ex;
	
	logic [31:0] mult_dot_op_a_ex;
	logic [31:0] mult_dot_op_b_ex;
	logic [31:0] mult_dot_op_c_ex; 
	logic [ 1:0] mult_dot_signed_ex;
	
	// outputs
	logic mult_multicycle;
	
	// Output of EX stage pipeline
	logic [ 5:0] regfile_waddr_fw_wb_o;
	logic        regfile_we_wb;
	logic        regfile_we_wb_power;
	logic signed [31:0] regfile_wdata;
	
	// Forwarding ports : to ID stage
	logic [ 5:0] regfile_alu_waddr_fw;
	logic        regfile_alu_we_fw;
	logic        regfile_alu_we_fw_power;
	logic signed [31:0] regfile_alu_wdata_fw;  // forward to RF and ID/EX pipe, ALU & MUL
	
	// To IF: Jump and branch target and decision
	logic [31:0] jump_target_ex;
	logic        branch_decision;
	
	logic ex_valid;  // EX stage gets new data
	
	
	// input from ID stage
    logic       branch_in_ex;
    logic [5:0] regfile_alu_waddr;
    logic       regfile_alu_we;

    // directly passed through to WB stage, not used in EX
    logic       regfile_we;
    logic [5:0] regfile_waddr;

    //Registering the class in factory& alongside its properties
    `uvm_object_utils_begin(cv32e40p_ie_sequence_item)

  `uvm_field_enum(cv32e40p_pkg::alu_opcode_e, alu_operator_ex, UVM_ALL_ON)
  `uvm_field_int(alu_operand_a_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(alu_operand_b_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(alu_operand_c_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(alu_en_ex, UVM_ALL_ON)

  `uvm_field_enum(cv32e40p_pkg::mul_opcode_e, mult_operator_ex, UVM_ALL_ON)
  `uvm_field_int(mult_operand_a_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(mult_operand_b_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(mult_operand_c_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(mult_en_ex, UVM_ALL_ON)
  `uvm_field_int(mult_sel_subword_ex, UVM_ALL_ON)
  `uvm_field_int(mult_signed_mode_ex, UVM_ALL_ON)
  `uvm_field_int(mult_imm_ex, UVM_ALL_ON)

  `uvm_field_int(mult_dot_op_a_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(mult_dot_op_b_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(mult_dot_op_c_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(mult_dot_signed_ex, UVM_ALL_ON)

  `uvm_field_int(mult_multicycle, UVM_ALL_ON)

  `uvm_field_int(regfile_waddr_fw_wb_o, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(regfile_we_wb, UVM_ALL_ON)
  `uvm_field_int(regfile_we_wb_power, UVM_ALL_ON)
  `uvm_field_int(regfile_wdata, UVM_ALL_ON | UVM_HEX)

  `uvm_field_int(regfile_alu_waddr_fw, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(regfile_alu_we_fw, UVM_ALL_ON)
  `uvm_field_int(regfile_alu_we_fw_power, UVM_ALL_ON)
  `uvm_field_int(regfile_alu_wdata_fw, UVM_ALL_ON | UVM_HEX)

  `uvm_field_int(jump_target_ex, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(branch_decision, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(ex_valid, UVM_ALL_ON)

  `uvm_field_int(branch_in_ex, UVM_ALL_ON)
  `uvm_field_int(regfile_alu_waddr, UVM_ALL_ON | UVM_HEX)
  `uvm_field_int(regfile_alu_we, UVM_ALL_ON)
  `uvm_field_int(regfile_we, UVM_ALL_ON)
  `uvm_field_int(regfile_waddr, UVM_ALL_ON | UVM_HEX)

`uvm_object_utils_end


endclass : cv32e40p_ie_sequence_item