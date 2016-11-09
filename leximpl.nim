# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
# this file is included by nppnim

proc handleHexChar(sc: var StyleContext) =
  if sc.ch in {'0'..'9', 'a'..'f', 'A'..'F'}: sc.forward()

proc handleDecChars(sc: var StyleContext) =
  while sc.ch in {'0'..'9'}: sc.forward()

proc getEscapedChar(sc: var StyleContext) =
  sc.forward() # skip '\'
  case sc.ch
  of 'n', 'N', 'r', 'R', 'c', 'C', 'l', 'L', 'f', 'F', 'e', 'E', 'a', 'A':
    sc.forward()
  of 'b', 'B', 'v', 'V', 't', 'T', '\'', '\"', '\\':
    sc.forward()
  of 'x', 'X':
    sc.forward()
    handleHexChar(sc)
    handleHexChar(sc)
  of '0'..'9':
    handleDecChars(sc)
  else: discard

proc getCharacter(sc: var StyleContext) =
  sc.setState(NIM_CHAR)
  sc.forward()
  var c = sc.ch
  case c
  of '\0'..pred(' '), '\'': discard
  of '\\': getEscapedChar(sc)
  else: sc.forward()
  sc.forward() # skip '\''
  sc.setState(NIM_DEFAULT)

proc getNumber(sc: var StyleContext) =
  proc matchUnderscoreChars(sc: var StyleContext, chars: set[char]) =
    while sc.more():
      if sc.ch in chars: sc.forward()
      else: break
      if sc.ch == '_':
        if sc.chNext notin chars: break
        sc.forward()

  const baseCodeChars = {'X', 'x', 'o', 'c', 'C', 'b', 'B'}

  # First stage: find out base, make verifications, build token literal string
  sc.setState(NIM_NUMBER)
  if sc.ch == '0' and sc.chNext in baseCodeChars + {'O'}:
    sc.forward()
    case sc.ch
    of 'O': discard
    of 'x', 'X':
      sc.forward()
      matchUnderscoreChars(sc, {'0'..'9', 'a'..'f', 'A'..'F'})
    of 'o', 'c', 'C':
      sc.forward()
      matchUnderscoreChars(sc, {'0'..'7'})
    of 'b', 'B':
      sc.forward()
      matchUnderscoreChars(sc,  {'0'..'1'})
    else:
      discard
  else:
    matchUnderscoreChars(sc, {'0'..'9'})
    if (sc.ch == '.') and (sc.chNext in {'0'..'9'}):
      sc.forward()
      matchUnderscoreChars(sc, {'0'..'9'})
    if sc.ch in {'e', 'E'}:
      sc.forward()
      if sc.ch in {'+', '-'}:
        sc.forward()
      matchUnderscoreChars(sc, {'0'..'9'})

  # Second stage, find out if there's a datatype suffix and handle it
  if sc.ch in {'\'', 'f', 'F', 'd', 'D', 'i', 'I', 'u', 'U'}:
    if sc.ch == '\'': sc.forward()

    case sc.ch
    of 'f', 'F':
      sc.forward()
      while sc.ch in {'0'..'9'}:
        sc.forward()
    of 'd', 'D':  # ad hoc convenience shortcut for f64
      sc.forward()
    of 'i', 'I':
      sc.forward()
      while sc.ch in {'0'..'9'}:
        sc.forward()
    of 'u', 'U':
      sc.forward()
      while sc.ch in {'0'..'9'}:
        sc.forward()
    else:
      discard
  sc.setState(NIM_DEFAULT)

var kw = newStringOfCap(50)
proc GetWordType(L: ptr LexAccessor, start, stop: int): WordType =
  kw.setLen(0)
  for i in start.. <stop:
    kw.add L[][i]
  if support.NimKeywords.contains(kw): return WT_KEYWORD
  if support.NimTypes.contains(kw): return WT_TYPE
  if support.NimCTypes.contains(kw): return WT_CTYPE
  if support.NimMagic.contains(kw): return WT_MAGIC
  result = WT_IDENT

