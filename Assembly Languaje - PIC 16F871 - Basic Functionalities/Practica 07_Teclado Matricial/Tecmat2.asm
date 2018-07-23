	list p=16f871
	#include <p16f871.inc>
;Práct 06 (EJEMPLO) "Lectura de Teclado Matricial y Visualización en Display de 7 Segmentos"
;DISPLAYS: Ánodo Común.
;DESCRIPCIÓN: Se visualizarán los caracteres leídos desde un Teclado Matricial de 4 X 4 teclas.
;Los caracteres se visualizarán rotándolos de izquierda a derecha.
;__________________________________________________________________________________________________________
;PARTE EVALUATIVA: Adicionar a esta aplicación la posibilidad de Identificar si un grupo de 6 caracteres ingresados
;resulta correcto o NO; con el objetivo de implementar la Lectura y Validación de Códigos en Alarmas o
;cualquier otra aplicación que utilice CONTRASEÑAS.
;__________________________________________________________________________________________________________
;FUNCIONA PARA LA SIGUIENTE CONEXIÓN DE HARDWARE.
;HARDWARE:
;Teclado Matricial: 	rb7 ..rb4 son Columnas, se programan como ENTRADAS.
			;rb3 ... rb0 son Filas, se programan como 	SALIDAS.
;Resto del HW: Idéntico a los ejemplos anteriores.


;=============================================================================================
;ZONA DE DECLARACIÓN DE SÍMBOLOS Y VARIABLES.
;=============================================================================================
;buffers de las lamparas. Aquí se almacena el dato que deberá visualizarse en
;los displays (l1 ... l6); que en este caso serán las seis últimas teclas pulsadas.

l1		equ 	0x20
l2		equ 	0x21
l3		equ 	0x22
l4		equ	0x23
l5		equ 	0x24
l6		equ 	0x25

;variables generales

nlamp		equ 	0x26	;número de la lámpara que esta siendo refrescada
wtemp		equ 	0x27	;respaldo ac.
fsr_temp	equ	0x28	;respaldo temporal del FSR.
stat_temp	equ 	0x29	;variable para respaldar el registro STATUS durante la interrupción.

;contadores para demora
cont1		equ 	0x2a	;contadores para demora
cont2		equ 	0x2b
cont3		equ 	0x2c

;parámetros para demora

N		equ 	0x2d	;factores de demora
M		equ	0x2e	

;otras variables

temp		equ	0x2f	;varible temporal auxiliar.

;variables asociadas a la subrutina de teclado
tecla		equ	0x31
k_flag		equ	0x32


;=============================================================================================
;Definición de Vectores (Reset e Interrupción).
;=============================================================================================

			org 0
			goto inicio	;vector de RESET.
			org 4
			goto IT	;vector de IT.
;=============================================================================================
;Bloque de Configuración del Hardware.
;=============================================================================================
inicio  			bcf 3,5
			bcf 3,6	;banco 0
			;===========================================================
			;BLOQUE QUE DEFINE LAS CONDICIONES INICIALES DEL SISTEMA
			;===========================================================
			;inicia parámetros relativos a lamparas		

			clrf nlamp	;inicia el contador de lámparas (nlamp) en la primera (l1)

			;carga valores de N y M para garantizar una demora de 150.86 ms Aproximadamente
			;que es un tiempo ideal para eliminar rebotes.

			movlw d'100'
			movwf M
			movlw d'44'
			movwf N
			
			;-------------------------------------------------------------------------------------------------------------------	
			;definicion de E/S
			;modifica los registros TRIS (banco 1 de la RAM)

			bsf 3,5			;banco 1

			clrf 8			;Bus de Datos
			clrf 9			;Puerto E salidas
			movlw b'11000111'	;rc3, rc4 y rc5 salidas
			movwf 7
			movlw 0xf0
			movwf 6		;rb7 ... rb4 entradas (columnas). rb0 ... rb3 salidas (filas).

			;-------------------------------------------------------------------------------------------------------------------	
			;definición de líneas digitales
	
			movlw 7		;líneas del Puerto E DIGITALES
			movwf ADCON1
			;-------------------------------------------------------------------------------------------------------------------				
			;definición de parámetros para el tmr0
			;tmr0 en modo timer, con pscaler / 64
			;Ciclo de instrucción=0.25 US
			;pull ups habilitado.

			movlw 4			;00000100, prescaler k = 4
			movwf OPTION_REG

			;-------------------------------------------------------------------------------------------------------------------				
			;habilitación de la interrupción del tmr0 y Interrupciones Globales deshabilitadas
			;(GIE = 0, T0IE = 0) por el momento.

			movlw b'00100000'	;11100000
			movwf 0x0b		;int del tmr0 habilitada
			;-------------------------------------------------------------------------------------------------------------------				
			bcf 3,5
	
;=============================================================================================
;BLOQUE PRINCIPAL (PROGRAMA PRINCIPAL)
;=============================================================================================

			clrf TMR0		;inicia timer 0.
			
			bsf INTCON,7	;habilita todas las interrupciones.

			;Valor Inicial del Contador en BCD:  000 000

			movlw d'16'	;Caracter de NO tecla "-"
			movwf l1
			movwf l2
			movwf l3
			movwf l4
			movwf l5
			movwf l6

			;----------------------------------------------------------------------------------------			
			;testea teclado matricial
			;la tecla pulsada se almacena en la variable "tecla" en formato
			;HEXADECIMAL
			
