;include '.\struct.inc'
; user mode perspective (readonly)

struct KSYSTEM_TIME
	union
		LowHigh1 rq 1
		struct
			LowPart		rd 1
			High1Time	rd 1
		end struct
	end struct
	High2Time	rd 1
end struct

;	NT_PRODUCT_TYPE
NtProductWinNt = 1
NtProductLanManNt = 2
NtProductServer = 3

;	ALTERNATIVE_ARCHITECTURE_TYPE
StandardDesign = 0
NEC98x86 = 1
EndAlternatives = 2

PROCESSOR_FEATURE_MAX=64


; https://www.geoffchappell.com/studies/windows/km/ntoskrnl/structs/kuser_shared_data/processorfeatures.htm
; 0274	ProcessorFeatures
iterate N,FLOATING_POINT_PRECISION_ERRATA,FLOATING_POINT_EMULATED,COMPARE_EXCHANGE_DOUBLE,MMX_INSTRUCTIONS_AVAILABLE,PPC_MOVEMEM_64BIT_OK,ALPHA_BYTE_INSTRUCTIONS,XMMI_INSTRUCTIONS_AVAILABLE,3DNOW_INSTRUCTIONS_AVAILABLE,RDTSC_INSTRUCTION_AVAILABLE,PAE_ENABLED,XMMI64_INSTRUCTIONS_AVAILABLE,SSE_DAZ_MODE_AVAILABLE,NX_ENABLED,SSE3_INSTRUCTIONS_AVAILABLE,COMPARE_EXCHANGE128,COMPARE64_EXCHANGE128,CHANNELS_ENABLED,XSAVE_ENABLED,ARM_VFP_32_REGISTERS_AVAILABLE,ARM_NEON_INSTRUCTIONS_AVAILABLE,SECOND_LEVEL_ADDRESS_TRANSLATION,VIRT_FIRMWARE_ENABLED,RDWRFSGSBASE_AVAILABLE,FASTFAIL_AVAILABLE,ARM_DIVIDE_INSTRUCTION_AVAILABLE,ARM_64BIT_LOADSTORE_ATOMIC,ARM_EXTERNAL_CACHE_AVAILABLE,ARM_FMAC_INSTRUCTIONS_AVAILABLE,RDRAND_INSTRUCTION_AVAILABLE,ARM_V8_INSTRUCTIONS_AVAILABLE,ARM_V8_CRYPTO_INSTRUCTIONS_AVAILABLE,ARM_V8_CRC32_INSTRUCTIONS_AVAILABLE,RDTSCP_INSTRUCTION_AVAILABLE
PF_#N := %-1 ; (indicies into byte array with boolean values)
end iterate

; 02D5	MitigationPolicies (6.2+)
NX_SUPPORT_POLICY_MASK		:=11b
NX_SUPPORT_POLICY_ALWAYSOFF	:=00b
NX_SUPPORT_POLICY_ALWAYSON	:=01b
NX_SUPPORT_POLICY_OPTIN		:=10b
NX_SUPPORT_POLICY_OPTOUT	:=11b

SEH_VALIDATION_POLICY_MASK	:=11_00b
SEH_VALIDATION_POLICY_ON	:=00_00b
SEH_VALIDATION_POLICY_OFF	:=01_00b
SEH_VALIDATION_POLICY_TELEMETRY	:=10_00b
SEH_VALIDATION_POLICY_DEFER	:=11_00b


; 02F0	SharedDataFlags (6.0+)
SHARED_GLOBAL_FLAGS_ERROR_PORT			:=0x00000001
SHARED_GLOBAL_FLAGS_ELEVATION_ENABLED		:=0x00000002
SHARED_GLOBAL_FLAGS_VIRT_ENABLED		:=0x00000004
SHARED_GLOBAL_FLAGS_INSTALLER_DETECT_ENABLED	:=0x00000008
SHARED_GLOBAL_FLAGS_LKG_ENABLED			:=0x00000010
SHARED_GLOBAL_FLAGS_DYNAMIC_PROC_ENABLED	:=0x00000020
SHARED_GLOBAL_FLAGS_CONSOLE_BROKER_ENABLED	:=0x00000040
SHARED_GLOBAL_FLAGS_SECURE_BOOT_ENABLED		:=0x00000080
SHARED_GLOBAL_FLAGS_MULTI_SESSION_SKU		:=0x00000100
SHARED_GLOBAL_FLAGS_MULTIUSERS_IN_SESSION_SKU	:=0x00000200
SHARED_GLOBAL_FLAGS_STATE_SEPARATION_ENABLED	:=0x00000400
SHARED_GLOBAL_FLAGS_SPARE			:=0x00000010 ; (Windows 7 WDK)
SHARED_GLOBAL_FLAGS_SEH_VALIDATION_ENABLED	:=0x00000040 ; (Windows 7 WDK)

