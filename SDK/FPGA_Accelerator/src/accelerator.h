/*
 * accelerator.h
 *
 *  Created on: May 28, 2019
 *      Author: Amin
 */

#ifndef SRC_ACCELERATOR_H_
#define SRC_ACCELERATOR_H_


#include <stdio.h>
#include <math.h>
#include "platform.h"

#define ST_SIZE 16

int Setup_HW_Accelerator(float p[ST_SIZE][ST_SIZE], float z_u[ST_SIZE], float q[ST_SIZE], float res[ST_SIZE]);
void accelerator_ref(float p[ST_SIZE][ST_SIZE], float q[ST_SIZE], float res[ST_SIZE]);
int setup_interrupt_system();
void isr (void *intc_inst_ptr);
int init_gpio();
int Run_HW_Accelerator();
int Start_HW_Accelerator();

#endif
