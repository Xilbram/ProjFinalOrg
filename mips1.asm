# Máquina de Café em MIPS Assembly
# Autores: Gibram Goulart Farias (20200402) e Kauan Elias Schneider Fank (23201964)

# ---------------------------------------------
# Segmento de Dados
# ---------------------------------------------
.data

# Contêineres de pós (20 doses cada)
	    .align 2
cafe:       .word 1
leite:      .word 1
chocolate:  .word 1
acucar:     .word 1


# Displays:
            .align 2
dsp1:       .word 0xFFFF0011 # Display 1
dsp2:       .word 0xFFFF0010 # Display 2

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
msg_tamanho:          .asciiz "\nEscolha o tamanho (1 - pequeno, 2 - grande): "
msg_acucar:           .asciiz "\nDeseja adicionar açúcar? (0 - não, 1 - sim): "
msg_preparando:       .asciiz "\nPreparando sua bebida...\n"
msg_concluido:        .asciiz "\nBebida pronta! Aproveite!\n"
msg_falta_cafe:       .asciiz "\nEstoque de cafe insuficiente para preparar a bebida selecionada.\n"
msg_falta_leite:      .asciiz "\nEstoque de leite insuficiente para preparar a bebida selecionada.\n"
msg_falta_chocolate:  .asciiz "\nEstoque de chocolate insuficiente para preparar a bebida selecionada.\n"
msg_falta_acucar:     .asciiz "\nEstoque de acucar insuficiente para preparar a bebida selecionada.\n"
msg_erro_cupom_fiscal:.asciiz "\nOcorreu um erro na geração do seu cupom fiscal, tentar novamente? (0 - não, 1 - sim)\n"

msg_reabastecer:      .asciiz "\nDigite 5 no menu de seleção de bebida para abrir o menu de reabastecimento\n"
msg_reabastecer_opcao:.asciiz "\nQual contêiner deseja reabastecer?\n1 - Café\n2 - Leite\n3 - Chocolate\n4 - Açúcar\nOpção: "
msg_reabastecido:     .asciiz "\nContêiner reabastecido com sucesso!\n"
msg_saida:            .asciiz "\nObrigado por utilizar a Máquina de Café!\n"
debug:	              .asciiz "\n Estou debugando aqui"

# Nomes das bebidas
	    	      .align 2
bebida_cafe_puro:     .asciiz "                   Café Puro"
bebida_cafe_leite:    .asciiz "              Café com Leite"
bebida_mochaccino:    .asciiz "                  Mochaccino" # espaços para alinhar com o cupom fiscal

# Arquivo de cupom fiscal
	    	      .align 2
nome_arquivo:         .asciiz "cupom_fiscal.txt"

# Variáveis auxiliares para calcular durante procedimento (Pega input user e joga na memória pra poder debugar também)
	    	      .align 2
opcao_bebida:         .space 4 	#Opcao de bebida em int
opcao_tamanho:        .space 4  #Opcao de tamanho em int (1 - pequeno ou 2 - grande)
opcao_acucar:         .space 4  #Opcao de acucar em int (0 - nao ou 1 - sim)
input_usuario:        .space 4
exibicao_digital_lab_sim: .space 4 #Valor que será usado para ser exibido no digital lab sim

# Labels para o cupom fiscal
	              	.align 2
cupom_fiscal_label:     .asciiz "########### CUPOM FISCAL ###########"
empresa_label:         	.asciiz "Padaria Organização de Computadores"
cnpj_label:            	.asciiz "CNPJ:            12.345.678/0001-91"
separador_de_linha:     .asciiz "-----------------------------------"
bebida_label:         	.asciiz "Bebida:"
tamanho_label:        	.asciiz "Tamanho:"
acucar_label:           .asciiz "Açúcar:" # Esses espaços todos são para alinhar o texto bonitinho no cupom
preco_label:          	.asciiz "Preço Final:                "
tamanho_pequeno_label:  .asciiz "                    Pequeno"
tamanho_grande_label:   .asciiz "                     Grande" # Esses espaços todos são para alinhar o texto bonitinho no cupom
acucar_sim_label:       .asciiz "                         Sim"
acucar_nao_label:       .asciiz "                         Não"
espacamento_data_1:     .asciiz "         "
espacamento_data_2:     .asciiz "   "
endl:                	.asciiz "\n"
# ---------------------------------------------
# Segmento de Texto
# ---------------------------------------------
	.text
        .globl main

