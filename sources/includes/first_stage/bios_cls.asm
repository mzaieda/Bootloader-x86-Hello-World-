bios_cls:
		;a routine to clear the screen after displaying the vedio mode.
		pusha ;push all register values to the stack.
	        mov ah,0x0   ; the function for vedio mode
 		 mov al,0x3   ; text mode for the vedio mode
		 int 0x10     ;INT 0x10
		 popa 	     ; pup all registers from the stack
		 ret
