/*
 * accelerator.h
 *
 *  Created on: Feb 28, 2019
 *      Author: Amin
 */

#ifndef SRC_ACCELERATOR_H_
#define SRC_ACCELERATOR_H_


#include <stdio.h>
#include <math.h>
#include "platform.h"
#include "xparameters.h"
#include "xscugic.h"
//#include "xaxidma.h"
#include "xil_printf.h"
#include "xconvolutional.h"

#define ST_SIZE 128

int Start_HW_Convolutional(void);

int Run_HW_Accelerator(double A[ST_SIZE], double B[ST_SIZE], double C[ST_SIZE]);

#endif
