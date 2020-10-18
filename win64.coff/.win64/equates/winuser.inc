
; winuser.inc
; USER procedure declarations, constant definitions and macros

struct MSGBOXPARAMSW
cbSize			dd ?,?
hwndOwner		dq ?
hInstance		dq ?
lpszText		dq ?
lpszCaption		dq ?
dwStyle			dd ?,?
lpszIcon		dq ?
dwContextHelpId		dd ?,?
lpfnMsgBoxCallback	dq ?
dwLanguageId		dd ?,?
end struct

include 'winuser.menu.inc'
