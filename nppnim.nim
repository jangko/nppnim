# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
import
  winapi, scintilla, support, strutils,
  lexaccessor, stylecontext, sets, utils

when defined(cpu64):
  {.link: "resource/resource64.o".}
else:
  {.link: "resource/resource32.o".}

const
  nbFunc = 1

var
  funcItem: array[nbFunc, FuncItem]
  nppData: NppData

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
proc pluginInit(hModule: HMODULE) = discard

# Here you can do the clean up, save the parameters (if any) for the next session
proc pluginCleanUp() = discard

when false:
  proc getSciHandle(): SciHandle =
    # Get the current scintilla
    var which = -1
    sendMessage(nppData.nppHandle, NPPM_GETCURRENTSCINTILLA, 0, cast[LPARAM](which.addr))
    if which == -1: return
    let curScintilla = if which == 0: nppData.sciMainHandle else: nppData.sciSecondHandle
    result = initSciHandle(curScintilla)

#proc hello() {.cdecl.} =
  #Open a new document
  ##sendMessage(nppData.nppHandle, NPPM_MENUCOMMAND, 0, IDM_FILE_NEW)
  #let sci = getSciHandle()
  # Say hello now:
  #sci.addText("Hello, Notepad++!")

proc helloDlg() {.cdecl.} =
  discard messageBox(NULL, "Copyright(c) 2016-2019, Andri Lim\nhttps://github.com/jangko/nppnim", "About", MB_OK)

# Initialization of your plugin commands
# You should fill your plugins commands here
proc commandMenuInit() =
  discard setCommand(0, "About", helloDlg, nil, false)
  #discard setCommand(1, "", hello, nil, false)

# Here you can do the clean up (especially for the shortcut)
proc commandMenuCleanUp() =
  # Don't forget to deallocate your shortcut here
  discard

# this is needed to initialize GC, global variable initialization, etc
when defined(vcc):
  {.emit: "N_LIB_EXPORT N_CDECL(void, NimMain)(void);".}
else:
  proc NimMain() {.cdecl, importc.}

proc DllMain(hModule: HANDLE, reasonForCall: DWORD, lpReserved: LPVOID): WINBOOL {.stdcall, exportc, dynlib.} =
  case reasonForCall
  of DLL_PROCESS_ATTACH:
    when defined(vcc):
      {.emit: "NimMain();".}
    else:
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

#the next 6 procs are standard notepad++ plugin interface, all must be cdecl callconv
proc setInfo(nd: NppDataCopy) {.cdecl, exportc, dynlib.} =
  nppData = nd
  commandMenuInit()

let
  pluginName = WC("Npp Nim")

proc getName(): ptr TCHAR {.cdecl, exportc, dynlib.} =
  when defined(winUnicode):
    result = pluginName
  else:
    result = cast[ptr TCHAR](pluginName.cstring)

proc getFuncsArray(n: ptr int): ptr FuncItem {.cdecl, exportc, dynlib.} =
  n[] = nbFunc
  result = addr(funcItem[0])

proc beNotified(scn: ptr SCNotification) {.cdecl, exportc, dynlib.} =
  # this is a hacky whacky approach to bug #2: the lexer not being called
  # after the new file just saved
  #if scn.nmhdr.code == NPPN_FILESAVED:
  #  let sci = getSciHandle()
  #  sci.addText(" ")
  #  sendMessage(nppData.nppHandle, NPPM_MENUCOMMAND, 0, IDM_EDIT_UNDO)
  discard

proc messageProc(Message: WINUINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.cdecl, exportc, dynlib.} =
  result = TRUE

proc isUnicode(): WINBOOL {.cdecl, exportc, dynlib.} = TRUE

const
  # Style constants 0..31 max. Correspond to nppnim.xml settings.
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
  NIM_CTYPE = 16
  NIM_DOC_BLOCK_COMMENT = 17
  NIM_DOC_COMMENT = 18

let emptyString = "\0"
let lcName = [
  "NIM_DEFAULT\0",
  "NIM_KEYWORD\0",
  "NIM_LINE_COMMENT\0",
  "NIM_TYPE\0",
  "NIM_NUMBER\0",
  "NIM_STRING\0",
  "NIM_BLOCK_COMMENT\0",
  "NIM_PRAGMA\0",
  "NIM_OPERATOR\0",
  "NIM_CHAR\0",
  "NIM_IDENT\0",
  "NIM_MAGIC\0",
  "NIM_BRACES\0",
  "NIM_STAR\0",
  "NIM_STRING_TRIPLE\0",
  "NIM_RAW_STRING\0",
  "NIM_CTYPE\0",
  "NIM_DOC_BLOCK_COMMENT\0",
  "NIM_DOC_COMMENT\0"]

