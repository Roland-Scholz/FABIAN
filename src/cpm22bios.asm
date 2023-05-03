	include "mc68681.asm"

DEBUG		equ	0
	
FATBUF		equ	$FC00		;address of 512-byte buffer for FAT
DATBUF		equ	FATBUF + $200	;adddres of 512-byte buffer for data

;
;	skeletal cbios for first level of CP/M 2.0 alteration
;
msize		equ	62		;cp/m version memory size in kilobytes
;
;	"bias" is address offset from 3400h for memory systems
;	than 16k (referred to as"b" throughout the text)
;									25616 (TP)	24592 (TP)
bias		equ	(msize-20)*1024	;		$B000 (64k)	$A800 (62k)		
ccp		equ	3400h+bias	;base of ccp	$E400		$DC00		$D800 (61k) 
bdos		equ	ccp+806h	;base of bdos	$EC06		$E406				
bios		equ	ccp+1600h	;base of bios	$FA00		$F200		$EE00
cdisk		equ	0004h		;current disk number 0=a,... l5=p
iobyte		equ	0003h		;intel i/o byte
;
	IFDEF STANDALONE
	org	bios		;origin of this program
	ENDIF
		
nsects		equ	$1600/128	;warm start sector count (44 sectors for BDOS + CCP)
;
;		jump vector for individual subroutines
;	
		jp	boot	;cold start
WBOOT:		jp	bwboot	;warm start
CONST:		jp	bconst	;console status
CONIN:		jp	bconin	;console character in
CONOUT:		jp	bconout	;console character out
LIST:		jp	blist	;list character out
PUNCH:		jp	bpunch	;punch character out
READER:		jp	breader	;reader character out
HOME:		jp	bhome	;lde head to home position
SELDSK:		jp	bseldsk	;select disk
SETTRK:		jp	bsettrk	;set track number
SETSEC:		jp	bsetsec	;set sector number
SETDMA:		jp	bsetdma	;set dma address
READ:		jp	bread	;read disk
WRITE:		jp	bwrite	;write disk
LISTST:		jp	blistst	;return list status
SECTRN:		jp	bsectran	;sector translate
;
;	dw	track
;	fixed data tables for four-drive standard
;	ibm-compatible 8" disks
;
;		disk Parameter header for disk 00
dpbase:		dw	0000h, 0000h
		dw	0000h, 0000h
		dw	dirbf, dpblk
		dw	chk00, all00
;		disk parameter header for disk 01
		dw	0000h, 0000h
		dw	0000h, 0000h
		dw	dirbf, dpblk
		dw	chk01, all01
;		disk parameter header for disk 02
		dw	0000h, 0000h
		dw	0000h, 0000h
		dw	dirbf, dpblk
		dw	chk02, all02
;		disk parameter header for disk 03
		dw	0000h, 0000h
		dw	0000h, 0000h
		dw	dirbf, dpblk
		dw	chk03, all03
;
;		sector translate vector
;trans:		db	 1,  7, 13, 19	;sectors  1,  2,  3,  4
;		db	25,  5, 11, 17	;sectors  5,  6,  7,  6
;		db	23,  3,  9, 15	;sectors  9, 10, 11, 12
;		db	21,  2,  8, 14	;sectors 13, 14, 15, 16
;		db	20, 26,  6, 12	;sectors 17, 18, 19, 20
;		db	18, 24,  4, 10	;sectors 21, 22, 23, 24
;		db	16, 22		;sectors 25, 26
;
dpblk:		;disk parameter block, common to all disks
		dw	26		;sectors per track
		db	3		;block shift factor
		db	7		;block mask
		db	0		;null mask
		dw	242		;disk size-1
		dw	63		;directory max
		db	192		;alloc 0
		db	0		;alloc 1
		dw	16		;check size
		dw	2		;track offset
;
;	end of fixed tables
;
;	individual subroutines to perform each function
boot:	;simplest case is to just perform parameter initialization
;		ld	sp, 80h		;use space below buffer for stack
		
		call	sdInit
			
;	jp	gocpm		;initialize and go to cp/m
;
bwboot:	;simplest case is to read the disk until all sectors loaded
		ld	sp, 80h		;use space below buffer for stack

;		ld	HL, 0100h
;		ld	DE, 0101h
;		ld	BC, 0F0FFh
;		ld	(HL), 0
;		ldir
	
		ld	HL, copyright
		call	printstr
		
		call	fopen
