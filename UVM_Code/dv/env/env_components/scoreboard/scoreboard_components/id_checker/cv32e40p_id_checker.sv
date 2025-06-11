/******************************************************************
 * File: cv32e40p_id_checker.sv
 * Authors: Team Verification
 * Email: verification@example.com
 * Date: 15/05/2024
 * Description: This class defines the top-level checker for the
 *              CV32E40P RV32IM core's ID stage, integrating both
 *              the predictor and comparator components.
 *
 * Copyright (c) [2024] [Verification Team]. All Rights Reserved.
 * This file is part of the CV32E40P Verification Project.
 ******************************************************************/
class cv32e40p_id_checker extends uvm_component;
    // Register with factory
    `uvm_component_utils(cv32e40p_id_checker)

    // Component instances
    cv32e40p_id_predictor  predictor_h;
    cv32e40p_id_comparator comparator_h;

    /***************************************************
    / Declare TLM component for reset (Reset Awareness)
    ****************************************************/
    uvm_analysis_export   #(cv32e40p_rst_sequence_item) RST_n_ap;
    uvm_analysis_export   #(cv32e40p_rst_sequence_item) RST_p_ap;

    /*****************************************
    / TLM Connections for this Stage Monitor
    ******************************************/
    uvm_analysis_export   #(cv32e40p_id_sequence_item) inputs_ap;
    uvm_analysis_export   #(cv32e40p_id_sequence_item) outputs_ap;

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

        // Create predictor and comparator
        predictor_h = cv32e40p_id_predictor::type_id::create("predictor_h", this);
        comparator_h = cv32e40p_id_comparator::type_id::create("comparator_h", this);

        // Create The needed TLM Analysis Exports for rst agent
        RST_n_ap = new("RST_n_ap", this);
        RST_p_ap = new("RST_p_ap", this);

        // Create TLM Connections for this Stage Monitor
        inputs_ap = new("inputs_ap", this);
        outputs_ap = new("outputs_ap", this);
    endfunction : build_phase

    /****************************************
    / Connect Phase : Has TLM Connections
    ******************************************/
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        // Connect Reset Awareness TLM Components
        RST_n_ap.connect(predictor_h.RST_n_ap);
        RST_p_ap.connect(predictor_h.RST_p_ap);
        RST_n_ap.connect(comparator_h.RST_n_ap);
        RST_p_ap.connect(comparator_h.RST_p_ap);

        // Connect inputs to predictor
        inputs_ap.connect(predictor_h.inputs_ap);

        // Connect predictor outputs to comparator
        predictor_h.rf_pred_ap.connect(comparator_h.rf_pred_ap);

        // Connect actual outputs to comparator
        outputs_ap.connect(comparator_h.outputs_ap);
    endfunction : connect_phase

    /*****************************************************************************
    / Report phase : reports the results of the data associated with the component
    ******************************************************************************/
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "ID Stage Checker Report Phase Complete", UVM_MEDIUM)
    endfunction : report_phase
endclass : cv32e40p_id_checker