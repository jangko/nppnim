# Copyright (c) 2016 Andri Lim
#
# Distributed under the MIT license
# (See accompanying file LICENSE.txt)
#
#-----------------------------------------
type
  WideChar* = uint16
  PWideChar* = ptr uint16

  HANDLE* = int
  HWND* = HANDLE
  HINST* = HANDLE  # Not HINSTANCE, else it has problems with the var HInstance
  HMENU* = HANDLE
  HICON* = HANDLE
  HCURSOR* = HANDLE # = HICON
  HBRUSH* = HANDLE
  HMODULE* = HANDLE
  HBITMAP* = HANDLE

  ATOM* = int16
  DWORD* = int32
  LONG* = int32
  WINUINT* = int32
  WINBOOL* = int32
  UCHAR* = int8

  LONG_PTR* = ByteAddress
  WPARAM* = LONG_PTR
  LPARAM* = LONG_PTR
  LRESULT* = LONG_PTR

  LPCSTR* = cstring
  LPWSTR* = PWideChar
  LPCWSTR* = PWideChar
  PCWSTR* = PWideChar
  LPVOID* = pointer
  LPDWORD* = ptr DWORD

  COLORREF* = DWORD
  LPCOLORREF* = ptr COLORREF

  RECT* {.final, pure.} = object
    left*: LONG
    top*: LONG
    right*: LONG
    bottom*: LONG

  PRECT* = ptr RECT
  LPRECT* = ptr RECT

  WNDPROC* = proc(wnd: HWND, msg: WINUINT, lParam: WPARAM, wParam: LPARAM): LRESULT {.stdcall.}
  TIMERPROC* = proc(para1: HWND, para2: WINUINT, para3: WINUINT, para4: DWORD) {.stdcall.}

when defined(winUnicode):
  type
    LPCTSTR* = PWideChar
    TBYTE* = uint16
    TCHAR* = uint16
    BCHAR* = int16
else:
  type
    LPCTSTR* = cstring
    TBYTE* = uint8
    TCHAR* = char
    BCHAR* = int8

type
  WNDCLASSW* {.final, pure.} = object
    style*: WINUINT
    lpfnWndProc*: WNDPROC
    cbClsExtra*: int32
    cbWndExtra*: int32
    hInstance*: HANDLE
    hIcon*: HICON
    hCursor*: HCURSOR
    hbrBackground*: HBRUSH
    lpszMenuName*: LPCWSTR
    lpszClassName*: LPCWSTR

  WNDCLASSA* {.final, pure.} = object
    style*: WINUINT
    lpfnWndProc*: WNDPROC
    cbClsExtra*: int32
    cbWndExtra*: int32
    hInstance*: HANDLE
    hIcon*: HICON
    hCursor*: HCURSOR
    hbrBackground*: HBRUSH
    lpszMenuName*: LPCTSTR
    lpszClassName*: LPCTSTR

  LPWNDCLASSA = ptr WNDCLASSA
  LPWNDCLASSW = ptr WNDCLASSW

  CREATESTRUCT* {.final, pure.} = object
    lpCreateParams*: LPVOID
    hInstance*: HINST
    hMenu*: HMENU
    hwndParent*: HWND
    cy*: int32
    cx*: int32
    y*: int32
    x*: int32
    style*: LONG
    lpszName*: LPCTSTR
    lpszClass*: LPCTSTR
    dwExStyle*: DWORD

  LPCREATESTRUCT* = ptr CREATESTRUCT
  TCREATESTRUCT* = CREATESTRUCT
  PCREATESTRUCT* = ptr CREATESTRUCT

  POINT* {.final, pure.} = object
    x*: LONG
    y*: LONG

  PPOINT* = ptr POINT
  LPPOINT* = ptr POINT

  MSG* {.final, pure.} = object
    hwnd*: HWND
    message*: WINUINT
    wParam*: WPARAM
    lParam*: LPARAM
    time*: DWORD
    pt*: POINT

  LPMSG* = ptr MSG

when defined(winUnicode):
  type
    WNDCLASS* = WNDCLASSW
else:
  type
    WNDCLASS* = WNDCLASSA

