/******************************************************************
 * File: cv32e40p_id_predictor.sv
 * Authors: Team Verification
 * Email: verification@example.com
 * Date: 15/05/2024
 * Description: This class defines a predictor for the CV32E40P RV32IM
 *              core's ID stage in a UVM testbench. It handles both
 *              register file predictions and ALU/MUL operations.
 *
 * Copyright (c) [2024] [Verification Team]. All Rights Reserved.
 * This file is part of the CV32E40P Verification Project.
 ******************************************************************/
class cv32e40p_id_predictor extends uvm_component;
    // Register with factory
    `uvm_component_utils(cv32e40p_id_predictor)

    /***************************************************
    / Declare TLM component for reset (Reset Awareness)
    ****************************************************/
    uvm_analysis_export   #(cv32e40p_rst_sequence_item) RST_n_ap;
    uvm_analysis_export   #(cv32e40p_rst_sequence_item) RST_p_ap;

    /*********************************************************
    / Declare TLM Analysis FIFOs for reset (Reset Awareness)
    **********************************************************/
    uvm_tlm_analysis_fifo #(cv32e40p_rst_sequence_item) RST_n_fifo;
    uvm_tlm_analysis_fifo #(cv32e40p_rst_sequence_item) RST_p_fifo;

    /*****************************************
    / TLM Connections for ID Stage Monitor
    ******************************************/
    uvm_analysis_export   #(cv32e40p_id_sequence_item) inputs_ap;
    uvm_analysis_port     #(cv32e40p_id_sequence_item) rf_pred_ap;
    uvm_analysis_port     #(cv32e40p_id_sequence_item) alu_pred_ap;

    uvm_tlm_analysis_fifo #(cv32e40p_id_sequence_item) inputs_fifo;


    /*******************************************************************************
    / Constructor : is responsible for the construction of objects and components
    *******************************************************************************/
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    /*********************************************************
    / Build Phase : Has Creators, Getters & possible overrides
    **********************************************************/
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create The needed TLM Analysis Exports for rst agent
        RST_n_ap = new("RST_n_ap", this);
        RST_p_ap = new("RST_p_ap", this);
        
        // Create rst FIFOs
        RST_n_fifo = new("RST_n_fifo", this);
        RST_p_fifo = new("RST_p_fifo", this);
        
        // Create TLM Connections for this Stage Monitor
        inputs_ap   = new("inputs_ap", this);
        rf_pred_ap  = new("rf_pred_ap", this);
        alu_pred_ap = new("alu_pred_ap", this);
        inputs_fifo = new("inputs_fifo", this);
    endfunction: build_phase

    /****************************************
    / Connect Phase : Has TLM Connections
    ******************************************/
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect exports to FIFOs
        RST_n_ap.connect(RST_n_fifo.analysis_export);
        RST_p_ap.connect(RST_p_fifo.analysis_export);
        inputs_ap.connect(inputs_fifo.analysis_export);
    endfunction: connect_phase

    /****************************************************************************************************
    / Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
    *****************************************************************************************************/
    task main_phase(uvm_phase phase);
        cv32e40p_rst_sequence_item rst_seq_item;
        forever begin
            fork
                RST_n_fifo.get(rst_seq_item);
                predict_outputs();    
            join_any
            disable fork;
            RST_p_ap.get(rst_seq_item);
        end
    endtask : main_phase

    /*****************************************************************
    / predict_outputs : Generates predicted values for RF and ALU/MUL
    ******************************************************************/
    task predict_outputs();
        cv32e40p_id_sequence_item in_tx, rf_tx;
        forever begin
            inputs_fifo.get(in_tx);
            
            // Create predicted transactions
            rf_tx = cv32e40p_id_sequence_item::type_id::create("rf_tx");
            
            // Copy input transaction
            rf_tx.copy(in_tx);
            
            // Predict Register File Operands
            predict_Operands_values(rf_tx);
            
            // Send predictions
            rf_pred_ap.write(rf_tx);
        end
    endtask

    /*****************************************************************
    / predict_Operands_values : Predicts register file read values
    ******************************************************************/
function void predict_Operands_values(ref cv32e40p_id_sequence_item tx);

  typedef enum logic [6:0] {
    OPCODE_LUI       = 7'b0110111,  // U-type
    OPCODE_AUIPC     = 7'b0010111,  // U-type
    OPCODE_JAL       = 7'b1101111,  // J-type
    OPCODE_JALR      = 7'b1100111,  // I-type
    OPCODE_BRANCH    = 7'b1100011,  // B-type
    OPCODE_LOAD      = 7'b0000011,  // I-type
    OPCODE_STORE     = 7'b0100011,  // S-type
    OPCODE_IMM       = 7'b0010011,  // I-type 
    OPCODE_OP        = 7'b0110011   // R-type 
  } opcode_e;

  logic [2: 0] funct3;
  logic [6: 0] funct7;
  logic [31:0] instr = tx.instr_rdata_i; 
  string op_str;

  opcode_e opcode ;
  if (!$cast(opcode, instr[6:0]))
    `uvm_error("ID_PREDICTOR", $sformatf("Invalid opcode: 0x%0h", instr[6:0]))  

  case (opcode)

    // ========================
    // R-type: ADD, SUB, etc.
    // ========================
    OPCODE_OP: begin
      tx.regfile_alu_waddr_ex_o = instr[11:7];  // Destination
      funct3                    = instr[14:12];
      tx.alu_operand_a_ex_o     = instr[19:15];  // rs1
      tx.alu_operand_b_ex_o     = instr[24:20];  // rs2
      funct7                    = instr[31:25];

      // Decode R-type and M-extension operations
      case ({funct7, funct3})
        10'b0000000000: op_str = "add";
        10'b0100000000: op_str = "sub";
        10'b0000000111: op_str = "and";
        10'b0000000110: op_str = "or";
        10'b0000000100: op_str = "xor";
        10'b0000000001: op_str = "sll";
        10'b0000000101: op_str = "srl";
        10'b0100000101: op_str = "sra";
        10'b0000000010: op_str = "slt";
        10'b0000000011: op_str = "sltu";

        // RV32M Multiply/Divide
        10'b0000001000: op_str = "mul";
        10'b0000001001: op_str = "mulh";
        10'b0000001010: op_str = "mulhsu";
        10'b0000001011: op_str = "mulhu";
        10'b0000001100: op_str = "div";
        10'b0000001101: op_str = "divu";
        10'b0000001110: op_str = "rem";
        10'b0000001111: op_str = "remu";

        default:        op_str = "unknown_rtype";
      endcase


      `uvm_info("DECODE", $sformatf("R-type: rd=x%0d, rs1=x%0d, rs2=x%0d, op=%s",
                                     tx.regfile_alu_waddr_ex_o, tx.alu_operand_a_ex_o, tx.alu_operand_b_ex_o,
                                     op_str), UVM_LOW)

    end

    // ========================
    // I-type: ADDI, LW, etc.
    // ========================
    OPCODE_IMM,
    OPCODE_LOAD,
    OPCODE_JALR: begin
      tx.regfile_alu_waddr_ex_o = instr[11:7];  // Destination
      funct3                    = instr[14:12];
      tx.alu_operand_a_ex_o     = instr[19:15];  // rs1

      if (instr[31] == 1'b0)
        tx.alu_operand_b_ex_o = {20'h00000, instr[31:20]};
      else
        tx.alu_operand_b_ex_o = {20'hfffff, instr[31:20]};

      // Decode I-type operation
      if (opcode == OPCODE_IMM) begin
        case (funct3)
          3'b000: op_str = "addi";
          3'b010: op_str = "slti";
          3'b011: op_str = "sltiu";
          3'b100: op_str = "xori";
          3'b110: op_str = "ori";
          3'b111: op_str = "andi";
          3'b001: op_str = "slli";
          3'b101: op_str = (instr[31:25] == 7'b0100000) ? "srai" : "srli";
          default: op_str = "unknown_itype";
        endcase
      end else if (opcode == OPCODE_LOAD) begin
        case (funct3)
          3'b000: op_str = "lb";
          3'b001: op_str = "lh";
          3'b010: op_str = "lw";
          3'b100: op_str = "lbu";
          3'b101: op_str = "lhu";
          default: op_str = "unknown_load";
        endcase
      end else if (opcode == OPCODE_JALR) begin
        op_str = "jalr";
      end
      if(op_str == "addi" ) `uvm_info("DECODE", $sformatf("I-type: rd=x%0d, rs1=x%0d, imm=%0d, op=%s",
                                     tx.regfile_alu_waddr_ex_o, tx.alu_operand_a_ex_o,
                                     tx.alu_operand_b_ex_o, op_str), UVM_LOW)
      else                               
      `uvm_info("DECODE", $sformatf("I-type: rd=x%0d, rs1=x%0d, imm=%0h, op=%s",
                                     tx.regfile_alu_waddr_ex_o, tx.alu_operand_a_ex_o,
                                     tx.alu_operand_b_ex_o, op_str), UVM_LOW)                               
    end

    // ========================
    // S-type: SW, SH, SB
    // ========================
    OPCODE_STORE: begin
      funct3                = instr[14:12];
      tx.alu_operand_a_ex_o = instr[19:15];
      tx.alu_operand_c_ex_o = instr[24:20];
      if (instr[31] == 1'b0)
        tx.alu_operand_b_ex_o = {20'h00000, instr[31:25], instr[11:7]};
      else
        tx.alu_operand_b_ex_o = {20'hfffff, instr[31:25], instr[11:7]};

      case (funct3)
        3'b000: op_str = "sb";
        3'b001: op_str = "sh";
        3'b010: op_str = "sw";
        default: op_str = "unknown_store";
      endcase

      `uvm_info("DECODE", $sformatf("S-type: rd=x%0d, rs2=x%0d, imm=%0d, op=%s",
                                     tx.alu_operand_a_ex_o, tx.alu_operand_c_ex_o,
                                     tx.alu_operand_b_ex_o, op_str), UVM_LOW)
    end

    // ========================
    // B-type: BEQ, BNE, etc.
    // ========================
    OPCODE_BRANCH: begin
      funct3 = instr[14:12];
      tx.alu_operand_a_ex_o = instr[19:15];
      tx.alu_operand_b_ex_o = instr[24:20];

      // Immediate construction (simplified - should be sign-extended)
      if (instr[31] == 1'b0)
        tx.alu_operand_c_ex_o = {20'h00000, instr[31], instr[7], instr[30:25], instr[11:8]};
      else
        tx.alu_operand_c_ex_o = {20'hfffff, instr[31], instr[7], instr[30:25], instr[11:8]};

      case (funct3)
        3'b000: op_str = "beq";
        3'b001: op_str = "bne";
        3'b100: op_str = "blt";
        3'b101: op_str = "bge";
        3'b110: op_str = "bltu";
        3'b111: op_str = "bgeu";
        default: op_str = "unknown_branch";
      endcase

      `uvm_info("DECODE", $sformatf("B-type: rs1=x%0d, rs2=x%0d, imm=%0d, op=%s",
                                     tx.alu_operand_a_ex_o, tx.alu_operand_b_ex_o,
                                     tx.alu_operand_c_ex_o, op_str), UVM_LOW)
    end

    // ========================
    // U-type: LUI, AUIPC
    // ========================
    OPCODE_LUI,
    OPCODE_AUIPC: begin
      tx.regfile_alu_waddr_ex_o = instr[11:7];
      tx.alu_operand_b_ex_o     = {instr[31:12], 12'b0};
      op_str                    = (opcode == OPCODE_LUI) ? "lui" : "auipc";

      `uvm_info("DECODE", $sformatf("U-type: rd=x%0d, imm=%0h, op=%s",
                                     tx.regfile_alu_waddr_ex_o,
                                     tx.alu_operand_b_ex_o, op_str), UVM_LOW)
    end

    // ========================
    // J-type: JAL
    // ========================
    OPCODE_JAL: begin
      tx.regfile_alu_waddr_ex_o = instr[11:7];
      if (instr[31] == 1'b0)
        tx.alu_operand_b_ex_o = {12'h000, instr[31], instr[19:12], instr[20], instr[30:21]};
      else
        tx.alu_operand_b_ex_o = {12'hfff, instr[31], instr[19:12], instr[20], instr[30:21]};
      op_str = "jal";

      `uvm_info("DECODE", $sformatf("J-type: rd=x%0d, imm=%0h, op=%s",
                                     tx.regfile_alu_waddr_ex_o,
                                     tx.alu_operand_b_ex_o, op_str), UVM_LOW)
    end

    default: begin
      op_str = "unknown";
      `uvm_warning("DECODE", $sformatf("Unknown opcode: 0x%0h", opcode))
    end
  endcase
endfunction



    /*****************************************************************************
    / Report phase : reports the results of the data associated with the component
    ******************************************************************************/
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "ID Stage Predictor Report Phase Complete", UVM_LOW)
    endfunction : report_phase
endclass : cv32e40p_id_predictor


