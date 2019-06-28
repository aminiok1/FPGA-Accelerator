#include "soft_threshold.h"

void soft_threshold_kernel(
		in_data_t u_bram[N],
		AXI_VAL x[N],

		volatile data_t &rho_inv,
		out_data_t result_z[N]
		)
{
	#pragma HLS INTERFACE bram port=u_bram
	#pragma HLS interface axis port=x
	#pragma HLS interface bram port=result_z

	data_t u_update[N];
	data_t x_in;
	data_t z_update;
	data_t x_add_u;
	data_t temp1, temp2;

	data_t rho_inv_lc = rho_inv;

	Compute: for (int iadd = 0; iadd < N; iadd++)
	{
		x_in = pop_stream<data_t, 1, 1, 1>(x[iadd]);

		x_add_u = x_in + u_bram[iadd];

		temp1 = x_add_u - rho_inv_lc;
		temp2 = (-1 * x_add_u) - rho_inv_lc;

		temp1 = temp1 > 0 ? temp1:0;
		temp2 = temp2 > 0 ? temp2:0;

		z_update = temp1 - temp2;

		u_update[iadd] = x_add_u - z_update;

		result_z[iadd] = z_update;
	}


	Out: for(int iout = 0; iout < N; iout++)
	{
		u_bram[iout] = u_update[iout];
	}


	return;
}

