class cv32e40p_if_agent_config extends uvm_object;
  // Virtual interface used for connecting the active agent to the Design Under Test (DUT)
  virtual cv32e40p_instruction_memory_if cv32e40p_instruction_memory_vif;
  virtual cv32e40p_internal_if          cv32e40p_internal_vif;
  
  // Enumeration indicating whether the agent is active or passive
  protected uvm_active_passive_enum cv32e40p_if_agent_is_active;
  
  // Register with factory
  `uvm_object_utils_begin(cv32e40p_if_agent_config)
    `uvm_field_enum(uvm_active_passive_enum, cv32e40p_if_agent_is_active, UVM_DEFAULT)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name = "cv32e40p_if_agent_config");
    super.new(name);
  endfunction : new
  
  // Initialization method
  function void initialize(virtual cv32e40p_instruction_memory_if   cv32e40p_instruction_memory_vif, 
                           virtual cv32e40p_internal_if            cv32e40p_internal_vif, 
                           uvm_active_passive_enum 				         cv32e40p_if_agent_is_active
                          );
    
    this.cv32e40p_instruction_memory_vif = cv32e40p_instruction_memory_vif;
    this.cv32e40p_internal_vif          = cv32e40p_internal_vif;
    this.cv32e40p_if_agent_is_active = cv32e40p_if_agent_is_active;
    `uvm_info(get_type_name, "Initialization Done", UVM_LOW)
  endfunction : initialize
  
  // Function to get the active/passive state of the agent
  function uvm_active_passive_enum get_is_active();
    return cv32e40p_if_agent_is_active;
  endfunction : get_is_active
  
  function virtual cv32e40p_instruction_memory_if hand_if_interface_handle();
    return cv32e40p_instruction_memory_vif;
  endfunction : hand_if_interface_handle

  function virtual cv32e40p_internal_if hand_internal_interface_handle();
    return cv32e40p_internal_vif;
  endfunction : hand_internal_interface_handle

endclass : cv32e40p_if_agent_config