; 03C6	QpcBypassEnabled (1709+)
SHARED_GLOBAL_FLAGS_QPC_BYPASS_ENABLED   :=$01
SHARED_GLOBAL_FLAGS_QPC_BYPASS_USE_MFENCE:=$10
SHARED_GLOBAL_FLAGS_QPC_BYPASS_USE_LFENCE:=$20
SHARED_GLOBAL_FLAGS_QPC_BYPASS_A73_ERRATA:=$40
SHARED_GLOBAL_FLAGS_QPC_BYPASS_USE_RDTSCP:=$80

struct _XSTATE_FEATURE
Offset	rd 1
Size	rd 1
end struct

struct XSTATE_CONFIGURATION
EnabledFeatures				rq 1
EnabledVolatileFeatures			rq 1
Size					rd 1
ControlFlags				rd 1
;	OptimizedSave:1
;	CompactionEnabled:1
Features	_XSTATE_FEATURE ; array
	rb 63*(sizeof Features)
EnabledSupervisorFeatures		rq 1
AlignedFeatures				rq 1
AllFeatureSize				rd 1
AllFeatures				rd 64+1 ; 1 pad
EnabledUserVisibleSupervisorFeatures	rq 1
end struct


virtual at 0x7FFE0000
KUSER_SHARED_DATA:
namespace KUSER_SHARED_DATA
TickCountLowDeprecated		rd 1
TickCountMultiplier		rd 1
InterruptTime		KSYSTEM_TIME
SystemTime		KSYSTEM_TIME
TimeZoneBias		KSYSTEM_TIME
ImageNumberLow			rw 1
ImageNumberHigh			rw 1
NtSystemRoot		dw 260 dup ?
MaxStackTraceDepth		rd 1
CryptoExponent			rd 1
TimeZoneId			rd 1
LargePageMinimum		rd 1
AitSamplingValue		rd 1
AppCompatFlag			rd 1
RNGSeedVersion			rq 1
GlobalValidationRunlevel	rd 1
TimeZoneBiasStamp		rd 1
NtBuildNumber			rd 1
NtProductType			rd 1 ; NT_PRODUCT_TYPE
ProductTypeIsValid		rb 2 ; BOOL, reserved
NativeProcessorArchitecture	rw 1
NtMajorVersion			rd 1
NtMinorVersion			rd 1
ProcessorFeatures		rb PROCESSOR_FEATURE_MAX + 8 ; 8 reserved
TimeSlip			rd 1
AlternativeArchitecture		rd 1 ; ALTERNATIVE_ARCHITECTURE_TYPE
BootId				rd 1
SystemExpirationDate		rq 1
SuiteMask			rd 1
KdDebuggerEnabled		rb 1
MitigationPolicies		rb 1
;	NXSupportPolicy			: 2
;	SEHValidationPolicy		: 2
;	CurDirDevicesSkippedForDlls	: 2
;	Reserved			: 2
CyclesPerYield			rw 1
ActiveConsoleId			rd 1
DismountCount			rd 1
ComPlusPackage			rd 1
LastSystemRITEventTickCount	rd 1
NumberOfPhysicalPages		rd 1
SafeBootMode			rb 1
VirtualizationFlags		rb 3 ; 2 reserved
SharedDataFlags			rd 2
;	DbgErrorPortPresent		: 1
;	DbgElevationEnabled		: 1
;	DbgVirtEnabled			: 1
;	DbgInstallerDetectEnabled	: 1
;	DbgLkgEnabled			: 1
;	DbgDynProcessorEnabled		: 1
;	DbgConsoleBrokerEnabled		: 1
;	DbgSecureBootEnabled		: 1
;	DbgMultiSessionSku		: 1
;	DbgMultiUsersInSessionSku	: 1
;	DbgStateSeparationEnabled	: 1
;	SpareBits			: 21+32
TestRetInstruction		rq 1
QpcFrequency			rq 1
SystemCall			rd 1
AllFlags			rd 1
; UserCetAvailableEnvironments
;	Win32Process		: 1
;	Sgx2Enclave		: 1
;	VbsBasicEnclave		: 1
;	SpareBits		: 29
SystemCallPad			rq 2
TickCount		KSYSTEM_TIME
label ReservedTickCountOverlay:4 at TickCount ; rd 3
label TickCountQuad:8 at TickCount
TickCountPad			rd 1
Cookie				rd 2 ; 1 pad
ConsoleSessionForegroundProcessId rq 1
TimeUpdateLock			rq 1
BaselineSystemTimeQpc		rq 1
BaselineInterruptTimeQpc	rq 1
QpcSystemTimeIncrement		rq 1
QpcInterruptTimeIncrement	rq 1
QpcSystemTimeIncrementShift	rb 1
QpcInterruptTimeIncrementShift	rb 1
UnparkedProcessorCount		rw 1
EnclaveFeatureMask		rd 4
TelemetryCoverageRound		rd 1
UserModeGlobalLogger		rw 16 ; 0x380
ImageFileExecutionOptions	rd 1
LangGenerationCount		rd 3 ; 2 reserved
InterruptTimeBias		rq 1
QpcBias				rq 1
ActiveProcessorCount		rd 1
ActiveGroupCount		rb 2 ; 1 reserved
QpcBypassEnabled		rb 1
QpcShift			rb 1
label QpcData:2 at QpcBypassEnabled
TimeZoneBiasEffectiveStart	rq 1
TimeZoneBiasEffectiveEnd	rq 1
XState				XSTATE_CONFIGURATION
FeatureConfigurationChangeStamp	KSYSTEM_TIME
Spare				rd 1
end namespace
end virtual

