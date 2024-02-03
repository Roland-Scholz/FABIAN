		$NOMOD51
		$INCLUDE (89S52.MCU)

HARDWARE	equ	1

stack		equ	80h
dph		equ	DP0H
dpl		equ	DP0L

WIDTH		equ	80
HEIGHT		equ	24

ST_IDLE		equ	0
ST_ESC		equ	2
ST_CSI		equ	4
ST_ESC_Q	equ	6
ST_ESC_HASH	equ	8
ST_CMD_ARG	equ	10
ST_ESC_LBRACK	equ	12
ST_CSI_Q	equ	14
ST_ESC_RBRACK	equ	16

C_TIME		equ	10

C_BELL		equ	7
C_BACKSP	equ	8
C_TAB		equ	9
C_NEWLINE	equ	10
C_VT		equ	11
C_FF		equ	12
C_CR		equ	13
C_SO		equ	14
C_SI		equ	15
C_XON		equ	17
C_XOFF		equ	19
C_ESC		equ	27
C_DEL		equ	07fh

CCHM		equ	01Ch	;move cursor home
CCBT		equ	01Dh	;move cursor to bottom
CCLM		equ	01Eh	;move cursor to left margin
CCRM		equ	01Fh	;move cursor to right margin
	
				;SUPERF equ 0
				
CLS		equ	001h	;clear screen
BACK		equ	008h	;backspace
TABU		equ	009h	;tabulator
LF		equ	00Ah	;$9B	;end of line (RETURN)
ESC		equ	01Bh	;escape key
CCUP		equ	01Ch	;cursor up
CCDN		equ	01Dh	;cursor down
CCLF		equ	01Eh	;cursor left
CCRT		equ	01Fh	;cursor right
CSPACE		equ	020h	;space
CILN		equ	09Dh	;insert line
CDCH		equ	0FEh	;delete character
CICH		equ	0FFh	;insert character
	
F1		equ	080h	;key code for F1
F2		equ	081h	;key code for F2
F3		equ	082h	;key code for F3
F4		equ	083h	;key code for F4
F5		equ	084h	;key code for F5
F6		equ	085h	;key code for F6
F7		equ	086h	;key code for F7
F8		equ	087h	;key code for F8
F9		equ	088h	;key code for F9
F10		equ	089h	;key code for F10
F11		equ	08ah	;key code for F11
F12		equ	08bh	;key code for F12

;	special key scan-codes
ALTGR		equ	011h	;extended!
ALR		equ	011h
CLSHIFT		equ	012h
CLSTRG		equ	014h
CRSHIFT		equ	059h
CCAPS		equ	058h
		
EXTENDED	equ	0e0h
BREAK		equ	0f0h

		;	0	;Error (ignored)
DECCKM		equ	1	;Cursor key
DECANM		equ	2	;ANSI/VT52
DECCOLM		equ	3	;Column
DECSCLM		equ	4	;Scrolling
DECSCNM		equ	5	;Screen
DECOM		equ	6	;Origin
DECAWM		equ	7	;Auto wrap
DECARM		equ	8	;Auto repeating
DECINLM		equ	9	;Interlace
IRM		equ	4	;Insert Replace mode
LNM		equ	20	;new line mode


VARS		equ	020h

flags		equ	020h
special		equ	flags.0
lastchar	equ	flags.1
lchartmp	equ	flags.2
inverse		equ	flags.3
xonoff		equ	flags.4
serbusy		equ	flags.5

flags1		equ	021h
keyavail	equ	flags1.0
keyrxextended	equ	flags1.1
keyrxbreak	equ	flags1.2
keyrxshift	equ	flags1.3
keyrxaltgr	equ	flags1.4
keyrxstrg	equ	flags1.5

flags2		equ	022h
nowrap		equ	flags2.0
origin		equ	flags2.1
newlinemode	equ	flags2.2
insert		equ	flags2.3
baudflag	equ	flags2.4

retstate	equ	023h
nargs		equ	025h
arg0		equ	026h
arg1		equ	027h
arg2		equ	028h
arg3		equ	029h
dummy		equ	02ah
scursorx	equ	02bh
scursory	equ	02ch
color		equ	02dh
cursorpos	equ	02eh
cursorpos1	equ	02fh
cursorsave	equ	030h
top		equ	031h
bottom		equ	032h
state		equ	033h
serstart	equ	034h
serend		equ	035h
sercount	equ	036h
cursorx		equ	037h
cursory		equ	038h
t0cnt		equ	039h
keyrxcnt	equ	03ah
keyrxval	equ	03bh
oldstatus	equ	03ch
baudidx		equ	03dh

serbuf		equ	040h

tabutab		equ	050h	;10-bytes tabulator

free0		equ	05ah
free1		equ	05bh
free2		equ	05ch
free3		equ	05dh
free4		equ	05eh
free5		equ	05fh

		org	0
		
	IF HARDWARE = 0 
		ljmp	start
	ENDIF
		org	2003h
		ajmp	exint0
		
		org	200bh
		ajmp	timer0int
		
		org	02023h
		
serint:		push	psw
		push	acc
		push	0

		jnb	ri, serintti	;ri active?
		clr	ri		;yes

		mov	r0, serend
		inc	r0
		cjne	r0, #serbuf+16, $+3
		jc	serint1
		mov	r0, #serbuf
serint1:	mov	@r0, sbuf
		mov	serend, r0
		inc	sercount
		mov	a, sercount
		cjne	a, #8, serintti
		mov	SBUF, #C_XOFF
		setb	xonoff
		mov	r0, #80
		djnz	r0, $
		clr	ti
		
serintti:	jnb 	ti, serintex
		clr	ti
		clr	serbusy
		
serintex:	pop	0
		pop	acc
		pop	psw
		reti



;===============================================	
; Timer 0 Interrupt 0 
;===============================================
timer0int:	djnz	t0cnt, timer0int_ex
		mov	t0cnt, #C_TIME
		push	psw
		push	acc
		push	ar0
		
		mov	p2, cursorpos+1
		mov	r0, cursorpos
		movx	a, @r0
		mov	a, p1
		cpl	a
		movx	@r0, a

		pop	ar0
		pop	acc
		pop	psw
timer0int_ex:	reti
		


;===============================================	
; External Interrupt 0 (falling edge)
; collect bits sent from keyboard
; lsb first
; 8E1, start-bit (low), 8 data-bits, even-parity, stop-bit (high)
;===============================================
exint0:		push	psw
		push	acc

		mov	a, keyrxcnt
		jnz	exint0b			;first bit?
		jb	t0, exint0ex		;not zero, no startbit

exint0b:	inc	a
		mov	keyrxcnt, a
		cjne	a, #10, $+3
		jc	exint0a			;< 10, collect bits
		cjne	a, #11, exint0ex	;skip parity-bit
		mov	keyrxcnt, #0
		jnb	t0, exint0ex		;no stop bit?
		call	keydecode
		sjmp 	exint0ex
			
exint0a:	mov	a, keyrxval
		mov	c, t0
		rrc	a
		mov	keyrxval, a
					
exint0ex:	pop	acc
		pop	psw
		reti



