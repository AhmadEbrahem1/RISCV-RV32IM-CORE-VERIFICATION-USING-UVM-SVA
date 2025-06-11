/******************************************************************
 * File: cv32e40p_if_predictor.sv
 * Authors: Team 1:
            * Ziad Ahmed
            * Ahmed Khaled
            * Ahmed Ebrahem
            * Mohamed Mohsen
            * Esmail Abdelrahman
            * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2024
 * Description: This class defines a predictor for a RV32IM Core for Instruction
 *              Decode Stage in a UVM testbench. It is responsible for recifving
 *              the input stimulus the RV32IM Core and providing expected outputs.  
 *
 * Copyright (c) [2024] [Abdelrahman Mohamed Yassien]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/
 `define rf cv32e40p_Regfile_config::regfile_mirror
class cv32e40p_if_predictor extends uvm_component;

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
    uvm_analysis_export	#(cv32e40p_if_sequence_item) inputs_ap;
    uvm_analysis_port	#(cv32e40p_if_sequence_item) expected_outputs_ap;

	uvm_tlm_analysis_fifo #(cv32e40p_if_sequence_item) inputs_fifo;

    // A signal to indicate that fetch enable finished its pulse
    local bit fetch_flag;

    // An instruction queue to keep track of pending request elements
	cv32e40p_if_sequence_item req_queue [$];

    // A signal to indicate that the pc increments normally
    local bit pc_flag;

    // A signal to indicate that the instr busses should remain stable
    bit [31:0] prev_rdata;

    // A signal to indicate that indicates that fetch has not started yet
    local int req_before_fetch;
    local bit delay_one_cycle_id_ready;
    local bit delay_one_cycle_is_decoding;
    local bit misaligned_flag;

    // A signal to indicate the supposed value of the instruction address output
    local bit [31:0] local_instr_addr_o;

    // Register with factory
    `uvm_component_utils(cv32e40p_if_predictor)

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
    `uvm_info(get_type_name(), "Main phase", UVM_MEDIUM)
    forever begin 
        fork
            begin
                RST_n_fifo.get(rst_seq_item);
                fetch_flag  = 0;
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
        // Input transaction to Predict the output from
        cv32e40p_if_sequence_item mon_in_tx;

        // Creating at each loop iteration to prevent overwriting
		mon_in_tx = cv32e40p_if_sequence_item:: type_id :: create ("mon_in_tx");

        // Getting the Input transaction from the fifo        
		inputs_fifo.get(mon_in_tx);
        `uvm_info(get_type_name(), $sformatf("Inputs Sampled \n %s", mon_in_tx.sprint()), UVM_MEDIUM)

        if(~fetch_flag) begin
            `uvm_info(get_type_name(), "predict_fetch task called", UVM_MEDIUM)
            predict_fetch(mon_in_tx);
        end
        else begin
            `uvm_info(get_type_name(), "predict_stage_outputs task called", UVM_MEDIUM)
            predict_stage_outputs(mon_in_tx);
        end
	end
endtask : predict_outputs

/***************************************************************************************************************
/ check_fetch : This task checks that the fetch has been asserted, and then expects that it will be 0 next cycle
****************************************************************************************************************/
task predict_fetch(cv32e40p_if_sequence_item t);
    cv32e40p_if_sequence_item expected_output;
    expected_output  = cv32e40p_if_sequence_item::type_id::create("expected_output");
    if(t.fetch_enable_i) begin
        expected_output.fetch_enable_i = 0;
        expected_outputs_ap.write(expected_output);
        fetch_flag = 1;
    end
endtask : predict_fetch

