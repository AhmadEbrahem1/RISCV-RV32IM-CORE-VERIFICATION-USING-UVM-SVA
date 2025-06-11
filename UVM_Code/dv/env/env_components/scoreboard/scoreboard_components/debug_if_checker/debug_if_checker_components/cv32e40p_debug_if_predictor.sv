/******************************************************************
 * File: cv32e40p_debug_if_predictor.sv
 * Authors: Team 1:
            * Ziad Ahmed
            * Ahmed Khaled
            * Ahmed Ebrahem
            * Mohamed Mohsen
            * Esmail Abdelrahman
            * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2024
 * Description: This class defines a predictor for a RV32IM Core for datauction
 *              Decode Stage in a UVM testbench. It is responsible for recifving
 *              the input stimulus the RV32IM Core and providing expected outputs.  
 *
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/
`define rf cv32e40p_Regfile_config::regfile_mirror
class cv32e40p_debug_if_predictor extends uvm_component;

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
    uvm_analysis_export	#(cv32e40p_debug_sequence_item) inputs_ap;
    uvm_analysis_port	#(cv32e40p_debug_sequence_item) expected_outputs_ap;
	uvm_tlm_analysis_fifo #(cv32e40p_debug_sequence_item) inputs_fifo;

    // A signal to indicate that req happened
    local bit [1:0] req_count;

    // Queue to keep track of pending request elements
    local cv32e40p_data_memory_sequence_item req_queue [$];

    // Regfile config instance to get in
    cv32e40p_Regfile_config regfile_cfg; //regfile_cfg.regfile_mirror

    // The Written data from the last time a write operation was done
    local logic [31:0] last_wdata;

    // Register with factory
    `uvm_component_utils(cv32e40p_debug_if_predictor)

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

    if(!uvm_config_db#(cv32e40p_Regfile_config)::get(this, "", "regfile_cfg", regfile_cfg))
        `uvm_fatal(get_type_name(), "Failed to get RegFile Config")

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
            begin
                RST_n_fifo.get(rst_seq_item);
                req_count   = 0;
            end
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
        // Input transaction to Predict the output from
        cv32e40p_debug_sequence_item mon_in_tx;

        // Creating at each loop iteration to prevent overwriting
		mon_in_tx = cv32e40p_debug_sequence_item:: type_id :: create ("mon_in_tx");

        // Getting the Input transaction from the fifo
		inputs_fifo.get(mon_in_tx);
        `uvm_info(get_type_name(), $sformatf("Inputs Sampled \n %s", mon_in_tx.sprint()), UVM_MEDIUM)
        
        // Start debug_if Output Prediction task
        predict_debug_if(mon_in_tx);
	end
endtask

/*********************************************************************************************************
/ predict_debug_if : This task predicts the outputs of the debug_if and sends them to the comparator to be compared
**********************************************************************************************************/
task predict_debug_if(cv32e40p_debug_sequence_item t);
    if(t.debug_req_i) begin
        predict_debug(t);
    end
    else if(~t.debug_req_i) begin
        predict_no_debug(t);
    end
endtask : predict_debug_if

/*********************************************************************************************************/

// A task that predicts the debug outputs in debug mode
task predict_debug(cv32e40p_debug_sequence_item t);
    cv32e40p_debug_sequence_item expected_item;
    expected_item = cv32e40p_debug_sequence_item::type_id::create("expected_item");
    expected_item.debug_havereset_o = 0;
    expected_item.debug_halted_o = 1;
    expected_item.debug_running_o = 0;
    expected_outputs_ap.write(expected_item);
endtask : predict_debug

// A task that predicts the debug outputs in non debug mode
task predict_no_debug(cv32e40p_debug_sequence_item t);
    cv32e40p_debug_sequence_item expected_item;
    expected_item = cv32e40p_debug_sequence_item::type_id::create("expected_item");
    expected_item.debug_havereset_o = 0;
    expected_item.debug_halted_o = 0;
    expected_item.debug_running_o = 1;
    expected_outputs_ap.write(expected_item);
endtask : predict_no_debug

endclass : cv32e40p_debug_if_predictor