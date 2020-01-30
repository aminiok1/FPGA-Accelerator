#include "convolutional.h"

//extern XAxiDma AxiDma;

// convolutional instance
XConvolutional xConvolutional;

XConvolutional_Config xConvolutional_config = {
		0,	//device id
		XPAR_CONVOLUTIONAL_0_S_AXI_CONTROL_BUS_BASEADDR //base address for the control bus (taken from xparameters.h)
};

// interrupt handler
XScuGic ScuGic;


// for a detailed implementation of the following functions refer to xConvolutional.c file
int XConvolutional_Setup()
{
	// this function sets the xConvolutional base address and sets its state to ready for execution
	return XConvolutional_CfgInitialize(&xConvolutional, &xConvolutional_config);
}

/*void XConvolutional_Start(void *InstancePtr)
{
	XConvolutional *pExample = (XConvolutional *) InstancePtr;
	XConvolutional_InterruptEnable(pExample,1);
	XConvolutional_InterruptGlobalEnable(pExample);
	
	// This function sets ap_start signal to 1 that initiates the execution of the Convolutional
	XConvolutional_Start(pExample);
}*/

void XConvolutional_ISR(void *InstancePtr)
{
	XConvolutional *pExample = (XConvolutional *) InstancePtr;
	//Disable GLobal Interrupts
	XConvolutional_InterruptGlobalDisable(pExample);
	//Disable Local Interrupts
	XConvolutional_InterruptDisable(pExample, 0xffffffff);

	//Clear Interrupt
	XConvolutional_InterruptClear(pExample,1);
}

int XConvolutional_SetupInterrupt()
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
	result = XScuGic_Connect(&ScuGic, XPAR_FABRIC_CONVOLUTIONAL_0_INTERRUPT_INTR, (Xil_ExceptionHandler)XConvolutional_ISR, &xConvolutional);
	if(result != XST_SUCCESS)
		return result;

	XScuGic_Enable(&ScuGic, XPAR_FABRIC_CONVOLUTIONAL_0_INTERRUPT_INTR);
	return XST_SUCCESS;
}


int Start_HW_Convolutional(void)
{
	int status = XConvolutional_Setup();
	if(status != XST_SUCCESS)
	{
		printf("Error: ConvolutionalSetup Failed\n");
		return XST_FAILURE;
	}
	status = XConvolutional_SetupInterrupt();
	if(status != XST_SUCCESS)
	{
		printf("Error: Interrupt Setup Failed\n");
		return XST_FAILURE;
	}

	XConvolutional_Start(&xConvolutional);

	while(!XConvolutional_IsDone(&xConvolutional));

	return XST_SUCCESS;
}

void Convolutional_ref(double A[ST_SIZE], double B[ST_SIZE], double C[ST_SIZE])
{
	int i;

	for(i = 0; i < ST_SIZE; ++i)
		C[i] = A[i] + B[i];
}
