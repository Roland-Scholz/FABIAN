		include "mc68681.asm"

adr0038		equ	038h




;PS2DATA		equ	IP2	
;PS2CLK		equ	IP1

CR:		equ	$0d

CCHM		equ	$1C	;move cursor home
CCBT		equ	$1D	;move cursor to bottom
CCLM		equ	$1E	;move cursor to left margin
CCRM		equ	$1F	;move cursor to right margin
	
				;SUPERF equ 0
				
CLS		equ	$01	;clear screen
BACK		equ	$08	;backspace
LF		equ	$0A	;$9B	;end of line (RETURN)
ESC		equ	$1B	;escape key
CCUP		equ	$1C	;cursor up
CCDN		equ	$1D	;cursor down
CCLF		equ	$1E	;cursor left
CCRT		equ	$1F	;cursor right
CSPACE		equ	$20	;space
TABU		equ	09	;tabulator
CILN		equ	$9D	;insert line
CDCH		equ	$FE	;delete character
CICH		equ	$FF	;insert character
	
HELP		equ	$11	;key code for HELP
CNTLF1		equ	$83	;key code for CTRL-F1
CNTLF2		equ	$84	;key code for CTRL-F2
CNTLF3		equ	$93	;key code for CTRL-F3
CNTLF4		equ	$94	;key code for CTRL-F4
CNTL1		equ	$9F	;key code for CTRL-1

;	special key scan-codes
ALTGR		equ	$11	;extended!
ALR		equ	$11
CLSHIFT		equ	$12
CLSTRG		equ	$14
CRSHIFT		equ	$59
CCAPS		equ	$58

FATBUF		equ	$F800
DATBUF		equ	$FA00

		org	$2000

		call	sdInit
		ld	de, sec2
		call	sdReadDat
		ret
		
		ld	de, sec2
		call	sdWriteDat
		ret

sec2:		db	2, 0, 0, 0

		ld	hl, $d800
		ld	de, $8000
		ld	BC, $1600
compare:	ld	a, (de)
		cp	(hl)
		jr	NZ, noequal
		inc	hl
		inc	de
		dec	bc
		ld	a, b
		or	c
		jr	NZ, compare
		ret
		
noequal:	call	printadr
		ex	de, hl
		call	printadr
		ret
		
debug:		db	0

	include "common.asm"
	include	"fat16.asm"
	
	if	NOEXCLUDE
	
		di

		jp	skip
		
		
		ld	a, 0c3h				;ld jump
		ld	(adr0038), a
		
		ld	hl, intproc
		ld	(adr0038 + 1), hl
		im	1				;interrupt mode 1, goto $38
		
		ld	a, $E2				;BRG set 2 and timer = X1/CLK and IP1 change
		out	(AUXCTRL), a
		
		ld	a, $82				;enable IP0-3 change
		out	(IMR), a			;enable RxRDY A interrupt

skip:
		ld	hl, 0
		ld	(rxstat), hl
		ld	(rxrdy), hl
		ld	(rxshift), hl
		ld	(rxaltgr), hl
		ld	(sdsector), hl
		ld	(sdsector + 1), hl	
		
;		ei

;
;
;
		
		
		call	sdInit				;initSd and read FAT data
		
		call	dirPrint
		call	fopen
		ret	NZ

readloop:		
		ld	hl, 0
		ld	(fseeklen + 2), hl
		ld	hl, 1000
		ld	(fseeklen), hl
		ld	hl, fseeklen
		call	fseek		
		
		ld	bc, $80
		ld	hl, $1000
		call	fread
		
;		push	bc
;		push	hl		
;		call	printadr
;		push	bc
;		pop	hl
;		call	printadr
;		ld	a, (fstatus)
;		call	printhex
;		call	newline

		ld	d, b
		ld	e, c

readloop1:	ld	c, (hl)
		call	conout
		inc	hl
		dec	de
		ld	a, d
		or	a, e
		jr	NZ, readloop1
		
		ld	a, (fstatus)
;		call	printhex
		or	a
		ret	NZ
		ret
		jr	readloop
				
;--------------------------------------------------------------
		include	"common.asm"
		include "fat16.asm"
;--------------------------------------------------------------

;--------------------------------------------------------------
;
;
;--------------------------------------------------------------
intproc:	ex	af, af'
		exx
		
intproc1:	in	a, (ISR)
		ld	b, a
		
		and	2				;RxRdy A?
		jr	Z, intIPchange

intReceive:	in	a, (RECA)
		out	(TRANSA),a
		
