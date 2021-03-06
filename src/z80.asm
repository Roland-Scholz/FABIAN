		;FNAME "z80.bin"

CR:		equ	0dh


VARS		equ	$FFF0
sum:		equ	0
addr:		equ	1
echo:		equ	3

MODEA		equ	0
STATA		equ	1
CLOCKA		equ	1
COMMA		equ	2
RECA		equ	3
TRANSA		equ	3
IPCHANGE	equ	4
AUXCTRL		equ	4
ISR		equ	5
IMR		equ	5
CNTMSB		equ	6
CNTLSB		equ	7
MODEB		equ	8
STATB		equ	9
CLOCKB		equ	9
COMMB		equ	10
RECB		equ	11
TRANSB		equ	11
IVR		equ	12
INPORT		equ	13
OPCTRL		equ	13
STRTCNT		equ	14
OPSET		equ	14
STOPCNT		equ	15
OPRES		equ	15

		ORG     0000h
		
		ld	HL, 0			;copy ROM to RAM from
		ld	DE, 0			;to
		ld	BC, 1800h		;length, 6KB
		ldir
		
		ld	HL, 1A00h		;copy ROM to RAM from $1A00
		ld	DE, 0FA00h		;to $FA00 (CP/M Bios)
		ld	BC, 600h		;length, 6 pages
		ldir
		
		ld	(VARS + addr), BC	;set addr to zero
		
		ld	SP, VARS
				
		ld	IX, VARS
		ld	(IX + echo), 1		;echo on
	
		ld	a, $4A			;RX+TX off and
		out	(COMMA),a		;RESET ERROR
		out	(COMMB),a
	
		ld	a, $30			;RESET TRANS
		out	(COMMA),a	
		out	(COMMB),a	
		
		ld	a, $20			;RESET RECV
		out	(COMMA),a	
		out	(COMMB),a	
		
		ld	a, $10			;RESET to MODE REG1
		out	(COMMA),a	
		out	(COMMB),a	
		
		ld	a, $E0			;BRG set 2 and timer = X1/CLK
		out	(AUXCTRL),a
	
		ld	a, 0			;load timer with
		out	(CNTMSB),a		;	
		ld	a, 2			;57600 BAUD
		out	(CNTLSB),a	
	
;		in	a, (COMMA)		;Switch to test baudrates
		
		ld	a, $66			;115200 BAUD
		out	(CLOCKA),a	
;		ld	a, $66			;
		out	(CLOCKB),a	

			
		ld	a, $13			;no RTS handshake + 8bits no parity
		out	(MODEA),a			
		out	(MODEB),a	
		
		ld	a, $07			;no CTS handshake + 1 stopbit
		out	(MODEA),a	
		out	(MODEB),a	
		
		ld	a, 0			;OP2-7 output
		out	(OPCTRL),a	
		
;		ld	a, %11111111		;out = low; inverting!
;		out	(OPSET),a
	
;		ld	a, %10101010
;		out	(OPRES),a
		
		ld	a, 0			;IRQS AUS
		out	(IMR),a
		
		ld	a, 5			;RX+TX AN
		out	(COMMA),a
		out	(COMMB),a
		
		
		ld	a, 080h			;OP7 = LOW, activate RAM
		out	(OPSET), a	
			
		ld	c, 32			;output space
		ld	b, 0
		call	conout
wait:		in	a, (STATA)
		inc	b
		and	4
		jr	Z, wait

		ld	a, b
		cp	10
		jr	C, printmenu
		in	a, (COMMA)		;Switch to test baudrates

printmenu:
		ld      HL, menutext
		call	printstr

printprompt:		
		call	newline
		ld	c, '>'
		call	printaddr
	
enterkey:	
		ld	c, 0
		ld	HL, menukey
		ld	b, (HL)
		inc	HL
		call	getupper
enterkey2: 
		cp	(HL)
		jr	Z, enterkey1
		inc	HL
		inc	c
		inc	c
		djnz	enterkey2
		jr	enterkey
enterkey1:	
		ld	b, 0
		ld	HL, menutab
		add	HL, BC
		ld	BC, printprompt
		push	BC
		ld	e, (HL)
		inc	HL
		ld	d, (HL)
		ex	DE, HL
		jp	(HL)


