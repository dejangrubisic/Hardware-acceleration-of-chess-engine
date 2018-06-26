/*******************************************************************************
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+
    |F|u|n|c|t|i|o|n|a|l| |V|e|r|i|f|i|c|a|t|i|o|n| |o|f| |H|a|r|d|w|a|r|e|
    +-+-+-+-+-+-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+-+-+-+ +-+-+ +-+-+-+-+-+-+-+-+

    FILE            eval_frame.sv

    DESCRIPTION     

*******************************************************************************/

`ifndef eval_FRAME_SV
`define eval_FRAME_SV

class eval_frame extends uvm_sequence_item;

	rand bit start_in;
	bit reset;
		
	rand bit side_in;	
	bit color_in[64];
	bit [2:0] piece_in[64];	// 0-pawn 1-knight 2-bishop 3-rook 4-queen 5-king 6-empty

	//result 
	int  result_axi_out;
    bit finished_axi_out;	
	
	
	
	rand int w_pawn_count;
	rand int w_knight_count;
	rand int w_bishop_count;
	rand int w_rook_count;
	rand int w_queen_count;
	
	rand int b_pawn_count;
	rand int b_knight_count;
	rand int b_bishop_count;
	rand int b_rook_count;
	rand int b_queen_count;
		
		
	constraint start_on {start_in == 1'b1;}
	
	constraint const_w_total_promoted{
		w_pawn_count + (w_knight_count <= 2 ? 0 : (w_knight_count - 2)) + 
					   (w_bishop_count <= 2 ? 0 : (w_bishop_count - 2)) +
					   (w_rook_count   <= 2 ? 0 : (w_rook_count - 2)) + 
					   (w_queen_count  <= 1 ? 0 : (w_queen_count - 1)) <= 8;
		}	
	constraint const_b_total_promoted{
		b_pawn_count + (b_knight_count <= 2 ? 0 : (b_knight_count - 2)) + 
					   (b_bishop_count <= 2 ? 0 : (b_bishop_count - 2)) +
					   (b_rook_count   <= 2 ? 0 : (b_rook_count - 2)) + 
					   (b_queen_count  <= 1 ? 0 : (b_queen_count - 1)) <= 8;
		}	
		

	constraint const_w_pawn_count{w_pawn_count inside{[0:8]};}
	constraint const_w_knight_count{
		w_knight_count dist{[0:2]:/900, 3:=70, 4:=20, 5:=9, [6:8]:/1 };
		}
	constraint const_w_bishop_count{
		w_bishop_count dist{[0:2]:/900, 3:=70, 4:=20, 5:=9, [6:8]:/1 };
		}
	constraint const_w_rook_count{
		w_rook_count dist{[0:2]:/900, 3:=70, 4:=20, 5:=9, [6:8]:/1 };
		}
	constraint const_w_queen_count{
		w_queen_count dist{[0:1]:/850, 2:=70, 3:=50, 4:=20, 5:=9, [6:8]:/1};
		}
	
	constraint const_b_pawn_count{b_pawn_count inside{[0:8]};}
	constraint const_b_knight_count{
		b_knight_count dist{[0:2]:/900, 3:=70, 4:=20, 5:=9, [6:8]:/1};
		}
	constraint const_b_bishop_count{
		b_bishop_count dist{[0:2]:/900, 3:=70, 4:=20, 5:=9, [6:8]:/1};
		}
	constraint const_b_rook_count{
		b_rook_count dist{[0:2]:/900, 3:=70, 4:=20, 5:=9, [6:8]:/1};
		}
	constraint const_b_queen_count{
		b_queen_count dist{[0:1]:/850, 2:=70, 3:=50, 4:=20, 5:=9, [6:8]:/1};
		}
	// UVM factory registracija
	`uvm_object_utils_begin(eval_frame)

		`uvm_field_int(start_in, UVM_DEFAULT)
		`uvm_field_int(side_in, UVM_DEFAULT)
		`uvm_field_sarray_int(color_in, UVM_DEFAULT)
		`uvm_field_sarray_int(piece_in, UVM_DEFAULT)

		`uvm_field_int(result_axi_out, UVM_DEFAULT)
		`uvm_field_int(finished_axi_out, UVM_DEFAULT)
		`uvm_field_int(reset, UVM_DEFAULT)


	`uvm_object_utils_end

	// konstruktor
	function new(string name = "eval_frame");
		super.new(name);
		
	endfunction
	
	function void post_randomize();
		
		int square_queue[$];
		int piece_count;
		int choose_square;
		int temp; //bira iz square_queue validno polje 
		
		for(int i = 0; i < 64; i++)
		begin
			square_queue[i] = i;
			color_in[i] = 0;	//nije bitno koje je polje kad je empty al aj
			piece_in[i] = 6;	//empty
		end
	
		for(int color = 0; color <= 1; color++)		//beli - 0, crni 1
			for(int piece = 0; piece < 6; piece++)	//0-pawn 1-knight 2-bishop 3-rook 4-queen 5-king 6-empty
			begin
		
				//Broj istih figura treba tezinski rasporediti !!!
				if(color == 0) begin
					case (piece)
					0: piece_count = w_pawn_count;
					1: piece_count = w_knight_count;
					2: piece_count = w_bishop_count;
					3: piece_count = w_rook_count;
					4: piece_count = w_queen_count;
					5: piece_count = 1;
					endcase
				end
				else begin
					case (piece)
					0: piece_count = b_pawn_count;
					1: piece_count = b_knight_count;
					2: piece_count = b_bishop_count;
					3: piece_count = b_rook_count;
					4: piece_count = b_queen_count;
					5: piece_count = 1;
					endcase
				
				end
				
				//$display("Piece_count[%0d] [%0d] = %0d ", color, piece, piece_count);							
				
				for(int i = 0; i < piece_count; i++)	//koliko ima figura iste boje i tipa
				begin
					
					//izaberi polje
					temp = $urandom_range(0, square_queue.size()-1);	//biramo polje na kom je figra
					//$display("temp = %0d ", temp);
					
					if(piece == 0)	//ako je pesak ne sme da dobije 1. i 8. red
					begin
						//$display("Pesak je");				
						while((square_queue[temp] < 8) || (square_queue[temp] > 55))
						begin
							//$display("Usao u while");
							//ako nije ok vrednost za pesaka, probaj nesto drugo  
							temp = $urandom_range(0, square_queue.size()-1);
							//$display("temp = %0d ", temp);							
						end
						
					end
					//polje je validno
					//$display("Polje validno");
					choose_square = square_queue[temp];
					square_queue.delete(temp);
					
					//$display("choose_square = %0d ", choose_square);
					
					$cast(color_in[choose_square] , color);
					$cast(piece_in[choose_square] , piece);
					
					//$display("color_in[%0d] = %0d", choose_square, color_in[choose_square]);
					//$display("piece_in[%0d] = %0d", choose_square, piece_in[choose_square]);
					
					
				end
				
			end
			
		//print_board();
		//print_cololor_piece();
	endfunction : post_randomize
	
	function void print_board();
		
		string w_piece_char = "PNBRQK" ;
		string b_piece_char = "pnbrqk" ;
		
		$write("******************* BOARD ********************* \n");
		


		$write("8 ");
		for (int i = 0; i < 64; ++i) 
		begin
			if (piece_in[i] == 6) 					
				$write(" .");
			else if(color_in[i] == 0)
				$write(" %c", w_piece_char.getc(piece_in[i]));
			else if(color_in[i] == 1)
				$write(" %c", b_piece_char.getc(piece_in[i]));
				
				
			if ((i + 1) % 8 == 0 && i != 63)
				$write("\n%d ", 7 - (i/8));
		end
		$write("\n a b c d e f g h\n\n");
	endfunction : print_board
	
	
	
	
	function void print_cololor_piece();
		$display("Color");
		for(int i = 0; i < 64; i++)
		begin
			if(i % 8 == 0)
				$write("\n");
			$write("%0d", color_in[i]);	
		end
	
		$display("Piece");
		for(int i = 0; i < 64; i++)
		begin
			if(i % 8 == 0)
				$write("\n");
			$write("%0d", piece_in[i]);	
		end
		$write("\n\n\n");
	endfunction : print_cololor_piece
	

endclass


`endif
