#ifndef _M_SOFT_HPP_
#define _M_SOFT_HPP_

#include <systemc>
#include <iostream>

#define BOOL int

using namespace sc_core;

SC_MODULE(soft_ip)
{
public:
	SC_HAS_PROCESS(soft_ip);

	soft_ip(sc_module_name);


	sc_core::sc_in<int> soft_eval_in;
	sc_core::sc_in<bool> start_in;
	sc_core::sc_in<int> res_par;

	sc_core::sc_out<int> soft_color[64];	
	sc_core::sc_out<int> soft_piece[64];	
	sc_core::sc_out<int> soft_side;
	sc_core::sc_out<bool> start_out;

	void think(int output);
	int search(int alpha, int beta, int depth);
	int quiesce(int alpha,int beta);
	BOOL init_new_position(); //dejan
	void bench();
private:

	void soft_main();
	
};






#endif
