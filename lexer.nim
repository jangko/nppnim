import strutils, nimlexbase, scintilla, support, etcpriv, sets

const
  numChars*: set[char] = {'0'..'9', 'a'..'z', 'A'..'Z'}
  SymChars*: set[char] = {'a'..'z', 'A'..'Z', '0'..'9', '\x80'..'\xFF'}
  SymStartChars*: set[char] = {'a'..'z', 'A'..'Z', '\x80'..'\xFF'}
  OpChars*: set[char] = {'+', '-', '*', '/', '\\', '<', '>', '!', '?', '^', '.',
    '|', '=', '%', '&', '$', '@', '~', ':', '\x80'..'\xFF'}

type
  TLexer* = object of TBaseLexer
  
  StyleType* = enum
    TS_NONE, TS_NUMBER, TS_STRING, TS_CHAR, TS_KEYWORD, 
    TS_IDENT, TS_COMMENT, TS_MULTILINECOMMENT, TS_OPERATOR,
    TS_EOF
    
  TStyle* = object
    start*, stop*: int
    style*: StyleType

proc openLexer*(lex: var TLexer, doc: IDocument, startPos, docLen: int) =
  openBaseLexer(lex, doc, startPos, docLen)
  
proc closeLexer*(lex: var TLexer) =
  closeBaseLexer(lex)

template eatChar(L: var TLexer) =
  inc(L.bufpos)

template eatChar(L: var TLexer) =
  inc(L.bufpos)

proc getNumber(L: var TLexer, ts: var TStyle) =
  proc matchUnderscoreChars(L: var TLexer, chars: set[char]) =
    var pos = L.bufpos
    var buf = L.buf
    while true:
      if buf[pos] in chars:
        inc(pos)
      else:
        break
      if buf[pos] == '_':
        if buf[pos+1] notin chars:
          break
        inc(pos)
    L.bufpos = pos
  
  var
    startpos, endpos: int
    isBase10 = true
  const
    baseCodeChars = {'X', 'x', 'o', 'c', 'C', 'b', 'B'}
  startpos = L.bufpos

  # First stage: find out base, make verifications, build token literal string
  if L.buf[L.bufpos] == '0' and L.buf[L.bufpos + 1] in baseCodeChars + {'O'}:
    isBase10 = false
    eatChar(L)
    case L.buf[L.bufpos]
    of 'O':
      discard
    of 'x', 'X':
      eatChar(L)
      matchUnderscoreChars(L, {'0'..'9', 'a'..'f', 'A'..'F'})
    of 'o', 'c', 'C':
      eatChar(L)
      matchUnderscoreChars(L, {'0'..'7'})
    of 'b', 'B':
      eatChar(L)
      matchUnderscoreChars(L,  {'0'..'1'})
    else:
      discard
  else:
    matchUnderscoreChars(L, {'0'..'9'})
    if (L.buf[L.bufpos] == '.') and (L.buf[L.bufpos + 1] in {'0'..'9'}):
      eatChar(L)
      matchUnderscoreChars(L, {'0'..'9'})
    if L.buf[L.bufpos] in {'e', 'E'}:
      eatChar(L)
      if L.buf[L.bufpos] in {'+', '-'}:
        eatChar(L)
      matchUnderscoreChars(L,{'0'..'9'})
  endpos = L.bufpos

  # Second stage, find out if there's a datatype suffix and handle it
  var postPos = endpos
  if L.buf[postPos] in {'\'', 'f', 'F', 'd', 'D', 'i', 'I', 'u', 'U'}:
    if L.buf[postPos] == '\'':
      inc(postPos)

    case L.buf[postPos]
    of 'f', 'F':
      inc(postPos)
      if (L.buf[postPos] == '3') and (L.buf[postPos + 1] == '2'):
        inc(postPos, 2)
      elif (L.buf[postPos] == '6') and (L.buf[postPos + 1] == '4'):
        inc(postPos, 2)
      elif (L.buf[postPos] == '1') and
           (L.buf[postPos + 1] == '2') and
           (L.buf[postPos + 2] == '8'):
         inc(postPos, 3)
      else:   # "f" alone defaults to float32
        discard
    of 'd', 'D':  # ad hoc convenience shortcut for f64
      inc(postPos)
    of 'i', 'I':
      inc(postPos)
      if (L.buf[postPos] == '6') and (L.buf[postPos + 1] == '4'):
        inc(postPos, 2)
      elif (L.buf[postPos] == '3') and (L.buf[postPos + 1] == '2'):
        inc(postPos, 2)
      elif (L.buf[postPos] == '1') and (L.buf[postPos + 1] == '6'):
        inc(postPos, 2)
      elif (L.buf[postPos] == '8'):
        inc(postPos)
      else:
        discard
    of 'u', 'U':
      inc(postPos)
      if (L.buf[postPos] == '6') and (L.buf[postPos + 1] == '4'):
        inc(postPos, 2)
      elif (L.buf[postPos] == '3') and (L.buf[postPos + 1] == '2'):
        inc(postPos, 2)
      elif (L.buf[postPos] == '1') and (L.buf[postPos + 1] == '6'):
        inc(postPos, 2)
      elif (L.buf[postPos] == '8'):
        inc(postPos)
      else:
        discard
    else:
      discard
  
  L.bufpos = postPos
  ts.start = startpos
  ts.stop = postPos
  ts.style = TS_NUMBER
  
