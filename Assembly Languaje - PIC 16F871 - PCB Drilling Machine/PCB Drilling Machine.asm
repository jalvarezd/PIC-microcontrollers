	list p=16f871
	#include <p16f871.inc>
;==============================================================================================
;PROYECTO DE MICROCONTROLADORES
;==============================================================================================
;Integrantes: Julio Alvarez
;			  Paul Bedoya
;			  Johana Villavicencio
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;FUNCIONAMIENTO:

;El sistema funciona con activacion por llave analogica
;Una vez activado el sistema es capaz de recibir datos que representan las coordenadas en X y Y a trazar
;Para el posicionamiento se utiliza control de velocidad del motor por medio de PWM.
;El sistema monitorea la temperatura y posee un seguro contra manipulacion indebida durante operacion 

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

rs		equ 	4	;pin ra4
e		equ 	0	;pin rc0
key     equ		0x2c		;bandera de activacion de llave
dato	equ     0x2d		;variable donde se guarda el valor del conversor AD
literal equ		0x2e		;variable para comparaciones
dato_X1 equ		0x2f		;variables para almacenar coordenadas
dato_X2 equ		0x30
dato_Y1 equ		0x31
dato_Y2 equ		0x32
asc1	equ  	0x33		;Variables para la conversion binario a BCD
asc10	equ  	0x34
asc100	equ  	0x35
contBinaBCD	equ  	0x36

wtemp		equ		0x38	;Variables para respaldo de interrupcion
stat_temp	equ		0x39
fsr_temp	equ		0x3a

literal1	equ		0x3b	;Variables para el encoder
rango		equ		0x3c

contX2	equ		0x3d
rangox	equ		0x3e
contY2	equ		0x3f

asc100x		equ		0x37		;Variables para la transmision / recepcion
asc10x		equ		0x38		
asc1x		equ		0x40
asc100y		equ		0x41
asc10y		equ		0x42
asc1y		equ		0x43	
;=========================================================================
;INICIO DEL CÓDIGO DEL PROGRAMA
;=========================================================================

		org 0
		goto inicio		;vector de RESET.
		org 4
		goto IT
;=========================================================================
;TABLA DE CARACTERES DE CARTELES
;=========================================================================
tabla		addwf PCL,1
		;================= index = 0
		;================= size  = 12
		retlw 'S'
		retlw 'Y'
		retlw 'S'
		retlw 'T'
		retlw 'E'
		retlw 'M'
		retlw ' '
		retlw 'L'
		retlw 'O'
		retlw 'C'
		retlw 'K'
		retlw 'E'
		retlw 'D'
		;================= index = 13
		;================= size  = 10
		retlw 'P'
		retlw 'U'
		retlw 'T'
		retlw ' '
		retlw 'T'
		retlw 'H'
		retlw 'E'
		retlw ' '
		retlw 'K'
		retlw 'E'
		retlw 'Y'		
		;================= index = 24
		;================= size  = 2
		retlw 'X'
		retlw '1'
		retlw ':'
		;================= index = 27
		;================= size  = 2
		retlw 'X'
		retlw '2'
		retlw ':'
		;================= index = 30
		;================= size  = 2
		retlw 'Y'
		retlw '1'
		retlw ':'
		;================= index = 33
		;================= size  = 2
		retlw 'Y'
		retlw '2'
		retlw ':'
		;================= index = 36
		;================= size  = 4
		retlw 'E'
		retlw 'R'
		retlw 'R'
		retlw 'O'
		retlw 'R'
		
;=============================================================
;TABLA PARA CONVERTIR VALORES EN ASCII
;=============================================================
ascii	addwf	PCL,1
		retlw	'0'
		retlw	'1'
		retlw	'2'
		retlw	'3'
		retlw	'4'
		retlw	'5'
		retlw	'6'
		retlw	'7'
		retlw	'8'
		retlw	'9'
		retlw	'A'
		retlw	'B'
		retlw	'C'
		retlw	'D'
		retlw	'E'
		retlw	'F'
;=========================================================================
;inicia Display de Cristal Líquido

