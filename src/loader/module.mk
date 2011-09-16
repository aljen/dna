SOURCES := stage1.S
SOURCES := $(addprefix loader/,$(SOURCES))

$(eval $(call add-plain-bin,stage1.bin,$(SOURCES)))

SOURCES := stage2.S
SOURCES := $(addprefix loader/,$(SOURCES))

$(eval $(call add-plain-bin,stage2.bin,$(SOURCES)))

$(eval $(call create-directories))

install-loader: create umount $(TARGETS)/tools/writebootloader \
  $(TARGETS)/loader/stage1.bin $(TARGETS)/loader/stage2.bin
	@echo "$(MSG_BOOTLOADER) $(DISKNAME) $(CRED)<- $(CNONE)stage{1,2}.bin"
	$(V)$(TARGETS)/tools/writebootloader $(DISKNAME) $(TARGETS)/loader/stage1.bin\
		$(TARGETS)/loader/stage2.bin 2> /dev/null

install: umount install-loader mount
