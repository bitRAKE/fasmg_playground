iterate L,\
	L_TEXT,L_PHP,L_C,L_CPP,L_CS,L_OBJC,L_JAVA,L_RC,\
	L_HTML,L_XML,L_MAKEFILE,L_PASCAL,L_BATCH,L_INI,L_ASCII,L_USER,\
	L_ASP,L_SQL,L_VB,L_JS,L_CSS,L_PERL,L_PYTHON,L_LUA,\
	L_TEX,L_FORTRAN,L_BASH,L_FLASH,L_NSIS,L_TCL,L_LISP,L_SCHEME,\
	L_ASM,L_DIFF,L_PROPS,L_PS,L_RUBY,L_SMALLTALK,L_VHDL,L_KIX,\
	L_AU3,L_CAML,L_ADA,L_VERILOG,L_MATLAB,L_HASKELL,L_INNO,L_SEARCHRESULT,\
	L_CMAKE,L_YAML,L_COBOL,L_GUI4CLI,L_D,L_POWERSHELL,L_R,L_JSP,\
	L_COFFEESCRIPT,L_JSON,L_JAVASCRIPT,L_FORTRAN_77,L_BAANC,L_SREC,L_IHEX,L_TEHEX,\
	L_SWIFT,L_ASN1,L_AVS,L_BLITZBASIC,L_PUREBASIC,L_FREEBASIC,L_CSOUND,L_ERLANG,\
	L_ESCRIPT,L_FORTH,L_LATEX,L_MMIXAL,L_NIMROD,L_NNCRONTAB,L_OSCRIPT,L_REBOL,\
	L_REGISTRY,L_RUST,L_SPICE,L_TXT2TAGS,L_VISUALPROLOG,\
	L_EXTERNAL ; The End of enumated language type
LangType.#L = %
end iterate

iterate W, WV_UNKNOWN,WV_WIN32S,WV_95,WV_98,WV_ME,WV_NT,WV_W2K,WV_XP,WV_S2003,WV_XPX64,WV_VISTA,WV_WIN7,WV_WIN8,WV_WIN81,WV_WIN10
winVer.#W = %
end iterate

iterate P, PF_UNKNOWN,PF_X86,PF_X64,PF_IA64
Platform.#P = %
end iterate



NPPMSG = (WM_USER + 1000)

NPPM_GETCURRENTSCINTILLA = (NPPMSG + 4)
NPPM_GETCURRENTLANGTYPE = (NPPMSG + 5)
NPPM_SETCURRENTLANGTYPE = (NPPMSG + 6)

NPPM_GETNBOPENFILES = (NPPMSG + 7)
	ALL_OPEN_FILES	= 0
	PRIMARY_VIEW	= 1
	SECOND_VIEW	= 2

NPPM_GETOPENFILENAMES = (NPPMSG + 8)

NPPM_MODELESSDIALOG = (NPPMSG + 12)
	MODELESSDIALOGADD	= 0
	MODELESSDIALOGREMOVE	= 1

NPPM_GETNBSESSIONFILES = (NPPMSG + 13)
NPPM_GETSESSIONFILES = (NPPMSG + 14)
NPPM_SAVESESSION = (NPPMSG + 15)
NPPM_SAVECURRENTSESSION = (NPPMSG + 16)
;		struct sessionInfo {
;			TCHAR* sessionFilePathName;
;			int nbFile;
;			TCHAR** files;
;		};
NPPM_GETOPENFILENAMESPRIMARY = (NPPMSG + 17)
NPPM_GETOPENFILENAMESSECOND = (NPPMSG + 18)

NPPM_CREATESCINTILLAHANDLE = (NPPMSG + 20)
NPPM_DESTROYSCINTILLAHANDLE = (NPPMSG + 21)
NPPM_GETNBUSERLANG = (NPPMSG + 22)

NPPM_GETCURRENTDOCINDEX = (NPPMSG + 23)
	MAIN_VIEW = 0
	SUB_VIEW = 1

