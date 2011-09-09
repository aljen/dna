modules := apps drivers kernel loader servers tools
modules := $(addprefix src/, $(modules))
modules := $(addsuffix /module.mk, $(modules))

include $(modules)

