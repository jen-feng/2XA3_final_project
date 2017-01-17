%include "asm_io.inc"


SECTION .data
print: db "sorted suffixes:",10,0
err1: db "incorrect number of command line arguments",10,0
err2: db "incorrect length of input string(should not greater than 30)",10,0
err3: db "incorrect input string contains character other than 0,1,2",10,0
msg: db "Press enter to exit the program",10,0

SECTION .bss
X: resb 31
N: resd 1
k: resd 1
t: resb 1
n: resd 1
m: resd 1
y: resd 31

SECTION .text
   global asm_main
   
asm_main:
   enter 0,0
   pusha
   mov eax, dword [ebp+8]      ; argc
   cmp eax, dword 2            ; argc should be 2
   jne ERR1
   
   mov ebx, dword [ebp+12]     ; address of argv[]
   mov eax, dword [ebx+4]      ; argv[1]   
   mov ecx, eax                       ; c = address of the argv[1]
   
   xor edx, edx                       ; d = 0
   
   mov ecx, eax                   ; ecx = address of argv[1]
   
   check_char: 
      
      cmp edx, dword 30           ; compare the current counter to the max input string
	  jg ERR2
      cmp byte [ecx], 0           ; check if it is the end of string
       jz check_ok                 ; 
       mov bl, byte [ecx]          ; 1st byte of argv[1]
      try1: cmp bl, '0'           ; check if the char is equal to '0'
      jne try2                    ; if not then jmp to try2
      jmp byte_ok                 ; if equal then jmp to byte_ok
      try2: cmp bl, '1'           ; check if the char is equal to '1' 
      jne try3                    ; if not then jmp to try3
      jmp byte_ok                 ; if equal then jmp to byte_ok
      try3: cmp bl, '2'           ; check if the char is equal to '2'
      jne ERR3                    ; if not, the char is already compared to '0','1','2', so it will jmp to ERR3 to do its stuff
      byte_ok: 
       inc ecx                     ; incrementing by 1 to go to the next char of the string
	   inc edx                     ; counter for counting length of input string
       jmp check_char
   check_ok:
   mov dword [N], edx              ; N stores the length of the string
   
   mov ecx, eax                   ; ecx = address of argv[1]
  
   mov edx, X                  ; edx = address of X
   str_to_arr:
       mov bl, byte [eax]       ; bl = first byte of eax
       inc eax                  ; next byte in eax
       cmp bl, 0                ; compare if it is the end of string
       je done 
       mov [edx], bl            ; put the value of bl into the adress of edx
       mov ebx, 0                  ; empty ebx
       inc edx                   
       jmp str_to_arr
   done: 
       
   mov eax, X                    ; print the array_X
   call print_string
   call print_nl
   
   mov esi, 0
   mov edx, 0
   Create_arrayY:               ; function to create the indeces array_Y
   mov dword [y+edx], esi       ; putting value into array by index
   add esi, dword 1             ; 
   add edx, dword 4             ; increasing the index by incrementing by 4 (array_Y is dword)
   cmp esi, dword [N]
   jne Create_arrayY
 
   mov ebx, ecx                   ; ebx = address of arg[1]
       
   mov ecx, dword [N]
   mov eax, ecx              ; eax = ecx
   add eax, ecx                     
   add eax, ecx
   add eax, ecx             ; eax = 4 * N purpose for getting the number of array y by dword
   mov edi, eax             ; edi is i
   mov esi, dword 4         ; esi is j 
   
   mov ecx, y               ; ecx = address of y
   mov ebx, 0             
   Loop_i: 
      mov esi, dword 4      ; esi is j 
      cmp esi, edi          ; range (4 to i*4) using 4 because j is help as index of array y
       je sort_end
       Loop_j:            
          mov eax, ecx       ;eax has the addres of y
           add eax, esi       ;addres of y[j]
           sub eax, 4              ;eax = address of y[j-1]
           mov eax, dword [eax]    ;eax = y[j-1]
           mov edx, ecx            ;edx = the adrress of y
           add edx, esi            ;eax = address of y[j]
           mov edx, dword [edx]    ;edx = y[j]
           call sufcmp             
           cmp ebx, dword 0        ;ebx contains value either 1 or -1 from sufcmp
           jl next_j               ; if ebx < 0 jmp to next_j
           mov eax, ecx            ;eax has the addres of y
           add eax, esi            ;addres of y[j]
           sub eax, 4              ;eax = address of y[j-1]
           mov eax, dword [eax]    ;eax = y[j-1]
           mov edx, ecx
           add edx, esi
           mov edx, dword [edx]    ;edx = y[j]
           mov dword[t], eax       ;t=y[j-1]
           mov eax, ecx            ;eax = address of y            
           add eax, esi            
           sub eax, 4              ; eax=address of y[j-1]
           mov dword [eax], edx    ; y[j-1]=y[j]
           mov edx, ecx                          
           add edx, esi
           mov eax, dword[t]       ;eax = y[j-1]
           mov dword [edx], eax    ;y[j] = y[j-1]
           next_j:
           add esi, 4
           cmp esi, edi
           jne Loop_j
   sub edi, 4
   cmp edi, 0
   jne Loop_i

   sort_end:
   
   mov eax, print
   call print_string
   
   mov esi, 0       ;esi = i
   mov ebx, y       ; ebx = address of y
   mov ecx, dword [N]
   mov eax, ecx              ; eax = ecx
   add eax, ecx
   add eax, ecx
   add eax, ecx
   mov ecx, eax              ; ecx = N*4
   mov edx, X                ; edx = address of X
   mov edi, 0
                             ; this function print the sorted suffixes
   print_suffix:
      mov ebx, y             ; ebx = address of y
       mov edx, X             ; edx = address of X
       add ebx, esi           ; ebx = adresse of y[i]
       mov edi, dword [ebx]   ; edi=y[i] 
       add edx, edi           ; edx = address of X[y[i]]
       print_eC:
       mov al, byte [edx]     ; al = value of X[y[i]]
       call print_char        ; print char at X[y[i]]
       inc edx                ; edx = edx + 1, next char of the X
       inc edi                ; counter from y[i] to N
       cmp edi, dword [N]
      jne print_eC
       call print_nl
   add esi, 4
   cmp esi, ecx
   jne print_suffix
   
   call print_nl
   mov eax, msg               
   call print_string
   
   call read_char
   
   jmp asm_main_end
     
