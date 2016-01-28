# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
import
  winapi, scintilla, nppmsg, menucmdid, support, strutils,
  lexaccessor, stylecontext, sets, etcpriv

{.link: "resource/resource.o".}

const
  nbChar = 64

type
  NppData* {.pure, final.} = object
    nppHandle*: HWND
    sciMainHandle*: HWND
    sciSecondHandle*: HWND

  NppDataCopy* {.bycopy.} = NppData

  PFUNCSETINFO* = proc(nd: NppDataCopy) {.cdecl.}
  PFUNCPLUGINCMD* = proc() {.cdecl.}
  PBENOTIFIED* = proc(scn: var SCNotification) {.cdecl.}
  PMESSAGEPROC* = proc(Message: WINUINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.cdecl.}

  ShortcutKey* {.pure, final.} = object
    isCtrl*: bool
    isAlt*: bool
    isShift*: bool
    key*: UCHAR

  FuncItem* {.pure, final.} = object
    itemName*: array[nbChar, TCHAR]
    pFunc*: PFUNCPLUGINCMD
    cmdID*: cint
    init2Check*: bool
    pShKey*: ptr ShortcutKey

  PFUNCGETFUNCSARRAY* = proc(x: ptr int): ptr FuncItem {.cdecl.}

const
  nbFunc = 1

var
  funcItem: array[nbFunc, FuncItem]
  nppData: NppData

proc lstrcpy(a: var openArray[TCHAR], b: string) =
  when defined(winUniCode):
    let x = newWideCString(b)
  else:
    let x = b.cstring

  var i = 0
  while x[i].int != 0:
    a[i] = TCHAR(x[i])
    inc i

  a[i] = TCHAR(0)

# This function help you to initialize your plugin commands
proc setCommand(idx: int, cmdName: string, pFunc: PFUNCPLUGINCMD, sk: ptr ShortcutKey, check0nInit: bool): bool =
  if idx >= nbFunc: return false
  if pFunc == nil: return false

  lstrcpy(funcItem[idx].itemName, cmdName)
  funcItem[idx].pFunc = pFunc
  funcItem[idx].init2Check = check0nInit
  funcItem[idx].pShKey = sk
  result = true

# Initialize your plugin data here
# It will be called while plugin loading
proc pluginInit(hModule: HMODULE) =
  discard

# Here you can do the clean up, save the parameters (if any) for the next session
proc pluginCleanUp() =
  discard

#proc getSciHandle(): SciHandle =
#  # Get the current scintilla
#  var which = -1
#  sendMessage(nppData.nppHandle, NPPM_GETCURRENTSCINTILLA, 0, cast[LPARAM](which.addr))
#  if which == -1: return
#  let curScintilla = if which == 0: nppData.sciMainHandle else: nppData.sciSecondHandle
#  result = initSciHandle(curScintilla)

#proc hello() {.cdecl.} =
  #Open a new document
  ##sendMessage(nppData.nppHandle, NPPM_MENUCOMMAND, 0, IDM_FILE_NEW)
  #let sci = getSciHandle()
  # Say hello now:
  #sci.addText("Hello, Notepad++!")

proc helloDlg() {.cdecl.} =
  discard messageBox(NULL, "Copyright(c) 2016, Andri Lim\nhttps://github.com/jangko/nppnim", "About", MB_OK)

# Initialization of your plugin commands
# You should fill your plugins commands here
proc commandMenuInit() =
  discard setCommand(0, "About", helloDlg, nil, false)
  #discard setCommand(1, "", hello, nil, false)

# Here you can do the clean up (especially for the shortcut)
proc commandMenuCleanUp() =
  # Don't forget to deallocate your shortcut here
  discard

proc NimMain() {.cdecl, importc.}

proc DllMain(hModule: HANDLE, reasonForCall: DWORD, lpReserved: LPVOID): WINBOOL {.stdcall, exportc, dynlib.} =
  case reasonForCall
  of DLL_PROCESS_ATTACH:
    NimMain()
    pluginInit(hModule)
  of DLL_PROCESS_DETACH:
    commandMenuCleanUp()
    pluginCleanUp()
  of DLL_THREAD_ATTACH:
    discard
  of DLL_THREAD_DETACH:
    discard
  else:
    discard
  result = TRUE

