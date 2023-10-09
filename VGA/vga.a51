		$NOMOD51
		$INCLUDE (89S52.MCU)
		$INCLUDE (PAULMON.INC)
		$INCLUDE (COMMON.INC)

DATABUS		EQU	P1

SYCS		EQU	P3.2
SYRS		EQU	P3.3
SYPHI2		EQU	P3.4
SYRW		EQU	P3.5


dpl		EQU	DP0L
dph		EQU	DP0H

LOCAT		EQU	06000h
		
		ORG    LOCAT
		DB     0A5H,0E5H,0E0H,0A5H	;SIGNITURE BYTES
		DB     35,0,0,0			;ID (35=PROG), id (253=startup)
		DB     0,0,0,0			;PROMPT CODE VECTOR
		DB     0,0,0,0			;RESERVED
		DB     0,0,0,0			;RESERVED
		DB     0,0,0,0			;RESERVED
		DB     0,0,0,0			;USER DEFINED
		DB     255,255,255,255		;LENGTH AND CHECKSUM (255=UNUSED)
		DB     "SY6845",0		;MAX 31 CHARACTERS, PLUS THE ZERO

		ORG    LOCAT+64			;EXECUTABLE CODE BEGINS HERE

;
;
;		
START:		;sjmp	START1
		clr	T1			;E 6845 = low
		clr	T0			;0=display mode, 1=CRT mode
		clr	INT0			;charset 0
		clr	INT1			;screen 0
		mov	AUXR1, #0	
		
		sjmp	start2	
		
;		mov	dptr, #8000h
;start1:		movx	@dptr, a
;		nop
;		push	acc
;		call	phex
;		mov	a, P1
;		call	phex
;		pop	acc
		
		;cjne	a, P1, error1
;		inc	a
;		sjmp	start1

;error1:		
;		ret
		
start2:		call	init6845
		call	copyFont
		
		;ljmp	02000h			;start vt100 program
		
		;call	CIN
		call	testScreen
		call	testram

start3:		call	cin
		call	scrolup
		sjmp	start3
				
scrolup:	mov	dptr, #8000h
		inc	auxr1
		mov	dptr, #8000h+160
		
		mov	r0, #24		;1
scrolup2:	mov	r1, #160	;1
		
scrolup1:	movx	a, @dptr	;2
		mov	a, databus	;1
		inc	dptr		;2
		inc	auxr1		;1
		
		movx	@dptr, a	;2
		inc	dptr		;2
		inc	auxr1		;1
		
		djnz	r1, scrolup1	;2	13x160 = 2080
		djnz	r0, scrolup2	;2	24 x (3 + 2080) = 49992, * 0,543uS = 27,2ms
		
		mov	r1, #160
		inc	auxr1
		clr	a
scrolup3:	movx	@dptr, a
		inc	dptr
		djnz	r1, scrolup3
		
		ret			;	22,1184Mhz = 0,543 uS 
			
regs:		call	CIN
		cjne	A, #13, regs4
		call	testram
		ret

regs4:		clr	C
		subb	A, #'0'
		mov	R0, A
		call	PHEX
		mov	DPTR, #SYDATA
		movc	A, @A+DPTR
		mov	R1, A
		call	PHEX
		
regs3:		call	CIN
		cjne	A, #'-',regs1
		dec	R1
		ajmp	regsset
regs1:		cjne	A, #'+', regs2
		inc	R1
		ajmp	regsset
regs2:		cjne	A, #'x', regs3
		ljmp	regs	
		
regsset:	mov	A, #LOW SYDATA
		add	A, R0
		mov	DP0L, A
		mov	A, #HIGH SYDATA
		addc	A, #0
		mov	DP0H, A
		mov	A, R1
		call	PHEX
		movx	@DPTR, A
		
		setb	T0
		mov	DPTR, #8000h
		mov	A, R0
		movx	@DPTR, A
		setb	T1
		clr	T1
		inc	DPTR
		mov	A, R1
		movx	@DPTR, A
		setb	T1
		clr	T1
		clr	T0
		ajmp	regs3
					
		ret
		
		
