/******************************************************************
 * File: cv32e40p_if_comparator.sv
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
class cv32e40p_if_comparator extends uvm_component;

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
    uvm_analysis_export	#(cv32e40p_if_sequence_item) expected_outputs_ap, actual_outputs_ap;

	uvm_tlm_analysis_fifo #(cv32e40p_if_sequence_item) expected_outputs_fifo;
    uvm_tlm_analysis_fifo #(cv32e40p_if_sequence_item) actual_outputs_fifo;
	
    // Register with factory
    `uvm_component_utils_begin(cv32e40p_if_comparator)
        `uvm_field_int(correct_counter, UVM_DEFAULT)
        `uvm_field_int(incorrect_counter, UVM_DEFAULT)
        `uvm_field_int(transaction_counter, UVM_DEFAULT)
    `uvm_component_utils_end

    // A signal to indicate that fetch enable finished its pulse
    local bit fetch_flag;

    // A signal to indicate that req happened
    local bit   [ 1:0] req_count;

    // Handle for the comparer component
    uvm_comparer comparer_h;

    // A signal to retain the past value of instr_rdata_i to check OBI correctly
    local logic [31:0] instr_rdata_i;

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
                fetch_flag  = 0;
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
	cv32e40p_if_sequence_item   predictor_tx, mon_out_tx;
    // Get from predictor
    `uvm_info(get_type_name(),"Checking Started~", UVM_LOW)
	forever begin
		expected_outputs_fifo.get(predictor_tx);
        `uvm_info(get_type_name(), $sformatf(" Expected Data :\n %s", predictor_tx.sprint), UVM_MEDIUM)
        // check_req_count();
        if(~fetch_flag) begin
            actual_outputs_fifo.flush();
            $display("Flushed Elged3an: %0t", $time);
        end
        actual_outputs_fifo.get(mon_out_tx);
        `uvm_info(get_type_name(), $sformatf(" Actual Data :\n %s", mon_out_tx.sprint), UVM_LOW)

        
        check_fetch_error(mon_out_tx);
        if(~fetch_flag) begin
            `uvm_info(get_type_name(), "check fetch task called", UVM_MEDIUM)
            check_fetch(mon_out_tx);
        end
        else begin
            `uvm_info(get_type_name(), "compare outputs task called", UVM_MEDIUM)
            compare_outputs(predictor_tx, mon_out_tx);
        end
	end
endtask : start_checking

/******************************************************************************************************
/ compare_outputs : Compares & Reports the result of the comparison between expected & actual outputs
*******************************************************************************************************/
task compare_outputs(input cv32e40p_if_sequence_item expected_output, actual_output);

    // Compare the actual and expected sequence items
    if (actual_output.compare(expected_output, comparer_h)) begin
        correct_counter++;
        `uvm_info(get_type_name(), "PASS", UVM_MEDIUM)
    end
    else begin
        incorrect_counter++;
        `uvm_error(get_type_name(), "FAIL")
        `uvm_info(get_type_name(), $sformatf(" FAIL: Actual output \n %s \n Expected output \n %s \n ", actual_output.sprint(),
                                                expected_output.sprint), UVM_LOW)
    end
endtask : compare_outputs

                        /**********************************************************************************
********************************** The following tasks check the validity of fetch_enable_i **********************************
                        ***********************************************************************************/

/**************************************************************************************
/ check_fetch : Checks that fetch is de-asserted after being asserted with 1 clk cycle
***************************************************************************************/
task check_fetch(cv32e40p_if_sequence_item t);
    if(t.fetch_enable_i == 0) begin
        `uvm_info(get_type_name(), "Fetch Check Passed", UVM_LOW)
        correct_counter++;
        fetch_flag = 1;
    end
    else begin
        incorrect_counter++;
        `uvm_error(get_type_name(), "Fetch Check Failed");
    end
endtask

/******************************************************************************************************************
/ check_fetch_error : This task checks only a single fetch_enable_i pulse happens after each reset during run_time
*******************************************************************************************************************/
task check_fetch_error(cv32e40p_if_sequence_item t);
    if(fetch_flag && t.fetch_enable_i) begin
        `uvm_error(get_type_name(), "A Second Fetch Pulse Detected during run time & not after reset")
    end
endtask : check_fetch_error

// /*****************************************************************************************
// / check_req_count : This task checks that the outstanding txn number does not pass 2 txns
// ******************************************************************************************/
// task check_req_count();
//     if(req_count > 2) begin
//         `uvm_error(get_type_name(), "request count breaches the OBI protocol")
//     end
// endtask : check_req_count

endclass : cv32e40p_if_comparator