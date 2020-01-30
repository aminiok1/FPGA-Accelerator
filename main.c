/******************************************************************************
 *
 * Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Use of the Software is limited solely to applications:
 * (a) running on a Xilinx device, or
 * (b) that interact with a Xilinx device through a bus or interconnect.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
 * OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Except as contained in this notice, the name of the Xilinx shall not be used
 * in advertising or otherwise to promote the sale, use or other dealings in
 * this Software without prior written authorization from Xilinx.
 *
 ******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "convolutional.h"
#define M 18
#define N 3
#define K 3
int i;
unsigned *imageInput = (unsigned int*) XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR;
unsigned *kernelInput = (unsigned int*) XPAR_AXI_BRAM_CTRL_2_S_AXI_BASEADDR;
unsigned *imageOutput = (unsigned int*) XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR;
//float imageInput[3][M][M], kernelInput[K][N][N][N], imageOutput[K][M - N + 1][M - N + 1];

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
	/*int i, j;
	for (i = 0; i < ST_SIZE; i++){
		if (i <= 10)
			kernelInput[i] = float_to_u32(i);
		else
			kernelInput[i] = float_to_u32(i-10);
		for (j = 0; j < ST_SIZE; j++)
			imageInput[(i*ST_SIZE) + j] = float_to_u32(-0.01);
	}*/

	//	for (i = 0; i < ST_SIZE; i++)
	//	res_hw[i] = 0;
	int i;
	for ( i = 0; i < K*N*N*N-1; ++i)
	{
		kernelInput[i] = i;

	}

	for ( i = 0; i < 3*M*M-1; ++i)
	{

		imageInput[i] = i;//float_to_u32(rand() % 10);

	}
}

/*void init_arrays_sw(float p_sw[ST_SIZE][ST_SIZE], float q_sw[ST_SIZE], float res_sw[ST_SIZE])
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
}*/

int main(int argc, char **argv)
{
	//float imageInput[3][M][M], kernelInput[K][N][N][N], imageOutput[K][M - N + 1][M - N + 1];

	//enable caches and initialize uart
	init_platform();

	xil_printf("Initializing HW and SW inputs\n\r");

	//init_arrays_sw(p_sw, q_sw, res_sw);

	init_arrays_hw();

	//Call software version of function
	//accelerator_ref(p_sw, q_sw, res_sw);

	//Call Hardware version of accelerator
	printf("starting HW execution\n");
	for (i=0;i<10;i++)
	{
		printf("kernel[%d] = %d,\n", i, kernelInput[i]);
	}

	Start_HW_Convolutional();


	xil_printf("Run HW Accelerator finished\n");
	for (i=0;i<10;i++)
		{
			printf("imageOutput[%d] = %d,\n", i, imageOutput[i]);
		}

	cleanup_platform();

	return 0;
}