const
  TRUE* = 1
  FALSE* = 0
  NULL* = 0

  # RTF control
  EM_CANPASTE* = 1074
  EM_CANUNDO* = 198
  EM_CHARFROMPOS* = 215
  EM_DISPLAYBAND* = 1075
  EM_EMPTYUNDOBUFFER* = 205
  EM_EXGETSEL* = 1076
  EM_EXLIMITTEXT* = 1077
  EM_EXLINEFROMCHAR* = 1078
  EM_EXSETSEL* = 1079
  EM_FINDTEXT* = 1080
  EM_FINDTEXTEX* = 1103
  EM_FINDWORDBREAK* = 1100
  EM_FMTLINES* = 200
  EM_FORMATRANGE* = 1081
  EM_GETCHARFORMAT* = 1082
  EM_GETEVENTMASK* = 1083
  EM_GETFIRSTVISIBLELINE* = 206
  EM_GETHANDLE* = 189
  EM_GETLIMITTEXT* = 213
  EM_GETLINE* = 196
  EM_GETLINECOUNT* = 186
  EM_GETMARGINS* = 212
  EM_GETMODIFY* = 184
  EM_GETIMECOLOR* = 1129
  EM_GETIMEOPTIONS* = 1131
  EM_GETOPTIONS* = 1102
  EM_GETOLEINTERFACE* = 1084
  EM_GETPARAFORMAT* = 1085
  EM_GETPASSWORDCHAR* = 210
  EM_GETPUNCTUATION* = 1125
  EM_GETRECT* = 178
  EM_GETSEL* = 176
  EM_GETSELTEXT* = 1086
  EM_GETTEXTRANGE* = 1099
  EM_GETTHUMB* = 190
  EM_GETWORDBREAKPROC* = 209
  EM_GETWORDBREAKPROCEX* = 1104
  EM_GETWORDWRAPMODE* = 1127
  EM_HIDESELECTION* = 1087
  EM_LIMITTEXT* = 197
  EM_LINEFROMCHAR* = 201
  EM_LINEINDEX* = 187
  EM_LINELENGTH* = 193
  EM_LINESCROLL* = 182
  EM_PASTESPECIAL* = 1088
  EM_POSFROMCHAR* = 214
  EM_REPLACESEL* = 194
  EM_REQUESTRESIZE* = 1089
  EM_SCROLL* = 181
  EM_SCROLLCARET* = 183
  EM_SELECTIONTYPE* = 1090
  EM_SETBKGNDCOLOR* = 1091
  EM_SETCHARFORMAT* = 1092
  EM_SETEVENTMASK* = 1093
  EM_SETHANDLE* = 188
  EM_SETIMECOLOR* = 1128
  EM_SETIMEOPTIONS* = 1130
  EM_SETLIMITTEXT* = 197
  EM_SETMARGINS* = 211
  EM_SETMODIFY* = 185
  EM_SETOLECALLBACK* = 1094
  EM_SETOPTIONS* = 1101
  EM_SETPARAFORMAT* = 1095
  EM_SETPASSWORDCHAR* = 204
  EM_SETPUNCTUATION* = 1124
  EM_SETREADONLY* = 207
  EM_SETRECT* = 179
  EM_SETRECTNP* = 180
  EM_SETSEL* = 177
  EM_SETTABSTOPS* = 203
  EM_SETTARGETDEVICE* = 1096
  EM_SETWORDBREAKPROC* = 208
  EM_SETWORDBREAKPROCEX* = 1105
  EM_SETWORDWRAPMODE* = 1126
  EM_STREAMIN* = 1097
  EM_STREAMOUT* = 1098
  EM_UNDO* = 199

  # Window messages
  WM_ACTIVATE* = 6
  WM_ACTIVATEAPP* = 28
  WM_ASKCBFORMATNAME* = 780
  WM_CANCELJOURNAL* = 75
  WM_CANCELMODE* = 31
  WM_CAPTURECHANGED* = 533
  WM_CHANGECBCHAIN* = 781
  WM_CHAR* = 258
  WM_CHARTOITEM* = 47
  WM_CHILDACTIVATE* = 34
  WM_CHOOSEFONT_GETLOGFONT* = 1025
  WM_CHOOSEFONT_SETLOGFONT* = 1125
  WM_CHOOSEFONT_SETFLAGS* = 1126
  WM_CLEAR* = 771
  WM_CLOSE* = 16
  WM_COMMAND* = 273
  WM_COMPACTING* = 65
  WM_COMPAREITEM* = 57
  WM_CONTEXTMENU* = 123
  WM_COPY* = 769
  WM_COPYDATA* = 74
  WM_CREATE* = 1
  WM_CTLCOLORBTN* = 309
  WM_CTLCOLORDLG* = 310
  WM_CTLCOLOREDIT* = 307
  WM_CTLCOLORLISTBOX* = 308
  WM_CTLCOLORMSGBOX* = 306
  WM_CTLCOLORSCROLLBAR* = 311
  WM_CTLCOLORSTATIC* = 312
  WM_CUT* = 768
  WM_DEADCHAR* = 259
  WM_DELETEITEM* = 45
  WM_DESTROY* = 2
  WM_DESTROYCLIPBOARD* = 775
  WM_DEVICECHANGE* = 537
  WM_DEVMODECHANGE* = 27
  WM_DISPLAYCHANGE* = 126
  WM_DRAWCLIPBOARD* = 776
  WM_DRAWITEM* = 43
  WM_DROPFILES* = 563
  WM_ENABLE* = 10
  WM_ENDSESSION* = 22
  WM_ENTERIDLE* = 289
  WM_ENTERMENULOOP* = 529
  WM_ENTERSIZEMOVE* = 561
  WM_ERASEBKGND* = 20
  WM_EXITMENULOOP* = 530
  WM_EXITSIZEMOVE* = 562
  WM_FONTCHANGE* = 29
  WM_GETDLGCODE* = 135
  WM_GETFONT* = 49
  WM_GETHOTKEY* = 51
  WM_GETICON* = 127
  WM_GETMINMAXINFO* = 36
  WM_GETTEXT* = 13
  WM_GETTEXTLENGTH* = 14
  WM_HELP* = 83
  WM_HOTKEY* = 786
  WM_HSCROLL* = 276
  WM_HSCROLLCLIPBOARD* = 782
  WM_ICONERASEBKGND* = 39
  WM_IME_CHAR* = 646
  WM_IME_COMPOSITION* = 271
  WM_IME_COMPOSITIONFULL* = 644
  WM_IME_CONTROL* = 643
  WM_IME_ENDCOMPOSITION* = 270
  WM_IME_KEYDOWN* = 656
  WM_IME_KEYUP* = 657
  WM_IME_NOTIFY* = 642
  WM_IME_SELECT* = 645
  WM_IME_SETCONTEXT* = 641
  WM_IME_STARTCOMPOSITION* = 269
  WM_INITDIALOG* = 272
  WM_INITMENU* = 278
  WM_INITMENUPOPUP* = 279
  WM_INPUTLANGCHANGE* = 81
  WM_INPUTLANGCHANGEREQUEST* = 80
  WM_KEYDOWN* = 256
  WM_KEYUP* = 257
  WM_KILLFOCUS* = 8
  WM_LBUTTONDBLCLK* = 515
  WM_LBUTTONDOWN* = 513
  WM_LBUTTONUP* = 514
  WM_MBUTTONDBLCLK* = 521
  WM_MBUTTONDOWN* = 519
  WM_MBUTTONUP* = 520
  WM_MDIACTIVATE* = 546
  WM_MDICASCADE* = 551
  WM_MDICREATE* = 544
  WM_MDIDESTROY* = 545
  WM_MDIGETACTIVE* = 553
  WM_MDIICONARRANGE* = 552
  WM_MDIMAXIMIZE* = 549
  WM_MDINEXT* = 548
  WM_MDIREFRESHMENU* = 564
  WM_MDIRESTORE* = 547
  WM_MDISETMENU* = 560
  WM_MDITILE* = 550
  WM_MEASUREITEM* = 44
  WM_MENUCHAR* = 288
  WM_MENUSELECT* = 287
  WM_MOUSEACTIVATE* = 33
  WM_MOUSEMOVE* = 512
  WM_MOUSEWHEEL* = 522
  WM_MOUSEHOVER* = 673
  WM_MOUSELEAVE* = 675
  WM_MOVE* = 3
  WM_MOVING* = 534
  WM_NCACTIVATE* = 134
  WM_NCCALCSIZE* = 131
  WM_NCCREATE* = 129
  WM_NCDESTROY* = 130
  WM_NCHITTEST* = 132
  WM_NCLBUTTONDBLCLK* = 163
  WM_NCLBUTTONDOWN* = 161
  WM_NCLBUTTONUP* = 162
  WM_NCMBUTTONDBLCLK* = 169
  WM_NCMBUTTONDOWN* = 167
  WM_NCMBUTTONUP* = 168
  WM_NCMOUSEMOVE* = 160
  WM_NCPAINT* = 133
  WM_NCRBUTTONDBLCLK* = 166
  WM_NCRBUTTONDOWN* = 164
  WM_NCRBUTTONUP* = 165
  WM_NEXTDLGCTL* = 40
  WM_NOTIFY* = 78
  WM_NOTIFYFORMAT* = 85
  WM_NULL* = 0
  WM_PAINT* = 15
  WM_PAINTCLIPBOARD* = 777
  WM_PAINTICON* = 38
  WM_PALETTECHANGED* = 785
  WM_PALETTEISCHANGING* = 784
  WM_PARENTNOTIFY* = 528
  WM_PASTE* = 770
  WM_PENWINFIRST* = 896
  WM_PENWINLAST* = 911
  WM_POWER* = 72
  WM_POWERBROADCAST* = 536
  WM_PRINT* = 791
  WM_PRINTCLIENT* = 792
  WM_PSD_ENVSTAMPRECT* = 1029
  WM_PSD_FULLPAGERECT* = 1025
  WM_PSD_GREEKTEXTRECT* = 1028
  WM_PSD_MARGINRECT* = 1027
  WM_PSD_MINMARGINRECT* = 1026
  WM_PSD_PAGESETUPDLG* = 1024
  WM_PSD_YAFULLPAGERECT* = 1030
  WM_QUERYDRAGICON* = 55
  WM_QUERYENDSESSION* = 17
  WM_QUERYNEWPALETTE* = 783
  WM_QUERYOPEN* = 19
  WM_QUEUESYNC* = 35
  WM_QUIT* = 18
  WM_RBUTTONDBLCLK* = 518
  WM_RBUTTONDOWN* = 516
  WM_RBUTTONUP* = 517
  WM_RENDERALLFORMATS* = 774
  WM_RENDERFORMAT* = 773
  WM_SETCURSOR* = 32
  WM_SETFOCUS* = 7
  WM_SETFONT* = 48
  WM_SETHOTKEY* = 50
  WM_SETICON* = 128
  WM_SETREDRAW* = 11
  WM_SETTEXT* = 12
  WM_SETTINGCHANGE* = 26
  WM_SHOWWINDOW* = 24
  WM_SIZE* = 5
  WM_SIZECLIPBOARD* = 779
  WM_SIZING* = 532
  WM_SPOOLERSTATUS* = 42
  WM_STYLECHANGED* = 125
  WM_STYLECHANGING* = 124
  WM_SYSCHAR* = 262
  WM_SYSCOLORCHANGE* = 21
  WM_SYSCOMMAND* = 274
  WM_SYSDEADCHAR* = 263
  WM_SYSKEYDOWN* = 260
  WM_SYSKEYUP* = 261
  WM_TCARD* = 82
  WM_TIMECHANGE* = 30
  WM_TIMER* = 275
  WM_UNDO* = 772
  WM_USER* = 1024
  WM_USERCHANGED* = 84
  WM_VKEYTOITEM* = 46
  WM_VSCROLL* = 277
  WM_VSCROLLCLIPBOARD* = 778
  WM_WINDOWPOSCHANGED* = 71
  WM_WINDOWPOSCHANGING* = 70
  WM_WININICHANGE* = 26

  # Window message ranges
  WM_KEYFIRST* = 256
  WM_KEYLAST* = 264
  WM_MOUSEFIRST* = 512
  WM_MOUSELAST* = 525
  WM_XBUTTONDOWN* = 523
  WM_XBUTTONUP* = 524
  WM_XBUTTONDBLCLK* = 525

  # CreateWindow
  CW_USEDEFAULT* = -1
  WS_BORDER* = 0x00800000
  WS_CAPTION* = 0x00C00000
  WS_CHILD* = 0x40000000
  WS_CHILDWINDOW* = 0x40000000
  WS_CLIPCHILDREN* = 0x02000000
  WS_CLIPSIBLINGS* = 0x04000000
  WS_DISABLED* = 0x08000000
  WS_DLGFRAME* = 0x00400000
  WS_GROUP* = 0x00020000
  WS_HSCROLL* = 0x00100000
  WS_ICONIC* = 0x20000000
  WS_MAXIMIZE* = 0x01000000
  WS_MAXIMIZEBOX* = 0x00010000
  WS_MINIMIZE* = 0x20000000
  WS_MINIMIZEBOX* = 0x00020000
  WS_OVERLAPPED* = 0
  WS_OVERLAPPEDWINDOW* = 0x00CF0000
  WS_POPUP* = LONG(0x80000000)
  WS_POPUPWINDOW* = LONG(0x80880000)
  WS_SIZEBOX* = 0x00040000
  WS_SYSMENU* = 0x00080000
  WS_TABSTOP* = 0x00010000
  WS_THICKFRAME* = 0x00040000

  WS_TILED* = 0
  WS_TILEDWINDOW* = 0x00CF0000
  WS_VISIBLE* = 0x10000000
  WS_VSCROLL* = 0x00200000
  MDIS_ALLCHILDSTYLES* = 0x00000001
  BS_3STATE* = 0x00000005
  BS_AUTO3STATE* = 0x00000006
  BS_AUTOCHECKBOX* = 0x00000003
  BS_AUTORADIOBUTTON* = 0x00000009
  BS_BITMAP* = 0x00000080
  BS_BOTTOM* = 0x00000800
  BS_CENTER* = 0x00000300
  BS_CHECKBOX* = 0x00000002
  BS_DEFPUSHBUTTON* = 0x00000001
  BS_GROUPBOX* = 0x00000007
  BS_ICON* = 0x00000040
  BS_LEFT* = 0x00000100
  BS_LEFTTEXT* = 0x00000020
  BS_MULTILINE* = 0x00002000
  BS_NOTIFY* = 0x00004000
  BS_OWNERDRAW* = 0x0000000B
  BS_PUSHBUTTON* = 0
  BS_PUSHLIKE* = 0x00001000
  BS_RADIOBUTTON* = 0x00000004
  BS_RIGHT* = 0x00000200
  BS_RIGHTBUTTON* = 0x00000020
  BS_TEXT* = 0
  BS_TOP* = 0x00000400
  BS_USERBUTTON* = 0x00000008
  BS_VCENTER* = 0x00000C00
  BS_FLAT* = 0x00008000
  CBS_AUTOHSCROLL* = 0x00000040
  CBS_DISABLENOSCROLL* = 0x00000800
  CBS_DROPDOWN* = 0x00000002
  CBS_DROPDOWNLIST* = 0x00000003
  CBS_HASSTRINGS* = 0x00000200
  CBS_LOWERCASE* = 0x00004000
  CBS_NOINTEGRALHEIGHT* = 0x00000400
  CBS_OEMCONVERT* = 0x00000080
  CBS_OWNERDRAWFIXED* = 0x00000010
  CBS_OWNERDRAWVARIABLE* = 0x00000020
  CBS_SIMPLE* = 0x00000001
  CBS_SORT* = 0x00000100
  CBS_UPPERCASE* = 0x00002000
  ES_AUTOHSCROLL* = 0x00000080
  ES_AUTOVSCROLL* = 0x00000040
  ES_CENTER* = 0x00000001
  ES_LEFT* = 0
  ES_LOWERCASE* = 0x00000010
  ES_MULTILINE* = 0x00000004
  ES_NOHIDESEL* = 0x00000100
  ES_NUMBER* = 0x00002000
  ES_OEMCONVERT* = 0x00000400
  ES_PASSWORD* = 0x00000020
  ES_READONLY* = 0x00000800
  ES_RIGHT* = 0x00000002
  ES_UPPERCASE* = 0x00000008
  ES_WANTRETURN* = 0x00001000
  LBS_DISABLENOSCROLL* = 0x00001000
  LBS_EXTENDEDSEL* = 0x00000800
  LBS_HASSTRINGS* = 0x00000040
  LBS_MULTICOLUMN* = 0x00000200
  LBS_MULTIPLESEL* = 0x00000008
  LBS_NODATA* = 0x00002000
  LBS_NOINTEGRALHEIGHT* = 0x00000100
  LBS_NOREDRAW* = 0x00000004
  LBS_NOSEL* = 0x00004000
  LBS_NOTIFY* = 0x00000001
  LBS_OWNERDRAWFIXED* = 0x00000010
  LBS_OWNERDRAWVARIABLE* = 0x00000020
  LBS_SORT* = 0x00000002
  LBS_STANDARD* = 0x00A00003
  LBS_USETABSTOPS* = 0x00000080
  LBS_WANTKEYBOARDINPUT* = 0x00000400
  SBS_BOTTOMALIGN* = 0x00000004
  SBS_HORZ* = 0
  SBS_LEFTALIGN* = 0x00000002
  SBS_RIGHTALIGN* = 0x00000004
  SBS_SIZEBOX* = 0x00000008
  SBS_SIZEBOXBOTTOMRIGHTALIGN* = 0x00000004
  SBS_SIZEBOXTOPLEFTALIGN* = 0x00000002
  SBS_SIZEGRIP* = 0x00000010
  SBS_TOPALIGN* = 0x00000002
  SBS_VERT* = 0x00000001
  SS_BITMAP* = 0x0000000E
  SS_BLACKFRAME* = 0x00000007
  SS_BLACKRECT* = 0x00000004
  SS_CENTER* = 0x00000001
  SS_CENTERIMAGE* = 0x00000200
  SS_ENHMETAFILE* = 0x0000000F
  SS_ETCHEDFRAME* = 0x00000012
  SS_ETCHEDHORZ* = 0x00000010
  SS_ETCHEDVERT* = 0x00000011
  SS_GRAYFRAME* = 0x00000008
  SS_GRAYRECT* = 0x00000005
  SS_ICON* = 0x00000003
  SS_LEFT* = 0
  SS_LEFTNOWORDWRAP* = 0x0000000C
  SS_NOPREFIX* = 0x00000080
  SS_NOTIFY* = 0x00000100
  SS_OWNERDRAW* = 0x0000000D
  SS_REALSIZEIMAGE* = 0x00000800
  SS_RIGHT* = 0x00000002
  SS_RIGHTJUST* = 0x00000400
  SS_SIMPLE* = 0x0000000B
  SS_SUNKEN* = 0x00001000
  SS_USERITEM* = 0x0000000A
  SS_WHITEFRAME* = 0x00000009
  SS_WHITERECT* = 0x00000006
  DS_3DLOOK* = 0x00000004
  DS_ABSALIGN* = 0x00000001
  DS_CENTER* = 0x00000800
  DS_CENTERMOUSE* = 0x00001000
  DS_CONTEXTHELP* = 0x00002000
  DS_CONTROL* = 0x00000400
  DS_FIXEDSYS* = 0x00000008
  DS_LOCALEDIT* = 0x00000020
  DS_MODALFRAME* = 0x00000080
  DS_NOFAILCREATE* = 0x00000010
  DS_NOIDLEMSG* = 0x00000100
  DS_SETFONT* = 0x00000040
  DS_SETFOREGROUND* = 0x00000200
  DS_SYSMODAL* = 0x00000002

  # CreateWindowEx
  WS_EX_ACCEPTFILES* = 0x00000010
  WS_EX_APPWINDOW* = 0x00040000
  WS_EX_CLIENTEDGE* = 0x00000200
  WS_EX_CONTEXTHELP* = 0x00000400
  WS_EX_CONTROLPARENT* = 0x00010000
  WS_EX_DLGMODALFRAME* = 0x00000001
  WS_EX_LEFT* = 0
  WS_EX_LEFTSCROLLBAR* = 0x00004000
  WS_EX_LTRREADING* = 0
  WS_EX_MDICHILD* = 0x00000040
  WS_EX_NOPARENTNOTIFY* = 0x00000004
  WS_EX_OVERLAPPEDWINDOW* = 0x00000300
  WS_EX_PALETTEWINDOW* = 0x00000188
  WS_EX_RIGHT* = 0x00001000
  WS_EX_RIGHTSCROLLBAR* = 0
  WS_EX_RTLREADING* = 0x00002000
  WS_EX_STATICEDGE* = 0x00020000
  WS_EX_TOOLWINDOW* = 0x00000080
  WS_EX_TOPMOST* = 0x00000008
  WS_EX_TRANSPARENT* = 0x00000020
  WS_EX_WINDOWEDGE* = 0x00000100

  # ShowWindow
  SW_HIDE* = 0
  SW_MAXIMIZE* = 3
  SW_MINIMIZE* = 6
  SW_NORMAL* = 1
  SW_RESTORE* = 9
  SW_SHOW* = 5
  SW_SHOWDEFAULT* = 10
  SW_SHOWMAXIMIZED* = 3
  SW_SHOWMINIMIZED* = 2
  SW_SHOWMINNOACTIVE* = 7
  SW_SHOWNA* = 8
  SW_SHOWNOACTIVATE* = 4
  SW_SHOWNORMAL* = 1

  # SetWindowPos, DeferWindowPos
  HWND_BOTTOM*    = HWND(1)
  HWND_NOTOPMOST* = HWND(-2)
  HWND_TOP*       = HWND(0)
  HWND_TOPMOST*   = HWND(-1)

  # WNDCLASS structure
  CS_BYTEALIGNCLIENT* = 4096
  CS_BYTEALIGNWINDOW* = 8192
  CS_CLASSDC* = 64
  CS_DBLCLKS* = 8
  CS_GLOBALCLASS* = 16384
  CS_HREDRAW* = 2
  CS_KEYCVTWINDOW* = 4
  CS_NOCLOSE* = 512
  CS_NOKEYCVT* = 256
  CS_OWNDC* = 32
  CS_PARENTDC* = 128
  CS_SAVEBITS* = 2048
  CS_VREDRAW* = 1
  DLGWINDOWEXTRA* = 30

  # GetWindowLong
  GWL_EXSTYLE* = -20
  GWL_STYLE* = -16
  GWL_WNDPROC* = -4
  GWL_HINSTANCE* = -6
  GWL_HWNDPARENT* = -8
  GWL_ID* = -12
  GWL_USERDATA* = -21
  DWL_DLGPROC* = 4
  DWL_MSGRESULT* = 0
  DWL_USER* = 8
  GWLP_HINSTANCE* = -6
  GWLP_USERDATA* = -21
  GWLP_WNDPROC* = -4

  # Virtual Key codes
  VK_LBUTTON* = 1
  VK_RBUTTON* = 2
  VK_CANCEL* = 3
  VK_MBUTTON* = 4
  VK_BACK* = 8
  VK_TAB* = 9
  VK_CLEAR* = 12
  VK_RETURN* = 13
  VK_SHIFT* = 16
  VK_CONTROL* = 17
  VK_MENU* = 18
  VK_PAUSE* = 19
  VK_CAPITAL* = 20
  VK_ESCAPE* = 27
  VK_SPACE* = 32
  VK_PRIOR* = 33
  VK_NEXT* = 34
  VK_END* = 35
  VK_HOME* = 36
  VK_LEFT* = 37
  VK_UP* = 38
  VK_RIGHT* = 39
  VK_DOWN* = 40
  VK_SELECT* = 41
  VK_PRINT* = 42
  VK_EXECUTE* = 43
  VK_SNAPSHOT* = 44
  VK_INSERT* = 45
  VK_DELETE* = 46
  VK_HELP* = 47
  VK_0* = 48
  VK_1* = 49
  VK_2* = 50
  VK_3* = 51
  VK_4* = 52
  VK_5* = 53
  VK_6* = 54
  VK_7* = 55
  VK_8* = 56
  VK_9* = 57
  VK_A* = 65
  VK_B* = 66
  VK_C* = 67
  VK_D* = 68
  VK_E* = 69
  VK_F* = 70
  VK_G* = 71
  VK_H* = 72
  VK_I* = 73
  VK_J* = 74
  VK_K* = 75
  VK_L* = 76
  VK_M* = 77
  VK_N* = 78
  VK_O* = 79
  VK_P* = 80
  VK_Q* = 81
  VK_R* = 82
  VK_S* = 83
  VK_T* = 84
  VK_U* = 85
  VK_V* = 86
  VK_W* = 87
  VK_X* = 88
  VK_Y* = 89
  VK_Z* = 90
  VK_LWIN* = 91
  VK_RWIN* = 92
  VK_APPS* = 93
  VK_NUMPAD0* = 96
  VK_NUMPAD1* = 97
  VK_NUMPAD2* = 98
  VK_NUMPAD3* = 99
  VK_NUMPAD4* = 100
  VK_NUMPAD5* = 101
  VK_NUMPAD6* = 102
  VK_NUMPAD7* = 103
  VK_NUMPAD8* = 104
  VK_NUMPAD9* = 105
  VK_MULTIPLY* = 106
  VK_ADD* = 107
  VK_SEPARATOR* = 108
  VK_SUBTRACT* = 109
  VK_DECIMAL* = 110
  VK_DIVIDE* = 111
  VK_F1* = 112
  VK_F2* = 113
  VK_F3* = 114
  VK_F4* = 115
  VK_F5* = 116
  VK_F6* = 117
  VK_F7* = 118
  VK_F8* = 119
  VK_F9* = 120
  VK_F10* = 121
  VK_F11* = 122
  VK_F12* = 123
  VK_F13* = 124
  VK_F14* = 125
  VK_F15* = 126
  VK_F16* = 127
  VK_F17* = 128
  VK_F18* = 129
  VK_F19* = 130
  VK_F20* = 131
  VK_F21* = 132
  VK_F22* = 133
  VK_F23* = 134
  VK_F24* = 135
  # GetAsyncKeyState
  VK_NUMLOCK* = 144
  VK_SCROLL* = 145
  VK_LSHIFT* = 160
  VK_LCONTROL* = 162
  VK_LMENU* = 164
  VK_RSHIFT* = 161
  VK_RCONTROL* = 163
  VK_RMENU* = 165
  # ImmGetVirtualKey
  VK_PROCESSKEY* = 229

  # Keystroke Message Flags
  KF_ALTDOWN* = 8192
  KF_DLGMODE* = 2048
  KF_EXTENDED* = 256
  KF_MENUMODE* = 4096
  KF_REPEAT* = 16384
  KF_UP* = 32768

  # GetKeyboardLayoutName
  KL_NAMELENGTH* = 9

  # WM_ACTIVATE message
  WA_ACTIVE* = 1
  WA_CLICKACTIVE* = 2
  WA_INACTIVE* = 0

  # WM_ACTIVATE message
  PWR_CRITICALRESUME* = 3
  PWR_SUSPENDREQUEST* = 1
  PWR_SUSPENDRESUME* = 2
  PWR_FAIL* = -1
  PWR_OK* = 1

  # DllEntryPoint
  DLL_PROCESS_ATTACH* = 1
  DLL_THREAD_ATTACH* = 2
  DLL_PROCESS_DETACH* = 0
  DLL_THREAD_DETACH* = 3

  # MessageBeep, MessageBox
  MB_USERICON* = 0x00000080
  MB_ICONASTERISK* = 0x00000040
  MB_ICONEXCLAMATION* = 0x00000030
  MB_ICONWARNING* = 0x00000030
  MB_ICONERROR* = 0x00000010
  MB_ICONHAND* = 0x00000010
  MB_ICONQUESTION* = 0x00000020
  MB_OK* = 0
  MB_ABORTRETRYIGNORE* = 0x00000002
  MB_APPLMODAL* = 0
  MB_DEFAULT_DESKTOP_ONLY* = 0x00020000
  MB_HELP* = 0x00004000
  MB_RIGHT* = 0x00080000
  MB_RTLREADING* = 0x00100000
  MB_TOPMOST* = 0x00040000
  MB_DEFBUTTON1* = 0
  MB_DEFBUTTON2* = 0x00000100
  MB_DEFBUTTON3* = 0x00000200
  MB_DEFBUTTON4* = 0x00000300
  MB_ICONINFORMATION* = 0x00000040
  MB_ICONSTOP* = 0x00000010
  MB_OKCANCEL* = 0x00000001
  MB_RETRYCANCEL* = 0x00000005
  MB_SERVICE_NOTIFICATION* = 0x00040000
  MB_SETFOREGROUND* = 0x00010000
  MB_SYSTEMMODAL* = 0x00001000
  MB_TASKMODAL* = 0x00002000
  MB_YESNO* = 0x00000004
  MB_YESNOCANCEL* = 0x00000003
  IDABORT* = 3
  IDCANCEL* = 2
  IDCLOSE* = 8
  IDHELP* = 9
  IDIGNORE* = 5
  IDNO* = 7
  IDOK* = 1
  IDRETRY* = 4
  IDYES* = 6

