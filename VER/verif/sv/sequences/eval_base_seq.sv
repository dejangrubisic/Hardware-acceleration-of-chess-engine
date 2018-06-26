/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_base_seq.sv

    DESCRIPTION     base sequence; to be extended by all other sequences

*******************************************************************************/

`ifndef eval_BASE_SEQ_SV
`define eval_BASE_SEQ_SV

class eval_base_seq extends uvm_sequence#(eval_frame);

    `uvm_object_utils(eval_base_seq)
    `uvm_declare_p_sequencer(eval_sequencer)

	//constraint num_of_transaction {num_of_tran == 5;}
	
	
    function new(string name = "eval_base_seq");
        super.new(name);
    endfunction

	task body();
		int unsigned num_of_tran;
		num_of_tran = 1000;
		
		$display("EVAL_BASE_SEQ: Broj transakcija je = %0d \n", num_of_tran);
		repeat(num_of_tran)begin			
			
			`uvm_do(req);	
		/*	req = eval_frame::type_id::create("req");
			
			while(!req.randomize());
						
			start_item(req);
			finish_item(req);						
		*/
		end
	endtask

endclass : eval_base_seq

`endif