LOCAT		equ	02100h

		org	LOCAT

		ORG    LOCAT
		DB     0A5H,0E5H,0E0H,0A5H	;SIGNITURE BYTES
		DB     35,0,0,0			;ID (35=PROG), id (253=startup)
		DB     0,0,0,0			;PROMPT CODE VECTOR
		DB     0,0,0,0			;RESERVED
		DB     0,0,0,0			;RESERVED
		DB     0,0,0,0			;RESERVED
		DB     0,0,0,0			;USER DEFINED
		DB     255,255,255,255		;LENGTH AND CHECKSUM (255=UNUSED)
		DB     "VT100",0		;MAX 31 CHARACTERS, PLUS THE ZERO

		ORG    LOCAT+64			;EXECUTABLE CODE BEGINS HERE
		
start:
		mov	sp, #stack		;set stack
						;1  1  0  1	0    1    1   1
		mov	p3, #0d7h		;RD WR T1 T0	INT1 INT0 TXD RXD
;		clr	T0
;		clr	T1			;E 6845 = low
;		clr	INT0			;charset 0
;		clr	INT1			;screen 0
		clr	a
		mov	AUXR1, a
		mov	ie, a		
		
		
;		setb	PS			;make PS high priority
						;enbale all, serial, timer0, extint0
		mov	ie, #093h		;ea - ET2 ES  ET1 EX1 ET0 EX0
		setb	it0			;set int0 to falling edge

		acall	term_reset
		
		mov	a, #C_XON
		call	cout
		
init:		call	init6845
		call	copyFont
		call	testScreen		

		mov	dptr, #8000h
		movx	a, @dptr
		mov	a, p1
		dec	a
		jz	init_loop
		mov	dptr, #0h
		movx	a, @dptr
		sjmp	init
	
init_loop:	call	cin
		cjne	a, #'x', init_1
		sjmp	init_2

init_1:		cjne	a, #'y', init_loop

loop_test:	call	cin
		call	cout
		sjmp	loop_test

		
init_2:		setb	tr0				;start timer0
		acall	term_reset

;		mov	dptr, #msg1
;		call	print
		
main_loop:	jnb	keyavail, main_serin		;key available?
		clr	keyavail			;clear key available
		mov	a, keyrxval
		cjne	a, #F5, main_F6			;F5 ?
		ajmp	init_2				;reset terminal
main_F6:	cjne	a, #F6, main_cout		;F6 ?
		mov	r0, baudidx			;switch baud
		inc	r0
		cjne	r0, #5, main_F6a
		mov	r0, #0
main_F6a:	mov	baudidx, r0
		call	getbaud
		clr	tr1
		mov	TH1, a
		mov	TH0, a
		setb	tr1
		sjmp	main_status
		
main_cout:	call	cout				;send out over serial
		cjne	a, #C_CR, main_serin		;CR sent?
		jnb	newlinemode, main_serin
		mov	a, #C_NEWLINE			;send LF, too
		call	cout	

main_serin:	mov	a, serstart			;serin available?
		cjne	a, serend, loop_cin
		sjmp	main_loop			;no serin available
		
loop_cin:	call	cin				;read from serial
		call	ansiout				;output to terminal's CRT
		
		mov	a, flags2			;have flags changed?
		xrl	a, oldstatus
		jz	main_loop			;no
		mov	oldstatus, flags2	
main_status:	call	prtstatus			;print status-line
		sjmp	main_loop
		

;===============================================	
; ansiout: dispatch according to state
;===============================================
ansiout:	mov	r7, a			;save acc in r7

		mov	a, state
		jz	do_idle			;speed up
		add	a, #ansi_tab-ansiout1+1	;fetch low-byte
		movc	a, @a+pc		
ansiout1:	push	acc			;2
		mov	a, state		;2
		add	a, #ansi_tab-ansiout2	;2
		movc	a, @a+pc		;1 fetch, high-byte
ansiout2:	push	acc			;2
		mov	a, r7			;1
		ret				;1

ansi_tab:	dw	do_idle, do_esc, do_csi, do_esc_q, do_esc_hash, do_cmd_arg, do_esc_lbrack, do_csi_q
		dw	do_esc_rbrack
		

;===============================================	
; state IDLE
;===============================================
do_idle:	mov	C, lastchar
		mov	lchartmp, C
		clr	lastchar

		clr	a
		mov	r0, a				;x-offset
		mov	r1, a				;y-offset
		mov	r2, a				;scrolling, 0 = no

do_idle_del:	cjne	r7, #C_DEL, do_idle_pre
		dec	r0
		ajmp	ansi_move
				
do_idle_pre:	cjne	r7, #32, $+3			;speed up
		jnc	draw_char
		
		cjne	r7, #C_BELL, do_idle_bs
		ret					;no bell yet

do_idle_bs:	cjne	r7, #C_BACKSP, do_idle_tab	;backspace
		dec	r0
		ajmp	ansi_move
		
do_idle_tab:	cjne	r7, #C_TAB, do_idle_nl		;tabulator
		acall	tab_set_r0_r1
do_idle_tab3:	clr	a
		inc	r1
		inc	cursorx
		cjne	r1, #8, do_idle_tab1
		inc	r0		
		mov	r1, a
		cjne	r0, #tabutab+10, do_idle_tab1
		mov	r0, a
		mov	cursorx, a
		inc	r1				
		inc	r2				;scroll on
		acall	ansi_move
		acall	tab_set_r0_r1
do_idle_tab1:	acall	getbit
		anl	a, @r0
		jz	do_idle_tab3			;bit not found
do_idle_tab2:	clr	a
		mov	r0, a
		mov	r1, a
		ajmp	ansi_move


do_idle_nl:	cjne	r7, #C_NEWLINE, do_idle_cr
do_newline:	mov	cursorx, #0
		inc	r1
		inc	r2
		ajmp	ansi_move
		
do_idle_cr:	cjne	r7, #C_CR, do_idle_esc
do_cr:		mov	cursorx, #0
		acall	ansi_move
		jb	newlinemode, do_newline		;per default, CR
		ret

do_idle_esc:	cjne	r7, #C_ESC, do_idle_so
		mov	state, #ST_ESC
		ajmp	clearargs

do_idle_so:	cjne	r7, #C_SO, do_idle_si
		setb	special
		ret

do_idle_si:	cjne	r7, #C_SI, do_idle_vt
		clr	special
		ret

do_idle_vt:	cjne	r7, #C_VT, do_idle_ff
		sjmp	do_newline
		
do_idle_ff:	cjne	r7, #C_FF, do_idle_end
		sjmp	do_newline

do_idle_end:	;ajmp	draw_char



draw_char:	push	ar7				;save r7 (received byte)
		call	cursor_off			;reset + disable cursor
							
		inc	r2				;with scroll
		jnb	lchartmp, char_out		;last char in line?
		jb	nowrap, char_out
		acall	do_newline

;===============================================	
; draws a char in ACC at cursor position
;===============================================	
char_out:	call	comp_dptr
			
		pop	ar1

		jnb	special, char_out_3	;special not set?
		cjne	r1, #060h, $+3
		jc	char_out_3		;<60h, do nothing
		cjne	r1, #07fh, $+3
		jnc	char_out_3		;>=7fh, do nothing
		mov	a, r1
		subb	a, #5eh			;carry set! subtract 5fh
		mov	r1, a