proc RGB*(r, g, b: int): COLORREF =
  result = toU32(r) or (toU32(g) shl 8) or (toU32(b) shl 16)

proc RGB*(r, g, b: range[0 .. 255]): COLORREF =
  result = toU32(r) or (toU32(g) shl 8) or (toU32(b) shl 16)

proc PALETTERGB*(r, g, b: range[0..255]): COLORREF =
  result = 0x02000000 or RGB(r, g, b)

proc PALETTEINDEX*(i: DWORD): COLORREF =
  result = COLORREF(0x01000000'i32 or i and 0xffff'i32)

proc GetRValue*(rgb: COLORREF): int8 =
  result = toU8(rgb)

proc GetGValue*(rgb: COLORREF): int8 =
  result = toU8(rgb shr 8)

proc GetBValue*(rgb: COLORREF): int8 =
  result = toU8(rgb shr 16)

proc HIBYTE*(w: int32): int8 =
  result = toU8(w shr 8'i32 and 0x000000FF'i32)

proc HIWORD*(L: int32): int16 =
  result = toU16(L shr 16'i32 and 0x0000FFFF'i32)

proc LOBYTE*(w: int32): int8 =
  result = toU8(w)

proc LOWORD*(L: int32): int16 =
  result = toU16(L)

proc MAKELONG*(a, b: int32): LONG =
  result = a and 0x0000ffff'i32 or b shl 16'i32