NPPM_SETSTATUSBAR = (NPPMSG + 24)
	STATUSBAR_DOC_TYPE	= 0
	STATUSBAR_DOC_SIZE	= 1
	STATUSBAR_CUR_POS	= 2
	STATUSBAR_EOF_FORMAT	= 3
	STATUSBAR_UNICODE_TYPE	= 4
	STATUSBAR_TYPING_MODE	= 5

NPPM_GETMENUHANDLE = (NPPMSG + 25)
	NPPPLUGINMENU = 0
	NPPMAINMENU = 1

NPPM_ENCODESCI = (NPPMSG + 26)
NPPM_DECODESCI = (NPPMSG + 27)
NPPM_ACTIVATEDOC = (NPPMSG + 28)
NPPM_LAUNCHFINDINFILESDLG = (NPPMSG + 29)
NPPM_DMMSHOW = (NPPMSG + 30)
NPPM_DMMHIDE = (NPPMSG + 31)
NPPM_DMMUPDATEDISPINFO = (NPPMSG + 32)
NPPM_DMMREGASDCKDLG = (NPPMSG + 33)
NPPM_LOADSESSION = (NPPMSG + 34)
NPPM_DMMVIEWOTHERTAB = (NPPMSG + 35)
NPPM_RELOADFILE = (NPPMSG + 36)
NPPM_SWITCHTOFILE = (NPPMSG + 37)
NPPM_SAVECURRENTFILE = (NPPMSG + 38)
NPPM_SAVEALLFILES = (NPPMSG + 39)
NPPM_SETMENUITEMCHECK = (NPPMSG + 40)
NPPM_ADDTOOLBARICON = (NPPMSG + 41)
;		struct toolbarIcons {
;			HBITMAP	hToolbarBmp;
;			HICON	hToolbarIcon;
;		};
NPPM_GETWINDOWSVERSION = (NPPMSG + 42)
NPPM_DMMGETPLUGINHWNDBYNAME = (NPPMSG + 43)
NPPM_MAKECURRENTBUFFERDIRTY = (NPPMSG + 44)
NPPM_GETENABLETHEMETEXTUREFUNC = (NPPMSG + 45)
NPPM_GETPLUGINSCONFIGDIR = (NPPMSG + 46)
NPPM_MSGTOPLUGIN = (NPPMSG + 47)
;		struct CommunicationInfo {
;			long internalMsg;
;			const TCHAR * srcModuleName;
;			void * info; // defined by plugin
;		};
NPPM_MENUCOMMAND = (NPPMSG + 48)
NPPM_TRIGGERTABBARCONTEXTMENU = (NPPMSG + 49)
NPPM_GETNPPVERSION = (NPPMSG + 50)
NPPM_HIDETABBAR = (NPPMSG + 51)
NPPM_ISTABBARHIDDEN = (NPPMSG + 52)
NPPM_GETPOSFROMBUFFERID = (NPPMSG + 57)
NPPM_GETFULLPATHFROMBUFFERID = (NPPMSG + 58)
NPPM_GETBUFFERIDFROMPOS = (NPPMSG + 59)
NPPM_GETCURRENTBUFFERID = (NPPMSG + 60)
NPPM_RELOADBUFFERID = (NPPMSG + 61)
; 62
; 63
NPPM_GETBUFFERLANGTYPE = (NPPMSG + 64)
NPPM_SETBUFFERLANGTYPE = (NPPMSG + 65)
NPPM_GETBUFFERENCODING = (NPPMSG + 66)
NPPM_SETBUFFERENCODING = (NPPMSG + 67)
NPPM_GETBUFFERFORMAT = (NPPMSG + 68)
NPPM_SETBUFFERFORMAT = (NPPMSG + 69)
NPPM_HIDETOOLBAR = (NPPMSG + 70)
NPPM_ISTOOLBARHIDDEN = (NPPMSG + 71)
NPPM_HIDEMENU = (NPPMSG + 72)
NPPM_ISMENUHIDDEN = (NPPMSG + 73)
NPPM_HIDESTATUSBAR = (NPPMSG + 74)
NPPM_ISSTATUSBARHIDDEN = (NPPMSG + 75)
NPPM_GETSHORTCUTBYCMDID = (NPPMSG + 76)
NPPM_DOOPEN = (NPPMSG + 77)
NPPM_SAVECURRENTFILEAS = (NPPMSG + 78)
NPPM_GETCURRENTNATIVELANGENCODING = (NPPMSG + 79)
NPPM_ALLOCATESUPPORTED   = (NPPMSG + 80)
NPPM_ALLOCATECMDID   = (NPPMSG + 81)
NPPM_ALLOCATEMARKER  = (NPPMSG + 82)
NPPM_GETLANGUAGENAME  = (NPPMSG + 83)
NPPM_GETLANGUAGEDESC  = (NPPMSG + 84)
NPPM_SHOWDOCSWITCHER    = (NPPMSG + 85)
NPPM_ISDOCSWITCHERSHOWN    = (NPPMSG + 86)
NPPM_GETAPPDATAPLUGINSALLOWED    = (NPPMSG + 87)
NPPM_GETCURRENTVIEW    = (NPPMSG + 88)
NPPM_DOCSWITCHERDISABLECOLUMN    = (NPPMSG + 89)
NPPM_GETEDITORDEFAULTFOREGROUNDCOLOR    = (NPPMSG + 90)
NPPM_GETEDITORDEFAULTBACKGROUNDCOLOR    = (NPPMSG + 91)
NPPM_SETSMOOTHFONT    = (NPPMSG + 92)
NPPM_SETEDITORBORDEREDGE    = (NPPMSG + 93)
NPPM_SAVEFILE = (NPPMSG + 94)
NPPM_DISABLEAUTOUPDATE = (NPPMSG + 95)
NPPM_REMOVESHORTCUTBYCMDID = (NPPMSG + 96)
NPPM_GETPLUGINHOMEPATH = (NPPMSG + 97)




