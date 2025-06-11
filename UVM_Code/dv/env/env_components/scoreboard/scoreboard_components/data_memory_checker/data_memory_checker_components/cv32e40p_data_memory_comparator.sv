/******************************************************************
 * File: cv32e40p_data_memory_comparator.sv
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
class cv32e40p_data_memory_comparator extends uvm_component;

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
    uvm_analysis_export	#(cv32e40p_data_memory_sequence_item) expected_outputs_ap, actual_outputs_ap;

	uvm_tlm_analysis_fifo #(cv32e40p_data_memory_sequence_item) expected_outputs_fifo;
    uvm_tlm_analysis_fifo #(cv32e40p_data_memory_sequence_item) actual_outputs_fifo;
	
    // Register with factory
    `uvm_component_utils_begin(cv32e40p_data_memory_comparator)
        `uvm_field_int(correct_counter, UVM_DEFAULT)
        `uvm_field_int(incorrect_counter, UVM_DEFAULT)
        `uvm_field_int(transaction_counter, UVM_DEFAULT)
    `uvm_component_utils_end

    // A signal to indicate that req happened
    local bit   [ 1:0] req_count;

    // A signal to retain the past value of data_rdata_i to check OBI correctly
    local logic [31:0] data_rdata_i;

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

	expected_outputs_fifo   = new("expected_outputs_fifo",this);
	actual_outputs_fifo     = new("actual_outputs_fifo",this);

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
            begin
                RST_n_fifo.get(rst_seq_item);
                req_count   = 0;
            end
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
	cv32e40p_data_memory_sequence_item   predictor_tx, mon_out_tx;
    // Get from predictor
    `uvm_info(get_type_name(),"Checking Started~", UVM_MEDIUM)
	forever begin
		expected_outputs_fifo.get(predictor_tx);
        `uvm_info(get_type_name(), $sformatf(" Expected Data :\n %s", predictor_tx.sprint), UVM_MEDIUM)
        check_req_count();
        // actual_outputs_fifo.flush();
        actual_outputs_fifo.get(mon_out_tx);
        `uvm_info(get_type_name(), $sformatf(" Actual Data :\n %s", mon_out_tx.sprint), UVM_MEDIUM)

        `uvm_info(get_type_name(), "check outputs task called", UVM_MEDIUM)
        check_outputs(predictor_tx, mon_out_tx);
end
endtask

                        /**********************************************************************************
************************** The following tasks check the validity of the driving according to OBI protocol ***********************
                        ***********************************************************************************/

/**********************************************************************************
/ check_outputs : Checks that data_rvalid_i is asserted @each valid data_rdata_i
***********************************************************************************/
task check_outputs(cv32e40p_data_memory_sequence_item expected_output_item, cv32e40p_data_memory_sequence_item actual_output_item);
    cv32e40p_data_memory_sequence_item actual_output, expected_output;
    actual_output       = cv32e40p_data_memory_sequence_item::type_id::create("actual_output");
    expected_output     = cv32e40p_data_memory_sequence_item::type_id::create("expected_output");
    expected_output.copy(expected_output_item);
    actual_output.copy(actual_output_item);
    if(expected_output.data_we_o) begin
        if(actual_output.data_rvalid_i == expected_output.data_rvalid_i) begin
            correct_counter++;
            `uvm_info(get_type_name(), "rvalid Check during WRITE Passed", UVM_MEDIUM)
        end
        else begin
            incorrect_counter++;
            `uvm_error(get_type_name(), "Check during WRITE Failed");
            `uvm_info(get_type_name(), $sformatf("actual output \n %s \n expected_output \n %s \n ", actual_output.sprint(), 
                                                  expected_output.sprint), UVM_MEDIUM)
        end
    end
    else begin   
        if(expected_output.data_rdata_i === actual_output.data_rdata_i && expected_output.data_rvalid_i === actual_output.data_rvalid_i) begin
            correct_counter++;
            `uvm_info(get_type_name(), "rvalid Check during READ Passed", UVM_MEDIUM)
        end
        else begin
            incorrect_counter++;
            `uvm_error(get_type_name(), "Check during READ Failed");
            `uvm_info(get_type_name(), $sformatf("actual output \n %s \n expected_output \n %s \n ", actual_output.sprint(),
                                                  expected_output.sprint), UVM_MEDIUM)
        end
        data_rdata_i = actual_output.data_rdata_i;
    end
endtask : check_outputs

/*****************************************************************************************
/ check_req_count : This task checks that the outstanding txn number does not pass 2 txns
******************************************************************************************/
task check_req_count();
    if(req_count > 2) begin
        `uvm_error(get_type_name(), "request count breaches the OBI protocol")
    end
endtask : check_req_count

endclass : cv32e40p_data_memory_comparator