let lcTag = [
  "default\0",
  "KEYWORD\0",
  "lineComment\0",
  "type\0",
  "number\0",
  "string\0",
  "blockComment\0",
  "pragma\0",
  "operator\0",
  "char\0",
  "identifier\0",
  "magic\0",
  "braces\0",
  "exportMarker\0",
  "string\0",
  "rawString\0",
  "ctype\0",
  "docBlockComment\0",
  "docComment\0"]

const
  numChars*: set[char] = {'0'..'9', 'a'..'z', 'A'..'Z'}
  SymChars*: set[char] = {'a'..'z', 'A'..'Z', '0'..'9', '\x80'..'\xFF'}
  SymStartChars*: set[char] = {'a'..'z', 'A'..'Z', '\x80'..'\xFF'}
  OpChars*: set[char] = {'+', '-', '*', '/', '\\', '<', '>', '!', '?', '^', '.',
    '|', '=', '%', '&', '$', '@', '~', ':', '\x80'..'\xFF'}

const
  lexer_ver {.strdefine.} = "release4"

proc Version(lex: Lexer): cint {.stdcall.} =
  when lexer_ver == "original":
    lvOriginal
  else:
    lvRelease4

proc Release(lex: Lexer) {.stdcall.} = discard
proc PropertyNames(lex: Lexer): cstring {.stdcall.} = nil
proc PropertyType(lex: Lexer, name: cstring): cint {.stdcall.} = -1
proc DescribeProperty(lex: Lexer, name: cstring): cstring {.stdcall.} = nil
proc PropertySet(lex: Lexer, key, val: cstring): Sci_Position {.stdcall.} = -1
proc DescribeWordListSets(lex: Lexer): cstring {.stdcall.} = nil
proc WordListSet(lex: Lexer, n: cint, wl: cstring): int {.stdcall.} = -1

include leximpl

proc Lex(lex: Lexer, startPos: Sci_PositionU, docLen: Sci_Position, initStyle: cint, pAccess: IDocument) {.stdcall.} =
  var
    styler = initLexAccessor(pAccess)
    sc = initStyleContext(startPos.int, docLen.int, initStyle.int, styler.addr)

  while sc.more():
    case sc.state
    of NIM_DEFAULT:
      DEFAULT_STATE_BODY
    of NIM_LINE_COMMENT, NIM_DOC_COMMENT:
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
        discard sc.popState()
        continue
      if sc.ch == '}':
        sc.forward()
        discard sc.popState()
      if sc.ch == '\"':
        # check for extended raw string literal:
        let rawMode = sc.currentPos > 0 and sc.chPrev in SymChars
        sc.pushState(NIM_STRING)
        sc.getString(rawMode)
        continue
    of NIM_STRING_TRIPLE:
      if sc.ch == '\\':
        sc.forward()
      elif sc.match "\"\"\"":
        sc.forward()
        sc.forward()
        discard sc.popForwardState()
    of NIM_DOC_BLOCK_COMMENT:
      if sc.match "]##":
        sc.forward()
        sc.forward()
        sc.forwardSetState(NIM_DEFAULT)
    else:
      discard

    sc.forward()
  sc.complete()

proc IsCommentLine(L: var LexAccessor, line: int): bool =
  let pos = L.lineStart(line)
  let eol_pos = L.lineStart(line + 1) - 1

  for i in pos..<eol_pos:
    let ch = L[i]
    if ch == '#': return true
    elif (ch != ' ') and (ch != '\t'): return false
  result = false

proc IsQuoteLine(L: LexAccessor, line: int): bool =
  let style = L.styleAt(L.lineStart(line)) and 31
  result = style == NIM_STRING_TRIPLE

#this algorithm is taken from scintilla python fold code
proc Fold(lex: Lexer, startPos: Sci_PositionU, docLen: Sci_Position, initStyle: cint, pAccess: IDocument) {.stdcall.} =
  var styler = initLexAccessor(pAccess)

  let maxPos = startPos.int + docLen.int
  let maxLines = if maxPos == styler.length(): styler.getLine(maxPos) else: styler.getLine(maxPos - 1) #Requested last line
  let docLines = styler.getLine(styler.length()) # Available last line

  # Backtrack to previous non-blank line so we can determine indent level
  # for any white space lines (needed esp. within triple quoted strings)
  # and so we can fix any preceding fold level (which is why we go back
  # at least one line in all cases)
  var
    spaceFlags: WSTypes
    lineCurrent = styler.getLine(startPos.int)
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

