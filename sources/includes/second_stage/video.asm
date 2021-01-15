%define VIDEO_BUFFER_SEGMENT                    0xB000
%define VIDEO_BUFFER_OFFSET                     0x8000
%define VIDEO_BUFFER_EFFECTIVE_ADDRESS          0xB8000
%define VIDEO_SIZE      0X0FA0    ; 25*80*2
video_cls_16:
      pusha                                   ; Save all general purpose registers on the stack

      mov ebx, 0xB8000                           
      .clear_screen_loop:
            mov word[ebx],0x0000 ;change this to 0x1000 if you want the background to be all in blue.
            add ebx, 2
            cmp ebx, 0xB8FA0
      jl .clear_screen_loop

      popa                                ; Restore all general purpose registers from the stack
ret