proc setInfo(nd: NppDataCopy) {.cdecl, exportc, dynlib.} =
  nppData = nd
  commandMenuInit()

let
  pluginName = WC("Nim Lexer")

proc getName(): ptr TCHAR {.cdecl, exportc, dynlib.} =
  when defined(winUnicode):
    result = pluginName
  else:
    result = cast[ptr TCHAR](pluginName.cstring)

proc getFuncsArray(n: ptr int): ptr FuncItem {.cdecl, exportc, dynlib.} =
  n[] = nbFunc
  result = addr(funcItem[0])

proc beNotified(scn: ptr SCNotification) {.cdecl, exportc, dynlib.} =
  discard

proc messageProc(Message: WINUINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.cdecl, exportc, dynlib.} = TRUE

proc isUnicode(): WINBOOL {.cdecl, exportc, dynlib.} = TRUE

const
  # Style constants 0..31 max. Correspond to npp.xml settings.
  NIM_DEFAULT = 0
  NIM_KEYWORD = 1
  NIM_LINE_COMMENT = 2
  NIM_TYPE    = 3
  NIM_NUMBER  = 4
  NIM_STRING  = 5
  NIM_BLOCK_COMMENT  = 6
  NIM_PRAGMA  = 7
  NIM_OPERATOR = 8
  NIM_CHAR = 9
  NIM_IDENT = 10
  NIM_MAGIC = 11
  NIM_BRACES = 12
  NIM_STAR = 13
  NIM_STRING_TRIPLE = 14
  NIM_RAW_STRING = 15

const
  numChars*: set[char] = {'0'..'9', 'a'..'z', 'A'..'Z'}
  SymChars*: set[char] = {'a'..'z', 'A'..'Z', '0'..'9', '\x80'..'\xFF'}
  SymStartChars*: set[char] = {'a'..'z', 'A'..'Z', '\x80'..'\xFF'}
  OpChars*: set[char] = {'+', '-', '*', '/', '\\', '<', '>', '!', '?', '^', '.',
    '|', '=', '%', '&', '$', '@', '~', ':', '\x80'..'\xFF'}

proc Version(x: pointer): int {.stdcall.} = lvOriginal
proc Release(x: pointer) {.stdcall.} = discard
proc PropertyNames(x: pointer): cstring {.stdcall.} = nil
proc PropertyType(x: pointer, name: cstring): int {.stdcall.} = -1
proc DescribeProperty(x: pointer, name: cstring): cstring {.stdcall.} = nil
proc PropertySet(x: pointer, key, val: cstring): int {.stdcall.} = -1
proc DescribeWordListSets(x: pointer): cstring {.stdcall.} = nil
proc WordListSet(x: pointer, n: int, wl: cstring): int {.stdcall.} = -1

include leximpl

proc Lex(x: pointer, startPos, docLen: int, initStyle: int, pAccess: IDocument) {.stdcall.} =
  var
    styler = initLexAccessor(pAccess)
    sc = initStyleContext(startPos, docLen, initStyle, styler.addr)

  while sc.more():
    case sc.state
    of NIM_DEFAULT:
      DEFAULT_STATE_BODY
    of NIM_LINE_COMMENT:
      if (sc.ch == '\x0D') or (sc.ch == '\x0A'):
        sc.setState(NIM_DEFAULT)
    of NIM_BLOCK_COMMENT:
      if sc.ch == ']' and sc.chNext == '#':
        sc.forward()
        sc.forward()
        sc.setState(NIM_DEFAULT)
    of NIM_PRAGMA:
      if sc.ch == '.' and sc.chNext == '}':
        sc.forward()
        sc.forward()
        sc.setState(NIM_DEFAULT)
    else:
      discard

    sc.forward()
  sc.complete()

