// 2024 Istituto per le Applicazioni del Calcolo "Mauro Picone"
// alessandro.celestini@cnr.it


#ifndef GPUPOWERLIB_H_
#define GPUPOWERLIB_H_

#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>
#include <nvml.h>
#include <stdlib.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <time.h>
#include <sys/time.h>
#include <sys/stat.h>
#include <string>
#include <cuda.h>

using namespace std;

void *threadWork(void*);

float DataOutput();

int GPowerU_init(string out_dir, string node_name);

int GPowerU_end();

#endif
