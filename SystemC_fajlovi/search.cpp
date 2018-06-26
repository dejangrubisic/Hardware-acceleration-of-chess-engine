/*
 *	SEARCH.C
 *	Tom Kerrigan's Simple Chess Program (TSCP)
 *
 *	Copyright 1997 Tom Kerrigan
 */

#include<cstdio>
#include"soft.hpp"
//-------------------------------------------------
#include <stdio.h>
#include <string.h>
#include "defs.hpp"
#include "data.hpp"
#include "protos.hpp"



/* see the beginning of think() */
#include <setjmp.h>
jmp_buf env;
BOOL stop_search;


/* think() calls search() iteratively. Search statistics
   are printed depending on the value of output:
   0 = no output
   1 = normal output
   2 = xboard format output */

void soft_ip::think(int output)
{
	int i, j, x;

	/* try the opening book first */
	pv[0][0].u = book_move();
	if (pv[0][0].u != -1)
		return;

	/* some code that lets us longjmp back here and return
	   from think() when our time is up */
	stop_search = FALSE;
	setjmp(env);
	if (stop_search) {

		/* make sure to take back the line we were searching */
		while (ply)
			takeback();
		return;
	}

	start_time = get_ms();
	stop_time = start_time + max_time;

	ply = 0;
	nodes = 0;

	memset(pv, 0, sizeof(pv));
	memset(history, 0, sizeof(history));

	if (output == 1)
		printf("ply      nodes  score  pv\n");
	for (i = 1; i <= max_depth; ++i) {
		follow_pv = TRUE;
		x = search(-10000, 10000, i);
		if (output == 1)
			printf("%3d  %9d  %5d ", i, nodes, x);
		else if (output == 2)
			printf("%d %d %d %d",
					i, x, (get_ms() - start_time) / 10, nodes);
		if (output) {
			for (j = 0; j < pv_length[0]; ++j)
				printf(" %s", move_str(pv[0][j].b));
			printf("\n");
			fflush(stdout);
		}
		if (x > 9000 || x < -9000)
			break;
	}
}


/* search() does just that, in negamax fashion */

int soft_ip::search(int alpha, int beta, int depth)
{
	int i, j, x;
	BOOL c, f;

	/* we're as deep as we want to be; call quiesce() to get
	   a reasonable score and return it. */
	if (!depth)
	{
		return quiesce(alpha,beta);	
	}
	++nodes;

	/* do some housekeeping every 1024 nodes */
	if ((nodes & 1023) == 0)
		checkup();

	pv_length[ply] = ply;

	/* if this isn't the root of the search tree (where we have
	   to pick a move and can't simply return 0) then check to
	   see if the position is a repeat. if so, we can assume that
	   this line is a draw and return 0. */
	if (ply && reps())
		return 0;


	/* are we too deep? */
	if (ply >= MAX_PLY - 1)
	{
		//return eval(color, piece, side);
		for(int i = 0; i < 64; i++)
		{
			soft_color[i]->write(color[i]);
			soft_piece[i]->write(piece[i]);
		}
		table_to_list(); //dejan
		print_list(); //dejan

		soft_side->write(side);
		start_out = 1;

		std::cout<<std::endl<<"START time = "<<sc_core::sc_time_stamp()<<std::endl;
		wait();
		std::cout<<"END time = "<<sc_core::sc_time_stamp()<<std::endl;

		start_out = 0;
		wait(1, SC_NS);
		printf("1SEARCH******************** Eval passed | SEQ = %d | PAR = %d ********************\n", soft_eval_in->read(), res_par->read());
		
		if(soft_eval_in->read() != res_par->read())
			sc_stop();

		return res_par->read();
//return soft_eval_in->read();
	}	
	if (hply >= HIST_STACK - 1)
	{	
		//return eval(color, piece, side);
		for(int i = 0; i < 64; i++)
		{
			soft_color[i]->write(color[i]);
			soft_piece[i]->write(piece[i]);
		}
		table_to_list(); //dejan
	    print_list(); //dejan

		soft_side->write(side);
		start_out = 1;
		
		std::cout<<std::endl<<"START time = "<<sc_core::sc_time_stamp()<<std::endl;
		wait();
		std::cout<<"END time = "<<sc_core::sc_time_stamp()<<std::endl;

		start_out = 0;
		wait(1, SC_NS);
		printf("2SEARCH******************** Eval passed | SEQ = %d | PAR = %d ********************\n", soft_eval_in->read(), res_par->read());
		if(soft_eval_in->read() != res_par->read())
			sc_stop();

		return res_par->read();
//return soft_eval_in->read();
	}
	/* are we in check? if so, we want to search deeper */
	c = in_check(side);
	if (c)
		++depth;
	gen();
	if (follow_pv)  /* are we following the PV? */
		sort_pv();
	f = FALSE;

	/* loop through the moves */
	for (i = first_move[ply]; i < first_move[ply + 1]; ++i) {
		sort(i);
		if (!makemove(gen_dat[i].m.b))
			continue;
		f = TRUE;
		x = -search(-beta, -alpha, depth - 1);
		takeback();
		if (x > alpha) {

			/* this move caused a cutoff, so increase the history
			   value so it gets ordered high next time we can
			   search it */
			history[(int)gen_dat[i].m.b.from][(int)gen_dat[i].m.b.to] += depth;
			if (x >= beta)
				return beta;
			alpha = x;

			/* update the PV */
			pv[ply][ply] = gen_dat[i].m;
			for (j = ply + 1; j < pv_length[ply + 1]; ++j)
				pv[ply][j] = pv[ply + 1][j];
			pv_length[ply] = pv_length[ply + 1];
		}
	}

	/* no legal moves? then we're in checkmate or stalemate */
	if (!f) {
		if (c)
			return -10000 + ply;
		else
			return 0;
	}

	/* fifty move draw rule */
	if (fifty >= 100)
		return 0;
	return alpha;
}


