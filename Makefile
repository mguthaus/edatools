.ONESHELL:

# Where to put the source repos
REPODIR ?= $(HOME)/repos
# Where to install the binaries
SWROOT ?= $(HOME)/software
# Set this if the SWROOT is not user writable
SUDO=sudo

# Where to fetch the commercial software (from /software)
HOST=`whoami`@donut.soe.ucsc.edu
nproc=4

APT_INSTALL=$(SUDO) apt install --install-recommends -y

.PHONY: help
help:
	@echo "sudo: add this target to run installs with sudo"
	@echo ""
	@echo "general: general dependencies"
	@echo ""
	@echo "open: all open source tools"
	@echo "layout"
	@echo "spice"
	@echo "litho"
	@echo ""
	@echo "layout: layout tools"
	@echo "magic"
	@echo "netgen"
	@echo "klayout"
	@echo ""
	@echo "spice: spice tools"
	@echo "ngspice"
	@echo "xschem"
	@echo "xyce"
	@echo "trilinos"
	@echo ""
	@echo "litho: litho tools"
	@echo ""
	@echo "commercial: commercial tools via rsync (requires VLSIDA account)"
	@echo "synopsys"
	@echo "cadence"
	@echo "mentor"
	@echo ""
	@echo "other:"
	@echo "vagrant"
	@echo "chrome"
	@echo ""
	@echo "tech:"
	@echo "sky130: google/skywater PDK and open_pdks"

all: help

### Dependencies ###
$(REPODIR):
	mkdir -p $(REPODIR)

$(SWROOT):
	mkdir -p $(SWROOT)

.PHONY: open
open: general layout spice litho

.PHONY: layout
layout: magic netgen klayout

.PHONY: spice
spice: ngspice xyce

.PHONY: litho
litho: DimmiLitho

.PHONY: commercial
commercial: synopsys cadence mentor

.PHONY: other
other: vagrant chrome

.PHONY: tech
tech: sky130

# General Linux stuff
.PHONY: general
general: update build interactive python lsb x11 network

.PHONY: update
update:
	$(SUDO) apt update
	$(SUDO) apt upgrade -y

# Build tools
.PHONY: build
build:
	$(APT_INSTALL) build-essential git ssh cmake autoconf automake libtool bison flex libncurses5-dev gdb
	$(SUDO) rm /bin/sh && $(SUDO) ln -s /bin/bash /bin/sh

# X11
.PHONY: x11
x11:
	$(APT_INSTALL) libx11-dev libcairo2-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev x11-xserver-utils

# Needed to run lmstat
.PHONY: lsb
lsb:
	$(APT_INSTALL) lsb lsb-release lsb-core

# Interactive tools
.PHONY: interactive
	$(APT_INSTALL) emacs tmux vim htop

# Network debug tools (can be removed to save space)
.PHONY: network
network:
	$(APT_INSTALL) iputils-ping net-tools lsof wget whois nmap telnet curl dnsutils tcpdump traceroute id-utils

.PHONY: python
python:
# Python3
	$(APT_INSTALL) python3 python3-setuptools python3-pip
	python3 -m pip install jedi autopep8 rope flake8 yapf black

.PHONY: openram
openram: python
	$(APT_INSTALL)  python3 python3-numpy python3-scipy python3-pip python3-matplotlib python3-venv python3-sklearn python-subunit python3-coverage

.PHONY: openeda
openeda: $(SWROOT) $(REPODIR)
	$(APT_INSTALL) m4 csh  tk tk-dev tcl-dev blt-dev libreadline8 libreadline-dev

.PHONY: setup
setup:
	scp $(HOST):/software/setup.sh $(SWROOT)

# CAD dependencies
# Needed by calibre
.PHONY: cadence
calibre: opengl $(SWROOT)
	$(APT_INSTALL) ksh libc6-i386
	ln -s libXpm.so.4 libXp.so.6
	rsync -azv $(HOST):/software/cadence $(SWROOT)

