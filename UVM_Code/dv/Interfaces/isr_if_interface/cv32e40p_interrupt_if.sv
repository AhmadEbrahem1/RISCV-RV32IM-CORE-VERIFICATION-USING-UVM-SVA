interface cv32e40p_interrupt_if(input bit clk_i);

    /***************************************
    / Instruction Fetch Stage Signals
    /***************************************/
    logic           rst_n;


    logic [31:0]    irq_i; //input
    /* Level sensistive active high interrupt inputs. Not all interrupt inputs can be used on CV32E40P. 
    Specifically irq_i[15:12], irq_i[10:8], irq_i[6:4] and irq_i[2:0] shall be tied to 0 
    externally as they are reserved for future standard use (or for cores which are not Machine mode only) 
    in the RISC-V Privileged specification. 

    irq_i[11], irq_i[7], and irq_i[3] correspond to the Machine External Interrupt 
    (MEI), Machine Timer Interrupt (MTI), and Machine Software Interrupt (MSI) respectively.

    The irq_i[31:16] interrupts are a CV32E40P specific extension to the RISC-V Basic (a.k.a. CLINT) interrupt scheme.*/

    logic           irq_ack_o; //output
    /* Interrupt acknowledge : Set to 1 for one cycle when the interrupt with ID irq_id_o[4:0] is taken.*/

    logic [4:0]     irq_id_o;  //output
    /* Interrupt index for taken interrupt : Only valid when irq_ack_o = 1.*/
    
endinterface : cv32e40p_interrupt_if