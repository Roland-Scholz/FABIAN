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

LOCAT		EQU	02000h
		
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
START:		mov	A, #0AAh
		mov	dptr, #0FF00h
		movx	@dptr, A
		

		ret
;
;
;		;setb	SYCS			;deselect
		clr	SYRS			;address
		clr	SYPHI2			;enable
		;clr	SYRW			;write

		mov	dptr, #SYDATA
		mov	R0, #0
		;clr	SYCS			; enable
		
setregs:	
;		call	PHEX
;		call	SPACE
		
		mov	DATABUS, R0		; send address
		clr	SYRS			; address register
		setb	SYPHI2			; clock high
		clr	SYPHI2			; clock low
		
		mov	A, R0
		movc	A, @A+DPTR
		mov	DATABUS, A		; send data
		setb	SYRS			; register data
		setb	SYPHI2			; clock high
		clr	SYPHI2			; clock low
		
		inc	R0
		cjne	R0, #15, setregs
		
		;setb	SYCS
		ret
			
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
SYDATA:		DB	99		;R0 Horizontal Total - 1
		DB	80		;R1 Horizontal Displayed	
		DB	82		;R2 Horizontal Sync Position
		DB	0Ch		;R3 VSYNC & HSYNC width
		DB	27		;R4 Vertical total - 1			;27	32
		DB	2		;R5 Vertical Adjust
		DB	25		;R6 Vertical Displayed			;25	30
		DB	25			;R7 Vertical Sync Position		;25	32
		DB	00h		;R8 Mode Control
		DB	15		;R9 Scan Lines - 1 (character lines)
		DB	0		;R10 Cursor Start
		DB	0		;R11 Cursor End
		DB	000h		;R12 Display Start High
		DB	002h		;R13 Display Start Low
		DB	0		;R14 Cursor Pos High
		DB	0		;R15 Cursor Pos Low
		DB	0		;R16 Light Pen High
		DB	0		;R17 Light Pen Low
		DB	0		;R18 Update Address Reg High
		DB	0		;R19 Update Address Reg Low
					;R31 Dummy Register
				 
		
;LOOP:		call	CIN
;		call	COUT
;		
		ajmp	LOOP
		
		
;		CLR	SCK_52
;		CLR	RES_52
;		CALL	TIME35MS
;		SETB	RES_52
;		MOV	R5,#7
;START2:		CALL	TIME35MS
;		DJNZ	R5,START2
;		MOV	AUXR1,#0
	
;		ACALL	ENABLE
;		ACALL	SIGNATURE
;		JNC	MENU
;		JC	MENU
;		MOV	DPTR,#MSGSIGFAIL
;		CALL	PSTR
;		CALL	CIN
;		AJMP	START
	
MENU:		MOV	DPTR,#MSGMENU
		CALL	PSTR
MENULOOP:	CALL	CIN
MENUC:		CJNE	A,#"c",MENUD
		ACALL	CLEAR
		AJMP	MENU	
MENUD:		CJNE	A,#"d",MENUP
		ACALL	DNLD
		AJMP	MENU	
MENUP:		CJNE	A,#"p",MENUR
		ACALL	PROGRAM
		AJMP	MENU
MENUR:		CJNE	A,#"r",MENUV
		ACALL	READFLASH
		AJMP	MENU
MENUV:		CJNE	A,#"v",MENUX
		ACALL	VERIFY
		AJMP	MENU
MENUX:		CJNE	A,#"x",MENULOOP
		RET
		
CLEAR:		MOV	R0,#SPICMD
		MOV	@R0,#0ACh
		INC	R0
		MOV	@R0,#080h
		ACALL	COMMAND
		ACALL	TIME5MS
		AJMP	TIME5MS
dnld:	
		mov	dptr, #dnlds1		 
		call	pcstr_h		   ;"begin sending file <ESC> to abort"
		acall	dnld_init

	  ;look for begining of line marker ':'
dnld1:		call	cin
		cjne	a, #27, dnld2	;Test for escape
		ajmp	dnld_esc

dnld2:		cjne	a, #':', dnld2b
		sjmp	dnld2d
dnld2b:	  ;check to see if it's a hex digit, error if it is
		call	asc2hex
		jc	dnld1
		mov	r1, #6
		acall	dnld_inc
		sjmp	dnld1

dnld_now: ;entry point for main menu detecting ":" character
		mov	a, #'^'
		call	cout
		acall	dnld_init

dnld2d:		mov	r1, #0
		acall	dnld_inc

	  ;begin taking in the line of data
dnld3:		mov	a, #'.'
		call	cout
		mov	r4, #0		;r4 will count up checksum
		acall	dnld_ghex
		mov	r0, a		;R0 = # of data bytes
