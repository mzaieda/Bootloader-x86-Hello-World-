first_stage_data:
boot_drive db 0x0 ;intialize a variable to store bood drive no inside the memory.
lba_sector dw 0x1  ;intialize a variable to store next sector read with 1
spt dw 0x12        ;var to store the number of sector/track
hpc dw 0x2	   ; var to store the number of head/cy;inder
Cylinder dw 0x0    ;var to store cylinder and gets intialized by 0
Head db 0x0        ; var to store heads and gets intialized by 0
Sector dw 0x0      ;var to store sectors and gets intialized by 0
disk_error_msg db 'Disk Error',13,10,0  ;an error msg to be displayed in first stage 
fault_msg db 'Unknown Boot Device',13,10,0  ;an error msg to be displayed in first stage
booted_from_msg db 'Booted from ',0 ;a msg to be displayed in first stage
floppy_boot_msg db 'Floppy',13,10,0 ;a  msg to be displayed in first stage
drive_boot_msg db 'Disk',13,10,0 ;a msg to be displayed in first stage
greeting_msg db '1st Stage Loader',13,10,0 ;a greetings msg to be displayed in first stage
second_stage_loaded_msg db 13,10,'2nd Stage loaded, press any key to resume!',0
dot db '.',0
newline db 13,10,0 
disk_read_segment dw 0 
disk_read_offset dw 0