proc handleHexChar(L: var TLexer) =
  case L.buf[L.bufpos]
  of '0'..'9':
    inc(L.bufpos)
  of 'a'..'f':
    inc(L.bufpos)
  of 'A'..'F':
    inc(L.bufpos)
  else: discard

proc handleDecChars(L: var TLexer) =
  while L.buf[L.bufpos] in {'0'..'9'}:
    inc(L.bufpos)

proc getEscapedChar(L: var TLexer) =
  inc(L.bufpos) # skip '\'
  case L.buf[L.bufpos]
  of 'n', 'N':
    inc(L.bufpos)
  of 'r', 'R', 'c', 'C':
    inc(L.bufpos)
  of 'l', 'L':
    inc(L.bufpos)
  of 'f', 'F':
    inc(L.bufpos)
  of 'e', 'E':
    inc(L.bufpos)
  of 'a', 'A':
    inc(L.bufpos)
  of 'b', 'B':
    inc(L.bufpos)
  of 'v', 'V':
    inc(L.bufpos)
  of 't', 'T':
    inc(L.bufpos)
  of '\'', '\"':
    inc(L.bufpos)
  of '\\':
    inc(L.bufpos)
  of 'x', 'X':
    inc(L.bufpos)
    handleHexChar(L)
    handleHexChar(L)
  of '0'..'9':
    handleDecChars(L)
  else: discard

proc handleCRLF(L: var TLexer, pos: int): int =
  case L.buf[pos]
  of CR:
    result = nimlexbase.handleCR(L, pos)
  of LF:
    result = nimlexbase.handleLF(L, pos)
  else: result = pos

proc getString(L: var TLexer, ts: var TStyle, rawMode: bool) =
  ts.start = L.bufpos
  var pos = L.bufpos + 1          # skip "
  var buf = L.buf                 # put `buf` in a register
  var line = L.lineNumber         # save linenumber for better error message
  if buf[pos] == '\"' and buf[pos+1] == '\"':
    inc(pos, 2)               # skip ""
    # skip leading newline:
    if buf[pos] in {' ', '\t'}:
      var newpos = pos+1
      while buf[newpos] in {' ', '\t'}: inc newpos
      if buf[newpos] in {CR, LF}: pos = newpos
    pos = handleCRLF(L, pos)
    buf = L.buf
    while true:
      case buf[pos]
      of '\"':
        if buf[pos+1] == '\"' and buf[pos+2] == '\"' and
            buf[pos+3] != '\"':
          L.bufpos = pos + 3 # skip the three """
          break
        inc(pos)
      of CR, LF:
        pos = handleCRLF(L, pos)
        buf = L.buf
      of nimlexbase.EndOfFile:
        var line2 = L.lineNumber
        L.lineNumber = line
        L.lineNumber = line2
        L.bufpos = pos
        break
      else:
        inc(pos)
  else:
    # ordinary string literal
    while true:
      var c = buf[pos]
      if c == '\"':
        if rawMode and buf[pos+1] == '\"':
          inc(pos, 2)
        else:
          inc(pos) # skip '"'
          break
      elif c in {CR, LF, nimlexbase.EndOfFile}:
        break
      elif (c == '\\') and not rawMode:
        L.bufpos = pos
        getEscapedChar(L)
        pos = L.bufpos
      else:
        inc(pos)
    L.bufpos = pos
  ts.stop = pos
  ts.style = TS_STRING

