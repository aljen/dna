ifneq ($(V), 1)
	override V		:= @
else
	override V		:=
endif

VPATH						= src

BUILD_REVISION	:= $(shell git rev-parse --short HEAD)
BUILD_DATE			:= $(shell date +"%r, %D")
DISKNAME				:= disk.vhd
DISKSIZE				?= 256
DISKMOUNTPATH		:= mnt

TARGET_AR				:= x86_64-pc-hitomi-ar
TARGET_AS				:= x86_64-pc-hitomi-as
TARGET_CC				:= x86_64-pc-hitomi-gcc
TARGET_CPP			:= $(TARGET_CC) -E
TARGET_CXX			:= x86_64-pc-hitomi-g++
TARGET_LD				:= x86_64-pc-hitomi-ld
TARGET_LIBGCC		:= $(shell $(TARGET_CC) -print-libgcc-file-name)
TARGET_OBJCOPY	:= x86_64-pc-hitomi-objcopy
TARGET_OBJDUMP	:= x86_64-pc-hitomi-objdump
TARGET_NM				:= x86_64-pc-hitomi-nm

HOST_AR					:= $(AR)
HOST_AS					:= $(AS)
HOST_CC					:= $(CC)
HOST_CPP				:= $(HOST_CC) -E
HOST_CXX				:= $(CXX)
HOST_OBJCOPY		:= objcopy
HOST_OBJDUMP		:= objdump
HOST_NM					:= nm

PYTHON					:= python
TAR							:= tar
INSTALL					:= install
YASM						:= yasm

HOST_APPS				:=
TARGET_APPS			:=
TARGET_DRIVERS	:=
TARGET_KERNEL		:=
TARGET_LOADER		:=
TARGET_SERVERS	:=
TARGET_LIBS			:=

WARNINGS_CFLAGS	:= -pedantic -Werror -Wall -Wextra -Wdouble-promotion
WARNINGS_CFLAGS	+= -Wformat=2 -Wno-format-extra-args -Wuninitialized
WARNINGS_CFLAGS	+= -Winit-self -Wmissing-include-dirs -Wswitch-default
WARNINGS_CFLAGS	+= -Wswitch-enum -Wunused-but-set-parameter
WARNINGS_CFLAGS	+= -Wunused-but-set-variable -Wunused-parameter -Wunused
WARNINGS_CFLAGS	+= -Wsuggest-attribute=pure -Wsuggest-attribute=const
WARNINGS_CFLAGS	+= -Wsuggest-attribute=noreturn -Wundef -Wshadow
WARNINGS_CFLAGS	+= -Wunsafe-loop-optimizations -Wcast-qual -Wwrite-strings
WARNINGS_CFLAGS	+= -Wconversion -Waddress -Wlogical-op -Waggregate-return
WARNINGS_CFLAGS	+= -Wmissing-declarations -Wmissing-format-attribute
WARNINGS_CFLAGS	+= -Wpacked -Wpadded -Wredundant-decls -Winline
WARNINGS_CFLAGS	+= -Wpointer-arith -Wcast-align -Wredundant-decls

WARNINGS_CC 		:= $(WARNINGS_CFLAGS) -Wno-format-zero-length
WARNINGS_CC			+= -Wbad-function-cast -Wjump-misses-init -Wmissing-prototypes
WARNINGS_CC			+= -Wnested-externs -Wstrict-prototypes
WARNINGS_CXX		:= $(WARNINGS_CFLAGS) -Wctor-dtor-privacy -Weffc++
WARNINGS_CXX		+= -Woverloaded-virtual

TARGET_CFLAGS		:= -pipe -std=gnu99 $(WARNINGS_CC)
TARGET_CXXFLAGS	:= -pipe -std=gnu++0x -fno-exceptions -fno-rtti $(WARNINGS_CXX)
TARGET_LDFLAGS	:=

HOST_CFLAGS			:= -pipe -std=gnu99 $(WARNINGS_CC)
HOST_CXXFLAGS		:= -pipe -std=gnu++0x $(WARNINGS_CXX)
HOST_LDFLAGS		:=

USE_COLORS			:= $(shell echo $(TERM))

ifneq ($(USE_COLORS),)
CBLACK					:= \033[0;30m
CRED						:= \033[0;31m
CGREEN					:= \033[0;32m
CYELLOW					:= \033[0;33m
CBLUE						:= \033[0;34m
CPURPLE					:= \033[0;35m
CCYAN						:= \033[0;36m
CWHITE					:= \033[0;37m
CNONE						:= \033[0m
else
CBLACK					:=
CRED						:=
CGREEN					:=
CYELLOW					:=
CBLUE						:=
CPURPLE					:=
CCYAN						:=
CWHITE					:=
CNONE						:=
endif

MSG_BOOTLOADER	:= $(CWHITE)[$(CYELLOW)BOOTLOADER$(CWHITE)]$(CNONE)
MSG_DIR					:= $(CWHITE)[       $(CYELLOW)DIR$(CWHITE)]$(CNONE)
MSG_INSTALL			:= $(CWHITE)[   $(CGREEN)INSTALL$(CWHITE)]$(CNONE)
MSG_RM					:= $(CWHITE)[        $(CRED)RM$(CWHITE)]$(CNONE)
MSG_CREATE			:= $(CWHITE)[    $(CYELLOW)CREATE$(CWHITE)]$(CNONE)
MSG_MOUNT				:= $(CWHITE)[     $(CYELLOW)MOUNT$(CWHITE)]$(CNONE)
MSG_UMOUNT			:= $(CWHITE)[    $(CYELLOW)UMOUNT$(CWHITE)]$(CNONE)
MSG_HOST_AS			:= $(CWHITE)[$(CBLUE)HOST    $(CCYAN)AS$(CWHITE)]$(CNONE)
MSG_HOST_CC			:= $(CWHITE)[$(CBLUE)HOST    $(CGREEN)CC$(CWHITE)]$(CNONE)
MSG_HOST_CXX		:= $(CWHITE)[$(CBLUE)HOST   $(CGREEN)CXX$(CWHITE)]$(CNONE)
MSG_HOST_LD			:= $(CWHITE)[$(CBLUE)HOST    $(CRED)LD$(CWHITE)]$(CNONE)
MSG_TARGET_AS		:= $(CWHITE)[$(CPURPLE)TARGET  $(CCYAN)AS$(CWHITE)]$(CNONE)
MSG_TARGET_CC		:= $(CWHITE)[$(CPURPLE)TARGET  $(CGREEN)CC$(CWHITE)]$(CNONE)
MSG_TARGET_CXX	:= $(CWHITE)[$(CPURPLE)TARGET $(CGREEN)CXX$(CWHITE)]$(CNONE)
MSG_TARGET_LD		:= $(CWHITE)[$(CPURPLE)TARGET  $(CRED)LD$(CWHITE)]$(CNONE)
MSG_DEPS_CC			:= $(CWHITE)[$(CYELLOW)DEPS    $(CGREEN)CC$(CWHITE)]$(CNONE)
MSG_DEPS_CXX		:= $(CWHITE)[$(CYELLOW)DEPS   $(CGREEN)CXX$(CWHITE)]$(CNONE)
MSG_YASM				:= $(CWHITE)[$(CBLUE)      $(CCYAN)YASM$(CWHITE)]$(CNONE)

