class B_type_vseq extends base_v_seq;

  
    //Registering the env class in the factory
    `uvm_object_utils(B_type_vseq)
    int total_loop_count;
    cv32e40p_if_driver driver_handle;

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "B_type_vseq");
    super.new(name);
    total_loop_count = 0;
endfunction

virtual task pre_body();
    // Call super.pre_body() to preserve base class behavior
    super.pre_body();

    rst_sequence_h = rst_sequence::type_id::create("rst_sequence_h");


    BEQ_sequence_h = BEQ_sequence::type_id::create("BEQ_sequence_h");
	BEQ_sequence_h.loop_count = 5;

    ADDI_sequence_h = ADDI_sequence::type_id::create("ADDI_sequence_h");
	ADDI_sequence_h.loop_count = 5;

    BNE_sequence_h = BNE_sequence::type_id::create("BNE_sequence_h");
	BNE_sequence_h.loop_count = 5;


    BLT_sequence_h = BLT_sequence::type_id::create("BLT_sequence_h");
	BLT_sequence_h.loop_count = 5;


    BGE_sequence_h = BGE_sequence::type_id::create("BGE_sequence_h");
	BGE_sequence_h.loop_count = 5;


    BLTU_sequence_h = BLTU_sequence::type_id::create("BLTU_sequence_h");
	BLTU_sequence_h.loop_count = 5;


    BGEU_sequence_h = BGEU_sequence::type_id::create("BGEU_sequence_h");
	BGEU_sequence_h.loop_count = 5;


	data_memory_sequence_h = data_mem_slave_sequence::type_id::create("data_memory_sequence_h");

endtask

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
    `uvm_info(get_type_name(), "Inside Body Task", UVM_LOW);

	    do begin

		BEQ_sequence_h               .start(p_sequencer.if_stage_sqr_h);
        ADDI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
        BNE_sequence_h               .start(p_sequencer.if_stage_sqr_h);
        ADDI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
        BLT_sequence_h               .start(p_sequencer.if_stage_sqr_h);
        ADDI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
        BGE_sequence_h               .start(p_sequencer.if_stage_sqr_h);
        ADDI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
        BLTU_sequence_h              .start(p_sequencer.if_stage_sqr_h);
        ADDI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
        BGEU_sequence_h              .start(p_sequencer.if_stage_sqr_h);
        ADDI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
			
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
