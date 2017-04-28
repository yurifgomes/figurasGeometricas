.text

#Funcao preenchimento
# $a0 x0
# $a1 y0
# $a2 cor1
# $a3 cor2

preenchimento:
		jr $ra

#funcao in_borders
# $a0 x0
# $a1 y0
#Verifica se o ponto (x0, y0) esta na tela do display
#Retorna 1 se estiver na tela, 0 se nao estiver

in_borders:
		addiu $t0, $zero, 0xff000000 #endereco inicial mmio
		mul $t1,$a1, 320  #y * 320
		addu $t1, $t1, $a0 # y * 320 + x
		
		addu $t8, $t0, $t1 # $t8 = 0xff000000 + 320 * y + x
		
		li $a0, 319 # x maximo
		li $a1, 239 # y maximo
		
		addiu $t0, $zero, 0xff000000 #endereco inicial mmio
		mul $t1,$a1, 320  #y * 320
		addu $t1, $t1, $a0 # y * 320 + x
		
		addu $t9, $t0, $t1 # $t0 = 0xff000000 + 320 * y + x
		
		slti $t0, $t8, 0xff000000 # $t8 < 0xff00000 => muito pequeno
		slti $t1, $t9, $t8 # $t9 (x max, y max) < $t8 => muito grande
		or $t0, $t0, $t1 # $t0 = {1 se eh muito pequeno ou muito grande; 0 se esta na tela}
		sub $t0, $zero, $t0 # $t0 = {-1 se eh muito pequeno ou muito grande; 0 se esta na tela}
		addi $v0, $t0, 1  # $v0 = {0 se eh muito pequeno ou muito grande; 1 se esta na tela}
		jr $ra

#funcao is_color
# $a0 x0
# $a1 y0
# $a2 cor
#Verifica se o ponto (x0, y0) tem a cor 'cor' (e esta na tela do display)
#Retorna 1 se estiver na tela, 0 se nao estiver

is_color:
		addi $sp, $sp, -16
		sw $ra, 12($sp)
		sw $s0, 8($sp)
		sw $s1, 4($sp)
		sw $s2, 0($sp)
		
		move $s0, $a0
		move $s1, $a1
		move $s2, $a2
		
		jal in_borders #verifica se (x0, y0) esta na tela
		
		move $t0, $v0 #esta na tela?
		move $v0, $zero #nao eh da cor certa
		
		beq $t0, $zero, f_is_color #se nao esta na tela, termina
		
		addiu $t0, $zero, 0xff000000 #endereco inicial mmio
		mul $t1,$s1, 320  #y * 320
		addu $t1, $t1, $s0 # y * 320 + x
		addu $t0, $t0, $t1 #0xff000000 + 320 * y + x
		lb $t0, 0($t0) #acha o cor do bit
		
		seq $v0, $t0, $s2 #se a cor for igual o retorno sera 1
		
f_is_color:	sw $ra, 12($sp)
		lw $s0, 8($sp)
		lw $s1, 4($sp)
		lw $s2, 0($sp)
		addi $sp, $sp, 12
		jr $ra

# Função ponto recebe:
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