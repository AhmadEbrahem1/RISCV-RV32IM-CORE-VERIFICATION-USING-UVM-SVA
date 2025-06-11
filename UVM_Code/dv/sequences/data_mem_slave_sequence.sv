class data_mem_slave_sequence extends uvm_sequence #(cv32e40p_data_memory_sequence_item);

	parameter mem_depth = 4096;
	bit  [31:0] RAM [int]; // Static memory array
	int addr;
	
  `uvm_object_utils(data_mem_slave_sequence)

  function new(string name = "data_mem_slave_sequence");
    super.new(name);
	/*
	foreach (RAM[i]) begin
		$display("RAM %d = %h",i,RAM[i]);
	end
	*/
	addr = 0;
  endfunction

  task body();
	
	cv32e40p_data_memory_sequence_item req;
	cv32e40p_data_memory_sequence_item rsp;
	
    forever begin
		req = cv32e40p_data_memory_sequence_item::type_id::create("req");
		rsp = cv32e40p_data_memory_sequence_item::type_id::create("rsp");
		
		// Slave request:
		start_item(req);
		finish_item(req);

		//$display("req address display is %0h and the decimal value is %0d",req.data_addr_o,req.data_addr_o);
		// Slave response:
		if (req.data_req_o) begin
			addr = req.data_addr_o[31:2];
			if(addr>mem_depth)
				`uvm_error("DATA MEM SEQUENCE",$sformatf("addres is >mem_depth %d ",addr))
			//$display("addr is %0h and the decimal value is %0d",addr,addr);
			//`uvm_info(get_full_name(),$sformatf("got : addr = %d  %b ",addr,req.data_be_o),UVM_LOW)
			if(req.data_we_o) begin
				//mask 
				if(req.data_be_o[0])
				begin
					RAM[addr][7:0] = req.data_wdata_o[7:0];
				end 
				if(req.data_be_o[1])
				begin
					RAM[addr][15:8] = req.data_wdata_o[15:8];
				end 
				if(req.data_be_o[2])
				begin
					RAM[addr][23:16] = req.data_wdata_o[23:16];
				end 
				if(req.data_be_o[3])
				begin
					RAM[addr][31:24] = req.data_wdata_o[31:24];
				end 
				
				$display("STORED DATA = %0d %0h RAMMMMMMMMMMMMMMMMMMMMMMMM",RAM[addr],RAM[addr]);
			end
			else begin //read data
				$display("content of ram in address %0d  is %0h",addr,RAM[addr]);
				//mask 
				if(req.data_be_o[0])
				begin
					req.data_rdata_i[7:0] = RAM[addr][7:0] ;
				end                                    
				if(req.data_be_o[1])                  
				begin                                  
					 req.data_rdata_i[15:8] =RAM[addr][15:8];
				end 
				if(req.data_be_o[2])
				begin
					req.data_rdata_i[23:16] = RAM[addr][23:16] ;
				end 
				if(req.data_be_o[3])
				begin
					req.data_rdata_i[31:24] = RAM[addr][31:24]  ;
				end 
			end
		
		req.valid_delay=0;
		end		
		start_item(rsp);
		rsp.copy(req);
		//assert (rsp.randomize() with {if(!rsp.rw) rsp.rdata == memory[rsp.addr];});
		finish_item(rsp);
		
    end
  endtask

endclass: data_mem_slave_sequence
