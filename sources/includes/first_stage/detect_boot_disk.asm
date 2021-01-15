detect_boot_disk:
    pusha  ;push all register to the stack
    mov si,fault_msg  ;store fault msg in si
    xor ax,ax    ; ax =0
    int 13h	 ;interrupt 0xx13
    jc .exit_with_error  ;jump to wxit with error in case carry flag is set.
    mov si,booted_from_msg ;store booted_from_msg into si
    call bios_print ;call the routine to print the string
    mov [boot_drive],dl  ;store the boot drive number stored in dl
    cmp dl,0		 ;compare it with zero
    je .floppy           ; in case they are equal, so it is floopy.
    call load_boot_drive_params ;overwirte the [spt] and [hpc]
    mov si,drive_boot_msg  ;store the driv_boot_msg adress inside si
    jmp .finish            ;go to finish.
    .floppy:               
        mov si, floppy_boot_msg  ;store floopy_boot_msg address inside si.
        jmp .finish              ;jump to finish label
    .exit_with_error:      
        jmp hang  ;jump to hang label
    .finish: 
        call bios_print ;call bios print to print string
    popa         ;pop all registers from the stack. 
ret 

