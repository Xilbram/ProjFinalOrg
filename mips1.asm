# Máquina de Café em MIPS Assembly
# Autores: Gibram Goulart Farias (20200402) e 

# ---------------------------------------------
# Segmento de Dados
# ---------------------------------------------
        .data
# Contêineres de pós (20 doses cada)
cafe:       .word 20
leite:      .word 20
chocolate:  .word 20
acucar:     .word 20

# Preços das bebidas
preco_cafe_puro_pequeno:      .asciiz "R$ 2.00"
preco_cafe_puro_grande:       .asciiz "R$ 3.50"
preco_cafe_leite_pequeno:     .asciiz "R$ 2.50"
preco_cafe_leite_grande:      .asciiz "R$ 4.00"
preco_mochaccino_pequeno:     .asciiz "R$ 3.00"
preco_mochaccino_grande:      .asciiz "R$ 5.00"

# Mensagens
msg_boas_vindas:      .asciiz "\nBem-vindo à Máquina de Café!\n"
msg_menu:             .asciiz "\nEscolha a bebida:\n1 - Café Puro\n2 - Café com Leite\n3 - Mochaccino\nOpção: "
msg_tamanho:          .asciiz "\nEscolha o tamanho (p - pequeno, g - grande): "
msg_acucar:           .asciiz "\nDeseja adicionar açúcar? (s - sim, n - não): "
msg_preparando:       .asciiz "\nPreparando sua bebida...\n"
msg_concluido:        .asciiz "\nBebida pronta! Aproveite!\n"
msg_estoque_insuf:    .asciiz "\nEstoque insuficiente para preparar a bebida selecionada.\n"
msg_reabastecer:      .asciiz "\nDigite 5 para reabastecer os contêineres ou qualquer outra tecla para sair: "
msg_reabastecer_opcao:.asciiz "\nQual contêiner deseja reabastecer?\n1 - Café\n2 - Leite\n3 - Chocolate\n4 - Açúcar\nOpção: "
msg_reabastecido:     .asciiz "\nContêiner reabastecido com sucesso!\n"
msg_saida:            .asciiz "\nObrigado por utilizar a Máquina de Café!\n"
debug:	       .asciiz "\n Estou debugando aqui"

# Nomes das bebidas
bebida_cafe_puro:     .asciiz "Café Puro"
bebida_cafe_leite:    .asciiz "Café com Leite"
bebida_mochaccino:    .asciiz "Mochaccino"

# Arquivo de cupom fiscal
nome_arquivo:         .asciiz "cupom_fiscal.txt"

# Alinhar as variáveis de palavra (Tava dando erro de store address not aligned on word boundary)
        .align 2

# Variáveis auxiliares para calcular durante procedimento (Pega input user e joga na memória pra poder debugar também)
opcao_bebida:         .space 4 	#Opcao de bebida em int
opcao_tamanho:        .space 4  #Opcao de tamanho em char (g ou p)
opcao_tamanho_int: .space 4  #Opcao de tamanho mapeado em int (grande = 2, pequeno = 1)
opcao_acucar:         .space 4  #Opcao de acucar em char (s ou n)
opcao_acucar_int:     .space 4  #Opcao de acucar mapeado em int (s = 1, n = 0)
input_usuario:        .space 4

# Labels para o cupom fiscal
bebida_label:         .asciiz "Bebida: "
tamanho_label:        .asciiz "\nTamanho: "
tamanho_pequeno_label:      .asciiz "Pequeno"
tamanho_grande_label:       .asciiz "Grande"
preco_label:          .asciiz "\nPreço: "
quebra_linha:         .asciiz "\n"
# ---------------------------------------------
# Segmento de Texto
# ---------------------------------------------
        .text
        .globl main

main:
    # Exibe mensagem de boas-vindas
    li $v0, 4
    la $a0, msg_boas_vindas
    syscall

