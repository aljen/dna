ifneq ($(V), 1)
  override V := @
else
  override V :=
endif

VPATH = src

BUILD_REVISION := $(shell git rev-parse --short HEAD)
BUILD_DATE     := $(shell date +"%r, %D")
DISKNAME       := disk.vhd
DISKSIZE       ?= 256
DISKMOUNTPATH  := mnt

TARGET_AR      := x86_64-pc-hitomi-ar
TARGET_AS      := x86_64-pc-hitomi-as
TARGET_CC      := x86_64-pc-hitomi-gcc
TARGET_CPP     := $(TARGET_CC) -E
TARGET_CXX     := x86_64-pc-hitomi-g++
TARGET_LD      := x86_64-pc-hitomi-ld
TARGET_LIBGCC  := $(shell $(TARGET_CC) -print-libgcc-file-name)
TARGET_OBJCOPY := x86_64-pc-hitomi-objcopy
TARGET_OBJDUMP := x86_64-pc-hitomi-objdump
TARGET_NM      := x86_64-pc-hitomi-nm

HOST_AR      := $(AR)
HOST_AS      := $(AS)
HOST_CC      := $(CC)
HOST_CPP     := $(HOST_CC) -E
HOST_CXX     := $(CXX)
HOST_OBJCOPY := objcopy
HOST_OBJDUMP := objdump
HOST_NM      := nm

PYTHON  := python
TAR     := tar
INSTALL := install
YASM    := yasm

HOST_APPS      :=
TARGET_APPS    :=
TARGET_DRIVERS :=
TARGET_KERNEL  :=
TARGET_LOADER  :=
TARGET_SERVERS :=
TARGET_LIBS    :=

WARNINGS := -pedantic -Werror -Wall -Wextra -Wdouble-promotion
WARNINGS += -Wformat=2 -Wno-format-extra-args -Wuninitialized
WARNINGS += -Winit-self -Wmissing-include-dirs -Wswitch-default
WARNINGS += -Wswitch-enum -Wunused-but-set-parameter
WARNINGS += -Wunused-but-set-variable -Wunused-parameter -Wunused
WARNINGS += -Wsuggest-attribute=pure -Wsuggest-attribute=const
WARNINGS += -Wsuggest-attribute=noreturn -Wundef -Wshadow
WARNINGS += -Wunsafe-loop-optimizations -Wcast-qual -Wwrite-strings
WARNINGS += -Wconversion -Waddress -Wlogical-op -Waggregate-return
WARNINGS += -Wmissing-declarations -Wmissing-format-attribute
WARNINGS += -Wpacked -Wpadded -Wredundant-decls -Winline
WARNINGS += -Wpointer-arith -Wcast-align -Wredundant-decls

WARNINGS_CFLAGS   := $(WARNINGS) -Wno-format-zero-length
WARNINGS_CFLAGS   += -Wbad-function-cast -Wjump-misses-init -Wmissing-prototypes
WARNINGS_CFLAGS   += -Wnested-externs -Wstrict-prototypes
WARNINGS_CXXFLAGS := $(WARNINGS) -Wctor-dtor-privacy -Weffc++
WARNINGS_CXXFLAGS += -Woverloaded-virtual

TARGET_CFLAGS   := -pipe $(WARNINGS_CFLAGS) -std=gnu99
TARGET_CXXFLAGS := -pipe $(WARNINGS_CXXFLAGS) -std=gnu++0x -fno-exceptions
TARGET_CXXFLAGS += -fno-rtti
TARGET_LDFLAGS  :=

HOST_CFLAGS   := -pipe $(WARNINGS_CFLAGS) -std=gnu99
HOST_CXXFLAGS := -pipe $(WARNINGS_CXXFLAGS) -std=gnu++0x
HOST_LDFLAGS  :=

USE_COLORS := $(shell echo $(TERM))

ifneq ($(USE_COLORS),)
CBLACK  := \033[0;30m
CRED    := \033[0;31m
CGREEN  := \033[0;32m
CYELLOW := \033[0;33m
CBLUE   := \033[0;34m
CPURPLE := \033[0;35m
CCYAN   := \033[0;36m
CWHITE  := \033[0;37m
CNONE   := \033[0m
else
CBLACK  :=
CRED    :=
CGREEN  :=
CYELLOW :=
CBLUE   :=
CPURPLE :=
CCYAN   :=
CWHITE  :=
CNONE   :=
endif

MSG_BOOTLOADER := $(CWHITE)[$(CYELLOW)BOOTLOADER$(CWHITE)]$(CNONE)
MSG_DIR        := $(CWHITE)[       $(CYELLOW)DIR$(CWHITE)]$(CNONE)
MSG_INSTALL    := $(CWHITE)[   $(CGREEN)INSTALL$(CWHITE)]$(CNONE)
MSG_RM         := $(CWHITE)[        $(CRED)RM$(CWHITE)]$(CNONE)
MSG_CREATE     := $(CWHITE)[    $(CYELLOW)CREATE$(CWHITE)]$(CNONE)
MSG_MOUNT      := $(CWHITE)[     $(CYELLOW)MOUNT$(CWHITE)]$(CNONE)
MSG_UMOUNT     := $(CWHITE)[    $(CYELLOW)UMOUNT$(CWHITE)]$(CNONE)
MSG_HOST_AS    := $(CWHITE)[$(CBLUE)HOST    $(CCYAN)AS$(CWHITE)]$(CNONE)
MSG_HOST_CC    := $(CWHITE)[$(CBLUE)HOST    $(CGREEN)CC$(CWHITE)]$(CNONE)
MSG_HOST_CXX   := $(CWHITE)[$(CBLUE)HOST   $(CGREEN)CXX$(CWHITE)]$(CNONE)
MSG_HOST_LD    := $(CWHITE)[$(CBLUE)HOST    $(CRED)LD$(CWHITE)]$(CNONE)
MSG_TARGET_AS  := $(CWHITE)[$(CPURPLE)TARGET  $(CCYAN)AS$(CWHITE)]$(CNONE)
MSG_TARGET_CC  := $(CWHITE)[$(CPURPLE)TARGET  $(CGREEN)CC$(CWHITE)]$(CNONE)
MSG_TARGET_CXX := $(CWHITE)[$(CPURPLE)TARGET $(CGREEN)CXX$(CWHITE)]$(CNONE)
MSG_TARGET_LD  := $(CWHITE)[$(CPURPLE)TARGET  $(CRED)LD$(CWHITE)]$(CNONE)
MSG_DEPS_CC    := $(CWHITE)[$(CYELLOW)DEPS    $(CGREEN)CC$(CWHITE)]$(CNONE)
MSG_DEPS_CXX   := $(CWHITE)[$(CYELLOW)DEPS   $(CGREEN)CXX$(CWHITE)]$(CNONE)
MSG_YASM       := $(CWHITE)[$(CBLUE)      $(CCYAN)YASM$(CWHITE)]$(CNONE)

