/******************************************************************
 * File: cv32e40p_data_memory_if_monitor.sv
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
 class cv32e40p_data_memory_if_monitor extends uvm_monitor;

    //Transaction Counter to report on
    protected int in_trans_count, out_trans_count;

	//Registering the data_memory_driver class in the factory
    `uvm_component_utils_begin(cv32e40p_data_memory_if_monitor)
        `uvm_field_int(in_trans_count, UVM_DEFAULT)
        `uvm_field_int(out_trans_count, UVM_DEFAULT)
    `uvm_object_utils_end

    //Reset Interface Virtual Interface Handle
    virtual cv32e40p_data_memory_if vif;

    //Sequence Item Handle 

    //TLM Connections between DBG inputsMonitor & IF Agent
	uvm_analysis_port #(cv32e40p_data_memory_sequence_item) data_memory_ap_in;
	uvm_analysis_port #(cv32e40p_data_memory_sequence_item) data_memory_ap_out;
    uvm_analysis_port #(cv32e40p_data_memory_sequence_item) lsu_ap_out;

    //TLM Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_p_ap;
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_n_ap;

    //TLM FIFO Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_p_fifo;
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_n_fifo;

/*****************************************************************************
/ Constructor : is responsible for the construction of objects and components
******************************************************************************/
function new (string name, uvm_component parent);
    super.new(name, parent);
endfunction

/*******************************************************************
/ Build Phase : Has Creators, Getters, Setters & possible overrides
********************************************************************/
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
    `uvm_info(get_full_name(), "Build phase", UVM_MEDIUM)

	// Retrieve virtual interface
	if (!uvm_config_db#(virtual cv32e40p_data_memory_if)::get(this, "", "vif", vif))
        `uvm_fatal(get_type_name(), "Failed to get Virtual Interface Handle")

	//Create Sequence Item
	
    //Create TLM ports
    data_memory_ap_in = new("data_memory_ap_in", this);
    data_memory_ap_out = new("data_memory_ap_out", this);
    lsu_ap_out = new("lsu_ap_out", this);

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
    `uvm_info(get_full_name(), "Connect phase", UVM_MEDIUM)
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
    `uvm_info(get_full_name(), "Reset phase", UVM_MEDIUM)
	RST_n_fifo.get(rst_seq_item);
    RST_p_fifo.get(rst_seq_item);

    `uvm_info(get_full_name(), "First Reset Done", UVM_HIGH)
	phase.drop_objection(this);
endtask : reset_phase

/****************************************************************************************************
/ Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
*****************************************************************************************************/
task main_phase(uvm_phase phase);
    cv32e40p_rst_sequence_item   rst_seq_item;
    super.main_phase(phase);
    `uvm_info(get_full_name(), "Main phase", UVM_MEDIUM)
    
    forever begin
        fork
            RST_n_fifo.get(rst_seq_item);
            monitor_interfaces();
        join_any
        disable fork;
        RST_p_fifo.get(rst_seq_item);
    end
endtask

// A task to start the inputs & outputs monitoring process
task monitor_interfaces();
    fork
        monitor_in();
        monitor_out_data_memory();
        monitor_out_lsu();
    join
endtask

// A task to monitor inputs
task monitor_in();
    cv32e40p_data_memory_sequence_item inputs_seq_item;
    forever begin
        @(vif.cb_mon);
        inputs_seq_item = cv32e40p_data_memory_sequence_item::type_id::create("inputs_seq_item");
        inputs_seq_item.data_gnt_i      = vif.data_gnt_i;
        inputs_seq_item.data_rvalid_i   = vif.data_rvalid_i;
        inputs_seq_item.data_rdata_i    = vif.data_rdata_i;
        inputs_seq_item.data_req_o      = vif.data_req_o;
        inputs_seq_item.data_we_o       = vif.data_we_o;
        inputs_seq_item.data_be_o       = vif.data_be_o;
        inputs_seq_item.data_addr_o     = vif.data_addr_o;
        inputs_seq_item.data_wdata_o    = vif.data_wdata_o;

        `uvm_info(get_type_name(), $sformatf("Data Memory Stage Inputs: \n %s", inputs_seq_item.sprint()), UVM_MEDIUM)
        data_memory_ap_in.write(inputs_seq_item);
        in_trans_count++;
    end
endtask

// A task to monitor outputs for data memory checker
task monitor_out_data_memory();
    cv32e40p_data_memory_sequence_item outputs_seq_item;
    @(vif.cb_mon);
    forever begin
        @(vif.cb_mon);
        if(vif.cb_mon.data_rvalid_i) begin
            outputs_seq_item = cv32e40p_data_memory_sequence_item::type_id::create("outputs_seq_item");
            
            outputs_seq_item.data_gnt_i      = vif.data_gnt_i;
            outputs_seq_item.data_rvalid_i   = vif.data_rvalid_i;
            outputs_seq_item.data_rdata_i    = vif.data_rdata_i;
            outputs_seq_item.data_req_o      = vif.data_req_o;
            outputs_seq_item.data_we_o       = vif.data_we_o;
            outputs_seq_item.data_be_o       = vif.data_be_o;
            outputs_seq_item.data_addr_o     = vif.data_addr_o;
            outputs_seq_item.data_wdata_o    = vif.data_wdata_o;

            `uvm_info(get_type_name(), $sformatf("Data Memory Stage Outputs: \n %s", outputs_seq_item.sprint()), UVM_MEDIUM)
            data_memory_ap_out.write(outputs_seq_item);
            out_trans_count++;
        end
    end
endtask

// A task to monitor outputs for LSU checker
task monitor_out_lsu();
    cv32e40p_data_memory_sequence_item outputs_seq_item;
    @(vif.cb_mon);
    forever begin
        @(vif.cb_mon);
        if(vif.cb_mon.data_req_o) begin
            outputs_seq_item = cv32e40p_data_memory_sequence_item::type_id::create("outputs_seq_item");
            
            outputs_seq_item.data_req_o      = vif.data_req_o;
            outputs_seq_item.data_we_o       = vif.data_we_o;
            outputs_seq_item.data_be_o       = vif.data_be_o;
            outputs_seq_item.data_addr_o     = vif.data_addr_o;
            outputs_seq_item.data_wdata_o    = vif.data_wdata_o;

            `uvm_info(get_type_name(), $sformatf("Data Memory Stage Outputs: \n %s", outputs_seq_item.sprint()), UVM_MEDIUM)
            lsu_ap_out.write(outputs_seq_item);
            out_trans_count++;
        end
    end
endtask

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
`uvm_info(get_type_name(), 
            $sformatf("\nData Memory Interface Monitor Report:\n\tInput Transactions Monitored: %0d \n\tOutput Transactions Monitored: %0d",in_trans_count, out_trans_count), UVM_MEDIUM)

`uvm_info(get_type_name(), "Data Memory Interface Monitor Report Phase Complete", UVM_LOW)
endfunction : report_phase

endclass