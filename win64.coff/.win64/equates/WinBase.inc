
; WinBase.inc

;include 'apiquery2.inc'
;include 'processenv.inc'
;include 'fileapifromapp.inc'
;include 'debugapi.inc'
;include 'utilapiset.inc'
;include 'handleapi.inc'
;include 'errhandlingapi.inc'
;include 'fibersapi.inc'
;include 'namedpipeapi.inc'
;include 'profileapi.inc'
;include 'heapapi.inc'
;include 'ioapiset.inc'
;include 'synchapi.inc'
;include 'interlockedapi.inc'
;include 'processthreadsapi.inc'
;include 'sysinfoapi.inc'
;include 'memoryapi.inc'
;include 'enclaveapi.inc'
;include 'threadpoollegacyapiset.inc'
;include 'threadpoolapiset.inc'
;include 'jobapi.inc'
;include 'jobapi2.inc'
;include 'wow64apiset.inc'
;include 'libloaderapi.inc'
;include 'securitybaseapi.inc'
;include 'namespaceapi.inc'
;include 'systemtopologyapi.inc'
;include 'processtopologyapi.inc'
;include 'securityappcontainer.inc'
;include 'realtimeapiset.inc'



FILE_FLAG_WRITE_THROUGH		=0x80000000
FILE_FLAG_OVERLAPPED		=0x40000000
FILE_FLAG_NO_BUFFERING		=0x20000000
FILE_FLAG_RANDOM_ACCESS		=0x10000000
FILE_FLAG_SEQUENTIAL_SCAN	=0x08000000
FILE_FLAG_DELETE_ON_CLOSE	=0x04000000
FILE_FLAG_BACKUP_SEMANTICS	=0x02000000
FILE_FLAG_POSIX_SEMANTICS	=0x01000000
FILE_FLAG_SESSION_AWARE		=0x00800000
FILE_FLAG_OPEN_REPARSE_POINT	=0x00200000
FILE_FLAG_OPEN_NO_RECALL	=0x00100000
FILE_FLAG_FIRST_PIPE_INSTANCE	=0x00080000
FILE_FLAG_OPEN_REQUIRING_OPLOCK	=0x00040000



; Application restart and data recovery

RESTART_MAX_CMD_LINE=1024
RESTART_NO_CRASH=1
RESTART_NO_HANG=2
RESTART_NO_PATCH=4
RESTART_NO_REBOOT=8

RECOVERY_DEFAULT_PING_INTERVAL=5000
RECOVERY_MAX_PING_INTERVAL=(5 * 60 * 1000)
