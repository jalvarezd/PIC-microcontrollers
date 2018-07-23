		list p = 16f877
		#include "p16f877.inc"


		;Ejemplo ilustrativo de utilizaci�n de direccionado indirecto de RAM
		;EJERCICIO: primero cargar 0xFF en las localizaciones de RAM desde la 0x20 hasta la 0x2F (banco 0)
		;despu�s limipar las localizaciones de RAM desde la 0x20 hasta la 0x2F (banco 0)
		;Visualizar los registros STATUS, FSR, INDF y las direcciones desde la 0x20 a la 0x2F
		;____________________________________________________________________________
		
		;definir valor del IRP
		bcf 3,7			;IRP = 0
		;____________________________________________________________________________
		;cargar primero el FSR con al direcci�n base (0x20)
		;____________________________________________________________________________
first_step	movlw 0x20
		movwf FSR
		;comienza el lazo que realiza el proceso
load_ram	movlw 0xff
		movwf INDF
		movf FSR,w
		sublw 0x2F
		btfsc STATUS,2
		goto next_step		;pr�xima operaci�n
		incf FSR		;apunta a la pr�xima
		goto load_ram		;repetir para pr�xima localizaci�n
		;fin del proceso, las localizaciones de RAM cargadas con 0xFF
		;____________________________________________________________________________
		;cargar de nuevo el FSR con la direcci�n base (0x20)
		;____________________________________________________________________________
next_step	movlw 0x20
		movwf FSR
		;comienza el lazo que realiza el proceso
clear_ram	clrf INDF
		movf FSR,w
		sublw 0x2F
		btfsc STATUS,2
		goto first_step		;repite todo de nuevo
		incf FSR		;apunta a la pr�xima
		goto clear_ram	;repetir para pr�xima localizaci�n

		end
