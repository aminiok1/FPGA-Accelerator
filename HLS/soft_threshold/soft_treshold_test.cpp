#include "soft_threshold.h"
#include <stdio.h>

// TODO: need software model to compare the results of the hardware with it
int main(int argc, char *argv[])
{
	data_t u_bram[N];
	data_t x[N];
	data_t rho_inv = 2.5;
	data_t result_z[N];
	
	data_t x_td[N];
	data_t z_td[N];
	data_t u_td[N];
	data_t z_old_td[N];
	
	AXI_VAL x_stream[N];


	for (int i = 0; i < N; i++)
	{
		x[i] = (data_t) i;
		u_bram[i] = (data_t) (2*i);

		x_stream[i] =  push_stream<data_t, 1, 1, 1>(x[i], i == (N-1));
	}

	soft_threshold_kernel (u_bram, x, rho_inv, result_z, x_td, z_td, u_td, z_old_td);

	for  (int i = 0; i < N; i++)
	{
		printf("result[%d] = %f\n", i, result_z[i]);
	}

	return 0;
}
