%define PIT_DATA0       0x40
%define PIT_DATA1       0x41
%define PIT_DATA2       0x42
%define PIT_COMMAND     0x43

pit_counter dq    0x0              
pit_temp_counter dq 0x0
handle_pit:
      pushaq
              
            
            cmp qword[pit_temp_counter], 1000
            jle .after
            mov rdi,[pit_counter]
            call bios_print_hexa  
            mov rsi,newline
            call video_print  
            mov qword[pit_temp_counter] , 0     
            .after:
            inc qword [pit_counter]   
            inc qword[pit_temp_counter]   
           
      popaq
      ret



configure_pit:
    pushaq
      mov rdi,32 ; PIT is connected to IRQ0 (interrupt 32)
      mov rsi, handle_pit ; The handle_pit (pit handler) will be invoked when PIT fires
      call register_idt_handler ; register the pit handler to be invoked through IRQ32
      mov al,00110110b ; Set PIT Command Register 00: Channel 0, 11: lo,hi bytes, 011: Mode 3, 0: Bin
      out PIT_COMMAND,al ; Write command port
      xor rdx,rdx ; Zero RDX for division
      mov rcx,1000 ;the value of the counter
      mov rax,1193180 ; 1.193180 MHz
      div rcx ; Calculate divider -> 11931280/50
      out PIT_DATA0,al ; Write low byte to channel 0 data port
      mov al,ah ; Copy high byte to AL
      out PIT_DATA0,al ; Write high byte to channel 0 data port
    popaq
    ret