.PHONY: synopsys
synopsys: $(SWROOT)
	  $(APT_INSTALL) libjpeg62 libtiff5 libmng2 libpng16-16
	ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5 /usr/lib/x86_64-linux-gnu/libtiff.so.3
	ln -s /usr/lib/x86_64-linux-gnu/libmng.so.2 /usr/lib/x86_64-linux-gnu/libmng.so.1
	$(APT_INSTALL) libqt5widgets5 libqt5x11extras5 libqt5printsupport5 libqt5xml5 libqt5sql5 libqt5svg5
	$(APT_INSTALL) wget
	wget -q -O /tmp/libpng12.deb http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb \
	&& dpkg -i /tmp/libpng12.deb \
	&& rm /tmp/libpng12.deb
	wget -q -O /tmp/libxp6.deb https://ftp.us.debian.org/debian/pool/main/libx/libxp/libxp6_1.0.2-2_amd64.deb \
	&& dpkg -i /tmp/libxp6.deb \
	&& rm /tmp/libxp6.deb
	rsync -azv $(HOST):/software/synopsys $(SWROOT)

.PHONY: mentor
mentor: $(SWROOT)
	rsync -azv $(HOST):/software/mentor $(SWROOT)

$(REPODIR)/Trilinos:
	git clone --depth 1 --branch trilinos-release-12-12-1 https://github.com/trilinos/Trilinos.git $(REPODIR)/Trilinos

.PHONY: trilinos
trilinos: $(SWROOT) $(REPODIR)/Trilinos

# Options for Trilinos/Xyce
	$(eval SRCDIR=$(REPODIR)/Trilinos)
	$(eval ARCHDIR=$(SWROOT)/XyceLibs/Parallel)
	$(eval FLAGS="-O3 -fPIC")


	$(APT_INSTALL) libfftw3-dev mpich libblas-dev liblapack-dev libsuitesparse-dev libfl-dev libgtk-3-dev
	cd $(REPODIR)/Trilinos
	mkdir -p $(REPODIR)/Trilinos/build
	cd $(REPODIR)/Trilinos/build
	cmake \
	-G "Unix Makefiles" \
	-DCMAKE_C_COMPILER=mpicc \
	-DCMAKE_CXX_COMPILER=mpic++ \
	-DCMAKE_Fortran_COMPILER=mpif77 \
	-DCMAKE_CXX_FLAGS=$(FLAGS) \
	-DCMAKE_C_FLAGS=$(FLAGS) \
	-DCMAKE_Fortran_FLAGS=$(FLAGS) \
	-DCMAKE_INSTALL_PREFIX="$(ARCHDIR)" \
	-DCMAKE_MAKE_PROGRAM="make" \
	-DTrilinos_ENABLE_NOX=ON \
	-DNOX_ENABLE_LOCA=ON \
	-DTrilinos_ENABLE_EpetraExt=ON \
	-DEpetraExt_BUILD_BTF=ON \
	-DEpetraExt_BUILD_EXPERIMENTAL=ON \
	-DEpetraExt_BUILD_GRAPH_REORDERINGS=ON \
	-DTrilinos_ENABLE_TrilinosCouplings=ON \
	-DTrilinos_ENABLE_Ifpack=ON \
	-DTrilinos_ENABLE_ShyLU=ON \
	-DTrilinos_ENABLE_Isorropia=ON \
	-DTrilinos_ENABLE_AztecOO=ON \
	-DTrilinos_ENABLE_Belos=ON \
	-DTrilinos_ENABLE_Teuchos=ON \
	-DTeuchos_ENABLE_COMPLEX=ON \
	-DTrilinos_ENABLE_Amesos=ON \
	-DAmesos_ENABLE_KLU=ON \
	-DTrilinos_ENABLE_Sacado=ON \
	-DTrilinos_ENABLE_Kokkos=ON \
	-DTrilinos_ENABLE_Zoltan=ON \
	-DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF \
	-DTrilinos_ENABLE_CXX11=ON \
	-DTPL_ENABLE_AMD=ON \
	-DAMD_LIBRARY_DIRS="/usr/lib" \
	-DTPL_AMD_INCLUDE_DIRS="/usr/include/suitesparse" \
	-DTPL_ENABLE_BLAS=ON \
	-DTPL_ENABLE_LAPACK=ON \
	-DTPL_ENABLE_MPI=ON \
	$(SRCDIR)
	make -j $(nproc)
	$(SUDO) make install

$(REPODIR)/Xyce:
	git clone https://github.com/Xyce/Xyce.git $(REPODIR)/Xyce

