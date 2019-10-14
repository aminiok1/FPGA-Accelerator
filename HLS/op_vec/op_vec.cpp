#include "op_vec.h"

void op_vec_kernel(

		//Inputs
		in_data_t in_1_mac[N],
		in_data_t in_1_bram_z[N],

		in_data_t in_2_feedback[N],
		in_data_t in_2_bram_u[N],
		in_data_t in_2_bram_q[N],

		// Output
		//AXI_VAL result_mac[N],
		out_data_t result_mac[N],
		out_data_t result_st[N],
		out_data_t result_feedback[N],

	//	out_data_t x[N],

		// Input signals
		volatile int1 &op_sel,
		volatile int1 &in1_sel,
		volatile int2 &in2_sel,

		volatile int1 &scale,
		volatile data_t &alpha
		)

{
	#pragma HLS INTERFACE ap_fifo port=in_2_feedback
	#pragma HLS INTERFACE ap_fifo port=result_feedback
	#pragma HLS INTERFACE ap_fifo port=in_1_mac

	#pragma HLS INTERFACE ap_fifo port=result_st
	#pragma HLS INTERFACE ap_fifo port=result_mac
	// Pragmas for input/output interface types

//	#pragma HLS INTERFACE bram port=x
	#pragma HLS INTERFACE bram port=in_1_bram_z
	#pragma HLS interface bram port=in_2_bram_u
	#pragma HLS interface bram port=in_2_bram_q

	volatile data_t one_alpha = 1 - alpha;

	int1 zero = 0;
	int2 zero_2 = 0;
	int1 one = 1;
	int2 one_2 = 1;
	int2 two = 2;

	// Registering the inputs (for some reasons hls throws data dependency warnings if inputs are directly used)
	int1 op_sel_t = op_sel;
	int1 scale_t = scale;
	int1 in1_sel_t = in1_sel;
	int2 in2_sel_t = in2_sel;


	// Intermediate variables
	data_t acc;
	data_t op_1;
	data_t op_2;


	Compute: for (int iadd = 0; iadd < 16; iadd++)
	{
		// input 1 selector
		if (in1_sel_t == zero)
		{
			op_1 = in_1_bram_z[iadd];
		}

		else if (in1_sel_t == one)
		{
			op_1 = in_1_mac[iadd]; //pop_stream<float, 1, 1, 1>(in_1_mac[iadd]);
		}

		// input 2 selector
		if (in2_sel_t == zero_2)
		{
			op_2 = in_2_feedback[iadd]; //pop_stream<float, 1, 1, 1>(in_2_feedback[iadd]);
		}

		else if (in2_sel_t == one_2)
		{
			op_2 = in_2_bram_u[iadd];
		}

		else if (in2_sel_t == two)
		{
			op_2 = in_2_bram_q[iadd];
		}

		// Main computation
		// op_sel:
		//		0 --> add
		//		1 --> subtract
		if (op_sel_t == zero)
		{
			if (scale_t == one)
				{
					acc= (one_alpha * op_1) + (alpha * op_2);
					result_st[iadd] = acc; //push_stream<data_t, 1, 1, 1>(acc, iadd == (N - 1));
				}
			else
				{
					acc = op_1 + op_2;
				//	x[iadd] = acc;
					result_feedback[iadd] = acc; //push_stream<data_t, 1, 1, 1>(acc, iadd == (N - 1));
				}
		}

		else if (op_sel_t == one)
			{
				acc = op_1 - op_2;
				result_mac[iadd] = acc; //push_stream<data_t, 1, 1, 1>(acc, iadd == (N - 1));
			}
	}

	return;
}
