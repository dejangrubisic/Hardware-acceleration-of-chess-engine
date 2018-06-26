/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            test_eval_base.sv

    DESCRIPTION     base test; to be extended by all other tests

*******************************************************************************/

`ifndef test_eval_base_SV
`define test_eval_base_SV

class test_eval_base extends uvm_test;
	
	eval_env env;
    eval_config cfg;

    `uvm_component_utils(test_eval_base)

    function new(string name = "test_eval_base", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = eval_env::type_id::create("env", this);
        cfg = eval_config::type_id::create("cfg");
        uvm_config_db#(eval_config)::set(this, "*", "eval_config", cfg);
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase
	
endclass : test_eval_base

`endif

