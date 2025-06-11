/******************************************************************
 * File: cv32e40p_rst_driver.sv
 * Authors: Team 1:
            * Ziad Ahmed
            * Ahmed Khaled
            * Ahmed Ebrahem
            * Mohamed Mohsen
            * Esmail Abdelrahman
            * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2025
 * Description: This class defines a UVM driver component for 
 *              sending sequence items to the Design Under Test (DUT).
 *
 * Copyright (c) [2024] [Team 1]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/
class cv32e40p_rst_driver extends uvm_driver#(cv32e40p_rst_sequence_item);

    //Registering the cv32e40p_rst_driver class in the factory
    `uvm_component_utils(cv32e40p_rst_driver)

    //Reset Interface Virtual Interface Handle
    virtual cv32e40p_rst_if rst_vif;

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

    //Retrieve Virtual Interface from db
    if(!(uvm_config_db#(virtual cv32e40p_rst_if)::get(this, "", "rst_vif", rst_vif)))
        `uvm_fatal(get_type_name(), "Failed to get Virtual Interface Handle")

    //Create Sequence Items

endfunction : build_phase

/********************************************
/ Connect Phase : Has TLM Connections
*********************************************/
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM)
endfunction

/****************************************************************************************************
/ Reset phase : Mostly used to wait the first Reset being initiated by the rst_agent or top-tb
*****************************************************************************************************/
task reset_phase(uvm_phase phase);
	cv32e40p_rst_sequence_item   rst_seq_item;
	phase.raise_objection(this);
    super.reset_phase(phase);
    `uvm_info(get_type_name(), "Reset phase", UVM_MEDIUM)
    rst_vif.reset(3);
    `uvm_info(get_type_name(), "First Reset Done", UVM_MEDIUM)
	phase.drop_objection(this);
endtask : reset_phase

/****************************************************************************************************
/ Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
*****************************************************************************************************/
task main_phase(uvm_phase phase);
    cv32e40p_rst_sequence_item req;
    super.main_phase(phase);
	`uvm_info(get_type_name(), "Main phase", UVM_MEDIUM)
	
    
    forever begin
        seq_item_port.get_next_item(req);
        if(req.reset_on) begin
            if(cv32e40p_rst_sequence_item::number_of_resets_per_test >= cv32e40p_rst_sequence_item::resets_count) begin
                rst_vif.reset(req.reset_duration);
                cv32e40p_rst_sequence_item::resets_count ++;
                `uvm_info(get_type_name(), "Reset Asserted", UVM_LOW)
            end
            else begin
				`uvm_info(get_type_name(),$sformatf("else : resets_count =  %d",cv32e40p_rst_sequence_item::resets_count ), UVM_LOW)
                cv32e40p_rst_sequence_item::resets_done = 1;
                `uvm_info(get_type_name(), "Resets Done", UVM_LOW)
            end
            @(posedge rst_vif.rst_ni);
            seq_item_port.item_done();
        end
        else begin
            #req.reset_delay;
            seq_item_port.item_done();
        end
    end
endtask : main_phase

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
`uvm_info(get_type_name(), 
            $sformatf("\nReset Driver Report:\n\tTotal Resets: %0d",cv32e40p_rst_sequence_item::resets_count), UVM_MEDIUM)

`uvm_info(get_type_name(), "Reset Driver Report Phase Complete", UVM_MEDIUM)
endfunction : report_phase

endclass : cv32e40p_rst_driver