main:

    li $s7, 0xFFFF0010		    	# Endereço do display para passar o valor. Evitar modificar este registrador, ou colocar ele na memória e ficar pegando-o na função display
    # Exibe mensagem de boas-vindas
    la $a0, msg_boas_vindas
    jal print

    inicio:

        seleciona_opcao_bebida:
            # Exibe menu de bebidas
            la $a0, msg_menu
            jal print

            # Lê opção de bebida
            jal escanea_digital_lab_sim # Retorna o valor numérico em v0

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
            la $a0, msg_tamanho
            jal print

            # Lê opção de tamanho
            jal escanea_digital_lab_sim # Le tamanho 1 - pequeno, 2 - grande, retorna em v0

            sw $v0, opcao_tamanho

            # Caso não faça o desvio, a entrada foi inválida
            li $t0, 1 # Indica que a entrada inválida ocorreu no seleciona_tamanho_bebida
            blt $v0, 1, entrada_invalida
            bgt $v0, 2, entrada_invalida # Caso o usuário digite algo diferente de 1 ou 2

        seleciona_acucar:
            # Solicita adição de açúcar
            la $a0, msg_acucar
            jal print

            # Lê opção de açúcar
            jal escanea_digital_lab_sim # Le caractere 0 - não, 1 - sim
            sw $v0, opcao_acucar

            li $t0, 2 # Indica que a entrada inválida ocorreu no seleciona_acucar
            blt $v0, 0, entrada_invalida
            bgt $v0, 1, entrada_invalida # Entrada inválida

        tudo_ok:
            # Verifica estoque e prepara a bebida
            jal verificaEstoque
            beq $v0, 0, prepararBebida  # Se retorno for 0, estoque suficiente
                                        # Retorno 1 - Falta café, 2 - Falta leite, 3 - Falta chocolate, 4 - Falta açucar
                                        # Vai retornar o primeiro que detectar estar faltando, não todos
            
            
            jal print # Caso falte, a mensagem de falta já foi carregada no verifica estoque

            la $a0, msg_reabastecer # apenas mostra a mensagem de como abrir o menu de reabastecimento
            jal print

            j inicio

        entrada_invalida:
            la $a0, msg_entrada_invalida
            jal print

            beq $t0, 0, seleciona_opcao_bebida
            beq $t0, 1, seleciona_tamanho_bebida
            beq $t0, 2, seleciona_acucar
            j inicio # Esse jump não é para acontecer, mas só para ter certeza.

    reabastecer:
        # Solicita contêiner para reabastecer
        la $a0, msg_reabastecer_opcao
        jal print

        # Lê opção de contêiner
        jal escanea_digital_lab_sim # Retorna a opção em v0
        sw $v0, input_usuario

        # Reabastece o contêiner selecionado
        lw $a0, input_usuario
        jal reabasteceContainer

        # Exibe mensagem de sucesso
        la $a0, msg_reabastecido
        jal print

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
        lw $t1, opcao_tamanho
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
                beq $t2, 0, estoque_suficiente # Se chegou até aqui e não precisa de açúcar, estoque suficiente
                
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
        la $a0, msg_preparando
        jal print

        # Simula preparação da bebida
        jal preparaBebidaFunc

        # Gera cupom fiscal
        jal geraCupomFiscal

        # Exibe mensagem de conclusão
        la $a0, msg_concluido
        jal print

        li $s3, -1
        jal escreve_display_num
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

            beq $t1, 2, tamanho_grande_prepara

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
                    beq $a0, 0, doses_bebida # sem açúcar
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
                # Soma o tempo total para mostrar no display
                move $s3, $t3 # Tempo de água
                add $s3, $s3, $t4 # doses de café
                add $s3, $s3, $t5 # doses de leite
                add $s3, $s3, $t6 # doses de chocolate
                add $s3, $s3, $t7 # doses de açúcar

                move $s2, $t3  # Tempo de água de acordo com o tamanho do copo, coloca em s2
                
                jal escreve_display_num # Escreve o tempo inicial no display (Máximo de 18, capuchinno grande com açúcar)
                                        # O Liberapo e liberaAgua chamam o método espera1segundo. Nesse método é feito o decréscimo desse registrador
                                        # e também atualiza o display


                # Prepara café
                move $s1, $t4  # doses de café
                jal liberaPo   

                lw $a1, cafe
                sub $a1, $a1, $t4 # Atualiza o café em estoque
                sw $a1, cafe

                # Prepara leite
                move $s1, $t5  # doses de leite
                jal liberaPo

                lw $a1, leite
                sub $a1, $a1, $t5 # Atualiza o leite em estoque
                sw $a1, leite

                # Prepara chocolate
                move $s1, $t6  # doses de chocolate
                jal liberaPo

                lw $a1, chocolate
                sub $a1, $a1, $t6 # Atualiza o chocolate em estoque
                sw $a1, chocolate

                # Prepara açúcar
                move $s1, $t7  # doses de açúcar
                jal liberaPo
    
                lw $a1, acucar
                sub $a1, $a1, $t7 # Atualiza o açucar em estoque
                sw $a1, acucar

                # Libera água

                jal liberaAgua
                
                lw $ra, 0($sp) # Restaura $ra da posição 16, que retém o valor de quem chamou a função prepara_bebida_func. Ponteiro já está no topo
                jr $ra 	# Pra onde esse cara deveria retornar?

                # ---------------------------------------------
                # Procedimento: liberaPo
                # Libera o pó (simula tempo de 1 segundo por dose). Generico para produtos
                # Entrada: $a0 - número de doses
                # ---------------------------------------------
                liberaPo:
                    subi $sp, $sp, 4 #É preciso salvar o valor de chamada de quem puxou esta funcao pois o $ra será sobreescrito dentro dela.Libera Po
                    sw $ra, 0($sp)
                    move $t8, $zero

                    #Hora que t0 atinge valor de pó necessário funcao retorna
                    liberaPo_loop:
                        beq $t8, $s1, liberaPo_fim

                        # Simula 1 segundo
                        jal espera1Segundo # Recebe o tempo atual em s3

                        addi $t8, $t8, 1
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
                    move $t8, $zero

                    liberaAgua_loop:
                        beq $t8, $s2, liberaAgua_fim

                        # Simula 1 segundo
                        jal espera1Segundo

                        addi $t8, $t8, 1
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
                    subi $sp, $sp, 4 # Vai haver chamada de função
                    sw $ra, 0($sp)

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
                        blt $t3, 10, espera_loop


                    subi $s3, $s3, 1 # Decrementa um segundo do timer

                    jal escreve_display_num # O tempo deve estar em s3

                    lw $ra, 0($sp)
                    addi $sp, $sp, 4
                    jr $ra

        # ---------------------------------------------
        # Procedimento: geraCupomFiscal
        # Gera o arquivo .txt com a descrição da bebida e preço
        # ---------------------------------------------
        geraCupomFiscal:

            subi $sp, $sp, 4 # decrementa 4 da stack
            sw $ra, 0($sp) # salva o retorno na stack (será usado depois)
            # Abre o arquivo para escrita
            li $v0, 13        # Syscall 13: open file
            la $a0, nome_arquivo
            li $a1, 1         # parametro write
            li $a2, 0         # mode ignored (não sei o que faz, porém estava no help do mars)
            syscall
            blt $v0, 0, erro_cupom_fiscal
            move $s0, $v0     # Salva o file descriptor

            # Exemplo de cupom fiscal a ser escrito:
            
            #   ########### CUPOM FISCAL ###########
            #   
            #   Padaria Organização de Computadores
            #   CNPJ:            12.345.678/0001-91
            #   
            #   -----------------------------------
            #   Bebida:              Café com Leite
            #   Tamanho:                     Grande
            #   Açúcar:                         Sim
            #   -----------------------------------
            #   
            #   Preço Final:                R$ 4.00
            #   
            #   -----------------------------------
            #            10:35   26/11/2024
            #   
            #   ########### CUPOM FISCAL ###########

            # para cada linha (não precisaria ser para cada linha porém nossas strings estão divididas assim):
            # syscall 15 para escrever no arquivo # reaproveita esse aqui
            # passa em a0 o file descriptor       # reaproveita esse aqui
            # em a1 o endereço da string          # muda esse
            # eme a2 o tamanho da string          # muda esse
            li $v0, 15        # Syscall 15: escreve no arquivo              
            move $a0, $s0     # Passa o file descriptor para a0 (parâmetro) 

            # Escreve "########### CUPOM FISCAL ###########"
            jal label_cupom_fiscal

            jal quebra_linha # quebra de linha (fizemos separado das outras strings para ter maior controle da formatação)

            jal quebra_linha

            # Escreve "Padaria Organização de Computadores"
            la $a1, empresa_label
            li $a2, 36
            jal escreve_string
            jal quebra_linha

            # Escreve "CNPJ:            12.345.678/0001-91"
            la $a1, cnpj_label
            li $a2, 36
            jal escreve_string
            jal quebra_linha

            jal quebra_linha

            # Escreve "-----------------------------------"
            jal separa_linha

            jal quebra_linha

            # Escreve "Bebida:              "
            la $a1, bebida_label
            li $a2, 7
            jal escreve_string

            # Determina nome da bebida
            lw $t0, opcao_bebida
            li $t1, 1
            beq $t0, $t1, cupom_cafe_puro
            li $t1, 2
            beq $t0, $t1, cupom_cafe_leite
            li $t1, 3
            beq $t0, $t1, cupom_mochaccino

            cupom_cafe_puro:
                la $a1, bebida_cafe_puro
                li $a2, 28 # tamanho da string
                j escreve_bebida

            cupom_cafe_leite:
                la $a1, bebida_cafe_leite
                li $a2, 28 # tamanho da string
                j escreve_bebida

            cupom_mochaccino:
                la $a1, bebida_mochaccino
                li $a2, 28 # tamanho da string

            escreve_bebida:
                jal escreve_string
                jal quebra_linha

            # Escreve "Tamanho:                     "
            la $a1, tamanho_label
            li $a2, 8
            jal escreve_string
    
            lw $t1, opcao_tamanho
            beq $t1, 2, cupom_tamanho_grande

            cupom_tamanho_pequeno:
                la $a1, tamanho_pequeno_label
                li $a2, 27 # tamanho da string
                j escreve_tamanho

            cupom_tamanho_grande:
                la $a1, tamanho_grande_label
                li $a2, 27 # tamanho da string

            escreve_tamanho:
                jal escreve_string
                jal quebra_linha

            # Escreve "Açúcar:                         "
            la $a1, acucar_label
            li $a2, 7
            jal escreve_string

            lw $t0, opcao_acucar
            beq $t0, 1, cupom_acucar_sim # 1 se tiver açúcar
            
            cupom_acucar_nao:
                la $a1, acucar_nao_label
                li $a2, 28 # tamanho da string
                j escreve_acucar
            
            cupom_acucar_sim:
                la $a1, acucar_sim_label
                li $a2, 28 # tamanho da string
            
            escreve_acucar:
                jal escreve_string
                jal quebra_linha

            jal separa_linha
            jal quebra_linha
            jal quebra_linha

            # Escreve "Preço Final:                "
            la $a1, preco_label
            li $a2, 28
            jal escreve_string

            # Determina preço
            determina_preco:
                lw $t1, opcao_tamanho
                li $a2, 7 # Todas as strings tem o mesmo tamanho
                beq $t1, 2, preco_grande

                preco_pequeno:
                    lw $t0, opcao_bebida
                    li $t1, 2
                    beq $t1, $t0, cafe_com_leite_pequeno
                    li $t1, 3
                    beq $t1, $t0, mochaccino_pequeno

                    cafe_puro_pequeno:
                        la $a1, preco_cafe_puro_pequeno
                        j escreve_preco

                    cafe_com_leite_pequeno:
                        la $a1, preco_cafe_leite_pequeno
                        j escreve_preco

                    mochaccino_pequeno:
                        la $a1, preco_mochaccino_pequeno
                        j escreve_preco

                preco_grande:
                    lw $t0, opcao_bebida
                    li $t1, 2
                    beq $t1, $t0, cafe_com_leite_grande
                    li $t1, 3
                    beq $t1, $t0, mochaccino_grande

                    cafe_puro_grande:
                        la $a1, preco_cafe_puro_grande
                        j escreve_preco

                    cafe_com_leite_grande:
                        la $a1, preco_cafe_leite_grande
                        j escreve_preco

                    mochaccino_grande:
                        la $a1, preco_mochaccino_grande
                        j escreve_preco
            
            escreve_preco:
                jal escreve_string

                jal quebra_linha

            jal quebra_linha
            jal separa_linha
            jal quebra_linha

            # imprime o horário e data
            #jal printa_data # função que imprime a data e hora (não implementada)
            jal quebra_linha
            
            jal quebra_linha
            jal label_cupom_fiscal
            
            # Fecha o arquivo
            li $v0, 16        # Syscall 16: close file
            syscall

            lw $ra, 0($sp) # pega o retorno
            addi $sp, $sp, 4 # incrementa 4 da stack

            jr $ra


            quebra_linha:
                li $v0, 15
                move $a0, $s0
                la $a1, endl
                li $a2, 1
                syscall
                jr $ra

            separa_linha:
                li $v0, 15
                move $a0, $s0
                la $a1, separador_de_linha
                li $a2, 35
                syscall
                jr $ra

            label_cupom_fiscal:
                li $v0, 15
                move $a0, $s0
                la $a1, cupom_fiscal_label
                li $a2, 36
                syscall
                jr $ra

            escreve_string:
                li $v0, 15
                move $a0, $s0
                syscall     # importante: a1 e a0 já foram setados antes de chamar essa função
                jr $ra

            erro_cupom_fiscal:
                la $a0, msg_erro_cupom_fiscal # não deveria acontecer, just in case
                jal print

                jal escanea_digital_lab_sim # Retorna o valor em vo

                li $a0, 1
                beq $a0, $v0, geraCupomFiscal

                #else
                j inicio


    sair:
        # Exibe mensagem de saída
        la $a0, msg_saida
        jal print

        # Encerra o programa
        li $v0, 10
        syscall

    print:
        li $v0, 4
        syscall
        jr $ra
        
        
