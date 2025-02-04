
SDIR=src
ODIR=obj
IDIR=include
BDIR=bin

NVCC=nvcc
CFLAGS= -I$(IDIR) -gencode arch=compute_80,code=sm_80
LDFLAGS=-lcuda -lnvidia-ml -lpthread -std=c++11
#LDFLAGS=-lcuda -lcublas -lcudart -lnvidia-ml -lpthread -std=c++11

MKDIR_P=mkdir -p

.PHONY: all clean

vpath %.cu $(SDIR)

# Create Directories
createDir:
	${MKDIR_P} ${ODIR}
	${MKDIR_P} ${BDIR}

# Compile C files
$(ODIR)/%.o : %.cu
	$(NVCC) $(CFLAGS) -o $@ -c $< 

TARGET=createDir $(BDIR)/powerMonitor

all: $(TARGET)

$(BDIR)/powerMonitor: $(ODIR)/powerMonitor.o $(ODIR)/gPower.o
	$(NVCC) $(LDFLAGS) -o $@ $^

# Clean files
clean:
	rm $(ODIR)/*
	rm $(BDIR)/*
