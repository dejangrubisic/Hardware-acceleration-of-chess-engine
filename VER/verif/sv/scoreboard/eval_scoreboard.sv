`ifndef eval_scoreboard_sv
`define eval_scoreboard_sv

`include "scoreboard/eval_predictor.sv"

class eval_scoreboard extends uvm_scoreboard;
	// control fileds
	bit checks_enable = 1;
	bit coverage_enable = 1;
	int num_of_tr;
	
	//eval_frame frame_queue[$];
	
	// This TLM port is used to connect the scoreboard to the monitor
	uvm_analysis_imp#(eval_frame, eval_scoreboard) frame_collected;
	
	
	`uvm_component_utils_begin(eval_scoreboard)
		`uvm_field_int(checks_enable, UVM_DEFAULT)
		`uvm_field_int(coverage_enable, UVM_DEFAULT)
	`uvm_component_utils_end

	function new(string name = "eval_scoreboard", uvm_component parent = null);
		super.new(name,parent);
		frame_collected = new("frame_collected", this);
		
	endfunction : new

	function write (input eval_frame tr);
		int predicted_result;
		int dut_result;
		
		eval_frame tr_clone;
		assert($cast(tr_clone, tr.clone()));
		
		
		if(checks_enable) begin
			// do actual checking here
			//asrt_queue_not_empty: assert(frame_queue.size())begin
						
			predicted_result = predict( tr_clone.color_in, tr_clone.piece_in, tr_clone.side_in);	
				
			//asrt_dut_res_to_int: assert($cast(dut_result, tr_clone.result_axi_out));			
			dut_result = tr_clone.result_axi_out;
			asrt_check_result: assert(predicted_result == dut_result)
				$display("******PROSAO TEST %0d  Result = %0d *****************************\n \n ", num_of_tr, dut_result);
			else
			begin
				$error("\n * * * * * ERROR in Comparing results: Predicted_result = %0d Dut_result = %0d * * * * * \n \n",predicted_result, dut_result);
				$finish;
			end
			
			 ++num_of_tr;
		end
	endfunction : write

	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(), $sformatf("eval scoreboard examined: \
					%0d transactions", num_of_tr), UVM_LOW);
	endfunction : report_phase

	endclass : eval_scoreboard
	
	
`endif