;--------------------------------------------------------------
; open a diskfile (and close if already assigned)
;--------------------------------------------------------------
opendisk:	
		call	getDiskno
		ret	C

		ld	c, a
		call	conout
		
		sub	a, '0'
		ld	b, a
		ld	a, 'O'
		call	serout
		ld	a, b
		call	serout
		call	serout
		call	serout
		
		call	serintime
		ret	C
		cp	'A'
		ret	NZ

		call	getfilename
		ret
		
;--------------------------------------------------------------
; close a diskfile
;--------------------------------------------------------------
closedisk:	
		call	getDiskno
		ret	C
		
		ld	c, a
		call	conout

		sub	a, '0'
		ld	b, a
		ld	a, 'C'
		call	serout
		ld	a, b
		call	serout
		call	serout
		call	serout
		
		call	serintime
		ret
		

;--------------------------------------------------------------
; enter disk number (0-9)
;--------------------------------------------------------------
getDiskno:
		ld	HL, disktext
		call	printstr
		call	conin
		cp	'0'
		ret	C
		cp	'9'+1
		ccf
		ret

;--------------------------------------------------------------
; enter text (filename) delimited by CR and send to SER:
;--------------------------------------------------------------
getfilename:	ld	HL, filetext
		call	printstr
getfilename1:
		call	conin
		call	serout
		ld	c, a
		call	conout
		cp	13
		jr	NZ, getfilename1
		ret
		
;--------------------------------------------------------------
; jump to CP/M
;--------------------------------------------------------------
cpm:
		jp	0FA00h
;--------------------------------------------------------------
; jump to printmenu
;--------------------------------------------------------------
questionmark:
		pop	BC
		jp	printmenu

;--------------------------------------------------------------
; exit from monitor
;--------------------------------------------------------------
;exit:		pop	BC
;		ld	SP, (VARS + oldstack)
;		ret


;--------------------------------------------------------------
; jump to (addr)
;--------------------------------------------------------------
goto:		ld	HL, (VARS + addr)
		jp	(HL)

		
;--------------------------------------------------------------
; Disassemble 22 lines starting from (addr)
;--------------------------------------------------------------
disass:
		ld	B, 22
		ld	DE, (VARS + addr)
		call	newline
disass1:
		push	BC
		call	DISASM
		call	newline
		pop	BC
		djnz	disass1
		
		ld	(VARS + addr), DE	;save new address
		ret

;--------------------------------------------------------------
; 
;--------------------------------------------------------------
fillmem:
		ld	HL, filltext
		call	printstr
		
		call	gethexbyte		;get from-addr
		ld	h, a
		call	gethexbyte
		ld	l, a
		push	HL
		push	HL
		
		ld	HL, lentext
		call	printstr
		call	gethexbyte		;get length
		ld	b, a
		call	gethexbyte
		ld	c, a
		
		ld	a, b			; if BC = 0
		or	a, c
		ret	Z			; return	
		dec	BC
		
		ld	HL, withtext
		call	printstr
		call	gethexbyte
		
		pop	DE			; DE = HL + 1
		inc	DE
		
		pop	HL
		ld	(HL), a 
		
		ld	a, b
		or	a, c
		ret	Z
		
		LDIR
		
		ret

;--------------------------------------------------------------
; 
;--------------------------------------------------------------
transfer:	
		ld	HL, transtext
		call	printstr
		
		call	gethexbyte		;get from-addr
		ld	h, a
		call	gethexbyte
		ld	l, a
		push	HL
		
		ld	HL, lentext
		call	printstr
		call	gethexbyte		;get length
		ld	b, a
		call	gethexbyte
		ld	c, a

		ld	HL, totext
		call	printstr
		call	gethexbyte		;get dest-addr
		ld	d, a
		call	gethexbyte
		ld	e, a

		pop	HL
		
		LDIR
		
		ret
		
;--------------------------------------------------------------
; change a byte in (addr)
;--------------------------------------------------------------
changebyte:
		ld	HL, (VARS + addr)
		ld	a, (HL)
		call	printhex
		ld	c, ':'
		call	conout
		call	gethexbyte
		ld	(HL), a
		ret


