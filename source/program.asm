;***** Definicoes do Compilador **********************************************
.basic
.bios

;***** Definicoes dos MSX ****************************************************
;***** Variaveis do Sistema **************************************************
USRTAB  equ 0F39Ah                      ;Tabela de DEF USR 0~9
FACLO   equ 0F7F8h                      ;Endereco Passagem Parametros USR
FORCLR  equ 0F3E9h                      ;Foreground color
BAKCLR  equ 0F3EAh                      ;Background color
BDRCLR  equ 0F3EBh                      ;Border color
LINL32  equ 0F3AFh                      ;Width da SCREEN 1
;***** Definicoes do Programa ************************************************




;***** Rotinas principais do programa ****************************************


;***** Rotina de Entrada *****************************************************
        ORG 0C000h
;***** Area de Rascunho usada entre BASIC e ASM, tem que estar '0' no carga
POSX: db 0                      ;Usada para marcar o X da tela/bloco
POSY: db 0                      ;Usada para marcar o Y da tela/bloco
WIDT: db 0                      ;Usada para marcar LARGURA da tela/bloco
HEIG: db 0                      ;Usada para marcar ALTURA da tela/bloco
CHAR: db 0                      ;Usada para marcar o CARACTER da tela/bloco
SLEN: db 0                      ;Usada temporariamente para guardar tamanho STR
MAIN:
        ld hl,POSX
        ld a,ALFABETO%256
        ld [hl],a
        ld hl,POSY
        ld a,ALFABETO/256
        ld [hl],a

        ld hl,CHOICE            ;Programa a USR0 na execucao
        ld [USRTAB],hl          ; DEFUSR0
        ld hl,NPRIN             ;Programa a USR1 na execucao
        ld [USRTAB+2],hl        ; DEFUSR1
        ld hl,IPRIN             ;Programa a USR2 na execucao
        ld [USRTAB+4],hl        ; DEFUSR2
        ld hl,WINDS             ;Programa a USR3 na execucao
        ld [USRTAB+6],hl        ;DEFUSR3
        ret
;***** Escolhe Rotinas pelo parametro USR(x)**********************************
CHOICE:
        ld a,[FACLO]            ;A USR0 so aceita inteiro como parametro
        cp 0                    ;Modo SCREEN 1 mix SCREEN 2
        jp z,SCRNIV
        cp 1                    ;SubFuncao prepara alfabeto na VRAM
        jp z,CPALPH
        cp 2                    ;SubFuncao 'Desktop' preenche tela com character
        jp z,DSKTOP
        cp 3                    ;SubFuncao troca as cores do alfabeto
        jp z,COLORS
        cp 4                    ;SubFuncao preenche bloco tela/char
        jp z,FBLOK
        cp 5                    ;SubFuncao salva tela na RAM
        jp z,SVSCR
        cp 6                    ;SubFuncao carrega tela da RAM
        jp z,LDSRC
        ret

SCRNIV:
        ld a,7                  ;Ciano na cor de frente
        ld [FORCLR],a
        ld a,1                  ;Preto na cor de fundo
        ld [BAKCLR],a
        ld a,1                  ;Pretoo na cor de borda
        ld [BDRCLR],a
        call INIGRP             ;Prepara tabelas da SCREEN 2
        ld a,20h                ;WIDTH 32 na SCREEN 1
        ld [LINL32],a
        call INIT32             ;Prepara tabelas da SCREEN 1
        call ERAFNK             ;Esconde as telcas de funcao do display
        call SETGRP             ;Coloca apenas o VDP em SCREEN 2
        ret

;***** Copia Alfabeto em CC00 para VRAM **************************************
CPALPH:
        ld hl,ALFABETO          ;Fontes foram carregadas em CC00 (Graphos III)
        ld de,0h                ;Area de Formacao de caracteres da SCREEN 2
        ld bc,800h              ;2048 bytes (255 caracteres x 8 bytes)
        call LDIRVM             ;Transfere primeiro bloco
        ld hl,ALFABETO
        ld de,800h
        ld bc,800h
        call LDIRVM             ;Transfere segundo bloco
        ld hl,ALFABETO
        ld de,1000h
        ld bc,800h
        call LDIRVM             ;Transfere terceiro bloco
        ld hl,0FF8h             ;Area do cursor 2 bloco
        ld bc,7
        ld a,255                ;Simulacao de cursor
        call FILVRM
        ld hl,17F8h             ;Area do cursor 3 bloco
        ld bc,7
        ld a,255
        call FILVRM
        ld hl,2000h             ;Area de cores da SCREEN 2
        ld bc,177Fh             ; tamanho da area
        ld a,45h                ;(frente)8->vermelho, (fundo)1->preto
        call FILVRM
        ret

