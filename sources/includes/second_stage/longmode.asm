
%define DATA_SEG 0x0010        
 ; Data segment selector in GDT

%define CODE_SEG 0x0008       
 ; Code segment selector in GDT
%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000

switch_to_long_mode:

         ;Set the PAE and PGE bits (bit 5 and 7).
         mov eax,10100000b; Store eax into CR4 
         mov cr4,eax

         mov edi,PAGE_TABLE_EFFECTIVE_ADDRESS
         mov edx,edi; Point CR3 at the PML4.
         mov cr3,edx




 ;Read from the EFER (Extended Feature Enable Register) 
 ; MSR. (Model Specific Register). 0xC0000080 is the EFER  
 ; register identifier which need to be store in EAX.
 ; The value of the register is read into EDX:EAX

         mov ecx, 0xC0000080
         rdmsr
        
            ; We will modifying bit # 8 so we will not touch EDX
            ; We will only modify bit 8 in EAX and  write back EDX:EAX


         or eax, 0x00000100; Set the LME bit. (Long Mode Enabled BIT # 8)
         wrmsr 




         mov ebx,cr0; Read CR0 
         or ebx,0x80000001; Set Bit 0 and 31
         ; Bit 0 to set protected mode
         ; Bit 31 for enabling Paging
         mov cr0,ebx; Set CR0

      lgdt [GDT64.Pointer]
      jmp CODE_SEG:LongModeEntry
         
                   
    ret
