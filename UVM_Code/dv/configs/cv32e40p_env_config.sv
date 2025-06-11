class cv32e40p_env_config extends uvm_object;

  // Agent configurations
  uvm_active_passive_enum cv32e40p_if_agent_is_active, 
                          cv32e40p_id_agent_is_active, 
                          cv32e40p_ie_agent_is_active, 
                          cv32e40p_data_memory_agent_is_active, 
                          cv32e40p_debug_if_agent_is_active, 
                          cv32e40p_interrupt_if_agent_is_active,
                          cv32e40p_rst_agent_is_active;

  // Virtual interface to the DUT             
  virtual cv32e40p_instruction_memory_if cv32e40p_instruction_memory_vif;
  virtual cv32e40p_internal_if           cv32e40p_internal_vif;
  virtual cv32e40p_data_memory_if        cv32e40p_data_memory_vif;
  virtual cv32e40p_debug_if              cv32e40p_debug_vif;
  virtual cv32e40p_interrupt_if          cv32e40p_interrupt_vif;
  virtual cv32e40p_rst_if                cv32e40p_rst_vif;
  
  // Register with factory
  `uvm_object_utils_begin(cv32e40p_env_config)
    `uvm_field_enum(uvm_active_passive_enum, cv32e40p_if_agent_is_active, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, cv32e40p_id_agent_is_active, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, cv32e40p_ie_agent_is_active, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, cv32e40p_data_memory_agent_is_active, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, cv32e40p_debug_if_agent_is_active, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, cv32e40p_interrupt_if_agent_is_active, UVM_DEFAULT)
    `uvm_field_enum(uvm_active_passive_enum, cv32e40p_rst_agent_is_active, UVM_DEFAULT)
  `uvm_object_utils_end
  
  // Constructor
  function new(string name = "cv32e40p_env_config");
    super.new(name);
  endfunction : new

  // initialize method
  function void initialize(uvm_active_passive_enum                cv32e40p_if_agent_type,
                           uvm_active_passive_enum                cv32e40p_id_agent_type,
                           uvm_active_passive_enum                cv32e40p_ie_agent_type,
                           uvm_active_passive_enum                cv32e40p_data_memory_agent_type,
                           uvm_active_passive_enum                cv32e40p_debug_if_agent_type,
                           uvm_active_passive_enum                cv32e40p_interrupt_if_agent_type,
                           uvm_active_passive_enum                cv32e40p_rst_agent_type,
                           virtual cv32e40p_instruction_memory_if cv32e40p_instruction_memory_vif,
                           virtual cv32e40p_internal_if           cv32e40p_internal_vif,
                           virtual cv32e40p_data_memory_if        cv32e40p_data_memory_vif, 
                           virtual cv32e40p_debug_if              cv32e40p_debug_vif, 
                           virtual cv32e40p_interrupt_if          cv32e40p_interrupt_vif,
                           virtual cv32e40p_rst_if                cv32e40p_rst_vif
                           );

    this.cv32e40p_if_agent_is_active                     = cv32e40p_if_agent_type;
    this.cv32e40p_id_agent_is_active                     = cv32e40p_id_agent_type;
    this.cv32e40p_ie_agent_is_active                     = cv32e40p_ie_agent_type;
    this.cv32e40p_data_memory_agent_is_active            = cv32e40p_data_memory_agent_type;
    this.cv32e40p_debug_if_agent_is_active               = cv32e40p_debug_if_agent_type;
    this.cv32e40p_interrupt_if_agent_is_active           = cv32e40p_interrupt_if_agent_type;
    this.cv32e40p_rst_agent_is_active                    = cv32e40p_rst_agent_type;

    this.cv32e40p_instruction_memory_vif        = cv32e40p_instruction_memory_vif;
    this.cv32e40p_internal_vif                  = cv32e40p_internal_vif;
    this.cv32e40p_data_memory_vif               = cv32e40p_data_memory_vif;
    this.cv32e40p_debug_vif                     = cv32e40p_debug_vif;
    this.cv32e40p_interrupt_vif                 = cv32e40p_interrupt_vif;
    this.cv32e40p_rst_vif                       = cv32e40p_rst_vif;

    `uvm_info(get_type_name, "Initialization Finished", UVM_LOW)
  endfunction : initialize

  // Function to get the active/passive state of the agent
  function uvm_active_passive_enum if_agent_get_is_active();
    return cv32e40p_if_agent_is_active;
  endfunction : if_agent_get_is_active 

  function uvm_active_passive_enum id_agent_get_is_active();
    return cv32e40p_id_agent_is_active;
  endfunction : id_agent_get_is_active

  function uvm_active_passive_enum ie_agent_get_is_active();
    return cv32e40p_ie_agent_is_active;
  endfunction : ie_agent_get_is_active

  function uvm_active_passive_enum data_memory_if_agent_get_is_active();
    return cv32e40p_data_memory_agent_is_active;
  endfunction : data_memory_if_agent_get_is_active

  function uvm_active_passive_enum debug_if_agent_get_is_active();
    return cv32e40p_debug_if_agent_is_active;
  endfunction : debug_if_agent_get_is_active

  function uvm_active_passive_enum interrupt_if_agent_get_is_active();
    return cv32e40p_interrupt_if_agent_is_active;
  endfunction : interrupt_if_agent_get_is_active

  function uvm_active_passive_enum rst_agent_get_is_active();
    return cv32e40p_rst_agent_is_active;
  endfunction : rst_agent_get_is_active

endclass : cv32e40p_env_config