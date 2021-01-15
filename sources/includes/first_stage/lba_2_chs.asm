lba_2_chs:
;routine to convert from lba to chs 
pusha ;push all reg to the stack 
xor dx,dx ;dx=0
mov ax, [lba_sector] ;store the sector in lba inside ax
; [Sector] = Remainder of [lba_sector]/[spt] +1
 ; [Cylinder] = Quotient of (([lba_sector]/[spt]) / [hpc])
 ; [Head] = Remainder of (([lba_sector]/[spt]) / [hpc])
div word [spt] 
inc dx 
mov [Sector], dx
xor dx, dx 
div word[hpc]
mov [Cylinder], ax ;store the cylinder stored in ax
mov [Head], dl  ;store the head stored in dl
popa ;pop all registers from the stack
ret

