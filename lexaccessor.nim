# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
import scintilla, support

const
  extremePosition = 0x7FFFFFFF
  #[ @a bufferSize is a trade off between time taken to copy the characters
        and retrieval overhead.
        @a slopSize positions the buffer before the desired position
        in case there is some backtracking. ]#
  bufferSize = 4000
  slopSize = bufferSize div 8

type
  EncodingType* = enum
    enc8bit, encUnicode, encDBCS

  WSType* = enum
    wsSpace, wsTab, wsSpaceTab, wsInconsistent

  WSTypes* = set[WSType]

  LexAccessor* = object
    pAccess: IDocument
    buf: array[0..bufferSize, char]
    startPos: int
    endPos: int
    codePage: int
    encodingType: EncodingType
    lenDoc: int
    styleBuf: array[0..bufferSize, char]
    validLen: int
    startSeg: int
    startPosStyling: int
    documentVersion: int

proc initLexAccessor*(pAccess: IDocument): LexAccessor =
  result.pAccess = pAccess
  result.startPos = extremePosition
  result.endPos = 0
  result.codePage = pAccess.nvCodePage()
  result.encodingType = enc8bit
  result.lenDoc = pAccess.nvLength()
  result.validLen = 0
  result.startSeg = 0
  result.startPosStyling = 0
  result.documentVersion = pAccess.nvVersion()
  result.buf[0] = chr(0)
  result.styleBuf[0] = chr(0)

  case result.codePage
  of 65001: result.encodingType = encUnicode
  of 932, 936, 949, 950, 1361:
    result.encodingType = encDBCS
  else: result.encodingType = enc8bit

proc fill*(L: var LexAccessor, pos: int) =
  L.startPos = pos - slopSize
  if (L.startPos + bufferSize) > L.lenDoc:
    L.startPos = L.lenDoc - bufferSize

  if L.startPos < 0: L.startPos = 0
  L.endPos = L.startPos + bufferSize
  if L.endPos > L.lenDoc: L.endPos = L.lenDoc
  L.pAccess.nvGetCharRange(cast[cstring](L.buf[0].addr), L.startPos, L.endPos - L.startPos)
  L.buf[L.endPos - L.startPos] = chr(0)

proc `[]`*(L: var LexAccessor, pos: int): char =
  if (pos < L.startPos) or (pos >= L.endPos): L.fill(pos)
  result = L.buf[pos - L.startPos]

# Safe version of operator[], returning a defined value for invalid position.
proc safeGetCharAt*(L: var LexAccessor, pos: int, chDefault = chr(0)): char =
  if (pos < L.startPos) or (pos >= L.endPos): L.fill(pos)
  if (pos < L.startPos) or (pos >= L.endPos):
    # Position is outside range of document
    return chDefault
  result = L.buf[pos - L.startPos]

proc encoding*(L: LexAccessor): EncodingType =
  result = L.encodingType

proc match*(L: var LexAccessor, pos: int, s: cstring): bool =
  var i = 0
  while s[i] != chr(0):
    if s[i] != L.safeGetCharAt((pos + i).int): return false
    inc i
  result = true

proc styleAt*(L: LexAccessor, pos: int): int =
  result = L.pAccess.nvStyleAt(pos).ord

proc getLine*(L: LexAccessor, pos: int): int =
  result = L.pAccess.nvLineFromPosition(pos)

proc lineStart*(L: LexAccessor, line: int): int =
  result = L.pAccess.nvLineStart(line)

proc lineEnd*(L: var LexAccessor, line: int): int =
  if L.documentVersion >= dvLineEnd:
    return cast[IDocumentWithLineEnd](L.pAccess).nvLineEnd(line)
  else:
    #Old interface means only '\r', '\n' and '\r\n' line ends.
    let startNext = L.pAccess.nvLineStart(line + 1)
    let chLineEnd = L.safeGetCharAt(startNext - 1)
    if (chLineEnd == '\x0A') and (L.safeGetCharAt(startNext - 2) == '\r'):
      return startNext - 2
    else:
      return startNext - 1

