;Bernardo Hummes Flores - 00287689

         assume cs:codigo,ds:dados,es:dados,ss:pilha

CR       EQU    0DH ; constante - codigo ASCII do caractere "carriage return"
LF       EQU    0AH ; constante - codigo ASCII do caractere "line feed"

; definicao do segmento de dados do programa
dados    segment
digite	 			db     	'Digite o nome do arquivo: $'
fimlinha 			db     	CR,LF,'$'
arquivo  			db 		13 dup(?)
bla					db		'$'
conteudo 			db		16000 dup(0)
blabla				db		0
comprimido			db		16000 dup(0)
blablabla			db		0
quebrado			db		16000 dup(0)
blablablabla		db		0
impressao			db		80 dup(0)
blablablablabla		db		0
limpaEspacoTexto	db		1839 dup(' ')
linhaBranca			db		80 dup(' ')
fimLimpa			db		'$'

inicioNome			db		0
posCursor			db		0
handle				dw		0

nCharsLidos			db		6 dup(0)
ble					db		'$'
nCharsRemovidos		db		6 dup(0)
bleble				db		'$'
endProxLinha		dw		0
op					db		0
flagUp				db		0
flagDown			db		0


posicaoAtual		dw		0
linhaAtual			db		0
ultimoEspaco		dw		0
charsLidos			dw		0
endFimLinha			dw		0

limiteSuperior		dw		16360
linhaInicial		dw		0
linhasEncontradas	dw		0
endInicialImpressao dw		0

temp				dw		0

oi1					db		' OI1 $'
oi2					db		' OI2 $'
oi3					db		' OI3 $'
oi4					db		' OI4 $'

msgErroAbertura		db		CR,LF,'Erro na abertura do arquivo $'
msgErroLeitura		db		CR,LF,'Erro na leitura do arquivo $'
cliqueParaContinuar	db		CR,LF,'Pressione qualquer tecla para continuar$'
erroArquivo			db		'Erro: arquivo nao encontrado$'
erroHandler			db		'Erro: nao ha mais handlers disponiveis$'
erroCaminho			db		'Erro: caminho nao encontrado$'
erroAcesso			db		'Erro: acesso negado$'
erroNaoConhecido	db		'Erro indeterminado$'

flag				db		0
nBytesLidos			dw		0
msgSupExibicao1		db		'Arquivo: $'
msgSupExibicao2		db		' contendo $'
msgSupExibicao3		db		' caracteres. Eliminados $'
msgSupExibicao4		db		' espacos e TABs.$'
nBytesRemovidos		dw		0

msgOpcoes			db		'Comandos: w/W - rolar para cima, s/S - rolar para baixo, ESC - fim da exibicao.$'

numeroASerExibido	db		0
resto				db		0
cem					db		100
dez					db 		10

msgFim1				db		'|----------------------------------------------------------|$'
msgFim2				db		'|                                                          |$'
msgFim3				db		'|                                                          |$'
msgFim4				db		'|            Programa simpaticamente encerrado!            |$'
msgFim5				db		'|                                                          |$'
msgFim6				db		'|                                                          |$'
msgFim7				db		'|                                                          |$'
msgFim8				db		'|             Um excelente dia para o usuario!             |$'
msgFim9				db		'|                                                          |$'
msgFim10			db		'|                                                          |$'
msgFim11			db		'|__________________________________________________________|$'

dados    ends

; definicao do segmento de pilha do programa
pilha    segment stack ; permite inicializacao automatica de SS:SP
         dw     128 dup(?)
pilha    ends
         
; definicao do segmento de codigo do programa
codigo   segment
inicio:  ; CS e IP sao inicializados com este endereco
         mov    ax,dados ; inicializa DS
         mov    ds,ax    ; com endereco do segmento DADOS
		 mov    es,ax    ; idem em ES
; fim da carga inicial dos registradores de segmento

; a partir daqui, as instrucoes especificas para cada programa
; neste exemplo, o programa apenas exibe uma mensagem na tela 
; e devolve o controle para o sistema operacional (DOS)

recebe_nome_arquivo:
		mov nBytesRemovidos, 0
		
;posiciona cursor no inicio da tela
		mov bh, 0
		mov dh, 0
		mov dl, 0
		mov ah, 2
		int 10h

