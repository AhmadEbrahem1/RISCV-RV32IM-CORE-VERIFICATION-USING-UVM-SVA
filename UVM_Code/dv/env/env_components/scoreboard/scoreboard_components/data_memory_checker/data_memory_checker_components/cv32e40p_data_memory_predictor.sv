/******************************************************************
 * File: cv32e40p_data_memory_predictor.sv
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
class cv32e40p_data_memory_predictor extends uvm_component;

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
    uvm_analysis_export	#(cv32e40p_data_memory_sequence_item) inputs_ap;
    uvm_analysis_port	#(cv32e40p_data_memory_sequence_item) expected_outputs_ap;

	uvm_tlm_analysis_fifo #(cv32e40p_data_memory_sequence_item) inputs_fifo;

    // A signal to indicate that req happened
    local bit [1:0] req_count;

    // Queue to keep track of pending request elements
    local cv32e40p_data_memory_sequence_item req_queue [$];

    // Data Memory RAM
    bit [31:0] RAM [63:0];

    // Register with factory
    `uvm_component_utils(cv32e40p_data_memory_predictor)

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
    initialize_ram();
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
        cv32e40p_data_memory_sequence_item mon_in_tx;
		mon_in_tx = cv32e40p_data_memory_sequence_item:: type_id :: create ("mon_in_tx");
		inputs_fifo.get(mon_in_tx);
        check_req_count();
        `uvm_info(get_type_name(), $sformatf("Inputs Sampled \n %s", mon_in_tx.sprint()), UVM_MEDIUM)

        `uvm_info(get_type_name(), "check req task called", UVM_MEDIUM)
        check_req(mon_in_tx);
	end
endtask

                        /**********************************************************************************
************************** The following tasks predict the validity of the driving according to OBI protocol ***********************
                        ***********************************************************************************/


/*****************************************************************************************************************
/ check_req : This task checks that data_req_o has been asserted and if data_gnt_i it predicts that the next clk 
/             cycle will have rvalid asserted
******************************************************************************************************************/
task check_req(cv32e40p_data_memory_sequence_item t);
    cv32e40p_data_memory_sequence_item check_req_output, check_req_input, after_grant_input;
    check_req_output    = cv32e40p_data_memory_sequence_item::type_id::create("check_req_output");
    check_req_input     = cv32e40p_data_memory_sequence_item::type_id::create("check_req_input");
    after_grant_input   = cv32e40p_data_memory_sequence_item::type_id::create("after_grant_input");
    check_req_input.copy(t);
    if(check_req_input.data_req_o) begin
        req_queue.push_back(check_req_input);
        req_count++;
    end
    if(check_req_input.data_gnt_i && req_count > 0) begin
        req_count--;
        after_grant_input = req_queue.pop_front();
        check_req_output.data_addr_o    = after_grant_input.data_addr_o;
        check_req_output.data_we_o      = after_grant_input.data_we_o;
        check_req_output.data_be_o      = after_grant_input.data_be_o;
        if(after_grant_input.data_we_o) begin
            if(after_grant_input.data_be_o[0]) begin
                RAM[after_grant_input.data_addr_o][7:0] = after_grant_input.data_wdata_o[7:0];
            end 
            if(after_grant_input.data_be_o[1]) begin
                RAM[after_grant_input.data_addr_o][15:8]  = after_grant_input.data_wdata_o[15:8];
            end 
            if(after_grant_input.data_be_o[2]) begin
                RAM[after_grant_input.data_addr_o][23:16] = after_grant_input.data_wdata_o[23:16];
            end 
            if(after_grant_input.data_be_o[3]) begin
                RAM[after_grant_input.data_addr_o][31:24] = after_grant_input.data_wdata_o[31:24];
            end 
        end
        else begin
            if(after_grant_input.data_be_o[0]) begin
                check_req_output.data_rdata_i[7:0]   = RAM[after_grant_input.data_addr_o][7:0];
            end                                    
            if(after_grant_input.data_be_o[1]) begin                                  
                check_req_output.data_rdata_i[15:8]  = RAM[after_grant_input.data_addr_o][15:8];
            end 
            if(after_grant_input.data_be_o[2]) begin
                check_req_output.data_rdata_i[23:16] = RAM[after_grant_input.data_addr_o][23:16];
            end 
            if(after_grant_input.data_be_o[3]) begin
                check_req_output.data_rdata_i[31:24] = RAM[after_grant_input.data_addr_o][31:24];
            end 
        end
        check_req_output.data_rvalid_i = 1;
        expected_outputs_ap.write(check_req_output);
    end
endtask : check_req

/*****************************************************************************************
/ check_req_count : This task checks that the outstanding txn number does not pass 2 txns
******************************************************************************************/
task check_req_count();
    if(req_count > 2) begin
        `uvm_error(get_type_name(), "request count breaches the OBI protocol")
    end
endtask : check_req_count

/****************************************************************************************************************************
/ check_req_count : This task Initalizes the data memory with the same values as the ones that the Agent initializes it with
*****************************************************************************************************************************/
task initialize_ram();
	foreach (RAM[i]) begin
		if(i == 2) begin
			RAM[i] = 32'h00001234;
		end
		else begin
			RAM[i] = 32'h00000000;
		end
	end
endtask : initialize_ram

endclass : cv32e40p_data_memory_predictor