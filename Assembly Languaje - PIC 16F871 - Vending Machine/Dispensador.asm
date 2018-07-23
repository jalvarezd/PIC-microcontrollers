	list p=16f871
	#include <p16f871.inc>
;==============================================================================================
;DISPENSADOR DE BEBIDAS
;UTILIZANDO TECLADO MATRICIAL, PANTALLA LCD 2X16, MENUS DE APLICACIONES
;==============================================================================================
;Alumnos: 	Julio Alvarez
;			Stalin Herrera
;			Esteban Morales
;(todos los derechos reservados, 2008)
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;Nota: 	El código aquí propuesto se ha generado con intenciones docentes y se encuentra adecuada al Hardware de Entrenamiento
;	propuesto (v 1.01), por lo que no se garantiza su funcionamiento en otra plataforma que utilice distintos recursos de HW
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;FUNCIONAMIENTO:
;Se presentan dos carteles introductorios
;Mediante el teclado se puede acceder a la bebida deseada ya sea por su codigo (ejem: 5 = gaseosa) o por botones predeterminados (si existe esa bebida predeterminada)
;Mediante los menus se puede acceder a toda la lista de las bebidas existentes, consultas de ventas y nivel de los tanques de deposito
;Para salir de cualquier menu o submenu se pulsa la tecla ESC
;============================================================================
;ZONA DE DECLARACIÓN DE SÍMBOLOS Y VARIABLES.
;============================================================================

;contadores para demoras.

cont1		equ 	0x20	;contadores para demora
cont2		equ 	0x21
cont3		equ 	0x22

;multiplicadores para demora

N		equ 	0x23	;factores de demora
M		equ		0x24	

;otras variables

index		equ		0x25	;índice de tabla de códigos 7 segmentos de los números.
temp		equ		0x26	;varible temporal auxiliar.
veces		equ 	0x27	;veces de conteo
size		equ 	0x28	;tamaño del cartel
ch_cont		equ 	0x29	;cntador de caracteres para cartel
tecla		equ 	0x2a	;contador de teclas
k_flag		equ 	0x2b	;bandera de tecla pulsada

;variables de conteo licor
uno			equ		0x2c
dos			equ     0x2d
tres		equ		0x2e
cuatro		equ		0x2f
cinco		equ		0x30

