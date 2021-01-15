bios_print: ; routine to print a string to the screen in 16 mood.
pusha	; Save all registers on the stack
.print_loop:
	xor ax,ax ;ax = zero
	lodsb	 ; atomic instruction to Load byte stored in si to al
		 ; and then increment si
	or al,al ; to raise the zero flag in case al contains zero. 
	jz .done ; jump to done in case zero flag is set. 
	mov ah,0x0E	 ;print character function
	int 0x10  ;interupt for printing. 
	jmp .print_loop; Loop to get next character
.done:	; exit 
	popa; Restore all registers from the stack
	ret