proc MAKEWORD*(a, b: int32): int16 =
  result = toU16(a and 0xff'i32) or toU16(b shl 8'i32)

when defined(winUniCode):
  proc WC*(s: string): LPCWSTR =
    if s == nil: return cast[LPCWSTR](0)
    let x = newWideCString(s)
    result = cast[LPCWSTR](x)
else:
  template WC*(s: string): cstring = s.cstring

proc SendMessageA*(wnd: HWND, msg: WINUINT, wp: WPARAM, lp: LPARAM): LRESULT {.
    stdcall, dynlib: "user32", importc: "SendMessageA".}
proc SendMessageW*(wnd: HWND, Msg: WINUINT, wp: WPARAM, lp: LPARAM): LRESULT {.
    stdcall, dynlib: "user32", importc: "SendMessageW".}

proc sendMessage*(wnd: HWND, msg: WINUINT, wp: WPARAM = 0, lp: LPARAM = 0): LRESULT {.discardable.} =
  when defined(winUnicode): result = SendMessageW(wnd, msg, wp, lp)
  else: result = SendMessageA(wnd, msg, wp, lp)

proc setFocus*(wnd: HWND): HWND {.stdcall, dynlib: "user32", importc: "SetFocus", discardable.}

proc CreateWindowExA(dwExStyle: DWORD, lpClassName: LPCSTR,
                      lpWindowName: LPCSTR, dwStyle: DWORD, X, Y,
                      nWidth, nHeight: cint, hWndParent: HWND,
                      menu: HMENU, hInstance: HINST, lpParam: LPVOID): HWND {.
    stdcall, dynlib: "user32", importc: "CreateWindowExA".}

