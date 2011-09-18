# common rules

DEPENDENCIES :=
MODULE_DIRS  :=

MODULE_CFLAGS    :=
MODULE_CXXFLAGS  :=
MODULE_DFLAGS    :=
MODULE_NAME      :=
MODULE_TYPE      :=
MODULE_SOURCES   :=
MODULE_DEPS      :=
MODULE_LIBS      :=
MODULE_LIBS_PATH :=

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

# $(call source-to-targets-dir, directory-list)
source-to-targets-dir = $(addprefix $(TARGETS)/,$1)

# $(call source-to-objects-dir, directory-list)
source-to-objects-dir = $(addprefix $(OBJS)/,$1)

# $(call source-to-object, sources-list)
source-to-object = $(call source-to-objects-dir,\
	$(subst .S,.o,$(filter %.S,$1))\
	$(subst .c,.o,$(filter %.c,$1))\
	$(subst .cc,.o,$(filter %.cc,$1))\
	$(subst .cpp,.o,$(filter %.cpp,$1))\
	$(subst .d,.o,$(filter %.d,$1))\
	$(subst .asm,.o,$(filter %.asm,$1)))

asm-to-bin = $(call source-to-targets-dir,$(subst .S,.bin,$(filter %.S,$1)))

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
  $(subst .o,.deps,$(call source-to-object,$1)): $1 Makefile mk/env.mk \
	mk/rules.mk | $(dir $(subst .o,.deps,$(call source-to-object,$1)))
		@echo "$(MSG_DEPS_CC) $$@"
		$(V)$(HOST_CC) $(HOST_CFLAGS) $(MODULE_CFLAGS) -MM -MF $$@ -MT \
			$(call source-to-object,$1) $$<
endef

# $(call host-deps-cxx, source.{cc,cpp})
define host-deps-cxx
  DEPENDENCIES += $(subst .o,.deps,$(call source-to-object,$1))
  $(subst .o,.deps,$(call source-to-object,$1)): $1 Makefile mk/env.mk \
	mk/rules.mk | $(dir $(subst .o,.deps,$(call source-to-object,$1)))
		@echo "$(MSG_DEPS_CXX) $$@"
		$(V)$(HOST_CXX) $(HOST_CXXFLAGS) $(MODULE_CXXFLAGS) -MM -MF $$@\
			-MT $(call source-to-object,$1) $$<
endef

# $(call target-compile-c, source.c)
define target-compile-c
  $(call source-to-object,$1): $1 Makefile mk/env.mk mk/rules.mk | \
	$(dir $(call source-to-object,$1))
		@echo "$(MSG_TARGET_CC) $$@"
		$(V)$(TARGET_CC) $(TARGET_CFLAGS) $(MODULE_CFLAGS) -c -o $$@ $$<
endef

# $(call target-compile-cxx, source.{cc,cpp})
define target-compile-cxx
  $(call source-to-object,$1): $1 Makefile mk/env.mk mk/rules.mk | \
	$(dir $(call source-to-object,$1))
		@echo "$(MSG_TARGET_CXX) $$@"
		$(V)$(TARGET_CXX) $(TARGET_CXXFLAGS) $(MODULE_CXXFLAGS) -c -o $$@ $$<
endef

# $(call target-compile-d, source.d)
define target-compile-d
  $(call source-to-object,$1): $1 Makefile mk/env.mk mk/rules.mk | \
	$(dir $(call source-to-object,$1))
		@echo "$(MSG_TARGET_D) $$@"
		$(V)$(TARGET_GDC) $(TARGET_DFLAGS) $(MODULE_DFLAGS) -c -o $$@ $$<
endef

# $(call target-compile-yasm, source.S)
define target-compile-yasm
  $(call source-to-object,$1): $1 Makefile mk/env.mk mk/rules.mk | \
	$(dir $(call source-to-object,$1))
		@echo "$(MSG_TARGET_AS) $$@"
		$(V)$(YASM) -felf -o $$@ $$<
endef

# $(call target-compile-cxx, source.{cc,cpp})
define target-compile-asm
  $(call source-to-object,$1): $1 Makefile mk/env.mk mk/rules.mk | \
	$(dir $(call source-to-object,$1))
		@echo "$(MSG_TARGET_AS) $$@"
		$(V)$(TARGET_CC) $(TARGET_CFLAGS) $(MODULE_CFLAGS) -c -o $$@ $$<
endef

# $(call target-deps-c, source.c)
define target-deps-c
  DEPENDENCIES += $(subst .o,.deps,$(call source-to-object,$1))
  $(subst .o,.deps,$(call source-to-object,$1)): $1 Makefile mk/env.mk \
	mk/rules.mk | $(dir $(subst .o,.deps,$(call source-to-object,$1)))
		@echo "$(MSG_DEPS_CC) $$@"
		$(V)$(TARGET_CC) $(TARGET_CFLAGS) $(MODULE_CFLAGS) -MM -MF $$@ -MT \
			$(call source-to-object,$1) $$<
endef

