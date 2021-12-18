.globl __start

.text
_start:
	li a1, 1000   # head_addr
    call __test_save_load
    stop: ecall
  
__test_save_load: # (&i32: head_addr)
    mv t5 a1
    
    li a1, 0x12345678
    li a2, 0x12345678
    mv a3, t5
    call __test_word
    
    li a1, 0x1111FFFF
    li a2, 0xFFFFFFFF # -1
    addi a3, t5, 4
    call __test_half_word
    
    li a1, 0x1111FFFF
    li a2, 0x0000FFFF # 65535
    addi a3, t5, 8
    call __test_unsigned_half_word
    
    li a1, 0x111111FF 
    li a2, 0xFFFFFFFF # -1
    addi a3, t5, 12
    call __test_byte
    
    li a1, 0x111111FF 
    li a2, 0x000000FF  # 255
    addi a3, t5, 16
    call __test_unsigned_byte
    
    li a0, 0
    jal stop
    
    error:
    	li a0, -1 
    	jal stop
        
__test_word: #(a1: input, a2: expected, a3: addr) -> a0
	sw a1, 0(a3) # TEST WORD by 00
    lw s0, 0(a3)
    bne s0, a2, error
    ret

__test_half_word: #(a1: input, a2: expected, a3: addr) -> a0
	sh a1, 0(a3) # TEST HALF-WORD by 00
    lh s0, 0(a3)
    bne s0, a2, error
   
    sh a1, 2(a3) # TEST HALF-WORD by 10
    lh s0, 2(a3)
    bne s0, a2, error
    ret

__test_byte: #(a1: input, a2: expected, a3: addr) -> a0
    sb a1, 0(a3)  # TEST BYTE by 00
    lb s0, 0(a3)
    bne s0, a2, error
    
    sb a1, 1(a3) # TEST BYTE by 01
    lb s0, 1(a3)
    bne s0, a2, error
    
    sb a1, 2(a3) # TEST BYTE by 10
    lb s0, 2(a3)
    bne s0, a2, error
    
    sb a1, 3(a3) # TEST BYTE by 11
    lb s0, 3(a3)
    bne s0, a2, error
    ret

__test_unsigned_half_word: #(a1: input, a2: expected, a3: addr) -> a0
	sh a1, 0(a3) # TEST U-HALF-WORD by 00
    lhu s0, 0(a3)
    bne s0, a2, error
   
    sh a1, 2(a3) # TEST U-HALF-WORD by 10
    lhu s0, 2(a3)
    bne s0, a2, error
    ret

__test_unsigned_byte: #(a1: input, a2: expected, a3: addr) -> a0
	sb a1, 0(a3)  # TEST U-BYTE by 00
    lbu s0, 0(a3)
    bne s0, a2, error
    
    sb a1, 1(a3) # TEST U-BYTE by 01
    lbu s0, 1(a3)
    bne s0, a2, error
    
    sb a1, 2(a3) # TEST U-BYTE by 10
    lbu s0, 2(a3)
    bne s0, a2, error
    
    sb a1, 3(a3) # TEST U-BYTE by 11
    lbu s0, 3(a3)
    bne s0, a2, error
    ret