;***** Desktop ***************************************************************
DSKTOP:
        ld a,[CHAR]             ;Caracter de preenchimento (em geral 0)
        ld hl,1820h             ;Inicio da area de nomes (6144 + 32 segunda linha)
        ld bc,2C0h              ;Preenche toda a tela exceto primeira e segunda linha
        call FILVRM
        ld hl,1800h             ;Cabecalo 32 caracteres do fim da tabela na linha 0
        ld a,0E0h               ;Inicio da tabela de caracteres
        ld b,31                 ;32 reservados para titulo
.loop:
        push af                 ;Slava registradores afetados
        call WRTVRM             ;Escreve na VRAM
        pop af                  ;Recupera registradores afetados
        inc a                   ;Proximo Caractere da tabela
        inc hl                  ;Proxima posicao da tela
        djnz .loop              ;loop 32x
        ret

;***** Define a colorizacao dos caracteres ***********************************
COLORS:
        ; ***** Blocos iniciais (decoracoes)
        ld b,16                 ;Caracteres do 0 ao 15 do 1/3 da tela
        ld de, 2000h            ; inicio da area de cores SCREEN IV
        ld hl, CDECO            ; degrade azul
        call CHGBLK             ; muda cores

        ld b,16                 ;Caracteres do 0 ao 15 do 2/3 da tela
        ld de, 2800h            ; inicio da area de cores SCREEN IV
        ld hl, CDECO            ; degrade azul
        call CHGBLK             ; muda cores

        ld b,16                 ;Caracteres do 0 ao 15 do 3/3 da tela
        ld de, 3000h            ; inicio da area de cores SCREEN IV
        ld hl, CDECO            ; degrade azul
        call CHGBLK             ; muda cores

        ; ***** Blocos iniciais (janelas, quadros)
        ld b,16                 ;Caracteres do 16 ao 31 do 1/3 da tela
        ld de, 2080h            ; inicio da area de cores SCREEN IV
        ld hl, CWIND            ; degrade amarelo
        call CHGBLK             ; muda cores

        ld b,16                 ;Caracteres do 16 ao 31 do 2/3 da tela
        ld de, 2880h            ; inicio da area de cores SCREEN IV
        ld hl, CWIND            ; degrade amarelo
        call CHGBLK             ; muda cores

        ld b,16                 ;Caracteres do 16 ao 31 do 3/3 da tela
        ld de, 3080h            ; inicio da area de cores SCREEN IV
        ld hl, CWIND            ; degrade amarelo
        call CHGBLK             ; muda cores

        ; ***** Blocos finais (Revista CPU N. NN)
        ld b,32                 ;Caracteres do 224 ao 255 do 1/3 da tela
        ld de, 2700h            ; inicio da area de cores do caracter 224
        ld hl, CTITL            ; degrade vermelho
        call CHGBLK             ; muda cores

        ld b,32                 ;Caracteres do 224 ao 255 do 2/3 da tela
        ld de, 2F00h            ; inicio da area de cores do caracter 224
        ld hl, CTITL            ; degrade vermelho
        call CHGBLK             ; muda cores

        ld b,32                 ;Caracteres do 224 ao 255 do 3/3 da tela
        ld de, 3700h            ; inicio da area de cores do caracter 224
        ld hl, CTITL            ; degrade vermelho
        call CHGBLK             ; muda cores

        ; ***** Blocos A-Z/a-z Normais e Ivertidos
        ld b, 96                ;Caracteres de 32 a 127 1/3 da tela
        ld de, 2100h            ; inicio da area de cores do caracter 64
        ld hl, CCHAR            ; degrade verde
        call CHGBLK             ; muda cores
        ld b, 96                ;Caracteres de 128 a 223 1/3 da tela
        ld de, 2400h            ; inicio da area de cores do caracter 128
        ld hl, CICHR            ; degrade verde
        call CHGBLK             ; muda cores
        
        ld b, 96                ;Caracteres de 32 a 127 2/3 da tela
        ld de, 2900h            ; inicio da area de cores do caracter 64
        ld hl, CCHAR            ; degrade verde
        call CHGBLK             ; muda cores
        ld b, 96                ;Caracteres de 128 a 223 2/3 da tela
        ld de, 2C00h            ; inicio da area de cores do caracter 128
        ld hl, CICHR            ; degrade verde
        call CHGBLK             ; muda cores

        ld b, 96                ;Caracteres de 32 a 127 3/3 da tela
        ld de, 3100h            ; inicio da area de cores do caracter 64
        ld hl, CCHAR            ; degrade verde
        call CHGBLK             ; muda cores
        ld b, 96                ;Caracteres de 128 a 223 3/3 da tela
        ld de, 3400h            ; inicio da area de cores do caracter 128
        ld hl, CICHR            ; degrade verde
        call CHGBLK             ; muda cores
        ret

;***** Coloriza um bloco de caracteres no modo SCREEN IV *********************
CHGBLK:
        push bc                 ;Salva os registradores afetados
        push de
        push hl
        ld bc, 8h               ;8 linhas por caracter
        call LDIRVM             ; Transfere da RAM para VRAM
        pop hl                  ;Recupera parte dos registradores
        pop de
        ex de,hl                ;Soma 8 para o proximo caracter
        ld bc,0008h
        add hl,bc
        ex de,hl
        pop bc                  ;Recupera resto dos registradores
        djnz CHGBLK             ;Loop para o proximo caracter
        ret

