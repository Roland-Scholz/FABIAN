;	skeletal cbios for first level of CP/M 2.0 alteration
;
msize	equ	62		;cp/m version memory size in kilobytes
;
;	"bias" is address offset from 3400h for memory systems
;	than 16k (referred to as"b" throughout the text)
;
bias	equ	(msize-20)*1024
ccp	equ	3400h+bias	;base of ccp
bdos	equ	ccp+806h	;base of bdos
bios	equ	ccp+1600h	;base of bios
cdisk	equ	0004h		;current disk number 0=a,... l5=p
iobyte	equ	0003h		;intel i/o byte
;
;	org	bios		;origin of this program
nsects	equ	($-ccp)/128	;warm start sector count
;
;	jump vector for individual subroutines
;
BOOT	jmp	boot	;cold start
WBOOT	jmp	wboot	;warm start
CONST	jmp	const	;console status
CONIN	jmp	conin	;console character in
CONOUT	jmp	conout	;console character out
LIST	jmp	list	;list character out
PUNCH	jmp	punch	;punch character out
READER	jmp	reader	;reader character out
HOME	jmp	home	;move head to home position
SELDSK	jmp	seldsk	;select disk
SETTRK	jmp	settrk	;set track number
SETSEC	jmp	setsec	;set sector number
SETDMA	jmp	setdma	;set dma address
READ	jmp	read	;read disk
WRITE	jmp	write	;write disk
PRSTAT	jmp	listst	;return list status
SECTRN	jmp	sectran	;sector translate

DCB	dw	track
;
;	fixed data tables for four-drive standard
;	ibm-compatible 8" disks
;
;	disk Parameter header for disk 00
dpbase:	dw	0000h, 0000h
	dw	0000h, 0000h
	dw	dirbf, dpblk
	dw	chk00, all00
;	disk parameter header for disk 01
	dw	0000h, 0000h
	dw	0000h, 0000h
	dw	dirbf, dpblk
	dw	chk01, all01
;	disk parameter header for disk 02
	dw	0000h, 0000h
	dw	0000h, 0000h
	dw	dirbf, dpblk
	dw	chk02, all02
;	disk parameter header for disk 03
	dw	0000h, 0000h
	dw	0000h, 0000h
	dw	dirbf, dpblk
	dw	chk03, all03
;
;	sector translate vector
;trans:	db	 1,  7, 13, 19	;sectors  1,  2,  3,  4
;	db	25,  5, 11, 17	;sectors  5,  6,  7,  6
;	db	23,  3,  9, 15	;sectors  9, 10, 11, 12
;	db	21,  2,  8, 14	;sectors 13, 14, 15, 16
;	db	20, 26,  6, 12	;sectors 17, 18, 19, 20
;	db	18, 24,  4, 10	;sectors 21, 22, 23, 24
;	db	16, 22		;sectors 25, 26
;
dpblk:	;disk parameter block, common to all disks
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
	xra	a		;zero in the accum
	sta	iobyte		;clear the iobyte
	sta	cdisk		;select disk zero
	jmp	gocpm		;initialize and go to cp/m
;
wboot:	;simplest case is to read the disk until all sectors loaded
	lxi	sp, 80h		;use space below buffer for stack
	mvi	c, 0		;select disk 0
	call	seldsk
	call	home		;go to track 00
;
	mvi	b, nsects	;b counts * of sectors to load
	mvi	c, 0		;c has the current track number
	mvi	d, 2		;d has the next sector to read
;	note that we begin by reading track 0, sector 2 since sector 1
;	contains the cold start loader, which is skipped in a warm start
	lxi	h, ccp		;base of cp/m (initial load point)
load1:	;load	one more sector
	push	b		;save sector count, current track
	push	d		;save next sector to read
	push	h		;save dma address
	mov	c, d		;get sector address to register C
	call	setsec		;set sector address from register C
	pop	b		;recall dma address to b, C
	push	b		;replace on stack for later recall
	call	setdma		;set dma address from b, C
;
;	drive set to 0, track set, sector set, dma address set
	call	read
	cpi	00h		;any errors?
	jnz	wboot		;retry the entire boot if an error occurs
;
;	no error, move to next sector
	pop	h		;recall dma address
	lxi	d, 128		;dma=dma+128
	dad	d		;new dma address is in h, l
	pop	d		;recall sector address
	pop	b	;recall number of sectors remaining, and current trk
	dcr	b		;sectors=sectors-1
	jz	gocpm		;transfer to cp/m if all have been loaded
;
;	more	sectors remain to load, check for track change
	inr	d
	mov	a,d		;sector=27?, if so, change tracks
	cpi	27
	jc	load1		;carry generated if sector<27
;
;	end of	current track,	go to next track
	mvi	d, 1		;begin with first sector of next track
	inr	c		;track=track+1
;
;	save	register state, and change tracks
	push	b
	push	d
	push	h
	call	settrk		;track address set from register c
	pop	h
	pop	d
	pop	b
	jmp	load1		;for another sector
;
;	end of	load operation, set parameters and go to cp/m
gocpm:
	mvi	a, 0c3h		;c3 is a jmp instruction
	sta	0		;for jmp to wboot
	lxi	h, WBOOT	;wboot entry point
	shld	1		;set address field for jmp at 0
;
	sta	5		;for jmp to bdos
	lxi	h, bdos		;bdos entry point
	shld	6		;address field of Jump at 5 to bdos
