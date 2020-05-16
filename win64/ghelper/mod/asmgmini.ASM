format PE GUI 4.0
entry start

include 'win32a.inc'

struct MEMORY_REGION
        address dd ?
        size dd ?
ends

EXPRESSION_MAX_LENGTH = 32767

IDR_CALCULATOR = 37

ID_EXPRESSION  = 100
ID_HEXADECIMAL = 116
ID_VERSION     = 199


section '.text' code readable executable

  start:

        invoke  VirtualAlloc,0,100000h,MEM_RESERVE,PAGE_READWRITE
        mov     [aout.address],eax
        mov     [aout.size],0
        invoke  VirtualAlloc,0,100000h,MEM_RESERVE,PAGE_READWRITE
        mov     [conv.address],eax
        mov     [conv.size],0

        invoke  GetModuleHandle,0
        invoke  DialogBoxParam,eax,IDR_CALCULATOR,HWND_DESKTOP,CalculatorDialog,0
        invoke  ExitProcess,0

proc CalculatorDialog hwnd,msg,wparam,lparam
        push    ebx esi edi
        cmp     [msg],WM_INITDIALOG
        je      init
        cmp     [msg],WM_COMMAND
        je      command
        cmp     [msg],WM_CLOSE
        je      close
        xor     eax,eax
        jmp     finish
    linescroll:
        invoke  SendDlgItemMessage,[hwnd],ID_EXPRESSION,EM_GETFIRSTVISIBLELINE,0,0
        invoke  SendDlgItemMessage,[hwnd],ID_HEXADECIMAL,EM_LINESCROLL,0,eax

        jmp     processed
    init:

        invoke  fasmg_GetVersion
        invoke  SetDlgItemText,[hwnd],ID_VERSION,eax

        invoke  CreateFile,_StdOut.txt,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_DELETE,\
                0,CREATE_ALWAYS,FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE,0
        mov [hStdOut],eax
        invoke  CreateFile,_StdErr.txt,GENERIC_READ or GENERIC_WRITE,FILE_SHARE_DELETE,\
                0,CREATE_ALWAYS,FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE,0
        mov [hStdErr],eax

        jmp     processed
    command:
        cmp     [wparam],IDCANCEL
        je      close
        cmp     [wparam],IDOK
        je      processed

        cmp     [wparam],ID_EXPRESSION + EN_CHANGE shl 16
        jne     processed

        invoke  GetDlgItemText,[hwnd],ID_EXPRESSION,expression_buffer,EXPRESSION_MAX_LENGTH

        invoke SetFilePointer,[hStdOut],0,0,FILE_BEGIN
        invoke SetFilePointer,[hStdErr],0,0,FILE_BEGIN
        invoke SetEndOfFile,[hStdOut]
        invoke SetEndOfFile,[hStdErr]
        invoke  fasmg_Assemble,\
                source_string,\         ; source string
                NULL,\                  ; source path
                aout,\                  ; output region
                NULL,\                  ; output path
                [hStdOut],\             ; stdout
                [hStdErr]               ; stderr
        test    eax,eax
        jnz     error

        mov     eax,[aout.size]
        lea     eax,[eax*8+8]
        cmp     eax,[conv.size]
        jbe     convert_output
        mov     [conv.size],eax
        invoke  VirtualAlloc,[conv.address],eax,MEM_COMMIT,PAGE_READWRITE
        test    eax,eax
        jnz     convert_output
        invoke  VirtualFree,[conv.address],0,MEM_RELEASE
        invoke  VirtualAlloc,0,[conv.size],MEM_COMMIT,PAGE_READWRITE
        test    eax,eax
        jz      error
        mov     [conv.address],eax
    convert_output:

        mov     esi,[aout.address]
        mov     ecx,[aout.size]
        jecxz   nobytes
        mov     edi,[conv.address]
        lea     ebx,[esi+ecx-4]
     listing:
        mov     ecx,[ebx-4]
        sub     ecx,[ebx]
        jecxz   hex_ready
      to_hex:
        lodsb
        mov     dl,al
        shr     al,4
        cmp     al,10
        sbb     al,69h
        das
        stosb
        mov     al,dl
        and     al,0Fh
        cmp     al,10
        sbb     al,69h
        das
        stosb
        mov     al,' '
        stosb
        loop    to_hex
      hex_ready:
        mov     ax,$0A0D
        stosw
        sub     ebx,4
        cmp     esi,ebx
        jb      listing
        xor     al,al
        stosb
        cmp     [aout.address],esi
        jz      nobytes
        invoke  SetDlgItemText,[hwnd],ID_HEXADECIMAL,[conv.address]
        jmp     processed
    nobytes:
        invoke SetFilePointer,[hStdOut],0,0,FILE_BEGIN
        mov [std_buf_read],0
        invoke ReadFile,[hStdOut],std_buf,std_buf_bytes,std_buf_read,0
        jmp bufout
    error:
        invoke SetFilePointer,[hStdErr],0,0,FILE_BEGIN
        mov [std_buf_read],0
        invoke ReadFile,[hStdErr],std_buf,std_buf_bytes,std_buf_read,0
    bufout:
        mov eax,[std_buf_read]
        mov byte[std_buf+eax],0
        invoke  SetDlgItemText,[hwnd],ID_HEXADECIMAL,std_buf;error_string
        jmp     processed
    close:
        invoke CloseHandle,[hStdOut]
        invoke CloseHandle,[hStdErr]
        invoke  EndDialog,[hwnd],0
    processed:
        mov     eax,1
    finish:
        pop     edi esi ebx
        ret
