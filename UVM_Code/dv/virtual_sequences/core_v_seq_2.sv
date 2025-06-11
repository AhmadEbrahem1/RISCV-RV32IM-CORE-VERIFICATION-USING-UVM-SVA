class core_v_seq_2 extends base_v_seq; 

	data_mem_slave_sequence	data_memory_sequence_h;
    //Registering the env class in the factory
    `uvm_object_utils(core_v_seq_2)

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "core_v_seq_2");
    super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
    `uvm_info(get_type_name(), "Inside Body Task", UVM_LOW);
	rst_sequence_h = rst_sequence::type_id::create("rst_sequence_h");

	R_sequence_h = R_sequence::type_id::create("R_sequence_h");
	R_sequence_h.loop_count = 200;
	S_sequence_h = S_sequence::type_id::create("S_sequence_h");
	S_sequence_h.loop_count = 200;
	U_sequence_h = U_sequence::type_id::create("U_sequence_h");
	U_sequence_h.loop_count = 400;

	B_sequence_h = B_Sequence::type_id::create("B_sequence_h");
	B_sequence_h.loop_count = 200;

	ADDI_sequence_h = ADDI_sequence::type_id::create("ADDI_sequence_h");
	ADDI_sequence_h.loop_count = 1000;

	
	MUL_sequence_h = MUL_sequence::type_id::create("MUL_sequence_h");
	MUL_sequence_h.loop_count = 500;
	
	data_memory_sequence_h = data_mem_slave_sequence::type_id::create("data_memory_sequence_h");

    do begin
		
		ADDI_sequence_h.start(p_sequencer.if_stage_sqr_h);
		MUL_sequence_h.start(p_sequencer.if_stage_sqr_h);
            	
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

endclass:core_v_seq_2
