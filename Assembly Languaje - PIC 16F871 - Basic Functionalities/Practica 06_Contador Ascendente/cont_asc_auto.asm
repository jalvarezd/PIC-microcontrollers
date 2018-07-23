	list p=16f871
	#include <p16f871.inc>

;�Ing. Leonel P�rez R. ISSBN 010234
;Pr�ctica 04 "CONTADOR ASCENDENTE".
;Este es un ejemplo de utilizaci�n de interrupciones. En la interrupci�n que produce el
;Timer 0 cada 1ms se produce el refrescamiento.
;DISPLAYS: �nodo Com�n.
;Pr�ctica Evaluativa: Convertir esta Aplicaci�n en un CONTADOR DE 6 D�GITOS ASCENDENTE 
;- DESCENDENTE.

;=============================================================================================
;ZONA DE DECLARACI�N DE S�MBOLOS Y VARIABLES.
;=============================================================================================
;Definici�n de la RAM de Display (L1 ... L6). En estas localizaciones se almacenar� el dato que 
;deber� visualizarse en los displays (L1 ... L6) que en este caso es el conteo en BCD del contador 

l1		equ 	0x20
l2		equ 	0x21
l3		equ 	0x22
l4		equ	0x23
l5		equ 	0x24
l6		equ 	0x25

;variables generales

nlamp		equ 	0x26			;n�mero de la l�mpara que esta siendo refrescada
wtemp		equ 	0x27			;respaldo del acumulador en la INT.
fsr_temp	equ	0x28			;respaldo temporal del FSR.
stat_temp	equ 	0x29			;variable para respaldar el registro STATUS 
						;durante la interrupci�n.
;Contadores para demora param�trica
cont1		equ 	0x2a	
cont2		equ 	0x2b
cont3		equ 	0x2c


;parametros para fijar el tiempo de la demora

N		equ 	0x2d	;factores de demora
M		equ	0x2e	

;otras variables

temp		equ	0x2f	;varible temporal auxiliar.

;=============================================================================================
;Definici�n de Vectores (Reset e Interrupci�n).
;=============================================================================================

			org 0
			goto inicio	;vector de RESET.
			org 4
			goto IT		;vector de INTERRUPCION.
;=============================================================================================
;Bloque de Configuraci�n del Hardware.
;=============================================================================================
inicio  			bcf 3,5
			bcf 3,6	;banco 0
			;===========================================================================
			;BLOQUE QUE DEFINE LAS CONDICIONES INICIALES DEL SISTEMA
			;===========================================================================
			;inicia par�metros relativos a lamparas		

			clrf nlamp	;inicia el contador de l�mparas (nlamp) en la primera (l1)

			;eL CONTEO INICIAL ES 000 000
			movlw 8
			movwf l1
			movwf l2
			movwf l3
			movwf l4
			movwf l5
			movwf l6

	
			;-------------------------------------------------------------------------------------------------------------------	
			;definicion de Entradas y Salidas
			;modifica los registros TRIS (banco 1 de la RAM)

			bsf 3,5			;banco 1 RAM

			clrf 8			;Bus de Datos de los displays
			clrf 9			;Puerto E salidas
			movlw b'11000111'	;rc3, rc4 y rc5 salidas
			movwf 7
			movlw 0xff
			movwf 6		;Puerto B entrada

			;-------------------------------------------------------------------------------------------------------------------	
			;definici�n de l�neas digitales
	
			movlw 7		;l�neas del Puerto E DIGITALES
			movwf ADCON1
			;-------------------------------------------------------------------------------------------------------------------				
			;definici�n de par�metros para el TMR0 (Temporizador 0)
			;TMR0 en modo timer, con pscaler / 64
			;Ciclo de instrucci�n=0.25 US
			;PULL UPS habilitados RBPU = 0.

			movlw 4			;00000100, prescaler k = 4
			movwf OPTION_REG

			;-------------------------------------------------------------------------------------------------------------------				
			;habilitaci�n de la interrupci�n del TMR0 y Interrupciones Globales deshabilitadas
			;(GIE = 0, T0IE = 1) por el momento.

			movlw b'00100000'		;11100000
			movwf 0x0b			;int del tmr0 habilitada
			;-------------------------------------------------------------------------------------------------------------------				
			bcf 3,5				;banco 0 de la RAM
	
;=============================================================================================
;BLOQUE PRINCIPAL (PROGRAMA PRINCIPAL)
;=============================================================================================

			clrf TMR0		;inicia timer 0
			
			bsf INTCON,7		;habilita todas las interrupciones (sincroniza sistema).

			;----------------------------------------------------------------------------------------
			;testea tecla
test			btfsc 6,0
			goto test		;tecla inactiva, seguir testeando
			;----------------------------------------------------------------------------------------
			call cuenta_up	;contar
			;----------------------------------------------------------------------------------------
;wait			btfss 6,0		;espera a que suelte la tecla
			;goto wait
			call dem_150ms	;demora antirebote
			goto test			

