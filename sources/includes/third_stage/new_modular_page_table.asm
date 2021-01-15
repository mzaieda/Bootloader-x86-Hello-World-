%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x10000
%define PTR_MEM_REGIONS_COUNT       0x21000
%define PTR_MEM_REGIONS_TABLE       0x21018

D_space: resb 100
D_space_pos: resb 8


p_address dq 0 ;The last physcial page mapped
v_address dq 0 ;The last virtual address

pml4_pointer dq 0x100000
pdp_pointer dq 0 ;The address of the current pdp address
pd_pointer dq 0  ;The address of the current pd address
pte_pointer dq 0 ;The address of the current pte address

pml4_index dq 0 ;This is the index of the entry in pml4
pdp_index dq 0 ;This is the index of the entry in pdp
pd_index dq 0  ;This is the index of the entry in pd
pte_index dq 0   ;This is the index of the entry in pte

last_page dq 0x100000 ;This is the last page in the page table

max_size dq 0  ;Maximum size available in the physical memory

no_regions dq 0  ;This is the number of regions



total_memory_mapped dq 0 
region_type dq 0
struc  memscan_regions  ;This struct is made to read the details of the memory regions already scanned
    .base_address resq 1
    .offset resq 1
    .type resd 1
endstruc

break_virtual_address:
;This function break down the virtual address into 4 parts: pml4_index(9 bits), pdp_index(9 bits), pd_index(9 bits), pte_index(9 bits)
    mov r8,qword[v_address]
    shr r8, 39
    and r8, 111111111b
    mov qword[pml4_index], r8

    mov r8,qword[v_address]
    shr r8, 30
    and r8, 111111111b
    mov qword[pdp_index], r8 

    mov r8,qword[v_address]
    shr r8, 21
    and r8, 111111111b
    mov qword[pd_index], r8
    

    mov r8,qword[v_address]
    shr r8, 12
    and r8, 111111111b
    mov qword[pte_index], r8
ret 


create_a_page:
;This function initializes a new page with all zeros and increases the last_page counter with 4096 
pushaq
    add qword[last_page], 4096

    mov rax, qword[last_page]
    mov rdi, rax
    mov ecx,0x1000; set rep counter to 4096
    xor eax,eax; Zero out eax
    cld; Clear direction flag
    rep stosb     ; Store EAX (4 bytes) at address ES:EDI
                    ; rep will repeat for 4096 and advance EDI by 4 each time
                    ; 4 * 4096 = 4 * 4 KB = 16 KB = 4 memory pages
popaq
ret

map_physical_to_virtual:
;This maps a physical address to a virtual address using the page table
pushaq
    call break_virtual_address

    mov rax, qword[pml4_index]
    shl rax, 3
    mov r10, qword[pml4_pointer]
    shr r10,12 ;makes sure the page is 4k aligned
    shl r10,12
    add rax, r10
    mov r15, rax

    cmp qword[rax], 0
    jne .dont_create_pdp_page
    call create_a_page
    mov r9,qword[last_page]
    mov qword[rax], r9
    or qword[rax], 3
    .dont_create_pdp_page:
    mov r8,qword[rax]
    mov qword[pdp_pointer], r8 
   


    mov rax, qword[pdp_index]
    shl rax, 3
    mov r10, qword[pdp_pointer]
    shr r10,12   ;makes sure the page is 4k aligned
    shl r10,12
    add rax, r10

    cmp qword[rax], 0
    jne .dont_create_pd_page
    call create_a_page
    mov r9,qword[last_page]
    mov qword[rax], r9
     or qword[rax], 3
    .dont_create_pd_page:
    mov r8,qword[rax]
    mov qword[pd_pointer], r8 


    
    
    mov rax, qword[pd_index]
    shl rax, 3
    mov r10, qword[pd_pointer]
    shr r10,12 ;makes sure the page is 4k aligned
    shl r10,12
    add rax, r10

    cmp qword[rax], 0
    jne .dont_create_pte_page
    call create_a_page
    mov r9,qword[last_page]
    mov qword[rax], r9
    or qword[rax], 3
    .dont_create_pte_page:
    mov r8,qword[rax]
    mov qword[pte_pointer], r8 
    

    mov rax, qword[pte_index]
    shl rax, 3
    mov r10, qword[pte_pointer]
    shr r10,12    ;makes sure the page is 4k aligned
    shl r10,12
    add rax, r10

    cmp qword[rax], 0
    jne .dont_create_physical_page
    mov r9, qword[p_address]
    or r9,3
    mov qword[rax], r9
    .dont_create_physical_page:
    add qword[v_address], 4096 
    add qword[total_memory_mapped], 4096
popaq
ret

check_max_size: 
;This function calculates the size of the maximum memory that can be accessed in the physical memeory
    mov rax, qword[PTR_MEM_REGIONS_COUNT]

    mov rbx, 0x18
    mul rbx
    add rax, PTR_MEM_REGIONS_COUNT

    mov r15, qword[rax + memscan_regions.base_address]
    add r15, qword[rax + memscan_regions.offset]

    mov qword[max_size], r15
ret 

check_region:
;This function returns 1 if the address is less than 0x100000 or if it is in a region of type 1
    mov r8, 0x100000
    cmp qword[p_address], r8
    jle .region_1
    
    mov r14, qword[PTR_MEM_REGIONS_COUNT] 
    mov r13, qword[p_address]
    mov rax, 0x21018
    .loop:
        mov r8, qword[rax+ memscan_regions.base_address];base address
        cmp r13, r8
        jl .out_of_region
        add r8, qword[rax+ memscan_regions.offset];base address + offset
        cmp r13, r8
        jge .out_of_region ;was jg
        cmp dword[rax + memscan_regions.type], 1
        jne .not_region_1
        .region_1:
        mov qword[region_type],1
        jmp .after_loop
        .not_region_1:
        mov qword[region_type],0
        jmp .after_loop
        .out_of_region: 
        add rax, 0x18
        dec r14
        cmp r14,0
        jne .loop
    .after_loop:

ret

update_cr3:
;This function updates cr3 register so that the CPU can access the new updated page table
    cmp qword[total_memory_mapped], 0x200000
    jle .after_cr3
    mov rdi, qword[total_memory_mapped]
    mov r10, 0x100000
    mov cr3, r10
    .after_cr3:
ret

main_mapping_function:
;This is the main function 
mov qword[last_page], 0x100000
sub qword[last_page], 0x1000
call create_a_page
mov qword[pml4_pointer], 0x100000 ;The address of the pml 4 page
    call check_max_size
    .loop_main:
        mov r9, qword[max_size]
        cmp qword[p_address], r9;if the physical page is larger than the maximum size allowed, terminate the program
        jge .terminate
        call check_region
    
        cmp qword[region_type], 1
        jne .dont_map
        call map_physical_to_virtual
        call update_cr3
        .dont_map:
        add qword[p_address], 4096
        
        jmp .loop_main
    .terminate:
    mov qword[0x100000008], 1 ;This is to make sure that the memory locations beyond the 1 mega are accessible
    mov r8, qword[0x100000008]
    mov rdi, r8
    call bios_print_hexa
    mov rsi, newline
    call video_print
   mov rdi, qword[total_memory_mapped]
   call bios_print_hexa
mov rsi, newline
call video_print
 
ret

