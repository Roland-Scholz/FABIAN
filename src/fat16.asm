FATDEBUG	equ	0

OP0		equ	1
OP1		equ	2
OP2		equ	4

IP0		equ	1
IP1		equ	2
IP2		equ	4

;--------------------------------------------------------------
; SD CARD constants
;--------------------------------------------------------------
CMD0		equ	$40 +  0	;GO_IDLE_STATE	0x40, 64
CMD1		equ	$40 +  1	;reset
CMD8		equ	$40 +  8	;SEND_IF_COND	0x48, 72
CMD9		equ	$40 +  9	;SEND_CSD	0x49, 73
CMD13		equ	$40 + 13	;get_status	0x4D, 77
CMD17		equ	$40 + 17	;read  sector 	0x51, 81
CMD24		equ	$40 + 24	;write sector 	0x58, 88
CMD41		equ	$40 + 41	;SEND_OP_COND	0x69, 105 (leave idle state)
CMD55		equ	$40 + 55	;ACMD 		0x77, 119	
CMD58		equ	$40 + 58	;READ_OCR	0x7A, 122

DATEND		equ	DATBUF + $200

DATA_START_BLOCK	equ $FE
DATA_RES_MASK		equ $1F
DATA_RES_ACCEPTED	equ $05

CMD0CHK		equ $95
CMD1CHK		equ $F9
CMD8CHK		equ $87

R1_IDLE_STATE	equ 1
R1_ILLEGAL_COMMAND equ 4

SDCS		equ	OP0
SDMOSI		equ	OP1
;SDCLK		equ	OP2
SDMISO		equ	IP0

FEOF		equ	$FF
FNOTFOUND	equ	$FE

;CR		equ	13
;LF		equ	10
;--------------------------------------------------------------
; Input
; HL 	pointer to 4-byte seek-length			
;--------------------------------------------------------------
fseek:
		call	isZero32			;(hl) zero = first request?
		jr	Z, fseek8
		
		ld	de, currpos			;no, currpos equal?
		call	equal32
		ret	z				;yes nothing to do
		
fseek8:		push	hl
		call	fopen1				;reset file-Ptr, currpos etc.

		pop	hl
		ld	de, bytesavail
		call	cmp32				;bytesavail - seeksize
		jr	NC, fseek1			;seeksize <= bytesavail 
		ld	a, FEOF				;no
		ld	(fstatus), a
		ret

fseek1:		call	sbc32				;byteavail -= seeklen
		ld	de, currpos			;currpos = seeklen
		call	copy32

		ld	de, datptr
		ld	a, (hl)				;copy 9 bits to datptr
		ld	(de), a
		ld	c, a				;save a in bc
		inc	hl
		inc	de
		ld	a, (hl)
		and	1
		ld	b, a				;save a in bc
		add	DATBUF >> 8			;carry clear
		ld	(de), a
		push	bc				;offset into DATBUF
		
		inc	hl
		inc	hl				;3rd byte of seeklen
		ld	de, datsec + 3
		xor	a				;clear 4th byte
		ld	(de), a
				
		ld	b, 3				;copy 3 bytes and shift right once
fseek2:		dec	de				;giving datsec
		ld	a, (hl)
		rra
		ld	(de), a
		dec	hl
		djnz	fseek2

		xor	a				;clear carry
		pop	bc
		ld	hl, 512
		sbc	hl, bc
		ld	(bytes2read), hl		;remaining bytes in sector
		
		ld	hl, datsec			;copy datsec to var32
		ld	de, var32
		call	copy32

							;compute cluster number
		ld	a, (secclus)			;rotate secclus bitposition to right
		ld	c, a		
fseek4:		rr	c
		jr	C, fseek3			;done
		ld	b, 3
		ld	hl, var32 + 2
fseek5:		rr	(hl)
		dec	hl
		djnz	fseek5
		jr	fseek4

