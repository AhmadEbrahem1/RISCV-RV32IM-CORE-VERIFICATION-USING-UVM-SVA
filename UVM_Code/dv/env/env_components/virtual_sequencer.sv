class virtual_sequencer extends uvm_sequencer;

    //Registering the env class in the factory
    `uvm_component_utils(virtual_sequencer)

    // All Agents' sequencers handles
    cv32e40p_rst_sequencer	            rst_sqr_h;
    cv32e40p_if_sequencer               if_stage_sqr_h;
    cv32e40p_data_memory_if_sequencer   data_memory_sqr_h;
    cv32e40p_debug_if_sequencer         dbg_if_sqr_h;
    cv32e40p_interrupt_sequencer        isr_if_sqr_h;
/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
endfunction

endclass : virtual_sequencer
