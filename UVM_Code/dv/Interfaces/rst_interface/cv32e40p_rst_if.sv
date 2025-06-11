interface cv32e40p_rst_if (input rst_ni);

  /****************
  / Reset Items  
  /****************/
  event need_reset;
  int reset_duration;
  int output_reset_matches;
  int output_reset_mismatches;

  /****************
  / Reset Task 
  /****************/
  task reset(int reset_duration1);
    reset_duration = reset_duration1;
    -> need_reset;
    $display("[time is %0t] reset task called, rst value is %0d", $time, rst_ni);
  endtask

endinterface : cv32e40p_rst_if