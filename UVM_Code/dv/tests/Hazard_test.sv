//---------------------------------------
// Random test - basic test with random operations
//---------------------------------------
class Hazard_test extends base_test;

  // Register with factory
  `uvm_component_utils(Hazard_test)

    // uvm stuff
    string plusargs_queue[$];
    uvm_cmdline_processor cmd;

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "Hazard_test", uvm_component parent = null);
    super.new(name, parent);    
endfunction : new

/*********************************************************
/ Build Phase : Has Creators, Getters & possible overrides
**********************************************************/
virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // override virtual sequence
    base_v_seq::type_id::set_type_override(Hazard_vseq::type_id::get());

    // Create Virtual sequence instance
    v_seq = base_v_seq::type_id::create("v_seq", this);

    // Override base_sequence_item with the agent's respective sequence item which it uses
    uvm_factory::get().set_inst_override_by_type(
        base_sequence_item::get_type(), 
        cv32e40p_if_sequence_item::get_type(),
        "uvm_test_top.env_h.if_stage_agt.*"
    );

    uvm_factory::get().set_inst_override_by_type(
        base_sequence_item::get_type(), 
        cv32e40p_id_sequence_item::get_type(),
        "uvm_test_top.env_h.id_stage_agt.*"
    );

    // uvm_factory::get().set_inst_override_by_type(
    //     base_sequence_item::get_type(), 
    //     ie_stage_sequence_item::get_type(),
    //     "uvm_test_top.env_h.ie_stage_agt.*"
    // );

    uvm_factory::get().set_inst_override_by_type(
        base_sequence_item::get_type(), 
        cv32e40p_data_memory_sequence_item::get_type(),
        "uvm_test_top.env_h.data_memory_agt.*"
    );

    uvm_factory::get().set_inst_override_by_type(
        base_sequence_item::get_type(), 
        cv32e40p_debug_sequence_item::get_type(),
        "uvm_test_top.env_h.dbg_if_agt.*"
    );

    uvm_factory::get().set_inst_override_by_type(
        base_sequence_item::get_type(), 
        cv32e40p_interrupt_sequence_item::get_type(),
        "uvm_test_top.env_h.isr_if_agt.*"
    );


    // cmd = uvm_cmdline_processor::get_inst();
    // cmd.get_plusargs(plusargs_queue);
    // `uvm_info (get_type_name(), $sformatf("PLUSARGS = %p", plusargs_queue), UVM_LOW)
endfunction : build_phase

/***********************
/ Set Arbitration mode
/***********************/
task cfg_arb_mode;
    //env_h.alu_agnt.sequencer.set_arbitration(UVM_SEQ_ARB_WEIGHTED);
endtask

  /*---------------------------------------
  Arbitration modes
  1. UVM_SEQ_ARB_FIFO
  2. UVM_SEQ_ARB_WEIGHTED
  3. UVM_SEQ_ARB_RANDOM
  4. UVM_SEQ_ARB_STRICT_FIFO
  5. UVM_SEQ_ARB_STRICT_RANDOM
  6. UVM_SEQ_ARB_USER
  ----------------------------------------*/


endclass : Hazard_test
