#include <ap_axi_sdata.h>

// configurable params

#define N		10

typedef float data_in_t;
typedef float data_out_t;

typedef ap_axiu<32, 4, 5, 5> AXI_VAL;

// function prototype
void op_vec_kernel(
		AXI_VAL p_times_z_u[N],
		float q[10],
		AXI_VAL result[N]);

template<typename T, int U, int TI, int TD>
T pop_stream(ap_axiu <sizeof(T) * 8, U, TI, TD> const &e)
{
#pragma HLS INLINE

	//assert(sizeof(T) == sizeof(double));
	union
	{
		long long ival;
		T oval;
	} converter;
	converter.ival = e.data;
	T ret = converter.oval;

	// axi signals
	volatile ap_uint<sizeof(T)> strb = e.strb;
	volatile ap_uint<sizeof(T)> keep = e.keep;
	volatile ap_uint<U> user = e.user;
	volatile ap_uint<1> last = e.last;
	volatile ap_uint<TI> id = e.id;
	volatile ap_uint<TD> dest = e.dest;

	return ret;
}

template <typename T, int U, int TI, int TD>
ap_axiu <sizeof(T) * 8, U, TI, TD> push_stream(T const &v, bool last = false)
{
#pragma HLS INLINE
	ap_axiu<sizeof(T) * 8, U, TI, TD> e;

	union
	{
		long long oval;
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