;		call	dirPrintEntry
		
		xor	a		;zero in the accum
		ld	(iobyte), a	;clear the iobyte
		ld	(cdisk), a	;select disk zero
		
;		ld	a, 3
;opendisks:
;		ld	(diskno), a
;		push	AF
;		call	cmdOpenDisk
;		pop	AF
;		dec	a
;		jp	P, opendisks
		
		ld	c, 0		;select disk 0	
		call	bseldsk
		call	bhome		;go to track 00
;		jp	gocpm
;	
		
		ld	b, nsects	;b counts * of sectors to load
		ld	c, 0		;c has the current track number
		ld	d, 0		;d has the next sector to read
					;note that we begin by reading track 0, sector 2 since sector 1
					;contains the cold start loader, which is skipped in a warm start
		ld	HL, ccp		;base of cp/m (initial load point)
load1:					;load	one more sector
		push	BC		;save sector count, current track
		push	DE		;save next sector to read
		push	HL		;save dma address
		ld	c, d		;get sector address to register C
		call	bsetsec		;set sector address from register C
		pop	BC		;recall dma address to b, C
		push	BC		;replace on stack for later recall
		call	bsetdma		;set dma address from b, C
;	
					;drive set to 0, track set, sector set, dma address set
		call	bread
;		cp	00h		;any errors?
		or	a
		jp	NZ, bwboot	;retry the entire boot if an error occurs
;	
					;no error, lde to next sector
		pop	HL		;recall dma address
		ld	DE, 128		;dma=dma+128
		add	HL, DE		;new dma address is in h, l
		pop	DE		;recall sector address
		pop	BC		;recall number of sectors remaining, and current trk
		dec	b		;sectors=sectors-1
		jp	Z, gocpm	;transfer to cp/m if all have been loaded
;	
					;more sectors remain to load, check for track change
		inc	d
		ld	a, d		;sector=26?, if so, change tracks
		
		push	HL
		ld	HL, (dpbase + $a) ;load Hl with dpblk of drive A:
		cp	(HL)
		pop	HL
		jp	C, load1	;carry generated if sector<26
;	
					;end of	current track,	go to next track
		ld	d, 0		;begin with first sector of next track
		inc	c		;track=track+1
;	
;		save	register state, and change tracks
;		push	BC
;		push	DE
;		push	HL
		call	bsettrk		;track address set from register c
;		pop	HL
;		pop	DE
;		pop	BC
		jp	load1		;for another sector
;
;		end of	load operation, set parameters and go to cp/m
gocpm:	
		ld	a, 0c3h		;c3 is a jp instruction
		ld	(0), a		;for jp to wboot
		ld	HL, WBOOT	;wboot entry point
		ld	(1), HL		;set address field for jp at 0
;	
		ld	(5), a		;for jp to bdos
		ld	HL, bdos	;bdos entry point
		ld	(6), HL		;address field of Jump at 5 to bdos
;	
		ld	BC, 80h		;default dma address is 80h
		call	bsetdma
;	
;		ei			;enable the interrupt system
		ld	a, (cdisk)	;get current disk number
		ld	c, a		;send to the ccp
		jp	ccp		;go to cp/m for further processing
;
;
;	simple i/o handlers (must be filled in by user)
;	in each case, the entry point is provided, with space reserved
;	to insert your own code
;
bconst:		;console status, return 0ffh if character ready, 00h if not
;		ds     10h		;space for status subroutine
;		in     00h		
	
		in	a, (STATA)
		and	a, 1
		ret	Z		; zero, not ready
		ld	a, 0ffh		; $ff, ready
		ret
;
bconin:					;console character into register a
;		ds	10h		;space for input routine
		jp	chrin
		

		
;		in      01h
;		and	7fh		;strip parity bit
;		ret
;
bconout:				;console character output from register c
		jp	chrout		
;		ld	a, c		;get to accumulator
;		ds	10h		;space for output routine
;		out     01h
;		ret
;	
blist:		;list character from register c
		ld	a, c	  	;character to register a
		ret		  	;null subroutine
;	
blistst:		;return list status (0 if not ready, 1 if ready)
		xor	a	 	;0 is always ok to return
		ret
;	
bpunch:		;punch	character from	register C
		ld	a, c		;character to register a
		ret			;null subroutine
;
;
breader:	;reader character into register a from reader device
		ld    a, 1ah		;enter end of file for now (replace later)
		ani    7fh		;remember to strip parity bit
		ret
