#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "op_vec.h"

// software function to compare the results of the HLS against it
void accelerator_sw(
		in_data_t op_1[N],
		in_data_t op_2[N],
		out_data_t res[N],
		int op_sel,
		int scale,
		data_t alpha)
{
	int i;

	data_t one_alpha = 1 - alpha;

	for (i = 0; i < N; i++)
	{
		if (op_sel == 0)
		{
			if (scale == 1)
				res[i] = (one_alpha * op_1[i]) + (alpha * op_2[i]);
			else
				res[i] = op_1[i] + op_2[i];
		}

		else if (op_sel == 1)
			res[i] = op_1[i] - op_2[i];
	}
}

void init_arrays(
		in_data_t op_1[N],
		in_data_t op_2[N])
{
	int i;
	for (i = 0; i < N; ++i)
	{
		op_1[i] = (data_t) i;
		op_2[i] = (data_t) 2 * i;
	}
}

int main(void)
{
	int err = 0;
	int i;


	volatile int1 in1_sel = 1;	// stream interface
	volatile int2 in2_sel = 1;	// BRAM interface

	volatile int1 op_sel = 0;
	volatile int1 scale = 1;

	volatile data_t alpha = 3.2;

	int op_sel_sw = 0;
	int scale_sw = 1;
	data_t alpha_sw = 3.2;

	in_data_t op_1[N];
	in_data_t op_2[N];
	AXI_VAL op_stream[N];


	out_data_t res_sw[N];
	out_data_t res_hw[N];
	AXI_VAL res_stream[N];

	// Initialize Software and HW Arrays
	init_arrays(op_1, op_2);

	// Push z_u to the axi stream
	for (int i = 0; i < N; i++)
		op_stream[i] = push_stream<data_t, 1, 1, 1>(op_1[i], i == (N-1));

	// Call Software Accelerator
	accelerator_sw(op_1, op_2, res_sw, op_sel_sw, scale_sw, alpha_sw);

	// Call Wrapped accelerator
	
	op_vec_kernel(op_1, op_1, op_2, op_2, op_2, res_hw, res_hw, res_hw, op_sel, in1_sel, in2_sel, scale, alpha);

	// Pop the results
	//for (int i = 0; i < N; i++)
	//	res_hw[i] = pop_stream<data_t, 1, 1, 1>(res_stream[i]);

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
