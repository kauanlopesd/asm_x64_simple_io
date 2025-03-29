section .data

section .text
global exit
global string_length
global print_string
global print_char
global print_newline
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

_start:
  xor rdi, rdi
  call exit
