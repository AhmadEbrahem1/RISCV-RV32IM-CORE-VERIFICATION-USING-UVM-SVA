class rst_sequence extends uvm_sequence #(cv32e40p_rst_sequence_item);

  // Register with factory
  `uvm_object_utils(rst_sequence)

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "rst_sequence");
super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
virtual task body();
    req = cv32e40p_rst_sequence_item::type_id::create("req");
    forever begin
        start_item(req);
        if(!req.randomize())
            `uvm_error(get_type_name(), "Randomization @cv32e40p_rst_sequence_item failed")

        finish_item(req);

        if(cv32e40p_rst_sequence_item::resets_done)begin
            break;
        end
    end
endtask

endclass : rst_sequence