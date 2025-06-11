class base_sequence_item extends uvm_sequence_item;

    //A transaction ID for the scoreboard to use to organise its operation
    local static int unsigned pkt_ID;

    //Counters used to make sure the test doesn't end before all transactions are sampled & compared
    static int expected_txn_counter;
    static int actual_txn_counter;

    //Used to randomize sequences in an array of sequences
    rand int unsigned sequence_randomizer;

    //Registering the env class in the factory
 	`uvm_object_utils_begin(base_sequence_item)
        `uvm_field_int(pkt_ID,UVM_ALL_ON)
        `uvm_field_int(expected_txn_counter,UVM_ALL_ON)
        `uvm_field_int(actual_txn_counter,UVM_ALL_ON)
        `uvm_field_int(sequence_randomizer,UVM_ALL_ON)
    `uvm_object_utils_end

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "base_sequence_item");
    super.new(name);
endfunction

/****************
/ Post randomize 
/****************/
function void post_randomize();
    pkt_ID++;
    `uvm_info(get_full_name(), "post_randomize", UVM_HIGH)
endfunction : post_randomize

endclass : base_sequence_item