if 0 ; verify offsets with:
; https://www.geoffchappell.com/studies/windows/km/ntoskrnl/structs/kuser_shared_data/index.htm?tx=2,26,158;1,156
; https://www.vergiliusproject.com/kernels/x64/Windows%2010%20%7C%202016/2004%2020H1%20(May%202020%20Update)/_KUSER_SHARED_DATA
virtual at 0
        HexDigits:: db '0123456789ABCDEF'
end virtual
iterate N,TickCountLowDeprecated,TickCountMultiplier,InterruptTime,SystemTime,TimeZoneBias,ImageNumberLow,ImageNumberHigh,NtSystemRoot,MaxStackTraceDepth,CryptoExponent,TimeZoneId,LargePageMinimum,AitSamplingValue,AppCompatFlag,RNGSeedVersion,GlobalValidationRunlevel,TimeZoneBiasStamp,NtBuildNumber,NtProductType,ProductTypeIsValid,NativeProcessorArchitecture,NtMajorVersion,NtMinorVersion,ProcessorFeatures,TimeSlip,AlternativeArchitecture,BootId,SystemExpirationDate,SuiteMask,KdDebuggerEnabled,MitigationPolicies,CyclesPerYield,ActiveConsoleId,DismountCount,ComPlusPackage,LastSystemRITEventTickCount,NumberOfPhysicalPages,SafeBootMode,VirtualizationFlags,SharedDataFlags,TestRetInstruction,QpcFrequency,SystemCall,AllFlags,SystemCallPad,TickCount,ReservedTickCountOverlay,TickCountQuad,TickCountPad,Cookie,ConsoleSessionForegroundProcessId,TimeUpdateLock,BaselineSystemTimeQpc,BaselineInterruptTimeQpc,QpcSystemTimeIncrement,QpcInterruptTimeIncrement,QpcSystemTimeIncrementShift,QpcInterruptTimeIncrementShift,UnparkedProcessorCount,EnclaveFeatureMask,TelemetryCoverageRound,UserModeGlobalLogger,ImageFileExecutionOptions,LangGenerationCount,InterruptTimeBias,QpcBias,ActiveProcessorCount,ActiveGroupCount,QpcBypassEnabled,QpcShift,QpcData,TimeZoneBiasEffectiveStart,TimeZoneBiasEffectiveEnd,XState,FeatureConfigurationChangeStamp,Spare
	display 13,10,`N,9,"=",9
	repeat 1,k:KUSER_SHARED_DATA.#N - 0x7FFE0000
repeat 4
load digit:byte from HexDigits:((k) shr ((%%-%) shl 2)) and 0Fh
display digit
end repeat
	end repeat
end iterate
end if



macro Get100ns reg*
local atom
atom:	mov reg,[dword KUSER_SHARED_DATA.InterruptTime.LowHigh1]
	ror reg,32
	cmp [dword KUSER_SHARED_DATA.InterruptTime.High2Time],reg32.reg
	jnz atom ; if the 32-bit value overflowed
	ror reg,32
end macro

; UTC from Jan 1, 1601, at 100ns resolution
macro _GetSystemTimeAsFileTime reg*
	mov reg,[dword KUSER_SHARED_DATA.SystemTime.LowHigh1]
end macro