sufcmp:
   enter 0,0
   pusha
   
   mov edi, eax               ;edi is i   , edi = eax = y[j-1]
   mov esi, edx               ; esi is j , esi = edx = y[j]
   mov eax, dword [N]         ; eax = arraylen
   sub eax, edi               ;eax is n , eax = arraylen-i 
   mov edx, dword [N]          
   sub edx, esi                ; edx is m, edx = arraylen-j
 
   mov dword [k], edx          ; k = m
   cmp edx, eax                ; 
   jl next1                    ; if m < n , done 
   mov dword [k], eax          ; else k = n
   next1:
   
   push eax                    ; save value of eax(n)
   push edx                    ; save value of edx(m)
   mov ebx, 0             
   mov edx, 0
   mov eax, dword 0            ; eax is counter "o" in the python code given
   mov ecx, X                  ; ecx = address of X
   
   Loop_k:
   mov edx, ecx                ; edx = address of X
   add edx, esi                ; edx = adress of X[i]
   add edx, eax                ; edx = adress of X[i+o]
   mov bl, byte [edx]          ; bl = X[i+o]
   push esi                    ; save esi(j)
   mov esi, ecx                ; esi = address of X
   add esi, edi                ; esi = address of X[j]
   add esi, eax                ; esi = address of X[j+o]
   mov edx, 0
   mov dl, byte [esi]          ; dl = X[j+o]
   pop esi                     ; get back esi(j)
   cmp bl, dl                  ; cmp X[i+o] and X[j+o]
   jl return_n1                ; if bl < dl
   cmp bl, dl
   jg return1                  ; if bl > dl                   
   inc eax                     ; o = o + 1
   cmp eax, dword [k]          
   jne Loop_k                  ; if o != k
   jmp end_loop
   return_n1:
   pop edx
   pop eax
   popa
   leave
   mov ebx, 1                  ; return 1
   ret
   return1:
   pop edx
   pop eax
   popa
   leave
   mov ebx, -1                 ; return -1
   ret
   end_loop:
   
   pop edx
   pop eax
   cmp eax, edx
   jge next_1                   ; if n >= m, jmp to next_1
   popa                          
   leave
   mov ebx, -1                  ; return -1
   ret
   next_1:
   popa
   leave
   mov ebx, 1                   ; return 1
   ret
   
ERR1:
   mov eax, err1			    ; print message to wrong arg number
   call print_string
   jmp asm_main_end

ERR2:
   mov eax, err2                ; print message to wrong character in input string
   call print_string
   jmp asm_main_end

ERR3:
   mov eax, err3                ; wrong length of input string
   call print_string
   jmp asm_main_end 
 
asm_main_end:
   popa                         ; clean up everything
   leave
   ret                          ; terminate the program