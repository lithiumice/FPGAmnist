# Copyright (C) 2013-2018 Altera Corporation, San Jose, California, USA. All rights reserved.
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to
# whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# This agreement shall be governed in all respects by the laws of the State of California and
# by the laws of the United States of America.
# This is a GNU Makefile.

# You must configure INTELFPGAOCLSDKROOT to point the root directory of the Intel(R) FPGA SDK for OpenCL(TM)
# software installation.
# See http://www.altera.com/literature/hb/opencl-sdk/aocl_getting_started.pdf
# for more information on installing and configuring the Intel(R) FPGA SDK for OpenCL(TM).

ifeq ($(VERBOSE),1)
ECHO :=
else
ECHO := @
endif

# Where is the Intel(R) FPGA SDK for OpenCL(TM) software?
ifeq ($(wildcard $(INTELFPGAOCLSDKROOT)),)
$(error Set INTELFPGAOCLSDKROOT to the root directory of the Intel(R) FPGA SDK for OpenCL(TM) software installation)
endif
ifeq ($(wildcard $(INTELFPGAOCLSDKROOT)/host/include/CL/opencl.h),)
$(error Set INTELFPGAOCLSDKROOT to the root directory of the Intel(R) FPGA SDK for OpenCL(TM) software installation.)
endif

# OpenCL compile and link flags.
AOCL_COMPILE_CONFIG := $(shell aocl compile-config --arm)
#AOCL_LINK_CONFIG := $(shell aocl link-config --arm)
AOCL_LINK_CONFIG := $(wildcard $(INTELFPGAOCLSDKROOT)/host/arm32/lib/*.so) $(wildcard $(AOCL_BOARD_PACKAGE_ROOT)/arm32/lib/*.so)

# Compilation flags
ifeq ($(DEBUG),1)
CXXFLAGS += -g
else
CXXFLAGS += -O2
endif

CXXFLAGS += -std=c99

# Compiler. ARM cross-compiler.
CXX := arm-linux-gnueabihf-g++

# Target
TARGET := mnist_host
TARGET_DIR := bin

# Directories
INC_DIRS := ./host/src/nnom/inc
# INC_DIRS := ../common/inc
LIB_DIRS :=

# Files
INCS := $(wildcard )
SRCS := $(wildcard host/src/*.cpp )
SRCS := $(wildcard host/src/nnom/src/core/*.c host/src/nnom/src/layers/*.c host/src/nnom/src/backends/*.c)
# SRCS := $(wildcard host/src/*.cpp ../common/src/AOCLUtils/*.cpp)
LIBS := rt pthread

SRCS_C = $(wildcard host/src/nnom/src/core/*.c host/src/nnom/src/layers/*.c host/src/nnom/src/backends/*.c)

# Make it all!
# all : $(TARGET_DIR)/$(TARGET)

# # Host executable target.
# $(TARGET_DIR)/$(TARGET) : Makefile $(SRCS) $(INCS) $(TARGET_DIR) 
# 	$(ECHO)$(CXX) $(CPPFLAGS) $(CXXFLAGS) -fPIC $(foreach D,$(INC_DIRS),-I$D) \
# 			$(AOCL_COMPILE_CONFIG) $(SRCS) $(AOCL_LINK_CONFIG) \
# 			$(foreach D,$(LIB_DIRS),-L$D) \
# 			$(foreach L,$(LIBS),-l$L) \
# 			-o $(TARGET_DIR)/$(TARGET)

# all :
# 	arm-linux-gnueabihf-gcc -std=c99 -fPIC $(foreach D,$(INC_DIRS),-I$D) -DARM $(SRCS_C) -DLINUX $(AOCL_COMPILE_CONFIG) $(AOCL_LINK_CONFIG) -lrt 
# 	arm-linux-gnueabihf-g++ -fPIC $(foreach D,$(INC_DIRS),-I$D) -DARM host/src/main.cpp -o $(TARGET) -DLINUX $(AOCL_COMPILE_CONFIG) $(AOCL_LINK_CONFIG) -lrt 

C++FILES = $(wildcard host/src/*.cpp)
CFILES = $(wildcard host/src/nnom/src/core/*.c host/src/nnom/src/layers/*.c host/src/nnom/src/backends/*.c)
OBJFILE = $(CFILES:.c=.o) $(C++FILES:.cpp=.o)
 
all:$(TARGET)
 
$(TARGET): $(OBJFILE)
# $(LINK) $^ $(LIBS) -Wall -fPIC -shared -o $@
	arm-linux-gnueabihf-g++ $^ -Wall -fPIC -shared -o $@
# arm-linux-gnueabihf-g++ $^ $(LIBS) -Wall -fPIC -shared $(AOCL_COMPILE_CONFIG) $(AOCL_LINK_CONFIG) -lrt -o $@
 
%.o:%.c
	arm-linux-gnueabihf-gcc -fPIC -std=c99 $(foreach D,$(INC_DIRS),-I$D) -o $@ -c $<
# $(CC) -o $@ $(CCFLAGS) $< $(INCLUDES)
 
%.o:%.cpp
	arm-linux-gnueabihf-g++ -fPIC $(foreach D,$(INC_DIRS),-I$D) -o $@ -c $<
# arm-linux-gnueabihf-g++ -fPIC $(foreach D,$(INC_DIRS),-I$D) -DARM -o $@ -c $< -DLINUX $(AOCL_COMPILE_CONFIG) $(AOCL_LINK_CONFIG) -lrt 
# $(C++) -o $@ $(C++FLAGS) $< $(INCLUDES)
 
# clean :
# 	$(ECHO)rm -f $(TARGET_DIR)/$(TARGET)
clean:
	rm -rf $(TARGET)
	rm -rf $(OBJFILE)
# .PHONY : all clean
