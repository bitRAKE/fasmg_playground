
; wincon.inc
;
; This module contains the public data structures, data types, and procedures
; exported by the NT console subsystem.

struct COORD
	X dw ?
	Y dw ?
end struct

struct SMALL_RECT
	Left dw ?
	Top dw ?
	Right dw ?
	Bottom dw ?
end struct

KEY_EVENT = 1
MOUSE_EVENT = 2
WINDOW_BUFFER_SIZE_EVENT = 4
MENU_EVENT = 8
FOCUS_EVENT = 16

struct KEY_EVENT_RECORD
	bKeyDown dd ?
	wRepeatCount dw ?
	wVirtualKeyCode dw ? ; VK_*
	wVirtualScanCode dw ?
	union
		UnicodeChar du ?
		AsciiChar db ?
	end struct
	dwControlKeyState dd ?
end struct

RIGHT_ALT_PRESSED = 1
LEFT_ALT_PRESSED = 2
RIGHT_CTRL_PRESSED = 4
LEFT_CTRL_PRESSED = 8
SHIFT_PRESSED = $10
NUMLOCK_ON = $20
SCROLLLOCK_ON = $40
CAPSLOCK_ON = $80
ENHANCED_KEY = $100
NLS_DBCSCHAR = $10000
NLS_ALPHANUMERIC = 0
NLS_KATAKANA = $20000
NLS_HIRAGANA = $40000
NLS_ROMAN = $400000
NLS_IME_CONVERSION = $800000
NLS_IME_DISABLE = $20000000

struct MOUSE_EVENT_RECORD
	dwMousePosition COORD
	dwButtonState dd ?
	dwControlKeyState dd ?
	dwEventFlags dd ?
end struct

FROM_LEFT_1ST_BUTTON_PRESSED = 1
RIGHTMOST_BUTTON_PRESSED = 2
FROM_LEFT_2ND_BUTTON_PRESSED = 4
FROM_LEFT_3RD_BUTTON_PRESSED = 8
FROM_LEFT_4TH_BUTTON_PRESSED = $10

MOUSE_MOVED = 1
DOUBLE_CLICK = 2
MOUSE_WHEELED = 4
MOUSE_HWHEELED = 8

struct WINDOW_BUFFER_SIZE_RECORD
	dwSize COORD
end struct

struct MENU_EVENT_RECORD
	dwCommandId dd ?
end struct

struct FOCUS_EVENT_RECORD
	bSetFocus dd ?
end struct

struct INPUT_RECORD
	EventType dw ?,?
	union
		KeyEvent	KEY_EVENT_RECORD
		MouseEvent	MOUSE_EVENT_RECORD
		WindowBufferSizeEvent WINDOW_BUFFER_SIZE_RECORD
		MenuEvent	MENU_EVENT_RECORD
		FocusEvent	FOCUS_EVENT_RECORD
	end struct
end struct

struct CHAR_INFO
	union
		UnicodeChar du ?
		AsciiChar db ?
	end struct
	Attributes dw ?
end struct

FOREGROUND_BLUE			= 1
FOREGROUND_GREEN		= 2
FOREGROUND_RED			= 4
FOREGROUND_INTENSITY		= 8
BACKGROUND_BLUE			= $10
BACKGROUND_GREEN		= $20
BACKGROUND_RED			= $40
BACKGROUND_INTENSITY		= $80
COMMON_LVB_LEADING_BYTE		= $100
COMMON_LVB_TRAILING_BYTE	= $200
COMMON_LVB_GRID_HORIZONTAL	= $400
COMMON_LVB_GRID_LVERTICAL	= $800
COMMON_LVB_GRID_RVERTICAL	= $1000
COMMON_LVB_REVERSE_VIDEO	= $4000
COMMON_LVB_UNDERSCORE		= $8000
COMMON_LVB_SBCSDBCS		= $300

struct CONSOLE_SCREEN_BUFFER_INFO
       dwSize COORD
       dwCursorPosition COORD
       wAttributes dw ?
       srWindow SMALL_RECT
       dwMaximumWindowSize COORD
end struct

struct CONSOLE_SCREEN_BUFFER_INFOEX
       cbSize dd ?
       dwSize COORD
       dwCursorPosition COORD
       wAttributes dw ?
       srWindow SMALL_RECT
       dwMaximumWindowSize COORD
       wPopupAttributes dw ?
       bFullscreenSupported dd ?
       ColorTable dd 16 dup(?)
end struct

struct CONSOLE_CURSOR_INFO
       dwSize dd ?
       bVisible dd ?
end struct

struct CONSOLE_FONT_INFO
       nFont dd ?
       dwFontSize COORD
end struct

LF_FACESIZE := 32

struct CONSOLE_FONT_INFOEX
       cbSize dd ?
       nFont dd ?
       dwFontSize COORD
       FontFamily dd ?
       FontWeight dd ?
       FaceName du LF_FACESIZE dup(?)
end struct

HISTORY_NO_DUP_FLAG = 1

struct CONSOLE_HISTORY_INFO
       cbSize dd ?
       HistoryBufferSize dd ?
       NumberOfHistoryBuffers dd ?
       dwFlags dd ?
end struct

struct CONSOLE_SELECTION_INFO
       dwFlags dd ?
       dwSelectionAnchor COORD
       srSelection SMALL_RECT
end struct

CONSOLE_NO_SELECTION = 0
CONSOLE_SELECTION_IN_PROGRESS = 1
CONSOLE_SELECTION_NOT_EMPTY = 2
CONSOLE_MOUSE_SELECTION = 4
CONSOLE_MOUSE_DOWN = 8

CTRL_C_EVENT = 0
CTRL_BREAK_EVENT = 1
CTRL_CLOSE_EVENT = 2
CTRL_LOGOFF_EVENT = 5
CTRL_SHUTDOWN_EVENT = 6

ENABLE_PROCESSED_INPUT = 1
ENABLE_LINE_INPUT = 2
ENABLE_ECHO_INPUT = 4
ENABLE_WINDOW_INPUT = 8
ENABLE_MOUSE_INPUT = $10
ENABLE_INSERT_MODE = $20
ENABLE_QUICK_EDIT_MODE = $40
ENABLE_EXTENDED_FLAGS = $80
ENABLE_AUTO_POSITION = $100

ENABLE_PROCESSED_OUTPUT = 1
ENABLE_WRAP_AT_EOL_OUTPUT = 2

CONSOLE_REAL_OUTPUT_HANDLE = -2
CONSOLE_REAL_INPUT_HANDLE = -3

ATTACH_PARENT_PROCESS = -1

struct CONSOLE_READCONSOLE_CONTROL
       nLength dd ?
       nInitialChars dd ?
       dwCtrlWakeupMask dd ?
       dwControlKeyState dd ?
end struct

CONSOLE_TEXTMODE_BUFFER = 1

CONSOLE_FULLSCREEN = 1
CONSOLE_FULLSCREEN_HARDWARE = 2

CONSOLE_FULLSCREEN_MODE = 1
CONSOLE_WINDOWED_MODE = 2
