%define Video_Ram_start 0x0B8000 

bios_print_hexa:  ; prints a 16-bit value stored in di in hexa (4 digits)
    pushaq
    mov rbx,0x0B8000          ; set bx to the start of the video RAM
    add bx,[start_location]
    mov rcx,0x10           ;set counter for 4 loops
    .loop:                  ; Loop on 4 digits
    cmp rbx, 0xB8FA0
    jl .not_scroll
    call scroll_loop
      mov rbx, 0xB8F00                           
    mov qword[start_location],0xF00  
    .not_scroll:
            mov rsi,rdi                          
            shr rsi,0x3C                          ; Shift si 60 bits right 
            mov al,[hexa_digits+rsi]              ; get the right hexadcimal digit from the array           
            mov byte [rbx],al                     ; Else Store the charcater into current video location
            inc rbx                               ; Increment current location
            mov byte [rbx],1Fh                    ; Blue Backgroun, Yellow font 
            inc rbx                               ; Increment current video location

            shl rdi,0x4                          ; Shift bx 4 bits left so the next digits is in the right place
            dec rcx                              ; decrement counter
            cmp rcx,0x0                          ; compare counter with zero.
            jg .loop                             ; loop if we didn't finish yet
    add [start_location],word 0x20
    popaq
    ret


video_print:  ;prints a string that its address is in rsi
    pushaq
    mov rbx,0x0B8000          ; set BX to the start of the video RAM
    ;mov es,bx               ; Set ES to the start of teh video RAM
    add bx,[start_location] ; Store the start location for printing in BX
    xor rcx,rcx
video_print_loop:           ; Loop for a character by charcater 
 cmp rbx, 0xB8FA0
    jl .not_scroll
    call scroll_loop
    mov rbx, 0xB8F00                           
    mov qword[start_location],0xF00  
    .not_scroll:

    lodsb                   ; Load character pointer to by SI into al
    cmp al,13               ; Check  new line character to stop printing
    je out_video_print_loop ; If so get out
    cmp al,0                ; Check  new line character to stop printing
    je out_video_print_loop1 ; If so get out
    ;This step is to make sure that that the screen is scrollable

    mov byte [rbx],al     ; Else Store the charcater into current video location
    inc rbx                ; Increment current video location
    mov byte [rbx],1Fh    ; Store Blue Backgroun, Yellow font color
    inc rbx                ; Increment current video location
    inc rcx
    inc rcx  ;increment 2 times because each location is 2 bytes
    jmp video_print_loop    ; Loop to print next character



clear_line:  ; clears the last line 
    pushaq
        mov rbx, 0xB8F00                           
        .clear_line_loop:
            mov qword[rbx],0
            add rbx, 8
            cmp rbx, 0xB8FA0
            jl .clear_line_loop
    popaq
ret

scroll_loop: ; a routine that scrolls the screen up 
pushaq
    mov r14, Video_Ram_start
    mov r15, r14
    add r14, 0xA0 ; go to the second line 
    .loop:
    ;copying every line onle line above
    mov ax, word[r14]
    mov word[r15],ax
    add r14, 2
    add r15, 2
    cmp r14, 0xB8FA0
    jle .loop
    call clear_line ;clearing last line
popaq
ret

out_video_print_loop: ;modifies the start location 
    cmp rbx, 0xB8F00
    jle .after_scroll ;if the screen is still not full (last line is still empty) 
    call scroll_loop
    mov rbx, 0xB8F00                           
    mov qword[start_location],0xF00
    jmp finish_video_print_loop
    .after_scroll: ;advnces the start location 
    xor rax,rax
    mov ax,[start_location] ; Store the start location for printing in AX
    mov r8,160
    xor rdx,rdx
    add ax,0xA0             ; Add a line to the value of start location (80 x 2 bytes)
    div r8
    xor rdx,rdx
    mul r8
    mov [start_location],ax
    jmp finish_video_print_loop
out_video_print_loop1:
    mov ax,[start_location] ; Store the start location for printing in AX
    add ax,cx             ; Add a line to the value of start location (80 x 2 bytes)
    mov [start_location],ax
finish_video_print_loop:
    popaq
ret
