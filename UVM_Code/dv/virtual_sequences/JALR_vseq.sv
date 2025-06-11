class JALR_vseq extends base_v_seq; 

	data_mem_slave_sequence	data_memory_sequence_h;
    //Registering the env class in the factory
    `uvm_object_utils(JALR_vseq)

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "JALR_vseq");
    super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
    `uvm_info(get_type_name(), "Inside Body Task", UVM_MEDIUM);
	rst_sequence_h = rst_sequence::type_id::create("rst_sequence_h");

	JALR_sequence_h =JALR_sequence::type_id::create("JALR_sequence_h");
	JALR_sequence_h.loop_count=10;
	data_memory_sequence_h = data_mem_slave_sequence::type_id::create("data_memory_sequence_h");

    do begin
		//test case : store > hazards scenarios > nop
		
		JALR_sequence_h.start(p_sequencer.if_stage_sqr_h);
		
		//NOP_sequence_h.start(p_sequencer.if_stage_sqr_h);
		
        fork
	    begin
				//slave agent
				data_memory_sequence_h.start(p_sequencer.data_memory_sqr_h);
                
            end
            begin
               #test_timeout;
                `uvm_info(get_name,("TIME OUT!!"), UVM_MEDIUM)
                cv32e40p_rst_sequence_item::resets_done = 1;
            end
        join_any
        disable fork;
    end while /*((!base_seq_item::cov_target) ||*/ (!cv32e40p_rst_sequence_item::resets_done)/*)*/;
endtask

endclass:JALR_vseq
