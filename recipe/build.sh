#!/bin/bash

CUDA=no
if [ "$cuda_impl" == "cuda" ]; then
    CUDA=yes
    # build with c++98
    # export CXXFLAGS=$(echo $CXXFLAGS | sed "s/-std=c++17/-std=c++98/")
    export CPPFLAGS="$CPPFLAGS -std=c++98"
fi
export CUDA

export CMAKE_OPTIONS="-DCMAKE_INSTALL_PREFIX:PATH=${PREFIX}"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

export INSTALL_LIB="${PREFIX}/lib"
export INSTALL_INCLUDE="${PREFIX}/include"

if [ "$blas_impl" == "mkl" ]; then
    export BLAS="-lmkl_rt"
    export LAPACK="-lmkl_rt"
elif [ "$blas_impl" == "openblas" ]; then
    export BLAS="-lopenblas"
    export LAPACK="-lopenblas"
else
    echo "blas_impl undefined in variant or not recognized.  Edit cvxopt's build.sh if you need to add a new supported blas"
fi

# export environment variable so SuiteSparse will use the METIS built above
export MY_METIS_INC="${PREFIX}/include"
export MY_METIS_LIB="-L${PREFIX}/lib -lmetis"

export TBB=-ltbb
export SPQR_CONFIG=-DHAVE_TBB

# (optional) write out various make variables for easier build debugging
make config 2>&1 | tee make_config.txt

# make SuiteSparse
make -j${CPU_COUNT} library
make install

# manually install the static libraries
cp ${SRC_DIR}/AMD/Lib/libamd.a ${PREFIX}/lib
cp ${SRC_DIR}/BTF/Lib/libbtf.a ${PREFIX}/lib
cp ${SRC_DIR}/CAMD/Lib/libcamd.a ${PREFIX}/lib
cp ${SRC_DIR}/CCOLAMD/Lib/libccolamd.a ${PREFIX}/lib
cp ${SRC_DIR}/CHOLMOD/Lib/libcholmod.a ${PREFIX}/lib
cp ${SRC_DIR}/COLAMD/Lib/libcolamd.a ${PREFIX}/lib
cp ${SRC_DIR}/CSparse/Lib/libcsparse.a ${PREFIX}/lib
cp ${SRC_DIR}/CXSparse/Lib/libcxsparse.a ${PREFIX}/lib
cp ${SRC_DIR}/KLU/Lib/libklu.a ${PREFIX}/lib
cp ${SRC_DIR}/LDL/Lib/libldl.a ${PREFIX}/lib
cp ${SRC_DIR}/RBio/Lib/librbio.a ${PREFIX}/lib
cp ${SRC_DIR}/SPQR/Lib/libspqr.a ${PREFIX}/lib
cp ${SRC_DIR}/SuiteSparse_config/libsuitesparseconfig.a ${PREFIX}/lib
cp ${SRC_DIR}/UMFPACK/Lib/libumfpack.a ${PREFIX}/lib

if [ "$cuda_impl" == "cuda" ]; then
    cp ${SRC_DIR}/SuiteSparse_GPURuntime/Lib/libSuiteSparse_GPURuntime.a ${PREFIX}/lib
    cp ${SRC_DIR}/GPUQREngine/Lib/libGPUQREngine.a ${PREFIX}/lib
fi
