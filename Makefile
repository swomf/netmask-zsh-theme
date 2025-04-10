SRC_DIR      := src
CONFIG_DIR   := $(SRC_DIR)/config
NCONFIG_PROG := $(CONFIG_DIR)/nconfig
IP_PROG      := $(SRC_DIR)/ip
THEME        := $(SRC_DIR)/netmask.zsh-theme

all: $(IP_PROG) $(THEME)

help:
	@echo "Usage: make [all|nconfig|clean|distclean|install]"
	@echo ""
	@echo "Targets: "
	@echo "  all       - all targets"
	@echo "  nconfig   - interactively configure netmask.zsh-theme for user's specific IP"
	@echo "                (default: find first ip that starts with \`wl\`)"
	@echo "  clean     - remove compiled targets"
	@echo "  distclean - clean, also remove configure step output"
	@echo "  install   - install netmask.zsh-theme and ip binaries to"
	@echo "              $$ZSH/custom"
	@echo "  uninstall - remove netmask.zsh-theme and ip binaries from"
	@echo "              $$ZSH/custom"
	@echo ""
	@echo "Recommended usage: make nconfig && make all && make install"

clean:
	$(RM) $(IP_PROG) $(THEME) $(NCONFIG_PROG)

distclean: clean
	$(RM) $(wildcard $(CONFIG_DIR)/*.sed)

install: all
ifndef ZSH
	$(error $$ZSH is not set! If ohmyzsh is installed, please inherit the env\
	using `sudo -E make install`. Otherwise, install ohmyzsh and retry)
endif
	install -Dm644 $(THEME) $(ZSH)/custom/themes/netmask.zsh-theme
	install -Dm755 $(IP_PROG) $(ZSH)/custom/bin/netmask/ip

uninstall:
	$(RM) $(ZSH)/custom/themes/netmask.zsh-theme
	$(RM) $(ZSH)/custom/bin/netmask/ip

nconfig: $(NCONFIG_PROG) $(IP_PROG)
	./$(NCONFIG_PROG)

$(NCONFIG_PROG): $(NCONFIG_PROG).c
$(NCONFIG_PROG): LDFLAGS+=$(shell pkg-config --libs ncurses menu)

$(IP_PROG): $(IP_PROG).c

$(THEME): $(THEME).in $(wildcard $(CONFIG_DIR)/*.sed)
	cp -f $(THEME).in $(THEME)
	$(foreach file, $(wildcard $(CONFIG_DIR)/*.sed), sed -f $(file) -i $(THEME);)

.PHONY: all nconfig clean distclean help install uninstall
