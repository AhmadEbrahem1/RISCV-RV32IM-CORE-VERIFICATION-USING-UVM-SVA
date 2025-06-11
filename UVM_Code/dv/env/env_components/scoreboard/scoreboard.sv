/***********************************************************************
/ Scoreboard - inestantiates predictor and comparator and connects them, 
/ also keeps track of the incorrect and correct comparisons of items
/**********************************************************************/ 
class scoreboard extends uvm_scoreboard;

    // Each Stage/Agent Checker Handle
    cv32e40p_if_checker             if_stage_checker_h;
    cv32e40p_id_checker             id_stage_checker_h;
    cv32e40p_ie_checker             ie_stage_checker_h;
    cv32e40p_data_memory_checker    data_memory_checker_h;
    cv32e40p_lsu_checker            lsu_checker_h;
    cv32e40p_debug_if_checker       debug_if_checker_h;
    // isr_if_checker isr_if_checker_h;
    
    /********************************
    / Declare TLM component for reset
    *********************************/
    uvm_analysis_export #(cv32e40p_rst_sequence_item) RST_n_ap;
    uvm_analysis_export #(cv32e40p_rst_sequence_item) RST_p_ap;

    //TLM Connections for all agents' Input Monitors
    uvm_analysis_export#(cv32e40p_if_sequence_item) if_stage_ap_in;
    uvm_analysis_export#(cv32e40p_id_sequence_item) id_stage_ap_in;
    uvm_analysis_export#(cv32e40p_ie_sequence_item) ie_stage_ap_in;
    uvm_analysis_export#(cv32e40p_data_memory_sequence_item) data_memory_ap_in;
    uvm_analysis_export#(cv32e40p_interrupt_sequence_item) isr_if_ap_in;
    uvm_analysis_export#(cv32e40p_debug_sequence_item) debug_if_ap_in;

    //TLM Connections for all agents' Output Monitors
    uvm_analysis_export#(cv32e40p_if_sequence_item) if_stage_ap_out;
    uvm_analysis_export#(cv32e40p_id_sequence_item) id_stage_ap_out;
    uvm_analysis_export#(cv32e40p_ie_sequence_item) ie_stage_ap_out;
    uvm_analysis_export#(cv32e40p_data_memory_sequence_item) data_memory_ap_out;
    uvm_analysis_export#(cv32e40p_data_memory_sequence_item) lsu_ap_out;
    uvm_analysis_export#(cv32e40p_interrupt_sequence_item) isr_if_ap_out;
    uvm_analysis_export#(cv32e40p_debug_sequence_item) debug_if_ap_out;

    /*************************************TO BE DEPECRATED, JUST ACTING AS A STUB*****************************************/
    
    /**************************************
    / Declare TLM Analaysis FIFOs for reset
    ***************************************/
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_n_fifo;
    uvm_tlm_analysis_fifo#(cv32e40p_rst_sequence_item) RST_p_fifo;

    //TLM FIFOs for all agents' Input Monitors
    // uvm_tlm_analysis_fifo#(cv32e40p_if_sequence_item) if_stage_fifo_in;
    // uvm_tlm_analysis_fifo#(cv32e40p_id_sequence_item) id_stage_fifo_in;
    // uvm_tlm_analysis_fifo#(cv32e40p_ie_sequence_item) ie_stage_fifo_in;
    // uvm_tlm_analysis_fifo#(cv32e40p_data_memory_sequence_item) data_memory_fifo_in;
    uvm_tlm_analysis_fifo#(cv32e40p_interrupt_sequence_item) isr_if_fifo_in;
    // uvm_tlm_analysis_fifo#(cv32e40p_debug_sequence_item) debug_if_fifo_in;

    //TLM FIFOs for all agents' Output Monitors
    // uvm_tlm_analysis_fifo#(cv32e40p_if_sequence_item) if_stage_fifo_out;
    // uvm_tlm_analysis_fifo#(cv32e40p_id_sequence_item) id_stage_fifo_out;
    // uvm_tlm_analysis_fifo#(cv32e40p_ie_sequence_item) ie_stage_fifo_out;
    // uvm_tlm_analysis_fifo#(cv32e40p_data_memory_sequence_item) data_memory_fifo_out;
    uvm_tlm_analysis_fifo#(cv32e40p_interrupt_sequence_item) isr_if_fifo_out;
    // uvm_tlm_analysis_fifo#(cv32e40p_debug_sequence_item) debug_if_fifo_out;

    /*************************************TO BE DEPECRATED, JUST ACTING AS A STUB*****************************************/

    // Register with factory
    `uvm_component_utils(scoreboard)

/*******************************************************************************
/ Constructor : is responsible for the construction of objects and components
*********************************************************************************/
function new(string name, uvm_component parent);
    super.new(name, parent);
endfunction : new

/*********************************************************
/ Build Phase : Has Creators, Getters & possible overrides
**********************************************************/
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Build phase", UVM_MEDIUM)

    // Create The needed TLM Components rst agent
    RST_n_ap = new("RST_n_ap",this);
    RST_p_ap = new("RST_p_ap",this);

    //TLM Connections for all agents' Input Monitors
    if_stage_ap_in      = new("if_stage_ap_in", this);
    id_stage_ap_in      = new("id_stage_ap_in", this);
    ie_stage_ap_in      = new("ie_stage_ap_in", this);
    data_memory_ap_in   = new("data_memory_ap_in", this);
    isr_if_ap_in        = new("isr_if_ap_in", this);
    debug_if_ap_in      = new("debug_if_ap_in", this);

    //TLM Connections for all agents' Output Monitors
    if_stage_ap_out     = new("if_stage_ap_out", this);
    id_stage_ap_out     = new("id_stage_ap_out", this);
    ie_stage_ap_out     = new("ie_stage_ap_out", this);
    data_memory_ap_out  = new("data_memory_ap_out", this);
    lsu_ap_out          = new("lsu_ap_out", this);
    isr_if_ap_out       = new("isr_if_ap_out", this);
    debug_if_ap_out     = new("debug_if_ap_out", this);

    // Create Checkers
    ie_stage_checker_h      = cv32e40p_ie_checker::type_id::create("ie_stage_checker_h",this);
    if_stage_checker_h      = cv32e40p_if_checker::type_id::create("if_stage_checker_h",this);
    id_stage_checker_h      = cv32e40p_id_checker::type_id::create("id_stage_checker_h",this);
    data_memory_checker_h   = cv32e40p_data_memory_checker::type_id::create("data_memory_checker_h",this);
    lsu_checker_h           = cv32e40p_lsu_checker::type_id::create("lsu_checker_h",this);
    debug_if_checker_h      = cv32e40p_debug_if_checker::type_id::create("debug_if_checker_h",this);
    // isr_if_checker_h       = cv32e40p_isr_if_checker::type_id::create("isr_if_checker_h",this);

    /*************************************TO BE DEPECRATED, JUST ACTING AS A STUB*****************************************/

    // Create rst FIFOs
    RST_n_fifo = new("RST_n_fifo",this);
    RST_p_fifo = new("RST_p_fifo",this);

    //TLM FIFOs for all agents' Input Monitors
    // if_stage_fifo_in      = new("if_stage_fifo_in", this);
    // id_stage_fifo_in      = new("id_stage_fifo_in", this);
    // ie_stage_fifo_in      = new("ie_stage_fifo_in", this);
    // data_memory_fifo_in   = new("data_memory_fifo_in", this);
    isr_if_fifo_in        = new("isr_if_fifo_in", this);
    // debug_if_fifo_in        = new("debug_if_fifo_in", this);

    //TLM FIFOs for all agents' Output Monitors
    // if_stage_fifo_out     = new("if_stage_fifo_out", this);
    // id_stage_fifo_out     = new("id_stage_fifo_out", this);
    // ie_stage_fifo_out     = new("ie_stage_fifo_out", this);
    // data_memory_fifo_out  = new("data_memory_fifo_out", this);
    isr_if_fifo_out       = new("isr_if_fifo_out", this);
    // debug_if_fifo_out       = new("debug_if_fifo_out", this);

    /*************************************TO BE DEPECRATED, JUST ACTING AS A STUB*****************************************/


endfunction: build_phase

/****************************************
/ Connect Phase : Has TLM Connections
******************************************/
function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "Connect phase", UVM_MEDIUM)

    // Connect reset to Stage Checkers

    // Connect inputs & outputs to their prespective checkers
    if_stage_ap_in.connect(if_stage_checker_h.inputs_ap);
    id_stage_ap_in.connect(id_stage_checker_h.inputs_ap);
    ie_stage_ap_in.connect(ie_stage_checker_h.inputs_ap);
    data_memory_ap_in.connect(data_memory_checker_h.inputs_ap);
    id_stage_ap_in.connect(lsu_checker_h.inputs_ap);
    debug_if_ap_in.connect(debug_if_checker_h.inputs_ap);
    // isr_if_ap_in.connect(isr_if_checker_h.isr_if_ap_in);

    if_stage_ap_out.connect(if_stage_checker_h.outputs_ap);
    id_stage_ap_out.connect(id_stage_checker_h.outputs_ap);
    ie_stage_ap_out.connect(ie_stage_checker_h.outputs_ap);
    data_memory_ap_out.connect(data_memory_checker_h.outputs_ap);
    lsu_ap_out.connect(lsu_checker_h.outputs_ap);
    debug_if_ap_out.connect(debug_if_checker_h.outputs_ap);
    // isr_if_ap_out.connect(isr_if_checker_h.isr_if_ap_out);

    /*************************************TO BE DEPECRATED, JUST ACTING AS A STUB*****************************************/

    //Connect RST Agent to Subscriber FIFOs
    RST_n_ap.connect(RST_n_fifo.analysis_export);
    RST_p_ap.connect(RST_p_fifo.analysis_export);

    // Connect All agents' (except RST_agent) inputs & outputs to Subscriber
    // if_stage_ap_in.connect(if_stage_fifo_in.analysis_export);
    // if_stage_ap_out.connect(if_stage_fifo_out.analysis_export);

    // id_stage_ap_in.connect(id_stage_fifo_in.analysis_export);
    // id_stage_ap_out.connect(id_stage_fifo_out.analysis_export);

    // ie_stage_ap_in.connect(ie_stage_fifo_in.analysis_export);
    // ie_stage_ap_out.connect(ie_stage_fifo_out.analysis_export);

    // data_memory_ap_in.connect(data_memory_fifo_in.analysis_export);
    // data_memory_ap_out.connect(data_memory_fifo_out.analysis_export);

    // debug_if_ap_in.connect(debug_if_fifo_in.analysis_export);
    // debug_if_ap_out.connect(debug_if_fifo_out.analysis_export);

    isr_if_ap_in.connect(isr_if_fifo_in.analysis_export);
    isr_if_ap_out.connect(isr_if_fifo_out.analysis_export);
    
    /*************************************TO BE DEPECRATED, JUST ACTING AS A STUB*****************************************/


endfunction : connect_phase

/****************************************************************************************************
/ Main phase : Translates the Transaction level stimulus to pin level stimulus & drives it to the DUT
*****************************************************************************************************/
task main_phase(uvm_phase phase);
    cv32e40p_rst_sequence_item rst_req;
    cv32e40p_if_sequence_item if_s_req_i;
    cv32e40p_id_sequence_item id_s_req_i;
    cv32e40p_ie_sequence_item ie_s_req_i;
    cv32e40p_data_memory_sequence_item data_memory_req_i;
    cv32e40p_debug_sequence_item debug_if_req_i;
    cv32e40p_interrupt_sequence_item isr_if_req_i;

    cv32e40p_if_sequence_item if_s_req_o;
    cv32e40p_id_sequence_item id_s_req_o;
    cv32e40p_ie_sequence_item ie_s_req_o;
    cv32e40p_data_memory_sequence_item data_memory_req_o;
    cv32e40p_debug_sequence_item debug_if_req_o;
    cv32e40p_interrupt_sequence_item isr_if_req_o;

    super.main_phase(phase);
    `uvm_info(get_type_name(), "Main phase", UVM_MEDIUM)
    forever begin
        fork
            begin
                RST_n_fifo.get(rst_req);
                RST_p_fifo.get(rst_req);
            end
            // if_stage_fifo_in.try_get(if_s_req_i);
            // id_stage_fifo_in.try_get(id_s_req_i);
            // ie_stage_fifo_in.try_get(ie_s_req_i);
            // data_memory_fifo_in.try_get(data_memory_req_i);
            // debug_if_fifo_in.try_get(debug_if_req_i);
            isr_if_fifo_in.try_get(isr_if_req_i);
            // if_stage_fifo_out.try_get(if_s_req_o);
            // id_stage_fifo_out.try_get(id_s_req_o);
            // ie_stage_fifo_out.try_get(ie_s_req_o);
            // data_memory_fifo_out.try_get(data_memory_req_o);
            // debug_if_fifo_out.try_get(debug_if_req_o);
            isr_if_fifo_out.try_get(isr_if_req_o);
        join
    end
