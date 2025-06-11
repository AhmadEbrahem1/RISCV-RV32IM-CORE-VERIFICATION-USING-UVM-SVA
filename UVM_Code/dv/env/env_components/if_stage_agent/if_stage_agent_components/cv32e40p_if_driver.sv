
/******************************************************************
 * File: cv32e40p_if_driver.sv
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
class cv32e40p_if_driver extends uvm_driver #(cv32e40p_if_sequence_item);

    //Transaction Counter to report on
    protected int trans_count;


	
	/*
		To calculate Number of instructions use formula: (number of sequencesx200) + (number of regfile initializationx31)

	        test name        |  number of sequences  |  number of regfile initialization  |  number of instructions
		 M_Extension_test    |           3           |                 3				  |		      693
		 R_type_std_vseq     |           10          |                 1                  |           2031
		 I_type_std_vseq     |           9           |                 1                  |           1831
		 I_type_load_vseq    |           5           |                 1                  |           1031
	*/	 

	//Instruction memory 
	bit [31:0] RAM [$];
	bit req_received;
	
	mailbox drv_m_box;
	cv32e40p_if_sequence_item	req_1;
	cv32e40p_if_sequence_item	req_2;	
	
    //Registering the if_stage_driver class in the factory
    `uvm_component_utils_begin(cv32e40p_if_driver)
        `uvm_field_int(trans_count, UVM_DEFAULT)
    `uvm_object_utils_end

    //Reset Interface Virtual Interface Handle
    virtual cv32e40p_instruction_memory_if  cv32e40p_instruction_memory_vif;

    //Sequence Item Handle    

    //TLM Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_p_ap;
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_n_ap;

    //TLM FIFO Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_p_fifo;
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_n_fifo;

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name, uvm_component parent);
    super.new(name, parent);
	drv_m_box = new();
endfunction

/*******************************************************************
/ Build Phase : Has Creators, Getters, Setters & possible overrides
********************************************************************/
function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

    //Retrieve Virtual Interface from db
    if(!(uvm_config_db#(virtual cv32e40p_instruction_memory_if)::get(this, "", "cv32e40p_instruction_memory_vif", cv32e40p_instruction_memory_vif)))
        `uvm_fatal(get_type_name(), "Failed to get Virtual Interface Handle")

    //Create Sequence Items
    //seq_item = cv32e40p_if_sequence_item::type_id::create("seq_item");

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

	//initilize
    cv32e40p_instruction_memory_vif.instr_gnt_i 	= 1;
	cv32e40p_instruction_memory_vif.instr_rvalid_i 	= 0;
	cv32e40p_instruction_memory_vif.instr_rdata_i  	= 0;
	cv32e40p_instruction_memory_vif.fetch_enable_i	= 0;
	
	RST_n_fifo.get(rst_seq_item);
    RST_p_fifo.get(rst_seq_item);
	`uvm_info(get_type_name(), " First Reset Done", UVM_HIGH)
	phase.drop_objection(this);
endtask : reset_phase

/****************************************************************************************************
/ Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
*****************************************************************************************************/
task main_phase(uvm_phase phase);
    cv32e40p_rst_sequence_item rst_seq_item;
    forever begin
        fork
            RST_n_fifo.get(rst_seq_item);
			start_driving(); // Drive the transaction
        join_any
        disable fork;
        RST_p_fifo.get(rst_seq_item);
    end
endtask
	
// A task to start the driving process
task start_driving();
	fork
	    get_instructions();
	    sample_requests_and_drive();
	join 
endtask : start_driving

task get_instructions();
    cv32e40p_if_sequence_item req;
    bit break_loop = 0;  // Control variable to exit the loop

    forever begin : main_loop
        fork : parallel_block
            begin
                req = cv32e40p_if_sequence_item::type_id::create("req");
                seq_item_port.get_next_item(req);
                RAM.push_back(req.instruction);
                seq_item_port.item_done();
            end
            
            begin
                #1ns;
                break_loop = 1;  // Set flag to exit the loop (instead of disable)
            end
        join_any

        // Exit the forever loop if break_loop is set
        if (break_loop) break;
    end : main_loop

    $display("Total instructions stored = %0d", RAM.size());

    // Continue with the rest of the task
    @(cv32e40p_instruction_memory_vif.cb_drv);
    cv32e40p_instruction_memory_vif.cb_drv.fetch_enable_i <= 1;
    @(cv32e40p_instruction_memory_vif.cb_drv);
    cv32e40p_instruction_memory_vif.cb_drv.fetch_enable_i <= 0;
    @(cv32e40p_instruction_memory_vif.cb_drv);
endtask : get_instructions



task sample_requests_and_drive();
	fork
		sample_and_send;
		send_response;
	join
endtask : sample_requests_and_drive

task sample_and_send();
	cv32e40p_if_sequence_item	req_tmp;
	forever
	begin
		req_1 =  cv32e40p_if_sequence_item:: type_id :: create ("req_1");
		req_tmp =  cv32e40p_if_sequence_item:: type_id :: create ("req_tmp");
		if  (cv32e40p_instruction_memory_vif.cb_drv.instr_req_o == 0 ) begin
			@(cv32e40p_instruction_memory_vif.cb_drv);
        end
		else begin
			req_1.instr_addr_o	=	cv32e40p_instruction_memory_vif.cb_drv.instr_addr_o;
			req_1.instr_req_o	= 	cv32e40p_instruction_memory_vif.cb_drv.instr_req_o;
			if(req_1.instr_addr_o[31:2] > RAM.size())
			begin
				`uvm_info("instr mem","instructionns are all fetched",UVM_LOW)				
				cv32e40p_instruction_memory_vif.instr_gnt_i 	= 0;
				break;

			end
			//removed:
			req_1.valid_delay 	= 0;
			//copy to req_tmp
			req_tmp.instr_addr_o = req_1.instr_addr_o ;
			req_tmp.instr_req_o= req_1.instr_req_o;
			req_tmp.valid_delay= req_1.valid_delay;
			//put in mailbox for other task
			drv_m_box.put(req_tmp);
			//wait till next clk 
			@(cv32e40p_instruction_memory_vif.cb_drv);
		end 
	end		