;***** FBLOK *****************************************************************
; Funcao: Preenche um bloco da VRAM com um caractere especifico. O bloco
; nao e contiguo, pensado para criar janelas.
; Os agrumentos vem do BASIC e sao auto descritivos, basta dar POKE nos
; enderecos
FBLOK:
        call CALCXY
        ld a,[HEIG]             ;Altura do bloco
        ld b,a
.loop:
        push hl                 ;Salva registradores
        push bc
        ld a,[WIDT]             ;Largura do Bloco
        ld c,a
        ld b,0
        ld a,[CHAR]             ;Caracter de Preenchimento
        call FILVRM             ;Preenche o tamanho da largura do bloco
        pop bc                  ;Restaura registradores
        pop hl
        ld e,32                 ;Tamanho da tela (SCREEN IV)
        ld d,0
        add hl,de
        djnz .loop              ;Laco para cada linha
        ret

;***** SVSCR *****************************************************************
; Salva a tela corrente na RAM para auxiliar no tracado de pseudo janelas
SVSCR:
        ld bc,768               ;Tamanho da SCREEN IV
        ld de,SCRN              ;Destino na RAM
        ld hl,1800h             ;Inicio tabela de nomes
        call LDIRMV             ;Transfere
        ret
;***** LDSCR *****************************************************************
; Carrega tela da RAM na corrente para auxiliar no tracado de pseudo janelas
LDSRC:
        ld bc,768               ;Tamanho da SCREEN IV
        ld de,1800h             ;Inicio tabela de nomes
        ld hl,SCRN              ;Origem na RAM
        call LDIRVM             ;Transfere
        ret

;***** Rotina para impressao de String na Screen IV **************************
NPRIN:
        call LDSTR              ;Carrega a string de USR em STR
        call PTSTR              ;Chama rotina de impressao
        ret
;***** Inverte uma String e a imprime na Screen IV ***************************
IPRIN:
        call LDSTR              ;Carrega a string de USR em STR
        ld a,[SLEN]             ;Tamanho da STRING
        ld b,a                  ;Laco para inverter STRING
        ld hl,STR               ;Endereco da STRING
LIPRN:
        ld a,[hl]               ;Aponta para o caractere
        add a,96                ;Desloca para o invertido
        ld [hl],a               ;Troca o original
        inc hl                  ;proximo caracter
        djnz LIPRN              ;laco
        call PTSTR              ;Chama rotina de impressao
        ret

;***** Rotina para criar janelas na Screen IV ********************************
WINDS:
        call LDSTR              ;Carrega string do titulo
        call DRWIND             ;Desenha Janela
        ret


;***** Imprime uma string armazenada em RAM (STR) na SCREEN IV ***************
; POSY e passada via BASIC representa a linha da impressao
; POSX tambem passada via BASIC representa a coluna
; WIDT e calculada em outras rotinas que usam NPRIN e tem o tamanho da string
PTSTR:
        call CALCXY             ;Posiciona VRAM
        ex de,hl                ;Swap de registradores
        ld a,[WIDT]
        ld b,0
        ld c,a
        ld hl,STR
        call LDIRVM
        ret

;***** LDSTR ******************************************************************
; Carrega uma STRING passada por parametro em USR("") na memoria em STR
LDSTR:
        cp 3                    ;E String?
        ret nz                  ;nao, volta
        ex de,hl                ;HL descritor STRING
        ld b,[hl]               ;B tamanho
        ld a,b                  
        ld [SLEN],a             ;WIDTH tem tamnho da STRING
        inc hl
        ld e,[hl]               ;LSB Endereco
        inc hl
        ld d,[hl]               ;MSB DE String
        inc b
        ld hl,STR               ;Armazena localmente
.loop:
        dec b                   ;Final?
        ret z
        ld a,[de]               ;Armazena caractere
        ld [hl],a
        inc hl
        inc de
        jr .loop                ;Proximo caractere
        ret

DRWIND:
        ld hl,STR               ;Copia a string original deslocada de 1
        ld de,STR3              ; de STR para STR3
        inc de                  ;desloca
        ld bc,20h               ;32 caracteres
        ldir                    ;backup
        ld hl,STR3              ;Adiciona decoracao no inicio titulo
        ld [hl],12h

        ld a,[SLEN]             ;Adiciona decoracao no fim do titulo
        inc a
        ld e,a
        ld d,0
        add hl,de
        ld [hl],10h

        ld hl,STR2              ;Montagem da janela
        ld a,10h                ;Canto superior esquerdo
        ld [hl],a
        inc hl
        ld a,[WIDT]             ;Largura da Janela
        dec a
        dec a
        ld b,a