fseek3:		ld	hl, datsec			;datsec
		ld	a, (secclus)
		dec	a
		and	(hl)
		ld	(fsecmask), a
		ld	b, a
		ld	a, (secclus)
		sub	b
		ld	(secs2read), a
			

		ld	hl, (var32)
fseek6:		push	hl				;traverse var32 + 1(firstclust) clusters
		call	fatNextCluster
		pop	hl
		ld	a, l
		or	a, h
		jr	Z, fseek7
		dec	hl
		jr	fseek6

fseek7:		call	clust2sec
		ld	a, (fsecmask)
		ld	(var8), a
		ld	de, datsec
		ld	hl, var8
		call	add32				;de += hl
		call	sdReadDat
		
;		ld	hl, (datptr)
;		call	printadr
;		ld	hl, (datsec)
;		call	printadr
;		ld	hl, (var32)
;		call	printadr
;		ld	hl, (bytesavail)
;		call	printadr
;		ld	hl, (bytes2read)
;		call	printadr
;		ld	a, (secs2read)
;		call	printhexdebug
		ret
		
;--------------------------------------------------------------
; Input
; BC	number of bytes to write
; HL	pointer to buffer to read from
;
; Output
; A	status, 0 = OK, negativ = Error
;--------------------------------------------------------------
fwrite:	

;--------------------------------------------------------------
; Input
; BC	number of bytes to read
; HL	pointer to buffer
;
; Output
; A	status, 0 = OK, negativ = Error
;--------------------------------------------------------------
fread:		push	hl
		ld	(freadbytes), bc		;bytes still to be read during fread
		ld	(fbuffer), hl			;save hl in fbuffer
		xor	a
		ld	(fstatus), a			;clear status
		ld	h, a
		ld	l, a
		ld	(fbytesread), hl		;clear fbytesread
		
freadloop:
	IF FATDEBUG = 1
		call	fdump
	ENDIF
		ld	hl, freadbytes			;bytes to be read?
		call	isZero32
		jr	Z, freadex			;no -> finished
		
		ld	hl, bytesavail			;are still bytes available?
		call	isZero32
		jr	NZ, fread1
		ld	a, FEOF
		ld	(fstatus),a
freadex:	pop	hl				;reload hl with adr of buffer
		ld	bc, (fbytesread)		;load bc with bytes read 
		ret

fread1:		ld	de, bytesavail			;if bytesavail < freadbytes 
		ld	hl, freadbytes
		call	cmp32
		jr	NC, fread2
		ld	a, FEOF
		ld	(fstatus), a
		ex	de, hl				;freadbytes = bytesavail
		call	copy32

fread2:		ld	bc, (freadbytes)
		xor	a				;clear carry
		ld	hl, (bytes2read)		;if bytes2read < freadbytes?
		sbc	hl, bc
		jr	NC, fread3
		ld	bc, (bytes2read)
		
fread3:		ld	a, b				;is bytes2read zero?
		or	a, c
		jr	NZ, fread4			;no, continue coying data
		
		ld	de, datsec			;increase data sector number
		ld	hl, const1
		call	add32
		
		ld	hl, secs2read	 		;read new cluster?
		dec	(hl)
		jr	NZ, fread6			;not zero, just go with incremented sector-number
		
		call	fatNextCluster			;get next cluster in curclus
		call	clust2sec			;compute sector-number

fread6:		
		call	fatInitSector
			
;		ld	hl, (bytes2read)		;$200 to read?	
;		ld	(var16), hl
;		ld	a, h
;		cp	2
;		jr	NZ, fread5
;		
;		ld	hl, (fbuffer)			;write sector directly into receiving buffer
;		call	sdReadSec
;		ld	(fbuffer), hl
;		jr	fread7
		
fread5:
		call	sdReadDat
		jr	fread2				;bytes2read is <> 0 so we always end up at fread4
		
fread4:		ld	(var16), bc			;copy available sector data to buffer
		ld	hl, (datptr)			;copy from datptr to fbuffer
		ld	de, (fbuffer)
		ldir
		ld	(fbuffer), de
		ld	(datptr), hl