;	
;	
;		i/o drivers for the disk follow
;		for now, we will simply store the parameters away for use
;		in the read and write	subroutines
;	
bhome:		;lde to the track 00	position of current drive
;		translate this call into a settrk call with Parameter 00
		ld    c, 0		;select track 0
		call   bsettrk
		ret			;we will lde to 00 on first read/write
;
bseldsk:	;select disk given by register c
		ld	HL, 0000h	;error return code
		ld	a, c
		ld	(diskno), a
		cp	4		;must be between 0 and 3
		ret	NC			;no carry if 4, 5,...
;		disk number is in the proper range
;		ds	10		;space for disk select
;		compute proper disk Parameter header address
;		ld	a, (diskno)
		ld	l, a		;l=disk number 0, 1, 2, 3
;		ld	h, 0		;high order zero
		add	HL, HL		;*2
		add	HL, HL		;*4
		add	HL, HL		;*8
		add	HL, HL		;*16 (size of each header)
		ld	DE, dpbase
		add	HL, DE		;hl=,dpbase (diskno*16)
		ret
;
bsettrk:	;set track given by register c
		ld	a, c
		ld	(track), a
	
;		push	BC
;		ld	c, 'T'
;		call	chrout
;		pop	BC
;		ld	a, c
;		call	printhex
;		pop	BC
;		push	BC
;		ld	a, b
;		call	printhex
;		ld	a, c
;		call	printhex
		ret
;
bsetsec:	;set sector given by register c
		ld	a, c
		ld	(sector), a
	
;		push	BC
;		ld	c, 'S'
;		call	chrout
;		pop	BC
;		ld	a, c
;		jp	printhex
		ret
;
;
bsectran:
	;translate the sector given by bc using the
	;translate table given by de
		ld	l, c
		ld	h, b
		ret
	
;		xchg			;hl=.trans
;		dad	b		;hl=.trans (sector)
;		ld	l, m		;l=trans (sector)
;		ld	h, 0		;hl=trans (sector)
;		ret			;with value in hl
;
bsetdma:	;set	dma address given by registers b and c
;		ld	l, c		;low order address
;		ld	h, b		;high order address
		ld	(dmaad), BC	;save the address
		ret

;
bread:		
		;perform read operation (usually this is similar to write
		;so we will allow space to set up read command, then use
		;common code in write)
	if DEBUG = 1
		ld	a, 0	
		ld	(debug), a
		
		ld	c, 'R'
		call	chroutdebug
		call	spacedebug
	endif
		call	seeksectrk

		
		ld	hl, (dmaad)
		ld	bc, 80h
		call	fread

	if DEBUG = 1
		call	newlinedebug
	endif
		xor	a
	if DEBUG = 1
		ld	(debug), a
	endif
		ret
;		jp	waitio			;to perform the actual i/o


;
;
;
seeksectrk:	ld	de, fseeklen		;clear fseeklen
		call	clear32
				
		xor	a			;seeklen = track * 26 + sector
		ld	bc, (track)
		ld	e, 26		
		ld	b, a
		ld	d, a
		call	mul16
		ld	bc, (sector)
		ld	b, 0
		add	hl, bc
		ld	(fseeklen + 1), hl
		
		xor	a			;shift right one position
		ld	b, 3
		ld	hl, fseeklen + 2
seeksectrk1:	rr	(hl)
		dec	hl
		djnz	seeksectrk1

	if DEBUG = 1
		ld	a, (debug)
		or	a
		jr	Z, seeksectrk2
		
		ld	c, 'T'
		call	chroutdebug
		ld	c, 'S'
		call	chroutdebug
		ld	a, (track)
		ld	h, a
		ld	a, (sector)
		ld	l, a
		call	printadrdebug
			
		ld	hl, (fseeklen + 2)
		call	printadrdebug
		ld	hl, (fseeklen)
		call	printadrdebug
	endif
	
seeksectrk2:	ld	hl, fseeklen
		call	fseek			;call fseek

	if DEBUG = 1		
		ld	hl, (datsec)
		call	printadrdebug
		ld	hl, (datptr)
		call	printadrdebug
		ld	hl, (dmaad)
		call	printadrdebug
	endif
		ret
