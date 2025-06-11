// `uvm_analysis_imp_decl(_reset)
class cv32e40p_interrupt_sequencer extends uvm_sequencer#(cv32e40p_interrupt_sequence_item);

    //Registering the isr_if_driver class in the factory
    `uvm_component_utils(cv32e40p_interrupt_sequencer) 

    //Sequence Item Handle  
    cv32e40p_rst_sequence_item rst_seq_item;

    //TLM Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_analysis_imp_reset #(cv32e40p_rst_sequence_item, cv32e40p_interrupt_sequencer) RST_imp;


/*****************************************************************************
/ Constructor : is responsible for the construction of objects and components
******************************************************************************/
function new(string name, uvm_component parent);
    super.new(name,parent);
endfunction

/*******************************************************************
/ Build Phase : Has Creators, Getters, Setters & possible overrides
********************************************************************/
function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

    //Create Sequence Item
    rst_seq_item = cv32e40p_rst_sequence_item::type_id::create("rst_seq_item");

    //Create TLM ports
    RST_imp = new("RST_imp", this);

endfunction : build_phase

/*******************************************************************
/ Build Phase : Has Creators, Getters, Setters & possible overrides
********************************************************************/
virtual function void write_reset(cv32e40p_rst_sequence_item t);
    `uvm_info(get_type_name(), "stop sequences called", UVM_MEDIUM)

    stop_sequences();
endfunction : write_reset


endclass : cv32e40p_interrupt_sequencer

