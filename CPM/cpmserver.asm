;--------------------------------------------------------------
;
;--------------------------------------------------------------
        ld      DE, codeout
        ld      HL, codein
        call    decodeBase64

        ld      HL, codeout + 1         ;print length
        ld      a, (HL)                 ;hi-byte
        call    printhex
        dec     HL                      ;lo-byte
        ld      a, (HL)
        ld      b, a
;       dec     (HL)
;       dec     (HL)
        call    printhex
        call    newline
        inc     HL
        inc     HL
outloop:
        ld      a, (HL)
        inc     HL
        call    printhex
        call    space
        dec     b
        jr      NZ, outloop

;       ld      HL, codeout + 127
;       ld      (HL), 0
;       dec     HL
;       ld      (HL), 0

        call    newline

        ld      DE, codeout
        ld      HL, codenew
        call    codeBase64


        ld      HL, codenew + 1
        ld      a, (HL)
	call	printhex
	dec	HL
	ld	b, (HL)
        ld      a, b
        call    printhex
        call    newline
        inc     HL
        inc     HL
outloop1:
        ld      a, (HL)
        inc     HL
        call    print

        djnz	outloop1
        ret

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
        add     a, 4                       ; '0' = 48 -> 52
        ret
decodeB64c:
        cp      '['
        jr      NC, decodeB64d          ; not A-Z?
        sub     'A'                     ; 'A' = 65 -> 0
        ret
decodeB64d:                             ; then a-z
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

codein:
        DW      172
        DB      "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc4OTo7PD0+P0BBQkNERUZHSElKS0xNTk9QUVJTVFVWV1hZWltcXV5fYGFiY2RlZmdoaWprbG1ub3BxcnN0dXZ3eHl6e3x9fn8="

codeout:
        DW      0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0               ; dummy-bytes

codenew:
        DW      0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0, 0, 0, 0, 0, 0, 0, 0
        DW      0               ; dummy-bytes

; 00: Transmit  Receive Data
; 01: Reset     Status
; 10: Command   Register
; 11: Control   Register

;RECEIVE:       EQU     0
;TRANSM:        EQU     0
;STATUS:        EQU     1
;RESET: EQU     1
;COMMAND:       EQU     2
;CONTROL:       EQU     3
;
;start:
;;      inr     d
;;      mov     a,d
;;      out     0
;;loop
;;      inx     b
;;      mov     a,b
;;      ora     c
;;      jnz     loop
;;      jmp     start   ;13 bytes
;
;       DB      0,0,0,0,0,0,0,0
;       DB      0,0,0,0,0,0,0,0
;       DB      0,0,0,0,0,0,0,0
;       DB      0,0,0,0,0,0,0,0
;       DB      0,0,0,0,0,0,0,0
;       DB      0,0,0,0,0,0,0,0
;       DB      0,0,0,0,0,0,0,0
;       DB      0,0,0,0,0,0,0,0
;       DB      0,0,0,0,0,0,0,0
;       DB      0,0,0,0,0,0,0,0
;
;       ld      a, 10h
;       out     (CONTROL), a
;       ld      a, 03h
;       ld      d, a
;       out     (COMMAND), a
;
;loop1:
;       ld      a, 'A'
;       out     (TRANSM), a
;
;       ld      a, d            ;toggle DTR
;       xor     01h
;       ld      d, a
;       out     (COMMAND), a
;
;loop:
;       inc     bc
;       ld      a, b
;       or      c
;       jp      NZ,loop
;       jp      loop1