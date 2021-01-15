GDT64:
 .Null: equ $ - GDT64; The null descriptor
dw 0 ; Limit (low)
dw 0 ; Base (low)
db 0 ; Base (middle)
db 0 ; Access byte.
db 0 ; Flags - Limit(high).
db 0 ;base(high)

 .Code: equ $ - GDT64; The Kernel code descriptor.
dw 0; Limit (low).
dw 0; Base (low).
db 0; Base (middle)
db 10011000b; Access byte: Pr,ring0,Ex .
db 00100000b; Flags: L - Limit(high).
db 0; Base (high).

.Data: equ $ - GDT64; The Kernel data descriptor.
dw 0; Limit (low).
dw 0; Base (low).
db 0; Base (middle)
db 10010011b; Access byte: Pr,ring0,RW,Ac.
db 00000000b; Flags - Limit(high).
db 0 ;base(high)

ALIGN 4 
dw 0    ; Padding to make the "address of the GDT" field aligned on a 4-byte boundary
.Pointer:
dw $ - GDT64 - 1; 16-bit Size (Limit) of GDT.
dd GDT64