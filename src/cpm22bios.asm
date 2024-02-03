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
copyright	equ	ccp+8
;
	IFDEF STANDALONE
	org	bios		;origin of this program
	ENDIF
		
nsects		equ	$1600/128	;warm start sector count (44 sectors for BDOS + CCP)
;
;		jump vector for individual subroutines
;	
		jp	boot		;cold start
WBOOT:		jp	bwboot		;warm start
CONST:		jp	bconst		;console status
CONIN:		jp	bconin		;console character in
CONOUT:		jp	bconout		;console character out
LIST:		jp	blist		;list character out
PUNCH:		jp	bpunch		;punch character out
READER:		jp	breader		;reader character in
HOME:		jp	bhome		;lde head to home position
SELDSK:		jp	bseldsk		;select disk
SETTRK:		jp	bsettrk		;set track number
SETSEC:		jp	bsetsec		;set sector number
SETDMA:		jp	bsetdma		;set dma address
READ:		jp	bread		;read disk
WRITE:		jp	bwrite		;write disk
LISTST:		jp	blistst		;return list status
SECTRN:		jp	bsectran	;sector translate
;
;	dw	track
;	fixed data tables for four-drive standard
;	ibm-compatible 8" disks
;
;		disk Parameter header for disk 00
dpbase:		;dw	0000h, 0000h
		;dw	0000h, 0000h
		;dw	dirbf, dpblk
		;dw	chk00, all00
		
		DW	0000h, 0000h	;TRANSLATE TABLE
		DW	0000h, 0000h	;SCRATCH AREA
		DW	dirbf, DPB0	;DIR BUFF,PARM BLOCK
		DW	CSV0, ALV0	;CHECK, ALLOC VECTORS

DPB0:		;EQU	$		;DISK PARM BLOCK
		DW	32		;SEC PER TRACK
		DB	5		;BLOCK SHIFT
		DB	31		;BLOCK MASK
		DB	1		;EXTNT MASK
		DW	2047		;DISK SIZE-1
		DW	1023		;DIRECTORY MAX
		DB	255		;ALLOC0
		DB	0		;ALLOC1
		DW	0		;CHECK SIZE
		DW	2		;OFFSET

		
;		disk parameter header for disk 01
;		dw	0000h, 0000h
;		dw	0000h, 0000h
;		dw	dirbf, dpblk
;		dw	chk01, all01
;		disk parameter header for disk 02
;		dw	0000h, 0000h
;		dw	0000h, 0000h
;		dw	dirbf, dpblk
;		dw	chk02, all02
;;		disk parameter header for disk 03
;		dw	0000h, 0000h
;		dw	0000h, 0000h
;		dw	dirbf, dpblk
;		dw	chk03, all03
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
;dpblk:		;disk parameter block, common to all disks
;		dw	26		;sectors per track
;		db	3		;block shift factor
;		db	7		;block mask
;		db	0		;null mask
;		dw	242		;disk size-1
;		dw	63		;directory max
;		db	192		;alloc 0
;		db	0		;alloc 1
;		dw	16		;check size
;		dw	2		;track offset
;
;	end of fixed tables
;
;	individual subroutines to perform each function
boot:	;simplest case is to just perform parameter initialization
		ld	sp, 80h		;use space below buffer for stack

		xor	a
		ld	(debug), a
		ld	(iobyte), a	;clear the iobyte
		ld	(cdisk), a	;select disk zero

		call	sdInit
			
;	jp	gocpm		;initialize and go to cp/m
;
bwboot:	;simplest case is to read the disk until all sectors loaded
		ld	sp, 80h		;use space below buffer for stack
		xor	a
		ld	(isdirty),a

;		ld	HL, 0100h
;		ld	DE, 0101h
;		ld	BC, 0F0FFh
;		ld	(HL), 0
;		ldir
	
;		call	bconin
				
		call	fopen
		
