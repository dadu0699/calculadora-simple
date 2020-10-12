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
msgCloseError    db 0ah,0dh,20h,20h,  'ERROR: NO SE PUDO CERRAR EL ARCHIVO', '$'

bufferContenidoJSON db 10000 dup('$')       ; Array para almacenar el contenido del archivo
auxiliar db 50 dup('$')                     ; Variable para ir formando cada uno de los IDs y numero del archivo
negativo db 48                              ; Variable para saber si hay que negar un numero
numeroU dw 00h, '$'                         ; Variable para el numero1 a operar
numeroD dw 00h, '$'                         ; Variable para el numero2 a operar
signo   db 00h, '$'                         ; Variable para guardar el signo de operacion
handleFile dw ?

alumnoJSON db '{', 0ah,09h, '"reporte": {', 0ah,09h,09h, '"alumno": {', 0ah,09h,09h,09h, '"Nombre": "Didier Alfredo Domínguez Urías",',  0ah,09h,09h,09h, '"Carnet": 201801266,', 0ah,09h,09h,09h, '"Seccion": "A",', 0ah,09h,09h,09h, '"Curso": "Arquitectura de Computadoras y Ensambladores 1"', 0ah,09h,09h, '},'                                         
fechaDiaJSON db  0ah,09h,09h, '"fecha": {', 0ah,09h,09h,09h, '"Dia": '
fechaMesJSON db  ',', 0ah,09h,09h,09h, '"Mes": '
fechaAnioJSON db  ',', 0ah,09h,09h,09h, '"Año": 2020'
horaHoraJSON db  0ah,09h,09h, '},', 0ah,09h,09h, '"hora": {', 0ah,09h,09h,09h, '"Hora": '
horaMinutosJSON db  ',', 0ah,09h,09h,09h, '"Minutos": '
horaSegundosJSON db  ',', 0ah,09h,09h,09h, '"Segundos": '
resultsMediaJSON db  0ah,09h,09h, '},', 0ah,09h,09h, '"resultados": {', 0ah,09h,09h,09h, '"Media": '
resultsMedianaJSON db  ',', 0ah,09h,09h,09h, '"Mediana": '
resultsModaJSON db  ',', 0ah,09h,09h,09h, '"Moda": '
resultsMenorJSON db  ',', 0ah,09h,09h,09h, '"Menor": '
resultsMayorJSON db  ',', 0ah,09h,09h,09h, '"Mayor": '
operacionesJSON db  0ah,09h,09h, '},', 0ah,09h,09h, '"'
operaciones1JSON db '": ['
operaciones2JSON db 0ah,09h,09h,09h, '{', 0ah,09h,09h,09h,09h
comillasDB db '"'
dosPuntos db ': '
operaciones3JSON db 0ah,09h,09h,09h, '},'
cierreJSON db  0ah,09h,09h, ']', 0ah,09h, '}', 0ah, '}'

fechaDia db 'dd'
fechaMes db 'mm'
fechaHora db 'hh'
fechaMinutos db 'mm'
fechaSegundos db 'ss'
resMedia dw 0, '$'
resMediana dw 0, '$'
resModa dw 0, '$'
resMenor dw 0, '$'
resMayor dw 0, '$'

pathFile db 50 dup('$')         ; Variable para guardar el nombre del padre para el reporte
nameParent db 30 dup('$')       ; Variable para guardar el nombre del padre e imprimir dentro del reporte
sizeNameParent dw 0             ; Variable para almacenar la longitud del nombre del padre
pathBool db 48                  ; Variable para saber si ya se almaceno un nombre padre 0 (False)

arrOperacionesNom db 255 dup('$')
arrOperacionesVal dw 255 dup('$')
contadorOperacionNom dw 0
contadorOperacionVal dw 0
auxValor dw 0

msgRESTA db 0ah,0dh, '   Resultado RESTA ', '$'
msgSUMA db 0ah,0dh, '   Resultado SUMA ', '$'
msgMULT db 0ah,0dh, '   Resultado MULTIPLICACION ', '$'
msgDIV db 0ah,0dh, '   Resultado DIVISION ', '$'
msgAnalisis  db 0ah,0dh,20h,20h,  ' OPERACIONES CALCULADAS', '$'
msG db 0ah,0dh, '   Resultado MAYOR: ', '$'
msL db 0ah,0dh, '   Resultado MENOR: ', '$'
msM db 0ah,0dh, '   Resultado MEDIA: ', '$'
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
            clearString path
            clearString pathFile
            clearString bufferContenidoJSON

            clearString auxiliar
            clearString arrOperacionesNom
            clearString arrOperacionesVal
            mov contadorOperacionNom, 0
            mov contadorOperacionVal, 0
            mov resMedia, 0
            mov resMediana, 0
            mov resModa, 0
            mov resMenor, 0
            mov resMayor, 0

            print msgCarg
            print getPath
            getPathFile path
            openFile path, handleFile
            readFile SIZEOF bufferContenidoJSON, bufferContenidoJSON , handleFile
            closeFile handleFile

            analisisJSON bufferContenidoJSON        ; Se recorre el archivo
            generateReport
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

        CloseError:
	    	print msgCloseError
	    	getChr
	    	jmp MENU
    main endp
; FIN SECCION DE CODIGO





    conv proc 
        AAM
        ADD ax, 3030h
        ret
    conv endp
end