char_out_3:	jnb	insert, char_out_4	;insert mode?
		
		clr	c
		mov	a, #WIDTH-1
		subb	a, cursorx
		rlc	a			;* 2
		jz	char_out_4
		mov	r0, a			;R0: number of chars to copy in
		inc	a
				
		add	a, dp1l			;add r0, to dptr1 (destination)
		mov	dp1l, a			
		mov	a, dp1h
		addc	a, #0
		mov	dp1h, a
		
		mov	a, dp1l			;dptr0 = dptr1 - 2 (source)
		subb	a, #2
		mov	dp0l, a
		mov	a, dp1h
		subb	a, #0
		mov	dp0h, a		
		

		
		
char_out_2:	movx	a, @dptr		;copy r0 bytes from right to left
		inc	auxr1
		mov	a, p1
		movx	@dptr, a
		inc	auxr1
		mov	a, dp0l
		jnz	char_out_2a
		dec	dp0h
char_out_2a:	dec	dp0l
		mov	a, dp1l
		jnz	char_out_2b
		dec	dp1h
char_out_2b:	dec	dp1l
		djnz	r0, char_out_2
		call	comp_dptr

char_out_4:	mov	a, r1
		inc	auxr1
		movx	@dptr, a
		inc	dptr
		mov	a, color
		jnb	inverse, char_out_1
		swap	a		
char_out_1:	movx	@dptr, a
		inc	auxr1
				
		mov	a, cursorx
		cjne	a, #WIDTH-1, draw_char_1
		setb	lastchar

draw_char_1:	mov	r0, #1
		mov	r1, #0
		call	draw_cursor
		ajmp	ansi_move

;===============================================	
; state ESC
;===============================================	
do_esc:		mov	state, #ST_IDLE	
		cjne	a, #C_ESC, do_esc_csi
		jmp	0h
		
do_esc_csi:	cjne	a, #'[', do_esc_7	;switch to CSI state
		mov	state, #ST_CSI
		ret
		
do_esc_7:	cjne	a, #'7', do_esc_8	;save cursor
		mov	scursorx, cursorx
		mov	scursory, cursory
		ret
					
do_esc_8:	cjne	a, #'8', do_esc_D	;restore cursor
		mov	cursorx, scursorx
		mov	cursory, scursory
		jmp	move_cursor
			
do_esc_D:	cjne	a, #'D', do_esc_M	;move cursor down and scroll
		inc	r2			;with scrolling
		mov	a, #'B'
		ajmp	do_csi_keys		;do cursor down
	
do_esc_M:	cjne	a, #'M', do_esc_ha	;move cursor up and scroll
		inc	r2			;with scrolling
		mov	a, #'A'
		ajmp	do_csi_keys		;do cursor up
		
do_esc_ha:	cjne	a, #'#', do_esc_lbr
		mov	state, #ST_ESC_HASH
		ret

do_esc_lbr:	cjne	a, #'(', do_esc_rbr
		mov	state, #ST_ESC_LBRACK
		ret

do_esc_rbr:	cjne	a, #')', do_esc_c
		mov	state, #ST_ESC_RBRACK
		ret

do_esc_c:	cjne	a, #'c', do_esc_H
		ajmp	term_reset

do_esc_H:	cjne	a, #'H', do_esc_Z
		acall	tab_set_r0_r1
		acall	getbit
		orl	a, @r0
		mov	@r0, a
		ret

do_esc_Z:	cjne	a, #'Z', do_esc_ex		
		ajmp	do_csi_cc2
		
do_esc_ex:	ret
		
;===============================================	
; state CSI
;===============================================	
do_csi:
		acall	isparm			;is parameter?
		jnc	do_csi_keys		;no
		mov	retstate, state
		mov	state, #ST_CMD_ARG
		jmp	do_cmd_arg
				
do_csi_keys:	mov	r0, #0			;x (column)
		mov	r1, #0			;y (row		
		mov	state, #ST_IDLE

		cjne	a, #'A', do_csi_B	;cursor up 
		acall	args_gr_zero
		mov	a, arg0
		cpl	a
		inc	a
		mov	r1, a
		ajmp	ansi_move


do_csi_B: 	cjne	a, #'B', do_csi_C	;cursor down
		acall	args_gr_zero
		mov	r1, arg0
		ajmp	ansi_move


do_csi_C:	cjne	a, #'C', do_csi_D	;cursor right
		acall	args_gr_zero
		mov	r0, arg0
		ajmp	ansi_move


do_csi_D:	cjne	a, #'D', do_csi_H 	;cursor left
		acall	args_gr_zero
		mov	a, arg0
		cpl	a
		inc	a
		mov	r0, a
		ajmp	ansi_move


do_csi_H:	cjne	a, #'H', do_csi_H1	;position cursor
		sjmp	do_csi_H2
do_csi_H1:	cjne	a, #'f', do_csi_s
do_csi_H2:	acall	args_gr_zero
		mov	a, arg0
		dec	a
		mov	cursory, a
		mov	a, arg1
		dec	a
		mov	cursorx, a
		ajmp	ansi_move


do_csi_s:	cjne	a, #'s', do_csi_u	;save cursor
		mov	scursorx, cursorx
		mov	scursory, cursory
		ret
		

do_csi_u:	cjne	a, #'u', do_csi_m	;restore cursor
		mov	cursorx, scursorx
		mov	cursory, scursory
		ajmp	ansi_move		


do_csi_m:	cjne	a, #'m', do_csi_n	;color handling
		mov	r1, nargs
		cjne	r1, #0, do_csi_ma
		mov	color, #0f0h		;no args, reset
		clr	inverse
		ret
do_csi_ma:	mov	r0, #arg0
do_csi_mc:	mov	a, @r0
		cjne	a, #0, do_csi_md	;if arg = 0, all attrs off
		mov	color, #0f0h
		clr	inverse
		ajmp	do_csi_mx3		;loop nargs		
do_csi_md:	cjne	a, #30, do_csi_mb
do_csi_mb:	jnc	do_csi_me		;arg >= 30
		sjmp	do_csi_mx		;loop nargs
do_csi_me:	cjne	a, #38, do_csi_mf
do_csi_mf:	jnc	do_csi_mx3		;>= 38	loop nargs
		subb	a, #29			; - 30 (carry set!)
		swap	a
		mov	r2, a
		mov	a, color
		anl	a, #0fh
		orl	a, r2
		mov	color, a
		ajmp	do_csi_mx3		;loop nargs				
do_csi_mg:	cjne	a, #40, $+3
		jnc	do_csi_mh		;>= 40
		ajmp	do_csi_mx		;loop nargs		
do_csi_mh:	cjne	a, #48, $+3
		jnc	do_csi_mx		;>= 48 loop
		subb	a, #39			;- 40 (carry set!)
		mov	r2, a
		mov	color, a
		anl	a, #0f0h
		orl	a, r2
		mov	color, a
		ajmp	do_csi_mx3		; loop nargs