;variables de nivel de tanques
tanka		equ  	0x31
tankb		equ     0x32
tankc		equ		0x33
tankd		equ		0x34
;variables de la EEPROM
dato_w		equ     0x35
dato_r		equ     0x36
dir			equ		0x37

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
		;================= size  = 10
		retlw 'U'
		retlw 'N'
		retlw 'I'
		retlw 'V'
		retlw 'E'
		retlw 'R'
		retlw 'S'
		retlw 'I'
		retlw 'D'
		retlw 'A'
		retlw 'D'
		;================= index = 11
		;================= size  = 8
		retlw 'D'
		retlw 'E'
		retlw 'L'
		retlw ' '
		retlw 'A'
		retlw 'Z'
		retlw 'U'
		retlw 'A'
		retlw 'Y'
		;================= index = 20
		;================= size  = 10
		retlw 'D'
		retlw 'I'
		retlw 'S'
		retlw 'P'
		retlw 'E'
		retlw 'N'
		retlw 'S'
		retlw 'A'
		retlw 'D'
		retlw 'O'
		retlw 'R'
		;================= index = 31
		;================= size  = 13
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
		;================= index = 45
		;================= size  = 6
		retlw '1'
		retlw ' '
		retlw 'L'
		retlw 'I'
		retlw 'S'
		retlw 'T'
		retlw 'A'
		;================= index = 52
		;================= size  = 10
		retlw '2'
		retlw ' '
		retlw 'C'
		retlw 'O'
		retlw 'N'
		retlw 'S'
		retlw 'U'
		retlw 'L'
		retlw 'T'
		retlw 'A'
		retlw 'S'
		;================= index = 63
		;================= size  = 9
		retlw '1'
		retlw ' '
		retlw 'R'
		retlw 'O'
		retlw 'N'
		retlw ' '
		retlw 'P'
		retlw 'U'
		retlw 'R'
		retlw 'O'
		;================= index = 73
		;================= size  = 11
		retlw '2'
		retlw ' '
		retlw 'C'
		retlw 'U'
		retlw 'B'
		retlw 'A'
		retlw ' '
		retlw 'L'
		retlw 'I'
		retlw 'B'
		retlw 'R'
		retlw 'E'
		;================= index = 85
		;================= size  = 13
		retlw '3'
		retlw ' '
		retlw 'O'
		retlw 'R'
		retlw 'A'
		retlw 'N'
		retlw 'G'
		retlw 'E'
		retlw ' '
		retlw 'V'
		retlw 'O'
		retlw 'D'
		retlw 'K'
		retlw 'A'
		;================= index = 99
		;================= size  = 10
		retlw '4'
		retlw ' '
		retlw 'N'
		retlw 'A'
		retlw 'R'
		retlw 'A'
		retlw 'N'
		retlw 'J'
		retlw 'A'
		retlw 'D'
		retlw 'A'
		;================= index = 110
		;================= size  = 8
		retlw '5'
		retlw ' '
		retlw 'G'
		retlw 'A'
		retlw 'S'
		retlw 'E'
		retlw 'O'
		retlw 'S'
		retlw 'A'
		;================= index = 119
		;================= size  = 15
		retlw '1'
		retlw ' '
		retlw 'U'
		retlw 'N'
		retlw 'I'
		retlw ' '
		retlw 'D'
		retlw 'I'
		retlw 'S'
		retlw 'P'
		retlw 'E'
		retlw 'N'
		retlw 'S'
		retlw 'A'
		retlw 'D'
		retlw 'A'
		;================= index = 135
		;================= size  = 9
		retlw '2'
		retlw ' '
		retlw 'R'
		retlw 'E'
		retlw 'S'
		retlw 'E'
		retlw 'R'
		retlw 'V'
		retlw 'A'
		retlw 'S'
		;================= index = 145
		;================= size  = 9
		retlw '1'
		retlw ' '
		retlw 'T'
		retlw 'A'
		retlw 'N'
		retlw 'Q'
		retlw 'U'
		retlw 'E'
		retlw ' '
		retlw 'A'	
		;================= index = 155
		;================= size  = 9
		retlw '2'
		retlw ' '
		retlw 'T'
		retlw 'A'
		retlw 'N'
		retlw 'Q'
		retlw 'U'
		retlw 'E'
		retlw ' '
		retlw 'B'
		;================= index = 165
		;================= size  = 9
		retlw '3'
		retlw ' '
		retlw 'T'
		retlw 'A'
		retlw 'N'
		retlw 'Q'
		retlw 'U'
		retlw 'E'
		retlw ' '
		retlw 'C'
		;================= index = 175
		;================= size  = 9
		retlw '4'
		retlw ' '
		retlw 'T'
		retlw 'A'
		retlw 'N'
		retlw 'Q'
		retlw 'U'
		retlw 'E'
		retlw ' '
		retlw 'D'
		;================= index = 185
		;================= size  = 12
		retlw 'N'
		retlw 'I'
		retlw 'V'
		retlw 'E'
		retlw 'L'
		retlw ' '
		retlw 'B'
		retlw 'A'
		retlw 'J'
		retlw 'O'
		retlw '!'
		retlw '!'
		retlw '!'
		;================= index = 198
		;================= size  = 11
		retlw 'S'
		retlw 'I'
		retlw 'R'
		retlw 'V'
		retlw 'I'
		retlw 'E'
		retlw 'N'
		retlw 'D'
		retlw 'O'
		retlw '.'
		retlw '.'
		retlw '.'
		;================= index = 210
		;================= size  = 12
		retlw 'N'
		retlw 'O'
		retlw ' '
		retlw 'D'
		retlw 'I'
		retlw 'S'
		retlw 'P'
		retlw 'O'
		retlw 'N'
		retlw 'I'
		retlw 'B'
		retlw 'L'
		retlw 'E'
		;================= index = 223
		;================= size  = 9
		retlw 'S'
		retlw 'E'
		retlw 'L'
		retlw 'E'
		retlw 'C'
		retlw 'C'
		retlw 'I'
		retlw 'O'
		retlw 'N'
		retlw 'E'
		;================= index = 233
		;================= size  = 5
		retlw 'B'
		retlw 'E'
		retlw 'B'
		retlw 'I'
		retlw 'D'
		retlw 'A'
				
;-----------------------------------------------------------------------------------------------------------------------------------

;=========================================================================
;TABLA DE DECODIFICACIÓN BINARIO => ASCII
;=========================================================================
ascii		addwf PCL,1
		retlw '0'
		retlw '1'
		retlw '2'
		retlw '3'
		retlw '4'
		retlw '5'
		retlw '6'
		retlw '7'
		retlw '8'
		retlw '9'
				
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
;=====================================================================================
;SUBRUTINAS EEPROM
;=====================================================================================
;Escribe en el EEPROM de datos
w_eeprom		bsf	3,6
				bsf 3,5		;banco 3
wait	btfsc	EECON1,WR
		goto wait
		;comienza el proceso de una nueva escritura
		;banco 0
		;rescata direccion en donde se escribira
		bcf 3,5
		bcf 3,6
		movf dir,w
		;banco 2
		;carga direccion a EEADR
		bcf	3,5
		bsf 3,6
		movwf EEADR		;EEADR = dir
		;banco 0
		;rescata dato a escribir
		bcf	3,5
		bcf	3,6
		movf dato_w,w
		;carga dato en EEDATA
		;banco 2
		bcf 3,5
		bsf	3,6
		movwf EEDATA	;EEDATA = dato_w
		;banco 3
		;selecciona la memoria en este caso EEPROM
		;Habilita la escritura
		bsf 3,5
		bsf 3,6
		bcf EECON1,EEPGD		;EEPGD = 0 (EEPROM)
		bsf EECON1,WREN			;WREN = 1 (Esc. Habilitada)
		;Segmento recomendado por el fabricante
	;	bcf INTCON,7
		;Secuencia necesaria para sincronia
		movlw	0x55
		movwf	EECON2
		movlw	0xAA
		movwf	EECON2
		;inica escritura
		bsf EECON1,WR			;WR = 1 (Inicia escritura)
		;Habilita las INTS 
	;	bsf INTCON,7			;Habilita las INTS nuevamente
		;Inhabilita la escritura
		bcf	EECON1,WREN			;WREN = 0 (Esc. Inhab.)
		;regresa a banco 0
		bcf 3,5
		bcf 3,6
		return
