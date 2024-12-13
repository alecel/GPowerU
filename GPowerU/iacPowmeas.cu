#include <iostream>
#include <math.h>
#include "nvml.h"
#include "helper_cuda.h"
#include "GPowerU.hpp"
#include <unistd.h>
#include <stdio.h>
#include <signal.h>     
#include <getopt.h>

#define USAGE                                                                                          \
    "Usage: %s --output-dir <DIR_NAME> \n\n"                                                           \
    "\t-o, --output-dir <DIR>              Write power profile data files to <DIR_NAME>.\n\n"



static void sigHandler(int signum){
    if (signum == SIGINT){
        fprintf( stderr, "SIGINT catched!\n" );
        fprintf( stderr, "Ready to exit!\n");
        if ( GPowerU_end(5) != 0 ){
            fprintf ( stderr, " error: terminating...\n" );
            _exit (1);
        }
        printf("Done!\n");
        _exit (0);
    }
}
 

int main( int argc, char** argv){
   
  char node_name[256];	
  char *out_dir=NULL;
  int opt;	
  static struct option long_options[] = {
        { "output-dir", required_argument, NULL, 'o' }
  };

  while ((opt = getopt_long(argc, argv, "o:h", long_options, NULL)) != -1) {
    switch (opt) {
     case 'o':
       out_dir = strdup(optarg);
       break;
     case 'h':
     default:
       printf(USAGE, argv[0]);
       exit(EXIT_FAILURE);
    }
  }
  
  if ( out_dir == NULL){
    printf(USAGE, argv[0]);
    exit(EXIT_FAILURE);
  }

  memset(node_name, 0, 256);
  gethostname(node_name, 256);
  
  printf("out_dir: %s --- node_name: %s \n", out_dir, node_name);

  //Initializations ==> enable the NVML library, starts CPU thread for the power monitoring,  
  if ( GPowerU_init(out_dir, node_name) != 0 ) {
    fprintf ( stderr, "%s: error: initializing...\n", argv[0] );
    _exit (1);
  }

  if (signal(SIGINT, sigHandler) == SIG_ERR){
    printf("Error, cannot handle SIGINT\n");
  }

  for(;;){
    sleep(30);
  }

  return 0;
}

