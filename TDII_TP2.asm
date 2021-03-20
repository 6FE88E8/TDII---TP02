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
	BootAddr        0000h
	StackAddr       FFFFh
	DataROM         4100h
    DataRAM         5100h

	AddrIntRST1		0008h
	AddrIntRST2		0010h
	AddrIntRST3		0018h
	AddrIntRST4		0020h
	AddrIntTRAP		0024h
	AddrIntRST5		0028h
	AddrIntRST55	002Ch
	AddrIntRST6		0030h
	AddrIntRST65	0034h
	AddrIntRST7		0038h
	AddrIntRST75	003Ch
    
    Teclado     10h    ; Puerto teclado
    Tecl1       31h    ; Valores numericos ASCII del teclado
    Tecl2       32h
    Tecl3       33h
    Tecl4       34h
    Tecl5       35h
    Tecl6       36h

    CantD       10      ; elementos del vector

;*****************************************************************
;       Datos en ROM
;*****************************************************************
.data       DataROM
    DatoNum:    dB 0h, 0h, 0h, 0h, 0h, 0h, 0h, 0h, 0h, 0h
    ;DatoNum:    dB 4h, 8h, 5h, 2h, 0h, 3h, 2h, 9h, 3h, 7h
    ;DatoNum:    dB	5Ch, D8h, 35h, 2Fh, 90h, 38h, A7h, B9h, 33h, A7h

;*****************************************************************
;       Datos en RAM
;*****************************************************************
.data       DataRAM
    DatoAux:    dB  0h, 0h, 0h, 0h, 0h, 0h, 0h, 0h, 0h, 0h
    CantPar:    dB  0h
    CritOrden:  dB  0h
    DatoTecl:   dB  0h

;*****************************************************************
;       Arranque del 8085
;*****************************************************************
.org        BootAddr
    JMP     Boot

;*****************************************************************
;       Vector de INTR
;*****************************************************************
.org        AddrIntRST1
    JMP	IntRST1
.org        AddrIntRST2
    JMP	IntRST2
.org    	AddrIntRST3
    JMP	IntRST3
.org    	AddrIntRST4
    JMP	IntRST4
.org    	AddrIntTRAP
    JMP	IntTRAP
.org    	AddrIntRST5
    JMP	IntRST5
.org    	AddrIntRST55
    JMP	IntRST55
.org    	AddrIntRST6
    JMP	IntRST6
.org        AddrIntRST65
    JMP	IntRST65
.org    	AddrIntRST7
    JMP	IntRST7
.org    	AddrIntRST75
    JMP	IntRST75

;*****************************************************************
;       Definiciones de INTR
;*****************************************************************
IntRST1:
    RET
IntRST2:
    RET
IntRST3:
    RET
IntRST4:
    RET
IntTRAP:
    RET
IntRST5:
    RET
IntRST55:
    RET
IntRST6:
    RET

IntRST65:
    PUSH	PSW
    
    POP     PSW
	EI
	RET

IntRST7:
    RET
IntRST75:
    RET

;*****************************************************************
;       PROGRAMA PRINCIPAL
;*****************************************************************
Boot:
	LXI     SP, StackAddr

    LXI     H, DatoNum
    MVI     B, CantD
MainI:
    IN      Teclado
    
    CPI     00h     ;  Valor nuevo identico o NULL no es
    JZ      MainI   ; recibido para evitar el conteo
    CMP     E       ; sucesivo del dato durante
    JZ      MainI   ; el pulso (mejorar con interupcion?)
    MOV     E, A
    STA     DatoTecl
    MVI     A, 00h
    
    CALL    ProcesaTecl
    DCR     B
    JNZ     MainI
;---------------------------
MainII:
    IN      Teclado
    STA     CritOrden

    CALL    ComoOrdeno

    JMP     MainII
;---------------------------
	HLT

