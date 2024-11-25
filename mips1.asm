# Máquina de Café em MIPS Assembly
# Autores: Gibram Goulart Farias (20200402) e Kauan Elias Schneider Fank (23201964)

# ---------------------------------------------
# Segmento de Dados
# ---------------------------------------------
        .data

# Contêineres de pós (20 doses cada)
	    .align 2
cafe:       .word 20
leite:      .word 20
chocolate:  .word 20
acucar:     .word 20

# Preços das bebidas
			      .align 2
preco_cafe_puro_pequeno:      .asciiz "R$ 2.00"
preco_cafe_puro_grande:       .asciiz "R$ 3.50"
preco_cafe_leite_pequeno:     .asciiz "R$ 2.50"
preco_cafe_leite_grande:      .asciiz "R$ 4.00"
preco_mochaccino_pequeno:     .asciiz "R$ 3.00"
preco_mochaccino_grande:      .asciiz "R$ 5.00"

# Mensagens
	    	      .align 2
msg_boas_vindas:      .asciiz "\nBem-vindo à Máquina de Café!\n"
msg_menu:             .asciiz "\nEscolha a bebida:\n1 - Café Puro\n2 - Café com Leite\n3 - Mochaccino\nOpção: "
msg_entrada_invalida: .asciiz "\nEntrada Inválida\n"
msg_tamanho:          .asciiz "\nEscolha o tamanho (p - pequeno, g - grande): "
msg_acucar:           .asciiz "\nDeseja adicionar açúcar? (s - sim, n - não): "
msg_preparando:       .asciiz "\nPreparando sua bebida...\n"
msg_concluido:        .asciiz "\nBebida pronta! Aproveite!\n"
msg_falta_cafe:       .asciiz "\nEstoque de cafe insuficiente para preparar a bebida selecionada.\n"
msg_falta_leite:      .asciiz "\nEstoque de leite insuficiente para preparar a bebida selecionada.\n"
msg_falta_chocolate:  .asciiz "\nEstoque de chocolate insuficiente para preparar a bebida selecionada.\n"
msg_falta_acucar:     .asciiz "\nEstoque de acucar insuficiente para preparar a bebida selecionada.\n"
msg_erro_cupom_fiscal:.asciiz "\nOcorreu um erro na geração do seu cupom fiscal, tentar novamente? (s - sim, n - não)\n"

msg_reabastecer:      .asciiz "\nDigite 5 no menu de seleção de bebida para abrir o menu de reabastecimento\n"
msg_reabastecer_opcao:.asciiz "\nQual contêiner deseja reabastecer?\n1 - Café\n2 - Leite\n3 - Chocolate\n4 - Açúcar\nOpção: "
msg_reabastecido:     .asciiz "\nContêiner reabastecido com sucesso!\n"
msg_saida:            .asciiz "\nObrigado por utilizar a Máquina de Café!\n"
debug:	              .asciiz "\n Estou debugando aqui"

# Nomes das bebidas
	    	      .align 2
bebida_cafe_puro:     .asciiz "Café Puro"
bebida_cafe_leite:    .asciiz "Café com Leite"
bebida_mochaccino:    .asciiz "Mochaccino"

# Arquivo de cupom fiscal
	    	      .align 2
nome_arquivo:         .asciiz "cupom_fiscal.txt"

# Variáveis auxiliares para calcular durante procedimento (Pega input user e joga na memória pra poder debugar também)
	    	      .align 2
opcao_bebida:         .space 4 	#Opcao de bebida em int
opcao_tamanho:        .space 4  #Opcao de tamanho em char (g ou p)
opcao_tamanho_int:    .space 4  #Opcao de tamanho mapeado em int (grande = 2, pequeno = 1)
opcao_acucar:         .space 4  #Opcao de acucar em char (s ou n)
opcao_acucar_int:     .space 4  #Opcao de acucar mapeado em int (s = 1, n = 0)
input_usuario:        .space 4

# Labels para o cupom fiscal
	              	.align 2
