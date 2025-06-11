
/******************************************************************
 * File: cv32e40p_ie_monitor.sv
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
 class cv32e40p_ie_monitor extends uvm_monitor;

    //Transaction Counter to report on
    protected int in_trans_count, out_trans_count;

	//Registering the ie_stage_driver class in the factory
    `uvm_component_utils_begin(cv32e40p_ie_monitor)
        `uvm_field_int(in_trans_count, UVM_DEFAULT)
        `uvm_field_int(out_trans_count, UVM_DEFAULT)
    `uvm_object_utils_end

    //Reset Interface Virtual Interface Handle
    virtual cv32e40p_internal_if vif;

    //Sequence Item Handle

    //TLM Connections between IE Stage inputsMonitor & IE Agent
	uvm_analysis_port #(cv32e40p_ie_sequence_item) ie_stage_ap_in;
	uvm_analysis_port #(cv32e40p_ie_sequence_item) ie_stage_ap_out;

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

    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM) 

	// Retrieve virtual interface
	if (!uvm_config_db#(virtual cv32e40p_internal_if)::get(this, "", "vif", vif))
        `uvm_fatal(get_type_name(), "Failed to get Virtual Interface Handle")


	//Create Sequence Item

    //Create TLM ports
    ie_stage_ap_in  = new("ie_stage_ap_in", this);
    ie_stage_ap_out = new("ie_stage_ap_out", this);

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
		monitor_out();
	join
endtask

// A task to start the inputs monitoring process
task monitor_in();
	cv32e40p_ie_sequence_item in_tx;
	forever begin
		in_tx = cv32e40p_ie_sequence_item:: type_id :: create ("in_tx");
		if (vif == null) $fatal("Virtual interface not set!");
		@(vif.cb_mon);
		if(vif.cb_mon.ex_ready) begin
			if(vif.cb_mon.alu_en_ex || vif.cb_mon.mult_en_ex) begin
				in_tx.alu_operator_ex				=	alu_opcode_e'(vif.cb_mon.alu_operator_ex);
				in_tx.alu_operand_a_ex				=	vif.cb_mon.alu_operand_a_ex;
				in_tx.alu_operand_b_ex				=	vif.cb_mon.alu_operand_b_ex;
				in_tx.alu_operand_c_ex				=	vif.cb_mon.alu_operand_c_ex;
				in_tx.alu_en_ex						=	vif.cb_mon.alu_en_ex;
				in_tx.mult_operator_ex				=	mul_opcode_e'(vif.cb_mon.mult_operator_ex);
				in_tx.mult_operand_a_ex				=	vif.cb_mon.mult_operand_a_ex;
				in_tx.mult_operand_b_ex				=	vif.cb_mon.mult_operand_b_ex;
				in_tx.mult_operand_c_ex				=	vif.cb_mon.mult_operand_c_ex;
				in_tx.mult_en_ex					=	vif.cb_mon.mult_en_ex;
				in_tx.mult_sel_subword_ex			=	vif.cb_mon.mult_sel_subword_ex;
				in_tx.mult_signed_mode_ex			=	vif.cb_mon.mult_signed_mode_ex;
				in_tx.mult_imm_ex					= 	vif.cb_mon.mult_imm_ex;
				in_tx. mult_dot_op_a_ex				=	vif.cb_mon.mult_dot_op_a_ex;
				in_tx. mult_dot_op_b_ex				=	vif.cb_mon.mult_dot_op_b_ex;
				in_tx.mult_dot_op_c_ex				=	vif.cb_mon.mult_dot_op_c_ex;
				in_tx.mult_dot_signed_ex			=	vif.cb_mon.mult_dot_signed_ex;

				ie_stage_ap_in.write(in_tx);
			end
        end
	end
endtask 

// A task to start the outputs monitoring process
task monitor_out();
	cv32e40p_ie_sequence_item out_tx;
	forever begin
		out_tx = cv32e40p_ie_sequence_item:: type_id :: create ("out_tx");
		@(vif.cb_mon);
		if(vif.cb_mon.ex_valid) begin

			out_tx.jump_target_ex			=	vif.cb_mon.jump_target_ex;
			out_tx.branch_decision			=	vif.cb_mon.branch_decision;
			out_tx.regfile_alu_waddr_fw		=	vif.cb_mon.regfile_alu_waddr_fw;
			out_tx.regfile_alu_we_fw		=	vif.cb_mon.regfile_alu_we_fw;
			out_tx.regfile_alu_wdata_fw		=	vif.cb_mon.regfile_alu_wdata_fw;
			out_tx.regfile_waddr_fw_wb_o	=	vif.cb_mon.regfile_waddr_fw_wb_o;
			
			ie_stage_ap_out.write(out_tx);
		end
	end
endtask

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
`uvm_info(get_type_name(), 
            $sformatf("\nInstruction Execution Stage Monitor Report:\n\tInput Transactions Monitored: %0d \n\tOutput Transactions Monitored: %0d",in_trans_count, out_trans_count), UVM_MEDIUM)
`uvm_info(get_type_name(), "Instruction Execution Stage Monitor Report Phase Complete", UVM_MEDIUM)
endfunction : report_phase

 endclass : cv32e40p_ie_monitor
