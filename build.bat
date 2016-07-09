pushd %~dp0

set OUTDIR=.out
set WORKDIR=.work

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
git clone --depth=1 --single-branch --branch master %1 .

rem fix symlinks which dont always come
rem TODO: delete existing symlink, in case it's there?
call ..\run-msys.bat -mingw64 -here %CD% -c "ln -s ${PWD}/src ${PWD}/include/mednafen"

rem configure and make
call ..\run-msys.bat -mingw64 -here %CD% -c "CFLAGS=""-O2 -fomit-frame-pointer -mtune=amdfam10"" CXXFLAGS=""$CFLAGS"" CPPFLAGS=""-D_LFS64_LARGEFILE=1"" LDFLAGS=""-static"" ./configure --host=x86_64-w64-mingw32 --enable-snes-faust && make -j%NUMBER_OF_PROCESSORS%"

rem copy to output and strip
call ..\run-msys.bat -mingw64 -here %CD% -c "cp src/mednafen.exe ../.out && strip -s ../.out/mednafen.exe"

rem consolidate dependencies
call ..\run-msys.bat -mingw64 -here %CD% -c "for f in `ldd ../.out/mednafen.exe | grep '/mingw' | awk '{print $3}'`; do cp $f ../.out/; done"

rem final cleanup
timeout 1
rmdir /s /q %WORKDIR%