;
;
bwrite:	
	if DEBUG = 1
		ld	a, 0
		ld	(debug), a
		
		ld	c, 'W'
		call	chroutdebug
		call	spacedebug
	endif
	
		call	seeksectrk		;compute seeklen
			
		ld	hl, (dmaad)		;copy data to sector buffer
		ld	de, (datptr)
		ld	bc, 80h
		ldir
		
		ld	de, datsec
		call	sdWriteDat

	if DEBUG = 1
		call	newlinedebug
	endif
	
		xor	a
	if DEBUG = 1
		ld	(debug), a
	endif
		ret
;
;writesec2:	ld	a, 1
;		ret


;
;waitio:	;enter	here from read	and write to perform the actual i/o
;		operation. return a 00h in register a if the operation completes
;		properly, and 0lh if an error occurs during the read or write
;	
;		in this case, we have saved the disk number in 'diskno' (0, 1)
;				the track number in 'track' (0-76)
;				the sector number in 'sector' (1-26)
;				the dma address in 'dmaad' (0-65535)
;		ds	256		;space reserved for i/o drivers
;		ld	a, 1		;error condition
;		ret			;replaced when filled-in
;	
;		the remainder of the cbios is reserved uninitialized
;		data area, and does not need to be a Part of the
;		system	memory image (the space must be available,
;		however, between"begdat" and"enddat").
;
diskno:		ds	1		;disk number 0-15
track:		ds	1		;two bytes for expansion
sector:		ds	1		;two bytes for expansion
dmaad:		ds	2		;direct memory address
debug:		ds	1		;1 = enable debug
;
;		scratch ram area for bdos use
begdat		equ	$	 	;beginning of data area
dirbf:		ds	128	 	;scratch directory area
all00:		ds	31	 	;allocation vector 0
all01:		ds	31	 	;allocation vector 1
all02:		ds	31	 	;allocation vector 2
all03:		ds	31	 	;allocation vector 3
chk00:		ds	16		;check vector 0
chk01:		ds	16		;check vector 1
chk02:		ds	16	 	;check vector 2
chk03:		ds	16	 	;check vector 3
;	
enddat		equ	$	 	;end of data area
datsiz		equ	$-begdat;	;size of data area
	

		include	"fat16.asm"
		include "common.asm"
		
		
;--------------------------------------------------------------
;--------------------------------------------------------------
;		E N D
;--------------------------------------------------------------
;--------------------------------------------------------------
				
		
		IFDEF NOEXCLUDE
cmdOpenDisk:
		ld	a, (diskno)
		call	bin2deca
		ld	HL, opendiskno
		call	dec2disp
		ld	HL, (opendiskno)
		ld	(opendiskno1), HL
		
		ld	HL, opendisk
		jp	sendCommand


cmdPutSector:
		ld	a, (diskno)		; write diskno
		call	bin2deca		; in paintext
		ld	HL, putsdisk		; to getsdisk
		call	dec2disp
		ld	a, (track)		; write track
		call	bin2deca
		ld	HL, putstrack
		call	dec2disp
		ld	a, (sector)		; write sector
		call	bin2deca
		ld	HL, putssector
		call	dec2disp
		
		ld	HL, (dmaad)		;128 from (dmadat)
		ld	DE, secdata		;to secdata
		ld	BC, 128			;set length length
		ld	(seclen), BC		
		ldir

		ld	DE, seclen
		ld	HL, putsdata-2
		call	codeBase64
		ld	HL, 00a0dh
		ld	(putsdata-2), HL
		
		ld	HL, putsector
		jp	sendCommand
		
		
cmdGetSector:
		ld	a, (diskno)		; write diskno
		call	bin2deca		; in paintext
		ld	HL, getsdisk		; to getsdisk
		call	dec2disp
		ld	a, (track)		; write track
		call	bin2deca
		ld	HL, getstrack
		call	dec2disp
		ld	a, (sector)		; write sector
		call	bin2deca
		ld	HL, getssector
		call	dec2disp

		ld	HL, getsector		; send the sector-command
		call	sendCommand
		
;		ld	a, h
;		call	printhex
;		ld	a, l
;		call	printhex
;		ld	a, d
;		call	printhex
;		ld	a, e
;		call	printhex
;		ld	c, 32
;		call	chrout

		ex	DE, HL			;DE = OK + 5
		dec	HL			;HL - 4
		dec	HL
		dec	HL
		dec	HL
		xor	a			
		ld	(HL), a
		ld	a, 172			;decode from
		dec	HL
		ld	(HL), a		
		ld	DE, seclen		;into seclen
		jp	decodeBase64
		


