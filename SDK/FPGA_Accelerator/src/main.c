#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xparameters.h"
#include "accelerator.h"
#include "xil_printf.h"
#include "xaxidma.h"

float *p_hw = (float *) XPAR_BRAM_0_BASEADDR;
float *z_u_hw = (float *) XPAR_BRAM_1_BASEADDR;
float *q_hw = (float *) XPAR_BRAM_2_BASEADDR;

//AXI DMA Instance
XAxiDma AxiDma;

int init_dma() {
	XAxiDma_Config *CfgPtr;
	int status;

	// check xparameters.h to see where XPAR_AXI_DMA_0_DEVICE_ID comes from
	CfgPtr = XAxiDma_LookupConfig((XPAR_AXI_DMA_0_DEVICE_ID));

	if (!CfgPtr) {
		print("Error: Failed to find DMA Config\n");
		return XST_FAILURE;
	}

	status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);

	if (status != XST_SUCCESS) {
		print("Error: Failed to Initialize DMA\n");
		return XST_FAILURE;
	}

	//check for scatter gather mode
	if (XAxiDma_HasSg(&AxiDma)) {
		print("Error: DMA has Scatter Gather Enabled \n");
		return XST_FAILURE;
	}

	//Reset Dma
	XAxiDma_Reset(&AxiDma);

	//wait for the reset to finish
	while(!XAxiDma_ResetIsDone(&AxiDma));

	return XST_SUCCESS;
}
void init_arrays_hw(float res_hw[ST_SIZE])
{
	int i, j;

	for (i = 0; i < ST_SIZE; i++){
		z_u_hw[i] = (float) (2*i);
		q_hw[i] = (float) (3*i);

		for (j = 0; j < ST_SIZE; j++)
			p_hw[(i*ST_SIZE) + j] = (float) (i+j);
	}

//	for (i = 0; i < ST_SIZE; i++)
	//	res_hw[i] = 0;
}

void init_arrays_sw(float p_sw[ST_SIZE][ST_SIZE], float z_u_sw[ST_SIZE], float q_sw[ST_SIZE], float res_sw[ST_SIZE])
{
	int i, j;

	for (i = 0; i < ST_SIZE; i++){
		z_u_sw[i] = (float) (2*i);
		q_sw[i] = (float) (3*i);

		for (j = 0; j < ST_SIZE; j++)
			p_sw[i][j] = (float) (i+j);
	}

	for (i = 0; i < ST_SIZE; i++)
		res_sw[i] = 0;
}
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

int main(int argc, char **argv)
{
	int i;
	int status;
	int err = 0 ;
	float errAccum = 0;

	float p_sw[ST_SIZE][ST_SIZE], z_u_sw[ST_SIZE], q_sw[ST_SIZE], res_sw[ST_SIZE];
	float res_hw[ST_SIZE];

	//enable caches and initialize uart
	init_platform();

	status = init_dma();

	if (status != XST_SUCCESS) {
			print("Error: Initializing DMA Failed\n");
			return XST_FAILURE;
	}

	xil_printf("start\n\r");

	init_arrays_sw(p_sw, z_u_sw, q_sw, res_sw);
	init_arrays_hw(res_hw);

	//Call software version of function
	xil_printf("Running MVM in SW\n");
	accelerator_ref(p_sw, z_u_sw, q_sw, res_sw);

	//Call Hardware version of accelerator
	xil_printf("Running MVM in HW\n");
	//Setup_HW_Accelerator(p_hw, z_u_hw, res_hw);

	Start_HW_Accelerator();
	xil_printf("Run HW Accelerator\n");
	Run_HW_Accelerator(res_hw);

	//**************************************************************************
	//Compare Results of add
	for (i = 0; i < ST_SIZE; i++)
		if(res_sw[i] != res_hw[i])
		{
			printf("index = %d, sw = %f, hw = %f\n", i, res_sw[i], res_hw[i]);
			err++;
			errAccum += abs(res_sw[i] - res_hw[i]);
		}

	errAccum = errAccum / err;

	if (err == 0)
		print("SW and HW Results Match!\n");

	else
	{
		printf("ERROR: Results Mismatch\n");
		printf("Errors: %d Average Error: %f\n", err, errAccum);
	}

	cleanup_platform();

	return 0;
}
