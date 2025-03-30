section .data

section .text
global exit
global string_length
global print_string
global print_char
global print_newline
global print_int
global print_uint
global read_char
global read_word
global parse_uint
global parse_int
global string_equals
global string_copy
global _start

exit: ; (statusCode: rdi)
  mov rax, 60
  syscall

string_length: ; (bufferPtr: rdi)
  xor rax, rax
.loop:
  cmp byte[rdi + rax], 0
  je .end

  inc rax
  jmp .loop
.end:
  ret

print_string: ; (bufferPtr: rdi)
  push rdi
  call string_length

  mov rdx, rax
  mov rax, 1
  pop rsi
  mov rdi, 1 ; stdout

  syscall
  ret

print_char: ; (charCode: rdi)
  push rdi

  mov rdi, rsp
  call print_string
  pop rdi
  ret

print_newline:
  mov rdi, 0xA ; '\n'
  call print_char
  ret

print_uint: ; (unsignedNum: rdi)
  push r14
  mov r14, 10

  push 0
  mov rsi, rsp
  sub rsp, 24
  mov rax, rdi
.loop:
  xor rdx, rdx
  div r14
  or dl, 0x30

  cmp rsi, rsp
  jl .end

  mov byte[rsi], dl

  test rax, rax
  jz .end
  dec rsi
  jmp .loop
.end:
  mov rdi, rsi
  call print_string
  add rsp, 32
  pop r14
  ret

print_int: ; (signedNum: rdi)
  test rdi, rdi
  jns print_uint
  push rdi
  mov rdi, '-'
  call print_char
  pop rdi
  neg rdi
  jmp print_uint

read_char: ; () -> charCode: rax
  xor rax, rax
  xor rdi, rdi ; stdin
  push 0
  mov rsi, rsp
  mov rdx, 1
  syscall
  
  test rax, rax
  jnz .get_char
  pop rsi
  xor rax, rax
  ret
.get_char:
  mov rax, [rsi]
  pop rsi
  ret

read_word: ; (buffer: rdi, size: rsi) -> (buffer: rax, wordSize: rdx)
  push r14
  push r15
  xor r14, r14
  mov r15, rsi
  dec r15
.get_first_char:
  push rdi
  call read_char
  pop rdi
  cmp al, 0x20
  je .get_first_char
  cmp al, 0xA
  je .get_first_char
  cmp al, 0xD
  je .get_first_char
  cmp al, 0x9
  je .get_first_char
  test al, al
  jz .no_word
.write:
  mov byte[rdi + r14], al
  inc r14
.get_chars:
  push rdi 
  call read_char
  pop rdi
  cmp al, 0x20
  je .end
  cmp al, 0xA
  je .end
  cmp al, 0xD
  je .end
  cmp al, 0x9
  je .end
  test al, al
  jz .end
  
  cmp r14, r15
  je .no_word

  jmp .write
.no_word:
  xor rax, rax
  xor rdx, rdx
  pop r15
  pop r14
  ret
.end:
  mov byte[rdi + r14], 0
  mov rax, rdi
  mov rdx, r14
  pop r15
  pop r14 
  ret

parse_uint: ; (buffer: rdi) -> (unsignedNum: rax, length: rdx)
  mov r8, 10
  xor rax, rax
  xor rcx, rcx
.loop:
  movzx r9, byte[rdi + rcx]
  cmp r9b, 0x30
  jb .end
  cmp r9b, 0x49
  ja .end

  and r9d, 0xf
  xor rdx, rdx
  mul r8

  add rax, r9
  inc rcx
  jmp .loop
.end:
  mov rdx, rcx
  ret

parse_int: ; (buffer: rdi) -> (signedNum: rax, length: rdx)
  cmp byte[rdi], '-'
  je .signed
  jmp parse_uint
.signed:
  inc rdi
  call parse_uint
  neg rax
  inc rdx
  ret

string_equals: ; (buffer: rdi, otherBuffer: rsi) -> isEqual: rax
  xor rcx, rcx
.loop:
  movzx r8, byte[rsi + rcx]
  cmp byte[rdi + rcx], r8b
  jne .not_equal

  cmp byte[rdi + rcx], 0
  jz .equal
  inc rcx
  jmp .loop
.not_equal:
  xor rax, rax
  ret
.equal:
  mov rax, 1
  ret

string_copy: ; (buffer: rdi, copyBuffer: rsi, copyBufferSize: rdx)
  xor rcx, rcx
.loop:
  movzx r8, byte[rdi + rcx]
  cmp rcx, rdx
  je .no_space

  mov byte[rsi + rcx], r8b
  inc rcx
  cmp r8b, 0
  je .end
  jmp .loop
.no_space:
  xor rax, rax
  xor rdx, rdx
  ret
.end:
  mov rax, rsi
  mov rdx, rcx
  ret

_start:
  xor rdi, rdi
  call exit