do_csi_mx:	cjne	a, #7, do_csi_mx1	; inverse
		setb	inverse
do_csi_mx1:	cjne	a, #1, do_csi_mx2	; bold
		mov	color, #30h
do_csi_mx2:	cjne	a, #5, do_csi_mx3
		mov	color, #10h
do_csi_mx3:	inc	r0
		djnz	r1, do_csi_mc
		ret 

do_csi_n:	cjne	a, #'n', do_csi_cc	;terminal status report
		mov	a, arg0
		cjne	a, #5, do_csi_n6
		mov	r0, #1			;always OK: "ESC [ 0 n"
do_csi_n1:	mov	a, r0
		call	getreport
		call	cout
		inc	r0
		cjne	r0, #5, do_csi_n1
		ret	
do_csi_n6:	cjne	a, #6, do_csi_cc		;report cursor position
		mov	a, #ESC
		call	cout
		mov	a, #'['
		call	cout		
		mov	a, cursory
		subb	a, top
		call	sendpos
		mov	a, #';'
		call	cout
		mov	a, cursorx
		call	sendpos
		mov	a, #'R'
		jmp	cout
			
sendpos:	inc	a
		call	hex2dez
		mov	a, r0
		call	cout
		mov	a, r1
		jmp	cout

getreport:	movc	a, @a+pc
		ret
reportok:	db	ESC, "[0n"		;terminal OK
reportda:	db	ESC, "[?1;0c"		;device attributes (VT100, no options)
	
do_csi_cc:	cjne	a, #'c', do_csi_r
do_csi_cc2:	mov	r0, #5			;reportda
do_csi_cc1:	mov	a, r0
		call	getreport
		call	cout
		inc	r0
		cjne	r0, #5+7, do_csi_cc1
		ret
		
do_csi_r:	cjne	a, #'r', do_csi_J	;set scroll margins
		mov	a, nargs
		jnz	do_csi_ra		;nargs > 0
		mov	top, #0
		mov	bottom, #HEIGHT-1
		sjmp	do_csi_rc
do_csi_ra:	acall	args_gr_zero
		cjne	a, #2, $+3
		jnc	do_csi_rb		;>= 2 args
		mov	top, arg0
		dec	top
		mov	bottom, #HEIGHT-1
		sjmp	do_csi_rc
do_csi_rb:	mov	a, arg0
		subb	a, arg1			;carry clear!
		jnc	do_csi_J		; a >= b
		mov	top, arg0
		dec	top

		mov	a, arg1
		cjne	a, #HEIGHT+1, $+3
		jc	do_csi_re
		mov	a, #HEIGHT
do_csi_re:	dec	a
		mov	bottom, a

do_csi_rc:	clr	a			;cursor home
		mov	r0, a
		mov	r1, a
		mov	cursorx, a
		mov	cursory, a
		jnb	origin, do_csi_rd
		mov	cursory, top			
do_csi_rd:	ajmp	ansi_move
	
	
do_csi_J:	cjne	a, #'J', do_csi_ques		;ED – Erase In Display
		mov	r0, arg0
do_csi_Ja:	cjne	r0, #0, do_csi_Jb
do_csi_Jc:	mov	r0, cursory			;Erase from the active position to the end of the screen, inclusive (default)
		mov	r1, #HEIGHT-1			;y from cursory to HEIGHT-1
		mov	r2, cursorx			;start position x
		mov	a, #WIDTH			;chars to erase first line
		subb	a, r2
		mov	r3, a			
		mov	r5, #WIDTH			;chars to erase last line
		jmp	clear_lines

do_csi_Jb:	cjne	r0, #1, do_csi_Jd
		mov	r0, #0				;Erase from start of the screen to the active position, inclusive
		mov	r1, cursory
		mov	r2, #0
		mov	r3, #WIDTH			;chars to erase first line
		mov	r5, cursorx		
		inc	r5				;chars to erase last line
		jmp	clear_lines

do_csi_Jd:	cjne	r0, #2, do_csi_ques	
		mov	r0, #0				;Erase all of the display – all lines are erased and the cursor does not move.
		mov	r1, #HEIGHT-1
		mov	r2, #0
		mov	r3, #WIDTH			;chars to erase first line
		mov	r5, #WIDTH			;chars to erase first line
		jmp	clear_lines	

do_csi_ques:	cjne	a, #'?', do_csi_K
		mov	state, #ST_CSI_Q
		ret

do_csi_K:	cjne	a, #'K', do_csi_g
		mov	r0, cursory
		mov	r1, cursory
		mov	a, arg0
		cjne	a, #0, do_csi_Ka		;Erase from the active position to the end of the line, inclusive (default)
		mov	r2, cursorx
		mov	a, #WIDTH
		subb	a, r2
		mov	r5, a
		jmp	clear_lines
do_csi_Ka:	cjne	a, #1, do_csi_Kb		;Erase from the start of the screen to the active position, inclusive
		mov	r2, #0
		mov	r5, cursorx
		inc	r5
		jmp	clear_lines
do_csi_Kb:	cjne	a, #2, do_csi_end1		;Erase all of the line, inclusive
		mov	r2, #0
		mov	r5, #WIDTH
		jmp	clear_lines
do_csi_end1:	ajmp	do_csi_end

do_csi_g:	cjne	a, #'g', do_csi_L
		mov	a, arg0
		cjne	a, #3, do_csi_g1
		ajmp	cleartabu			;clear all tabs
do_csi_g1:	acall	tab_set_r0_r1
		acall	getbit
		cpl	a
		anl	a, @r0
		mov	@r0, a
		ajmp	do_csi_end

do_csi_L:	cjne	a, #'L', do_csi_MM		;insert line
		acall	args_gr_zero
		mov	a, cursory			;check if within bounds
		cjne	a, top, $+3
		jc	do_csi_end1
		cjne	a, bottom, $+3
		sjmp	do_csi_L1
		jnc	do_csi_end1
do_csi_L1:	call	cursor_off
		mov	r0, arg0
do_csi_L2:	mov	r3, #-1
		clr	c
		mov	a, bottom
		subb	a, cursory
		mov	r4, a
		acall	scroll_r4
		djnz	r0, do_csi_L2
		jmp	cursor_on

do_csi_MM:	cjne	a, #'M', do_csi_hh		;delete line
		acall	args_gr_zero
		mov	a, cursory			;check if within bounds
		cjne	a, top, $+3
		jc	do_csi_end1
		cjne	a, bottom, $+3
		sjmp	do_csi_MM1
		jnc	do_csi_end1
do_csi_MM1:	call	cursor_off
		mov	r0, arg0
		push	top
do_csi_MM2:	mov	r3, #1
		clr	c
		mov	a, bottom
		subb	a, cursory
		mov	r4, a
		mov	top, cursory
		acall	scroll_r4
		djnz	r0, do_csi_MM2 
		pop	top
		jmp	cursor_on
		
do_csi_hh:	mov	state, #ST_IDLE			;h set NEWLINE / INSERT
		mov	oldstatus, flags2

		cjne	a, #'h', do_csi_ll		;set mode
		mov	r0, #arg0
		mov	r1, nargs
		cjne	r1, #0, do_csi_hh1		;>= 1 arg
		ret
