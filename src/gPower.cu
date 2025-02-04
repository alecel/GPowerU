// 2025 Istituto per le Applicazioni del Calcolo "Mauro Picone"
// alessandro.celestini@cnr.it

#include "gPower.h"

using namespace std;

// Max number of samples per device
#define SAMPLE_MAX_SIZE_DEFAULT 2000000
// Max number of sampled devices
#define MAX_DEVICES 8
// Sampling frequency in seconds
#define TIME_STEP 0.00001

// Flag variable used to end the sampling thread
int terminate_thread = 0;
// NVML handlers
nvmlDevice_t nvDevice[MAX_DEVICES];
// Arrays of sampling timestamp in us 
double thread_times[MAX_DEVICES][SAMPLE_MAX_SIZE_DEFAULT];
// Arrays of power sampling in milliwatts
double thread_powers[MAX_DEVICES][SAMPLE_MAX_SIZE_DEFAULT];
// Total number of samples
int n_values;

// Sampling thread handler
pthread_t thread_sampler;
// Number of devices to monitor
unsigned int device_count;
// Output directory
string glb_out_dir;
// Hostname of the computing node
string glb_node_name;
// File with the starting sample timestamp of each device 
string glb_file_starttime;



void *threadWork(void * arg) {
    unsigned int power[MAX_DEVICES];
    int i=0;
    bool not_enough=0;
    struct timeval tv_aux;
    struct timeval tv_start = *((struct timeval *) arg);
    nvmlReturn_t nvResult;

    printf("*** Start Sampling Thread ***\n");

    while (!terminate_thread) {
	for(int d=0; d < device_count; d++){		       
            nvResult = nvmlDeviceGetPowerUsage(nvDevice[d], &power[d]);
	    if (NVML_SUCCESS != nvResult) {
		printf("Failed to get power usage: %s [device %d]\n", nvmlErrorString(nvResult), d);
		if (nvResult == NVML_ERROR_UNINITIALIZED){
		    printf("NVML_ERROR_UNINITIALIZED: the library has not been successfully initialized\n");
		    pthread_exit(NULL);
		}
		if (nvResult == NVML_ERROR_INVALID_ARGUMENT){
		    printf("NVML_ERROR_INVALID_ARGUMENT: device is invalid or power is NULL\n");
		}
		if (nvResult == NVML_ERROR_NOT_SUPPORTED){
		    printf("NVML_ERROR_NOT_SUPPORTED: the device does not support power readings\n");
		}
		if (nvResult == NVML_ERROR_GPU_IS_LOST){
		    printf("NVML_ERROR_GPU_IS_LOST: the target GPU has fallen off the bus or is otherwise inaccessible\n");
		}
		if (nvResult == NVML_ERROR_UNKNOWN){
		    printf("NVML_ERROR_UNKNOWN on any unexpected error\n");
		}
		if ( i>0 ) {
		  // If a critical error DOES NOT occure we keep the last measure	
		  power[d] = thread_powers[d][i-1];
		}else{
		  power[d] = 0;
		}
	    }			
	    if(i < SAMPLE_MAX_SIZE_DEFAULT ) {
		gettimeofday(&tv_aux,NULL);
            	thread_powers[d][i] = power[d];			
		thread_times[d][i] = (tv_aux.tv_sec-tv_start.tv_sec)*1000000;
            	thread_times[d][i] += (tv_aux.tv_usec-tv_start.tv_usec);
		if(i==0) { 
		    printf("*** Start Power Sampling (device %d) ***\n",d);
		}
		if(i==0) { 
	            FILE *fp_starttime;
		    fp_starttime = fopen(glb_file_starttime.c_str(), "a");
		    fprintf(fp_starttime,"%d;%ld;%ld\n", d, tv_aux.tv_sec, tv_aux.tv_usec);
		    fclose(fp_starttime);
		}
	     }
	     else{
	        if(i == SAMPLE_MAX_SIZE_DEFAULT) {
		    printf("ERROR: POWER VECTOR SIZE EXCEEDED!\n");
		    pthread_exit(NULL);
		}
		if(!not_enough){
		    printf("NOT ENOUGH POWER!\n");
		    not_enough=1;
		}
	     }	
	}//endfor 
	i++;
	n_values = i;
	sleep(TIME_STEP);
    }//endwhile	
    printf("*** Stop Sampling Thread ***\n");
    pthread_exit(NULL);
}


