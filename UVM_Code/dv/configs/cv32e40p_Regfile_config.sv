class cv32e40p_Regfile_config extends uvm_object;

  // 32-entry static register file mirror
  static logic signed [31:0] regfile_mirror [32];   // [0:31] is also fine

  `uvm_object_utils_begin(cv32e40p_Regfile_config)
    `uvm_field_sarray_int(regfile_mirror, UVM_DEFAULT)   // <<< static-array macro
  `uvm_object_utils_end

  function new(string name = "cv32e40p_Regfile_config");
    super.new(name);
    foreach (regfile_mirror[i]) regfile_mirror[i] = 32'b0;
  endfunction

endclass
