print macro str
    LOCAL ETIQUETAPRINT
    ETIQUETAPRINT:
        mov ah,09h
        mov dx, offset str
        int 21h
endm

getChr macro
    mov ah,01h
    int 21h
endm

getString macro buffer
    LOCAL COCAT, TERM

    xor si,si
    COCAT:
        getChr
        cmp al, 0dh
        je TERM
        mov buffer[si], al
        inc si
        jmp COCAT

    TERM:
        mov al, '$'
        mov buffer[si], al
endm



getPathFile macro buffer
    LOCAL CONCATENAR, TERMINAR
    
    xor si, si
    CONCATENAR:
        getChr
        cmp al, 0dh
        je TERMINAR
        mov buffer[si], al
        inc si
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
endm

deleteFile macro buffer
    mov ah, 41h
    lea dx, buffer
    jc DeleteError
endm



;clearArray macro buffer
;    xor ax, ax
;    mov cx, SIZEOF buffer
;    mov di, buffer
;    cld
;    rep stosb
;endm