.loop:                          ;Completa largura da janela
        ld [hl],11h             ;Barra superior
        inc hl
        djnz .loop              ;laco
        ld [hl],12h             ;Canto superior direito
        ld hl,STR2              ;Transfere a STRING decorada
        ld de,STR               ;Para a area principal
        ld bc,20h               ; 32 caracteres
        ldir
        call PTSTR              ;Imprime a String

        call CALCXY             ;Recalcula VRAM
        ld a,[HEIG]
        dec a
        dec a
        ld b,a
.loop2:
        push bc
        ld d,0
        ld e,20h
        add hl,de
        push hl
        ld a,13h
        call WRTVRM
        ld a,[WIDT]
        dec a
        ld d,0
        ld e,a
        add hl,de
        ld a,14h
        call WRTVRM
        pop hl
        pop bc
        djnz .loop2

        ld b,20h
        ld a,20h
.loop3:
        ld hl,STR2
        ld [hl],a
        inc hl
        djnz .loop3

        ld hl,STR2              ;Montagem da janela
        ld a,15h                ;Canto superior esquerdo
        ld [hl],a
        inc hl
        ld a,[WIDT]             ;Largura da Janela
        dec a
        dec a
        ld b,a
.loop4:                         ;Completa largura da janela
        ld [hl],16h             ;Barra superior
        inc hl
        djnz .loop4             ;laco
        ld [hl],17h             ;Canto superior direito
        ld hl,STR2              ;Transfere a STRING decorada
        ld de,STR               ;Para a area principal
        ld bc,20h               ; 32 caracteres
        ldir

        ld a,[POSY]
        ld [CHAR],a
        ld a,[POSY]
        ld h,0
        ld l,a
        ld a,[HEIG]
        ld d,0
        ld e,a
        dec hl
        add hl,de
        ld a,l
        ld [POSY],a

        call PTSTR              ;Imprime a String

        ld a,[POSX]
        inc a
        ld [POSX],a
        ld a,[CHAR]
        ld [POSY],a
        ld hl,STR3              ;Copia a string backup
        ld de,STR               ; de STR3 para STR
        ld bc,20h               ;32 caracteres
        ldir                    ;backup
        ld a,[SLEN]
        inc a
        inc a
        ld [WIDT],a
        call PTSTR

        ret

;***** Calcula o endereco da VRAM a partir de POSX e POSY ********************
CALCXY:
        ld a,[POSY]             ;Linha inicial
        ld h,a
        ld e,32                 ;WIDTH do programa (SCREENIV)
        call MULHXE
        ld a,[POSX]             ;Coluna inicial
        ld e,a
        ld d,0
        add hl,de
        ld de,1800h             ;Tabela de nomes (SCREEN IV)
        add hl,de
        ret

;***** MULHXE *****************************************************************
; Funcao: Multiplica H por E prioriza tamanho a velocidade
; Entrada: H e E operandos
; Saida: HL produto
;        D zero
;        A, E, B, C preservados
MULHXE:
        ld d,0
        ld l,d
        ld b,8
.loop:
        add hl,hl
        jr nc,$+3
        add hl,de
        djnz .loop
        ret

;***** Area de Dados do Programa *********************************************
;***** Cores do alfabeto SCRNIV usadas pelo programa *************************
; 0 -> Transparente             8 -> Vermelho medio
; 1 -> Preto                    9 -> Vermelho claro
; 2 -> Verde medio              A -> Amarelo escuro
; 3 -> Verde claro              B -> Amarelo claro
; 4 -> Azul escuro              C -> Verde escuro
; 5 -> Azul medio               D -> Roxo
; 6 -> Vermelho escuro          E -> Branco escuro
; 7 -> Azul claro               F -> Branco claro
;***** Cores do titulo *******************************************************
CTITL:
        db 061h, 061h, 061h, 081h, 081h, 081h, 091h, 091h
;***** Cor dos caracteres padrao *********************************************
CCHAR:
        db 0C1h, 0C1h, 0C1h, 021h, 021h, 021h, 031h, 031h
;***** Cor dos caracteres invertidos
CICHR:
        db 0CAh, 0CAh, 0CAh, 02Ah, 02Bh, 02Bh, 03Bh, 03Bh
;***** Cor dos caracreres de decoracao
CDECO:
        db 041h, 041h, 041h, 051h, 051h, 051h, 071h, 071h
;***** Cor dos caracteres das janelas
CWIND:
        db 0A1h, 0A1h, 0A1h, 0A1h, 0B1h, 0B1h, 0B1h, 0B1h
STR:
        ds 40
STR2:
        ds 40
STR3:
        ds 40
SCRN:
        ds 768
LSBMSB:
        dw 0
