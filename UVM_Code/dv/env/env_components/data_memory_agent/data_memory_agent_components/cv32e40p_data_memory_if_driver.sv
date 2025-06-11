/******************************************************************
 * File: cv32e40p_data_memory_if_driver.sv
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
class cv32e40p_data_memory_if_driver extends uvm_driver #(cv32e40p_data_memory_sequence_item);

	//cv32e40p_data_memory_sequence_item q_tx[$:2];
	mailbox drv_m_box;
	rand int gnt_delay;

    //Transaction Counter to report on
    protected int trans_count;

    //Registering the cv32e40p_data_memory_if_driver class in the factory
    `uvm_component_utils_begin(cv32e40p_data_memory_if_driver)
        `uvm_field_int(trans_count, UVM_DEFAULT)
    `uvm_object_utils_end

    //Reset Interface Virtual Interface Handle
    virtual cv32e40p_data_memory_if vif;

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
    if(!(uvm_config_db#(virtual cv32e40p_data_memory_if)::get(this, "", "vif", vif)))
        `uvm_fatal(get_type_name(), "Failed to get Virtual Interface Handle")

    //Create Sequence Items
    //seq_item = cv32e40p_data_memory_sequence_item::type_id::create("seq_item");

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
	vif.data_gnt_i		= 1;
	vif.data_rvalid_i	= 0;
	vif.data_rdata_i	= 0;
	
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
    `uvm_info(get_type_name(), "Main phase", UVM_MEDIUM)

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
			
		forever begin
            @(negedge vif.clk_i);
			fork
                sample_and_send();
                send_response();
                //grant_task();
			join
		end
endtask : start_driving

//
task sample_and_send();
	cv32e40p_data_memory_sequence_item req;
	cv32e40p_data_memory_sequence_item rsp;
    forever begin
        req =  cv32e40p_data_memory_sequence_item:: type_id :: create ("req");
        rsp =  cv32e40p_data_memory_sequence_item:: type_id :: create ("rsp");
        
		if  ((vif.cb_drv.data_req_o == 0)  || (vif.cb_mon.data_gnt_i == 0) ) begin
			@( vif.cb_drv);
        end
		else 
		begin
			// get req from sequence
			seq_item_port.get_next_item(req);
			req.data_req_o 		 = vif.cb_drv.data_req_o;
			req.data_we_o        = vif.cb_drv.data_we_o;
			req.data_be_o        = vif.cb_drv.data_be_o;
			req.data_addr_o      = vif.cb_drv.data_addr_o;
			req.data_wdata_o     = vif.cb_drv.data_wdata_o;
	
			seq_item_port.item_done();
			//get respinse from sequence 
			seq_item_port.get_next_item(rsp);
			//q_tx.push_back(rsp);
			drv_m_box.put(rsp.clone());
			seq_item_port.item_done();
	
			//wait till next clk 
			@( vif.cb_drv);
		end 
    end
endtask : sample_and_send

//
task send_response();
	cv32e40p_data_memory_sequence_item rsp_drv;
    forever begin
        rsp_drv = cv32e40p_data_memory_sequence_item:: type_id :: create ("rsp_drv");
        //wait (q_tx.size()!=0);
        if  (vif.cb_drv.data_req_o == 0 ) begin
			vif.cb_drv.data_rvalid_i	<= 0;
			@( vif.cb_drv);
        end
		else 
		begin
        
			drv_m_box.get(rsp_drv) ;
			if(rsp_drv.data_req_o ==1) begin
				if(rsp_drv.valid_delay == 0) begin
					vif.cb_drv.data_rvalid_i <= 1;
				end
				else begin
					vif.cb_drv.data_rvalid_i <= 0;
					repeat(rsp_drv.valid_delay)
					@( vif.cb_drv);
					vif.cb_drv.data_rvalid_i	<= 1;
					vif.cb_drv.data_rdata_i 	<= rsp_drv.data_rdata_i;
				end
		
				@( vif.cb_drv);
				
				//2nd tx
				if(rsp_drv.valid_delay == 0) begin
					if (vif.cb_drv.data_req_o &&  vif.cb_mon.data_gnt_i) begin
						drv_m_box.get(rsp_drv);
						vif.cb_drv.data_rvalid_i	<= 1;
						vif.cb_drv.data_rdata_i 	<= rsp_drv.data_rdata_i;
					end
					else begin
						vif.cb_drv.data_rvalid_i <= 0;
					end
				end
				else begin
					if( drv_m_box.try_get(rsp_drv)) begin
						vif.cb_drv.data_rvalid_i <= 1;
						vif.cb_drv.data_rdata_i  <= rsp_drv.data_rdata_i;
					end
					else begin
						vif.cb_drv.data_rvalid_i <= 0;
					end
				end
				
				@( vif.cb_drv);
			end 
		end 
    end
endtask : send_response

//
task grant_task();
    int num_tx;
    forever begin
        while (!vif.cb_drv.data_req_o ||  !vif.cb_mon.data_gnt_i) begin     
            @( vif.cb_drv);
        end
        num_tx++;

        if (num_tx == 2) begin 
            num_tx = 0;
            randcase
            20: begin
                vif.cb_drv.data_gnt_i <= 0; 
                // # time
                gnt_delay = $urandom_range(4, 8);
                repeat(gnt_delay)
                @( vif.cb_drv);
                vif.cb_drv.data_gnt_i <= 1; 
            end
            30: begin
                vif.cb_drv.data_gnt_i <= 0; 
                while (!vif.cb_drv.data_req_o)
                @( vif.cb_drv);
                //next clk give grnt
                @( vif.cb_drv);
                vif.cb_drv.data_gnt_i <= 1; 
            end
            50: begin
                vif.cb_drv.data_gnt_i <= 1; 
                gnt_delay = $urandom_range(10, 20);
                repeat(gnt_delay)
                    @( vif.cb_drv);
            end
            endcase
        end
        @( vif.cb_drv);  
    end
endtask : grant_task

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
`uvm_info(get_type_name(), 
            $sformatf("\nData Memory Interface Driver Report:\n\tTotal Transactions driven: %0d",trans_count), UVM_MEDIUM)

`uvm_info(get_type_name(), "Data Memory Interface Driver Report Phase Complete", UVM_MEDIUM)
endfunction : report_phase

endclass : cv32e40p_data_memory_if_driver