# $(call target-deps-cxx, source.{cc,cpp})
define target-deps-cxx
  DEPENDENCIES += $(subst .o,.deps,$(call source-to-object,$1))
  $(subst .o,.deps,$(call source-to-object,$1)): $1 Makefile mk/env.mk \
	mk/rules.mk | $(dir $(subst .o,.deps,$(call source-to-object,$1)))
		@echo "$(MSG_DEPS_CXX) $$@"
		$(V)$(TARGET_CXX) $(TARGET_CXXFLAGS) $(MODULE_CXXFLAGS) -MM -MF $$@\
			-MT $(call source-to-object,$1) $$<
endef

# $(call host-compile-rules, sources-list)
define host-compile-rules
  $(foreach s,$(filter %.c,$1),
    $(call host-compile-c,$s))
  $(foreach s,$(filter %.cc,$1),
    $(call host-compile-cxx,$s))
  $(foreach s,$(filter %.cpp,$1),
    $(call host-compile-cxx,$s))
  $(foreach s,$(filter %.d,$1),
    $(call host-compile-d,$s))
  $(foreach s,$(filter %.S,$1),
    $(call host-compile-yasm,$s))
  $(foreach s,$(filter %.asm,$1),
    $(call host-compile-asm,$s))
endef

# $(call host-deps-rules, sources-list)
define host-deps-rules
  $(foreach s,$(filter %.c,$1),
    $(call host-deps-c,$s))
  $(foreach s,$(filter %.cc,$1),
    $(call host-deps-cxx,$s))
  $(foreach s,$(filter %.cpp,$1),
    $(call host-deps-cxx,$s))
  $(foreach s,$(filter %.d,$1),
    $(call host-deps-d,$s))
endef

# $(call target-compile-rules, sources-list)
define target-compile-rules
  $(foreach s,$(filter %.c,$1),
    $(call target-compile-c,$s))
  $(foreach s,$(filter %.cc,$1),
    $(call target-compile-cxx,$s))
  $(foreach s,$(filter %.cpp,$1),
    $(call target-compile-cxx,$s))
  $(foreach s,$(filter %.d,$1),
    $(call target-compile-d,$s))
  $(foreach s,$(filter %.S,$1),
    $(call target-compile-yasm,$s))
  $(foreach s,$(filter %.asm,$1),
    $(call target-compile-asm,$s))
endef

# $(call target-deps-rules, sources-list)
define target-deps-rules
  $(foreach s,$(filter %.c,$1),
    $(call target-deps-c,$s))
  $(foreach s,$(filter %.cc,$1),
    $(call target-deps-cxx,$s))
  $(foreach s,$(filter %.cpp,$1),
    $(call target-deps-cxx,$s))
  $(foreach s,$(filter %.d,$1),
    $(call target-deps-d,$s))
endef

# $(eval $(call create-directories))
define create-directories
  $(MODULE_DIRS):
		@echo "$(MSG_DIR) $$@"
		$(V)mkdir -p "$$@"
  MODULE_DIRS :=
endef

# $(call lib-name-to-path,target-lib-name)
define lib-name-to-path
  MODULE_LIBS_PATH += $$$$(MODULE_$1)
endef

# $(eval $(call libs-names-to-paths,targets-libs-names))
define libs-names-to-paths
  $(foreach lib,$(MODULE_LIBS),$(call lib-name-to-path,$(lib)))
endef

# $(eval $(call add-binary-module))
define add-binary-module
  MODULE_DIRS := $(sort $(MODULE_DIRS) $(dir $(call asm-to-bin,$(MODULE_SOURCES))) $(dir $(call source-to-objects-dir,$(MODULE_SOURCES))))

  $(TARGETS)/$(module-dir)/$(MODULE_NAME): $(MODULE_SOURCES) Makefile mk/env.mk mk/rules.mk | $(addprefix $(TARGETS)/,$(module-dir))
		@echo "$(MSG_YASM) $$@"
		$(V)$(YASM) -f bin -o $$@ $$<

  .PHONY: $(MODULE_NAME)
  $(MODULE_NAME): $(MODULE_DEPS) $(MODULE_LIBS) $(TARGETS)/$(module-dir)/$(MODULE_NAME)

  ALL_TARGETS += $(MODULE_NAME)

  MODULE_$(MODULE_NAME) := $(TARGETS)/$(module-dir)/$(MODULE_NAME)

  MODULE_CFLAGS    :=
  MODULE_CXXFLAGS  :=
  MODULE_DFLAGS    :=
  MODULE_NAME      :=
  MODULE_TYPE      :=
  MODULE_SOURCES   :=
  MODULE_DEPS      :=
  MODULE_LIBS      :=
  MODULE_LIBS_PATH :=
endef