proc CreateWindowExW(dwExStyle: DWORD, lpClassName: LPCWSTR,
                      lpWindowName: LPCWSTR, dwStyle: DWORD, X, Y,
                      nWidth, nHeight: cint, hWndParent: HWND,
                      menu: HMENU, hInstance: HINST, lpParam: LPVOID): HWND {.
    stdcall, dynlib: "user32", importc: "CreateWindowExW".}

proc CreateWindowA*(lpClassName: LPCSTR, lpWindowName: LPCSTR, dwStyle: DWORD,
                   X, Y, nWidth, nHeight: cint,
                   hWndParent: HWND, menu: HMENU, hInstance: HINST,
                   lpParam: LPVOID): HWND =
  result = CreateWindowExA(0, lpClassName, lpWindowName, dwStyle, X, Y, nWidth,
                           nHeight, hWndParent, menu, hInstance, lpParam)

proc CreateWindowW*(lpClassName: LPCWSTR, lpWindowName: LPCWSTR, dwStyle: DWORD,
                   X, Y, nWidth, nHeight: cint,
                   hWndParent: HWND, menu: HMENU, hInstance: HINST,
                   lpParam: LPVOID): HWND =
  result = CreateWindowExW(0, lpClassName, lpWindowName, dwStyle, X, Y, nWidth,
                           nHeight, hWndParent, menu, hInstance, lpParam)

