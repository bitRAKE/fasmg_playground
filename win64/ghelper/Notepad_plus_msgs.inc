; This file is part of Notepad++ project
; Copyright (C)2020 Don HO <don.h@free.fr>
;
; This program is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either
; version 2 of the License, or (at your option) any later version.
;
; Note that the GPL places important restrictions on "derived works", yet
; it does not provide a detailed definition of that term.  To avoid
; misunderstandings, we consider an application to constitute a
; "derivative work" for the purpose of this license if it does any of the
; following:
; 1. Integrates source code from Notepad++.
; 2. Integrates/includes/aggregates Notepad++ into a proprietary executable
;    installer, such as those produced by InstallShield.
; 3. Links to a library or executes a program that does any of the above.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
iterate LangType,\
	L_TEXT, L_PHP , L_C, L_CPP, L_CS, L_OBJC, L_JAVA, L_RC,\
	L_HTML, L_XML, L_MAKEFILE, L_PASCAL, L_BATCH, L_INI, L_ASCII, L_USER,\
	L_ASP, L_SQL, L_VB, L_JS, L_CSS, L_PERL, L_PYTHON, L_LUA, \
	L_TEX, L_FORTRAN, L_BASH, L_FLASH, L_NSIS, L_TCL, L_LISP, L_SCHEME,\
	L_ASM, L_DIFF, L_PROPS, L_PS, L_RUBY, L_SMALLTALK, L_VHDL, L_KIX, L_AU3,\
	L_CAML, L_ADA, L_VERILOG, L_MATLAB, L_HASKELL, L_INNO, L_SEARCHRESULT,\
	L_CMAKE, L_YAML, L_COBOL, L_GUI4CLI, L_D, L_POWERSHELL, L_R, L_JSP,\
	L_COFFEESCRIPT, L_JSON, L_JAVASCRIPT, L_FORTRAN_77, L_BAANC, L_SREC,\
	L_IHEX, L_TEHEX, L_SWIFT,\
	L_ASN1, L_AVS, L_BLITZBASIC, L_PUREBASIC, L_FREEBASIC, \
	L_CSOUND, L_ERLANG, L_ESCRIPT, L_FORTH, L_LATEX, \
	L_MMIXAL, L_NIMROD, L_NNCRONTAB, L_OSCRIPT, L_REBOL, \
	L_REGISTRY, L_RUST, L_SPICE, L_TXT2TAGS, L_VISUALPROLOG,\
	L_EXTERNAL
	; Don't use L_JS, use L_JAVASCRIPT instead
	; The end of enumated language type, so it should be always at the end
	LangType := %
end iterate
iterate winVer, WV_UNKNOWN, WV_WIN32S, WV_95, WV_98, WV_ME, WV_NT, WV_W2K, WV_XP, WV_S2003, WV_XPX64, WV_VISTA, WV_WIN7, WV_WIN8, WV_WIN81, WV_WIN10
	winVer := %
end iterate
iterate Platform, PF_UNKNOWN, PF_X86, PF_X64, PF_IA64
	Platform := %
end iterate


define NPPMSG (WM_USER + 1000)
define NPPM_GETCURRENTSCINTILLA	(NPPMSG + 4)
define NPPM_GETCURRENTLANGTYPE  (NPPMSG + 5)
define NPPM_SETCURRENTLANGTYPE  (NPPMSG + 6)
define NPPM_GETNBOPENFILES	(NPPMSG + 7)
	define ALL_OPEN_FILES			0
	define PRIMARY_VIEW			1
	define SECOND_VIEW				2

define NPPM_GETOPENFILENAMES		(NPPMSG + 8)
define NPPM_MODELESSDIALOG		 (NPPMSG + 12)
	define MODELESSDIALOGADD		0
	define MODELESSDIALOGREMOVE	1

