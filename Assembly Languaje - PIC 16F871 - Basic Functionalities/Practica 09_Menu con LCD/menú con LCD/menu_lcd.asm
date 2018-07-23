	list p=16f877
	#include <p16f877.inc>
;==============================================================================================
;PRÁCTICA SOBRE MANEJO DE LCD
;DISEÑO DE MENÚ DE OPCIONES UTILIZANDO UN LCD MATRICIAL DE 2X16 CARACTERES
;==============================================================================================
;Ing. L. Pérez,Mgt. (todos los derechos reservados, 2006)
;Nota: 	El código aquí propuesto se ha generado con intenciones docentes y se encuentra adecuada al Hardware de Entrenamiento
;	propuesto (v 1.01), por lo que no se garantiza su funcionamiento en otra plataforma que utilice distintos recursos de HW
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;OBJETIVO:; ENTRENAR EN EL MANEJO DE CRISTALES LÍQUIDOS MATRICIALES.
	; APLICAR LA TEORÍA SOBRE MANEJO DE LCD
	; APLICAR LA TEORÍA SOBRE DISEÑO DE MENÚS MULTINIVELES.
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;FUNCIONAMIENTO:

;Se presentan dos carteles introductorios y posteriormente un menú de tres opciones.
;Las opciones se pueden seleccionar con el teclado matricial.
;Se pueden ejecutar las opciones presionando la tecla correspondiente (1, 2, 3).
;Cada opción lo único que hace es visualizar un cartel en el LCD indicando la opción
;que se está ejecutando.
;Para salir de cada opción es necesario presionar la tecla 4
;============================================================================
;ZONA DE DECLARACIÓN DE SÍMBOLOS Y VARIABLES.
;============================================================================

;contadores para demoras.

cont1		equ 	0x20	;contadores para demora
cont2		equ 	0x21
cont3		equ 	0x22

;multiplicadores para demora

N		equ 	0x23	;factores de demora
M		equ	0x24	

;otras variables

index		equ	0x25	;índice de tabla de códigos 7 segmentos de los números.
temp		equ	0x26	;varible temporal auxiliar.
veces		equ 	0x27	;veces de conteo
size		equ 	0x28	;tamaño del cartel
ch_cont		equ 	0x29	;cntador de caracteres para cartel
tecla		equ 	0x2a	;contador de teclas
k_flag		equ 	0x2b	;bandera de tecla pulsada

rs		equ 	4	;pin ra4
e		equ 	0	;pin rc0


;=========================================================================
;INICIO DEL CÓDIGO DEL PROGRAMA
;=========================================================================

		org 0
		goto inicio		;vector de RESET.
