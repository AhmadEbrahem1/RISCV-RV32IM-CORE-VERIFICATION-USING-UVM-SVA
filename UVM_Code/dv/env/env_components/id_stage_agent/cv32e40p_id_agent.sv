/******************************************************************
 * File: cv32e40p_id_agent.sv
 * Authors: Team 1:
            * Ziad Ahmed
            * Ahmed Khaled
            * Ahmed Ebrahem
            * Mohamed Mohsen
            * Esmail Abdelrahman
            * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2025
 * Description: This class extends `uvm_agent` to create a passive
 *              agent in the UVM testbench. The agent is responsible
 *              for sequencing and driving stimulus, as well as monitoring
 *              outputs. It configures and connects its components 
 *              based on its active/passive state.
 *
 * Copyright (c) [2024] [Team 1]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/
class cv32e40p_id_agent extends uvm_agent;

    //Registering the agent class in the factory
    `uvm_component_utils(cv32e40p_id_agent)

    //Reset Interface Virtual Interface Handle
    virtual cv32e40p_internal_if          vif;
    
    //Configuration objects for all the agents
    cv32e40p_id_agent_config   cv32e40p_id_agt_cfg;  //passive

    //TLM Connections between RST Agent & all other Agents (Reset Awareness)
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_p_ap;
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_n_ap;

    //TLM Connections between IF Agent & The Environment
    uvm_analysis_port #(cv32e40p_id_sequence_item) id_stage_ap_in;
    uvm_analysis_port #(cv32e40p_id_sequence_item) id_stage_ap_out;
    
    //Agent Components Instances
    // cv32e40p_id_sequencer          cv32e40p_id_sqr;
    // cv32e40p_id_driver             cv32e40p_id_drv;  
    cv32e40p_id_monitor            cv32e40p_id_mntr; 

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "cv32e40p_id_agent", uvm_component parent);
    super.new(name, parent);
endfunction

/*********************************************************
/ Build Phase : Has Creators, Getters & possible overrides
**********************************************************/
function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

    //Get config from db
    if(!uvm_config_db#(cv32e40p_id_agent_config)::get(this,"","cv32e40p_id_agt_cfg", cv32e40p_id_agt_cfg))
        `uvm_fatal(get_type_name(), "Failed to get config")

    //Using the agent's Configuration to parametaraise the agent
    this.is_active = cv32e40p_id_agt_cfg.get_is_active();

    //Recieve reset interface virtual handles
    vif = cv32e40p_id_agt_cfg.hand_interface_handle();

    //Create TLM ports between RST Agent & This Agent
    RST_p_ap = new("RST_p_ap", this);
    RST_n_ap = new("RST_n_ap", this);

    //Create TLM ports between This Agent & Enviornment
    id_stage_ap_in = new("id_stage_ap_in", this);
    id_stage_ap_out = new("id_stage_ap_out", this);

    //Create RST agent components
    cv32e40p_id_mntr  = cv32e40p_id_monitor::type_id::create("cv32e40p_id_mntr", this);
    
    if(get_is_active() == UVM_ACTIVE) begin
        // cv32e40p_id_drv  = cv32e40p_id_driver   ::type_id::create("cv32e40p_id_drv", this);
        // cv32e40p_id_sqr  = cv32e40p_id_sequencer::type_id::create("cv32e40p_id_sqr", this);
        // uvm_config_db#(virtual cv32e40p_internal_if)::set(this, "cv32e40p_id_drv", "vif", vif);
    end

    //Setters
    uvm_config_db#(virtual cv32e40p_internal_if)::set(this, "cv32e40p_id_mntr", "vif", vif);

endfunction

/********************************************
/ Connect Phase : Has TLM Connections
*********************************************/
function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);

    `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM) 

    //TLM Connection between Sequencer & Driver
    if(get_is_active() == UVM_ACTIVE) begin
        // cv32e40p_id_drv.seq_item_port.connect(cv32e40p_id_sqr.seq_item_export);
        // RST_p_ap.connect(cv32e40p_id_drv.RST_p_ap);
        // RST_n_ap.connect(cv32e40p_id_drv.RST_n_ap);
        // RST_n_ap.connect(cv32e40p_id_sqr.RST_imp);
    end

    //TLM connections between RST agent & IF agent (Reset Awareness)
    RST_p_ap.connect(cv32e40p_id_mntr.RST_p_ap);
    RST_n_ap.connect(cv32e40p_id_mntr.RST_n_ap);

    //TLM connections between IF Monitors & The Environment
    cv32e40p_id_mntr.id_stage_ap_in.connect(id_stage_ap_in);
    cv32e40p_id_mntr.id_stage_ap_out.connect(id_stage_ap_out);

endfunction : connect_phase

/*****************************************************************************************************************
/ End of Elaboration Phase : Has minor adjustments 
/ to the hierarchy before starting he run: TLM debugging
******************************************************************************************************************/
function void end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(), "End of elaboration phase", UVM_MEDIUM)  

    //TLM debuging

endfunction : end_of_elaboration_phase

// task main_phase(uvm_phase phase);
//     super.main_phase(phase);
//     `uvm_info(get_type_name(), "Main phase inside cv32e40p_id_agent", UVM_MEDIUM)
// endtask

endclass: cv32e40p_id_agent
