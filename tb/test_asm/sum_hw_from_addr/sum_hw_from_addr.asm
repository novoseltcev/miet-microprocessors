.globl __start
.text
_start:
	li a1, 32
    slli a1, a1, 2
    call __sum_hw_from_addr
    ecall
    
__sum_hw_from_addr:  # (&i32: addr) - > i32
    lw t0, 0(a1)  # length = Mem[a1]
    mv a0, zero	# sum = 0
    beqz t0, end  # if (length == 0): goto end
	mv t1, zero  # counter = 0
    addi t2, a1, 4 # next_addr = addr + 4
    loop:
    	addi t1, t1, 1 # counter++
        lh t3, 0(t2)      # h_w = Mem[next_addr]
        addi t2 t2 2   # next_addr += 2
        add a0 a0 t3   # sum += h_w
        bne t1, t0, loop  # while (counter != length)
          
    end: ret
