#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xparameters.h"
#include "accelerator.h"
#include "xil_printf.h"

unsigned *p_hw = (unsigned int *) (XPAR_BRAM_0_BASEADDR);
unsigned *q_hw = (unsigned int*) (XPAR_BRAM_1_BASEADDR);

// float to IEEE conversion
unsigned int float_to_u32(float val)
{
	unsigned int result;
	union float_bytes{
		float v;
		unsigned char bytes[4];
	}data;

	data.v = val;

	result = (data.bytes[3] << 24) + (data.bytes[2] << 16) + (data.bytes[1] << 8) + (data.bytes[0]);

	return result;
}

void init_arrays_hw()
{
	int i, j;

	for (i = 0; i < ST_SIZE; i++){
		if (i <= 10)
			q_hw[i] = float_to_u32(i);
		else
			q_hw[i] = float_to_u32(i-10);
		for (j = 0; j < ST_SIZE; j++)
			p_hw[(i*ST_SIZE) + j] = float_to_u32(-0.01);
	}

//	for (i = 0; i < ST_SIZE; i++)
	//	res_hw[i] = 0;
}

void init_arrays_sw(float p_sw[ST_SIZE][ST_SIZE], float q_sw[ST_SIZE], float res_sw[ST_SIZE])
{
	int i, j;

	for (i = 0; i < ST_SIZE; i++){
		if (i <= 10)
			q_sw[i] = (float) (i);
		else
			q_sw[i] = (float) (i-10);

		for (j = 0; j < ST_SIZE; j++)
			p_sw[i][j] = (float) (-0.01);
	}

	for (i = 0; i < ST_SIZE; i++)
		res_sw[i] = 0;
}

int main(int argc, char **argv)
{
	float p_sw[ST_SIZE][ST_SIZE], q_sw[ST_SIZE], res_sw[ST_SIZE];

	//enable caches and initialize uart
	init_platform();

	xil_printf("Initializing HW and SW inputs\n\r");

	init_arrays_sw(p_sw, q_sw, res_sw);

	init_arrays_hw();

	//Call software version of function
	accelerator_ref(p_sw, q_sw, res_sw);

	//Call Hardware version of accelerator
	printf("starting HW execution\n");

	Start_HW_Accelerator();

	xil_printf("Run HW Accelerator finished\n");

	cleanup_platform();

	return 0;
}
