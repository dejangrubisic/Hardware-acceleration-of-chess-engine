#ifndef _TOP_HPP_
#define _TOP_HPP_

#include <systemc>
#include "eval.hpp"
#include "soft.hpp"

using namespace sc_core;

SC_MODULE(top)
{
public:
	SC_HAS_PROCESS(top);

	top(sc_module_name);

	
protected:
	sc_core::sc_signal<int> s_color[64];
	sc_core::sc_signal<int> s_piece[64];
	sc_core::sc_signal<int> s_side;
	sc_core::sc_signal<bool> s_start_eval;

	sc_core::sc_signal<int> s_result;
	sc_core::sc_signal<bool> s_return_eval;
	
	sc_core::sc_signal<int> s_result_parallel;
	//sc_core::sc_signal<bool> s_finished;

	hard_acc::m_eval ev;
	soft_ip sw;

};
#endif