;		ld	hl, init1msg
;		call	printstr	
;		call	dirPrintEntry

		
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
		ld	b, 0
		ld	c, d		;get sector address to register C
		call	bsetsec		;set sector address from register C
		pop	BC		;recall dma address to b, C
		push	BC		;replace on stack for later recall
		call	bsetdma		;set dma address from b, C
;	
					;drive set to 0, track set, sector set, dma address set
		call	bread
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
		ld	HL, (dpbase + 0ah) ;load Hl with dpblk of drive A:
		cp	(HL)
		pop	HL
		jp	C, load1	;carry generated if sector<26
;	
					;end of	current track,	go to next track
		ld	d, 0		;begin with first sector of next track
		inc	c		;track=track+1
;	
;		save	register state, and change tracks
		push	BC
;		push	DE
;		push	HL
		ld	b, 0
		call	bsettrk		;track address set from register c
;		pop	HL
;		pop	DE
		pop	BC
		jp	load1		;for another sector
;
;		end of	load operation, set parameters and go to cp/m
gocpm:	
		ld	HL, copyright
		call	printstr

		ld	a, 0c3h		;c3 is a jp instruction
		ld	(0), a		;for jp to wboot
		ld	HL, WBOOT	;wboot entry point
		ld	(1), HL		;set address field for jp at 0
;	
		ld	(5), a		;for jp to bdos
		ld	HL, bdos	;bdos entry point
		ld	(6), HL		;address field of Jump at 5 to bdos
;	
		ld	bc, 80h		;default dma address is 80h
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
	
		in	a, (STATB)
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
;		ld	a, c		;character to register a
;		ret			;null subroutine
		jp	serout
;
;
breader:	;reader character into register a from reader device
;		ld    a, 1ah		;enter end of file for now (replace later)
;		ani    7fh		;remember to strip parity bit
;		ret
		jp	serin
;	
;	
;		i/o drivers for the disk follow
;		for now, we will simply store the parameters away for use
;		in the read and write	subroutines
;	
bhome:		;lde to the track 00	position of current drive
;		translate this call into a settrk call with Parameter 00
		ld	bc, 0		;select track 0
		call	bsettrk
		ret			;we will lde to 00 on first read/write
;
bseldsk:	;select disk given by register c
		ld	HL, 0000h	;error return code
		ld	a, c
;		call	printhex
		ld	(diskno), a
		;cp	4		;must be between 0 and 3
		or	a		;must be 0
		ret	NZ		;no carry if 4, 5,...
;		disk number is in the proper range
;		ds	10		;space for disk select
;		compute proper disk Parameter header address
;		ld	a, (diskno)
;		ld	l, a		;l=disk number 0, 1, 2, 3
;		ld	h, 0		;high order zero
;		add	HL, HL		;*2
;		add	HL, HL		;*4
;		add	HL, HL		;*8
;		add	HL, HL		;*16 (size of each header)
		ld	hl, dpbase
;		add	HL, DE		;hl=,dpbase (diskno*16)
		ret
;
bsettrk:	;set track given by register bc
		ld	(track), bc	
;		push	BC
;		ld	c, 'T'
;		call	chrout
;		pop	BC
;		ld	a, b
;		call	printhex
;		ld	a, c
;		call	printhex
		ret
;
bsetsec:	;set sector given by register bc
		ld	(sector), bc
;		push	BC
;		ld	c, 'S'
;		call	chrout
;		pop	BC
;		ld	a, b
;		call	printhex
;		ld	a, c
;		call	printhex
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
;		ld	a, 1	
;		ld	(debug), a
;		
;		ld	c, 'R'
;		call	chroutdebug
;		call	spacedebug
	endif
	
;		ld	c, 'r'
;		call	bconout
		
		call	seeksectrk		
		ld	hl, (dmaad)
		ld	bc, 128
		call	fread

;	if DEBUG = 1
;		call	newlinedebug
;	endif
		xor	a
;	if DEBUG = 1
;		ld	(debug), a
;	endif
		ret
;		jp	waitio			;to perform the actual i/o