/* quiesce() is a recursive minimax search function with
   alpha-beta cutoffs. In other words, negamax. It basically
   only searches capture sequences and allows the evaluation
   function to cut the search off (and set alpha). The idea
   is to find a position where there isn't a lot going on
   so the static evaluation function will work. */

int soft_ip::quiesce(int alpha,int beta)
{
	int i, j, x;
	
	++nodes;

	/* do some housekeeping every 1024 nodes */
	if ((nodes & 1023) == 0)
		checkup();

	pv_length[ply] = ply;

	/* are we too deep? */
	if (ply >= MAX_PLY - 1)
	{
		//return eval(color, piece, side);
		for(int i = 0; i < 64; i++)
		{
			soft_color[i]->write(color[i]);
			soft_piece[i]->write(piece[i]);
		}	
		table_to_list(); //dejan
		print_list(); //dejan

		soft_side->write(side);
		start_out = 1;

		std::cout<<std::endl<<"START time = "<<sc_core::sc_time_stamp()<<std::endl;
		wait();
		std::cout<<"END time = "<<sc_core::sc_time_stamp()<<std::endl;

		start_out = 0;
		wait(1, SC_NS);
		printf("1QUIESCE******************** Eval passed | SEQ = %d | PAR = %d ********************\n", soft_eval_in->read(), res_par->read());
		
		if(soft_eval_in->read() != res_par->read())
			sc_stop();

		return res_par->read();
//return soft_eval_in->read();
		
	
	}
	if (hply >= HIST_STACK - 1)
	{
		//return eval(color, piece, side);
		for(int i = 0; i < 64; i++)
		{
			soft_color[i]->write(color[i]);
			soft_piece[i]->write(piece[i]);
		}	
		table_to_list(); //dejan
		print_list(); //dejan

		soft_side->write(side);
		start_out = 1;

		std::cout<<std::endl<<"START time = "<<sc_core::sc_time_stamp()<<std::endl;
		wait();
		std::cout<<"END time = "<<sc_core::sc_time_stamp()<<std::endl;

		start_out = 0;
		wait(1, SC_NS);

		printf("2QUIESCE******************** Eval passed | SEQ = %d | PAR = %d ********************\n", soft_eval_in->read(), res_par->read());

		if(soft_eval_in->read() != res_par->read())
			sc_stop();

		return res_par->read();
//return soft_eval_in->read();
	}
	/* check with the evaluation function */
	//x = eval(color, piece, side);
		for(int i = 0; i < 64; i++)
		{
			soft_color[i]->write(color[i]);
			soft_piece[i]->write(piece[i]);
		}
		table_to_list(); //dejan
		print_list(); //dejan	

		soft_side->write(side);
		start_out = 1;

		std::cout<<std::endl<<"START time = "<<sc_core::sc_time_stamp()<<std::endl;
		wait();
		std::cout<<"END time = "<<sc_core::sc_time_stamp()<<std::endl;
		start_out = 0;
		wait(1, SC_NS);
		printf("3QUIESCE******************** Eval passed | SEQ = %d | PAR = %d ********************\n", soft_eval_in->read(), res_par->read());

		if(soft_eval_in->read() != res_par->read())
			sc_stop();

		x = res_par->read();
//x = soft_eval_in->read();

//---------------------------------------------------
	if (x >= beta)
		return beta;
	if (x > alpha)
		alpha = x;

	gen_caps();
	if (follow_pv)  /* are we following the PV? */
		sort_pv();

	/* loop through the moves */
	for (i = first_move[ply]; i < first_move[ply + 1]; ++i) {
		sort(i);
		if (!makemove(gen_dat[i].m.b))  //dejan: if move is illegal continue
			continue;
		x = -quiesce(-beta, -alpha);
		takeback();
		if (x > alpha) {
			if (x >= beta)
				return beta;
			alpha = x;

			/* update the PV */
			pv[ply][ply] = gen_dat[i].m;
			for (j = ply + 1; j < pv_length[ply + 1]; ++j)
				pv[ply][j] = pv[ply + 1][j];
			pv_length[ply] = pv_length[ply + 1];
		}
	}
	return alpha;
}