proc createWindow*(className, windowName: string, dwStyle: DWORD, X, Y, nWidth, nHeight: int,
                  hwndParent = 0.HWND, hMenu = 0.HMENU, hInstance = 0.HINST, lpParam: LPVOID = nil): HWND =
  when defined(winUnicode):
    result = CreateWindowW(WC(className), WC(windowName), dwStyle, X.cint, Y.cint, nWidth.cint, nHeight.cint,
      hwndParent, hMenu, hInstance, lpParam)
  else:
    result = CreateWindowA(className.cstring, windowName.cstring, dwStyle, X.cint, Y.cint, nWidth.cint, nHeight.cint,
      hwndParent, hMenu, hInstance, lpParam)

proc createWindowEx*(dwExStyle: DWORD, className, windowName: string, dwStyle: DWORD, X, Y, nWidth, nHeight: int,
                  hwndParent = 0.HWND, hMenu = 0.HMENU, hInstance = 0.HINST, lpParam: LPVOID = nil): HWND =
  when defined(winUnicode):
    result = CreateWindowExW(dwExStyle, WC(className), WC(windowName), dwStyle,
      X.cint, Y.cint, nWidth.cint, nHeight.cint,
      hwndParent, hMenu, hInstance, lpParam)
  else:
    result = CreateWindowExA(dwExStyle, className.cstring, windowName.cstring, dwStyle,
      X.cint, Y.cint, nWidth.cint, nHeight.cint,
      hwndParent, hMenu, hInstance, lpParam)

