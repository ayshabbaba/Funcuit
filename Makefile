NVCC=/usr/local/cuda-9.1/bin/nvcc

trial: trial.cu
	${NVCC} -arch=sm_37 trial.cu -o trial
