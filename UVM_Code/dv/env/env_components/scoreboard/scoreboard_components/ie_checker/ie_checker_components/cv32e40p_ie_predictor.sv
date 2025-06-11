/******************************************************************
 * File: cv32e40p_ie_predictor.sv
 * Authors: Team 1:
            * Ziad Ahmed
            * Ahmed Khaled
            * Ahmed Ebrahem
            * Mohamed Mohsen
            * Esmail Abdelrahman
            * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2024
 * Description: This class defines a predictor for a RV32IM Core for Instruction
 *              Decode Stage in a UVM testbench. It is responsible for recieving
 *              the input stimulus the RV32IM Core and providing expected outputs.  
 *
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/
class cv32e40p_ie_predictor extends uvm_component ;

    /***************************************************
    / Declare TLM component for reset (Reset Awareness)
    ****************************************************/
    uvm_analysis_export   #(cv32e40p_rst_sequence_item) RST_n_ap;
    uvm_analysis_export   #(cv32e40p_rst_sequence_item) RST_p_ap;

    /*********************************************************
    / Declare TLM Analaysis FIFOs for reset (Reset Awareness)
    **********************************************************/
    uvm_tlm_analysis_fifo #(cv32e40p_rst_sequence_item) RST_n_fifo;
    uvm_tlm_analysis_fifo #(cv32e40p_rst_sequence_item) RST_p_fifo;

    /*****************************************
    / TLM Connections for this Stage Monitor
    ******************************************/
    uvm_analysis_export	#(cv32e40p_ie_sequence_item) inputs_ap;
    uvm_analysis_port	#(cv32e40p_ie_sequence_item) expected_outputs_ap;

	uvm_tlm_analysis_fifo #(cv32e40p_ie_sequence_item) inputs_fifo;
	
	cv32e40p_ie_sequence_item	mon_in_tx	;
	cv32e40p_ie_sequence_item	expected_out_tx	;
	logic signed [31:0] expected_result,A,B,C;
	longint mul_result;
	
    // Register with factory
    `uvm_component_utils(cv32e40p_ie_predictor)

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name, uvm_component parent);
    super.new(name, parent);
endfunction : new

/*********************************************************
/ Build Phase : Has Creators, Getters & possible overrides
**********************************************************/
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

    // Create The needed TLM Analysis Exports for rst agent
    RST_n_ap = new("RST_n_ap",this);
    RST_p_ap = new("RST_p_ap",this);
	
	// Create rst FIFOs
    RST_n_fifo = new("RST_n_fifo",this);
    RST_p_fifo = new("RST_p_fifo",this);
	
    // Create TLM Connections for this Stage Monitor
    inputs_ap               = new("inputs_ap", this);
    expected_outputs_ap     = new("expected_outputs_ap", this);
	inputs_fifo             = new("inputs_fifo", this);

endfunction: build_phase

/****************************************
/ Connect Phase : Has TLM Connections
******************************************/
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM)

    // Connect exports to FIFOs
    RST_n_ap.connect(RST_n_fifo.analysis_export);
    RST_p_ap.connect(RST_p_fifo.analysis_export);
	inputs_ap.connect(inputs_fifo.analysis_export);
endfunction: connect_phase

/**********************************************************************************************
/ Main phase : Marks the start of the simulation and the beggining of the reading from monitors
***********************************************************************************************/
task main_phase(uvm_phase phase);
    cv32e40p_rst_sequence_item rst_seq_item;
    `uvm_info(get_type_name(), "Main phase", UVM_MEDIUM)	
    forever begin 
    fork
		RST_n_fifo.get(rst_seq_item);
        predict_outputs();    
    join_any
    disable fork;
    RST_p_fifo.get(rst_seq_item);
	end
endtask : main_phase

/*********************************************************************************************************
/ predict_outputs : This task gets the sequence item from the fifo and then startes the prediction logic
/                   and after that writes to the comparator the expected result
**********************************************************************************************************/
task predict_outputs();
	forever begin
		mon_in_tx = cv32e40p_ie_sequence_item:: type_id :: create ("mon_in_tx");
		expected_out_tx = cv32e40p_ie_sequence_item:: type_id :: create ("expected_out_tx");
		inputs_fifo.get(mon_in_tx);
		this.get_expected();
		expected_outputs_ap.write(expected_out_tx);
	end