fread7:		xor	a				;bytes2read -= var16
		ld	hl, (bytes2read)
		ld	bc, (var16)
		sbc	hl, bc
		ld	(bytes2read), hl
		
		ld	hl, (fbytesread)		;fbytesread += var16
		add	hl, bc
		ld	(fbytesread), hl
				
		ld	de, bytesavail			;bytesavail -= bytes2read
		ld	hl, var16
		call	sbc32

		ld	de, freadbytes			;freadbytes -= bytes2read
		call	sbc32
		
		ld	de, currpos			;currpos += bytes2read
		call	add32
		jp	freadloop
		
;--------------------------------------------------------------
;
;--------------------------------------------------------------
fatInitSector:		
		ld	hl, DATBUF			;datptr = DATBUF
		ld	(datptr), hl
		
		ld	a, (secclus)			;secs2read = secclus
		ld	(secs2read), a
		
		ld	hl, 512				;bytes to read = 512
		ld	(bytes2read), hl
		
		ld	hl, bytesavail + 3
		ld	a, (hl)				;if filesize < 512 then
		dec	hl
		or	a, (hl)
		ret	NZ				;> $FFFF!
		dec	hl
		ld	a, (hl)
		cp	2				;>= $200?
		ret	NC				;yes
		
		ld	hl, (bytesavail)		;bytes2read = filesize
		ld	(bytes2read), hl
		
		ret
;
;
;		
fopen:		call	dirSearch
		jr	NZ, fopen1
		ld	a, FNOTFOUND
		or	a
		ret

fopen1:				
		ld	de, currpos			;currpos = 0
		call	clear32
		
		ld	hl, filesize			;bytesavail = filesize
		ld	de, bytesavail
		call	copy32

		ld	hl, 0
		ld	(bytes2read), hl
		ld	(curclus), hl
		
;		dec	hl
;		ld	(lastfatsec), hl
;		ld	(lastfatsec + 2), hl
		
		xor	a	
		ret	

;--------------------------------------------------------------
;
;--------------------------------------------------------------
	IF FATDEBUG = 1
fdump:		ld	hl, (fbuffer)
		call	printadr
		ld	hl, (datptr)
		call	printadr
		ld	hl, (bytesavail)
		call	printadr
		ld	hl, (bytes2read)
		call	printadr
		ld	hl, (currpos)
		call	printadr
		ld	hl, (freadbytes)
		call	printadr		
		ld	hl, (curclus)
		call	printadr
		
		jp	newline
	ENDIF

;--------------------------------------------------------------
; gets next cluster after curclus and stores in curclus
;--------------------------------------------------------------
fatNextCluster:
		ld	hl, (curclus)			;is curclus = 0, go with curclus = firstclust
		ld	a, l
		or	a, h
		jr	NZ, fatNextCluster1		;no
		ld	bc, (firstclust)
		jr	fatNextCluster2
		
fatNextCluster1:
		ld	hl, fatbase			;computer FAT sector containing cluster
		ld	de, fatsector
		call	copy32				;fatsector = fatbase
		ld	a, (curclus + 1)
		ld	(var8), a
		ld	hl, var8
		call	add32				;de = fatsector = fatbase + hi(firstclust)		

		call	sdReadFat

	
		ld	hl, (curclus)			;lo(curclus) * 2
		ld	h, 0
		add	hl, hl
		ld	bc, FATBUF
		add	hl, bc				;+ FATBUF
		ld	c, (hl)
		inc	hl
		ld	b, (hl)
fatNextCluster2:
		ld	(curclus), bc
		ret	

;--------------------------------------------------------------		
; search root-dir for file like "dirpattern"
;--------------------------------------------------------------
dirSearch:	call	dirReadFirst			;read first root-entry	
dirSearch1:	ret	Z				;exit if zero	
		ld	b, 11				;compare 11-bytes of dir name
		ld	de, dirpattern	
dirSearch2:	ld	a, (de)	
		cp	'?'	
		jr	Z, dirSearch3	
		cp	(hl)	
		jr	NZ, dirSearch4	
