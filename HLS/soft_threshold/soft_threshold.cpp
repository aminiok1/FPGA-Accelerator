#include "soft_threshold.h"

void soft_threshold_kernel(
		in_data_t x[N],
		in_data_t u_bram[16],

		volatile data_t &rho_inv,
		out_data_t result_z[N],

		//fifos for termination detector
		out_data_t x_td[N],
		out_data_t z_td[N],
		out_data_t u_td[N],
		out_data_t z_old_td[N]
		)
{
#pragma HLS RESOURCE variable=result_z core=RAM_1P_BRAM
	#pragma HLS INTERFACE ap_fifo port=z_old_td
	#pragma HLS INTERFACE ap_fifo port=u_td
	#pragma HLS INTERFACE ap_fifo port=z_td
	#pragma HLS INTERFACE ap_fifo port=x_td
	#pragma HLS INTERFACE ap_fifo port=x

	#pragma HLS INTERFACE bram port=u_bram


	data_t u_update[N];
	data_t x_z;
	data_t z_old;
	data_t x_in;
	data_t z_update;
	data_t x_add_u;
	data_t temp1, temp2;

	data_t rho_inv_lc = rho_inv;

	Compute: for (int iadd = 0; iadd < N; iadd++)
	{
		x_in = x[iadd]; //pop_stream<data_t, 1, 1, 1>(x[iadd]);

		z_old = result_z[iadd];

		x_add_u = x_in + u_bram[iadd];

		temp1 = x_add_u - rho_inv_lc;
		temp2 = (-1 * x_add_u) - rho_inv_lc;

		temp1 = temp1 > 0 ? temp1:0;
		temp2 = temp2 > 0 ? temp2:0;

		z_update = temp1 - temp2;

		x_z = x_add_u - z_update;
		u_update[iadd] = x_z;

		result_z[iadd] = z_update;

		// termination detector outputs
		x_td[iadd] = x_in;
		z_td[iadd] = z_update;
		u_td[iadd] = x_z;
		z_old_td[iadd] = z_old;
	}


	Out: for(int iout = 0; iout < N; iout++)
	{
		u_bram[iout] = u_update[iout];
	}


	return;
}