do_csi_hh1:	cjne	@r0, #LNM, do_csi_hh2 
		setb	newlinemode			;set newlinemode
do_csi_hh2:	cjne	@r0, #IRM, do_csi_hhx 
		setb	insert				;set insert mode
do_csi_hhx:	inc	r0
		djnz	r1, do_csi_hh1
		ret

do_csi_ll:	cjne	a, #'l', do_csi_P		;h reset NEWLINE / INSERT
		mov	r0, #arg0
		mov	r1, nargs
		cjne	r1, #0, do_csi_ll1
		ret
do_csi_ll1:	cjne	@r0, #LNM, do_csi_ll2		
		clr	newlinemode			;clear newlinemode		
do_csi_ll2:	cjne	@r0, #IRM, do_csi_llx	
		clr	insert				;clear insert mode		
do_csi_llx:	inc	r0
		djnz	r1, do_csi_ll1
		ret
		
do_csi_P:	cjne	a, #'P', do_csi_end		;Delete Character (DCH)
		acall	args_gr_zero
		mov	r1, arg0
do_csi_P2:	clr	c
		mov	a, #WIDTH-1
		subb	a, cursorx
		jz	do_csi_end			;nothing to do
		rl	a
		mov	r0, a				
		call	comp_dptr			;compute dptr1
		mov	dp0l, dp1l			;copy to dptr0
		mov	dp0h, dp1h
		inc	dptr				;
		inc	dptr				;dptr0 = dptr1 + 2
		
do_csi_P1:	movx	a, @dptr
		mov	a, P1
		inc	dptr
		inc	auxr1
		movx	@dptr, a
		inc	dptr
		inc	auxr1
		djnz	r0, do_csi_P1
		inc	auxr1
		clr	a
		movx	@dptr, a	
		inc	auxr1
		djnz	r1, do_csi_P2
do_csi_end:	ret

;		mov	a, r0
;		call	phex
;		mov	a, dp0h
;		call	phex
;		mov	a, dp0l
;		call	phex
;		call	space
;		mov	a, dp1h
;		call	phex
;		mov	a, dp1l
;		call	phex
;		call	space
;		call	space

;===============================================	
; state CSI_questionmark "ESC [ ?"
;===============================================
do_csi_q:	acall	isparm				;is parameter?
		jnc	do_csi_q_h			;no	
		mov	retstate, state
		mov	state, #ST_CMD_ARG
		ajmp	do_cmd_arg
		
do_csi_q_h:	mov	state, #ST_IDLE
		mov	oldstatus, flags2

		cjne	a, #'h', do_csi_q_l		;set mode
		mov	r0, #arg0
		mov	r1, nargs
		cjne	r1, #0, do_csi_q_h1		;>= 1 arg
		ret
do_csi_q_h1:	cjne	@r0, #DECAWM, do_csi_q_h2	;set auto wrap
		clr	nowrap
do_csi_q_h2:	cjne	@r0, #DECOM, do_csi_q_hx	;set origin
		setb	origin
		ajmp	do_csi_rc			;position cursor home
do_csi_q_hx:	inc	r0
		djnz	r1, do_csi_q_h1
		ret

do_csi_q_l:	cjne	a, #'l', do_csi_q_end		;reset mode
		mov	r0, #arg0
		mov	r1, nargs
		cjne	r1, #0, do_csi_q_l1
		sjmp	do_csi_end
do_csi_q_l1:	cjne	@r0, #DECAWM, do_csi_q_l2	;reset auto wrap
		setb	nowrap
do_csi_q_l2:	cjne	@r0, #DECOM, do_csi_q_lx	;reset origin
		clr	origin
		ajmp	do_csi_rc			;position cursor home
do_csi_q_lx:	inc	r0
		djnz	r1, do_csi_q_l1
do_csi_q_end:	ret


;===============================================	
; state ESC_questionmark "ESC ?"
;===============================================
do_esc_q:
		mov	state, #ST_IDLE
		ret

;===============================================	
; state ESC_hash "ESC #"
;===============================================
do_esc_hash:	mov	state, #ST_IDLE

		cjne	a, #'8', do_esc_hash_end
		mov	r4, #'E'
		jmp	fill_screen

do_esc_hash_end:
		ret


;===============================================	
; state ESC right-bracket "ESC )"
;===============================================
do_esc_rbrack:
;===============================================	
; state ESC left-bracket "ESC ("
;===============================================
do_esc_lbrack:	mov	state, #ST_IDLE

		cjne	a, #'0', do_esc_lb_1
		setb	special
		ret
do_esc_lb_1:	clr	special
		ret


;===============================================	
; state command arg
;===============================================
do_cmd_arg:	
		mov	r1, a			;save a
		mov	a, #arg0		;pointer to vars
		add	a, nargs
		mov	r0, a
		mov	a, r1
		acall	isdigit
		jnc	do_cmd_arg_1		;no digit
;		inc	argcnt
		mov	a, @r0
		mov	b, #10
		mul	ab
		add	a, r1
		subb	a, #'0'
		mov	@r0, a
		ret
do_cmd_arg_1:	cjne	a, #';', do_cmd_arg_2
		inc	nargs
;		mov	a, argcnt
;		jnz	do_cmd_arg_3
;		mov	@r0, #1
;do_cmd_arg_3:	mov	argcnt, #0
		ret
do_cmd_arg_2:	cjne	a, #C_ESC, do_cmd_arg_3
		mov	state, #ST_ESC
		ret
do_cmd_arg_3:	inc	nargs
		mov	state, retstate
do_cmd_arg_4:	;mov	retstate, #0
		ajmp	ansiout
		
		
;
; set arg0-3 to one if zero
;
args_gr_zero:	push	ar0
		push	ar1
		mov	r0, #arg0
		mov	r1, #4
args_gr_zero_2:	cjne	@r0, #0, args_gr_zero_1
		inc	@r0
args_gr_zero_1:	inc	r0
		djnz	r1, args_gr_zero_2
		pop	ar1
		pop	ar0
		ret
		
; r0: x - offset
; r1: y - offset
; r2: 0: without scroll, 1: with scroll
; r3: scroll occured
; r4: 0 = within bounds, 1 = out of bounds
ansi_move:	
		;acall	cursor_off
				
		mov	r3, #0			;no scroll
		mov	r4, top
		mov	r5, bottom

;
; check new x-posiion
;				
		mov	a, r0
		add	a, cursorx		;< 0?
		jnb	acc.7, ansi_move_x1	;no, check width
		clr	a
ansi_move_x1:	cjne	a, #WIDTH, $+3		;>= WIDTH ?
		jc	ansi_move_x3		;< WIDTH
		mov	a, #WIDTH-1		;=WIDTH, set to WIDTH-1
ansi_move_x3:	mov	cursorx, a

;
; check if within margins
;	
		jb	origin, ansi_move_y	;if origin, no out-of-margins
		mov	a, cursory		;check margins
		cjne	a, top, $+3
		jc	ansi_move_m1		;< top!
		cjne	a, bottom, $+5
		sjmp	ansi_move_y		;= bottom
		jc	ansi_move_y		;< bottom
