SOURCES := stage1.S
SOURCES := $(addprefix loader/,$(SOURCES))

$(eval $(call add-plain-bin,stage1.bin,$(SOURCES)))

SOURCES := stage2.S
SOURCES := $(addprefix loader/,$(SOURCES))

$(eval $(call add-plain-bin,stage2.bin,$(SOURCES)))

$(eval $(call create-directories))