endp


section '.data' data readable writeable

    hStdOut rd 1
    hStdErr rd 1
    std_buf_read rd 1

    _StdOut.txt db "stdout.txt",0
    _StdErr.txt db "stderr.txt",0

    error_string:
        db 0

    source_string:
        file 'header.inc'
        db 10
    expression_buffer db EXPRESSION_MAX_LENGTH dup ?

    aout MEMORY_REGION
    conv MEMORY_REGION

    std_buf_bytes = 4096
    std_buf rb std_buf_bytes

section '.idata' import data readable writeable

  library kernel,'KERNEL32.DLL',\
          user,'USER32.DLL',\
          fasmg,'FASMG.DLL'

  import kernel,\
         CloseHandle,'CloseHandle',\
         CreateFile,'CreateFileA',\
         GetModuleHandle,'GetModuleHandleA',\
         ReadFile,'ReadFile',\
         SetEndOfFile,'SetEndOfFile',\
         SetFilePointer,'SetFilePointer',\
         VirtualAlloc,'VirtualAlloc',\
         VirtualFree,'VirtualFree',\
         ExitProcess,'ExitProcess'

  import user,\
         DialogBoxParam,'DialogBoxParamA',\
         GetDlgItemText,'GetDlgItemTextA',\
         SendDlgItemMessage,'SendDlgItemMessageA',\
         SetDlgItemText,'SetDlgItemTextA',\
         EndDialog,'EndDialog'

  import fasmg,\
         fasmg_GetVersion,'fasmg_GetVersion',\
         fasmg_Assemble,'fasmg_Assemble'


section '.rsrc' resource data readable

  directory RT_DIALOG,dialogs

  resource dialogs,\
           IDR_CALCULATOR,LANG_ENGLISH+SUBLANG_DEFAULT,calculator_dialog

  dialog calculator_dialog,'fasmg-powered mini assembler',100,120,400,200,WS_CAPTION+WS_POPUP+WS_SYSMENU+DS_MODALFRAME,,,'Courier New'
    dialogitem 'EDIT','',ID_EXPRESSION,4,6,194,180,WS_VISIBLE+WS_BORDER+WS_TABSTOP+WS_VSCROLL+WS_HSCROLL+ES_AUTOHSCROLL+ES_MULTILINE+ES_WANTRETURN+ES_AUTOVSCROLL
    dialogitem 'EDIT','',ID_HEXADECIMAL,202,6,194,180,WS_VISIBLE+WS_BORDER+WS_TABSTOP+WS_VSCROLL+WS_HSCROLL+ES_READONLY+ES_MULTILINE
    dialogitem 'STATIC','fasm g .',-1,326,188,30,8,WS_VISIBLE+SS_RIGHT
    dialogitem 'STATIC','',ID_VERSION,356,188,20,8,WS_VISIBLE+SS_RIGHT
  enddialog