sendCommand:
		push	HL
		push	HL
		
		ld	HL, atstatus		;status of connection
		call	writeesp
		ld	a, (line + 21)
		cp	'3'
		jp	Z, sendCommand1		;if 3 send command

sendCommand3:		
		ld	HL, connect
		call	writeesp
		jr	NC, sendCommand1
		
enterIP:	
		ld	HL, iptext
		call	printstr
		call	getline
		ld	HL, line
		ld	DE, connectip
		call	copystr
		
		dec	DE
		ld	HL, porttext
		call	copystr
		ld	(DE), a
;		jp	error
		jr	sendCommand3
		
sendCommand1:		
		pop	HL
		call	strlen			;length in DE
;		ld	a, d
;		call	printhex
;		ld	a, e
;		call	printhex
		call	bin2dec			;e in hex to a in dec
		ld	HL, cipsendlenl		;prite dec to display
		call	dec2disp
		ld	HL, 03030h		;"00" into
		ld	(cipsendlenh), HL
		ld	a, d
		or	a
		jr	Z, sendCommand2
		ld	HL, 03230h		;02
		ld	(cipsend+11), HL
		ld	HL, 03638h		;86
		ld	(cipsend+13), HL
		
sendCommand2:
		ld	HL, cipsend
		call	writeesp
		jr	NC, sendCommand4
		pop	HL
		xor	a
		call	printhex
		jr	sendCommand
		
		
;		call	prtline
sendCommand4:
		call	espin
		call	espin


		pop	HL
		push	HL
		call	writeesp
		pop	HL
		ret
		
;		ret	NC
;		ld	a, 1
;		call	printhex
;		jr	sendCommand

		
error:		
		ld	b, 0
e1:		djnz	e1
		ld	a, 080h			;OP7 = HIGH
		out	(OPRES), a	
		jp	0

connect:	DB	"AT+CIPSTART=\"TCP\",\""
connectip:	DB	"192.168.178.22"
		DB	"\","
connectport:	DB	"4434",13,10,0,0,0

cipsend:	DB	"AT+CIPSEND="
cipsendlenh:	DB	"00"
cipsendlenl:	DB	"xx",13,10,0

opendisk:	DB	"GET /disk?func=open&disk="
opendiskno:	DB	"00"
		DB	"&filename=disk"
opendiskno1:	DB	"00.dsk HTTP/1.0",13,10,13,10,0
		
getsector:	DB	"GET /sectordata?disk="
getsdisk:	DB	"00"
		DB	"&track="
getstrack:	DB	"00"
		DB	"&sector="
getssector:	DB	"00"
		DB	" HTTP/1.1",13,10
		DB	"Host: roland.z80",13,10,13,10,0
		
putsector:	DB	"PUT /sectordata?disk="
putsdisk:	DB	"00"
		DB	"&track="
putstrack:	DB	"00"
		DB	"&sector="
putssector:	DB	"00"
		DB	" HTTP/1.0",13,10
		DB	"Host: roland.z80",13,10
		DB	"Accept: text/plain",13,10
		DB	"Content-Length: 172",13,10,13,10
putsdata:	DS	172
		DB	0
atstatus:	DB	"AT+CIPSTATUS",13,10,0
iptext:		DB	13,10,"IP:",0
porttext:	DB	"\",4434",13,10,0


;--------------------------------------------------------------
; DE: Pointer to input-area
; HL: Base64 coded output input
;
; area: 2-byte          len
;       xxx-byte        data
;--------------------------------------------------------------
codeBase64:
		push    HL              ; IY = ptr to out-length
		pop     IY
		inc     HL
		inc     HL
		push    HL              ; save ptr to out-data
	
		ld      a, (DE)
		neg
		ld      c, a
		inc     DE
		ld      a, (DE)
		neg
		ld      b, a
		inc     DE              ; BC = in-len
		push    BC
		pop     IX
		add     IX, DE
	
		ld      c, 0

code_loop1:
		ex      DE, HL          ;switch to input-pointer
		ld      a, c
		inc     c
		and     3
	
		jr      NZ, code1
	
		ld      a, (HL)
		rra
		rra
		and     00111111b
		call    codeB64
		jr      code_loop

code1:
		dec     a
		jr      NZ, code2
		ld      a, (HL)
		rla
		rla
		rla
		rla
		and     00110000b
		ld      b, a
		inc     HL
		ld      a, (HL)
		rra
		rra
		rra
		rra
		and     %00001111
		or      b
		call    codeB64
		jr      code_loop
	