;=========================================================================
;TABLA DE CARACTERES DE CARTELES
;=========================================================================
tabla		addwf PCL,1
		;================= index = 0
		;================= size  = 14
		retlw 'P'
		retlw 'r'
		retlw 'a'
		retlw 'c'
		retlw 't'
		retlw 'i'
		retlw 'c'
		retlw 'a'
		retlw ' '
		retlw '#'
		retlw ' '
		retlw '5'
		retlw '!'
		retlw '!'
		retlw '!'
		;================= index = 15
		;================= size  = 8
		retlw 'S'
		retlw 'O'
		retlw 'B'
		retlw 'R'
		retlw 'E'
		retlw ' '
		retlw 'L'
		retlw 'C'
		retlw 'D'
		;================= index = 24
		;================= size  = 8
		retlw 'O'
		retlw 'P'
		retlw 'C'
		retlw 'I'
		retlw 'O'
		retlw 'N'
		retlw ' '
		retlw '#'
		retlw '2'
		;================= index = 33
		;================= size  = 6
		retlw '0'
		retlw '0'
		retlw '0'
		retlw '0'
		retlw '0'
		retlw '0'
		retlw '0'
		;================= index = 40
		;================= size  = 14
		retlw 'I'
		retlw 'n'
		retlw 'g'
		retlw '.'
		retlw ' '
		retlw 'p'
		retlw 'o'
		retlw 'r'
		retlw ' '
		retlw 'T'
		retlw 'i'
		retlw 'e'
		retlw 'm'
		retlw 'p'
		retlw 'o'
		;================= index = 55
		;================= size  = 13
		retlw 'B'
		retlw 'l'
		retlw 'o'
		retlw 'q'
		retlw 'u'
		retlw 'e'
		retlw 'a'
		retlw 'd'
		retlw 'o'
		retlw '!'
		retlw '!'
		retlw '!'
		retlw '!'
		retlw '!'
		;================= index = 69
		;================= size  = 13
		retlw 'L'
		retlw 'l'
		retlw 'a'
		retlw 'v'
		retlw 'e'
		retlw ' '
		retlw 'R'
		retlw 'o'
		retlw 'j'
		retlw 'a'
		retlw ' '
		retlw 'I'
		retlw 'D'
		retlw '!'
		;================= index = 83
		;================= size  = 13
		retlw 'B'
		retlw 'o'
		retlw 'r'
		retlw 'r'
		retlw 'a'
		retlw ' '
		retlw 'e'
		retlw 'n'
		retlw ' '
		retlw '4'
		retlw 's'
		retlw 'e'
		retlw 'g'
		retlw 's'
		;================= index = 97
		;================= size  = 13
		retlw 'M'
		retlw 'e'
		retlw 'm'
		retlw ' '
		retlw 'B'
		retlw 'o'
		retlw 'r'
		retlw 'r'
		retlw 'a'
		retlw 'd'
		retlw 'a'
		retlw '!'
		retlw '!'
		retlw '!'
		;================= index = 111
		;================= size  = 14
		retlw 'L'
		retlw 'l'
		retlw 'a'
		retlw 'v'
		retlw 'e'
		retlw ' '
		retlw 'V'
		retlw 'E'
		retlw 'R'
		retlw 'D'
		retlw 'E'
		retlw ' '
		retlw 'I'
		retlw 'D'
		retlw '!'
		;================= index = 126
		;================= size  = 14
		retlw 'U'
		retlw 't'
		retlw 'i'
		retlw 'l'
		retlw 'i'
		retlw 'c'
		retlw 'e'
		retlw ' '
		retlw 'T'
		retlw 'e'
		retlw 'c'
		retlw 'l'
		retlw 'a'
		retlw 'd'
		retlw 'o'
		;================= index = 141
		;================= size  = 11
		retlw 'O'
		retlw 'P'
		retlw 'C'
		retlw 'I'
		retlw 'O'
		retlw 'N'
		retlw ' '
		retlw '#'
		retlw ' '
		retlw '3'
		retlw ' '
		retlw ' '
		;================= index = 153
		;================= size  = 15
		retlw 'M'
		retlw 'E'
		retlw 'N'
		retlw 'U'
		retlw ' '
		retlw 'P'
		retlw 'R'
		retlw 'I'
		retlw 'N'
		retlw 'C'
		retlw 'I'
		retlw 'P'
		retlw 'A'
		retlw 'L'
		retlw ':'
		retlw ' '
		;================= index = 169
		;================= size  = 6
		retlw ' '
		retlw 'a'
		retlw ' '
		retlw 'l'
		retlw 'a'
		retlw 's'
		retlw ' '
		;================= index = 176
		;================= size  = 1
		retlw 'B'
		retlw '#'
		;================= index = 178
		;================= size  = 11
		retlw 'O'
		retlw 'P'
		retlw 'C'
		retlw 'I'
		retlw 'O'
		retlw 'N'
		retlw ' '
		retlw '#'
		retlw ' '
		retlw '1'
		retlw ' '
		retlw ' '
		;================= index = 190
		;================= size  = 13
		retlw 'S'
		retlw 'E'
		retlw 'T'
		retlw 'E'
		retlw 'A'
		retlw 'R'
		retlw ' '
		retlw 'M'
		retlw 'I'
		retlw 'N'
		retlw 'U'
		retlw 'T'
		retlw 'O'
		retlw 'S'
		;================= index = 204
		;================= size  = 16
		retlw '1'
		retlw '-'
		retlw 'O'
		retlw 'P'
		retlw '1'
		retlw ' '
		retlw '2'
		retlw '-'
		retlw 'O'
		retlw 'P'
		retlw '2'
		retlw ' '
		retlw '3'
		retlw '-'
		retlw 'O'
		retlw 'P'
		retlw '3'
		;================= index = 219
		;================= size  = 8
		retlw 'E'
		retlw 'F'
		retlw 'E'
		retlw 'C'
		retlw 'T'
		retlw ':'
		retlw ' '
		retlw '$'
		retlw ' '
