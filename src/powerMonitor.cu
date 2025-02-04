// 2025 Istituto per le Applicazioni del Calcolo "Mauro Picone"
// alessandro.celestini@cnr.it

#include <iostream>
#include <math.h>
#include "nvml.h"
#include "gPower.h"
#include <unistd.h>
#include <stdio.h>
#include <signal.h>     
#include <getopt.h>

#define USAGE                                                                                                   \
    "Usage: %s --output-dir <DIR_NAME> \n\n"                                                                    \
    "\t-o, --output-dir <DIR>              Write power profile data files to <DIR_NAME>.\n"                     \
    "\t                                    If <DIR_NAME> does not exist the program creates it.\n "  



static void sigHandler(int signum){
    if (signum == SIGINT){
        fprintf( stderr, "SIGINT catched!\n" );
        fprintf( stderr, "Ready to exit!\n");
        if ( GPowerU_end() != 0 ){
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
 
  printf("### START Configuration\n"); 
  printf("\toutput directory: %s \n", out_dir);
  printf("\tnode name: %s \n", node_name);
  printf("### END Configuration\n"); 

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

