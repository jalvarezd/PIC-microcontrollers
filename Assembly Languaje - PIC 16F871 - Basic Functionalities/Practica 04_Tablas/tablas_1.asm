		list p = 16f877
		#include "p16f877.inc"
		;definición de variables auxiliares

indice		= 0x20
valor_out	= 0x21

		;condiciones iniciales

		clrf indice	;inidice = 00

		;Ejemplo ilustrativo # 1 de utilización de creación y utilización de una tabla de calibración
		;de 250 valores
		;____________________________________________________________________________
		

inicio		;carga PCLATH = 09
		movlw 4
		movwf PCLATH

		;carga indice en W

		movf	indice,w
		call tabla
		movwf valor_out
		;regresa a la página cero
		clrf PCLATH
		;chequea indice máximo
		movf indice,w
		sublw d'250'
		btfsc 3,2
		goto fin_tabla
		incf indice
		goto inicio
		;sacados todos los valores
fin_tabla	clrf indice
		goto inicio

;=================================================================================
		org 0x400		;inicio de la tabla en la 0x400
;=========================================================================
;TABLA DE CALIBRACIÓN CONDUCTIVIDAD SONDA 1
;=========================================================================
tabla		addwf PCL,1
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 25 valores -------------------------------
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 50 valores -------------------------------
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 75 valores -------------------------------
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 100 valores -------------------------------
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 125 valores -------------------------------
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 150 valores -------------------------------
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 175 valores -------------------------------
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 200 valores -------------------------------
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 225 valores -------------------------------
		retlw 0
		retlw 1
		retlw 2
		retlw 3
		retlw 4
		retlw 5
		retlw 6
		retlw 7
		retlw 8
		retlw 9
		retlw d'10'
		retlw d'11'
		retlw d'12'
		retlw d'13'
		retlw d'14'
		retlw d'15'
		retlw d'16'
		retlw d'17'
		retlw d'18'
		retlw d'19'
		retlw d'20'
		retlw d'21'
		retlw d'22'
		retlw d'23'
		retlw d'24'
;---------------- 250 valores -------------------------------

		end