;--------------------------------------------------------------
; read new address from conin
;--------------------------------------------------------------
newaddress:
		ld	HL, addrtext
		call	printstr
		call	gethexbyte
		ld	(VARS + addr + 1), a
		call	gethexbyte
		ld	(VARS + addr), a
		ret


;--------------------------------------------------------------
; dump 256 bytes starting from (HL)
;--------------------------------------------------------------
dumpmem:
		call	newline
		ld	d, 16
		ld	HL, (VARS + addr)
	
dumpline:
		ld	c, ':'
		call	printaddr
		call	space
		push	HL
		
		ld	b, 16
dumpmem1:
		ld	a, (HL)
		inc	HL
		call	printhex
		call	space
		ld	a, b
		cp	9
		jr	NZ, dumpmem3
		call	space
dumpmem3:	
		djnz	dumpmem1
		
		
		ld	c, '|'
		call	conout
		ld	b, 16
		pop	HL
	
dumpmem5:
		ld	a, (HL)
		inc	HL
		cp	32
		jr	C, dumpmem6
		cp	126
		jr	C, dumpmem4
dumpmem6:
		ld	a, '.'
dumpmem4:
		ld	c, a
		call	conout
		djnz	dumpmem5
		
		ld	c, '|'
		call	conout
		
		call	newline
		ld	(VARS + addr), hl
		dec	d
		jr	NZ, dumpline
		ret
	
	
;--------------------------------------------------------------
; print zero-terminated string via conout and character in C
; uses A, E
;--------------------------------------------------------------
printaddr:
		ld	a, (VARS + addr + 1)
		call	printhex
		ld	a, (VARS + addr)
		call	printhex
		jp	conout


;--------------------------------------------------------------
; download an Intel-Hex file
; uses A, B, HL, E
;--------------------------------------------------------------
download:	xor	a
		ld	(VARS + echo), a	;echo off
		ld	(VARS + sum), a		;sum = 0
		ld	HL, downtext		;print "download..."
		call	printstr
download2:	
		call	conin			;wait for ':'
		cp	a, ':'
		jr	NZ, download2
		
		call	gethexbyte		;# of bytes to read
		ld	b, a			;in b
		call	gethexbyte		;address high
		ld	h, a
		call	gethexbyte		;address low 
		ld	l, a
		call	gethexbyte		;record-type
		or	a
		jr	NZ, downend
	
download1:
		call	gethexbyte		;get byte to store
		
		ld	(HL), a			;store
		inc	HL			;increment address
		djnz	download1		;loop
		
		call	gethexbyte
		ld	a, (VARS + sum)
		or	a
		jr	NZ, downerror
	
		jr	download2
	
downend:
		call	gethexbyte
		ld	HL, downendtext
downend1:
		call	printstr
		ld	(IX + echo), 1	;echo on
		ret
	
downerror:
		ld	HL, errortext
		jr	downend1


;--------------------------------------------------------------
; gethexbyte
; returns 00-FF in A
; uses E
;--------------------------------------------------------------
gethexbyte:
		push	DE
		call	getnibble
		rlca
		rlca
		rlca
		rlca
		ld	e, a
		call	getnibble
		or	e
		ld	e, a
		add	a, (IX + sum)
		ld	(VARS + sum), a
		ld	a, e
		pop	DE
		ret

	
;--------------------------------------------------------------
; calls conin
; returns 0-F in A
;--------------------------------------------------------------
getnibble:
		call	conin
		push	AF
		ld	a, (VARS + echo)
		or	a
		jr	Z, getnibble2
		pop	AF
		push	AF
		push	BC
		ld	c, a
		call	conout
		pop	BC
getnibble2:
		pop	AF	
		sub	'0'
		cp	10		; < 10 ?
		ret	C		; yes, return
		and	11011111b	; make uppercase
		sub	7
		ret
	
	
;--------------------------------------------------------------
; print text in (HL) uses
; A
;--------------------------------------------------------------
printstr:
		push	BC
printstr2:
		ld	a, (HL)
		inc	HL
		or	a
		jr	Z, printstr1
		ld	c, a
		call	conout
		jr	printstr2
