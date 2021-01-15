check_a20_gate:
    pusha     ; Save all general purpose registers on the stack
    mov ax,0x2402 
    int 0x15
    jc .error

    cmp al,0x0   ; if al is 0, then the a20 gate is disabled and we'll enable it
    je .enable_a20


.enable_a20: ; function to enable a20 gate using int 0x15
  mov si, a20_not_enabled_msg ; output message tells that a20 is not enabled yet
  call bios_print
  mov ax,0x2401
  int 0x15    ;enabling a20
  jc .error ;if carry flag is set to 1, then there is error 
  mov si, a20_enabled_msg  ;output message tells if a20 is enabled
  call bios_print
  jmp .return

.error: ; function that decides the type of a20 error and output corresponding messages 
    cmp ah,0x1  ;if ah is set to 1 then it's keyboard controller in secure mode or unavailable
    je .print_key_error
    cmp ah,0x86   ;if ah is set to 0x86 then the function is not supported
    je .print_F_error

    jmp .print_unkown_error  ;if neither options is true then it is an unkown error
    
.return:
    popa                                ; Restore all general purpose registers from the stack
    ret

.print_key_error: ;prints keyboard controller error
mov si, keyboard_controller_error_msg
call bios_print
jmp .return


.print_F_error: ;prints function not supported message
mov si, a20_function_not_supported_msg
call bios_print
jmp .return

.print_unkown_error:  ;prints unknown message
mov si, unknown_a20_error
call bios_print
jmp .return
