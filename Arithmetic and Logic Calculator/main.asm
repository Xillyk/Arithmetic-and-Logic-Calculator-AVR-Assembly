; 4 bit Arithmetic & Logic Calculation (Display in 8 bit)
; Created: 24/1/2563 10:49:36
; Author : Pitchapong Charmtong
; Microcontroller : Arduino Mega 2560
;
.INCLUDE	"M2560DEF.INC"							;include ATmega2560

.DEF	IN1_DDRA	= R16							;set symbolic IN1_DDRA as R16
.DEF	IN1_VALUE	= R17							;set symbolic IN1_VALUE as R17
.DEF	IN2_DDRB	= R18							;set symbolic IN2_DDRB as R18
.DEF	IN2_VALUE	= R19							;set symbolic IN2_VALUE as R19
.DEF	OUT_DDRC	= R20							;set symbolic OUT_DDRC as R20
.DEF	OUT_VALUE	= R21							;set symbolic OUT_VALUE as R21
.DEF	IN_F_VALUE	= R22							;set symbolic IN_F_VALUE as R22
.DEF	IN_F_DDRL	= R23							;set symbolic IN_F_DDRL as R23
.DEF	TMP			= R24							;set symbolic TMP as R24

.CSEG
.ORG	$00											;set program counter to hex 0
		RJMP	RESET								;relative jump to RESET:
													;set value in register
RESET:												
		LDI		TMP			, $00					;loads value $00 directly to TMP 		
		LDI		IN1_DDRA	, $F0					;loads value $F0 directly to IN1_DDRA
		LDI		IN2_DDRB	, $F0					;loads value $F0 directly to IN2_DDRB
		LDI		IN_F_DDRL	, $F8					;loads value $F8 directly to IN_F_DDRL
		LDI		OUT_DDRC	, $FF					;loads value $FF directly to OUT_DDRC
;define direction fro port pins
		OUT		DDRA , IN1_DDRA		;set bit of DDRA register to be '1111 0000' (use 4 LSB bits as INPUT port pins)
		OUT		DDRB , IN2_DDRB 	;set bit of DDRB register to be '1111 0000' (use 4 LSB bits as INPUT port pins)
		STS		DDRL , IN_F_DDRL	;set bit of DDRL register to be '1111 1000' (use 3 LSB bits as INPUT port pins) 
		OUT		DDRC , OUT_DDRC		;set bit of DDRC register to be '1111 1111' (use 8 bits as OUTPUT port pins)
		RJMP	MAIN								;relative jump to MAIN:

MAIN:
		IN		IN1_VALUE	, PINA					;load data from portA into IN1_VALUE (Read port PIN_A)							
		IN		IN2_VALUE	, PINB					;load data from portB into IN2_VALUE (Read port PIN_B)						
		ANDI	IN1_VALUE	, $0F					;Filter bit 4-7 out 
		ANDI	IN2_VALUE	, $0F					;Filter bit 4-7 out
		LDS		IN_F_VALUE	, PINL					;load direct from portL into IN_F_VALUE (Read port PIN_L)	
		ANDI	IN_F_VALUE	, $07					;Filter bit 3-7 out
		MOV		TMP	, IN1_VALUE						;copy value from IN1_VALUE into TMP
			
