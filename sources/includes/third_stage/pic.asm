%define MASTER_PIC_COMMAND_PORT     0x20
%define SLAVE_PIC_COMMAND_PORT      0xA0
%define MASTER_PIC_DATA_PORT        0x21
%define SLAVE_PIC_DATA_PORT         0xA1


    configure_pic:
        pushaq

                ;masking irqs
                mov al,11111111b  
                out MASTER_PIC_DATA_PORT,al
                out SLAVE_PIC_DATA_PORT,al

                ;ICW1 ;Initialization
                mov al,00010001b  ;set bit 0 and bit 4
                out MASTER_PIC_COMMAND_PORT,al
                out SLAVE_PIC_COMMAND_PORT,al

                ;ICW2
                mov al,0x20 ; master starts with interrupt 32 (irq0)
                out MASTER_PIC_DATA_PORT,al
                mov al,0x28 ;slave starts with interrupt 40 (irq8)
                out SLAVE_PIC_DATA_PORT,al

                ;ICW3 ;communicating master and slave
                mov al,00000100b 
                out MASTER_PIC_DATA_PORT,al
                mov al,00000010b 
                out SLAVE_PIC_DATA_PORT,al

                ; ICW4  ; set 80x86 mode
                mov al,00000001b 
                out MASTER_PIC_DATA_PORT,al
                out SLAVE_PIC_DATA_PORT,al

                ;Unmasking irqs
                mov al,0x0 
                out MASTER_PIC_DATA_PORT,al
                out SLAVE_PIC_DATA_PORT,al

        popaq
        ret


    set_irq_mask: ; masking irq with number rdi
        pushaq                             
        mov rdx,MASTER_PIC_DATA_PORT        
        cmp rdi,15                         
        jg .out                             
        cmp rdi,8                         
        jl .master ; if irq number between 0 and 7 then it is in master, else, if between 8 and 15 then it is in slave
        sub rdi,8                           
        mov rdx,SLAVE_PIC_DATA_PORT        
        .master:                           
            in eax,dx                     
            mov rcx,rdi                     
            mov rdi,0x1                     
            shl rdi,cl                      
            or rax,rdi                     
            out dx,eax            ; write to data port          
        .out:    
        popaq
        ret

        clear_irq_mask: ;clearing irq with number rdi
        pushaq                             
        mov rdx,MASTER_PIC_DATA_PORT        
        cmp rdi,15                         
        jg .out                             
        cmp rdi,8                         
        jl .master
        sub rdi,8                           
        mov rdx,SLAVE_PIC_DATA_PORT        
        .master:                           
            in eax,dx                     
            mov rcx,rdi                     
            mov rdi,0x1                     
            shl rdi,cl       
            not rdi               
            and rax,rdi                     
            out dx,eax                ;write to data port      
        .out:    
        popaq
        ret