[ORG 0x10000]

[BITS 64]


Kernel:

mov rsi,hello_world_str
call video_print ;printing a welcoming message

nop 
nop 
nop
nop
call main_mapping_function  ;mapping the whole memory then printing the total size of memory
bus_loop:;checking alll devices on the bus and printing the vendor id, device id, class and subclass
    device_loop:
        function_loop:
            call get_pci_device
            inc byte [function]
            cmp byte [function],8
        jne device_loop
        inc byte [device]
        mov byte [function],0x0
        cmp byte [device],32
        jne device_loop
    inc byte [bus]
    mov byte [device],0x0
    cmp byte [bus],255
    jne bus_loop
channel_loop:
    mov qword [ata_master_var],0x0
    master_slave_loop:
        mov rdi,[ata_channel_var]
        mov rsi,[ata_master_var]
      call ata_identify_disk
        inc qword [ata_master_var]
        cmp qword [ata_master_var],0x2
        jl master_slave_loop

    inc qword [ata_channel_var]
    inc qword [ata_channel_var]
    cmp qword [ata_channel_var],0x4
    jl channel_loop
    
;initializing the idt
call init_idt
call setup_idt

;reading the database from disk to memory
mov rdi,2
mov rsi,0
call read_disk_sectors
    

kernel_halt: 
    hlt
    jmp kernel_halt


;*******************************************************************************************************************
      %include "sources/includes/third_stage/pushaq.asm"
      %include "sources/includes/third_stage/pic.asm"
      %include "sources/includes/third_stage/idt.asm"
      %include "sources/includes/third_stage/pci.asm"
      %include "sources/includes/third_stage/video.asm"
      %include "sources/includes/third_stage/pit.asm"
      %include "sources/includes/third_stage/ata.asm"
      %include "sources/includes/third_stage/new_modular_page_table.asm"


;*******************************************************************************************************************


colon db ':',0
comma db ',',0
newline db 13,0

end_of_string  db 13        ; The end of the string indicator
start_location   dq  0x0  ; A default start position (Line # 8)

    hello_world_str db 'Hello all here',13,0
greeting_msg      db "___  ___      _____ _____          ___  _   _ _____ ", 13, 10
                  db "|  \/  |     |  _  /  ___|  ____  / _ \| | | /  __ \", 13, 10
                  db "| .  . |_   _| | | \ `--.  / __ \/ /_\ \ | | | /  \/", 13, 10
                  db "| |\/| | | | | | | |`--. \/ / _` |  _  | | | | |    ", 13, 10
                  db "| |  | | |_| \ \_/ /\__/ / | (_| | | | | |_| | \__/\", 13, 10
                  db "\_|  |_/\__, |\___/\____/ \ \__,_\_| |_/\___/ \____/", 13, 10
                  db "         __/ |             \____/                   ", 13, 10
                  db "        |___/                                       ", 13, 10
                  db " _____               _   _                          ", 13, 10
                  db "|  __ \             | | (_)                         ", 13, 10
                  db "| |  \/_ __ ___  ___| |_ _ _ __   __ _ ___          ", 13, 10
                  db "| | __| '__/ _ \/ _ \ __| | '_ \ / _` / __|         ", 13, 10
                  db "| |_\ \ | |  __/  __/ |_| | | | | (_| \__ \         ", 13, 10
                  db " \____/_|  \___|\___|\__|_|_| |_|\__, |___/         ", 13, 10
                  db "                                  __/ |             ", 13, 10
                  db "                                 |___/              ", 13, 10
                  db " _____  _____ _____  _____       _____  _____  __   ", 13, 10
                  db "/  __ \/  ___/  __ \|  ___|     / __  \|____ |/  |  ", 13, 10
                  db "| /  \/\ `--.| /  \/| |__ ______`' / /'    / /`| |  ", 13, 10
                  db "| |     `--. \ |    |  __|______| / /      \ \ | |  ", 13, 10
                  db "| \__/\/\__/ / \__/\| |___      ./ /___.___/ /_| |_ ", 13, 10
                  db " \____/\____/ \____/\____/      \_____/\____/ \___/ ", 13, 10
                  db "Second Stage Boot Loader is ready, press any key to resume",13,10,0  
    ata_channel_var dq 0
    ata_master_var dq 0

    bus db 0
    device db 0
    function db 0
    offset db 0
    hexa_digits       db "0123456789ABCDEF"         ; An array for displaying hexa decimal numbers
    ALIGN 4


times 65024-($-$$) db 0