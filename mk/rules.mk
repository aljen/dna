# compile tools/*.c
$(OBJDIR)/tools/%.o: src/tools/%.c | $(OBJDIR)/tools
	@echo "$(MSG_HOST_CC) $@"
	$(VERBOSE)$(HOST_CC) $(HOST_CFLAGS) -c -o $@ $< $(WARNINGS)

# compile tools/*.cc
$(OBJDIR)/tools/%.o: src/tools/%.cc | $(OBJDIR)/tools
	@echo "$(MSG_HOST_CXX) $@"
	$(VERBOSE)$(HOST_CXX) $(HOST_CXXFLAGS) -c -o $@ $< $(WARNINGS)

# resolve dependencies for tools/*.c
$(OBJDIR)/tools/%.d: src/tools/%.c | $(OBJDIR)/tools
	@echo "$(MSG_DEPS_CC) $@"
	$(VERBOSE)$(HOST_CC) $(HOST_CFLAGS) -MM -MF $@ -MT $(subst .d,.o,$@) \
		$< $(WARNINGS)

# resolve dependencies for tools/*.cc
$(OBJDIR)/tools/%.d: src/tools/%.cc | $(OBJDIR)/tools
	@echo "$(MSG_DEPS_CXX) $@"
	$(VERBOSE)$(HOST_CXX) $(HOST_CXXFLAGS) -MM -MF $@ -MT $(subst .d,.o,$@) \
		$< $(WARNINGS)

# make directories
$(OBJDIR)/apps $(OBJDIR)/drivers $(OBJDIR)/kernel $(OBJDIR)/loader \
$(OBJDIR)/servers $(OBJDIR)/tools:
	@echo "$(MSG_DIR) $@"
	$(VERBOSE)mkdir -p "$@"

# create vhd
$(DISKNAME):
	@echo "$(MSG_CREATE) $(DISKNAME) $(DISKSIZE) MB, 1 partition (ext2)"
	$(VERBOSE)$(PYTHON) scripts/vhd-create.py $(DISKNAME) $(DISKSIZE) \
	$(DISKMOUNTPATH) 2> /dev/null > /dev/null