define NPPM_GETNBSESSIONFILES (NPPMSG + 13)
define NPPM_GETSESSIONFILES (NPPMSG + 14)
define NPPM_SAVESESSION (NPPMSG + 15)
define NPPM_SAVECURRENTSESSION (NPPMSG + 16)

		struct sessionInfo {
			TCHAR* sessionFilePathName;
			int nbFile;
			TCHAR** files;
		};

	#define NPPM_GETOPENFILENAMESPRIMARY (NPPMSG + 17)
	#define NPPM_GETOPENFILENAMESSECOND (NPPMSG + 18)

	#define NPPM_CREATESCINTILLAHANDLE (NPPMSG + 20)
	#define NPPM_DESTROYSCINTILLAHANDLE (NPPMSG + 21)
	#define NPPM_GETNBUSERLANG (NPPMSG + 22)

	#define NPPM_GETCURRENTDOCINDEX (NPPMSG + 23)
		#define MAIN_VIEW 0
		#define SUB_VIEW 1

	#define NPPM_SETSTATUSBAR (NPPMSG + 24)
		#define STATUSBAR_DOC_TYPE 0
		#define STATUSBAR_DOC_SIZE 1
		#define STATUSBAR_CUR_POS 2
		#define STATUSBAR_EOF_FORMAT 3
		#define STATUSBAR_UNICODE_TYPE 4
		#define STATUSBAR_TYPING_MODE 5

	#define NPPM_GETMENUHANDLE (NPPMSG + 25)
		#define NPPPLUGINMENU 0
		#define NPPMAINMENU 1
	; INT NPPM_GETMENUHANDLE(INT menuChoice, 0)
	; Return: menu handle (HMENU) of choice (plugin menu handle or Notepad++ main menu handle)

	#define NPPM_ENCODESCI (NPPMSG + 26)
	;ascii file to unicode
	;int NPPM_ENCODESCI(MAIN_VIEW/SUB_VIEW, 0)
	;return new unicodeMode

	#define NPPM_DECODESCI (NPPMSG + 27)
	;unicode file to ascii
	;int NPPM_DECODESCI(MAIN_VIEW/SUB_VIEW, 0)
	;return old unicodeMode

	#define NPPM_ACTIVATEDOC (NPPMSG + 28)
	;void NPPM_ACTIVATEDOC(int view, int index2Activate)

	#define NPPM_LAUNCHFINDINFILESDLG (NPPMSG + 29)
	;void NPPM_LAUNCHFINDINFILESDLG(TCHAR * dir2Search, TCHAR * filtre)

	#define NPPM_DMMSHOW (NPPMSG + 30)
	;void NPPM_DMMSHOW(0, tTbData->hClient)

	#define NPPM_DMMHIDE	(NPPMSG + 31)
	;void NPPM_DMMHIDE(0, tTbData->hClient)

	#define NPPM_DMMUPDATEDISPINFO (NPPMSG + 32)
	;void NPPM_DMMUPDATEDISPINFO(0, tTbData->hClient)

	#define NPPM_DMMREGASDCKDLG (NPPMSG + 33)
	;void NPPM_DMMREGASDCKDLG(0, &tTbData)

	#define NPPM_LOADSESSION (NPPMSG + 34)
	;void NPPM_LOADSESSION(0, const TCHAR* file name)

	#define NPPM_DMMVIEWOTHERTAB (NPPMSG + 35)
	;void WM_DMM_VIEWOTHERTAB(0, tTbData->pszName)

	#define NPPM_RELOADFILE (NPPMSG + 36)
	;BOOL NPPM_RELOADFILE(BOOL withAlert, TCHAR *filePathName2Reload)

	#define NPPM_SWITCHTOFILE (NPPMSG + 37)
	;BOOL NPPM_SWITCHTOFILE(0, TCHAR *filePathName2switch)

	#define NPPM_SAVECURRENTFILE (NPPMSG + 38)
	;BOOL NPPM_SAVECURRENTFILE(0, 0)

	#define NPPM_SAVEALLFILES	(NPPMSG + 39)
	;BOOL NPPM_SAVEALLFILES(0, 0)

	#define NPPM_SETMENUITEMCHECK	(NPPMSG + 40)
	;void WM_PIMENU_CHECK(UINT	funcItem[X]._cmdID, TRUE/FALSE)

	#define NPPM_ADDTOOLBARICON (NPPMSG + 41)
	;void WM_ADDTOOLBARICON(UINT funcItem[X]._cmdID, toolbarIcons icon)
		struct toolbarIcons {
			HBITMAP	hToolbarBmp;
			HICON	hToolbarIcon;
		};

	#define NPPM_GETWINDOWSVERSION (NPPMSG + 42)
	;winVer NPPM_GETWINDOWSVERSION(0, 0)

	#define NPPM_DMMGETPLUGINHWNDBYNAME (NPPMSG + 43)
	;HWND WM_DMM_GETPLUGINHWNDBYNAME(const TCHAR *windowName, const TCHAR *moduleName)
	; if moduleName is NULL, then return value is NULL
	; if windowName is NULL, then the first found window handle which matches with the moduleName will be returned

	#define NPPM_MAKECURRENTBUFFERDIRTY (NPPMSG + 44)
	;BOOL NPPM_MAKECURRENTBUFFERDIRTY(0, 0)

	#define NPPM_GETENABLETHEMETEXTUREFUNC (NPPMSG + 45)
	;BOOL NPPM_GETENABLETHEMETEXTUREFUNC(0, 0)

	#define NPPM_GETPLUGINSCONFIGDIR (NPPMSG + 46)
	;INT NPPM_GETPLUGINSCONFIGDIR(int strLen, TCHAR *str)
	; Get user's plugin config directory path. It's useful if plugins want to save/load parameters for the current user
	; Returns the number of TCHAR copied/to copy.
	; Users should call it with "str" be NULL to get the required number of TCHAR (not including the terminating nul character),
	; allocate "str" buffer with the return value + 1, then call it again to get the path.

	#define NPPM_MSGTOPLUGIN (NPPMSG + 47)
	;BOOL NPPM_MSGTOPLUGIN(TCHAR *destModuleName, CommunicationInfo *info)
	; return value is TRUE when the message arrive to the destination plugins.
	; if destModule or info is NULL, then return value is FALSE
		struct CommunicationInfo {
			long internalMsg;
			const TCHAR * srcModuleName;
			void * info; ; defined by plugin
		};

	#define NPPM_MENUCOMMAND (NPPMSG + 48)
	;void NPPM_MENUCOMMAND(0, int cmdID)
	; uncomment ;#include "menuCmdID.h"
	; in the beginning of this file then use the command symbols defined in "menuCmdID.h" file
	; to access all the Notepad++ menu command items

	#define NPPM_TRIGGERTABBARCONTEXTMENU (NPPMSG + 49)
	;void NPPM_TRIGGERTABBARCONTEXTMENU(int view, int index2Activate)

	#define NPPM_GETNPPVERSION (NPPMSG + 50)
	; int NPPM_GETNPPVERSION(0, 0)
	; return version
	; ex : v4.6
	; HIWORD(version) == 4
	; LOWORD(version) == 6

	#define NPPM_HIDETABBAR (NPPMSG + 51)
	; BOOL NPPM_HIDETABBAR(0, BOOL hideOrNot)
	; if hideOrNot is set as TRUE then tab bar will be hidden
	; otherwise it'll be shown.
	; return value : the old status value

	#define NPPM_ISTABBARHIDDEN (NPPMSG + 52)
	; BOOL NPPM_ISTABBARHIDDEN(0, 0)
	; returned value : TRUE if tab bar is hidden, otherwise FALSE

	#define NPPM_GETPOSFROMBUFFERID (NPPMSG + 57)
	; INT NPPM_GETPOSFROMBUFFERID(UINT_PTR bufferID, INT priorityView)
	; Return VIEW|INDEX from a buffer ID. -1 if the bufferID non existing
	; if priorityView set to SUB_VIEW, then SUB_VIEW will be search firstly
	;
	; VIEW takes 2 highest bits and INDEX (0 based) takes the rest (30 bits)
	; Here's the values for the view :
	;  MAIN_VIEW 0
	;  SUB_VIEW  1

	#define NPPM_GETFULLPATHFROMBUFFERID (NPPMSG + 58)
	; INT NPPM_GETFULLPATHFROMBUFFERID(UINT_PTR bufferID, TCHAR *fullFilePath)
	; Get full path file name from a bufferID.
	; Return -1 if the bufferID non existing, otherwise the number of TCHAR copied/to copy
	; User should call it with fullFilePath be NULL to get the number of TCHAR (not including the nul character),
	; allocate fullFilePath with the return values + 1, then call it again to get full path file name

	#define NPPM_GETBUFFERIDFROMPOS (NPPMSG + 59)
	; LRESULT NPPM_GETBUFFERIDFROMPOS(INT index, INT iView)
	; wParam: Position of document
	; lParam: View to use, 0 = Main, 1 = Secondary
	; Returns 0 if invalid

	#define NPPM_GETCURRENTBUFFERID (NPPMSG + 60)
	; LRESULT NPPM_GETCURRENTBUFFERID(0, 0)
	; Returns active Buffer

	#define NPPM_RELOADBUFFERID (NPPMSG + 61)
	; VOID NPPM_RELOADBUFFERID(UINT_PTR bufferID, BOOL alert)
	; Reloads Buffer
	; wParam: Buffer to reload
	; lParam: 0 if no alert, else alert


	#define NPPM_GETBUFFERLANGTYPE (NPPMSG + 64)
	; INT NPPM_GETBUFFERLANGTYPE(UINT_PTR bufferID, 0)
	; wParam: BufferID to get LangType from
	; lParam: 0
	; Returns as int, see LangType. -1 on error

	#define NPPM_SETBUFFERLANGTYPE (NPPMSG + 65)
	; BOOL NPPM_SETBUFFERLANGTYPE(UINT_PTR bufferID, INT langType)
	; wParam: BufferID to set LangType of
	; lParam: LangType
	; Returns TRUE on success, FALSE otherwise
	; use int, see LangType for possible values
	; L_USER and L_EXTERNAL are not supported

	#define NPPM_GETBUFFERENCODING (NPPMSG + 66)
	; INT NPPM_GETBUFFERENCODING(UINT_PTR bufferID, 0)
	; wParam: BufferID to get encoding from
	; lParam: 0
	; returns as int, see UniMode. -1 on error

	#define NPPM_SETBUFFERENCODING (NPPMSG + 67)
	; BOOL NPPM_SETBUFFERENCODING(UINT_PTR bufferID, INT encoding)
	; wParam: BufferID to set encoding of
	; lParam: encoding
	; Returns TRUE on success, FALSE otherwise
	; use int, see UniMode
	; Can only be done on new, unedited files

	#define NPPM_GETBUFFERFORMAT (NPPMSG + 68)
	; INT NPPM_GETBUFFERFORMAT(UINT_PTR bufferID, 0)
	; wParam: BufferID to get EolType format from
	; lParam: 0
	; returns as int, see EolType format. -1 on error

	#define NPPM_SETBUFFERFORMAT (NPPMSG + 69)
	; BOOL NPPM_SETBUFFERFORMAT(UINT_PTR bufferID, INT format)
	; wParam: BufferID to set EolType format of
	; lParam: format
	; Returns TRUE on success, FALSE otherwise
	; use int, see EolType format


	#define NPPM_HIDETOOLBAR (NPPMSG + 70)
	; BOOL NPPM_HIDETOOLBAR(0, BOOL hideOrNot)
	; if hideOrNot is set as TRUE then tool bar will be hidden
	; otherwise it'll be shown.
	; return value : the old status value

	#define NPPM_ISTOOLBARHIDDEN (NPPMSG + 71)
	; BOOL NPPM_ISTOOLBARHIDDEN(0, 0)
	; returned value : TRUE if tool bar is hidden, otherwise FALSE

	#define NPPM_HIDEMENU (NPPMSG + 72)
	; BOOL NPPM_HIDEMENU(0, BOOL hideOrNot)
	; if hideOrNot is set as TRUE then menu will be hidden
	; otherwise it'll be shown.
	; return value : the old status value

	#define NPPM_ISMENUHIDDEN (NPPMSG + 73)
	; BOOL NPPM_ISMENUHIDDEN(0, 0)
	; returned value : TRUE if menu is hidden, otherwise FALSE

	#define NPPM_HIDESTATUSBAR (NPPMSG + 74)
	; BOOL NPPM_HIDESTATUSBAR(0, BOOL hideOrNot)
	; if hideOrNot is set as TRUE then STATUSBAR will be hidden
	; otherwise it'll be shown.
	; return value : the old status value

	#define NPPM_ISSTATUSBARHIDDEN (NPPMSG + 75)
	; BOOL NPPM_ISSTATUSBARHIDDEN(0, 0)
	; returned value : TRUE if STATUSBAR is hidden, otherwise FALSE

	#define NPPM_GETSHORTCUTBYCMDID (NPPMSG + 76)
	; BOOL NPPM_GETSHORTCUTBYCMDID(int cmdID, ShortcutKey *sk)
	; get your plugin command current mapped shortcut into sk via cmdID
	; You may need it after getting NPPN_READY notification
	; returned value : TRUE if this function call is successful and shortcut is enable, otherwise FALSE

	#define NPPM_DOOPEN (NPPMSG + 77)
	; BOOL NPPM_DOOPEN(0, const TCHAR *fullPathName2Open)
	; fullPathName2Open indicates the full file path name to be opened.
	; The return value is TRUE (1) if the operation is successful, otherwise FALSE (0).

	#define NPPM_SAVECURRENTFILEAS (NPPMSG + 78)
	; BOOL NPPM_SAVECURRENTFILEAS (BOOL asCopy, const TCHAR* filename)

    #define NPPM_GETCURRENTNATIVELANGENCODING (NPPMSG + 79)
	; INT NPPM_GETCURRENTNATIVELANGENCODING(0, 0)
	; returned value : the current native language encoding

    #define NPPM_ALLOCATESUPPORTED   (NPPMSG + 80)
    ; returns TRUE if NPPM_ALLOCATECMDID is supported
    ; Use to identify if subclassing is necessary

	#define NPPM_ALLOCATECMDID   (NPPMSG + 81)
    ; BOOL NPPM_ALLOCATECMDID(int numberRequested, int* startNumber)
    ; sets startNumber to the initial command ID if successful
    ; Returns: TRUE if successful, FALSE otherwise. startNumber will also be set to 0 if unsuccessful

	#define NPPM_ALLOCATEMARKER  (NPPMSG + 82)
    ; BOOL NPPM_ALLOCATEMARKER(int numberRequested, int* startNumber)
    ; sets startNumber to the initial command ID if successful
    ; Allocates a marker number to a plugin
    ; Returns: TRUE if successful, FALSE otherwise. startNumber will also be set to 0 if unsuccessful

	#define NPPM_GETLANGUAGENAME  (NPPMSG + 83)
	; INT NPPM_GETLANGUAGENAME(int langType, TCHAR *langName)
	; Get programming language name from the given language type (LangType)
	; Return value is the number of copied character / number of character to copy (\0 is not included)
	; You should call this function 2 times - the first time you pass langName as NULL to get the number of characters to copy.
    ; You allocate a buffer of the length of (the number of characters + 1) then call NPPM_GETLANGUAGENAME function the 2nd time
	; by passing allocated buffer as argument langName

	#define NPPM_GETLANGUAGEDESC  (NPPMSG + 84)
	; INT NPPM_GETLANGUAGEDESC(int langType, TCHAR *langDesc)
	; Get programming language short description from the given language type (LangType)
	; Return value is the number of copied character / number of character to copy (\0 is not included)
	; You should call this function 2 times - the first time you pass langDesc as NULL to get the number of characters to copy.
    ; You allocate a buffer of the length of (the number of characters + 1) then call NPPM_GETLANGUAGEDESC function the 2nd time
	; by passing allocated buffer as argument langDesc

	#define NPPM_SHOWDOCSWITCHER    (NPPMSG + 85)
	; VOID NPPM_SHOWDOCSWITCHER(0, BOOL toShowOrNot)
	; Send this message to show or hide doc switcher.
	; if toShowOrNot is TRUE then show doc switcher, otherwise hide it.

	#define NPPM_ISDOCSWITCHERSHOWN    (NPPMSG + 86)
	; BOOL NPPM_ISDOCSWITCHERSHOWN(0, 0)
	; Check to see if doc switcher is shown.

	#define NPPM_GETAPPDATAPLUGINSALLOWED    (NPPMSG + 87)
	; BOOL NPPM_GETAPPDATAPLUGINSALLOWED(0, 0)
	; Check to see if loading plugins from "%APPDATA%\..\Local\Notepad++\plugins" is allowed.

	#define NPPM_GETCURRENTVIEW    (NPPMSG + 88)
	; INT NPPM_GETCURRENTVIEW(0, 0)
	; Return: current edit view of Notepad++. Only 2 possible values: 0 = Main, 1 = Secondary

	#define NPPM_DOCSWITCHERDISABLECOLUMN    (NPPMSG + 89)
	; VOID NPPM_DOCSWITCHERDISABLECOLUMN(0, BOOL disableOrNot)
	; Disable or enable extension column of doc switcher

	#define NPPM_GETEDITORDEFAULTFOREGROUNDCOLOR    (NPPMSG + 90)
	; INT NPPM_GETEDITORDEFAULTFOREGROUNDCOLOR(0, 0)
	; Return: current editor default foreground color. You should convert the returned value in COLORREF

	#define NPPM_GETEDITORDEFAULTBACKGROUNDCOLOR    (NPPMSG + 91)
	; INT NPPM_GETEDITORDEFAULTBACKGROUNDCOLOR(0, 0)
	; Return: current editor default background color. You should convert the returned value in COLORREF

	#define NPPM_SETSMOOTHFONT    (NPPMSG + 92)
	; VOID NPPM_SETSMOOTHFONT(0, BOOL setSmoothFontOrNot)

	#define NPPM_SETEDITORBORDEREDGE    (NPPMSG + 93)
	; VOID NPPM_SETEDITORBORDEREDGE(0, BOOL withEditorBorderEdgeOrNot)

	#define NPPM_SAVEFILE (NPPMSG + 94)
	; VOID NPPM_SAVEFILE(0, const TCHAR *fileNameToSave)

	#define NPPM_DISABLEAUTOUPDATE (NPPMSG + 95) ; 2119 in decimal
	; VOID NPPM_DISABLEAUTOUPDATE(0, 0)

	#define NPPM_REMOVESHORTCUTBYCMDID (NPPMSG + 96) ; 2120 in decimal
	; BOOL NPPM_REMOVESHORTCUTASSIGNMENT(int cmdID)
	; removes the assigned shortcut mapped to cmdID
	; returned value : TRUE if function call is successful, otherwise FALSE

	#define NPPM_GETPLUGINHOMEPATH (NPPMSG + 97)
	; INT NPPM_GETPLUGINHOMEPATH(size_t strLen, TCHAR *pluginRootPath)
	; Get plugin home root path. It's useful if plugins want to get its own path
	; by appending <pluginFolderName> which is the name of plugin without extension part.
	; Returns the number of TCHAR copied/to copy.
	; Users should call it with pluginRootPath be NULL to get the required number of TCHAR (not including the terminating nul character),
	; allocate pluginRootPath buffer with the return value + 1, then call it again to get the path.

