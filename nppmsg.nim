import winapi

type
  LangType* = enum
    L_TXT, L_PHP, L_C, L_CPP, L_CS, L_OBJC, L_JAVA, L_RC, L_HTML, L_XML, L_MAKEFILE,
    L_PASCAL, L_BATCH, L_INI, L_NFO, L_USER, L_ASP, L_SQL, L_VB, L_JS, L_CSS, L_PERL,
    L_PYTHON, L_LUA, L_TEX, L_FORTRAN, L_BASH, L_FLASH, L_NSIS, L_TCL, L_LISP, L_SCHEME,
    L_ASM, L_DIFF, L_PROPS, L_PS, L_RUBY, L_SMALLTALK, L_VHDL, L_KIX, L_AU3, L_CAML,
    L_ADA, L_VERILOG, L_MATLAB, L_HASKELL, L_INNO, L_SEARCHRESULT, L_CMAKE, L_YAML,
    # The end of enumated language type, so it should be always at the end
    L_EXTERNAL

  winVer* = enum
    WV_UNKNOWN, WV_WIN32S, WV_95, WV_98, WV_ME, WV_NT, WV_W2K, WV_XP, WV_S2003, WV_XPX64,
    WV_VISTA, WV_WIN7

  sessionInfo* = object
    sessionFilePathName*: ptr TCHAR
    nbFile*: cint
    files*: ptr ptr TCHAR

  toolbarIcons* = object
    hToolbarBmp*: HBITMAP
    hToolbarIcon*: HICON

  CommunicationInfo* = object
    internalMsg*: clong
    srcModuleName*: ptr TCHAR
    info*: pointer             # defined by plugin

#Here you can find how to use these messages : http://notepad-plus.sourceforge.net/uk/plugins-HOWTO.php