escanea_digital_lab_sim: # Executa a leitura até achar um valor, quando achar retorna o número pressionado.
    subi $sp, $sp, 4
    sw $ra, 0($sp) # Guarda o retorno pois irá haver chamada de função

    li $t0, 0x1			    	# Inicializa t0 com o valor para varrer a linha 1 do teclado
 	li $s0, 0xFFFF0012		   	# Endereço de comando do teclado
 	li $s1, 0xFFFF0014		  	# Endereço dos dados do teclado

    verifica_coluna:
        sb $t0, 0($s0)				# Envia o comando para verificar uma linha do teclado
        lw $s3, 0($s1)				# Lê o valor da tecla pressionada
        beq $s3, $zero, avanca_proxima_coluna	# Se nenhuma tecla foi pressionada, avança para a próxima coluna			
 	
    # Caso chegue aqui é por que alguma tecla foi pressionada, retorna em v0.

    jal escreve_display_hexa # Escreve o número lido no display

    jal parse_hex_num # Irá transformar o hex lido em número para retornar ao código, retorna no mesmo registrador v0

    lw $ra, 0($sp)
    addi $sp, $sp, 4
 	jr $ra 					
	
avanca_proxima_coluna:
 	sll $t0, $t0, 1				    # Desloca para a próxima linha do teclado
 	li  $t5, 16 				    # Verifica se já percorreu todas as linhas (tamanho do teclado)
 	beq $t0, $t5, reset_leitura_teclado		    # Se já percorreu todas, reinicia
 	j verifica_coluna

