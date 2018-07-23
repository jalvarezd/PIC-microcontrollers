	list p=16f871
	#include <p16f871.inc>
;Práctica 04 (Ejemplo). "DESPLAZAMIENTO EN OLA DE CARACTERES"
;DISPLAYS: Ánodo Común.
;Nota: Los Datos que aquí se visualizan están en Código 7 Segmento; por lo tanto no se necesita
;implementar la decodificación.

;============================================================================
;ZONA DE DECLARACIÓN DE SÍMBOLOS Y VARIABLES.
;============================================================================
;buffers de las lamparas. Aquí se almacena el dato que deberá visualizarse en
;los displays (l1 ... l6). 

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
cont1		equ 	0x29	;contadores para demora
cont2		equ 	0x2a
cont3		equ 	0x2b
stat_temp	equ 	0x2c	;variable para respaldar el registro STATUS durante la interrupción.

;parametros para demora

N		equ 	0x2d	;factores de demora
M		equ	0x2e	

;otras variables

temp		equ	0x2f	;varible temporal auxiliar.
num_disp		equ 	0x30	;veces de conteo
temp1		equ	0x31	;varible temporal auxiliar.


rs			equ 4
e			equ 0
;================================================================================
;Definición de Vectores (Reset e Interrupción).
;================================================================================

			org 0
			goto inicio		;vector de RESET.
			org 4
			goto IT			;vector de IT.
;================================================================================
;Bloque de Configuración del Hardware.
;================================================================================
inicio  			bcf 3,5
			bcf 3,6			;banco 0
			;==============================================================
			;BLOQUE QUE DEFINE LAS CONDICIONES INICIALES DEL SISTEMA
			;==============================================================
			;inicia parámetros relativos a lamparas		

			clrf nlamp		;inicia el contador de lámparas (nlamp) en la primera (l1)

			;carga valores de N y M para garantizar la demora deseada.

			movlw d'128'
			movwf M
			movlw d'30'
			movwf N
			
			;-------------------------------------------------------------------------------------------------------------------	
			;definicion de E/S
			;modifica los registros TRIS (banco 1 de la RAM)

			bsf 3,5			;banco 1

			clrf 8			;Bus de Datos

			clrf 9			;Puerto E salidas

			movlw b'11000111'	;rc3, rc4 y rc5 salidas
			movwf 7

			;-------------------------------------------------------------------------------------------------------------------	
			;definición de líneas digitales
	
			movlw 7		;líneas del Puerto E DIGITALES
			movwf ADCON1
			;-------------------------------------------------------------------------------------------------------------------				
			;definición de parámetros para el tmr0
			;tmr0 en modo timer, con pscaler / 64
			;Ciclo de instrucción=0.25 US

			movlw 4			;00000100, prescaler k = 4
			movwf OPTION_REG

			;-------------------------------------------------------------------------------------------------------------------				
			;habilitación de la interrupción del TMR0 e Interrupciones Globales deshabilitadas
			;(GIE = 0, T0IE = 0) por el momento.

			movlw b'00100000'	;11100000
			movwf 0x0b		;int del tmr0 habilitada
			;-------------------------------------------------------------------------------------------------------------------				
			bcf 3,5
	
;================================================================================
;BLOQUE PRINCIPAL (PROGRAMA PRINCIPAL)
;================================================================================

			clrf TMR0		;inicia timer 0
			call apaga		;displays apagados al inicio.
			bsf INTCON,7		;habilita todas las interrupciones.


last			call demora		;demora para que se observe la última
						;lámpara
			clrf num_disp
			call apaga		;apaga displays
			call demora		;demora para que se observe el apagado
						;cuando termine cada ciclo.

desplaza		movlw 0x20
			movwf FSR		;inicia el FSR en la dirección de la RAM de Display
						;de la primera lámpara (l1)
			movf num_disp,w
			call tab_char		;tabla de caracteres que serán sacados
			movwf temp1		;respalda caracter
			movf num_disp,w
			addwf 4,1		;direcciona display en donde se escribirá
						;el caracter leído de la tabla
			movf temp1,w
			movwf 0		;escribe caracter

			;¿Último display?

			movf num_disp,w
			sublw 5
			btfsc 3,2
			goto last		;último display
			;No es el último

			incf num_disp
			call demora
			goto desplaza		


again			goto again
			

;================================================================================
;BLOQUE DE SUBRUTINAS
;********************************************************************************************************************************
;subrutina de Atención a Interrupción. Este caso incluye la decodificación de BCD a 7 segmentos
;Atención al timer0, cada vez que se desborda; para refrescar el display cada 1ms.
;********************************************************************************************************************************
IT		;---------------------------------------------------------------------------------------------------------	
		;respaldo de registros.

		movwf wtemp	;respaldo ac.
		swapf STATUS,w
		movwf stat_temp
		movf FSR,0
		movwf fsr_temp	;respaldo el FSR
		
		;---------------------------------------------------------------------------------------------------------	
		;encuesta de banderas. 

		btfss INTCON,2		;T0IF =? 0
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

mayor_2	movf nlamp,0
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
		;call cod_ss
		movwf 8

		;próxima  lámpara

		movf nlamp,w
		sublw 5
		btfss 3,2
		goto menor_5

		;nlamp = 0

		clrf nlamp
		goto back_t0
		
		;nlamp < 5

menor_5	incf nlamp

back_t0	bcf INTCON,2 		;limpia la bandera del timer0

back		movf fsr_temp,w
		movwf FSR		;restituye FSR
		swapf stat_temp,w
		movwf STATUS	;restituye STATUS
		swapf wtemp,f
		swapf wtemp,w	;restituye W sin afectar las banderas del STATUS.
							;la instrucción "swapf   f ", no afecta el contenido del STATUS			
		retfie			;retorno de la subrutina.

;********************************************************************************************************************************
;tabla de códigos de activación (ánodo común)
cod_act	addwf PCL,1		;suma el offset al acum.
		retlw b'11111110'
		retlw b'11111101'
		retlw b'11111011'
		retlw b'11110111'
		retlw b'11101111'
		retlw b'11011111'
;********************************************************************************************************************************
;tabla auxiliar de códigos 7 segmentos
tab_char	addwf PCL,1		;suma el offset al acum.
		retlw 0xa3
		retlw 0x9c
		retlw 0xa3
		retlw 0x9c
		retlw 0xa3
		retlw 0x9c


;***********************************************************************************************************************
;apaga displays

apaga		movlw 0xff
		movwf l1
		movwf l2
		movwf l3
		movwf l4
		movwf l5
		movwf l6
		return
;***********************************************************************************************************************
;subrutina de DEMORA paramétrica general
;***********************************************************************************************************************
demora	;return
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
		
		end