dirSearch3:	inc	de	
		inc	hl	
		djnz	dirSearch2	
		or	1	
		ret	
dirSearch4:	call	dirReadNext			;get next dir
		jr	dirSearch1	
;	
;	
;	
dirReadFirst:			
		ld	hl, dirbase			;from dirbase
		ld	de, dirsec			;to dirsec
		call	copy32	
	
dirReadSector:	
		call	sdReadDat			;load directory sectorgiven in DE	
		ld	hl, DATBUF 			;start at begin of dir-data
		ld	(dirptr), hl	
			
dirRead2:	ld	a, (hl)				;first byte of name zero?
		or	a	
		ret	Z				;yes, dir-ed reached, quit ZERO flag set
		cp	0e5h				;first byte of file-name E5? -> deleted
		jr	Z, dirRead1
	
		push	hl	
		pop	ix				;ix = hl
		ld	a, (ix + 11)			;load attribute byte
		and	%00011111			;mask out archive ($20) and 2 highest bits
		jr	NZ, dirRead1			;if no file -> next dir
		
		ld	b, 6				;copy 6 bytes (clust + size)
		ld	de, firstclust			;to firstclust, filesize
dirRead5:	ld	a, (ix + $1a)	
		ld	(de), a	
		inc	de	
		inc	ix	
		djnz	dirRead5			
		or	1				;reset ZERO flag
		ret	
	
dirReadNext:	ld	hl, (dirptr)	
dirRead1:	ld	de, 32				;hl = hl + 32
		add	hl, de	
		ld	(dirptr), hl	
	
		ld	a, h
		cp	DATEND >> 8	
		jr	NZ, dirRead2 	
			
		ld	de, dirsec			;increment dirsector 32-bit
		ld	hl, const1
		call	add32		
		jr	dirReadSector
	
;--------------------------------------------------------------
; prints entire directory
;--------------------------------------------------------------	
dirPrint:
;		ld	hl, allpattern			;copy allpattern to dirpattern
;		ld	de, dirpattern
;		ld	bc, 11
;		ldir
		
		call	dirReadFirst
dirPrint1:	ret	Z				;return if zero
		call	dirPrintEntry
		call	dirReadNext
		jr	dirPrint1
		
;--------------------------------------------------------------
; prints dir @ hl
;--------------------------------------------------------------
dirPrintEntry:	push	hl
		ld	hl, (dirptr)			;print dir name 8 space 3
		ld	b, 8
		call	dirPrintEntry1
		call	space
		ld	b, 3
		call	dirPrintEntry1
		
		call	space				;filesize high
		ld	hl, (filesize + 2)
		call	printadr		
		ld	hl, (filesize)			;filesize low
		call	printadr
		
		call	newline
		pop	hl
		ret
		
dirPrintEntry1:	ld	c, (hl)
		call	chrout
		inc	hl
		djnz	dirPrintEntry1
		ret
		
		
;--------------------------------------------------------------
; computes the first data-sector from cluster-number
;
; datsec = (curclus - 2) * secclus + datbase
; de : points to datsec
;--------------------------------------------------------------
clust2sec:	ld	hl, (curclus)
		dec	hl
		dec	hl				;minus 2
		ld	de, 0
		ld	a, (secclus)
		
clust2sec2:	rra
		jr	C, clust2sec1			;carry set, finished		
		rl	l
		rl	h
		rl	e
		rl	d
		jr	clust2sec2
		
clust2sec1:	ld	(datsec), hl
		ld	(datsec + 2), de
		ld	de, datsec
		ld	hl, datbase
		jp	add32
			
;--------------------------------------------------------------
;
;--------------------------------------------------------------
sdInit:
;		ld	hl, init0msg
;		call	printstr
		
		call	sdDeselect
;		ld	a, SDCLK			;bring SDCLK low
;		out	(OPSET), a	
		ld	d, 12				;clock 96 times
		call	sdReadbyteX	
		