proc getCharacter(L: var TLexer, ts: var TStyle) =
  ts.start = L.bufpos
  inc(L.bufpos)               # skip '
  var c = L.buf[L.bufpos]
  case c
  of '\0'..pred(' '), '\'': discard
  of '\\': getEscapedChar(L)
  else:
    inc(L.bufpos)
  if L.buf[L.bufpos] != '\'': discard
  inc(L.bufpos)               # skip '
  ts.stop = L.bufpos
  ts.style = TS_CHAR

var kw = newStringOfCap(50)
proc isKeyword(L: var TLexer, start, stop: int): bool =
  if (stop-start) > kw.len: kw.setLen(stop-start)
  for i in start..stop:
    kw.add L.buf[i]
  if support.Keywords.contains(kw): return true
  result = false
  
proc getSymbol(L: var TLexer, ts: var TStyle) =
  var pos = L.bufpos
  var buf = L.buf
  while true:
    var c = buf[pos]
    case c
    of 'a'..'z', '0'..'9', '\x80'..'\xFF':
      if  c == '\226' and
          buf[pos+1] == '\128' and
          buf[pos+2] == '\147':  # It's a 'magic separator' en-dash Unicode
        if buf[pos + magicIdentSeparatorRuneByteWidth] notin SymChars:
          break
        inc(pos, magicIdentSeparatorRuneByteWidth)
      else:
        inc(pos)
    of 'A'..'Z':
      c = chr(ord(c) + (ord('a') - ord('A'))) # toLower()
      inc(pos)
    of '_':
      if buf[pos+1] notin SymChars:
        break
      inc(pos)
    else: break
    
  ts.start = L.bufpos
  ts.stop = pos
  if L.isKeyword(ts.start, ts.stop):
    ts.style = TS_KEYWORD
  else:
    ts.style = TS_IDENT
  L.bufpos = pos
  
proc endOperator(L: var TLexer, ts: var TStyle, pos: int) {.inline.} =
  ts.start = L.bufpos
  ts.stop = pos
  ts.style = TS_OPERATOR
  L.bufpos = pos

proc getOperator(L: var TLexer, ts: var TStyle) =
  var pos = L.bufpos
  var buf = L.buf
  while true:
    var c = buf[pos]
    if c notin OpChars: break
    inc(pos)
  endOperator(L, ts, pos)
  # advance pos but don't store it in L.bufpos so the next token (which might
  # be an operator too) gets the preceding spaces:
  while buf[pos] == ' ':
    inc pos

proc skipMultiLineComment(L: var TLexer; ts: var TStyle; start: int) =
  var pos = start
  var buf = L.buf
  var nesting = 0
  while true:
    case buf[pos]
    of '#':
      if buf[pos+1] == '[':
        inc nesting
      inc pos
    of ']':
      if buf[pos+1] == '#':
        if nesting == 0:
          inc(pos, 2)
          break
        dec nesting
      inc pos
    of '\t':
      inc(pos)
    of CR, LF:
      pos = handleCRLF(L, pos)
      buf = L.buf
    of nimlexbase.EndOfFile:
      break
    else:
      inc(pos)
  L.bufpos = pos
  ts.start = start
  ts.stop = pos
  ts.style = TS_MULTILINECOMMENT

proc scanComment(L: var TLexer, ts: var TStyle) =
  var pos = L.bufpos
  var buf = L.buf
  when not defined(nimfix):
    assert buf[pos+1] == '#'
    if buf[pos+2] == '[':
      skipMultiLineComment(L, ts, pos+3)
      return
    inc(pos, 2)

  var toStrip = 0
  while buf[pos] == ' ':
    inc pos
    inc toStrip

  while true:
    var lastBackslash = -1
    while buf[pos] notin {CR, LF, nimlexbase.EndOfFile}:
      if buf[pos] == '\\': lastBackslash = pos+1
      inc(pos)

    pos = handleCRLF(L, pos)
    buf = L.buf
    var indent = 0
    while buf[pos] == ' ':
      inc(pos)
      inc(indent)

    template doContinue(): expr =
      buf[pos] == '#' and buf[pos+1] == '#'
    if doContinue():
      inc(pos, 2)
      var c = toStrip
      while buf[pos] == ' ' and c > 0:
        inc pos
        dec c
    else:
      break
  ts.start = L.bufpos
  ts.stop = pos
  ts.style = TS_COMMENT
  L.bufpos = pos

