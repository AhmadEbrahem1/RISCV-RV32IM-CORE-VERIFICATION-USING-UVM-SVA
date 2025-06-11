class base_v_seq extends uvm_sequence;

        
    // All Agents' sequencers handles
    cv32e40p_rst_sequencer	            rst_sqr_h;
    cv32e40p_if_sequencer               if_stage_sqr_h;
    cv32e40p_data_memory_if_sequencer   data_memory_sqr_h;
    cv32e40p_debug_if_sequencer         dbg_if_sqr_h;
    cv32e40p_interrupt_sequencer        isr_if_sqr_h;
   
    // ==============================================
    // Instruction Sequences
    // ==============================================

    // I-Type Instructions
    ADDI_sequence               ADDI_sequence_h;             // Add immediate instruction sequence
    ANDI_sequence               ANDI_sequence_h;             // And immediate instruction sequence
    ORI_sequence                ORI_sequence_h;              // Or immediate instruction sequence
    XORI_sequence               XORI_sequence_h;             // Xor immediate instruction sequence
    SLTI_sequence               SLTI_sequence_h;             // Set less than immediate (signed)
    SLTIU_sequence              SLTIU_sequence_h;            // Set less than immediate unsigned

    // R-Type Arithmetic Instructions
    ADD_sequence                ADD_sequence_h;              // Add instruction sequence
    SUB_sequence                SUB_sequence_h;              // Subtract instruction sequence
    AND_sequence                AND_sequence_h;              // And instruction sequence
    OR_sequence                 OR_sequence_h;               // Or instruction sequence
    XOR_sequence                XOR_sequence_h;              // Xor instruction sequence

    // R-Type Multiplication/Division
    MUL_sequence                MUL_sequence_h;              // Multiply instruction sequence
    DIV_sequence                DIV_sequence_h;              // Division instruction sequence
    REM_sequence                REM_sequence_h;              // Remainder instruction sequence

    // R-Type Shift Instructions
    SLL_sequence                SLL_sequence_h;              // Shift left logical sequence
    SRL_sequence                SRL_sequence_h;              // Shift right logical sequence
    SRA_sequence                SRA_sequence_h;              // Shift right arithmetic sequence

    // I-Type Shift Instructions
    SLLI_sequence               SLLI_sequence_h;             // Shift left logical immediate
    SRLI_sequence               SRLI_sequence_h;             // Shift right logical immediate
    SRAI_sequence               SRAI_sequence_h;             // Shift right arithmetic immediate

    // Comparison Instructions
    SLT_sequence                SLT_sequence_h;              // Set less than (signed)
    SLTU_sequence               SLTU_sequence_h;             // Set less than unsigned

    // Memory Access Instructions
    LW_sequence                 LW_sequence_h;               // Load word sequence
    LH_sequence                 LH_sequence_h;               // Load halfword sequence
    LHU_sequence                LHU_sequence_h;              // Load halfword unsigned sequence
    LB_sequence                 LB_sequence_h;               // Load byte sequence
    LBU_sequence                LBU_sequence_h;              // Load byte unsigned sequence
    S_sequence                  S_sequence_h;                // Store instructions sequence
    SwLoad_sequence             SwLoad_sequence_h; 
    ShLoad_sequence             ShLoad_sequence_h;
    SbLoad_sequence             SbLoad_sequence_h;

    BEQ_sequence                BEQ_sequence_h;
    BNE_sequence                BNE_sequence_h;
    BLT_sequence                BLT_sequence_h;
    BGE_sequence                BGE_sequence_h;
    BLTU_sequence               BLTU_sequence_h;
    BGEU_sequence               BGEU_sequence_h;

    lui_sequence                lui_sequence_h;
    auipc_sequence              auipc_sequence_h;

    
    // Control Flow Instructions
    B_Sequence                   B_sequence_h;                // Branch instructions sequence
    JAL_sequence                 JAL_sequence_h;              // Jump and link sequence
    JALR_sequence                JALR_sequence_h;
    // Special Instructions
    NOP_sequence                NOP_sequence_h;              // No operation sequence
    rst_sequence                rst_sequence_h;              // Reset sequence
    U_sequence                  U_sequence_h;                // Upper immediate instructions
    R_sequence                  R_sequence_h;                // Generic R-type sequence

    // System Sequences
    Regfile_Initialize_sequence                 Regfile_Initialize_sequence_h;        // Register file initialization
    Regfile_Initialize_sequence_for_loadInstr   Regfile_Initialize_sequence_for_loadInstr_h;
    data_mem_slave_sequence                     data_memory_sequence_h;   // Data memory slave sequence
    Hazard_sequence                             Hazard_sequence_h;           // Hazard testing sequence

    //test config object handle
    cv32e40p_test_config  test_cfg;
    
    // Timeout, to be used to prevent simulator from hanging in case of errors
    int  test_timeout;

    //Registering the env class in the factory
    `uvm_object_utils(base_v_seq)

    //Declaring P_sequencer to use the virtual sequencer
    `uvm_declare_p_sequencer(virtual_sequencer)

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new (string name = "base_v_seq");
    super.new(name);
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
virtual task body();
    `uvm_info(get_type_name(), "Inside Body Task", UVM_LOW);
endtask

endclass : base_v_seq