const
  VAR_NOT_RECOGNIZED* = 0
  FULL_CURRENT_PATH* = 1
  CURRENT_DIRECTORY* = 2
  FILE_NAME* = 3
  NAME_PART* = 4
  EXT_PART* = 5
  CURRENT_WORD* = 6
  NPP_DIRECTORY* = 7
  CURRENT_LINE* = 8
  CURRENT_COLUMN* = 9

  NPPMSG* = (WM_USER + 1000)
  NPPM_GETCURRENTSCINTILLA* = (NPPMSG + 4)
  NPPM_GETCURRENTLANGTYPE* = (NPPMSG + 5)
  NPPM_SETCURRENTLANGTYPE* = (NPPMSG + 6)
  NPPM_GETNBOPENFILES* = (NPPMSG + 7)
  ALL_OPEN_FILES* = 0
  PRIMARY_VIEW* = 1
  SECOND_VIEW* = 2
  NPPM_GETOPENFILENAMES* = (NPPMSG + 8)
  NPPM_MODELESSDIALOG* = (NPPMSG + 12)
  MODELESSDIALOGADD* = 0
  MODELESSDIALOGREMOVE* = 1
  NPPM_GETNBSESSIONFILES* = (NPPMSG + 13)
  NPPM_GETSESSIONFILES* = (NPPMSG + 14)
  NPPM_SAVESESSION* = (NPPMSG + 15)
  NPPM_SAVECURRENTSESSION* = (NPPMSG + 16)
  NPPM_GETOPENFILENAMESPRIMARY* = (NPPMSG + 17)
  NPPM_GETOPENFILENAMESSECOND* = (NPPMSG + 18)
  NPPM_CREATESCINTILLAHANDLE* = (NPPMSG + 20)
  NPPM_DESTROYSCINTILLAHANDLE* = (NPPMSG + 21)
  NPPM_GETNBUSERLANG* = (NPPMSG + 22)
  NPPM_GETCURRENTDOCINDEX* = (NPPMSG + 23)
  MAIN_VIEW* = 0
  SUB_VIEW* = 1
  NPPM_SETSTATUSBAR* = (NPPMSG + 24)
  STATUSBAR_DOC_TYPE* = 0
  STATUSBAR_DOC_SIZE* = 1
  STATUSBAR_CUR_POS* = 2
  STATUSBAR_EOF_FORMAT* = 3
  STATUSBAR_UNICODE_TYPE* = 4
  STATUSBAR_TYPING_MODE* = 5
  NPPM_GETMENUHANDLE* = (NPPMSG + 25)
  NPPPLUGINMENU* = 0

  NPPM_ENCODESCI* = (NPPMSG + 26)
  #ascii file to unicode
  #int NPPM_ENCODESCI(MAIN_VIEW/SUB_VIEW, 0)
  #return new unicodeMode

  NPPM_DECODESCI* = (NPPMSG + 27)
  #unicode file to ascii
  #int NPPM_DECODESCI(MAIN_VIEW/SUB_VIEW, 0)
  #return old unicodeMode

  NPPM_ACTIVATEDOC* = (NPPMSG + 28)
  #void NPPM_ACTIVATEDOC(int view, int index2Activate)

  NPPM_LAUNCHFINDINFILESDLG* = (NPPMSG + 29)
  #void NPPM_LAUNCHFINDINFILESDLG(TCHAR * dir2Search, TCHAR * filtre)

  NPPM_DMMSHOW* = (NPPMSG + 30)
  NPPM_DMMHIDE* = (NPPMSG + 31)
  NPPM_DMMUPDATEDISPINFO* = (NPPMSG + 32)
  #void NPPM_DMMxxx(0, tTbData->hClient)

  NPPM_DMMREGASDCKDLG* = (NPPMSG + 33)
  #void NPPM_DMMREGASDCKDLG(0, &tTbData)

  NPPM_LOADSESSION* = (NPPMSG + 34)
  #void NPPM_LOADSESSION(0, const TCHAR* file name)

  NPPM_DMMVIEWOTHERTAB* = (NPPMSG + 35)
  #void WM_DMM_VIEWOTHERTAB(0, tTbData->pszName)

  NPPM_RELOADFILE* = (NPPMSG + 36)
  #BOOL NPPM_RELOADFILE(BOOL withAlert, TCHAR *filePathName2Reload)

  NPPM_SWITCHTOFILE* = (NPPMSG + 37)
  #BOOL NPPM_SWITCHTOFILE(0, TCHAR *filePathName2switch)

  NPPM_SAVECURRENTFILE* = (NPPMSG + 38)
  #BOOL WM_SWITCHTOFILE(0, 0)

  NPPM_SAVEALLFILES* = (NPPMSG + 39)
  #BOOL NPPM_SAVEALLFILES(0, 0)

  NPPM_SETMENUITEMCHECK* = (NPPMSG + 40)
  #void WM_PIMENU_CHECK(UINT	funcItem[X]._cmdID, TRUE/FALSE)

  NPPM_ADDTOOLBARICON* = (NPPMSG + 41)
  #void WM_ADDTOOLBARICON(UINT funcItem[X]._cmdID, toolbarIcons icon)

  NPPM_GETWINDOWSVERSION* = (NPPMSG + 42)
  #winVer NPPM_GETWINDOWSVERSION(0, 0)

  NPPM_DMMGETPLUGINHWNDBYNAME* = (NPPMSG + 43)
  #HWND WM_DMM_GETPLUGINHWNDBYNAME(const TCHAR *windowName, const TCHAR *moduleName)
  # if moduleName is NULL, then return value is NULL
  # if windowName is NULL, then the first found window handle which matches with the moduleName will be returned

  NPPM_MAKECURRENTBUFFERDIRTY* = (NPPMSG + 44)
  #BOOL NPPM_MAKECURRENTBUFFERDIRTY(0, 0)

  NPPM_GETENABLETHEMETEXTUREFUNC* = (NPPMSG + 45)
  #BOOL NPPM_GETENABLETHEMETEXTUREFUNC(0, 0)

  NPPM_GETPLUGINSCONFIGDIR* = (NPPMSG + 46)
  #void NPPM_GETPLUGINSCONFIGDIR(int strLen, TCHAR *str)

  NPPM_MSGTOPLUGIN* = (NPPMSG + 47)
  #BOOL NPPM_MSGTOPLUGIN(TCHAR *destModuleName, CommunicationInfo *info)
  # return value is TRUE when the message arrive to the destination plugins.
  # if destModule or info is NULL, then return value is FALSE

  NPPM_MENUCOMMAND* = (NPPMSG + 48)
  #void NPPM_MENUCOMMAND(0, int cmdID)
  # uncomment //#include "menuCmdID.h"
  # in the beginning of this file then use the command symbols defined in "menuCmdID.h" file
  # to access all the Notepad++ menu command items

  NPPM_TRIGGERTABBARCONTEXTMENU* = (NPPMSG + 49)
  #void NPPM_TRIGGERTABBARCONTEXTMENU(int view, int index2Activate)

  NPPM_GETNPPVERSION* = (NPPMSG + 50)
  # int NPPM_GETNPPVERSION(0, 0)
  # return version
  # ex : v4.6
  # HIWORD(version) == 4
  # LOWORD(version) == 6

  NPPM_HIDETABBAR* = (NPPMSG + 51)
  # BOOL NPPM_HIDETABBAR(0, BOOL hideOrNot)
  # if hideOrNot is set as TRUE then tab bar will be hidden
  # otherwise it'll be shown.
  # return value : the old status value

  NPPM_ISTABBARHIDDEN* = (NPPMSG + 52)
  # BOOL NPPM_ISTABBARHIDDEN(0, 0)
  # returned value : TRUE if tab bar is hidden, otherwise FALSE

  NPPM_GETPOSFROMBUFFERID* = (NPPMSG + 57)
  # INT NPPM_GETPOSFROMBUFFERID(INT bufferID, 0)
  # Return VIEW|INDEX from a buffer ID. -1 if the bufferID non existing
  # VIEW takes 2 highest bits and INDEX (0 based) takes the rest (30 bits)
  # Here's the values for the view :
  #  MAIN_VIEW 0
  #  SUB_VIEW  1

  NPPM_GETFULLPATHFROMBUFFERID* = (NPPMSG + 58)
  # INT NPPM_GETFULLPATHFROMBUFFERID(INT bufferID, TCHAR *fullFilePath)
  # Get full path file name from a bufferID.
  # Return -1 if the bufferID non existing, otherwise the number of TCHAR copied/to copy
  # User should call it with fullFilePath be NULL to get the number of TCHAR (not including the nul character),
  # allocate fullFilePath with the return values + 1, then call it again to get  full path file name

  NPPM_GETBUFFERIDFROMPOS* = (NPPMSG + 59)
  #wParam: Position of document
  #lParam: View to use, 0 = Main, 1 = Secondary
  #Returns 0 if invalid

  NPPM_GETCURRENTBUFFERID* = (NPPMSG + 60)
  #Returns active Buffer

  NPPM_RELOADBUFFERID* = (NPPMSG + 61)
  #Reloads Buffer
  #wParam: Buffer to reload
  #lParam: 0 if no alert, else alert

  NPPM_GETBUFFERLANGTYPE* = (NPPMSG + 64)
  #wParam: BufferID to get LangType from
  #lParam: 0
  #Returns as int, see LangType. -1 on error

  NPPM_SETBUFFERLANGTYPE* = (NPPMSG + 65)
  #wParam: BufferID to set LangType of
  #lParam: LangType
  #Returns TRUE on success, FALSE otherwise
  #use int, see LangType for possible values
  #L_USER and L_EXTERNAL are not supported

  NPPM_GETBUFFERENCODING* = (NPPMSG + 66)
  #wParam: BufferID to get encoding from
  #lParam: 0
  #returns as int, see UniMode. -1 on error

  NPPM_SETBUFFERENCODING* = (NPPMSG + 67)
  #wParam: BufferID to set encoding of
  #lParam: format
  #Returns TRUE on success, FALSE otherwise
  #use int, see UniMode
  #Can only be done on new, unedited files

  NPPM_GETBUFFERFORMAT* = (NPPMSG + 68)
  #wParam: BufferID to get format from
  #lParam: 0
  #returns as int, see formatType. -1 on error

  NPPM_SETBUFFERFORMAT* = (NPPMSG + 69)
  #wParam: BufferID to set format of
  #lParam: format
  #Returns TRUE on success, FALSE otherwise
  #use int, see formatType
  # #define NPPM_ADDREBAR (NPPMSG + 57)
  # // BOOL NPPM_ADDREBAR(0, REBARBANDINFO *)
  # // Returns assigned ID in wID value of struct pointer
  # #define NPPM_UPDATEREBAR (NPPMSG + 58)
  # // BOOL NPPM_ADDREBAR(INT ID, REBARBANDINFO *)
  # //Use ID assigned with NPPM_ADDREBAR
  # #define NPPM_REMOVEREBAR (NPPMSG + 59)
  # // BOOL NPPM_ADDREBAR(INT ID, 0)
  # //Use ID assigned with NPPM_ADDREBAR


  NPPM_HIDETOOLBAR* = (NPPMSG + 70)
  # BOOL NPPM_HIDETOOLBAR(0, BOOL hideOrNot)
  # if hideOrNot is set as TRUE then tool bar will be hidden
  # otherwise it'll be shown.
  # return value : the old status value

  NPPM_ISTOOLBARHIDDEN* = (NPPMSG + 71)
  # BOOL NPPM_ISTOOLBARHIDDEN(0, 0)
  # returned value : TRUE if tool bar is hidden, otherwise FALSE

  NPPM_HIDEMENU* = (NPPMSG + 72)
  # BOOL NPPM_HIDEMENU(0, BOOL hideOrNot)
  # if hideOrNot is set as TRUE then menu will be hidden
  # otherwise it'll be shown.
  # return value : the old status value

  NPPM_ISMENUHIDDEN* = (NPPMSG + 73)
  # BOOL NPPM_ISMENUHIDDEN(0, 0)
  # returned value : TRUE if menu is hidden, otherwise FALSE

  NPPM_HIDESTATUSBAR* = (NPPMSG + 74)
  # BOOL NPPM_HIDESTATUSBAR(0, BOOL hideOrNot)
  # if hideOrNot is set as TRUE then STATUSBAR will be hidden
  # otherwise it'll be shown.
  # return value : the old status value

  NPPM_ISSTATUSBARHIDDEN* = (NPPMSG + 75)
  # BOOL NPPM_ISSTATUSBARHIDDEN(0, 0)
  # returned value : TRUE if STATUSBAR is hidden, otherwise FALSE

  NPPM_GETSHORTCUTBYCMDID* = (NPPMSG + 76)
  # BOOL NPPM_GETSHORTCUTBYCMDID(int cmdID, ShortcutKey *sk)
  # get your plugin command current mapped shortcut into sk via cmdID
  # You may need it after getting NPPN_READY notification
  # returned value : TRUE if this function call is successful and shorcut is enable, otherwise FALSE

  NPPM_DOOPEN* = (NPPMSG + 77)
  # BOOL NPPM_DOOPEN(0, const TCHAR *fullPathName2Open)
  # fullPathName2Open indicates the full file path name to be opened.
  # The return value is TRUE (1) if the operation is successful, otherwise FALSE (0).

  RUNCOMMAND_USER* = (WM_USER + 3000)
  NPPM_GETFULLCURRENTPATH* = (RUNCOMMAND_USER + FULL_CURRENT_PATH)
  NPPM_GETCURRENTDIRECTORY* = (RUNCOMMAND_USER + CURRENT_DIRECTORY)
  NPPM_GETFILENAME* = (RUNCOMMAND_USER + FILE_NAME)
  NPPM_GETNAMEPART* = (RUNCOMMAND_USER + NAME_PART)
  NPPM_GETEXTPART* = (RUNCOMMAND_USER + EXT_PART)
  NPPM_GETCURRENTWORD* = (RUNCOMMAND_USER + CURRENT_WORD)
  NPPM_GETNPPDIRECTORY* = (RUNCOMMAND_USER + NPP_DIRECTORY)

  # BOOL NPPM_GETXXXXXXXXXXXXXXXX(size_t strLen, TCHAR *str)
  # where str is the allocated TCHAR array,
  #	     strLen is the allocated array size
  # The return value is TRUE when get generic_string operation success
  # Otherwise (allocated array size is too small) FALSE

  NPPM_GETCURRENTLINE* = (RUNCOMMAND_USER + CURRENT_LINE)
  # INT NPPM_GETCURRENTLINE(0, 0)
  # return the caret current position line

  NPPM_GETCURRENTCOLUMN* = (RUNCOMMAND_USER + CURRENT_COLUMN)
  # INT NPPM_GETCURRENTCOLUMN(0, 0)
  # return the caret current position column

  # Notification code

  NPPN_FIRST* = 1000
  NPPN_READY* = (NPPN_FIRST + 1) # To notify plugins that all the procedures of launchment of notepad++ are done.
                            #scnNotification->nmhdr.code = NPPN_READY;
                            #scnNotification->nmhdr.hwndFrom = hwndNpp;
                            #scnNotification->nmhdr.idFrom = 0;
  NPPN_TBMODIFICATION* = (NPPN_FIRST + 2) # To notify plugins that toolbar icons can be registered
                                     #scnNotification->nmhdr.code = NPPN_TB_MODIFICATION;
                                     #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                     #scnNotification->nmhdr.idFrom = 0;
  NPPN_FILEBEFORECLOSE* = (NPPN_FIRST + 3) # To notify plugins that the current file is about to be closed
                                      #scnNotification->nmhdr.code = NPPN_FILEBEFORECLOSE;
                                      #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                      #scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILEOPENED* = (NPPN_FIRST + 4) # To notify plugins that the current file is just opened
                                 #scnNotification->nmhdr.code = NPPN_FILEOPENED;
                                 #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                 #scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILECLOSED* = (NPPN_FIRST + 5) # To notify plugins that the current file is just closed
                                 #scnNotification->nmhdr.code = NPPN_FILECLOSED;
                                 #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                 #scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILEBEFOREOPEN* = (NPPN_FIRST + 6) # To notify plugins that the current file is about to be opened
                                     #scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
                                     #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                     #scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILEBEFORESAVE* = (NPPN_FIRST + 7) # To notify plugins that the current file is about to be saved
                                     #scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
                                     #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                     #scnNotification->nmhdr.idFrom = BufferID;
  NPPN_FILESAVED* = (NPPN_FIRST + 8) # To notify plugins that the current file is just saved
                                #scnNotification->nmhdr.code = NPPN_FILESAVED;
                                #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                #scnNotification->nmhdr.idFrom = BufferID;
  NPPN_SHUTDOWN* = (NPPN_FIRST + 9) # To notify plugins that Notepad++ is about to be shutdowned.
                               #scnNotification->nmhdr.code = NPPN_SHUTDOWN;
                               #scnNotification->nmhdr.hwndFrom = hwndNpp;
                               #scnNotification->nmhdr.idFrom = 0;
  NPPN_BUFFERACTIVATED* = (NPPN_FIRST + 10) # To notify plugins that a buffer was activated (put to foreground).
                                       #scnNotification->nmhdr.code = NPPN_BUFFERACTIVATED;
                                       #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                       #scnNotification->nmhdr.idFrom = activatedBufferID;
  NPPN_LANGCHANGED* = (NPPN_FIRST + 11) # To notify plugins that the language in the current doc is just changed.
                                   #scnNotification->nmhdr.code = NPPN_LANGCHANGED;
                                   #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                   #scnNotification->nmhdr.idFrom = currentBufferID;
  NPPN_WORDSTYLESUPDATED* = (NPPN_FIRST + 12) # To notify plugins that user initiated a WordStyleDlg change.
                                         #scnNotification->nmhdr.code = NPPN_WORDSTYLESUPDATED;
                                         #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                         #scnNotification->nmhdr.idFrom = currentBufferID;
  NPPN_SHORTCUTREMAPPED* = (NPPN_FIRST + 13) # To notify plugins that plugin command shortcut is remapped.
                                        #scnNotification->nmhdr.code = NPPN_SHORTCUTSREMAPPED;
                                        #scnNotification->nmhdr.hwndFrom = ShortcutKeyStructurePointer;
                                        #scnNotification->nmhdr.idFrom = cmdID;
                                        #where ShortcutKeyStructurePointer is pointer of struct ShortcutKey:
                                        #struct ShortcutKey {
                                        #	bool _isCtrl;
                                        #	bool _isAlt;
                                        #	bool _isShift;
                                        #	UCHAR _key;
                                        #};
  NPPN_FILEBEFORELOAD* = (NPPN_FIRST + 14) # To notify plugins that the current file is about to be loaded
                                      #scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
                                      #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                      #scnNotification->nmhdr.idFrom = NULL;
  NPPN_FILELOADFAILED* = (NPPN_FIRST + 15) # To notify plugins that file open operation failed
                                      #scnNotification->nmhdr.code = NPPN_FILEOPENFAILED;
                                      #scnNotification->nmhdr.hwndFrom = hwndNpp;
                                      #scnNotification->nmhdr.idFrom = BufferID;
  NPPN_READONLYCHANGED* = (NPPN_FIRST + 16) # To notify plugins that current document change the readonly status,
                                       #scnNotification->nmhdr.code = NPPN_READONLYCHANGED;
                                       #scnNotification->nmhdr.hwndFrom = bufferID;
                                       #scnNotification->nmhdr.idFrom = docStatus;
                                       # where bufferID is BufferID
                                       #       docStatus can be combined by DOCSTAUS_READONLY and DOCSTAUS_BUFFERDIRTY
  DOCSTAUS_READONLY* = 1
  DOCSTAUS_BUFFERDIRTY* = 2
  NPPN_DOCORDERCHANGED* = (NPPN_FIRST + 16) # To notify plugins that document order is changed
                                       #scnNotification->nmhdr.code = NPPN_DOCORDERCHANGED;
                                       #scnNotification->nmhdr.hwndFrom = newIndex;
                                       #scnNotification->nmhdr.idFrom = BufferID;
