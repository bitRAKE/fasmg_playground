EXCEPTION_CONTINUE_EXECUTION		=	-1
EXCEPTION_CONTINUE_SEARCH		=	 0
EXCEPTION_NONCONTINUABLE		=	 1

EXCEPTION_MAXIMUM_PARAMETERS		=	15	; maximum number of exception parameters

EXCEPTION_GUARD_PAGE			=	 80000001h
EXCEPTION_DATATYPE_MISALIGNMENT		=	 80000002h
EXCEPTION_BREAKPOINT			=	 80000003h
EXCEPTION_SINGLE_STEP			=	 80000004h
EXCEPTION_ACCESS_VIOLATION		=	0C0000005h
EXCEPTION_IN_PAGE_ERROR			=	0C0000006h
EXCEPTION_INVALID_HANDLE		=	0C0000008h
EXCEPTION_ILLEGAL_INSTRUCTION		=	0C000001Dh
EXCEPTION_NONCONTINUABLE_EXCEPTION	=	0C0000025h
EXCEPTION_INVALID_DISPOSITION		=	0C0000026h
EXCEPTION_ARRAY_BOUNDS_EXCEEDED		=	0C000008Ch
EXCEPTION_FLT_DENORMAL_OPERAND		=	0C000008Dh
EXCEPTION_FLT_DIVIDE_BY_ZERO		=	0C000008Eh
EXCEPTION_FLT_INEXACT_RESULT		=	0C000008Fh
EXCEPTION_FLT_INVALID_OPERATION		=	0C0000090h
EXCEPTION_FLT_OVERFLOW			=	0C0000091h
EXCEPTION_FLT_STACK_CHECK		=	0C0000092h
EXCEPTION_FLT_UNDERFLOW			=	0C0000093h
EXCEPTION_INT_DIVIDE_BY_ZERO		=	0C0000094h
EXCEPTION_INT_OVERFLOW			=	0C0000095h
EXCEPTION_PRIV_INSTRUCTION		=	0C0000096h
EXCEPTION_STACK_OVERFLOW		=	0C00000FDh
CONTROL_C_EXIT				=	0C000013Ah
EXCEPTION_POSSIBLE_DEADLOCK		=	0C0000194h


struc EXCEPTION_POINTERS
label .
namespace .
ExceptionRecord		rq 1	; PEXCEPTION_RECORD
ContextRecord		rq 1	; PCONTEXT
end namespace
end struc

struc EXCEPTION_RECORD64
label .
namespace .
ExceptionCode		rd 1
ExceptionFlags		rd 1
ExceptionRecord		rq 1
ExceptionAddress	rq 1
NumberParameters	rd 2	; +padding
ExceptionInformation	rq EXCEPTION_MAXIMUM_PARAMETERS
end namespace
end struc

struc XMM_SAVE_AREA32
label .
namespace .
ControlWord	rw 1
StatusWord	rw 1
TagWord		rb 1
Reserved1	rb 1
ErrorOpcode	rw 1
ErrorOffset	rd 1
ErrorSelector	rw 1
Reserved2	rw 1
DataOffset	rd 1
DataSelector	rw 1
Reserved3	rw 1
MxCsr		rd 1
MxCsr_Mask	rd 1
FloatRegisters	rb 8*16		; every 128-bit holds st in low 80-bits or mm in low 64-bits
XmmRegisters	rb 16*16	; yeah, AMD64 in long mode (64-bit) has 16 xmm registers
Reserved4	rb 96
end namespace
end struc

struc CONTEXT64
label .
namespace .
; Register parameter home addresses.
; N.B. These fields are for convience - they could be used to extend the context record in the future.
P1Home			rq	1
P2Home			rq	1
P3Home			rq	1
P4Home			rq	1
P5Home			rq	1
P6Home			rq	1
; Control flags.
ContextFlags		rd	1
MxCsr			rd	1
; Segment Registers and processor flags.
SegCs			rw	1
SegDs			rw	1
SegEs			rw	1
SegFs			rw	1
SegGs			rw	1
SegSs			rw	1
EFlags			rd	1
; Debug registers
Dr0			rq	1
Dr1			rq	1
Dr2			rq	1
Dr3			rq	1
Dr6			rq	1
Dr7			rq	1
; Integer registers.
Rax			rq	1
Rcx			rq	1
Rdx			rq	1
Rbx			rq	1
Rsp			rq	1
Rbp			rq	1
Rsi			rq	1
Rdi			rq	1
R8			rq	1
R9			rq	1
R10			rq	1
R11			rq	1
R12			rq	1
R13			rq	1
R14			rq	1
R15			rq	1
; Program counter.
Rip			rq	1
; Floating point state.
FltSave		XMM_SAVE_AREA32
; Vector registers.
VectorRegister		rb	16*26
VectorControl		rq	1
; Special debug control registers.
DebugControl		rq	1
LastBranchToRip		rq	1
LastBranchFromRip	rq	1
LastExceptionToRip	rq	1
LastExceptionFromRip	rq	1
end namespace
end struc
