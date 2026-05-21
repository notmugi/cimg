#
# weh - tiny C image viewer for X11 and Wayland.
#
# Build:        make
# Run:          ./weh IMAGE
# Install:      sudo make install                 (defaults to /usr/local)
# Uninstall:    sudo make uninstall
# Override:     make PREFIX=/usr install
#

CC          ?= cc
PKG_CONFIG  ?= pkg-config
PREFIX      ?= /usr/local
DESTDIR     ?=
CFLAGS      ?= -O2 -g
WARNINGS    := -Wall -Wextra -Wpedantic
PKGS        := sdl3 gegl-0.4 babl-0.1 gdk-pixbuf-2.0 librsvg-2.0 cairo pangocairo
CPPFLAGS    += $(shell $(PKG_CONFIG) --cflags $(PKGS))
LDLIBS      += $(shell $(PKG_CONFIG) --libs $(PKGS)) -lm

TARGET      := weh
SRC_MAIN    := src/main.c
OBJ_MAIN    := build/main.o
OBJS        := $(OBJ_MAIN)

BINDIR      := $(DESTDIR)$(PREFIX)/bin
MANDIR      := $(DESTDIR)$(PREFIX)/share/man/man1
APPDIR      := $(DESTDIR)$(PREFIX)/share/applications
ICONBASE    := $(DESTDIR)$(PREFIX)/share/icons/hicolor

.PHONY: all clean install uninstall

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $(OBJS) $(LDLIBS)

$(OBJ_MAIN): $(SRC_MAIN) | build
	$(CC) $(WARNINGS) $(CFLAGS) $(CPPFLAGS) -c -o $@ $<

build:
	mkdir -p build

clean:
	rm -rf build $(TARGET)

install: $(TARGET)
	install -Dm755 $(TARGET)             "$(BINDIR)/$(TARGET)"
	install -Dm644 dist/weh.1            "$(MANDIR)/weh.1"
	install -Dm644 dist/weh.desktop      "$(APPDIR)/weh.desktop"
	@# Icons (scalable preferred; PNG fallbacks installed if present).
	@if [ -f dist/icons/weh.svg ]; then \
	    install -Dm644 dist/icons/weh.svg \
	      "$(ICONBASE)/scalable/apps/weh.svg"; \
	fi
	@for sz in 16 24 32 48 64 128 256 512; do \
	    if [ -f "dist/icons/$$sz/weh.png" ]; then \
	        install -Dm644 "dist/icons/$$sz/weh.png" \
	          "$(ICONBASE)/$${sz}x$${sz}/apps/weh.png"; \
	    fi; \
	done
	@# Refresh the icon cache if available (best effort).
	@if command -v gtk-update-icon-cache >/dev/null 2>&1; then \
	    gtk-update-icon-cache -f -t "$(ICONBASE)" 2>/dev/null || true; \
	fi
	@if command -v update-desktop-database >/dev/null 2>&1; then \
	    update-desktop-database "$(APPDIR)" 2>/dev/null || true; \
	fi

uninstall:
	rm -f "$(BINDIR)/$(TARGET)"
	rm -f "$(MANDIR)/weh.1"
	rm -f "$(APPDIR)/weh.desktop"
	rm -f "$(ICONBASE)/scalable/apps/weh.svg"
	@for sz in 16 24 32 48 64 128 256 512; do \
	    rm -f "$(ICONBASE)/$${sz}x$${sz}/apps/weh.png"; \
	done