reset_leitura_teclado:
	li $t0, 0x1				    # Reseta para a primeira linha
	j verifica_coluna


parse_hex_num: # Recebe uma posição em hexadecimal do display em s3 e retorna o número correspondente.
    beq $s3, 0x11, num0
    beq $s3, 0x21, num1
    beq $s3, 0x41, num2
    beq $s3, 0x81, num3
    beq $s3, 0x12, num4
    beq $s3, 0x22, num5
    beq $s3, 0x42, num6
    beq $s3, 0x82, num7
    beq $s3, 0x14, num8
    beq $s3, 0x24, num9
    beq $s3, 0x44, num10
    beq $s3, 0x84, num11
    beq $s3, 0x18, num12
    beq $s3, 0x28, num13
    beq $s3, 0x48, num14
    beq $s3, 0x88, num15
    num0:
        li $v0, 0
        jr $ra
    num1:
        li $v0, 1
        jr $ra
    num2:
        li $v0, 2
        jr $ra
    num3:
        li $v0, 3
        jr $ra
    num4:
        li $v0, 4
        jr $ra
    num5:
        li $v0, 5
        jr $ra
    num6:
        li $v0, 6
        jr $ra
    num7:
        li $v0, 7
        jr $ra
    num8:
        li $v0, 8
        jr $ra
    num9:
        li $v0, 9
        jr $ra
    num10:
        li $v0, 10
        jr $ra
    num11:
        li $v0, 11
        jr $ra
    num12:
        li $v0, 12
        jr $ra
    num13:
        li $v0, 13
        jr $ra
    num14:
        li $v0, 14
        jr $ra
    num15:
        li $v0, 15
        jr $ra

    li $v0, -1 # Se chegar até aqui é por que o valor inserido é incorreto
    jr $ra