endtask : sample_and_send

task send_response();
	
	forever begin
		req_2 = cv32e40p_if_sequence_item:: type_id :: create ("req_2");
		if  (cv32e40p_instruction_memory_vif.cb_drv.instr_req_o == 0 ) begin
			cv32e40p_instruction_memory_vif.cb_drv.instr_rvalid_i	<= 0;
			@(cv32e40p_instruction_memory_vif.cb_drv);
        end
		else 
		begin
		
			drv_m_box.get(req_2);
			if(req_2.instr_req_o ==1) begin
				if(req_2.valid_delay == 0) begin
					cv32e40p_instruction_memory_vif.cb_drv.instr_rdata_i 	<= RAM[req_2.instr_addr_o[31:2]];
					cv32e40p_instruction_memory_vif.cb_drv.instr_rvalid_i	<= 1;
				end
				else begin
					cv32e40p_instruction_memory_vif.cb_drv.instr_rvalid_i	<= 0;
					repeat(req_2.valid_delay)
					@(cv32e40p_instruction_memory_vif.cb_drv);
					cv32e40p_instruction_memory_vif.cb_drv.instr_rvalid_i	<= 1;
					cv32e40p_instruction_memory_vif.cb_drv.instr_rdata_i 	<= RAM[req_2.instr_addr_o[31:2]];
					
				end
				
				@(cv32e40p_instruction_memory_vif.cb_drv);
		
				//2nd tx
				if(req_2.valid_delay == 0) begin
					if (cv32e40p_instruction_memory_vif.cb_drv.instr_req_o) begin
						drv_m_box.get(req_2);
						cv32e40p_instruction_memory_vif.cb_drv.instr_rvalid_i	<= 1;
						cv32e40p_instruction_memory_vif.cb_drv.instr_rdata_i 	<= RAM[req_2.instr_addr_o[31:2]];
					end
					else begin
						cv32e40p_instruction_memory_vif.cb_drv.instr_rvalid_i	<= 0;
					end
				end
				else begin
					if( drv_m_box.try_get(req_2)) begin
						cv32e40p_instruction_memory_vif.cb_drv.instr_rvalid_i	<= 1;
						cv32e40p_instruction_memory_vif.cb_drv.instr_rdata_i 	<= RAM[req_2.instr_addr_o[31:2]];
					end
					else begin
						cv32e40p_instruction_memory_vif.cb_drv.instr_rvalid_i	<= 0;
					end
				end
				@(cv32e40p_instruction_memory_vif.cb_drv);
			end
		end 
	end		
endtask : send_response


/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
`uvm_info(get_type_name(),$sformatf("\nInstruction Fetch Stage Driver Report:\n\tTotal Transactions driven: %0d",trans_count), UVM_MEDIUM)

`uvm_info(get_type_name(), "Instruction Fetch Stage Driver Report Phase Complete", UVM_MEDIUM)
endfunction : report_phase

endclass : cv32e40p_if_driver