;Lee la EEPROM DE DATOS
r_eeprom	;banco 0
			;rescata la direccion que debe leerse
			bcf 3,5
			bcf	3,6
			movf	dir,w		; w = dir
			;banco2
			;se carga registro EEADR
			bcf 3,5
			bsf 3,6
			movwf EEADR			; EEADR = dir
			;banco 3
			;selecciona la EEPROM
			;inicia la lectura
			bsf 3,5
			bcf EECON1,EEPGD
			bsf	EECON1,RD
			nop
			;banco 2
			;rescata dato desde EEDATA
			bcf 3,5
			bsf 3,6
			movf EEDATA,W
			;banco 0
			;carga el dato leido en la variable de salida "dato_r)
			bcf 3,5
			bcf 3,6
			movwf dato_r
			return				;retorna con el dato leido		
		
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
		
		bcf 5,0		;pines para control de motores
		bcf 5,1
		bcf 5,2
		bcf 5,3
		bcf 5,5		;PIN BACKLIGHT	

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
		clrf uno 
		clrf dos
		clrf tres
		clrf cuatro
		clrf cinco
		clrf tanka
		clrf tankb
		clrf tankc
		clrf tankd
		
		;cartel de presentación (inicio)
		;UNIVERSIDAD
presen	call clrdisp
		movlw 0x83
		call chdir		;empieza en 83
		clrf index		;index = 0
		movlw d'10'
		movwf size		;size = 10
		call write
		;----------------------------------------------------------------------
		;cartel de presentación (inicio)
		;"DEL AZUAY"
		movlw 0xc4
		call chdir		;empieza en C4
		movlw d'11'
		movwf index	    ;index = 11
		movlw d'8'
		movwf size		;size = 8
		call write
		; demora de exhibición
		call dem_1s
		call dem_1s
		;prox cartel
		call clrdisp	
		;----------------------------------------------------------------------		
		;cartel de presentación (inicio)
		;"DISPENSADOR"
		movlw 0x83
		call chdir		;empieza en 83
		movlw d'20'
		movwf index	;index = 20
		movlw d'10'
		movwf size		;size = 10
		call write
		;----------------------------------------------------------------------
		;----------------------------------------------------------------------
		;LEER teclado
		;hacer ejecución de segmentos
scantec1		call teclado
		btfss k_flag,0
		goto scantec1
		;tecla pulsada
		;identficarla
		;pregunto por el "1"
		movf tecla,w
		btfsc 3,2
		goto opcion1
		;pregunto por el "2"
		movf tecla,w
		sublw 1
		btfsc 3,2
		goto opcion2
		;pregunto por el "3"
		movf tecla,w
		sublw 2
		btfsc 3,2
		goto opcion3
		;pregunto por el "A"
		movf tecla,w
		sublw 3
		btfsc 3,2
		goto opcionA
		;pregunto por el "4"
		movf tecla,w
		sublw 4
		btfsc 3,2
		goto opcion4
		;pregunto por el "5"
		movf tecla,w
		sublw 5
		btfsc 3,2
		goto opcion5
		;pregunto por el "6"
		movf tecla,w
		sublw 6
		btfsc 3,2
		goto opcion6
		;pregunto por el "B"
		movf tecla,w
		sublw 7
		btfsc 3,2
		goto opcionB	
		;pregunto por el "7"
		movf tecla,w
		sublw 8
		btfsc 3,2
		goto opcion7		
		;pregunto por el "8"
		movf tecla,w
		sublw 9
		btfsc 3,2
		goto opcion8
		;pregunto por el "9"
		movf tecla,w
		sublw d'10'
		btfsc 3,2
		goto opcion9
		;pregunto por el "C"
		movf tecla,w
		sublw d'11'
		btfsc 3,2
		goto opcionC	
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto opcioncancel
		;pregunto por el "0"
		movf tecla,w
		sublw d'13'
		btfsc 3,2
		goto opcion0
		;pregunto por el "MENU"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto opcionmenu
		;pregunto por el "START"
		movf tecla,w
		sublw d'15'
		btfss 3,2
		goto scantec1			
;-----------------------------------------------------------------------
;OPCIONES DEL ESCANEO PRINCIPAL
;-----------------------------------------------------------------------
		;opción START
		call clrdisp
		;cartel opcion START
		;direccion del cartel
		movlw 0x83
		call chdir
		;escritura del cartel
		;SELECCIONE
		movlw d'223'
		movwf index	;index = 223
		movlw d'9'
		movwf size		;size = 9
		call write
		;escritura del cartel
		;BEBIDA
		;direccion del cartel
		movlw 0xc5
		call chdir		
		movlw d'233'
		movwf index	;index = 233
		movlw d'5'
		movwf size		;size = 5
		call write
		call dem_1s
		call dem_1s
		call dem_1s
		call dem_1s
		goto presen
		;-----------------------------------------------------------------------
		;opción 1
opcion1	call clrdisp
		;cartel opcion 1
		;1 RON PURO
		;escritura del cartel
		movlw d'63'
		movwf index	;index = 63
		movlw d'9'
		movwf size		;size = 11
		call write
		;----------------------------------------------------------------
		;esperar accion
