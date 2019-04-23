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
} Node;

//create array of type node, of size x;
Node* nodes = (Node*)malloc((sizeof(Node) * SIZE));

//GPU Function
//Sents relevant arguements to GPU child which makes a node in position i of array

__global__ void gpu_cuit(int totalPlusses, int* op, char* input) //end is exclusive
{
	//char* lclvar = "actual string";
	//printf("top of gpu method %s\n", lclvar);
	int i = threadIdx.x;
	int start;
	int end;
	int j;

	//printf("IN GPU: gpu paramaters: int totalPlusses: (%d), int* op (%p), %s, op[%d]: %d \n", totalPlusses, op, input, i, op[i]);

	if(i == 0)
	{
		//printf("inside if i == 0, op[%d]: %d\n", i,op[i]);
		start = 0;
		end = op[i] - 1;
	}
	else
	{
		//printf("inside if i != 0, op[%d]: %d\n", i, op[i]);
		start = op[i - 1] + 1;
		end  = op[i] - 1;
	}

	printf("assignmet of start (%d) and end (%d). totalOps: %d THREAD: %d\n", start, end, totalPlusses, i);

}

	//create a Node
//	Node* temp = (Node*)malloc(sizeof(Node));
//temp->op = '+';
	//int l = 0;
	/*
	while(substring[l] != NULL)
	{
		printf("infiniteeeeeeeeeee");
		if (l == 0)
			temp->c1 = substring[l];
		else if (l == 1)
			temp->c2 = substring[l];
		else if (l == 2)
			temp->c3 = substring[l];
		else if (l == 3)
			temp->c4 = substring[l];
		else if (l == 4)
			temp->c5 = substring[l];
	}*/

	//assign position i to Node
//
//		printf("currArrIndex %d, %s\n", currArrIndex, substring);


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
	char input[SIZE * 5 + SIZE]; //= (char*)malloc(sizeof(char) * (SIZE * 5 + SIZE)); 	//maximum number of arguments + operators      //holds indexes / indices of operators of the input
	int i = 0;		     //loop variable
	int totalPlusses = 0;     //holds the position of the last element of the op array
	int currArrIndex = 0;
	//long N = 64000000;

	//define file object and read it in
	FILE* file = fopen(filename,"r");
	if(file == NULL)
	{
		printf("Could not open %s. Please make sure your file is valid.\n", filename);
		exit(0);
	}

	//read in equation
	fgets(input, SIZE, file);

	int* op; //= (int*) malloc(sizeof(int) * SIZE);
	cudaMallocManaged(&op, SIZE);

	int* gpu_op;
	char* gpu_input;
	cudaMalloc(&gpu_op, sizeof(int) * SIZE);
	cudaMalloc(&gpu_input, sizeof(char) * (SIZE * 5 + SIZE));

	//iterate through and save operator indexes
	for(i = 0; i < strlen(input); i++)
	{
		if(input[i] == '+')
		{
			op[totalPlusses] = i;
			totalPlusses++;
		}
	}

	cudaMemcpy(gpu_op, op, (sizeof(int) * SIZE), cudaMemcpyDeviceToHost);
	cudaMemcpy(gpu_input, input,  sizeof(char) * (SIZE * 5 + SIZE), cudaMemcpyDeviceToHost);

	char* sub;
	cudaMallocManaged(&sub, 1000);
	strcpy(sub, input);

	printf("before gpu call\n");
	printf("IN MAIN: gpu paramaters: int totalPlusses: (%d), int* op (%p), char* input (%p) \n", totalPlusses, op, sub);

	for (i = 0; i < totalPlusses; i++)
	{
		printf("op[%d]: %d \n", i, op[i]);
	}

	gpu_cuit<<<1, 8>>>(totalPlusses, op, sub);
	printf("after gpu call\n");

	cudaDeviceSynchronize();

	printf("after gpu synchronize\n");

	//free(op);
	//sfree(input);
	cudaFree(gpu_op);
	cudaFree(gpu_input);

	exit(0);
}