float DataOutput() {
   float p_average;
   double interval;
   double tot_power;
   float power_peak=0;
   FILE  *fp2;
	
   for(int d=0; d < device_count; d++){
	string s = glb_out_dir+"/nvmlPowerProfile_"+std::to_string(d)+"_"+glb_node_name+".csv";
	fp2 = fopen(s.c_str(), "w+");
	fprintf(fp2,"Timestamp [s];Power measure [W]");

	for(int i=0; i<n_values; i++) {
            fprintf(fp2, "\n%.6f;%.4f", (thread_times[d][i]-thread_times[d][0])/1000000, thread_powers[d][i]/1000.0);	
            if (thread_powers[d][i] > power_peak){ 
        	power_peak = thread_powers[d][i];
	    }
	    tot_power += thread_powers[d][i];
	}
	fclose(fp2);
   }

   p_average = tot_power/(device_count*n_values);    
   interval = thread_times[0][n_values-1] - thread_times[0][0];

   printf("\tAverage Power: %.2f W;  Max Power: %.2f W;  Sampling Duration: %.2f s;  Samples number: %d\n", p_average/1000.0, power_peak/1000.0, (interval)/1000000, n_values);
   
   return 0;
}

int GPowerU_init(string out_dir, string node_name) {	
   struct timeval start_time;

   gettimeofday(&start_time,NULL);
   glb_out_dir = out_dir;
   glb_node_name = node_name;
   nvmlReturn_t nvResult;

   if ( mkdir(glb_out_dir.c_str(), 0777) < 0 && errno != EEXIST){
      printf("Unable to create the output directory named: %s", glb_out_dir);
      exit(-1); 
   }

   FILE *fp_starttime;
   glb_file_starttime = glb_out_dir + "/startTime_"+ glb_node_name +".time";
   fp_starttime = fopen(glb_file_starttime.c_str(), "w");
   fprintf(fp_starttime,"device;tv_sec;tv_usec\n");
   fclose(fp_starttime);
    
   terminate_thread = 0;
   nvResult = nvmlInit();
   if (NVML_SUCCESS != nvResult){
        printf("Failed to initialize NVML: %s\n", nvmlErrorString(nvResult));
        printf("Press ENTER to continue...\n");
        getchar();
        return -1;
   }
   nvResult = nvmlDeviceGetCount(&device_count);
   if (NVML_SUCCESS != nvResult){
        printf("Failed to query device count: %s\n", nvmlErrorString(nvResult));
        return -1;
   }
   printf("Found %d device%s\n\n", device_count, device_count != 1 ? "s" : "");
   if (device_count > MAX_DEVICES) {
        printf("Device_id is out of range.\n");
        return -1;
   }

   for(int d=0; d<device_count; d++){
     nvResult = nvmlDeviceGetHandleByIndex(d, &nvDevice[d]);
     if (NVML_SUCCESS != nvResult){
       printf("Failed to get handle for device %d: %s\n",d, nvmlErrorString(nvResult));
       return -1;
     }
   }
   int a = pthread_create(&thread_sampler, NULL, threadWork, &start_time);
   if(a) {
     fprintf(stderr,"Error - pthread_create() return code: %d\n",a);
     return -1;
   }

   return 0;
}


int GPowerU_end() {
   terminate_thread = 1;
   pthread_join(thread_sampler, NULL);
   DataOutput();
   return 0;
}
