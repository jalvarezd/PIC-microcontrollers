;PRÁCTICA DEMOSTRATIVA MÓDULO CCP en Modo PWM

		list p=16f871
		#include "p16f871.inc"

;-------------------------------------------------------------------------------------------------------------------------------
;aquí comienza la zona de declaración de variables, constantes, etc. Esta zona es
;opcional. En un programa se puede trabajar directamente con las direcciones en
;formato numérico.
;-------------------------------------------------------------------------------------------------------------------------------

M 		= 0x21		
N		= 0x22		;M y N son factores de multiplicación de tiempo
					;para lograr demoras grandes a partir de una de_
					;mora general (subrutina demora)

cont1		= 0x23		;cont (1,2 y 3) son registros de la RAM que se utiliza
				;rán como contadores en la subrutina de demora
cont2		= 0x24
cont3		= 0x25


		org 0
		goto inicio

;------------------------------------------------------------------------------------------------------------------------------------------------
;Zona de configuración de registros. Esta zona la ocupan un conjunto de instrucciones que preparan
; al microcontrolador para el trabajo.
;--------------------------------------------------------------------------------------------------------------------------------------------------
inicio		bsf	STATUS,5		;cambia al banco 1 de la RAM
		
	
		bcf 7,2				;salida PWM

		;---------------------------------------------------------------------------------------------------------------
		;habilita pull ups del puerto B (internos)
		bcf OPTION_REG,7
		;---------------------------------------------------------------------------------------------------------------
		;Carga Valor del registro PR2 (define frecuencia)
		movlw d'250'
		movwf PR2
		;---------------------------------------------------------------------------------------------------------------
		bcf 3,5		;banco 0
		;---------------------------------------------------------------------------------------------------------------
		;configura TMR2
		movlw b'00000011'		;prescaler / 16, OFF
		movwf T2CON
		;---------------------------------------------------------------------------------------------------------------
		;configura Módulo CCP en Modo PWM
		movlw 0x0f
		movwf	CCP1CON		;modo PWM

;-----------------------------------------------------------------------------------------------------------------------------------------
;Zona del programa principal. El programa principal rige el funcionamiento de una apli_
;cación de control en particular.
;-------------------------------------------------------------------------------------------------------------------------------------------
				
		;Inicio Programa Principal

		movlw 0x7f
		movwf CCPR1L	;Ciclo Útil Inicial

		;---------------------------------------------------------------------------------------------------------------
		;enciende timer 2
		bsf	T2CON,2	;enc TMR2
		;---------------------------------------------------------------------------------------------------------------
demo		btfss 6,0
		goto UP_CU
		btfsc 6,1
		goto demo
		;bajar CU
		movf CCPR1L,w
		btfsc 3,2
		goto demo
		;CCPR1L > 0 disminuye CU
		decf CCPR1L
		call dem_150ms
	  	goto	demo			;retorna a realizar nuevamente el ciclo
UP_CU		;subir CU
		movf CCPR1L,w
		sublw 0xff
		btfsc 3,2
		goto demo
		;CU < FF, aumentar
		incf CCPR1L
		call dem_150ms
		goto demo

;-------------------------------------------------------------------------------------------------------------------------------
;zona de subrutinas.
;-------------------------------------------------------------------------------------------------------------------------------				
;==========================================================================
;subrutinas de DEMORA 
;==========================================================================
;--------------------------------------------------
;DEMORA DE 150ms
;--------------------------------------------------	

dem_150ms	movlw d'30'
		movwf N			;parámetro a cargar en contadores
		movlw d'38'
		movwf M			;parámetro a cargar en contadores
		call demora			;demora de 150 mseg.
		return

;-----------------------------------------------------------------------------
;DEMORA PARAMÉTRICA DE TIEMPOS (GENERAL)
;-----------------------------------------------------------------------------

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
		;fin del proceso, inicia contadores
		return

		end

				
				
				
			
			
			
			
				
				
				
				
				
				
				
