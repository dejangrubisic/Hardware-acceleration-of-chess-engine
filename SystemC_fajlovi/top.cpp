#include "top.hpp"

using namespace sc_core;
using namespace std;


top::top(sc_module_name n) :
		sc_module(n),
		sw("sw"), // Member initializer list
		ev("ev")
	{
		cout << name() << " constructed.\n";
		//SOFT		
		//input
		sw.start_in(s_return_eval); // control signal
		sw.soft_eval_in.bind(s_result);//result sequential
		sw.res_par(s_result_parallel);//result parallel
		//output
		for(int i = 0; i < 64; i++)
		{
			sw.soft_color[i].bind(s_color[i]);
			sw.soft_piece[i].bind(s_piece[i]);
		}		
		sw.soft_side.bind(s_side);
		sw.start_out(s_start_eval);

		//EVAL
		//input
		for(int i = 0; i < 64; i++)
		{
			ev.eval_color[i].bind(s_color[i]);
			ev.eval_piece[i].bind(s_piece[i]);
		}	
		ev.eval_side.bind(s_side);
		ev.start_in_eval(s_start_eval);
		//output
		ev.result_seq.bind(s_result);
		ev.finished(s_return_eval);//za paralelno
		ev.result_parallel(s_result_parallel);

	}

