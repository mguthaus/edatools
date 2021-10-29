
export SWROOT=${SWROOT:-'/software'}

export LM_LICENSE_FILE=27000@license.soe.ucsc.edu

# Calibre
export USE_CALIBRE_VCO=aoi
export CALIBRE_HOME=$SWROOT/mentor/calibre/aoi_cal_2017.3_29.23
export MGC_HOME=$CALIBRE_HOME
export MGC_TMPDIR=/tmp
export CALIBREPATH=$CALIBRE_HOME/bin
export PATH=$PATH:$CALIBREPATH

# Hspice
export PATH=$PATH:$SWROOT/synopsys/hspice/bin

# Virtuoso
export ICHOME=$SWROOT/cadence/IC617
export ICPATH=$ICHOME/tools/bin:$ICHOME/tools/dfII/bin
export PATH=$PATH:$ICPATH
export CDS_AUTO_64BIT=ALL
export W3264_NO_HOST_CHECK=1
export OA_UNSUPPORTED_PLAT=linux_rhel50_gcc48x
export CDS_Netlisting_Mode=Analog
#export CDS_SITE=$CDK_DIR
#export SYSTEM_CDS_LIB_DIR=$CDK_DIR/cdssetup
export SKIP_CDSLIB_MANAGER=
if [ -z "$LD_LIBRARY_PATH" ]; then
        export LD_LIBRARY_PATH=$SWROOT/cadence/ic/share/oa/lib/linux_rhel50_gcc48x_64/opt:$SWROOT/cadence/ic/share/oa/lib/linux_rhel50_gcc48x_32/opt
else
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SWROOT/cadence/ic/share/oa/lib/linux_rhel50_gcc48x_64/opt:$SWROOT/cadence/ic/share/oa/lib/linux_rhel50_gcc48x_32/opt
fi
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# ICC
export ICC_HOME=$SWROOT/synopsys/icc
export ICCPATH=$ICC_HOME/bin
export PATH=$PATH:$ICCPATH

# DC
export SYN_HOME=$SWROOT/synopsys/syn
export SYNPATH=$SYN_HOME/bin
export PATH=$PATH:$SYNPATH
export SYNOPSYS=$SWROOT/synopsys

# LC
export LC_HOME=$SWROOT/synopsys/lc
export LCPATH=$LC_HOME/bin
export PATH=$PATH:$LCPATH

# Innovus
export INNOVUS_HOME=$SWROOT/cadence/innovus
export INNOVUS_PATH=$INNOVUS_HOME/bin
export PATH=$PATH:$INNOVUS_PATH

# Cosmoscope
export CSCOPE_HOME=$SWROOT/synopsys/cscope64
export CSCOPE_PATH=$CSCOPE_HOME/ai_bin
export PATH=$PATH:$CSCOPE_PATH

# Klayout
export KLAYOUT_PATH=/usr/local/klayout
export XDG_RUNTIME_DIR=/tmp/runtime-$USER
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$KLAYOUT_PATH
export PATH=$PATH:$KLAYOUT_PATH

# xschem-gaw
export PATH=$PATH:/usr/local/bin

# Xyce
# Xyce
export XYCE_HOME=$SWROOT/Xyce/Parallel
export XYCE_PATH=$XYCE_HOME/bin
export PATH=$PATH:$XYCE_PATH
export XYCE_LIB=$XYCE_HOME/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$XYCE_LIB
export XYCE_NO_TRACKING="anything at all"

# PDKs
export FREEPDK45=$SWROOT/PDKs/FreePDK45
export FREEPDK15=$SWROOT/PDKs/FreePDK15
#export ASAP7=$HOME/ASAP7_PDKandLIB_v1p5/asap7PDK_r1p5
# Set to the PDK you want to use
export PDK_DIR=$FREEPDK15

# OpenRAM
export OPENRAM_HOME=$HOME/openram/compiler
export OPENRAM_TECH=$HOME/openram/technology:$HOME/data/sky130_fd_bd_sram/tools/openram/technology

#Skywater
export SW_PDK_ROOT=$HOME/data/skywater-src-nda
export PDK_HOME=$SW_PDK_ROOT/s8/V2.0.1
export SW_IP_HOME=$SW_PDK_ROOT/s8_ip
export METAL_STACK="s8phirs_10r"
export PDK_ROOT=$SWROOT/share/pdk
#export NDA_PDK_ROOT=$HOME/data/skywater-src-nda/s8/V2.0.1

export PDK_MODEL_HOME=$PDK_HOME
export DEVICELIB_ROOT=$PDK_HOME/VirtuosoOA/libs

export TECHDIR=$PDK_HOME
export TECHDIR_DRC=$PDK_HOME/DRC/Calibre
export TECHDIR_LVS=$PDK_HOME/LVS/Calibre

export CDS_Netlisting_Mode=Analog
export CDS_AUTO_64BIT=ALL
export CDS_AHDLCMI_ENABLE=YES
#export SOS_CDS_EXIT=YES
#export LBS_BASE_SYSTEM=LBS_SGE
export CDS_QUIET=0
