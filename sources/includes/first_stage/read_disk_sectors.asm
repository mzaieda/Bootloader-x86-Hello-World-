read_disk_sectors:
pusha ;push all reg to the stack 
add di,[lba_sector] ;indicate the last sector to read
mov ax,[disk_read_segment] ;addrress of loading sector will be stored in ax
mov es, ax ;store the value of ax inside es
add bx,[disk_read_offset] ;store the offset inside bx
mov dl,[boot_drive] ; store the boot drive inside dl
.read_sector_loop: 
call lba_2_chs ;call this routine to convert
mov ah,0x2 ;read sector 
mov al,0x1 ;read only one sector
mov cx,[Cylinder] ;store cylinder inside cx
shl cx, 0x8 ;shift left by 8;
or cx, [Sector]  ;store sector into 1st 6 bits 
mov dh, [Head] ;store head in dh 
int 0x13 ;interupt 13
jc .read_disk_error 
mov si, dot 
call bios_print ;print dot  
inc word [lba_sector] ;get the next sector 
add bx, 0x200 ;advance the memory location for the new sector
cmp word[lba_sector],di ;if done?
jl .read_sector_loop ;loop again
jmp .finish ;jump to finish 
.read_disk_error: 
mov si,disk_error_msg ;printing error msg
call bios_print 
jmp hang 
.finish: 
popa ;pop all values from the stack
ret

