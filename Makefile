#
# cimg - tiny C image viewer for X11 and Wayland.
#
# Build:        make
# Run:          ./cimg IMAGE
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

TARGET      := cimg
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
	install -Dm644 dist/cimg.1           "$(MANDIR)/cimg.1"
	install -Dm644 dist/cimg.desktop     "$(APPDIR)/cimg.desktop"
	@# Icons (scalable preferred; PNG fallbacks installed if present).
	@if [ -f dist/icons/cimg.svg ]; then \
	    install -Dm644 dist/icons/cimg.svg \
	      "$(ICONBASE)/scalable/apps/cimg.svg"; \
	fi
	@for sz in 16 24 32 48 64 128 256 512; do \
	    if [ -f "dist/icons/$$sz/cimg.png" ]; then \
	        install -Dm644 "dist/icons/$$sz/cimg.png" \
	          "$(ICONBASE)/$${sz}x$${sz}/apps/cimg.png"; \
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
	rm -f "$(MANDIR)/cimg.1"
	rm -f "$(APPDIR)/cimg.desktop"
	rm -f "$(ICONBASE)/scalable/apps/cimg.svg"
	@for sz in 16 24 32 48 64 128 256 512; do \
	    rm -f "$(ICONBASE)/$${sz}x$${sz}/apps/cimg.png"; \
	done