;=============================================================================================
;BLOQUE DE SUBRUTINAS
;=============================================================================================
;subrutina de Atenci�n a Interrupci�n. Este caso incluye la decodificaci�n de BCD a 7 segmentos
;Atenci�n al timer0, cada vez que se desborda; para refrescar el display cada 1ms.
;****************************************************************************************************************************************************
IT		;-----------------------------------------------------------------------------------------------------------------------------------------------------------------
		;respaldo de registros. Los registros de mayor USO en el Programa Principal
		;deben ser respaldados durante la ejecuci�n de una Interrupci�n para evitar
		;que pierdan su valor y al retornar al Programa Principal se produzcan errores.
		;CONSULTE SECCION "SPECIAL FEATURES OF THE CPU" => "INTERRUPTS"
		;en PIC16F87X datasheet.

		movwf wtemp		;respaldo acumulador.
		swapf STATUS,w
		movwf stat_temp	;respaldo del STATUS
		movf FSR,0
		movwf fsr_temp	;respaldo del FSR
		
		;---------------------------------------------------------------------------------------------------------	
		;encuesta de banderas. En este segmento se validan la o las interrupciones
		;que hayan sido solicitadas.

		btfss INTCON,2		;T0IF =? 0
		goto back_t0		;regresa de Interrupci�n, al parecer fue un error

		;INT del timer 0: Refrescar Display.
		;apaga l�mparas al inicio.
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

		;chequea en que PUERTO (C � E) est� el com�n que debe activarse
		;en funci�n de nlamp.
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
		andlw 7		;m�scara para eliminar dato del puerto E
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
		;sacar el dato para la l�mpara nlamp

dato		movf nlamp,w
		addwf FSR,1			
		movf INDF,0
		call cod_ss
		movwf 8
		;comf 8

		;pr�xima  l�mpara

		movf nlamp,w
		sublw 5
		btfss 3,2
		goto menor_5

		;nlamp = 0

		clrf nlamp
		goto back_t0
		
		;nlamp < 5

menor_5	incf nlamp

back_t0	bcf INTCON,2 		;limpia la bandera de INT del timer0

back		movf fsr_temp,w
		movwf FSR		;restituye FSR
		swapf stat_temp,w
		movwf STATUS	;restituye STATUS
		swapf wtemp,f
		swapf wtemp,w	;restituye W sin afectar las banderas del STATUS.
					;la instrucci�n "swapf   f ", no afecta el contenido del STATUS			
		retfie			;retorno de la subrutina.

;*************************************************************************************************
;tabla de c�digos de activaci�n (�nodo com�n)

cod_act	addwf PCL,1		;suma el offset al acum.
		retlw b'11111110'
		retlw b'11111101'
		retlw b'11111011'
		retlw b'11110111'
		retlw b'11101111'
		retlw b'11011111'
;**************************************************************************************************
;tabla decodificadora de BCD a caracteres 7 SEGMENTO para �NODO COM�N.
;Si se trabajara c�digos para C�TODO se complementar�a cualquier DATO que
;deba salir ya sea hacia los comunes o hacia el BUS de Segmentos.

cod_ss		addwf	PCL,1
		retlw	0xc0			;"0"
		retlw	0xf9			;"1"
		retlw	0xa4			;"2"
		retlw	0xb0			;"3"
		retlw	0x99			;"4"
		retlw	0x92			;"5"
		retlw	0x82			;"6"
		retlw	0xb8			;"7"
		retlw	0x80			;"8"
		retlw	0x98			;"9"
;*****************************************************************************************************
;Subrutina de conteo ascendente (6 d�gitos)
;Usted debe dise�ar la subrutina de conteo descendente.

cuenta_up	;-----------------------------------
		;procesa L6
		incf l6
		movf l6,w
		sublw d'10'
		btfss 3,2
		return		;no incrementar d�gito adyacente
		;llego a 10
		clrf l6
		;-----------------------------------
		;procesa L5
		incf l5
		movf l5,w
		sublw d'10'
		btfss 3,2
		return		;no incrementar d�gito adyacente
		;llego a 10
		clrf l5
		;-----------------------------------
		;procesa L4
		incf l4
		movf l4,w
		sublw d'10'
		btfss 3,2
		return		;no incrementar d�gito adyacente
		;llego a 10
		clrf l4
		;-----------------------------------
		;procesa L3
		incf l3
		movf l3,w
		sublw d'10'
		btfss 3,2
		return		;no incrementar d�gito adyacente
		;llego a 10
		clrf l3
		;-----------------------------------
		;procesa L2
		incf l2
		movf l2,w
		sublw d'10'
		btfss 3,2
		return		;no incrementar d�gito adyacente
		;llego a 10
		clrf l2
		;-----------------------------------
		;procesa L1
		incf l1
		movf l1,w
		sublw d'10'
		btfss 3,2
		return		;no incrementar d�gito adyacente
		;llego a 10
		clrf l1
		return
;*****************************************************************************************************
;DEMORA DE 150 ms antirebote para leer el pulsante
;*****************************************************************************************************
dem_150ms	movlw d'100'
		movwf M
		movlw d'44'
		movwf N
		call demora
		return
;*****************************************************************************************************
;subrutina de DEMORA param�trica general
;*****************************************************************************************************
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