proc skip(L: var TLexer, ts: var TStyle) =
  var pos = L.bufpos
  var buf = L.buf
  while true:
    case buf[pos]
    of ' ':
      inc(pos)
    of '\t':
      inc(pos)
    of CR, LF:
      pos = handleCRLF(L, pos)
      buf = L.buf
      while true:
        if buf[pos] == ' ':
          inc(pos)
        elif buf[pos] == '#' and buf[pos+1] == '[':
          skipMultiLineComment(L, ts, pos+2)
          pos = L.bufpos
          buf = L.buf
        else:
          break
      template doBreak(): expr =
        buf[pos] > ' ' and (buf[pos] != '#' or buf[pos+1] == '#')
      if doBreak():
        break
    of '#':
      # do not skip documentation comment:
      if buf[pos+1] == '#': break
      if buf[pos+1] == '[':
        skipMultiLineComment(L, ts, pos+2)
        pos = L.bufpos
        buf = L.buf
      else:
        while buf[pos] notin {CR, LF, nimlexbase.EndOfFile}: inc(pos)
    else:
      break                   # EndOfFile also leaves the loop
  L.bufpos = pos

proc rawGetTok*(L: var TLexer, ts: var TStyle) =
  ts.style = TS_NONE
  ts.start = L.bufpos
  ts.stop = L.bufpos
  skip(L, ts)
  var c = L.buf[L.bufpos]
  if c in SymStartChars - {'r', 'R', 'l'}:
    getSymbol(L, ts)
  else:
    case c
    of '#':
      scanComment(L, ts)
    of '*':
      # '*:' is unfortunately a special case, because it is two tokens in
      # 'var v*: int'.
      if L.buf[L.bufpos+1] == ':' and L.buf[L.bufpos+2] notin OpChars:
        endOperator(L, ts, L.bufpos+1)
      else:
        getOperator(L, ts)
    of ',':
      inc(L.bufpos)
    of 'l':
      getSymbol(L, ts)
    of 'r', 'R':
      if L.buf[L.bufpos + 1] == '\"':
        inc(L.bufpos)
        getString(L, ts, true)
      else:
        getSymbol(L, ts)
    of '(':
      inc(L.bufpos)
      if L.buf[L.bufpos] == '.' and L.buf[L.bufpos+1] != '.':
        inc(L.bufpos)      
    of ')':
      inc(L.bufpos)
    of '[':
      inc(L.bufpos)
      if L.buf[L.bufpos] == '.' and L.buf[L.bufpos+1] != '.':
        inc(L.bufpos)
    of ']':
      inc(L.bufpos)
    of '.':
      if L.buf[L.bufpos+1] == ']':
        inc(L.bufpos, 2)
      elif L.buf[L.bufpos+1] == '}':
        inc(L.bufpos, 2)
      elif L.buf[L.bufpos+1] == ')':
        inc(L.bufpos, 2)
      else:
        getOperator(L, ts)
    of '{':
      inc(L.bufpos)
      if L.buf[L.bufpos] == '.' and L.buf[L.bufpos+1] != '.':
        inc(L.bufpos)
    of '}':
      inc(L.bufpos)
    of ';':
      inc(L.bufpos)
    of '`':
      inc(L.bufpos)
    of '_':
      inc(L.bufpos)
    of '\"':
      # check for extended raw string literal:
      var rawMode = L.bufpos > 0 and L.buf[L.bufpos-1] in SymChars
      getString(L, ts, rawMode)
    of '\'':
      getCharacter(L, ts)
    of '0'..'9':
      getNumber(L, ts)
    else:
      if c in OpChars:
        getOperator(L, ts)
      elif c == nimlexbase.EndOfFile:
        ts.style = TS_EOF
      else:
        inc(L.bufpos)
