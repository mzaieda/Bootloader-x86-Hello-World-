check_long_mode:
pusha
call check_cpuid_support   
call check_long_mode_with_cpuid 
popa  
ret

check_cpuid_support:
pusha
pushfd
pushfd
pushfd
pop eax 
xor eax,0x0200000
push eax
popfd 
pushfd
pop eax
pop ecx
xor eax,ecx
and eax,0x0200000
cmp eax,0x0
jne .cpuid_supported
mov si, cpuid_not_supported
call bios_print
jmp hang
.cpuid_supported:
mov si,cpuid_supported
call bios_print
popfd
popa 
ret

check_long_mode_with_cpuid:
pusha                                  
mov eax,0x80000000
cpuid 
cmp eax,0x80000001
jl .long_mode_not_supported
mov eax,0x80000001
cpuid 
and edx,0x20000000
cmp edx, 0
je .long_mode_not_supported
mov si,long_mode_supported_msg
call bios_print
jmp .exit_check_long_mode_with_cpuid
.long_mode_not_supported:
mov si,long_mode_not_supported_msg
call bios_print
jmp hang 
.exit_check_long_mode_with_cpuid:

popa 



                         
ret
