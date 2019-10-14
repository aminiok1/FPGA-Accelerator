#include "termination_detector.h"
#include "hls_math.h"

void termination_detector (

		// inputs
		in_data_t z_td[N],
		in_data_t x_td[N],
		in_data_t u_td[N],
		in_data_t z_old_td[N],

		volatile data_t &rho,

		out_data_t x_out[N],
		bool &terminate

		)
{
	#pragma HLS INTERFACE bram port=x_out
	#pragma HLS INTERFACE ap_none port=terminate
	#pragma HLS INTERFACE ap_none port=rho
	#pragma HLS INTERFACE ap_fifo port=z_old_td
	#pragma HLS INTERFACE ap_fifo port=u_td
	#pragma HLS INTERFACE ap_fifo port=z_td
	#pragma HLS INTERFACE ap_fifo port=x_td

	terminate = false;

	data_t rho_inv_lc = rho;

	data_t x_in, z_in, u_in, z_old_in;
	data_t x_z_norm = 0, z_zold_norm = 0, x_norm = 0, z_norm = 0, u_norm = 0, max_x_z, max_x_z_norm;
	data_t r_norm, s_norm, eps_pri, eps_dual;
	data_t x_td_cache[N];

	Compute: for (int icalc = 0; icalc < 16; icalc++)
	{
		#pragma HLS PIPELINE

		x_td_cache[icalc] = x_td[icalc];
		z_in = z_td[icalc];
		u_in = u_td[icalc];
		z_old_in = z_old_td[icalc];

		x_z_norm += (x_td_cache[icalc] - z_in) * (x_td_cache[icalc] - z_in);
		z_zold_norm += (z_in - z_old_in) * (z_in - z_old_in);
		x_norm += x_td_cache[icalc] * x_td_cache[icalc];
		z_norm += z_in * z_in;
		u_norm += u_in * u_in;

	}
	max_x_z = (x_norm > z_norm) ? x_norm:z_norm;
	max_x_z_norm = hls::sqrtf(max_x_z);

	r_norm = hls::sqrtf(x_z_norm);
	s_norm = hls::sqrtf(z_zold_norm) * rho;

	eps_pri =  SQRTN_ABSTOL + RELTOL * max_x_z_norm;
	eps_dual = SQRTN_ABSTOL + RELTOL * hls::sqrtf(u_norm) * rho;

	bool cond1 = (r_norm < eps_pri) ? true:false;
	bool cond2 = (s_norm < eps_dual) ? true:false;

	if (cond1 && cond2)
		terminate = true;
	else
		terminate = false;

	if (terminate)
		Out: for (int iout = 0; iout < 16; iout++)
		{
			#pragma HLS PIPELINE
			x_out[iout] = x_td_cache[iout];
		}
}
