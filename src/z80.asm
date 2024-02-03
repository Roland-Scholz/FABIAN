		;FNAME "z80.bin"

		include "mc68681.asm"
	
CR:		equ	0dh
LF:		equ	0ah
C_XON		equ	17
C_XOFF		equ	19


VARS		equ	$FFF0			;stack grows downwards from this address
sum:		equ	0
addr:		equ	1
echo:		equ	3			;0 = off, 1 = on
xonxoff		equ	4			;0 = transmit, 1 = stop

;
; must be loaded at 04000h in 27c256 EPROM!
; BIOS at 05200h
;

		ORG     0000h
		
		di				;disable interrupts
		im	1			;interrup mode 1 = jp @ 038h
		
		ld	a, 80h			;OP7 = HIGH, deactivate RAM
		out	(OPRES), a

		ld	HL, 0			;copy ROM to RAM from
		ld	DE, 0			;to
		ld	BC, 1000h		;length, 4KB
		ldir
		
		ld	HL, 01200h		;copy ROM to RAM from $1200
		ld	DE, 0F200h		;to $F200 (CP/M Bios)
		ld	BC, 0e00h		;length, 14 pages
		ldir
		
		ld	(VARS + addr), BC	;set addr to zero
		
		ld	SP, VARS		;load stack-pointer
				
		ld	IX, VARS
		ld	(IX + echo), 1		;echo on
		ld	(IX + xonxoff), 0	;xonxoff off
	
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
		ld	b, 0			;test how long it takes to send
		call	conout
wait:		in	a, (STATA)
		inc	b
		and	4
		jr	Z, wait

		ld	a, b			;if b < 10
		cp	10			;test baudrate is already acrivated
		jr	C, printmenu
		in	a, (COMMA)		;switch to test baudrates

;--------------------------------------------------------------
; print menu
; print prompt
; read upper key
; check if key is found in menukey
; read jmp-address and jump to subroutine
;--------------------------------------------------------------
printmenu:
		ld      HL, menutext
		call	printstr

printprompt:		
		call	newline
		ld	c, '>'
		call	printaddr
	
enterkey:	
		ld	c, 0			;offset in jumptable
		ld	HL, menukey		;number auf keys
		ld	b, (HL)			;in b
		inc	HL
		call	getupper		;read upper key
enterkey2: 
		cp	(HL)			;key found?
		jr	Z, enterkey1		;yes ==>
		inc	HL
		inc	c
		inc	c
		djnz	enterkey2		;decrease b and jump
		jr	enterkey
enterkey1:	
		ld	b, 0			;add offset in BC
		ld	HL, menutab		;to base
		add	HL, BC
		ld	BC, printprompt		;push return-address
		push	BC
		ld	e, (HL)			;load jp address in DE
		inc	HL
		ld	d, (HL)
		ex	DE, HL			;in HL now
		jp	(HL)


vt102:		in	a, (STATA)
		and	a, 1
		jr	Z, vt102a
		in	a, (RECA)
		call	serout
vt102a:
		in	a, (STATB)
		and	a, 1
		jr	Z, vt102
		in	a, (RECB)
		ld	c, a
		call	conout
		jp	vt102

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
		jp	0F200h
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
		cp	CR
		jr	NZ, printstr2
		ld	c, LF
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

;chrin1:
;		in	a, (STATB)
;		and	a, 1
;		jr	Z, chrin
;		in	a, (RECB)
;		ret
		
;--------------------------------------------------------------
; output a character in C over rs232 (1)
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
; output a character in A over rs232 (1)
; 
;--------------------------------------------------------------
serout:
		push	AF

;		in	a, (STATB)
;		and	a, 1
;		jr	Z, serout1
;		in	a, (RECB)
;		cp	C_XOFF
;		jr	NZ, serout1
;		
;serout2:	in	a, (STATB)
;		and	a, 1
;		jr	Z, serout2
;		in	a, (RECB)
;		cp	C_XON
;		jr	NZ, serout2

serout1:	in	a, (STATB)
		and	a, 4
		jr	Z, serout1
		pop	AF
		out	(TRANSB), a
		ret	
		
menukey:
		DB	13
		DB	"?CDEFGLMNOPTV"

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
		DW	vt102
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
		DB	"V - VT102 test", CR
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
		ld      c, LF
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
