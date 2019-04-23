/************************************************************************************
 * Converts a boolean equation in DNF form to a list of nodes.
 * 		Compares parallel computations with varied shared memory allocation
 *    and and iterative implementation.
 *
 * We affirm that we wrote this program ourselves in accordance to FIU the Code of
 * Academic Integrity.
 *    Authors: Alejandro Ravelo
 *             Alejandro Koszarycz
 *             Aysha Habbaba
 *             Rahul Mittal
 **********************************************************************************/
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <getopt.h>
#define SIZE 10000                //max number of operations
#define BLOCKSIZE 1               //total blocks
#define filename "data.txt"       //filename is by default data.txt

//represents each 'subtree' with values op and children c1-c5
typedef struct Node_Struct
{
	char op, c1, c2, c3, c4, c5;
} Node;

//***GPU Functions***/

//Creates a node representing the operation at point i, and adds it to the nodes array at position i
//Both operator indicies array and input string are part of the block's share'd memory
__global__ void gpu_cuit_all_shared(int totalPlusses, char* op, int* opIndexes, char* input, Node** nodes) //end is exclusive
{
	int i = threadIdx.x;
	__shared__ char op_shared[BLOCKSIZE];
	__shared__ int opIndexes_shared[BLOCKSIZE];
	__shared__ char input_shared[BLOCKSIZE];

	int start;
	int end;
	int j;

	op_shared[i] = op[i];
	opIndexes_shared[i] = opIndexes[i];
	input_shared[i] = input[i];

	if(i == 0)
	{
		start = 0;
		end = opIndexes_shared[i] - 1;
	}
	else
	{
		start = opIndexes_shared[i - 1] + 1;
		end  = opIndexes_shared[i] - 1;
	}

	Node* temp = (Node*)malloc(sizeof(Node));
	temp->op = op_shared[i];
	temp->c1 = ' ';
	temp->c2 = ' ';
	temp->c3 = ' ';
	temp->c4 = ' ';
	temp->c5 = ' ';
	int l = 0;

	for(j = start; j <= end; j++ )
	{
		if (input_shared[j] == NULL)
			break;
		else
			if (l == 0)
				{temp->c1 = input_shared[j]; l++;}
			else if (l == 1)
				{temp->c2 = input_shared[j]; l++;}
			else if (l == 2)
				{temp->c3 = input_shared[j]; l++;}
			else if (l == 3)
				{temp->c4 = input_shared[j]; l++;}
			else if (l == 4)
				{temp->c5 = input_shared[j]; l++;}
	}

	nodes[i] = temp;
}