escreve_display_num: # Recebe um número em base decimal em s3 e passa ao equivalente display
                     # Será utilizado ao printar os segundos decrementando
    beq $s3, -1, case_PF
    beq $s3, 0, case_0
    beq $s3, 1, case_1
    beq $s3, 2, case_2
    beq $s3, 3, case_3
    beq $s3, 4, case_4
    beq $s3, 5, case_5
    beq $s3, 6, case_6
    beq $s3, 7, case_7
    beq $s3, 8, case_8
    beq $s3, 9, case_9
    beq $s3, 10, case_10
    beq $s3, 11, case_11
    beq $s3, 12, case_12
    beq $s3, 13, case_13
    beq $s3, 14, case_14
    beq $s3, 15, case_15
    beq $s3, 16, case_16
    beq $s3, 17, case_17
    beq $s3, 18, case_18

    j case_null # Se chegar aqui é por que houve um erro na passagem

escreve_display_hexa: # Recebe um numero hexadecimal como parâmetro em s3 e passa ao equivalente display
                     # Será utilizado ao printar os botão selecionado no display 
    beq $s3, 0x11, case_0
    beq $s3, 0x21, case_1
    beq $s3, 0x41, case_2
    beq $s3, 0x81, case_3
    beq $s3, 0x12, case_4
    beq $s3, 0x22, case_5
    beq $s3, 0x42, case_6
    beq $s3, 0x82, case_7
    beq $s3, 0x14, case_8
    beq $s3, 0x24, case_9
    beq $s3, 0x44, case_10
    beq $s3, 0x84, case_11
    beq $s3, 0x18, case_12
    beq $s3, 0x28, case_13
    beq $s3, 0x48, case_14
    beq $s3, 0x88, case_15
    
    j case_null # Se chegar aqui é por que houve um erro na passagem

