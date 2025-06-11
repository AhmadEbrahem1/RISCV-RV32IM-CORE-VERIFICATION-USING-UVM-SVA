class cv32e40p_interrupt_sequence_item extends base_sequence_item;

    // Declare the properties of the sequence item
    rand    bit       [31:0]    irq_i;
            logic               irq_ack_o;
            logic     [ 4:0]    irq_id_o; 

    //Registering the class in factory& alongside its properties
    `uvm_object_utils_begin(cv32e40p_interrupt_sequence_item)
        //inputs
        `uvm_field_int(irq_i, UVM_ALL_ON | UVM_HEX) // make an enum
        //outputs
        `uvm_field_int(irq_ack_o, UVM_ALL_ON) // make an enum
        `uvm_field_int(irq_id_o, UVM_ALL_ON) // make an enum
    `uvm_object_utils_end

endclass : cv32e40p_interrupt_sequence_item