#define	RUNCOMMAND_USER    (WM_USER + 3000)
	#define NPPM_GETFULLCURRENTPATH		(RUNCOMMAND_USER + FULL_CURRENT_PATH)
	#define NPPM_GETCURRENTDIRECTORY	(RUNCOMMAND_USER + CURRENT_DIRECTORY)
	#define NPPM_GETFILENAME			(RUNCOMMAND_USER + FILE_NAME)
	#define NPPM_GETNAMEPART			(RUNCOMMAND_USER + NAME_PART)
	#define NPPM_GETEXTPART				(RUNCOMMAND_USER + EXT_PART)
	#define NPPM_GETCURRENTWORD			(RUNCOMMAND_USER + CURRENT_WORD)
	#define NPPM_GETNPPDIRECTORY		(RUNCOMMAND_USER + NPP_DIRECTORY)
	#define NPPM_GETFILENAMEATCURSOR	(RUNCOMMAND_USER + GETFILENAMEATCURSOR)
	; BOOL NPPM_GETXXXXXXXXXXXXXXXX(size_t strLen, TCHAR *str)
	; where str is the allocated TCHAR array,
	;	     strLen is the allocated array size
	; The return value is TRUE when get generic_string operation success
	; Otherwise (allocated array size is too small) FALSE

	#define NPPM_GETCURRENTLINE			(RUNCOMMAND_USER + CURRENT_LINE)
	; INT NPPM_GETCURRENTLINE(0, 0)
	; return the caret current position line
	#define NPPM_GETCURRENTCOLUMN			(RUNCOMMAND_USER + CURRENT_COLUMN)
	; INT NPPM_GETCURRENTCOLUMN(0, 0)
	; return the caret current position column

	#define NPPM_GETNPPFULLFILEPATH			(RUNCOMMAND_USER + NPP_FULL_FILE_PATH)

		#define VAR_NOT_RECOGNIZED 0
		#define FULL_CURRENT_PATH 1
		#define CURRENT_DIRECTORY 2
		#define FILE_NAME 3
		#define NAME_PART 4
		#define EXT_PART 5
		#define CURRENT_WORD 6
		#define NPP_DIRECTORY 7
		#define CURRENT_LINE 8
		#define CURRENT_COLUMN 9
		#define NPP_FULL_FILE_PATH 10
		#define GETFILENAMEATCURSOR 11