;	mov	a, #'.'
;	acall	cout
		acall	dnld_ghex
		CJNE	A,#030h,dnld3_a
dnld3_a:	JNC	dnld3_b
		ADD	A,#0D0h	
dnld3_b:	mov	dp0h, a		;High byte of load address
		acall	dnld_ghex
		mov	dp0l, a		;Low byte of load address
		acall	dnld_ghex	;Record type
		cjne	a, #1, dnld4	;End record?
		sjmp	dnld_end
dnld4:		jnz	dnld_unknown	;is it a unknown record type???
dnld5:		mov	a, r0
		jz	dnld_get_cksum
		acall	dnld_ghex	;Get data byte
		mov	r2, a
		mov	r1, #1
		acall	dnld_inc	;count total data bytes received
		mov	a, r2
		lcall	smart_wr	;c=1 if an error writing
		clr	a
		addc	a, #2
		mov	r1, a
;     2 = bytes written
;     3 = bytes unable to write
		acall	dnld_inc
		inc	dptr
		djnz	r0, dnld5
dnld_get_cksum:
		acall	dnld_ghex	;get checksum
		mov	a, r4
		jz	dnld1		;should always add to zero
dnld_sumerr:
		mov	r1, #4
		acall	dnld_inc	;all we can do it count # of cksum errors
		sjmp	dnld1

dnld_unknown:	;handle unknown line type
		mov	a, r0
		jz	dnld_get_cksum	;skip data if size is zero
dnld_ukn2:
		acall	dnld_ghex	;consume all of unknown data
		djnz	r0, dnld_ukn2
		sjmp	dnld_get_cksum

dnld_end:   ;handles the proper end-of-download marker
		mov	a, r0
		jz	dnld_end_3	;should usually be zero
dnld_end_2:
		acall	dnld_ghex	;consume all of useless data
		djnz	r0, dnld_ukn2
dnld_end_3:
		acall	dnld_ghex	;get the last checksum
		mov	a, r4
		jnz	dnld_sumerr
		acall	dnld_dly
		mov	dptr, #dnlds3
		call	pcstr_h		   ;"download went ok..."
	;consume any cr or lf character that may have been
	;on the end of the last line
		jb	ri, dnld_end_4
		ajmp	dnld_sum
dnld_end_4:
		call	cin
		sjmp	dnld_sum



dnld_esc:   ;handle esc received in the download stream
		acall	dnld_dly
		mov	dptr, #dnlds2	 
		call	pcstr_h		   ;"download aborted."
		sjmp	dnld_sum

dnld_dly:   ;a short delay since most terminal emulation programs
	    ;won't be ready to receive anything immediately after
	    ;they've transmitted a file... even on a fast Pentium(tm)
	    ;machine with 16550 uarts!
		mov	R0,#0
dnlddly2:	mov	R1,#0
		djnz	r1, $		;roughly 128k cycles, appox 0.1 sec
		djnz	r0, dnlddly2
		ret

dnld_inc:     ;increment parameter specified by R1
	      ;note, values in Acc and R1 are destroyed
		mov	a, r1
		anl	a, #00000111b	;just in case
		rl	a
		add	a, #dnld_parm
		mov	r1, a		;now r1 points to lsb
		inc	@r1
		mov	a, @r1
		jnz	dnldin2
		inc	r1
		inc	@r1
dnldin2:	ret

dnld_gp:     ;get parameter, and inc to next one (@r1)
	     ;carry clear if parameter is zero.
	     ;16 bit value returned in dptr
		setb	c
		mov	dp0l, @r1
		inc	r1
		mov	dp0h, @r1
		inc	r1
		mov	a, dp0l
		jnz	dnldgp2
		mov	a, dph
		jnz	dnldgp2
		clr	c
dnldgp2:	ret

;a spacial version of ghex just for the download.  Does not
;look for carriage return or backspace.	 Handles ESC key by
;poping the return address (I know, nasty, but it saves many
;bytes of code in this 4k ROM) and then jumps to the esc
;key handling.	This ghex doesn't echo characters, and if it
;sees ':', it pops the return and jumps to an error handler
;for ':' in the middle of a line.  Non-hex digits also jump
;to error handlers, depending on which digit.
	  
dnld_ghex:
dnldgh1:	call	cin
		call	upper
		cjne	a, #27, dnldgh3
dnldgh2:	pop	acc
		pop	acc
		sjmp	dnld_esc
dnldgh3:	cjne	a, #':', dnldgh5
dnldgh4:	mov	r1, #5		;handle unexpected beginning of line
		acall	dnld_inc
		pop	acc
		pop	acc
		ajmp	dnld3		;and now we're on a new line!
dnldgh5:	call	asc2hex
		jnc	dnldgh6
		mov	r1, #7
		acall	dnld_inc
		sjmp	dnldgh1