;-----------------------------------------------------------------------------------------------------------------------------------

;=========================================================================
;TABLA DE DECODIFICACIÓN BINARIO => ASCII
;=========================================================================
ascii		addwf PCL,1
		retlw '1'
		retlw '2'
		retlw '3'
		retlw 'A'
		retlw '4'
		retlw '5'
		retlw '6'
		retlw 'B'
		retlw '7'
		retlw '8'
		retlw '9'
		retlw 'C'
		retlw '*'		
		retlw '0'
		retlw '#'
		retlw 'D'

;=========================================================================
;inicia Display de Cristal Líquido

ini_lcd		call dem_100ms
		bcf 7,e				;E = 0 (LCD ihabilitado E = 0)
		bcf 5,rs				;RS = 0 (Modo de Instrucciones)

		;INICIO DE LA SECUENCIA DE RESET DEL CRISTAL

		call dem_5ms			;demora de power UP
		movlw 0x38
		movwf 8
		call pulse			;enable
		call dem_40us

		;FIN DE SECUENCIA DE RESET DEL CRISTAL
		
		;*******************
		;FUNCTION SET INST
		;*******************
		;Modo de transferencia de Datos: 8 bits
		;Display en 2 líneas
		;Matriz de 5x7 puntos

		movlw 0x38			;funtion set = 38h		
		movwf 8
		call pulse			;pulso de 1us en "E"
		call dem_40us			;demora de 40 us

		;****************************
		;DISPLAY ON/OFF CONTROL
		;****************************
		;display ON
		;cursor ON
		;cursor parpadea
		movlw b'00001100'
		;movlw 0x0e			;display ON/OFF control = 0ch
		movwf 8
		call pulse			;pulso de 1us en "E"
		call dem_40us	

		;****************************
		;ENTRY MODE SET INST
		;****************************
		;La posición del cursor se incrementa (direcciones de la DD RAM)
		;No desplazar el Dato
			
		movlw 6				;entry mode set = 6
		movwf 8
		call pulse			;pulso de 1us en "E"
		call dem_40us		


		;****************************
		;DISPLAY CLEAR
		;****************************
		;limpia la RAM de display y pone el cursor en la posisción cero
			
		movlw 1				;display clear = 1
		movwf 8
		call pulse			;pulso de 1us en "E"
		call dem_1640us			

		;****************************
		;RAM A LA 80H
		;****************************
		;limpia la RAM de display y pone el cursor en la posisción cero
			
		movlw 0x80			;display clear = 1
		movwf 8
		call pulse			;pulso de 1us en "E"
		call dem_40us			

		bsf 5,rs			;modo datos
		return
;=========================================================================
;limpia display
clrdisp		bcf 5,rs
		movlw 1				;display clear = 1
		movwf 8
		call pulse			;pulso de 1us en "E"
		call dem_1640us			
		bsf 5,rs				;modo datos
		return
;=========================================================================
;habilita display (da un pulso en el pin enable)
pulse		bcf 7,e
		bsf 7,e				;E = 1
		nop
		nop
		nop
		nop				;demora de 1 us
		bcf 7,e				;E = 0
		return
;=========================================================================
;cambia de dirección en el display
;requisitos: cargar previamente la dirección en WREG
;ej: movlw 0xc2	;dir a donde se desea cambiar.
;     call chdir
chdir		bcf 5,rs			;modo comandos
		movwf 8			;la dirección viene en el acumulador
		call pulse
		call dem_40us
		bsf 5,rs
		return
;=========================================================================
;escribe cualquier cartel en el LCD por el método de indexado de TABLA
;antes de llamarla deben cargarse las variables "index" y "size"
write		clrf ch_cont			;contador de caracteres del
		;clrf PCLATH			;cartel que se está sacando
next_char		movf index,w		;indexo
		call tabla			;tabla de caracteres del cartel
		movwf 8			;saco caracter
		call pulse			;pulso enable
		call dem_40us		;demora de ejecución
		movf ch_cont,w
		subwf size,w		;resta ch_cont del size
		btfsc 3,2
		return			;RETORNA, se escribió completo
		;próximo caracter del cartel
		incf index
		incf ch_cont
		goto next_char	

