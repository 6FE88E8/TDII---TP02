;*****************************************************************
;       Técnicas Digitales II - Trabajo Práctico N2
;       Actividad: Simulación del 8085 - Ordenamiento de datos
;       FERRER, Ezequiel
;*****************************************************************
; Requiere (simulacion):
;   - Teclado en puerto 10h

;*****************************************************************
;       Definición de Etiquetas
;*****************************************************************
.define
	BootAddr	0000h
	StackAddr   FFFFh
	DataROM		4000h
    
    Teclado     10h    ; Puerto teclado

    Tecl1       31h    ; Valores numericos ASCII del teclado
    Tecl2       32h
    Tecl3       33h
    Tecl4       34h
    Tecl5       35h
    Tecl6       36h

;*****************************************************************
;       Datos en ROM
;*****************************************************************
.data       DataROM
    DatoN:  dB	11h, 22h, 00h, 55h, 77h, 99h, 22h, 66h;, 88h, 33h
    ;DatoN:  dB	0Bh, 16h, 00h, 37h, 4Dh, 63h, 16h, 42h, 58h, 21h

;*****************************************************************
;       Arranque del 8085
;*****************************************************************
.org        BootAddr
    JMP     Boot

;*****************************************************************
;       PROGRAMA PRINCIPAL
;*****************************************************************
Boot:
	LXI     SP, StackAddr

Main:
    CALL    Ordenar

	HLT

;*****************************************************************
;       FUNCION Ordenar
;*****************************************************************
; Ordenamiento electronico. r:  A -> dato principal
;                           r:  B -> auxiliar p/ intercambio
;                           r:  C -> contador
;                           rp: H -> adrr de dato a comparar
Ordenar:
    MVI     C, 08h          ; cant elementos
    LXI     H, DatoN        ; inicializo vactor

OrdFor:
    MOV     A, M            ; tomo 1er elemento
    INX     H               ; incremento adrr mem
    CMP     M               ; comparo con mem
    JNC     OrdAltr         ; IF (A) <= (M) , ta bien ->JMP

    DCR     C
    JNZ     OrdFor          ; elemento ordenado
    RET

OrdAltr:
    MOV     B, M            ; ELSE intercambio
    DCX     H               ; out status:
    MOV     M, B            ;  . A <- May   B <- Men
    INX     H               ;  . M (May)
    MOV     M, A            ;  . M-1 (Men)

    MOV     A, L            ; cargo posicion comparada
    CPI     00h             ; comparo lo 2 primeros?
    JNC     OrdFor          ; SI-> salto
    
    DCX     H               ; NO-> debo comprobar con M-1
    DCX     H               ; 2 xq fue incrementado
    JNZ     OrdFor

    HLT