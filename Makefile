SRC_DIR     := src
IP_PROG     := $(SRC_DIR)/ip
THEME       := $(SRC_DIR)/netmask.zsh-theme

all: $(IP_PROG) $(THEME)

help:
	@echo "Usage: make [all|clean|install]"
	@echo ""
	@echo "Targets: "
	@echo "  all       - all targets"
	@echo "  clean     - remove compiled targets"
	@echo "  install   - install netmask.zsh-theme and ip binaries t"
	@echo "              ZSH/custom"
	@echo ""
	@echo "Recommended usage: make all && make install"

clean:
	rm -f $(IP_PROG) $(THEME)

install: all
ifndef ZSH
	$(error $$ZSH is not set! If ohmyzsh is installed, please inherit the env\
	using `sudo -E make install`. Otherwise, install ohmyzsh and retry)
endif
	install -Dm644 $(THEME) $(ZSH)/custom/themes/netmask.zsh-theme

$(IP_PROG): $(IP_PROG).c

$(THEME): $(THEME).tmpl
	cp -f $(THEME).tmpl $(THEME)

.PHONY: all clean help install