; limpa a tela
        mov     ch,0         	;linha zero  - canto superior esquerdo 
        mov     cl,0         	;coluna zero - da janela
        mov     dh,24        	;linha 24    - canto inferior direito
        mov     dl,79        	;coluna 79   - da janela
        mov     bh,07h       	;atributo de preenchimento (fundo preto e letras cinzas)
        mov     al,0         	;detemina toda tela a ser limpada
        mov     ah,6         	;rola janela para cima
        int     10h          	

;limpa a memoria	
		mov si, offset arquivo
		mov cx, 13
limpa_nome:
		mov [si], 0
		inc si
		loop limpa_nome
		
		mov si, offset conteudo
		mov cx, 16000
limpa_conteudo:
		mov[si], 0
		inc si
		loop limpa_conteudo
		
		mov si, offset comprimido
		mov cx, 16000
limpa_comprimido:
		mov [si], 0
		inc si
		loop limpa_comprimido
		
		mov si, offset quebrado
		mov cx, 16000
limpa_quebrado:
		mov [si], 0
		inc si
		loop limpa_quebrado

		
;recebe nome do arquivo
        lea dx, digite        	;endereco da mensagem em DX
        mov ah,9               	;funcao exibir mensagem no AH
        int 21h                	;chamada do DOS
		
		mov ah, 3
		mov bh, 0
		int 10h
		mov inicioNome, dl		;armazena em inicioNome a posicao do inico da mensagem a ser digitara, a fim de nao apagar o pedido de digitar
	
		mov si, offset arquivo	;inicializa ponteiro para onde sera armazenado o nome do arquivo
		
entra:
		mov ah, 8
		int 21h					;recebe char do teclado
		
		cmp al, 8
		je backspace			;testa se foi digitado espaco
		cmp al, 13
		je testa_sufixo			;testa se foi encerrada a digitacao
		
		mov [si], al			;armazena char digitado
		inc si					;incrementa ponteiro
		
		mov dl, al				
		mov ah, 2
		int 21h					;exibe caractere digitado
		
		jmp entra				;retoma processo de receber chars
		
backspace:
		mov ah, 3
		mov bh, 0
		int 10h					;funcao para receber a posicao do cursor
		
		cmp dl, inicioNome
		je entra				;testa se jah nao apagou todo o nome
		
		dec dl					;decrementa reg com coluna do cursor para que fique no ultimo char recebido
		mov posCursor, dl		;armazena essa posicao, por retornara para ela
		
		mov bh, 0
		mov ah, 2
		int 10h					;posiciona cursor na coluna que foi decrescida
		
		mov dl, 32
		mov ah, 2
		int 21h					;insere um espaco
		
		dec si
		mov [si], 0				;decrementa ponteiro para string com nomne do arquivo e insere espaco em branco
		
		mov bh, 0
		mov dl, posCursor
		mov ah, 2				;retorna mais uma vez o cursor para que proximo char ocupe o espaco
		int 10h
		
		mov [si], 0
		
		jmp entra				;retorna para digitacao do nome do arquivo

testa_sufixo:
		inc si					
		mov [si], 0				;incrementa ponteiro e insere delimitador do fim da string
		
		mov di, offset arquivo	;aponta di para inicio da string com o nome do arquivo
		cld						;percorre string no sentido normal
		mov si, di				;ponteiro de destino eh o mesmo da origem
		
		mov cx, 12
procura_ponto:
		lodsb					;carrega em al o char na posicao atual
		cmp al, '.'				;procura pelo char '.' que inidia a existencia de uma extensao
		je abertura_arquivo			;se encontrar, continua para abrir o arquivo
		cmp al, 0				;procura pelo fim do nome
		je insere_txt			;chegando no fim do nome sem encontrar a extensao, a insere
		stosb					;armazena char lido no destino
		loop procura_ponto		;enquanto nao encontra fim ou extensao, retoma loop
		
insere_txt:
		cmp arquivo, 0			;testa se nada foi digitado
		je fim_1				;caso sim, vai para pulo auxiliar para encerramento
		jmp continua_insere_txt	;caso nao, continua com insercao do sufixo
fim_1:
		jmp fim					;pulo auxiliar para fim do programa

continua_insere_txt:
		mov [di], '.'
		mov [di+1], 't'
		mov [di+2], 'x'
		mov [di+3], 't'
		mov [di+4], 0			;move .txt para o final do nome do arquivo
		
