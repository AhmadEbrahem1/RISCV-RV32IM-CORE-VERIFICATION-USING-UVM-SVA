class I_type_store_load_vseq extends base_v_seq;

  
    //Registering the env class in the factory
    `uvm_object_utils(I_type_store_load_vseq)
    cv32e40p_if_driver driver_handle;

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "I_type_store_load_vseq");
    super.new(name);
endfunction

virtual task pre_body();
    // Call super.pre_body() to preserve base class behavior
    super.pre_body();

    rst_sequence_h = rst_sequence::type_id::create("rst_sequence_h");


    SwLoad_sequence_h = SwLoad_sequence::type_id::create("SwLoad_sequence_h");    
	SwLoad_sequence_h.loop_count = 50;

    ShLoad_sequence_h = ShLoad_sequence::type_id::create("ShLoad_sequence_h");    
	ShLoad_sequence_h.loop_count = 50;

    SbLoad_sequence_h = SbLoad_sequence::type_id::create("SbLoad_sequence_h");    
	SbLoad_sequence_h.loop_count = 50;    

	data_memory_sequence_h = data_mem_slave_sequence::type_id::create("data_memory_sequence_h");

endtask

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
    `uvm_info(get_type_name(), "Inside Body Task", UVM_LOW);

	    do begin

		SwLoad_sequence_h.start(p_sequencer.if_stage_sqr_h);
        ShLoad_sequence_h.start(p_sequencer.if_stage_sqr_h);
        SbLoad_sequence_h.start(p_sequencer.if_stage_sqr_h);

        fork
            // begin
            //     rst_sequence_h.start(p_sequencer.rst_sqr_h);
            // end
	    begin
				//slave agent
				data_memory_sequence_h.start(p_sequencer.data_memory_sqr_h);
                
            end
            begin
               #test_timeout;
                `uvm_info(get_name,("TIME OUT!!"), UVM_LOW)
                // base_seq_item::cov_target=1;
                cv32e40p_rst_sequence_item::resets_done = 1;
            end
        join_any
        disable fork;
    end while /*((!base_seq_item::cov_target) ||*/ (!cv32e40p_rst_sequence_item::resets_done)/*)*/;
endtask

endclass
