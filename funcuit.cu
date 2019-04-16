#include <sys/time.h>
#include <stdio.h>

long N = 64000000;  // Play with this value                                                                                                                                                                                        
int doPrint = 0; 

////////////////////////////////////////////////////////////////////////////////////////////////////////////
// GPU CODE
//
// Normal C function to square root values
void normal(float* a, long N)                                                                                                                                                                                     
{
  long i;                                                                                                                                                                                                                
  for (i = 0; i < N; ++i)                                                                                                                                                                                    
    a[i] = sqrt(a[i]);                                                                                                                                                                                           
}                 

// GPU function to square root values
__global__ void gpu_sqrt(float* a, long N) {
   long element = blockIdx.x*blockDim.x + threadIdx.x; // Each thread must get a different element
   if (element < N) a[element] = sqrt(a[element]);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                                                                                                                                                               

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



int main()                                                                                                                                                                                  
{
  float* a = (float*) malloc(N*sizeof(float));
  ///////////////////////////////////////////////
  // Test 1: Sequential For Loop
  init(a, N, "Normal");
  normal(a, N); 
  finish(a, N, "Normal"); 
  ///////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Test 2: GPU
  init(a, N, "GPU");

  // How many threads, how many cores?
  int numThreads = 1024; // This can vary, up to 1024
  long numCores = N / 1024 + 1;

  float* gpuA;

  cudaMalloc(&gpuA, N*sizeof(float)); // 1. Allocate enough memory on the GPU
  cudaMemcpy(gpuA, a, N*sizeof(float), cudaMemcpyHostToDevice); // 2. Copy original array from CPU to GPU
  gpu_sqrt<<<numCores, numThreads>>>(gpuA, N);  // 3. Each GPU thread square roots its value
  cudaMemcpy(a, gpuA, N*sizeof(float), cudaMemcpyDeviceToHost); // 4. Copy square rooted values from GPU to CPU
  cudaFree(&gpuA); // 5. Free the memory on the GPU


  finish(a, N, "GPU");
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  free(a);
  return 0;
}