scan1	call teclado
		btfss k_flag,0	;bandera de tecla pulsada
		goto scan1
		;hay tecla, ver si es CANCEL
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "START"
		movf tecla,w
		sublw d'15'
		btfss 3,2
		goto scan1
		
		call clrdisp
		;cartel SIRVIENDO.....
		;direccion del cartel
		movlw 0x81
		call chdir
		;escritura del cartel
		movlw d'198'
		movwf index	;index = 198
		movlw d'11'
		movwf size		;size = 11
		call write
		bsf 5,0			;habilita pin Ra0
		incf uno		;incrementa cantidad vendida
		
		movlw 0x20		;se gurada dato en la EEPROM (0X20)
		movwf dir
		movlw uno
		movwf dato_w	

		call dem_1s
		call dem_1s
		call dem_1s
		bcf 5,0			;deshabilita pin Ra0
		goto presen	
		
		;-----------------------------------------------------------------------
		;opción 2
opcion2		call clrdisp
		;cartel opcion 2
		;2 CUBA LIBRE
		;escritura del cartel
		movlw d'73'
		movwf index	;index = 73
		movlw d'11'
		movwf size		;size = 11
		call write
		;----------------------------------------------------------------
		;esperar accion
scan2	call teclado
		btfss k_flag,0	;bandera de tecla pulsada
		goto scan2
		;hay tecla, ver si es CANCEL
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "START"
		movf tecla,w
		sublw d'15'
		btfss 3,2
		goto scan2
		
		call clrdisp
		;cartel SIRVIENDO...
		;direccion del cartel
		movlw 0x81
		call chdir
		;escritura del cartel
		;SIRVIENDO...
		movlw d'198'
		movwf index	;index = 198
		movlw d'11'
		movwf size		;size = 11
		call write
		bsf 5,0			;habilita pin Ra0
		incf dos		;incrementa cantidad vendida

		movlw 0x21		;se gurada dato en la EEPROM (0X21)
		movwf dir
		movlw dos
		movwf dato_w	
		
		call dem_1s
		call dem_1s
		call dem_1s
		bcf 5,0			;deshabilita pin Ra0
		
		bsf 5,1			;habilita pin Ra1
		call dem_1s
		call dem_1s
		call dem_1s
		bcf 5,1			;deshabilita pin Ra1			
		goto presen	
		;----------------------------------------------------------------	
		;opción 3
opcion3	call clrdisp
		;cartel opcion 3
		;3 ORANGE VODKA
		;escritura del cartel
		movlw d'85'
		movwf index	;index = 85
		movlw d'13'
		movwf size		;size = 13
		call write
		;----------------------------------------------------------------
		;esperar accion
scan3	call teclado
		btfss k_flag,0	;bandera de tecla pulsada
		goto scan3
		;hay tecla, ver si es CANCEL
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "START"
		movf tecla,w
		sublw d'15'
		btfss 3,2
		goto scan3
		
		call clrdisp
		;cartel SIRVIENDO...
		;direccion del cartel
		movlw 0x81
		call chdir
		;escritura del cartel
		;SIRVIENDO
		movlw d'198'
		movwf index	;index = 198
		movlw d'11'
		movwf size		;size = 11
		call write
		bsf 5,2			;habilita pin Ra2
		incf tres		;incrementa cantidad vendida

		movlw 0x22		;se gurada dato en la EEPROM (0X22)
		movwf dir
		movlw tres
		movwf dato_w
		
		call dem_1s
		call dem_1s
		call dem_1s
		bcf 5,2			;deshabilita pin Ra2
		
		bsf 5,3			;habilita pin Ra3
		call dem_1s
		call dem_1s
		call dem_1s
		bcf 5,3			;deshabilita pin Ra3			
		goto presen	
		;----------------------------------------------------------------
		;opción 4
opcion4	call clrdisp
		;cartel opcion 4
		;4 NARANJADA
		;escritura del cartel
		movlw d'99'
		movwf index	;index = 99
		movlw d'10'
		movwf size		;size = 10
		call write
		;----------------------------------------------------------------
		;esperar accion
scan4	call teclado
		btfss k_flag,0	;bandera de tecla pulsada
		goto scan4
		;hay tecla, ver si es CANCEL
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "START"
		movf tecla,w
		sublw d'15'
		btfss 3,2
		goto scan4
		
		call clrdisp
		;cartel SIRVIENDO...
		;direccion del cartel
		movlw 0x81
		call chdir
		;escritura del cartel
		;SELECCIONE
		movlw d'198'
		movwf index	;index = 198
		movlw d'11'
		movwf size		;size = 11
		call write
		bsf 5,3			;habilita pin Ra3
		incf cuatro		;incrementa cantidad vendida

		movlw 0x23		;se gurada dato en la EEPROM (0X23)
		movwf dir
		movlw cuatro
		movwf dato_w	

		call dem_1s
		call dem_1s
		call dem_1s
		call dem_1s
		bcf 5,3			;deshabilita pin Ra3			
		goto presen	
		;----------------------------------------------------------------
		;opción 5
