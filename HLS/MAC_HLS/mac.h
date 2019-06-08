#include <ap_axi_sdata.h>

// configurable params
const int FIFO_LENGTH		= 10;
#define N		10
const int M					= 10;
typedef float data_int_t;
typedef float data_out_t;

typedef ap_axiu<32, 4, 5, 5> AXI_VAL;

// function prototype
void mac_kernel(
		data_int_t p[N*N],
		data_int_t z_u[N],
		AXI_VAL result[N]);


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