inicio:
    # Exibe menu de bebidas
    li $v0, 4
    la $a0, msg_menu
    syscall

    # Lê opção de bebida
    li $v0, 5	#Inputs mapeados: 1 -Café preto; 2- Café com leite; 3- Mocachino -5 Reabastecer
    syscall
    sw $v0, opcao_bebida

    # Verifica se o usuário digitou 5 para reabastecer. Vai pra func ver o que ele deseja reabastecer
    li $t0, 5
    beq $v0, $t0, reabastecer

    # Solicita tamanho da bebida
    li $v0, 4	
    la $a0, msg_tamanho
    syscall

    # Lê opção de tamanho
    li $v0, 12	#Le caracteres p ou g
    syscall
    sw $v0, opcao_tamanho
    #beq $v0, 112, mapeia_tamanho_pequeno
    #beq $v0, 103, mapeia_tamanho_pequeno

    # Solicita adição de açúcar
    li $v0, 4	
    la $a0, msg_acucar
    syscall

    # Lê opção de açúcar
    li $v0, 12	#Le caractere s ou n
    syscall
    sw $v0, opcao_acucar

    # Verifica estoque e prepara a bebida
    jal verificaEstoque
    beq $v0, 0, prepararBebida  # Se retorno for 0, estoque suficiente (sucess), se 1 failure
    # Caso contrário, exibe mensagem de estoque insuficiente
    li $v0, 4
    la $a0, msg_estoque_insuf
    syscall
    j inicio

prepararBebida:
    # Exibe mensagem de preparação
    li $v0, 4
    la $a0, msg_preparando
    syscall
    li $v0, 4
    la $a0, debug
    syscall

    # Simula preparação da bebida
    jal preparaBebidaFunc

    # Atualiza estoque
    jal atualizaEstoque

    # Gera cupom fiscal
    jal geraCupomFiscal

    # Exibe mensagem de conclusão
    li $v0, 4
    la $a0, msg_concluido
    syscall

    # Retorna ao início
    j inicio

reabastecer:
    # Solicita contêiner para reabastecer
    li $v0, 4
    la $a0, msg_reabastecer_opcao
    syscall

    # Lê opção de contêiner
    li $v0, 5	#Mapeamento de entradas:
    syscall
    sw $v0, input_usuario

    # Reabastece o contêiner selecionado
    lw $t1, input_usuario
    jal reabasteceContainer

    # Exibe mensagem de sucesso
    li $v0, 4
    la $a0, msg_reabastecido
    syscall

    # Retorna ao início
    j inicio

sair:
    # Exibe mensagem de saída
    li $v0, 4
    la $a0, msg_saida
    syscall

    # Encerra o programa
    li $v0, 10
    syscall

# ---------------------------------------------
# Procedimento: verificaEstoque
# Verifica se há estoque suficiente para a bebida selecionada
# Retorna em $v0: 0 - suficiente, 1 - insuficiente
# ---------------------------------------------
verificaEstoque:
    # Carrega opções do usuário
    lw $t0, opcao_bebida
    lw $t1, opcao_tamanho

   
    #Verifica em t5 se opcao é grande. Se não vai para tamanho_pequeno e calcula com métricas tamanho pequeno
    li $t5, 'g'
    beq $t1, $t5, tamanho_grande

tamanho_pequeno:
    li $t2, 1          # Doses padrão para copo pequeno
    li $t3, 5          # Tempo de água para copo pequeno
    li $t4, 1          # Flag de tamanho (1 - pequeno, 2 - grande)
    j calcula_doses

tamanho_grande:
    li $t2, 2          # Doses para copo grande
    li $t3, 10         # Tempo de água para copo grande
    li $t4, 2          # Flag de tamanho
    j calcula_doses

calcula_doses:
    # Inicializa registros de doses necessárias
    li $t6, 0  # Doses de café necessárias
    li $t7, 0  # Doses de leite necessárias
    li $t8, 0  # Doses de chocolate necessárias
    li $t9, 0  # Doses de açúcar necessárias

    # Verifica bebida selecionada
    li $a0, 1
    beq $t0, $a0, bebida_cafe_puro_func
    li $a0, 2
    beq $t0, $a0, bebida_cafe_leite_func
    li $a0, 3
    beq $t0, $a0, bebida_mochaccino_func

    # Se opção inválida, retorna insuficiente
    li $v0, 1
    jr $ra

bebida_cafe_puro_func:
    move $t6, $t2  # Doses de café
    j verifica_acucar

bebida_cafe_leite_func:
    move $t6, $t2  # Doses de café
    move $t7, $t2  # Doses de leite
    j verifica_acucar

bebida_mochaccino_func:
    move $t6, $t2  # Doses de café
    move $t7, $t2  # Doses de leite
    move $t8, $t2  # Doses de chocolate
    j verifica_acucar

verifica_acucar:
    # Verifica se o usuário quer açúcar
    lw $a0, opcao_acucar
    li $a1, 's'
    beq $a0, $a1, adicionar_acucar
    j verifica_estoque_containers

