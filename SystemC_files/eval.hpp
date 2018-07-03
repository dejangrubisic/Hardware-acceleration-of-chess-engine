#ifndef _M_EVAL_HPP_
#define _M_EVAL_HPP_

#include <systemc>

namespace hard_acc
{
using namespace sc_core;
using namespace sc_dt;
SC_MODULE(m_eval)
{
public:
	SC_HAS_PROCESS(m_eval);

	m_eval(sc_module_name);


	sc_core::sc_in<int> eval_color[64];	
	sc_core::sc_in<int> eval_piece[64];	
	sc_core::sc_in<int> eval_side;	
	sc_core::sc_in<bool> start_in_eval;

	sc_core::sc_out<int> result_seq;

	//COMMON
	sc_core::sc_out<int> result_parallel;
	sc_core::sc_out<bool> finished;
//------------------------------------------------------------
protected:
	void eval();	// Main_method
	//Dejan:Declaration from protos.hpp
	int eval_light_pawn(int sq);
	int eval_dark_pawn(int sq);
	int eval_light_king(int sq);
	int eval_lkp(int f);
	int eval_dark_king(int sq);
	int eval_dkp(int f);

	int color[64]; 
	int piece[64]; 
	int side;
	

	void print_board();

	sc_core::sc_signal<int> rank[2][10];	// *RANK -> the least advanced pawn
	sc_core::sc_signal<bool> start_in;		//-------------start hardware-------------

	// Methods for parallel design
	void piece_select();
	sc_core::sc_fifo<int> f_w_pawn;	//used by mat_pieces
	sc_core::sc_fifo<int> f_w_knight;	//used by mat_pieces
	sc_core::sc_fifo<int> f_w_bishop;	//used by mat_pieces
	sc_core::sc_fifo<int> f_w_rook;	//used by mat_pieces
	sc_core::sc_fifo<int> f_w_queen;	//used by mat_pieces
	sc_core::sc_signal<int> w_king;

	sc_core::sc_fifo<int> f_b_pawn;	//used by mat_pieces
	sc_core::sc_fifo<int> f_b_knight;	//used by mat_pieces
	sc_core::sc_fifo<int> f_b_bishop;	//used by mat_pieces
	sc_core::sc_fifo<int> f_b_rook;	//used by mat_pieces
	sc_core::sc_fifo<int> f_b_queen;	//used by mat_pieces
	sc_core::sc_signal<int> b_king;

	sc_core::sc_signal<bool> s_go;	//used by w_eval_pawn, b_eval_pawn

	void adder();

	// WHITE
//------------------------------------------------------------
	void w_eval_pawn();
	sc_core::sc_signal<int> s_w_pawn_add; //used by adder
	sc_core::sc_signal<bool> s_w_pawn_finished;
//------------------------------------------------------------
	void w_mat_pieces();
	sc_core::sc_signal<int> s_w_raw_mat;
	sc_core::sc_signal<int> s_w_mat_pieces; //used by adder, b_op_mat
	sc_core::sc_signal<bool> s_w_mat_pieces_finished;
	sc_core::sc_signal<int> s_w_king_end;
//------------------------------------------------------------
	void w_eval_king();
	sc_core::sc_signal<int> s_w_eval_king; //used by w_op_mat
	sc_core::sc_signal<bool> s_w_eval_king_finished;
	int	w_king_pawn(int f);		//helper method
//------------------------------------------------------------
	void w_op_mat();
	sc_core::sc_signal<int> s_w_op; //used by adder
	sc_core::sc_signal<bool> s_w_op_finished;
//------------------------------------------------------------
	// BLACK
//------------------------------------------------------------
	void b_eval_pawn();
	sc_core::sc_signal<int> s_b_pawn_add; //used by adder
	sc_core::sc_signal<bool> s_b_pawn_finished;
//------------------------------------------------------------
	void b_mat_pieces();
	sc_core::sc_signal<int> s_b_raw_mat;
	sc_core::sc_signal<int> s_b_mat_pieces; //used by adder, b_op_mat
	sc_core::sc_signal<bool> s_b_mat_pieces_finished;
	sc_core::sc_signal<int> s_b_king_end;
//------------------------------------------------------------
	void b_eval_king();
	sc_core::sc_signal<int> s_b_eval_king; //used by w_op_mat
	sc_core::sc_signal<bool> s_b_eval_king_finished;
	int	b_king_pawn(int f);		//helper method
//------------------------------------------------------------
	void b_op_mat();
	sc_core::sc_signal<int> s_b_op; //used by adder
	sc_core::sc_signal<bool> s_b_op_finished;
//------------------------------------------------------------


	//VARIABLES AND CONSTANTS

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
		   values for DARK pieces. The piece/square value of a
		   LIGHT pawn is pawn_pcsq[sq] and the value of a DARK
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
	   impossibly far advanced (0 for LIGHT and 7 for DARK). This makes it easy to
	   test for pawns on a rank and it simplifies some pawn evaluation code. */
		int pawn_rank[2][10];
		int piece_mat[2];  /* the value of a side's pieces */
		int pawn_mat[2];  /* the value of a side's pawns */



};

}
#endif
