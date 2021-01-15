%define CONFIG_ADDRESS  0xcf8
%define CONFIG_DATA     0xcfc

ata_device_msg db 'Found ATA Controller',13,10,0
pci_header times 512 db 0



struc PCI_CONF_SPACE 
.vendor_id          resw    1
.device_id          resw    1
.command            resw    1
.status             resw    1
.rev                resb    1
.prog_if            resb    1
.subclass           resb    1
.class              resb    1
.cache_line_size    resb    1
.latency            resb    1
.header_type        resb    1
.bist               resb    1
.bar0               resd    1
.bar1               resd    1
.bar2               resd    1
.bar3               resd    1
.bar4               resd    1
.bar5               resd    1
.reserved           resd    2
.int_line           resb    1
.int_pin            resb    1
.min_grant          resb    1
.max_latency        resb    1
.data               resb    192
endstruc

get_pci_device:
pushaq
        xor rax,rax
        ;Composing the Command Register ( in eax ): Bit 23-16 : bus , Bit 15-11 : device , Bit 10-8 : function , Bit 7-2 : offset, Bit 0-1 : 00, Bit 31 : Enable bit
        xor rbx,rbx 
        mov bl,[bus]
        shl ebx,16
        or eax,ebx
        xor rbx,rbx 
        mov bl,[device]
        shl ebx,11
        or eax,ebx
        xor rbx,rbx 
        mov bl,[function]
        shl ebx,8
        or eax,ebx
        or eax,0x80000000 
        xor rsi,rsi ; Zero rsi as we'll use it as an offset
        pci_config_space_read_loop:
        push rax ; Save Initial Command Register ( with rsi as zeros)
        or rax,rsi ; oring with offset
        and al,0xfc ; last 2 bits are zeros
        mov dx,CONFIG_ADDRESS
        out dx,eax          ; Write from command port
        mov dx,CONFIG_DATA
        xor rax,rax
        in eax,dx           ;write from data port
        mov [pci_header+rsi],eax ;store in memory the 32 bits that were reveived in eax ( rsi is the offset)
     
        add rsi,0x4 ; Advance Offset by 4 ( 32 bits )
        pop rax ; Restore initial Command Register
        cmp rsi,0xff ; Check if we read the whole configuration space (256 bytes)
        jl pci_config_space_read_loop ;loop

;;;;;;;;;;;;;;;;;;;;;;;;From here;;;;;;;;;;;;;;;;;

; read the device header 
            cmp word[pci_header+PCI_CONF_SPACE.device_id],0xFFFF   ; if we receive ff then there is no device connected
            je .no_device_connected

            ;check if the device is the ATA
            cmp byte[pci_header+PCI_CONF_SPACE.class],0x01 ;ata's class os 0x1
            jne .not_ata
            cmp byte[pci_header+PCI_CONF_SPACE.subclass],0x01   ; subclass = 0x1  --> pata
            je .ata_detected
            cmp byte[pci_header+PCI_CONF_SPACE.subclass],0x06    ; subclass = 0x6  --> sata
            je .ata_detected
            jmp .not_ata
            .ata_detected:  ;display message if the ata is found
            mov rsi, ata_device_msg
            call video_print
            call ata_copy_pci_header

            .not_ata:  ;prints the device info (vendor id, device id, class, subclass)
            xor rdi, rdi
            mov di,word[pci_header+PCI_CONF_SPACE.vendor_id]
            call bios_print_hexa  ;prints vendor id
            mov rsi, comma
            call video_print
            xor rdi, rdi
            mov di,word[pci_header+PCI_CONF_SPACE.device_id]
            call bios_print_hexa   ; prints device id
            mov rsi, comma
            call video_print
            xor rax, rax
            xor rdi, rdi
            mov al,byte[pci_header+PCI_CONF_SPACE.class]
            mov rdi, rax
            call bios_print_hexa  ;prints class
            mov rsi, comma
            call video_print
            xor rax, rax
            mov al,byte[pci_header+PCI_CONF_SPACE.subclass]
            mov rdi, rax
            call bios_print_hexa  ;prints subclass


            mov rsi, newline
            call video_print
            mov rsi, newline
            call video_print
.no_device_connected:

popaq

ret