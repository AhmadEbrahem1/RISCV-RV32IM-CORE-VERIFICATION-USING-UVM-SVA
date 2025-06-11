class I_type_std_vseq extends base_v_seq;

  
    //Registering the env class in the factory
    `uvm_object_utils(I_type_std_vseq)
    int total_loop_count;
    cv32e40p_if_driver driver_handle;

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "I_type_std_vseq");
    super.new(name);
    total_loop_count = 0;
endfunction

virtual task pre_body();
    // Call super.pre_body() to preserve base class behavior
    super.pre_body();

    rst_sequence_h = rst_sequence::type_id::create("rst_sequence_h");

    Regfile_Initialize_sequence_h = Regfile_Initialize_sequence::type_id::create("Regfile_Initialize_sequence_h");

    ADDI_sequence_h = ADDI_sequence::type_id::create("ADDI_sequence_h");
	ADDI_sequence_h.loop_count = 200;

    XORI_sequence_h = XORI_sequence::type_id::create("XORI_sequence_h");
	XORI_sequence_h.loop_count = 200;

    ORI_sequence_h = ORI_sequence::type_id::create("ORI_sequence_h");
	ORI_sequence_h.loop_count = 200;

    ANDI_sequence_h = ANDI_sequence::type_id::create("ANDI_sequence_h");
	ANDI_sequence_h.loop_count = 200;

    SLLI_sequence_h = SLLI_sequence::type_id::create("SLLI_sequence_h");
	SLLI_sequence_h.loop_count = 200;

    SRLI_sequence_h = SRLI_sequence::type_id::create("SRLI_sequence_h");
	SRLI_sequence_h.loop_count = 200;

    SRAI_sequence_h = SRAI_sequence::type_id::create("SRAI_sequence_h");
	SRAI_sequence_h.loop_count = 200;

    SLTI_sequence_h = SLTI_sequence::type_id::create("SLTI_sequence_h");
	SLTI_sequence_h.loop_count = 200;

    SLTIU_sequence_h = SLTIU_sequence::type_id::create("SLTIU_sequence_h");
	SLTIU_sequence_h.loop_count = 200;

	data_memory_sequence_h = data_mem_slave_sequence::type_id::create("data_memory_sequence_h");

endtask

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
    `uvm_info(get_type_name(), "Inside Body Task", UVM_LOW);

	    do begin

		Regfile_Initialize_sequence_h.start(p_sequencer.if_stage_sqr_h);

		ADDI_sequence_h               .start(p_sequencer.if_stage_sqr_h);
        XORI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
		ORI_sequence_h               .start(p_sequencer.if_stage_sqr_h);
		ANDI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
		SLLI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
        SRLI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
		SRAI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
		SLTI_sequence_h              .start(p_sequencer.if_stage_sqr_h);
        SLTIU_sequence_h             .start(p_sequencer.if_stage_sqr_h);
			
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
