; IMPORTS MACROS
include p4mac.asm

; TIPO DE EJECUTABLE
.model small 
.stack 100h

.data ;SEGMENTO DE DATOS
; SECCION DE DATOS 
lineaH  db 0ah,0dh, '  ========================================================', '$'
header  db 0ah,0dh, '   UNIVERSIDAD DE SAN CARLOS DE GUATEMALA', 0ah,0dh, '   FACULTAD DE INGENIERIA', 0ah,0dh, '   CIENCIAS Y SISTEMAS', 0ah,0dh, '   CURSO: ARQUITECTURA DE COMPUTADORES Y ENSAMBLADORES 1', 0ah,0dh, '   NOMBRE: DIDIER ALFREDO DOMINGUEZ URIAS', 0ah,0dh, '   CARNET: 201801266', '$'
options db 0ah,0dh, '   1) CARGAR ARCHIVO', 0ah,0dh, '   2) CONSOLA', 0ah,0dh, '   3) SALIR', '$'
getOPT  db 0ah,0dh, '   >> Escoger Opcion: ', '$'
finHDR  db 0ah,0dh, '  ========================================================', '$'
ln db 0ah,0dh, '$'

msgCarg db 0ah,0dh, '  ==================== CARGAR ARCHIVO ====================', '$'
getPath db 0ah,0dh, '   >> Ingrese Ruta: ', '$'
msgPath db 0ah,0dh, '   ARCHIVO LEIDO CON EXITO!', '$'
msgEPath db 0ah,0dh, '   ERROR AL LEER ARCHIVO', '$'
path db 100 dup('$')

msgCons db 0ah,0dh, '  ======================= CONSOLA ========================', '$'
getCMD db 0ah,0dh, '   >> ', '$'
msgECMD db 0ah,0dh, '   COMANDO NO ECONTRADO', '$'

msgMedia db 0ah,0dh, '   Estadistico Media: ', '$'
msgModa db 0ah,0dh, '   Estadistico Moda: ', '$'
msgMediana db 0ah,0dh, '   Estadistico Mediana: ', '$'
msgMayor db 0ah,0dh, '   Estadistico Mayor: ', '$'
msgMenor db 0ah,0dh, '   Estadistico Menor: ', '$'
msgID db 0ah,0dh, '   Resultado ', '$'

msgOpeningError  db 0ah,0dh,20h,20h,  'ERROR: NO SE PUDO ABRIR EL ARCHIVO', '$'
msgCreationError db 0ah,0dh,20h,20h,  'ERROR: NO SE PUDO CREAR EL ARCHIVO', '$'
msgWritingError  db 0ah,0dh,20h,20h,  'ERROR: NO SE PUDO ESCRIBIR EN EL ARCHIVO', '$'
msgDeleteError   db 0ah,0dh,20h,20h,  'ERROR: NO SE PUDO ELIMINAR EL ARCHIVO', '$'
msgReadingError  db 0ah,0dh,20h,20h,  'ERROR: NO SE PUDO LEER EL ARCHIVO', '$'

bufferContenidoJSON db 10000 dup('$')
handleFile dw ?
; FIN SECCION DE DATOS 

.code ;SEGMENTO DE CODIGO
; SECCION DE CODIGO
    main proc
        mov dx, @data
        mov ds, dx

        MENU:
            print lineaH
            print header
            print ln
            print options
            print ln
            print getOPT
            getChr
            print finHDR

            cmp al, 49
			je CARGAR
			cmp al, 50
			je CONSOLA
			cmp al, 51
			je SALIR
            jmp MENU
        
        CARGAR:
            print msgCarg
            print getPath
            getPathFile path
            openFile path, handleFile
            readFile SIZEOF bufferContenidoJSON, bufferContenidoJSON , handleFile
            closeFile handleFile
            print bufferContenidoJSON

            ;clearArray bufferContenidoJSON
            ;clearArray path
            ;print bufferContenidoJSON
            ;print path
            jmp MENU

        CONSOLA:
            print msgCons
            print getCMD
            getChr
            jmp MENU

        SALIR: 
			mov ah, 4ch
			int 21h

        OpeningError: 
	    	print msgOpeningError
	    	getChr
	    	jmp MENU
        
        CreationError:
	    	print msgCreationError
	    	getChr
	    	jmp MENU

        ReadingError:
	    	print msgReadingError
	    	getChr
	    	jmp MENU
        
        WritingError:
	    	print msgWritingError
	    	getChr
	    	jmp MENU

        DeleteError:
	    	print msgDeleteError
	    	getChr
	    	jmp MENU
    main endp
; FIN SECCION DE CODIGO
end