intIPchange:
		ld	a, b
		and	128
		jr	Z, intprocex
		
		
		in	a, (IPCHANGE)			;IP1 = low?
		and	PS2CLK
		jr	NZ, intprocex			;IP1 = high, no nothing
				
		ld	hl, rxstat			;status 0 (start-bit expected)	
		ld	a, (hl)				;load status
		or	a				;test if zero
		jr	NZ, intIPdata			;status <> 0
		in	a, (IPCHANGE)
		and	PS2DATA				;start-bit 0?
		jr	NZ, intprocex			;no, do nothing
		inc	(hl)				;increment rxstat
	
		jr	intprocex
		
		
intIPdata:	inc	(hl)				;inc rxstat
		inc	hl				;hl = rxval
		cp	9
		jr	NC, intIPstop
		
		in	a, (IPCHANGE)			;PS2DATA = IP0		
		rra					;shift until bit in C
		rr	(hl)				;shift in result
		jr	intprocex

intIPstop:	cp	10
		jr	NZ, intprocex

		xor	a
		ld	(rxstat), a			;set rxstat to 0
		
		call	decodeKey

				
intprocex:	exx
		ex	af, af'
		ei
		ret
	
;
;
;
decodeKey:	ld	a, (hl)				;load scan-code
		cp	$E0				;extended?
		jr	NZ, decodeBreak
		ld	(rxextended), a
		ret

decodeBreak:	cp	$F0				;break-key?
		jr	NZ, decodeShift			;no -> make
		ld	(rxbreak), a			;store Info
		ret

decodeShift:	cp	CLSHIFT				;left-shift?
		jr	Z, decodeShift1
		cp	CRSHIFT
		jr	NZ, decodeStrg			;right-shift
decodeShift1:	ld	a, (rxbreak)
		xor	$f0
		ld	(rxshift), a			;save shift-info
		jr	decodeEnd			;clear break
		
decodeStrg:	cp	CLSTRG
		jr	NZ, decodeChkBrk
		ld	a, (rxbreak)
		xor	$f0
		ld	(rxstrg), a			;save strg-info
		jr	decodeEnd
		
decodeChkBrk:	ld	a, (rxbreak)			;break?
		or	a
		jr	Z, decodeNormal			;no

		ld	a, (hl)				;load scan-code
		cp	ALTGR				;is it ALTGR?
		jr	NZ, decodeEnd			;no
		xor	a				;clear altgr
		ld	(rxaltgr), a
decodeEnd:	xor	a				;clear rxbreak
		ld	(rxbreak), a			
		ld	(rxextended), a	
		ret
	
decodeNormal:	ld	c, (hl)				;load scan-code
		ld	b, 0
		ld	hl, CHARTABLE_NOSHIFT		;load normal table
		ld	a, (rxshift)
		or	a
		jr	Z, decodeMakeExt
		ld	hl, CHARTABLE_SHIFT		;load shift table
		
decodeMakeExt:	ld	a, (rxextended)
		or	a
		jr	Z, decodeAltGr			;no extended

		xor	a
		ld	(rxextended), a			;clear extended
		
		ld	hl, EXT_TABLE_IND
		ld	a, (rxval)
		ld	b, 13
decodeMakeExt1:	cp	(hl)
		jr	Z, decodeMakeExt2
		inc	hl
		djnz	decodeMakeExt1
		ret
decodeMakeExt2: ld	bc, 13
		cp	ALTGR				;ALTGR-key?
		jr	NZ, decodeMake
		ld	(rxaltgr), a			
		ret
		
decodeAltGr:	ld	a, (rxaltgr)			;ALTGR-Presed?
		or	a
		jr	Z, decodeMake			;no
		
		ld	a, (rxval)
		ld	b, 8
		ld	hl, ALTGR_TABLE_IND
decodeAltGr1:	cp 	(hl)
		jr	Z, decodeAltGr2
		inc	hl
		djnz	decodeAltGr1
		ret		
decodeAltGr2:	ld	bc, 8

decodeMake:	add	hl, bc

		ld	b, 0
		ld	a, (rxstrg)
		or	a
		jr	Z, decodeMake1
		ld	b, 96
decodeMake1:	ld	a, (hl)
		sub	a, b
		ld	(rxval), a
		ld	(rxrdy), a

		ret
	
