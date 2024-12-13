// 2023 INFN APE Lab - Sezione di Roma
// cristian.rossi@roma1.infn.it
// 2024 Istituto per le Applicazioni del Calcolo "Mauro Picone"
// alessandro.celestini@cnr.it


#ifndef _GPOWERU_H_
#define _GPOWERU_H_

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

//#define SAMPLE_MAX_SIZE_DEFAULT 1000000
#define SAMPLE_MAX_SIZE_DEFAULT 2000000
#define MAX_CHECKPOINTS 64
#define MAX_DEVICES 16

#define ROOT_ENABLED 0
#define MULTIGPU_DISABLED 0
#define TIME_STEP 0.00001  //Interval for sampling (in s)
#define POWER_THRESHOLD 0 



/*+++++++++++++++++++++++++++++++++++++++++++++++++++
 *              POWER_MEASURE FUNCTIONALITY         +
 *++++++++++++++++++++++++++++++++++++++++++++++++++*/

void *threadWork(void*); //CPU thread managing the parallel power data taking during the kernel execution

float DataOutput(); //Generate the output samples files
int GPowerU_init(string out_dir, string node_name); //Initializations ==> enable the NVML library, starts CPU thread for the power monitoring
int GPowerU_end(); //Ends power monitoring, returns data output files


/*+++++++++++++++++++++++++++++++++++++++++++++++++++
 *              POWER_MEASURE GLOBAL VARIABLES       +
 *++++++++++++++++++++++++++++++++++++++++++++++++++*/

int terminate_thread = 0; //END PROGRAM

nvmlDevice_t nvDevice[MAX_DEVICES];
nvmlReturn_t nvResult;

//Time sampling arrays for the power monitoring curve (thread_times) and kernel checkpoints (device_times)
double thread_times[MAX_DEVICES][SAMPLE_MAX_SIZE_DEFAULT];
double device_times[SAMPLE_MAX_SIZE_DEFAULT];

//Power sampling arrays for the power monitoring curve (powers) and kernel checkpoints (powerz)
double thread_powers[MAX_DEVICES][SAMPLE_MAX_SIZE_DEFAULT];
double device_powers[SAMPLE_MAX_SIZE_DEFAULT];


int n_values; //Total number of data taken
int deviceID; //Device id
int threshold;     // Threshold value in W indicating the power ranges when GPU is active (above threshold)


struct timeval start_time; //Time for synchronizing threadWork() and checkpoint()

pthread_t thread_sampler; //Thread managing the continuos power data taking


unsigned int core_clock, mem_clock;

float power_peak; //Maximum power value measured

unsigned int device_count;

string glb_out_dir;
string glb_node_name;
string glb_file_starttime;

#endif
