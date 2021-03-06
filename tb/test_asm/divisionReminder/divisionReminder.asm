.globl: .globl __start

.text
__start:
  li a1 1024
  li a2 10
  call __division_reminder
  ecall
  
 __division_reminder:  # division_reminder(i32 a1, i32 a2) -> a0
  mv t0 zero  # sum = 0
  bnez a2 while
  li a0 -1
  ret
  while: # while sum <= a1
    add t0 t0 a2  # sum += a2
    bleu t0 a1 while
  
  sub t0 t0 a2
  sub a0 a1 t0
  ret
