pushd %~dp0

set OUTDIR=.out32
set WORKDIR=.work32

set PATH=%PATH%;C:\Program Files (x86)\git\bin;C:\Program Files\git\bin

rem cleanup old working and output stuff
rmdir /s /q %OUTDIR%
rmdir /s /q %WORKDIR%

rem sometimes workdir won't be deleted by the time we get here? who knows.
timeout 1

rem prepare working directory for clone and final output directory
mkdir %WORKDIR%
mkdir %OUTDIR%

rem http://stackoverflow.com/questions/13750182/git-how-to-archive-from-remote-repository-directly
cd %WORKDIR%
git clone --depth=1 --single-branch --branch %2 %1 .

rem fix symlinks which dont always come
call ..\run-msys32.bat -mingw32 -here %CD% -c "rm ${PWD}/include/mednafen && ln -s ${PWD}/src ${PWD}/include/mednafen"

rem configure and make
call ..\run-msys32.bat -mingw32 -here %CD% -c "CFLAGS=""-O2 -fomit-frame-pointer -march=i586 -mtune=pentium3"" CXXFLAGS=""$CFLAGS"" CPPFLAGS=""-D_LFS64_LARGEFILE=1"" LDFLAGS=""-static"" ./configure --host=i686-w64-mingw32 --enable-snes-faust && make -j%NUMBER_OF_PROCESSORS%"

rem copy to output and strip
call ..\run-msys32.bat -mingw32 -here %CD% -c "cp src/mednafen.exe ../%OUTDIR% && strip -s ../%OUTDIR%/mednafen.exe"

rem consolidate dependencies
call ..\run-msys32.bat -mingw32 -here %CD% -c "for f in `ldd ../%OUTDIR%/mednafen.exe | grep '/mingw' | awk '{print $3}'`; do cp $f ../%OUTDIR%/; done"

rem final cleanup
timeout 1
rmdir /s /q %WORKDIR%

rem deep fry chinchilla nachos with dill pinecone and strychnine sauce