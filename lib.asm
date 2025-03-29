section .data

section .text
global _start

exit: ; (statusCode: rdi)
  mov rax, 60
  syscall

_start:
  xor rdi, rdi
  call exit
