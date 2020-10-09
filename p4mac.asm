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

parseString macro buffer;, ref
    LOCAL RestartSplit, Split, ConcatParse, FinParse, Negativo
    xor si, si
	xor cx, cx
	xor bx, bx
	xor dx, dx

	mov bx, 0ah
    ; mov ax, ref
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
		push dx
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

convertAscii macro numero
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
; MACROS ANALIZIS Y OPERACIONES
;-------------------------------------------------------------------------------------
forArray macro buffer
    LOCAL CICLO, CONTINUARC, FINC, IDS, SAVEID, GUARDARPADRE, GUARDARPLOOP, FINLOOPGP
    LOCAL BUSCARNUM, CICLONUM, FINCICLONUM

    xor si, si
    xor cx, cx
    mov [pathBool], 48
    
    CICLO:
        mov dh, buffer[si]        
        cmp dh, 22h ; "
        je IDS
        jmp CONTINUARC

    CONTINUARC: 
        cmp dh, '$'
        je FINC

        inc si
        jmp CICLO

    IDS:
        inc si
        mov dh, buffer[si]
        cmp dh, 22h ; "
        je SAVEID

        cmp dh, 23h ; #
        je BUSCARNUM

        PUSH si
        xor si, si
        mov si, cx
        mov auxiliar[si], dh
        inc cx
        POP si

        jmp IDS

    SAVEID:
        xor cx, cx
        xor ax, ax
        mov ah, auxiliar
        PUSH ax

        cmp [pathBool], 48 ; 0 FALSE
		je GUARDARPADRE

        ;print auxiliar
        clearString auxiliar
        ;getChr

        inc si
        jmp CICLO

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
        inc si
        inc si
        inc si
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

        PUSH si
        xor si, si
        mov si, cx
        mov auxiliar[si], dh
        inc cx
        POP si
        jmp CICLONUM

    FINCICLONUM:
        xor cx, cx
        xor ax, ax
        mov ah, auxiliar
        PUSH ax

        ;print auxiliar
        clearString auxiliar
        ;getChr

        inc si
        jmp CICLO
    
    FINC:
endm

operaciones macro buffer
endm

comandos macro buffer
    ; LOCAL 
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