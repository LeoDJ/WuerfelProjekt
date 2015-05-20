Cseg at 0x0000

wuerfelSchalter BIT P3.2		;Pin-Definitionen
speaker 		BIT P2.0

LCD_RAM         DATA 30h


LCD_RS          EQU P0.7		;Definieren der LCD-Pins
LCD_RW          EQU P0.6
LCD_ENABLE      EQU P0.4
LCD_D4          EQU P0.0
LCD_D5          EQU P0.1
LCD_D6          EQU P0.2
LCD_D7          EQU P0.3

; Springe zum Programmbeginn
;---------------------------------------------------------------
 ORG 0h
        jmp laufInit
		
		
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

; LC-Display Ansteuerung

; LCD initialisieren
LCD_init:

; warten, bis sich das Display initialisiert hat
        mov a,#50
LCD_init_sleepsometime:
        call LCD_ws
        djnz Acc,LCD_init_sleepsometime

; Steuercodes senden
        clr LCD_RS
        clr LCD_RW
        clr LCD_ENABLE
        mov a,#00101000b
        call LCD_send_b
        setb LCD_ENABLE
        clr LCD_ENABLE
        mov a,#00101000b
        call LCD_send_b
        mov a,#1100b
        call LCD_send_b
        call LCD_clear
		

        ret
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LCD_returnhome:						;setze den Cursor zum Anfang zurück 
        push ACC
        mov a,#128					;Steuercode 0x80
        call LCD_send_b
        mov LCD_RAM,#0
        pop ACC
        ret
		
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LCD_clear:							;lösche den Display-Inhalt
        push ACC
        mov a,#1
        call LCD_send_b
        mov LCD_RAM,#0
        pop ACC
        ret
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LCD_printc:							; Ausgabe eines Charakters aus ACC
        inc LCD_RAM

        push ACC             		; bei Überlauf der Spalten in
        mov a,LCD_RAM        		; nächste Zeile weitersetzen
        cjne a,#17,LCD_no_change
        mov a,#168
        call LCD_send_b
LCD_no_change:
        pop ACC
; Zeichen ausgeben
        call LCD_send_d
        ret
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LCD_prints:
; Ausgabe eines mit 0 terminierten Strings aus DPTR
        push ACC
LCD_prints_anf:
        clr a
        movc a,@A+DPTR
        jz LCD_prints_weiter
        inc DPTR
        call LCD_printc
        jmp LCD_prints_anf
LCD_prints_weiter:
        pop ACC
        ret
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
LCD_send_b:
;sendet Befehle aus ACC an Datenport des LCD (interne Funktion)
        clr LCD_RS
        clr LCD_RW
        jmp LCD_send
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
;sendet Daten aus ACC an Datenport des LCD   (interne Funktion)
LCD_send_d:
        clr LCD_RW
        setb LCD_RS
LCD_send:
        mov c,ACC.7        ; high-nibble ausgeben
        mov LCD_D7,c
        mov c,ACC.6
        mov LCD_D6,c
        mov c,ACC.5
        mov LCD_D5,c
        mov c,ACC.4
        mov LCD_D4,c

        setb LCD_ENABLE
        call LCD_ws
        clr LCD_ENABLE

        mov c,ACC.3        ; low-nibble ausgeben
        mov LCD_D7,c
        mov c,ACC.2
        mov LCD_D6,c
        mov c,ACC.1
        mov LCD_D5,c
        mov c,ACC.0
        mov LCD_D4,c

        setb LCD_ENABLE
        call LCD_ws
        clr LCD_ENABLE

        ret
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Warteschleife für das LC-Display: 1.64ms
LCD_ws:
        push psw
        push 0
        mov  0,#232
LCD_ws_labelA:
        nop
        nop
        nop
        nop
        nop
        djnz 0,LCD_ws_labelA
        nop
        nop
        pop 0
        pop psw
        ret
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

text:      db "Bitte schwarzen Taster druecken.",0

	




