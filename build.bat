rmdir /S /Q build
mkdir build

cd build
cmake -G "Unix Makefiles" --toolchain ../arm-none-eabi-gcc.cmake  -DCMAKE_BUILD_TYPE=DEBUG -DNDEBUG=1 ..
cls
cmake --build . -j16
cd .. 