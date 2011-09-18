MODULE_NAME := stage1.bin
MODULE_SOURCES := stage1.S
MODULE_SOURCES := $(addprefix loader/,$(MODULE_SOURCES))
$(eval $(call add-binary-module))

MODULE_NAME := stage2.bin
MODULE_SOURCES := stage2.S
MODULE_SOURCES := $(addprefix loader/,$(MODULE_SOURCES))
$(eval $(call add-binary-module))

MODULE_NAME := bootstrap.bin
MODULE_SOURCES := bootstrap.S
MODULE_SOURCES := $(addprefix loader/,$(MODULE_SOURCES))
$(eval $(call add-binary-module))

MODULE_NAME := loader
MODULE_TYPE := loader
MODULE_DFLAGS := $(WARNINGS_DFLAGS) -Werror
MODULE_SOURCES := boot.S main.d
MODULE_SOURCES := $(addprefix loader/,$(MODULE_SOURCES))
MODULE_DEPS := bootstrap.bin
$(eval $(call add-target-module))

install-loader: create umount write_bootloader stage1.bin stage2.bin
	@echo "$(MSG_BOOTLOADER) $(DISKNAME) $(CRED)<- $(CNONE)stage{1,2}.bin"
	$(V)$(MODULE_write_bootloader) $(DISKNAME) $(MODULE_stage1.bin) \
		$(MODULE_stage2.bin) 2> /dev/null

