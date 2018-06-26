/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_verif_top.sv

    DESCRIPTION     top module

*******************************************************************************/

module eval_verif_top;

    import uvm_pkg::*;            // import the UVM library
    `include "uvm_macros.svh"     // Include the UVM macros

    import eval_verif_pkg::*;
    
    logic clk;
    logic reset;

    // interface
    eval_if eval_vif(clk, reset);

    // DUT
    top_with_memory DUT(
        .clk_mem_in  		( clk ),
		.clk_ip_in 			( clk ),
        .reset_in       	( reset ),
        .reg_data_in    	( eval_vif.reg_data_in ),
        .start_wr_in    	( eval_vif.start_wr_in ),
        .start_axi_out  	( eval_vif.start_axi_out ),
        .side_wr_in     	( eval_vif.side_wr_in ),
        .side_axi_out   	( eval_vif.side_axi_out ),
        .result_axi_out 	( eval_vif.result_axi_out ),
        .finished_axi_out   ( eval_vif.finished_axi_out ),
        .mem_data_in      	( eval_vif.mem_data_in ),
        .mem_wr_in    		( eval_vif.mem_wr_in ),
        .mem_wr_addr_in   	( eval_vif.mem_wr_addr_in )
        
    );
	
    // run test
    initial begin
        uvm_config_db#(virtual eval_if)::set(null, "*", "eval_if", eval_vif);
        run_test("test_eval_my_1");
    end

    // clock and reset init.
    initial begin
        clk <= 0;
        reset <= 1;
        #50 reset <= 0;
    end

    // clock generation
    always #50 clk = ~clk;

endmodule : eval_verif_top

