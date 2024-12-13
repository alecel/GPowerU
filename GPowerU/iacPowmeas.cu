#include <iostream>
#include <math.h>
#include "nvml.h"
#include "helper_cuda.h"
#include "GPowerU.hpp"
#include <unistd.h>
#include <stdio.h>
#include <signal.h>     


static void sigHandler(int signum){
    if (signum == SIGINT){
        fprintf ( stderr, "SIGINT catched!\n" );
        printf("Ready to exit!\n");
        if ( GPowerU_end(5) != 0 ){
            fprintf ( stderr, " error: terminating...\n" );
            _exit (1);
        }
        printf("Done!\n");
        _exit (0);
    }
}
 

int main( int argc, char** argv){

    //Initializations ==> enable the NVML library, starts CPU thread for the power monitoring,  
    if ( GPowerU_init() != 0 ) {
        fprintf ( stderr, "%s: error: initializing...\n", argv[0] );
        _exit (1);
     }

    if (signal(SIGINT, sigHandler) == SIG_ERR){
        printf("Error, cannot handle SIGINT\n");
    }

    printf("Start FOR\n");
    for(;;){
       sleep(30);
    }
    fprintf( stderr, "ERROR: End FOR!!!\n");

    return 0;
}

