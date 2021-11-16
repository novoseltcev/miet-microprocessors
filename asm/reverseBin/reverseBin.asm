li ra 1		# res
li a0 1022	# input

mv t0 a0	# val 	  = input
mv t1 zero	# counter = 0

while:	# while (counter != 10)
	addi t6 zero 10
	bge t1 t6 end
    
	check_boundary:
    	beqz t0 pre_end	# if (val == 0)
        
    	addi t6 zero 1
        beq  t0 t6 add_1	# if (val == 1)
        
        addi t6 zero 2
        beq  t0 t6 add_0	# if (val == 2)
    
    get_mod:
    	srli t2 t0 1
        slli t2 t2 1 	# without_last = (val / 2) * 2
        sub t3 t0 t2	# mod = val - without_last     
       
	add_to_res:
    	slli ra ra 1	# res *= 2
    	add ra ra t3	# res += mod
    
    iter:
    	addi t1 t1 1	# counter++
        srli t0 t0 1	# val /= 2
    
    j while

add_0:
	mv t3 zero
	j add_to_res
    
add_1:
	mv t3 t6
	j add_to_res

pre_end: # while (counter != 10)
	addi t6 zero 10
	beq t1 t6 end	
	slli ra ra 1	# res *= 2
    addi t1 t1 1	# counter++
    j pre_end
    
end:
	addi ra ra -1024    
