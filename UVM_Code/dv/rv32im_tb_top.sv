//-------------------------------------------------------------------------
//				            rv32im_tb_top.sv
//-------------------------------------------------------------------------

module rv32im_tb_top;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  // import rst_uvm_pkg::*;
  import rv32im_pkg::*;

  //---------------------------------------
  // Clock and reset signal declaration
  //---------------------------------------
  bit clk;
  logic rst_ni;
  int no_of_resets;
  int test_timeout;

  /*****************
  / Clock Generation
  /*****************/
  always #5 clk = ~clk;

  /***********************
  / Reset Generation Task
  /***********************/
  task rst;
	rst_ni = 1;
	#2ns
    rst_ni = 0;
    #173;
    rst_ni = 1;
  endtask

  /***********************
  / Reset Generation
  /***********************/ 
  initial begin
    //rst();
	
	
    //     #194;
    //     rst();
    //     #99;
    //     rst();
    //     #375;
    //     rst();
  end

  /**********************
  / Interfaces instances
  /**********************/
  cv32e40p_instruction_memory_if cv32e40p_instruction_memory_intf(clk);
  cv32e40p_internal_if           cv32e40p_internal_intf(clk);
  cv32e40p_data_memory_if        cv32e40p_data_memory_intf(clk);
  cv32e40p_debug_if              cv32e40p_debug_if_intf(clk);
  cv32e40p_interrupt_if          cv32e40p_interrupt_if_intf(clk);
  cv32e40p_rst_if                cv32e40p_rst_intf(rst_ni);



  /**************************************
  / cv32e40p top module inestantiation
  /*************************************/
    cv32e40p_top #(
        .FPU                      ( 0 ),
        .FPU_ADDMUL_LAT           ( 0 ),
        .FPU_OTHERS_LAT           ( 0 ),
        .ZFINX                    ( 0 ),
        .COREV_PULP               ( 0 ),
        .COREV_CLUSTER            ( 0 ),
        .NUM_MHPMCOUNTERS         ( 1 )
    ) u_core (
        // Clock and reset
        .rst_ni                   (rst_ni),
        .clk_i                    (clk),
        .scan_cg_en_i             (0),

        // Special control signals
        .fetch_enable_i           (cv32e40p_instruction_memory_intf.fetch_enable_i),
        .pulp_clock_en_i          (0),
        .core_sleep_o             (cv32e40p_instruction_memory_intf.core_sleep_o),

        // Configuration
        .boot_addr_i              (0),
        .mtvec_addr_i             (0), //Revise
        .dm_halt_addr_i           (0),
        .dm_exception_addr_i      (0),
        .hart_id_i                (0),

        // Instruction memory interface
        .instr_addr_o             (cv32e40p_instruction_memory_intf.instr_addr_o),
        .instr_req_o              (cv32e40p_instruction_memory_intf.instr_req_o),
        .instr_gnt_i              (cv32e40p_instruction_memory_intf.instr_gnt_i),
        .instr_rvalid_i           (cv32e40p_instruction_memory_intf.instr_rvalid_i),
        .instr_rdata_i            (cv32e40p_instruction_memory_intf.instr_rdata_i),

        // Data memory interface
        .data_addr_o              (cv32e40p_data_memory_intf.data_addr_o),
        .data_req_o               (cv32e40p_data_memory_intf.data_req_o),
        .data_gnt_i               (cv32e40p_data_memory_intf.data_gnt_i),
        .data_we_o                (cv32e40p_data_memory_intf.data_we_o),
        .data_be_o                (cv32e40p_data_memory_intf.data_be_o),
        .data_wdata_o             (cv32e40p_data_memory_intf.data_wdata_o),
        .data_rvalid_i            (cv32e40p_data_memory_intf.data_rvalid_i),
        //.data_rdata_i             (32'h1f1f1f1f),
        .data_rdata_i             (cv32e40p_data_memory_intf.data_rdata_i),

        // Interrupt interface
        .irq_i                    (cv32e40p_interrupt_if_intf.irq_i),
        .irq_ack_o                (cv32e40p_interrupt_if_intf.irq_ack_o),
        .irq_id_o                 (cv32e40p_interrupt_if_intf.irq_id_o),

        // Debug interface
        .debug_req_i              (cv32e40p_debug_if_intf.debug_req_i),
        .debug_havereset_o        (cv32e40p_debug_if_intf.debug_havereset_o),
        .debug_running_o          (cv32e40p_debug_if_intf.debug_running_o),
        .debug_halted_o           (cv32e40p_debug_if_intf.debug_halted_o)
    );

