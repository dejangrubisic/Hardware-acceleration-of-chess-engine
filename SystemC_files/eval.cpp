/*
 *	EVAL.C
 *	Tom Kerrigan's Simple Chess Program (TSCP)
 *
 *	Copyright 1997 Tom Kerrigan
 */




#include <iostream>
#include<cstdio>
#include "eval.hpp"
//-------------------------------------------------
#include <string.h>
//#include "defs.hpp"
//#include "data.hpp"
//#include "protos.hpp"
//-------------------------------------------------------------------------------

#define DOUBLED_PAWN_PENALTY		10
#define ISOLATED_PAWN_PENALTY		20
#define BACKWARDS_PAWN_PENALTY		8
#define PASSED_PAWN_BONUS			20
#define ROOK_SEMI_OPEN_FILE_BONUS	10
#define ROOK_OPEN_FILE_BONUS		15
#define ROOK_ON_SEVENTH_BONUS		20
//-------------------------------------------------------------------------------
//Dejan:Declaration from protos.hpp
/*
int eval_light_pawn(int sq);
int eval_dark_pawn(int sq);
int eval_light_king(int sq);
int eval_lkp(int f);
int eval_dark_king(int sq);
int eval_dkp(int f);
*/
//Dejan:Macros from defs.hpp
#define LIGHT			0
#define DARK			1

#define PAWN			0
#define KNIGHT			1
#define BISHOP			2
#define ROOK			3
#define QUEEN			4
#define KING			5

#define EMPTY			6
#define ROW(x)			((x) >> 3)    //dejan: Returns number of row of x
#define COL(x)			((x) & 7)     //dejan: Returns number of column of x
//-------------------------------------------------------------------------------

namespace hard_acc
{

//CONSTRUCTOR
m_eval::m_eval(sc_module_name n) : sc_module(n),
	f_w_pawn(8),
	f_w_knight(8),
	f_w_bishop(8),
	f_w_rook(8),
	f_w_queen(8),
	f_b_pawn(8),
	f_b_knight(8),
	f_b_bishop(8),
	f_b_rook(8),
	f_b_queen(8)

