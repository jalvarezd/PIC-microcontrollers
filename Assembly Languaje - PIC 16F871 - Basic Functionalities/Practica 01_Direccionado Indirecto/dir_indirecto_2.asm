		list p = 16f877
		#include "p16f877.inc"


		;Ejemplo ilustrativo de utilización de direccionado indirecto de RAM
		;EJERCICIO: transferir los datos guardados en el bloque de RAM desde "buffer1" hasta "buffer4"
		;hacia otro bloque de respaldo "c_buffer1" hasta "c_buffer4"
		;____________________________________________________________________________
		;definir direcciones del bloque origen y de respaldo:
		;BLOQUE ORIGEN (20 =====>23)

buffer1		=	0x20
buffer2		=	0x21
buffer3		=	0x22
buffer4		=	0x23

		;BLOQUE DESTINO (24 =====>27)
c_buffer1	=	0x24
c_buffer2	=	0x25
c_buffer3	=	0x26
c_buffer4	=	0x27

		;variable de respaldo temporal
temp		= 	0x28
		
		;conatadores auxiliares para desplazarse por ambos bloques
offset_1	=	0x29
offset_2	=	0x2a
		
		;definir valor del IRP
		bcf 3,7			;IRP = 0
		;____________________________________________________________________________
		;cargar primero el FSR con al dirección base DEL BLOQUE ORIGEN (0x20)
		;____________________________________________________________________________
first_step	clrf offset_1		;offset_1= 00
		movlw 4
		movwf offset_2		;offset_1= 04
		;comienza el lazo que realiza el proceso

copy_ram	;_____________________________________________
		;inicia el FSR
		movlw 0x20
		movwf FSR
		;_____________________________________________
		;suma "offset_1" al FSR para direccionar origen
		movf offset_1,w
		addwf FSR,1
		;_____________________________________________
		;descarga y respalda dato origen en temp
		movf INDF,0
		movwf temp
		;_____________________________________________
		;inicia el FSR
		movlw 0x20
		movwf FSR
		;_____________________________________________
		;suma "offset_2" al FSR para direccionar destino
		movf offset_2,w
		addwf FSR,1
		;_____________________________________________
		;descarga dato respaldado en "temp"
		movf temp,w
		movwf INDF	;graba dato en dirección destino de RAM
		;_____________________________________________
		;compara valor actual del FSR con el valor final del FSR origen (en este caso 0x23)
		movf offset_1,w
		sublw 3
		btfsc STATUS,2
		goto first_step		;fin del proceso, bloque transferido
		;incrementa los "offsets"
		incf offset_1
		incf offset_2
		goto copy_ram		;repetir para próxima localización

		;____________________________________________________________________________

		end