dnldgh6:	mov	r2, a		;keep first digit in r2
dnldgh7:	call	cin
		call	upper
		cjne	a, #27, dnldgh8
		sjmp	dnldgh2
dnldgh8:	cjne	a, #':', dnldgh9
		sjmp	dnldgh4
dnldgh9:	call	asc2hex
		jnc	dnldghA
		mov	r1, #7
		acall	dnld_inc
		sjmp	dnldgh7
dnldghA:	xch	a, r2
		swap	a
		orl	a, r2
		mov	r2, a
		add	a, r4		;add into checksum
		mov	r4, a
		mov	a, r2		;return value in acc
		ret

;dnlds4 =  "Summary:"
;dnlds5 =  " lines received"
;dnlds6a = " bytes received"
;dnlds6b = " bytes written"

dnld_sum:    ;print out download summary
		mov	a, r6
		push	acc
		mov	a, r7
		push	acc
		mov	dptr, #dnlds4
		call	pcstr_h
		mov	r1, #dnld_parm
		mov	r6, #LOW dnlds5
		mov	r7, #HIGH dnlds5
		acall	dnld_i0
		mov	r6, #LOW dnlds6a
		mov	r7, #HIGH dnlds6a
		acall	dnld_i0
		mov	r6, #LOW dnlds6b
		mov	r7, #HIGH dnlds6b
		acall	dnld_i0

dnld_err:    ;now print out error summary
		mov	r2, #5
dnlder2:	acall	dnld_gp
		jc	dnlder3		;any errors?
		djnz	r2, dnlder2
	 ;no errors, so we print the nice message
		mov	dptr, #dnlds13
		call	pcstr_h
		sjmp	dlnd_sum_done

dnlder3:  ;there were errors, so now we print 'em
		mov	dptr, #dnlds7
		call	pcstr_h
	  ;but let's not be nasty... only print if necessary
		mov	r1, #(dnld_parm+6)
		mov	r6, #LOW dnlds8
		mov	r7, #HIGH dnlds8
		acall	dnld_item
		mov	r6, #LOW dnlds9
		mov	r7, #HIGH dnlds9
		acall	dnld_item
		mov	r6, #LOW dnlds10
		mov	r7, #HIGH dnlds10
		acall	dnld_item
		mov	r6, #LOW dnlds11
		mov	r7, #HIGH dnlds11
		acall	dnld_item
		mov	r6, #LOW dnlds12
		mov	r7, #HIGH dnlds12
		acall	dnld_item
dlnd_sum_done:
		pop	acc
		mov	r7, a
		pop	acc
		mov	r6, a
		jmp	newline

dnld_item:
		acall	dnld_gp		;error conditions
		jnc	dnld_i3
dnld_i2:call	space
		lcall	pint16u
		acall	r6r7todptr
		call	pcstr_h
dnld_i3:	ret

dnld_i0:	acall	dnld_gp		;non-error conditions
		sjmp	dnld_i2


dnld_init:
	;init all dnld parms to zero.
		mov	r0, #dnld_parm
dnld0:		mov	@r0, #0
		inc	r0
		cjne	r0, #dnld_parm + 16, dnld0
		ret

space:		mov	a, #' '
		JMP	COUT
	
r6r7todptr:
		mov	dpl, r6
		mov	dph, r7
		ret
	
	
PROGRAM:	MOV	DPTR,#0D000h
				
PROGRAM64:	MOV	R0,#SPICMD
		MOV	@R0,#050h		; Byte Write Page
		INC	R0
		MOV	@R0,#0
		INC 	R0
		MOV	@R0,#0

PROGRAM64B:	CLR	A
		MOVC	A,@A+DPTR
		MOV	R0,#SPIDATA
		MOV	@R0,A
		ACALL	COMMAND
		INC	DPTR
		
		MOV	R6,#63
PROGRAM64A:	CLR	A
		MOVC	A,@A+DPTR
;		ACALL	SPIBYTE
		INC	DPTR
		DJNZ	R6,PROGRAM64A

		MOV	@R0,#SPIADRLO
		MOV	A,@R0
		ADD	A,#64
		MOV	@R0,A
		DEC	R0
		MOV	A,@R0
		ADDC	A,#0
		MOV	@R0,A
		ACALL	TIME5MS
		CJNE	A,#030h,PROGRAM64B
PROGRAM64EX:	RET

VERIFY:		MOV	R2,#1
		AJMP	READFLASH1
		
READFLASH:	MOV	R2,#0
READFLASH1:	MOV	DPTR,#0D000h
				
READ64:		MOV	R0,#SPICMD
		MOV	@R0,#030h		; Byte Read Page
		INC	R0
		MOV	@R0,#0
		INC 	R0
		MOV	@R0,#0