ansi_move_m1:	clr	a
		mov	r2, a			;no scroll
		mov	r4, a
		mov	r5, #HEIGHT-1
	
;
; check y-position
;	
ansi_move_y:	mov	a, r1
		add	a, cursory		;
		jb	acc.7, ansi_move_y2	;< 0
		cjne	a, ar4, $+3		;
		jnc	ansi_move_y1		;>= top
ansi_move_y2:	clr	c
		subb	a, r4
		mov	r3, a
		mov	a, r4			;< top, set to top
					
ansi_move_y1:	cjne	a, ar5, $+5		;= bottom ?
		sjmp	ansi_move_y3		;yes 
		jc	ansi_move_y3		;< bottom?
		subb	a, r5			;no, >bottom
		mov	r3, a
		mov	a, r5			;set to bottom	
ansi_move_y3:	mov	cursory, a
		call	cursor_off
			
		mov	a, r2			;is scrolling enabled ?
		jz	ansi_move_ex		;no, exit
		mov	a, r3			;did scrolling occur?
		jz	ansi_move_ex		;no, exit
		
		acall	scroll
		
ansi_move_ex:	call	draw_cursor
		ret
		
;ansi_line_left:	
		;call	phex
;		ret
				
isparm:		acall	isdigit
		jc	isparmex
		cjne	a, #';', isparm1
		setb	c
isparmex:	ret
isparm1:	clr	c
		ret
;
; is acc beteen '0' and '9'?
; if so, return carry clear, set otherwise
;
isdigit:	cjne	a, #'0', isdigit1	
isdigit1:	jnc	isdigit2		;>= '0'
		cpl	c
		ret				;carry set		
isdigit2:	cjne	a, #'9'+1, isdigit3
isdigit3:	ret				;= '9' carry clear



;===============================================	
; reset terminal
;===============================================	
term_reset:	clr	ea
		acall	clear_vars
		mov	color, #0f0h
		mov	bottom, #HEIGHT-1
		mov	serstart, #serbuf
		mov	serend, #serbuf
		mov	t0cnt, #C_TIME

		acall	resettabu
		call	clear_screen
		setb	ea
	
		call	prtstatus
		call	draw_cursor
		ret
		
;
; clear 32 vars from "state" on
;	
clear_vars:	mov	r0, #VARS	;clear term-vars
		mov	r1, #64
clear_v1:	mov	@r0, #0
		inc	r0
		djnz	r1, clear_v1
		ret
		
		
resettabu:	mov	r0, #tabutab
		mov	r1, #10
resettabu1:	mov	@r0, #128
		inc	r0
		djnz	r1, resettabu1
		mov	tabutab, r1	;R1 = 0
		inc	tabutab+9	;128 + 1 = 129
		ret


cleartabu:	mov	r0, #tabutab
		mov	r1, #10
cleartabu1:	mov	@r0, #0
		inc	r0
		djnz	r1, cleartabu1
		inc	tabutab+9	;tabutab+9 = 1
		ret

;
; compute 
; r0 = cursorx / 8 (byte holding tab-info) + tabutab
; r1 = cursorx AND 7 (bi tposition within byte)
;
tab_set_r0_r1:	mov	a, cursorx		
		rr	a
		rr	a
		rr	a
		anl	a, #0fh
		add	a, #tabutab
		mov	r0, a				;address byte
		mov	a, cursorx
		anl	a, #7
		mov	r1, a
		ret
		
		
getbit:		mov	a, r1
		inc	a
		movc	a, @a+pc
		ret
getbittab:	db	128, 64, 32, 16, 8, 4, 2, 1


clearargs:	mov	r0, #nargs
		mov	r1, #5
clearargs1:	mov	@r0, #0
		inc	r0
		djnz	r1, clearargs1
		ret


print:		clr	a
		movc	a, @a+dptr
		jnz	print1
		ret
print1:		acall	ansiout
		inc	dptr
		sjmp	print

;msg1:		db	C_ESC, "[J", C_ESC, "[5;5H", 0
;msg4:		db	C_ESC,"[5;65H", C_ESC,"[31mH", C_ESC,"[32mello ", C_ESC, "[mWorld", C_ESC, "[AJ", C_ESC, "[23;65Ha", C_ESC, "[H"
;msg2:		db	"Hello world!", C_NEWLINE,0
;msg3:		db	C_ESC, "[5C", C_ESC, "[7D", 0	

;===============================================	
; pyhsical routines
;===============================================

;===============================================
; scrolls one line up or down
; clear first or last line	
; r3 positive (0-127) scroll-up, scroll-down otherwise
; r4 numbers of lines to scroll
; ----------------------------------------------
; r5 used for x-count
;===============================================	
scroll:		clr	c
		mov	a, bottom
		subb	a, top
		mov	r4, a			;number of lines to scroll
scroll_r4:		
		cjne	r3, #128, $+3
		jc	scroll_up		;<128, positive, scroll up
		
		mov	a, bottom
		dec	a
		mov	b, #WIDTH*2
		mul	ab
		add	a, #(WIDTH*2)-1
		mov	dp0l, a
		mov	a, b
		addc 	a, #80h
		mov	dp0h, a
		
		mov	a, dp0l
		add	a, #WIDTH*2
		mov	dp1l, a		
		mov	a, dp0h
		addc	a, #0
		mov	dp1h, a
		
;		call	phex16
;		mov	a, dp1h
;		call	phex
;		mov	a, dp1l
;		call	phex		
;		jmp	cursor_on
		
		mov	a, r4
		jz	scroll_down_6
scroll_down_4:
		mov	r5, #WIDTH*2
scroll_down_1:		
		movx	a, @dptr
		mov	a, P1
		inc	auxr1
		movx	@dptr, a
		inc	auxr1

		mov	a, dp0l
		jnz	scroll_down_2
		dec	dp0h
scroll_down_2:	dec	dp0l

		mov	a, dp1l
		jnz	scroll_down_3
		dec	dp1h
scroll_down_3:	dec	dp1l
		
		djnz	r5, scroll_down_1
		djnz	r4, scroll_down_4

		inc	dptr
		
		;call	phex16	
scroll_down_6:			
		mov	r5, #WIDTH*2
		clr	a
scroll_down_5:	movx	@dptr, a
		inc	dptr
		djnz	r5, scroll_down_5

		;ajmp	cursor_on		;reactivate cursor
		ret
		
scroll_up:	
		mov	a, top			;dp0 = topline
		mov	b, #WIDTH * 2		;dp1 = topline + 1
		mul	ab
		mov	dp0l, a
		mov	a, b
		addc	a, #80h
		mov	dp0h, a
		
		mov	a, dp0l
		add	a, #WIDTH * 2
		mov	dp1l, a		
		mov	a, dp0h
		addc	a, #0
		mov	dp1h, a
		
		mov	a, r4
		jz	scroll_up_4

scroll_up_1:		
		mov	r5, #WIDTH * 2

scroll_up_2:	inc	auxr1			;copy from line n+1 to line n
		movx	a, @dptr
		inc	dptr
		mov	a, P1
		inc	auxr1
		movx	@dptr, a
		inc	dptr	
		djnz	r5, scroll_up_2
		djnz	r4, scroll_up_1		

