#include <stdio.h>
#include <string.h>
#define SIZE 100
#define filename "data.txt"

typedef struct Node_Struct
{
	char op;
	char c1;
	char c2;
	char c3;
	char c4;
	char c5;
	int totChildren;

}Node;

//create array of type node, of size x;


//GPU Function
//Sents relevant arguements to GPU child which makes a node in position i of array
__global__ void gpu_cuit(int count, int index, char* input) //end is exclusive
{

	int i = threadIdx.x;
	//create a Node
	//assign position i to Node
	if(i < index)
	printf("count %d, %s\n", count, input);
}

/*
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// HELPER CODE TO INITIALIZE, PRINT AND TIME
struct timeval start, end;
void initialize(float *a, long N) {
long i;
for (i = 0; i < N; ++i) {
a[i] = pow(rand() % 10, 2);
}
}

void print(float* a, long N) {
if (doPrint) {
long i;
for (i = 0; i < N; ++i)
printf("%d ", (int) a[i]);
printf("\n");
}
}

void starttime() {
gettimeofday( &start, 0 );
}

void endtime(const char* c) {
gettimeofday( &end, 0 );
double elapsed = ( end.tv_sec - start.tv_sec ) * 1000.0 + ( end.tv_usec - start.tv_usec ) / 1000.0;
printf("%s: %f ms\n", c, elapsed);
}

void init(float* a, long N, const char* c) {
printf("***************** %s **********************\n", c);
printf("Initializing array....\n");
initialize(a, N);
printf("Done.\n");
print(a, N);
printf("Running %s...\n", c);
starttime();
}

void finish(float* a, long N, const char* c) {
endtime(c);
printf("Done.\n");
print(a, N);
printf("***************************************************\n");
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////

*/

int main()
{

	
	char input[SIZE * 5 + SIZE]; 	//maximum number of arguments + operators
	long N = sizeof(input);
	int op[SIZE];      //holds indexes / indices of operators of the input
	int i = 0;		     //loop variable
	int index = 0;     //holds the position of the last element of the op array
	int start = 0;
	int end = 0;

	//define file object and read it in
	FILE* file = fopen(filename,"r");
	if(file == NULL)
	{
		printf("Could not open %s. Please make sure your file is valid.\n", filename);
		exit(0);
	}

	//read in equation
	fgets(input, 100, file);

	//iterate through and save operator indexes
	for(i = 0; i < strlen(input);i++)
	{
		if(input[i] == '+')
		{
			op[index] = i;
			index++;
		}
	}

	// Test: GPU

	// How many threads, how many cores?
	int numThreads = 1024; // This can vary, up to 1024
	long numCores = N / 1024 + 1;

	int count = 0;

	char* sub;
	cudaMallocManaged(&sub, 5);
//	strcpy(sub, input);

	//send to gpu children
	for(i = 0; i <= index - 1;i++)
	{

		if(i == 0)
		{
			strncpy(sub, input, op[i]);
			gpu_cuit<<<1,1>>>(count, index, sub);
		}else
		{
			strncpy(sub, input+op[i-1] + 1, op[i]-op[i-1]-1);
			gpu_cuit<<<1,1>>>(count, index, sub);
		}

		cudaDeviceSynchronize();
		count++;
	}

	exit(0);
}
