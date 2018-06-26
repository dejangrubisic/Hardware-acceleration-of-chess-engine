/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_agent.sv

    DESCRIPTION     

*******************************************************************************/

`ifndef eval_AGENT_SV
`define eval_AGENT_SV

class eval_agent extends uvm_agent;

    // components
    eval_driver drv;
    eval_sequencer seqr;
    eval_monitor mon;

    // configuration
    eval_config cfg;

    `uvm_component_utils_begin (eval_agent)
        `uvm_field_object(cfg, UVM_DEFAULT)
    `uvm_component_utils_end

    function new(string name = "eval_agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(eval_config)::get(this, "", "eval_config", cfg))
            `uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".cfg"})

        mon = eval_monitor::type_id::create("mon", this);
        if(cfg.is_active == UVM_ACTIVE) begin
            drv = eval_driver::type_id::create("drv", this);
            seqr = eval_sequencer::type_id::create("seqr", this);
        end

    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(cfg.is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction : connect_phase

endclass : eval_agent

`endif

