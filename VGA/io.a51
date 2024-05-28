;
;
;
init6845:
		mov	dptr, #0		;enable ADR + DAT
		movx	a, @dptr
		
		mov	DPTR, #08000h
		inc	AUXR1
		mov	DPTR, #SYDATA
		inc	AUXR1
		mov	R0, #0
		
setregs:	
;		call	PHEX
;		call	SPACE
		
		mov	A, R0			;send address
;		call	PHEX
		movx	@DPTR,A			;address register
		setb	T1			;clock high
		clr	T1			;clock low
		inc	DPTR			;data reg

		inc	AUXR1			;data pointer
		movc	A, @A+DPTR
;		call	PHEX
		inc	AUXR1			;address pointer
		movx	@DPTR, A		;send data
		setb	T1			;clock high
		clr	T1			;clock low

;		call	SPACE
		inc	DPTR
		inc	R0
		cjne	R0, #15, setregs
		
		mov	dptr, #0		;enable ADR + DAT
		movx	a, @dptr

;		call	newline
;		call	CIN
;		
;		setb	INT0
;		call	CIN
		ret
		
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
;	
;
;	
copyFont:	
		mov	DPTR, #vt100_font
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
		;call	PHEX
		cjne	A, #80h, copyFont1
		
;		mov	A, AUXR1
;		call	PHEX
;		call	newline
		ret

;
;
;
testScreen:	mov	DPTR, #8000h
		mov	R0, #21

testScreen3:	mov	R1, #80
		mov	R2, #1		
testScreen1:	mov	A, R2
		movx	@DPTR, A
		inc	DPTR
		mov	A, #70h
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
		
testScreen4:	mov	a, r0
		movx	@dptr, a
		inc	dptr
		mov	a, #60h
		movx	@dptr, a
		inc	dptr
		inc	r0
		cjne	r0, #0, testScreen4
		ret
;
;
;
space:		push	acc
		mov	a, #' '
		call	cout
		pop	acc
		ret
		
newline:	push	acc
		mov	a, #0ah
		call	cout
		pop	acc
		ret
	

cout:		jb	serbusy, cout	
		setb	serbusy
		mov	sbuf, a
		ret
		

cin:		push	ar0
		push	ar1	
cin_2:		mov	a, serstart
		mov	r1, serend
		cjne	a, ar1, cin_1
		sjmp	cin_2
		
cin_1:		;clr	ES			;no serial interrupt
		inc	a
		setb	acc.7
		mov	r0, a
		mov	serstart, a
		
		jnb	xonoff, cin_3		;XON/XOFF active?
		cjne	a, ar1, cin_3	
		
cin_4:		;setb	ES
		mov	a, #C_XON		;yes, send XON
		acall	cout
		clr	xonoff
				
cin_3:		;setb	ES
		mov	a, @r0
		pop	ar1
		pop	ar0
		ret
	
	
;cin_x:		jnb	ri, cin
;		clr	ri
;		mov	a, sbuf
;		ret

; Highly code efficient resursive call phex contributed
; by Alexander B. Alexandrov <abalex@cbr.spb.ru>

phex:
phex8:
		acall	phex_b
phex_b:		swap	a		;SWAP A will be twice => A unchanged
phex1:		push	acc
		anl	a, #15
		add	a, #90h	; acc is 0x9X, where X is hex digit
		da	a		; if A to F, C=1 and lower four bits are 0..5
		addc	a, #40h
		da	a
		call	cout
		pop	acc
		ret

phex16:
		push	acc
		mov	a, dph
		call	phex
		mov	a, dpl
		call	phex
		pop	acc
		ret	
					
;a not so well documented feature of pstr is that you can print
;multiple consecutive strings without needing to reload dptr
;(which takes 3 bytes of code!)... this is useful for inserting
;numbers or spaces between strings.

;pstr:		push	acc
;pstr1:		clr	a
;		movc	a, @a+dptr
;		inc	dptr
;		jz	pstr2
;		mov	c, acc.7
;		anl	a, 7Fh
;		call	cout
;		jc	pstr2
;		sjmp	pstr1
;pstr2:		pop	acc
;		ret

;converts the ascii code in Acc to uppercase, if it is lowercase

; Code efficient (saves 6 byes) upper contributed
; by Alexander B. Alexandrov <abalex@cbr.spb.ru>

;upper:
;		cjne	a, #97, upper2
;upper2:		jc	upper4		;end if acc < 97
;		cjne	a, #123, upper3
;upper3:		jnc	upper4		;end if acc >= 123
;		add	a, #224		;convert to uppercase
;upper4:		ret