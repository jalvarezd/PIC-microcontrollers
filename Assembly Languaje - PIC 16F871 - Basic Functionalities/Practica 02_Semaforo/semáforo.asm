;Encabezamiento del programa. Se define el procesador que se trabajar� y el fichero 
;"include" asociado a �l. Los ficheros "include" son ficheros de s�mbolos, que se aignan a n�meros.
;los n�meros asignados est�n relacionados con pines de puerto, n�meros de un bit dentro de un 
;registro; direcciones de registros de la Memoria de Datos (RAM); etc..
;objetivos de esta pr�ctica:
; * demostrar el proceso de desarrollo de una aplicaci�n.
; * Estudiar la estructura de un programa en ensamblador.
; * Introducir las t�cnicas de programaci�n f�sica de los chips.
		list p=16f877
		#include "p16f877.inc"

;-------------------------------------------------------------------------------------------------------------------------------
;aqu� comienza la zona de declaraci�n de variables, constantes, etc. Esta zona es
;opcional. En un programa se puede trabajar directamente con las direcciones en
;formato num�rico.
;-------------------------------------------------------------------------------------------------------------------------------

M 			= 0x21		
N			= 0x22		;M y N son factores de multiplicaci�n de tiempo
					;para lograr demoras grandes a partir de una de_
					;mora general (subrutina demora)

cont1			= 0x23		;cont (1,2 y 3) son registros de la RAM que se utiliza
					;r�n como contadores en la subrutina de demora
cont2			= 0x24
cont3			= 0x25

;------------------------------------------------------------------------------------------------------------------------------------------------
;Zona de configuraci�n de registros. Esta zona la ocupan un conjunto de instrucciones que preparan
; al microcontrolador para el trabajo.
;En ella se cargan valores a los registros especiales que se denominan "de control". Los regis_
;tros de control garantizan el funcionamiento de los "recursos" que integran el microcontrolador.
;Son "recursos", los puertos de entrada / salida, temporizadores, Conversores Anal�gico -
; Digitales etc. En esta aplicaci�n s�lo se trabajar�n puertos de entrada / salida.
;--------------------------------------------------------------------------------------------------------------------------------------------------
		bsf STATUS,5		;cambia al banco 1 de la RAM
		clrf TRISD			;PUERTO D salida
					;s�lo se utilizar�n rd0, rd1 y rd2
;-----------------------------------------------------------------------------------------------------------------------------------------
;Zona del programa principal. El programa principal rige el funcionamiento de una apli_
;caci�n de control en particular. Siempre es un proceso CICLICO. Observe en este caso
;que finaliza en la instrucci�n (comando) "goto again". "again" es lo que se denomina 
;etiqueta (label). Una etiqueta marca un punto dentro del programa que se est� ejecutando
;y f�sicamente corresponde a una direcci�n (lugar), dentro de la Memoria de Programas.
;-------------------------------------------------------------------------------------------------------------------------------------------
				
		;Inicio Programa Principal

		bcf STATUS,5			;cambia al banco cero de la RAM	
		clrf PORTD				;al inicio se apagan todas las luces
						;para que el sem�foro arranque en un estado
						;estable.
	
		;Ciclo del sem�foro

again		;-----------------------------------------------------------------------------------------------------------
		;ROJO ��
		;se apagan amarillo y verde
		;garantizando que s�lo se encienda el rojo
		bcf	PORTD,2	;apaga verde
		bsf	PORTD,0	;enciende rojo
		
		;carga valores de los par�metros de la demora
		;N = 128
		;M = 128
		;antes de llamar a la demora, para obtener
		;el tiempo deseado de encendido del ROJO

		movlw d'200'
		movwf N
		movlw d'128'
		movwf M	

		;demora un tiempo de ENCENDIDO de rojo

		call demora		;hace una llamada a la subrutina "demora"
				;que es la encargada de realizar la espera

		;-----------------------------------------------------------------------------------------------------------
		;ROJO - AMARILLO �

		bsf	PORTD,1	;enciende amarillo
				;a�n permanece encendido el rojo


		;demora un tiempo de ENCENDIDO de rojo - amarillo
		;menor que el encendido del rojo
		;carga valores de los par�metros de la demora
		;N = 128
		;M = 128
		;antes de llamar a la demora, para obtener
		;el tiempo deseado de encendido del ROJO - AMARILLO

		movlw d'128'
		movwf N
		movlw d'128'
		movwf M	

		;demora un tiempo de ENCENDIDO de ROJO - AMARILLO

		call demora		;hace una llamada a la subrutina "demora"
				;que es la encargada de realizar la espera
		;-----------------------------------------------------------------------------------------------------------
		;VERDE ��

		bcf	PORTD,0	;apaga rojo
		bcf	PORTD,1	;apaga amarillo
		bsf	PORTD,2	;ENCIENDE VERDE


		;demora un tiempo de ENCENDIDO de VERDE
		;carga valores de los par�metros de la demora
		;N = 128
		;M = 128
		;antes de llamar a la demora, para obtener
		;el tiempo deseado de encendido del VERDE (similar al del ROJO)

		movlw d'128'
		movwf N
		movlw d'128'
		movwf M	

		;demora un tiempo de ENCENDIDO de VERDE

		call demora		;hace una llamada a la subrutina "demora"
				;que es la encargada de realizar la espera

		goto	again	;retorna a realizar nuevamente el ciclo del sem�foro

;-------------------------------------------------------------------------------------------------------------------------------
;zona de subrutinas.
;-------------------------------------------------------------------------------------------------------------------------------				
		;subrutina de demoras
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
		;fin del proceso, retorna al programa principal
		return			
	
		end
				
				
				
			
			
			
			
				
				
				
				
				
				
				
