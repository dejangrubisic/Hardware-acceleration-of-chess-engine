`ifndef eval_coverage_sv
 `define eval_coverage_sv

covergroup piece_number_value_cg with function sample(int unsigned piece_number);
   option.per_instance = 1;
   cp_piece_number : coverpoint piece_number{
      bins cnt_0 = {0};
	  bins cnt_1 = {1};
	  bins cnt_2 = {2};
	  bins cnt_3 = {3};
	  bins cnt_4 = {4};
	  bins cnt_5 = {5};
   }
endgroup : piece_number_value_cg


covergroup pawn_number_value_cg with function sample(int unsigned pawn_number);
   option.per_instance = 1;
   cp_pawns_number : coverpoint pawn_number{
      bins cnt_0 = {0};
	  bins cnt_1 = {1};
	  bins cnt_2 = {2};
	  bins cnt_3 = {3};
	  bins cnt_4 = {4};
	  bins cnt_5 = {5};
	  bins cnt_6 = {6};
	  bins cnt_7 = {7};
	  bins cnt_8 = {8};
   }
endgroup : pawn_number_value_cg



covergroup side_value_cg (ref bit side);
   option.per_instance = 1;
   cp_side : coverpoint side;
endgroup : side_value_cg

covergroup square_value_cg with function sample(bit unsigned [3:0] square);
   option.per_instance = 1;
   cp_square : coverpoint square
     {
      bins w_pawn   = { {`LIGHT, `PAWN} };
      bins w_knight = { {`LIGHT, `KNIGHT} };
      bins w_bishop = { {`LIGHT, `BISHOP} };
      bins w_rook   = { {`LIGHT, `ROOK} };
      bins w_queen  = { {`LIGHT, `QUEEN} };
      bins w_king   = { {`LIGHT, `KING} };
      bins b_pawn   = { {`DARK, `PAWN} };
      bins b_knight = { {`DARK, `KNIGHT} };
      bins b_bishop = { {`DARK, `BISHOP} };
      bins b_rook   = { {`DARK, `ROOK} };
      bins b_queen  = { {`DARK, `QUEEN} };
      bins b_king   = { {`DARK, `KING} };
      ignore_bins empty_light = { {`LIGHT, `EMPTY} };
	  ignore_bins empty_dark = { {`DARK, `EMPTY} };
      illegal_bins illegal_piece = {'h7, 'hF};
   }
endgroup : square_value_cg




class eval_coverage extends uvm_component;  

   bit unsigned [3:0] square[64];
   int unsigned piece_number[8];
   int unsigned pawn_number[2];
   bit side;

   square_value_cg square_cg[64];
   piece_number_value_cg piece_number_cg[8];
   pawn_number_value_cg pawn_number_cg[2];
   side_value_cg side_cg; 

   
   function new(string name = "eval_coverage", uvm_component parent = null);
      super.new(name, parent);
	  
      foreach(square_cg[i])
        square_cg[i] = new();

      foreach(piece_number[i])
        piece_number_cg[i] = new(); 

	  foreach(pawn_number[i])
		pawn_number_cg[i] = new();
		
      side_cg = new(side); 

   endfunction : new

   //--------------------------------------------------------
   function collect_coverage(bit color_in[64], bit[2:0] piece_in[64], bit side_in);

	  foreach(piece_number[i])
        piece_number[i] = 0; 
	  foreach(pawn_number[i])
        pawn_number[i] = 0;

		
		
      foreach(square[i])
        begin
           square[i] = {color_in[i], piece_in[i]};
           square_cg[i].sample(square[i]);


           case(square[i])
             {`LIGHT, `PAWN}    : pawn_number[0]++;
			 {`DARK, `PAWN}   	: pawn_number[1]++;
			 
             {`LIGHT, `KNIGHT}  : piece_number[0]++;
             {`LIGHT, `BISHOP}  : piece_number[1]++;
             {`LIGHT, `ROOK}    : piece_number[2]++;
             {`LIGHT, `QUEEN} 	: piece_number[3]++;             
             {`DARK, `KNIGHT} 	: piece_number[4]++;
             {`DARK, `BISHOP} 	: piece_number[5]++;
             {`DARK, `ROOK}   	: piece_number[6]++;
             {`DARK, `QUEEN}    : piece_number[7]++;
           endcase
        end


      foreach(piece_number[i])
        piece_number_cg[i].sample(piece_number[i]); 

		
	  foreach(pawn_number[i])
        pawn_number_cg[i].sample(pawn_number[i]); 
		
      side = side_in;
      side_cg.sample(); 
	  
   endfunction : collect_coverage
   
endclass : eval_coverage 

`endif