abertura_arquivo:
		mov al, 0				;define a abertura do arquivo
		mov dx, offset arquivo	;passa endereco do inicio da string com o nome do arquivo
		mov ah, 3dh				
		int 21h					;chama abertura do arquivo
		jc erro_abertura		;se carry = 1 -> erro na abertura
		mov handle, ax			;se conseguiu abrir, move para a variavel o handle
		jmp leitura_arquivo		;pula para a leitura do arquivo
		
erro_abertura:
		lea dx, msgErroAbertura	;exibe mensagem de erro de abetura
		mov ah, 9
		int 21h
		mov [di+5], '$'			;insere '$' no fim do nome do arquivo para permitir exibicao
		lea dx, arquivo
		mov ah, 9
		int 21h					;exibe nome do arquivo testado
		lea dx, fimlinha
		mov ah, 9
		int 21h					;insere quebra de linha
		cmp al, 2
		je erro_arquivo
		cmp al, 4
		je erro_handler			;testa se o erro foi falta de handlers
		cmp al, 3
		je erro_caminho			;testa se o erro foi caminho inexistente
		cmp al, 5
		je erro_acesso			;testa se o erro foi acesso negado
		
		lea dx, erroNaoConhecido;no caso de nao ser qualquer um desses casos, exibe que foi um erro indeterminado
		jmp fim_erro_abertura
erro_arquivo:
		lea dx, erroArquivo
		jmp fim_erro_abertura
erro_handler:
		lea dx, erroHandler
		jmp fim_erro_abertura
erro_caminho:
		lea dx, erroCaminho
		jmp fim_erro_abertura
erro_acesso:
		lea dx, erroAcesso
		jmp fim_erro_abertura
								
fim_erro_abertura:
		mov ah, 9
		int 21h					;exibe mensagens de erro de acordo com o teste
		lea dx, cliqueParaContinuar		
		mov ah, 9
		int 21h					;exibe mensagem pedindo que clique em algo para continuar
		mov ah, 8
		int 21h					;espera usuario digitar algo para retomar pedido pelo nome do arquivo
		jmp recebe_nome_arquivo
		
leitura_arquivo:
		mov bx, handle			;indica a handle que foi salva
		mov cx, 2000			;maximo de caracteres a serem lidos
		lea dx, conteudo		;indica buffer
		mov ah, 3fh				
		int 21h					;chamada da leitura do arquivo
		jc erro_leitura			;se carry == 1, erro na leitura
		mov nBytesLidos, ax		;caso nao ocorra erro, copia o numero de chars lidos
		jmp limpeza_texto		;vai para parte que elimina repeticao de espacos e TABs
	
erro_leitura:
		lea dx, msgErroLeitura
		mov ah, 9
		int 21h
		jmp recebe_nome_arquivo	;exibe mensagem de erro de leitura
		
limpeza_texto:
		mov si, offset conteudo	;aponta si para conteudo do arquivo
		mov di, offset comprimido;aponta di para onde vai salvar o conteudo sem as repeticoes
		cld						;limpa flag de direcao
		
procura_para_remover:
		lodsb					;carrega char
		
		;lea dx, oi				
		;mov ah, 9
		;int 21h
		
		cmp al, 0
		je exibe_texto			;testa se eh o final da string
		
		cmp al, 9
		jne continua_procura_1	;testa se eh tabulacao
		
		cmp flag, 1
		je incrementa_removidos	;se for e a flag de jah ter encontrado algum antes estiver ligada, ignora char
		mov flag, 1				;se nao estiver, liga a flag e 
		jmp insere				;pula para insercao na nova parte da memoria
		
continua_procura_1:
		cmp al, 32				;testa se eh espaco
		jne continua_procura_2
		
		cmp flag, 1
		je incrementa_removidos	;se for e tiver flag de jah ter encontrado algum antes ligado, ignora char
		mov flag, 1				;se nao, liga flag e
		jmp insere				;pula para insercao na nova parte da memoria
		
continua_procura_2:
		mov flag, 0				;no caso de nao ser espaco ou tab, garante que flag esta desligada
insere:
		stosb					;armazena char na nova parte da memoria
		jmp procura_para_remover;retoma loop de procura
		
incrementa_removidos:
		inc nBytesRemovidos		;a cada remocao, apenas incrementa contador de chars removidos
		jmp procura_para_remover;e volta para loop de procura
	


