;routine to read the boot drive number and hence update the corrosponding hpc and spt
load_boot_drive_params:
    pusha  ;push all reg to the stack
    xor di,di ;di =0
    mov es,di ; store zero inside es
    mov ah,0x8 ;func that fetch disk par.
    mov dl,[boot_drive] ;move the disk par in di
    int 0x13 ;interupt 13
    inc dh ;increment the value of dh
    mov word[hpc],0x0 ;ckear hpc
    mov[hpc+1],dh ;store dh in the lower byte.
    and cx,0000000000111111b ;get the most 6 right bits os CX
    mov word[spt],cx ;store sector value into [spt]
    popa ;pup all reg from the stack.
ret