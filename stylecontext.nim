# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
import lexaccessor, scintilla

const maxState = 10

type
  StyleContext* = object
    styler*: ptr LexAccessor
    endPos: int
    lengthDocument: int

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

    # stateStack were added to cope with string/triple string in pragma
    statePos: int
    stateStack: array[0..maxState, int]

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

  result.statePos = 0

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

proc pushState*(ctx: var StyleContext, state: int) =
  if ctx.statePos < maxState:
    ctx.stateStack[ctx.statePos] = ctx.state
    inc ctx.statePos
  ctx.setState(state)

proc popState*(ctx: var StyleContext): int =
  if ctx.statePos > 0:
    result = ctx.stateStack[ctx.statePos - 1]
    dec ctx.statePos
  ctx.setState(result)

proc popForwardState*(ctx: var StyleContext): int =
  if ctx.statePos > 0:
    result = ctx.stateStack[ctx.statePos - 1]
    dec ctx.statePos
  ctx.forwardSetState(result)

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