exibe_texto:
		mov bh, 0
		mov dh, 0
		mov dl, 0
		mov ah, 2
		int 10h					;posiciona cursor no inicio da tela

;limpa a tela
        mov     ch,0         	;linha zero  - canto superior esquerdo 
        mov     cl,0         	;coluna zero - da janela
        mov     dh,24        	;linha 24    - canto inferior direito
        mov     dl,79        	;coluna 79   - da janela
        mov     bh,07h       	;atributo de preenchimento (fundo preto e letras cinzas)
        mov     al,0         	;detemina toda tela a ser limpada
        mov     ah,6         	;rola janela para cima
        int     10h          	

;formata primeira e ultima linhas
		mov cx, 80				;80 linhas para serem modificadas
		mov bl, 41h				;fundo vermelho e letras azuis
		mov al, ' '				;completa com espacos
		mov bh, 0
		mov ah, 9
		int 10h					
		
		mov bh, 0				;pagina
		mov dh, 24				;linha
		mov dl, 0				;coluna
		mov ah, 2
		int 10h					;posiciona cursor no inicio da ultima linha para repetir o processo
		
		mov cx, 80
		mov bl, 41h
		mov al, ' '
		mov bh, 0
		mov ah, 9
		int 10h					;completa com espacos, modificando o fundo para vermelho e as letras para azul
	
;insere mensgem superior
		mov bh, 0
		mov dh, 0
		mov dl, 0
		mov ah, 2
		int 10h					;posiciona cursor no inicio da primeira linha
		
		lea dx, msgSupExibicao1
		mov ah, 9
		int 21h					;exibe primeira parte da mensagem
		
		
		mov si, offset arquivo	;aponta si para inicio da string com o nome do arquivo
procura_cifra:
		cmp [si], 0				;procura 0, indicando fim da string
		je insere_cifra			;quando acha, insere '$', permitindo exibicao
		inc si					;incrementa ponteiro
		jmp procura_cifra		;retoma loop		
insere_cifra:
		mov [si+1], '$'			;insere '$' no fim da string
		
		lea dx, arquivo
		mov ah, 9
		int 21h					;exibe nome do arquivo
		
		lea dx, msgSupExibicao2
		mov ah, 9
		int 21h					;exibe segunda parte da mensagem do cabecalho
		
		
		mov ax, nBytesLidos
		mov di, offset nCharsLidos
		
		cmp ax, 9999
		ja maior_que_9999
		mov [di], 48			;insere o algarismo das dezenas de milhar, testado a partir de uma comparacao por existe apenas a possibildade de ser 1 ou 0
		jmp continua_div_num
maior_que_9999:
		mov [di], 49
		
continua_div_num:	
		mov ax, nBytesLidos
		div dez
		add ah, 48
		mov [di+4], ah			;divide por 10 para separar o digito das unidades
		
		mov ah, 0				;zera parte mais significativa do numero onde estava armazenado o resto
		div dez	
		add ah, 48
		mov [di+3], ah			;divide o resto por 10 para separar o digito das dezenas
		
		mov ah, 0				;zera parte mais significativa do numero onde estava armazenado o resto
		div dez
		add ah, 48
		mov [di+2], ah			;divide o resto por 10 para separar o digito das centenas

		mov ah, 0				;zera parte mais significativa do numero onde estava armazenado o resto
		div dez
		add ah, 48
		mov [di+1], ah			;divide o resto por 10 para separar o digito dos milhares
		
		mov [di+5], '$'
		
;procura o primeiro digito diferente de 0 para começar a impressao do numero
		mov si, offset nCharsLidos

		lodsb
		cmp al, 48
		jne imprime_numero_chars
		lodsb
		cmp al, 48
		jne imprime_numero_chars
		lodsb
		cmp al, 48
		jne imprime_numero_chars
		lodsb
		cmp al, 48
		jne imprime_numero_chars
		lodsb
		
imprime_numero_chars:
		dec si
		mov dx, si
		mov ah, 9
		int 21h

		lea dx, msgSupExibicao3
		mov ah, 9
		int 21h					;exibe terceira parte do cabecalho

		mov ax, nBytesRemovidos	;copia o numero de bytes lidos do arquivo para manipulacao
		mov di, offset nCharsRemovidos

		cmp ax, 9999
		ja maior_que_9999_2
		mov [di], 48		;insere o algarismo das dezenas de milhar, testado a partir de uma comparacao por existe apenas a possibildade de ser 1 ou 0
		
		jmp continua_div_num_2