READ64B:	ACALL	COMMAND
		ACALL	READVERI
		JC	READ64ERR
		INC	DPTR
		
		MOV	R6,#63
READ64A:	;ACALL	SPIBYTE
		ACALL	READVERI
		JC	READ64ERR
		INC	DPTR
		DJNZ	R6,READ64A

		MOV	@R0,#SPIADRLO
		MOV	A,@R0
		ADD	A,#64
		MOV	@R0,A
		DEC	R0
		MOV	A,@R0
		ADDC	A,#0
		MOV	@R0,A
		CJNE	A,#030h,READ64B
READ64EX:	RET

READ64ERR:	PUSH	ACC
		PUSH	DP0L
		PUSH	DP0H
		MOV	DPTR,#MSGVERIFAIL
		CALL	PSTR
		POP	DP0H
		POP	DP0L
		CALL	PHEX16
		MOV	A,#"m"
		CALL	COUT
		POP	ACC
		CALL	PHEX
		MOV	A,#"c"
		CALL	COUT
		MOV	A,TEMP
		CALL	PHEX
		CALL	NEWLINE
		CALL	CIN
		POP	ACC
		POP	ACC
		AJMP	START
		
READVERI:	CJNE	R2,#0,READVERI1
		MOVX	@DPTR,A
		RET
		
READVERI1:	MOV	TEMP,A
		CLR	A
		MOVC	A,@A+DPTR
		CJNE	A,TEMP,READVERI2
		RET
READVERI2:	SETB	C
		RET
		
SIGNATURE:	MOV	R0,#SPICMD
		MOV	@R0,#028h
		INC	R0
		INC	R0
		MOV	@R0,#030h
		ACALL	COMMAND
		CJNE	A,#01Eh,SIGFAIL
		MOV	R0,#SPIADRLO
		MOV	@R0,#031h
		ACALL	COMMAND
		CJNE	A,#073h,SIGFAIL
		CLR	C
		RET
SIGFAIL:	SETB	C
		RET
		
ENABLE:		MOV	R0,#SPICMD
		MOV	@R0,#0ACh
		INC	R0
		MOV	@R0,#053h
		AJMP	COMMAND
				
COMMAND:	MOV	R0,#SPICMD
COMMAND1:	MOV	A,@R0
;		CALL	PHEX
;		ACALL	SPIBYTE
		INC	R0
		CJNE	R0,#0,COMMAND1
;		CALL	NEWLINE
		RET

;SPIBYTE:	MOV	R7,#8
;SPIBYTE1:	RLC	A
;		SETB	SCK_52
;		MOV	MOSI_52,C
;		CLR	SCK_52
;		MOV	C,MISO_52
;		DJNZ	R7,SPIBYTE1
;		RLC	A
;		CALL	PHEX
;		RET	

TIME35MS:	MOV	R6,#0
TIME35MS2:	MOV	R7,#0
TIME35MS1:	DJNZ	R7,TIME35MS1
		DJNZ	R6,TIME35MS1
		RET

TIME5MS:	MOV	R6,#18
		AJMP	TIME35MS2

MSGMENU:	DB	13,10,"AT89S8253 - Prommer Menu",13,10
		DB	"C - Clear Flash",13,10
		DB	"D - Download Intel-Hex file at $D000",13,10
		DB	"P - Program Chip",13,10
		DB	"R - Read Flash",13,10
		DB	"V - Verify Flash",13,10
		DB	"X - Exit"		
		DB	13, 10, 0

MSGSIGFAIL:	DB	"AT89S8253 signature check failure!",13,10,0
MSGVERIFAIL:	DB	"Verify failure at: ",0

dnlds1: 	db	13,13,31,159," ascii",249,150,31,152,132,137
		db	",",149,140,128,160,13,14
dnlds2: 	db	13,31,138,160,"ed",13,14
dnlds3: 	DB	13,31,138,193,"d",13,14
dnlds4: 	DB	"Summary:",14
dnlds5: 	DB	" ",198,"s",145,"d",14
dnlds6a:	DB	" ",139,145,"d",14
dnlds6b:	DB	" ",139," written",14
dnlds7: 	DB	31,155,":",14
dnlds8: 	DB	" ",139," unable",128," write",14
dnlds9: 	DB	32,32,"bad",245,"s",14
dnlds10:	DB	" ",133,159,150,198,14
dnlds11:	DB	" ",133,132,157,14
dnlds12:	DB	" ",133," non",132,157,14
dnlds13:	DB	31,151,155," detected",13,14

TEMP		EQU	127
dnld_parm	EQU	236
SPICMD		EQU	252
SPIADRHI	EQU	253
SPIADRLO	EQU	254
SPIDATA		EQU	255

		END