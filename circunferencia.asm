.data
	bmpAdd: .word 0xFF000000	# endereço inicial do display
	largura: .word 320		# largura da tela em pixels
	altura: .word 240		# altura da tela em pixels
.text	
main:
	# Essas instruções apenas carregam os valores de X, Y, raio e a cor nos registradores de argumento
	ori $a0, $zero, 160	# X = 160
	ori $a1, $zero, 120	# Y = 120
	ori $a2, $zero, 60	# Raio = 60
	ori $a3, $zero, 0x000000FF	# cor = 0xFF
	jal circulo
	j exit

# Funcao que desenha um ponto dadas coordenadas (X, Y)	
ponto:
	lw $t0, largura 	# t0 = 320
	multu $a1, $t0		# 320 * Y (unsigned)
	mflo $a1		# move p/ a1 o resultado da multiplicacao contido no reg LO 
	addu $a0, $a0, $a1	# (320*Y) + X
	lw $t1, bmpAdd		# carrega em t1 o valor de bmpAdd (endereço inicial do display)
	addu $t1, $t1, $a0	# t1 = endereço inicial do display + posisão calculada
	
	sb $t0, 0($t1)		# armazena o byte menos significativo em t0
	
	jr $ra			# retorna para a main
	
# A função a seguir utiliza o "midpoint circle algorithm" para realizar o desenho do circulo.
# https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
circulo:
	or $s0, $zero, $a0	# copia a0 em s0 = X0
	or $s1, $zero, $a1	# copia a1 em s1 = Y0
	sub $s2, $zero, $a2	# s2 = inverso do raio (-raio)
	or $s3, $zero, $a3	# copia a3 em s3 = cor
	or $s4, $zero, $a2	# copia a2 em s4 = raio
	ori $s5, $zero, 0	# s5 = Y = 0
	
# Loop para desenhar o circilo. A ideia é dividir o circulo em quadrantes e desenhar em cada um de forma simultanea	
loop_circulo:

	blt $s4, $s5 loop_circuloFIM	# condição de saida válida apenas quando X for menor que Y		

	add $a0, $s0, $s4		# a0 = X0 + X
	add $a1, $s1, $s5		# a1 = Y0 + Y
	or $a2, $zero, $s3		# a2 = valor da cor
	addi $sp, $sp, -4		# cria espaço na pilha
	sw $ra, 0($sp)			# empilha o valor de $ra para retorna a função principal
	jal ponto			# chamada p/ a funcao ponto
	
	add $a0, $s0, $s5		# = a0 = X0 + Y
	add $a1, $s1, $s4		# = a1 = Y0 + X
	or $a2, $zero, $s3		# = cor
	jal ponto			# chamada p/ a funcao ponto
	
	sub $a0, $s0, $s5		# a0 = X0 - Y
	add $a1, $s1, $s4		# a1 = Y0 + X
	or $a2, $zero, $s3		# a2 = cor
	jal ponto			# chamada p/ a funcao ponto
	
	sub $a0, $s0, $s4		# a0 = X0 - X
	add $a1, $s1, $s5		# a1 = Y0 + Y
	or $a2, $zero, $s3		# a2 = cor
	jal ponto			# chamada p/ a funcao ponto
	
	sub $a0, $s0, $s4		# a0 = X0 - X
	sub $a1, $s1, $s5		# a1 = Y0 - Y
	or $a2, $zero, $s3		# = cor
	jal ponto			# chamada p/ a funcao ponto
	
	sub $a0, $s0, $s5		# a2 = X0 - Y
	sub $a1, $s1, $s4		# a1 = Y0 - X
	or $a2, $zero, $s3		# = cor
	jal ponto			# chamada p/ a funcao ponto
	
	add $a0, $s0, $s5		# a0 = X0 + Y
	sub $a1, $s1, $s4		# a1 = Y0 - X
	or $a2, $zero, $s3		# a2 = cor
	jal ponto			# chamada p/ a funcao ponto
	
	add $a0, $s0, $s4		# = X0 + X
	sub $a1, $s1, $s5		# = Y0 - Y
	or $a2, $zero, $s3		# a2 = cor
	jal ponto			# chamada p/ a funcao ponto
	
					
	addi $s5, $s5, 1		# Y = Y + 1
	add $s2, $s2, $s5		# erro = erro + Y
	add $s2, $s2, $s5		# erro = erro + Y

	bltz $s2, loop_circulo		# Se o erro for menor que 0, repete o loop
					
	addi $s4, $s4, -1		# X = X - 1
	sub $s2, $s2, $s4		# erro = erro - X
	sub $s2, $s2, $s4		# erro = erro - X
		
	j loop_circulo			# repete o loop	
	
loop_circuloFIM:
	lw $ra, 0($sp)			# recupera o valor de $ra
	addi $sp, $sp 4			# restaura a posição de sp
	jr $ra				# retorna a função main
	
exit:
	li $v0, 10	# chamada p/ encerrar o programa
	syscall
	
	
	