maior_que_9999_2:
		mov [di], 49
		
		
continua_div_num_2:	
		div dez
		add ah, 48
		mov [di+4], ah		;divide por 10 para separar o digito das unidades

		mov ah, 0			;zera parte mais significativa do numero onde estava armazenado o resto
		div dez
		add ah, 48
		mov [di+3], ah		;divide o resto por 10 para separar o digito das dezenas

		mov ah, 0			;zera parte mais significativa do numero onde estava armazenado o resto
		div dez
		add ah, 48
		mov [di+2], ah		;divide o resto por 10 para separar o digito das centenas

		mov ah, 0			;zera parte mais significativa do numero onde estava armazenado o resto
		div dez
		add ah, 48			;divide o resto por 10 para separar o digito dos milhares
		mov [di+1], ah
		
		mov [di+5], '$'
		
;procura o primeiro digito diferente de 0 para começar a impressao do numero
		mov si, offset nCharsRemovidos

		lodsb
		cmp al, 48
		jne imprime_numero_chars_2
		lodsb
		cmp al, 48
		jne imprime_numero_chars_2
		lodsb
		cmp al, 48
		jne imprime_numero_chars_2
		lodsb
		cmp al, 48
		jne imprime_numero_chars_2
		lodsb
		
imprime_numero_chars_2:
		dec si
		mov dx, si
		mov ah, 9
		int 21h					;imprime numero de caracteres removidos
		
		lea dx, msgSupExibicao4
		mov ah, 9
		int 21h

		;call ola
		;call pausa
		
		lea si, conteudo		;aponta para endereco inicial do conteudo do arquivo
		add si, nBytesLidos		;soma os bytes modificados
		mov [si+1], '$'			;insere $ para delimitar fim da string

		lea si, comprimido		;aponta para endereco inicia da string comprimida
		add si, nBytesLidos		;adiciona o numero de bytes lidos
		sub si, nBytesRemovidos ;e remove o numero de bytes removidos, a fim de apontar para o final da string
		mov [si+1], '$'			;insere $ para permitir exibicao
		
	
		mov bh, 0
		mov dh, 1
		mov dl, 0
		mov ah, 2
		int 10h					;coloca cursor no inicio da segunda linha da tela
		
		jmp formata_texto
	
	
formata_texto:
		mov si, offset comprimido;aponta para endereco inicial da string comprimida de origem
		mov di, offset quebrado	;aponta para endereco inicial da string de destino
		mov charsLidos, 0		;inicializa contador de caracteres lidos com 0

procura_quebra:
		lodsb					;carrega em al char da origem
		
		cmp al, ' '				;testa se eh um espaco para salvar o endereco
		je salva_endereco_espaco;sempre salva o ultimo espaco encontrado para inserir o delimitador de string quando termina o contador do tamanho maximo da string
		
continua_procura_quebra_1:
		cmp al, CR
		je achou_cr				;testa se encontra uma quebra de linha antes do fim da linha, para representar isso na string de destino
		
		cmp al, '$'
		je imprime_linhas		;testa se encontrou um delimitador de fim de string para encerrar insercao das quebras
		
		cmp al, 0
		je imprime_linhas		;testa se encontrou um delimitador de fim de string para encerrar insercao das quebras
		
		cmp charsLidos, 80
		je fim_linha			;testa se chegou no tamanho maximo da string
		
		inc charsLidos			;a cada iteracao incrementa o contador de chars lidos
		stosb					;nao sendo qualquer um dos casos especiais, armazena no destino o caractere da origem
		jmp procura_quebra		;retoma loop de procura
		
salva_endereco_espaco:
		mov ultimoEspaco, di	;tendo encontrado um espaco, salva seu endereco
		jmp continua_procura_quebra_1;continua loop da procura
		
achou_cr:
		mov al, '$'				;quando encontra uma quebra de linha ntes do fim da mesma, insere no endereco correspondente em destino um delimitador de string
		
		stosb					;armazena o delimitador
		lodsb					;carrega um char sem armazenar para pular o LF
		mov charsLidos, 0		;reseta o contador de chars lidos por comecar uma nova linha
		jmp procura_quebra		;retoma loop
		
