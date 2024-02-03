;
;		RunCPM - Execute 8bit CP/M applications on modern computers
;		Copyright (c) 2016 - Marcelo Dantas
;
;		Extensive debugging/testing by Tom L. Burnett
;		Debugging/testing and new features by Krzysztof Klis
;
; EXIT - Calls to BIOS to terminate RunCPM
	org	0100h
;
BDOS	equ	0005h
BIOS	equ	0001h
;
	mvi	c,9
	lxi	d,MSG
	call	BDOS
;
	lhld	BIOS
	dcx	h
	dcx	h
	dcx	h
	pchl
;
MSG	db	'Terminating RunCPM.',0Dh,0Ah,'$'
;
