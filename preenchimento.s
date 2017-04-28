.text

		li $a0, 0
		li $a1, 0
		li $a2, 0x00
		
		jal preenchimento2
		li $v0, 10
		syscall

#Funcao preenchimento2
# $a0 x0 (0, 319) => 16 bits (halfword)
# $a1 y0 (0, 239) => 16 bits (halfword)
# $a2 cor2

preenchimento2:
		addi $sp, $sp -4
		sw $ra, 0($sp)
		
		move $a3, $a2
		
		addiu $t0, $zero, 0xff000000 #endereco inicial mmio
		mul $t1,$a1, 320  #y * 320
		addu $t1, $t1, $a0 # y * 320 + x
		addu $t0, $t0, $t1 #0xff000000 + 320 * y + x
		lb $a2, 0($t0) #pega a cor do pixel
		
		jal preenchimento

		lw $ra, 0($sp)
		addi $sp, $sp 4
		jr $ra


#Funcao preenchimento
# $a0 x0 (0, 319) => 16 bits (halfword)
# $a1 y0 (0, 239) => 16 bits (halfword)
# $a2 cor1
# $a3 cor2

preenchimento:
		addi $sp, $sp, -24
		sw $fp, 20($sp) #Sera utilizada a pilha nao somente para a inicializacao e a finalizacao,
			       #mas tambem no meio do procedimento. Logo, se grava $fp, para poder
			       #acessar-se dados estaticos e verificar o fim do loop
		sw $ra, 16($sp)
		sw $s0, 12($sp)
		sw $s1, 8($sp)
		sw $s2, 4($sp)
		sw $s3, 0($sp)
		
		move $fp, $sp #inicio dos dados dinamicos que serao usados nesse programa
		
		move $s0, $a2 #cor1
		move $s1, $a3 #cor2
		
		addi $sp, $sp, -4
		sh $a0, 2($sp)
		sh $a1, 0($sp)

l_preenchiment:
		
		beq $fp, $sp, f_preenchiment #se nao ha nenhum dado dinamico, termine
		
		lh $s2, 2($sp) #x
		lh $s3, 0($sp) #y
		addi $sp, $sp, 4
		
		move $a0, $s2 #x
		move $a1, $s3 #y
		move $a2, $s0 #cor1
		
		jal is_color #verifica se a cor esta certa
		
		beq $v0, $zero, l_preenchiment #se a cor esta errada volte pro comeco
		
		#cor esta certa e eh um elemento do display, entao pinte e olhe os vizinhos
		
		move $a0, $s2 #x
		move $a1, $s3 #y
		move $a2, $s1 #cor2
		
		jal ponto #desenha
		
		addi $t0, $s2, -1 #x - 1
		addi $t1, $s3, 0 #y
		addi $sp, $sp, -4
		sh $t0, 2($sp) #x
		sh $t1, 0($sp) #y
		
		addi $t0, $s2, 1 #x + 1
		addi $t1, $s3, 0 #y
		addi $sp, $sp, -4
		sh $t0, 2($sp) #x
		sh $t1, 0($sp) #y
		
		addi $t0, $s2, 0 #x
		addi $t1, $s3, -1 #y - 1
		addi $sp, $sp, -4
		sh $t0, 2($sp) #x
		sh $t1, 0($sp) #y
		
		addi $t0, $s2, 0 #x
		addi $t1, $s3, 1 #y + 1
		addi $sp, $sp, -4
		sh $t0, 2($sp) #x
		sh $t1, 0($sp) #y
		
		j l_preenchiment
		
f_preenchiment:		
		lw $fp, 20($sp)
		lw $ra, 16($sp)
		lw $s0, 12($sp)
		lw $s1, 8($sp)
		lw $s2, 4($sp)
		lw $s3, 0($sp)
		addi $sp, $sp, 24
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
		
f_is_color:	lw $ra, 12($sp)
		lw $s0, 8($sp)
		lw $s1, 4($sp)
		lw $s2, 0($sp)
		addi $sp, $sp, 16
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
		
		addi $t2, $zero, 0xff000000
		
		slt $t0, $t8, $t2 # $t8 < 0xff00000 => muito pequeno
		slt $t1, $t9, $t8 # $t9 (x max, y max) < $t8 => muito grande
		or $t0, $t0, $t1 # $t0 = {1 se eh muito pequeno ou muito grande; 0 se esta na tela}
		sub $t0, $zero, $t0 # $t0 = {-1 se eh muito pequeno ou muito grande; 0 se esta na tela}
		addi $v0, $t0, 1  # $v0 = {0 se eh muito pequeno ou muito grande; 1 se esta na tela}
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