proc IsCommentLine(L: var LexAccessor, line: int): bool =
  let pos = L.lineStart(line)
  let eol_pos = L.lineStart(line + 1) - 1

  for i in pos.. <eol_pos:
    let ch = L[i]
    if ch == '#': return true
    elif (ch != ' ') and (ch != '\t'): return false
  result = false

proc IsQuoteLine(L: LexAccessor, line: int): bool =
  let style = L.styleAt(L.lineStart(line)) and 31
  result = style == NIM_STRING_TRIPLE

#this algorithm is taken from scintilla python fold code
proc Fold(x: pointer, startPos, docLen: int, initStyle: int, pAccess: IDocument) {.stdcall.} =
  var styler = initLexAccessor(pAccess)

  let maxPos = startPos + docLen
  let maxLines = if maxPos == styler.length(): styler.getLine(maxPos) else: styler.getLine(maxPos - 1) #Requested last line
  let docLines = styler.getLine(styler.length()) # Available last line

  # Backtrack to previous non-blank line so we can determine indent level
  # for any white space lines (needed esp. within triple quoted strings)
  # and so we can fix any preceding fold level (which is why we go back
  # at least one line in all cases)
  var
    spaceFlags: WSTypes
    lineCurrent = styler.getLine(startPos)
    indentCurrent = styler.indentAmount(lineCurrent, spaceFlags)

  while lineCurrent > 0:
    dec lineCurrent
    indentCurrent = styler.indentAmount(lineCurrent, spaceFlags)
    if ((indentCurrent and SC_FOLDLEVELWHITEFLAG) == 0) and
       (not styler.IsCommentLine(lineCurrent)) and
       (not styler.IsQuoteLine(lineCurrent)): break

  var indentCurrentLevel = indentCurrent and SC_FOLDLEVELNUMBERMASK
  # Set up initial loop state
  var startPos2 = styler.lineStart(lineCurrent)
  var prev_state = NIM_DEFAULT and 31
  if lineCurrent >= 1:
    prev_state = styler.styleAt(startPos2 - 1) and 31
  var prevQuote = prev_state == NIM_STRING_TRIPLE
 
  # Process all characters to end of requested range or end of any triple quote
  # that hangs over the end of the range.  Cap processing in all cases
  # to end of document (in case of unclosed quote at end).
  while (lineCurrent <= docLines) and ((lineCurrent <= maxLines) or prevQuote):
    # Gather info
    var 
      lev = indentCurrent
      lineNext = lineCurrent + 1
      indentNext = indentCurrent
      quote = false
      
    if lineNext <= docLines:
      # Information about next line is only available if not at end of document
      indentNext = styler.indentAmount(lineNext, spaceFlags)
      var lookAtPos = if styler.lineStart(lineNext) == styler.length(): styler.length() - 1 else: styler.lineStart(lineNext)
      var style = styler.styleAt(lookAtPos) and 31
      quote = style == NIM_STRING_TRIPLE
  
    let quote_start = quote and not prevQuote
    let quote_continue = quote and prevQuote
    if not quote or not prevQuote:
      indentCurrentLevel = indentCurrent and SC_FOLDLEVELNUMBERMASK
      
    if quote: indentNext = indentCurrentLevel
    if (indentNext and SC_FOLDLEVELWHITEFLAG) != 0:
      indentNext = SC_FOLDLEVELWHITEFLAG or indentCurrentLevel
  
    if quote_start:
      # Place fold point at start of triple quoted string
      lev = lev or SC_FOLDLEVELHEADERFLAG
    elif quote_continue or prevQuote:
      # Add level to rest of lines in the string
      lev = lev + 1
  
    # Skip past any blank lines for next indent level info we skip also
    # comments (all comments, not just those starting in column 0)
    # which effectively folds them into surrounding code rather
    # than screwing up folding.
  
    while (not quote and (lineNext < docLines) and
      (((indentNext and SC_FOLDLEVELWHITEFLAG) != 0) or
      (lineNext <= docLines and styler.IsCommentLine(lineNext)))):
        inc lineNext
        indentNext = styler.indentAmount(lineNext, spaceFlags)
  
    let levelAfterComments = indentNext and SC_FOLDLEVELNUMBERMASK
    let levelBeforeComments = max(indentCurrentLevel, levelAfterComments)
  
    # Now set all the indent levels on the lines we skipped
    # Do this from end to start.  Once we encounter one line
    # which is indented more than the line after the end of
    # the comment-block, use the level of the block before
  
    var skipLine = lineNext - 1
    var skipLevel = levelAfterComments
    let foldCompact = false
  
    while skipLine > lineCurrent:
      var skipLineIndent = styler.indentAmount(skipLine, spaceFlags)
      if foldCompact:
        if (skipLineIndent and SC_FOLDLEVELNUMBERMASK) > levelAfterComments:
          skipLevel = levelBeforeComments
        var whiteFlag = skipLineIndent and SC_FOLDLEVELWHITEFLAG
        styler.setLevel(skipLine, skipLevel or whiteFlag)
      else:
        let a = (skipLineIndent and SC_FOLDLEVELNUMBERMASK) > levelAfterComments
        let b = (skipLineIndent and SC_FOLDLEVELWHITEFLAG) == 0
        if a and b and (not styler.IsCommentLine(skipLine)):
          skipLevel = levelBeforeComments
        styler.setLevel(skipLine, skipLevel)
      dec skipLine
  
    # Set fold header on non-quote line
    if (not quote) and ((indentCurrent and SC_FOLDLEVELWHITEFLAG) == 0):
      if ((indentCurrent and SC_FOLDLEVELNUMBERMASK) < (indentNext and SC_FOLDLEVELNUMBERMASK)):
        lev = lev or SC_FOLDLEVELHEADERFLAG
  
    # Keep track of triple quote state of previous line
    prevQuote = quote
  
    # Set fold level for this line and move to next line
    if foldCompact: styler.setLevel(lineCurrent, lev)
    else: styler.setLevel(lineCurrent, lev and not SC_FOLDLEVELWHITEFLAG)
    indentCurrent = indentNext
    lineCurrent = lineNext
  
  # NOTE: Cannot set level of last line here because indentCurrent doesn't have
  # header flag set; the loop above is crafted to take care of this case!
  # styler.setLevel(lineCurrent, indentCurrent)
  
