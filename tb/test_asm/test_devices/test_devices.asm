.globl __start
.text
_start:
	call __scanf
    mv a1, a0
    call __printf
    slli a1, a1 2
    call __sum_ub_rom_addr
    mv a1, a0
    call __printf
    ecall
    
__sum_ub_rom_addr:  # (&i32: addr) - > i32
    lw t0, 0(a1)   # length = Mem[a1]
    mv a0, zero	   # sum = 0
    beqz t0, end   # if (length == 0): goto end
	mv t1, zero    # counter = 0
    addi t2, a1, 4 # next_addr = addr + 4
    loop:
    	addi t1, t1, 1 # counter++
        lbu t3, 0(t2)  # ub = Mem[next_addr]
        addi t2 t2 1   # next_addr ++
        add a0, a0, t3   # sum += ub
        bne t1, t0, loop  # while (counter != length)
        
    end: ret

__scanf:
	li t0, 0x80002000
	lhu a0, 0(t0)
    ret
    
__printf:
	li t0, 0x80000009
	sh a1, 0(t0)
	ret
