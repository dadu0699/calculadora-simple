print macro str
    LOCAL ETIQUETAPRINT
    almacenar
    ETIQUETAPRINT:
        mov ah,09h
        mov dx, offset str
        int 21h
    desalmacenar
endm

getChr macro
    mov ah,01h
    int 21h
endm

getString macro buffer
    LOCAL COCAT, TERM, DELSPACE
    almacenar

    xor si, si
    COCAT:
        getChr
        cmp al, 0dh
        je TERM
        cmp al, 08h
        je DELSPACE
        mov buffer[si], al
        inc si
        jmp COCAT

    DELSPACE:
        mov al, 24h
        dec si
        mov buffer[si], al
        jmp COCAT

    TERM:
        mov al, '$'
        mov buffer[si], al
    desalmacenar
endm

parseString macro buffer, ref
    LOCAL RestartSplit, Split, ConcatParse, FinParse, Negativo
    PUSH si
    PUSH cx

    xor si, si
	xor cx, cx
	xor bx, bx
	xor dx, dx

	mov bx, 0ah
    mov ax, ref
	test ax, 1000000000000000b
    jnz Negativo
	jmp Split

    Negativo:
        neg ax
        mov buffer[si], 45
        inc si
        jmp Split

	RestartSplit:
		xor dx, dx

	Split:
		div bx
		inc cx
		PUSH dx
		cmp ax, 00h
		je ConcatParse
		jmp RestartSplit

	ConcatParse:
		pop ax
		add ax, 30h
		mov buffer[si], ax
		inc si
		loop ConcatParse
		mov ax, 24h
		mov buffer[si], ax

	FinParse:
    POP cx
    POP si
endm

equalsString macro buffer, command, etq
    almacenar
    mov ax, ds
    mov es, ax
    mov cx, 30   ;Cantidad de caracateres a comparar
    
    lea si, buffer
    lea di, command
    repe cmpsb
    desalmacenar
    je etq
endm

convertAscii macro numero, varSalida
	LOCAL convI, finA
    almacenar

	xor ax, ax
	xor bx, bx
	xor cx, cx
	mov bx, 10
	xor si, si

	convI:
		mov cl, numero[si] 
		cmp cl, 48
		jl finA
		cmp cl, 57
		jg finA
		inc si
		sub cl, 48
		mul bx
		add ax, cx
		jmp convI
	finA:
        mov varSalida, ax
    desalmacenar
endm

getInteger macro buffer
	LOCAL IniciInt, FinInt
	xor si, si
	IniciInt:
		getChr
		cmp al, 0dh
		je FinInt
		mov buffer[si], al
		inc si
		jmp IniciInt

	FinInt:
		mov buffer[si], 00h
endm

clearString macro buffer
    LOCAL RestartClear
    almacenar

    xor si, si
    xor cx, cx
    mov cx, SIZEOF buffer
    
    RestartClear:
        mov buffer[si], '$'
        inc si
    loop RestartClear
    desalmacenar
endm

;-------------------------------------------------------------------------------------
; MACROS ARCHIVOS
;-------------------------------------------------------------------------------------
getPathFile macro buffer
    LOCAL CONCATENAR, TERMINAR, ELIMINARESPACIO
    
    xor si, si
    CONCATENAR:
        getChr
        cmp al, 0dh
        je TERMINAR
        cmp al, 08h
        je ELIMINARESPACIO
        mov buffer[si], al
        inc si
        jmp CONCATENAR

    ELIMINARESPACIO:
        mov al, 24h
        dec si
        mov buffer[si], al
        jmp CONCATENAR

    TERMINAR:
        mov buffer[si], 00h
endm

createFile macro buffer, handle
    mov ah, 3ch
    mov cx, 00h
    lea dx, buffer
    int 21h
    mov handle, ax
    jc CreationError
endm

openFile macro path, handle
    mov ah, 3dh
    mov al, 10b
    lea dx, path
    int 21h
    mov handle, ax
    jc OpeningError
endm

readFile macro nobytes, buffer, handle
    mov ah, 3fh
    mov bx, handle
    mov cx, nobytes
    lea dx, buffer
    int 21h
    jc ReadingError
    print msgPath
    print ln
endm

writingFile macro numbytes, buffer, handle
	PUSH cx
	PUSH dx

	mov ah, 40h
	mov bx, handle
	mov cx, numbytes
	lea dx, buffer
	int 21h
	jc WritingError

	POP dx
	POP cx
endm

closeFile macro handle
    mov ah, 3eh
    mov handle, bx
    int 21h
    jc CloseError
endm

