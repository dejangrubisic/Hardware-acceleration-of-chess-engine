/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_env.sv

    DESCRIPTION     

*******************************************************************************/

`ifndef eval_ENV_SV
`define eval_ENV_SV

class eval_env extends uvm_env;

    eval_agent agent;
	eval_scoreboard scbd;
	
    `uvm_component_utils (eval_env)
	
    function new(string name = "eval_env", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = eval_agent::type_id::create("agent", this);
		scbd = eval_scoreboard::type_id::create("scbd", this);
    endfunction : build_phase
	
	function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.item_collected_port.connect(scbd.frame_collected);
    endfunction : connect_phase

endclass : eval_env

`endif


