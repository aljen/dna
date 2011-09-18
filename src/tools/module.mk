MODULE_NAME := write_bootloader
MODULE_TYPE := application
MODULE_SOURCES := writebootloader.c
MODULE_SOURCES := $(addprefix tools/,$(MODULE_SOURCES))
MODULE_CFLAGS := $(WARNINGS_CFLAGS) -Werror
MODULE_CXXFLAGS := $(WARNINGS_CXXFLAGS) -Werror
$(eval $(call add-host-module))

MODULE_NAME := vhd_info
MODULE_TYPE := application
MODULE_SOURCES := vhd_info.cc
MODULE_SOURCES := $(addprefix tools/,$(MODULE_SOURCES))
MODULE_CFLAGS := $(WARNINGS_CFLAGS) -Werror
MODULE_CXXFLAGS := $(WARNINGS_CXXFLAGS) -Werror
$(eval $(call add-host-module))

