/******************************************************************
 * File: cv32e40p_env.sv
 * Authors: Team 1:
            * Ziad Ahmed
            * Ahmed Khaled
            * Ahmed Ebrahem
            * Mohamed Mohsen
            * Esmail Abdelrahman
            * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2025
 * Description: This class defines a UVM environment component which
 *              coordinates the different agents, scoreboard, and
 *              coverage components in the testbench. It handles
 *              their configuration, connection, and lifecycle phases.
 * 
 * Copyright (c) [2024] [Team 1]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/
class cv32e40p_env extends uvm_env;

    //Registering the cv32e40p_env class in the factory
    `uvm_component_utils(cv32e40p_env)

    //Configuration object for the environment
    cv32e40p_env_config env_cfg;
    
    //Configuration objects for all the agents
    cv32e40p_rst_agent_config             cv32e40p_rst_agt_cfg;             // Active Agent
    cv32e40p_if_agent_config              cv32e40p_if_agt_cfg;              // Active Agent
    cv32e40p_id_agent_config              cv32e40p_id_agt_cfg;              // Passive Agent
    cv32e40p_ie_agent_config              cv32e40p_ie_agt_cfg;              // Passive Agent
    cv32e40p_data_memory_if_agent_config  cv32e40p_data_memory_if_agt_cfg;  // Reactive Agent
    cv32e40p_interrupt_if_agent_config    cv32e40p_interrupt_if_agt_cfg;    // Active Agent
    cv32e40p_debug_if_agent_config        cv32e40p_debug_if_agt_cfg;        // Active Agent

    // Agents Instances
    cv32e40p_rst_agent              cv32e40p_rst_agt;
    cv32e40p_if_agent               cv32e40p_if_agt;
    cv32e40p_id_agent               cv32e40p_id_agt;
    cv32e40p_ie_agent               cv32e40p_ie_agt;
    cv32e40p_data_memory_if_agent   cv32e40p_data_memory_if_agt;
    cv32e40p_interrupt_if_agent     cv32e40p_interrupt_if_agt;
    cv32e40p_debug_if_agent         cv32e40p_debug_if_agt;

    // Scoreboard & Subscriber Instances 
    scoreboard          scoreboard_h;
    subscriber          subscriber_h;

    //Virtual Sequencer Handle
    virtual_sequencer v_sqr;

    //TLM Connections between RST Agent & all other Agents (Reset Awareness)
    uvm_analysis_port#(cv32e40p_rst_sequence_item) RST_p_ap;
    uvm_analysis_port#(cv32e40p_rst_sequence_item) RST_n_ap;

    //TLM Connections for all agents' Input Monitors
    uvm_analysis_port#(cv32e40p_if_sequence_item) if_stage_ap_in;
    uvm_analysis_port#(cv32e40p_id_sequence_item) id_stage_ap_in;
    uvm_analysis_port#(cv32e40p_ie_sequence_item) ie_stage_ap_in;
    uvm_analysis_port#(cv32e40p_data_memory_sequence_item) data_memory_ap_in;
    uvm_analysis_port#(cv32e40p_interrupt_sequence_item) isr_if_ap_in;
    uvm_analysis_port#(cv32e40p_debug_sequence_item) dbg_if_ap_in;

    //TLM Connections for all agents' Output Monitors
    uvm_analysis_port#(cv32e40p_if_sequence_item) if_stage_ap_out;
    uvm_analysis_port#(cv32e40p_id_sequence_item) id_stage_ap_out;
    uvm_analysis_port#(cv32e40p_ie_sequence_item) ie_stage_ap_out;
    uvm_analysis_port#(cv32e40p_data_memory_sequence_item) data_memory_ap_out;
    uvm_analysis_port#(cv32e40p_data_memory_sequence_item) lsu_ap_out;
    uvm_analysis_port#(cv32e40p_interrupt_sequence_item) isr_if_ap_out;
    uvm_analysis_port#(cv32e40p_debug_sequence_item) dbg_if_ap_out;
    
    

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
    `uvm_info(get_type_name(), "Build phase", UVM_LOW)

    //get config from db
    if(!(uvm_config_db#(cv32e40p_env_config)::get(this, "", "env_cfg", env_cfg)))
        `uvm_fatal(get_type_name(), "Failed to get config")

    if (env_cfg.cv32e40p_internal_vif == null) $fatal("cv32e40p_internal_vif not set inside env!");
    if (env_cfg.cv32e40p_instruction_memory_vif == null) $fatal("cv32e40p_instruction_memory_vif not set inside env!");    

    //Create sequence items

    //Create TLM ports
    RST_p_ap = new("RST_p_ap", this);
    RST_n_ap = new("RST_n_ap", this);

    if_stage_ap_in     = new("if_stage_ap_in", this);
    id_stage_ap_in     = new("id_stage_ap_in", this);
    ie_stage_ap_in     = new("ie_stage_ap_in", this);
    data_memory_ap_in  = new("data_memory_ap_in", this);
    isr_if_ap_in       = new("isr_if_ap_in", this);
    dbg_if_ap_in       = new("dbg_if_ap_in", this);

    if_stage_ap_out     = new("if_stage_ap_out", this);
    id_stage_ap_out     = new("id_stage_ap_out", this);
    ie_stage_ap_out     = new("ie_stage_ap_out", this);
    data_memory_ap_out  = new("data_memory_ap_out", this);
    lsu_ap_out          = new("lsu_ap_out", this);
    isr_if_ap_out       = new("isr_if_ap_out", this);
    dbg_if_ap_out       = new("dbg_if_ap_out", this);

    //Create agents' configuration objects
    cv32e40p_rst_agt_cfg            = cv32e40p_rst_agent_config::type_id::create("cv32e40p_rst_agt_cfg");
    cv32e40p_if_agt_cfg             = cv32e40p_if_agent_config::type_id::create("cv32e40p_if_agt_cfg");
    cv32e40p_id_agt_cfg             = cv32e40p_id_agent_config::type_id::create("cv32e40p_id_agt_cfg");
    cv32e40p_ie_agt_cfg             = cv32e40p_ie_agent_config::type_id::create("cv32e40p_ie_agt_cfg");
    cv32e40p_data_memory_if_agt_cfg = cv32e40p_data_memory_if_agent_config::type_id::create("cv32e40p_data_memory_if_agt_cfg");
    cv32e40p_debug_if_agt_cfg       = cv32e40p_debug_if_agent_config::type_id::create("cv32e40p_debug_if_agt_cfg");
    cv32e40p_interrupt_if_agt_cfg   = cv32e40p_interrupt_if_agent_config::type_id::create("cv32e40p_interrupt_if_agt_cfg");

    //populate the agents' configuration objects
    cv32e40p_rst_agt_cfg.initialize(env_cfg.cv32e40p_rst_vif, env_cfg.rst_agent_get_is_active());
    cv32e40p_if_agt_cfg.initialize(env_cfg.cv32e40p_instruction_memory_vif, env_cfg.cv32e40p_internal_vif, env_cfg.if_agent_get_is_active());
    cv32e40p_id_agt_cfg.initialize(env_cfg.cv32e40p_internal_vif, env_cfg.id_agent_get_is_active());
    cv32e40p_ie_agt_cfg.initialize(env_cfg.cv32e40p_internal_vif, env_cfg.ie_agent_get_is_active());
    cv32e40p_data_memory_if_agt_cfg.initialize(env_cfg.cv32e40p_data_memory_vif, env_cfg.data_memory_if_agent_get_is_active());
    cv32e40p_debug_if_agt_cfg.initialize(env_cfg.cv32e40p_debug_vif, env_cfg.debug_if_agent_get_is_active());
    cv32e40p_interrupt_if_agt_cfg.initialize(env_cfg.cv32e40p_interrupt_vif, env_cfg.interrupt_if_agent_get_is_active());

    // Create Agents' Instances
    cv32e40p_rst_agt                = cv32e40p_rst_agent::type_id::create("cv32e40p_rst_agt", this);
    cv32e40p_if_agt                 = cv32e40p_if_agent::type_id::create("cv32e40p_if_agt", this);
    cv32e40p_id_agt                 = cv32e40p_id_agent::type_id::create("cv32e40p_id_agt", this);
    cv32e40p_ie_agt                 = cv32e40p_ie_agent::type_id::create("cv32e40p_ie_agt", this);
    cv32e40p_data_memory_if_agt     = cv32e40p_data_memory_if_agent::type_id::create("cv32e40p_data_memory_if_agt", this);
    cv32e40p_interrupt_if_agt       = cv32e40p_interrupt_if_agent::type_id::create("cv32e40p_interrupt_if_agt", this);
    cv32e40p_debug_if_agt           = cv32e40p_debug_if_agent::type_id::create("cv32e40p_debug_if_agt", this);
    
    // Create Scoreboard & Subscriber Instances
    scoreboard_h            = scoreboard::type_id::create("scoreboard_h", this);
    subscriber_h            = subscriber::type_id::create("subscriber_h", this);

    // Create Virtual Sequencer Instance
    v_sqr               = virtual_sequencer::type_id::create("v_sqr", this);
    
    //Setters    
    uvm_config_db#(cv32e40p_rst_agent_config)::set(this,"cv32e40p_rst_agt","cv32e40p_rst_agt_cfg", cv32e40p_rst_agt_cfg);
    uvm_config_db#(cv32e40p_if_agent_config)::set(this,"cv32e40p_if_agt","cv32e40p_if_agt_cfg", cv32e40p_if_agt_cfg);
    uvm_config_db#(cv32e40p_id_agent_config)::set(this,"cv32e40p_id_agt","cv32e40p_id_agt_cfg", cv32e40p_id_agt_cfg);
    uvm_config_db#(cv32e40p_ie_agent_config)::set(this,"cv32e40p_ie_agt","cv32e40p_ie_agt_cfg", cv32e40p_ie_agt_cfg);
    uvm_config_db#(cv32e40p_data_memory_if_agent_config)::set(this,"cv32e40p_data_memory_if_agt","cv32e40p_data_memory_if_agt_cfg", cv32e40p_data_memory_if_agt_cfg);
    uvm_config_db#(cv32e40p_interrupt_if_agent_config)::set(this,"cv32e40p_interrupt_if_agt","cv32e40p_interrupt_if_agt_cfg", cv32e40p_interrupt_if_agt_cfg);
    uvm_config_db#(cv32e40p_debug_if_agent_config)::set(this,"cv32e40p_debug_if_agt","cv32e40p_debug_if_agt_cfg", cv32e40p_debug_if_agt_cfg);

endfunction : build_phase

/****************************************
/ Connect Phase : Has TLM Connections
******************************************/
function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "Connect phase", UVM_LOW)

    //connect TLM ports from RST_agent to Environment
    cv32e40p_rst_agt.RST_p_ap.connect(RST_p_ap);
    cv32e40p_rst_agt.RST_n_ap.connect(RST_n_ap);

    //connect TLM ports of RST agent from Environment to other agents
    RST_p_ap.connect(cv32e40p_if_agt.RST_p_ap); //IF
    RST_p_ap.connect(cv32e40p_id_agt.RST_p_ap); //ID
    RST_p_ap.connect(cv32e40p_ie_agt.RST_p_ap); //IE
    RST_p_ap.connect(cv32e40p_data_memory_if_agt.RST_p_ap); //WB
    RST_p_ap.connect(cv32e40p_interrupt_if_agt.RST_p_ap); //ISR
    RST_p_ap.connect(cv32e40p_debug_if_agt.RST_p_ap); //DBG
    RST_n_ap.connect(cv32e40p_if_agt.RST_n_ap); //IF
    RST_n_ap.connect(cv32e40p_id_agt.RST_n_ap); //ID
    RST_n_ap.connect(cv32e40p_ie_agt.RST_n_ap); //IE
    RST_n_ap.connect(cv32e40p_data_memory_if_agt.RST_n_ap); //WB
    RST_n_ap.connect(cv32e40p_interrupt_if_agt.RST_n_ap); //ISR
    RST_n_ap.connect(cv32e40p_debug_if_agt.RST_n_ap); //DBG

    //Connect RST Agent to Scoreboard & Subscriber
    RST_p_ap.connect(scoreboard_h.RST_p_ap);
    RST_n_ap.connect(scoreboard_h.RST_n_ap);

    RST_p_ap.connect(subscriber_h.RST_p_ap);
    RST_n_ap.connect(subscriber_h.RST_n_ap);

    // Connect All agents' (except RST_agent) inputs & outputs to Environment
    cv32e40p_if_agt.if_stage_ap_in.connect(if_stage_ap_in);
    cv32e40p_if_agt.if_stage_ap_out.connect(if_stage_ap_out);

    cv32e40p_id_agt.id_stage_ap_in.connect(id_stage_ap_in);
    cv32e40p_id_agt.id_stage_ap_out.connect(id_stage_ap_out);

    cv32e40p_ie_agt.ie_stage_ap_in.connect(ie_stage_ap_in);
    cv32e40p_ie_agt.ie_stage_ap_out.connect(ie_stage_ap_out);

    cv32e40p_data_memory_if_agt.data_memory_ap_in.connect(data_memory_ap_in);
    cv32e40p_data_memory_if_agt.data_memory_ap_out.connect(data_memory_ap_out);
    cv32e40p_data_memory_if_agt.lsu_ap_out.connect(lsu_ap_out);

    cv32e40p_interrupt_if_agt.isr_if_ap_in.connect(isr_if_ap_in);
    cv32e40p_interrupt_if_agt.isr_if_ap_out.connect(isr_if_ap_out);

    cv32e40p_debug_if_agt.dbg_if_ap_in.connect(dbg_if_ap_in);
    cv32e40p_debug_if_agt.dbg_if_ap_out.connect(dbg_if_ap_out);

    // Connect All agents' (except RST_agent) inputs & outputs to Scoreboard & Subscriber

    //Inputs to Scoreboard
    if_stage_ap_in.connect(scoreboard_h.if_stage_ap_in);
    id_stage_ap_in.connect(scoreboard_h.id_stage_ap_in);
    ie_stage_ap_in.connect(scoreboard_h.ie_stage_ap_in);
    data_memory_ap_in.connect(scoreboard_h.data_memory_ap_in);
    dbg_if_ap_in.connect(scoreboard_h.debug_if_ap_in);
    isr_if_ap_in.connect(scoreboard_h.isr_if_ap_in);

    //Outputs to Scoreboard
    if_stage_ap_out.connect(scoreboard_h.if_stage_ap_out);
    id_stage_ap_out.connect(scoreboard_h.id_stage_ap_out);
    ie_stage_ap_out.connect(scoreboard_h.ie_stage_ap_out);
    data_memory_ap_out.connect(scoreboard_h.data_memory_ap_out);
    lsu_ap_out.connect(scoreboard_h.lsu_ap_out);
    dbg_if_ap_out.connect(scoreboard_h.debug_if_ap_out);
    isr_if_ap_out.connect(scoreboard_h.isr_if_ap_out);

    //Inputs to Subscriber
    if_stage_ap_in.connect(subscriber_h.if_stage_ap_in);
    id_stage_ap_in.connect(subscriber_h.id_stage_ap_in);
    ie_stage_ap_in.connect(subscriber_h.ie_stage_ap_in);
    data_memory_ap_in.connect(subscriber_h.data_memory_ap_in);
    dbg_if_ap_in.connect(subscriber_h.dbg_if_ap_in);
    isr_if_ap_in.connect(subscriber_h.isr_if_ap_in);

    //Outputs to Subscriber
    if_stage_ap_out.connect(subscriber_h.if_stage_ap_out);
    id_stage_ap_out.connect(subscriber_h.id_stage_ap_out);
    ie_stage_ap_out.connect(subscriber_h.ie_stage_ap_out);
    data_memory_ap_out.connect(subscriber_h.data_memory_ap_out);
    dbg_if_ap_out.connect(subscriber_h.dbg_if_ap_out);
    isr_if_ap_out.connect(subscriber_h.isr_if_ap_out);

    //Connect the sequencers handles to their prespective ones in the Virtual Sequencer
    v_sqr.rst_sqr_h           = cv32e40p_rst_agt           .cv32e40p_rst_sqr;
    v_sqr.if_stage_sqr_h      = cv32e40p_if_agt            .cv32e40p_if_sqr;
    v_sqr.data_memory_sqr_h   = cv32e40p_data_memory_if_agt.cv32e40p_data_memory_if_sqr;
    v_sqr.isr_if_sqr_h        = cv32e40p_interrupt_if_agt  .cv32e40p_interrupt_sqr;
    v_sqr.dbg_if_sqr_h        = cv32e40p_debug_if_agt      .cv32e40p_debug_if_sqr;

endfunction : connect_phase

/**********************************************************
/ End of Elaboration Phase : Has minor adjustments 
/ to the hierarchy before starting he run: TLM debugging
***********************************************************/
function void end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_type_name(), "End of elaboration phase", UVM_LOW)

    //TLM debuging

endfunction : end_of_elaboration_phase


endclass : cv32e40p_env
