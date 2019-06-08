#include "op_vec.h"


void op_vec_kernel(AXI_VAL p_times_z_u[N], float q[10], AXI_VAL result[N])
{

	#pragma HLS INTERFACE bram port=q
	#pragma HLS interface axis port=p_times_z_u
	#pragma HLS interface axis port=result
	#pragma HLS interface s_axilite port=return bundle=CTRL_BUS

	float in[N];
	float acc[N];
	float data_cache[N];

	Reset: for (int iacc = 0; iacc < N; iacc++)
	#pragma HLS UNROLL
		acc[iacc] = 0;

	In: for (int i = 0; i < N; i++)
				in[i] = pop_stream<float, 4, 5, 5>(p_times_z_u[i]);

	float temp[N];
	for (int iwtf = 0; iwtf < 10; iwtf++)
		temp[iwtf] = q[iwtf];


	for (int iadd = 0; iadd < 10; iadd++){
	//	#pragma HLS PIPELINE
		acc[iadd] = in[iadd] + temp[iadd];
	}

	Out: for (int iout = 0; iout < N; iout++)
		result[iout] = push_stream<float, 4, 5, 5>(acc[iout], iout == (N - 1));

//	return;
}
