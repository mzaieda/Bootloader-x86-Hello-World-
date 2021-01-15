get_key_stroke:		
       pusha 			;Save all registers on the stack
       mov ah,0x0;  keyboard input function
       int 0x16; interrupt 0x16
      popa; Restore all registers from the stack
	ret