;----------------------------------Lauftext------------------------------------------------------------------------------------------------------------------------------------------------------------
laufInit:   ACALL LCD_init			;Initialisierung des LCDs
			CLR P3.6
            CLR P3.7

laufInit2:  MOV DPTR, #segText		;Position des Texts
            MOV B,#00h
			
laufStart: CLR A
        MOVC A,@A+DPTR				;Hole das aktuelle Zeichen des Strings
		CJNE A,#0,laufAnzeige		;Prüfen, ob String komplett abgearbeitet ist (EOF=0)
		MOV DPTR,#text				;Ausgabe des Anleitungstexts auf dem LCD
        LCALL LCD_prints			; -"-
	    LJMP initWuerfel			;Zum Würfel-Programm Springen

		    
laufAnzeige:
			LCALL convert    		;Konvertierung des ASCII-Zeichens in 7-Segment-Code
			MOV R1,#7				; v v v v v 
            laufLoop1: MOV R0,#250  ; ab hier vorgegebenes Lauftext-Programm

			laufLoop0:

            MOV P2, B					;linken Buchstabe anzeigen
            SETB P3.7
		    LCALL up100us
		    CLR P3.7
		    
            MOV P2, A					;rechten Buchstaben anzeigen
            SETB P3.6
		    LCALL up100us
		    CLR P3.6
		    
			DJNZ R0,laufLoop0			;Verlangsamen der Scroll-Geschwindigkeit
			DJNZ R1,laufLoop1

			MOV B,A						;rechten Buchstaben (A) in linken (B) kopieren
			INC DPTR
		    SJMP laufStart 
			

up100us:								;Warteschleife für den POV-Effekt
	MOV R2,#50
	laufLoop:
		DJNZ R2, laufLoop			; bis hier
RET									; ^ ^ ^ ^ ^ ^ ^

convert:			;Funktion zur Konvertierung von ASCII-Zeichen im ACC zu 7-Segment-Code
	push DPL				;sichere den DPTR an der jeweiligen Stelle des Strings
	push DPH

	SUBB A,#0x20			;Subtrahiert 20h vom gegebenen ASCII-Zeichen, um den Offset der Lookup-Tabelle zu kompensieren
	MOV DPTR, #segData		;setze den DPTR an den Anfang der Lookup-Tabelle
	MOVC A, @A+DPTR			;hole den entsprechenden 7-Segment-Code für das ASCII Zeichen im ACC
	
	pop DPH					;hole den gesicherten DPTR
	pop DPL

RET

segText: DB "HALLO ",0		;Anzuzeigender Lauftext bei Programmbeginn (Nur Großbuchstaben erlaubt)
segData: DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	 ;ASCII Lookup-Tabelle (Start bei Zeichen 0x20)
		 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	 ;0x28
		 DB 0x7E, 0x12, 0xBC, 0xB6, 0xD2, 0xE6, 0xEE, 0x32	 ;0x30
		 DB 0xFE, 0xF6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	 ;0x38
		 DB 0xFF, 0xFA, 0xCE, 0x8C, 0x9E, 0xEC, 0xE8, 0x6E	 ;0x40
		 DB 0xDA, 0x48, 0x1E, 0xEA, 0x4C, 0x2A, 0x7A, 0x8E	 ;0x48
		 DB 0xF8, 0xF2, 0x88, 0xE6, 0xCC, 0x5E, 0x0E, 0xD4	 ;0x50
		 DB 0xA4, 0xD6, 0xBC	





;----------------------------------Würfel----------------------------------
initWuerfel: 	
			MOV DPTR, #siebenseg		;Segment-Daten-Position in den DPTR-Laden
			JNB wuerfelSchalter, halt2
			CLR P3.7
			CLR P3.6
init2Wuerfel:	
			MOV R7, #7

anzeige:	CLR P3.6					;Display abdunkeln
			;ACALL up100us
			;SETB P3.6					
			DJNZ R7, weiter				;Wenn Würfel bei 0 angekommen, reset auf 6
			SJMP init2Wuerfel
