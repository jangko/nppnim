import 
  winapi, scintilla, nppmsg, menucmdid, support, strutils, 
  lexaccessor, stylecontext, sets, etcpriv

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
  nbFunc = 2

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

proc getSciHandle(): SciHandle =
  # Get the current scintilla
  var which = -1
  sendMessage(nppData.nppHandle, NPPM_GETCURRENTSCINTILLA, 0, cast[LPARAM](which.addr))
  if which == -1: return
  let curScintilla = if which == 0: nppData.sciMainHandle else: nppData.sciSecondHandle
  result = initSciHandle(curScintilla)

proc hello() {.cdecl.} =
  #Open a new document
  sendMessage(nppData.nppHandle, NPPM_MENUCOMMAND, 0, IDM_FILE_NEW)
  let sci = getSciHandle()
  # Say hello now:
  sci.addText("Hello, Notepad++!")

proc helloDlg() {.cdecl.} =
  discard messageBox(NULL, "Hello, Notepad++!", "Notepad++ Plugin Template", MB_OK)

# Initialization of your plugin commands
# You should fill your plugins commands here
proc commandMenuInit() =
  discard setCommand(0, "Hello Notepad++", hello, nil, false)
  discard setCommand(1, "Hello (with dialog)", helloDlg, nil, false)

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
  elif wt == WT_MAGIC:
    sc.setState(NIM_MAGIC)
  else:
    sc.setState(NIM_IDENT)
  sc.forward(pos - sc.currentPos)
  sc.setState(NIM_DEFAULT)
  
proc getString(sc: var StyleContext, rawMode: bool) =  
  sc.setState(NIM_STRING)
  sc.forward()          # skip "
  if sc.ch == '\"' and sc.chNext == '\"':
    sc.forward(2)   # skip ""
    while sc.more():
      if sc.ch == '\"':
        sc.forward()
        if sc.ch == '\"' and sc.chNext == '\"': 
          sc.forward(2)
          break
      else:
        sc.forward()    
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

proc Lex(x: pointer, startPos, docLen: int, initStyle: int, pAccess: IDocument) {.stdcall.} =
  var
    styler = initLexAccessor(pAccess)
    sc = initStyleContext(startPos, docLen, initStyle, styler.addr)

  while sc.more():
    case sc.state
    of NIM_DEFAULT:
      if sc.ch in SymStartChars - {'r', 'R', 'l'}:
        sc.getSymbol()
      elif sc.ch == 'l':
        sc.getSymbol()
      elif sc.ch in {'r', 'R'}:
        if sc.chNext == '\"':
          sc.forward()
          sc.getString(true)
        else:
          sc.getSymbol()
      elif sc.ch == '#':
        let state = if sc.chNext == '[': NIM_BLOCK_COMMENT else: NIM_LINE_COMMENT
        sc.setState(state)
      elif sc.ch == '\'':
        sc.getCharacter()
      elif sc.ch in {'0'..'9'}:
        sc.getNumber()
      elif sc.ch == '{':
        if sc.chNext == '.': sc.setState(NIM_PRAGMA)
      elif sc.ch == '\"':
        # check for extended raw string literal:
        let rawMode = sc.currentPos > 0 and sc.chPrev in SymChars
        sc.getString(rawMode)
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

proc Fold(x: pointer, startPos, lengthDoc: int, initStyle: int, pAccess: IDocument) {.stdcall.} =
  discard

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
