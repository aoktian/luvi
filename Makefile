LUVI_TAG=2.8.0
LUVI_ARCH=$(shell uname -s)_$(shell uname -m)
LUVI_PREFIX?=/usr/local
LUVI_BINDIR?=$(LUVI_PREFIX)/bin

OS:=$(shell uname -s)

CMAKE_FLAGS+= -H. -Bbuild -DCMAKE_BUILD_TYPE=Release

ifdef WITHOUT_AMALG
	CMAKE_FLAGS+= -DWITH_AMALG=OFF
endif

CMAKE_FLAGS += \
	-DWITH_LUA_ENGINE=Lua

CPACK_FLAGS=-DWithPackageSH=ON -DWithPackageTGZ=ON -DWithPackageTBZ2=ON


ifndef NPROCS
	NPROCS:=$(shell grep -c ^processor /proc/cpuinfo)
endif

ifdef NPROCS
  EXTRA_OPTIONS:=-j${NPROCS}
endif

# This does the actual build and configures as default flavor is there is no build folder.
luvi: build
	cmake --build build -- ${EXTRA_OPTIONS}

build:
	@echo "Please run tiny' or 'regular' make target first to configure"

# Configure the build with minimal dependencies
tiny:
	cmake $(CMAKE_FLAGS) $(CPACK_FLAGS)

# Configure the build with openssl statically included
regular:
	cmake $(CMAKE_FLAGS) $(CPACK_FLAGS) -DWithOpenSSL=ON -DWithSharedOpenSSL=OFF -DWithPCRE=ON -DWithLPEG=ON -DWithSharedPCRE=OFF -DWithZLIB=ON -DWithSharedZLIB=OFF

package:
	cmake --build build -- package


clean:
	rm -rf build luvi-*

test: luvi
	rm -f test.bin
	build/luvi samples/test.app -- 1 2 3 4
	build/luvi samples/test.app -o test.bin
	./test.bin 1 2 3 4
	rm -f test.bin

install: luvi
	install -p build/luvi $(LUVI_BINDIR)/

uninstall:
	rm -rf $(LUVI_BINDIR)/luvi