opcion5	call clrdisp
		;cartel opcion 5
		;5 GASEOSA
		;escritura del cartel
		movlw d'110'
		movwf index	;index = 110
		movlw d'8'
		movwf size		;size = 8
		call write
		;----------------------------------------------------------------
		;esperar accion
scan5	call teclado
		btfss k_flag,0	;bandera de tecla pulsada
		goto scan5
		;hay tecla, ver si es CANCEL
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "START"
		movf tecla,w
		sublw d'15'
		btfss 3,2
		goto scan5
		
		call clrdisp
		;cartel SIRVIENDO...
		;direccion del cartel
		movlw 0x81
		call chdir
		;escritura del cartel
		;SELECCIONE
		movlw d'198'
		movwf index	;index = 198
		movlw d'11'
		movwf size		;size = 11
		call write
		bsf 5,1			;habilita pin Ra1
		incf cinco		;incrementa cantidad vendida

		movlw 0x24		;se gurada dato en la EEPROM (0X21)
		movwf dir
		movlw cinco
		movwf dato_w
	
		call dem_1s
		call dem_1s
		call dem_1s
		call dem_1s
		bcf 5,1			;deshabilita pin Ra1			
		goto presen	
		;----------------------------------------------------------------
		;opción 6
opcion6 call clrdisp
		;cartel opcion 6
		;NO DISPONIBLE
		;direccion de cartel
		movlw 0x82
		call chdir		; empieza 82
		;escritura del cartel
		movlw d'210'
		movwf index	;index = 210
		movlw d'12'
		movwf size		;size = 12
		call write
		;esperar salida
scanout	call teclado
		btfss k_flag,0	;bandera de tecla pulsada
		goto scanout
		;hay tecla, ver si es CANCEL
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;----------------------------------------------------------------
		;opción 7
opcion7 call clrdisp
		;cartel opcion 6
		;NO DISPONIBLE
		;direccion de cartel
		movlw 0x82
		call chdir		; empieza 82
		;escritura del cartel
		movlw d'210'
		movwf index	;index = 210
		movlw d'12'
		movwf size		;size = 12
		call write
		;esperar salida
		call scanout	
		;----------------------------------------------------------------
		;opción 8
opcion8 call clrdisp
		;cartel opcion 6
		;NO DISPONIBLE
		;direccion de cartel
		movlw 0x82
		call chdir		; empieza 82
		;escritura del cartel
		movlw d'210'
		movwf index	;index = 210
		movlw d'12'
		movwf size		;size = 12
		call write
		;esperar salida
		call scanout
		;----------------------------------------------------------------
		;opción 9
opcion9 call clrdisp
		;cartel opcion 6
		;NO DISPONIBLE
		;direccion de cartel
		movlw 0x82
		call chdir		; empieza 82
		;escritura del cartel
		movlw d'210'
		movwf index	;index = 210
		movlw d'12'
		movwf size		;size = 12
		call write
		;esperar salida
		call scanout
		;----------------------------------------------------------------
		;opción 0
opcion0 call clrdisp
		;cartel opcion 6
		;NO DISPONIBLE
		;direccion de cartel
		movlw 0x82
		call chdir		; empieza 82
		;escritura del cartel
		movlw d'210'
		movwf index	;index = 210
		movlw d'12'
		movwf size		;size = 12
		call write
		;esperar salida
		call scanout	
		;----------------------------------------------------------------
		;OPCIONES PREDETERMINADAS
		;opción A
opcionA call clrdisp
		call opcion2
		;----------------------------------------------------------------
		;opción B
opcionB call clrdisp
		call opcion3
		;----------------------------------------------------------------
		;opción C
opcionC call clrdisp
		call opcion1
		;----------------------------------------------------------------
		;opción CANCEL
opcioncancel call clrdisp
		;cartel opcion 6
		;NO DISPONIBLE
		;direccion de cartel
		movlw 0x82
		call chdir		; empieza 82
		;escritura del cartel
		movlw d'210'
		movwf index	;index = 210
		movlw d'12'
		movwf size		;size = 12
		call write
		;esperar salida
		call scanout
		;----------------------------------------------------------------
		;opción menu
opcionmenu call clrdisp
		;cartel opcion MENU
		;MENU PRINCIPAL
		;escritura del cartel presentacion menu
		movlw d'31'
		movwf index	;index = 31
		movlw d'13'
		movwf size		;size = 13
		call write
		;---------------------------------------------------------------
		;direccion cartel 1 LISTA	
		;direccion del cartel
		movlw 0xc0
		call chdir		; empieza c0
		;escritura cartel
		movlw d'45'
		movwf index	;index = 45
		movlw d'6'
		movwf size		;size = 6
		call write
		;cartel cursor
		call dem_100ms
		movlw 0xce
		call chdir
		movlw '<'
		movwf 8
		call dem_40us
		call pulse
		call dem_40us
		call dem_100ms
		;esperar accion
scantec3		call teclado
		btfss k_flag,0
		goto scantec3
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "ENTER"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto opcionlista
		;pregunto por el "8 (abajo)"
		movf tecla,w
		sublw 9
		btfss 3,2
		goto scantec3
		;-----------------------------------------------------------
		call clrdisp
		;cartel de presentación (segunda pantalla menu)
		;direccion del cartel 2 CONSULTAS 
		;escritura cartel
		movlw d'52'
		movwf index	    ;index = 52
		movlw d'10'
		movwf size		;size = 10
		call write
		;cartel cursor
		call dem_1s
		movlw 0x8e
		call chdir
		movlw '<'
		movwf 8
		call dem_40us
		call pulse
		call dem_40us
		call dem_100ms
		;esperar accion