	{
		std::cout << name() << " constructed.\n";
		SC_THREAD(eval);
		sensitive_pos << start_in_eval;

		
		//Parallel methods
		SC_THREAD(piece_select);
		sensitive_pos << start_in;
//-----------------------------------------------------------------------------		
		// WHITE
		SC_THREAD(w_eval_pawn);
		sensitive_pos << start_in;			

		SC_THREAD(w_mat_pieces);
		sensitive_pos << start_in;


		SC_THREAD(w_eval_king);
		sensitive_pos << start_in;		


		SC_THREAD(w_op_mat);
		sensitive << s_b_mat_pieces_finished;
		sensitive << s_w_eval_king_finished;

//-----------------------------------------------------------------------------		
		// BLACK

		SC_THREAD(b_eval_pawn);
		sensitive_pos << start_in ;						

		SC_THREAD(b_mat_pieces);
		sensitive_pos << start_in;	


		SC_THREAD(b_eval_king);
		sensitive_pos << start_in;			


		SC_THREAD(b_op_mat);
		sensitive << s_w_mat_pieces_finished;
		sensitive << s_b_eval_king_finished;		
//-----------------------------------------------------------------------------		

		SC_THREAD(adder);
		sensitive_pos << s_w_pawn_finished;
		sensitive_pos << s_b_pawn_finished;
		sensitive_pos << s_w_mat_pieces_finished;
		sensitive_pos << s_b_mat_pieces_finished;
		sensitive_pos << s_w_op_finished;
		sensitive_pos << s_b_op_finished;



	}//END CONSTRUCTOR

//*******************************************************************************
//				PARALLEL MODEL
//*******************************************************************************
// WHITE
void m_eval::piece_select()
{
	int row, col;
	int temp_col = -1;
	int sq;

	while(1)
	{
		s_go = 0;
		temp_col = -1;	
		for(int i=0; i<10; i++)
		{
			rank[LIGHT][i] = 0;
			rank[DARK][i] = 7;
		}
		wait();
//-----------------------------------------------------------------------------------
	for(col=0; col<8; col++)	//i - a, b, c, d, e, f, g, h
		for(row=0; row<8; row++)	// j - 0, 1, 2, ..., 7
		{
			sq = 8*row+col;

			if(color[sq] == LIGHT)
			{
				switch(piece[sq])
				{

				case PAWN:	f_w_pawn.write(sq);
							if(row == 6)
								rank[LIGHT][col+1] = 6;
							else if(row == 5)
								rank[LIGHT][col+1] = 5;
							else if(row == 4)
								rank[LIGHT][col+1] = 4;
							else if(row == 3)
								rank[LIGHT][col+1] = 3;
							else if(row == 2)
								rank[LIGHT][col+1] = 2;
							else if(row == 1)
								rank[LIGHT][col+1] = 1;
							else
								rank[LIGHT][col+1] = 0;			
				
							break;
				case KNIGHT:	f_w_knight.write(sq);
							break;
				case BISHOP:	f_w_bishop.write(sq);	
							break;
				case ROOK:		f_w_rook.write(sq);
							break;
				case QUEEN:		f_w_queen.write(sq);
							break;
				case KING:		w_king = sq;
							break;

				}
			}
			else if(color[sq] == DARK)
			{
				switch(piece[sq])
				{

				case PAWN:	f_b_pawn.write(sq);
							if(temp_col == col)
								continue;
							if(row == 1)
								rank[DARK][col+1] = 1;
							else if(row == 2)
								rank[DARK][col+1] = 2;
							else if(row == 3)
								rank[DARK][col+1] = 3;
							else if(row == 4)
								rank[DARK][col+1] = 4;
							else if(row == 5)
								rank[DARK][col+1] = 5;
							else if(row == 6)
								rank[DARK][col+1] = 6;
							else
								rank[DARK][col+1] = 7;	
							
							temp_col = col;
							break;

				case KNIGHT:	f_b_knight.write(sq);
							break;
				case BISHOP:	f_b_bishop.write(sq);	
							break;
				case ROOK:		f_b_rook.write(sq);
							break;
				case QUEEN:		f_b_queen.write(sq);
							break;
				case KING:		b_king = sq;
							break;		
				}
			}

		}

//-----------------------------------------------------------------------------------
		s_go = 1;	//dejan: sign that white rank is prepared
		
		std::cout<<sc_time_stamp()<<"        RANK GO!!!!!!----------------------------------------- "<<std::endl;

		wait(1, SC_NS);

		while(finished->read() != 1)
			wait(1, SC_NS);
		

	}
}	
void m_eval::w_eval_pawn()	//input: s_w_pawn_sq,s_w_rank, s__pawn_sq,s_b_rank   | output:s_w_pawn_add
{
	int i;
	int res;


	while(1)
	{
		wait();
	
		res = 0;
		s_w_pawn_add = 0;
		s_w_pawn_finished = 0;

		//Rank should be ready by now
		while(s_go == 0)
			wait(1, SC_NS);

		//std::cout<<sc_time_stamp()<<" W_eval_pawn go"<<std::endl;
		//for(i = 0; i<8; i++)
			//std::cout<<"White Rank: "<< rank[LIGHT][i+1]<<" Black Rank: "<<rank[DARK][i+1]<<std::endl;

	//-----------------------------------------
		while(f_w_pawn.num_available() != 0)
		{
			int sq;
			int f;

			f_w_pawn.read(sq);
			f = COL(sq) + 1;

			res += pawn_pcsq[sq] + piece_value[PAWN];
			
		if (rank[LIGHT][f] > ROW(sq))
			res -= DOUBLED_PAWN_PENALTY;

		/* if there aren't any friendly pawns on either side of
		   this one, it's isolated */
		if ((rank[LIGHT][f - 1] == 0) && (rank[LIGHT][f + 1] == 0))
			res -= ISOLATED_PAWN_PENALTY;

		/* if it's not isolated, it might be backwards */
		else if ((rank[LIGHT][f - 1] < ROW(sq)) &&	(rank[LIGHT][f + 1] < ROW(sq)))
			res -= BACKWARDS_PAWN_PENALTY;

		/* add a bonus if the pawn is passed */
		if ((rank[DARK][f - 1] >= ROW(sq)) && (rank[DARK][f] >= ROW(sq)) &&
				(rank[DARK][f + 1] >= ROW(sq)))
			res += (7 - ROW(sq)) * PASSED_PAWN_BONUS;
	
		}

		s_w_pawn_add = res;
		s_w_pawn_finished = 1;	
		//std::cout<<sc_time_stamp()<<" W_eval_pawn finished"<<std::endl;

		wait(1, SC_NS);	

		while(finished->read() != 1)
			wait(1, SC_NS);
		s_w_pawn_finished = 0;		

	}
}

void m_eval::w_mat_pieces()
{
	int i;
	int mat_soft = 0;
	int mat_raw = 0;
	int sq;

	while(1)
	{
		mat_soft = 0;
		mat_raw = 0;
		wait();		

		while(s_go == 0)
			wait(1, SC_NS);
		
		//std::cout<<sc_time_stamp()<<" W_mat_pieces go"<<std::endl;

		while(f_w_knight.num_available() != 0)
		{
			f_w_knight.read(sq);
			mat_raw += piece_value[KNIGHT];	//knight
			mat_soft += knight_pcsq[sq] ;	
		}	
		while(f_w_bishop.num_available() != 0)
		{
			f_w_bishop.read(sq);
			mat_raw += piece_value[BISHOP];	//bishop
			mat_soft += bishop_pcsq[sq] ;	
		}
		while(f_w_rook.num_available() != 0)
		{
			f_w_rook.read(sq);
			mat_raw += piece_value[ROOK];	//rook
			if (rank[LIGHT][COL(sq) + 1] == 0) 
			{
				if (rank[DARK][COL(sq) + 1] == 7)
					mat_soft += ROOK_OPEN_FILE_BONUS;
				else
					mat_soft += ROOK_SEMI_OPEN_FILE_BONUS;
			}
			if (ROW(sq) == 1)
				mat_soft += ROOK_ON_SEVENTH_BONUS;
		}
		while(f_w_queen.num_available() != 0)
		{
			f_w_queen.read(sq);
			mat_raw += piece_value[QUEEN];
		}
		s_w_king_end = king_endgame_pcsq[w_king.read()];	//king
				
		//Done set control signals
		s_w_raw_mat = mat_raw;
		s_w_mat_pieces = mat_raw + mat_soft;
		s_w_mat_pieces_finished = 1;	

		//std::cout<<sc_time_stamp()<<" W_mat_pieces finished"<<std::endl;
		//std::cout<<"White_SUM = "<< mat_raw<<" + "<<mat_soft<<std::endl;

		wait(1, SC_NS);

		while(finished->read() != 1)
			wait(1, SC_NS);
		s_w_mat_pieces_finished = 0;	

	}

}
void m_eval::w_eval_king()
{
	int res;


	while(1)
	{
		res = 0;
	
		wait();		
		while(s_go == 0)
			wait(1, SC_NS);		


		res = king_pcsq[w_king];

		if(COL(w_king) < 3)
		{
			res += w_king_pawn(1);
			res += w_king_pawn(2);
			res += w_king_pawn(3)/2;
		}
		else if(COL(w_king) > 4)
		{
			res += w_king_pawn(8);
			res += w_king_pawn(7);
			res += w_king_pawn(6)/2;
		}
		else
		{
			for (int i = COL(w_king); i <= COL(w_king) + 2; ++i)
		    {
		        if ((rank[LIGHT][i] == 0) && (rank[DARK][i] == 7))
					res -= 10;
		    }
		}

	wait(1, SC_NS);

	//std::cout<<sc_time_stamp()<<" *2 White King [ "<<w_king<<" ] ="<< res <<std::endl;

	while(s_b_mat_pieces_finished == 0)
		wait(1, SC_NS);

	/* scale the king safety value according to the opponent's material;
	   the premise is that your king safety can only be bad if the
	   opponent has enough pieces to attack you */	
	res *= s_b_raw_mat;
	res /= 3100;
		

	s_w_eval_king = res;
	s_w_eval_king_finished = 1;
	
	//std::cout<<sc_time_stamp()<<" W_eval_king finished"<<std::endl;

	wait(1, SC_NS);	

	while(finished->read() != 1)
		wait(1, SC_NS);

	s_w_eval_king_finished = 0;
	
	}
}
int	m_eval::w_king_pawn(int f)		//helper method
{
	int r = 0;

	//std::cout<<"W_rank["<<f<<"] = "<< rank[LIGHT][f];
	//std::cout<<" B_rank["<<f<<"] = "<< rank[DARK][f]<<std::endl;

	if (rank[LIGHT][f] == 6);  /* pawn hasn't moved */
	else if (rank[LIGHT][f] == 5)
		r -= 10;  /* pawn moved one square */
	else if (rank[LIGHT][f] != 0)
		r -= 20;  /* pawn moved more than one square */
	else
		r -= 25;  /* no pawn on this file */

	if (rank[DARK][f] == 7)
		r -= 15;  /* no enemy pawn */
	else if (rank[DARK][f] == 5)
		r -= 10;  /* enemy pawn on the 3rd rank */
	else if (rank[DARK][f] == 4)
		r -= 5;   /* enemy pawn on the 4th rank */

	return r;

}

void m_eval::w_op_mat()
{
	while(1)
	{
		wait();		

		if(s_b_raw_mat <= 1200)
			s_w_op = s_w_king_end;
		else
			s_w_op = s_w_eval_king;

		s_w_op_finished = s_w_eval_king_finished & s_b_mat_pieces_finished;
	
	/*	if(s_w_eval_king_finished & s_b_mat_pieces_finished == 1)
		{
			std::cout<<sc_time_stamp()<<" White King = "<< s_w_op<<std::endl;
			while(finished->read() != 1)
				wait(1, SC_NS);
			s_w_op_finished = 0;
		}
	*/
	}

}
//----------------------------------------------------------
// BLACK

void m_eval::b_eval_pawn()
{

	int i;
	int res;

	while(1)
	{
		wait();

		//init
		res = 0;
		s_b_pawn_add = 0;
		s_b_pawn_finished = 0;


		//Rank should be ready by now
		while(s_go == 0)
			wait(1, SC_NS);
			//std::cout<<sc_time_stamp()<<" 1 BLACK s_go = "<< s_go << std::endl;
	//std::cout<<sc_time_stamp()<<" B_eval_pawn go"<<std::endl;
	//-----------------------------------------
		while(f_b_pawn.num_available() != 0)
		{
			int sq;
			int f;

			f_b_pawn.read(sq);
			f = COL(sq) + 1;

			res += pawn_pcsq[flip[sq]] + piece_value[PAWN];
			
		if (rank[DARK][f] < ROW(sq))
			res -= DOUBLED_PAWN_PENALTY;

		/* if there aren't any friendly pawns on either side of
		   this one, it's isolated */
		if ((rank[DARK][f - 1] == 7) && (rank[DARK][f + 1] == 7))
			res -= ISOLATED_PAWN_PENALTY;

		/* if it's not isolated, it might be backwards */
		else if ((rank[DARK][f - 1] > ROW(sq)) &&	(rank[DARK][f + 1] > ROW(sq)))
			res -= BACKWARDS_PAWN_PENALTY;

		/* add a bonus if the pawn is passed */
		if ((rank[LIGHT][f - 1] <= ROW(sq)) && (rank[LIGHT][f] <= ROW(sq)) &&
				(rank[LIGHT][f + 1] <= ROW(sq)))
			res += ROW(sq) * PASSED_PAWN_BONUS;
		}

		s_b_pawn_add = res;
		s_b_pawn_finished = 1;
		
		//std::cout<<sc_time_stamp()<<" B_eval_pawn finished"<<std::endl;

		wait(1, SC_NS);	

		while(finished->read() != 1)
			wait(1, SC_NS);
		s_b_pawn_finished = 0;	

	}
}
void m_eval::b_mat_pieces()
{
	int i;
	int mat_soft = 0;
	int mat_raw = 0;
	int sq;

	while(1)
	{
		mat_soft = 0;
		mat_raw = 0;
		wait();		

		while(s_go == 0)
			wait(1, SC_NS);
		
		//std::cout<<sc_time_stamp()<<" B_mat_pieces go"<<std::endl;

		while(f_b_knight.num_available() != 0)
		{
			f_b_knight.read(sq);
			mat_raw += piece_value[KNIGHT];	//knight
			mat_soft += knight_pcsq[flip[sq]] ;	
		}	
		while(f_b_bishop.num_available() != 0)
		{
			f_b_bishop.read(sq);
			mat_raw += piece_value[BISHOP];	//bishop
			mat_soft += bishop_pcsq[flip[sq]] ;	
		}
		while(f_b_rook.num_available() != 0)
		{
			f_b_rook.read(sq);
			mat_raw += piece_value[ROOK];	//rook
			if (rank[DARK][COL(sq) + 1] == 7) 
			{
				if (rank[LIGHT][COL(sq) + 1] == 0)
					mat_soft += ROOK_OPEN_FILE_BONUS;
				else
					mat_soft += ROOK_SEMI_OPEN_FILE_BONUS;
			}
			if (ROW(sq) == 6)
				mat_soft += ROOK_ON_SEVENTH_BONUS;
		}
		while(f_b_queen.num_available() != 0)
		{
			f_b_queen.read(sq);
			mat_raw += piece_value[QUEEN];
		}
		s_b_king_end = king_endgame_pcsq[flip[b_king.read()]];	//king

			

		//Done set control signals
		s_b_raw_mat = mat_raw;
		s_b_mat_pieces = mat_raw + mat_soft;
		s_b_mat_pieces_finished = 1;	
		//std::cout<<sc_time_stamp()<<" B_mat_pieces finished"<<std::endl;
		//std::cout<<"BLACK_SUM = "<< mat_raw<<" + "<<mat_soft<<std::endl;

		wait(1, SC_NS);	

		while(finished->read() != 1)
			wait(1, SC_NS);
		s_b_mat_pieces_finished = 0;	

	}
}

void m_eval::b_eval_king()
{
	int res;

	while(1)
	{
		res = 0;
	
		wait();		

		while(s_go == 0)
			wait(1, SC_NS);	
	
		//std::cout<<sc_time_stamp()<<" B_eval_king go"<<std::endl;

		res = king_pcsq[flip[b_king]];

		if(COL(b_king) < 3)
		{
			res += b_king_pawn(1);
			res += b_king_pawn(2);
			res += b_king_pawn(3)/2;
		}
		else if(COL(b_king) > 4)
		{
			res += b_king_pawn(8);
			res += b_king_pawn(7);
			res += b_king_pawn(6)/2;
		}
		else
		{
			for (int i = COL(b_king); i <= COL(b_king) + 2; ++i)
		    {
		        if ((rank[LIGHT][i] == 0) && (rank[DARK][i] == 7))
					res -= 10;
		    }
		}
	wait(1, SC_NS);
	//std::cout<<sc_time_stamp()<<" Black King [ "<<b_king<<" ] = "<< res<<std::endl;

	/* scale the king safety value according to the opponent's material;
	   the premise is that your king safety can only be bad if the
	   opponent has enough pieces to attack you */

	while(s_w_mat_pieces_finished == 0)	wait(1, SC_NS);

	res *= s_w_raw_mat;
	res /= 3100;
		

	s_b_eval_king = res;
	s_b_eval_king_finished = 1;
	
	//std::cout<<sc_time_stamp()<<" B_eval_king finished"<<std::endl;

	while(finished->read() != 1)
		wait(1, SC_NS);

	s_b_eval_king_finished = 0;
	
	}
}
int	m_eval::b_king_pawn(int f)		//helper method
{
	int r = 0;

	if (rank[DARK][f] == 1);  /* pawn hasn't moved */
	else if (rank[DARK][f] == 2)
		r -= 10;  /* pawn moved one square */
	else if (rank[DARK][f] != 7)
		r -= 20;  /* pawn moved more than one square */
	else
		r -= 25;  /* no pawn on this file */

	if (rank[LIGHT][f] == 0)
		r -= 15;  /* no enemy pawn */
	else if (rank[LIGHT][f] == 2)
		r -= 10;  /* enemy pawn on the 3rd rank */
	else if (rank[LIGHT][f] == 3)
		r -= 5;   /* enemy pawn on the 4th rank */

	return r;

}

void m_eval::b_op_mat()
{
	while(1)
	{
		wait();		

		if(s_w_raw_mat <= 1200)
			s_b_op = s_b_king_end;
		else
			s_b_op = s_b_eval_king;

		s_b_op_finished = s_b_eval_king_finished & s_w_mat_pieces_finished;
	
	/*	if(s_b_eval_king_finished & s_w_mat_pieces_finished == 1)
		{
			std::cout<<sc_time_stamp()<<" Dark King = "<< s_b_op<<std::endl;
			while(finished->read() != 1)
				wait(1, SC_NS);
			s_b_op_finished = 0;
		}
	*/
	}

}


//COMMON
void m_eval::adder()
{

	while(1)
	{
		finished->write(0);
		wait();
		
		if (side == LIGHT)
			result_parallel-> write(s_w_pawn_add + s_w_mat_pieces + s_w_op - s_b_pawn_add - s_b_mat_pieces - s_b_op);
		else
			result_parallel-> write(s_b_pawn_add + s_b_mat_pieces + s_b_op - s_w_pawn_add - s_w_mat_pieces - s_w_op);


		if((s_w_pawn_finished & s_b_pawn_finished & s_w_mat_pieces_finished & s_b_mat_pieces_finished & s_w_op_finished & s_b_op_finished) == 1)
		{		
			wait(1, SC_NS);
			finished -> write(1);

	
			std::cout<<std::endl<<"WHITE  \t \tBLACK"<<std::endl;
			std::cout<<"ukupno: "<<(s_w_mat_pieces+s_w_pawn_add+s_w_op);
			std::cout<<"\tukupno: "<<(s_b_mat_pieces+s_b_pawn_add+s_b_op)<<std::endl;

			std::cout<<"raw_mat: "<<s_w_raw_mat;
			std::cout<<"\traw_mat: "<<s_b_raw_mat<<std::endl;

			std::cout<<"soft_mat: "<<(s_w_mat_pieces-s_w_raw_mat);
			std::cout<<"\tsoft_mat: "<<(s_b_mat_pieces-s_b_raw_mat)<<std::endl;

			std::cout<<"pawns: "<<s_w_pawn_add;
			std::cout<<"\tpawns: "<<s_b_pawn_add<<std::endl;

			std::cout<<"king: "<<s_w_op;
			std::cout<<" \tking: "<<s_b_op <<std::endl;

			wait(1, SC_NS);
		}
		
	}
}











//****************** E V A L ******************************************************************
//****************** E V A L ******************************************************************
//****************** E V A L ******************************************************************
//****************** E V A L ******************************************************************
//****************** E V A L ******************************************************************
//****************** E V A L ******************************************************************
//****************** E V A L ******************************************************************
//****************** E V A L ******************************************************************

void m_eval::eval() //int color[64], int piece[64], int side
{
/*proba*/	int s_row_mat[2] = {0, 0};
			int s_mat[2] = {0, 0};
			int s_pawns[2] = {0, 0}; 
			int s_king[2] = {0, 0};

	while(1)
	{
	wait();
	start_in = 0;

	s_row_mat[0] = 0;	s_row_mat[1] = 0;
	s_mat[0] = 0;   	s_mat[1] = 0;
	s_pawns[0] = 0; 	s_pawns[1] = 0; 
	s_king[0] = 0; 		s_king[1] = 0;


	side = eval_side->read();

	for(int i = 0; i<64; i++)
	{
		color[i] = eval_color[i].read();
		piece[i] = eval_piece[i].read();
	}
	
//-----------------------------------------------------------
	wait(1, SC_NS);
	start_in = 1; 	// Run parallel module --------------------------------------------------
	
	std::cout <<std::endl<<"	SIDE = "<< (side ? " CRNI":" BELI ")<< std::endl;

	print_board();
//-----------------------------------------------------------TU KRECE NJIHOVO

	int i;
	int f;  /* file */
	int score[2];  /* each side's score */

	/* this is the first pass: set up pawn_rank, piece_mat, and pawn_mat. */
	for (i = 0; i < 10; ++i) {
		pawn_rank[LIGHT][i] = 0;
		pawn_rank[DARK][i] = 7;
	}
	piece_mat[LIGHT] = 0;
	piece_mat[DARK] = 0;
	pawn_mat[LIGHT] = 0;
	pawn_mat[DARK] = 0;
	for (i = 0; i < 64; ++i) {

		if (color[i] == EMPTY)
			continue;
		if (piece[i] == PAWN) {
			pawn_mat[color[i]] += piece_value[PAWN];
			f = COL(i) + 1;  /* add 1 because of the extra file in the array */
			if (color[i] == LIGHT) {
				if (pawn_rank[LIGHT][f] < ROW(i))
					pawn_rank[LIGHT][f] = ROW(i);
			}
			else {
				if (pawn_rank[DARK][f] > ROW(i))
					pawn_rank[DARK][f] = ROW(i);
			}
		}
		else
			piece_mat[color[i]] += piece_value[piece[i]];//---------------------------
	}
	/* this is the second pass: evaluate each piece */
	score[LIGHT] = piece_mat[LIGHT] + pawn_mat[LIGHT];//----------------------------
	score[DARK] = piece_mat[DARK] + pawn_mat[DARK];

	//provera
	s_row_mat[LIGHT] += piece_mat[LIGHT];
	s_row_mat[DARK] += piece_mat[DARK];

	s_pawns[LIGHT] += pawn_mat[LIGHT];
	s_pawns[DARK] += pawn_mat[DARK];

//	for(int i=0; i<8; i++)
//	std::cout<<"Rank Beli: "<<pawn_rank[LIGHT][i+1]<<" Rank Crni: "<<pawn_rank[DARK][i+1]<<std::endl;



	for (i = 0; i < 64; ++i) {
		if (color[i] == EMPTY)
			continue;
		if (color[i] == LIGHT) {
			switch (piece[i]) {
				case PAWN:
					score[LIGHT] += eval_light_pawn(i);
					s_pawns[LIGHT] += eval_light_pawn(i);//provera
					break;
				case KNIGHT:
					score[LIGHT] += knight_pcsq[i];
					s_mat[LIGHT] += knight_pcsq[i]; // provera
					break;
				case BISHOP:
					score[LIGHT] += bishop_pcsq[i];
					s_mat[LIGHT] += bishop_pcsq[i]; // provera
					break;
				case ROOK:
					if (pawn_rank[LIGHT][COL(i) + 1] == 0) 
					{
						if (pawn_rank[DARK][COL(i) + 1] == 7)
						{
							score[LIGHT] += ROOK_OPEN_FILE_BONUS;
							s_mat[LIGHT] += ROOK_OPEN_FILE_BONUS; // provera
						}
						else
						{
							score[LIGHT] += ROOK_SEMI_OPEN_FILE_BONUS;
							s_mat[LIGHT] += ROOK_SEMI_OPEN_FILE_BONUS; // provera
						}
					}
					if (ROW(i) == 1)
					{
						score[LIGHT] += ROOK_ON_SEVENTH_BONUS;
						s_mat[LIGHT] += ROOK_ON_SEVENTH_BONUS; // provera						
					}
					break;
				case KING:
					if (piece_mat[DARK] <= 1200)
					{
						score[LIGHT] += king_endgame_pcsq[i];
						s_king[LIGHT] += king_endgame_pcsq[i];
					}
					else
					{
						score[LIGHT] += eval_light_king(i);
						s_king[LIGHT] += eval_light_king(i);
					}
					break;
			}
		}
		else {
			switch (piece[i]) {
				case PAWN:
					score[DARK] += eval_dark_pawn(i);
					s_pawns[DARK] += eval_dark_pawn(i);	//provera
					break;
				case KNIGHT:
					score[DARK] += knight_pcsq[flip[i]];
					s_mat[DARK] += knight_pcsq[flip[i]]; 
					break;
				case BISHOP:
					score[DARK] += bishop_pcsq[flip[i]];
					s_mat[DARK] += bishop_pcsq[flip[i]];
					break;
				case ROOK:
					if (pawn_rank[DARK][COL(i) + 1] == 7) 
					{
						if (pawn_rank[LIGHT][COL(i) + 1] == 0)
						{
							score[DARK] += ROOK_OPEN_FILE_BONUS;
							s_mat[DARK] += ROOK_OPEN_FILE_BONUS;
						}
						else
						{
							score[DARK] += ROOK_SEMI_OPEN_FILE_BONUS;
							s_mat[DARK] += ROOK_SEMI_OPEN_FILE_BONUS;
						}
					}
					if (ROW(i) == 6)
					{
						score[DARK] += ROOK_ON_SEVENTH_BONUS;
						s_mat[DARK] += ROOK_ON_SEVENTH_BONUS;
					}
					break;
				case KING:
					if (piece_mat[LIGHT] <= 1200)
					{
						score[DARK] += king_endgame_pcsq[flip[i]];
						s_king[DARK] += king_endgame_pcsq[flip[i]];
					}
					else
					{
						score[DARK] += eval_dark_king(i);
						s_king[DARK] += eval_dark_king(i);
					}
					break;
			}
		}
	}

	/* the score[] array is set, now return the score relative
	   to the side to move */

	std::cout<<"Beli ukupno = "<<score[LIGHT]<<"\tCrni ukupno = "<<score[DARK]<<std::endl;
	std::cout<<"Beli raw_mat = "<<s_row_mat[LIGHT]<<"\tCrni raw_mat = "<<s_row_mat[DARK]<<std::endl;
	std::cout<<"Beli soft_mat = "<<s_mat[LIGHT]<<"\tCrni soft_mat = "<<s_mat[DARK]<<std::endl;
	std::cout<<"Beli pawns = "<<s_pawns[LIGHT]<<"\tCrni pawns = "<<s_pawns[DARK]<<std::endl;
	std::cout<<"Beli king = "<<s_king[LIGHT]<<"\t\tCrni king = "<<s_king[DARK]<<std::endl;

	if (side == LIGHT)
		result_seq->write(score[LIGHT] - score[DARK]);//return score[LIGHT] - score[DARK];
	else
		result_seq->write(score[DARK] - score[LIGHT]);//return score[DARK] - score[LIGHT];

	//start_out = !start_out;

	}
}



int m_eval::eval_light_pawn(int sq)
{
	int r;  /* the value to return */
	int f;  /* the pawn's file */

	r = 0;
	f = COL(sq) + 1;

	r += pawn_pcsq[sq];

	/* if there's a pawn behind this one, it's doubled */
	if (pawn_rank[LIGHT][f] > ROW(sq))
		r -= DOUBLED_PAWN_PENALTY;

	/* if there aren't any friendly pawns on either side of
	   this one, it's isolated */
	if ((pawn_rank[LIGHT][f - 1] == 0) &&
			(pawn_rank[LIGHT][f + 1] == 0))
		r -= ISOLATED_PAWN_PENALTY;

	/* if it's not isolated, it might be backwards */
	else if ((pawn_rank[LIGHT][f - 1] < ROW(sq)) &&
			(pawn_rank[LIGHT][f + 1] < ROW(sq)))
		r -= BACKWARDS_PAWN_PENALTY;

	/* add a bonus if the pawn is passed */
	if ((pawn_rank[DARK][f - 1] >= ROW(sq)) &&
			(pawn_rank[DARK][f] >= ROW(sq)) &&
			(pawn_rank[DARK][f + 1] >= ROW(sq)))
		r += (7 - ROW(sq)) * PASSED_PAWN_BONUS;

	return r;
}

int m_eval::eval_dark_pawn(int sq)
{
	int r;  /* the value to return */
	int f;  /* the pawn's file */

	r = 0;
	f = COL(sq) + 1;

	r += pawn_pcsq[flip[sq]];

	/* if there's a pawn behind this one, it's doubled */
	if (pawn_rank[DARK][f] < ROW(sq))
		r -= DOUBLED_PAWN_PENALTY;

	/* if there aren't any friendly pawns on either side of
	   this one, it's isolated */
	if ((pawn_rank[DARK][f - 1] == 7) &&
			(pawn_rank[DARK][f + 1] == 7))
		r -= ISOLATED_PAWN_PENALTY;

	/* if it's not isolated, it might be backwards */
	else if ((pawn_rank[DARK][f - 1] > ROW(sq)) &&
			(pawn_rank[DARK][f + 1] > ROW(sq)))
		r -= BACKWARDS_PAWN_PENALTY;

	/* add a bonus if the pawn is passed */
	if ((pawn_rank[LIGHT][f - 1] <= ROW(sq)) &&
			(pawn_rank[LIGHT][f] <= ROW(sq)) &&
			(pawn_rank[LIGHT][f + 1] <= ROW(sq)))
		r += ROW(sq) * PASSED_PAWN_BONUS;

	return r;
}

int m_eval:: eval_light_king(int sq)
{
	int r;  /* the value to return */
	int i;

	r = king_pcsq[sq];

	/* if the king is castled, use a special function to evaluate the
	   pawns on the appropriate side */
	if (COL(sq) < 3) {
		r += eval_lkp(1);
		r += eval_lkp(2);
		r += eval_lkp(3) / 2;  /* problems with pawns on the c & f files
								  are not as severe */
	}
	else if (COL(sq) > 4) {
		r += eval_lkp(8);
		r += eval_lkp(7);
		r += eval_lkp(6) / 2;
	}

	/* otherwise, just assess a penalty if there are open files near
	   the king */
	else {
		for (i = COL(sq); i <= COL(sq) + 2; ++i)
			if ((pawn_rank[LIGHT][i] == 0) &&
					(pawn_rank[DARK][i] == 7))
				r -= 10;
	}

	/* scale the king safety value according to the opponent's material;
	   the premise is that your king safety can only be bad if the
	   opponent has enough pieces to attack you */
	r *= piece_mat[DARK];
	r /= 3100;

	return r;
}

/* eval_lkp(f) evaluates the Light King Pawn on file f */

int m_eval:: eval_lkp(int f)
{
	int r = 0;

	if (pawn_rank[LIGHT][f] == 6);  /* pawn hasn't moved */
	else if (pawn_rank[LIGHT][f] == 5)
		r -= 10;  /* pawn moved one square */
	else if (pawn_rank[LIGHT][f] != 0)
		r -= 20;  /* pawn moved more than one square */
	else
		r -= 25;  /* no pawn on this file */

	if (pawn_rank[DARK][f] == 7)
		r -= 15;  /* no enemy pawn */
	else if (pawn_rank[DARK][f] == 5)
		r -= 10;  /* enemy pawn on the 3rd rank */
	else if (pawn_rank[DARK][f] == 4)
		r -= 5;   /* enemy pawn on the 4th rank */

	return r;
}

int m_eval:: eval_dark_king(int sq)
{
	int r;
	int i;

	r = king_pcsq[flip[sq]];
	if (COL(sq) < 3) {
		r += eval_dkp(1);
		r += eval_dkp(2);
		r += eval_dkp(3) / 2;
	}
	else if (COL(sq) > 4) {
		r += eval_dkp(8);
		r += eval_dkp(7);
		r += eval_dkp(6) / 2;
	}
	else {
		for (i = COL(sq); i <= COL(sq) + 2; ++i)
			if ((pawn_rank[LIGHT][i] == 0) &&
					(pawn_rank[DARK][i] == 7))
				r -= 10;
	}
	r *= piece_mat[LIGHT];
	r /= 3100;
	return r;
}

int m_eval:: eval_dkp(int f)
{
	int r = 0;

	if (pawn_rank[DARK][f] == 1);   /* pawn hasn't moved */
	else if (pawn_rank[DARK][f] == 2)
		r -= 10;
	else if (pawn_rank[DARK][f] != 7)
		r -= 20;
	else
		r -= 25;

	if (pawn_rank[LIGHT][f] == 0)
		r -= 15;
	else if (pawn_rank[LIGHT][f] == 2)
		r -= 10;
	else if (pawn_rank[LIGHT][f] == 3)
		r -= 5;

	return r;
}

void m_eval::print_board()
{
	int i;
	char piece_char[6] = {'P', 'N', 'B', 'R', 'Q', 'K'};
	printf("\n8 ");
	for (i = 0; i < 64; ++i) {
		switch (color[i]) {
			case EMPTY:
				printf(" .");
				break;
			case LIGHT:
				printf(" %c", piece_char[piece[i]]);
				break;
			case DARK:
				printf(" %c", piece_char[piece[i]] + ('a' - 'A'));
				break;
		}
		if ((i + 1) % 8 == 0 && i != 63)
			printf("\n%d ", 7 - ROW(i));
	}
	printf("\n\n   a b c d e f g h\n\n");
}

}
//using namespace hard_acc