proc getSymbol(sc: var StyleContext) =
  var pos = sc.currentPos
  var styler = sc.styler
  while sc.more():
    var c = styler[][pos]
    case c
    of 'a'..'z', '0'..'9', '\x80'..'\xFF':
      if  c == '\226' and
          styler[][pos+1] == '\128' and
          styler[][pos+2] == '\147':  # It's a 'magic separator' en-dash Unicode
        if styler[][pos + magicIdentSeparatorRuneByteWidth] notin SymChars:
          break
        inc(pos, magicIdentSeparatorRuneByteWidth)
      else:
        inc(pos)
    of 'A'..'Z':
      inc(pos)
    of '_':
      if sc.chNext notin SymChars: break
      inc(pos)
    else: break

  let wt = styler.GetWordType(sc.currentPos, pos)
  if wt == WT_KEYWORD:
    sc.setState(NIM_KEYWORD)
  elif wt == WT_TYPE:
    sc.setState(NIM_TYPE)
  elif wt == WT_CTYPE:
    sc.setState(NIM_CTYPE)
  elif wt == WT_MAGIC:
    sc.setState(NIM_MAGIC)
  else:
    sc.setState(NIM_IDENT)
  sc.forward(pos - sc.currentPos)
  sc.setState(NIM_DEFAULT)

proc getString(sc: var StyleContext, rawMode: bool) =
  sc.forward()          # skip "
  if sc.ch == '\"' and sc.chNext == '\"':
    sc.changeState(NIM_STRING_TRIPLE)
    sc.forward(2)   # skip ""
    return
  else:
    # ordinary string literal
    while sc.more():
      var c = sc.ch
      if c == '\"':
        if rawMode and sc.chNext == '\"':
          sc.forward(2)
        else:
          sc.forward() # skip '"'
          break
      elif c in {'\x0D', '\x0A', chr(0)}:
        break
      elif (c == '\\') and not rawMode:
        sc.getEscapedChar()
      else:
        sc.forward()
  sc.setState(NIM_DEFAULT)

template DEFAULT_STATE_BODY: stmt =
  case sc.ch
  of SymStartChars - {'r', 'R', 'l'}:
    sc.getSymbol()
    continue
  of 'l':
    sc.getSymbol()
    continue
  of 'r', 'R':
    if sc.chNext == '\"':
      sc.setState(NIM_RAW_STRING)
      sc.forward()
      sc.getString(true)
      continue
    else:
      sc.getSymbol()
      continue
  of '#':
    let state = if sc.chNext == '[': NIM_BLOCK_COMMENT else: NIM_LINE_COMMENT
    sc.setState(state)
    sc.forward()
    if sc.ch == '#' and sc.chNext == '[':
      sc.changeState(NIM_DOC_BLOCK_COMMENT)
      sc.forward(2)   # skip ']##
    elif sc.ch == '#' and sc.chNext != '[':
      sc.changeState(NIM_DOC_COMMENT)
      sc.forward(1)
  of '*':
    sc.setState(NIM_STAR)
    sc.forward()
    sc.setState(NIM_DEFAULT)
    continue
  of '\'':
    sc.getCharacter()
    continue
  of '0'..'9':
    sc.getNumber()
    continue
  of '{':
    if sc.chNext == '.': sc.setState(NIM_PRAGMA)
    else:
      sc.setState(NIM_BRACES)
      sc.forward()
      sc.setState(NIM_DEFAULT)
      continue
  of '\"':
    # check for extended raw string literal:
    let rawMode = sc.currentPos > 0 and sc.chPrev in SymChars
    sc.setState(NIM_STRING)
    sc.getString(rawMode)
    continue
  of {'[', '(', '}', ']', ')'}:
    sc.setState(NIM_BRACES)
    sc.forward()
    sc.setState(NIM_DEFAULT)
    continue
  else:
    if sc.ch in OpChars:
      sc.setState(NIM_OPERATOR)
      sc.forward()
      while sc.ch in OpChars:
        sc.forward()
      sc.setState(NIM_DEFAULT)
      continue