scantec4	call teclado
		btfss k_flag,0
		goto scantec4
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "ENTER"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto opcionconsultas
		;pregunto por el "2 (arriba)"
		movf tecla,w
		sublw 1
		btfss 3,2
		goto scantec4
		call opcionmenu
		call dem_1s
;-----------------------------------------------------------------------------------------------------
;OPCIONES DEL MENU PRINCIPAL
;-----------------------------------------------------------------------------------------------------
		;MUESTRA EL SUBMENU LISTA DE BEBIDAS
opcionlista		call clrdisp
		;cartel opcion LISTA
		;----------------------------------------------------------------------------
		;PANTALLA LISTA / 1 RON PURO
		;----------------------------------------------------------------------------
		;escritura del cartel presentacion LISTA
		movlw d'47'
		movwf index	;index = 47
		movlw d'4'
		movwf size		;size = 4
		call write
		call dem_1s
		;---------------------------------------------------------------
		;direccion cartel 1 RON PURO	
		;direccion del cartel
		movlw 0xc0
		call chdir		; empieza c0
		;escritura cartel
		movlw d'63'
		movwf index	;index = 63
		movlw d'9'
		movwf size		;size = 9
		call write
		call down		;pone al cursor abajo
		call dem_40us
		;esperar accion
scantec5	call teclado 
		btfss k_flag,0
		goto scantec5
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "ENTER"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto opcion1
		;pregunto por el 8(abajo)
		movf tecla,w
		sublw d'8'
		btfss 3,2
		goto scroll2
		goto scantec5
		;--------------------------------------------------------------------------------
		;SIGUIENTE PANTALLA 2 CUBA LIBRE / 3 ORANGE VODKA
		;--------------------------------------------------------------------------------
scroll2		call clrdisp
		call dem_40us
		;cartel 2 CUBA LIBRE
		;escritura del cartel 
		movlw d'73'
		movwf index	;index = 73
		movlw d'11'
		movwf size		;size = 11
		call write
		;---------------------------------------------------------------
		;direccion cartel 3 ORANGE VODKA	
		;direccion del cartel
		movlw 0xc0
		call chdir		; empieza c0
		;escritura cartel
		movlw d'85'
		movwf index	;index = 85
		movlw d'13'
		movwf size		;size = 13
		call write
		call dem_1s
		;esperar accion
scantec6 call up		;cursor arriba
		call dem_100ms
		call teclado 
		btfss k_flag,0
		goto scantec6
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "ENTER"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto opcion2
		;pregunto por el 2(arriba)
		movf tecla,w
		sublw d'1'
		btfsc 3,2
		goto opcionlista
		;pregunto por el 8(abajo)
		movf tecla,w
		sublw d'8'
		btfss 3,2
		goto scantec7
		goto scantec6
		
scantec7  call down		;cursor abajo
		call dem_100ms
		call dem_50ms
		call teclado 
		btfss k_flag,0
		goto scantec7
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "ENTER"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto opcion3
		;pregunto por el 2 (arriba)
		movf tecla,w
		sublw d'1'
		btfsc 3,2
		goto scroll2
		;pregunto por el 8 (abajo)
		movf tecla,w
		sublw d'8'
		btfss 3,2
		goto scroll3
		goto scantec7
		;---------------------------------------------------------------------------------------
		;SIGUIENTE PANTALLA 4 NARANJADA / 5 GASEOSA
		;---------------------------------------------------------------------------------------
scroll3 	call clrdisp
		;cartel opcion 4 NARANJADA
		;escritura del cartel 
		movlw d'99'
		movwf index		;index = 99
		movlw d'10'
		movwf size		;size = 10
		call write
		;direccion del cartel
		movlw 0xc0
		call chdir		; empieza c0
		;escritura cartel 5 GASEOSA
		movlw d'110'
		movwf index		;index = 110
		movlw d'8'
		movwf size		;size = 8
		call write		
		call dem_1s

scantec8 call up
		call dem_100ms
		call dem_100ms
		call dem_100ms
		call teclado 
		btfss k_flag,0
		goto scantec8
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por "ENTER"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto opcion4
		;pregunto por 2 (arriba)
		movf tecla,w
		sublw d'1'
		btfsc 3,2
		goto scroll2
		;pregunto por 8 (abajo)
		movf tecla,w
		sublw d'8'
		btfss 3,2
		goto scantec9
		goto scantec8

scantec9  call down
		call dem_40us
		call teclado 
		btfss k_flag,0
		goto scantec9
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "ENTER"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto opcion5
		;pregunto por el 2 "arriba"
		movf tecla,w
		sublw d'1'
		btfss 3,2
		goto scantec9
		goto scantec8
		
		;----------------------------------------------------------------------------
		;MUESTRA EL SUBMENU DE CONSULTAS
