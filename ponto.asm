.text

	addi $a0, $zero, 20	#x
	addi $a1, $zero, 20	#y
	addi $a2, $zero, 0xc0   #cor
	
	jal ponto
	
	addi $t8, $zero, 23
	addi $t9, $zero, 23
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
	addi $sp, $sp, -4 # aloca 1 word na pilha
	sw $ra, 0($sp)    #salva o ra
	jal loop_reta
	move $ra,$sp   # volta pro ra anterior
	addi $sp, $sp,4 #desaloca
	jr $ra
loop_reta:
	beq $t2,$t8, return
	mtc1 $t2, $f5 # f5 vai ser auxiliar para multiplica a * x
	mul.s $f4, $f2, $f5 # f4 = a*x
	add.s $f6, $f4, $f3 # f6 = a*x + b
	round.w.s $f7,$f6 # arredonde o valor
	mfc1 $a1,$f7 # a1 é o Y = ax + b
	move $a0,$t2 # a0 é x
	addi $sp, $sp, -4 # aloca 1 word na pilha
	sw $ra, 0($sp)    #salva o ra
	jal ponto         # desenha
	move $ra,$sp      # volta pro ra anterior
	addi $sp,$sp, 4 #desaloca
	addi $t2, $t2, 1 # t2++
	j loop_reta
 		
return:
	jr $ra
# Função ponto recebe:
# $s0 endereço de memória do bitmap
# $a0 coordenada x do pixel a ser colorido
# $a1 coordenada y do pixel a ser colorido
# $a2 cor do pixel a ser colorido
# Salvar os valores anteriores dos registradores na pilha?
# Seguindo a convencao utilizada os valores $t e $a nao sao
# permantentes, logo nao precisa usar a pilha

ponto:
	addiu $t0, $zero, 0xff000000 #endereco inicial mmio
	mul $t1,$a1, 320  #y * 320
	addu $t1, $t1, $a0 # y * 320 + x
	addu $t0, $t0, $t1 #0xff000000 + 320 * y + x
	sb $a2, 0($t0) #desenha
	jr $ra
	