/* reps() returns the number of times the current position
   has been repeated. It compares the current value of hash
   to previous values. */

int reps()
{
	int i;
	int r = 0;

	for (i = hply - fifty; i < hply; ++i)
		if (hist_dat[i].hash == hash)
			++r;
	return r;
}


/* sort_pv() is called when the search function is following
   the PV (Principal Variation). It looks through the current
   ply's move list to see if the PV move is there. If so,
   it adds 10,000,000 to the move's score so it's played first
   by the search function. If not, follow_pv remains FALSE and
   search() stops calling sort_pv(). */

void sort_pv()
{
	int i;

	follow_pv = FALSE;
	for(i = first_move[ply]; i < first_move[ply + 1]; ++i)
		if (gen_dat[i].m.u == pv[0][ply].u) {
			follow_pv = TRUE;
			gen_dat[i].score += 10000000;
			return;
		}
}


/* sort() searches the current ply's move list from 'from'
   to the end to find the move with the highest score. Then it
   swaps that move and the 'from' move so the move with the
   highest score gets searched next, and hopefully produces
   a cutoff. */

void sort(int from)
{
	int i;
	int bs;  /* best score */
	int bi;  /* best i */
	gen_t g;

	bs = -1;
	bi = from;
	for (i = from; i < first_move[ply + 1]; ++i)
		if (gen_dat[i].score > bs) {
			bs = gen_dat[i].score;
			bi = i;
		}
	g = gen_dat[from];
	gen_dat[from] = gen_dat[bi];
	gen_dat[bi] = g;
}


/* checkup() is called once in a while during the search. */

void checkup()
{
	/* is the engine's time up? if so, longjmp back to the
	   beginning of think() */
	if (get_ms() >= stop_time) {
		stop_search = TRUE;
		longjmp(env, 0);
	}
}


