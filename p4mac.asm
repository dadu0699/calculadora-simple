print macro str
    LOCAL ETIQUETAPRINT
    almacenar
    ETIQUETAPRINT:
        mov ah,09h
        mov dx, offset str
        int 21h
    desalmanecar
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
    desalmanecar
endm

parseString macro buffer
    LOCAL RestartSplit, Split, ConcatParse, FinParse, Negativo
    almacenar
    xor si, si
	xor cx, cx
	xor bx, bx
	xor dx, dx
	mov dl, 0ah
	test ax, 1000000000000000
    jnz Negativo
	jmp Split

    Negativo:
        neg ax
        mov buffer[si], 45
        inc si
        jmp Split

	RestartSplit:
		xor ah,ah

	Split:
		div dl
		inc cx
		push ax
		cmp al, 00h
		je ConcatParse
		jmp RestartSplit

	ConcatParse:
		pop ax
		add ah, 30h
		mov buffer[si], ah
		inc si
		loop ConcatParse
		mov ah, 24h
		mov buffer[si], ah
		inc si

	FinParse:
    desalmanecar
endm

equalsString macro buffer, command, etq
    almacenar
    mov ax, ds
    mov es, ax
    mov cx, 5   ;Cantidad de caracateres a comparar
    
    lea si, buffer
    lea di, command
    repe cmpsb
    desalmanecar
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
    desalmanecar
endm

getInteger macro buffer
	LOCAL IniciInt, FinInt
    almacenar
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
    desalmanecar
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
    desalmanecar
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



forArray macro buffer
    LOCAL CICLO, CONTINUARC, FINC, IDS, SAVEID

    xor si, si
    xor cx, cx
    
    CICLO:
        mov dh, buffer[si]        
        cmp dh, 22h
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
        cmp dh, 22h
        je SAVEID

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

        print auxiliar
        clearString auxiliar
        getChr

        inc si
        jmp CICLO

    FINC:
endm

almacenar macro
    push ax
    push bx
    push cx
    push dx
    push si
    push di
endm

desalmanecar macro                  
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
endm