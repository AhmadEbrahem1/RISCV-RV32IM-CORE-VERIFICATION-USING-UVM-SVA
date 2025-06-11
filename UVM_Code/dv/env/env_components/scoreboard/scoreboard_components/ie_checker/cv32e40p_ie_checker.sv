/******************************************************************
 * File: cv32e40p_ie_checker.sv
 * Authors: Team 1:
            * Ziad Ahmed
            * Ahmed Khaled
            * Ahmed Ebrahem
            * Mohamed Mohsen
            * Esmail Abdelrahman
            * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2024
 * Description: This class defines a scoreboard for a UVM testbench. 
 *              The scoreboard is responsible for managing the overall 
 *              comparison and monitoring of sequence items between 
 *              different components. It includes phases for building 
 *              and connecting the scoreboard with the predictor and 
 *              comparator components.
 * 
 * Copyright (c) [2024] [Team1]. All Rights Reserved.
 * This file is part of the Verification & Design of reconfigurable AMBA AHB LITE.
 **********************************************************************************/
class cv32e40p_ie_checker extends uvm_component;

  // Reference model and comparator instances
  cv32e40p_ie_predictor predictor_h;
  cv32e40p_ie_comparator comparator_h;

    /***************************************************
    / Declare TLM component for reset (Reset Awareness)
    ****************************************************/
    uvm_analysis_export   #(cv32e40p_rst_sequence_item) RST_n_ap;
    uvm_analysis_export   #(cv32e40p_rst_sequence_item) RST_p_ap;

    /*****************************************
    / TLM Connections for this Stage Monitor
    ******************************************/
    uvm_analysis_export   #(cv32e40p_ie_sequence_item) outputs_ap;
    uvm_analysis_export   #(cv32e40p_ie_sequence_item) inputs_ap;

    // Register with factory
    `uvm_component_utils(cv32e40p_ie_checker)

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

    // Create reference model and comparator
    predictor_h = cv32e40p_ie_predictor::type_id::create("predictor_h", this);
    comparator_h = cv32e40p_ie_comparator::type_id::create("comparator_h", this);

    // Create The needed TLM Analysis Exports for rst agent
    RST_n_ap = new("RST_n_ap",this);
    RST_p_ap = new("RST_p_ap",this);

    // Create TLM Connections for this Stage Monitor
    outputs_ap = new("outputs_ap", this);
    inputs_ap = new("inputs_ap", this);

endfunction : build_phase

/****************************************
/ Connect Phase : Has TLM Connections
******************************************/
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Connect Reset Awareness TLM Components to predictor and comparator 
    RST_n_ap.connect(predictor_h.RST_n_ap); 
    RST_p_ap.connect(predictor_h.RST_p_ap); 

    RST_n_ap.connect(comparator_h.RST_n_ap);
    RST_p_ap.connect(comparator_h.RST_p_ap);

    // Connect inputs to reference model
    inputs_ap.connect(predictor_h.inputs_ap);

    // Connect actual outputs to comparator
    outputs_ap.connect(comparator_h.actual_outputs_ap);

    // Connect reference model to comparator
    predictor_h.expected_outputs_ap.connect(comparator_h.expected_outputs_ap);
endfunction : connect_phase


/*************************************************************************************
/   Phase ready to end : a Test termination technique is deployed in this phase to 
/    make sure the test only ends when a certain event has happened
/*************************************************************************************/
//   function void phase_ready_to_end(uvm_phase phase);
//     if (phase.get_name() != "run") return;
//     if (~cv32e40p_ie_sequence_item::cov_target || ~rst_seq_item::resets_done) begin
//       phase.raise_objection(.obj(this)); 
//       fork 
//         begin 
//           delay_phase(phase);
//         end
//       join_none
//     end
//   endfunction

/****************************************************************************************
// Delay Phase: A task that stalls the test termination, is called by phase_ready_to_end
/***************************************************************************************/
//   task delay_phase(uvm_phase phase);
//     wait(alu_seq_item::cov_target && rst_seq_item::resets_done);
//     phase.drop_objection(.obj(this));
//   endtask

/***************************************************************************************************
// Final Phase: used to report when the scoreboard finishes its operation before the simulation ends
/***************************************************************************************************/
function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info(get_type_name(), "cv32e40p_ie_checker is stopping.", UVM_LOW)
endfunction : final_phase

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(), 
                $sformatf("\ncv32e40p_ie_checker Report:\n\tTotal Transactions: %0d\n\tTotal Correct Items: %0d\n\tTotal Incorrect Items: %0d", 
                        comparator_h.transaction_counter, comparator_h.correct_counter, comparator_h.incorrect_counter), UVM_MEDIUM)
    `uvm_info(get_type_name(), "cv32e40p_ie_checker Report Phase Complete", UVM_MEDIUM)
endfunction : report_phase


endclass : cv32e40p_ie_checker