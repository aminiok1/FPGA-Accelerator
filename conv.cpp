
#include<stdio.h>
#include "conv.h"
//#include "vec_add.h"

//void convolutional(AXI_VAL image_stream[3*M*M],AXI_VAL kernal_stream[K*N*N*N],AXI_VAL out_stream[K*(M - N + 1)*(M - N + 1)])  // one img, all kernals,int K, int M, int N
void convolutional(int image[3][M][M], int kernal[K][N][N][N], int out[K][M - N + 1][M - N + 1])  // one img, all kernals,int K, int M, int N

{
#pragma HLS RESOURCE variable=kernal core=RAM_1P_BRAM
#pragma HLS RESOURCE variable=image core=RAM_1P_BRAM
#pragma HLS INTERFACE bram port=out

//#pragma HLS INTERFACE axis register both port=image_stream
//#pragma HLS INTERFACE axis register both port=kernal_stream
//#pragma HLS INTERFACE axis register both port=out_stream
#pragma HLS INTERFACE s_axilite port=return bundle=CONTROL_BUS


	int ch = 0;
	int row = 0;
	int col = 0;
	int temp = 0;
	int k, ax, ay, c;
	int i, j, m, n;
	//int image[3][M][M], kernal[K][N][N][N], out[K][M - N + 1][M - N + 1];
	/**********************************
	 * retrive image
	 *
	 *
	 * ************************************************/
	/*
	for ( i=0; i<4; ++i)
	{
		for ( j=0; j<M; ++j)
		{
			for ( m=0; m<M; ++m)
			{
				image[i][j][m] = pop_stream<int, 4, 5, 5> (image_stream[(i*4) + (j*M) + m]);
			}
		}
	}
	*/
	/**********************************
	 * retrive kernal
	 *
	 *
	 * ************************************************/
	/*
	for ( i=0; i<K; ++i)
	{
		for ( j=0; j<N; ++j)
		{
			for ( m=0; m<N; ++m)
			{
				for( n=0; n<N; ++n)
				{
					kernal[i][j][m][n] = pop_stream<int, 4, 5, 5> (kernal_stream[(i*K) + (j*N) + (m*N) + n]);
				}
			}
		}
	}
	*/
	/****************
	 * computation
	 *
	 *
	 * ******************/

	convolutional_label0:for ( k = 0; k < K; ++k)
	{
		convolutional_label1:for ( ax = 1; ax <= M - N + 1; ++ax)
		{
			convolutional_label2:for ( ay = 1; ay <= M - N + 1; ++ay)
			{
				convolutional_label3:for ( c = 0; c < 3; ++c) //each RGB channel
				{
//#pragma HLS PIPELINE
					temp += image[c][ax - 1][ay - 1] * kernal[k][c][0][0] +
							image[c][ax - 1][ay] * kernal[k][c][0][1] +
							image[c][ax - 1][ay + 1] * kernal[k][c][0][2] +
							image[c][ax][ay - 1] * kernal[k][c][1][0] +
							image[c][ax][ay] * kernal[k][c][1][1] +
							image[c][ax][ay + 1] * kernal[k][c][1][2] +
							image[c][ax + 1][ay - 1] * kernal[k][c][2][0] +
							image[c][ax + 1][ay] * kernal[k][c][2][1] + image[c][ax + 1][ay + 1] * kernal[k][c][2][2];
				}

				out[ch][row][col] = temp;
				temp = 0;
				col++;
				if (col == M - N + 1)
				{
					col = 0;
					row++;
					if (row == M - N + 1)
					{
						row = 0;
						ch++;
					}

				}

			}
		}
	}

	/**********************************
		 * streaming output
		 * ************************************************/
	/*
	for ( i=0; i<4; ++i)
		{
			for ( j=0; j<M; ++j)
			{
				for ( m=0; m<M; ++m)
				{
					out_stream[(i*4) + (j*M) + m] = push_stream<int, 4, 5, 5> (out[i][j][m]);
				}
			}
		}
		*/
return;
}
