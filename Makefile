ROOT	:= ""
PREFIX	:= $(ROOT)/usr
BINDIR	:= $(SRCDIR)/bin
SRCDIR	:= $(PREFIX)/share/hpkg

define install
	mkdir -p $(SRCDIR) $(BINDIR)
	cp -r ./lib $(SRCDIR)
	install -m 755 ./src/hpkg.sh $(BINDIR)/hpkg
endef

define uninstall
	rm -rf $(SRCDIR) $(BINDIR)/hpkg
endef

install:
	@$(install)
	@echo "installed.."

uninstall:
	@$(uninstall)
	@echo "uninstalled.." 

reinstall:
	@$(uninstall)
	@$(install)
	@echo "reinstalled.."
