%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x1018
%define MEM_MAGIC_NUMBER            0x0534D4150                
    memory_scanner:
            pusha                                       ; Save all general purpose registers on the stack

                      ; Save all general purpose registers on the stack    
                              mov ax,MEM_REGIONS_SEGMENT    ; Set ES to 0x2000     
                              mov es,ax
                              xor ebx,ebx                                 ; Set EBX to zero            
                              mov [es:PTR_MEM_REGIONS_COUNT],word 0x0     ; Use the word at address 0x2000:0x0000 as a counter to count memory regions            
                              mov di, PTR_MEM_REGIONS_TABLE   ; Set DI to point to address 0x18 to be 24-bytes aligned to store the memory regions table               
                              .memory_scanner_loop:                    ; Loop over available memory regions                
                                    mov edx,MEM_MAGIC_NUMBER         ; Set DX to magic number 0x0534D4150 = 'SMAP'                 
                                    mov word [es:di+20], 0x1                ; This is needed by function 0xe820 int 0x15                
                                    mov eax, 0xE820                         ; Set the memory scanner function number                
                                    mov ecx,0x18                            ; Set size of the memory buffer to store region data                
                                    int 0x15                                                
                                    jc .memory_scan_failed                  ; If carry flag thens something wrong happened so we need to exit with error message                
                                    cmp eax,MEM_MAGIC_NUMBER          ; If eax is equal to the magic  number then everything is okay                
                                    jnz .memory_scan_failed                 ; Else something wrong happened so we need to exit with error message                
                                    add di,0x18                             ; Advance di 24 bytes to point to the next entry in the memory region table                
                                    inc word [es:PTR_MEM_REGIONS_COUNT] ; Increment the memory regions counter                
                                    cmp ebx,0x0                             ; If ebx is 0x0 then no more regions and we need to exit the loop                
                                    jne .memory_scanner_loop                ; Else loop to fetch next region                
                                    jmp .finish_memory_scan                 ; If we are here then everything went well so we need to skip the error section            
                                    .memory_scan_failed: 
                                        mov si, memory_scan_failed_msg
                                        call bios_print
                                        jmp hang
                                    .finish_memory_scan:            
                                    popa                                        ; Restore all general purpose registers from the stack            
                                    ret
            popa                                        ; Restore all general purpose registers from the stack
            ret

    print_memory_regions:
            pusha
            mov ax,MEM_REGIONS_SEGMENT                  ; Set ES to 0x0000
            mov es,ax       
            xor edi,edi
            mov di,word [es:PTR_MEM_REGIONS_COUNT]
            call bios_print_hexa
            mov si,newline
            call bios_print
            mov ecx,[es:PTR_MEM_REGIONS_COUNT]
            mov si,0x1018 
            .print_memory_regions_loop:
                mov edi,dword [es:si+4]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si]
                call bios_print_hexa
                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+12]
                call bios_print_hexa_with_prefix
                mov edi,dword [es:si+8]
                call bios_print_hexa

                push si
                mov si,double_space
                call bios_print
                pop si

                mov edi,dword [es:si+16]
                call bios_print_hexa_with_prefix


                push si
                mov si,newline
                call bios_print
                pop si
                add si,0x18

                dec ecx
                cmp ecx,0x0
                jne .print_memory_regions_loop
            popa
            ret
