
CPPFLAGS = -D_REENTRANT=1 -D_XOPEN_SOURCE=600 -I ./include
CC = gcc
CXX = g++
NVCC	:= nvcc
NVCCFLAGS :=  -ccbin $(CXX) -m64 --ptxas-options=-v  -maxrregcount=255 
#ROOTFLAGS := -I/usr/include/root -L/usr/lib64/root -lCore -lImt -lRIO -lNet -lHist -lGraf -lGraf3d -lGpad -lROOTVecOps -lTree -lTreePlayer -lRint -lPostscript -lMatrix -lPhysics -lMathCore -lThread -lMultiProc -lROOTDataFrame -lm -ldl

LIBS = -lcuda -lcublas -lcudart -lnvidia-ml -lpthread -std=c++11 

CFLAGS = -O2
SMVERSIONFLAGS = -gencode arch=compute_80,code=sm_80

#CUSRCS = powmeas.cu
#APPS= powmeas
CUSRCS = iacPowmeas.cu
APPS= iacPowmeas

DEPS := $(patsubst %,%.d,$(basename $(CUSRCS)))

BINS= $(CSRCS:%.c=%) $(CUSRCS:%.cu=%)

all: $(APPS)


#powmeas.o: powmeas.cu powmeas.d 
#	$(NVCC) $(NVCCFLAGS) $(ROOTFLAGS) $(CPPFLAGS)  $(SMVERSIONFLAGS) -c $@  $< $(LIBS)

#powmeas: powmeas.o
#	$(NVCC) $(NVCCFLAGS) $(ROOTFLAGS) $(CPPFLAGS)  $(SMVERSIONFLAGS) -o $@  $< $(LIBS)


iacPowmeas.o: iacPowmeas.cu iacPowmeas.d 
	$(NVCC) $(NVCCFLAGS) $(ROOTFLAGS) $(CPPFLAGS)  $(SMVERSIONFLAGS) -c $@  $< $(LIBS)

iacPowmeas: iacPowmeas.o
	$(NVCC) $(NVCCFLAGS) $(ROOTFLAGS) $(CPPFLAGS)  $(SMVERSIONFLAGS) -o $@  $< $(LIBS)


#.PHONY: clean
clean:
	rm -f *.d *.o $(APPS) $(BINS)
	rm data -r 

#.PHONY: powmeas, clean, all
.PHONY: iacPowmeas, clean, all
#powmeas.d: $(CUSRCS)
#	@if [ ! -z "$(CUSRCS)" ]; then ( $(NVCC) $(CPPFLAGS) -M $(CUSRCS) > $@ ); fi
iacPowmeas.d: $(CUSRCS)
	@if [ ! -z "$(CUSRCS)" ]; then ( $(NVCC) $(CPPFLAGS) -M $(CUSRCS) > $@ ); fi

%.o: %.cu %.d
	$(NVCC) $(NVCCFLAGS) $(CPPFLAGS) $(SMVERSIONFLAGS) -o $@ -c $<

-include $(DEPS)
