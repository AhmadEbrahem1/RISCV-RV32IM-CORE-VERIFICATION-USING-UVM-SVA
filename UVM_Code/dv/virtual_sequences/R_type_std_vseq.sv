class R_type_std_vseq extends base_v_seq;

  
    //Registering the env class in the factory
    `uvm_object_utils(R_type_std_vseq)
    int total_loop_count;
    cv32e40p_if_driver driver_handle;

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "R_type_std_vseq");
    super.new(name);
    total_loop_count = 0;
endfunction

virtual task pre_body();
    // Call super.pre_body() to preserve base class behavior
    super.pre_body();

    rst_sequence_h = rst_sequence::type_id::create("rst_sequence_h");

    Regfile_Initialize_sequence_h = Regfile_Initialize_sequence::type_id::create("Regfile_Initialize_sequence_h");

    ADD_sequence_h = ADD_sequence::type_id::create("ADD_sequence_h");
	ADD_sequence_h.loop_count = 200;

    SUB_sequence_h = SUB_sequence::type_id::create("SUB_sequence_h");
	SUB_sequence_h.loop_count = 200;

    XOR_sequence_h = XOR_sequence::type_id::create("XOR_sequence_h");
	XOR_sequence_h.loop_count = 200;

    OR_sequence_h = OR_sequence::type_id::create("OR_sequence_h");
	OR_sequence_h.loop_count = 200;

    AND_sequence_h = AND_sequence::type_id::create("AND_sequence_h");
	AND_sequence_h.loop_count = 200;

    SLL_sequence_h = SLL_sequence::type_id::create("SLL_sequence_h");
	SLL_sequence_h.loop_count = 200;

    SRL_sequence_h = SRL_sequence::type_id::create("SRL_sequence_h");
	SRL_sequence_h.loop_count = 200;

    SRA_sequence_h = SRA_sequence::type_id::create("SRA_sequence_h");
	SRA_sequence_h.loop_count = 200;

    SLT_sequence_h = SLT_sequence::type_id::create("SLT_sequence_h");
	SLT_sequence_h.loop_count = 200;

    SLTU_sequence_h = SLTU_sequence::type_id::create("SLTU_sequence_h");
	SLTU_sequence_h.loop_count = 200;

	data_memory_sequence_h = data_mem_slave_sequence::type_id::create("data_memory_sequence_h");

endtask

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
    `uvm_info(get_type_name(), "Inside Body Task", UVM_LOW);

	    do begin

		Regfile_Initialize_sequence_h.start(p_sequencer.if_stage_sqr_h);

		ADD_sequence_h               .start(p_sequencer.if_stage_sqr_h);
		SUB_sequence_h               .start(p_sequencer.if_stage_sqr_h);
		XOR_sequence_h               .start(p_sequencer.if_stage_sqr_h);
        OR_sequence_h                .start(p_sequencer.if_stage_sqr_h);
		AND_sequence_h               .start(p_sequencer.if_stage_sqr_h);
		SLL_sequence_h               .start(p_sequencer.if_stage_sqr_h);
        SRL_sequence_h               .start(p_sequencer.if_stage_sqr_h);
		SRA_sequence_h               .start(p_sequencer.if_stage_sqr_h);
		SLT_sequence_h               .start(p_sequencer.if_stage_sqr_h);
        SLTU_sequence_h              .start(p_sequencer.if_stage_sqr_h);
			
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