;	
; send CMD0	
;				
		call	sdClrAdr	
		ld	a, CMD0CHK			;load checksum
		ld	(sdchk), a	
sdInit1:	ld	a, CMD0				;command in A
		call	sdCardCmd
		cp	R1_IDLE_STATE
		jr	NZ, sdInit

;
; send CMD8
;
		
sdInit2:	call	sdClrAdr
		ld	hl, $aa01
		ld	(sdadr+2), hl
		ld	a, CMD8CHK
		ld	(sdchk), a
		ld	a, CMD8
		call	sdCardCmd
;		and	#R1_ILLEGAL_COMMAND
;		cmp	#R1_ILLEGAL_COMMAND		
;		bne	sdInit3
		
;		ldx #3
;		jsr readByteX



;		
; ACMD41 = CMD55 + CMD41
;
sdInit6:	call	sdDeselect
		call	sdClrAdr
		ld	a, CMD55	
		call	sdCardCmd
			
		ld	a, $40
		ld	(sdadr), a
		ld	a, CMD41
		call	sdCardCmd
		jr	NZ, sdInit6			;result not 0, start over
		call	sdDeselect
			
;sdInit4:	call	sdDeselect	
;		ld	a, CMD58			;read OCR, ($3A)
;		ld	(sdcmd), a	
;		call	sdCardCmd	
;		jr	NZ, sdInit4	
;		
;		ld	d, 3	
;		call	sdReadbyteX	
	
		ld	de, fatsector			;read sector 0
		call	clear32
		call	sdReadFat	
			
		ld	hl, FATBUF			;from
		ld	bc, $1c6			;sdbuffer + $1c6
		add	hl, bc                  	 
		ld	de, fatsector			;to fatsector
		call	copy32                  	 
							
		call	sdReadFat	
							
		ld	hl, FATBUF			;from
		ld	bc, 13				;sdbuffer + 13
		add	hl, bc                  	 
		ld	de, secclus			;to secclus
		ld	bc, 11				;copy 11-bytes
		ldir                            	 
							
							
		ld	hl, (ressec)			;fatbase = dirbase = fatsector + ressec 
		ld	(var16), hl			;copy resec to var16
		ld	hl, fatsector			;copy sdsector to fatbase
		ld	de, fatbase             	 
		call	copy32                  	 
		ld	hl, var16			;add resec to fatbase
		call	add32 	
		ex	de, hl				;copy fatbase to dirbase
		ld	de, dirbase             	 
		call	copy32                  	 
							
		ld	hl, (secsfat)           	 
		ld	(var16), hl             	 
		ld	hl, var16               	 
		ld	a, (numfats)			;dirbase += secsfat * numfats
		ld	b, a	
fatCompDirbase:	call	add32	
		djnz	fatCompDirbase	
	
							;datbase = (numdir / 16) + dirbase
		ld	hl, (numdir)			;datbase = numdir
		ld	b, 4	
fatcompDatbase:	srl	h	
		rr	l	
		djnz	fatcompDatbase	
			
		ld	de, (dirbase)	
		add	hl, de				;datbase += dirbase
		ld	(datbase), hl
		
;		ld	hl, init1msg
;		jp	printstr		
		ret
		
;--------------------------------------------------------------
; DE: address of 4-byte sector number
;--------------------------------------------------------------
sdSetSector:	ld	hl, sdadr + 3
		xor	a
		ld	(hl), a
		dec	hl
		ld	b, 3
sdSetSector1:	ld	a, (de)
;	if DEBUG = 1
;		call	printhexdebug
;	endif
		rla
		ld	(hl), a
		inc	de
		dec	hl
		djnz	sdSetSector1
		ret
		
;--------------------------------------------------------------
;
;--------------------------------------------------------------
sdReadFat:	
;		push	de
;		ld	b, 4
;sdReadFat1:	ld	a, (de)
;		call	printhex
;		inc	de
;		djnz	sdReadFat1
;		pop	de
		
		ld	hl, lastfatsec			;FAT sector in DE already read?
		call	equal32
		ret	Z				;yes
		