fim_linha:
		mov endFimLinha, di		;chegando no final da linha, move para variavel que armazena o final da linha o valor atual de di
		mov di, ultimoEspaco	;di apont para o ultimo espaco antes do termino da linha
		mov al, '$'				;passa para al o char a ser inserido ($)
		stosb					;armazena o caractere
		
		dec si					;volta uma posicao para ser conferida
volta:
		mov ax, [si]			
		cmp al, ' '				;testa na oridem se encontrou o espaco que foi substituido por um delimitador de string na destino
		je continua_1			;caso encontre, incrementa si para apontar para o novo comeco de linha

		dec si					;decrementa si para testar char anterior
		jmp volta				;retoma loop

continua_1:
		inc si					;incrementa si para apontar para o novo comeco de linha
		jmp continua_2
		
		
continua_2:
		mov charsLidos, 0		;reseta o numero de chars lidos
		jmp procura_quebra		;retoma a procura pelas quebras de linha
		

imprime_linhas:
		mov si, offset quebrado	;aponta si para string com os delimitadores de string no lugar das quebras
		mov di, offset impressao;aponta di para espaco para armazenar temporariamente a string a set colocada no visor
		
		mov linhaAtual, 1		;inicializa contador da linha atual com 1 (a primeira eh o cabecalho do programa)

		mov bh, 0
		mov dh, 1
		mov dl, 0
		mov ah, 2
		int 10h					;move o cursor para inicio da linha 1
		
procura_fim_linha:
		lodsb					;carrega char da origem
		
		cmp al, '$'
		je imprime				;testa se encontrou o delimitador de linha
		
		cmp al, 0				
		je ultima_linha			;testa de encontrou o fim da string
		
		
		stosb					;nao sendo qualquer um desses, armazena na string temporaria o conteudo da original
		jmp procura_fim_linha	;retoma loop
		
imprime:
		mov al, '$'				;move para al char a ser inserido

		stosb					;tendo encontrado fim da linha, armazena delimitador no destino
		
		mov bh, 0			
		mov dh, linhaAtual
		mov dl, 0
		mov ah, 2
		int 10h					;posiciona cursor no inicio da linha atual
		
		lea dx, impressao
		mov ah, 9
		int 21h					;imprime string armazenada temporariamente, contendo apenas 1 linha
		
		;call pausa
		
		cmp linhaAtual, 23		;testa se chegou na ultima linha da tela que deve receber texto
		je ultima_linha			;passa para impressao da ultima linha com comandos possiveis para o usuario
		
		inc linhaAtual			;incrementa contador da linha atual
		mov di, offset impressao;reinicia ponteiro para string temporaria
		jmp procura_fim_linha	;retoma loop de impressao
		
		

;funcao que pausa a execucao e espera pressinar qualquer tecla - para debug	
pausa:
	mov ah, 8
	int 21h
	ret
	
;funcao que printa mensagem na tela - para debug
ola1:
	lea dx, oi1
	mov ah, 9
	int 21h
	ret
ola2:
	lea dx, oi2
	mov ah, 9
	int 21h
	ret
ola3:
	lea dx, oi3
	mov ah, 9
	int 21h
	ret
ola4:
	lea dx, oi4
	mov ah, 9
	int 21h
	ret
	
	
;exibe mensagem com opcoes para o usuario
;posiciona cursor na ultimalinha
ultima_linha:
		mov si, offset impressao			;aponta si para endereco inicial da string temporaria de impressao
		
procura_fim_linha_2:
		lodsb								;carrega char de origem para ser testado
		
		cmp al, '$'							;testa se jah chegou no final da linha
		je end_prox_linha					;se encontra, segue para impressao da ultima linha e salva endereco do fim anterior
		jmp procura_fim_linha_2				;retoma loop de procura

end_prox_linha:
		inc si								;incrementa si para passar pelo marcador
		mov endProxLinha, si				;salva endereco

		mov bh, 0				;pagina
		mov dh, 24				;linha
		mov dl, 0				;coluna
		mov ah, 2
		int 10h								;posiciona cursor na ultima linha da tela
	
		lea dx, msgOpcoes
		mov ah, 9
		int 21h								;imprime opcoes para o usuario
		
		jmp prepara_rolagem 				
		
		
prepara_rolagem:
		mov linhaInicial, 0					;inicializa contador da linha por onde deve comecar a impressao na tela
		
		jmp espera_op
		
