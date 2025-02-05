# Monitoring the power consumption of NVIDIA GPUs with `powerMonitor`

`powerMonitor` is based on [GPowerU](https://github.com/crrossi/GPowerU), and it is meant to monitor the power consumption of NVIDIA GPUs and thus in turn of CUDA applications. We nailed it to our needs, but it is general enough to be adapted to any CUDA application. Moreover you can integrate it inside your application if you like, you need just to use the functions defined in `include/gPower.h` and implemented in `src/gPower.cu`, `powerMonitor` can be see as an example of usage of these functions.

## Building

```
make all
```
This creates the executable `powerMonitor` in the `bin` directory.

## Usage

`powerMonitor` takes a single argument, the name of the direcotry that will be used to store the output files.

```
Usage: ./bin/powerMonitor --output-dir <DIR_NAME> 

	-o, --output-dir <DIR>              Write power profile data files to <DIR_NAME>.
	                                    If <DIR_NAME> does not exist the program creates it
```

## Run

```
./bin/powerMonitor -o test_run
```

`powerMonitor` stops when it catch a SIGINT. When a SIGINT is sent to the tool it stops sampling and writes the output files, then it exits.

# Customization

`powerMonitor` offers a working solution to monitor all GPUs of a node, it runs independently of the applications you want to monitor. `powerMonitor` creates an output file for each device found on the node, each file is named using the following syntax `nvmlPowerProfile_DEVICENUMBER_HOSTNAME.csv`. The maximum number of monitored devices per node is 8, but you can change it by editing `src/gPower.cu` (MAX_DEVICES).

It is also possible to integrate the power monitoring in your code, so you do not need to run `powerMonitor`. You can use the functions defined in `include/gPower.h` and implemented in `src/gPower.cu`, `powerMonitor` can be see as an example of usage of these functions.