code2:
		dec     a
		jr      NZ, code3
		ld      a, (HL)
		rla
		rla
		and     00111100b
		ld      b, a
		inc     HL
		ld      a, (HL)
		rlca
		rlca
		and     00000011b
		or      b
		call    codeB64
	
code_loop:
		ex      DE, HL                  ;switch to output-pointer
		ld      (HL), a                 ;store base64 symbol
		inc     HL
		jr      code_loop1
	
code3:
		ld      a, (HL)
		inc     HL
		and     00111111b
		call    codeB64
	
		ex      DE, HL                  ;switch HL to output-pointer
		ld      (HL), a                 ;store base64 symbol
		inc     HL
	
		push    DE
		push    HL
		ex      DE, HL
		push    IX
		pop     DE
		sbc     HL, DE
		ld      b, l
		pop     HL
		pop     DE
	
		jp      M, code_loop1
		push    HL
code3a:
		jr      Z, code3b
		dec     HL
		ld      (HL), '='
		djnz    code3a
code3b:
		pop     HL
		pop     DE
		sbc     HL, DE
		ld      (IY), l
		ld      (IY + 1), h
		ret
	
	
	
;--------------------------------------------------------------
; DE: Pointer to output-area
; HL: Base64 coded input
;
; area: 2-byte          len
;       xxx-byte        data
;--------------------------------------------------------------
decodeBase64:
		ld      c, (HL)                 ; load lo, hi length
		inc     HL
		ld      b, (HL)
		inc     HL
		push    BC
		exx
		pop     BC                      ; put length in BC'
		exx
	
		ld      c, 0
	
		push    DE                      ; save out-ptr on stack
		inc     DE                      ; skip-out-length
		inc     DE
		push    DE                      ; save it, too
		
decode_loop1:
		call    decodeB64               ; load in-byte in (HL) and decode into a
		ld      b, a
		ld      a, c
		inc     c
		jr      C, decode_loop2         ; if decodeB64 has set Carry, input was '='
	
		inc     HL                      ; increment input-pointer
		ex      DE, HL                  ; switch to output-pointer
		and     3
	
		jr      NZ, decode1
	
		ld      a, b
		rla
		rla
		and     11111100b
		ld      (HL), a
		jr      decode_loop

decode1:
		dec     a
		jr      NZ, decode2
		ld      a, b
		rra
		rra
		rra
		rra
		and     00000011b
		or      (HL)
		ld      (HL), a
		inc     HL
		ld      a, b
		rla
		rla
		rla
		rla
		and     11110000b
		ld      (HL), a
		jr      decode_loop

decode2:
		dec     a
		jr      NZ, decode3
		ld      a, b
		rra
		rra
		and     00001111b
		or      (HL)
		ld      (HL), a
		inc     HL
		ld      a, b
		rrca
		rrca
		and     11000000b
		ld      (HL), a
		jr      decode_loop

decode3:
		ld      a, b
		or      (HL)
		ld      (HL), a
		inc     HL

decode_loop:
		ex      DE, HL                  ; switch to input-pointer
	
		exx
		dec     BC
		ld      a, b
		or      c
		exx
		jr      NZ, decode_loop1

decode_loop2:
		ex      DE, HL                  ; switch to output-pointer
		pop     DE                      ; get start of output
	
		or      a                       ; reset carry!
		sbc     HL, DE                  ; len = end - start
		pop     DE                      ; load address of output-len
		ex      DE, HL                  ; switch to output-len
		ld      (HL), E                 ; save len
		inc     HL
		ld      (HL), D
		ret



decodeB64:
		ld      a, (HL)
		
		cp      '='
		jr      NZ, decodeB64e
		xor     a
		scf
		ret
decodeB64e:
		cp      '+'
		jr      NZ, decodeB64a
		ld      a, 62
		ret
decodeB64a:
		cp      '/'
		jr      NZ, decodeB64b
		ld      a, 63
		ret
decodeB64b:
		cp      ':'
		jr      NC, decodeB64c          ; not 0-9?
		add     a, 4                    ; '0' = 48 -> 52
		ret
decodeB64c:
		cp      'Z'+1
		jr      NC, decodeB64d          ; not A-Z?
		sub     'A'                     ; 'A' = 65 -> 0
		ret
decodeB64d:                             	; then a-z
		sub     71
		ret



