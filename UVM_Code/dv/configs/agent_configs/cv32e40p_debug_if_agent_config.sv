class cv32e40p_debug_if_agent_config extends uvm_object;
  // Virtual interface used for connecting the active agent to the Design Under Test (DUT)
  virtual cv32e40p_debug_if vif;
  
  // Enumeration indicating whether the agent is active or passive
  protected uvm_active_passive_enum is_active;
  
  // Register with factory
  `uvm_object_utils_begin(cv32e40p_debug_if_agent_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_DEFAULT)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name = "cv32e40p_debug_if_agent_config");
    super.new(name);
  endfunction : new
  
  // Initialization method
  function void initialize(virtual cv32e40p_debug_if vif, uvm_active_passive_enum is_active);
    this.vif = vif;
    this.is_active = is_active;
  endfunction : initialize
  
  // Function to get the active/passive state of the agent
  function uvm_active_passive_enum get_is_active();
    return is_active;
  endfunction : get_is_active
  
  function virtual cv32e40p_debug_if hand_interface_handle();
    return vif;
  endfunction : hand_interface_handle

endclass : cv32e40p_debug_if_agent_config