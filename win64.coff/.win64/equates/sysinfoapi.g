
; sysinfoapi.inc ; System Services
; ApiSet Contract for api-ms-win-core-sysinfo-l1

struct MEMORYSTATUSEX
dwLength rd 1
dwMemoryLoad rd 1
ullTotalPhys rq 1
ullAvailPhys rq 1
ullTotalPageFile rq 1
ullAvailPageFile rq 1
ullTotalVirtual rq 1
ullAvailVirtual rq 1
ullAvailExtendedVirtual rq 1
end struct

struct SYSTEM_INFO
; obsolete field left out purposefully
wProcessorArchitecture rw 2 ; 1 reserved
dwPageSize rd 1
lpMinimumApplicationAddress rq 1
lpMaximumApplicationAddress rq 1
dwActiveProcessorMask rq 1
dwNumberOfProcessors rd 1
dwProcessorType rd 1
dwAllocationGranularity rd 1
wProcessorLevel rw 1
wProcessorRevision rw 1
end struct

USER_CET_ENVIRONMENT_WIN32_PROCESS	= 0x00000000
USER_CET_ENVIRONMENT_SGX2_ENCLAVE	= 0x00000002
USER_CET_ENVIRONMENT_VBS_BASIC_ENCLAVE	= 0x00000011

; enum COMPUTER_NAME_FORMAT
iterate N, NetBIOS,DnsHostname,DnsDomain,DnsFullyQualified,PhysicalNetBIOS,PhysicalDnsHostname,PhysicalDnsDomain,PhysicalDnsFullyQualified,Max
ComputerName#N = % - 1
end iterate
