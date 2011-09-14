SOURCES := stage1.S
SOURCES := $(addprefix loader/,$(SOURCES))

$(eval $(call add-plain-bin,stage1.bin,$(SOURCES)))

SOURCES := stage2.S
SOURCES := $(addprefix loader/,$(SOURCES))

$(eval $(call add-plain-bin,stage2.bin,$(SOURCES)))

$(eval $(call create-directories))

install-loader: create umount $(BUILD)/tools/writebootloader \
$(BUILD)/loader/stage1.bin $(BUILD)/loader/stage2.bin
	@echo "$(MSG_BOOTLOADER) $(DISKNAME) $(CRED)<- $(CNONE)stage{1,2}.bin"
	$(V)$(BUILD)/tools/writebootloader $(DISKNAME) $(BUILD)/loader/stage1.bin \
		$(BUILD)/loader/stage2.bin 2> /dev/null

install: umount install-loader mount
