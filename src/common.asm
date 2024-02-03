C_XON		equ	17
C_XOFF		equ	19

;--------------------------------------------------------------
;
;--------------------------------------------------------------
copystr:
		ld	a, (HL)
		or	a
		ret	Z
		ld	(DE), a
		inc	HL
		inc	DE
		jr	copystr

;--------------------------------------------------------------
;
;--------------------------------------------------------------
printstr:	
		xor	a
		add	a, (HL)
		ret	Z
		call	chrouta
		inc	HL
		jr	printstr

;--------------------------------------------------------------
;
;--------------------------------------------------------------
space:
		push	bc
		ld	c, 32
		call	chrout
		pop	bc
		ret
		
;--------------------------------------------------------------
;
;--------------------------------------------------------------
newline:
		push	bc
		ld	c, 13
		call	chrout
		ld	c, 10
		call	chrout
		pop	bc
		ret
		
		
;--------------------------------------------------------------
; get a character in A from rs232 (2)
; 
;--------------------------------------------------------------
chrin:
		in	a, (STATB)
		and	a, 1
		jr	Z, chrin
;		in	a, (RECA)
		in	a, (RECB)
		ret
		
		
;--------------------------------------------------------------
; output a character in A over rs232 (2) honour XON/XOFF
;--------------------------------------------------------------
chrouta:
		push	bc
		ld	c, a
		call	chrout
		pop	bc
		ret

;--------------------------------------------------------------
; output a character in C over rs232 (2) honour XON/XOFF
;--------------------------------------------------------------		
chrout:
		push	AF
		
;		ld	a, 40h			
;		out	(COMMB), a		;RESET ERROR
		
		in	a, (STATB)
		and	a, 1
		jr	Z, chrout1
		in	a, (RECB)
		cp	C_XOFF
		jr	NZ, chrout1
		
chrout2:	in	a, (STATB)
		and	a, 1
		jr	Z, chrout2
		in	a, (RECB)
		cp	C_XON
		jr	NZ, chrout2

chrout1:	in	a, (STATB)
		and	a, 4
		jr	Z, chrout1
		ld	a, c
		out	(TRANSB), a
		pop	AF
		ret	

				
;--------------------------------------------------------------
; get a character in A from rs232 (1)
; 
;--------------------------------------------------------------
serin:
;		ld	a, 40h			
;		out	(COMMA), a		;RESET ERROR
		
		in	a, (STATA)
		and	a, 1
		jr	Z, serin
		in	a, (RECA)
		ret


;--------------------------------------------------------------
; output a character in C over rs232 (1)
; 
;--------------------------------------------------------------
serout:
		push	AF
serout1:	in	a, (STATA)
		and	a, 4
		jr	Z, serout1
		ld	a, c
		out	(TRANSA), a
		pop	AF
		ret


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
;print:
		push    BC
		ld      c, a
		call    chrout
		pop     BC
		ret

;--------------------------------------------------------------
;
;--------------------------------------------------------------
printstack:	push	hl
		ld	hl, 0
		add	hl, sp
		call	printadr
		pop	hl
		ret
		
;--------------------------------------------------------------
;
;--------------------------------------------------------------
getupper:
		call	chrin
		cp	'a'
		ret	C
		sub	32
		ret
		
;--------------------------------------------------------------
;
;--------------------------------------------------------------
printadr:	ld	a, h
		call	printhex
		ld	a, l
		call	printhex
		jp	space		
;--------------------------------------------------------------
;	(de, Carry) = (de) - (hl)
;--------------------------------------------------------------
sbc32:		push	bc
		push	de
		push	hl
		
		or	a				;clear carry
		ld	b, 4				;sbc 4 bytes
sbc32a:		ld	a, (de)
		sbc	(hl)
		ld	(de), a
		inc	de
		inc	hl
		djnz	sbc32a
		
		pop	hl
		pop	de
		pop	bc
		ret

;--------------------------------------------------------------
;	Z = (DE == HL)
;--------------------------------------------------------------
equal32:	push	bc
		push	de
		push	hl
		
		ld	b, 4				;cmp 4 bytes
equal32a:	ld	a, (de)
		cp	a, (hl)
		jr	NZ, equal32b
		inc	de
		inc	hl
		djnz	equal32a
		
equal32b:	pop	hl
		pop	de
		pop	bc
		ret

;--------------------------------------------------------------
;	Carry = (de) - (hl)
;--------------------------------------------------------------
cmp32:		push	bc
		push	de
		push	hl
		
		or	a				;clear carry
		ld	b, 4				;cmp 4 bytes
cmp32a:		ld	a, (de)
		sbc	a, (hl)
		inc	de
		inc	hl
		djnz	cmp32a
		
		pop	hl
		pop	de
		pop	bc
		ret
		
;--------------------------------------------------------------
;	(de) = (hl) + (de)
;--------------------------------------------------------------
add32:		push	af
		push	bc
		push	de
		push	hl
		
		or	a				;clear carry
		ld	b, 4				;add 4 bytes
add32a:		ld	a, (de)
		adc	(hl)
		ld	(de), a
		inc	hl
		inc	de
		djnz	add32a
		
		pop	hl
		pop	de
		pop	bc
		pop	af
		ret
	
;--------------------------------------------------------------
;	(de) = (hl)
;--------------------------------------------------------------
copy32:		push	bc
		push	de
		push	hl
	
		ld	bc, 4
		ldir
		
		pop	hl
		pop	de
		pop	bc
		ret

;--------------------------------------------------------------
; are all 4 bytes hl is pointing to zero?
;--------------------------------------------------------------
isZero32:	push	bc
		push	hl
		xor	a
		ld	b, 4
isZero32a:	or	(hl)
		jr	NZ, isZero32b
		inc	hl
		djnz	isZero32a
isZero32b:	pop	hl
		pop	bc
		ret
		
;--------------------------------------------------------------	
;
;	(DE) = 4 x zeros
;--------------------------------------------------------------
clear32:	push	af
		push	bc
		push	de
		xor	a
		ld	b, 4
clear32a:	ld	(de), a
		inc	de
		djnz	clear32a
		pop	de
		pop	bc
		pop	af
		ret

;--------------------------------------------------------------
;; multiply DE and BC
;; DE is equivalent to the number in the top row in our algorithm
;; and BC is equivalent to the number in the bottom row in our algorithm
;--------------------------------------------------------------
mul16:
		ld 	a, 16				; this is the number of bits of the number to process
		ld 	hl, 0				; HL is updated with the partial result, and at the end it will hold 
							; the final result.
mul16loop:			
		srl	b			
		rr	c       			;; divide BC by 2 and shifting the state of bit 0 into the carry
							;; if carry = 0, then state of bit 0 was 0, (the rightmost digit was 0) 
							;; if carry = 1, then state of bit 1 was 1. (the rightmost digit was 1)
							;; if rightmost digit was 0, then the result would be 0, and we do the add.
							;; if rightmost digit was 1, then the result is DE and we do the add.
		jr	nc, mul16noadd	
		
							;; will get to here if carry = 1        
		add	hl, de   

mul16noadd:
    ;; at this point BC has already been divided by 2

		ex	de,	hl 			;; swap DE and HL
		add	hl, hl				;; multiply DE by 2
		ex	de,	hl 			;; swap DE and HL

    ;; at this point DE has been multiplied by 2
    
		dec	a
		jr	nz, mul16loop			;; process more bits
		ret