;
	lxi	b, 80h		;default dma address is 80h
	call	setdma
;
;	ei			;enable the interrupt system
	lda	cdisk		;get current disk number
	mov	c, a		;send to the ccp
	jmp	ccp		;go to cp/m for further processing
;
;
;	simple i/o handlers (must be filled in by user)
;	in each case, the entry point is provided, with space reserved
;	to insert your own code
;
const:	;console status, return 0ffh if character ready, 00h if not
;	ds     10h		;space for status subroutine
	mvi    a, 00h
	ret
;
conin:	;console character into register a
;	ds	10h		;space for input routine
	lda	con
	cpi	13
	jnz	conin1
	xra	a
	sta	con
	mvi	a, 10
	ret
conin1:
;	out	0fch
	in	1
;	ani	7fh		;strip parity bit
	cpi	10
;	out	0fdh
	rnz
;	out	0fch
	mvi	a, 13
	sta	con	
;	out	0fdh
	ret
	
con:	ds	1
;
conout:	;console character output from register c
	mov	a, c		;get to accumulator
	out	1
;	ds	10h		;space for output routine
	ret
;
list:	;list character from register c
	mov	a, c	  	;character to register a
	ret		  	;null subroutine
;
listst:	;return list status (0 if not ready, 1 if ready)
	xra	a	 	;0 is always ok to return
	ret
;
punch:	;punch	character from	register C
	mov	a, c		;character to register a
	ret			;null subroutine
;
;
reader:	;reader character into register a from reader device
	mvi    a, 1ah		;enter end of file for now (replace later)
	ani    7fh		;remember to strip parity bit
	ret
;
;
;	i/o drivers for the disk follow
;	for now, we will simply store the parameters away for use
;	in the read and write	subroutines
;
home:	;move to the track 00	position of current drive
;	translate this call into a settrk call with Parameter 00
	mvi    c, 0		;select track 0
	call   settrk
	ret			;we will move to 00 on first read/write
;
seldsk:	;select disk given by register c
	lxi	h, 0000h	;error return code
	mov	a, c
	sta	diskno
	cpi	4		;must be between 0 and 3
	rnc			;no carry if 4, 5,...
;	disk number is in the proper range
;	ds	10		;space for disk select
;	compute proper disk Parameter header address
	lda	diskno
	mov	l, a		;l=disk number 0, 1, 2, 3
	mvi	h, 0		;high order zero
	dad	h		;*2
	dad	h		;*4
	dad	h		;*8
	dad	h		;*16 (size of each header)
	lxi	d, dpbase
	dad	d		;hl=,dpbase (diskno*16)
	ret
;
settrk:	;set track given by register c
	mov	a, c
	sta	track
	xra	a
	sta	track+1
;	ds	10h		;space for track select
	ret
;
setsec:	;set sector given by register c
	mov	a, c
	sta	sector
	xra	a
	sta	sector+1
;	ds	10h		;space for sector select
	ret
;
;
sectran:
	;translate the sector given by bc using the
	;translate table given by de
;	xchg			;hl=.trans
;	dad	b		;hl=.trans (sector)
;	out	0fch
	mov	l, c		;l=trans (sector)
	mov	h, b		;hl=trans (sector)
;	out	0fdh
	ret			;with value in hl
;
setdma:	;set	dma address given by registers b and c
	mov	l, c		;low order address
	mov	h, b		;high order address
	shld	dmaad		;save the address
;	ds	10h		;space for setting the dma address
	ret
;
read:	;perform read operation (usually this is similar to write
;	so we will allow space to set up read command, then use
;	common code in write)
;	ds	10h		;set up read command
;	jmp	waitio		;to perform the actual i/o
	in	2
	xra	a
	ret
;
write:	;perform a write operation
	out	2
	xra	a
	ret
;
;	ds	10h		;set up write command
;
waitio:	;enter	here from read	and write to perform the actual i/o
;	operation. return a 00h in register a if the operation completes
;	properly, and 0lh if an error occurs during the read or write
;
;	in this case, we have saved the disk number in 'diskno' (0, 1)
;			the track number in 'track' (0-76)
;			the sector number in 'sector' (1-26)
;			the dma address in 'dmaad' (0-65535)
;	ds	256		;space reserved for i/o drivers
;	mvi	a, 1		;error condition
;	ret			;replaced when filled-in
;
;	the remainder of the cbios is reserved uninitialized
;	data area, and does not need to be a Part of the
;	system	memory image (the space must be available,
;	however, between"begdat" and"enddat").
;
track:	ds	2		;two bytes for expansion
sector:	ds	2		;two bytes for expansion
dmaad:	ds	2		;direct memory address
diskno:	ds	1		;disk number 0-15
;
;	scratch ram area for bdos use
begdat	equ	$	 	;beginning of data area
dirbf:	ds	128	 	;scratch directory area
all00:	ds	31	 	;allocation vector 0
all01:	ds	31	 	;allocation vector 1
all02:	ds	31	 	;allocation vector 2
all03:	ds	31	 	;allocation vector 3
chk00:	ds	16		;check vector 0
chk01:	ds	16		;check vector 1
chk02:	ds	16	 	;check vector 2
chk03:	ds	16	 	;check vector 3
;
enddat	equ	$	 	;end of data area
datsiz	equ	$-begdat;	;size of data area
	;end