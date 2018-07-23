		list p = 16f877
		#include "p16f877.inc"
		;definici�n de variables auxiliares

opcion		= 0x20
cod_tecla	= 0x21

		;condiciones iniciales

		clrf opcion	;tecla = 00

		;Ejemplo ilustrativo # 3 de utilizaci�n de creaci�n y utilizaci�n de una tabla 
		;de OPCIONES para un men� hipot�tico (tabla de "GOTOs")
		;____________________________________________________________________________
		

inicio		;carga opcion en W

		movf	opcion,w
		call opciones
		;---------------------------------------------
		;chequea �ltima opci�n
		movf opcion,w
		sublw d'2'
		btfsc 3,2
		goto fin_tabla
		incf opcion
		goto inicio
		;sacados todos los valores
fin_tabla	clrf opcion
		goto inicio

opciones	addwf PCL,1
		goto opcion1
		goto opcion2
		goto opcion3
regresar	return
;==============================================
;Opciones del Men�
;==============================================
opcion1	goto regresar
;==============================================
opcion2	goto regresar
;==============================================
opcion3	goto regresar
;==============================================

		end