opcionconsultas		call clrdisp
		;----------------------------------------------------------------------------
		;PANTALLA CONSULTAS / UNI DISPENSA
		;-----------------------------------------------------------------------------
		;cartel opcion CONSULTAS
		;escritura del cartel CONSULTAS
		movlw d'54'
		movwf index	;index = 54
		movlw d'8'
		movwf size		;size = 8
		call write	
		call dem_40us
		;direccion del cartel
		movlw 0xc0
		call chdir
		;escritura del cartel 1 UNI DISPENSA
		movlw d'119'
		movwf index	;index = 54
		movlw d'13'
		movwf size		;size = 8
		call write	
		call down
		call dem_1s
scantec0		call teclado
		btfss k_flag,0
		goto scantec0
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "ENTER"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto unidades
		;pregunto por el "8 (abajo)"
		movf tecla,w
		sublw 9
		btfss 3,2
		goto scantec0
		;----------------------------------------------------------------------------------
		;SIGUIENTE PANTALLA RESERVAS
		;----------------------------------------------------------------------------------
		call clrdisp
		;escritura del cartel RESERVAS
		movlw d'135'
		movwf index	;index = 135
		movlw d'9'
		movwf size		;size = 9
		call write	
		call dem_40us
		call up

scantec11		call teclado
		btfss k_flag,0
		goto scantec11
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el "ENTER"
		movf tecla,w
		sublw d'14'
		btfsc 3,2
		goto reservas
		;pregunto por el "2 (arriba)"
		movf tecla,w
		sublw 1
		btfss 3,2
		goto scantec11
		goto opcionconsultas
;===============================================================================================================
;SUBRUTINAS PARA UBICACION DEL CURSOR
;===============================================================================================================				
up 		movlw 0x8e
		call chdir
		call dem_40us
		movlw '<'
		movwf 8
		call pulse
		call dem_40us

		movlw 0xce
		call chdir
		call dem_40us
		movlw ' '
		movwf 8
		call pulse
		call dem_40us
		return

down 	movlw 0xce
		call chdir
		call dem_40us
		movlw '<'
		movwf 8
		call pulse
		call dem_40us

		movlw 0x8e
		call chdir
		call dem_40us
		movlw ' '
		movwf 8
		call pulse
		call dem_40us
		return
;---------------------------------------------------------------------------------------------------
;OPCION UNI DISPENSADAS
;---------------------------------------------------------------------------------------------------
unidades		call clrdisp
		;-------------------------------------------------------------------------------------------
		;unidades de ron puro vendidas
		;cartel 1 RON PURO
		;escritura del cartel 
		movlw d'63'
		movwf index	;index = 63
		movlw d'9'
		movwf size		;size = 9
		call write	
		movlw 0x20		; leo desde la eeprom cantidad vendida
		movwf dir
		call r_eeprom
		movf dato_r,w	; escribo cantidad vendida
		movwf uno
		;escritura de unidades vendidas	
		movlw 0xcd
		call chdir		; empieza c0
		;escritura cartel
		movf uno,w
		call ascii		
		movwf 8
		call pulse
		call dem_1s
scantec12 	call teclado
		btfss k_flag,0
		goto scantec12
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el 8 (abajo)
		movf tecla,w
		sublw d'9'
		btfss 3,2
		goto scantec12
		goto next1		
		;---------------------------------------------------------------------------------------------
		;unidades de cuba libre vendidas
next1	call clrdisp
		;cartel 2 CUBA LIBRE
		;escritura del cartel 
		movlw d'73'
		movwf index	;index = 63
		movlw d'11'
		movwf size		;size = 9
		call write	
		;escritura de unidades vendidas	
		movlw 0xcd
		call chdir		; empieza c0
		;escritura cartel
		movlw 0x21		; leo desde la eeprom cantidad vendida
		movwf dir
		call r_eeprom
		movf dato_r,w	; escribo cantidad vendida
		call ascii		
		movwf 8
		call pulse
		call dem_1s
		;esperar accion	
scantec13 	call teclado
		btfss k_flag,0
		goto scantec13
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el 2 (arriba)
		movf tecla,w
		sublw d'1'
		btfsc 3,2
		goto unidades
		;pregunto por el 8 (abajo)
		movf tecla,w
		sublw d'9'
		btfss 3,2
		goto scantec13
		goto next2
		;---------------------------------------------------------------------------------------------
		;unidades de orange vodka vendidas
next2	call clrdisp
		;cartel 3 ORANGE VODKA
		;escritura del cartel 
		movlw d'85'
		movwf index	;index = 85
		movlw d'13'
		movwf size		;size = 13
		call write	
		;escritura de unidades vendidas	
		movlw 0xcd
		call chdir		; empieza c0
		;escritura cartel
		movlw 0x22		; leo desde la eeprom cantidad vendida
		movwf dir
		call r_eeprom
		movf dato_r,w	; escribo cantidad vendida
		call ascii		
		movwf 8
		call pulse
		call dem_1s
		;esperar accion	
scantec14 	call teclado
		btfss k_flag,0
		goto scantec14
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el 2 (arriba)
		movf tecla,w
		sublw d'1'
		btfsc 3,2
		goto next1
		;pregunto por el 8 (abajo)
		movf tecla,w
		sublw d'9'
		btfss 3,2
		goto scantec14
		goto next3
		;----------------------------------------------------------------------------------------
		;unidades de naranjada vendidas
