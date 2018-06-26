`ifndef EVAL_PREDICTOR_SV
`define EVAL_PREDICTOR_SV

//Macros - Bonus points
`define DOUBLED_PAWN_PENALTY		10
`define ISOLATED_PAWN_PENALTY		20
`define BACKWARDS_PAWN_PENALTY		8
`define PASSED_PAWN_BONUS			20
`define ROOK_SEMI_OPEN_FILE_BONUS	10
`define ROOK_OPEN_FILE_BONUS		15
`define ROOK_ON_SEVENTH_BONUS		20
/*
//Macros - pieces
`define LIGHT			0
`define DARK			1

`define PAWN			0
`define KNIGHT			1
`define BISHOP			2
`define ROOK			3
`define QUEEN			4
`define KING			5

`define EMPTY			6

*/
//Functions  find ROW and COLUMN
//`define ROW(x)	(x << 3)
function int ROW( int x);
	return (x >> 3);
endfunction : ROW

//`define COL(x)	(x & 7)
function int COL( int x);
	return (x & 3'b111);
endfunction : COL






/* the values of the pieces */
int piece_value[6] = {
	100, 300, 300, 500, 900, 0
};

/* The "pcsq" arrays are piece/square tables. They're values
   added to the material value of the piece based on the
   location of the piece. */

int pawn_pcsq[64] = {
	  0,   0,   0,   0,   0,   0,   0,   0,
	  5,  10,  15,  20,  20,  15,  10,   5,
	  4,   8,  12,  16,  16,  12,   8,   4,
	  3,   6,   9,  12,  12,   9,   6,   3,
	  2,   4,   6,   8,   8,   6,   4,   2,
	  1,   2,   3, -10, -10,   3,   2,   1,
	  0,   0,   0, -40, -40,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0
};

int knight_pcsq[64] = {
	-10, -10, -10, -10, -10, -10, -10, -10,
	-10,   0,   0,   0,   0,   0,   0, -10,
	-10,   0,   5,   5,   5,   5,   0, -10,
	-10,   0,   5,  10,  10,   5,   0, -10,
	-10,   0,   5,  10,  10,   5,   0, -10,
	-10,   0,   5,   5,   5,   5,   0, -10,
	-10,   0,   0,   0,   0,   0,   0, -10,
	-10, -30, -10, -10, -10, -10, -30, -10
};

int bishop_pcsq[64] = {
	-10, -10, -10, -10, -10, -10, -10, -10,
	-10,   0,   0,   0,   0,   0,   0, -10,
	-10,   0,   5,   5,   5,   5,   0, -10,
	-10,   0,   5,  10,  10,   5,   0, -10,
	-10,   0,   5,  10,  10,   5,   0, -10,
	-10,   0,   5,   5,   5,   5,   0, -10,
	-10,   0,   0,   0,   0,   0,   0, -10,
	-10, -10, -20, -10, -10, -20, -10, -10
};

int king_pcsq[64] = {
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-20, -20, -20, -20, -20, -20, -20, -20,
	  0,  20,  40, -20,   0, -20,  40,  20
};

int king_endgame_pcsq[64] = {
	  0,  10,  20,  30,  30,  20,  10,   0,
	 10,  20,  30,  40,  40,  30,  20,  10,
	 20,  30,  40,  50,  50,  40,  30,  20,
	 30,  40,  50,  60,  60,  50,  40,  30,
	 30,  40,  50,  60,  60,  50,  40,  30,
	 20,  30,  40,  50,  50,  40,  30,  20,
	 10,  20,  30,  40,  40,  30,  20,  10,
	  0,  10,  20,  30,  30,  20,  10,   0
};

/* The flip array is used to calculate the piece/square
   values for `DARK pieces. The piece/square value of a
   `LIGHT pawn is pawn_pcsq[sq] and the value of a `DARK
   pawn is pawn_pcsq[flip[sq]] */
int flip[64] = {
	 56,  57,  58,  59,  60,  61,  62,  63,
	 48,  49,  50,  51,  52,  53,  54,  55,
	 40,  41,  42,  43,  44,  45,  46,  47,
	 32,  33,  34,  35,  36,  37,  38,  39,
	 24,  25,  26,  27,  28,  29,  30,  31,
	 16,  17,  18,  19,  20,  21,  22,  23,
	  8,   9,  10,  11,  12,  13,  14,  15,
	  0,   1,   2,   3,   4,   5,   6,   7
};

/* pawn_rank[x][y] is the rank of the least advanced pawn of color x on file
   y - 1. There are "buffer files" on the left and right to avoid special-case
   logic later. If there's no pawn on a rank, we pretend the pawn is
   impossibly far advanced (0 for `LIGHT and 7 for `DARK). This makes it easy to
   test for pawns on a rank and it simplifies some pawn evaluation code. */
int pawn_rank[2][10];

int piece_mat[2];  /* the value of a side's pieces */
int pawn_mat[2];  /* the value of a side's pawns */
	
function void print_board(bit color_in[64], bit[2:0] piece_in[64]);
		
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


	
function int predict(bit color[64], bit[2:0] piece[64], bit side);

	int i;
	int f;  /* file */
	int score[2];  /* each side's score */

	//Moje promenjive da se lakse debaguje
	int s_row_mat[2];
	int s_soft_mat[2];
	int s_pawns[2]; 
	int s_king[2];
	
	s_row_mat[0] = 0;	s_row_mat[1] = 0;
	s_soft_mat[0] = 0;   	s_soft_mat[1] = 0;
	s_pawns[0] = 0; 	s_pawns[1] = 0; 
	s_king[0] = 0; 		s_king[1] = 0;
	
	
	
	$display("%0t Predictor table", $time);
	print_board(color, piece);
	
	
	// this is the first pass: set up pawn_rank, piece_mat, and pawn_mat.
	for (i = 0; i < 10; ++i) 
	begin
		pawn_rank[`LIGHT][i] = 0;
		pawn_rank[`DARK][i] = 7;
	end
	
	piece_mat[`LIGHT] = 0;
	piece_mat[`DARK] = 0;
	pawn_mat[`LIGHT] = 0;
	pawn_mat[`DARK] = 0;
	for (i = 0; i < 64; ++i) 
	begin
		if (piece[i] == `EMPTY)
			continue;
		if (piece[i] == `PAWN) 
		begin
			pawn_mat[color[i]] += piece_value[`PAWN];
			f = COL(i) + 1;  /* add 1 because of the extra file in the array */
			if (color[i] == `LIGHT) 
			begin
				if (pawn_rank[`LIGHT][f] < ROW(i))
					pawn_rank[`LIGHT][f] = ROW(i);
			end
			else 
			begin
				if (pawn_rank[`DARK][f] > ROW(i))
					pawn_rank[`DARK][f] = ROW(i);
			end
		end
		else
			piece_mat[color[i]] += piece_value[piece[i]];
	end

	/* this is the second pass: evaluate each piece */
	score[`LIGHT] = piece_mat[`LIGHT] + pawn_mat[`LIGHT];
	score[`DARK] = piece_mat[`DARK] + pawn_mat[`DARK];
	
	s_row_mat[`LIGHT] += piece_mat[`LIGHT];
	s_row_mat[`DARK] += piece_mat[`DARK];

	s_pawns[`LIGHT] += pawn_mat[`LIGHT];
	s_pawns[`DARK] += pawn_mat[`DARK];
	
	
	
	for (i = 0; i < 64; ++i) 
	begin
		if (piece[i] == `EMPTY)
			continue;
		if (color[i] == `LIGHT) 
		begin
			case (piece[i]) 			
			`PAWN:
				begin
					score[`LIGHT] += eval_light_pawn(i);
					s_pawns[`LIGHT] += eval_light_pawn(i);//provera
				end
			`KNIGHT:
				begin
					score[`LIGHT] += knight_pcsq[i];
					s_soft_mat[`LIGHT] += knight_pcsq[i]; // provera
				end	
			`BISHOP:
				begin
					score[`LIGHT] += bishop_pcsq[i];
					s_soft_mat[`LIGHT] += bishop_pcsq[i]; // provera
				end
			`ROOK: 				
				begin
					if (pawn_rank[`LIGHT][COL(i) + 1] == 0) 
					begin
						if (pawn_rank[`DARK][COL(i) + 1] == 7) begin
							score[`LIGHT] += `ROOK_OPEN_FILE_BONUS;
							s_soft_mat[`LIGHT] += `ROOK_OPEN_FILE_BONUS; // provera
						end
						else begin
							score[`LIGHT] += `ROOK_SEMI_OPEN_FILE_BONUS;						
							s_soft_mat[`LIGHT] += `ROOK_SEMI_OPEN_FILE_BONUS; // provera
						end
					end
					if (ROW(i) == 1) begin
						score[`LIGHT] += `ROOK_ON_SEVENTH_BONUS;
						s_soft_mat[`LIGHT] += `ROOK_ON_SEVENTH_BONUS; // provera	s_mat[LIGHT] += ROOK_ON_SEVENTH_BONUS; // provera	
					end
				end				
			`KING:
				begin
					if (piece_mat[`DARK] <= 1200) begin
						score[`LIGHT] += king_endgame_pcsq[i];
						s_king[`LIGHT] += king_endgame_pcsq[i];
					end
					else begin
						score[`LIGHT] += eval_light_king(i);
						s_king[`LIGHT] += eval_light_king(i);
					end
				end
			endcase
		end
		else 
		begin
			case (piece[i])
			`PAWN:
				begin
					score[`DARK] += eval_dark_pawn(i);
					s_pawns[`DARK] += eval_dark_pawn(i);	//provera
				end
			`KNIGHT:
				begin
					score[`DARK] += knight_pcsq[flip[i]];
					s_soft_mat[`DARK] += knight_pcsq[flip[i]];  	//provera
				end
			`BISHOP:
				begin
					score[`DARK] += bishop_pcsq[flip[i]];
					s_soft_mat[`DARK] += bishop_pcsq[flip[i]];	//provera
				end
			`ROOK:
				begin
					if (pawn_rank[`DARK][COL(i) + 1] == 7) 
					begin
						if (pawn_rank[`LIGHT][COL(i) + 1] == 0) begin
							score[`DARK] += `ROOK_OPEN_FILE_BONUS;
							s_soft_mat[`DARK] += `ROOK_OPEN_FILE_BONUS;
						end
						else begin
							score[`DARK] += `ROOK_SEMI_OPEN_FILE_BONUS;
							s_soft_mat[`DARK] += `ROOK_SEMI_OPEN_FILE_BONUS;
						end
					end
					
					if (ROW(i) == 6) begin
						score[`DARK] += `ROOK_ON_SEVENTH_BONUS;
						s_soft_mat[`DARK] += `ROOK_ON_SEVENTH_BONUS;
					end
				end
			`KING:
				begin
					if (piece_mat[`LIGHT] <= 1200) begin
						score[`DARK] += king_endgame_pcsq[flip[i]];
						s_king[`DARK] += king_endgame_pcsq[flip[i]];
					end
					else begin
						score[`DARK] += eval_dark_king(i);
						s_king[`DARK] += eval_dark_king(i);
					end
				end
			endcase
		end
	end
	$display("PLAYS ---->  %s ", side ? "CRNI":"BELI");
	$display("RAW_MATERIAL: 	Beli = %0d 	|	Crni = %0d ", s_row_mat[`LIGHT], s_row_mat[`DARK] );
	$display("SOFT_MATERIAL:	Beli = %0d 	|	Crni = %0d ", s_soft_mat[`LIGHT], s_soft_mat[`DARK] );
	$display("PAWNS: 			Beli = %0d 	|	Crni = %0d ", s_pawns[`LIGHT], s_pawns[`DARK] );
	$display("KING: 			Beli = %0d 	|	Crni = %0d ", s_king[`LIGHT], s_king[`DARK] );
	
	
	
	
	/* the score[] array is set, now return the score relative
	   to the side to move */
	if (side == `LIGHT)
		return score[`LIGHT] - score[`DARK];
	else	
		return score[`DARK] - score[`LIGHT];

endfunction : predict

function int eval_light_pawn(int sq);

	int r;  /* the value to return */
	int f;  /* the pawn's file */

	r = 0;
	f = COL(sq) + 1;

	r += pawn_pcsq[sq];

	/* if there's a pawn behind this one, it's doubled */
	if (pawn_rank[`LIGHT][f] > ROW(sq))
		r -= `DOUBLED_PAWN_PENALTY;

	/* if there aren't any friendly pawns on either side of
	   this one, it's isolated */
	if ((pawn_rank[`LIGHT][f - 1] == 0) &&
			(pawn_rank[`LIGHT][f + 1] == 0))
		r -= `ISOLATED_PAWN_PENALTY;

	/* if it's not isolated, it might be backwards */
	else if ((pawn_rank[`LIGHT][f - 1] < ROW(sq)) &&
			(pawn_rank[`LIGHT][f + 1] < ROW(sq)))
		r -= `BACKWARDS_PAWN_PENALTY;

	/* add a bonus if the pawn is passed */
	if ((pawn_rank[`DARK][f - 1] >= ROW(sq)) &&
			(pawn_rank[`DARK][f] >= ROW(sq)) &&
			(pawn_rank[`DARK][f + 1] >= ROW(sq)))
		r += (7 - ROW(sq)) * `PASSED_PAWN_BONUS;

	return r;
endfunction : eval_light_pawn

function int eval_dark_pawn(int sq);

	int r;  /* the value to return */
	int f;  /* the pawn's file */

	r = 0;
	f = COL(sq) + 1;

	r += pawn_pcsq[flip[sq]];

	/* if there's a pawn behind this one, it's doubled */
	if (pawn_rank[`DARK][f] < ROW(sq))
		r -= `DOUBLED_PAWN_PENALTY;

	/* if there aren't any friendly pawns on either side of
	   this one, it's isolated */
	if ((pawn_rank[`DARK][f - 1] == 7) &&
			(pawn_rank[`DARK][f + 1] == 7))
		r -= `ISOLATED_PAWN_PENALTY;

	/* if it's not isolated, it might be backwards */
	else if ((pawn_rank[`DARK][f - 1] > ROW(sq)) &&
			(pawn_rank[`DARK][f + 1] > ROW(sq)))
		r -= `BACKWARDS_PAWN_PENALTY;

	/* add a bonus if the pawn is passed */
	if ((pawn_rank[`LIGHT][f - 1] <= ROW(sq)) &&
			(pawn_rank[`LIGHT][f] <= ROW(sq)) &&
			(pawn_rank[`LIGHT][f + 1] <= ROW(sq)))
		r += ROW(sq) * `PASSED_PAWN_BONUS;

	return r;
endfunction : eval_dark_pawn

function int eval_light_king(int sq);

	int r;  /* the value to return */
	int i;

	r = king_pcsq[sq];

	/* if the king is castled, use a special function to evaluate the
	   pawns on the appropriate side */
	if (COL(sq) < 3) 
	begin
		r += eval_lkp(1);
		r += eval_lkp(2);
		r += eval_lkp(3) / 2;  /* problems with pawns on the c & f files
								  are not as severe */
	end
	else if (COL(sq) > 4) 
	begin
		r += eval_lkp(8);
		r += eval_lkp(7);
		r += eval_lkp(6) / 2;
	end

	/* otherwise, just assess a penalty if there are open files near
	   the king */
	else 
	begin
		for (i = COL(sq); i <= COL(sq) + 2; ++i)        
            if ((pawn_rank[`LIGHT][i] == 0) && (pawn_rank[`DARK][i] == 7))
				r -= 10;
	end

	/* scale the king safety value according to the opponent's material;
	   the premise is that your king safety can only be bad if the
	   opponent has enough pieces to attack you */
	   
	
	r *= piece_mat[`DARK];
	
	r /= 3100;
	
	return r;
endfunction : eval_light_king

/* eval_lkp(f) evaluates the Light King Pawn on file f */

function int eval_lkp(int f);

	int r;
	r = 0;	//ako je int r = 0; // r = 0; se zapravo i ne izvrsi
	
	if (pawn_rank[`LIGHT][f] == 6);  /* pawn hasn't moved */
	else if (pawn_rank[`LIGHT][f] == 5)
		r -= 10;  /* pawn moved one square */
	else if (pawn_rank[`LIGHT][f] != 0)
		r -= 20;  /* pawn moved more than one square */
	else
		r -= 25;  /* no pawn on this file */

	if (pawn_rank[`DARK][f] == 7)
		r -= 15;  /* no enemy pawn */
	else if (pawn_rank[`DARK][f] == 5)
		r -= 10;  /* enemy pawn on the 3rd rank */
	else if (pawn_rank[`DARK][f] == 4)
		r -= 5;   /* enemy pawn on the 4th rank */

	return r;
endfunction : eval_lkp

function int eval_dark_king(int sq);

	int r;
	int i;

	r = king_pcsq[flip[sq]];
	if (COL(sq) < 3) 
	begin
		r += eval_dkp(1);
		r += eval_dkp(2);
		r += eval_dkp(3) / 2;
	end
	else if (COL(sq) > 4) 
	begin
		r += eval_dkp(8);
		r += eval_dkp(7);
		r += eval_dkp(6) / 2;
	end
	else 
	begin
		for (i = COL(sq); i <= COL(sq) + 2; ++i)        
            if ((pawn_rank[`LIGHT][i] == 0) && (pawn_rank[`DARK][i] == 7))
				r -= 10;        
	end

	r *= piece_mat[`LIGHT];
	r /= 3100;
	return r;
endfunction : eval_dark_king

function int eval_dkp(int f);

	int r;

	r = 0;
	
	if (pawn_rank[`DARK][f] == 1);   /* pawn hasn't moved */
	else if (pawn_rank[`DARK][f] == 2)
		r -= 10;
	else if (pawn_rank[`DARK][f] != 7)
		r -= 20;
	else
		r -= 25;

	if (pawn_rank[`LIGHT][f] == 0)
		r -= 15;
	else if (pawn_rank[`LIGHT][f] == 2)
		r -= 10;
	else if (pawn_rank[`LIGHT][f] == 3)
		r -= 5;

	return r;
endfunction : eval_dkp

`endif