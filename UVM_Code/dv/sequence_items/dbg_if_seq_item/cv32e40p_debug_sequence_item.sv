class cv32e40p_debug_sequence_item extends base_sequence_item;

    // Declare the properties of the sequence item
    rand    bit        debug_req_i;
    rand    bit [31:0] dm_halt_addr_i;
    rand    bit [31:0] dm_exception_addr_i;
            bit        debug_havereset_o;
            bit        debug_running_o;
            bit        debug_halted_o;

    //Registering the class in factory& alongside its properties
    `uvm_object_utils_begin(cv32e40p_debug_sequence_item)
        //inputs
        `uvm_field_int(debug_req_i, UVM_ALL_ON | UVM_NOCOMPARE) // make an enum
        `uvm_field_int(dm_halt_addr_i, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE)
        `uvm_field_int(dm_exception_addr_i, UVM_ALL_ON | UVM_HEX | UVM_NOCOMPARE)
        //outputs
        `uvm_field_int(debug_havereset_o, UVM_ALL_ON) // make an enum
        `uvm_field_int(debug_running_o, UVM_ALL_ON) // make an enum
        `uvm_field_int(debug_halted_o, UVM_ALL_ON) // make an enum
    `uvm_object_utils_end

endclass : cv32e40p_debug_sequence_item