bebida_label:         	.asciiz "Bebida: "
tamanho_label:        	.asciiz "\nTamanho: "
tamanho_pequeno_label:  .asciiz "Pequeno"
tamanho_grande_label:   .asciiz "Grande"
preco_label:          	.asciiz "\nPreço: "
quebra_linha:         	.asciiz "\n"
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

        seleciona_opcao_bebida:
            # Exibe menu de bebidas
            li $v0, 4
            la $a0, msg_menu
            syscall

            # Lê opção de bebida
            li $v0, 5	#Inputs mapeados: 1 -Café preto; 2- Café com leite; 3- Mocachino -5 Reabastecer
            syscall
            sw $v0, opcao_bebida

            li $t0, 0 # Indica que a entrada inválida ocorreu no seleciona_opcao_bebida
            beq $v0, 4, entrada_invalida # Caso ocorra, imprime entrada inválida e recomeça
            bgt $v0, 5, entrada_invalida # Caso ocorra, imprime entrada inválida e recomeça
            blt $v0, 1, entrada_invalida # Caso ocorra, imprime entrada inválida e recomeça
                                        # (Importante para garantir que o resto da lógica funcione).

            # Verifica se o usuário digitou 5 para reabastecer. Vai pra func ver o que ele deseja reabastecer
            li $t0, 5
            beq $v0, $t0, reabastecer

        seleciona_tamanho_bebida:
            # Solicita tamanho da bebida
            li $v0, 4	
            la $a0, msg_tamanho
            syscall

            # Lê opção de tamanho
            li $v0, 12	#Le caracteres p ou g
            syscall
            sw $v0, opcao_tamanho

            beq $v0, 112, mapeia_tamanho_pequeno # 112 em ascii é p
            beq $v0, 103, mapeia_tamanho_grande  # 103 em ascii é g

            # Caso não faça o desvio, a entrada foi inválida
            li $t0, 1 # Indica que a entrada inválida ocorreu no seleciona_tamanho_bebida
            j entrada_invalida

            mapeia_tamanho_pequeno:
                li $t1, 1
                sw $t1, opcao_tamanho_int
                j seleciona_acucar

            mapeia_tamanho_grande:
                li $t1, 2
                sw $t1, opcao_tamanho_int


        seleciona_acucar:
            # Solicita adição de açúcar
            li $v0, 4	
            la $a0, msg_acucar
            syscall

            # Lê opção de açúcar
            li $v0, 12	#Le caractere s ou n
            syscall
            sw $v0, opcao_acucar
            
            beq $v0, 110, tudo_ok # 110 em ascii é n
            beq $v0, 115, tudo_ok # 115 em ascii é s

            # se chegar aqui, é por que a entrada foi inválida
            li $t0, 2 # Indica que a entrada inválida ocorreu no seleciona_acucar
            j entrada_invalida

        tudo_ok:
            # Verifica estoque e prepara a bebida
            jal verificaEstoque
            beq $v0, 0, prepararBebida  # Se retorno for 0, estoque suficiente
                                        # Retorno 1 - Falta café, 2 - Falta leite, 3 - Falta chocolate, 4 - Falta açucar
                                        # Vai retornar o primeiro que detectar estar faltando, não todos
            
            
            li $v0, 4 # Caso falte, a mensagem de falta já foi carregada no verifica estoque
            syscall

            li $v0, 4
            la $a0, msg_reabastecer # apenas mostra a mensagem de como abrir o menu de reabastecimento
            syscall

            j inicio

        entrada_invalida:
            li $v0, 4
            la $a0, msg_entrada_invalida
            syscall

            beq $t0, 0, seleciona_opcao_bebida
            beq $t0, 1, seleciona_tamanho_bebida
            beq $t0, 2, seleciona_acucar
            j inicio # Esse jump não é para acontecer, mas só para ter certeza.

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
        lw $a0, input_usuario
        jal reabasteceContainer

        # Exibe mensagem de sucesso
        li $v0, 4
        la $a0, msg_reabastecido
        syscall

        # Retorna ao início
        j inicio
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
    
    
    # ---------------------------------------------
    # Procedimento: verificaEstoque
    # Verifica se há estoque suficiente para a bebida selecionada
    # Retorna em $v0: 0 - suficiente, 1 - insuficiente
    # ---------------------------------------------
    verificaEstoque:
        # Carrega opções do usuário
        lw $t0, opcao_bebida
        lw $t1, opcao_tamanho_int
        lw $t2, opcao_acucar
    
        verifica_doses:
            beq $t0, 1, verifica_dose_cafe_puro      # pula para a respectiva bebida
            beq $t0, 2, verifica_dose_cafe_com_leite
            beq $t0, 3, verifica_dose_mochaccino

            verifica_dose_cafe_puro:
                lw $t3, cafe
                la $a0, msg_falta_cafe
                li $v0, 1  # Caso falte café o retorno é 1
                blt $t3, $t1, estoque_insuficiente # caso cafe < necessário, pula para insuficiente

                j verifica_dose_acucar
            
            verifica_dose_cafe_com_leite:
                lw $t3, cafe
                la $a0, msg_falta_cafe
                li $v0, 1  # Caso falte café o retorno é 1
                blt $t3, $t1, estoque_insuficiente
                
                lw $t3, leite
                la $a0, msg_falta_leite
                li $v0, 2  # Caso falte leite o retorno é 2
                blt $t3, $t1, estoque_insuficiente # caso leite < necessário, pula para insuficiente
                
                j verifica_dose_acucar

            verifica_dose_mochaccino:
                
                lw $t3, cafe
                la $a0, msg_falta_cafe
                li $v0, 1  # Caso falte café o retorno é 1
                blt $t3, $t1, estoque_insuficiente
                
                lw $t3, leite
                la $a0, msg_falta_leite
                li $v0, 2  # Caso falte leite o retorno é 2
                blt $t3, $t1, estoque_insuficiente
                
                lw $t3, chocolate
                la $a0, msg_falta_chocolate
                li $v0, 3  # Caso falte chocolate o retorno é 3
                blt $t3, $t1, estoque_insuficiente
                
            verifica_dose_acucar:
                li $t4, 'n'
                beq $t2, $t4, estoque_suficiente # Se chegou até aqui e não precisa de açúcar, estoque suficiente
                
                lw $t3, acucar
                la $a0, msg_falta_acucar
                li $v0, 4  # Caso falte açucar o retorno é 4
                blt $t3, $t1, estoque_insuficiente # caso acucar < necessário, pula para insuficiente

        estoque_suficiente:
            li $v0, 0 # Se chegar até aqui pela execução normal, significa que todos os ingredientes
            jr $ra    # foram suficientes, do contrário teria retornado insuficiente

        estoque_insuficiente:
            jr $ra

            
    prepararBebida:
        # Exibe mensagem de preparação
        li $v0, 4
        la $a0, msg_preparando
        syscall

        # Simula preparação da bebida
        jal preparaBebidaFunc

        # Gera cupom fiscal
        # jal geraCupomFiscal

        # Exibe mensagem de conclusão
        li $v0, 4
        la $a0, msg_concluido
        syscall

        # Retorna ao início
        j inicio

        # ---------------------------------------------
        # Procedimento: preparaBebidaFunc
        # Simula a preparação da bebida usando timer
        # ---------------------------------------------
        preparaBebidaFunc:
            # Simula a liberação dos pós (1 segundo por dose)
            # Utiliza syscall 30 para ler o tempo do SO

            subi $sp, $sp, 4 #É preciso salvar o valor de chamada de quem puxou esta funcao pois o $ra será sobreescrito dentro dela. preparaBebidaFunc
            sw $ra, 0($sp)

            # Carrega doses necessárias
            lw $t0, opcao_bebida
            lw $t1, opcao_tamanho

            li $t3, 'g'
            beq $t1, $t3, tamanho_grande_prepara

            tamanho_pequeno_prepara:
            # Determina doses necessárias novamente
                li $t1, 1          # Doses padrão para copo pequeno
                li $t3, 5
                j prepara_doses

            tamanho_grande_prepara:
                li $t1, 2          # Doses para copo grande
                li $t3, 10
                j prepara_doses

            prepara_doses:
                # Inicializa contadores de doses
                move $t4, $zero # doses de café
                move $t5, $zero # doses de leite
                move $t6, $zero # doses de chocolate
                move $t7, $zero # doses de açúcar

                dose_acucar:
                    #verifica se precisa de açúcar ou não
                    lw $a0, opcao_acucar
                    beq $a0, 110, doses_bebida # ascii da letra n
                    # Se ele não pulou, significa que é para colocar o açúcar
                    move $t7, $t1 # doses em $t1

                    # Determina doses a preparar
                doses_bebida:    
                    li $a0, 1
                    beq $t0, $a0, prepara_cafe_puro
                    li $a0, 2
                    beq $t0, $a0, prepara_cafe_leite
                    li $a0, 3
                    beq $t0, $a0, prepara_mochaccino
                    # Por causa da verificação inicial, é garantido que ele irá cair em algum dos beq

                #Lembrar que t3 é tempo de agua e t1 é dose padrao. Nesta linha já está de acordo com o tamanho do copo
                prepara_cafe_puro:
                    move $t4, $t1  # Doses de café
                    j iniciar_preparacao

                prepara_cafe_leite:
                    move $t4, $t1  # Doses de café
                    move $t5, $t1  # Doses de leite
                    j iniciar_preparacao

                prepara_mochaccino:
                    move $t4, $t1  # Doses de café
                    move $t5, $t1  # Doses de leite
                    move $t6, $t1  # Doses de chocolate

            iniciar_preparacao:

                move $s2, $t3  # Tempo de água de acordo com o tamanho do copo, coloca em s2
                # Prepara café
                move $s1, $t4  # doses de café
                jal liberaPo

                lw $a0, cafe
                sub $a0, $a0, $t4 # Atualiza o café em estoque
                sw $a0, cafe

                # Prepara leite
                move $s1, $t5  # doses de leite
                jal liberaPo

                lw $a0, leite
                sub $a0, $a0, $t5 # Atualiza o leite em estoque
                sw $a0, leite

                # Prepara chocolate
                move $s1, $t6  # doses de chocolate
                jal liberaPo

                lw $a0, chocolate
                sub $a0, $a0, $t6 # Atualiza o chocolate em estoque
                sw $a0, chocolate

                # Prepara açúcar
                move $s1, $t7  # doses de açúcar
                jal liberaPo
    
                lw $a0, acucar
                sub $a0, $a0, $t7 # Atualiza o açucar em estoque
                sw $a0, acucar

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
                    subi $sp, $sp, 4 #É preciso salvar o valor de chamada de quem puxou esta funcao pois o $ra será sobreescrito dentro dela.Libera Po
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
                        addi $sp, $sp, 4 #Devolve ponteiro pro topo
                        jr $ra

                # ---------------------------------------------
                # Procedimento: liberaAgua
                # Libera a água (simula tempo de $a0 segundos)
                # Entrada: $a0 - tempo em segundos
                # ---------------------------------------------
                liberaAgua:
                    subi $sp, $sp, 4 #É preciso salvar o valor de chamada de quem puxou esta funcao pois o $ra será sobreescrito dentro dela. LiberaAgua
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
                        addi $sp, $sp, 4 #Devolve ponteiro pro topo
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
                        # 1000 ms = 1 segundo
                        blt $t3, 1000, espera_loop

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
                la $a1, tamanho_pequeno_label
                j escreve_tamanho

            cupom_tamanho_grande:
                la $a1, tamanho_grande_label

            escreve_tamanho:
                li $v0, 15
                move $a0, $s0
                la $t1, tamanho_pequeno_label
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

            erro_cupom_fiscal:
                la $a0, msg_erro_cupom_fiscal # não deveria acontecer, just in case
                li $v0, 4
                syscall

                li $v0, 5 # tentar novamente, sim/nao
                syscall

                li $a0, 's'
                beq $a0, $v0, geraCupomFiscal

                #else
                j inicio

    sair:
        # Exibe mensagem de saída
        li $v0, 4
        la $a0, msg_saida
        syscall

        # Encerra o programa
        li $v0, 10
        syscall