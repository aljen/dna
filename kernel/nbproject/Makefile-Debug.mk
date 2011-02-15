#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Environment
MKDIR=mkdir
CP=cp
GREP=grep
NM=nm
CCADMIN=CCadmin
RANLIB=ranlib
CC=i586-elf-gcc.exe
CCC=i586-elf-g++.exe
CXX=i586-elf-g++.exe
FC=
AS=yasm.exe

# Macros
CND_PLATFORM=CrossTools-Windows
CND_CONF=Debug
CND_DISTDIR=dist

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=build/${CND_CONF}/${CND_PLATFORM}

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/string.o \
	${OBJECTDIR}/serial.o \
	${OBJECTDIR}/keyboard.o \
	${OBJECTDIR}/timer.o \
	${OBJECTDIR}/boot.o \
	${OBJECTDIR}/gdt.o \
	${OBJECTDIR}/pic.o \
	${OBJECTDIR}/console.o \
	${OBJECTDIR}/idt.o \
	${OBJECTDIR}/isr.o \
	${OBJECTDIR}/utils.o \
	${OBJECTDIR}/irqs.o \
	${OBJECTDIR}/kmain.o \
	${OBJECTDIR}/irq.o \
	${OBJECTDIR}/interrupts.o \
	${OBJECTDIR}/cpp_support.o


# C Compiler Flags
CFLAGS=-Wall -Wextra -Werror -nostdlib -nostartfiles -nodefaultlibs -fno-builtin -std=c99

# CC Compiler Flags
CCFLAGS=-Wall -Wextra -Werror -nostdlib -nostartfiles -nodefaultlibs -fno-builtin -fno-exceptions -fno-rtti -fno-stack-protector
CXXFLAGS=-Wall -Wextra -Werror -nostdlib -nostartfiles -nodefaultlibs -fno-builtin -fno-exceptions -fno-rtti -fno-stack-protector

# Fortran Compiler Flags
FFLAGS=

# Assembler Flags
ASFLAGS=-f elf

# Link Libraries and Options
LDLIBSOPTIONS=-L../crosstools/lib/gcc/i586-elf/4.5.2 -lgcc

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-Debug.mk dist/Debug/CrossTools-Windows/kernel.exe

dist/Debug/CrossTools-Windows/kernel.exe: ${OBJECTFILES}
	${MKDIR} -p dist/Debug/CrossTools-Windows
	i586-elf-ld.exe -T ../ldscripts/kernel.ld -o ${CND_DISTDIR}/${CND_CONF}/${CND_PLATFORM}/kernel ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/string.o: string.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/string.o string.c

${OBJECTDIR}/serial.o: serial.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/serial.o serial.c

${OBJECTDIR}/keyboard.o: keyboard.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/keyboard.o keyboard.c

${OBJECTDIR}/timer.o: timer.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/timer.o timer.c

${OBJECTDIR}/boot.o: boot.S 
	${MKDIR} -p ${OBJECTDIR}
	$(AS) $(ASFLAGS) -o ${OBJECTDIR}/boot.o boot.S

${OBJECTDIR}/gdt.o: gdt.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/gdt.o gdt.c

${OBJECTDIR}/pic.o: pic.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/pic.o pic.c

${OBJECTDIR}/console.o: console.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/console.o console.c

${OBJECTDIR}/idt.o: idt.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/idt.o idt.c

${OBJECTDIR}/isr.o: isr.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/isr.o isr.c

${OBJECTDIR}/utils.o: utils.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/utils.o utils.c

${OBJECTDIR}/irqs.o: irqs.S 
	${MKDIR} -p ${OBJECTDIR}
	$(AS) $(ASFLAGS) -o ${OBJECTDIR}/irqs.o irqs.S

${OBJECTDIR}/kmain.o: kmain.cc 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/kmain.o kmain.cc

${OBJECTDIR}/irq.o: irq.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/irq.o irq.c

${OBJECTDIR}/interrupts.o: interrupts.S 
	${MKDIR} -p ${OBJECTDIR}
	$(AS) $(ASFLAGS) -o ${OBJECTDIR}/interrupts.o interrupts.S

${OBJECTDIR}/cpp_support.o: cpp_support.c 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.c) -g -I../include/kernel -I../include/posix -I../include/utils -MMD -MP -MF $@.d -o ${OBJECTDIR}/cpp_support.o cpp_support.c

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/Debug
	${RM} dist/Debug/CrossTools-Windows/kernel.exe

# Subprojects
.clean-subprojects:

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc
