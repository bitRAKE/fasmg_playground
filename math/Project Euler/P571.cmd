;@REM use windows CMD processor to build ;)
;@SET INCLUDE=..\..\fasmg\examples\x86\include
;@..\..\fasmg\fasmg.exe %~nx0 %~n0.exe
;@GOTO:EOF

macro align? boundary
    rb (boundary-1)-(($ scale 0) + boundary - 1) mod boundary
end macro

; Because protections are page granular section alignment must be page size or larger.
;
; Sections are needed for the following configurations:
;   - Readonly data (same as PE header)
;   - Executable
;   - Readwrite data (also includes uninitialized data on the end)
; (extra padding bytes <= 2*(512 - 1))


IMAGE_BASE = 10000h
RVA? equ -IMAGE_BASE+ ; relative virtual address

SECTION_ALIGNMENT = 4096
FILE_ALIGNMENT = 512

org IMAGE_BASE

  dd 'MZ'
  rb 64-8
  dd 64 ; e_lfanew

; IMAGE_FILE_HEADER
  dd 'PE'				; Signature
  dw 8664h				; PROCESSOR_AMD_X8664
  dw 2					; NumberOfSections
  dd ?					; #### ; TimeDateStamp
  dd ?					; #### ; PointerToSymbolTable
  dd ?					; #### ; NumberOfSymbols
  dw Sections - Optional		; RVA SizeOfOptionalHeader
  dw 0002h				; Characteristics ; IMAGE_FILE_32BIT_MACHINE or IMAGE_FILE_EXECUTABLE_IMAGE

Optional: ; IMAGE_OPTIONAL_HEADER64
  ; Standard Fields:
  dw 020Bh ; PE+ ; IMAGE_NT_OPTIONAL_HDR64_MAGIC
  db ?,?				; ## LinkerVersion
  dd ?					; #### ; SizeOfCode
  dd ?					; #### ; SizeOfInitializedData
  dd ?					; #### ; SizeOfUninitializedData
  dd RVA Main				; RVA AddressOfEntryPoint
  dd ?					; #### ; BaseOfCode

  ; Windows Specific Fields:
  dq IMAGE_BASE 			; ImageBase
  dd SECTION_ALIGNMENT			; memory align of sections
  dd FILE_ALIGNMENT			; file align of sections
  dw ?,?				; OperatingSystemVersion
  dw ?,?				; ImageVersion
  dw 5,2				; SubsystemVersion
  dd ?					; Win32VersionValue
  dd SizeOfImage ;*SizeOfImage, must be multiple of section alignment
  dd SizeOfHeaders ; SizeOfHeaders, must be a multiple of file alignment
  dd ?					; #### checksum
  dw 0003h				; IMAGE_SUBSYSTEM_WINDOWS_CUI
  dw 8000h				; IMAGE_DLLCHARACTERISTICS_TERMINAL_SERVER_AWARE
  dq 0,0				; stack: reserve, commit
  dq 0,0				; heap: reserve, commit
  dd ?					; loader flags, obsolete
  dd 2				       ; number of directories

; Data Directories:
  dd 0,0 ; Export Table 		; RVA, Size
  dd RVA import_, 0 ;end_import-import_
	; Resource
	; Exception
	; Certificate
	; Relocation
	; Debug
	; Copyright
	; Globalptr
	; TLS Table
	; LoadConfig
	; BoundImport
	; IAT
	; DelayImport
	; COM+
	; Reserved



IMAGE_SCN_TYPE_NO_PAD		 = 0x00000008
IMAGE_SCN_CNT_CODE		 = 0x00000020
IMAGE_SCN_CNT_INITIALIZED_DATA	 = 0x00000040
IMAGE_SCN_CNT_UNINITIALIZED_DATA = 0x00000080
IMAGE_SCN_LNK_OTHER		 = 0x00000100
IMAGE_SCN_LNK_INFO		 = 0x00000200
IMAGE_SCN_LNK_REMOVE		 = 0x00000800
IMAGE_SCN_LNK_COMDAT		 = 0x00001000
IMAGE_SCN_GPREL 		 = 0x00008000
IMAGE_SCN_MEM_PURGEABLE 	 = 0x00020000
IMAGE_SCN_MEM_16BIT		 = 0x00020000
IMAGE_SCN_MEM_LOCKED		 = 0x00040000
IMAGE_SCN_MEM_PRELOAD		 = 0x00080000
IMAGE_SCN_ALIGN_1BYTES		 = 0x00100000
IMAGE_SCN_ALIGN_2BYTES		 = 0x00200000
IMAGE_SCN_ALIGN_4BYTES		 = 0x00300000
IMAGE_SCN_ALIGN_8BYTES		 = 0x00400000
IMAGE_SCN_ALIGN_16BYTES 	 = 0x00500000
IMAGE_SCN_ALIGN_32BYTES 	 = 0x00600000
IMAGE_SCN_ALIGN_64BYTES 	 = 0x00700000
IMAGE_SCN_ALIGN_128BYTES	 = 0x00800000
IMAGE_SCN_ALIGN_256BYTES	 = 0x00900000
IMAGE_SCN_ALIGN_512BYTES	 = 0x00A00000
IMAGE_SCN_ALIGN_1024BYTES	 = 0x00B00000
IMAGE_SCN_ALIGN_2048BYTES	 = 0x00C00000
IMAGE_SCN_ALIGN_4096BYTES	 = 0x00D00000
IMAGE_SCN_ALIGN_8192BYTES	 = 0x00E00000
IMAGE_SCN_LNK_NRELOC_OVFL	 = 0x01000000
IMAGE_SCN_MEM_DISCARDABLE	 = 0x02000000
IMAGE_SCN_MEM_NOT_CACHED	 = 0x04000000
IMAGE_SCN_MEM_NOT_PAGED 	 = 0x08000000
IMAGE_SCN_MEM_SHARED		 = 0x10000000
IMAGE_SCN_MEM_EXECUTE		 = 0x20000000
IMAGE_SCN_MEM_READ		 = 0x40000000
IMAGE_SCN_MEM_WRITE		 = 0x80000000

Sections:

Section_Code:
  dq '.bitRAKE'
  dd Section_Code.Length		; VirtualSize
  dd RVA Section_Code.Base		; RVA VirtualAddress
  dd Section_Code.Bytes 		; SizeOfRawData
  dd Section_Code.FileOffset		; PointerToRawData
  dd 0					; PointerToRelocations
  dd 0					; PointerToLinenumbers
  dw 0					; NumberOfRelocations
  dw 0					; NumberOfLinenumbers
  dd IMAGE_SCN_MEM_EXECUTE or IMAGE_SCN_MEM_SHARED or IMAGE_SCN_ALIGN_4096BYTES

Section_Data:
  dq '.DATA'
  dd Section_Data.Length		; VirtualSize
  dd RVA Section_Data.Base		; RVA VirtualAddress
  dd Section_Data.Bytes 		; SizeOfRawData
  dd Section_Data.FileOffset		; PointerToRawData
  dd 0					; PointerToRelocations
  dd 0					; PointerToLinenumbers
  dw 0					; NumberOfRelocations
  dw 0					; NumberOfLinenumbers
  dd IMAGE_SCN_MEM_WRITE or IMAGE_SCN_ALIGN_4096BYTES

;###############################################################################
; Constant data goes here...

Output db "Found %I64u, Sum %I64u",13,10,0

Error_Messages dd \
  .Not_Enough_Digits

  .Not_Enough_Digits db "Insufficient digits for 10, 12-Super-Pandigital numbers!",13,10,0

;###############################################################################
; DLL Strings

  _kernel32 db "kernel32",0
  _msvcrt db "msvcrt",0

; Hint/Name Table

  rb ($ and 1) ; align 2
  _ExitProcess db 0,0,"ExitProcess",0

  rb ($ and 1) ; align 2
  _printf db 0,0,"printf",0




;###############################################################################
VIRTUAL at $
  ALIGN SECTION_ALIGNMENT,0
  TEMP = $
END VIRTUAL
ORG $%
ALIGN FILE_ALIGNMENT,0
Section_Code.FileOffset:
ORG TEMP
Section_Code.Base:

  include 'x64.inc'
  use64


Main: ;=RIP=RDX=R9

	xor r8,r8		; clear running sum
	push 10 		; problem wants sum of smallest 10
