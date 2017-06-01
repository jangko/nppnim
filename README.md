# nppnim
a notepad++ plugin contains syntax highlighter and code folding for Nim lang

- - -

After I removed the cpp stuff, this plugin now written 100% in Nim.
This means this plugin also can serve as a model for anyone who want to write their own plugin
compatible with recent notepad++ in any language that can produce a DLL.

requirements(for notepad++ 32bit):
  * Nim32/64bit
  * MinGW-w64 or MingGW32 ~~or VCC 32bit~~
  
(ironically, although VCC can compile this plugin, notepad++ reject it for some unknown reason)

how to compile:
  * nim c -d:release nppnim
  
how to cross compile using 64bit Nim compiler:
  * nim c -d:release --cpu:i386 --passL:-m32 --passC:-m32 nppnim
  
how to test:
  * put nppnim.dll in NPPINSTDIR\plugins
  * put nppnim.xml in NPPINSTDIR\plugins\config

beware:
  if there exist more than one npp plugin written in Nim, please use compiler switch "-d:useNimRtl", 
  (I never tested it before, but the documentation says like that)
  
download:
  * Precompiled binaries can be downloaded [here](https://github.com/jangko/nppnim/releases)