codeB64:
		cp      26
		jr      NC, codeB64a
		add     a, 'A'                     ; < 0-25
		ret
codeB64a:
		cp      52
		jr      NC, codeB64b
		add     a, 71
		ret
codeB64b:
		cp      62
		jr      NC, codeB64c
		sub     4
		ret
codeB64c:
		cp      62
		jr      NZ, codeB64d
		ld      a, '+'
		ret
codeB64d:
		ld      a, '/'
		ret
;
;
;
dec2disp:	push    af
		rrca
		rrca
		rrca
		rrca
		call    dec2nibble
		inc	HL
		pop     af
		
dec2nibble:   	or      0xf0
		daa
		add     a,0xa0
		adc     a,0x40
		ld	(HL), a
		ret


bin2deca:	ld	e, a
bin2dec:	ld	b, 8
		xor	a
bin2dec1:	rlc	e
		adc	a, a
		daa
		djnz	bin2dec1
		ret
		
		

strlen:		ld	DE, 0
strlen1:
		ld	a, (HL)
		or	a
		ret	z
		inc	DE
		inc	HL
		jr	strlen1
		
		
		
getesp:
		ld	HL, line
getesp2:
		push	HL
		pop	DE		; DE = HL
getesp1:
		call	espin
		ld	(HL), a
		inc	HL
		cp	10
		jr	NZ, getesp1	; read until EOL
		
		ex	DE, HL
		ld	a, (HL)
		inc	HL
		ld	b, (HL)
		inc	HL
		inc	HL
		inc	HL
		inc	HL
		ld	c, (HL)
		ex	DE, HL
		cp	'O'		; "OK"?
		jr	Z, getespK
		cp	'E'		; "ERR"?
		jr	Z, getespR
		ld	a, c
		cp	'F'		; "FAIL"?
		jr	NZ, getesp2
		ex	DE, HL
		inc	HL
		ld	a, (HL)
		ex	DE, HL
		cp	'A'
		jr	Z, getesperr
		jr	getesp2

getespK:	ld	a, b
		cp	'K'
		jr	NZ, getesp2
		xor	a
		ld	(HL), a
		ret
		
getespR:	ld	a, b
		cp	'R'
		jr	NZ, getesp2
getesperr:	xor	a
		ld	(HL), a
		scf
		ret
		
getespE:	ld	a, b
		cp	'E'
		jr	NZ, getesp2
		jr	getesperr
writeesp:
		ld	a, (HL)
		or	a
		jr	Z, getesp
		call	espout
;		call	chrout
		inc	HL
		jr	writeesp
	
putesp:
		ld	HL, line
putesp1:
		ld	a, (HL)
		cp	10
		jr	NZ, putesp2
		ld	a, 13
		call	espout
		ld	a, 10
		jp	espout
putesp2:	call	espout
		inc	HL
		jr	putesp1
		
		
		
getline:	ld	HL, line-1
getline1:
		inc	HL
		call	chrin
		ld	(HL), a
		call	chrouta
;		ld	a, c
		cp	a, 10
		jr	NZ, getline1
		xor	a
		ld	(HL), a
		ret

prtline:
		ld	HL, line
prtline1:
		ld	a, (HL)
		inc	HL
		or	a
		ret	Z
		call	chrouta
		jr	prtline1
		
;--------------------------------------------------------------
; get a character in A from rs232 (2)
; 
;--------------------------------------------------------------
espin:
		in	a, (STATB)
		and	a, 1
		jr	Z, espin
		in	a, (RECB)
		ret
		
espstat:	in	a, (STATB)
		and	a, 1
		ret
		
;--------------------------------------------------------------
; output a character in A over rs232 (2)
; 
;--------------------------------------------------------------
espout:
		push	AF
espout1:	in	a, (STATB)
		and	a, 4
		jr	Z, espout1
		pop	AF
		out	(TRANSB), a
		ret
		
line:		DS	300
		
seclen:		DS	2
secdata:	DS	128		
		ENDIF
		
copyright:	DB	27, "[m", 13
		DB	"Z80 "
		DB	27, "[35mFa", 27, "[m"
		DB	"bulous "
		DB	27, "[32mBi", 27, "[m"
		DB	"nary "
		DB	27, "[36mAn", 27, "[m"
		DB	"ihilator",13 
		DB	"CP/M 2.2 Copyright 1979 (c) by Digital Research"
		DB	0



		
;	end