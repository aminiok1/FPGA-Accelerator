
#include <stdio.h>
#include <stdlib.h>
#include "conv.h"
//#define M 18
//#define N 3
//#define K 3
typedef int T;
//int combined_image[M][N];
int image[3][M][M] = { 0 };

int kernal[K][N][N][N] = { 0 };
int out[K][M - N + 1][M - N + 1] = { 0 };


//initial kernal
void init_kernals()
{
int a, b, c, d;
	for ( a = 0; a < K; ++a)
	{
		for ( b = 0; b < N; ++b)
		{
			for ( c = 0; c < N; ++c)
			{
				for ( d = 0; d < N; ++d)
				{
					kernal[a][b][c][d] = rand() % 3;
				}
			}

		}
	}
}

//initial image
void generate_matrix()
{
int i, row, col;

	for ( i = 0; i < 3; ++i)
	{
		for ( row = 1; row <= M - N + 1; ++row)
		{
			for ( col = 1; col <= M - N + 1; ++col)
			{
				image[i][row][col] = rand() % 10;
			}
		}
	}

}

void print_kernal()
{
int a, b, c, d;
	for ( a = 0; a < K; ++a)
	{
		for ( b = 0; b < N; ++b)
		{
			for ( c = 0; c < N; ++c)
			{
				for ( d = 0; d < N; ++d)
				{
					printf("%d ", kernal[a][b][c][d]);
				}
				printf("\n");
			}
			printf("\n");
		}
		printf("\n");
	}

}
/*
void convolutional()
{
	int ch = 0;
	int row = 0;
	int col = 0;
int k, ax, ay, c;
	for ( k = 0; k < K; ++k)
	{
		for ( ax = 1; ax <= M - N + 1; ++ax)
		{
			for ( ay = 1; ay <= M - N + 1; ++ay)
			{
				for ( c = 0; c < 3; ++c)
				{
					temp += image[c][ax - 1][ay - 1] * kernal[k][c][0][0] + image[c][ax - 1][ay] * kernal[k][c][0][1] + image[c][ax - 1][ay + 1] * kernal[k][c][0][2] +
						image[c][ax][ay - 1] * kernal[k][c][1][0] + image[c][ax][ay] * kernal[k][c][1][1] + image[c][ax][ay + 1] * kernal[k][c][1][2] +
						image[c][ax + 1][ay - 1] * kernal[k][c][2][0] + image[c][ax + 1][ay] * kernal[k][c][2][1] + image[c][ax + 1][ay + 1] * kernal[k][c][2][2];
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

}*/

void print_data()
{
int i, row, col;
	for  (i = 0; i < 3; ++i)
	{
		for ( row = 0; row < M; ++row)
		{
			for ( col = 0; col < M; ++col)
			{
				printf("%d ", image[i][row][col]);
			}
			printf("\n");
		}
		printf("\n");
	}
}

void print_out_data()
{
int ch, row, col;
	for ( ch = 0; ch < K;++ch)
	{
		for ( row = 0; row < M - N + 1; ++row)
		{
			for ( col = 0; col < M - N + 1; ++col)
			{
				printf("%d ", out[ch][row][col]);
			}
			printf("\n");
		}
		printf("\n");
	}

}

int main()
{
	generate_matrix();
	init_kernals();
	print_data();

	print_kernal();
	convolutional(image,kernal,out);
	print_out_data();
}

