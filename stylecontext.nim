# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
import lexaccessor, scintilla

type
  StyleContext* = object
    styler*: ptr LexAccessor
    endPos: int
    lengthDocument: int
    
    #Used for optimizing GetRelativeCharacter
    posRelative: int
    currentPosLastRelative: int
    offsetRelative: int
    
    currentPos*: int
    currentLine: int
    lineDocEnd: int
    lineStartNext: int
    atLineStart: bool
    atLineEnd: bool
    state*: int
    chPrev*: char
    ch*: char
    width: int
    chNext*: char
    widthNext: int
  
proc makeLowerCase(ch: char): char =
  if (ch < 'A') or (ch > 'Z'): return ch
  else: result = (ch.ord - 'A'.ord + 'a'.ord).chr

proc getNextChar*(ctx: var StyleContext) =
  ctx.chNext = safeGetCharAt(ctx.styler[], ctx.currentPos + ctx.width, chr(0))
  ctx.widthNext = 1
    
  #End of line determined from line end position, allowing CR, LF,
  #CRLF and Unicode line ends as set by document.
  if ctx.currentLine < ctx.lineDocEnd:
    ctx.atLineEnd = ctx.currentPos >= (ctx.lineStartNext-1)
  else: #Last line
    ctx.atLineEnd = ctx.currentPos >= ctx.lineStartNext
  
proc initStyleContext*(startPos, length, initStyle: int, styler: ptr LexAccessor, chMask = '\xFF'): StyleContext =
  result.styler = styler
  result.endPos = startPos + length
  result.posRelative = 0
  result.currentPosLastRelative = 0x7FFFFFFF
  result.offsetRelative = 0
  result.currentPos = startPos
  result.currentLine = -1
  result.lineStartNext = -1
  result.atLineEnd = false 
  result.state = initStyle and chMask.ord # Mask off all bits which aren't in the chMask.
  result.chPrev = 0.chr
  result.ch = 0.chr
  result.width = 0
  result.chNext = 0.chr 
  result.widthNext = 1
  styler[].startAt(startPos)
  styler[].startSegment(startPos)
  result.currentLine = styler[].getLine(startPos)
  result.lineStartNext = styler[].lineStart(result.currentLine + 1)
  result.lengthDocument = styler[].length()
  if result.endPos == result.lengthDocument:
    inc result.endPos
  result.lineDocEnd = styler[].getLine(result.lengthDocument)
  result.atLineStart = styler[].lineStart(result.currentLine) == startPos
  
  # Variable width is now 0 so GetNextChar gets the char at currentPos into chNext/widthNext
  result.width = 0
  result.getNextChar()
  result.ch = result.chNext
  result.width = result.widthNext
  result.getNextChar()

proc complete*(ctx: StyleContext) =
  let x = if ctx.currentPos > ctx.lengthDocument: 2 else: 1
  ctx.styler[].colourTo(ctx.currentPos - x, ctx.state)
  ctx.styler[].flush()

proc more*(ctx: StyleContext): bool =
  result = ctx.currentPos < ctx.endPos

proc forward*(ctx: var StyleContext) =
  if ctx.currentPos < ctx.endPos:
    ctx.atLineStart = ctx.atLineEnd
    if ctx.atLineStart:
      inc ctx.currentLine
      ctx.lineStartNext = ctx.styler[].lineStart(ctx.currentLine + 1)
    ctx.chPrev = ctx.ch
    inc(ctx.currentPos, ctx.width)
    ctx.ch = ctx.chNext
    ctx.width = ctx.widthNext
    ctx.getNextChar()
  else:
    ctx.atLineStart = false
    ctx.chPrev = ' '
    ctx.ch = ' '
    ctx.chNext = ' '
    ctx.atLineEnd = true

proc forward*(ctx: var StyleContext, nb: int) =
  for i in 0..nb-1: ctx.forward()

proc forwardBytes*(ctx: var StyleContext, nb: int) =
  let forwardPos = ctx.currentPos + nb
  while forwardPos > ctx.currentPos:
    ctx.forward()

proc changeState*(ctx: var StyleContext, state: int) =
  ctx.state = state

proc setState*(ctx: var StyleContext, state: int) =
  let x = if ctx.currentPos > ctx.lengthDocument: 2 else: 1
  ctx.styler[].colourTo(ctx.currentPos - x, ctx.state)
  ctx.state = state

proc forwardSetState*(ctx: var StyleContext, state: int) =
  ctx.forward()
  let x = if ctx.currentPos > ctx.lengthDocument: 2 else: 1
  ctx.styler[].colourTo(ctx.currentPos - x, ctx.state)
  ctx.state = state

proc lengthCurrent*(ctx: StyleContext): int =
  result = ctx.currentPos - ctx.styler[].getStartSegment()

proc getRelative*(ctx: StyleContext, n: int): char = 
  result = ctx.styler[].safeGetCharAt(ctx.currentPos + n, chr(0))

proc getRelativeCharacter*(ctx: StyleContext, n: int): char =
  if n == 0: return ctx.ch
  #fast version for single byte encodings
  result = ctx.styler[].safeGetCharAt(ctx.currentPos + n, chr(0))

proc match*(ctx: StyleContext, ch0: char): bool =
  result = ctx.ch == ch0

proc match*(ctx: StyleContext, ch0, ch1: char): bool =
  result = (ctx.ch == ch0) and (ctx.chNext == ch1)

proc match*(ctx: StyleContext, s: cstring): bool =
  var i = 0
  if ctx.ch != s[i]: return false
  inc i
  if s[i] == chr(0): return true
  if ctx.chNext != s[i]: return false
  inc i
  
  while s[i].ord != 0:
    if s[i] != ctx.styler[].safeGetCharAt(ctx.currentPos + i, chr(0)): 
      return false
    inc i
  result = true

proc matchIgnoreCase*(ctx: StyleContext, s: cstring): bool =
  var i = 0
  if makeLowerCase(ctx.ch) != s[i]: return false
  inc i
  if makeLowerCase(ctx.chNext) != s[i]: return false
  inc i
  
  while s[i].ord != 0:
    if s[i] != makeLowerCase(ctx.styler[].safeGetCharAt(ctx.currentPos + i, chr(0))): 
      return false
    inc i
  result = true

proc getRange(start, stop: int, styler: var LexAccessor, s: var cstring, len: int) =
  var i = 0
  while(i < stop - start + 1) and (i < len-1):
    s[i] = styler[start + i]
    inc i
  s[i] = chr(0)

proc getCurrent*(ctx: StyleContext, s: var cstring, len: int) = 
  getRange(ctx.styler[].getStartSegment(), ctx.currentPos - 1, ctx.styler[], s, len)

proc getRangeLowered(start, stop: int, styler: var LexAccessor, s: var cstring, len: int) =
  var i = 0
  while (i < stop - start + 1) and (i < len-1):
    s[i] = makeLowerCase(styler[start + i])
    inc i
  s[i] = chr(0)

proc getCurrentLowered*(ctx: StyleContext, s: var cstring, len: int) = 
  getRangeLowered(ctx.styler[].getStartSegment(), ctx.currentPos - 1, ctx.styler[], s, len)