adicionar_acucar:
    move $t9, $t2  # Doses de açúcar

verifica_estoque_containers:
    # Verifica estoque de café
    lw $a0, cafe
    bge $a0, $t6, verifica_leite #t6 aqui é cafe
    li $v0, 1
    jr $ra

verifica_leite:
    # Verifica estoque de leite
    lw $a0, leite
    bge $a0, $t7, verifica_chocolate #t7 aqui é leite
    li $v0, 1
    jr $ra

verifica_chocolate:
    # Verifica estoque de chocolate
    lw $a0, chocolate
    bge $a0, $t8, verifica_acucar_container #t8 aqui é chocolate
    li $v0, 1
    jr $ra

verifica_acucar_container:
    # Verifica estoque de açúcar
    lw $a0, acucar
    bge $a0, $t9, estoque_suficiente
    li $v0, 1
    jr $ra

estoque_suficiente:
    li $v0, 0 #Se estoque até aqui for suficiente para todos itens a serem usados, retornar 0
    jr $ra

# ---------------------------------------------
# Procedimento: preparaBebidaFunc
# Simula a preparação da bebida usando timer
# ---------------------------------------------
preparaBebidaFunc:
    # Simula a liberação dos pós (1 segundo por dose)
    # Utiliza syscall 30 para ler o tempo do SO

    addi $sp, $sp, -16 #É preciso salvar o valor de chamada de quem puxou esta funcao pois o $ra será sobreescrito dentro dela. preparaBebidaFunc
    sw $ra, 0($sp)

    # Carrega doses necessárias
    lw $t6, opcao_bebida
    lw $t1, opcao_tamanho

    li $t5, 'g'
    beq $t1, $t5, tamanho_grande_prepara

tamanho_pequeno_prepara:
 # Determina doses necessárias novamente
    li $t2, 1          # Doses padrão para copo pequeno
    li $t3, 1          # Tempo de água para copo pequeno
    
    j prepara_doses

tamanho_grande_prepara:
    li $t2, 2          # Doses para copo grande
    li $t3, 1         # Tempo de água para copo grande
    j prepara_doses

prepara_doses:
    # Inicializa contadores de doses
    move $t6, $zero  # Doses de café
    move $t7, $zero  # Doses de leite
    move $t8, $zero  # Doses de chocolate
    move $t9, $zero  # Doses de açúcar

    # Determina doses a preparar
    lw $t0, opcao_bebida
    li $a0, 1
    beq $t0, $a0, prepara_cafe_puro
    li $a0, 2
    beq $t0, $a0, prepara_cafe_leite
    li $a0, 3
    beq $t0, $a0, prepara_mochaccino

#Lembrar que t3 é tempo de agua e t2 é dose padrao. Nesta linha já está de acordo com o tamanho do copo
prepara_cafe_puro:
    move $t6, $t2  # Doses de café
    j avalia_acucar_preparar

prepara_cafe_leite:
    move $t6, $t2  # Doses de café
    move $t7, $t2  # Doses de leite
    j avalia_acucar_preparar

prepara_mochaccino:
    move $t6, $t2  # Doses de café
    move $t7, $t2  # Doses de leite
    move $t8, $t2  # Doses de chocolate
    j avalia_acucar_preparar

avalia_acucar_preparar:
    # Verifica se o usuário quer açúcar
    lw $a0, opcao_acucar
    li $a1, 's'
    beq $a0, $a1, preparar_acucar

    j iniciar_preparacao

preparar_acucar:
    move $t9, $t2  # Doses de açúcar

iniciar_preparacao:

    move $s2, $t3  # Tempo de água em segundos fica salvo em s2
    # Prepara café
    move $s1, $t6
    jal liberaPo

    # Prepara leite
    move $s1, $t7
    jal liberaPo

    # Prepara chocolate
    move $s1, $t8
    jal liberaPo

    # Prepara açúcar
    move $s1, $t9
    jal liberaPo

    # Libera água

    jal liberaAgua
    
    lw $ra, 0($sp) #Restaura $ra da posição 16, que retém o valor de quem chamou a função prepara_bebida_func. Ponteiro já está no topo
    jr $ra 	#Pra onde esse cara deveria retornar?

# ---------------------------------------------
# Procedimento: liberaPo
# Libera o pó (simula tempo de 1 segundo por dose). Generico para produtos
# Entrada: $a0 - número de doses
# ---------------------------------------------
liberaPo:
    addi $sp, $sp, -32 #É preciso salvar o valor de chamada de quem puxou esta funcao pois o $ra será sobreescrito dentro dela.Libera Po
    sw $ra, 0($sp)
    move $t0, $zero

