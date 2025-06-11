class S_sequence extends uvm_sequence #(base_sequence_item);

	//Registering the env class in the factory
    `uvm_object_utils(S_sequence)
	int loop_count;
	logic [4:0] rd_reg;
	logic [11:0] imm_ss;
	// rf model helps in randomization
	logic signed [31:0] value_rf[32];
	rand logic [31:0] updated_rf;
/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name = "S_sequence");
    super.new(name);
	foreach(value_rf[i]) value_rf[i] = 0;
	updated_rf	= 0;
endfunction

/*********************************************************************
/ Body Task: Create, Randomize & Send the Sequence Item to the driver
/*********************************************************************/
task body();
	cv32e40p_if_sequence_item req,req1,req2,req3,req4;
   
    req1 = cv32e40p_if_sequence_item::type_id::create("req1");
	req = cv32e40p_if_sequence_item::type_id::create("req");
    req2 = cv32e40p_if_sequence_item::type_id::create("req2");
    req3 = cv32e40p_if_sequence_item::type_id::create("req3");
    req4 = cv32e40p_if_sequence_item::type_id::create("req4");

    `uvm_info(get_type_name(), "Running S_sequence instructions", UVM_LOW)

    repeat(loop_count) begin
      // --------- write to any rd  ---------

start_item(req1);
assert(req1.randomize() with {
    instr_type == I_TYPE;
    opcode     == OPCODE_I;
    funct3     == ADDI_FUNCT3;
    imm_I % 4  == 0;
   
        imm_I inside {[0 : 2044]};
    
});
rd_reg = req1.rd;
imm_ss = req1.imm_I;
// update rf value to be used later as a base address
if (rd_reg != 0)
    value_rf[rd_reg] = value_rf[req1.rs1] + imm_ss;

finish_item(req1);

updated_rf = value_rf[rd_reg];

// --------- SB store byte ---------

start_item(req2);
assert(req2.randomize() with {
    instr_type == S_TYPE;
    rs1        == rd_reg;
    funct3     == SB_FUNCT3;
    // Effective address >= 0 and <= max address for byte store
    (imm_s ) >= -updated_rf;
    (imm_s ) <= DATA_MEM_DEPTH -updated_rf- 1;
	
});
finish_item(req2);

// --------- SH store halfword ---------

start_item(req3);
assert(req3.randomize() with {
    instr_type == S_TYPE;
    rs1        == rd_reg;
    funct3     == SH_FUNCT3;
    // Effective address >= 0 and <= max address for halfword store (2 bytes)
    (imm_s ) >= -updated_rf;
    (imm_s ) <= DATA_MEM_DEPTH - updated_rf-2;
	
});
finish_item(req3);

// --------- SW store word ---------

start_item(req4);
assert(req4.randomize() with {
    instr_type == S_TYPE;
    rs1        == rd_reg;
    funct3     == SW_FUNCT3;
    // Effective address >= 0 and <= max address for word store (4 bytes)
    (imm_s ) >= -updated_rf;
    (imm_s  ) <= DATA_MEM_DEPTH - updated_rf-4;
	
});
finish_item(req4);


	
/*	
	for (int i = 1; i <= 31; i++) begin
            start_item(req);

            assert(req.randomize() with {
                instr_type == I_TYPE;
		        opcode     == OPCODE_I ;
		        funct3     == ADDI_FUNCT3;
                rd         == i;
                rs1        == 0;
                imm_I     %4==0;
				imm_I >=0;
                });

            `uvm_info("REG_INIT", $sformatf("ADDI x%0d, x0, %0d (Instr: 0x%08h)", 
                req.rd, $signed(req.imm_I), req.instruction), UVM_HIGH)

            finish_item(req);
        end
		// --------- SB  ---------
       
        start_item(req2);
        assert(req2.randomize() with {
               	 instr_type == S_TYPE;

				funct3== SB_FUNCT3 ; 
				// limit offset + rf value less than memory boundry
				imm_s == 8;
							});
        finish_item(req2);
	        // --------- SH  ---------
	 start_item(req3);
        assert(req3.randomize() with {
               	 		instr_type == S_TYPE;
				
				funct3== SH_FUNCT3 ;  
				imm_s == 8;
					});
        finish_item(req3);
        // --------- SW  ---------

 	start_item(req4);
 	assert(req4.randomize() with {
               	 		instr_type == S_TYPE;
				funct3== SW_FUNCT3 ;
				imm_s == 8;
				});
        finish_item(req4);
		
		
		*/
		
		
    end

endtask

endclass : S_sequence

