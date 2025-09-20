SDL_MAJOR := 3
SDL_MINOR := 2
SDL_PATCH := 22
SHA256 := f29d00cbcee273c0a54f3f32f86bf5c595e8823a96b1d92a145aac40571ebfcc

CMAKE := cmake
TAR := tar
CURL := curl
SHA256SUM := sha256sum

ifeq (, $(shell $(CMAKE) --version 2>/dev/null))
$(error "Need 'cmake' to build SDL")
endif

ifeq (, $(shell $(TAR) --version 2>/dev/null))
$(error "Need 'tar' to build SDL")
endif

ifeq (, $(shell $(CURL) --version 2>/dev/null))
$(error "Need 'curl' to build SDL")
endif

ifeq (, $(shell $(SHA256SUM) --version 2>/dev/null))
$(error "Need 'sha256sum' to build SDL")
endif

SDL_VERSION := $(SDL_MAJOR).$(SDL_MINOR).$(SDL_PATCH)
SDL_FULLNAME := SDL$(SDL_MAJOR)-$(SDL_VERSION)
PACKAGE_FILENAME := $(SDL_FULLNAME).tar.gz
URL := https://github.com/libsdl-org/SDL/releases/download/release-$(SDL_VERSION)/$(PACKAGE_FILENAME)
SDL_FOLDER := $(SDL_FULLNAME)
SDL_CMAKELISTS := $(SDL_FOLDER)/CMakeLists.txt
SDL_BUILD_FOLDER := $(SDL_FOLDER)/build
SDL_MAKEFILE := $(SDL_BUILD_FOLDER)/Makefile
SDL_SHARED := $(SDL_BUILD_FOLDER)/libSDL$(SDL_MAJOR).so
INSTALL_FOLDER := $(SDL_FOLDER)/install
SDL_SHARED_INSTALL := $(INSTALL_FOLDER)/lib/libSDL$(SDL_MAJOR).so

.PHONY: all
all: $(SDL_SHARED_INSTALL)

.PHONY: clean
clean:
	rm -rf $(SDL_FOLDER)
	rm -f $(PACKAGE_FILENAME)

$(INSTALL_FOLDER):
	mkdir -p $@

$(SDL_SHARED_INSTALL): $(SDL_SHARED) | $(INSTALL_FOLDER)
	$(CMAKE) --install $(SDL_BUILD_FOLDER) --prefix $(INSTALL_FOLDER)

$(SDL_SHARED): $(SDL_MAKEFILE)
	$(CMAKE) --build $(SDL_BUILD_FOLDER) --parallel

$(SDL_MAKEFILE): $(SDL_CMAKELISTS)
	$(CMAKE) -S $(SDL_FOLDER) -B $(SDL_BUILD_FOLDER)

$(SDL_CMAKELISTS):
	$(CURL) -fsLo $(PACKAGE_FILENAME) $(URL)
	echo "$(SHA256)  $(PACKAGE_FILENAME)" | $(SHA256SUM) -c
	$(TAR) xzf $(PACKAGE_FILENAME)
	rm -f $(PACKAGE_FILENAME)