# Valores para mostrar no display:
    case_PF:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x73
		li $t3, 0x71

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
    case_0:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x3f

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
	case_1:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x06

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
	case_2:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x5b

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
	case_3:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x4f

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
    case_4:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x66

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
	case_5:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x6d

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
	case_6:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x7d

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
	case_7:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x07

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
	case_8:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x7f

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
	case_9:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x3f
		li $t3, 0x67

        sb $t2, 0($t0)
        sb $t3, 0($t1)
		
        jr $ra
	case_10:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x06
		li $t3, 0x3f

		sb $t2, 0($t0)
        sb $t3, 0($t1)

		jr $ra
	case_11:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x06
		li $t3, 0x06

		sb $t2, 0($t0)
        sb $t3, 0($t1)
        
		jr $ra
	case_12:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x06
		li $t3, 0x5b

		sb $t2, 0($t0)
        sb $t3, 0($t1)
        
		jr $ra
	case_13:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x06
		li $t3, 0x4f

		sb $t2, 0($t0)
        sb $t3, 0($t1)
        
		jr $ra
	case_14:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x06
		li $t3, 0x66

		sb $t2, 0($t0)
        sb $t3, 0($t1)
        
		jr $ra
	case_15:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x06
		li $t3, 0x6d

		sb $t2, 0($t0)
        sb $t3, 0($t1)
        
		jr $ra
    case_16:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x06
		li $t3, 0x7d

		sb $t2, 0($t0)
        sb $t3, 0($t1)
        
		jr $ra
    case_17:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x06
		li $t3, 0x07

		sb $t2, 0($t0)
        sb $t3, 0($t1)
        
		jr $ra
    case_18:
        lw $t0, dsp1
		lw $t1, dsp2

		li $t2, 0x06
		li $t3, 0x7f

		sb $t2, 0($t0)
        sb $t3, 0($t1)
        
		jr $ra
    
    case_null:
        lw $t0, dsp1
        lw $t1, dsp2
        
        li $t2, 0xff
        li $t3, 0xff

        sb $t2, 0($t0)
        sb $t3, 0($t1)
        
        jr $ra