proc showWindow*(wnd: HWND, nCmdShow: int32): WINBOOL {.stdcall,
    dynlib: "user32", importc: "ShowWindow", discardable.}

proc getClientRect*(wnd: HWND, lpRect: LPRECT): WINBOOL {.stdcall,
    dynlib: "user32", importc: "GetClientRect", discardable.}

proc getWindowRect*(wnd: HWND, lpRect: LPRECT): WINBOOL {.stdcall,
    dynlib: "user32", importc: "GetWindowRect", discardable.}

proc setWindowPos*(wnd, hWndInsertAfter: HWND, X, Y, cx, cy: int32, uFlags: WINUINT): WINBOOL {.stdcall,
    dynlib: "user32", importc: "SetWindowPos", discardable.}

proc setWindowPos*(wnd, hWndInsertAfter: HWND, rc: RECT, uFlags: WINUINT = 0): WINBOOL {.discardable.} =
  result = setWindowPos(wnd, hWndInsertAfter, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, uFlags)

proc destroyWindow*(wnd: HWND): WINBOOL {.stdcall, dynlib: "user32", importc: "DestroyWindow", discardable.}

proc postQuitMessage*(nExitCode: int32) {.stdcall, dynlib: "user32", importc: "PostQuitMessage".}

proc DefWindowProcA(wnd: HWND, Msg: WINUINT, wp: WPARAM, lp: LPARAM): LRESULT {.
    stdcall, dynlib: "user32", importc: "DefWindowProcA".}

proc DefWindowProcW(wnd: HWND, Msg: WINUINT, wp: WPARAM, lp: LPARAM): LRESULT {.
    stdcall, dynlib: "user32", importc: "DefWindowProcW".}

template defWindowProc*(wnd: HWND, msg: WINUINT, wp: WPARAM, lp: LPARAM): LRESULT =
  when defined(winUnicode): DefWindowProcW(wnd, msg, wp, lp)
  else: DefWindowProcA(wnd, msg, wp, lp)

proc RegisterClassA*(lpWndClass: LPWNDCLASSA): ATOM {.stdcall, dynlib: "user32",
    importc: "RegisterClassA".}

proc RegisterClassW*(lpWndClass: LPWNDCLASSW): ATOM {.stdcall, dynlib: "user32",
    importc: "RegisterClassW".}

template registerClass*(wndClass: expr): ATOM =
  when defined(winUnicode): RegisterClassW(addr(wndClass))
  else: RegisterClassA(addr(wndClass))

proc GetModuleHandleA(lpModuleName: LPCSTR): HMODULE {.stdcall, dynlib: "kernel32", importc: "GetModuleHandleA".}
proc GetModuleHandleW(lpModuleName: LPCWSTR): HMODULE {.stdcall, dynlib: "kernel32", importc: "GetModuleHandleW".}

template getModuleHandle*(moduleName: string): HMODULE =
  when defined(winUnicode): GetModuleHandleW(WC(moduleName))
  else: GetModuleHandleA(moduleName.cstring)

proc LoadLibraryA(lpLibFileName: LPCSTR): HINST {.stdcall, dynlib: "kernel32", importc: "LoadLibraryA".}
proc LoadLibraryW(lpLibFileName: LPCWSTR): HINST {.stdcall, dynlib: "kernel32", importc: "LoadLibraryW".}

template loadLibrary*(libName: string): HINST =
  when defined(winUnicode): LoadLibraryW(WC(libName))
  else: LoadLibraryA(libName.cstring)

proc GetMessageA(lpMsg: LPMSG, wnd: HWND, wMsgFilterMin: WINUINT,
                  wMsgFilterMax: WINUINT): WINBOOL {.stdcall, dynlib: "user32", importc: "GetMessageA".}

proc GetMessageW(lpMsg: LPMSG, wnd: HWND, wMsgFilterMin: WINUINT,
                  wMsgFilterMax: WINUINT): WINBOOL {.stdcall, dynlib: "user32", importc: "GetMessageW".}

template getMessage*(lpMsg: expr, wnd: HWND, wMsgFilterMin, wMsgFilterMax: WINUINT): expr =
  when defined(winUnicode): GetMessageW(addr(lpMsg), wnd, wMsgFilterMin, wMsgFilterMax) != 0
  else: GetMessageA(addr(lpMsg), wnd, wMsgFilterMin, wMsgFilterMax) != 0