dumpRam:	mov	DPTR, #8000h
dumpRam2:	movx	A, @DPTR
		mov	A, P1
		call	PHEX
		call	SPACE
		inc	DPTR
		mov	A, DP0L
		anl	A, #0fh
		cjne	A, #0, dumpRam1
		call	newline
dumpram1:	mov	A, DP0H
		cjne	A, #81h, dumpram2
		ret
		
testScreen:	mov	DPTR, #8000h
		mov	R0, #10

testScreen3:	mov	R1, #80
		mov	R2, #'0'		
testScreen1:	mov	A, R2
		movx	@DPTR, A
		inc	DPTR
		mov	A, #71h
		;anl	A, #3
		;orl	A, #0f0h
		;inc	A
		movx	@DPTR, A
		inc	DPTR
		inc	R2
		cjne	R2, #'9'+1, testScreen2
		mov	R2, #'0'
testScreen2:	djnz	R1, testScreen1
		djnz	R0, testScreen3		
		ret
;	
;
;	
copyFont:	
		mov	DPTR, #7000h
		inc	AUXR1
		mov	DPTR, #(8000h+2000h) ;+4000h+1000h
		inc	AUXR1

copyFont1:	clr	A
		movc	A, @A+DPTR
		inc	DPTR
		inc	AUXR1
		movx	@DPTR, A
		inc	DPTR
		inc	AUXR1
		
		mov	A, DP0H
		cjne	a, #80h, copyFont1
		
		mov	A, AUXR1
		call	PHEX
		call	newline
		ret
		
		

;
;
;
init6845hi:	
		mov	dptr, #0		;enable ADR + DAT (mode 2)
		movx	a, @dptr
		movx	a, @dptr	
																																									
		mov	DPTR, #8000h
		inc	AUXR1
		mov	DPTR, #highres
		inc	AUXR1
		mov	R0, #0
		call	setregs
		
		
init6845:	mov	dptr, #0		;enable ADR + DAT (mode 2)
		movx	a, @dptr
		movx	a, @dptr	
																																									
		mov	DPTR, #8000h
		inc	AUXR1
		mov	DPTR, #SYDATA
		inc	AUXR1
		mov	R0, #0
		
setregs:			
		mov	A, R0			; send address
		call	PHEX
		movx	@DPTR,A			; address register
		setb	T1			; clock high
		clr	T1			; clock low
		inc	DPTR			; data reg

		inc	AUXR1			; data pointer
		movc	A, @A+DPTR
		call	PHEX
		inc	AUXR1			; address pointer
		movx	@DPTR, A		; send data
		setb	T1			; clock high
		clr	T1			; clock low
		
		call	SPACE
		inc	DPTR
		inc	R0
		cjne	R0, #15, setregs
		
		mov	dp0h, #0		;disable ADR + DAT(mode 0)
		movx	a, @dptr
		movx	a, @dptr																																								
		ljmp	newline
		

;
; 25,333 Mhz / 8 = 3,166 Mhz
;
; 31468 HZ = 31,77 uS
;	
; 25,333 Mhz / 8 / 31468 ~ 	100 chars Horizontal Total
;				  2 chars Fornt Porch
;				  6 chars Back Porch
;				 80 chars Horizontal Visible
;				 12 chars Sync Pulse
;Scanline part	Pixels	Time [µs]
;Visible area	640	25.422045680238
;Front porch	16	0.63555114200596
;Sync pulse	96	3.8133068520357
;Back porch	48	1.9066534260179
;Whole line	800	31.777557100298

