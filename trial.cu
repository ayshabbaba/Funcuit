#include <stdio.h>
#include <string.h>
int main() //a is the array, N is the size of the array
{
	// create int array to store indeces of '+'
	int op[100][100];
	
	//read in String from file

	FILE* file = fopen("data.txt","r");
	if(file == NULL)
	{
		printf("Could not open %s  make sure your file is valid.\n","data.txt");
		exit(0);
	}


	char input[500];
	fgets(input, 100, file);

	printf("%s",input);
	//loop through String and populate indeces array
	int i = 0;
	int index = 0;

	char output[500];
	output[0] = '*';
	int j = 1;
	for(i = 0; i < strlen(input);i++)
	{
		if(input[i] == '+')
		{
			op[index] = i;
			index++;
			printf("Found a + at %d\n",i);
			output
			[j] = input[i];

		}

	}
	//send to gpu child
	//loop through indexes array
	//if i = 0, send 0 - i-1
	//else send indexes[i]+1 to indexes[i+1]-1
	//send OR

	exit(0);
}