; Notification codes
define NPPN_FIRST		1000
define NPPN_READY		1001
define NPPN_TBMODIFICATION	1002
define NPPN_FILEBEFORECLOSE	1003
define NPPN_FILEOPENED		1004
define NPPN_FILECLOSED		1005
define NPPN_FILEBEFOREOPEN	1006
define NPPN_FILEBEFORESAVE	1007
define NPPN_FILESAVED		1008
define NPPN_SHUTDOWN		1009
define NPPN_BUFFERACTIVATED	1010
define NPPN_LANGCHANGED		1011
define NPPN_WORDSTYLESUPDATED	1012
define NPPN_SHORTCUTREMAPPED	1013
define NPPN_FILEBEFORELOAD	1014
define NPPN_FILELOADFAILED	1015
define NPPN_READONLYCHANGED	1016
	define DOCSTATUS_READONLY 1
	define DOCSTATUS_BUFFERDIRTY 2
define NPPN_DOCORDERCHANGED	1017
define NPPN_SNAPSHOTDIRTYFILELOADED 1018
define NPPN_BEFORESHUTDOWN	1019
define NPPN_CANCELSHUTDOWN	1020
define NPPN_FILEBEFORERENAME	1021
define NPPN_FILERENAMECANCEL	1022
define NPPN_FILERENAMED		1023
define NPPN_FILEBEFOREDELETE	1024
define NPPN_FILEDELETEFAILED	1025
define NPPN_FILEDELETED		1026