;=========================================================================
;subrutinas de demora para LCD y otros fines
;--------------------------------------------------
;DEMORA DE 5.32 ms

dem_5ms		movlw d'60'
		movwf N		;parámetro a cargar en contadores
		movlw d'5'
		movwf M		;parámetro a cargar en contadores
		call demora		;demora de 47us
		return
;--------------------------------------------------
;DEMORA DE 1s aprox
;--------------------------------------------------	

dem_1s		movlw d'80'
		movwf N		;parámetro a cargar en contadores
		movlw d'128'
		movwf M		;parámetro a cargar en contadores
		call demora		;demora de 47us
		return
;--------------------------------------------------
;DEMORA DE 1.64MS (1640 US)
;--------------------------------------------------	

dem_1640us	movlw d'46'
		movwf N		;parámetro a cargar en contadores
		movlw d'1'
		movwf M		;parámetro a cargar en contadores
		call demora		;demora de 47us
		return
;--------------------------------------------------
;DEMORA DE 100ms
;--------------------------------------------------	

dem_100ms		movlw d'100'
		movwf N		;parámetro a cargar en contadores
		movlw d'15'
		movwf M		;parámetro a cargar en contadores
		call demora		;demora de 47us
		return
;--------------------------------------------------
;DEMORA DE 50ms
;--------------------------------------------------	

dem_50ms		movlw d'67'
		movwf N		;parámetro a cargar en contadores
		movlw d'14'
		movwf M		;parámetro a cargar en contadores
		call demora		;demora de 47us
		return
;--------------------------------------------------
;DEMORA DE 47US*
;--------------------------------------------------	

dem_40us		movlw d'8'
		movwf N		;parámetro a cargar en contadores
		movlw d'1'
		movwf M		;parámetro a cargar en contadores
		call demora		;demora de 47us
		return
;--------------------------------------------------
;subrutina de DEMORA paramétrica general
;--------------------------------------------------
demora		;return
		movf N,w
		movwf cont1
		movwf cont2
		movf M,w
		movwf cont3
loop		decfsz cont1
		goto loop
		movf N,w
		movwf cont1
		decfsz cont2
		goto loop
		movf N,w
		movwf cont2
		decfsz cont3
		goto loop
		;fin del proceso, inicia contadores
		return
;===========================================================
		;subrutina que ESCANEA un Teclado Matricial de 4 X 4 teclas.

teclado		clrf	tecla		;esquina sup izquierda
		clrf	k_flag		;no tecla
		movlw b'11110111'		;patron inicial de filas
		movwf 6
		;columnas rb3 .... rb0
scancol		btfss	6,7
		goto sitecla
		incf	tecla
		btfss	6,6
		goto sitecla
		incf	tecla
		btfss	6,5
		goto sitecla
		incf	tecla
		btfss	6,4
		goto sitecla
		incf	tecla
		;pregunto si estoy testeando la última tecla
		movf	tecla,w
		sublw	d'16'
		btfss	3,2
		goto 	next
		;sí, es la última
		bcf	k_flag,0		;indico que no hubo tecla
		return
sitecla		bsf	k_flag,0		;indico que hubo tecla
		return
next		;pasar a la próxima fila
		bsf	3,0		;setea acarreo
		rrf	6
		goto scancol

;===========================================================
;Programa Principal (BLOQUE DE CONFIGURACIÓN DE HARDWARE)
;===========================================================
inicio  		bcf 3,5
		bcf 3,6			;banco 0
		;===========================================================
		;BLOQUE QUE DEFINE LAS CONDICIONES INICIALES DEL SISTEMA
		;Y CONFIGURA LOS REGISTROS DE CONTROL.
		;===========================================================
		;condiciones iniciales del sistema

		;---------------------------------------------------------------------------------------------
		;definicion de E/S

		bsf 3,5		;banco 1
				;banco 1
		clrf 8		;Bus de Datos (puerto D)

		bcf 7,0		;pin enable
		bcf 5,4		;pin RS
		bcf 5,5		;activación de backlight

		movlw 0xf0
		movwf 6		;conexión teclado matricial

		;-------------------------------------------------------------------------------------------------------------------	
		;definición de líneas digitales
	
		movlw 7			;líneas digitales
		movwf ADCON1

		;-------------------------------------------------------------------------------------------------------------------				
		;pull ups habilitado.

		bcf OPTION_REG,7
		;-------------------------------------------------------------------------------------------------------------------						
		bcf 3,5			;banco 0
		;-------------------------------------------------------------------------------------------------------------------						
		;inicia el LCD
		call ini_lcd		;inicia el lcd
		;-------------------------------------------------------------------------------------------------------------------						
		bsf 5,5		;enc backlight
