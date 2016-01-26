import winapi, scintilla, nppmsg, menucmdid, ilexer, lexaccessor, stylecontext

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

proc hello() {.cdecl.} =
  #Open a new document
  sendMessage(nppData.nppHandle, NPPM_MENUCOMMAND, 0, IDM_FILE_NEW)

  # Get the current scintilla
  var which = -1
  sendMessage(nppData.nppHandle, NPPM_GETCURRENTSCINTILLA, 0, cast[LPARAM](which.addr))
  if which == -1: return
  let curScintilla = if which == 0: nppData.sciMainHandle else: nppData.sciSecondHandle

  # Say hello now:
  # Scintilla control has no Unicode mode, so we use (char *) here
  let text = "Hello, Notepad++!"
  sendMessage(curScintilla, SCI_SETTEXT, 0, cast[LPARAM](text.cstring))

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
  NIM_FLOW_BREAKER = 2
  NIM_UNSAFE  = 3
  NIM_NUMBER  = 4
  NIM_STRING  = 5
  NIM_COMMENT = 6
  NIM_PRAGMA  = 7
  NIM_ERROR   = 8
  
proc Version(x: pointer): int {.stdcall.} = 
  result = lvOriginal
  discard messageBox(NULL, "Hello, Notepad++!", "Notepad++ Plugin Template", MB_OK)
  
proc Release(x: pointer) {.stdcall.} = discard
proc PropertyNames(x: pointer): cstring {.stdcall.} = nil
proc PropertyType(x: pointer, name: cstring): int {.stdcall.} = -1
proc DescribeProperty(x: pointer, name: cstring): cstring {.stdcall.} = nil
proc PropertySet(x: pointer, key, val: cstring): int {.stdcall.} = -1
proc DescribeWordListSets(x: pointer): cstring {.stdcall.} = nil
proc WordListSet(x: pointer, n: int, wl: cstring): int {.stdcall.} = -1

proc Lex(x: pointer, startPos, lengthDoc: int, initStyle: int, pAccess: ptr IDocument) {.stdcall.} =
  #var 
  #  styler = newLexAccessor(pAccess)
  #  ctx = newStyleContext(startPos, lengthDoc, initStyle, styler)
  #  
  #while ctx.more():
  #  case ctx.state
  #  of NIM_DEFAULT:
  #    if ctx.match('#', '['):
  #      ctx.setState(NIM_COMMENT)
  #      ctx.forward() #Move over the #
  #
  #  of NIM_COMMENT:
  #    if ctx.match(']', '#'):
  #      ctx.forward() #Move over the ]
  #      ctx.forwardSetState(NIM_DEFAULT)
  #      
  #  else:
  #    discard
  #    
  #  ctx.forward()
  #ctx.complete()
  discard

proc Fold(x: pointer, startPos, lengthDoc: int, initStyle: int, pAccess: ptr IDocument) {.stdcall.} =
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

var lexer: ILexer
var lex: ILex

proc lexFactory(): ptr ILex {.stdcall.} =
  lexer.version = Version
  lexer.release = Release
  lexer.propNames = PropertyNames
  lexer.propType = PropertyType
  lexer.descProp = DescribeProperty
  lexer.propSet = PropertySet
  lexer.descWordListSets = DescribeWordListSets
  lexer.wordListSet = WordListSet
  lexer.lex = Lex
  lexer.fold = Fold
  lexer.privateCall = PrivateCall
  lex.vTable = lexer.addr
  result = lex.addr

proc GetLexerFactory(idx: int): LexerFactoryProc {.stdcall, exportc, dynlib.} =
  result = lexFactory
