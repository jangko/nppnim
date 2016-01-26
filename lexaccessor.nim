import ilexer, scintilla

const
  extremePosition = 0x7FFFFFFF
  #[ @a bufferSize is a trade off between time taken to copy the characters
        and retrieval overhead.
        @a slopSize positions the buffer before the desired position
        in case there is some backtracking. ]#
  bufferSize = 4000
  slopSize = bufferSize div 8
  
type
  EncodingType = enum
    enc8bit, encUnicode, encDBCS
    
  LexAccessor* = ref object
    pAccess: ptr IDocument
    buf: array[0..bufferSize, char]
    startPos: Sci_Position
    endPos: Sci_Position
    codePage: int
    encodingType: EncodingType
    lenDoc: Sci_Position
    styleBuf: array[0..bufferSize, char]
    validLen: Sci_Position
    startSeg: Sci_PositionU
    startPosStyling: Sci_Position
    documentVersion: int

proc newLexAccessor*(pAccess: ptr IDocument): LexAccessor =
  new(result)
  result.pAccess = pAccess
  result.startPos = extremePosition
  result.endPos = 0
  result.codePage = pAccess.codePage()
  result.encodingType = enc8bit
  result.lenDoc = pAccess.length()
  result.validLen = 0
  result.startSeg = 0
  result.startPosStyling = 0
  result.documentVersion = pAccess.version()
  
  #Prevent warnings by static analyzers about uninitialized buf and styleBuf.
  result.buf[0] = chr(0)
  result.styleBuf[0] = chr(0)
  
  case result.codePage
  of 65001: result.encodingType = encUnicode
  of 932, 936, 949, 950, 1361:
    result.encodingType = encDBCS
  else: result.encodingType = enc8bit
  
proc fill*(L: LexAccessor, pos: Sci_Position) =
  L.startPos = pos - slopSize
  if (L.startPos + bufferSize) > L.lenDoc:
    L.startPos = L.lenDoc - bufferSize
  
  if L.startPos < 0: L.startPos = 0
  L.endPos = L.startPos + bufferSize
  if L.endPos > L.lenDoc: L.endPos = L.lenDoc
  L.pAccess.getCharRange(L.buf, L.startPos, L.endPos - L.startPos)
  L.buf[L.endPos - L.startPos] = chr(0)
  
proc `[]`*(L: LexAccessor, pos: Sci_Position): char =
  if (pos < L.startPos) or (pos >= L.endPos): L.fill(pos)
  result = L.buf[pos - L.startPos]

proc multiByteAccess*(L: LexAccessor): ptr IDocumentWithLineEnd =
  if L.documentVersion >= dvLineEnd:
    return cast[ptr IDocumentWithLineEnd](L.pAccess)
  result = nil

# Safe version of operator[], returning a defined value for invalid position.
proc safeGetCharAt*(L: LexAccessor, pos: Sci_Position, chDefault = ' '): char =
  if (pos < L.startPos) or (pos >= L.endPos): L.fill(pos)
  if (pos < L.startPos) or (pos >= L.endPos):
    # Position is outside range of document
    return chDefault
  result = L.buf[pos - L.startPos]

proc isLeadByte*(L: LexAccessor, ch: char): bool =
  result = L.pAccess.isDBCSLeadByte(ch)
  
proc encoding*(L: LexAccessor): EncodingType =
  result = L.encodingType

proc match*(L: LexAccessor, pos: Sci_Position, s: cstring): bool =
  var i = 0
  while s[i] != chr(0):
    if s[i] != L.safeGetCharAt((pos + i).Sci_Position): return false
    inc i
  result = true

proc styleAt*(L: LexAccessor, pos: Sci_Position): char =
  result = L.pAccess.styleAt(pos)
  
proc getLine*(L: LexAccessor, pos: Sci_Position): Sci_Position =
  result = L.pAccess.lineFromPosition(pos)

proc lineStart*(L: LexAccessor, line: Sci_Position): Sci_Position = 
  result = L.pAccess.lineStart(line)

proc lineEnd*(L: LexAccessor, line: Sci_Position): Sci_Position =
  if L.documentVersion >= dvLineEnd:
    return cast[ptr IDocumentWithLineEnd](L.pAccess).lineEnd(line)
  else:
    #Old interface means only '\r', '\n' and '\r\n' line ends.
    let startNext = L.pAccess.lineStart(line+1)
    let chLineEnd = L.safeGetCharAt(startNext-1)
    if (chLineEnd == '\x0A') and (L.safeGetCharAt(startNext-2) == '\x0D'):
      return startNext - 2
    else:
      return startNext - 1
      
proc levelAt*(L: LexAccessor, line: Sci_Position): int =
  result = L.pAccess.getLevel(line)

proc length*(L: LexAccessor): Sci_Position =
  result = L.lenDoc

proc flush*(L: LexAccessor) =
  if L.validLen > 0:
    discard L.pAccess.setStyles(L.validLen, L.styleBuf)
    inc(L.startPosStyling, L.validLen)
    L.validLen = 0

proc getLineState*(L: LexAccessor, line: Sci_Position): int =
  result = L.pAccess.getLineState(line)

proc setLineState*(L: LexAccessor, line: Sci_Position, state: int): int =
  result = L.pAccess.setLineState(line, state)

#Style setting
proc startAt*(L: LexAccessor, start: Sci_Position) =
  L.pAccess.startStyling(start, '\xFF')
  L.startPosStyling = start

proc getStartSegment*(L: LexAccessor): Sci_PositionU =
  result = L.startSeg

proc startSegment*(L: LexAccessor, pos: Sci_PositionU) =
  L.startSeg = pos

proc colourTo*(L: LexAccessor, pos: Sci_PositionU, chAttr: int) =
  # Only perform styling if non empty range
  if pos != L.startSeg - 1:
    assert(pos >= L.startSeg)
    if pos < L.startSeg: return
    if L.validLen + ((pos - L.startSeg).Sci_Position + 1) >= bufferSize: L.flush()
    if L.validLen + ((pos - L.startSeg).Sci_Position + 1) >= bufferSize:
      # Too big for buffer so send directly
      discard L.pAccess.setStyleFor((pos - L.startSeg).Sci_Position + 1, chr(chAttr))
    else:
      for i in L.startSeg..pos:
        assert((L.startPosStyling + L.validLen) < L.length())
        L.styleBuf[L.validLen] = chr(chAttr)
        inc L.validLen
  L.startSeg = pos + 1

proc setLevel*(L: LexAccessor, line: Sci_Position, level: int) =
  discard L.pAccess.setLevel(line, level)

proc indicatorFill*(L: LexAccessor, start, stop: Sci_Position, indicator, value: int) =
  L.pAccess.decorationSetCurrentIndicator(indicator)
  L.pAccess.decorationFillRange(start, value, stop - start)

proc changeLexerState*(L: LexAccessor, start, stop: Sci_Position) =
  L.pAccess.changeLexerState(start, stop)
