/*
 * accelerator.c
 *
 *  Created on: May 28, 2019
 *      Author: Amin
 */
#include "accelerator.h"
#include "xil_cache.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "xmac_kernel.h"
#include "xop_vec_kernel.h"

// accelerator instance
XMac_kernel xmac_kernel;
XOp_vec_kernel xvec_kernel;

// axi dma instance
extern XAxiDma AxiDma;

XMac_kernel_Config xmac_kernel_config = {
		0,	//device id
		XPAR_MAC_KERNEL_0_S_AXI_CTRL_BUS_BASEADDR //base address for the control bus (taken from xparameters.h)
};

XOp_vec_kernel_Config xvec_kernel_config = {
		0,	//device id
		XPAR_OP_VEC_KERNEL_0_S_AXI_CTRL_BUS_BASEADDR //base address for the control bus (taken from xparameters.h)
};

// interrupt handler
XScuGic ScuGic;

// for a detailed implementation of the following functions refer to xaccelerator_kernel.c file
int XAccel_kernelSetup()
{
	int status;

	// this function sets the xaccel_kernel base address and sets its state to ready for execution
	status = XOp_vec_kernel_CfgInitialize(&xvec_kernel, &xvec_kernel_config);

	if (status != XST_SUCCESS)
	{
		printf("Error in kernel config initialize\n");
		return status;
	}

	status = XMac_kernel_CfgInitialize(&xmac_kernel, &xmac_kernel_config);

	if (status != XST_SUCCESS)
			printf("Error in kernel config initialize\n");

	return status;
}

void XAccel_kernelStart(void *InstancePtr)
{
	XMac_kernel *pExample = (XMac_kernel *) InstancePtr;
	XMac_kernel_InterruptEnable(pExample,1);
	XMac_kernel_InterruptGlobalEnable(pExample);

	// This function sets ap_start signal to 1 that initiates the execution of the accelerator
	XMac_kernel_Start(pExample);
}

void XAccel_kernelISR(void *InstancePtr)
{
	XMac_kernel *pExample = (XMac_kernel *) InstancePtr;
	//Disable GLobal Interrupts
	XMac_kernel_InterruptGlobalDisable(pExample);
	//Disable Local Interrupts
	XMac_kernel_InterruptDisable(pExample, 0xffffffff);

	//Clear Interrupt
	XMac_kernel_InterruptClear(pExample,1);
}

int XAccel_kernelSetupInterrupt()
{
	int result;
	XScuGic_Config *pCfg = XScuGic_LookupConfig(XPAR_SCUGIC_SINGLE_DEVICE_ID);
	if(pCfg == NULL)
	{
		printf("Interrupt Config Look Up Failed\n");
		return XST_FAILURE;
	}
	result = XScuGic_CfgInitialize(&ScuGic, pCfg, pCfg->CpuBaseAddress);
	if(result != XST_SUCCESS)
		return result;

	//self test
	result = XScuGic_SelfTest(&ScuGic);
	if(result != XST_SUCCESS)
		return result;

	//Initialize Exception Handler
	Xil_ExceptionInit();
	//Register Exception Handler with Interrupt Service Routine
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &ScuGic);
	Xil_ExceptionEnable();
	result = XScuGic_Connect(&ScuGic, XPAR_FABRIC_MAC_KERNEL_0_INTERRUPT_INTR, (Xil_ExceptionHandler)XAccel_kernelISR, &xmac_kernel);
	if(result != XST_SUCCESS)
		return result;

	XScuGic_Enable(&ScuGic, XPAR_FABRIC_MAC_KERNEL_0_INTERRUPT_INTR);
	return XST_SUCCESS;
}

int Setup_HW_Accelerator(float p[ST_SIZE][ST_SIZE], float z_u[ST_SIZE], float q[ST_SIZE], float res[ST_SIZE])
{
	int status = XAccel_kernelSetup();
	if(status != XST_SUCCESS)
	{
		printf("Error: Accelerator Setup Failed\n");
		return XST_FAILURE;
	}
	status = XAccel_kernelSetupInterrupt();
	if(status != XST_SUCCESS)
	{
		printf("Error: Interrupt Setup Failed\n");
		return XST_FAILURE;
	}
	XMac_kernel_Start(&xmac_kernel);

	//Cache Flush
	Xil_DCacheFlushRange((unsigned int)p, sizeof(double)*ST_SIZE*ST_SIZE);
	Xil_DCacheFlushRange((unsigned int)z_u, sizeof(double)*ST_SIZE);
	Xil_DCacheFlushRange((unsigned int)res, sizeof(double)*ST_SIZE);

	printf("Cache Cleared\n");

	return 0;
}

int Start_HW_Accelerator(void)
{
	int status = XAccel_kernelSetup();
	if(status != XST_SUCCESS)
	{
		printf("Error: Accelerator Setup Failed\n");
		return XST_FAILURE;
	}
	status = XAccel_kernelSetupInterrupt();
	if(status != XST_SUCCESS)
	{
		printf("Error: Interrupt Setup Failed\n");
		return XST_FAILURE;
	}

	XMac_kernel_Start(&xmac_kernel);

	XOp_vec_kernel_Start(&xvec_kernel);

	return XST_SUCCESS;
}

int Run_HW_Accelerator(float res[ST_SIZE])
{
	int status;

	// Wait for MAC kernel
	while (!XMac_kernel_IsDone(&xmac_kernel));

	// wait for add kernel and get the results from axi dma
	status = XAxiDma_SimpleTransfer(&AxiDma, (unsigned int) res, sizeof(float)*ST_SIZE, XAXIDMA_DEVICE_TO_DMA);

	if(status != XST_SUCCESS)
	{
		printf("Error: Receiving C from the Accelerator");
	}

	//Poll DMA engine to ensure transfers are complete.
	while (XAxiDma_Busy(&AxiDma, XAXIDMA_DEVICE_TO_DMA));

	printf("waiting for vec op\n");
	while (!XOp_vec_kernel_IsDone(&xvec_kernel));
	printf("vec op finished\n");

	return XST_SUCCESS;

}

void accelerator_ref(float p[ST_SIZE][ST_SIZE], float z_u[ST_SIZE], float q[ST_SIZE], float res[ST_SIZE])
{
	int i, j;
	for (i = 0; i < ST_SIZE; ++i)
		for (j = 0; j < ST_SIZE; ++j)
			res[i] += p[i][j] * z_u[j];

	for (i = 0; i < ST_SIZE; ++i)
		res[i] += q[i];
}
