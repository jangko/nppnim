# nppnim
a notepad++ plugin contains lexer for Nim lang

requirements(for notepad++ 32bit):

  * Nim32
  * MingW32
  
how to compile:
  * nim c -d:release nppnim
  
how to test:
  * put nppnim.dll in NPPINSTDIR\plugins
  * put nppnim.xml in NPPINSTDIR\plugins\config

beware:
  if there exist more than one npp plugin written in Nim, please use compiler switch "-d:useNimRtl", (I never tested it before, but the doc says like that)