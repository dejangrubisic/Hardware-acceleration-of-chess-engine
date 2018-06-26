/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_verif_pkg.sv

    DESCRIPTION     package

*******************************************************************************/

`ifndef eval_VERIF_PKG_SV
`define eval_VERIF_PKG_SV

package eval_verif_pkg;

	`define LIGHT			1'b0
	`define DARK			1'b1

	`define PAWN			3'b000
	`define KNIGHT			3'b001
	`define BISHOP			3'b010
	`define ROOK			3'b011
	`define QUEEN			3'b100
	`define KING			3'b101

	`define EMPTY			3'b110


    import uvm_pkg::*;            // import the UVM library
    `include "uvm_macros.svh"     // Include the UVM macros

	`include "eval_config.sv"

	`include "eval_frame.sv"
	`include "eval_sequencer.sv"
	`include "sequences/eval_seq_lib.sv"
    `include "eval_driver.sv"
	`include "eval_coverage.sv"
	`include "eval_monitor.sv"
	`include "eval_agent.sv"
	`include "scoreboard/eval_scoreboard_lib.sv"
	`include "eval_env.sv"
	
    `include "tests/eval_test_lib.sv"
    
	
endpackage : eval_verif_pkg

`include "eval_if.sv"


`endif