test			call teclado
			btfss k_flag,0
			goto test		;no hubo tecla pulsada (key = 00000000)
					; seguir testeando

			;----------------------------------------------------------------------------------------
			;tecla pulsada: rotar la información en las lámparas
			;y visualizar la tecla actual en "l6".
			;ROTAR LA INFORMACIÓN, antes de actualizar l6.

			movf l2,w
			movwf l1
			movf l3,w
			movwf l2
			movf l4,w
			movwf l3
			movf l5,w
			movwf l4
			movf l6,w
			movwf l5
			;----------------------------------------------------------------------------------------			
			;actualiza l6
			movf tecla,w
			movwf l6
			;----------------------------------------------------------------------------------------		
			;Espera a que suelte la tecla
wait			call teclado
			btfsc k_flag,0
			goto wait
			;----------------------------------------------------------------------------------------		
			call demora		;demora anti rebote
			goto test

;FIN DEL PROGRAMA PRINCIPAL
;============================================================================		
;BLOQUE DE SUBRUTINAS
;============================================================================
;***********************************************************************************************************************
;subrutina de Atención a Interrupción. Este caso incluye la decodificación de BCD a 7 segmentos
;Atención al timer0, cada vez que se desborda; para refrescar el display cada 1ms.
;***********************************************************************************************************************
IT		;---------------------------------------------------------------------------------------------------------	
		;respaldo de registros.

		movwf wtemp	;respaldo acumulador.
		swapf STATUS,w
		movwf stat_temp	;respaldo del STATUS
		movf FSR,0
		movwf fsr_temp	;respaldo del FSR
		
		;---------------------------------------------------------------------------------------------------------	
		;encuesta de banderas. 

		btfss INTCON,2	;T0IF =? 0
		goto back_t0	;refresca el display

		;INT del timer 0: Rfrescar display.
		;apaga lámparas al inicio.
		;---------------------------------------------------------------------------------------------------------
		;apaga comunes del puerto C
refresh		bsf PORTC,3
		bsf PORTC,4
		bsf PORTC,5
		;apaga comunes del puerto E
		movlw 0xff
		movwf 9

		;---------------------------------------------------------------------------------------------------------
		;inicia el FSR	

		movlw 0x20
		movwf FSR

		;chequea puerto de comunes (C ó E), en función de nlamp
		;---------------------------------------------------------------------------------------------------------
		;nlamp >= 2?

		movf nlamp,0
		sublw 2
		btfsc 3,2
		goto menor		;nlamp = 2
		btfss 3,0		;pregunta por carry, es >< 2
		goto mayor_2

		;carry = 1 ==> nlamp = < 2

menor		movf nlamp,0
		call cod_act
		andlw 7			;máscara para eliminar puerto E
		movwf temp
		bcf 3,0			;limpia carry antes de rotar
		rlf temp
		rlf temp
		rlf temp		;rota izq

		;trucaje para no afectar dato

		movf temp,0		;leo cod act
		andwf 7,1		;sumo para no afectar
		goto dato

		;carry = 1 nlamp > 2

mayor_2		movf nlamp,0
		call cod_act
		clrf temp
		movwf temp		;respalda valor
		bcf 3,0			;limpia carry antes de rotar
		rrf temp
		rrf temp
		rrf temp
		movf temp,w		;cod act al acum.
		movwf 9			;cod. de act al puerto E
		;sacar el dato para la lámpara nlamp

dato		movf nlamp,w
		addwf FSR,1			
		movf INDF,0
		call cod_ss
		movwf 8			;se saca directamente el dato
					;la tabla "cod_ss" está codificada
					;para Ánodo Común

		;próxima  lámpara

		movf nlamp,w
		sublw 5
		btfss 3,2
		goto menor_5

		;nlamp = 0

		clrf nlamp
		goto back_t0
		
		;nlamp < 5

menor_5		incf nlamp

back_t0		bcf INTCON,2 	;limpia la bandera del timer0

back		movf fsr_temp,w
		movwf FSR		;restituye FSR
		swapf stat_temp,w
		movwf STATUS	;restituye STATUS
		swapf wtemp,f
		swapf wtemp,w	;restituye W sin afectar las banderas del STATUS.
							;la instrucción "swapf   f ", no afecta el contenido del STATUS			
		retfie			;retorno de la subrutina.

;***********************************************************************************************************************
;tabla de códigos de activación (ánodo común)

cod_act	addwf PCL,1		;suma el offset al acum.
		retlw b'11111110'
		retlw b'11111101'
		retlw b'11111011'
		retlw b'11110111'
		retlw b'11101111'
		retlw b'11011111'

;***********************************************************************************************************************
;subrutina de DEMORA paramétrica general
;***********************************************************************************************************************
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
		;fin del proceso
		return
;**************************************************************************************************
;tabla de caracteres 7 segmentos para decodificar un teclado matricial (como el que utiliza el KIT).
;Códigos para Anodo Común.

cod_ss		addwf	PCL,1
		retlw	0xf9			;"1"
		retlw	0xa4			;"2"
		retlw	0xb0			;"3"
		retlw	0x88			;"A"
		retlw	0x99			;"4"
		retlw	0x92			;"5"
		retlw	0x82			;"6"
		retlw	0x83			;"B"
		retlw	0xb8			;"7"
		retlw	0x80			;"8"
		retlw	0x98			;"9"
		retlw	0xc6			;"C"
		retlw	0x9c			;"*"
		retlw	0xc0			;"0"
		retlw	0xa3			;"#"
		retlw	0xa1			;"D"
		retlw	0xbf			;"-", no tecla
;===========================================================
		;subrutina que ESCANEA un Teclado Matricial de 4 X 4 teclas.

teclado		clrf	tecla		;esquina sup izquierda
		clrf	k_flag		;no tecla
		movlw b'11110111'		;patron inicial de filas
		movwf 6
		;columnas rb7 .... rb4
scancol	btfss	6,7
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


		
		end