;Frame part	Lines	Time [ms]
;Visible area	400	12.711022840119
;Front porch	12	0.38133068520357
;Sync pulse	2	0.063555114200596
;Back porch	35	1.1122144985104
;Whole frame	449	14.268123138034
;
SYDATA:		DB	100		;R0 Horizontal Total - 1
		DB	80		;R1 Horizontal Displayed	
		DB	84		;R2 Horizontal Sync Position
		DB	0ch		;R3 VSYNC & HSYNC width
		DB	28		;R4 Vertical total - 1			;27	32
		DB	5		;R5 Vertical Adjust
		DB	25		;R6 Vertical Displayed			;25	30
		DB	27		;R7 Vertical Sync Position		;25	32
		DB	00h		;R8 Mode Control
		DB	15		;R9 Scan Lines - 1 (character lines)
		DB	0		;R10 Cursor Start
		DB	0		;R11 Cursor End
		DB	000h		;R12 Display Start High
		DB	000h		;R13 Display Start Low
		DB	0		;R14 Cursor Pos High
		DB	0		;R15 Cursor Pos Low
		DB	0		;R16 Light Pen High
		DB	0		;R17 Light Pen Low
		DB	0		;R18 Update Address Reg High
		DB	0		;R19 Update Address Reg Low
					;R31 Dummy Register
				 
highres:	DB	50		;R0 Horizontal Total - 1
		DB	40		;R1 Horizontal Displayed	
		DB	41		;R2 Horizontal Sync Position
		DB	0ch		;R3 VSYNC & HSYNC width
		DB	28		;R4 Vertical total - 1			;27	32
		DB	5		;R5 Vertical Adjust
		DB	25		;R6 Vertical Displayed			;25	30
		DB	27		;R7 Vertical Sync Position		;25	32
		DB	00h		;R8 Mode Control
		DB	15		;R9 Scan Lines - 1 (character lines)
		DB	0		;R10 Cursor Start
		DB	0		;R11 Cursor End
		DB	000h		;R12 Display Start High
		DB	000h		;R13 Display Start Low
		DB	0		;R14 Cursor Pos High
		DB	0		;R15 Cursor Pos Low
		DB	0		;R16 Light Pen High
		DB	0		;R17 Light Pen Low
		DB	0		;R18 Update Address Reg High
		DB	0		;R19 Update Address Reg Low
					;R31 Dummy Register

testram:		
		mov	R0, #00h
		mov	R1, #00h
		mov	R2, #80h
		
testloop:	call	writepage
		mov	R4, A
testloop1:	call	readpage
		cjne	A, 4, testloop1
		call	newline

		inc	R1
;		inc	R2
		cjne	R1, #20h, testloop	
		ajmp	testram
				
error:		ret
		
		
				
writepage:	mov	A, R1
		call	PHEX
		mov	A, R0
		call	PHEX
		call	space
		mov	A, R2
		call	PHEX
		call	space
			
		mov	R3, #00h
tp0:		clr	A
		mov	DP0L, R0
		mov	DP0H, R1
		movc	A, @A+DPTR
;		push	ACC
;		call	PHEX
;		call	SPACE
;		pop	ACC
		mov	DP0H, R2
		movx	@dptr, A
		add	A, R3
		mov	R3, A
		djnz	R0, tp0
		
;		call	newline
		mov	A, R3
		call	PHEX
		ret
		
		
readpage:	mov	R3, #00h
 		mov	DP0H, R2
tp1: 		mov	DP0L, R0
 		
		movx	A, @dptr
;		nop
;		nop
		mov	A, P1
;		push	ACC
;		call	PHEX
;		call	SPACE
;		pop	ACC
		add	A, R3
		mov	R3, A
		djnz	R0, tp1
	
		call	space
		mov	A, R3
		call	PHEX
		
		ret
;
;
;		;setb	SYCS			;deselect
		clr	SYRS			;address
		clr	SYPHI2			;enable
		;clr	SYRW			;write
			
loop:		inc	A
		mov	DATABUS, A		; send data
		setb	SYRS			; register data
		setb	SYPHI2			; clock high
		clr	SYPHI2			; clock low
		acall	time
		ajmp	loop					
		
time:		mov	R0, #0
		mov	R1, #0
time1:		djnz	r0, time1
		djnz	r1, time1
		ret
			
		
;LOOP:		call	CIN
;		call	COUT
;		
		ajmp	LOOP
		
	
space:		push	ACC
		mov	a, #' '
		call	COUT
		pop	ACC
		ret
		
		END