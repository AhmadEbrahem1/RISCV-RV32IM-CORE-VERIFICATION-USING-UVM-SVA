/******************************************************************
 * File: cv32e40p_debug_if_monitor.sv
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
 *              inputs of a DUT (Device Under Test). It provides
 *              functionality for collecting and analyzing sequence
 *              seq_items through an analysis port.
 *
 * Copyright (c) [2024] [Team 1]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/
 class cv32e40p_debug_if_monitor extends uvm_monitor;

    //Transaction Counter to report on
    protected int in_trans_count, out_trans_count;

	//Registering the if_stage_driver class in the factory
    `uvm_component_utils_begin(cv32e40p_debug_if_monitor)
        `uvm_field_int(in_trans_count, UVM_DEFAULT)
        `uvm_field_int(out_trans_count, UVM_DEFAULT)
    `uvm_object_utils_end

    // Declare the interface and monitor
    virtual cv32e40p_debug_if  vif;

    //Sequence seq_item Handle    
    
    //TLM Connections between DBG monitor & DBG Agent
    uvm_analysis_port #(cv32e40p_debug_sequence_item) dbg_if_ap_in;
    uvm_analysis_port #(cv32e40p_debug_sequence_item) dbg_if_ap_out;

    //TLM Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_p_ap;
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_n_ap;

    //TLM FIFO Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_p_fifo;
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_n_fifo;

/*****************************************************************************
/ Constructor : is responsible for the construction of objects and components
******************************************************************************/
function new (string name = "cv32e40p_debug_if_monitor", uvm_component parent);
    super.new(name, parent);
endfunction

/*******************************************************************
/ Build Phase : Has Creators, Getters, Setters & possible overrides
********************************************************************/
function void build_phase (uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

    //Get Virtual Interface handle from db
    if(!(uvm_config_db#(virtual cv32e40p_debug_if)::get(this, "","vif", vif)))
        `uvm_fatal(get_type_name(), "Failed to get Virtual Interface Handle")

    //Create Sequence seq_item

    //Create TLM ports
    dbg_if_ap_in    = new("dbg_if_ap_in", this);
    dbg_if_ap_out   = new("dbg_if_ap_out", this);
    RST_p_ap        = new("RST_p_ap", this);
    RST_n_ap        = new("RST_n_ap", this);
    
    //Create TLM FIFOs
    RST_p_fifo      = new("RST_p_fifo", this);
    RST_n_fifo      = new("RST_n_fifo", this);
    
endfunction

/********************************************
/ Connect Phase : Has TLM Connections
*********************************************/
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM)
    RST_p_ap.connect(RST_p_fifo.analysis_export);
    RST_n_ap.connect(RST_n_fifo.analysis_export);
endfunction

/****************************************************************************************************
/ Reset phase : Mostly used to wait the first Reset being initiated by the rst_agent or top-tb
*****************************************************************************************************/
task reset_phase(uvm_phase phase);
	cv32e40p_rst_sequence_item   rst_seq_item;
	phase.raise_objection(this);
    
    super.reset_phase(phase);
    `uvm_info(get_type_name(), "Reset phase", UVM_MEDIUM)
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
            monitor_trigger();
        join_any
        disable fork;
        RST_p_fifo.get(rst_seq_item);
    end
endtask : main_phase

// A task to start the monitoring process
task monitor_in_out();
	cv32e40p_debug_sequence_item inputs_seq_item, outputs_seq_item;
	//Monitor Inputs
	inputs_seq_item = cv32e40p_debug_sequence_item::type_id::create("inputs_seq_item");
    inputs_seq_item.dm_halt_addr_i         = vif.dm_halt_addr_i;
    inputs_seq_item.dm_exception_addr_i    = vif.dm_exception_addr_i;
    inputs_seq_item.debug_req_i 		   = vif.debug_req_i;
	`uvm_info(get_type_name(), $sformatf("Debug Interface Monitor Inputs :\n %s", inputs_seq_item.sprint), UVM_MEDIUM)
    dbg_if_ap_in.write(inputs_seq_item);
    in_trans_count++;

    //Monitor Outputs
    @(vif.clk_i);
    outputs_seq_item  = cv32e40p_debug_sequence_item::type_id::create("outputs_seq_item");
    outputs_seq_item.debug_havereset_o = vif.debug_havereset_o;
    outputs_seq_item.debug_running_o   = vif.debug_running_o;
    outputs_seq_item.debug_halted_o    = vif.debug_halted_o;
	`uvm_info(get_type_name(), $sformatf("Debug Interface Monitor Outputs :\n %s", outputs_seq_item.sprint), UVM_MEDIUM)
    dbg_if_ap_out.write(outputs_seq_item);
	out_trans_count++;
endtask : monitor_in_out

// A task to trigger the monitoring of monitor_in & monitor_out task
task monitor_trigger();
	forever begin
		@(posedge vif.clk_i)
		fork
			monitor_in_out();
		join_none
	end		
endtask

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
`uvm_info(get_type_name(), 
            $sformatf("\nDebug Interface Monitor Report:\n\tInput Transactions Monitored: %0d\n\tOutput Transactions Monitored: %0d",in_trans_count, out_trans_count), UVM_MEDIUM)

`uvm_info(get_type_name(), "Debug Interface Monitor Report Phase Complete", UVM_MEDIUM)
endfunction : report_phase

endclass: cv32e40p_debug_if_monitor
