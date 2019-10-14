#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "mac.h"

// software function to compare the results of the HLS against it
void accelerator_sw(
		in_data_t p[N][N],
		in_data_t z_u[N],
		out_data_t res[N])
{
	int i, j;

	for (i = 0; i < N; ++i)
		res[i] = 0;

	for (i = 0; i < N; ++i)
		for (j = 0; j < N; ++j)
			res[i] += p[i][j] * z_u[j];
}

void init_arrays(
		in_data_t p[N][N],
		in_data_t z_u[N])
{
	int i, j;
	for (i = 0; i < N; ++i)
	{
		for(j = 0; j < N; ++j)
			p[i][j] = (data_t) i + j;

		z_u[i] = (data_t) 2 * i;

	}
}

int main(void)
{
	int err = 0;
	int i;

	in_data_t p_sw[N][N];
	in_data_t p_hw[N][N];

	in_data_t z_u_sw[N];
	in_data_t z_u_hw[N];

	out_data_t res_sw[N];
	out_data_t res_hw[N];

	// Initialize Software and HW Arrays
	init_arrays(p_sw, z_u_sw);
	init_arrays(p_hw, z_u_hw);

	// Call Software Accelerator
	accelerator_sw(p_sw, z_u_sw, res_sw);

	// Call Wrapped accelerator
	mac_kernel(p_hw, z_u_hw, res_hw);

	// Compare Results of Add
	for (i = 0; i < N; ++i)
	{
		if (abs(res_sw[i] - res_hw[i]) != 0)
		{
			printf("index:%d --> sw = %f, hw = %f\n", i, res_sw[i], res_hw[i]);
			++err;
		}
	}
	if (err == 0)
		printf("\n ----- No Errors!, HW/SW Results Match! ----- ");

	return err;
}
