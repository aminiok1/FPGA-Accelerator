/*
 * accelerator.c
 *
 *  Created on: May 28, 2019
 *      Author: Amin
 */
#include "accelerator.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xscugic.h"

#define ALPHA				1
#define RHO_INV				1
#define INTC_INTERRUPT_ID_0 61 // IRQ_F2P[0:0]

float *res_hw = (float *) (XPAR_BRAM_2_BASEADDR);


XGpio gpioOut, gpioIn;

// Instance of interrupt controller
static XScuGic intc;

// interrupt service routine for IRQ_F2P[0:0]
void isr (void *intc_inst_ptr)
{
    xil_printf("HW results\n");
    for (int i = 0; i < ST_SIZE; i++)
    		printf("res_hw[%d] = %.6f\n", i, res_hw[i]);
}

// sets up the interrupt system and enables interrupts for IRQ_F2P[1:0]
int setup_interrupt_system()
{

    int result;
    XScuGic *intc_instance_ptr = &intc;
    XScuGic_Config *intc_config;

    // get config for interrupt controller
    intc_config = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID);
    if (NULL == intc_config) {
        return XST_FAILURE;
    }

    // initialize the interrupt controller driver
    result = XScuGic_CfgInitialize(intc_instance_ptr, intc_config, intc_config->CpuBaseAddress);

    if (result != XST_SUCCESS) {
        return result;
    }

    // set the priority of IRQ_F2P[0:0] to 0xA0 (highest 0xF8, lowest 0x00) and a trigger for a rising edge 0x3.
    XScuGic_SetPriorityTriggerType(intc_instance_ptr, INTC_INTERRUPT_ID_0, 0x00, 0x3);

    // connect the interrupt service routine isr0 to the interrupt controller
    result = XScuGic_Connect(intc_instance_ptr, INTC_INTERRUPT_ID_0, (Xil_ExceptionHandler)isr, (void *)&intc);

    if (result != XST_SUCCESS) {
        return result;
    }

    // enable interrupts for IRQ_F2P[0:0]
    XScuGic_Enable(intc_instance_ptr, INTC_INTERRUPT_ID_0);


    // initialize the exception table and register the interrupt controller handler with the exception table
    Xil_ExceptionInit();

    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, intc_instance_ptr);

    // enable non-critical exceptions
    Xil_ExceptionEnable();

    return XST_SUCCESS;
}

int Start_HW_Accelerator(void)
{

	int status;

	//initialize axi gpio
	status = init_gpio();
	XGpio_DiscreteWrite(&gpioOut, 1, 0x00);

	//setup interrupt
	status = setup_interrupt_system();
	if(status != XST_SUCCESS)
	{
		printf("Error: Accelerator Setup Failed\n");
		return XST_FAILURE;
	}

	// start the execution
	XGpio_DiscreteWrite(&gpioOut, 1, 0xFF);
	printf("read = %d\n", 	XGpio_DiscreteRead(&gpioIn, 1));
	printf("read = %d\n", 	XGpio_DiscreteRead(&gpioIn, 1));
	printf("read = %d\n", 	XGpio_DiscreteRead(&gpioIn, 1));


	while(1);

	return XST_SUCCESS;
}

int init_gpio()
{
	int status = XGpio_Initialize(&gpioOut, XPAR_GPIO_0_DEVICE_ID);
	status = XGpio_Initialize(&gpioIn, XPAR_GPIO_1_DEVICE_ID);

	if (status != XST_SUCCESS) {
		print("Error:GPIO Initialization Failed\n");
		return XST_FAILURE;
	}

	//set direction as output
	XGpio_SetDataDirection(&gpioOut, 1, 0x00);
	XGpio_SetDataDirection(&gpioIn, 1, 0xFF);

	return XST_SUCCESS;
}

void accelerator_ref(float p[ST_SIZE][ST_SIZE], float q[ST_SIZE], float res[ST_SIZE])
{
	int i;
	int irow, icol;
	float z[ST_SIZE] = {0};
	float u[ST_SIZE] = {0};
	float x[ST_SIZE], x_hat[ST_SIZE], z_u[ST_SIZE], p_z_u[ST_SIZE];

	for (i = 0; i < 6; i++)
	{

		for (irow = 0; irow < ST_SIZE; irow++)
			z_u[irow] = z[irow] - u[irow];

		for (irow = 0; irow < ST_SIZE; irow++)
		{
			float tmp = 0;
			for (icol = 0; icol < ST_SIZE; icol++)
				tmp += p[irow][icol] * z_u[icol];
			p_z_u[irow] = tmp;
		}

		for (irow = 0; irow < ST_SIZE; irow++)
			x[irow] = p_z_u[irow] + q[irow];

		for (irow = 0; irow < ST_SIZE; irow++)
			x_hat[irow] = (ALPHA * x[irow]) + ((1 - ALPHA) * z[irow]);

		for (irow = 0; irow < ST_SIZE; irow++)
		{
			float tmp1 = x_hat[irow] + u[irow] - RHO_INV;
			float tmp2 = -1 * x_hat[irow] - u[irow] - RHO_INV;

			tmp1 = (tmp1 > 0) ? tmp1:0;
			tmp2 = (tmp2 > 0) ? tmp2:0;

			z[irow] = tmp1 - tmp2;
		}

		for (irow = 0; irow < ST_SIZE; irow++)
			u[irow] = u[irow] + x_hat[irow] - z[irow];
	}

	for (irow = 0; irow < ST_SIZE; irow++)
		res[irow] = x[irow];

	printf("SW results:\n");
	for (irow = 0; irow < ST_SIZE; irow++)
		printf("res_sw[%d] = %.6f\n", irow, res[irow]);

}
