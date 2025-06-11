/******************************************************************
 * File: cv32e40p_id_comparator.sv
 * Authors: Team Verification
 * Email: verification@example.com
 * Date: 15/05/2024
 * Description: This class defines a comparator for the CV32E40P RV32IM
 *              core's ID stage in a UVM testbench. It verifies both
 *              register file accesses and ALU/MUL operations.
 *
 * Copyright (c) [2024] [Verification Team]. All Rights Reserved.
 * This file is part of the CV32E40P Verification Project.
 ******************************************************************/
`define rf cv32e40p_Regfile_config::regfile_mirror
class cv32e40p_id_comparator extends uvm_component;
    // Register with factory
    `uvm_component_utils(cv32e40p_id_comparator)

    // Counters for matches and mismatches
    int rf_correct_count;
    int rf_incorrect_count;
    int alu_correct_count;
    int alu_incorrect_count;
    int mul_correct_count;
    int mul_incorrect_count;
    cv32e40p_Regfile_config regfile_cfg;
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
    opcode_e opcode;

    typedef enum logic [6:0] {
        FUNCT7_STD_OP    = 7'b0000000,  // Standard operations
        FUNCT7_STD_OP1   = 7'b0100000,  // sub and sra
        FUNCT7_M_EXT     = 7'b0000001   // M-extension operations
    } funct7_e;

    funct7_e funct7;
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
    / TLM Connections for this Stage Monitor
    ******************************************/
    uvm_analysis_export   #(cv32e40p_id_sequence_item) rf_pred_ap;
    uvm_analysis_export   #(cv32e40p_id_sequence_item) outputs_ap;

    uvm_tlm_analysis_fifo #(cv32e40p_id_sequence_item) rf_pred_fifo;
    uvm_tlm_analysis_fifo #(cv32e40p_id_sequence_item) actual_fifo;

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
        rf_pred_ap = new("rf_pred_ap", this);
        outputs_ap = new("outputs_ap", this);
        
        rf_pred_fifo = new("rf_pred_fifo", this);
        actual_fifo = new("actual_fifo", this);

        if (! uvm_config_db#(cv32e40p_Regfile_config)::get(this, "", "regfile_cfg", regfile_cfg) )
            `uvm_fatal(get_type_name(), "regfile_mirror not found")
            
    endfunction: build_phase

    /****************************************
    / Connect Phase : Has TLM Connections
    ******************************************/
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect exports to FIFOs
        RST_n_ap.connect(RST_n_fifo.analysis_export);
        RST_p_ap.connect(RST_p_fifo.analysis_export);
        rf_pred_ap.connect(rf_pred_fifo.analysis_export);
        outputs_ap.connect(actual_fifo.analysis_export);
        
    endfunction: connect_phase

    /****************************************************************************************************
    / Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
    *****************************************************************************************************/
    task main_phase(uvm_phase phase);
        cv32e40p_rst_sequence_item rst_seq_item;
        forever begin
            fork
                RST_n_fifo.get(rst_seq_item);
                start_checking();    
            join_any
            disable fork;
            RST_p_ap.get(rst_seq_item);
        end
    endtask : main_phase

    /*****************************************************************
    / start_checking : Compares predicted and actual values
    ******************************************************************/
    task start_checking();
        cv32e40p_id_sequence_item rf_pred, actual;
        forever begin
            // Get transactions from FIFOs
            rf_pred_fifo.get(rf_pred);
            store_rf_values(rf_pred);

            // Check Register File accesses
            actual_fifo.get(actual);
            check_rf_values(actual,rf_pred);
            
        end
    endtask

    function void store_rf_values(cv32e40p_id_sequence_item rf_pred);

        logic [31:0] instruction = rf_pred.instr_rdata_i;
        logic [31:0] pc          = rf_pred.pc_id_i;
        longint signed mul_result;

        // Decode instruction fields
        logic [6:0] opcode = instruction[6 : 0];
        logic [4:0] rd     = instruction[11: 7];
        logic [4:0] rs1    = instruction[19:15];
        logic [4:0] rs2    = instruction[24:20];
        logic [2:0] funct3 = instruction[14:12];
        logic [6:0] funct7 = instruction[31:25];
        
        // Immediate extraction
        logic [31:0] imm_i = {{20{instruction[31]}}, instruction[31:20]};
        logic [31:0] imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
        logic [31:0] imm_b = {{19{instruction[31]}}, instruction[31], instruction[7], 
                               instruction[30:25], instruction[11:8], 1'b0};
        logic [31:0] imm_u = {instruction[31:12], 12'b0};
        logic [31:0] imm_j = {{11{instruction[31]}}, instruction[31], instruction[19:12], 
                               instruction[20], instruction[30:21], 1'b0};
        
        // Only update if destination is not x0
        if (rd != 0 || opcode == OPCODE_BRANCH || opcode == OPCODE_STORE ) begin
            case (opcode)
                // LUI (U-type)
                OPCODE_LUI: `rf[rd] = imm_u;
                
                // AUIPC (U-type)
                OPCODE_AUIPC: `rf[rd] = pc + imm_u;
                
                // JAL (J-type)
                OPCODE_JAL: `rf[rd] = pc + 4;
                
                // JALR (I-type)
                OPCODE_JALR: `rf[rd] = pc + 4;
                
                // Arithmetic I-type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
                OPCODE_IMM : begin
                    case (funct3)
                        3'b000: `rf[rd] = `rf[rs1] + $signed(imm_i);  // ADDI
                        3'b010: `rf[rd] = `rf[rs1] < $signed(imm_i);  // SLTI
                        3'b011: `rf[rd] = $unsigned(`rf[rs1]) < $unsigned(imm_i);  // SLTIU
                        3'b100: `rf[rd] = `rf[rs1] ^ $signed(imm_i);  // XORI
                        3'b110: `rf[rd] = `rf[rs1] | $signed(imm_i);  // ORI
                        3'b111: `rf[rd] = `rf[rs1] & $signed(imm_i);  // ANDI
                        3'b001: `rf[rd] = `rf[rs1] << $signed(imm_i[4:0]);  // SLLI
                        3'b101: begin
                            if (funct7[5] == 1'b0)
                                `rf[rd] = `rf[rs1] >> $signed(imm_i[4:0]);  // SRLI
                            else
                                `rf[rd] = `rf[rs1] >>> $signed(imm_i[4:0]);  // SRAI
                        end
                    endcase
                end
                
                // R-type operations
                OPCODE_BRANCH,
                OPCODE_STORE
                : begin
                    `uvm_info(get_type_name(),"This is a store or a branch operation which doesn't required to write to the RegFile",UVM_MEDIUM)
                end

                // R-type operations
                OPCODE_OP: begin
                    case (funct7)
                        FUNCT7_STD_OP,
                        FUNCT7_STD_OP1: begin
                            case (funct3)
                                3'b000: begin
                                if (funct7[5] == 1'b0)
                                    `rf[rd] = `rf[rs1] + `rf[rs2];  // ADD
                                else
                                    `rf[rd] = `rf[rs1] - `rf[rs2];  // SUB
                                end
                                3'b001: `rf[rd] = `rf[rs1] << `rf[rs2][4:0];  // SLL
                                3'b010: `rf[rd] = $signed(`rf[rs1]) < $signed(`rf[rs2]);  // SLT
                                3'b011: `rf[rd] = $unsigned(`rf[rs1]) < $unsigned(`rf[rs2]);  // SLTU
                                3'b100: `rf[rd] = `rf[rs1] ^ `rf[rs2];  // XOR
                                3'b101: begin
                                if (funct7[5] == 1'b0)
                                    `rf[rd] = `rf[rs1] >> `rf[rs2][4:0];  // SRL
                                else
                                    `rf[rd] = $signed(`rf[rs1]) >>> `rf[rs2][4:0];  // SRA
                                end
                                3'b110: `rf[rd] = `rf[rs1] | `rf[rs2];  // OR
                                3'b111: `rf[rd] = `rf[rs1] & `rf[rs2];  // AND
                            endcase
                       end
                        FUNCT7_M_EXT: begin
                            case (funct3)
                                // ===== MUL/DIV Extension (RISC-V M) =====
                                // MUL (signed × signed, lower 32 bits)
                                3'b000: begin
                                        `rf[rd] = `rf[rs1] * `rf[rs2];  // MUL
                                end
                                // MULH (signed × signed, upper 32 bits)
                                3'b001: begin
                                    mul_result = (longint'(`rf[rs1]) * longint'(`rf[rs2]));
                                    `rf[rd] =  mul_result [63:32];  // MULH
                                end
                                // MULHSU (signed × unsigned, upper 32 bits)
                                3'b010: begin
                                    mul_result = (longint'(`rf[rs1]) * longint'(unsigned'(`rf[rs2])));
                                    `rf[rd] =  mul_result [63:32];  // MULHSU
                                end
                                // MULHU (unsigned × unsigned, upper 32 bits)
                                3'b011: begin
                                    mul_result = (longint'(unsigned'(`rf[rs1])) * longint'(unsigned'(`rf[rs2])));
                                    `rf[rd] = mul_result [63:32];  // MULHU
                                end
                                // DIV (signed division)
                                3'b100: begin
                                        if (`rf[rs2] == 0) begin
                                           `uvm_warning(get_type_name(),"You are trying to divide by zero")
                                           `rf[rd] = 32'hFFFFFFFF;
                                        end
                                        else if (`rf[rs1] == 32'h80000000 && `rf[rd] == 32'hFFFFFFFF)
                                            `rf[rd] = 32'h80000000;  // Overflow case
                                        else
                                            `rf[rd] = `rf[rs1] / `rf[rs2];  // DIV
                                end
                                // DIVU (unsigned division)
                                3'b101: begin
                                        if (`rf[rs2] == 0) begin
                                            `uvm_warning(get_type_name(),"You are trying to divide by zero")
                                            `rf[rd] = 32'hFFFFFFFF;
                                        end
                                        else
                                            `rf[rd] = $unsigned(`rf[rs1]) / $unsigned(`rf[rs2]);  // DIVU
                                end
                                // REM (signed remainder)
                                // REM (signed remainder)
								3'b110: begin
									if (`rf[rs2] == 0) begin
										`uvm_warning(get_type_name(),"You are trying to get remainder of zero — divide by zero")
										`rf[rd] = `rf[rs1];
									end
									else if (`rf[rs1] == 32'h80000000 && `rf[rs2] == 32'hFFFFFFFF) begin
										`rf[rd] = 0;  // Special case: signed overflow
									end
									else begin
										`rf[rd] = `rf[rs1] % `rf[rs2];  // REM
									end
								end

                                // REMU (unsigned remainder)
                                3'b111: begin
                                        if (`rf[rs2] == 0) begin
                                            `uvm_warning(get_type_name(),"You are trying to get reminder of zero that means trying to divide by zero")
                                            `rf[rd] = `rf[rs1];  
                                        end
                                        else
                                            `rf[rd] = $unsigned(`rf[rs1]) % $unsigned(`rf[rs2]);  // REMU
                                end
                            endcase
                        end
                        default: `uvm_warning(get_type_name(),"NO VALID funct7")
                    endcase
                end
                // Default case - do nothing
                OPCODE_LOAD : `uvm_info(get_type_name(),"This is A load Operation which not getting anything due to no data memory!",UVM_MEDIUM)
                default: begin
                    `uvm_warning(get_type_name(),"NO VALID OPCODE OR MAYBE THE OPCODE DOESN'T REQUIRED TO CHECK REGFILE")
                end
            endcase
        end else `uvm_warning(get_type_name(),"You are trying to write to destination 'x0' which ins't allowed")

        `uvm_info(get_type_name(),$sformatf("[%0t] The Memory is : %0p", $time ,`rf),UVM_HIGH)
    endfunction

    /*****************************************************************
    / check_rf_values : Verifies register file read values
    ******************************************************************/
    function void check_rf_values(cv32e40p_id_sequence_item actual,rf_pred);
        if(actual.regfile_alu_we_fw_i == 1'b1) begin
            if (`rf[actual.regfile_alu_waddr_fw_i] == actual.regfile_alu_wdata_fw_i) begin
                `uvm_info(get_type_name(),$sformatf("The Regfile will write 0x%0h in the address x%0d which Matches the Data Predicted in the Mirror Regfile which is %0d",
                actual.regfile_alu_wdata_fw_i,
                actual.regfile_alu_waddr_fw_i,
                `rf[actual.regfile_alu_waddr_fw_i]),
                UVM_LOW)

            end else begin
                    if(actual.regfile_alu_waddr_fw_i == 0) 
                        `uvm_info(get_type_name(),"Writing in x0 isn't allowed",UVM_LOW)
                        else
                `uvm_error(get_type_name(),$sformatf("The Regfile will write 0x%0h in the address x%0d but the data predicted in the address x%0d is 0x%0h which mismatches",
                    actual.regfile_alu_wdata_fw_i,
                    actual.regfile_alu_waddr_fw_i,
                    actual.regfile_alu_waddr_fw_i,
                    `rf[actual.regfile_alu_waddr_fw_i]))
            end
        end else begin
            if (`rf[rf_pred.alu_operand_a_ex_o] == actual.alu_operand_a_ex_o && `rf[rf_pred.alu_operand_c_ex_o] == actual.alu_operand_c_ex_o) begin
                `uvm_info(get_type_name(),$sformatf("The Regfile will read 0x%0h from the address x%0d and the value of address x%0d as base address which Matches the Data Predicted in the Mirror Regfile",
                actual.alu_operand_a_ex_o,
                rf_pred.alu_operand_a_ex_o,
                rf_pred.alu_operand_c_ex_o
                ),
                UVM_LOW)

            end else `uvm_error(get_type_name(),$sformatf("The Regfile will read 0x%0h from the address x%0d and the value of address x%0d as base address which misMatches the Data Predicted in the Mirror Regfile",
                     actual.alu_operand_a_ex_o,
                     rf_pred.alu_operand_a_ex_o,
                     rf_pred.alu_operand_c_ex_o
                     ))
        end
    endfunction


    /*****************************************************************************
    / Report phase : reports the results of the data associated with the component
    ******************************************************************************/
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), 
            $sformatf("\nID Stage Comparator Report:\n" +
                     "Register File Checks:\n\tCorrect: %0d\n\tIncorrect: %0d\n" +
                     "ALU Checks:\n\tCorrect: %0d\n\tIncorrect: %0d\n" +
                     "MUL Checks:\n\tCorrect: %0d\n\tIncorrect: %0d",
                     rf_correct_count, rf_incorrect_count,
                     alu_correct_count, alu_incorrect_count,
                     mul_correct_count, mul_incorrect_count), UVM_MEDIUM)
    endfunction : report_phase
endclass : cv32e40p_id_comparator

