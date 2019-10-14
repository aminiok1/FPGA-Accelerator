#include "mac.h"

// partitioning arrays P and vec_cache decreases the clock cycles by 60 and meanwhile
// increases BRAM, LUT, and FF by  10, 1000, and 1000 respectively.

// FIXME: Reading z_u and p is not concurrent rn!
void mac_kernel (
		in_data_t p[N][N],
		in_data_t z_u[N],
		out_data_t result[N]
		)
{
	#pragma HLS INTERFACE ap_fifo port=result
	#pragma HLS INTERFACE ap_fifo port=z_u
	#pragma HLS RESOURCE variable=p core=RAM_1P_BRAM

	in_data_t vec_cache[N];
	out_data_t res[N];

	// Read input data. Fill the internal buffer.
	read_data (z_u, vec_cache);

	// Compute the matrix vector multiplication
	mac (p, vec_cache, res);

	// Write output to axi stream
	write_data (res, result);

}
void read_data(
		in_data_t z_u[N],
		in_data_t data_cache[N]
		)
{
	Read_Vec: for (int jj = 0; jj < 16; jj++)
				{
					data_cache[jj] = z_u[jj]; //pop_stream<data_t, 1, 1, 1>(z_u[jj]);
				}
}

void mac(
		in_data_t p[N][N],
		in_data_t vec[N],
		out_data_t res[N]
		)
{
	Compute: for (int ii = 0; ii < N; ii++)
	{
		data_t acc = 0;

		Product: for (int jj = 0; jj < N; jj++)
			acc += p[ii][jj] * vec[jj];

		res[ii] = acc;
	}
}

void write_data(
		out_data_t res[N],
		out_data_t res_stream[N]
		)
{
	Write: for (int iout = 0; iout < N; iout++)
		res_stream[iout] = res[iout]; //push_stream<data_t, 1, 1, 1>(res[iout], iout == (N - 1));
}
