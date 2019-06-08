#include "mac.h"
#include <hls_stream.h>
// example code for adding two vectors

void mac_kernel(data_int_t p[N][N], data_int_t z_u[N], AXI_VAL result[N])
{

	#pragma HLS interface bram port=p
	#pragma HLS interface bram port=z_u
	#pragma HLS interface axis port=result
	#pragma HLS interface s_axilite port=return bundle=CTRL_BUS

	data_out_t acc[N];
	data_out_t data_cache;

	Reset: for (int iacc = 0; iacc < N; iacc++)
	#pragma HLS UNROLL
		acc[iacc] = 0;

	I_LOOP: for (int ii = 0; ii < N; ii++) {
		data_cache = z_u[ii];

		Product: for (int jj = 0; jj < N; jj++) {
		#pragma HLS PIPELINE
			acc[jj] += data_cache * p[ii][jj];
		}
	}

	Result: for (int ires = 0; ires < N; ires++)
	{
		// i == (DIM - 1) is for indicating the last byte (TLAST signal in axi interface)
		result[ires] = push_stream<data_out_t, 4, 5, 5>(acc[ires], ires == (N - 1));
	}

	// Use this block if result is Bram
	/*Result: for (int ires = 0; ires < N; ires++)
		result[ires] = acc[ires];
	 */
	return;
}
	/*
	 data_out_t temp;
int k = 0;
	 // Generate the expected result
	 I_LOOP:  for(int i = 0; i < N; i++){
	 //  K_LOOP:      for(int k = 0; k < N; k++) {

		   #pragma HLS PIPELINE
		   if(k==0)
	    	   temp = 0;

		   temp += z_u[k] * p[(i*N) + k];

	       //if(k == (N - 1))
	    	 //  result[i] = temp;
	    // }
	   result[i] = temp;}
	return;
}

*/
