	list p=16f871
	#include <p16f871.inc>
;EJEMPLO 1 (displays de 7 segmentos): "PRUEBA DE ALGORITMO DE VISUALIZACI�N DE CARACTERES"
;El refrescamiento de la informaci�n en las l�mparas se realiza dentro del Programa Principal
;lo que no es conveniente, puesto que la demora de refrescamiento estar�a condicionando la lectura
;del switch (RB0) que conmuta el cartel.
;DISPLAYS: �nodo Com�n. Para tecnolog�a c�todo se debe complementar el dato antes de mandarlo
;al PUERTO D

;Nota: Los Datos que aqu� se visualizan est�n en C�digo 7 Segmento; por lo tanto no se necesita
;implementar la decodificaci�n.

;============================================================================
;ZONA DE DECLARACI�N DE S�MBOLOS Y VARIABLES.
;============================================================================
;buffers de las lamparas. Aqu� se almacena el dato en 7 segmentos que deber� visualizarse en
;los displays (L1 ... L6). 

L1		equ 	0x20
L2		equ 	0x21
L3		equ 	0x22
L4		equ	0x23
L5		equ 	0x24
L6		equ 	0x25

;parametros para demora universal

N		equ 	0x26	;factores de demora
M		equ	0x27

;contadores auxiliares

cont1		equ 	0x28	;contadores auxiliares
cont2		equ	0x29
cont3		equ	0x2a

	


;=========================================================================
;Definici�n de Vectores (Reset).
;=========================================================================

			org 0
			goto inicio		;vector de RESET.


inicio  			bcf 3,5
			bcf 3,6			;banco 0
			;===========================================================
			;BLOQUE QUE DEFINE LAS CONDICIONES INICIALES DEL SISTEMA
			;===========================================================
		
			;============================================================
			;Bloque de Configuraci�n del Hardware.
			;============================================================		
			;-------------------------------------------------------------------------------------------------------------------	
			;definicion de E/S
			;modifica los registros TRIS (banco 1 de la RAM)

			bsf 3,5		;banco 1

			clrf TRISD		;Bus de Datos para los segmentos (Puerto D)

			movlw b'11000111'	;rc3, rc4 y rc5 salidas
			movwf TRISC

			clrf TRISE		;Puerto E salidas de comunes de displays
			;-------------------------------------------------------------------------------------------------------------------	
			;definici�n de l�neas digitales (necesario para que RE0, RE1 y RE2 funcionen como tal)
	
			movlw 7		;l�neas del Puerto E DIGITALES
			movwf ADCON1
			;-------------------------------------------------------------------------------------------------------------------	
			;Habilitaci�n de los pull ups del puerto B (bit 7 del registro OPTION_REG)
			bcf OPTION_REG,7

			bcf 3,5			;banco 0
	
;===========================================================
;BLOQUE PRINCIPAL (PROGRAMA PRINCIPAL)
;===========================================================

			;selector de cartel
			;TESTEO DEL PIN RB0 (SWITCH)
again			btfss PORTB,0	
			goto dos
			;RB0 = 0 visualizar cartel "UDA" 
			;carga caracteres a visualizar
			;"UDA"
			movlw 0xc1
			movwf L1
			movlw 0xa1
			movwf L2
			movlw 0x88
			movwf L3
			;"o o o"
			movlw 0xa3
			movwf L4
			movwf L5
			movwf L6
			call refresca
			goto again
		
dos			;RB0 = 1 visualizar cartel "ELECtr" 
			;carga caracteres a visualizar
			movlw 0x86
			movwf L1
			movlw 0xc7
			movwf L2
			movlw 0x86
			movwf L3
			movlw 0xc6
			movwf L4
			movlw 0x87
			movwf L5
			movlw 0xaf
			movwf L6
			call refresca		;refrescar display
			goto again

;============================================================================		
;BLOQUE DE SUBRUTINAS
;============================================================================
;***********************************************************************************************************************
;subrutina de refrescamiento. Este caso NO incluye la decodificaci�n de BCD a 7 segmentos
;puesto que en el Programa Principal se cargan los datos en 7 segmento directamente
;***********************************************************************************************************************

refresca	;apaga todas las l�mparas al inicio.
		;---------------------------------------------------------------------------------------------------------
		;apaga comunes del puerto C
		bsf PORTC,3
		bsf PORTC,4
		bsf PORTC,5
		;apaga comunes del puerto E
		movlw 0xff
		movwf PORTE
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L1 (COM�N RC3)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTC,3		;enciende com�n de L1
		movf L1,w		;saca dato de L1 desde RAM
		movwf PORTD		;pone dato de L1 en PORTD
		call dem_refresc
		bsf PORTC,3		;apaga L1
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L2 (COM�N RC4)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTC,4		;enciende com�n de L2
		movf L2,w		;saca dato de L2 desde RAM
		movwf PORTD		;pone dato de L2 en PORTD
		call dem_refresc
		bsf PORTC,4		;apaga L2
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L3 (COM�N RC5)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTC,5		;enciende com�n de L3
		movf L3,w		;saca dato de L3 desde RAM
		movwf PORTD		;pone dato de L3 en PORTD
		call dem_refresc
		bsf PORTC,5		;apaga L3
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L4 (COM�N RE0)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTE,0		;enciende com�n de L4
		movf L4,w		;saca dato de L4 desde RAM
		movwf PORTD		;pone dato de L4 en PORTD
		call dem_refresc
		bsf PORTE,0		;apaga L4
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L5 (COM�N RE1)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTE,1		;enciende com�n de L5
		movf L5,w		;saca dato de L5 desde RAM
		movwf PORTD		;pone dato de L5 en PORTD
		call dem_refresc
		bsf PORTE,1		;apaga L5
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L6 (COM�N RE2)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTE,2		;enciende com�n de L6
		movf L6,w		;saca dato de L6 desde RAM
		movwf PORTD		;pone dato de L6 en PORTD
		call dem_refresc
		bsf PORTE,2		;apaga L6
		;FIN DEL PROCESO
		return			;retorno de la subrutina.
;***********************************************************************************************************************
;subrutina de DEMORA para exhibir el dato en cada display
;***********************************************************************************************************************
dem_refresc	;return
		movlw d'40'
		movwf M
		movlw d'10'
		movwf N
		call demora
		return
;***********************************************************************************************************************
;subrutina de DEMORA param�trica general
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
