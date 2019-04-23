#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#define SIZE 10000
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


//GPU Function
//Sents relevant arguements to GPU child which makes a node in position i of array
__global__ void gpu_cuit(int totalPlusses, int* op, char* input, Node** nodes) //end is exclusive
{
	int i = threadIdx.x;
	int start;
	int end;
	int j;

	if(i == 0)
	{
		start = 0;
		end = op[i] - 1;
	}
	else
	{
		start = op[i - 1] + 1;
		end  = op[i] - 1;
	}

	Node* temp = (Node*)malloc(sizeof(Node));
	temp->op = '+';
	int l = 0;

	for(j = start; j <= end; j++ )
	{
		if (input[j] == NULL)
			break;
		else
			if (l == 0)
				{temp->c1 = input[j]; l++;}
			else if (l == 1)
				{temp->c2 = input[j]; l++;}
			else if (l == 2)
				{temp->c3 = input[j]; l++;}
			else if (l == 3)
				{temp->c4 = input[j]; l++;}
			else if (l == 4)
				{temp->c5 = input[j]; l++;}
	}

	nodes[i] = temp;
}

void normal_cuit(int totalPlusses, int* op, char* input, Node** nodes)
{
	int start;
	int end;
	int i;

	for (i = 0; i < totalPlusses; i++)
	{
		if(i == 0)
		{
			start = 0;
			end = op[i] - 1;
		}
		else
		{
			start = op[i - 1] + 1;
			end  = op[i] - 1;
		}

		Node* temp = (Node*)malloc(sizeof(Node));
		temp->op = '+';
		int l = 0;
		int j = 0;
		for(j = start; j <= end; j++ )
		{
				if (l == 0)
					{temp->c1 = input[j]; l++;}
				else if (l == 1)
					{temp->c2 = input[j]; l++;}
				else if (l == 2)
					{temp->c3 = input[j]; l++;}
				else if (l == 3)
					{temp->c4 = input[j]; l++;}
				else if (l == 4)
					{temp->c5 = input[j]; l++;}
		}
		nodes[i] = temp;
	}
}

struct timeval start, end;

void starttime() {
gettimeofday( &start, 0 );
}

void endtime() {
gettimeofday( &end, 0 );
double elapsed = ( end.tv_sec - start.tv_sec ) * 1000.0 + ( end.tv_usec - start.tv_usec ) / 1000.0;
printf("Time: %f ms\n",elapsed);
}

int main()
{
	char* input;
	cudaMallocManaged(&input, sizeof(char) * SIZE * 5 + SIZE);
	int i = 0;		//loop variable
	int totalPlusses = 0;     //holds the position of the last element of the op array
	int* op; 						//holds indexes / indices of operators of the input
	cudaMallocManaged(&op, SIZE);
	Node** nodes_gpu;
	cudaMallocManaged(&nodes_gpu, sizeof(Node*) * SIZE);
	Node** nodes_normal;
	cudaMallocManaged(&nodes_normal, sizeof(Node*) * SIZE);

	//define file object and read it in
	FILE* file = fopen(filename,"r");
	if(file == NULL)
	{
		printf("Could not open %s. Please make sure your file is valid.\n", filename);
		exit(0);
	}

	//read in equation
	fgets(input, SIZE, file);

	//iterate through and save operator indexes
	for(i = 0; i < strlen(input); i++)
	{
		if(input[i] == '+')
		{
			op[totalPlusses] = i;
			totalPlusses++;
		}
	}

	//gpu timed test
	starttime();
	gpu_cuit<<<1, totalPlusses>>>(totalPlusses, op, input, nodes_gpu);
	cudaDeviceSynchronize();
	endtime();

	//iterative timed test
	starttime();
	normal_cuit(totalPlusses, op, input, nodes_normal);
	endtime();


	//free everything
	cudaFree(input);
	for (i = 0; i < totalPlusses; i++)
	{
		free(nodes_gpu[i]);
		free(nodes_normal[i]);
	}
	cudaFree(op);
	cudaFree(nodes_gpu);
	cudaFree(nodes_normal);

	exit(0);
}