.PHONY: xyce
xyce: trilinos $(REPODIR)/Xyce
	cd $(REPODIR)/Xyce
	./bootstrap
	mkdir -p $(REPODIR)/Xyce/build
	cd $(REPODIR)/Xyce/build
	../configure CXXFLAGS="-O3 -std=c++11" \
	ARCHDIR="$(SWROOT)/XyceLibs/Parallel" \
	CPPFLAGS="-I/usr/include/suitesparse" \
	--enable-mpi \
	CXX=mpicxx \
	CC=mpicc \
	F77=mpif77 \
	--prefix=$(SWROOT)/Xyce/Parallel \
	--enable-shared --enable-xyce-shareable
# This crashes a VM!
#	make -j $(nproc)
	make
	$(SUDO) make install

$(REPODIR)/DimmiLitho: $(REPODIR)/DimmiLitho
	git clone https://github.com/mguthaus/DimmiLitho.git

dimmilitho: $(REPODIR)/DimmiLitho

.PHONY: chrome
chrome:
	$(APT_INSTALL) libxss1 libappindicator1 libindicator7
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	$(SUDO) apt install ./google-chrome*.deb

$(REPODIR)/magic-8.3:
	git clone git://opencircuitdesign.com/magic-8.3 $(REPODIR)/magic-8.3

.PHONY: magic
magic: openeda $(REPODIR)/magic-8.3
	cd $(REPODIR)/magic-8.3
	./configure --prefix=$(SWROOT)
	make
	$(SUDO) make install

$(REPODIR)/ngspice:
	git clone git://git.code.sf.net/p/ngspice/ngspice $(REPODIR)/ngspice

.PHONY: ngspice
ngspice: $(SWROOT) $(REPODIR)/ngspice
	$(APT_INSTALL) libxaw7-dev octave
	cd $(REPODIR)/ngspice
	./autogen.sh
	./configure \
	--enable-openmp \
	--with-readline \
	--prefix=$(SWROOT)
	make -j $(nproc)
	$(SUDO) make install

$(REPODIR)/netgen:
	git clone git://opencircuitdesign.com/netgen-1.5 $(REPODIR)/netgen

.PHONY: netgen
netgen: openeda $(REPODIR)/netgen
	cd $(REPODIR)/netgen
	git checkout netgen-1.5
	./configure --prefix=$(SWROOT)
	make -j $(nproc)
	$(SUDO) make install

$(REPODIR)/klayout:
	git clone https://github.com/KLayout/klayout $(REPODIR)/klayout

.PHONY: klayout
klayout: $(SWROOT) $(REPODIR)/klayout
	$(APT_INSTALL) qt5-default qtcreator ruby-full ruby-dev python3-dev qtmultimedia5-dev libqt5multimediawidgets5 libqt5multimedia5-plugins libqt5multimedia5 libqt5svg5-dev libqt5designer5 libqt5designercomponents5 libqt5xmlpatterns5-dev qttools5-dev
	cd $(REPODIR)/klayout
	./build.sh -qt5 -python python3
	rm -rf $(SWROOT)/klayout
	cp -r bin-release $(SWROOT)/klayout

$(REPODIR)/xschem-gaw:
	git@github.com:StefanSchippers/xschem-gaw.git $(REPODIR)/xschem-gaw

.PHONY: xschem
xschem: $(SWROOT) $(REPODIR)/xschem-gaw
	cd $(REPODIR)/xschem-gaw
	./configure --prefix=$(SWROOT)
	make -j $(nproc)
	$(SUDO) make install

.PHONY: sky130
sky130: $(REPODIR)/open_pdks
	cd $(REPODIR)/open_pdks
	./configure --prefix=$(SWROOT) --enable-sky130-pdk
	make
	$(SUDO) make install

$(REPODIR)/open_pdks:
	git clone git://opencircuitdesign.com/open_pdks $(REPODIR)/open_pdks

.PHONY: vagrant
vagrant:
	cd $(REPODIR)
	$(APT_INSTALL) virtualbox
	curl -O https://releases.hashicorp.com/vagrant/2.2.18/vagrant_2.2.18_x86_64.deb
	$(APT) install ./vagrant_2.2.18_x86_64.deb

.PHONY: clean
clean:
	rm -rf $(REPODIR)