deleteFile macro buffer
    mov ah, 41h
    lea dx, buffer
    jc DeleteError
endm

;-------------------------------------------------------------------------------------
; MACROS REPORTES
;-------------------------------------------------------------------------------------
generateReport macro 
    getDate
    getTime

    deleteFile pathFile
    createFile pathFile, handleFile
    openFile pathFile, handleFile

    writingFile SIZEOF alumnoJSON, alumnoJSON, handleFile
    writingFile SIZEOF fechaDiaJSON, fechaDiaJSON, handleFile
    writingFile SIZEOF fechaDia, fechaDia, handleFile
    writingFile SIZEOF fechaMesJSON, fechaMesJSON, handleFile
    writingFile SIZEOF fechaMes, fechaMes, handleFile
    writingFile SIZEOF fechaAnioJSON, fechaAnioJSON, handleFile
    writingFile SIZEOF horaHoraJSON, horaHoraJSON, handleFile
    writingFile SIZEOF fechaHora, fechaHora, handleFile
    writingFile SIZEOF horaMinutosJSON, horaMinutosJSON, handleFile
    writingFile SIZEOF fechaMinutos, fechaMinutos, handleFile
    writingFile SIZEOF horaSegundosJSON, horaSegundosJSON, handleFile
    writingFile SIZEOF fechaSegundos, fechaSegundos, handleFile
    writingFile SIZEOF resultsMediaJSON, resultsMediaJSON, handleFile
    writingFile SIZEOF resMedia, resMedia, handleFile
    writingFile SIZEOF resultsMedianaJSON, resultsMedianaJSON, handleFile
    writingFile SIZEOF resMediana, resMediana, handleFile
    writingFile SIZEOF resultsModaJSON, resultsModaJSON, handleFile
    writingFile SIZEOF resModa, resModa, handleFile
    writingFile SIZEOF resultsMenorJSON, resultsMenorJSON, handleFile
    writingFile SIZEOF resMenor, resMenor, handleFile
    writingFile SIZEOF resultsMayorJSON, resultsMayorJSON, handleFile
    writingFile SIZEOF resMayor, resMayor, handleFile
    writingFile SIZEOF operacionesJSON, operacionesJSON, handleFile
    
    parentSize nameParent, sizeNameParent               ; Se obtiene el tamnaño de la cadena
    writingFile sizeNameParent, nameParent, handleFile
    writingFile SIZEOF operaciones1JSON, operaciones1JSON, handleFile
    writingFile SIZEOF operaciones2JSON, operaciones2JSON, handleFile

    writingFile SIZEOF cierreJSON, cierreJSON, handleFile

    closeFile handleFile
endm

getDate macro
    almacenar
    mov ah,2ah
    int 21h
    
    mov al, dl
    call conv
    mov fechaDia[0], ah
    mov fechaDia[1], al

    mov al, dh
    call conv
    mov fechaMes[0], ah
    mov fechaMes[1], al
    desalmacenar
endm

getTime macro
    almacenar
    mov ah,2ch
    int 21h

    mov al, ch
    call conv
    mov fechaHora[0], ah
    mov fechaHora[1], al

    mov al, cl
    call conv
    mov fechaMinutos[0], ah
    mov fechaMinutos[1], al

    mov al, dh
    call conv
    mov fechaSegundos[0], ah
    mov fechaSegundos[1], al

    desalmacenar
endm

; @buffer cadena de la cual se obtendra la longitud exceptuando el signo de aceptacion '$'
; @varSize contador 
parentSize macro buffer, varSize
    LOCAL PSIZELOOP, PSIZEENDL
    almacenar                               ; Se guardan en la pila todos los registros anteriores 
    xor si, si                              ; Se reinicia el contador si
    PSIZELOOP:
        mov dh, buffer[si]                  ; Se obtiene caracter por caracter de la cadena
        cmp dh, '$'                         ; Se compara si es un signo de aceptacion '$'
            je PSIZEENDL                    ; Si es un signo de aceptacion '$' se termina el ciclo
        inc si
        jmp PSIZELOOP
    PSIZEENDL:
        mov varSize, si                     ; Se actualiza el contador con el conteo llevado en el ciclo
    desalmacenar                            ; Se sacan de la pila los registros anteriores
endm

