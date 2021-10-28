.ONESHELL:

# Where to put the source repos
REPO_DIR ?= $(PWD)/repos
# Where to install the binaries
SWROOT ?= $(HOME)/software
# Where to fetch the commercial software (from /software)
HOST=mrg@donut.soe.ucsc.edu
nproc=2

APT_INSTALL=sudo apt install --install-recommends -y

# Options for Trilinos/Xyce
SRCDIR=$(REPO_DIR)/Trilinos
ARCHDIR=$(SWROOT)/XyceLibs/Parallel
FLAGS="-O3 -fPIC"

### Dependencies ###
.PHONY: general
general:
	sudo apt update
	sudo apt upgrade -y
	$(APT_INSTALL) build-essential git ssh vim cmake autoconf automake libtool bison flex libncurses5-dev gdb
	$(APT_INSTALL) libx11-dev libcairo2-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev

	sudo rm /bin/sh && sudo ln -s /bin/bash /bin/sh
# X11
	$(APT_INSTALL) x11-xserver-utils
# Needed to run lmstat
	$(APT_INSTALL) lsb lsb-release lsb-core
# Interactive tools
	$(APT_INSTALL) emacs tmux
# Network debug tools (can be removed to save space)
	$(APT_INSTALL) iputils-ping net-tools lsof wget whois nmap telnet curl dnsutils tcpdump traceroute id-utils

$(REPO_DIR):
	mkdir -p $(REPO_DIR)

$(SWROOT):
	mkdir -p $(SWROOT)

.PHONY: open
open: magic netgen klayout ngspice xyce

.PHONY: commercial
commercial: synopsys cadence mentor

.PHONY: python
python:
# Code stuff for elpy
	$(APT_INSTALL) python3 python3-setuptools python3-pip
	python3 -m pip install jedi autopep8 rope flake8 yapf black 
# Openvpn
#	$(APT_INSTALL) openconnect lib32ncurses5 lib32tinfo5 lib32z1 libc6-i386 libpkcs11-helper1 openvpn vpnc-scripts net-tools

.PHONY: openram
openram:
	$(APT_INSTALL)  python3 python3-numpy python3-scipy python3-pip python3-matplotlib python3-venv

.PHONY: openeda
openeda: $(SWROOT) $(REPO_DIR)
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

$(REPO_DIR)/Trilinos:
	git clone --depth 1 --branch trilinos-release-12-12-1 https://github.com/trilinos/Trilinos.git $(REPO_DIR)/Trilinos

.PHONY: trilinos
trilinos: $(SWROOT) $(REPO_DIR)/Trilinos
	$(APT_INSTALL) libfftw3-dev mpich libblas-dev liblapack-dev libsuitesparse-dev libfl-dev libgtk-3-dev
	cd $(REPO_DIR)/Trilinos
	mkdir -p $(REPO_DIR)/Trilinos/build
	cd $(REPO_DIR)/Trilinos/build
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
	sudo make install

$(REPO_DIR)/Xyce: $(REPO_DIR)/Xyce
	git clone https://github.com/Xyce/Xyce.git $(REPO_DIR)/Xyce

.PHONY: xyce
xyce: trilinos $(REPO_DIR)/Xyce
	cd $(REPO_DIR)/Xyce
	./bootstrap
	mkdir -p $(REPO_DIR)/Xyce/build
	cd $(REPO_DIR)/Xyce/build
	../configure CXXFLAGS="-O3 -std=c++11" \
	ARCHDIR="$(ARCH_DIR)" \
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
	sudo make install

.PHONY: chrome
chrome:
	$(APT_INSTALL) libxss1 libappindicator1 libindicator7
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo apt install ./google-chrome*.deb

$(REPO_DIR)/magic-8.3:
	git clone git://opencircuitdesign.com/magic-8.3 $(REPO_DIR)/magic-8.3

.PHONY: magic
magic: openeda $(REPO_DIR)/magic-8.3
	cd $(REPO_DIR)/magic-8.3
	./configure --prefix=$(SWROOT)
	make
	sudo make install

$(REPO_DIR)/ngspice:
	git clone git://git.code.sf.net/p/ngspice/ngspice $(REPO_DIR)/ngspice

.PHONY: ngspice
ngspice: $(SWROOT) $(REPO_DIR)/ngspice
	$(APT_INSTALL) libxaw7-dev octave
	cd $(REPO_DIR)/ngspice
	./autogen.sh
	./configure \
	--enable-openmp \
	--with-readline \
	--prefix=$(SWROOT)
	make -j $(nproc)
	sudo make install

$(REPO_DIR)/netgen:
	git clone git://opencircuitdesign.com/netgen-1.5 $(REPO_DIR)/netgen

.PHONY: netgen
netgen: openeda $(REPO_DIR)/netgen
	cd $(REPO_DIR)/netgen
	git checkout netgen-1.5
	./configure --prefix=$(SWROOT)
	make -j $(nproc)
	sudo make install

$(REPO_DIR)/klayout:
	git clone https://github.com/KLayout/klayout $(REPO_DIR)/klayout

.PHONY: klayout
klayout: $(SWROOT) $(REPO_DIR)/klayout
	$(APT_INSTALL) qt5-default qtcreator ruby-full ruby-dev python3-dev qtmultimedia5-dev libqt5multimediawidgets5 libqt5multimedia5-plugins libqt5multimedia5 libqt5svg5-dev libqt5designer5 libqt5designercomponents5 libqt5xmlpatterns5-dev qttools5-dev
	cd $(REPO_DIR)/klayout
	./build.sh -qt5 
	cp -r bin-release $(SWROOT)/klayout

$(REPO_DIR)/xschem-gaw:
	git@github.com:StefanSchippers/xschem-gaw.git $(REPO_DIR)/xschem-gaw

.PHONY: xschem
xschem: $(SWROOT) $(REPO_DIR)/xschem-gaw
	cd $(REPO_DIR)/xschem-gaw
	./configure --prefix=$(SWROOT)
	make -j $(nproc)
	sudo make install


.PHONY: repos
repos:
#hostnamectl set-hostname $1
	git clone git@github.com:VLSIDA/PrivateRAM.git openram
	git clone git@github.com:VLSIDA/OpenRAM.git openram-pub
	git clone git@github.com:VLSIDA/openram_testchip.git 
	git clone --recurse-submodules git@github.com:mguthaus/personal.git

.PHONY: vagrant
vagrant:
	cd $(REPO_DIR)
	$(APT_INSTALL) virtualbox
	curl -O https://releases.hashicorp.com/vagrant/2.2.18/vagrant_2.2.18_x86_64.deb
	$(APT) install ./vagrant_2.2.18_x86_64.deb