//Creates a node representing the operation at point i, and adds it to the nodes array at position i
//Operator indices array is part of the block's shared memory
__global__ void gpu_cuit_op_shared(int totalPlusses, char* op ,int* opIndexes, char* input, Node** nodes) //end is exclusive
{
	int i = threadIdx.x;
	__shared__ char op_shared[BLOCKSIZE];
	__shared__ int opIndexes_shared[BLOCKSIZE];

	int start;
	int end;
	int j;

	op_shared[i] = op[i];
	opIndexes_shared[i] = opIndexes[i];

	if(i == 0)
	{
		start = 0;
		end = opIndexes_shared[i] - 1;
	}
	else
	{
		start = opIndexes_shared[i - 1] + 1;
		end  = opIndexes_shared[i] - 1;
	}

	Node* temp = (Node*)malloc(sizeof(Node));
	temp->op = op_shared[i];
	temp->c1 = ' ';
	temp->c2 = ' ';
	temp->c3 = ' ';
	temp->c4 = ' ';
	temp->c5 = ' ';
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

//Creates a node representing the operation at point i, and adds it to the nodes array at position i
//Input string is part of the block's shared memory
__global__ void gpu_cuit_input_shared(int totalPlusses, char* op, int* opIndexes, char* input, Node** nodes) //end is exclusive
{
	int i = threadIdx.x;
	__shared__ char input_shared[BLOCKSIZE];

	int start;
	int end;
	int j;

	input_shared[i] = input[i];

	if(i == 0)
	{
		start = 0;
		end = opIndexes[i] - 1;
	}
	else
	{
		start = opIndexes[i - 1] + 1;
		end  = opIndexes[i] - 1;
	}

	Node* temp = (Node*)malloc(sizeof(Node));
	temp->op = op[i];
	temp->c1 = ' ';
	temp->c2 = ' ';
	temp->c3 = ' ';
	temp->c4 = ' ';
	temp->c5 = ' ';
	int l = 0;

	for(j = start; j <= end; j++ )
	{
		if (input_shared[j] == NULL)
			break;
		else
			if (l == 0)
				{temp->c1 = input_shared[j]; l++;}
			else if (l == 1)
				{temp->c2 = input_shared[j]; l++;}
			else if (l == 2)
				{temp->c3 = input_shared[j]; l++;}
			else if (l == 3)
				{temp->c4 = input_shared[j]; l++;}
			else if (l == 4)
				{temp->c5 = input_shared[j]; l++;}
	}

	nodes[i] = temp;
}

//Creates a node representing the operation at point i, and adds it to the nodes array at position i
//no shared memory used
__global__ void gpu_cuit_none_shared(int totalPlusses, char* op, int* opIndexes, char* input, Node** nodes) //end is exclusive
{
	int i = threadIdx.x;
	int start;
	int end;
	int j;

	if(i == 0)
	{
		start = 0;
		end = opIndexes[i] - 1;
	}
	else
	{
		start = opIndexes[i - 1] + 1;
		end  = opIndexes[i] - 1;
	}

	Node* temp = (Node*)malloc(sizeof(Node));
	temp->op = op[i];
	temp->c1 = ' ';
	temp->c2 = ' ';
	temp->c3 = ' ';
	temp->c4 = ' ';
	temp->c5 = ' ';
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

//***Iterative Function****/

//Creates a node representing the operation at point i, and adds it to the nodes array at position i
//Uses a for loop to replicate the above thread independent methods
void normal_cuit(int totalPlusses, char* op, int* opIndexes, char* input, Node** nodes)
{
	int start;
	int end;
	int i;

	for (i = 0; i < totalPlusses; i++)
	{
		if(i == 0)
		{
			start = 0;
			end = opIndexes[i] - 1;
		}
		else
		{
			start = opIndexes[i - 1] + 1;
			end  = opIndexes[i] - 1;
		}

		Node* temp = (Node*)malloc(sizeof(Node));
		temp->op = op[i];
		temp->c1 = ' ';
		temp->c2 = ' ';
		temp->c3 = ' ';
		temp->c4 = ' ';
		temp->c5 = ' ';
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

//***Utility Methods**/

//Timing
struct timeval start, end;

void start_time()
{
	gettimeofday( &start, 0 );
}

double end_time()
{
	gettimeofday( &end, 0 );
	return (( end.tv_sec - start.tv_sec ) * 1000.0 + ( end.tv_usec - start.tv_usec ) / 1000.0);
}

//print nodes list
void print_nodes(Node** nodes, int totalNodes)
{
	for (int i = 0; i < totalNodes; i++)
	{
		printf("Operation: %c\n\tOperands: ", nodes[i]->op);

		//print only relavant children
		if (nodes[i]->c1 != ' ' && nodes[i]->c2 == ' ')
			printf("c1: %c\n", nodes[i]->c1);
		else if (nodes[i]->c1 != ' ' && nodes[i]->c2 != ' ' && nodes[i]->c3 == ' ')
			printf("c1: %c, c2: %c\n", nodes[i]->c1, nodes[i]->c2);
		else if (nodes[i]->c1 != ' ' && nodes[i]->c2 != ' ' && nodes[i]->c3 != ' ' && nodes[i]->c4 == ' ')
			printf("c1: %c, c2: %c, c3: %c\n", nodes[i]->c1, nodes[i]->c2, nodes[i]->c3);
		else if (nodes[i]->c1 != ' ' && nodes[i]->c2 != ' ' && nodes[i]->c3 != ' ' && nodes[i]->c4 != ' ' && nodes[i]->c5 == ' ')
			printf("c1: %c, c2: %c, c3: %c, c4: %c\n", nodes[i]->c1, nodes[i]->c2, nodes[i]->c3, nodes[i]->c4);
		else
			printf("c1: %c, c2: %c, c3: %c, c4: %c, c5: %c\n", nodes[i]->c1, nodes[i]->c2, nodes[i]->c3, nodes[i]->c4, nodes[i]->c5);
	}
}

//simulates the running of the gpu and iterative cuit methods n times, and calcuates the average elapsed
//takes all necessary arguments for the cuit methods plus
	//int n - number of iterations
	//int version - which cuit method to call (0 = all_shared, 1 = op_shared, 2 = input_shared, 3 = none_shared, 4 = normal)
void simulate(int n, int totalPlusses, char* op, int* opIndexes, char* input, Node** nodes, int version)
{
	int i = 0;
	double avg = 0.0;
	while(i < n)
	{
		start_time();

		if(version == 0)
			gpu_cuit_all_shared<<<BLOCKSIZE, totalPlusses>>>(totalPlusses, op, opIndexes, input, nodes);
		else if(version == 1)
			gpu_cuit_op_shared<<<BLOCKSIZE, totalPlusses>>>(totalPlusses, op, opIndexes, input, nodes);
		else if(version == 2)
			gpu_cuit_input_shared<<<BLOCKSIZE, totalPlusses>>>(totalPlusses, op, opIndexes, input, nodes);
		else if(version == 3)
			gpu_cuit_none_shared<<<BLOCKSIZE, totalPlusses>>>(totalPlusses, op, opIndexes, input, nodes);
		else if(version == 4)
			normal_cuit(totalPlusses, op, opIndexes, input, nodes);

		cudaDeviceSynchronize();
		avg += end_time();
		i++;
	}

	if (version == 0)
		printf("GPU -  all shared arrays: ");
	else if (version == 1)
		printf("    -    op shared array: ");
	else if (version == 2)
		printf("    - input shared array: ");
	else if (version == 3)
		printf("    -   no shared arrays: ");
	else if (version == 4)
		printf("\nSequential computation: ");

	avg = avg / n;
	printf("%lf\n", avg);
}

int main(int argc, char **argv)
{
	int c = 0;                   //getopt var
	int print = 0;               //if 1, print nodes
	char* input;                 //stores read in string
	cudaMallocManaged(&input, sizeof(char) * SIZE * 5 + SIZE);
	int i = 0;                  //loop variable
	int totalPlusses = 0;       //holds the position of the last element of the op array
	int* opIndexes;             //holds indexes / indices of operators of the input
	cudaMallocManaged(&opIndexes, sizeof(int) * SIZE);
	char* op;                   //holds operators of the input
	cudaMallocManaged(&op, sizeof(char) * SIZE);
	Node** nodes_gpu;
	cudaMallocManaged(&nodes_gpu, sizeof(Node*) * SIZE);
	Node** nodes_normal;
	cudaMallocManaged(&nodes_normal, sizeof(Node*) * SIZE);

	//allows for command line command to enable node list printing
	while ((c = getopt(argc, argv, "p")) != -1) {
			 if (c == 'p')
			 	print = 1;
			 else
			 {
					 printf("Sorry, you entered an invalid flag. Please try again.");
					 exit(0);
					 break;
			 }
	 }

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
		if(input[i] == '+' || input[i] == '*')
		{
			op[totalPlusses] = input[i];
			opIndexes[totalPlusses] = i;
			totalPlusses++;
		}
	}

	int n = 10000;

	printf("Average time (s) with %d iterations\n", n);
	//gpu timed tests
	//both arrays shared
	simulate(n, totalPlusses, op, opIndexes, input, nodes_gpu, 0);
	//op array shared
	simulate(n, totalPlusses, op, opIndexes, input, nodes_gpu, 1);
	//input array shared
	simulate(n, totalPlusses, op, opIndexes, input, nodes_gpu, 2);
	//no arrays shared
	simulate(n, totalPlusses, op, opIndexes, input, nodes_gpu, 3);

	//serial timed test
	simulate(n, totalPlusses, op, opIndexes, input, nodes_normal, 4);

	if (print)
		print_nodes(nodes_normal, totalPlusses);

	//free everything
	cudaFree(input);
	for (i = 0; i < totalPlusses; i++)
	{
		free(nodes_gpu[i]);
		free(nodes_normal[i]);
	}
	cudaFree(op);
	cudaFree(opIndexes);
	cudaFree(nodes_gpu);
	cudaFree(nodes_normal);

	exit(0);
}