printstr1:
		pop	BC
		ret
	
;--------------------------------------------------------------
; get a character in A from rs232 (1)
; 
;--------------------------------------------------------------
chrin:
		in	a, (STATA)
		and	a, 1
		jr	Z, chrin
		in	a, (RECA)
		ret
		
;--------------------------------------------------------------
; output a character in A over rs232 (1)
; 
;--------------------------------------------------------------
chrout:
		push	AF
chrout1:	in	a, (STATA)
		and	a, 4
		jr	Z, chrout1
		ld	a, c
		out	(TRANSA), a
		pop	AF
		ret
		
;--------------------------------------------------------------
; get a character in A from rs232 (2)
; 
;--------------------------------------------------------------
serintime:
		ld	BC, 0
serintime2:	in	a, (STATB)
		and	a, 1
		jr	NZ, serintime1		;byte received?
		djnz	b, serintime2		;no, decrement b and try again
		dec	c
		jr	NZ, serintime2
		ccf				;set carry ('and' clears carry)
		ret
serintime1:	in	a, (RECB)
		ret
		
;--------------------------------------------------------------
; get a character in A from rs232 (2)
; 
;--------------------------------------------------------------
serin:
		in	a, (STATB)
		and	a, 1
		jr	Z, serin
		in	a, (RECB)
		ret

;--------------------------------------------------------------
; output a character in A over rs232 (2)
; 
;--------------------------------------------------------------
serout:
		push	AF
serout1:	in	a, (STATB)
		and	a, 4
		jr	Z, serout1
		pop	AF
		out	(TRANSB), a
		ret	
		
menukey:
		DB	12
		DB	"?CDEFGLMNOPT"

menutab:	DW	questionmark
		DW	changebyte
		DW	download
		DW	closedisk
		DW	fillmem
		DW	goto
		DW	disass
		DW	dumpmem
		DW	newaddress
		DW	opendisk
		DW	cpm
		DW	transfer
;		DW	exit
	
menutext:
		DB	32, 27, "[m", CR
		DB	"*************************************************", CR
		DB	"***  Z80 Mini-Monitor  (c) '22  by ", 27, "[1mR. Scholz", 27,"[m  ***", CR
		DB	"*************************************************", CR
		DB	"? - This help", CR
		DB	"C - Change byte", CR
		DB	"D - Download Intel Hex file", CR
		DB	"E - Close Disk", CR
		DB	"F - Fill memory", CR
		DB	"G - Goto address", CR
		DB	"L - Disassemble", CR
		DB	"M - Memory dump", CR
		DB	"N - New address", CR
		DB	"O - Open Disk", CR
		DB	"P - CP/M", CR
		DB	"T - Transfer memory", CR
;		DB	"X - eXit", CR
		DB	0

downtext:	DB	"downloading...", CR, 0
downendtext:	DB	"finished.", CR, 0
addrtext:	DB	"address:", 0
errortext:	DB	"error!", 0
transtext:	DB	"transfer from:", 0
lentext:	DB	" len:", 0
totext:		DB	" to:", 0
filltext:	DB	"fill from:", 0
withtext:	DB	" with:", 0
disktext:	DB	"enter disk number (0-9):",0
filetext:	DB	CR, "filename:",0

;--------------------------------------------------------------
; prints byte in A in hexadecimal format
;--------------------------------------------------------------
printhex:
		push    AF
		push    AF
		rra
		rra
		rra
		rra
		call    printnib
		pop     AF
		call    printnib
		pop     AF
		ret
printnib:
		and     0fh
		cp      0ah
		jr      C, printnib1
		add     a, 07h
printnib1:
		add     a, '0'
print:
		push    BC
		ld      c, a
		call    conout
		pop     BC
		ret

newline:
		push    BC
		ld      c, CR
		call    conout
		pop     BC
		ret

space:
		push    BC
		ld      c, ' '
		call    conout
		pop     BC
		ret

getupper:
		call	conin
		cp	'a'
		ret	C
		sub	32
		ret

conout:		equ	chrout
conin:		equ	chrin


	include "disz80.asm"
