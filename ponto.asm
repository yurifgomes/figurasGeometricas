.text

	addi $s0, $zero, 0xff000000   #endereço inicial mmio
	addi $a0, $zero, 20	#x
	addi $a1, $zero, 20	#y
	addi $a2, $zero, 0xc0   #cor
	
	jal ponto
	li $v0, 10
	syscall
ponto:
	
	mul $t1,$a1, 320  #y * 320
	add $t1, $t1, $a0 # y * 320 + x
	add $t0, $s0, $t1
	sb $a2, 0($t0)
	
	jr $ra
	