#Hora que t0 atinge valor de pó necessário funcao retorna
liberaPo_loop:
    beq $t0, $s1, liberaPo_fim

    # Simula 1 segundo
    jal espera1Segundo

    addi $t0, $t0, 1
    j liberaPo_loop

liberaPo_fim:
    lw $ra, 0($sp)	#Restaura $ra de quem chamou essa função, efetivamente encerrando o loop
    addi $sp, $sp, 32 #Devolve ponteiro pro topo
    jr $ra

# ---------------------------------------------
# Procedimento: liberaAgua
# Libera a água (simula tempo de $a0 segundos)
# Entrada: $a0 - tempo em segundos
# ---------------------------------------------
liberaAgua:
    addi $sp, $sp, -32 #É preciso salvar o valor de chamada de quem puxou esta funcao pois o $ra será sobreescrito dentro dela. LiberaAgua
    sw $ra, 0($sp)
    move $t0, $zero

liberaAgua_loop:
    beq $t0, $s2, liberaAgua_fim

    # Simula 1 segundo
    jal espera1Segundo

    addi $t0, $t0, 1
    j liberaAgua_loop

liberaAgua_fim:
    lw $ra, 0($sp)	#Restaura $ra de quem chamou essa função, efetivamente encerrando o loop
    addi $sp, $sp, 32 #Devolve ponteiro pro topo
    jr $ra

# ---------------------------------------------
# Procedimento: espera1Segundo
# Espera por aproximadamente 1 segundo usando syscall 30
# ---------------------------------------------
espera1Segundo:
    # Lê tempo inicial. Isso está em ms como descrito no Mars_guide, pois vem de Java.util.Date.getTime() 
    li $v0, 30
    syscall
    move $t1, $a0  # Tempo inicial em ms

espera_loop:
    # Lê tempo atual.Esse loop vai rodar até que o valor do tempo atual supere o tempo inicial em 1000. Isso implicaria que 1 segundo passou
    li $v0, 30
    syscall
    move $t2, $a0  # Tempo atual em ms

    sub $t3, $t2, $t1  # Calcula diferença
    li $t4, 10       # 1000 ms = 1 segundo
    blt $t3, $t4, espera_loop

    jr $ra

# ---------------------------------------------
# Procedimento: atualizaEstoque
# Atualiza o estoque após preparação da bebida
# ---------------------------------------------
atualizaEstoque:
    # Carrega doses utilizadas
    # Similar ao procedimento verificaEstoque

    # Carrega opções do usuário
    lw $t0, opcao_bebida
    lw $t1, opcao_tamanho

    # Determina doses utilizadas
    li $t2, 1          # Doses padrão para copo pequeno
    li $t3, 5          # Tempo de água para copo pequeno

    li $t5, 'g'
    beq $t1, $t5, tamanho_grande_atualiza

tamanho_pequeno_atualiza:
    j atualiza_doses

tamanho_grande_atualiza:
    li $t2, 2          # Doses para copo grande
    li $t3, 10         # Tempo de água para copo grande
    j atualiza_doses

atualiza_doses:
    # Inicializa registros de doses necessárias
    li $t6, 0  # Doses de café utilizadas
    li $t7, 0  # Doses de leite utilizadas
    li $t8, 0  # Doses de chocolate utilizadas
    li $t9, 0  # Doses de açúcar utilizadas

    # Verifica bebida selecionada
    li $a0, 1
    beq $t0, $a0, atualiza_cafe_puro
    li $a0, 2
    beq $t0, $a0, atualiza_cafe_leite
    li $a0, 3
    beq $t0, $a0, atualiza_mochaccino

    jr $ra  # Retorna se opção inválida

atualiza_cafe_puro:
    move $t6, $t2  # Doses de café
    j atualiza_acucar

atualiza_cafe_leite:
    move $t6, $t2  # Doses de café
    move $t7, $t2  # Doses de leite
    j atualiza_acucar

atualiza_mochaccino:
    move $t6, $t2  # Doses de café
    move $t7, $t2  # Doses de leite
    move $t8, $t2  # Doses de chocolate
    j atualiza_acucar

atualiza_acucar:
    # Verifica se o usuário quer açúcar
    lw $a0, opcao_acucar
    li $a1, 's'
    beq $a0, $a1, descontar_acucar

    j descontar_estoque

