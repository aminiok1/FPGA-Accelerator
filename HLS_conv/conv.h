#ifndef CONV_H_
#define CONV_H_

#include <ap_axi_sdata.h>
typedef ap_axiu<32, 4, 5, 5> AXI_VAL;

#ifndef M
#define M 18        //photo 18 *18 * 3
#endif

#ifndef N
#define N 3			//kernal 3 * 3 * 3
#endif

#ifndef K
#define K 3       //number of kernal
#endif

//void convolutional(AXI_VAL image_stream[3*M*M],AXI_VAL kernal_stream[K*N*N*N],AXI_VAL out_stream[K*(M - N + 1)*(M - N + 1)]);  // one img, all kernals,int K, int M, int N
void convolutional(int image[3][M][M], int kernal[K][N][N][N], int out[K][M - N + 1][M - N + 1]);  // one img, all kernals,int K, int M, int N

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

	//assert(sizeof(T) == sizeof(double));
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

#endif
