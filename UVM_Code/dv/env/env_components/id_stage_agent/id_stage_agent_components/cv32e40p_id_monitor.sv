/******************************************************************
 * File: cv32e40p_id_monitor.sv
 * Authors: Team 1:
 *          * Ziad Ahmed
 *          * Ahmed Khaled
 *          * Ahmed Ebrahem
 *          * Mohamed Mohsen
 *          * Esmail Abdelrahman
 *          * Abdelrahman Yassien
 * Email: Abdelrahman.Yassien11@gmail.com
 * Date: 28/04/2025
 * Description: This class extends `uvm_monitor` to monitor the
 *              inputs & outputs of a DUT (Device Under Test). It provides
 *              functionality for collecting and analyzing sequence
 *              items through an analysis port.
 *
 * Copyright (c) [2024] [Team 1]. All Rights Reserved.
 * This file is part of the Verification of CV32E40P_RV32IM Core.
 **********************************************************************************/

class cv32e40p_id_monitor extends uvm_monitor;

    // Transaction Counter to report on
    protected int in_trans_count, out_trans_count;

    // Registering the id_stage_driver class in the factory
    `uvm_component_utils_begin(cv32e40p_id_monitor)
        `uvm_field_int(in_trans_count, UVM_DEFAULT)
        `uvm_field_int(out_trans_count, UVM_DEFAULT)
    `uvm_object_utils_end

    // Reset Interface Virtual Interface Handle
    virtual cv32e40p_internal_if vif;
    protected logic [31:0] ProgramCounter_i;
    protected logic [31:0] ProgramCounter_o;

    // Sequence Item Handle

    // TLM Connections between ID stage inputsMonitor & ID Agent
    uvm_analysis_port #(cv32e40p_id_sequence_item) id_stage_ap_in;
    uvm_analysis_port #(cv32e40p_id_sequence_item) id_stage_ap_out;

    // TLM Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_p_ap;
    uvm_analysis_export#(cv32e40p_rst_sequence_item) RST_n_ap;

    // TLM FIFO Connection between RST Agent & all other Agents (Reset Awareness)
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_p_fifo;
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_n_fifo;

    /*****************************************************************************
    * Constructor : is responsible for the construction of objects and components
    ******************************************************************************/
    function new (string name, uvm_component parent);
        super.new(name, parent);
        ProgramCounter_i = 0;
        ProgramCounter_o = 4;
    endfunction

    /*******************************************************************
    * Build Phase : Has Creators, Getters, Setters & possible overrides
    ********************************************************************/
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

        // Retrieve virtual interface
        if (!uvm_config_db#(virtual cv32e40p_internal_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Failed to get Virtual Interface Handle")

        // Create TLM ports
        id_stage_ap_in = new("id_stage_ap_in", this);
        id_stage_ap_out = new("id_stage_ap_out", this);

        RST_p_ap  = new("RST_p_ap", this);
        RST_n_ap  = new("RST_n_ap", this);

        // Create TLM FIFOs
        RST_p_fifo  = new("RST_p_fifo", this);
        RST_n_fifo  = new("RST_n_fifo", this);
    endfunction

    /********************************************
    * Connect Phase : Has TLM Connections
    *********************************************/
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM)
        RST_p_ap.connect(RST_p_fifo.analysis_export);
        RST_n_ap.connect(RST_n_fifo.analysis_export);
    endfunction

    /****************************************************************************************************
    * Reset phase : Mostly used to wait the first Reset being initiated by the rst_agent or top-tb
    *****************************************************************************************************/
    task reset_phase(uvm_phase phase);
        cv32e40p_rst_sequence_item rst_seq_item;
        phase.raise_objection(this);

        super.reset_phase(phase);
        `uvm_info(get_type_name(), "Reset phase", UVM_MEDIUM)
        RST_n_fifo.get(rst_seq_item);
        RST_p_fifo.get(rst_seq_item);

        `uvm_info(get_type_name(), "First Reset Done", UVM_HIGH)
        phase.drop_objection(this);
    endtask : reset_phase

    /****************************************************************************************************
    * Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
    *****************************************************************************************************/
    task main_phase(uvm_phase phase);
        cv32e40p_rst_sequence_item rst_seq_item;
        super.main_phase(phase);
        `uvm_info(get_type_name(), "Main phase", UVM_MEDIUM)

        forever begin
            fork
                RST_n_fifo.get(rst_seq_item);
                monitor_trigger();
            join_any
            disable fork;
            RST_p_fifo.get(rst_seq_item);
        end
    endtask

    // A task to start the inputs & outputs monitoring process
    task monitor_in();
        cv32e40p_id_sequence_item inputs_seq_item;
        forever begin
            inputs_seq_item = cv32e40p_id_sequence_item::type_id::create("inputs_seq_item");
            @(vif.cb_mon);
            if (vif.cb_mon.instr_valid_id) begin
                if (vif.cb_mon.pc_id == ProgramCounter_i) begin
                    ProgramCounter_i = ProgramCounter_i + 4;
                    inputs_seq_item.instr_rdata_i = vif.cb_mon.instr_rdata_id;
                    inputs_seq_item.pc_id_i       = vif.cb_mon.pc_id;
                    `uvm_info(get_type_name(), $sformatf("[%0t] The pc is: %0h", $time, vif.cb_mon.pc_id), UVM_HIGH)
                    `uvm_info(get_type_name(), $sformatf("[%0t] The Instruction is: %0h", $time, inputs_seq_item.instr_rdata_i), UVM_HIGH)
                    id_stage_ap_in.write(inputs_seq_item);
                    in_trans_count++;
                end
            end
        end
    endtask

    // ============================================================================
    // ALU Operand and Result Handling
    // ============================================================================
    //
    // 1. ADD Instruction (Two Source Operands)
    //
    // Description:
    //   For instructions such as ADD that require two source operands (rs1 and rs2),
    //   the following signal assignments are performed:
    //
    //   - The value of register rs1 is assigned to             → alu_operand_a_ex_o
    //   - The value of register rs2 is assigned to             → alu_operand_b_ex_o
    //   - The destination register address (rd) is assigned to → regfile_alu_waddr_ex_o
    //
    // ALU Output (Forwarding Path):
    //   - The destination register address is forwarded via  → regfile_alu_waddr_fw_i
    //   - The computed ALU result is forwarded via           → regfile_alu_wdata_fw_i
    //
    // 2. ADDI Instruction (One Source Operand + Immediate)
    //
    // Description:
    //   For instructions such as ADDI that use a single register operand and
    //   an immediate value, the following signal assignments are performed:
    //
    //   - The value of register rs1 is assigned to             → alu_operand_a_ex_o
    //   - The immediate value is assigned to                   → alu_operand_b_ex_o
    //   - The destination register address (rd) is assigned to → regfile_alu_waddr_ex_o
    //
    // ALU Output (Forwarding Path):
    //   - The destination register address is forwarded via  → regfile_alu_waddr_fw_i
    //   - The computed ALU result is forwarded via           → regfile_alu_wdata_fw_i

    task monitor_out();
        cv32e40p_id_sequence_item outputs_seq_item;
        forever begin
            outputs_seq_item = cv32e40p_id_sequence_item::type_id::create("outputs_seq_item");
            @(vif.cb_mon);
            if (vif.cb_mon.ex_valid) begin
                if (vif.cb_mon.pc_id == ProgramCounter_o) begin
                    ProgramCounter_o = ProgramCounter_o + 4;
                    outputs_seq_item.alu_operand_a_ex_o      = vif.cb_mon.alu_operand_a_ex;
                    outputs_seq_item.alu_operand_b_ex_o      = vif.cb_mon.alu_operand_b_ex;
                    outputs_seq_item.alu_operand_c_ex_o      = vif.cb_mon.alu_operand_c_ex;
                    outputs_seq_item.mult_operand_a_ex_o     = vif.cb_mon.mult_operand_a_ex;
                    outputs_seq_item.mult_operand_b_ex_o     = vif.cb_mon.mult_operand_b_ex;
                    outputs_seq_item.mult_operand_c_ex_o     = vif.cb_mon.mult_operand_c_ex;
                    outputs_seq_item.regfile_alu_we_fw_i     = vif.cb_mon.regfile_alu_we_fw;
                    outputs_seq_item.regfile_alu_waddr_ex_o  = vif.cb_mon.regfile_alu_waddr_ex;
                    outputs_seq_item.regfile_alu_waddr_fw_i  = vif.cb_mon.regfile_alu_waddr_fw;
                    outputs_seq_item.regfile_alu_wdata_fw_i  = vif.cb_mon.regfile_alu_wdata_fw;

                    `uvm_info(get_type_name(),
                        $sformatf("[%0t] opA: %h  opB: %h  opC: %h  regfile_alu_waddr_ex: %h  regfile_alu_waddr_fw: %h  regfile_alu_wdata_fw: %h",
                            $time,
                            outputs_seq_item.alu_operand_a_ex_o,
                            outputs_seq_item.alu_operand_b_ex_o,
                            outputs_seq_item.alu_operand_c_ex_o,
                            outputs_seq_item.regfile_alu_waddr_ex_o,
                            outputs_seq_item.regfile_alu_waddr_fw_i,
                            outputs_seq_item.regfile_alu_wdata_fw_i),
                        UVM_HIGH);
                    id_stage_ap_out.write(outputs_seq_item);
                    out_trans_count++;
                end
            end
        end
    endtask

    // A task to trigger the monitoring of monitor_in & monitor_out task
    task monitor_trigger();
        forever begin
            fork
                monitor_in();
                monitor_out();
            join
        end
    endtask

    /*****************************************************************************
    * Report phase : reports the results of the data associated with the component
    ******************************************************************************/
    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
            $sformatf("\nInstruction Decode Stage Monitor Report:\n\tInput Transactions Monitored: %0d \n\tOutput Transactions Monitored: %0d",
            in_trans_count, out_trans_count), UVM_MEDIUM)

        `uvm_info(get_type_name(), "Instruction Decode Stage Monitor Report Phase Complete", UVM_MEDIUM)
    endfunction : report_phase

endclass