;check input_function_value							
		CLZ											;clear zero flag
		CPI		IN_F_VALUE	, $00					;compare input_function_value with $00						
		BREQ	THEN_RESET							;branch if equal to THEN_RESET:
		CLZ											;clear zero flag							
		CPI		IN_F_VALUE	, $01					;compare input_function_value with $01							
		BREQ	THEN_ADD							;branch if equal to	THEN_ADD:						
		CLZ											;clear zero flag
		CPI		IN_F_VALUE	, $02					;compare input_function_value with $02
		BREQ	THEN_SUB							;branch if equal to THEN_SUB:
		CLZ											;clear zero flag
		CPI		IN_F_VALUE	, $03					;compare input_function_value with $03
		BREQ	THEN_MUL							;branch if equal to THEN_MUL:
		CLZ											;clear zero flag
		CPI		IN_F_VALUE	, $04					;compare input_function_value with $04
		BREQ	THEN_SH_R							;branch if equal to THEN_SH_R:
		CLZ											;clear zero flag
		CPI		IN_F_VALUE	, $05					;compare input_function_value with $05
		BREQ	THEN_AND							;branch if equal to THEN_AND:
		CLZ											;clear zero flag
		CPI		IN_F_VALUE	, $06					;compare input_function_value with $06
		BREQ	THEN_OR								;branch if equal to THEN_OR:
		CLZ											;clear zero flag
		CPI		IN_F_VALUE	, $07					;compare input_function_value with $07
		BREQ	THEN_XOR							;branch if equal to THEN_XOR:
		CLZ											;clear zero flag
		RJMP	MAIN								;relative jump to MAIN:

;call function
THEN_RESET:
		RJMP	RESET								;relative jump to RESET:
THEN_ADD:
		CALL	F_ADD								;call to subroutine 'F_ADD'
		RJMP	ENDIF								;relative jump to ENDIF:
THEN_SUB:
		CALL	F_SUB								;call to subroutine 'F_SUB'
		RJMP	ENDIF								;relative jump to ENDIF:
THEN_MUL:
		CALL	F_MUL								;call to subroutine 'F_MUL'
		RJMP	ENDIF								;relative jump to ENDIF:
THEN_SH_R:
		CALL	F_SH_R								;call to subroutine 'F_SH_R'
		RJMP	ENDIF								;relative jump to ENDIF:
THEN_AND:
		CALL	F_AND								;call to subroutine 'F_AND'
		RJMP	ENDIF								;relative jump to ENDIF:
THEN_OR:
		CALL	F_OR								;call to subroutine 'F_OR'
		RJMP	ENDIF								;relative jump to ENDIF:
THEN_XOR:
		CALL	F_XOR								;call to subroutine 'F_XOR'
		RJMP	ENDIF								;relative jump to ENDIF:
ENDIF:

;output to led module
		MOV		OUT_VALUE , TMP						;copy value from TMP to OUT_VALUE
		COM		OUT_VALUE							;performs a One’s Complement of OUT_VALUE 
		OUT		PORTC , OUT_VALUE					;send value in OUT_VALUE out to PORTC
		RJMP	MAIN								;relative jump to MAIN:


F_ADD:
		ADD		TMP , IN2_VALUE						;TMP <- TMP + IN2_VALUE
		RET											;return from subroutine
F_SUB:
		SUB		TMP , IN2_VALUE						;TMP <- TMP - IN2_VALUE 
		RET											;return from subroutine
F_MUL:	
		MUL		TMP , IN2_VALUE						;copy value from IN2_VALUE to TMP						
		MOV		TMP , R0							;TMP <- TMP - IN2_VALUE
		RET											;return from subroutine
F_SH_R:	
		CLZ											;clear zero flag
		CPI		IN2_VALUE , $00						;compare value in IN2_value with $00
		BREQ	END_SH_R							;branch if equal to END_SH_R:
		DEC		IN2_VALUE							;declement value in IN2_VALUE
		LSR		TMP									;shifts all bits in TMP register one place to the right 
		RJMP	F_SH_R								;relative jump to F_SH_R:
END_SH_R:		
		RET											;return from subroutine
F_AND:
		AND		TMP , IN2_VALUE						;TMP <- TMP (AND operation with) IN2_VALUE
		RET											;return from subroutine
F_OR:
		OR		TMP , IN2_VALUE						;TMP <- TMP (OR operation with) IN2_VALUE
		RET											;return from subroutine
F_XOR:
		EOR		TMP , IN2_VALUE						;TMP <- TMP (XOR operation with) IN2_VALUE
		RET											;return from subroutine 
.EXIT												;exit this file