;		ld	c, 'F'
;		call	chrout
		
		ex	de, hl				;copy sector to lastfatsec
		call	copy32
		ex	de, hl
		
		ld	hl, FATBUF
		jr	sdReadSec		

;--------------------------------------------------------------
; reads one sector in (DE) into DATBUF
;--------------------------------------------------------------
sdReadDat:	
		ld	hl, lastdatsec			;FAT sector in DE already read?
		call	equal32				;de = hl ?
		ret	Z				;yes
		
;		ld	c, 'R'
;		call	chrout
		
		ld	a, (isdirty)
		or	a
		jr	Z, sdReadDat1
		
		push	de
		push	hl
		ld	de, lastdatsec
		call	sdWriteDat
		pop	hl
		pop	de
		
sdReadDat1:	ex	de, hl				;copy sector to lastdatsec
		call	copy32				;de = hl
		ex	de, hl
		ld	hl, DATBUF
		
;--------------------------------------------------------------
; hl		buffer to load data into
; de		pointer to 4-byte sector number
;--------------------------------------------------------------
sdReadSec:	push	hl
		call	sdSetSector
		ld	a, CMD17			;read block
		call	sdCardCmd	
			
sdReadSec2:	call	sdReadByte			;data token until $FE, i.e. bit 0 = 0;
		rr	c	
		jr	C, sdReadSec2	

;		ld	a, SDMOSI
;		out	(OPRES), a			;SDMOSI = 1
			
		pop	hl	
;		ld	de, 512				;read 512 bytes
;		ld	b, SDCLK

;		ld	d, 2
		ld	bc, 02h				;b = 0, c = 2
sdReadSec1:	
		in	a, (INPORT)			;11
		rra					;4
		rl	d				;7 = 22
		in	a, (INPORT)
		rra
		rl	d
		in	a, (INPORT)
		rra
		rl	d
		in	a, (INPORT)
		rra
		rl	d
		in	a, (INPORT)
		rra
		rl	d
		in	a, (INPORT)
		rra
		rl	d
		in	a, (INPORT)
		rra
		rl	d
		in	a, (INPORT)
		rra
		rl	d

		ld	(hl), d	
		inc	hl	
		djnz	sdReadSec1
		dec	c	
		jr	NZ, sdReadSec1	

		ld	d, 2				;2-byte checksum
		call	sdReadbyteX	
		jp	sdDeselect
		
		
;--------------------------------------------------------------
; writes one sector in (DE) into DATBUF
;--------------------------------------------------------------
sdWriteDat:
;		ld	c, 'W'
;		call	chrout
		
		ld	hl, DATBUF
		xor	a
		ld	(isdirty), a
;--------------------------------------------------------------
; hl		buffer to copy data from
; de		pointer to 4-byte sector number
;--------------------------------------------------------------
sdWriteSec:	
		push	hl
		call	sdSetSector
		ld	a, CMD24			;write sector
		call	sdCardCmd	

		ld	c, DATA_START_BLOCK
		call	sdSendByte
		
		pop	hl	
		ld	b, 0				;read 512 bytes
		ld	d, SDMOSI
		ld	e, 7
		
sdWriteSec1:	call	sdWrite256
		call	sdWrite256	

sdWriteSec2:	call	sdReadByte
		ld	a, c
		cp	$FF
		jr	Z, sdWriteSec2			;loop if $ff
		
;		and	DATA_RES_MASK			;assume data accepted
;		cp	DATA_RES_ACCEPTED		; "00000101" = 5 ?

		call	sdWait
		jp	sdDeselect	


