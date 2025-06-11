/******************************************************************
 * File: cv32e40p_ie_comparator.sv
 * Authors: Team 1:
            * Ziad Ahmed
            * Ahmed Khaled
            * Ahmed Ebrahem
            * Mohamed Mohsen
            * Esmail Abdelrahman
            * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2024
 * Description: This class defines a UVM comparator component used
 *              to compare sequence items and report results.
 *
 * Copyright (c) [2024] [Team1]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/
class cv32e40p_ie_comparator extends uvm_component;


    // Counters for matches and mismatches
    int correct_counter;
    int incorrect_counter;
    int transaction_counter;

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
    uvm_analysis_export	#(cv32e40p_ie_sequence_item) expected_outputs_ap, actual_outputs_ap;

	uvm_tlm_analysis_fifo #(cv32e40p_ie_sequence_item) expected_outputs_fifo;
    uvm_tlm_analysis_fifo #(cv32e40p_ie_sequence_item) actual_outputs_fifo;
	
    // Register with factory
    `uvm_component_utils_begin(cv32e40p_ie_comparator)
    `uvm_field_int(correct_counter, UVM_DEFAULT)
    `uvm_field_int(incorrect_counter, UVM_DEFAULT)
    `uvm_field_int(transaction_counter, UVM_DEFAULT)
    `uvm_component_utils_end

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
    expected_outputs_ap   = new("expected_outputs_ap", this);
    actual_outputs_ap     = new("actual_outputs_ap", this);

	expected_outputs_fifo = new("expected_outputs_fifo",this);
	actual_outputs_fifo = new("actual_outputs_fifo",this);
 
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
	
	expected_outputs_ap.connect(expected_outputs_fifo.analysis_export);

	actual_outputs_ap.connect(actual_outputs_fifo.analysis_export);

endfunction: connect_phase

/***********************************************************************************************************
/ Main phase : Marks the start of the simulation and the beggining of the reading from monitors & predictors
************************************************************************************************************/
task main_phase(uvm_phase phase);
    cv32e40p_rst_sequence_item rst_seq_item;
    `uvm_info(get_type_name(), "Main phase", UVM_MEDIUM) 
    forever begin
        fork
            RST_n_fifo.get(rst_seq_item);
            start_checking();    
        join_any
        disable fork;
        RST_p_fifo.get(rst_seq_item);
	end
endtask : main_phase

/*****************************************************************
/ start_checking : Checks expected outputs against actual outputs
******************************************************************/
task start_checking();
	cv32e40p_ie_sequence_item	predictor_tx,mon_out_tx	;
	alu_opcode_e	ALU_OP;	
	mul_opcode_e	MUL_OP;
	forever begin
		// Get from predictor
        `uvm_info(get_type_name(),"Start Checking Started!",UVM_MEDIUM) 
		expected_outputs_fifo.get(predictor_tx);
        //`uvm_info(get_type_name(), $sformatf("predictor data :\n %s", predictor_tx.sprint), UVM_LOW)
        actual_outputs_fifo.get(mon_out_tx);
        //`uvm_info(get_type_name(), $sformatf("actual  data :\n %s", mon_out_tx.sprint), UVM_LOW)
		if(predictor_tx.alu_en_ex) begin
			ALU_OP = predictor_tx.alu_operator_ex;
			if (ALU_OP ==ALU_LTS || ALU_OP == ALU_LTU || ALU_OP ==  ALU_LES || ALU_OP ==  ALU_LEU ||ALU_OP == ALU_GTS 
                || ALU_OP == ALU_GTU || ALU_OP ==  ALU_GES || ALU_OP ==  ALU_GEU || ALU_OP ==  ALU_EQ 
                || ALU_OP ==  ALU_NE && (mon_out_tx.jump_target_ex ==  predictor_tx.jump_target_ex) ) begin
                    if(mon_out_tx.branch_decision==  predictor_tx.branch_decision) begin
                        correct_counter++;
                        `uvm_info(get_type_name(),"TEST PASSED",UVM_LOW)
                    end
				    else begin
                        incorrect_counter++;
						`uvm_error(get_type_name(), $sformatf(" Branch decision mismatch, opcode = %s  expected = %0d , actual = %0d",ALU_OP,predictor_tx.regfile_alu_wdata_fw,mon_out_tx.regfile_alu_wdata_fw))
                    end
            end
		    else begin
				if(mon_out_tx.regfile_alu_wdata_fw ==  predictor_tx.regfile_alu_wdata_fw) begin
				    correct_counter++;
                    `uvm_info(get_type_name(),"TEST PASSED",UVM_LOW)
                end
				else begin
                    incorrect_counter++;                
					`uvm_error(get_type_name(), $sformatf(" ALU write data mismatch!, opcode = %s  expected = %0d , actual = %0d",ALU_OP,predictor_tx.regfile_alu_wdata_fw,mon_out_tx.regfile_alu_wdata_fw))
                end
		    end
			/*
			if(mon_out_tx.jump_target_ex ==  predictor_tx.jump_target_ex) begin
				    correct_counter++;
                    `uvm_info(get_type_name(),"TEST PASSED",UVM_LOW)
			end
			else begin
                incorrect_counter++;
				`uvm_fatal(get_type_name(), $sformatf(" jump_target_ex write data mismatch!, opcode = %s  expected = %0d , actual = %0d",ALU_OP,predictor_tx.regfile_alu_wdata_fw,mon_out_tx.regfile_alu_wdata_fw))
            end
			*/
        end
		else if(predictor_tx.mult_en_ex) begin
			MUL_OP = predictor_tx.mult_operator_ex;
			if(mon_out_tx.regfile_alu_wdata_fw ==  predictor_tx.regfile_alu_wdata_fw) begin
				correct_counter++;
                `uvm_info(get_type_name(),"TEST PASSED",UVM_LOW)
            end
			else begin
                incorrect_counter++;
				`uvm_error(get_type_name(), $sformatf(" MULTIPLY write data mismatch!, opcode = %s  expected = %0d , actual = %0d",MUL_OP,predictor_tx.regfile_alu_wdata_fw,mon_out_tx.regfile_alu_wdata_fw))
            end
		end
	end
endtask

endclass : cv32e40p_ie_comparator
