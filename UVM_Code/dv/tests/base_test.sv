class base_test extends uvm_test;
  
  
    // Virtual ALU interface handle  
    cv32e40p_test_config test_cfg;
    cv32e40p_env_config env_cfg;
  
    // Environment instance
    cv32e40p_env env_h;
    base_v_seq v_seq;
  
    // Register with factory
    `uvm_component_utils(base_test)
  
/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

/*********************************************************
/ Build Phase : Has Creators, Getters & possible overrides
**********************************************************/
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_full_name(), "Build phase", UVM_LOW)

    // Create environment
    env_h = cv32e40p_env::type_id::create("env_h", this);

    // Set verbosity level
    uvm_top.set_report_verbosity_level(UVM_LOW);

    uvm_config_db#(string)::set(this,"*","test_name",get_type_name());

    //setter and getter for rst interface    
    if(!uvm_config_db#(cv32e40p_test_config)::get(this, "", "test_cfg", test_cfg))
        `uvm_fatal(get_type_name(),{"Failed to get config",get_full_name()});

    // Create and set environment configuration
    env_cfg = cv32e40p_env_config::type_id::create("env_cfg");
    env_cfg.initialize( test_cfg.if_agent_get_is_active(), 
                        test_cfg.id_agent_get_is_active(),
                        test_cfg.ie_agent_get_is_active(), 
                        test_cfg.data_memory_agent_get_is_active(),
                        test_cfg.debug_if_agent_get_is_active(), 
                        test_cfg.interrupt_if_agent_get_is_active(),
                        test_cfg.rst_agent_get_is_active(),
                        test_cfg.cv32e40p_instruction_memory_vif, 
                        test_cfg.cv32e40p_internal_vif,
                        test_cfg.cv32e40p_data_memory_vif, 
                        test_cfg.cv32e40p_debug_vif, 
                        test_cfg.cv32e40p_interrupt_vif, 
                        test_cfg.cv32e40p_rst_vif);

    uvm_config_db#(cv32e40p_env_config)::set(this,"env_h","env_cfg",env_cfg);

    // Configure reset count
    cv32e40p_rst_sequence_item::number_of_resets_per_test = test_cfg.no_of_resets;

endfunction : build_phase

/*********************************************************
/ Arbitiration Mode Method
**********************************************************/

virtual task cfg_arb_mode;
endtask

/**********************************************************
/ End of Elaboration Phase : Has minor adjustments 
/ to the hierarchy before starting he run: TLM debugging
***********************************************************/
function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info(get_full_name(), "End of elaboration phase", UVM_LOW)
    // Print the topology
    uvm_top.print_topology();
endfunction : end_of_elaboration_phase
 
 
 
task reset_phase(uvm_phase phase);
	
	phase.raise_objection(this);
	phase.drop_objection(this);
endtask : reset_phase


 
/****************************************************************************************************
/ Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
*****************************************************************************************************/
task main_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_full_name(), "Main phase", UVM_LOW)

    v_seq 	= base_v_seq::type_id::create("v_seq", this);
    v_seq.test_timeout = test_cfg.test_timeout;

    // Raise objection to keep the test from completing
    phase.raise_objection(this);
    // cfg_arb_mode();
    // `uvm_info(get_name, $sformatf("Arbitration mode for ALU SQR = %s", env_h.alu_agent_h.sequencer_h.get_arbitration()), UVM_LOW);
    // `uvm_info(get_name, $sformatf("Arbitration mode for RST SQR = %s", env_h.rst_agent_h.sequencer_h.get_arbitration()), UVM_LOW);

    //v_seq.start(null); //virtual sequences can be started on NULL/no sequencer
    v_seq.start(env_h.v_sqr);

    `uvm_info(get_type_name(), "Base test started", UVM_HIGH)
        
    `uvm_info(get_type_name(), "Base test completed", UVM_MEDIUM)

    // Drop objection to allow the test to complete :(
    phase.drop_objection(this);
endtask : main_phase

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
    uvm_report_server server = uvm_report_server::get_server();

    if (server.get_severity_count(UVM_FATAL) + server.get_severity_count(UVM_ERROR) == 0)
        `uvm_info(get_type_name(), "TEST PASSED", UVM_LOW)
    else
        `uvm_info(get_type_name(), "TEST FAILED", UVM_LOW)
endfunction : report_phase
  
endclass : base_test