;-------------------------------------------------------------------------------------
; MACROS ANALISIS Y OPERACIONES
;-------------------------------------------------------------------------------------
; @buffer contenido del archivo JSON 
analisisJSON macro buffer
    LOCAL CICLO, CONTINUARC, FINC
    LOCAL BUSCARNUM, CICLONUM, FINCICLONUM, ESPNUMC, NEGARNUMERO, NEGARASCII 
    LOCAL IDS, VERIFICARID, SAVEID, GOPLOOP, FGOP, SEGUIROPERANDO
    LOCAL GUARDARPADRE, GUARDARPLOOP, FINLOOPGP
    LOCAL ID_DIV, ID_DIV1, ID_DIV2, ID_DIV3
    LOCAL ID_MUL, ID_MUL1, ID_MUL2, ID_MUL3
    LOCAL ID_SUB, ID_SUB1, ID_SUB2, ID_SUB3
    LOCAL ID_ADD, ID_ADD1, ID_ADD2, ID_ADD3
    LOCAL ID_ID, ID_ID1, ID_ID2
    LOCAL OPERAR, NOOPERAR, SUMAR, RESTAR, MULTIPLICAR, DIVIDIR, GUARDAROPERA

    xor si, si                      ; Limpiar registro SI el cual nos servira como contador global del archivo
    xor cx, cx                      ; Limpiar registro CX para llevar el control de caracteres de IDs
    mov [pathBool], 48              ; Se reinicia la variable del nombre del padre
    
    xor ax, ax
    mov ah, '&'
    PUSH ax
    
    CICLO:
        mov dh, buffer[si]          ; Se obtiene el caracter del buffer en la posicion actual de registro si y se guarda en el registro dh
        
        cmp dh, 22h                 ; Se verifica si el caracter en el registro dh es igual a las comillas dobles '"'
        je IDS                      ; Si son comillas dobles se salta a la etiqueta para reconocer IDs
        
        jmp CONTINUARC

    CONTINUARC: 
        cmp dh, '$'                 ; Se verifica si el caracater en el registro dh es un signo de aceptacion '$'
        je FINC                     ; Si es un signo de aceptacion se salta a la etiqueta para finalizar el analisis

        inc si                      ; Se incremente el contador guardado en el registro SI
        jmp CICLO                   

    IDS:
        inc si                      ; Se incremente el contador guardado en el registro SI 
        mov dh, buffer[si]          ; Se obtiene el caracter del buffer en la posicion actual de registro si y se guarda en el registro dh
        cmp dh, 22h                 ; Se verifica si el caracter en el registro dh es igual a las comillas dobles '"'
        je VERIFICARID              ; Si son comillas dobles se salta a la etiqueta para guardar IDs

        cmp dh, 23h                 ; Se verifica si el caracter en el registro dh es igual al signo numeral '#'
        je BUSCARNUM                ; Si son comillas dobles se salta a la etiqueta para reconocer numeros

        PUSH si                     ; Almacenamos el contador global en la pila
        xor si, si                  ; Limpiar registro
        mov si, cx                  ; Movemos el valor del registro cx a si
        mov auxiliar[si], dh        ; Vamos formando el ID
        inc cx                      ; incrementamos CX
        POP si                      ; Sacamos el contador global en la pila

        jmp IDS

    VERIFICARID:
        xor ax, ax                  ; Limpiamos el valor almacenado en AX
        xor cx, cx                  ; Limpiamos CX para llevar el control de futuros IDs

        cmp [pathBool], 48          ; Se verifica si ya se almaceno un padre (48 = 0 "False")
		je GUARDARPADRE             ; Si es "0" se salta a guardar el padre

        ; BUSCAR DIVISION
        cmp auxiliar[0], 'D'
        je ID_DIV1
        cmp auxiliar[0], 'd'
        je ID_DIV1
        cmp auxiliar[0], '/'
        je ID_DIV

        ; BUSCAR MULTIPLICACION
        cmp auxiliar[0], 'M'
        je ID_MUL1
        cmp auxiliar[0], 'm'
        je ID_MUL1
        cmp auxiliar[0], '*'
        je ID_MUL

        ; BUSCAR RESTA
        cmp auxiliar[0], 'S'
        je ID_SUB1
        cmp auxiliar[0], 's'
        je ID_SUB1
        cmp auxiliar[0], '-'
        je ID_SUB

        ; BUSCAR SUMA
        cmp auxiliar[0], 'A'
        je ID_ADD1
        cmp auxiliar[0], 'a'
        je ID_ADD1
        cmp auxiliar[0], '+'
        je ID_ADD

        ; BUSCAR ID
        cmp auxiliar[0], 'I'
        je ID_ID1
        cmp auxiliar[0], 'i'
        je ID_ID1

        jmp SAVEID

    SAVEID:        
        almacenar                           ; Se Guardan los registros anteriores en pila
        xor si, si                          ; Reiniciamos el registro SI el cual nos ayudara a recorrer el aux
        mov di, contadorOperacionNom        ; Guardamos en el registro DI el valor de posicion del ultimo nombre de operacion mas 1
        GOPLOOP:
            mov dh, auxiliar[si]
            cmp dh, '$'
            je FGOP
            
            mov arrOperacionesNom[di], dh   ; Vamos almacenando el letra por letra el nuevo nombre de operacion
            
            inc di
            inc si
            jmp GOPLOOP
        FGOP:
            mov arrOperacionesNom[di], '&'  ; Agregamos un valor pivote para reconocer los ID
            inc di
            mov contadorOperacionNom, di
            inc contadorOperacionVal
            ;print arrOperacionesNom
            ;getChr
        desalmacenar

        ;print auxiliar
        clearString auxiliar
        ; getChr
        inc si
        jmp CICLO


    ID_DIV:
        xor ax, ax
        mov ah, '/'
        PUSH ax

        clearString auxiliar
        inc si
        jmp CICLO
    ID_DIV1:
        cmp auxiliar[1], 'I'
        je ID_DIV2
        cmp auxiliar[1], 'i'
        je ID_DIV2
        jmp SAVEID
    ID_DIV2:
        cmp auxiliar[2], 'V'
        je ID_DIV3
        cmp auxiliar[2], 'v'
        je ID_DIV3
        jmp SAVEID
    ID_DIV3:
        cmp auxiliar[3], '$'
        je ID_DIV
        jmp SAVEID
    ID_MUL:
        xor ax, ax
        mov ah, '*'
        PUSH ax

        clearString auxiliar
        inc si
        jmp CICLO
    ID_MUL1:
        cmp auxiliar[1], 'U'
        je ID_MUL2
        cmp auxiliar[1], 'u'
        je ID_MUL2
        jmp SAVEID
    ID_MUL2:
        cmp auxiliar[2], 'L'
        je ID_MUL3
        cmp auxiliar[2], 'l'
        je ID_MUL3
        jmp SAVEID
    ID_MUL3:
        cmp auxiliar[3], '$'
        je ID_MUL
        jmp SAVEID
    ID_SUB:
        xor ax, ax
        mov ah, '-'
        PUSH ax

        clearString auxiliar
        inc si
        jmp CICLO
    ID_SUB1:
        cmp auxiliar[1], 'U'
        je ID_SUB2
        cmp auxiliar[1], 'u'
        je ID_SUB2
        jmp SAVEID
    ID_SUB2:
        cmp auxiliar[2], 'B'
        je ID_SUB3
        cmp auxiliar[2], 'b'
        je ID_SUB3
        jmp SAVEID
    ID_SUB3:
        cmp auxiliar[3], '$'
        je ID_SUB
        jmp SAVEID
    ID_ADD:
        xor ax, ax
        mov ah, '+'
        PUSH ax

        clearString auxiliar
        inc si
        jmp CICLO
    ID_ADD1:
        cmp auxiliar[1], 'D'
        je ID_ADD2
        cmp auxiliar[1], 'd'
        je ID_ADD2
        jmp SAVEID
    ID_ADD2:
        cmp auxiliar[2], 'D'
        je ID_ADD3
        cmp auxiliar[2], 'd'
        je ID_ADD3
        jmp SAVEID
    ID_ADD3:
        cmp auxiliar[3], '$'
        je ID_ADD
        jmp SAVEID
    ID_ID:
        ;TODO BUSCAR VALOR DEL ID

        clearString auxiliar
        inc si
        jmp CICLO
    ID_ID1:
        cmp auxiliar[1], 'D'
        je ID_ID2
        cmp auxiliar[1], 'd'
        je ID_ID2
    ID_ID2:
        cmp auxiliar[3], '$'
        je ID_ID
        jmp SAVEID


    GUARDARPADRE:
        almacenar
        xor si, si
        GUARDARPLOOP:
            mov dh, auxiliar[si]
            cmp dh, '$'
                je FINLOOPGP
            mov pathFile[si], dh
            mov nameParent[si], dh
            inc si
            jmp GUARDARPLOOP
        FINLOOPGP:
            mov pathFile[si], '.'
            inc si
            mov pathFile[si], 'j'
            inc si
            mov pathFile[si], 's'
            inc si
            mov pathFile[si], 'o'
            inc si
            mov pathFile[si], 00h
            mov [pathBool], 49 ; 1 TRUE
            
            ; print auxiliar
            ; print ln
            ; print pathFile
        desalmacenar

        clearString auxiliar
        inc si
        jmp CICLO


    BUSCARNUM:
        ESPNUMC:    
            inc si    
            mov dh, buffer[si]
            cmp dh, 22h ; COMILLAS DOBLES
            je ESPNUMC
            cmp dh, 3Ah ; DOS PUNTOS :
            je ESPNUMC
            cmp dh, 20h ; ESPACIO EN BLANCO
            je ESPNUMC
            cmp dh, 0ah ; SALTO DE LINEA
            je ESPNUMC
            cmp dh, 0dh ; RETORNO DE CARRO
            je ESPNUMC
            cmp dh, 09h ; TABS
            je ESPNUMC

        dec si
        jmp CICLONUM

    CICLONUM:
        inc si
        mov dh, buffer[si]
        
        cmp dh, 2Ch ; ,
            je FINCICLONUM
        cmp dh, 7Dh ; }
            je FINCICLONUM
        cmp dh, 0ah ; SALTO DE LINEA
            je FINCICLONUM
        cmp dh, 2Dh ; Signo Menos -
            je NEGARNUMERO

        PUSH si
        xor si, si
        mov si, cx
        mov auxiliar[si], dh
        inc cx
        POP si
        jmp CICLONUM
    NEGARNUMERO:
        mov [negativo], 49      ; La variable del negativo pasa a ser 1 (True)
        jmp CICLONUM

    FINCICLONUM:
        xor cx, cx
        
        convertAscii auxiliar, numeroD
        cmp [negativo], 48          ; Se verifica si no es necesario negar
        je NEGARASCII 
        neg numeroD

        NEGARASCII:
        xor ax, ax
        POP ax
        clearString auxiliar
        mov auxiliar, al
        cmp auxiliar, 00h
        je NOOPERAR
        
        mov numeroU, ax

        xor ax, ax
        POP ax
        clearString auxiliar
        mov auxiliar, ah
        cmp auxiliar, '+'
        je SUMAR
        cmp auxiliar, '-'
        je RESTAR
        cmp auxiliar, '*'
        je MULTIPLICAR
        cmp auxiliar, '/'
        je DIVIDIR

    NOOPERAR:
        clearString auxiliar
        mov auxiliar, ah
        cmp auxiliar, '&'
        je GUARDAROPERA

        PUSH ax
        PUSH numeroD
        ; print auxiliar
        clearString auxiliar
        ; getChr
        mov [negativo], 48 

        inc si
        jmp CICLO
    
    GUARDAROPERA:
        xor ax, ax
        mov ah, '&'
        PUSH ax

        mov di, contadorOperacionVal
        mov ax, numeroD
        mov arrOperacionesVal[di], ax

        clearString auxiliar
        ; mov [negativo], 48 

        inc si
        jmp CICLO

    SEGUIROPERANDO:
        xor ax, ax
        POP ax
        clearString auxiliar
        mov auxiliar, al
        cmp auxiliar, 00h
        je NOOPERAR

        mov numeroU, ax

        xor ax, ax
        POP ax
        clearString auxiliar
        mov auxiliar, ah

        cmp auxiliar, '+'
        je SUMAR
        cmp auxiliar, '-'
        je RESTAR
        cmp auxiliar, '*'
        je MULTIPLICAR
        cmp auxiliar, '/'
        je DIVIDIR

    SUMAR:
        mov ax, numeroU
        mov bx, numeroD
        add ax, bx
        
        clearString numeroU
        clearString numeroD
        mov numeroD, ax
        jmp SEGUIROPERANDO

    RESTAR:
        mov ax, numeroU
        mov bx, numeroD
        sub ax, bx

        clearString numeroU
        clearString numeroD
        mov numeroD, ax
        jmp SEGUIROPERANDO

    DIVIDIR:
        mov ax, numeroU
        mov bx, numeroD
        cwd
        idiv bx

        clearString numeroU
        clearString numeroD
        mov numeroD, ax
        jmp SEGUIROPERANDO
    MULTIPLICAR:
        mov ax, numeroU
        mov bx, numeroD
        imul bx

        clearString numeroU
        clearString numeroD
        mov numeroD, ax
        jmp SEGUIROPERANDO
    FINC:
        print arrOperacionesNom
        print ln
        parseString numeroU, arrOperacionesVal[1]
        print numeroU
        getChr 
endm


;-------------------------------------------------------------------------------------
; MACROS ALMACENAMIENTO
;-------------------------------------------------------------------------------------
almacenar macro
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    PUSH si
    PUSH di
endm

desalmacenar macro                  
    POP di
    POP si
    POP dx
    POP cx
    POP bx
    POP ax
endm