scroll_up_4:
		mov	r5, #WIDTH * 2		;clear last line
		clr	a
scroll_up_3:	movx	@dptr, a
		inc	dptr
		djnz	r5, scroll_up_3
		
		ret
		;ajmp	cursor_on		;restore cursor


;
; r0: top line
; r1: bottom line
; r2: start position first line
; r3: chars to fill first line
; r4: value filled with
; r5; chars to fill last line
;
clear_screen:	mov	r4, #0
fill_screen:	clr	a
		mov	r0, a
		mov	r1, #HEIGHT-1
		mov	r2, a
		mov	r3, #WIDTH
		mov	r5, #WIDTH
		sjmp	fill_lines

clear_lines:	
		mov	r4, #0				;fill with zero
fill_lines:
		mov	a, r2				;r2 = r2 * 2
		rl	a
		mov	r2, a
				
		mov	a, r1				;r1 = r1 - r0 + 1
		clr	c
		subb	a, r0
		inc	a
		mov	r1, a				;line count in r1
		
		mov	a, r0				;compute start-position from r0 und r2
		mov	b, #WIDTH * 2
		mul	ab
		add	a, r2
		mov	dp1l, a
		mov	a, b
		addc	a, #80h
		mov	dp1h, a
				
		inc	auxr1				;switch to dptr1
		mov	r0, ar3				;chars to fill first line

clear_lines2:	cjne 	r1, #1, clear_lines1		;last line?
		mov	r0, ar5				;chars to fill last line
clear_lines1:	mov	a, r4
		movx	@dptr, a
		inc	dptr
		mov	a, #70h
		movx	@dptr, a
		inc	dptr
		djnz	r0, clear_lines1
		mov	r0, #WIDTH		
		djnz	r1, clear_lines2
		inc	auxr1
		ret

		
;===============================================	
; move cursor
;===============================================
move_cursor:	call	cursor_off			;restore color under cursor
draw_cursor:	call	comp_dptr			;compute new address
		inc	auxr1				;increase by 1 for color
		inc	dptr
		inc	auxr1
		mov	cursorpos, dp1l			;store in cursorpos/+1
		mov	cursorpos+1, dp1h
		
;		ajmp	cursor_on			;save color under cursor
;
; save color under new cursor position in cursorsave
; enable interrupt
;
cursor_on:	;mov	a, cursorpos+1
		;call	phex
		;mov	a, cursorpos
		;call	phex
		
		mov	dp1l, cursorpos
		mov	dp1h, cursorpos+1
		inc	auxr1
		movx	a, @dptr
		mov	a, P1
		mov	cursorsave, a
		inc	auxr1	
		setb	tr0				;enable timer
		ret		

;
; clear timer0 interrupt
; restore color under cursor
; reset t0cnt
;
cursor_off:	clr	tr0				;stop timer

;		mov	a, cursorpos+1
;		call	phex
;		mov	a, cursorpos
;		call	phex
		
		mov	dp1l, cursorpos
		mov	dp1h, cursorpos+1
		inc	auxr1
		mov	a, cursorsave
		movx	@dptr, a
		inc	auxr1
		mov	TH0, #128	
		mov	t0cnt, #1
		ret
					
;
; converts accu	into two digits in R0, R1 (high, low)
;	
hex2dez:	mov	b, #10
		div	ab
		add	a, #'0'
		mov	r0, a
		mov	a, b
		add	a, #'0'
		mov	r1, a
		ret

;
; compute dp1 cursor screen address
; dp1l/h = cursorx * 2 + cursory * WIDTH * 2 + 0x8000
;
comp_dptr:
		mov	a, cursorx
		rl	a
		mov	r7, a

		mov	a, cursory
		mov	b, #WIDTH * 2
		mul	ab
				
		add	a, r7
		mov	dp1l, a
		mov	a, b
		addc	a, #80h
		mov	dp1h, a
		ret

		$INCLUDE (io.a51)
		
;===============================================	
; decode scancode
;===============================================
keydecode:	;mov	a, keyrxval
		;call	phex

		mov	a, #EXTENDED			;extended?
		cjne	a, keyrxval, keybreak
		setb	keyrxextended			;set extended flag
		ret		

keybreak:	mov	a, #BREAK			;break?
		cjne	a, keyrxval, keyshift
		setb	keyrxbreak
		ret

keyshift:	mov	a, #CLSHIFT			;left-shift?
		cjne	a, keyrxval, keyshift1
		sjmp	keyshift2
keyshift1:	mov	a, #CRSHIFT			;right shift?
		cjne	a, keyrxval, keyStrg
keyshift2:	mov	c, keyrxbreak
		cpl	c
		mov	keyrxshift, c
		sjmp	keyCheckBrk1

keyStrg:	mov	a, #CLSTRG
		cjne	a, keyrxval, keyCheckBrk
		mov	c, keyrxbreak
		cpl	c
		mov	keyrxstrg, c
		sjmp	keyCheckBrk1		

keyCheckBrk:	jnb	keyrxbreak, keynormal		;break active?
		mov	a, #ALTGR			;ALT-GR?
		cjne	a, keyrxval, keyCheckBrk1
		clr	keyrxaltgr			;clear ALT-GR
keyCheckBrk1:	clr	keyrxbreak
		clr	keyrxextended
		ret
	
keynormal:	push	ar0
		jnb	keyrxshift, keyMakeExt
		call	keygetshift
		sjmp	keyExitOK
	
keyMakeExt:	jnb	keyrxextended, keyAltGr
		clr	keyrxextended			;clear extended
		mov	r0, #13
keyMakeExt2:	call	keygetextind
		cjne	a, keyrxval, keyMakeExt1	;found?
		call	keygetext
		cjne	a, #ALTGR, keyMakeExt3		;ALTGR-pressed?
		setb	keyrxaltgr			;set ALTGR-flag
		sjmp	keyExit
keyMakeExt3:	sjmp	keyExitOK	
keyMakeExt1:	djnz	r0, keyMakeExt2
		sjmp	keyExit
			
keyAltGr:	jnb	keyrxaltgr, keyMake		;AltGR pressed?
		mov	r0, #8
keyAltGr2:	call	keygetaltgrind
		cjne	a, keyrxval, keyAltGr1		;found?
		call	keygetaltgr
		sjmp	keyExitOK	
keyAltGr1:	djnz	r0, keyAltGr2
		sjmp	keyExit

keyMake:	call	keygetnoshift
		jnb	keyrxstrg, keyExitOK
		clr	c
		subb	a, #96	

keyExitOK:	mov	keyrxval, a
		setb	keyavail
		
;		mov	p2, #High(08000h + 24*160 + 77*2)
;		mov	r0, #Low(08000h + 24*160 + 77*2);
;		movx	@r0, a
				
keyExit:	pop	ar0
		ret


keygetnoshift:	mov	a, keyrxval
		inc	a
		movc	a, @a+pc
		ret
