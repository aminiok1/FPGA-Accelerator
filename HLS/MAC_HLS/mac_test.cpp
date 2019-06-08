#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "mac.h"

typedef float T;

// software function to compare the results of the HLS against it
void accelerator_sw(
		T p[N][N],
		T z_u[N],
		T res[N])
{
	int i, j;
	for (i = 0; i < N; ++i)
		for (j = 0; j < N; ++j)
			res[i] += p[i][j] + z_u[j];
}

void init_arrays(
		T p[N][N],
		T z_u[N])
{
	int i, j;
	for (i = 0; i < N; ++i)
	{
		for(j = 0; j < N; ++j)
			p[i][j] = (T) i + j;

		z_u[i] = (T) 2 * i;

	}
}

int main(void)
{
	int err = 0;
	int i;
	T p_sw[N][N];
	T p_hw[N][N];
	T z_u_sw[N];
	T z_u_hw[N];
	T res_sw[N];
	T res_hw[N];

	//Initialize Software and HW Arrays
	init_arrays(p_sw, z_u_sw);
	init_arrays(p_hw, z_u_hw);

	//Call Software Accelerator
	accelerator_sw(p_sw, z_u_sw, res_sw);

	//Call Wrapped accelerator
	mac_kernel(p_hw, z_u_hw, res_hw);


	//Compare Results of Add
	for (i = 0; i < N; ++i)
	{
		if (abs(res_sw[i] - res_hw[i]) != 0)
		{
			printf("%f\n", res_sw[i] - res_hw[i]);
			++err;
		}
	}
	if (err == 0)
		printf("\n ----- No Errors!, HW/SW Results Match! ----- ");
	return err;
}