ini_lcd		call dem_100ms
		bcf 7,e					;E = 0 (LCD ihabilitado E = 0)
		bcf 5,rs				;RS = 0 (Modo de Instrucciones)

		;INICIO DE LA SECUENCIA DE RESET DEL CRISTAL

		call dem_5ms			;demora de power UP
		movlw 0x38
		movwf 8
		call pulse				;enable
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
;BLOQUE DE SUBRUTINAS
;=========================================================================
;=========================================================================
;SUBRUTINAS PARA EL LCD Y OTROS FINES
;--------------------------------------------------
;DEMORA DE 5.32 ms
;--------------------------------------------------

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
;DEMORA DE 100ms
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
;------------------------------------------------------
;SUBRUTINA CONVERSOR AD Y COMPARACIONES
;------------------------------------------------------
;Subrutina conversor AD
AD		
		bsf ADCON0,0 	      ;enciende el conversor
		call dem_40us        ;demora de adquisicion
		bsf ADCON0,2		 ;iniciar la conversion
wait
		btfsc ADCON0,2
		goto wait
		movf ADRESH,w
		movwf dato
		bcf ADCON0,0
		return
;--------------------------------------------------------
;subrutina para la activacion por llave

compKey movlw d'200'		;limite superior
		subwf dato
		btfsc 3,0
		return
		movlw d'150'		;limite inferior
		movwf literal
		movf dato,w
		subwf literal
		btfsc 3,0
		bsf key,0
		return
;--------------------------------------------------------
;subrutina rango del encoder

compEnc movlw d'250'		;limite superior
		subwf dato
		btfsc 3,0
		return
		movlw d'100'		;limite inferior
		movwf literal1
		movf dato,w
		subwf literal1
		btfsc 3,0
		bsf rango,0
		return
;--------------------------------------------------------
;subrutina comparacion de datos recibidos con posicion del motor

compX	movf dato_X1,w		;limite superior
		subwf contX2
		btfsc 3,0
		return
		bsf rangox,0
		return
;---------------------------------------------------------
;SUBRUTINAS PARA CONVERSIONES
;--------------------------------------------------------
;Conversion binario BCD
binabcd
		movwf dato
		clrf asc100
		clrf asc10
		clrf asc1
		clrf contBinaBCD
	
sub100
		movlw d'100'
		subwf dato,f
		btfsc 3,0
		goto cent
		goto fincent

cent 
		incf contBinaBCD,f
		goto sub100

fincent
		movf contBinaBCD,w
		movwf asc100

		clrf contBinaBCD
		
		movlw d'100'
		addwf dato,f
		
sub10
		movlw d'10'
		subwf dato,f
		btfsc 3,0
		goto dec
		goto findec
dec
		incf contBinaBCD,f
		goto sub10

findec
		movlw d'10'
		addwf dato,f
		movf contBinaBCD,w
		movwf asc10
		clrf contBinaBCD
sub1  
		movlw d'1'
		subwf dato,f
		btfsc 3,0
		goto uni
		goto finuni
uni
		incf contBinaBCD,f
		goto sub1
finuni	
		movf contBinaBCD,w
		movwf asc1
		return
;------------------------------------------------------------
;Subrutina para visualizar los datos en BCD
veamos  call ascii
		movwf 8			;se visualiza en el lcd
		call pulse
		call dem_40us
		return
;-------------------------------------------------------------
;SUBRUTINAS PARA LA TRANSMISION Y RECEPCION DE DATOS
;-------------------------------------------------------------
transmite
		bsf 3,5
		bcf TRISC,6
		movlw b'00100110'
		movwf TXSTA
		bcf 3,5

		bsf RCSTA,7
			
		bcf PIR1,4
		movlw '*'
		movwf TXREG
back
		nop		
		btfss PIR1,4
		goto back			
primero	movf asc100x,w
		movwf TXREG
back1	nop
		btfsc TXSTA,1
		goto back1
segundo	movf asc10x,w
		movwf TXREG
back2	nop
		btfsc TXSTA,1
		goto back2
tercero	movf asc1x,w
		movwf TXREG
back3	nop
		btfsc TXSTA,1
		goto back3						
		return
