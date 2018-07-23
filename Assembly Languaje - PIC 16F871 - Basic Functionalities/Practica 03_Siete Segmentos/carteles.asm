	list p=16f871
	#include <p16f871.inc>
;EJEMPLO 1 (displays de 7 segmentos): "PRUEBA DE ALGORITMO DE VISUALIZACIÓN DE CARACTERES"
;El refrescamiento de la información en las lámparas se realiza dentro del Programa Principal
;lo que no es conveniente, puesto que la demora de refrescamiento estaría condicionando la lectura
;del switch (RB0) que conmuta el cartel.
;DISPLAYS: Ánodo Común. Para tecnología cátodo se debe complementar el dato antes de mandarlo
;al PUERTO D

;Nota: Los Datos que aquí se visualizan están en Código 7 Segmento; por lo tanto no se necesita
;implementar la decodificación.

;============================================================================
;ZONA DE DECLARACIÓN DE SÍMBOLOS Y VARIABLES.
;============================================================================
;buffers de las lamparas. Aquí se almacena el dato en 7 segmentos que deberá visualizarse en
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
;Definición de Vectores (Reset).
;=========================================================================

			org 0
			goto inicio		;vector de RESET.


inicio  			bcf 3,5
			bcf 3,6			;banco 0
			;===========================================================
			;BLOQUE QUE DEFINE LAS CONDICIONES INICIALES DEL SISTEMA
			;===========================================================
		
			;============================================================
			;Bloque de Configuración del Hardware.
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
			;definición de líneas digitales (necesario para que RE0, RE1 y RE2 funcionen como tal)
	
			movlw 7		;líneas del Puerto E DIGITALES
			movwf ADCON1
			;-------------------------------------------------------------------------------------------------------------------	
			;Habilitación de los pull ups del puerto B (bit 7 del registro OPTION_REG)
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
;subrutina de refrescamiento. Este caso NO incluye la decodificación de BCD a 7 segmentos
;puesto que en el Programa Principal se cargan los datos en 7 segmento directamente
;***********************************************************************************************************************

refresca	;apaga todas las lámparas al inicio.
		;---------------------------------------------------------------------------------------------------------
		;apaga comunes del puerto C
		bsf PORTC,3
		bsf PORTC,4
		bsf PORTC,5
		;apaga comunes del puerto E
		movlw 0xff
		movwf PORTE
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L1 (COMÚN RC3)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTC,3		;enciende común de L1
		movf L1,w		;saca dato de L1 desde RAM
		movwf PORTD		;pone dato de L1 en PORTD
		call dem_refresc
		bsf PORTC,3		;apaga L1
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L2 (COMÚN RC4)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTC,4		;enciende común de L2
		movf L2,w		;saca dato de L2 desde RAM
		movwf PORTD		;pone dato de L2 en PORTD
		call dem_refresc
		bsf PORTC,4		;apaga L2
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L3 (COMÚN RC5)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTC,5		;enciende común de L3
		movf L3,w		;saca dato de L3 desde RAM
		movwf PORTD		;pone dato de L3 en PORTD
		call dem_refresc
		bsf PORTC,5		;apaga L3
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L4 (COMÚN RE0)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTE,0		;enciende común de L4
		movf L4,w		;saca dato de L4 desde RAM
		movwf PORTD		;pone dato de L4 en PORTD
		call dem_refresc
		bsf PORTE,0		;apaga L4
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L5 (COMÚN RE1)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTE,1		;enciende común de L5
		movf L5,w		;saca dato de L5 desde RAM
		movwf PORTD		;pone dato de L5 en PORTD
		call dem_refresc
		bsf PORTE,1		;apaga L5
		;---------------------------------------------------------------------------------------------------------
		;PROCESAR LAMPARA L6 (COMÚN RE2)
		;---------------------------------------------------------------------------------------------------------
		bcf PORTE,2		;enciende común de L6
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