proc TranslateMessage(lpMsg: LPMSG): WINBOOL {.stdcall, dynlib: "user32",
    importc: "TranslateMessage", discardable.}

template translateMessage*(lpMsg: expr): expr =
  TranslateMessage(addr(lpMsg))

proc DispatchMessageA(lpMsg: LPMSG): int32 {.stdcall, dynlib: "user32", importc: "DispatchMessageA", discardable.}
proc DispatchMessageW(lpMsg: LPMSG): int32 {.stdcall, dynlib: "user32", importc: "DispatchMessageW", discardable.}

template dispatchMessage*(lpMsg: expr): expr =
  when defined(winUnicode): DispatchMessageW(addr(lpMsg))
  else: DispatchMessageA(addr(lpMsg))

when defined(cpu64):
  proc GetWindowLongPtrA(wnd: HWND, nIndex: int32): LONG_PTR{.stdcall,
      dynlib: "user32", importc: "GetWindowLongPtrA".}
  proc SetWindowLongPtrA(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR{.
      stdcall, dynlib: "user32", importc: "SetWindowLongPtrA".}
  proc GetClassLongPtrA(wnd: HWND, nIndex: int32): LONG_PTR{.stdcall,
      dynlib: "user32", importc: "GetClassLongPtrA".}
  proc SetClassLongPtrA(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR{.
      stdcall, dynlib: "user32", importc: "SetClassLongPtrA".}

  proc GetWindowLongPtrW(wnd: HWND, nIndex: int32): LONG_PTR{.stdcall,
      dynlib: "user32", importc: "GetWindowLongPtrW".}
  proc SetWindowLongPtrW(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR{.
      stdcall, dynlib: "user32", importc: "SetWindowLongPtrW".}
  proc GetClassLongPtrW(wnd: HWND, nIndex: int32): LONG_PTR{.stdcall,
      dynlib: "user32", importc: "GetClassLongPtrW".}
  proc SetClassLongPtrW(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR{.
      stdcall, dynlib: "user32", importc: "SetClassLongPtrW".}
else:
  proc GetWindowLongPtrA(wnd: HWND, nIndex: int32): LONG_PTR{.stdcall,
      dynlib: "user32", importc: "GetWindowLongA".}
  proc SetWindowLongPtrA(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR{.
      stdcall, dynlib: "user32", importc: "SetWindowLongA".}
  proc GetClassLongPtrA(wnd: HWND, nIndex: int32): LONG_PTR{.stdcall,
      dynlib: "user32", importc: "GetClassLongA".}
  proc SetClassLongPtrA(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR{.
      stdcall, dynlib: "user32", importc: "SetClassLongA".}

  proc GetWindowLongPtrW(wnd: HWND, nIndex: int32): LONG_PTR{.stdcall,
      dynlib: "user32", importc: "GetWindowLongW".}
  proc SetWindowLongPtrW(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR{.
      stdcall, dynlib: "user32", importc: "SetWindowLongW".}
  proc GetClassLongPtrW(wnd: HWND, nIndex: int32): LONG_PTR{.stdcall,
      dynlib: "user32", importc: "GetClassLongW".}
  proc SetClassLongPtrW(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR{.
      stdcall, dynlib: "user32", importc: "SetClassLongW".}

template setWindowLongPtr*(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR =
  when defined(winUnicode): SetWindowLongPtrW(wnd, nIndex, dwNewLong)
  else: SetWindowLongPtrA(wnd, nIndex, dwNewLong)

template setClasLongPtr*(wnd: HWND, nIndex: int32, dwNewLong: LONG_PTR): LONG_PTR =
  when defined(winUnicode): SetClassLongPtrW(wnd, nIndex, dwNewLong)
  else: SetClassLongPtrA(wnd, nIndex, dwNewLong)

template getWindowLongPtr*(wnd: HWND, nIndex: int32): LONG_PTR =
  when defined(winUnicode): GetWindowLongPtrW(wnd, nIndex)
  else: GetWindowLongPtrA(wnd, nIndex)

template getClasLongPtr*(wnd: HWND, nIndex: int32): LONG_PTR =
  when defined(winUnicode): GetClassLongPtrW(wnd, nIndex)
  else: GetClassLongPtrA(wnd, nIndex)

proc PostThreadMessageA(idThread: DWORD, Msg: WINUINT, wp: WPARAM,
                         lp: LPARAM): WINBOOL{.stdcall, dynlib: "user32", importc: "PostThreadMessageA".}

proc PostThreadMessageW(idThread: DWORD, Msg: WINUINT, wp: WPARAM,
                         lp: LPARAM): WINBOOL{.stdcall, dynlib: "user32", importc: "PostThreadMessageW".}

template postThreadMessage*(idThread: DWORD, Msg: WINUINT, wp: WPARAM, lp: LPARAM): WINBOOL =
  when defined(winUnicode): PostThreadMessageW(idThread, Msg, wp, lp)
  else: PostThreadMessageA(idThread, Msg, wp, lp)

proc getLastError*(): DWORD{.stdcall, dynlib: "kernel32", importc: "GetLastError".}
proc getWindowThreadProcessId*(wnd: HWND, lpdwProcessId: LPDWORD): DWORD{.
    stdcall, dynlib: "user32", importc: "GetWindowThreadProcessId".}

proc setTimer*(wnd: HWND, nIDEvent: WINUINT, uElapse: WINUINT, lpTimerFunc: TIMERPROC): WINUINT{.
    stdcall, dynlib: "user32", importc: "SetTimer".}

proc killTimer*(wnd: HWND, uIDEvent: WINUINT): WINBOOL{.stdcall, dynlib: "user32",
    importc: "KillTimer".}

proc messageBoxA*(wnd: HWND, lpText: LPCSTR, lpCaption: LPCSTR, uType: int): int32{.
    stdcall, dynlib: "user32", importc: "MessageBoxA".}

proc messageBoxW*(wnd: HWND, lpText: LPCWSTR, lpCaption: LPCWSTR, uType: int): int32{.
    stdcall, dynlib: "user32", importc: "MessageBoxW".}

template messageBox*(wnd: HWND, lpText, lpCaption: string, uType: int): int32 =
  when defined(winUnicode): messageBoxW(wnd, WC(lpText), WC(lpCaption), uType)
  else: messageBoxA(wnd, WC(lpText), WC(lpCaption), uType)