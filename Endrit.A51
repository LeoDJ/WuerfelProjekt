Cseg at 0x0000

c1 EQU 96
d1 EQU 85
e1 EQU 76
f1 EQU 72
g1 EQU 64
a1 EQU 57
h1 EQU 51
c2 EQU 48


C1d EQU 52
D1d EQU 59
E1d EQU 66
F1d EQU 70
G1d EQU 75
A1d EQU 88
H1d EQU 90
C2d EQU 105

SSEGZ BIT P3.6
SSEGE BIT P3.7
Box BIT P2.0

CLR SSEGZ
CLR SSEGE

Lauftext:
	
	init:
		MOV A,#0				
		
	start:
		PUSH ACC					
			MOV B,A						
			INC B
			ACALL display	
		POP ACC	
		
		DJNZ R7, start
		ACALL reruns
		JB P1.0, start				
		INC A						
		CJNE A,#37, start	
		;SJMP/ACALL init
		MOV A,#0
		SJMP startdice	
		
	reruns:
		MOV R7,#15						;Speed
		RET
	
	display:
		PUSH ACC								
			MOV A,B					
			MOV DPTR, #letter_table
			MOVC A,@A+DPTR
			MOV P2, A	
							
			SETB SSEGZ					
			ACALL wait					;Multiplex
			CLR SSEGZ
		POP ACC						
		
		MOV DPTR, #letter_table
		movC A, @A+DPTR
		MOV P2, A
								
		SETB SSEGE						
		ACALL wait						;Multiplex
		CLR SSEGE
		
		RET
	

Dice:
	 ;MOV R5,#0
	init1:
		MOV A,#1				
	
	startdice:
		PUSH ACC					
			ACALL displaydice	
		POP ACC	
		;CJNE R5,#1,halt
		;LCALL TONE
			;halt:
				JNB P3.3, startdice
				
		  	;CJNE R5,#1, TONE
			INC A	
							
			CJNE A,#7, continue	
			SJMP init1
			
			continue:
				SJMP startdice
								 			
	displaydice:
		PUSH ACC													
			MOV DPTR, #dice_table
			MOVC A,@A+DPTR
			MOV P2, A				
			SETB SSEGE	
			;LCALL TONE				
		;	ACALL up20ms					
		;	CLR SSEGZ
		POP ACC	
		RET




; TONE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@	START

TONE:
	;MOV R5,#1

	initTone:
		MOV DPTR, #tondata
		
	startTone:
		JB P1.0, startTone
		CLR A
		movC A, @A+DPTR
		MOV R0, A
		CJNE A, #255, tonheight
			  
		RET
	
	
	tonheight:
		INC DPTR
		CLR A
		movC A, @A+DPTR
		
		toff:
			MOV R6, A
			CLR Box
			LCALL up20ms
		ton:
			MOV R6, A
			SETB Box
			LCALL up20ms
	
		DJNZ R0, toff
		MOV R6, #255
		LCALL up20ms
		INC DPTR
		SJMP startTone
		

; TONE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  END

up20ms:						  	;Pause 20ms
	zeit2: 
		MOV R7, #13
	zeit1:
		DJNZ R7, zeit1
		DJNZ R6, zeit2

RET


wait:							;Pause 10ms
    PUSH PSW
    PUSH 0
    PUSH 1
    MOV 1,#217
	wait_labelB1:
        MOV 0,#6
	wait_labelB0:
        NOP
		NOP
		NOP
		NOP
		NOP
        DJNZ 0,wait_labelB0
        DJNZ 1,wait_labelB1
        POP 1
        POP 0
        POP PSW
RET

letter_table:
	db 00h	;
	db 00h	;
	db 0CCh	;T
	db 0FAh ;A
	db 0EAh	;k
	db 0ECh ;E
	db 00h	;
	db 08h	;I
	db 0CCh	;T
	db 00h	;
	db 0ECh ;E
	db 0FAh ;A
	db 0E6h	;S
	db 0D6h ;Y
	db 00h	;
	db 00h	;
	db 00h  ;
	db 0F8h ; P
	db 0B6h ; 3
	db 01h  ; .
	db 0B6h ; 3
	db 00h  ;
	db 0CCh ; T
	db 8Eh  ; O
	db 00h  ;
	db 0E6h	; S
	db 0CCh ; T
	db 0FAh ; A
	db 88h  ; R
	db 0CCh ; T
	db 00h  ;
	db 9Eh  ; D
 	db 08h	; I
	db 8Ch	; C
	db 0ECh ; E
	db 00h  ;
	db 00h  ;
	
	
dice_table:
	db	080h	;-
	db  012h  	;1
	db  0BCh	;2
	db  0B6h	;3
	db  0D2h	;4
	db  0E6h	;5
	db  0EEh	;6


tondata: db C1d, c1, E1d, e1,C1d, c1, G1d*2, g1, 255

		
END
 