#include <stdio.h>
#include <string.h>

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


//GPU Function
void gpu_cuit(int start, int end, int index, char* input) //end is exclusive
{
	char* c = (char*) malloc(5);
	strncpy(c, input+start, end-start+1);

printf("%d, end %d, index %d, c %s\n", start, end, index, c);
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

int main() //a is the array, N is the size of the array
{
	long N = 1024;
		
	//read in String from file

	FILE* file = fopen("data.txt","r");
	if(file == NULL)
	{
		printf("Could not open %s  make sure your file is valid.\n","data.txt");
		exit(0);
	}

	char input[500];
	int op[100];

	fgets(input, 100, file);

	printf("%s",input);
	//loop through String and populate indeces array
	int i = 0;
	int index = 0;

	char output[500];
	int j = 0;

	int start = 0;
	int end = 0;

	for(i = 0; i < strlen(input);i++)
	{
		if(input[i] == '+')
		{
			op[index] = i;
			index++;
			printf("Found a + at %d\n",i);
			output[j] = input[i];

		}

	}


	// Test: GPU


  // How many threads, how many cores?
  int numThreads = 1024; // This can vary, up to 1024
  long numCores = N / 1024 + 1;

int count = 0;
	for(i = 0; i <= index - 1;i++)
	{
		if(i == 0)
		{
			gpu_cuit(0, op[i] - 1, count, input);
		}else
		{
			gpu_cuit(op[i-1] + 1, op[i] - 1, count, input);
		}
		count++;	
	}


  

	exit(0);
}