proc levelAt*(L: LexAccessor, line: int): int =
  result = L.pAccess.nvGetLevel(line)

proc length*(L: LexAccessor): int =
  result = L.lenDoc

proc flush*(L: var LexAccessor) =
  if L.validLen > 0:
    discard L.pAccess.nvSetStyles(L.validLen, cast[cstring](L.styleBuf[0].addr))
    inc(L.startPosStyling, L.validLen)
    L.validLen = 0

proc getLineState*(L: LexAccessor, line: int): int =
  result = L.pAccess.nvGetLineState(line)

proc setLineState*(L: LexAccessor, line: int, state: int) =
  discard L.pAccess.nvSetLineState(line, state)

#Style setting
proc startAt*(L: var LexAccessor, start: int) =
  L.pAccess.nvStartStyling(start, '\xFF')
  L.startPosStyling = start

proc getStartSegment*(L: LexAccessor): int =
  result = L.startSeg

proc startSegment*(L: var LexAccessor, pos: int) =
  L.startSeg = pos

proc colourTo*(L: var LexAccessor, pos: int, chAttr: int) =
  # Only perform styling if non empty range
  if pos != L.startSeg - 1:
    assert(pos >= L.startSeg)
    if pos < L.startSeg: return
    if L.validLen + ((pos - L.startSeg).int + 1) >= bufferSize: L.flush()
    if L.validLen + ((pos - L.startSeg).int + 1) >= bufferSize:
      # Too big for buffer so send directly
      discard L.pAccess.nvSetStyleFor((pos - L.startSeg).int + 1, chAttr.chr)
    else:
      for i in L.startSeg..pos:
        assert((L.startPosStyling + L.validLen) < L.length())
        L.styleBuf[L.validLen] = chr(chAttr)
        inc L.validLen
  L.startSeg = pos + 1

proc setLevel*(L: LexAccessor, line, level: int) =
  discard L.pAccess.nvSetLevel(line, level)

proc changeLexerState*(L: LexAccessor, start, stop: int) =
  L.pAccess.nvChangeLexerState(start, stop)

proc indicatorFill*(L: LexAccessor, start, stop, indicator, value: int) =
  L.pAccess.nvDecorationSetCurrentIndicator(indicator)
  L.pAccess.nvDecorationFillRange(start, value, stop - start)

proc indentAmount*(L: var LexAccessor, line: int, flags: var WSTypes): int =
  var
    stop = L.length()
    spaceFlags: WSTypes
    pos = L.lineStart(line)
    ch = L[pos]
    indent = 0
    inPrevPrefix = line > 0
    posPrev = if inPrevPrefix: L.lineStart(line-1) else: 0

  # Determines the indentation level of the current line and also checks for consistent
  # indentation compared to the previous line.
  # Indentation is judged consistent when the indentation whitespace of each line lines
  # the same or the indentation of one line is a prefix of the other.

  while ((ch == ' ') or (ch == '\t')) and (pos < stop):
    if inPrevPrefix:
      var chPrev = L[posPrev]
      inc posPrev
      if (chPrev == ' ') or (chPrev == '\t'):
        if chPrev != ch: spaceFlags.incl(wsInconsistent)
      else:
        inPrevPrefix = false

    if ch == ' ':
      spaceFlags.incl(wsSpace)
      inc indent
    else: # Tab
      spaceFlags.incl(wsTab)
      if spaceFlags.contains(wsSpace):
        spaceFlags.incl(wsSpaceTab)
      indent = (indent div 8 + 1) * 8

    inc(pos)
    ch = L[pos]

  flags = spaceFlags
  inc(indent, SC_FOLDLEVELBASE)
  # if completely empty line or the start of a comment...

  if (L.lineStart(line) == L.length()) or (ch in {' ', '\t', '\x0A', '\r'}):
    return indent or SC_FOLDLEVELWHITEFLAG
  else:
    return indent
