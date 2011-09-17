#!/bin/bash
set +e

CPUS=`cat /proc/cpuinfo  | grep "processor" | wc -l`
JOBS=$(($CPUS*2+1))

GMP=5.0.2
MPFR=3.0.1
MPC=0.9
BINUTILS=2.21.1
GCC=4.6.1
NEWLIB=1.19.0

PREFIX=/usr/local
TARGET=x86_64-pc-hitomi

CBLACK="\e[[0;30m"
CRED="\e[;31m"
CGREEN="\e[0;32m"
CYELLOW="\e[0;33m"
CBLUE="\e[0;34m"
CPURPLE="\e[0;35m"
CCYAN="\e[0;36m"
CWHITE="\e[0;37m"
CNONE="\e[0m"

echo -e "${CCYAN}Building crosstools for ${CGREEN}${TARGET}${CNONE}"
echo -e "${CYELLOW}Prefix    : ${CGREEN}${PREFIX}${CNONE}"
echo -e "${CYELLOW}Found cpus: ${CGREEN}${CPUS}${CNONE}"
echo -e "${CYELLOW}Make jobs : ${CGREEN}${JOBS}${CNONE}"

rm -rf temp

mkdir -p temp/build-{gmp,mpfr,mpc,binutils,gcc,newlib}

cd temp

echo -e "${CYELLOW}Downloading ${CGREEN}gmp-${GMP}${CNONE}"
wget -cq http://ftp.gnu.org/gnu/gmp/gmp-${GMP}.tar.bz2 || exit 1

echo -e "${CYELLOW}Downloading ${CGREEN}mpfr-${MPFR}${CNONE}"
wget -cq http://www.mpfr.org/mpfr-current/mpfr-${MPFR}.tar.bz2 || exit 1

echo -e "${CYELLOW}Downloading ${CGREEN}mpc-${MPC}${CNONE}"
wget -cq http://www.multiprecision.org/mpc/download/mpc-${MPC}.tar.gz || exit 1

echo -e "${CYELLOW}Downloading ${CGREEN}binutils-${BINUTILS}${CNONE}"
wget -cq http://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS}.tar.bz2 || exit 1

echo -e "${CYELLOW}Downloading ${CGREEN}gcc-core-${GCC}${CNONE}"
wget -cq http://ftp.gnu.org/gnu/gcc/gcc-4.6.1/gcc-core-${GCC}.tar.bz2 || exit 1

echo -e "${CYELLOW}Downloading ${CGREEN}gcc-g++-${GCC}${CNONE}"
wget -cq http://ftp.gnu.org/gnu/gcc/gcc-4.6.1/gcc-g++-${GCC}.tar.bz2 || exit 1

echo -e "${CYELLOW}Downloading ${CGREEN}newlib-${NEWLIB}${CNONE}"
wget -cq ftp://sources.redhat.com/pub/newlib/newlib-${NEWLIB}.tar.gz || exit 1

echo -e "${CYELLOW}Cloning ${CGREEN}gdc ${CYELLOW}repository${CNONE}"
hg clone https://bitbucket.org/goshawk/gdc > /dev/null || exit 1

echo -e "${CYELLOW}Unpacking ${CGREEN}gmp-${GMP}${CNONE}"
tar jxf gmp-${GMP}.tar.bz2 || exit 1
rm gmp-${GMP}.tar.bz2 || exit 1

echo -e "${CYELLOW}Unpacking ${CGREEN}mpfr-${MPFR}${CNONE}"
tar jxf mpfr-${MPFR}.tar.bz2 || exit 1
rm mpfr-${MPFR}.tar.bz2 || exit 1

echo -e "${CYELLOW}Unpacking ${CGREEN}mpc-${MPC}${CNONE}"
tar zxf mpc-${MPC}.tar.gz || exit 1
rm mpc-${MPC}.tar.gz || exit 1

echo -e "${CYELLOW}Unpacking ${CGREEN}binutils-${BINUTILS}${CNONE}"
tar jxf binutils-${BINUTILS}.tar.bz2 || exit 1
rm binutils-${BINUTILS}.tar.bz2 || exit 1

echo -e "${CYELLOW}Unpacking ${CGREEN}gcc-core-${GCC}${CNONE}"
tar jxf gcc-core-${GCC}.tar.bz2 || exit 1
rm gcc-core-${GCC}.tar.bz2 || exit 1

echo -e "${CYELLOW}Unpacking ${CGREEN}gcc-g++-${GCC}${CNONE}"
tar jxf gcc-g++-${GCC}.tar.bz2 || exit 1
rm gcc-g++-${GCC}.tar.bz2 || exit 1

echo -e "${CYELLOW}Unpacking ${CGREEN}newlib-${NEWLIB}${CNONE}"
tar zxf newlib-${NEWLIB}.tar.gz || exit 1
rm newlib-${NEWLIB}.tar.gz || exit 1

echo -e "${CYELLOW}Patching ${CGREEN}binutils-${BINUTILS}${CNONE}"
cd binutils-${BINUTILS}
patch -p1 < ../../binutils-hitomi.patch > /dev/null || exit 1
cd ..

