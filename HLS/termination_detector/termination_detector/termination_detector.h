#ifndef TERMINATION_DETECTOR_H_
#define TERMINATION_DETECTOR_H_


// configurable params

#define N		16
#define SQRT_N	N*N

#define ABSTOL	1e-4
#define RELTOL	1e-2

#define SQRTN_ABSTOL	SQRT_N*ABSTOL

typedef float 	in_data_t;
typedef float 	out_data_t;
typedef float 	data_t;


void termination_detector (

		// inputs
		in_data_t z_td[N],
		in_data_t x_td[N],
		in_data_t u_td[N],
		in_data_t z_old_td[N],

		volatile data_t &rho,

		out_data_t x_out[N],
		bool &terminate

		);
#endif