sdWrite256:	ld	a, (hl)
		rla					;4
		ld	c, e				;4
		rl	c				;8
		out	(c), d				;12
		in	c, (c)				;12 just clock the sdCard = 40
		rla		
		ld	c, e
		rl	c	
		out	(c), d
		in	c, (c)
		rla		
		ld	c, e	
		rl	c	
		out	(c), d
		in	c, (c)
		rla		
		ld	c, e	
		rl	c	
		out	(c), d
		in	c, (c)
		rla		
		ld	c, e	
		rl	c	
		out	(c), d
		in	c, (c)
		rla		
		ld	c, e	
		rl	c	
		out	(c), d
		in	c, (c)
		rla		
		ld	c, e	
		rl	c	
		out	(c), d
		in	c, (c)
		rla		
		ld	c, e	
		rl	c	
		out	(c), d
		in	c, (c)

		inc	hl		
		djnz	sdWrite256	
		ret
;--------------------------------------------------------------
;
;--------------------------------------------------------------
sdSelect:	ld	a, SDCS					
		out	(OPSET), a			;SDCS low (active)	
sdWait:		call	sdReadByte
		ld	a, 255
		cp	c
		jr	NZ, sdWait
		ret
		
;--------------------------------------------------------------
;
;--------------------------------------------------------------
sdDeselect:	ld	a, SDCS
		out	(OPRES), a
		jp	sdReadByte
		
;--------------------------------------------------------------
;
;--------------------------------------------------------------
sdReadbyteX:	call	sdReadByte
		dec	d
		jr	NZ, sdReadbyteX
		ret

;--------------------------------------------------------------
; Input, get byte form sdCard
;
; c : read byte from sd-card
;--------------------------------------------------------------
sdReadByte:	ld	a, SDMOSI
		out	(OPRES), a			;SDMOSI = 1
		ld	b, 8
sdReadByte1:	in	a, (INPORT)
		rra
		rl	c
		djnz	sdReadByte1
		ret
		

;--------------------------------------------------------------
; output, send byte to sdCard
;
; c : byte to send to sd-card
;--------------------------------------------------------------
sdSendByte:	ld	b, 8
sdSendByte1:	rl	c				;7
		ld	a, SDMOSI			;7
		jr	C, sdSendByte2			;12/7
		out	(OPSET), a			;11 ;carry 0, SDMOSI = 0
		jr	sdSendByte3			;12/7		
sdSendByte2:	out	(OPRES), a			;11 carry 1, SDMOSI = 1
sdSendByte3:	in	a, (INPORT)			;11 just clock the sdCard
		djnz	sdSendByte1
		ret

;--------------------------------------------------------------
; sends command in A to SD card
;--------------------------------------------------------------
sdCardCmd:	ld	hl, sdcmd
		ld	(hl), a
			
;	if DEBUG = 1
;		ld	c, 'C'
;		call	chroutdebug
;		call	printhexdebug
;		call	spacedebug
;	endif
	
sdCardCmd3:	
		call	sdSelect
		ld	d, 6
sdCardCmd1:	ld	c, (hl)
		call	sdSendByte
		inc	hl
		dec	d
		jr	NZ, sdCardCmd1
sdCardCmd2:	call	sdReadByte
		ld	a, c
;	if DEBUG = 1
;		call	printhexdebug
;	endif
		or	a, a
		jp	M, sdCardCmd2
;	if DEBUG = 1
;		call	spacedebug
;	endif
	
		ret

;--------------------------------------------------------------
;
;--------------------------------------------------------------	
sdClrAdr:	ld	hl, 0
		ld	(sdadr), hl
		ld	(sdadr + 2), hl
		ret
		
	if DEBUG = 1
printadrdebug:
		push	af
		ld	a, (debug)
		or	a
		jr	Z, printadrdebex
		pop	af
		jp	printadr
printadrdebex:	pop	af
		ret


printhexdebug:
		push	af
		ld	a, (debug)
		or	a
		jr	Z, printhexdex
		pop	af
		jp	printhex
printhexdex:	pop	af
		ret
		
		
		
chroutdebug:
		push	af
		ld	a, (debug)
		or	a
		jr	Z, chroutdebugex
		pop	af
		jp	chrout
chroutdebugex:	pop	af
		ret

spacedebug:
		push	af
		ld	a, (debug)
		or	a
		jr	Z, spacedebugex
		pop	af
		jp	space
