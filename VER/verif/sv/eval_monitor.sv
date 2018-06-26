/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_monitor.sv

    DESCRIPTION     

*******************************************************************************/



`ifndef eval_MONITOR_SV
`define eval_MONITOR_SV

`include "eval_coverage.sv"

class eval_monitor extends uvm_monitor;

    // control fileds
    bit checks_enable = 1;
    bit coverage_enable = 1;

    uvm_analysis_port #(eval_frame) item_collected_port;

    `uvm_component_utils_begin(eval_monitor)
        `uvm_field_int(checks_enable, UVM_DEFAULT)
        `uvm_field_int(coverage_enable, UVM_DEFAULT)
    `uvm_component_utils_end

    // The virtual interface used to drive and view HDL signals.
    virtual interface eval_if vif;

    // current transaction
    eval_frame current_frame;

    // coverage 
    eval_coverage cov;

    function new(string name = "eval_monitor", uvm_component parent = null);
        super.new(name,parent);
		//Analysis port
        item_collected_port = new("item_collected_port", this);
		
		cov = new();
		
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
		//Virtual Interface
        if (!uvm_config_db#(virtual eval_if)::get(this, "*", "eval_if", vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
    endfunction : connect_phase

    task run_phase(uvm_phase phase);
        forever begin
            current_frame = eval_frame::type_id::create("current_frame", this);            		
			
			fork
				// collect transactions
				collect_input();
				collect_result();
			join
			
			$display("%0t MONITOR salje rezultat DUV-a: %d 
					za poziciju: ", $time, current_frame.result_axi_out);
			current_frame.print_board();	
				

			item_collected_port.write(current_frame);				
			
			cov.collect_coverage(current_frame.color_in, current_frame.piece_in,
									current_frame.side_in);			
        end
    endtask : run_phase

		`uvm_info(get_type_name(),$sformatf("Printing from Monitor\n %s",current_frame.sprint()),UVM_HIGH)		
		
	task collect_input();

		fork 
		
			begin
				do begin
					@(posedge vif.clk );
					#1ns;
				end
				while(vif.start_axi_out != 1'b1);
								
					current_frame.start_in = vif.start_axi_out;
					current_frame.side_in = vif.side_axi_out;
				
			end
			
			
			 //Upis u memoriju
				
			forever	
			begin
				int square;
				
				do begin
					@(posedge vif.clk);				
					#1ns;
				end 
				while (vif.mem_wr_in != 1'b1);
				
				//$display("MONITOR Memory transaction")	;
				for(int i=0; i<8; i++)begin
					square = 8*i + vif.mem_wr_addr_in;
				
					current_frame.color_in[square] = vif.mem_data_in[4*i+3];
					
					current_frame.piece_in[square][2] = vif.mem_data_in[(4*i+2)];
					current_frame.piece_in[square][1] = vif.mem_data_in[(4*i+1)];
					current_frame.piece_in[square][0] = vif.mem_data_in[(4*i+0)];
				
				
				//$display(" %0t Addr = %0x || Current_frame: Polje: %0d | piece = %0x , color = %0x ",$time, vif.mem_wr_addr_in, square, current_frame.piece_in[square],  current_frame.color_in[square]);
				end
				
			end
		join_any
		//$display("MONITOR fork disabled ")	;
				disable fork;
		$display("%0t MONITOR: Board -------> %s *****************************", $time, current_frame.side_in ? "CRNI":"BELI");
		//current_frame.print_board();
		
	endtask : collect_input

	task collect_result();
		
		@(posedge vif.finished_axi_out);			
		current_frame.result_axi_out = signed'(vif.result_axi_out);		
		//$display("%0t Collected_result finished***************************************************************", $time);

	endtask : collect_result
	
endclass : eval_monitor

`endif

