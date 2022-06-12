@echo off

if [%1]==[] goto usage

if "%1"=="all" goto nppnim32
if "%1"=="x86" goto nppnim32
if "%1"=="x64" goto nppnim64

:nppnim32
@echo building 32 bit version
SET BASE=release\nppnim32
SET TMPPATH=%PATH%
SET PATH=F:\mingw32\bin;%PATH%
windres -i resource\resource.rc -F pe-i386 -o resource\resource32.o
nim c -d:release --cpu:i386 -o:%BASE%\nppnim.dll nppnim
strip %BASE%\nppnim.dll
7z a -tzip %BASE%\nppnim32.zip %BASE%\nppnim.dll %BASE%\nppnim.xml
SET PATH=%TMPPATH%
if "%1"=="all" goto nppnim64
goto :eof

:nppnim64
@echo building 64 bit version
SET BASE=release\nppnim64
windres -i resource\resource.rc -o resource\resource64.o
nim c -d:release -o:%BASE%\nppnim.dll nppnim
strip %BASE%\nppnim.dll
7z a -tzip %BASE%\nppnim64.zip %BASE%\nppnim.dll %BASE%\nppnim.xml
goto :eof

:usage
@echo Usage: %0 options
@echo x86: buils 32 bit version
@echo x64: build 64 bit version
@echo all: build both 32 bit and 64 bit version
exit /B 1