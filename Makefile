# Hitomi build system
# Artur Wyszyński <artur.wyszynski@hitomi.pl>

TOP			= .
OBJDIR		:= build

include mk/env.mk
include mk/rules.mk

.PHONY: all clean distclean rebuild install help mount umount install_bootloader \
		print_objs_recipes

.NOTPARALLEL: create mount umount

.DEFAULT_GOAL := all

all: create

clean:
		@echo "$(MSG_RM) $(OBJDIR)/"
		$(VERBOSE)-$(RM) -rf $(OBJDIR)

# do not depend on umount, since it depends on create and on disk.vhd itself,
# so to do an umount & remove disk.vhd, we need to create it first, only to
# remove it after creation
distclean: clean
		@echo -n "$(MSG_UMOUNT) $(DISKNAME) $(CYELLOW)<- $(CNONE)$(DISKMOUNTPATH)/"
		$(VERBOSE)$(PYTHON) scripts/vhd-umount.py $(DISKMOUNTPATH)
		@echo "$(MSG_RM) $(DISKNAME)"
		$(VERBOSE)-$(RM) -rf $(DISKNAME)

rebuild: clean all

install: umount install_bootloader mount
		@echo "$(MSG_INSTALL) $@"

help:
		@echo "\t$(CCYAN)Hitomi$(CNONE) build system (revision $(CPURPLE)$(BUILD_REVISION)$(CNONE))"
		@echo "$(CYELLOW)make create		$(CNONE)- Create virtual disk image"
		@echo "$(CYELLOW)make mount		$(CNONE)- Mount virtual disk image"
		@echo "$(CYELLOW)make umount		$(CNONE)- Umount virtual disk image"

create: $(DISKNAME)

mount: create
		@echo -n "$(MSG_MOUNT) $(DISKNAME) $(CYELLOW)-> $(CNONE)$(DISKMOUNTPATH)/"
		$(VERBOSE)$(PYTHON) scripts/vhd-mount.py $(DISKNAME) $(DISKMOUNTPATH)

umount: create
		@echo -n "$(MSG_UMOUNT) $(DISKNAME) $(CYELLOW)<- $(CNONE)$(DISKMOUNTPATH)/"
		$(VERBOSE)$(PYTHON) scripts/vhd-umount.py $(DISKMOUNTPATH)

install_bootloader: create umount $(OBJDIR)/tools/writebootloader \
$(OBJDIR)/loader/stage1.bin $(OBJDIR)/loader/stage2.bin
		@echo "$(MSG_BOOTLOADER) $(DISKNAME) $(CRED)<- $(CNONE)stage{1,2}.bin"
		$(VERBOSE)$(OBJDIR)/tools/writebootloader $(DISKNAME) $(OBJDIR)/loader/stage1.bin \
				$(OBJDIR)/loader/stage2.bin 2> /dev/null

print_objs_recipes:
		@echo "$(MSG_BOOTLOADER) <disk.vhd> $(CRED)<- $(CNONE)stage{1,2}.bin"
		@echo "$(MSG_DIR) to/create"
		@echo "$(MSG_INSTALL) file1 $(CGREEN)-> $(CNONE)file2"
		@echo "$(MSG_RM) file-or-dir"
		@echo "$(MSG_CREATE) <disk.vhd> <size> MB, partitions, fs"
		@echo "$(MSG_MOUNT) <disk.vhd> $(CYELLOW)-> $(CNONE)<mnt point>"
		@echo "$(MSG_UMOUNT) <disk.vhd> $(CYELLOW)<- $(CNONE)<mnt point>"
		@echo "$(MSG_HOST_AS) file.o"
		@echo "$(MSG_HOST_CC) file.o"
		@echo "$(MSG_HOST_CXX) file.o"
		@echo "$(MSG_HOST_LD) target"
		@echo "$(MSG_TARGET_AS) file.o"
		@echo "$(MSG_TARGET_CC) file.o"
		@echo "$(MSG_TARGET_CXX) file.o"
		@echo "$(MSG_TARGET_LD) target"
		@echo "$(MSG_DEPS_CC) file.d"
		@echo "$(MSG_DEPS_CXX) file.d"
		@echo "$(MSG_YASM) file.bin"

include src/Makefrag