// observer obs1(
//   .instr_valid_id_o(u_core.core_i.if_stage_i.instr_valid_id_o)
// );

bind cv32e40p_core observer obs1( 
          .cv32e40p_internal_intf(cv32e40p_internal_intf.INTERNAL),
          //IF TO ID
          .instr_valid_id(instr_valid_id),
          .instr_rdata_id(instr_rdata_id),
          .clear_instr_valid(clear_instr_valid),
          .pc_set(pc_set),
          .pc_mux_id(pc_mux_id),
          .exc_pc_mux_id(exc_pc_mux_id),
          .trap_addr_mux(trap_addr_mux),
          .is_fetch_failed_id(is_fetch_failed_id),
          .pc_id(pc_id),
          .pc_if(pc_if),
          .halt_if(halt_if),
          .instr_req_int(instr_req_int),
          .id_ready(id_ready),
          /*
            Instruction Decode
          */
          .is_decoding(is_decoding),
          // Branch & Jumping
          .branch_in_ex(branch_in_ex),
          .ctrl_transfer_insn_in_dec(ctrl_transfer_insn_in_dec),
          // ID to EX (Pipelined)          
          .pc_ex(pc_ex),
          .alu_en_ex(alu_en_ex),
          .alu_operator_ex(alu_operator_ex),
          .alu_operand_a_ex(alu_operand_a_ex),
          .alu_operand_b_ex(alu_operand_b_ex),
          .alu_operand_c_ex(alu_operand_c_ex),
          .bmask_a_ex(bmask_a_ex),
          .bmask_b_ex(bmask_b_ex),
          .imm_vec_ext_ex(imm_vec_ext_ex),
          .alu_vec_mode_ex(alu_vec_mode_ex),
          .regfile_waddr_ex(regfile_waddr_ex),
          .regfile_we_ex(regfile_we_ex),
          .regfile_alu_waddr_ex(regfile_alu_waddr_ex),
          .regfile_alu_we_ex(regfile_alu_we_ex),
          // Multiplier Signals
          .mult_operator_ex(mult_operator_ex),
          .mult_operand_a_ex(mult_operand_a_ex),
          .mult_operand_b_ex(mult_operand_b_ex),
          .mult_operand_c_ex(mult_operand_c_ex),
          .mult_en_ex(mult_en_ex),
          .mult_sel_subword_ex(mult_sel_subword_ex),
          .mult_signed_mode_ex(mult_signed_mode_ex),
          .mult_imm_ex(mult_imm_ex),
          .mult_dot_op_a_ex(mult_dot_op_a_ex),
          .mult_dot_op_b_ex(mult_dot_op_b_ex),
          .mult_dot_op_c_ex(mult_dot_op_c_ex),
          .mult_dot_signed_ex(mult_dot_signed_ex),
          .mult_is_clpx_ex(mult_is_clpx_ex),
          .mult_clpx_shift_ex(mult_clpx_shift_ex),
          .mult_clpx_img_ex(mult_clpx_img_ex),
          /*
            Instruction Execution
          */        
          // EX Output Pipelined
          .regfile_we_wb(regfile_we_wb),
          .regfile_we_wb_power(regfile_we_wb_power),
          .regfile_wdata(regfile_wdata),  
          // Forwarding ports : to ID stage
          // To IF: Jump and branch target and decision
          .jump_target_id(jump_target_id),
          .jump_target_ex(jump_target_ex),
          .branch_decision(branch_decision),
          .ex_ready(ex_ready), // EX stage ready for new data
          .ex_valid(ex_valid), // EX stage gets new data 
          .regfile_alu_waddr_fw(regfile_alu_waddr_fw),
          .regfile_alu_we_fw(regfile_alu_we_fw),
          .regfile_alu_we_fw_power(regfile_alu_we_fw_power),
          .regfile_alu_wdata_fw(regfile_alu_wdata_fw),
          .regfile_waddr_fw_wb_o(regfile_waddr_fw_wb_o) // From WB to ID
);

  /**********************
  / Reset monitor process
  /**********************/
  initial begin
    forever begin
      @(cv32e40p_rst_intf.need_reset);
      $display("[time is %0t] Reset event detected", $time);
      rst_ni = 0;
      #cv32e40p_rst_intf.reset_duration;
      rst_ni = 1;
      $display("[time is %0t] Reset sequence completed", $time);
    end
  end

  /**********************************************************************************************
  / Passing the interface handle to lower heirarchy using set method and enabling the wave dump
  /**********************************************************************************************/
  
  cv32e40p_test_config test_cfg;
  cv32e40p_Regfile_config regfile_cfg;
  string test_name;
  initial begin

    if ($value$plusargs("UVM_TESTNAME=%s", test_name)) 
    $display("Running test: %s", test_name);
    case (test_name)
      "M_Extension_test"       : test_timeout = 118205;
      "R_type_std_test"        : test_timeout = 20355;
      "I_type_std_test"        : test_timeout = 18355;
      "I_type_store_load_test" : test_timeout = 10125;
      "B_type_test"            : test_timeout = 1453;
      "U_type_test"            : test_timeout = 10055;
      "Hazard_test"            : test_timeout = 15065;
	    default:  test_timeout = 20000;
    endcase
	
    no_of_resets = 4;

    // Create and initialize test config
    test_cfg    = cv32e40p_test_config::type_id::create("test_cfg");
    regfile_cfg = cv32e40p_Regfile_config::type_id::create("regfile_cfg");
    test_cfg.set_config (UVM_ACTIVE, UVM_PASSIVE, UVM_PASSIVE, UVM_ACTIVE, UVM_ACTIVE, UVM_ACTIVE, UVM_ACTIVE, 
                          cv32e40p_instruction_memory_intf, 
                          cv32e40p_internal_intf, 
                          cv32e40p_data_memory_intf, 
                          cv32e40p_debug_if_intf, 
                          cv32e40p_interrupt_if_intf, 
                          cv32e40p_rst_intf, 
                          no_of_resets, 
                          test_timeout
    );
    
    // Set in config DB
    uvm_config_db#(cv32e40p_test_config)   ::set(uvm_root::get(),"uvm_test_top","test_cfg",test_cfg);
    uvm_config_db#(cv32e40p_Regfile_config)::set(uvm_root::get(),"*","regfile_cfg",regfile_cfg);
    uvm_config_db#(string)::set(uvm_root::get(),"*","test_name",test_name);

    //enable wave dump
   
  end
