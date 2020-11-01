; WM_KEYUP/DOWN/CHAR HIWORD(lParam) flags
KF_EXTENDED	:=$0100
KF_DLGMODE	:=$0800
KF_MENUMODE	:=$1000
KF_ALTDOWN	:=$2000
KF_REPEAT	:=$4000
KF_UP		:=$8000

; Virtual Keys, Standard Set

VK_LBUTTON	:=$01
VK_RBUTTON	:=$02
VK_CANCEL	:=$03
VK_MBUTTON	:=$04 ; NOT contiguous with L & RBUTTON
VK_XBUTTON1	:=$05 ; NOT contiguous with L & RBUTTON
VK_XBUTTON2	:=$06 ; NOT contiguous with L & RBUTTON

;	(reserved)	0x07	(bell)

VK_BACK	:=$08
VK_TAB	:=$09

;	(reserved)	0x0A - 0x0B	(linefeed and formfeed)

VK_CLEAR	:=$0C
VK_RETURN	:=$0D

;	(unassigned)	0x0E - 0x0F

VK_SHIFT	:=$10
VK_CONTROL	:=$11
VK_MENU		:=$12
VK_PAUSE	:=$13
VK_CAPITAL	:=$14

VK_KANA		:=$15
VK_HANGEUL	:=$15 ; old name - should be here for compatibility
VK_HANGUL	:=$15

;	(unassigned)	0x16

VK_JUNJA:=$17
VK_FINAL:=$18
VK_HANJA:=$19
VK_KANJI:=$19

;	(unassigned)	0x1A

VK_ESCAPE:=$1B

VK_CONVERT	:=$1C
VK_NONCONVERT	:=$1D
VK_ACCEPT	:=$1E
VK_MODECHANGE	:=$1F

VK_SPACE	:=$20
VK_PRIOR	:=$21
VK_NEXT		:=$22
VK_END		:=$23
VK_HOME		:=$24
VK_LEFT		:=$25
VK_UP		:=$26
VK_RIGHT	:=$27
VK_DOWN		:=$28
VK_SELECT	:=$29
VK_PRINT	:=$2A
VK_EXECUTE	:=$2B
VK_SNAPSHOT	:=$2C
VK_INSERT	:=$2D
VK_DELETE	:=$2E
VK_HELP		:=$2F

; VK_0 - VK_9 are the same as ASCII '0' - '9' (0x30 - 0x39)
;	(unassigned)	0x3A - 0x40
; VK_A - VK_Z are the same as ASCII 'A' - 'Z' (0x41 - 0x5A)

VK_LWIN:=$5B
VK_RWIN:=$5C
VK_APPS:=$5D

;	(reserved)	0x5E

VK_SLEEP:=$5F

VK_NUMPAD0	:=$60
VK_NUMPAD1	:=$61
VK_NUMPAD2	:=$62
VK_NUMPAD3	:=$63
VK_NUMPAD4	:=$64
VK_NUMPAD5	:=$65
VK_NUMPAD6	:=$66
VK_NUMPAD7	:=$67
VK_NUMPAD8	:=$68
VK_NUMPAD9	:=$69
VK_MULTIPLY	:=$6A
VK_ADD		:=$6B
VK_SEPARATOR	:=$6C
VK_SUBTRACT	:=$6D
VK_DECIMAL	:=$6E
VK_DIVIDE	:=$6F

VK_F1	:=$70
VK_F2	:=$71
VK_F3	:=$72
VK_F4	:=$73
VK_F5	:=$74
VK_F6	:=$75
VK_F7	:=$76
VK_F8	:=$77
VK_F9	:=$78
VK_F10	:=$79
VK_F11	:=$7A
VK_F12	:=$7B
VK_F13	:=$7C
VK_F14	:=$7D
VK_F15	:=$7E
VK_F16	:=$7F
VK_F17	:=$80
VK_F18	:=$81
VK_F19	:=$82
VK_F20	:=$83
VK_F21	:=$84
VK_F22	:=$85
VK_F23	:=$86
VK_F24	:=$87

; (UI navigation) 0x88 - 0x8F
VK_NAVIGATION_VIEW	:=$88 ; reserved
VK_NAVIGATION_MENU	:=$89 ; reserved
VK_NAVIGATION_UP	:=$8A ; reserved
VK_NAVIGATION_DOWN	:=$8B ; reserved
VK_NAVIGATION_LEFT	:=$8C ; reserved
VK_NAVIGATION_RIGHT	:=$8D ; reserved
VK_NAVIGATION_ACCEPT	:=$8E ; reserved
VK_NAVIGATION_CANCEL	:=$8F ; reserved

VK_NUMLOCK	:=$90
VK_SCROLL	:=$91

; NEC PC-9800 kbd definitions
VK_OEM_NEC_EQUAL:=$92 ; '=' key on numpad

; Fujitsu/OASYS kbd definitions
VK_OEM_FJ_JISHO		:=$92 ; 'Dictionary' key
VK_OEM_FJ_MASSHOU	:=$93 ; 'Unregister word' key
VK_OEM_FJ_TOUROKU	:=$94 ; 'Register word' key
VK_OEM_FJ_LOYA		:=$95 ; 'Left OYAYUBI' key
VK_OEM_FJ_ROYA		:=$96 ; 'Right OYAYUBI' key

;	(unassigned)	0x97 - 0x9F