;===========================================================
;BLOQUE DEL PROGRAMA PRINCIPAL
;===========================================================
		;cartel de presentación (prueba)
		;"Practica # 5"
		clrf index		;index = 0
		movlw d'14'
		movwf size		;size = 14
		call write
		; demora de exhibición
		call dem_1s
		call dem_1s
		call dem_1s
		call dem_1s
		call dem_1s
		call dem_1s
		;prox cartel
		call clrdisp		;limpia display
		;----------------------------------------------------------------------
		;cartel de presentación (prueba)
		;"sobre LCD"
		movlw d'15'
		movwf index	;index = 15
		movlw d'8'
		movwf size		;size = 8
		call write
		call dem_1s
		call dem_1s
		call dem_1s
		call dem_1s
		call dem_1s
		call dem_1s
		;----------------------------------------------------------------------
		;----------------------------------------------------------------------
		;prox cartel
mainmenu		call clrdisp		;limpia display
		;cartel de presentación (prueba)
		;----------------------------------------------------------------------
		;"MENU PRINCIPAL"
		;poner dirección
		movlw 0x81
		call chdir		;empieza en la 81
		;escritura del cartel
		movlw d'153'
		movwf index	;index = 15
		movlw d'15'
		movwf size		;size = 8
		call write
		;----------------------------------------------------------------------
		;poner dirección
		movlw 0xC0
		call chdir	
		;escritura del cartel
		movlw d'204'
		movwf index	;index = 15
		movlw d'16'
		movwf size		;size = 8
		call write
		;----------------------------------------------------------------------
		;LEER teclado
		;hacer ejecución de segmentos
scantec1		call teclado
		btfss k_flag,0
		goto scantec1
		;tecla pulsada
		;identficarla
		;pregunto por "1"
		movf tecla,w
		btfsc 3,2
		goto opcion1
		;pregunto por el "2"
		movf tecla,w
		sublw 1
		btfsc 3,2
		goto opcion2
		;pregunto por "3"
		movf tecla,w
		sublw 2
		btfss 3,2
		goto scantec1
		;-----------------------------------------------------------------------
		;opción 3
		call clrdisp
		;cartel opcion 3
		;poner dirección
		movlw 0x83
		call chdir	
		;escritura del cartel
		movlw d'141'
		movwf index	;index = 141
		movlw d'11'
		movwf size		;size = 11
		call write
		;esperar salida
scantec2		call teclado
		btfss k_flag,0	;bandera de tecla pulsada
		goto scantec2
		;hay tecla, ver si es #
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto mainmenu
		call dem_100ms
		goto scantec2
		;-----------------------------------------------------------------------
		;opción 1
opcion1	call clrdisp
		;cartel opcion 1
		;poner dirección
		movlw 0x83
		call chdir	
		;escritura del cartel
		movlw d'178'
		movwf index	;index = 178
		movlw d'11'
		movwf size		;size = 11
		call write
		;----------------------------------------------------------------
		;submenu

		;esperar salida
scantec3	call teclado
		btfss k_flag,0	;bandera de tecla pulsada
		goto scantec3
		;hay tecla, ver si es #
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto mainmenu
		call dem_100ms
		goto scantec3

		;-----------------------------------------------------------------------
		;opción 2
opcion2		call clrdisp
		;cartel opcion 2
		;poner dirección
		movlw 0x83
		call chdir	
		;escritura del cartel
		movlw d'24'
		movwf index	;index = 24
		movlw d'8'
		movwf size		;size = 8
		call write
		;esperar salida
scantec4		call teclado
		btfss k_flag,0	;bandera de tecla pulsada
		goto scantec4
		;hay tecla, ver si es #
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto mainmenu
		call dem_100ms
		goto scantec4

scan1		goto scan1
		end
