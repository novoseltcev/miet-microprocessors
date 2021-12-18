.globl __start

.text
__start:
  li a0 1000
  call reverse_bin

reverse_bin: #reverse_bin(a0: int32) -> int32
    li ra 1		# res
    mv t0 a0	# val 	  = input
    mv t1 zero	# counter = 0

    while:	# while (counter != 10)
        li t6 10
        bge t1 t6 end

        check_boundary:
            beqz t0 pre_end	# if (val == 0)

            li t6 2
            beq  t0 t6 add_0	# if (val == 2)

            li t6 1
            beq  t0 t6 add_1	# if (val == 1)



        get_mod:
            srl t2 t0 t6
            sll t2 t2 t6 	# without_last = (val / 2) * 2
            sub t3 t0 t2	# mod = val - without_last     

        add_to_res:
            sll ra ra t6	# res *= 2
            add ra ra t3	# res += mod

        iter:
            add t1 t1 t6	# counter++
            srl t0 t0 t6	# val /= 2

        j while

    add_0:
        mv t3 zero
        j add_to_res

    add_1:
        mv t3 t6
        j add_to_res

    pre_end: # while (counter != 10)
        li t6 10
        beq t1 t6 end	
        li t6 1
        sll ra ra t6	# res *= 2
        add t1 t1 t6	# counter++
        j pre_end

    end:
        li t5 1024
        sub ra ra t5    