descontar_acucar:
    move $t9, $t2  # Doses de açúcar

descontar_estoque:
    # Desconta doses de café
    lw $a0, cafe
    sub $a0, $a0, $t6
    sw $a0, cafe

    # Desconta doses de leite
    lw $a0, leite
    sub $a0, $a0, $t7
    sw $a0, leite

    # Desconta doses de chocolate
    lw $a0, chocolate
    sub $a0, $a0, $t8
    sw $a0, chocolate

    # Desconta doses de açúcar
    lw $a0, acucar
    sub $a0, $a0, $t9
    sw $a0, acucar

    jr $ra

# ---------------------------------------------
# Procedimento: geraCupomFiscal
# Gera o arquivo .txt com a descrição da bebida e preço
# ---------------------------------------------
geraCupomFiscal:
    # Abre o arquivo para escrita
    li $v0, 13        # Syscall 13: open file
    la $a0, nome_arquivo
    li $a1, 0x602     # Flags: O_CREAT | O_WRONLY
    li $a2, 0x1B6     # Mode: 666 em octal
    syscall
    move $s0, $v0     # File descriptor

    # Escreve dados no arquivo
    # Exemplo: "Bebida: Café com Leite\nTamanho: Grande\nPreço: R$ 4.00\n"

    # Escreve "Bebida: "
    li $v0, 15        # Syscall 15: write to file
    move $a0, $s0     # File descriptor
    la $a1, bebida_label
    li $a2, 8         # Tamanho da string
    syscall

    # Determina nome da bebida
    lw $t0, opcao_bebida
    li $a0, 1
    beq $t0, $a0, cupom_cafe_puro
    li $a0, 2
    beq $t0, $a0, cupom_cafe_leite
    li $a0, 3
    beq $t0, $a0, cupom_mochaccino

cupom_cafe_puro:
    la $a1, bebida_cafe_puro
    j escreve_bebida

cupom_cafe_leite:
    la $a1, bebida_cafe_leite
    j escreve_bebida

cupom_mochaccino:
    la $a1, bebida_mochaccino

escreve_bebida:
    li $v0, 15
    move $a0, $s0
    la $t1, bebida_cafe_puro
    li $a2, 10        # Tamanho máximo do nome
    syscall

    # Escreve "\nTamanho: "
    li $v0, 15
    move $a0, $s0
    la $a1, tamanho_label
    li $a2, 10
    syscall

    # Escreve tamanho
    lw $t1, opcao_tamanho
    li $t2, 'p'
    beq $t1, $t2, cupom_tamanho_pequeno
    li $t2, 'g'
    beq $t1, $t2, cupom_tamanho_grande

cupom_tamanho_pequeno:
    la $a1, tamanho_pequeno
    j escreve_tamanho

cupom_tamanho_grande:
    la $a1, tamanho_grande

escreve_tamanho:
    li $v0, 15
    move $a0, $s0
    la $t1, tamanho_pequeno
    li $a2, 8
    syscall

    # Escreve "\nPreço: "
    li $v0, 15
    move $a0, $s0
    la $a1, preco_label
    li $a2, 9
    syscall

    # Determina preço
    # (Por simplicidade, você pode associar preços fixos conforme bebida e tamanho)
    # Escreve o preço correspondente

    # Fecha o arquivo
    li $v0, 16        # Syscall 16: close file
    move $a0, $s0
    syscall

    jr $ra

# ---------------------------------------------
# Procedimento: reabasteceContainer
# Reabastece o contêiner selecionado para 20 doses
# Entrada: $t1 - opção do contêiner
# ---------------------------------------------
reabasteceContainer:
    lw $t0, input_usuario

    li $a0, 1
    beq $t0, $a0, reabastece_cafe
    li $a0, 2
    beq $t0, $a0, reabastece_leite
    li $a0, 3
    beq $t0, $a0, reabastece_chocolate
    li $a0, 4
    beq $t0, $a0, reabastece_acucar

    jr $ra  # Retorna se opção inválida

reabastece_cafe:
    li $a0, 20
    sw $a0, cafe
    jr $ra

reabastece_leite:
    li $a0, 20
    sw $a0, leite
    jr $ra

reabastece_chocolate:
    li $a0, 20
    sw $a0, chocolate
    jr $ra

reabastece_acucar:
    li $a0, 20
    sw $a0, acucar
    jr $ra

