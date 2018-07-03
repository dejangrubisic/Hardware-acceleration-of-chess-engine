#include <systemc>
#include <cstdio>
//-------------------------------------------------
#include "top.hpp"
//#include "soft.hpp"
/* get_ms() returns the milliseconds elapsed since midnight,
   January 1, 1970. */


int sc_main(int argv, char* argc[])
{
	top t("t");

	sc_start();

	return 0;
}
