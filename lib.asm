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

_start:
  xor rdi, rdi
  call exit