.next:
	call Permute_Digits	; 12-pandigital by design
	mov cl,0
	jc .FAIL

	; what is base-12 number in binary?
	push 12
	xor eax,eax
	pop rcx
  .b12: movzx edx,[Digits+rcx-1]
	imul rax,rax,12
	add rax,rdx
	loop .b12

	call Super_PanDigital_11_RAX
	jnc .next

	; output number in base 10, and sum thus far
	add r8,rax
	push r8
	enter 32,0
	xchg rdx,rax
	lea rcx,[Output]
	call [printf]
	leave
	pop r8

	sub dword [rsp],1
	jnz .next
	pop rcx ; zero
	call [ExitProcess]
	int3

; POSSIBLE ERRORS:
;   1) 12 digits are not sufficient to generate 10,
;      12-Super-Pandigital numbers!
.FAIL:	movzx ecx,cl
	push rcx rcx
	enter 32,0
	mov ecx,[Error_Messages+ecx*4]
	call [printf]
	leave
	pop rcx rcx
	call [ExitProcess]
	int3



align 64
; Computer the next lexicographical order of Digits:
; RAX RCX RDX are trashed
Permute_Digits:

 ; find suffix of increasing values

	lea rcx,[Digits]
 .sufx: add rcx,1
	mov al,[rcx]
	cmp al,[rcx-1]
	jnc .sufx
	cmp rcx,Digits_end
	jnc .bad_pivot

 ; swap pivot into suffix order

	lea rdx,[Digits-1]
 .pvt:	add rdx,1
	cmp al,[rdx]
	jnc .pvt
 .swap: mov ah,[rdx]
	mov [rdx],al
	mov [rcx],ah

 ; reverse suffix to create lexical minimal

	sub rcx,1
	lea rdx,[Digits]
 .rev:	mov ah,[rcx]
	mov al,[rdx]
	mov [rdx],ah
	mov [rcx],al
	add rdx,1
	sub rcx,1
	cmp rdx,rcx		; insure one less itteration
	jc .rev 		; in the odd length suffix case
;	clc
	retn
 .bad_pivot:
	stc			; already at last permutation
	retn



align 64
; pass 12-pandigital numbers in RAX to check
Super_PanDigital_11_RAX:
	push rbx rcx rdx
	push 12
	pop rbx
  .check:
	sub ebx,1
	push rax
	xor ecx,ecx
	bts ecx,ebx
	sub ecx,1		; bit set for each base digit
  .more_digits:
	xor edx,edx
	div rbx 		; extract digit
	btr ecx,edx		; tag digit
	jrcxz .pandigital	; all digits present
; NOTE: most significant zero digits do not count
	test rax,rax
	jnz .more_digits
;	clc			; failed
	pop rax
	jmp .end
  .pandigital:
	pop rax
	cmp ebx,2
	jnz .check
	stc			; RAX is 12-super-pandigital
  .end: pop rdx rcx rbx
	retn

Section_Code.Bytes = $ - Section_Code.Base
Section_Code.Length = $ - Section_Code.Base




;###############################################################################
VIRTUAL at $
  ALIGN SECTION_ALIGNMENT
  TEMP = $
END VIRTUAL
ORG $%
ALIGN FILE_ALIGNMENT,0
Section_Data.FileOffset:
ORG TEMP
Section_Data.Base:


align 64
; start with last leading zero permutation because leading zeroes don't count.
Digits db 1,2,3,4,5,6,7,8,9,10,11,0
Digits_end:
  db 0 ; force termination of suffix search
align 64


import_:
  dd 0, 0, 0, RVA _kernel32, RVA kernel32_iat
  dd 0, 0, 0, RVA _msvcrt, RVA msvcrt_iat
  dd 0,0,0,0,0

kernel32_iat:
  ExitProcess dq RVA _ExitProcess
  dq 0

msvcrt_iat:
  printf dq RVA _printf
  dq 0
end_import:

Section_Data.Bytes = $ - Section_Data.Base
Section_Data.Length = $ - Section_Data.Base




;###############################################################################
VIRTUAL at $
  ALIGN SECTION_ALIGNMENT
  SizeOfImage = RVA $
END VIRTUAL

SizeOfHeaders = Section_Code.FileOffset ; same as first segment file offset
