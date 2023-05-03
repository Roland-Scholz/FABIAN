conin		equ 0f209h
conout		equ 0f20ch	
		jr	shardStart
		
shardeye:	defm	"SHARD           "
vers:		defw	8 
mode:		defw	0
id4:		defw	0
id5:		defw	0
id6:		defw	0
id7:		defw	0
		defw	0
		defw	0
		jp	shout 
		jp	shbin 
        	jp	shbout 
		jp	shiocnt 
		jp	shend 
		jp	shsinf 
		jp	shsacc 
		defw 	0
limit:		defw 	0ffffh
		defw	0
		defw	0
		defw	0
		defw	0
		defw	0
		defw	0

shardStart:	ld	hl, shardeye
		jp	0141Eh

shout:		ret
shbin:		ret
shbout:		ret


;          Eingang:         A     Kanalnummer (0...31) 
;                           BC    1 
;          Ausgang:         BC    Kanaltyp 
; 
;          Zweck:           Informiert EUMEL-0, welche IO für den angegebenen Kanal
;                           sinnvoll ist. Die Rückmeldung in BC wird bitweise interpre­
;                           tiert: 
; 
;                           Bit 0 gesetzt  <=>      'inputinterrupt' kann kommen. 
;                           Bit 1 gesetzt  <=>      OUTPUT ist sinnvoll. 
;                           Bit 2 gesetzt  <=>      BLOCKIN ist sinnvoll. 
;                           Bit 3 gesetzt  <=>      BLOCKOUT ist sinnvol. 
;                           Bit 4 gesetzt  <=>      IOCONTROL "format" ist sinn­
;                                                   voll. 
;						   
;     #dx("IOCONTROL ""frout""")##goalpage("frout")# 
; 
;          Eingang:         A     Kanalnummer (1...15) 
;                           BC    2 
;          Ausgang:         BC    Anzahl Zeichen, die nächster OUTPUT übernimmt 
;                           C-Flag gesetzt <=> Puffer leer 
; 
;          Zweck:           Liefert Information über die Belegung des Puffers. Diese
;                           Information wird von EUMEL-0 zum Scheduling benutzt. 
; 
;          Achtung:         #on("i")#Wenn EUMEL-0 längere Zeit kein OUTPUT gemacht hat,
;                           muß irgendwann BC > 49 gemeldet werden.#off("i")# 
; 
;          Hinweis:         Unter Berücksichtigung des oben Gesagten darf "gelogen"
;                           werden. Man kann z.B. immer 50 in BC zurückmelden, muß
;                           dann aber schlechtere Nutzung der CPU bei Multi-User-
;                           Systemen in Kauf nehmen. 
; 
;                           Falls auf dem angegebenen Kanal ein Drucker mit eigenem
;                           Puffer über Parallelschnittstelle angeschlossen ist (siehe
;                           S.#topage("druck")#) und man auf einen SHard-internen Puffer verzichtet hat,
;                           sollte bei 'Druckerpuffer voll' 0 in BC und 'NC' zurückge­
;                           meldet werden. Wenn aber Zeichen übernommen werden
;                           können, sollte 50 in BC und 'C-Flag gesetzt' gemeldet
;                           werden. 
; 
;          Vorschlag:       Falls der Kanal nicht existiert oder nicht für Stream-IO zur
;                           Verfügung steht, sollten 200 in BC und C-Flag gesetzt
;                           zurückgemeldet werden. 

shiocnt:	push	af		;save channel-nr
		ld	a, c
		dec	a
		rlca
		ld	c, a
		ld	hl, iotab
		add	hl, bc
		ld	a, (hl)
		inc	hl
		ld	h, (hl)
		ld	l, a
		jp	(HL)
			
;--------------------------------------------------------------
iotyp:		pop	af		;channel
		xor	a
		jr	NZ, iotyp1	;channel <> 0
		ld	BC, 12		;blockio
		ret
iotyp1:		ld	BC, 2
		ret

;--------------------------------------------------------------
iofrout:	pop	af
		cp	1
		jr	NZ, iofrout1
		ld	BC, 50
		ccf
		ret
iofrout1:	ld	BC, 200
		ccf
		ret
		
;--------------------------------------------------------------
ioweiter:	ret
;--------------------------------------------------------------
iosize:
;--------------------------------------------------------------
ioformat:
;--------------------------------------------------------------
iounknown:	pop	AF
		ret
	
iotab:		defw	iotyp
		defw	iofrout
		defw	iounknown
		defw	ioweiter
		defw	iosize
		defw	iounknown
		defw	ioformat
		
shend:		ret
shsinf:		ret
shsacc:		ret
	
		
opend:		call	getDiskno
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
		
		call	serin
		cp	'A'
		ret	NZ

		call	gettext
		ret


closedisk:	call	getDiskno
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
		
		call	serin
		ret
		
		
getDiskno:	call	conin
		cp	'0'
		ret	C
		cp	'9'+1
		ccf
		ret

gettext:	;ld	hl, line
gettext1:	call	conin
		call	serout
		ld	c, a
		call	conout
		cp	13
		jr	NZ, gettext1
		ret
		




;--------------------------------------------------------------
; read sector 
; diskno, track, sector, dmaad
;--------------------------------------------------------------
readsec:		
		ld	a, 'R'		;read
		call	serout
		ld	a, (diskno)	;disk 0
		call	serout
		ld	a, (track)	;track 2
		call	serout
		ld	a, (sector)	;sector 0
		call	serout
		
		call	serin		;check ack
		jr	C, readsec	;timeout?, retry

readsec3:		
		cp	'A'
		jr	NZ, readsec	;ack NOT OK, retry
readsec2:
		ld	hl, (dmaad)
		ld	d, 128
readsec1:	call	serinfast
		ld	(hl), a
		inc	hl
		dec	d
		jr	NZ, readsec1

		xor	a
		ret

;--------------------------------------------------------------
; write sector 
; diskno, track, sector, dmaad
;--------------------------------------------------------------
writesec:
		ld	a, 'W'		;write
		call	serout
		ld	a, (diskno)	;disk 0
		call	serout
		ld	a, (track)	;track 2
		call	serout
		ld	a, (sector)	;sector 0
		call	serout
		
		ld	b, 128
		ld	hl, (dmaad)
writesec1:	ld	a, (hl)
		inc	hl
		call	serout
		djnz	b, writesec1
		
		call	serin		;check ack
		jr	C, writesec	;timeout?, retry
		cp	a, 'A'		;ack?
		jr	NZ, writesec	;error, retry
		
		xor	a
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
		pop	AF
		out	(TRANSA), a
		ret

;--------------------------------------------------------------
; get a character in A from rs232 (2)
; 
;--------------------------------------------------------------
serin:		ld	bc, 0
serin1:		in	a, (STATB)
		and	a, 1
		jr	NZ, serin2
		djnz	b, serin1
		dec	c
		jr	NZ, serin1
		scf
		ret
serin2:		in	a, (RECB)
		ret


serinfast:	ld	a, (STATB)
		and	a, 1
		jr	Z, serinfast
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

diskno:		defb	0
track:		defb	0
sector:		defb	0
dmaad:		defw	0


;readsec:		
;		ld	a, 'R'		;read
;		call	serout
;		ld	a, (diskno)	;disk 0
;		call	serout
;		ld	a, (track)	;track 2
;		call	serout
;		ld	a, (sector)	;sector 0
;		call	serout
;		
;		call	serin		;check ack
;		jr	C, readsec	;timeout?, redo
;
;readsec3:		
;		cp	'A'
;		jr	Z, readsec2	;ack OK
;		ld	a, 1		;else return 1 (= unrecov. error)
;		ret
;readsec2:
;		ld	hl, (dmaad)
;		ld	d, 128
;readsec1:	call	serin
;		ld	(hl), a
;		inc	hl
;		dec	d
;		jr	NZ, readsec1
		
;		call	newline
;		ld	hl, (dmaad)
;		ld	b, 128
;		ld	d, 16
;readsec4:	ld	a, (hl)
;		inc	hl
;		call	printhex
;		call	space
;		dec	d
;		jr	nz, readsec5
;		ld	d, 16
;		call	newline
;readsec5:	djnz	b, readsec4

;		ld	c, 'R'
;		call	chrout
	
;		call	newline
;;		call	cmdGetSector
;		call	newline
		
;		ld	a, (seclen)
;		cp	128
;		jp	NZ, error
;	
;		ld	HL, secdata		;copy ROM to RAM from
;		ld	DE, (dmaad)		;to
;		ld	BC, 128			;length
;		ldir
