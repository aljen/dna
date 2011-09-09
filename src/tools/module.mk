SOURCES := writebootloader.c
SOURCES := $(addprefix tools/,$(SOURCES))

$(eval $(call add-tool,writebootloader,$(SOURCES)))

SOURCES := vhd_info.cc
SOURCES := $(addprefix tools/,$(SOURCES))

$(eval $(call add-tool,vhd_info,$(SOURCES)))

$(eval $(call create-directories))