;espera opcao para continuar
espera_op:
		mov ah, 8
		int 21h								;recebe char do teclado
		
		mov op, al							;armazena opcao em variavel
		
		cmp al, 27
		je pulo_inicio						;se for esc, volta para escolha do arquivo a ser operado em cima
		
		cmp al, 'w'
		je sobe_tela						
		
		cmp al, 'W'
		je sobe_tela						;se for w ou W sobe a tela, imprimindo a partir da linha superior
		
		cmp al, 's'
		je desce_tela
		
		cmp al, 'S'
		je desce_tela						;se for s ou S desce a tela, imprimindo a partir da linha abaixo
		
		jmp espera_op						;espera pressionar alguma tecla
		
pulo_inicio:
	jmp recebe_nome_arquivo					;pulo auxiliar para inicio do programa
	
sobe_tela:
;rola a tela 1 linha para cima
		cmp linhaInicial, 0				;primeira linha que permite impressao de texto sem lixo de memoria	
		je espera_op					;ignora caso passe dela
		
		cmp flagUp, 1				
		je espera_op					;caso flag de fim do arquivo na mesma direcao ligada, ignora comando
		
		cmp flagDown, 1
		je desliga_flag_down			;caso flag do fim do arquivo na direcao oposta ligada, a desliga e continua
		
continua_sobe_tela:
		dec linhaInicial				;decrementa contador de linhas a fim de exibir a partir da linha acima
		
		mov ax, linhaInicial			;move linha inical para ax, parametro da funcao
		call imprime_a_partir_de		;chama funcao de imprimir as linhas da tela
		
		jmp espera_op					;retorna para espera da escolha de uma opcao pelo usuario
		
desliga_flag_down:
		mov flagDown, 0					;desliga flag quando direcao oposta a ela eh selecionada
		jmp continua_sobe_tela
		
desce_tela:	
		mov ax, linhaInicial
		cmp ax, limiteSuperior			; 16.383 - 23 -> ultima linha que possibilida impressao de texto sem lixo de 
		je espera_op					;ignora comando caso no limite
		
		cmp flagDown, 1				
		je espera_op					;caso flag de fim do arquivo na mesma direcao ligada, ignora comando
		
		cmp flagUp, 1
		je desliga_flag_up				;caso flag de fim do arquivo na direcao oposta ligaga, a desliga e continua
		
continua_desce_tela:
		inc linhaInicial				;incrementa variavel que indica a linha por onde comecar a exibicao na tela
		
		mov ax, linhaInicial
		call imprime_a_partir_de		;chama funcao para exibir na tela as linhas a partir da indicada por ax
	
		jmp espera_op					;retorna para espera por uma escolha do usuario de opcao

desliga_flag_up:
		mov flagUp, 0
		jmp continua_desce_tela			;desliga flag de fim do arquivo quando direcao oposta eh escolhida pelo usuario

imprime_a_partir_de:
;recebe em AX a partir de qual linha que deve imprimir
		mov si, offset quebrado

		mov linhasEncontradas, 0
	
		mov bh, 0
		mov dh, 1
		mov dl, 0
		mov ah, 2
		int 10h							;move o cursor para inicio da linha 1
		
		lea dx, limpaEspacoTexto
		mov ah, 9
		int 21h							;limpa tela para evitar lixo
	
procura_inicio:
		lodsb							;carrega char para ser testado
		
		mov bx, linhaInicial
		cmp bx, linhasEncontradas		;testa se jah chegou na enesima mensagem, indicada na chamada da funcao
		je imprime_texto				;quando ocorre, imprime as linhas a partir da indicada
		
		cmp al, '$'						;testa se encontrou o final da string
		jne procura_inicio				;enquanto nao ocorre, continua procura
		inc linhasEncontradas			;incrementa numero de linhas encontradas quando acha o $
		
		jmp procura_inicio				;retoma loop para procurar o inicio da mensagem a ser exibida na tela
				
imprime_texto:
		mov di, offset impressao		;aponta di pra endereco incial da string temporaria de impressao
		dec si							;volta uma posicao do si para apontar para o inicio correto da string de origem
		mov linhaAtual, 1				;inicializa contador de linhas com 1 para comecar a imprimir na segunda linha do visor, pulando o cabecalho
		
		mov bh, 0
		mov dh, 1
		mov dl, 0
		mov ah, 2
		int 10h							;move o cursor para inicio da linha 1	
		