;*****************************************************************
;       FUNCION ProcesaTecl
;*****************************************************************
ProcesaTecl:
	LDA	    DatoTecl       ; A<- tecla
	
	CPI	    '0'            ; comparo con 0
	JZ      valid          ; es cero? sigo comparando
    CPI 	'1'            ; comparo con 1
	JZ    	valid          ; es uno?.....
	CPI    	'2'
	JZ    	valid
	CPI    	'3'
	JZ    	valid
	CPI    	'4'
	JZ    	valid
	CPI    	'5'
	JZ    	valid
	CPI     '6'
	JZ    	valid
	CPI    	'7'
	JZ    	valid
	CPI    	'8'
	JZ    	valid
	CPI    	'9'
	JZ    	valid          ; ...no es valido?

	JMP	    NoDato         ; se tira
valid:
	CALL	GuardarDato    ; al array
NoDato:
	RET
;---------------------------
    HLT

;*****************************************************************
;       FUNCION GuardarDato
;*****************************************************************
GuardarDato:
    ;LDA	    DatoTecl
    MOV     M, A
    INX     H
    RET
;---------------------------
    HLT

;*****************************************************************
;       FUNCION ComoOrdeno
;*****************************************************************
; Se debe cargar CritOrden para correcta seleccion
ComoOrdeno:
    CPI     Tecl1
    JC      ComoOrdenoError
    CPI     Tecl6+1         ; xq condicion de C en CPI 
    JNC     ComoOrdenoError ; C=0 => A>data || A=data (tmb Z=1) 
    
    CALL    Ordenar         ; afuera para facil visualizacion
    LDA     CritOrden       ; de otros algoritmos (no exigido)
    CPI     Tecl1
    JNZ     ComoOrdenoII
    CALL    Invertir
    RET
ComoOrdenoII:
    CPI     Tecl2
    JNZ     ComoOrdenoIII
    RET
ComoOrdenoIII:
    CALL    CrearCopia      ; siguentes precisan copia
    LDA     CritOrden
    CPI     Tecl3
    JNZ     ComoOrdenoIV
    CALL    ParAImpar
    RET
ComoOrdenoIV:
    CPI     Tecl4
    JNZ     ComoOrdenoV
    CALL    ImparAPar
    RET
ComoOrdenoV:
    CPI     Tecl5
    JNZ     ComoOrdenoVI
    CALL    CentroMen
    RET
ComoOrdenoVI:
    CPI     Tecl6
    JNZ     ComoOrdenoError
    CALL    CentroMay
    RET
ComoOrdenoError:
    RET

    HLT

;*****************************************************************
;       FUNCION Ordenar
;*****************************************************************
Ordenar:
    LXI     H, DatoNum      ; cargo vector en M
    MVI     C, CantD        ; cargo cant elementos en C

    DCR     C
OrdComparar:
    MOV     A, M            ; tomo elemento M
    INX     H               ; incremento adrr M 
    CMP     M               ; comparo numeros 
    JC      OrdOrdenado     ; IF (A) < (M) , ta bien ->JMP 
    JZ      OrdOrdenado     ; IF (A) = (M) , ta bien ->JMP

    MOV     B, M            ; ELSE intercambio
    MOV     M, A            ; out status:
    DCX     H               ;  . A <- May   B <- Men
    MOV     M, B            ;  . M (May)
    INX     H               ;  . M-1 (Men)

    JMP     Ordenar         ; evaluar con anteriores
OrdOrdenado:
    DCR     C
    JNZ     OrdComparar
    
    RET
;---------------------------
    HLT

;*****************************************************************
;       FUNCION Invertir
;*****************************************************************
;  Dos direcciones, una en cada "punta del array" 
; una crece otra decrece e intercambian valores
Invertir:
    LXI     H, DatoNum
    LXI     D, DatoNum+CantD-1
    MVI     C, CantD/2

InvCambio:
    MOV     A, M
    XCHG
    MOV     B, M
    MOV     M, A
    XCHG
    MOV     M, B

    INX     H
    DCX     D
    DCR     C
    JNZ     InvCambio

    RET
;---------------------------
    HLT

