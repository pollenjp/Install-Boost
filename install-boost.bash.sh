#!/bin/bash -eux

# [bash - What's a concise way to check that environment variables are set in a Unix shell script? - Stack Overflow](https://stackoverflow.com/a/307735/9316234)
#BOOST_VERSION=1.70.0
: "${BOOST_VERSION:?Need to be set. (ex: '$ BOOST_VERSION=1.70.0 ./xxx.sh')}"
# 'shared' or 'static'
: "${BOOST_LIBS:?Need to be set. 'static' or 'shared' (ex: '$ BOOST_LIBS=shared ./xxx.sh')}"

if [ ${BOOST_LIBS} == "static" ]; then
    BUILD_SHARED_LIBS=OFF
elif [ ${BOOST_LIBS} == "shared" ]; then
    BUILD_SHARED_LIBS=ON
else
    printf "\e[101m %s \e[0m \n" "Variable BOOST_LIBS should be 'static' or 'shared'."
    exit 1
fi

BOOST_DIR=${HOME}/.boost
INSTALL_PREFIX=${BOOST_DIR}/install/boost-${BOOST_VERSION}/${BOOST_LIBS}
if [ -d "${INSTALL_PREFIX}" ]; then
  rm -rf ${INSTALL_PREFIX}
fi
# current working directory
CWD=$(pwd)


#=======================================
# if a directory or a symbolic link does not exist
if [ ! -d ${BOOST_DIR} ] && [ ! -L ${BOOST_DIR} ]; then
  mkdir ${BOOST_DIR}
fi

#=======================================
# clone boost
cd ${BOOST_DIR}
if [ ! -d "${BOOST_DIR}/boost" ]; then
  git clone --recursive git@github.com:boostorg/boost.git
fi

cd "${BOOST_DIR}/boost"
git checkout master
git fetch
git pull --all
git checkout "boost-${BOOST_VERSION}"
cd ${BOOST_DIR}
 
#=======================================
# build
cd "${BOOST_DIR}/boost"
./bootstrap.sh
./b2 \
    link=${BOOST_LIBS} \
    threading=multi \
    variant=release \
    address-model=64 \
    install -j4 --prefix=${INSTALL_PREFIX}

#===============================================================================
# Back to working directory
cd ${CWD}