;
;
;
seeksectrk:	ld	de, fseeklen		;clear fseeklen
		call	clear32
						;fseeklen = track * secPerTrk + sector
		ld	de, (DPB0)		;de = sectors per track
		ld	bc, (track)
		call	mul16			;hl = de * bc
		ld	bc, (sector)
		add	hl, bc
		ld	(fseeklen + 1), hl
		
		xor	a			;shift right one position
		ld	b, 3			;fseeklen = hl * 128 (* 256 shr 1)
		ld	hl, fseeklen + 2
seeksectrk1:	rr	(hl)
		dec	hl
		djnz	seeksectrk1

;	if DEBUG = 1
;		ld	a, (debug)
;		or	a
;		jr	Z, seeksectrk2
;		
;		ld	c, 'T'
;		call	chroutdebug
;		ld	c, 'S'
;		call	chroutdebug
;		ld	a, (track)
;		ld	h, a
;		ld	a, (sector)
;		ld	l, a
;		call	printadrdebug
;			
;		ld	hl, (fseeklen + 2)
;		call	printadrdebug
;		ld	hl, (fseeklen)
;		call	printadrdebug
;	endif
	
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
		ld	a, c
		ld	(writemode), a
		
;		ld	c, 'w'
;		call	bconout
		
		call	seeksectrk		;compute seeklen
				
		ld	de, currpos		;currpos += 128
		ld	hl, const128
		call	add32
		
		ld	hl, (dmaad)		;copy data to sector buffer
		ld	de, (datptr)
		ld	bc, 128
		ldir
		ld	(datptr), de

		ld	a, 1
		ld	(isdirty), a
		
		ld	a, d
		or	a
		jr	nz, bwrite2		;last chunk to buffer written?

		ld	hl, DATBUF		;no, reset datptr to start of DATBUF
		ld	(datptr), hl
		
		ld	de, datsec		;increase data sector number
		ld	hl, const1
		call	add32
		
		ld	hl, secs2read	 	;read new cluster?
		dec	(hl)
		jr	NZ, bwrite3		;not zero, just go with incremented sector-number
		
		call	fatNextCluster		;get next cluster in curclus
		call	clust2sec		;compute sector-number
		call	fatInitSector
bwrite3:	ld	de, datsec
		call	sdReadDat
		jr	bwrite1
		
bwrite2:	
		ld	a, (writemode)		;is directory write (=1)?
		dec	a		
		jr	NZ, bwrite1		;no

		ld	de, datsec
		call	sdWriteDat

bwrite1:
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
track:		ds	2		;word track
sector:		ds	2		;two bytes for expansion
dmaad:		ds	2		;direct memory address
debug:		ds	1		;1 = enable debug
writemode:	ds	1		;0 = WRITE TO ALLOCATED, 1 = WRITE TO DIRECTORY, 2 = WRITE TO UNALLOCATED
;
;		scratch ram area for bdos use
begdat		equ	$	 	;beginning of data area
dirbf:		ds	128	 	;scratch directory area
ALV0:		DS	256		;allocation bitmap
CSV0:		DS	0

;all00:		ds	31	 	;allocation vector 0
;all01:		ds	31	 	;allocation vector 1
;all02:		ds	31	 	;allocation vector 2
;all03:		ds	31	 	;allocation vector 3
;chk00:		ds	16		;check vector 0
;chk01:		ds	16		;check vector 1
;chk02:		ds	16	 	;check vector 2
;chk03:		ds	16	 	;check vector 3
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
				
		

		
;copyright:	DB	27, "[2J", 27, "[H", 27, "[1m"
;		DB	"Z80 "
;		DB	27, "[35mFa", 27, "[m"
;		DB	"bulous "
;		DB	27, "[32mBi", 27, "[m"
;		DB	"nary "
;		DB	27, "[36mAn", 27, "[m"
;		DB	"ihilator",13, 10
;		DB	"CP/M 2.2 Copyright 1979 (c) by Digital Research"
;		DB	0



		
;	end