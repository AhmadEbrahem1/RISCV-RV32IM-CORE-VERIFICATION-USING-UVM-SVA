class Hazard_vseq extends base_v_seq; 

	data_mem_slave_sequence	data_memory_sequence_h;
    //Registering the env class in the factory
    `uvm_object_utils(Hazard_vseq)

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "Hazard_vseq");
    super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
    `uvm_info(get_type_name(), "Inside Body Task", UVM_LOW);
	rst_sequence_h = rst_sequence::type_id::create("rst_sequence_h");

	Hazard_sequence_h = Hazard_sequence::type_id::create("Hazard_sequence_h");
	Hazard_sequence_h.loop_count = 5;
	

	NOP_sequence_h = NOP_sequence::type_id::create("NOP_sequence_h");
	NOP_sequence_h.loop_count = 1490;
	
	data_memory_sequence_h = data_mem_slave_sequence::type_id::create("data_memory_sequence_h");

    do begin
		//basic_ test case : ADDI, store operations, U instructions
		Hazard_sequence_h.start(p_sequencer.if_stage_sqr_h);
		//NOP_sequence_h.start(p_sequencer.if_stage_sqr_h);
		
		//B_sequence_h.start(p_sequencer.if_stage_sqr_h);
            	
        fork
	    begin
				//slave agent
				data_memory_sequence_h.start(p_sequencer.data_memory_sqr_h);
                
            end
            begin
               #test_timeout;
                `uvm_info(get_name,("TIME OUT!!"), UVM_LOW)
                cv32e40p_rst_sequence_item::resets_done = 1;
            end
        join_any
        disable fork;
    end while /*((!base_seq_item::cov_target) ||*/ (!cv32e40p_rst_sequence_item::resets_done)/*)*/;
endtask

endclass:Hazard_vseq
