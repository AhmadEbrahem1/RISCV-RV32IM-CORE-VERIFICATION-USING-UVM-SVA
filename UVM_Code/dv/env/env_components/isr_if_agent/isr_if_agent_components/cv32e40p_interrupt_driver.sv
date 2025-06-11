/******************************************************************
 * File: cv32e40p_interrupt_driver .sv
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
class cv32e40p_interrupt_driver  extends uvm_driver #(cv32e40p_interrupt_sequence_item);

    //Transaction Counter to report on
    protected int trans_count;

    //Registering the IF_driver class in the factory
    `uvm_component_utils_begin(cv32e40p_interrupt_driver )
        `uvm_field_int(trans_count, UVM_DEFAULT)
    `uvm_object_utils_end

    // Declare the interface and monitor
    virtual cv32e40p_interrupt_if  vif;

    //Sequence Item Handle    

    //TLM Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_p_ap;
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_n_ap;

    //TLM FIFO Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_p_fifo;
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_n_fifo;

/*****************************************************************************
/ Constructor : is responsible for the construction of objects and components
******************************************************************************/
function new (string name = "cv32e40p_interrupt_driver ", uvm_component parent);
    super.new(name, parent);
endfunction

/*******************************************************************
/ Build Phase : Has Creators, Getters, Setters & possible overrides
********************************************************************/
function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

    //Get Virtual Interface handle from db
    if(!(uvm_config_db#(virtual cv32e40p_interrupt_if)::get(
        this, 
        "", 
        "vif", 
        vif)))
        `uvm_fatal(get_type_name(), "Failed to get Virtual Interface Handle")

    //Create Sequence Item
    //seq_item = cv32e40p_interrupt_sequence_item::type_id::create("seq_item");

    //Create TLM ports
    RST_p_ap  = new("RST_p_ap", this);
    RST_n_ap  = new("RST_n_ap", this);
    
    //Create TLM FIFOs
    RST_p_fifo  = new("RST_p_fifo", this);
    RST_n_fifo  = new("RST_n_fifo", this);
    
endfunction

/********************************************
/ Connect Phase : Has TLM Connections
*********************************************/
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    RST_p_ap.connect(RST_p_fifo.analysis_export);
    RST_n_ap.connect(RST_n_fifo.analysis_export);
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
	vif.irq_i =0;
	RST_n_fifo.get(rst_seq_item);
    RST_p_fifo.get(rst_seq_item);

    `uvm_info(get_type_name(), "First Reset Done", UVM_HIGH)
	phase.drop_objection(this);
endtask : reset_phase

/****************************************************************************************************
/ Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
*****************************************************************************************************/
task main_phase(uvm_phase phase);
    cv32e40p_rst_sequence_item   rst_seq_item;
    super.main_phase(phase);
    `uvm_info(get_type_name(), "Main phase", UVM_MEDIUM)

    forever begin
        fork
            RST_n_fifo.get(rst_seq_item);
            start_driving();
        join_any
        disable fork;
        RST_p_fifo.get(rst_seq_item);
    end
endtask : main_phase

// A task to start the driving process
task start_driving();
    cv32e40p_interrupt_sequence_item  req;
    forever begin
        @(vif.clk_i);
	vif.irq_i <=0;	
        //logic
    end
endtask : start_driving

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
`uvm_info(get_type_name(), 
            $sformatf("\nDebug Interface Driver Report:\n\tTotal Transactions driven: %0d",trans_count), UVM_MEDIUM)

`uvm_info(get_type_name(), "Debug Interface Driver Report Phase Complete", UVM_MEDIUM)
endfunction : report_phase

endclass: cv32e40p_interrupt_driver 
