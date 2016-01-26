import winapi, scintilla, nppmsg, menucmdid, ilexer, lexaccessor

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

proc getName(): ptr TCHAR {.cdecl, exportc, dynlib.} = pluginName

proc getFuncsArray(n: ptr int): ptr FuncItem {.cdecl, exportc, dynlib.} =
  n[] = nbFunc
  result = addr(funcItem[0])

proc beNotified(scn: ptr SCNotification) {.cdecl, exportc, dynlib.} =
  discard

proc messageProc(Message: WINUINT, wParam: WPARAM, lParam: LPARAM): LRESULT {.cdecl, exportc, dynlib.} = TRUE

proc isUnicode(): WINBOOL {.cdecl, exportc, dynlib.} = TRUE

const
  # Style constants 0..31 max. Correspond to npp.xml settings.
  DefaultStyle = 0
  KeywordStyle = 1
  FlowBreakerStyle = 2
  UnsafeStyle = 3
  NumberStyle = 4
  StringStyle = 5
  CommentStyle = 6
  PragmaStyle = 7
  ErrorStyle = 8

proc Version(): int {.stdcall.} = lvOriginal
proc Release() {.stdcall.} = discard
proc PropertyNames(): cstring {.stdcall.} = nil
proc PropertyType(name: cstring): int {.stdcall.} = -1
proc DescribeProperty(name: cstring): cstring {.stdcall.} = nil
proc PropertySet(key, val: cstring): Sci_Position {.stdcall.} = -1
proc DescribeWordListSets(): cstring {.stdcall.} = nil
proc WordListSet(n: int, wl: cstring): Sci_Position {.stdcall.} = -1

proc Lex(startPos, lengthDoc: Sci_PositionU, initStyle: int, pAccess: ptr IDocument) {.stdcall.} =
  discard

proc Fold(startPos, lengthDoc: Sci_PositionU, initStyle: int, pAccess: ptr IDocument) {.stdcall.} =
  discard

proc PrivateCall(operation: int, ud: pointer): pointer {.stdcall.} = nil

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

proc getLexerCount(): int {.stdcall, exportc, dynlib.} = 1

proc getLexerName(idx: int, name: ptr TCHAR, nameLen: int) {.stdcall, exportc, dynlib.} =
  copyToBuff("Nim", name, nameLen)

proc getLexerStatusText(idx: int, desc: ptr TCHAR, descLen: int) {.stdcall, exportc, dynlib.} =
  copyToBuff("Nim Lang", desc, descLen)

var lexer: ILexer

proc lexFactory(): ptr ILexer {.stdcall.} =
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
  result = lexer.addr

proc GetLexerFactory(idx: int): LexerFactoryProc {.stdcall, exportc, dynlib.} =
  result = lexFactory

