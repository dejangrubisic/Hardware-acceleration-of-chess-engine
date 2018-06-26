/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            test_eval_my_1.sv

    DESCRIPTION     example test

*******************************************************************************/

`ifndef test_eval_my_1_SV
`define test_eval_my_1_SV

`include "sequences/eval_base_seq.sv"

class test_eval_my_1 extends test_eval_base;

    `uvm_component_utils(test_eval_my_1)

    eval_base_seq my_seq;

    function new(string name = "test_eval_my_1", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        my_seq = eval_base_seq::type_id::create("my_seq");
    endfunction : build_phase

    task run_phase(uvm_phase phase);
		`uvm_info("moj_glavni_test","---TEST_SEQUENCE_GLAVNI---",UVM_HIGH)

		
        //randomize je u samoj klasi
		phase.raise_objection(this);
        my_seq.start(env.agent.seqr);
        phase.drop_objection(this);
		`uvm_info(get_type_name(), $sformatf("Zavrsio test, Rezultati...\n%s", my_seq.sprint()), UVM_HIGH)
    endtask : run_phase

endclass : test_eval_my_1

`endif

