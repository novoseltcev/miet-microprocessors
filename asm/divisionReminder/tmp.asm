.globl: .globl __start

.data 
  divisible: .word 1024
  divider:   .word 1023

.text
__start:
  lw a1 divisible
  lw a2 divider
  call __division_reminder
  mv t0 a0
  xor a0 a0 a2
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
