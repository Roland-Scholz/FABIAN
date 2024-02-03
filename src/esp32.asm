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