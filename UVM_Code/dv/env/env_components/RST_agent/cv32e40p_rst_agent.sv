/******************************************************************
 * File: cv32e40p_rst_agent.sv
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
class cv32e40p_rst_agent extends uvm_agent;

    //Registering the cv32e40p_rst_agent class in the factory
    `uvm_component_utils(cv32e40p_rst_agent)

    //Reset Interface Virtual Interface Handle
    virtual cv32e40p_rst_if rst_vif;

    //Configuration objects for all the agents
    cv32e40p_rst_agent_config rst_agt_cfg; //active

    //TLM Connections between RST Agent & all other Agents (Reset Awareness)
    uvm_analysis_port#(cv32e40p_rst_sequence_item) RST_p_ap;
    uvm_analysis_port#(cv32e40p_rst_sequence_item) RST_n_ap;

    //Agent Components Instances
    cv32e40p_rst_driver cv32e40p_rst_drv;
    cv32e40p_rst_monitor cv32e40p_rst_mntr;
    cv32e40p_rst_sequencer cv32e40p_rst_sqr;

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name, uvm_component parent);
    super.new(name, parent);
endfunction

/*********************************************************
/ Build Phase : Has Creators, Getters & possible overrides
**********************************************************/
function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

    //Get config from db
    if(!(uvm_config_db#(cv32e40p_rst_agent_config)::get(this,"", "cv32e40p_rst_agt_cfg", rst_agt_cfg)))
        `uvm_fatal(get_type_name(), "Failed to get config")

    //Using RST agent Configuration to parametaraise the agent
    this.is_active = rst_agt_cfg.get_is_active();

    //Recieve reset interface virtual handles
    rst_vif = rst_agt_cfg.hand_interface_handle();
    
    //Create sequence items

    //Create TLM ports
    RST_p_ap = new("RST_p_ap", this);
    RST_n_ap = new("RST_n_ap", this);

    //Create RST agent components
    cv32e40p_rst_mntr = cv32e40p_rst_monitor::type_id::create("cv32e40p_rst_mntr", this);
    
    if(get_is_active() == UVM_ACTIVE) begin
        cv32e40p_rst_drv  = cv32e40p_rst_driver::type_id::create("cv32e40p_rst_drv", this);
        cv32e40p_rst_sqr     = cv32e40p_rst_sequencer::type_id::create("cv32e40p_rst_sqr", this);
    end

    //Setters
    uvm_config_db#(virtual cv32e40p_rst_if)::set(this, "cv32e40p_rst_drv", "rst_vif", rst_vif);
    uvm_config_db#(virtual cv32e40p_rst_if)::set(this, "cv32e40p_rst_mntr" , "rst_vif", rst_vif); 

endfunction : build_phase

/****************************************
/ Connect Phase : Has TLM Connections
******************************************/
function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM)

    //TLM Connection between Sequencer & Driver
    if(get_is_active() == UVM_ACTIVE) begin
        cv32e40p_rst_drv.seq_item_port.connect(cv32e40p_rst_sqr.seq_item_export);
    end
    
    //TLM connections between RST monitor & RST agent
    cv32e40p_rst_mntr.RST_p_ap.connect(RST_p_ap);
    cv32e40p_rst_mntr.RST_n_ap.connect(RST_n_ap);

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

endclass : cv32e40p_rst_agent