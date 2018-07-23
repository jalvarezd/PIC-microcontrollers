		list p = 16f877
		#include "p16f877.inc"
		;definición de variables auxiliares

num_tecla	= 0x20
cod_tecla	= 0x21

		;condiciones iniciales

		clrf num_tecla	;tecla = 00
		clrf cod_tecla	;tecla = 00

		;Ejemplo ilustrativo # 1 de utilización de creación y utilización de una tabla para decodificar un
		;teclado hipotético de 16 teclas (las teclas se enumeran desde 0 hasta 15)
		;La tabla en este caso se define a partir de la dir 0x400
		;____________________________________________________________________________
		

inicio		;carga PCLATH = 04
		movlw 4
		movwf PCLATH

		;carga indice en W

		movf	num_tecla,w
		call cod_ss
		movwf cod_tecla
		;regresa a la página cero
		clrf PCLATH
		;chequea indice máximo
		movf num_tecla,w
		sublw d'16'
		btfsc 3,2
		goto fin_tabla
		incf num_tecla
		goto inicio
		;sacados todos los valores
fin_tabla	clrf num_tecla
		goto inicio

;=================================================================================
		org 0x400		;inicio de la tabla en la 0x400
;=========================================================================
;**************************************************************************************************
;tabla de caracteres 7 segmentos para decodificar un teclado matricial.
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
;-----------------------------------------------------------------------------------------------------------------------
		end
