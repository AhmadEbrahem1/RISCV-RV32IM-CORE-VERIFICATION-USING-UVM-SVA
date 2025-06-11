class cv32e40p_rst_sequencer extends uvm_sequencer#(cv32e40p_rst_sequence_item);

    //Registering the rst_driver class in the factory
    `uvm_component_utils(cv32e40p_rst_sequencer)

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name, uvm_component parent);
    super.new(name, parent);
endfunction

endclass : cv32e40p_rst_sequencer