//****************************************************************************
  void table_to_list() //dejan LIST: P0 P1 P2 P3 P4 P5 P6 P7 N0 N1 B0 B1 K Q0 R0 R1
 {

    int i, w_pawn=0, b_pawn=0; //dejan: position in list of piece to move from square i to place j
    int w_promote=7, b_promote=7;   //position of the first promoted piece
	int col = 0;
	int row = 0;
    for(i=0; i < 16; i++)
    {
        list_white[i] = 0;
        list_black[i] = 0;
    }
	for(col=0; col<8; col++)
		for(row=0; row<8; row++)
		{
			i = col + 8*row;

		    if(color[i]==EMPTY)
		        continue;
		    else if(color[i] == LIGHT)
		    {
		        switch(piece[i])
		        {
		        case PAWN:  list_white[w_pawn++] = i; break;

		        case KNIGHT:    if(list_white[8]==0)
		                            list_white[8] = (int)(i | (1<<6));
		                        else if(list_white[9]==0)
		                            list_white[9] = (int)(i | (1<<6));
		                        else
		                            list_white[w_promote--] = (int)(i | (int)(0b100<<6));
		                        break;

		        case BISHOP:    if(list_white[10]==0)
		                            list_white[10] =(int)( i | (1<<6));
		                        else if(list_white[11]==0)
		                            list_white[11] = (int)(i | (1<<6));
		                        else
		                            list_white[w_promote--] = (int)(i | (int)(0b101<<6));
		                        break;

		        case ROOK:      if(list_white[14]==0)
		                            list_white[14] = (int)(i | (1<<6));
		                        else if(list_white[15] == 0)
		                            list_white[15] = (int)(i | (1<<6));
		                        else
		                            list_white[w_promote--] = (int)(i | (int)(0b110<<6));
		                        break;

		        case QUEEN:     if(list_white[13]==0)
		                            list_white[13] = (int)(i | (1<<6));
		                        else
		                        {
		                            list_white[w_promote--] = (int)(i | (int)(0b111<<6));
		                            //printf("PromoteW %d= %d\n",w_promote+1, list_white[w_promote+1]);    //brisi provera
		                        }

		                        break;

		        case KING:      list_white[12] = (int)(i | (1<<6)); break;

		        }
		    }
		    else
		    {
		    switch(piece[i])
		        {
		        case PAWN:  list_black[b_pawn++] = i; break;

		        case KNIGHT:    if(list_black[8]==0)
		                            list_black[8] = (int)(i | (1<<6));
		                        else if(list_black[9]==0)
		                            list_black[9] = (int)(i | (1<<6));
		                        else
		                            list_black[b_promote--] = (int)(i | (int)(0b100<<6));
		                        break;

		        case BISHOP:    if(list_black[10]==0)
		                            list_black[10] = (int)(i | (1<<6));
		                        else if(list_black[11]==0)
		                            list_black[11] = (int)(i | (1<<6));
		                        else
		                            list_black[b_promote--] = (int)(i | (int)(0b101<<6));
		                        break;

		        case ROOK:      if(list_black[14]==0)
		                            list_black[14] = (int)(i | (1<<6));
		                        else if(list_black[15] == 0)
		                            list_black[15] = (int)(i | (1<<6));
		                        else
		                            list_black[b_promote--] = (int)(i | (int)(0b110<<6));
		                        break;

		        case QUEEN:     if(list_black[13]==0)
		                            list_black[13] = (int)(i | (1<<6));
		                        else
		                        {
		                            list_black[b_promote--] = (int)(i | (int)(0b111<<6));
		                            //printf("PromoteB %d= %d\n",b_promote+1, list_black[b_promote+1]);    //brisi provera
		                        }

		                        break;

		        case KING:      list_black[12] = (int)(i | (1<<6)); break;

		        }
		    }

    	}

 }
//****************************************************************************
/**/
void print_list()
{
    printf("\n\t P0 P1 P2 P3 P4 P5 P6 P7 N0 N1 B0 B1 K  Q0 R0 R1 \n");
    printf("  WHITE: ");
    int i;


    for(i=0; i<16; i++)
    {
        //printf(" %d ", list_white[i]);
        if(list_white[i] == 0)
            printf(" X ");
        else if((list_white[i]&(1<<8))==0) //not promote
            printf("%c%d ", 'a'+COL(list_white[i]), 8-ROW((int)(list_white[i]&0x3f)));
        else
            printf("%c%c%d ", piece_char[(int)((list_white[i]>>6)&0b11) +1],'a'+COL((int)(list_white[i]&0x3f)), 8-ROW((int)(list_white[i]&0x3f)));
    }
    printf("\n  BLACK: ");
    for(i=0; i<16; i++)
    {
        //printf(" %d ", list_black[i]);
        if(list_black[i] == 0)
            printf(" X ");
        else if((list_black[i]&(1<<8))==0)
            printf("%c%d ", 'a'+COL(list_black[i]), 8-ROW((int)(list_black[i]&0x3f)));
        else
            printf("%c%c%d ", piece_char[(int)((list_black[i]>>6)&0b11) +1],'a'+COL((int)(list_black[i]&0x3f)), 8-ROW((int)(list_black[i]&0x3f)));
    }
    printf("\n");
	//provera za VHDL
	printf("Color \n");
    for(i=0; i<64; i++)
    {
        if(i%8 == 0)
            printf("\n");
        printf("'%d', ", color[i]?1:0);
    }


    printf("\n Piece \n");
    for(i=0; i<64; i++)
    {
        if(i%8 == 0)
            printf("\n");
        printf("X\"%x\", ", piece[i]);
    }

    printf(" \n Memory hardware 8x32b \n");	//od a1 & a2 & a3...a8, b1 & b2....b8
    int j;
    for(i=0; i<8; i++)
    {
        printf("\n");
        for(j=7; 0<=j; j--)
        {
            if(j != 0)
                printf("X\"%x\" & ", (((color[8*j+i]?1:0)<<3) + piece[8*j+i]));
            else
                printf("X\"%x\", ", (((color[8*j+i]?1:0)<<3) + piece[8*j+i]));
        }
    }

}
