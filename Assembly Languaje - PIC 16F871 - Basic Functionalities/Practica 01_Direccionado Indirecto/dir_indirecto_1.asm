		list p = 16f877
		#include "p16f877.inc"


		;Ejemplo ilustrativo de utilización de direccionado indirecto de RAM
		;EJERCICIO: primero cargar 0xFF en las localizaciones de RAM desde la 0x20 hasta la 0x2F (banco 0)
		;después limipar las localizaciones de RAM desde la 0x20 hasta la 0x2F (banco 0)
		;Visualizar los registros STATUS, FSR, INDF y las direcciones desde la 0x20 a la 0x2F
		;____________________________________________________________________________
		
		;definir valor del IRP
		bcf 3,7			;IRP = 0
		;____________________________________________________________________________
		;cargar primero el FSR con al dirección base (0x20)
		;____________________________________________________________________________
first_step	movlw 0x20
		movwf FSR
		;comienza el lazo que realiza el proceso
load_ram	movlw 0xff
		movwf INDF
		movf FSR,w
		sublw 0x2F
		btfsc STATUS,2
		goto next_step		;próxima operación
		incf FSR		;apunta a la próxima
		goto load_ram		;repetir para próxima localización
		;fin del proceso, las localizaciones de RAM cargadas con 0xFF
		;____________________________________________________________________________
		;cargar de nuevo el FSR con la dirección base (0x20)
		;____________________________________________________________________________
next_step	movlw 0x20
		movwf FSR
		;comienza el lazo que realiza el proceso
clear_ram	clrf INDF
		movf FSR,w
		sublw 0x2F
		btfsc STATUS,2
		goto first_step		;repite todo de nuevo
		incf FSR		;apunta a la próxima
		goto clear_ram	;repetir para próxima localización

		end