/*********************************************************************************************
/ predict_stage_outputs : This task predicts the outputs of the stage according to the inputs
**********************************************************************************************/
task predict_stage_outputs(cv32e40p_if_sequence_item t);
    cv32e40p_if_sequence_item expected_output;
    expected_output  = cv32e40p_if_sequence_item::type_id::create("expected_output");
    if(t.instr_rvalid_i && req_queue.size() < 2) begin
        req_queue.push_back(t);
        predict_valid_output(t);
    end
    else if(~t.instr_rvalid_i && req_queue.size() < 2) begin
        expected_output.instr_addr_o = (req_before_fetch < 1) ? local_instr_addr_o : local_instr_addr_o + 4; // If no instruction has been fetched, set the address to 0, otherwise increment by 4
        expected_output.instr_valid_id  = 0;
        expected_output.instr_rdata_id  = 0;
        expected_output.fetch_enable_i  = 0; // Fetch should be disabled after the first instruction fetch
        req_before_fetch++; // Increment the request before fetch counter
        local_instr_addr_o = expected_output.instr_addr_o; // Reset the local instruction address
        expected_outputs_ap.write(expected_output);
    end
    else if(t.instr_rvalid_i && req_queue.size() >= 2) begin
        `uvm_warning(get_type_name(), "Request queue is full, req_o should not have been asserted")
        $display("queue size: %0d", req_queue.size());
    end

endtask : predict_stage_outputs

task predict_valid_output(cv32e40p_if_sequence_item t);
    cv32e40p_if_sequence_item expected_output, req, misaligned_req;
    expected_output  = cv32e40p_if_sequence_item::type_id::create("expected_output");
    req              = cv32e40p_if_sequence_item::type_id::create("req");
    misaligned_req   = cv32e40p_if_sequence_item::type_id::create("misaligned_req");
    expected_output.fetch_enable_i = 0; // Fetch should be disabled after the first instruction fetch
    if(t.instr_req_int && ~t.halt_if && t.id_ready && t.is_decoding) begin
        req = req_queue.pop_front();
        expected_output.instr_valid_id  = 1;
        expected_output.instr_rdata_id  = req.instr_rdata_i;
        // misaligned_flag = ((req.instr_rdata_i[1:0] != 2'b00) && ~misaligned_flag); // Check if the instruction is misaligned
        // if(misaligned_flag) begin
        //     misaligned_req.copy(req);
        //     req_queue.push_front(misaligned_req); // Check if the instruction is misaligned
        // end
        case(t.instr_rdata_i[6:0])
            OPCODE_JAL: begin // JAL
                expected_output.instr_addr_o   = local_instr_addr_o + {{12{req.instr_rdata_i[31]}}, req.instr_rdata_i[19:12], req.instr_rdata_i[20], req.instr_rdata_i[30:21], 1'b0};
            end
            OPCODE_JALR: begin // JALR
                $display("natta");
                expected_output.instr_addr_o   = (`rf[t.instr_rdata_i[19:15]] + {{20{req.instr_rdata_i[31]}}, req.instr_rdata_i[30:20]}) & ~32'h1;
            end
            OPCODE_B: begin // Branch
                if(t.pc_mux_id == PC_BRANCH) begin
                    expected_output.instr_addr_o   = local_instr_addr_o + {{20{req.instr_rdata_i[31]}}, req.instr_rdata_i[7], req.instr_rdata_i[30:25], req.instr_rdata_i[11:8], 1'b0};
                end
                else begin
                    expected_output.instr_addr_o   = local_instr_addr_o + 'h4; // Increment the instruction address by 4
                end
            end
            OPCODE_I, OPCODE_R, OPCODE_S, OPCODE_LOAD, OPCODE_AUIPC, OPCODE_LUI: begin // Other instructions
                expected_output.instr_addr_o   = local_instr_addr_o + 'h4;
            end
            default: begin
                `uvm_error(get_type_name(), $sformatf("Unknown instruction opcode: %b", t.instr_rdata_i[6:0]))
                expected_output.instr_addr_o   = local_instr_addr_o + 'h4; // Default to next instruction
            end
        endcase
        delay_one_cycle_id_ready = 0; // Reset the delay one cycle flag
        delay_one_cycle_is_decoding = 0; // Reset the delay one cycle flag
        local_instr_addr_o  = expected_output.instr_addr_o; // Update the local instruction address
        prev_rdata          = req.instr_rdata_i;
    end
    else if(~t.id_ready) begin
        if(delay_one_cycle_id_ready) begin
            // $display("mmm1");
            expected_output.instr_addr_o    = local_instr_addr_o; // Keep the previous instruction address
            expected_output.instr_valid_id  = 1;
            expected_output.instr_rdata_id  = prev_rdata;
        end
        else begin
            // $display("mmm2");
            expected_output.instr_addr_o    = local_instr_addr_o + 4; // Increment the instruction address by 4
            expected_output.instr_valid_id  = 1;     // Set the instruction valid flag
            expected_output.instr_rdata_id  = prev_rdata; // Keep the previous instruction data
        end
        delay_one_cycle_id_ready = (~t.id_ready); // If ID is not valid, delay the output by one cycle
        // if(~t.id_ready) delay_one_cycle = (t.id_ready); // If ID is not valid, delay the output by one cycle
        local_instr_addr_o  = expected_output.instr_addr_o; // Update the local instruction address;
    end
    else if(~t.is_decoding) begin
        req = req_queue.pop_front();
        if(delay_one_cycle_is_decoding) begin
            // $display("xxx1");
            expected_output.instr_addr_o    = local_instr_addr_o; // Keep the previous instruction address
            expected_output.instr_valid_id  = 1;
            expected_output.instr_rdata_id  = prev_rdata;
        end
        else begin
            // $display("xxx2");
            expected_output.instr_addr_o    = local_instr_addr_o + 4; // Increment the instruction address by 4
            expected_output.instr_valid_id  = 1;     // Set the instruction valid flag
            expected_output.instr_rdata_id  = req.instr_rdata_i; // Keep the previous instruction data
        end
        delay_one_cycle_is_decoding = (~t.is_decoding); // If ID is not valid, delay the output by one cycle
        // if(~t.id_ready) delay_one_cycle = (t.id_ready); // If ID is not valid, delay the output by one cycle
        local_instr_addr_o  = expected_output.instr_addr_o; // Update the local instruction address;        
    end
    expected_outputs_ap.write(expected_output);
    `uvm_info(get_type_name(), $sformatf("Expected Output Sampled \n %s", expected_output.sprint()), UVM_MEDIUM)
endtask : predict_valid_output

endclass : cv32e40p_if_predictor