echo -e "${CYELLOW}Patching ${CGREEN}gcc-${GCC}${CNONE}"
cd gcc-${GCC}
patch -p1 < ../../gcc-hitomi.patch > /dev/null || exit 1
ln -s ../../gdc/d gcc/d
./gcc/d/setup-gcc.sh > /dev/null || exit 1
cd ..

echo -e "${CYELLOW}Patching ${CGREEN}newlib-${NEWLIB}${CNONE}"
cd newlib-${NEWLIB}
patch -p1 < ../../newlib-hitomi.patch > /dev/null || exit 1
cd ..

echo -e "${CYELLOW}Patching ${CGREEN}gdc${CNONE}"
cd gdc
patch -p1 < ../../gdc-hitomi.patch > /dev/null || exit 1
cd ..

echo -e "${CYELLOW}Building ${CGREEN}gmp-${GMP}${CNONE}"
cd build-gmp
echo -e "  ${CCYAN}configure${CNONE}"
../gmp-${GMP}/configure --prefix=$PREFIX > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make${CNONE}"
make -j${JOBS} > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make install${CNONE}"
sudo make install > /dev/null 2>&1 || exit 1
cd ..

echo -e "${CYELLOW}Building ${CGREEN}mpfr-${MPFR}${CNONE}"
cd build-mpfr
echo -e "  ${CCYAN}configure${CNONE}"
../mpfr-${MPFR}/configure --prefix=$PREFIX --with-gmp=$PREFIX > /dev/null 2>&1 \
|| exit 1
echo -e "  ${CCYAN}make${CNONE}"
make -j${JOBS} > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make install${CNONE}"
sudo make install > /dev/null 2>&1 || exit 1
cd ..

echo -e "${CYELLOW}Building ${CGREEN}mpc-${MPC}${CNONE}"
cd build-mpc
echo -e "  ${CCYAN}configure${CNONE}"
../mpc-${MPC}/configure --prefix=$PREFIX --with-gmp=$PREFIX \
--with-mpfr=$PREFIX > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make${CNONE}"
make -j${JOBS} > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make install${CNONE}"
sudo make install > /dev/null 2>&1 || exit 1
cd ..

echo -e "${CYELLOW}Building ${CGREEN}binutils-${BINUTILS}${CNONE}"
cd build-binutils
echo -e "  ${CCYAN}configure${CNONE}"
../binutils-${BINUTILS}/configure --disable-nls --prefix=$PREFIX \
--target=$TARGET --with-gmp=$PREFIX --with-mpfr=$PREFIX --with-mpc=$PREFIX \
--disable-werror --disable-multilib > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make all${CNONE}"
make -j${JOBS} all > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make install${CNONE}"
sudo make install > /dev/null 2>&1 || exit 1
cd ..

echo -e "${CYELLOW}Building ${CGREEN}gcc-${GCC}${CNONE}"
cd build-gcc
echo -e "  ${CCYAN}configure${CNONE}"
../gcc-${GCC}/configure --prefix=$PREFIX --target=$TARGET --disable-nls \
--with-gmp=$PREFIX --with-mpfr=$PREFIX --with-mpc=$PREFIX --disable-werror \
--enable-languages=c,c++,d --disable-multilib --disable-shared \
--enable-linker-build-id --enable-clocale=gnu --enable-plugin --enable-gold \
--enable-ld=default --with-plugin-ld=ld.gold > /dev/null 2>&1  || exit 1
echo -e "  ${CCYAN}make all-gcc${CNONE}"
make -j${JOBS} all-gcc > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make install-gcc${CNONE}"
sudo make install-gcc > /dev/null 2>&1 || exit 1
cd ..

echo -e "${CYELLOW}Building ${CGREEN}newlib-${NEWLIB}${CNONE}"
cd build-newlib
echo -e "  ${CCYAN}configure${CNONE}"
../newlib-${NEWLIB}/configure --prefix=$PREFIX --target=$TARGET --disable-nls \
--with-gmp=$PREFIX --with-mpfr=$PREFIX --with-mpc=$PREFIX --disable-werror \
--enable-newlib-hw-fp > /dev/null 2>&1  || exit 1
echo -e "  ${CCYAN}make${CNONE}"
make -j${JOBS} all > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make install${CNONE}"
sudo make install > /dev/null 2>&1 || exit 1
cd ..

echo -e "${CYELLOW}Building ${CGREEN}gcc-${GCC}${CNONE}"
cd build-gcc
echo -e "  ${CCYAN}make all-target-libgcc${CNONE}"
make -j${JOBS} all-target-libgcc > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make install-target-libgcc${CNONE}"
sudo make install-target-libgcc > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make all-target-libstdc++-v3${CNONE}"
make -j${JOBS} all-target-libstdc++-v3 > /dev/null 2>&1 || exit 1
echo -e "  ${CCYAN}make install-target-libstdc++-v3${CNONE}"
sudo make install-target-libstdc++-v3 > /dev/null 2>&1 || exit 1
cd ..

