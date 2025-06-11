class I_type_load_vseq extends base_v_seq;

  
    //Registering the env class in the factory
    `uvm_object_utils(I_type_load_vseq)
    cv32e40p_if_driver driver_handle;

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "I_type_load_vseq");
    super.new(name);
endfunction

virtual task pre_body();
    // Call super.pre_body() to preserve base class behavior
    super.pre_body();

    rst_sequence_h = rst_sequence::type_id::create("rst_sequence_h");

    Regfile_Initialize_sequence_for_loadInstr_h = Regfile_Initialize_sequence_for_loadInstr::type_id::create("Regfile_Initialize_sequence_for_loadInstr_h");

    LB_sequence_h = LB_sequence::type_id::create("LB_sequence_h");    
	LB_sequence_h.loop_count = 200;

    LH_sequence_h = LH_sequence::type_id::create("LH_sequence_h");    
	LH_sequence_h.loop_count = 200;

    LW_sequence_h = LW_sequence::type_id::create("LW_sequence_h");       
	LW_sequence_h.loop_count = 200;

    LBU_sequence_h = LBU_sequence::type_id::create("LBU_sequence_h");   
	LBU_sequence_h.loop_count = 200;

    LHU_sequence_h = LHU_sequence::type_id::create("LHU_sequence_h");    
	LHU_sequence_h.loop_count = 200;


	data_memory_sequence_h = data_mem_slave_sequence::type_id::create("data_memory_sequence_h");

endtask

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
    `uvm_info(get_type_name(), "Inside Body Task", UVM_LOW);

	    do begin

		Regfile_Initialize_sequence_for_loadInstr_h.start(p_sequencer.if_stage_sqr_h);

		LB_sequence_h                .start(p_sequencer.if_stage_sqr_h);
        LH_sequence_h                .start(p_sequencer.if_stage_sqr_h);
		LW_sequence_h                .start(p_sequencer.if_stage_sqr_h);
		LBU_sequence_h               .start(p_sequencer.if_stage_sqr_h);
        LHU_sequence_h               .start(p_sequencer.if_stage_sqr_h);

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