; VK_L* & VK_R* - left and right Alt, Ctrl and Shift virtual keys.
; Used only as parameters to GetAsyncKeyState() and GetKeyState().
; No other API or message will distinguish left and right keys in this way.
VK_LSHIFT	:=$A0
VK_RSHIFT	:=$A1
VK_LCONTROL	:=$A2
VK_RCONTROL	:=$A3
VK_LMENU	:=$A4
VK_RMENU	:=$A5

VK_BROWSER_BACK		:=$A6
VK_BROWSER_FORWARD	:=$A7
VK_BROWSER_REFRESH	:=$A8
VK_BROWSER_STOP		:=$A9
VK_BROWSER_SEARCH	:=$AA
VK_BROWSER_FAVORITES	:=$AB
VK_BROWSER_HOME		:=$AC

VK_VOLUME_MUTE		:=$AD
VK_VOLUME_DOWN		:=$AE
VK_VOLUME_UP		:=$AF
VK_MEDIA_NEXT_TRACK	:=$B0
VK_MEDIA_PREV_TRACK	:=$B1
VK_MEDIA_STOP		:=$B2
VK_MEDIA_PLAY_PAUSE	:=$B3
VK_LAUNCH_MAIL		:=$B4
VK_LAUNCH_MEDIA_SELECT	:=$B5
VK_LAUNCH_APP1		:=$B6
VK_LAUNCH_APP2		:=$B7

;	(reserved)	0xB8 - 0xB9

VK_OEM_1	:=$BA ; ';:' for US
VK_OEM_PLUS	:=$BB ; '+' any country
VK_OEM_COMMA	:=$BC ; ',' any country
VK_OEM_MINUS	:=$BD ; '-' any country
VK_OEM_PERIOD	:=$BE ; '.' any country
VK_OEM_2	:=$BF ; '/?' for US
VK_OEM_3	:=$C0 ; '`~' for US

;	(reserved)	0xC1 - 0xC2

; 0xC3 - 0xDA : reserved for Gamepad input
VK_GAMEPAD_A				:=$C3
VK_GAMEPAD_B				:=$C4
VK_GAMEPAD_X				:=$C5
VK_GAMEPAD_Y				:=$C6
VK_GAMEPAD_RIGHT_SHOULDER		:=$C7
VK_GAMEPAD_LEFT_SHOULDER		:=$C8
VK_GAMEPAD_LEFT_TRIGGER			:=$C9
VK_GAMEPAD_RIGHT_TRIGGER		:=$CA
VK_GAMEPAD_DPAD_UP			:=$CB
VK_GAMEPAD_DPAD_DOWN			:=$CC
VK_GAMEPAD_DPAD_LEFT			:=$CD
VK_GAMEPAD_DPAD_RIGHT			:=$CE
VK_GAMEPAD_MENU				:=$CF
VK_GAMEPAD_VIEW				:=$D0
VK_GAMEPAD_LEFT_THUMBSTICK_BUTTON	:=$D1
VK_GAMEPAD_RIGHT_THUMBSTICK_BUTTON	:=$D2
VK_GAMEPAD_LEFT_THUMBSTICK_UP		:=$D3
VK_GAMEPAD_LEFT_THUMBSTICK_DOWN		:=$D4
VK_GAMEPAD_LEFT_THUMBSTICK_RIGHT	:=$D5
VK_GAMEPAD_LEFT_THUMBSTICK_LEFT		:=$D6
VK_GAMEPAD_RIGHT_THUMBSTICK_UP		:=$D7
VK_GAMEPAD_RIGHT_THUMBSTICK_DOWN	:=$D8
VK_GAMEPAD_RIGHT_THUMBSTICK_RIGHT	:=$D9
VK_GAMEPAD_RIGHT_THUMBSTICK_LEFT	:=$DA

VK_OEM_4:=$DB ; '[{' for US
VK_OEM_5:=$DC ; '\|' for US
VK_OEM_6:=$DD ; ']}' for US
VK_OEM_7:=$DE ; ''"' for US
VK_OEM_8:=$DF

;	(reserved)	0xE0

; Various extended or enhanced keyboards
VK_OEM_AX	:=$E1 ; 'AX' key on Japanese AX kbd
VK_OEM_102	:=$E2 ; "<>" or "\|" on RT 102-key kbd.
VK_ICO_HELP	:=$E3 ; Help key on ICO
VK_ICO_00	:=$E4 ; 00 key on ICO

VK_PROCESSKEY	:=$E5
VK_ICO_CLEAR	:=$E6
VK_PACKET	:=$E7

;	(unassigned)	0xE8

; Nokia/Ericsson definitions
VK_OEM_RESET	:=$E9
VK_OEM_JUMP	:=$EA
VK_OEM_PA1	:=$EB
VK_OEM_PA2	:=$EC
VK_OEM_PA3	:=$ED
VK_OEM_WSCTRL	:=$EE
VK_OEM_CUSEL	:=$EF
VK_OEM_ATTN	:=$F0
VK_OEM_FINISH	:=$F1
VK_OEM_COPY	:=$F2
VK_OEM_AUTO	:=$F3
VK_OEM_ENLW	:=$F4
VK_OEM_BACKTAB	:=$F5

VK_ATTN		:=$F6
VK_CRSEL	:=$F7
VK_EXSEL	:=$F8
VK_EREOF	:=$F9
VK_PLAY		:=$FA
VK_ZOOM		:=$FB
VK_NONAME	:=$FC
VK_PA1		:=$FD
VK_OEM_CLEAR	:=$FE
