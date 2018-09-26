
Robocopy "%SRC_DIR%\SuiteSparse-to-move" "%SRC_DIR%\SuiteSparse" /E /S /MOV

set "CMAKE_INCLUDE_PATH=%LIBRARY_INC%"
set "CMAKE_LIBRARY_PATH=%LIBRARY_LIB%"

if "%with_cuda%"" == "true"
(
      set "CMAKE_WITH_CUDA=ON"
)
else
(
      set "CMAKE_WITH_CUDA=OFF"
)

mkdir build
pushd build
:: Configure step.
cmake -G "%CMAKE_GENERATOR%" ^
      -D CMAKE_BUILD_TYPE:STRING=RELEASE ^
      -D CMAKE_PREFIX_PATH:PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON ^
      -D BUILD_METIS=OFF ^
      -D SUITESPARSE_USE_CUSTOM_BLAS_LAPACK_LIBS=ON  ^
      -D SUITESPARSE_CUSTOM_BLAS_LIB=%LIBRARY_LIB:\=/%/mkl_rt.lib    ^
      -D SUITESPARSE_CUSTOM_LAPACK_LIB=%LIBRARY_LIB:\=/%/mkl_rt.lib  ^
      -D WITH_CUDA:BOOL=%CMAKE_WITH_CUDA% ^
      ..
if errorlevel 1 exit 1

:: Build C libraries and tools.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
popd