CHARTABLE_NOSHIFT:
;		 	 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F 
		db	  0,  F9,   0,  F5,  F3,  F1,  F2, F12,   0, F10,  F8,  F6,  F4,TABU, '^',   0	; 00
		db     	  0,   0,   0,   0,   0, 'q', '1',   0,   0,   0, 'y', 's', 'a', 'w', '2',   0	; 10
		db	  0, 'c', 'x', 'd', 'e', '4', '3',   0,   0, ' ', 'v', 'f', 't', 'r', '5',   0	; 20 
		db	  0, 'n', 'b', 'h', 'g', 'z', '6',   0,   0,   0, 'm', 'j', 'u', '7', '8',   0	; 30 
		db	  0, ',', 'k', 'i', 'o', '0', '9',   0,   0, '.', '-', 'l', 246, 'p', 223,   0	; 40 	5c = \, 223 = ß
		db	  0,   0, 228,  'X',252, 180,   0,   0,   0,   0,C_CR, '+',   0, '#',   0,   0	; 50 
		db	  0, '<',   0,   0,   0,   0,C_DEL,  0,   0, '1',   0, '4', '7',   0,   0,   0	; 60 
		db	 '0', '.', '2', '5', '6', '8',ESC,   0, F11, '+', '3', '-', '*', '9', CLS,   0	; 70 
		db	  0,   0,   0,  F7,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

keygetshift:	mov	a, keyrxval
		inc	a
		movc	a, @a+pc
		ret
CHARTABLE_SHIFT:
;		 	 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F 
		db	  0,   9,   0,   5,   3,   1,   2,  12,   0,  10,   8,   6,   4,TABU,0B0h,   0	; 00
		db        0,   0,   0,   0,   0, 'Q', '!',   0,   0,   0, 'Y', 'S', 'A', 'W', '"',   0	; 10
		db	  0, 'C', 'X', 'D', 'E', '$', 167,   0,   0, ' ', 'V', 'F', 'T', 'R', '%',   0	; 20 	167=§
		db	  0, 'N', 'B', 'H', 'G', 'Z', '&',   0,   0,   0, 'M', 'J', 'U', '/', '(',   0	; 30 
		db	  0, ';', 'K', 'I', 'O', '=', ')',   0,   0, ':', '_', 'L', 214, 'P', '?',   0	; 40 
		db	  0,   0, 196,   0, 220, '`',   0,   0,   0,   0,  LF, '*',   0,027h,   0,   0	; 50 
		db	  0, '>',   0,   0,   0,   0,CDCH,   0,   0, '1',   0, CCLF, '7',   0,  0,   0	; 60 
		db	'0', '.', CCDN, '5', CCRT, CCUP,  0,   0,  11, '+', '3', '-', '*', '9', 0,   0  ; 70 
		db	  0,   0,   0,   7,   0,   0,   0,   0,   0,   0,   0,   0,   0,  0,    0,   0	; 80


keygetaltgrind:	mov	a, r0
		movc	a, @a+pc
		ret
ALTGR_TABLE_IND:
		db	015h	; q = @
		db	061h	; <> = |
		db	05Bh	; *+ = ~
		db	04Eh	; ?ß = \
		db	03Eh	; 8( = [
		db	046h	; 9) = ]
		db	03Dh	; 7/ = {
		db	045h	; 0= = }


keygetaltgr:	mov	a, r0
		movc	a, @a+pc
		ret
ALTGR_TABLE:	db	'@'
		db	'|'
		db	'~'
		db	05Ch
		db	'['
		db	']'
		db	'{'
		db	'}'
		

keygetextind:	mov	a, r0
		movc	a, @a+pc
		ret
EXT_TABLE_IND:	db	ALTGR
		db	04Ah	; /
		db	05Ah	; ENTER
		db	069h	; END
		db	06Bh	; LEFT
		db	06Ch	; HOME
		db	070h	; INS
		db	071h	; DEL
		db	072h	; DOWN
		db	074h	; RIGHT
		db	075h	; Up
		db	07Ah	; PAGE DOWN
		db	07Dh	; PAGE UP
		
keygetext:	mov	a, r0
		movc	a, @a+pc
		ret
EXT_TABLE:	db	ALTGR
		db	'/'	; NumPad division symbol
		db	C_CR	; ENTER
		db	CCBT	; cursor bottom with SuperFlag
		db	19	; cursor left	CTRL-S
		db	CCHM	; cursor home with SuperFLag
		db	22	; insert	CTRL-V
		db	7	; delete	CTRL-G
		db	24	; cursor down	CTRL-X
		db	4	; cursor right	CTRL-D
		db	5	; cursor up	CTRL-E
		db	3	; pagedown CTRL-C
		db	18	; pageup CTRL-R
;	
;
;
getbaud:	mov	a, r0
		inc	a
		movc	a, @a+pc
		ret
		db	0ffh	;115200
		db	0f4h	;9600
		db	0fah	;19200
		db	0fdh	;38400
		db	0feh	;57600

getbdtxt:	movc	a, @a+pc
		ret		
		db	"1152"
		db	"  96"
		db	" 192"
		db	" 384"
		db	" 576"
			
;
;
prtstatus:
;		mov	dptr, #08000h + 20 * WIDTH * 2
;		mov	r0, #0
;prtstatus6:	mov	a, r0
;		movx	@dptr, a
;		inc	dptr
;		mov	a, #070h
;		movx	@dptr, a
;		inc	dptr
;		inc	r0
;		cjne	r0, #0, prtstatus6		

		mov	dptr, #08000h + 24 * WIDTH * 2
		mov	r0, #1
prtstatus1:	acall	getstatus			;get status line
		movx	@dptr, a
		inc	dptr
		mov	a, #06h				;color turquoise
		movx	@dptr, a
		inc	dptr		
		inc	r0
		cjne	r0, #81, prtstatus1
		
		mov	dptr, #08000h + 24 * WIDTH * 2 + 8 * 2
		mov	a, baudidx
		rl	a				;mul2
		rl	a				;mul4
		inc	a
		mov	r0, a
		mov	r1, #0
prtbaud:	call	getbdtxt
		movx	@dptr, a
		inc	dptr
		inc	dptr
		inc	r0
		mov	a, r0
		inc	r1
		cjne	r1, #4, prtbaud
		
		mov	a, #251				;Haken
		jnb	newlinemode, prtstatus2
		mov	dptr, #08000h + 24 * WIDTH * 2 + 26 * 2
		movx	@dptr, a
prtstatus2:	jnb	insert	, prtstatus3
		mov	dptr, #08000h + 24 * WIDTH * 2 + 38 * 2
		movx	@dptr, a
prtstatus3:	jnb	origin, prtstatus4
		mov	dptr, #08000h + 24 * WIDTH * 2 + 50 * 2
		movx	@dptr, a
prtstatus4:	jb	nowrap, prtstatus5
		mov	dptr, #08000h + 24 * WIDTH * 2 + 60 * 2
		movx	@dptr, a
prtstatus5:	ret
		
getstatus:	mov	a, r0
		movc	a, @a + pc
		ret	
;			"0         1         2         3         4         5         6         7         "
;			"01234567890123456789012345678901234567890123456789012345678901234567890123456789		
status:		db	"| Baud:     00 | Newline: - | Insert: - | Origin: - | Wrap: - |     VT102      |"
		END