rxstat:		db	0
rxval:		db	0
rxrdy:		db	0
rxbreak:	db	0
rxshift:	db	0
rxstrg:		db	0
rxaltgr:	db	0
rxextended:	db	0

			
CHARTABLE_NOSHIFT:
;		 	 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F 
		db	  0,   9,   0,   5,   3,   1,   2,  12,   0,  10,   8,   6,   4,TABU, '^',   0	; 00
		db     	  0,   0,   0,   0,   0, 'q', '1',   0,   0,   0, 'y', 's', 'a', 'w', '2',   0	; 10
		db	  0, 'c', 'x', 'd', 'e', '4', '3',   0,   0, ' ', 'v', 'f', 't', 'r', '5',   0	; 20 
		db	  0, 'n', 'b', 'h', 'g', 'z', '6',   0,   0,   0, 'm', 'j', 'u', '7', '8',   0	; 30 
		db	  0, ',', 'k', 'i', 'o', '0', '9',   0,   0, '.', '-', 'l', $94, 'p', 223,   0	; 40 	5c = \, 223 = ß
		db	  0,   0, $84,  'X',252, 180,   0,   0,   0,   0, LF, '+',   0, '#',   0,   0	; 50 
		db	  0, '<',   0,   0,   0,   0,BACK,   0,   0, '1',   0, '4', '7',   0,   0,   0	; 60 
		db	 '0', '.', '2', '5', '6', '8',ESC,   0,  11, '+', '3', '-', '*', '9', CLS,   0	; 70 
		db	  0,   0,   0,   7,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0	; 80

CHARTABLE_SHIFT:
;		 	 00   01   02   03   04   05   06   07   08   09   0A   0B   0C   0D   0E   0F 
		db	  0,   9,   0,   5,   3,   1,   2,  12,   0,  10,   8,   6,   4,TABU, $B0,   0	; 00
		db        0,   0,   0,   0,   0, 'Q', '!',   0,   0,   0, 'Y', 'S', 'A', 'W', '"',   0	; 10
		db	  0, 'C', 'X', 'D', 'E', '$', 167,   0,   0, ' ', 'V', 'F', 'T', 'R', '%',   0	; 20 	167=§
		db	  0, 'N', 'B', 'H', 'G', 'Z', '&',   0,   0,   0, 'M', 'J', 'U', '/', '(',   0	; 30 
		db	  0, ';', 'K', 'I', 'O', '=', ')',   0,   0, ':', '_', 'L', $99, 'P', '?',   0	; 40 
		db	  0,   0, $8E,   0, 220, '`',   0,   0,   0,   0,  LF, '*',   0, $27,   0,   0	; 50 
		db	  0, '>',   0,   0,   0,   0,CDCH,   0,   0, '1',   0, CCLF, '7',   0,  0,   0	; 60 
		db	'0', '.', CCDN, '5', CCRT, CCUP,  0,   0,  11, '+', '3', '-', '*', '9', 0,   0  ; 70 
		db	  0,   0,   0,   7,   0,   0,   0,   0,   0,   0,   0,   0,   0,  0,    0,   0	; 80

ALTGR_TABLE_IND:
		db	$15	; q = @
		db	$61	; <> = |
		db	$5B	; *+ = ~
		db	$4E	; ?ß = \
		db	$3E	; 8( = [
		db	$46	; 9) = ]
		db	$3D	; 7/ = {
		db	$45	; 0= = }
		
ALTGR_TABLE:	db	'@'
		db	'|'
		db	'~'
		db	$5C
		db	'['
		db	']'
		db	'{'
		db	'}'
		
EXT_TABLE_IND:	db	ALTGR
		db	$4A	; /
		db	$5A	; ENTER
		db	$69	; END
		db	$6B	; LEFT
		db	$6C	; HOME
		db	$70	; INS
		db	$71	; DEL
		db	$72	; DOWN
		db	$74	; RIGHT
		db	$75	; Up
		db	$7A	; PAGE DOWN
		db	$7D	; PAGE UP
		
EXT_TABLE:	db	ALTGR
		db	'/'	; NumPad division symbol
		db	LF	; ENTER
		db	CCBT	; cursor bottom with SuperFlag
		db	CCLF	; cursor left
		db	CCHM	; cursor home with SuperFLag
		db	CICH	; insert
		db	CDCH	; delete
		db	CCDN	; cursor down
		db	CCRT	; cursor right
		db	CCUP	; cursor up
		db	CCLM	; left margin with SuperFLag
		db	CCRM	; right margin with SuperFLag
;--------------------------------------------------------------
;--------------------------------------------------------------
;--------------------------------------------------------------

conout:		equ	chrout
conin:		equ	chrin

		ENDIF