;*****************************************************************
;       FUNCION CrearCopia
;*****************************************************************
;  Guarda los datos del array en RAM para operaciones complejas
CrearCopia:
    LXI     H, DatoNum
    LXI     D, DatoAux
    MVI     C, CantD

CreCopiar:
    MOV     A, M
    XCHG
    MOV     M, A
    XCHG

    INX     H
    INX     D
    DCR     C
    JNZ     CreCopiar

    RET
;---------------------------
    HLT

;*****************************************************************
;       FUNCIONES CentroMen | CentroMay
;*****************************************************************
;  Necesita copia ordenada. Dos punteros, uno en la copia 
; y otra en el array, estos son inicializados segun lo
; necesite la función para luego llamar a los bucles que 
; colocan los valores de manera ascendente o descendente
CentroMen:
    LXI     H, DatoAux
    LXI     D, DatoNum+CantD/2
    MVI     C, CantD/2
    CALL    CenUbicarUp

    LXI     H, DatoAux+1
    LXI     D, DatoNum+CantD/2-1
    MVI     C, CantD/2
    CALL    CenUbicarDw
    RET
;---------------------------
CentroMay:
    LXI     H, DatoAux
    LXI     D, DatoNum
    MVI     C, CantD/2
    CALL    CenUbicarUp

    LXI     H, DatoAux+1
    LXI     D, DatoNum+CantD-1  ; decremento
    MVI     C, CantD/2
    CALL    CenUbicarDw
    RET
;---------------------------
CenUbicarUp:
    MOV     A, M
    XCHG
    MOV     M, A
    XCHG

    INX     H
    INX     H
    INX     D               ; rp D disminulle "carga para arriba"

    DCR     C
    JNZ     CenUbicarUp
    RET
;---------------------------
CenUbicarDw:
    MOV     A, M
    XCHG
    MOV     M, A
    XCHG

    INX     H
    INX     H
    DCX     D               ; rp D disminulle "carga para abajo"

    DCR     C
    JNZ     CenUbicarDw
    RET
;---------------------------
    HLT

;*****************************************************************
;       FUNCION CuantosPares
;*****************************************************************
; El 0 es consierado par
CuantosPares:
    LXI     H, DatoNum      ; cargo vector en M
    MVI     C, CantD        ; cargo cant elementos en C
    MVI     B, 00h          ; inicializo contador de pares

CnPComparar:
    MOV     A, M            ; tomo elemento M
    RRC                     ; A0 -> CY
    JNC     CnPSiguiente    ; IF CY=0 => es par
    INR     B
CnPSiguiente:
    INX     H
    DCR     C
    JNZ     CnPComparar

    MOV     A, B
    STA     CantPar
    RET
    HLT

;*****************************************************************
;       FUNCIONES ParAImpar | ImparAPar
;*****************************************************************
;  Las funciones utilizadas solo llaman, segun el orden exigido,
; a bucles que cargan unicamente los valores pares o impares
ParAImpar:
    LXI     D, DatoNum
    CALL    CargarPares
    CALL    CargarImPares
    RET
;---------------------------
ImparAPar:
    LXI     D, DatoNum
    CALL    CargarImPares
    CALL    CargarPares
    RET
;---------------------------
CargarPares:
    LXI     H, DatoAux
    MVI     C, CantD
CgPBucle:
    MOV     A, M            ; tomo elemento M
    RRC                     ; A0 -> CY
    JC      CgPSiguiente    ; IF CY=1 => es impar => salto
    
    XCHG
    RLC
    MOV     M, A
    XCHG
    INX     D
CgPSiguiente:
    INX     H
    DCR     C
    JNZ     CgPBucle

    RET
;---------------------------
CargarImPares:              ; solo cambia salto. reusabilidad?
    LXI     H, DatoAux
    MVI     C, CantD
CgIBucle:
    MOV     A, M
    RRC
    JNC     CgISiguiente    ; IF CY=1 => es par => salto
    
    XCHG
    RLC
    MOV     M, A
    XCHG
    INX     D
CgISiguiente:
    INX     H
    DCR     C
    JNZ     CgIBucle

    RET
;---------------------------
    HLT