procura_fim:
		lodsb							;carrega char para ser testado
		
		cmp al, '$'
		je imprime_linha				;testa se encontrou o delimitador de string
		
		cmp al, 0
		je flag_op						;testa se encontrou o final da mensagem para ativar a flag e impedir que imprima lixo de memoria
		
		stosb							;armazena na string temporaria de impressao enquanto nao acha o fim da string
		
		jmp procura_fim					;retoma loop de procura pelo fim da string
		
imprime_linha:
		mov al, '$'						
		stosb							;armazena no destino o delimitador da string a ser printada
		
		mov bh, 0			
		mov dh, linhaAtual
		mov dl, 0
		mov ah, 2
		int 10h							;posiciona o cursor na linha indicada pela variavel linhaAtual
		
		lea dx, impressao
		mov ah, 9
		int 21h							;imprime linha
		
		cmp linhaAtual, 23
		je fim_imprime_linhas_a_partir_de;testa se imprimiu a ultima linha que cabe no visor
		
		inc linhaAtual					;se nao, incrementa contador de linhas
		mov di, offset impressao		;reinicia ponteiro da string temporaria
		jmp procura_fim					;e retoma loop de impressao

fim_imprime_linhas_a_partir_de:
		mov bh, 0						;pagina
		mov dh, 24						;ultima linha
		mov dl, 0						;coluna
		mov ah, 2
		int 10h
	
		lea dx, msgOpcoes
		mov ah, 9
		int 21h							;imprime linha com opcoes do usuario

		ret								;retorno da funcao

flag_op:								;testa opcao que foi selecionada que levou o programa a alcancar o fim da mensagem e liga a flag para essa direcao
		cmp op, 'w'
		je flag_up						
		
		cmp op, 'W'
		je flag_up
		
		cmp op, 's'
		je flag_down
		
		cmp op, 'S'
		je flag_down
	
flag_up:
	mov flagUp, 1						;liga flag para subir a tela quando a ultima vez que essa opcao foi selecionada fez chegar ao fim da mensagem
	jmp fim_imprime_linhas_a_partir_de
	
flag_down:
	mov flagDown, 1						;liga flag para descer a tela quando a ultima vez que essa opcao foi selecionada fez chegar ao fim da mensagem
	jmp fim_imprime_linhas_a_partir_de
	
	
espera_op_aux:
	jmp espera_op						;retorna para selecao da opcao pelo usuario
		
; retorno ao DOS com codigo de retorno 0 no AL (fim normal)
fim:
		mov bh, 0
		mov dh, 0
		mov dl, 0
		mov ah, 2
		int 10h									;posiciona cursor no inicio da primeira linha
		
		mov dx, offset linhaBranca
		mov ah, 9
		int 21h									;insere linha em branco para limpar pedido de escolha de arquivo

		mov linhaAtual, 6						;inicializa contador da linha atual com 6, por onde deve comecar a impressao da mensagemd e fim
		mov di, offset msgFim1					;aponta di para endereco da primeira mensagem final

mensagem_fim:		
		mov bh, 0
		mov dh, linhaAtual
		mov dl, 10								;coluna 10, para centralizar a mensagem
		mov ah, 2
		int 10h									;posiciona cursor na linha indicada pela variavle linhaAtual, que eh incrementada a cada iteracao
		
		mov dx, di
		mov ah, 9
		int 21h									;imprime parte da mensagem final
		
		inc linhaAtual							;incrementa indicador da linha atual
		add di, 61								;adiciona 61 ao di para apontar para a proxima mensagem a ser exibida (60 caracteres por mensagem + $)
		
		cmp linhaAtual, 17
		je continua_fim							;testa se chegou na ultima mensagem (6 inicial + 11 mensagens)
		
		jmp mensagem_fim						;retoma loop de insercao da mensagem na tela
		
continua_fim:
		mov bh, 0
		mov dh, 24
		mov dl, 0
		mov ah, 2
		int 10h									;posiciona o cursor no inico da ultima linha para retorno ao dos

        mov    ax, 4c00h           				;funcao retornar ao DOS no AH
        int    21h                				;chamada do DOS

codigo   ends

; a diretiva a seguir indica o fim do codigo fonte (ultima linha do arquivo)
; e informa que o programa deve começar a execucao no rotulo "inicio"
         end    inicio 