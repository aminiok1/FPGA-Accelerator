#ifndef SOFT_THRESHOLD_H_
#define SOFT_THRESHOLD_H_

#include <ap_axi_sdata.h>
// configurable params

#define N		16

typedef float 	in_data_t;
typedef float 	out_data_t;
typedef float 	data_t;

typedef ap_axis<32, 1, 1, 1> AXI_VAL;

// function prototype
void soft_threshold_kernel(
		in_data_t u[N],
		AXI_VAL x[N],

		volatile data_t &rho_inv,
		out_data_t result_z[N]
		);

template<typename T, int U, int TI, int TD>
T pop_stream(ap_axis <sizeof(T) * 8, U, TI, TD> const &e)
{
#pragma HLS INLINE

	//assert(sizeof(T) == sizeof(double));
	union
	{
		long ival;
		T oval;
	} converter;
	converter.ival = e.data;
	T ret = converter.oval;

	// axi signals
	//volatile ap_uint<sizeof(T)> strb = e.strb;
	//volatile ap_uint<sizeof(T)> keep = e.keep;
	//volatile ap_uint<U> user = e.user;
	//volatile ap_uint<1> last = e.last;
	//volatile ap_uint<TI> id = e.id;
	//volatile ap_uint<TD> dest = e.dest;

	return ret;
}

template <typename T, int U, int TI, int TD>
ap_axis <sizeof(T) * 8, U, TI, TD> push_stream(T const &v, bool last = false)
{
#pragma HLS INLINE
	ap_axis<sizeof(T) * 8, U, TI, TD> e;

	union
	{
		long oval;
		T ival;
	} converter;
	converter.ival = v;
	e.data = converter.oval;

	// setting axi signals
	e.strb = 0xFF;
	e.keep = 0xFF; //e.strb;
	e.user = 0;
	e.last = last ? 1 : 0;
	e.id = 0;
	e.dest = 0;
	return e;
}

#endif