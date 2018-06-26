/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_if.sv

    DESCRIPTION     eval interface

*******************************************************************************/

`ifndef eval_IF_SV
`define eval_IF_SV

interface eval_if (input clk, bit rst);
	//Axi Lite
    bit reg_data_in;
    bit start_wr_in;
    bit start_axi_out;
    bit side_wr_in;
    bit side_axi_out;
	//Result
    bit [14 : 0]  result_axi_out;
    bit finished_axi_out;
    //Memory
	bit [31 : 0]  mem_data_in;
    bit  mem_wr_in;
    bit [2 : 0]  mem_wr_addr_in;
		
endinterface : eval_if

`endif

