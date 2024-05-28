		$NOMOD51
		$INCLUDE (89S52.MCU)

;===============================================	
; adjust base for RAM or ROM version
; RAM: 02000h
; ROM: 00000h
;===============================================	
base		equ	00000h

vector		equ	base
psw_init	equ	0		;value for psw (which reg bank to use)
dnld_parm	equ 	10h		;block of 16 bytes for download
stack		equ	80h		;location of the stack
dpl		equ	dp0l
dph		equ	dp0h

		org	base
		ljmp	poweron		;reset vector

		org	base+3
		ljmp	vector+3	;ext int0 vector

r6r7todptr:
		mov	dpl, r6
		mov	dph, r7
		ret

		org	base+11
		ljmp	vector+11	;timer0 vector

dptrtor6r7:
		mov	r6, dpl
		mov	r7, dph
		ret

		org	base+19
		ljmp	vector+19	;ext int1 vector

dash:		mov	a, #'-'		;seems kinda trivial, but each time
		ajmp	moncout		;this appears in code, it takes 4
		nop			;bytes, but an acall takes only 2

		org	base+27
		ljmp	vector+27	;timer1 vector

cout_sp:	acall	moncout
		ajmp	monspace
		nop

		org	base+35
		ljmp	vector+35	;uart vector

dash_sp:	acall	dash
		ajmp	monspace
		nop

		org	base+43
		ljmp	vector+43	;timer2 vector (8052)

;---------------------------------------------------------
;first the hardware has to get initialized.
;---------------------------------------------------------
intr_return:
		reti

;---------------------------------------------------------
;poweron execution starts here
;---------------------------------------------------------
poweron:
		clr	a
		mov	ie, a		;all interrupts off
		mov	ip, a
		;clear any interrupt status, just in case the user put
		;"ljmp 0" inside their interrupt service code.
		acall	intr_return
		acall	intr_return
		cpl	a
		mov	p0, a
		mov	p1, a
		mov	p2, a
		mov	p3, a
		mov	tl1, a
		mov	th1, a
		mov	tmod, #021h	;set timer #1 for 8 bit auto-reload
		mov	pcon, #080h	;configure built-in uart
		mov	scon, #052h
		setb	tr1		;start the baud rate timer
		
		ajmp	base + 200h	;start program

monstart:	clr	a
		mov	ie, a		;all interrupts off
		mov	ip, a	
		mov	auxr1, a
		mov	r0, a
		mov	r1, a
		mov	psw, #psw_init
		mov	sp, #stack
		acall	intr_return
		acall	intr_return
		
		mov	tmod, #021h	;set timer #1 for 8 bit auto-reload
		mov	pcon, #080h	;configure built-in uart
		mov	scon, #052h
		setb	tr1		;start the baud rate timer		

monwait:	djnz	r0, monwait
		djnz	r1, monwait
		
		mov	dptr, #minitext
		call	monpstr	
		mov	dptr, #base + 0200h

monmain:	acall	monnewline
		call	monphex16
		mov	a, #'>'
		acall	moncout
		acall	moncin
		cjne	a, #'d', monmain1
		acall	download
monmain1:	cjne	a, #'g', monmain2
		acall	goto
monmain2:	cjne	a, #'h', monmain3
		acall	dump		
monmain3:	cjne	a, #'n', monmain9
		acall	newaddr		
monmain9:	acall	moncout	
		sjmp	monmain

;---------------------------------------------------------
;download routine
;---------------------------------------------------------
download:	acall	moncin
		cjne	a, #':', download
		acall	gethexbyte
		mov	r0, a
		acall	newaddr
		acall	gethexbyte
		cjne	a, #1, downloop
		acall	gethexbyte
		clr	a
		ret

downloop:	acall	gethexbyte
		movx	@dptr, a
		inc	dptr
		djnz	r0, downloop
		ajmp	download		
		
;---------------------------------------------------------
;goto routine
;---------------------------------------------------------
goto:		clr	a
		jmp	@a+dptr
;---------------------------------------------------------
;dump routine
;---------------------------------------------------------
dump:		mov	r0, #16
		acall	monnewline
		
dumpline:	call	monphex16
		acall	dspace
		mov	r1, #16
dumpline1:	clr	a
		movc	a, @a+dptr
		inc	dptr
		call	monphex
		acall	monspace
		djnz	r1, dumpline1		
		acall	monnewline

		djnz	r0, dumpline
		clr	a
		ret
;---------------------------------------------------------
;newaddr routine
;---------------------------------------------------------
newaddr:	acall	gethexbyte
		mov	dph, a
		acall	gethexbyte
		mov	dpl, a
		clr	a
		ret
		
;---------------------------------------------------------
;helper
;---------------------------------------------------------
gethexbyte:	acall	gethex
		swap	a
		mov	r7, a
		acall	gethex
		orl	a, r7
		ret
				
gethex:		acall	moncin
		cjne	a, #'a', $+3
		jc	gethex1
		subb	a, #32	
gethex1:	clr	c
		subb	a, #'0'
		cjne	a, #10, $+3
		jc	gethex2
		subb	a, #'A' - '9' - 1
gethex2:	ret

;---------------------------------------------------------;
;							  ;
;	       Subroutines for serial I/O		  ;
;							  ;
;---------------------------------------------------------;


moncin:		jnb	ri, moncin
		clr	ri
		mov	a, sbuf
		ret

dspace:		acall	monspace
monspace:	mov	a, #' '
moncout:	jnb	ti, moncout
		clr	ti		;clr ti before the mov to sbuf!
		mov	sbuf, a
		ret

;clearing ti before reading sbuf takes care of the case where
;interrupts may be enabled... if an interrupt were to happen
;between those two instructions, the serial port will just
;wait a while, but in the other order and the character could
;finish transmitting (during the interrupt routine) and then
;ti would be cleared and never set again by the hardware, causing
;the next call to cout to hang forever!

monnewline:	push	acc		;print one newline
		mov	a, #13
		acall	moncout
		mov	a, #10
		acall	moncout
		pop	acc
		ret

;a not so well documented feature of pstr is that you can print
;multiple consecutive strings without needing to reload dptr
;(which takes 3 bytes of code!)... this is useful for inserting
;numbers or spaces between strings.

monpstr:	push	acc
monpstr1:	clr	a
		movc	a, @a+dptr
		inc	dptr
		jz	monpstr2
		mov	c, acc.7
		anl	a, #07Fh
		call	moncout
		jc	monpstr2
		sjmp	monpstr1
monpstr2:	pop	acc
		ret	

; Highly code efficient resursive call phex contributed
; by Alexander B. Alexandrov <abalex@cbr.spb.ru>

monphex:	acall	monphex_b
monphex_b:	swap	a		;SWAP A will be twice => A unchanged
monphex1:	push	acc
		anl	a, #15
		add	a, #90h	; acc is 0x9X, where X is hex digit
		da	a		; if A to F, C=1 and lower four bits are 0..5
		addc	a, #40h
		da	a
		call	moncout
		pop	acc
		ret

monphex16:
		push	acc
		mov	a, dph
		call	monphex
		mov	a, dpl
		call	monphex
		pop	acc
		ret	
		
minitext:	db	13, 10, "*** Mini-Mon", 13, 10
		db	"d - download", 13, 10
		db	"g - goto", 13, 10
		db	"h - dump ext mem", 13, 10
		db	"n - new address", 13, 10+080h
		
		$include (vt102.a51)
;		$include (vt100_font.a51)
		END