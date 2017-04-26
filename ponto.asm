.text

	addi $s0, $zero, 0xff000000   #endereço inicial mmio
	addi $a0, $zero, 20	#x
	addi $a1, $zero, 20	#y
	addi $a2, $zero, 0xc0   #cor
	
	jal ponto
	
	addi $t8, $zero, 40
	addi $t9, $zero, 40
	jal reta
	li $v0, 10
	syscall
# Função reta recebe:
# $s0 endereço de memória do bitmap
# $a0 coordenada x do primeiro ponto
# $a1 coordenada y do primeiro ponto
# $a2 cor da reta
# $t8 coordenada x do segundo ponto
# $t9 coordenada y do segundo ponto
# TODO Salvar os valores anteriores dos registradores na pilha?
reta:
	beq $a0, $t8, return # se delta x = 0 , faça apenas uma coluna vertical
	sub $t0, $a0, $t8 # t0 = Delta x
	sub $t1, $a1, $t9 # t1 = Delta y
	mtc1 $t0,$f0 # f0 será o valor de delta x
	mtc1 $t1,$f1 # f1 será o valor de delta y
	mtc1 $a1,$f3 # f3 será o valor de b
	div.s $f2, $f1,$f0 # f2 = inclinação na reta
	and $t2, $zero, $zero #t2 = 0, t2 é o contador 
	jal loop_reta
loop_reta:
	beq $t2,$t8,return
	mtc1 $t2, $f5 # f5 vai ser auxiliar para multiplica a * x
	mul.s $f4, $f2, $f5 # f4 = a*x
	add.s $f6, $f4, $f3 # f6 = a*x + b
	round.w.s $f7,$f6 # arredonde o valor
	mfc1 $a1,$f7 # a1 é o Y = ax + b
	move $a0,$t2 # a0 é x
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal ponto
	move $ra,$sp
	addi $sp,$sp, 4
	j loop_reta
 		
return:
	jr $ra
# Função ponto recebe:
# $s0 endereço de memória do bitmap
# $a0 coordenada x do pixel a ser colorido
# $a1 coordenada y do pixel a ser colorido
# $a2 cor do pixel a ser colorido
# TODO Salvar os valores anteriores dos registradores na pilha?
	
ponto:
	addi $sp, $sp, -8
	sw   $t0 4($sp)
	sw   $t1 0($sp)
	mul $t1,$a1, 320  #y * 320
	add $t1, $t1, $a0 # y * 320 + x
	add $t0, $s0, $t1
	sb $a2, 0($t0)
	lw $t0  4($sp)
	lw $t1  0($sp)
	jr $ra
	
