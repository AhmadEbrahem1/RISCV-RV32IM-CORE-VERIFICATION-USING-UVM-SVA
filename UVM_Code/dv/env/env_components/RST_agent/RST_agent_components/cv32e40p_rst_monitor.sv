/******************************************************************
 * File: cv32e40p_rst_monitor.sv
 * Authors: Team 1:
            * Ziad Ahmed
            * Ahmed Khaled
            * Ahmed Ebrahem
            * Mohamed Mohsen
            * Esmail Abdelrahman
            * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2025
 * Description: This class extends `uvm_monitor` to monitor the
 *              inputs & outputs of a DUT (Device Under Test). It provides
 *              functionality for collecting and analyzing sequence
 *              items through an analysis port.
 *
 * Copyright (c) [2024] [Team 1]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/
class cv32e40p_rst_monitor extends uvm_monitor;

    //Registering the rst_driver class in the factory
    `uvm_component_utils(cv32e40p_rst_monitor)

    //Sequence Item Handle
    cv32e40p_rst_sequence_item rst_seq_item;

    // Declare the interface and monitor
    virtual cv32e40p_rst_if  rst_vif;

    //TLM Ports to communicate reset assertion & de-assertion to the Environment
    uvm_analysis_port#(cv32e40p_rst_sequence_item) RST_p_ap;
    uvm_analysis_port#(cv32e40p_rst_sequence_item) RST_n_ap;

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

/*********************************************************
/ Build Phase : Has Creators, Getters & possible overrides
**********************************************************/
function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

    //Get config from db
    if(!(uvm_config_db#(virtual cv32e40p_rst_if)::get(this,"", "rst_vif", rst_vif)))
        `uvm_fatal(get_type_name(), "Failed to get Virtual Interface Handle")
        
    //Create TLM ports
    RST_p_ap = new("RST_p_ap", this);
    RST_n_ap = new("RST_n_ap", this);

    //Create Sequence Items
endfunction : build_phase

/********************************************
/ Connect Phase : Has TLM Connections
*********************************************/
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM)
endfunction : connect_phase

/****************************************************************************************************
/ Run phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
*****************************************************************************************************/
task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Run phase", UVM_MEDIUM)


    forever begin
        fork
            begin
                @(negedge rst_vif.rst_ni);
                RST_n_ap.write(rst_seq_item);
                `uvm_info(get_type_name(),"-ve ResetMonitor", UVM_LOW)
            end
            begin
                @(posedge rst_vif.rst_ni);
                RST_p_ap.write(rst_seq_item);
                `uvm_info(get_type_name(),"+ve ResetMonitor", UVM_LOW)
            end
        join
    end
endtask : run_phase

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
`uvm_info(get_type_name(), 
            $sformatf("\nReset Monitor Report:\n\tTotal Resets: %0d",cv32e40p_rst_sequence_item::resets_count), UVM_MEDIUM)

`uvm_info(get_type_name(), "Reset Monitor Report Phase Complete", UVM_MEDIUM)
endfunction : report_phase

endclass : cv32e40p_rst_monitor