;--------------------------------------------------------------
;SUBRUTINA PARA VISUALIZACION DE ERROR
;--------------------------------------------------------------
bad		call clrdisp
		movlw 0x85
		call chdir
		movlw d'36'				;Cartel ERROR: en 0x80
		movwf index
		movlw d'4'
		movwf size
		call write
;=================================================================================================================
;Programa Principal (BLOQUE DE CONFIGURACIÓN DE HARDWARE)
;=================================================================================================================
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
		bcf 5,0     ;entrada ra0
		bcf 5,1     ;entrada ra1
		bcf 5,2     ;entrada ra2
		bcf 5,3     ;entrada ra3
		
		movlw 0xf0
		movwf 6		;conexión teclado matricial

		;-------------------------------------------------------------------------------------------------------------------	
		;definición de líneas digitales
	
		;movlw 7			;líneas digitales
		;movwf ADCON1

		;-------------------------------------------------------------------------------------------------------------------				
		;pull ups habilitado.

		bcf OPTION_REG,7
		;-------------------------------------------------------------------------------------------------------------------						
		bcf 3,5			;banco 0
		;-------------------------------------------------------------------------------------------------------------------						
		;inicia el LCD
		call ini_lcd		;inicia el lcd
		;-------------------------------------------------------------------------------------------------------------------						
		bsf 5,5		;enc backlight		retlw 'C'
		;------------------------------------------------------------------------------------------------------
		;CONFIGURACION DE INTERRUPCIONES
		movlw b'11000000'
		movwf INTCON
		;-------------------------------------------------------------------------------------------------------------
		;CONFIGURACION DEL CONVERSOR AD
		movlw b'00000000'	;Puertos ra0 al ra3 definidos como entradas analogicas
		movwf ADCON1
		;--------------------------------------------------------------------------------------------------------------------
		bsf 3,5
		;CONFIGURACION DEL USART
		movlw d'129'
		movwf SPBRG 		
		movlw b'00100110'	
		movwf TXSTA	

		bcf 3,5
		movlw b'10010000'	
		movwf RCSTA		;para recepcion de 8 datos
		bsf 3,5
		bsf PIE1,RCIE	;INT del USART por recepción del dato
		bsf 3,5
		bcf TRISC,6
		bsf TRISC,7
		bcf 3,5
;===========================================================
;BLOQUE DEL PROGRAMA PRINCIPAL
;===========================================================
;Escritura de carteles de SYSTEM LOCKED, PUT THE KEY TO ENABLE en un loop hasta que la llave se active 
		call clrdisp
		clrf index
		clrf size
		clrf chdir
		clrf key
				
inactive 
		clrf literal
		movlw 0x81				;Cartel SYSTEM LOCKED en 0x81 del LCD
		call chdir
		movlw d'0'			
		movwf index
		movlw d'12'
		movwf size
		call write
		movlw 0xC2				;Cartel PUT THE KEY en 0xC2 del LCD
		call chdir
		movlw d'13'			
		movwf index
		movlw d'10'
		movwf size
		call write
				
		clrf dato
		clrf ADRESH
		bcf 3,5					;Adquisiscion del valor y comparacion de llave
		movlw b'10000000'
		movwf ADCON0
		call AD
		call compKey
		btfss key,0				;key es correcta? 
		goto inactive			;key es incorrecta vuelva a poner carteles
		bcf key,0				;key es correcta escribir carteles de cordenadas

		;Escritura de carteles de coordenadas recibidas y transmitidas		
		call clrdisp
active		movlw d'24'				;Cartel X1: en 0x80
		movwf index
		movlw d'2'
		movwf size
		call write
		movlw 0xc0				;Cartel X2: en 0xc0
		call chdir
		movlw d'27'
		movwf index
		movlw d'2'
		movwf size
		call write
		movlw 0x88				;Cartel Y1: en 0x88
		call chdir
		movlw d'30'
		movwf index
		movlw d'2'
		movwf size
		call write
		movlw 0xc8				;Cartel Y2: en 0xc8
		call chdir
		movlw d'33'
		movwf index
		movlw d'2'
		movwf size
		call write
		
		;Adquisicion de datos para la posicion relativa del encoder
		
		movlw d'30'
		movwf dato_X1		
		bsf 6,0						;motor encendido
		bcf 6,1

