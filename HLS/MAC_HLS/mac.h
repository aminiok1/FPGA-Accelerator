#include <ap_axi_sdata.h>

// Configurable params
#define N		16

typedef float 	in_data_t;
typedef float 	out_data_t;
typedef float 	data_t;

typedef ap_axis<32, 1, 1, 1> AXI_VAL;

// Functions prototypes
void mac_kernel (
		in_data_t p[N][N],
		in_data_t z_u[N],
		out_data_t result[N]
		);

void read_data(
		in_data_t z_u[N],
		in_data_t data_cache[N]
		);

void mac(
		in_data_t p[N][N],
		in_data_t vec[N],
		out_data_t res[N]
		);

void write_data(
		out_data_t res[N],
		out_data_t res_stream[N]
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