# MODULE_TYPE := {application, library}
# example:
# MODULE_CFLAGS := $(WARNINGS_CFLAGS) -Werror
# MODULE_CXXFLAGS := $(WARNINGS_CXXFLAGS) -Werror
# MODULE_NAME := example
# MODULE_TYPE := application
# MODULE_SOURCES := source1.c source2.cc source3.S
# MODULE_SOURCES := $(addprefix $(module-dir)/,$(MODULE_SOURCES))
# MODULE_DEPS := libanotherlibrary.a
# $(eval $(call add-host-module))
#
# Now we've got this variable set for each target:
# MODULE_${MODULE_NAME} := full/path/to/created/target
#
# MODULE_example = $(TARGETS)/$(module-dir)/example
define add-host-module
  MODULE_DIRS := $(sort $(MODULE_DIRS) $(dir $(call source-to-object,$(MODULE_SOURCES))) $(dir $(call source-to-targets-dir,$(MODULE_SOURCES))))
  MODULE_LIBS_PATH :=

  $(eval $(call libs-names-to-paths))

  $(TARGETS)/$(module-dir)/$(MODULE_NAME): $(call source-to-object,$(MODULE_SOURCES)) | $(addprefix $(TARGETS)/,$(module-dir)) $(addprefix $(OBJS)/,$(module-dir))
  ifeq ($(MODULE_TYPE), application)
		@echo "$(MSG_HOST_LD) $$@"
		$(V)$(HOST_CXX) $(HOST_CXXFLAGS) -o $$@ $$^ $(MODULE_LIBS_PATH)
  endif
  ifeq ($(MODULE_TYPE), library)
		@echo "$(MSG_HOST_LIB) $$@"
		$(V)$(HOST_AR) rc $$@ $$^
		$(V)$(HOST_RANLIB) $$@
  endif

  .PHONY: $(MODULE_NAME)
  $(MODULE_NAME): $(MODULE_DEPS) $(MODULE_LIBS) $(TARGETS)/$(module-dir)/$(MODULE_NAME)

  ALL_TARGETS += $(MODULE_NAME)
  ifeq ($(MODULE_TYPE), application)
    HOST_APPS += $(MODULE_NAME)
  endif

  MODULE_$(MODULE_NAME) := $(TARGETS)/$(module-dir)/$(MODULE_NAME)

  $(call host-compile-rules,$(MODULE_SOURCES))
  $(call host-deps-rules,$(MODULE_SOURCES))

  MODULE_CFLAGS    :=
  MODULE_CXXFLAGS  :=
  MODULE_DFLAGS    :=
  MODULE_NAME      :=
  MODULE_TYPE      :=
  MODULE_SOURCES   :=
  MODULE_DEPS      :=
  MODULE_LIBS      :=
  MODULE_LIBS_PATH :=
endef

define add-target-module
  MODULE_DIRS := $(sort $(MODULE_DIRS) $(dir $(call source-to-object,$(MODULE_SOURCES))) $(dir $(call source-to-targets-dir,$(MODULE_SOURCES))))
  MODULE_LIBS_PATH :=

  $(eval $(call libs-names-to-paths))

  $(TARGETS)/$(module-dir)/$(MODULE_NAME): $(call source-to-object,$(MODULE_SOURCES)) | $(addprefix $(TARGETS)/,$(module-dir)) $(addprefix $(OBJS)/,$(module-dir))
  ifeq ($(MODULE_TYPE), loader)
		@echo "$(MSG_TARGET_LD) $$@"
		$(V)$(TARGET_LD) -T ldscripts/loader.ld -melf_i386 -o $$@.elf $$^
		$(V)$(TARGET_OBJCOPY) -Obinary $$@.elf $$@.bin
		$(V)cat $(MODULE_bootstrap.bin) $$@.bin > $$@
  endif

  .PHONY: $(MODULE_NAME)
  $(MODULE_NAME): $(MODULE_DEPS) $(MODULE_LIBS) $(TARGETS)/$(module-dir)/$(MODULE_NAME)

  ALL_TARGETS += $(MODULE_NAME)
  ifeq ($(MODULE_TYPE), loader)
    TARGET_LOADER += $(MODULE_NAME)
  endif

  MODULE_$(MODULE_NAME) := $(TARGETS)/$(module-dir)/$(MODULE_NAME)

  $(call target-compile-rules,$(MODULE_SOURCES))
  $(call target-deps-rules,$(MODULE_SOURCES))

  MODULE_CFLAGS    :=
  MODULE_CXXFLAGS  :=
  MODULE_DFLAGS    :=
  MODULE_NAME      :=
  MODULE_TYPE      :=
  MODULE_SOURCES   :=
  MODULE_DEPS      :=
  MODULE_LIBS      :=
  MODULE_LIBS_PATH :=
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
	@echo "$(MSG_HOST_D) file.o"
	@echo "$(MSG_HOST_LD) target"
	@echo "$(MSG_HOST_LIB) target.a"
	@echo "$(MSG_TARGET_AS) file.o"
	@echo "$(MSG_TARGET_CC) file.o"
	@echo "$(MSG_TARGET_CXX) file.o"
	@echo "$(MSG_TARGET_D) file.o"
	@echo "$(MSG_TARGET_LD) target"
	@echo "$(MSG_TARGET_LIB) target.a"
	@echo "$(MSG_DEPS_CC) file.deps"
	@echo "$(MSG_DEPS_CXX) file.deps"
	@echo "$(MSG_YASM) file.bin"
