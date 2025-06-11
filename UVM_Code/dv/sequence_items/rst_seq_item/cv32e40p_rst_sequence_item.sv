class cv32e40p_rst_sequence_item extends uvm_sequence_item;

    // Control parameters to control the number of resets & notify when all the resets have been initiated.
    static int unsigned number_of_resets_per_test;
    static bit unsigned resets_done;

    /***********************************
    / Reset Assertion Control properties
    //**********************************/
    rand    bit   reset_on;
    rand    time  reset_duration;
            time  start_reset;
            time  end_reset;
    rand	time  reset_delay;

    local static int  unsigned rst_pkt_ID;
          static int  unsigned resets_count;

    /***************************
    / Randomization Constraints
    /***************************/    
    constraint reset_power            { reset_on dist {1 := 20, 0 := 80};} // active low reset
    constraint reset_time 		      { reset_duration inside {[100:150]};} // reset duration inside 200:500 ns
    constraint time_between_reset     { reset_delay   inside {[200:500]};} // time between resets inside 200:500 ns
  
    /*************************
    / Utility and Field macros
    /*************************/
    `uvm_object_utils_begin(cv32e40p_rst_sequence_item)
    `uvm_field_int(rst_pkt_ID,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(reset_on,UVM_ALL_ON)
    `uvm_field_int(start_reset,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(end_reset,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(reset_duration,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(reset_delay,UVM_ALL_ON | UVM_DEC)
    `uvm_field_int(resets_count,UVM_ALL_ON | UVM_DEC)
    `uvm_object_utils_end

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "cv32e40p_rst_sequence_item");
    super.new(name);
endfunction

/****************
/ Post randomize 
/****************/
function void post_randomize();
    rst_pkt_ID++;
    if (reset_on)  begin
        start_reset = $time;
        end_reset   = start_reset + reset_duration;
    end
endfunction


endclass : cv32e40p_rst_sequence_item