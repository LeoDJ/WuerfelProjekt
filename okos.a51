Cseg at 0000h
lautsprecher bit 0a0h
c1 equ 96
c1d	equ	52
d equ 85
d1d equ	59
e equ 76
e1d	equ	66
f equ 72
f1d	equ	70
g equ 64
g1d	equ	78
a1 equ 57
a1d	equ	88
h equ 51
h1d	equ	99
//________________________________________________________________________
StartProgramm:
wuerfeln BIT P3.2  
start_init:     CLR P3.6
            	CLR P3.7
start_init2:      Mov DPTR, #initialien
            Mov B,#00h
			
holbu: clr A
        movC A,@A+DPTR
		cjne A,#0FFh,start_anzeige
		JB P3.2, wuerfel_init
		sjmp start_init2
       
		    
start_anzeige:    mov R1,#7
loop1: 			mov R0,#250
loop0:
            Mov P2, B
            SETB P3.7
		    LCALL up100us
		    CLR P3.7
		    
            Mov P2, A
            SETB P3.6
		    LCALL up100us
		    CLR P3.6
		    
			djnz R0,loop0
			djnz R1,loop1
			mov B,A
			INC DPTR
		    sjmp holbu
//_______________________________________________________
//wuerfel_WuerfelZaehler:
wuerfel_init:
		mov DPTR, #siebenseg 
wuerfel_init2:	mov R7,#7
wuerfel_anzeige: DJNZ R7,wuerfel_weiter
				SETB P3.6
		 		SJMP wuerfel_init2
wuerfel_weiter:  mov A,R7
         		movC A,@A+DPTR
				 mov P2,A
				 SETB P3.6
		 
			JB P3.2, halt1
			sjmp wuerfel_anzeige
			
			
halt1: 		CLR p3.7
			CLR p3.6
			SETB P3.6					;Display anschalten
			LJMP init		
halt2:		JNB P3.3, halt2		
			SJMP wuerfel_anzeige
//_______________________________________________________
//ton_ausgabe:
init:
		mov dptr,#tondata
start:
		clr A
		movC A,@A+DPTR
		mov R0,A
		cjne A,#255,tonhoehe
		sjmp init
tonhoehe:
		inc dptr
		clr A
		movC A,@A+dptr
tp:
		mov R6,A
		clr lautsprecher
		lcall up20us
tii:
		mov R6,A
		setb lautsprecher
		lcall up20us
		djnz R0,tp
		lcall up20us
		inc dptr
		ljmp init //<----------------------------------		
up20us:
zeit2: mov R7,#09
zeit1:
djnz R7,zeit1
djnz R6,zeit2
ret
up100us:	mov R2,#50
loop:       DJNZ R2, loop
            RET
wup500ms:	
			mov R4,#5
			zeitw4:
			mov R3,#200
			zeitw3:
			mov R2,#250
			zeitw2:	
			DJNZ R2, zeitw2
			DJNZ R3, zeitw3
			DJNZ R4, zeitw4
			RET
//____________________________________________________________________________
initialien: DB 0DAh,0FAh,04Ch,04Ch,07Eh,    00h,00h,02Eh,0ECh,088h,0E8h,0ECh,0xff//E0F
siebenseg:DB 000h, 0EEh,0E6h,0D2h,0B6h,0BCh,012h, 000h
tondata: DB c1d,c1,     d1d,d,     e1d,e,      f1d,f,      g1d*2,g,      g1d*2,g,    a1d,a1,    a1d,a1,    a1d,a1,     a1d,a1,    g1d*2,g,  a1d,a1,    a1d,a1,    a1d,a1,     a1d,a1,    g1d*2,g,  f1d,f,     f1d,f,      f1d,f,     f1d,f,      e1d*2,e,     e1d*2,e,     d1d,d,      d1d,d,     d1d,d,   d1d,d,   c1d*2,c1 ,255
END