proc PrivateCall(lex: Lexer, operation: cint, ud: pointer): pointer {.stdcall.} = nil

# ILexer4
proc LineEndTypesSupported(lex: Lexer): cint {.stdcall.} =
  SC_LINE_END_TYPE_DEFAULT

proc AllocateSubStyles(lex: Lexer, styleBase, numberStyles: cint): cint {.stdcall.} =
  -1.cint

proc SubStylesStart(lex: Lexer, styleBase: cint): cint {.stdcall.} =
  -1.cint

proc SubStylesLength(lex: Lexer, styleBase: cint): cint {.stdcall.} =
  0.cint

proc StyleFromSubStyle(lex: Lexer, subStyle: cint): cint {.stdcall.} =
  subStyle.cint

proc PrimaryStyleFromStyle(lex: Lexer, style: cint): cint {.stdcall.} =
  style.cint

proc FreeSubStyles(lex: Lexer) {.stdcall.} =
  discard

proc SetIdentifiers(lex: Lexer, style: cint, identifiers: cstring) {.stdcall.} =
  discard

proc DistanceToSecondaryStyles(lex: Lexer): cint {.stdcall.} =
  0

proc GetSubStyleBases(lex: Lexer): cstring {.stdcall.} =
  var styleSubable = [0.char]
  styleSubable[0].addr

proc NamedStyles(lex: Lexer): cint {.stdcall.} =
  lcName.len.cint

proc NameOfStyle(lex: Lexer, style: cint): cstring {.stdcall.} =
  if style < lex.NamedStyles():
    lcName[style.int][0].unsafeAddr
  else:
    emptyString[0].unsafeAddr

proc TagsOfStyle(lex: Lexer, style: cint): cstring {.stdcall.} =
  if style < lex.NamedStyles():
    lcTag[style.int][0].unsafeAddr
  else:
    emptyString[0].unsafeAddr

proc DescriptionOfStyle(lex: Lexer, style: cint): cstring {.stdcall.} =
  # TODO: use descriptive style instead of identifier
  if style < lex.NamedStyles():
    lcName[style.int][0].unsafeAddr
  else:
    emptyString[0].unsafeAddr

proc GetLexerCount(): int {.stdcall, exportc, dynlib.} = 1

proc GetLexerName(idx: int, name: pointer, nameLen: int) {.stdcall, exportc, dynlib.} =
  let str = "Nim"
  let len = min(str.len, nameLen-1)
  copyMem(name, str.cstring, len+1)

proc GetLexerStatusText(idx: int, desc: ptr TCHAR, descLen: int) {.stdcall, exportc, dynlib.} =
  copyToBuff("Nim Programming Language", desc, descLen)

var lex: ILexer
var vTable: VTABLE

proc lexFactory(): ptr ILexer {.stdcall.} =
  vTable[0] = Version
  vTable[1] = Release
  vTable[2] = PropertyNames
  vTable[3] = PropertyType
  vTable[4] = DescribeProperty
  vTable[5] = PropertySet
  vTable[6] = DescribeWordListSets
  vTable[7] = WordListSet
  vTable[8] = Lex
  vTable[9] = Fold
  vTable[10] = PrivateCall

  # ILexer4
  vTable[11] = LineEndTypesSupported
  vTable[12] = AllocateSubStyles
  vTable[13] = SubStylesStart
  vTable[14] = SubStylesLength
  vTable[15] = StyleFromSubStyle
  vTable[16] = PrimaryStyleFromStyle
  vTable[17] = FreeSubStyles
  vTable[18] = SetIdentifiers
  vTable[19] = DistanceToSecondaryStyles
  vTable[20] = GetSubStyleBases
  vTable[21] = NamedStyles
  vTable[22] = NameOfStyle
  vTable[23] = TagsOfStyle
  vTable[24] = DescriptionOfStyle

  lex.vTable = vTable.addr
  result = lex.addr

proc GetLexerFactory(idx: int): LexerFactoryProc {.stdcall, exportc, dynlib.} =
  result = lexFactory