proc PrivateCall(x: pointer, operation: int, ud: pointer): pointer {.stdcall.} = nil

proc copyToBuff(str: string; buff: ptr TCHAR; len: int) =
  var
    buflen = min(str.len, len-1)
    b = str.substr(0, buflen)

  when defined(winUniCode):
    let src = newWideCString(b)
  else:
    let src = b.cstring

  if buflen > 0:
    inc buflen
    copyMem(buff, src.unsafeAddr, sizeof(TCHAR) * buflen)

proc GetLexerCount(): int {.stdcall, exportc, dynlib.} =
  result = 1

proc GetLexerName(idx: int, name: pointer, nameLen: int) {.stdcall, exportc, dynlib.} =
  let str = "Nim"
  let len = min(str.len, nameLen-1)
  copyMem(name, str.cstring, len+1)

proc GetLexerStatusText(idx: int, desc: ptr TCHAR, descLen: int) {.stdcall, exportc, dynlib.} =
  copyToBuff("Nim Lang", desc, descLen)

type
  ILexer* {.pure.} = object
    vTable*: pointer

  LexerFactoryProc* = proc(): ptr ILexer {.stdcall.}

var ilex: ILexer
var lex: array[0..10, pointer]

proc lexFactory(): ptr ILexer {.stdcall.} =
  lex[0] = Version
  lex[1] = Release
  lex[2] = PropertyNames
  lex[3] = PropertyType
  lex[4] = DescribeProperty
  lex[5] = PropertySet
  lex[6] = DescribeWordListSets
  lex[7] = WordListSet
  lex[8] = Lex
  lex[9] = Fold
  lex[10] = PrivateCall
  ilex.vTable = lex.addr
  result = ilex.addr

proc GetLexerFactory(idx: int): LexerFactoryProc {.stdcall, exportc, dynlib.} =
  result = lexFactory