ALFABETO:
        
        db 0xAF,0xA8,0xFF,0x8A,0xFA,0x8A,0xFF,0xA8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0xFF,0xFF,0xC0,0xC0,0xC0,0xC0,0xC0,0xC0,0xFF,0xFF,0x00,0x00,0x00,0x00,0x00,0x00
        db 0xFF,0xFF,0x03,0x03,0x03,0x03,0x03,0x03,0xC0,0xC0,0xC0,0xC0,0xC0,0xC0,0xC0,0xC0
        db 0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0xC0,0xC0,0xC0,0xC0,0xC0,0xC0,0xFF,0xFF
        db 0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0xFF,0x03,0x03,0x03,0x03,0x03,0x03,0xFF,0xFF
        db 0xC0,0xC0,0xC0,0xFF,0xFF,0xC0,0xC0,0xC0,0x03,0x03,0x03,0xFF,0xFF,0x03,0x03,0x03
        db 0x18,0x18,0x18,0x18,0x18,0x18,0xFF,0xFF,0xFF,0xFF,0x18,0x18,0x18,0x18,0x18,0x18
        db 0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x00,0x00,0x00,0xFF,0xFF,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x18,0x18,0x18,0x00,0x18,0x00,0x00
        db 0x00,0x36,0x6C,0x00,0x00,0x00,0x00,0x00,0x00,0x6C,0xFE,0x6C,0xFE,0x6C,0x00,0x00
        db 0x10,0x7E,0xD0,0x7C,0x16,0xFC,0x10,0x00,0x00,0xCC,0x98,0x30,0x64,0xCC,0x00,0x00
        db 0x00,0x78,0xCC,0x78,0xCC,0x7C,0x00,0x00,0x00,0x18,0x30,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x18,0x30,0x30,0x30,0x18,0x00,0x00,0x00,0x18,0x0C,0x0C,0x0C,0x18,0x00,0x00
        db 0x00,0x54,0x38,0x7C,0x38,0x54,0x00,0x00,0x00,0x10,0x10,0x7C,0x10,0x10,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x30,0x60,0x00,0x00,0x00,0x00,0x7C,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x18,0x18,0x00,0x00,0x00,0x06,0x0C,0x18,0x30,0x60,0x00,0x00
        db 0x00,0xFE,0xC6,0xC6,0xC6,0xFE,0x00,0x00,0x00,0x78,0x18,0x18,0x18,0x7E,0x00,0x00
        db 0x00,0xFE,0x06,0xFE,0xC0,0xFE,0x00,0x00,0x00,0xFE,0x06,0xFE,0x06,0xFE,0x00,0x00
        db 0x00,0xC6,0xC6,0xFE,0x06,0x06,0x00,0x00,0x00,0xFE,0xC0,0xFE,0x06,0xFE,0x00,0x00
        db 0x00,0xFE,0xC0,0xFE,0xC6,0xFE,0x00,0x00,0x00,0xFE,0x06,0x06,0x06,0x06,0x00,0x00
        db 0x00,0xFE,0xC6,0xFE,0xC6,0xFE,0x00,0x00,0x00,0xFE,0xC6,0xFE,0x06,0x06,0x00,0x00
        db 0x00,0x18,0x18,0x00,0x18,0x18,0x00,0x00,0x00,0x18,0x18,0x00,0x00,0x18,0x30,0x00
        db 0x00,0x0C,0x18,0x30,0x18,0x0C,0x00,0x00,0x00,0x00,0x7C,0x00,0x7C,0x00,0x00,0x00
        db 0x00,0x30,0x18,0x0C,0x18,0x30,0x00,0x00,0x00,0x3C,0x66,0x0C,0x18,0x00,0x18,0x00
        db 0x00,0x7C,0xC6,0xDC,0xC0,0x7E,0x00,0x00,0x00,0x78,0xC6,0xFE,0xC6,0xC6,0x00,0x00
        db 0x00,0xFC,0xC6,0xFC,0xC6,0xFC,0x00,0x00,0x00,0x7C,0xC6,0xC0,0xC6,0x7C,0x00,0x00
        db 0x00,0xFC,0xC6,0xC6,0xC6,0xFC,0x00,0x00,0x00,0xFE,0xC0,0xF8,0xC0,0xFE,0x00,0x00
        db 0x00,0xFE,0xC0,0xF8,0xC0,0xC0,0x00,0x00,0x00,0xFE,0xC0,0xCE,0xC6,0xFE,0x00,0x00
        db 0x00,0xC6,0xC6,0xFE,0xC6,0xC6,0x00,0x00,0x00,0x7E,0x18,0x18,0x18,0x7E,0x00,0x00
        db 0x00,0x1E,0x06,0x06,0xC6,0xFE,0x00,0x00,0x00,0xCE,0xDC,0xF8,0xDC,0xCE,0x00,0x00
        db 0x00,0xC0,0xC0,0xC0,0xC0,0xFE,0x00,0x00,0x00,0xC6,0xEE,0xFE,0xD6,0xC6,0x00,0x00
        db 0x00,0xFE,0xC6,0xC6,0xC6,0xC6,0x00,0x00,0x00,0x7C,0xC6,0xC6,0xC6,0x7C,0x00,0x00
        db 0x00,0xFC,0xC6,0xFC,0xC0,0xC0,0x00,0x00,0x00,0x7C,0xC6,0xC6,0xCE,0x7E,0x00,0x00
        db 0x00,0xFC,0xC6,0xFC,0xC6,0xC6,0x00,0x00,0x00,0x7E,0xE0,0x7C,0x0E,0xFC,0x00,0x00
        db 0x00,0xFC,0x30,0x30,0x30,0x30,0x00,0x00,0x00,0xC6,0xC6,0xC6,0xC6,0x7C,0x00,0x00
        db 0x00,0xC6,0xC6,0x6C,0x38,0x10,0x00,0x00,0x00,0xC6,0xD6,0xFE,0xEE,0xC6,0x00,0x00
        db 0x00,0xC6,0x6C,0x38,0x6C,0xC6,0x00,0x00,0x00,0xCC,0xCC,0xFC,0x30,0x30,0x00,0x00
        db 0x00,0xFE,0x1C,0x38,0x70,0xFE,0x00,0x00,0x00,0x3C,0x30,0x30,0x30,0x3C,0x00,0x00
        db 0x00,0x60,0x30,0x18,0x0C,0x06,0x00,0x00,0x00,0x3C,0x0C,0x0C,0x0C,0x3C,0x00,0x00
        db 0x00,0x00,0x10,0x28,0x48,0x28,0x18,0x00,0x00,0x00,0x00,0x00,0x00,0x7C,0x00,0x00
        db 0x00,0x18,0x0C,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7C,0x06,0xFE,0x7E,0x00,0x00
        db 0x00,0xC0,0xFC,0xC6,0xC6,0xFC,0x00,0x00,0x00,0x00,0x7E,0xC0,0xC0,0x7E,0x00,0x00
        db 0x00,0x06,0x7E,0xC6,0xC6,0x7E,0x00,0x00,0x00,0x00,0x7C,0xFE,0xC0,0x7C,0x00,0x00
        db 0x00,0x3E,0x30,0xFE,0x30,0x30,0x00,0x00,0x00,0x00,0x7E,0xC6,0xC6,0x7E,0x06,0xFC
        db 0x00,0xC0,0xFC,0xC6,0xC6,0xC6,0x00,0x00,0x00,0x18,0x38,0x18,0x18,0x3C,0x00,0x00
        db 0x00,0x06,0x06,0x06,0xC6,0xFE,0x00,0x00,0x00,0xC0,0xCC,0xF8,0xCC,0xC6,0x00,0x00
        db 0x00,0x70,0x30,0x30,0x30,0x3C,0x00,0x00,0x00,0x00,0xEE,0xFE,0xD6,0xC6,0x00,0x00
        db 0x00,0x00,0xFE,0xC6,0xC6,0xC6,0x00,0x00,0x00,0x00,0x7C,0xC6,0xC6,0x7C,0x00,0x00
        db 0x00,0x00,0xFC,0xC6,0xC6,0xFC,0xC0,0xC0,0x00,0x00,0x7E,0xC6,0xC6,0x7E,0x06,0x06
        db 0x00,0x00,0x7E,0x66,0x60,0x60,0x00,0x00,0x00,0x00,0xFE,0xF0,0x0E,0xFE,0x00,0x00
        db 0x00,0x30,0xFC,0x30,0x30,0x3E,0x00,0x00,0x00,0x00,0xC6,0xC6,0xC6,0xFE,0x00,0x00
        db 0x00,0x00,0xC6,0xEE,0x7C,0x38,0x00,0x00,0x00,0x00,0xC6,0xD6,0xFE,0xEE,0x00,0x00
        db 0x00,0x00,0xEE,0x7C,0x7C,0xEE,0x00,0x00,0x00,0x00,0xC6,0xC6,0xC6,0x7E,0x06,0xFC
        db 0x00,0x00,0xFE,0x0E,0xF0,0xFE,0x00,0x00,0x00,0x18,0x30,0x18,0x30,0x18,0x00,0x00
        db 0x00,0x18,0x18,0x18,0x18,0x18,0x00,0x00,0x00,0x30,0x18,0x30,0x18,0x30,0x00,0x00
        db 0x00,0x76,0xDC,0x00,0x00,0x00,0x00,0x00,0x00,0x10,0x38,0x00,0x00,0x00,0x00,0x00
        db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xE7,0xE7,0xE7,0xFF,0xE7,0xFF,0xFF
        db 0xFF,0xC9,0x93,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x93,0x01,0x93,0x01,0x93,0xFF,0xFF
        db 0xEF,0x81,0x2F,0x83,0xE9,0x03,0xEF,0xFF,0xFF,0x33,0x67,0xCF,0x9B,0x33,0xFF,0xFF
        db 0xFF,0x87,0x33,0x87,0x33,0x83,0xFF,0xFF,0xFF,0xE7,0xCF,0xFF,0xFF,0xFF,0xFF,0xFF
        db 0xFF,0xE7,0xCF,0xCF,0xCF,0xE7,0xFF,0xFF,0xFF,0xE7,0xF3,0xF3,0xF3,0xE7,0xFF,0xFF
        db 0xFF,0xAB,0xC7,0x83,0xC7,0xAB,0xFF,0xFF,0xFF,0xEF,0xEF,0x83,0xEF,0xEF,0xFF,0xFF
        db 0xFF,0xFF,0xFF,0xFF,0xFF,0xCF,0x9F,0xFF,0xFF,0xFF,0xFF,0x83,0xFF,0xFF,0xFF,0xFF
        db 0xFF,0xFF,0xFF,0xFF,0xE7,0xE7,0xFF,0xFF,0xFF,0xF9,0xF3,0xE7,0xCF,0x9F,0xFF,0xFF
        db 0xFF,0x01,0x39,0x39,0x39,0x01,0xFF,0xFF,0xFF,0x87,0xE7,0xE7,0xE7,0x81,0xFF,0xFF
        db 0xFF,0x01,0xF9,0x01,0x3F,0x01,0xFF,0xFF,0xFF,0x01,0xF9,0x01,0xF9,0x01,0xFF,0xFF
        db 0xFF,0x39,0x39,0x01,0xF9,0xF9,0xFF,0xFF,0xFF,0x01,0x3F,0x01,0xF9,0x01,0xFF,0xFF
        db 0xFF,0x01,0x3F,0x01,0x39,0x01,0xFF,0xFF,0xFF,0x01,0xF9,0xF9,0xF9,0xF9,0xFF,0xFF
        db 0xFF,0x01,0x39,0x01,0x39,0x01,0xFF,0xFF,0xFF,0x01,0x39,0x01,0xF9,0xF9,0xFF,0xFF
        db 0xFF,0xE7,0xE7,0xFF,0xE7,0xE7,0xFF,0xFF,0xFF,0xE7,0xE7,0xFF,0xFF,0xE7,0xCF,0xFF
        db 0xFF,0xF3,0xE7,0xCF,0xE7,0xF3,0xFF,0xFF,0xFF,0xFF,0x83,0xFF,0x83,0xFF,0xFF,0xFF
        db 0xFF,0xCF,0xE7,0xF3,0xE7,0xCF,0xFF,0xFF,0xFF,0xC3,0x99,0xF3,0xE7,0xFF,0xE7,0xFF
        db 0xFF,0x83,0x39,0x23,0x3F,0x81,0xFF,0xFF,0xFF,0x87,0x39,0x01,0x39,0x39,0xFF,0xFF
        db 0xFF,0x03,0x39,0x03,0x39,0x03,0xFF,0xFF,0xFF,0x83,0x39,0x3F,0x39,0x83,0xFF,0xFF
        db 0xFF,0x03,0x39,0x39,0x39,0x03,0xFF,0xFF,0xFF,0x01,0x3F,0x07,0x3F,0x01,0xFF,0xFF
        db 0xFF,0x01,0x3F,0x07,0x3F,0x3F,0xFF,0xFF,0xFF,0x01,0x3F,0x31,0x39,0x01,0xFF,0xFF
        db 0xFF,0x39,0x39,0x01,0x39,0x39,0xFF,0xFF,0xFF,0x81,0xE7,0xE7,0xE7,0x81,0xFF,0xFF
        db 0xFF,0xE1,0xF9,0xF9,0x39,0x01,0xFF,0xFF,0xFF,0x31,0x23,0x07,0x23,0x31,0xFF,0xFF
        db 0xFF,0x3F,0x3F,0x3F,0x3F,0x01,0xFF,0xFF,0xFF,0x39,0x11,0x01,0x29,0x39,0xFF,0xFF
        db 0xFF,0x01,0x39,0x39,0x39,0x39,0xFF,0xFF,0xFF,0x83,0x39,0x39,0x39,0x83,0xFF,0xFF
        db 0xFF,0x03,0x39,0x03,0x3F,0x3F,0xFF,0xFF,0xFF,0x83,0x39,0x39,0x31,0x81,0xFF,0xFF
        db 0xFF,0x03,0x39,0x03,0x39,0x39,0xFF,0xFF,0xFF,0x81,0x1F,0x83,0xF1,0x03,0xFF,0xFF
        db 0xFF,0x03,0xCF,0xCF,0xCF,0xCF,0xFF,0xFF,0xFF,0x39,0x39,0x39,0x39,0x83,0xFF,0xFF
        db 0xFF,0x39,0x39,0x93,0xC7,0xEF,0xFF,0xFF,0xFF,0x39,0x29,0x01,0x11,0x39,0xFF,0xFF
        db 0xFF,0x39,0x93,0xC7,0x93,0x39,0xFF,0xFF,0xFF,0x33,0x33,0x03,0xCF,0xCF,0xFF,0xFF
        db 0xFF,0x01,0xE3,0xC7,0x8F,0x01,0xFF,0xFF,0xFF,0xC3,0xCF,0xCF,0xCF,0xC3,0xFF,0xFF
        db 0xFF,0x9F,0xCF,0xE7,0xF3,0xF9,0xFF,0xFF,0xFF,0xC3,0xF3,0xF3,0xF3,0xC3,0xFF,0xFF
        db 0xFF,0xFF,0xEF,0xD7,0xB7,0xD7,0xE7,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x83,0xFF,0xFF
        db 0xFF,0xE7,0xF3,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0x83,0xF9,0x01,0x81,0xFF,0xFF
        db 0xFF,0x3F,0x03,0x39,0x39,0x03,0xFF,0xFF,0xFF,0xFF,0x81,0x3F,0x3F,0x81,0xFF,0xFF
        db 0xFF,0xF9,0x81,0x39,0x39,0x81,0xFF,0xFF,0xFF,0xFF,0x83,0x01,0x3F,0x83,0xFF,0xFF
        db 0xFF,0xC1,0xCF,0x01,0xCF,0xCF,0xFF,0xFF,0xFF,0xFF,0x81,0x39,0x39,0x81,0xF9,0x03
        db 0xFF,0x3F,0x03,0x39,0x39,0x39,0xFF,0xFF,0xFF,0xE7,0xC7,0xE7,0xE7,0xC3,0xFF,0xFF
        db 0xFF,0xF9,0xF9,0xF9,0x39,0x01,0xFF,0xFF,0xFF,0x3F,0x33,0x07,0x33,0x39,0xFF,0xFF
        db 0xFF,0x8F,0xCF,0xCF,0xCF,0xC3,0xFF,0xFF,0xFF,0xFF,0x11,0x01,0x29,0x39,0xFF,0xFF
        db 0xFF,0xFF,0x01,0x39,0x39,0x39,0xFF,0xFF,0xFF,0xFF,0x83,0x39,0x39,0x83,0xFF,0xFF
        db 0xFF,0xFF,0x03,0x39,0x39,0x03,0x3F,0x3F,0xFF,0xFF,0x81,0x39,0x39,0x81,0xF9,0xF9
        db 0xFF,0xFF,0x81,0x99,0x9F,0x9F,0xFF,0xFF,0xFF,0xFF,0x01,0x0F,0xF1,0x01,0xFF,0xFF
        db 0xFF,0xCF,0x03,0xCF,0xCF,0xC1,0xFF,0xFF,0xFF,0xFF,0x39,0x39,0x39,0x01,0xFF,0xFF
        db 0xFF,0xFF,0x39,0x11,0x83,0xC7,0xFF,0xFF,0xFF,0xFF,0x39,0x29,0x01,0x11,0xFF,0xFF
        db 0xFF,0xFF,0x11,0x83,0x83,0x11,0xFF,0xFF,0xFF,0xFF,0x39,0x39,0x39,0x81,0xF9,0x03
        db 0xFF,0xFF,0x01,0xF1,0x0F,0x01,0xFF,0xFF,0xFF,0xE7,0xCF,0xE7,0xCF,0xE7,0xFF,0xFF
        db 0xFF,0xE7,0xE7,0xE7,0xE7,0xE7,0xFF,0xFF,0xFF,0xCF,0xE7,0xCF,0xE7,0xCF,0xFF,0xFF
        db 0xFF,0x89,0x23,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xEF,0xC7,0xFF,0xFF,0xFF,0xFF,0xFF
        db 0x7C,0x7E,0x0E,0x7E,0x7C,0x0E,0x0E,0x0E,0xFE,0xFE,0x00,0xFE,0xFE,0xE0,0xFE,0xFE
        db 0xE6,0xE6,0xE6,0x7C,0x7C,0x7C,0x38,0x38,0xFE,0xFE,0x00,0x38,0x38,0x38,0xFE,0xFE
        db 0x70,0x70,0x78,0x7C,0x3E,0x0E,0xFE,0xFC,0xFE,0xFE,0x00,0xE0,0xE0,0xE0,0xFE,0x7E
        db 0xF8,0xFC,0x1E,0xCE,0xEE,0xEE,0xCE,0xCE,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x3E,0x7E,0xFE,0xE0,0xE0,0xFE,0x7E,0x3E,0xFC,0xFE,0x0E,0xFE,0xFC,0xE0,0xE0,0xE0
        db 0xCE,0xCE,0xCE,0xCE,0xCE,0xCE,0xFE,0x7E,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0xFC,0xFE,0xCE,0xCE,0xCE,0xCE,0xCE,0xCE,0x60,0xF0,0x90,0xF0,0x60,0x00,0x00,0x00
        db 0x7C,0xFE,0xC6,0xC6,0xC6,0xC6,0xFE,0x7C,0x1C,0x3C,0x3C,0x1C,0x1C,0x1C,0x1C,0x1C
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00