endtask

/***************************************************************
/ get_expected : This task has the prediction logic of the ALU
****************************************************************/
task get_expected();
	expected_out_tx.copy(mon_in_tx);
	//check ALU 
	if(mon_in_tx.alu_en_ex) begin
	//ALU_checking 
		A	=	mon_in_tx.alu_operand_a_ex;
		B	=	mon_in_tx.alu_operand_b_ex;
		C	=	mon_in_tx.alu_operand_c_ex;
        case(expected_out_tx.alu_operator_ex)
            ALU_ADD:    expected_out_tx.regfile_alu_wdata_fw  = $signed(A) + $signed(B);
            ALU_ADDU:   expected_out_tx.regfile_alu_wdata_fw  = $unsigned(A) + $unsigned(B);
            ALU_ADDR:   expected_out_tx.regfile_alu_wdata_fw  = $signed(B) + $signed(A);
            ALU_ADDUR:  expected_out_tx.regfile_alu_wdata_fw  = $unsigned(B) + $unsigned(A);
            ALU_SUB:    expected_out_tx.regfile_alu_wdata_fw  = $signed(A) - $signed(B);
            ALU_SUBU:   expected_out_tx.regfile_alu_wdata_fw  = $unsigned(A) - $unsigned(B);
            ALU_SUBR:   expected_result = $signed(B) - $signed(A);
            ALU_SUBUR:  expected_out_tx.regfile_alu_wdata_fw  = $unsigned(B) - $unsigned(A);
           
            ALU_XOR:    expected_out_tx.regfile_alu_wdata_fw  = A ^ B;
            ALU_OR:     expected_out_tx.regfile_alu_wdata_fw  = A | B;
            ALU_AND:    expected_out_tx.regfile_alu_wdata_fw  = A & B;
	
		// Shifts
        	ALU_SRA: expected_out_tx.regfile_alu_wdata_fw = $signed(A) >>> B[4:0];
        	ALU_SRL: expected_out_tx.regfile_alu_wdata_fw = A >> B[4:0];
        	ALU_SLL: expected_out_tx.regfile_alu_wdata_fw = A << B[4:0];
        	ALU_ROR: expected_out_tx.regfile_alu_wdata_fw = (A >> B[4:0]) | (A << (32 - B[4:0]));

        	// Sign- and Zero-Extension (assuming 16-bit to 32-bit extension as an example)
        	ALU_EXTS: expected_out_tx.regfile_alu_wdata_fw = {{16{A[15]}}, A[15:0]};  // Sign-extend lower 16 bits
        	ALU_EXT:  expected_out_tx.regfile_alu_wdata_fw = {16'd0, A[15:0]};        // Zero-extend lower 16 bits
	
            ALU_LTS:    expected_out_tx.branch_decision = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            ALU_LTU:    expected_out_tx.branch_decision = ($unsigned(A) < $unsigned(B)) ? 32'd1 : 32'd0;
            ALU_LES:    expected_out_tx.branch_decision = ($signed(A) <= $signed(B)) ? 32'd1 : 32'd0;
            ALU_LEU:    expected_out_tx.branch_decision = ($unsigned(A) <= $unsigned(B)) ? 32'd1 : 32'd0;
            ALU_GTS:    expected_out_tx.branch_decision = ($signed(A) > $signed(B)) ? 32'd1 : 32'd0;
            ALU_GTU:    expected_out_tx.branch_decision = ($unsigned(A) > $unsigned(B)) ? 32'd1 : 32'd0;
            ALU_GES:    expected_out_tx.branch_decision = ($signed(A) >= $signed(B)) ? 32'd1 : 32'd0;
            ALU_GEU:    expected_out_tx.branch_decision = ($unsigned(A) >= $unsigned(B)) ? 32'd1 : 32'd0;
            ALU_EQ:     expected_out_tx.branch_decision = ($unsigned(A) == $unsigned(B)) ? 32'd1 : 32'd0;
            ALU_NE:     expected_out_tx.branch_decision = ($unsigned(A) != $unsigned(B)) ? 32'd1 : 32'd0;
            // ---- Set Lower Than operations ----
            ALU_SLTS:   expected_out_tx.regfile_alu_wdata_fw = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            ALU_SLTU:   expected_out_tx.regfile_alu_wdata_fw = ($unsigned(A) < $unsigned(B)) ? 32'd1 : 32'd0;
            ALU_SLETS:  expected_out_tx.regfile_alu_wdata_fw = ($signed(A) <= $signed(B)) ? 32'd1 : 32'd0;
            ALU_SLETU:  expected_out_tx.regfile_alu_wdata_fw = ($unsigned(A) <= $unsigned(B)) ? 32'd1 : 32'd0;
            ALU_DIV: begin
            // Signed division, rounding toward zero
                if (A == 0) begin
                    expected_out_tx.regfile_alu_wdata_fw = 32'hFFFFFFFF;  // RISC-V spec: result is all 1s if divide by 0
                end
                else if ((B == 'h8000_0000) && (A == -1)) begin
                    expected_out_tx.regfile_alu_wdata_fw = B ; // overflow case
                end
                else begin
                    expected_out_tx.regfile_alu_wdata_fw = $signed(B) / $signed(A);
                end
            end

            ALU_DIVU: begin
                // Unsigned division
                if (A == 0) begin
                    expected_out_tx.regfile_alu_wdata_fw = 32'hFFFFFFFF;
                end
                else begin
                    expected_out_tx.regfile_alu_wdata_fw = $unsigned(B) / $unsigned(A);
                end
            end
            
            ALU_REM: begin
                // Signed remainder, sign matches dividend
                if (A == 0) begin
                    expected_out_tx.regfile_alu_wdata_fw = B;
                end
                else if ((B == 'h8000_0000) && (A == -1)) begin
                    expected_out_tx.regfile_alu_wdata_fw = 0;
                end
                else begin
                    expected_out_tx.regfile_alu_wdata_fw = $signed(B) % $signed(A);
                end
            end
            
            ALU_REMU: begin
                // Unsigned remainder
                if (A == 0) begin
                    expected_out_tx.regfile_alu_wdata_fw = $unsigned(B);
                end
                else begin
                    expected_out_tx.regfile_alu_wdata_fw = $unsigned(B) % $unsigned(A);
                end
            end
            
            default: begin
                `uvm_warning("ALU_MON", $sformatf("Unhandled ALU opcode: %0s", mon_in_tx.alu_operator_ex))
                expected_result = 32'h00000000; // Indicate undefined/unsupported op
            end
        endcase

        expected_out_tx.jump_target_ex =  C ;	
	`uvm_info(get_type_name(), $sformatf("Ex opcode  = %s  A =%d ,B = %d  , result =%d",expected_out_tx.alu_operator_ex ,A,B,expected_out_tx.regfile_alu_wdata_fw),UVM_LOW)
	end
	else if(mon_in_tx.mult_en_ex) begin
		A	=	mon_in_tx.mult_operand_a_ex;
		B	=	mon_in_tx.mult_operand_b_ex;
		C	=	mon_in_tx.mult_operand_c_ex;
		// MUL checking
		case (expected_out_tx.mult_operator_ex)
            MUL_MAC32: begin
                mul_result = A * B ; // Mul
                expected_result = mul_result[31:0];     // LSB result (or your spec)
            end
            MUL_H: begin
                case (mon_in_tx.mult_signed_mode_ex)
                    2'b00: begin //mulhu
                        mul_result = longint'(unsigned'(A)) * longint'(unsigned'(B));
                        expected_result = mul_result[63:32];
                    end
                    2'b01: begin  //Mulhsu Operation
                        mul_result = longint'(A) * longint'(unsigned'(B));
                        expected_result = mul_result[63:32];
                    end
                    2'b11: begin  //Mulhs
                        mul_result = longint'(A) * longint'(B);
                        expected_result = mul_result[63:32];
                    end 
                endcase
            end
            default: begin
                expected_result = 32'hDEADBEEF; // or trigger error
            end
		endcase
		expected_out_tx.regfile_alu_wdata_fw = expected_result;
		`uvm_info(get_type_name(), $sformatf("Ex opcode  = %s  A =%d ,B = %d  , result =%d",expected_out_tx.mult_operator_ex ,A,B,expected_out_tx.regfile_alu_wdata_fw),UVM_LOW)
	end	
endtask

endclass : cv32e40p_ie_predictor
