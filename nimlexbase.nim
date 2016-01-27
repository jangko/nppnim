import strutils, scintilla, winapi, support

const
  Lrz* = ' '
  Apo* = '\''
  Tabulator* = '\x09'
  ESC* = '\x1B'
  CR* = '\x0D'
  FF* = '\x0C'
  LF* = '\x0A'
  BEL* = '\x07'
  BACKSPACE* = '\x08'
  VT* = '\x0B'

const
  EndOfFile* = '\0' 
  NewLines* = {CR, LF}

type
  TStream* = object
    doc: IDocument
    pos: int
    len: int
    
  TBaseLexer* = object of RootObj
    bufpos*: int
    buf*: cstring
    bufLen*: int              # length of buffer in characters
    stream*: TStream          # we read from this stream
    lineNumber*: int          # the current line number
    sentinel*: int
    lineStart*: int           # index of last line start in buffer
    cursor*: int
    docLen: int

proc openBaseLexer*(L: var TBaseLexer, doc: IDocument, startPos, docLen: int, bufLen: int = 8192)
proc closeBaseLexer*(L: var TBaseLexer)
proc handleCR*(L: var TBaseLexer, pos: int): int
proc handleLF*(L: var TBaseLexer, pos: int): int

const
  chrSize = sizeof(char)

proc closeBaseLexer(L: var TBaseLexer) =
  dealloc(L.buf)

proc initStream(doc: IDocument, startPos, docLen: int): TStream =
  result.doc = doc
  result.pos = startPos
  result.len = docLen
  
proc readChars(s: TStream, buf: cstring, read: int): int =
  var toRead = read
  let len = s.doc.nvLength()
  if s.pos + toRead > len: toRead = len - s.pos
  s.doc.nvGetCharRange(buf, s.pos, s.pos + toRead)
  result = toRead

proc fillBuffer(L: var TBaseLexer) =
  var
    charsRead, toCopy, s: int # all are in characters,
                              # not bytes (in case this
                              # is not the same)
    oldBufLen: int
  # we know here that pos == L.sentinel, but not if this proc
  # is called the first time by initBaseLexer()
  assert(L.sentinel < L.bufLen)
  toCopy = L.bufLen - L.sentinel - 1
  assert(toCopy >= 0)
  if toCopy > 0:
    moveMem(L.buf, addr(L.buf[L.sentinel + 1]), toCopy * chrSize)
    # "moveMem" handles overlapping regions
    
  charsRead = L.stream.readChars(addr(L.buf[toCopy]), (L.sentinel + 1) * chrSize) div chrSize
  
  s = toCopy + charsRead
  if charsRead < L.sentinel + 1:
    L.buf[s] = EndOfFile      # set end marker
    L.sentinel = s
  else:
    # compute sentinel:
    dec(s)                    # BUGFIX (valgrind)
    while true:
      assert(s < L.bufLen)
      while (s >= 0) and not (L.buf[s] in NewLines): dec(s)
      if s >= 0:
        # we found an appropriate character for a sentinel:
        L.sentinel = s
        break
      else:
        # rather than to give up here because the line is too long,
        # double the buffer's size and try again:
        oldBufLen = L.bufLen
        L.bufLen = L.bufLen * 2
        L.buf = cast[cstring](realloc(L.buf, L.bufLen * chrSize))
        assert(L.bufLen - oldBufLen == oldBufLen)
        charsRead = L.stream.readChars(addr(L.buf[oldBufLen]), oldBufLen * chrSize) div chrSize
        if charsRead < oldBufLen:
          L.buf[oldBufLen + charsRead] = EndOfFile
          L.sentinel = oldBufLen + charsRead
          break
        s = L.bufLen - 1

proc fillBaseLexer(L: var TBaseLexer, pos: int): int =
  assert(pos <= L.sentinel)
  if pos < L.sentinel:
    result = pos + 1          # nothing to do
  else:
    fillBuffer(L)
    L.bufpos = 0              # XXX: is this really correct?
    result = 0
  L.lineStart = result

proc handleCR(L: var TBaseLexer, pos: int): int =
  assert(L.buf[pos] == CR)
  inc(L.lineNumber)
  result = fillBaseLexer(L, pos)
  if L.buf[result] == LF:
    result = fillBaseLexer(L, result)

proc handleLF(L: var TBaseLexer, pos: int): int =
  assert(L.buf[pos] == LF)
  inc(L.lineNumber)
  result = fillBaseLexer(L, pos) #L.lastNL := result-1; // BUGFIX: was: result;

proc skipUTF8BOM(L: var TBaseLexer) =
  if L.buf[0] == '\xEF' and L.buf[1] == '\xBB' and L.buf[2] == '\xBF':
    inc(L.bufpos, 3)
    inc(L.lineStart, 3)

proc openBaseLexer(L: var TBaseLexer, doc: IDocument, startPos, docLen: int, bufLen = 8192) =
  assert(bufLen > 0)
  L.bufpos = 0
  L.bufLen = bufLen
  L.buf = cast[cstring](alloc(bufLen * chrSize))
  L.sentinel = bufLen - 1
  L.lineStart = 0
  L.lineNumber = 1            # lines start at 1
  L.stream = initStream(doc, startPos, docLen)
  fillBuffer(L)
  skipUTF8BOM(L)
