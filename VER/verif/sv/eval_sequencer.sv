/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_sequencer.sv

    DESCRIPTION     

*******************************************************************************/

`ifndef eval_SEQUENCER_SV
`define eval_SEQUENCER_SV

class eval_sequencer extends uvm_sequencer#(eval_frame);

    `uvm_component_utils(eval_sequencer)

    function new(string name = "eval_sequencer", uvm_component parent = null);
        super.new(name,parent);
    endfunction

endclass : eval_sequencer

`endif