endtask : main_phase
  
/*************************************************************************************
/   Phase ready to end : a Test termination technique is deployed in this phase to 
/    make sure the test only ends when a certain event has happened
/*************************************************************************************/
function void phase_ready_to_end(uvm_phase phase);
    if (phase.get_name() != "run") return;
    if (/*~base_sequence_item::cov_target ||*/ ~cv32e40p_rst_sequence_item::resets_done) begin
    phase.raise_objection(.obj(this)); 
    fork 
        begin 
        delay_phase(phase);
        end
    join_none
    end
endfunction

/****************************************************************************************
// Delay Phase: A task that stalls the test termination, is called by phase_ready_to_end
/***************************************************************************************/
task delay_phase(uvm_phase phase);
    wait(/*cv32e40p_rst_sequence_item::cov_target &&*/ cv32e40p_rst_sequence_item::resets_done);
    phase.drop_objection(.obj(this));
endtask

/***************************************************************************************************
// Final Phase: used to report when the scoreboard finishes its operation before the simulation ends
/***************************************************************************************************/
function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info(get_type_name(), "Scoreboard is stopping.", UVM_LOW)
endfunction

/*****************************************************************************
/ Report phase : reports the results of the data associated with the component
******************************************************************************/
function void report_phase(uvm_phase phase);
    // `uvm_info(get_type_name(), 
            // $sformatf("\nScoreboard Report:\n\tTotal Transactions: %0d\n\tTotal Correct Items: %0d\n\tTotal Incorrect Items: %0d", 
            //             comparator_h.transaction_counter, comparator_h.correct_counter, comparator_h.incorrect_counter), 
            // UVM_LOW)
    `uvm_info(get_type_name(), "Scoreboard Report Phase Complete", UVM_MEDIUM)
endfunction : report_phase


endclass : scoreboard
