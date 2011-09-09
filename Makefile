# Hitomi build system
# Artur Wyszyński <artur.wyszynski@hitomi.pl>
# Recursive Make Considered Harmful (http://aegis.sourceforge.net/auug97.pdf)
# Managing Projects with GNU Make, 3rd Edition

TOP    = .
BUILD := build

include mk/env.mk
include mk/rules.mk

.PHONY: all
.PHONY: all-apps all-drivers all-kernel all-loader all-servers all-tools
.PHONY: clean distclean install help mount umount install_bootloader
.PHONY: print_objs_recipes

#.NOTPARALLEL: create mount umount

.DEFAULT_GOAL := all

all: create all-apps all-drivers all-kernel all-loader all-servers all-tools

clean:
	@echo "$(MSG_RM) $(BUILD)/"
	$(V)-$(RM) -rf $(BUILD)

# do not depend on umount, since it depends on create and on disk.vhd itself,
# so to do an umount & remove disk.vhd, we need to create it first, only to
# remove it after creation
distclean: clean
	@echo -n "$(MSG_UMOUNT) $(DISKNAME) $(CYELLOW)<- $(CNONE)$(DISKMOUNTPATH)/"
	$(V)$(PYTHON) scripts/vhd-umount.py $(DISKMOUNTPATH)
	@echo "$(MSG_RM) $(DISKNAME)"
	$(V)-$(RM) -rf $(DISKNAME)

install: umount install_bootloader mount
	@echo "$(MSG_INSTALL) $@"

create: $(DISKNAME)

mount: create
	@echo -n "$(MSG_MOUNT) $(DISKNAME) $(CYELLOW)-> $(CNONE)$(DISKMOUNTPATH)/"
	$(V)$(PYTHON) scripts/vhd-mount.py $(DISKNAME) $(DISKMOUNTPATH)

umount: create
	@echo -n "$(MSG_UMOUNT) $(DISKNAME) $(CYELLOW)<- $(CNONE)$(DISKMOUNTPATH)/"
	$(V)$(PYTHON) scripts/vhd-umount.py $(DISKMOUNTPATH)

install_bootloader: create umount $(BUILD)/tools/writebootloader \
$(BUILD)/loader/stage1.bin $(BUILD)/loader/stage2.bin
	@echo "$(MSG_BOOTLOADER) $(DISKNAME) $(CRED)<- $(CNONE)stage{1,2}.bin"
	$(V)$(BUILD)/tools/writebootloader $(DISKNAME) $(BUILD)/loader/stage1.bin \
		$(BUILD)/loader/stage2.bin 2> /dev/null

include src/module.mk

all-apps: $(TARGET_APPS)
all-drivers: $(TARGET_DRIVERS)
all-kernel: $(TARGET_KERNEL)
all-loader: $(TARGET_LOADER)
all-servers: $(TARGET_SERVERS)
all-tools: $(HOST_APPS)

-include $(DEPENDENCIES)