RUNCOMMAND_USER = (WM_USER + 3000)
iterate R,NPPM_GETFULLCURRENTPATH,NPPM_GETCURRENTDIRECTORY,NPPM_GETFILENAME,NPPM_GETNAMEPART,NPPM_GETEXTPART,NPPM_GETCURRENTWORD,NPPM_GETNPPDIRECTORY,NPPM_GETCURRENTLINE,NPPM_GETCURRENTCOLUMN,NPPM_GETNPPFULLFILEPATH,NPPM_GETFILENAMEATCURSOR
	R = RUNCOMMAND_USER + %
end iterate


; Notification codes

NPPN_FIRST = 1000
iterate N,NPPN_READY,NPPN_TBMODIFICATION,NPPN_FILEBEFORECLOSE,NPPN_FILEOPENED,NPPN_FILECLOSED,NPPN_FILEBEFOREOPEN,NPPN_FILEBEFORESAVE,NPPN_FILESAVED,NPPN_SHUTDOWN,NPPN_BUFFERACTIVATED,NPPN_LANGCHANGED,NPPN_WORDSTYLESUPDATED,NPPN_SHORTCUTREMAPPED,NPPN_FILEBEFORELOAD,NPPN_FILELOADFAILED,NPPN_READONLYCHANGED,NPPN_DOCORDERCHANGED,NPPN_SNAPSHOTDIRTYFILELOADED,NPPN_BEFORESHUTDOWN,NPPN_CANCELSHUTDOWN,NPPN_FILEBEFORERENAME,NPPN_FILERENAMECANCEL,NPPN_FILERENAMED,NPPN_FILEBEFOREDELETE,NPPN_FILEDELETEFAILED,NPPN_FILEDELETED
	N = NPPN_FIRST + %
end iterate

DOCSTATUS_READONLY = 1
DOCSTATUS_BUFFERDIRTY = 2