/*
  initial begin
		string vpd_file;
		#1ns;
		// Select VPD file based on runtime UVM_TESTNAME
		case (test_name)
		"B_type_test":      	vpd_file = "B_type_test.vpd";
		"Hazard_test": 		 	vpd_file = "Hazard_test.vpd";
		"JALR_test":       		vpd_file = "JALR_test.vpd";
		"M_Extension_test":     vpd_file = "M_Extension_test.vpd";
		"S_type_test":       	vpd_file = "S_type_test.vpd";
		"U_type_test":       	vpd_file = "U_type_test.vpd";

		
		 
		default :           vpd_file = "random_test.vpd";
		endcase
	
		// Open the VPD file and start dumping signals
		$vcdplusfile(vpd_file);
		$vcdpluson;

		 $dumpfile("dump.vcd"); 
    		$dumpvars;
  
  end
*/

initial begin
	 string vpd_file;
  if (!$value$plusargs("UVM_TESTNAME=%s", test_name)) begin
    test_name = "default_test";
  end

   vpd_file = {test_name, ".vpd"};

  $vcdplusfile(vpd_file); // Set unique VPD file
  $vcdpluson();
end

  //---------------------------------------
  //calling reset and test
  //---------------------------------------
  initial begin 
    run_test();
  end

endmodule : rv32im_tb_top
