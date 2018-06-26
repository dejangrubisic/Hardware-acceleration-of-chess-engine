/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_driver.sv

    DESCRIPTION     

*******************************************************************************/

`ifndef eval_DRIVER_SV
`define eval_DRIVER_SV

class eval_driver extends uvm_driver#(eval_frame);

    `uvm_component_utils(eval_driver)
	
	// The virtual interface used to drive and view HDL signals.
    virtual interface eval_if vif;
    
	function new(string name = "eval_driver", uvm_component parent = null);
        super.new(name,parent);
    endfunction

	function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (!uvm_config_db#(virtual eval_if)::get(this, "*", "eval_if", vif))
            `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
    endfunction : connect_phase

	
    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
           `uvm_info(get_type_name(),
                        $sformatf("DRIVER_EVAL: Driver sending...\n%s",
						req.sprint()), UVM_HIGH)
			
			
			drive_tr();			
			
            @(posedge vif.finished_axi_out);
			
			seq_item_port.item_done();
        end
    endtask : run_phase

	
	
	
task drive_tr();
	//Drive start_in and side_in 
	logic [31 : 0]  temp_data_in[8];
		
	if(req.reset == 1'b1) 
	begin
		@(posedge vif.clk);
		vif.reset = 1'b1;
	end		
	else 
	begin
		
		for(int i=0; i<8; i++) 
		begin
			@(posedge vif.clk);					
				
				vif.mem_wr_in = 1'b1;					
				vif.mem_wr_addr_in = i;
				//Converting to format of memory 32b
				temp_data_in[vif.mem_wr_addr_in] = 0;
				for(int j=0; j<8; j++)
				begin
					temp_data_in[vif.mem_wr_addr_in] |= ({req.color_in[8*j+i], req.piece_in[8*j+i] } << (4*j)); 
				end
				vif.mem_data_in = temp_data_in[vif.mem_wr_addr_in];
				
		end 
		
		@(posedge vif.clk);
			vif.mem_wr_in = 1'b0;
			vif.mem_data_in = 0;
		
			vif.reg_data_in <= req.side_in;
			vif.side_wr_in <= 1'b1;
		@(posedge vif.clk);
			vif.side_wr_in <= 1'b0;
			
			vif.reg_data_in = req.start_in;
			vif.start_wr_in = 1'b1;
		@(posedge vif.clk);
			vif.start_wr_in = 1'b0;
			
		//Ispisi memorijsku mapu za tablu
		$display("Memorija");
		for(int i = 0; i < 8; i++)
			$display("%x", temp_data_in[i]);	
	end
	
endtask : drive_tr
	
	
/*	
	-------------------------------------------------------------------------------
	--Frame
	rand bit start_in;
	rand bit side_in;

	rand bit color_in[64];
	rand bit [2:0] piece_in[64];	// 0-pawn 1-knight 2-bishop 3-rook 4-queen 5-king 6-empty

	bit reset;
	
	-------------------------------------------------------------------------------
	--Virtuelni interfejs
	clk
	reset	
	--Axi Lite
    logic reg_data_in;
    logic start_wr_in;
    logic side_wr_in;	
    --Memory
	logic [31 : 0]  mem_data_in;
    logic  mem_wr_in;
    logic [2 : 0]  mem_wr_addr_in;
*/
endclass : eval_driver

`endif