weiter: 	MOV A,R7					;Data-Offset (1-6) in ACC laden
			MOVC A,@A+DPTR				;Segment-Daten von DB laden
			MOV P2,A					;Ausgabe Segment-Daten
			
			JNB wuerfelSchalter, halt1	;Wenn Knopf gedrückt wird, Display an und Melodie abspielen
			SJMP anzeige
			
halt1: 		SETB P3.6					;Display anschalten
			LCALL melodyInit			;Melodie abspielen
halt2:		JNB wuerfelSchalter, halt2	;Solange Knopf nicht ge
			SJMP anzeige	
			

siebenseg: db 0x00, 0xee, 0xe6, 0xd2, 0xb6, 0xbc, 0x12
	
	
	
	
	
;----------------------------------Melodie----------------------------------
MOV P2,#0
MOV P3,#0


c4 EQU 96			;Tonhöhen
d4 EQU 85
e4 EQU 76
f4 EQU 72
g4 EQU 64
gis4 EQU 60
a4 EQU 57
ais4 EQU 54
h4 EQU 51
c5 EQU 96/2
d5 EQU 85/2
dis5 EQU 40
e5 EQU 76/2
f5 EQU 72/2
fis5 EQU 34
g5 EQU 64/2
gis5 EQU 60/2
a5 EQU 57/2
h5 EQU 51/2
c6 EQU 24
	
c4d EQU 33 			;Tonlängen(1/4 Note bei 120BPM)
d4d EQU 37
e4d EQU 41
f4d EQU 43
g4d EQU 49
gis4d EQU 52
a4d EQU 55
ais4d EQU 58
h4d EQU 61
c5d EQU 65 
d5d EQU 74
dis5d EQU 78
e5d EQU 82
f5d EQU 87
fis5d EQU 92
g5d EQU 98
gis5d EQU 104
a5d EQU 110
h5d EQU 123
c6d EQU 130

melodyInit:
	MOV DPTR, #tonedata			;Datenpointer an den Anfang der Meleodie setzen

melodyStart:
	CLR A
	MOVC A, @A+DPTR             ;Tonlänge auslesen
	MOV R0, A					;Tonlänge -> R0

	CJNE A, #255,tonepitch		;EOF
	;SJMP melodyInit
	CLR P2.0					;Zurück zum Würfel Programm
	LJMP initWuerfel

tonepitch:
	INC DPTR						;DPTR zu Tonhöhe bewegen
	CLR A
	MOVC A, @A+DPTR
	CJNE A, #0, tLow 				;wenn Tonhöhe=0 -> sechzentelpause*Tonlänge
	SJMP melodyDelaySemiQuarter
	tLow:							;Rechteckwelle - aus
		MOV R6, A					;Multiplikator laden
		CLR speaker					;Lautsprecher aus
		LCALL melodyDelay			;Wartschleife (von R6 abhängig)

	tHigh:							;Rechteckwelle - an
		MOV R6, A					;Multiplikator laden
		SETB speaker				;Lautsprecher an
		LCALL melodyDelay           ;Wartschleife (von R6 abhängig)

	DJNZ R0, tLow					;Solange Tonlänge > 0, Ton abspielen
	pauseEntry:						;Pausenwiedereinstiegspunkt
	MOV R6,#250 					;Kurze Pause nach den Noten
	LCALL melodyDelay
	INC DPTR						;DPTR zu nächster Note bewegen
	SJMP melodyStart

melodyDelay:						;20µs Warteschleife
	melodyDelay2:
		MOV R7, #9
		melodyDelay1:
			DJNZ R7, melodyDelay1
			DJNZ R6, melodyDelay2
	RET
	
melodyDelaySemiQuarter: 			;Sechzehntelpause (1/32s)
	CLR speaker
	dsq2:
		MOV R1,#125
	dsq1:
		MOV R2,#125
	dsq0:
		DJNZ R2, dsq0
		DJNZ R1, dsq1
		DJNZ R0, dsq2
SJMP pauseEntry
	

tonedata: DB h4d/2,h4, e5d*2,e5, 255	;Bestätigungsmelodie

END