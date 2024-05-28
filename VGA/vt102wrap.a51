		$NOMOD51
		$INCLUDE (89S52.MCU)
;===============================================	
; adjust base for RAM or ROM version
; RAM: 02000h
; ROM: 00000h
;===============================================	
base		equ	02000h
vector		equ	base
psw_init	equ	0		;value for psw (which reg bank to use)
dnld_parm	equ 	10h		;block of 16 bytes for download
stack		equ	50h		;location of the stack
dpl		equ	dp0l
dph		equ	dp0h
monstart	equ	0

		$include (vt102.a51)
		END