# common rules

MODULE_DIRS     :=
DEPENDENCIES    :=
MODULE_CFLAGS   :=
MODULE_CXXFLAGS :=

# $(subdirectory)
subdirectory = $(patsubst %/module.mk,%,$(word $(words $(MAKEFILE_LIST)),\
	$(MAKEFILE_LIST)))

# $(module-dir)
module-dir = $(subst src/,,$(subdirectory))
module-dir-suffix = $(addsuffix /,$(module-dir))

# $(call prefix-non-modules-sources, sources-list)
prefix-non-module-sources = $(sort $(filter $(module-dir-suffix)%,$1) \
	$(addprefix $(module-dir-suffix), $(filter-out $(module-dir-suffix)%, \
	$1)))

# $(call source-to-build-dir, directory-list)
source-to-build-dir = $(addprefix $(BUILD)/,$1)

# $(call source-to-object, sources-list)
source-to-object = $(call source-to-build-dir,$(subst .c,.o,$(filter %.c,$1)) \
	$(subst .cc,.o,$(filter %.cc,$1)) $(subst .cpp,.o,$(filter %.cpp,$1)))

asm-to-bin = $(call source-to-build-dir,$(subst .S,.bin,$(filter %.S,$1)))

# $(call host-compile-c, source.c)
define host-compile-c
  $(call source-to-object,$1): $1 Makefile mk/env.mk mk/rules.mk | \
	$(dir $(call source-to-object,$1))
		@echo "$(MSG_HOST_CC) $$@"
		$(V)$(HOST_CC) $(HOST_CFLAGS) $(MODULE_CFLAGS) -c -o $$@ $$<
endef

# $(call host-compile-cxx, source.{cc,cpp})
define host-compile-cxx
  $(call source-to-object,$1): $1 Makefile mk/env.mk mk/rules.mk | \
	$(dir $(call source-to-object,$1))
		@echo "$(MSG_HOST_CXX) $$@"
		$(V)$(HOST_CXX) $(HOST_CXXFLAGS) $(MODULE_CXXFLAGS) -c -o $$@ $$<
endef

# $(call host-deps-c, source.c)
define host-deps-c
  DEPENDENCIES += $(subst .o,.deps,$(call source-to-object,$1))
  $(subst .o,.deps,$(call source-to-object,$1)): $1 Makefile mk/env.mk mk/rules.mk\
	| $(dir $(subst .o,.deps,$(call source-to-object,$1)))
		@echo "$(MSG_DEPS_CC) $$@"
		$(V)$(HOST_CC) $(HOST_CFLAGS) $(MODULE_CFLAGS) -MM -MF $$@ -MT \
			$(call source-to-object,$1) $$<
endef

# $(call host-deps-cxx, source.{cc,cpp})
define host-deps-cxx
  DEPENDENCIES += $(subst .o,.deps,$(call source-to-object,$1))
  $(subst .o,.deps,$(call source-to-object,$1)): $1 Makefile mk/env.mk mk/rules.mk\
	| $(dir $(subst .o,.deps,$(call source-to-object,$1)))
		@echo "$(MSG_DEPS_CXX) $$@"
		$(V)$(HOST_CXX) $(HOST_CXXFLAGS) $(MODULE_CXXFLAGS) -MM -MF $$@\
			-MT $(call source-to-object,$1) $$<
endef

# $(call add-plain-bin, name, source, dependencies)
define add-plain-bin
  MODULE_DIRS := $(sort $(MODULE_DIRS) $(dir $(call asm-to-bin,$2)))

  $(BUILD)/$(module-dir)/$1: $2 $3 Makefile mk/env.mk mk/rules.mk |\
	$(addprefix $(BUILD)/,$(module-dir))
		@echo "$(MSG_YASM) $$@"
		$(V)$(YASM) -f bin -o $$@ $$<

  .PHONY: loader-$1
  loader-$1: $(BUILD)/$(module-dir)/$1

  TARGET_LOADER += loader-$1
endef

# $(call add-tool, name, sources-list)
define add-tool
  MODULE_DIRS := $(sort $(MODULE_DIRS) $(dir $(call source-to-object,$2)))

  $(BUILD)/$(module-dir)/$1: $(call source-to-object,$2) |\
	$(addprefix $(BUILD)/,$(module-dir))
		@echo "$(MSG_HOST_LD) $$@"
		$(V)$(HOST_CXX) $(HOST_CXXFLAGS) -o $$@ $$^

  .PHONY: tools-$1
  tools-$1: $(BUILD)/$(module-dir)/$1

  HOST_APPS += tools-$1

  $(call host-compile-rules,$2)
  $(call host-deps-rules,$2)
endef

# $(call host-compile-rules, sources-list)
define host-compile-rules
  $(foreach s,$(filter %.c,$1),$(call host-compile-c,$s))
  $(foreach s,$(filter %.cc,$1),$(call host-compile-cxx,$s))
  $(foreach s,$(filter %.cpp,$1),$(call host-compile-cxx,$s))
endef

# $(call host-deps-rules, sources-list)
define host-deps-rules
  $(foreach s,$(filter %.c,$1),$(call host-deps-c,$s))
  $(foreach s,$(filter %.cc,$1),$(call host-deps-cxx,$s))
  $(foreach s,$(filter %.cpp,$1),$(call host-deps-cxx,$s))
endef

define create-directories
  $(MODULE_DIRS):
		@echo "$(MSG_DIR) $$@"
		$(V)mkdir -p "$$@"
  MODULE_DIRS :=
endef

# create vhd
$(DISKNAME):
	@echo "$(MSG_CREATE) $(DISKNAME) $(DISKSIZE) MB, 1 partition (ext2)"
	$(V)$(PYTHON) scripts/vhd-create.py $(DISKNAME) $(DISKSIZE) \
	$(DISKMOUNTPATH) 2> /dev/null > /dev/null

help:
	@echo "	$(CCYAN)Hitomi$(CNONE) build system (revision$(CPURPLE)"\
		"$(BUILD_REVISION)$(CNONE))"
	@echo "$(CYELLOW)make create		$(CNONE)- Creates virtual disk image"
	@echo "$(CYELLOW)make mount		$(CNONE)- Mounts virtual disk image"
	@echo "$(CYELLOW)make umount		$(CNONE)- Umounts virtual disk image"
	@echo "$(CYELLOW)make all-apps		$(CNONE)- Builds all applications"
	@echo "$(CYELLOW)make all-drivers	$(CNONE)- Builds all drivers"
	@echo "$(CYELLOW)make all-kernel		$(CNONE)- Builds kernel"
	@echo "$(CYELLOW)make all-loader		$(CNONE)- Builds bootloader"
	@echo "$(CYELLOW)make all-servers	$(CNONE)- Builds all servers"
	@echo "$(CYELLOW)make all-tools		$(CNONE)- Builds all tools"

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
	@echo "$(MSG_DEPS_CC) file.deps"
	@echo "$(MSG_DEPS_CXX) file.deps"
	@echo "$(MSG_YASM) file.bin"