coorX2		bcf 3,5						;coordenada X2 
		movlw b'10001000' 
		movwf ADCON0
		clrf dato
		clrf ADRESH
		call AD
		call compEnc					;Compara si el encoder esta dentro del rango
		btfss rango,0
		call bad						;No esta mostrar cartel de ERROR
		clrf rango						
		incf contX2								
		movf contX2,w
		subwf dato_X1					
		btfss 3,2						;El contador del encoder es igual al valor de X1?
		goto coorX2						;NO regrese a contar
		movf contX2,w					;Almacene el dato y mandelo a visualizar
		call binabcd
		bcf 6,0
		bcf 6,1		
		movlw 0xC4						;Escritura del valor de X2 en BCD en 0xC4
		call chdir
		movf asc100,w
		
		call veamos
		movwf asc100x
		movf asc10,w
		call veamos
		movwf asc10x
		movf asc1,w
		
		
		call veamos
		movwf asc1x
		call dem_40us
		call transmite					;Envia paquete de datos de la posicion en x
		bsf 6,2							;Habilita el motor 2
		bcf 6,3
		movlw d'10'
		movwf dato_X2
	
coorY2	bcf 3,5							;coordenada Y2 
		movlw b'10010000' 
		movwf ADCON0
		clrf dato
		clrf ADRESH
		call AD
		call compEnc					;Compara si el encoder esta dentro del rango
		btfss rango,0
		call bad						;No esta mostrar cartel de ERROR
		clrf rango						
		incf contY2								
		movf contY2,w
		subwf dato_Y2					
		btfss 3,2						;El contador del encoder es igual al valor de X1?
		goto coorY2						;NO regrese a contar
		movf contY2,w					;Almacene el dato y mandelo a visualizar
		call binabcd
		bcf 6,2							;Para el Motor 2
		bcf 6,3
		movlw 0xCC						;Escritura del valor de Y2 en BCD en 0xCD
		call chdir
		movf asc100,w
		movwf asc100y
		movf asc100,w
		call veamos
		movf asc10,w
		movwf asc10y
		movf asc10,w
		call veamos
		movf asc1,w
		movwf asc1y
		movf asc1,w
		call veamos
		call dem_40us
		call transmite		;Envia paquete de datos de la posicion en Y
		goto active	
			
		
;----------------------------------------------------------------------------		
;SUBRUTINA DE SERVICIO DE IT
;----------------------------------------------------------------------------
IT		;respaldo de registros
		movwf wtemp	;respaldo ac
		swapf STATUS,w
		movwf  stat_temp
		movf FSR,0
		movwf fsr_temp ;respaldo el FSR
;--------------------------------------------------------------------------
		;chequeo de banderas
 		btfss PIR1,RCIF
		return
recibe	movf RCREG,w
		movwf dato	
		movlw '*'
		subwf dato
		btfss 3,2
		goto regreso
		clrf dato						;Primer valor X1
		movf RCREG,w
		movwf dato_X1
		movf dato_X1,w
		call binabcd
		movlw 0x84						;Escritura del valor de X1 en BCD en 0x84
		call chdir
		movf asc100,w
		movwf asc100x
		movf asc100,w
		call veamos
		movf asc10,w
		movwf asc10x
		movf asc10,w
		call veamos
		movf asc1,w
		movwf asc1x
		movf asc1,w
		call veamos
		call dem_40us
		clrf dato
		movf RCREG,w					;Segundo valor Y1
		movwf dato_Y1
		movf dato_Y1,w
		call binabcd
		movlw 0x92						;Escritura del valor de Y1 en BCD en 0x92
		call chdir
		movf asc100,w
		movwf asc100y
		movf asc100,w
		call veamos
		movf asc10,w
		movwf asc10y
		movf asc10,w
		call veamos
		movf asc1,w
		movwf asc1y
		movf asc1,w
		call veamos
		call dem_40us
regreso movf fsr_temp,w
		movwf FSR		;restituye FSR
		swapf stat_temp,w
		movwf STATUS	;restituye STATUS
		swapf wtemp,f
		swapf wtemp,w	;restituye W sin afectar las banderas del STATUS
		retfie	

	end	

