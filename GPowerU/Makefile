
CPPFLAGS = -D_REENTRANT=1 -D_XOPEN_SOURCE=600 -I ./include
CC = gcc
CXX = g++
NVCC	:= nvcc
NVCCFLAGS :=  -ccbin $(CXX) -m64 --ptxas-options=-v  -maxrregcount=255 
LIBS = -lcuda -lcublas -lcudart -lnvidia-ml -lpthread -std=c++11 
CFLAGS = -O2
SMVERSIONFLAGS = -gencode arch=compute_80,code=sm_80

CUSRCS = iacPowmeas.cu
APPS= iacPowmeas

DEPS := $(patsubst %,%.d,$(basename $(CUSRCS)))
BINS= $(CSRCS:%.c=%) $(CUSRCS:%.cu=%)

all: $(APPS)

iacPowmeas.o: iacPowmeas.cu iacPowmeas.d 
	$(NVCC) $(NVCCFLAGS) $(ROOTFLAGS) $(CPPFLAGS)  $(SMVERSIONFLAGS) -c $@  $< $(LIBS)

iacPowmeas: iacPowmeas.o
	$(NVCC) $(NVCCFLAGS) $(ROOTFLAGS) $(CPPFLAGS)  $(SMVERSIONFLAGS) -o $@  $< $(LIBS)

clean:
	rm -f *.d *.o $(APPS) $(BINS)
	rm data -r 

.PHONY: iacPowmeas, clean, all
iacPowmeas.d: $(CUSRCS)
	@if [ ! -z "$(CUSRCS)" ]; then ( $(NVCC) $(CPPFLAGS) -M $(CUSRCS) > $@ ); fi

%.o: %.cu %.d
	$(NVCC) $(NVCCFLAGS) $(CPPFLAGS) $(SMVERSIONFLAGS) -o $@ -c $<

-include $(DEPS)