spacedebugex:	pop	af
		ret

newlinedebug:
		push	af
		ld	a, (debug)
		or	a
		jr	Z, newlinedebugex
		pop	af
		jp	newline
newlinedebugex:	pop	af
		ret
	endif
	
;--------------------------------------------------------------
; variables and constants
;--------------------------------------------------------------	

;init0msg:	db	13, 10, "initialising SDcard... ", 0
;init1msg:	db	"done.", 13, 10 , 0
	
sdcmd:		db	0			;1-byte SD card command
sdadr:		db	0, 0, 0, 0		;4-byte SD card address
sdchk:		db	0			;1-byte SD card checksum
sdres:		db	0			;1-byte SD card R1 result

;
; FATBUF + 13, 11-bytes holding basic FAT info
secclus:	db	0			;1-byte FAT sectors per cluster
ressec:		db	0, 0			;2-byte	DAT reserved sectors
numfats:	db	0			;1-byte number of FATS
numdir:		db	0, 0			;2-byte max number of 32-bytes root directoy entries
numsecs:	db	0, 0			;2-byte number of sectors in this volume
media:		db	0			;1-byte 0xF8 is the standard value for “fixed” (nonremovable) media. For removable media, 0xF0 is frequently used.
secsfat:	db	0, 0			;2-byte FAT12/FAT16 16-bit count of sectors occupied by one FAT
						
fatbase:	db	0, 0, 0, 0		;4-byte	first sector of FAT
dirbase:	db	0, 0, 0, 0		;4-byte	first sector of root directory
datbase:	db	0, 0, 0, 0		;4-byte	first sector of data section
						
dirsec:		db	0, 0, 0, 0		;4-byte	current sector of root directory
dirptr:		dw	0			;2-byte pointer in directory data
						;32-byte directory structure
;dirname:	dw	0, 0, 0, 0		;8-byte
;dirext:		db 0, 0, 0		;3-byte
;dirattr:	db	0			;1-byte
;dirreserved:	db	0			;1-byte
;dirdatetime:	db	0, 0, 0, 0, 0, 0, 0	;7-byte
;dirclusthi:	dw	0			;2-byte (always 0 for FAT16)
;dirwritetd:	dw	0, 0			;4-byte write time/date
;dircluster:	dw	0			;2-byte first cluster of data
;dirfilesize:	dw	0, 0			;4-byte size of file in bytes
			
const1:		db	1, 0, 0, 0		;4-byte const1
const128:	db	128, 0, 0, 0
var32:		dw	0, 0
var16:		dw	0, 0
var8:		dw	0, 0
			
dirpattern:	db	"DISK00??DSK"	;
;allpattern:	db	"???????????"	;
;kilopattern:	db	"KILO????C??"	;

;
; file related data
;
firstclust:	dw 0				;2-byte first cluster of file
filesize:	dw 0, 0				;4-byte length of file
currpos:	dw 0, 0	
	
fatsector:	dw 0, 0				;4-byte actual FAT sector read
lastfatsec:	dw $ffff, $ffff			;4-byte last read FAT sector
lastdatsec:	dw $ffff, $ffff			;4-byte last read data sector
datsec:		dw 0, 0				;4-byte current data sector read
curclus:	dw 0				;2-byte current cluster
bytes2read:	dw 0				;2-byte remaining bytes in sector to read
secs2read:	db 0				;1-byte sectors to read in cluster
bytesavail:	dw 0, 0				;4-byte bytes still available in file
fbytesread:	dw 0				;2-byte bytes read during fread
freadbytes:	dw 0, 0				;4-byte
fbuffer:	dw 0				;2-byte buffer data to be copied to
datptr:		dw 0				;2-byte pointer into data sector
fstatus:	db 0				;1-byte status of operation
fseeklen:	dw 0, 0				;4-byte length of fseek
fsecmask:	db 0				;1-byte mask for sector in fseek
isdirty:	db 0				;1-byte flag if data sector is dirty and need to be written to disk