next3   call clrdisp
		;cartel 4 NARANJADA
		;escritura del cartel 
		movlw d'99'
		movwf index	;index = 99
		movlw d'10'
		movwf size		;size = 10
		call write	
		;escritura de unidades vendidas	
		movlw 0xcd
		call chdir		; empieza c0
		;escritura cartel
		movlw 0x23		; leo desde la eeprom cantidad vendida
		movwf dir
		call r_eeprom
		movf dato_r,w	; escribo cantidad vendida
		call ascii		
		movwf 8
		call pulse
		call dem_1s
		;esperar accion	
scantec15 	call teclado
		btfss k_flag,0
		goto scantec15
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el 2 (arriba)
		movf tecla,w
		sublw d'1'
		btfsc 3,2
		goto next2
		;pregunto por el 8 (abajo)
		movf tecla,w
		sublw d'9'
		btfss 3,2
		goto scantec15
		goto next4	
		;----------------------------------------------------------------------------------------
		;unidades de gaseosa
next4   call clrdisp
		;cartel 5 GASEOSA
		;escritura del cartel 
		movlw d'110'
		movwf index	;index = 99
		movlw d'8'
		movwf size		;size = 10
		call write	
		;escritura de unidades vendidas	
		movlw 0xcd
		call chdir		; empieza c0
		;escritura cartel
		movlw 0x25		; leo desde la eeprom cantidad vendida
		movwf dir
		call r_eeprom
		movf dato_r,w	; escribo cantidad vendida
		call ascii		
		movwf 8
		call pulse
		call dem_1s
		;esperar accion	
scantec16 	call teclado
		btfss k_flag,0
		goto scantec16
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el 2 (arriba)
		movf tecla,w
		sublw d'1'
		btfss 3,2
		goto scantec16
		goto next3
;---------------------------------------------------------------------------------------------
;OPCION RESERVAS
;---------------------------------------------------------------------------------------------				
reservas	call clrdisp
		;-------------------------------------------------------------------------------------------
		;nivel tanque A
		;cartel 1 TANQUE A
		;escritura del cartel 
		movlw d'145'
		movwf index	;index = 145
		movlw d'9'
		movwf size		;size = 9
		call write	
		;escritura del nivel	
		movlw 0xcd
		call chdir		; empieza cd
		;escritura cartel
		movf tanka,w		;nivel de tanque
		call ascii		
		movwf 8
		call pulse
		call dem_1s
scanteca 	call teclado
		btfss k_flag,0
		goto scanteca
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el 8 (abajo)
		movf tecla,w
		sublw d'9'
		btfss 3,2
		goto scanteca
		goto nextb		
		;---------------------------------------------------------------------------------------------
		;nivel tanque b
nextb	call clrdisp
		;cartel 2 TANQUE B
		;escritura del cartel 
		movlw d'155'
		movwf index	;index = 155
		movlw d'9'
		movwf size		;size = 9
		call write	
		;escritura del nivel	
		movlw 0xcd
		call chdir		; empieza cd
		;escritura cartel
		movf tankb,w		;nivel tanque 
		call ascii		
		movwf 8
		call pulse
		call dem_1s
		;esperar accion	
scantecb 	call teclado
		btfss k_flag,0
		goto scantecb
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el 2 (arriba)
		movf tecla,w
		sublw d'1'
		btfsc 3,2
		goto reservas
		;pregunto por el 8 (abajo)
		movf tecla,w
		sublw d'9'
		btfss 3,2
		goto scantecb
		goto nextc
		;---------------------------------------------------------------------------------------------
		;nivel tanque c
nextc	call clrdisp
		;cartel 3 TANQUE C
		;escritura del cartel 
		movlw d'165'
		movwf index	;index = 165
		movlw d'9'
		movwf size		;size = 9
		call write	
		;escritura del nivel	
		movlw 0xcd
		call chdir		; empieza cd
		;escritura cartel
		movf tankc,w		;nivel tanque
		call ascii		
		movwf 8
		call pulse
		call dem_1s
		;esperar accion	
scantecc 	call teclado
		btfss k_flag,0
		goto scantecc
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el 2 (arriba)
		movf tecla,w
		sublw d'1'
		btfsc 3,2
		goto nextb
		;pregunto por el 8 (abajo)
		movf tecla,w
		sublw d'9'
		btfss 3,2
		goto scantecc
		goto nextd
		;----------------------------------------------------------------------------------------
		;nivel tanque d
nextd   call clrdisp
		;cartel 4 TANQUE D
		;escritura del cartel 
		movlw d'175'
		movwf index	;index = 175
		movlw d'9'
		movwf size		;size = 9
		call write	
		;escritura del nivel	
		movlw 0xcd
		call chdir		; empieza cd
		;escritura cartel
		movf cuatro,w		;nivel tanque
		call ascii		
		movwf 8
		call pulse
		call dem_1s
		;esperar accion	
scantecd 	call teclado
		btfss k_flag,0
		goto scantecd
		;tecla pulsada
		;identficarla
		;pregunto por el "CANCEL"
		movf tecla,w
		sublw d'12'
		btfsc 3,2
		goto presen
		;pregunto por el 2 (arriba)
		movf tecla,w
		sublw d'1'
		btfss 3,2
		goto scantecd
		goto nextc		
		
		;----------------------------------------------------------------

;scan1		goto scan1
		end
