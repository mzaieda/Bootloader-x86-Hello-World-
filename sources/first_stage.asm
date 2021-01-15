;;;;;;;;;;FIRST STAGE BOOTLOADER
[ORG 0x7c00]      ;the address at which the first stage will be loaded at in memory
;*********************************************** Macros ************************************************
%define SECOND_STAGE_CODE_SEG       0x0000      ; segment of the first stage
%define SECOND_STAGE_OFFSET         0xC000      ; offset of the first stage
%define THIRD_STAGE_CODE_SEG        0x1000      ; segment of the second stage
%define THIRD_STAGE_OFFSET          0x0000      ; offset of the second stage
%define STACK_OFFSET                0xB000      ; offset of stack
;********************************************* Main Program ********************************************
      xor ax,ax                           ; AX=0
      mov ds,ax                           ; data segment=0
      mov ss,ax                           ; stack segment =0
      mov sp,STACK_OFFSET                 ; 
      call bios_cls                       ; Clear the screen
      mov si,greeting_msg                 ; Print the greeting message
      call bios_print 
      call detect_boot_disk               ; detecting whether we are booting from the disk or a floppy
      mov di,0x8
      mov word [disk_read_segment],SECOND_STAGE_CODE_SEG
      mov word [disk_read_offset],SECOND_STAGE_OFFSET
      call read_disk_sectors              ; read second stage boot loader
      mov di,0x7F
      mov word [disk_read_segment],THIRD_STAGE_CODE_SEG
      mov word [disk_read_offset],THIRD_STAGE_OFFSET
      call read_disk_sectors   ;reads 63.5k which is the third stage bootloader

      
      mov si,second_stage_loaded_msg      
      call bios_print
      call get_key_stroke                
      jmp SECOND_STAGE_OFFSET             

      hang:             ; An infinite loop just in case interrupts are enabled. More on that later.
            hlt         ; Halt will suspend the execution. This will not return unless the processor got interrupted.
            jmp hang    ; Jump to hang so we can halt again.
;************************************ Data Declaration and Definition **********************************
      %include "sources/includes/first_stage/first_stage_data.asm"
;************************************ Subroutines/Functions Includes ***********************************
      %include "sources/includes/first_stage/detect_boot_disk.asm"
      %include "sources/includes/first_stage/load_boot_drive_params.asm"
      %include "sources/includes/first_stage/lba_2_chs.asm"
      %include "sources/includes/first_stage/read_disk_sectors.asm"
      %include "sources/includes/first_stage/bios_cls.asm"
      %include "sources/includes/first_stage/bios_print.asm"
      %include "sources/includes/first_stage/get_key_stroke.asm"
;**************************** Padding and Signature **********************************

     ; times 446-($-$$) db 0

;partition table
      times 446-($-$$) db 0   
      partition_1:

      db 0x80  ; boot\active indicator
      db 0    ;Starting Head Number
      dw 1    ;Starting Sector Number
      db 0x83  ;System ID    Filesystem type e.g. ext3, ReiserFs, NTFS
      db 254  ;Ending head
      dw 254   ;Ending sector
      dd 80325  ;LBA 
      dd 254 ;total number of sectors

      ; cylindar start and end ?

      partition_2:
      times 16 db 0
      partition_3:
      times 16 db 0
      partition_4:
      times 16 db 0

    
      db 0x55,0xAA            ; Boot sector MBR signature
;db 0x00 ;partition2 
