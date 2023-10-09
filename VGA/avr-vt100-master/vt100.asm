;--------------------------------------------------------
; File Created by SDCC : free open source ISO C Compiler 
; Version 4.3.0 #14184 (MINGW64)
;--------------------------------------------------------
	.module vt100
	.optsdcc -mmcs51 --model-small
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _spf
	.globl __st_escape
	.globl __st_esc_right_br
	.globl __st_esc_left_br
	.globl __st_command_arg
	.globl __vt100_putc
	.globl __vt100_drawCursor
	.globl __vt100_move
	.globl _abs
	.globl __vt100_scroll
	.globl __vt100_clearLines
	.globl _VT100_CURSOR_Y
	.globl __vt100_resetScroll
	.globl __vt100_reset
	.globl _CY
	.globl _AC
	.globl _F0
	.globl _RS1
	.globl _RS0
	.globl _OV
	.globl _FL
	.globl _P
	.globl _TF2
	.globl _EXF2
	.globl _RCLK
	.globl _TCLK
	.globl _EXEN2
	.globl _TR2
	.globl _C_T2
	.globl _CP_RL2
	.globl _T2CON_7
	.globl _T2CON_6
	.globl _T2CON_5
	.globl _T2CON_4
	.globl _T2CON_3
	.globl _T2CON_2
	.globl _T2CON_1
	.globl _T2CON_0
	.globl _PT2
	.globl _PS
	.globl _PT1
	.globl _PX1
	.globl _PT0
	.globl _PX0
	.globl _RD
	.globl _WR
	.globl _T1
	.globl _T0
	.globl _INT1
	.globl _INT0
	.globl _TXD
	.globl _RXD
	.globl _P3_7
	.globl _P3_6
	.globl _P3_5
	.globl _P3_4
	.globl _P3_3
	.globl _P3_2
	.globl _P3_1
	.globl _P3_0
	.globl _EA
	.globl _ET2
	.globl _ES
	.globl _ET1
	.globl _EX1
	.globl _ET0
	.globl _EX0
	.globl _P2_7
	.globl _P2_6
	.globl _P2_5
	.globl _P2_4
	.globl _P2_3
	.globl _P2_2
	.globl _P2_1
	.globl _P2_0
	.globl _SM0
	.globl _SM1
	.globl _SM2
	.globl _REN
	.globl _TB8
	.globl _RB8
	.globl _TI
	.globl _RI
	.globl _T2EX
	.globl _T2
	.globl _P1_7
	.globl _P1_6
	.globl _P1_5
	.globl _P1_4
	.globl _P1_3
	.globl _P1_2
	.globl _P1_1
	.globl _P1_0
	.globl _TF1
	.globl _TR1
	.globl _TF0
	.globl _TR0
	.globl _IE1
	.globl _IT1
	.globl _IE0
	.globl _IT0
	.globl _P0_7
	.globl _P0_6
	.globl _P0_5
	.globl _P0_4
	.globl _P0_3
	.globl _P0_2
	.globl _P0_1
	.globl _P0_0
	.globl _B
	.globl _A
	.globl _ACC
	.globl _PSW
	.globl _TH2
	.globl _TL2
	.globl _RCAP2H
	.globl _RCAP2L
	.globl _T2MOD
	.globl _T2CON
	.globl _IP
	.globl _P3
	.globl _IE
	.globl _P2
	.globl _SBUF
	.globl _SCON
	.globl _P1
	.globl _TH1
	.globl _TH0
	.globl _TL1
	.globl _TL0
	.globl _TMOD
	.globl _TCON
	.globl _PCON
	.globl _DPH
	.globl _DPL
	.globl _SP
	.globl _P0
	.globl _vga_init
	.globl _vga_drawChar
	.globl _vga_setBackColor
	.globl _vga_setFrontColor
	.globl _vga_fillRect
	.globl _vga_setScrollStart
	.globl _vga_setScrollMargins
	.globl _putchar
	.globl _getchar
	.globl __st_esc_question
	.globl __st_esc_sq_bracket
	.globl __st_esc_hash
	.globl __st_idle
	.globl _vt100_init
	.globl _vt100_putc
	.globl _vt100_puts
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
	.area RSEG    (ABS,DATA)
	.org 0x0000
_P0	=	0x0080
_SP	=	0x0081
_DPL	=	0x0082
_DPH	=	0x0083
_PCON	=	0x0087
_TCON	=	0x0088
_TMOD	=	0x0089
_TL0	=	0x008a
_TL1	=	0x008b
_TH0	=	0x008c
_TH1	=	0x008d
_P1	=	0x0090
_SCON	=	0x0098
_SBUF	=	0x0099
_P2	=	0x00a0
_IE	=	0x00a8
_P3	=	0x00b0
_IP	=	0x00b8
_T2CON	=	0x00c8
_T2MOD	=	0x00c9
_RCAP2L	=	0x00ca
_RCAP2H	=	0x00cb
_TL2	=	0x00cc
_TH2	=	0x00cd
_PSW	=	0x00d0
_ACC	=	0x00e0
_A	=	0x00e0
_B	=	0x00f0
;--------------------------------------------------------
; special function bits
;--------------------------------------------------------
	.area RSEG    (ABS,DATA)
	.org 0x0000
_P0_0	=	0x0080
_P0_1	=	0x0081
_P0_2	=	0x0082
_P0_3	=	0x0083
_P0_4	=	0x0084
_P0_5	=	0x0085
_P0_6	=	0x0086
_P0_7	=	0x0087
_IT0	=	0x0088
_IE0	=	0x0089
_IT1	=	0x008a
_IE1	=	0x008b
_TR0	=	0x008c
_TF0	=	0x008d
_TR1	=	0x008e
_TF1	=	0x008f
_P1_0	=	0x0090
_P1_1	=	0x0091
_P1_2	=	0x0092
_P1_3	=	0x0093
_P1_4	=	0x0094
_P1_5	=	0x0095
_P1_6	=	0x0096
_P1_7	=	0x0097
_T2	=	0x0090
_T2EX	=	0x0091
_RI	=	0x0098
_TI	=	0x0099
_RB8	=	0x009a
_TB8	=	0x009b
_REN	=	0x009c
_SM2	=	0x009d
_SM1	=	0x009e
_SM0	=	0x009f
_P2_0	=	0x00a0
_P2_1	=	0x00a1
_P2_2	=	0x00a2
_P2_3	=	0x00a3
_P2_4	=	0x00a4
_P2_5	=	0x00a5
_P2_6	=	0x00a6
_P2_7	=	0x00a7
_EX0	=	0x00a8
_ET0	=	0x00a9
_EX1	=	0x00aa
_ET1	=	0x00ab
_ES	=	0x00ac
_ET2	=	0x00ad
_EA	=	0x00af
_P3_0	=	0x00b0
_P3_1	=	0x00b1
_P3_2	=	0x00b2
_P3_3	=	0x00b3
_P3_4	=	0x00b4
_P3_5	=	0x00b5
_P3_6	=	0x00b6
_P3_7	=	0x00b7
_RXD	=	0x00b0
_TXD	=	0x00b1
_INT0	=	0x00b2
_INT1	=	0x00b3
_T0	=	0x00b4
_T1	=	0x00b5
_WR	=	0x00b6
_RD	=	0x00b7
_PX0	=	0x00b8
_PT0	=	0x00b9
_PX1	=	0x00ba
_PT1	=	0x00bb
_PS	=	0x00bc
_PT2	=	0x00bd
_T2CON_0	=	0x00c8
_T2CON_1	=	0x00c9
_T2CON_2	=	0x00ca
_T2CON_3	=	0x00cb
_T2CON_4	=	0x00cc
_T2CON_5	=	0x00cd
_T2CON_6	=	0x00ce
_T2CON_7	=	0x00cf
_CP_RL2	=	0x00c8
_C_T2	=	0x00c9
_TR2	=	0x00ca
_EXEN2	=	0x00cb
_TCLK	=	0x00cc
_RCLK	=	0x00cd
_EXF2	=	0x00ce
_TF2	=	0x00cf
_P	=	0x00d0
_FL	=	0x00d1
_OV	=	0x00d2
_RS0	=	0x00d3
_RS1	=	0x00d4
_F0	=	0x00d5
_AC	=	0x00d6
_CY	=	0x00d7
;--------------------------------------------------------
; overlayable register banks
;--------------------------------------------------------
	.area REG_BANK_0	(REL,OVR,DATA)
	.ds 8
;--------------------------------------------------------
; overlayable bit register bank
;--------------------------------------------------------
	.area BIT_BANK	(REL,OVR,DATA)
bits:
	.ds 1
	b0 = bits[0]
	b1 = bits[1]
	b2 = bits[2]
	b3 = bits[3]
	b4 = bits[4]
	b5 = bits[5]
	b6 = bits[6]
	b7 = bits[7]
;--------------------------------------------------------
; internal ram data
;--------------------------------------------------------
	.area DSEG    (DATA)
_vga_color:
	.ds 1
_scroll_start:
	.ds 1
_scroll_top:
	.ds 1
_scroll_bottom:
	.ds 1
_term:
	.ds 28
_buf:
	.ds 32
;--------------------------------------------------------
; overlayable items in internal ram
;--------------------------------------------------------
;--------------------------------------------------------
; Stack segment in internal ram
;--------------------------------------------------------
	.area SSEG
__start__stack:
	.ds	1

;--------------------------------------------------------
; indirectly addressable internal ram data
;--------------------------------------------------------
	.area ISEG    (DATA)
;--------------------------------------------------------
; absolute internal ram data
;--------------------------------------------------------
	.area IABS    (ABS,DATA)
	.area IABS    (ABS,DATA)
;--------------------------------------------------------
; bit data
;--------------------------------------------------------
	.area BSEG    (BIT)
;--------------------------------------------------------
; paged external ram data
;--------------------------------------------------------
	.area PSEG    (PAG,XDATA)
;--------------------------------------------------------
; uninitialized external ram data
;--------------------------------------------------------
	.area XSEG    (XDATA)
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area XABS    (ABS,XDATA)
;--------------------------------------------------------
; initialized external ram data
;--------------------------------------------------------
	.area XISEG   (XDATA)
	.area HOME    (CODE)
	.area GSINIT0 (CODE)
	.area GSINIT1 (CODE)
	.area GSINIT2 (CODE)
	.area GSINIT3 (CODE)
	.area GSINIT4 (CODE)
	.area GSINIT5 (CODE)
	.area GSINIT  (CODE)
	.area GSFINAL (CODE)
	.area CSEG    (CODE)
;--------------------------------------------------------
; interrupt vector
;--------------------------------------------------------
	.area HOME    (CODE)
__interrupt_vect:
	ljmp	__sdcc_gsinit_startup
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area HOME    (CODE)
	.area GSINIT  (CODE)
	.area GSFINAL (CODE)
	.area GSINIT  (CODE)
	.globl __sdcc_gsinit_startup
	.globl __sdcc_program_startup
	.globl __start__stack
	.globl __mcs51_genXINIT
	.globl __mcs51_genXRAMCLEAR
	.globl __mcs51_genRAMCLEAR
	.area GSFINAL (CODE)
	ljmp	__sdcc_program_startup
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME    (CODE)
	.area HOME    (CODE)
__sdcc_program_startup:
	ljmp	_main
;	return from main will return to caller
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CSEG    (CODE)
;------------------------------------------------------------
;Allocation info for local variables in function 'vga_init'
;------------------------------------------------------------
;	vga.h:37: void vga_init(void) {
;	-----------------------------------------
;	 function vga_init
;	-----------------------------------------
_vga_init:
	ar7 = 0x07
	ar6 = 0x06
	ar5 = 0x05
	ar4 = 0x04
	ar3 = 0x03
	ar2 = 0x02
	ar1 = 0x01
	ar0 = 0x00
;	vga.h:39: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'vga_drawChar'
;------------------------------------------------------------
;y                         Allocated to stack - _bp -3
;c                         Allocated to stack - _bp -4
;x                         Allocated to registers r7 
;mem                       Allocated to registers r7 r6 r5 
;------------------------------------------------------------
;	vga.h:42: void vga_drawChar(uint8_t x, uint8_t y, uint8_t c) {
;	-----------------------------------------
;	 function vga_drawChar
;	-----------------------------------------
_vga_drawChar:
	push	_bp
	mov	_bp,sp
	mov	r7,dpl
;	vga.h:46: mem += (x + y * VGA_WIDTH) << 1;
	mov	r6,#0x00
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	ar4,@r0
	mov	r5,#0x00
	push	ar7
	push	ar6
	push	ar4
	push	ar5
	mov	dptr,#0x0050
	lcall	__mulint
	mov	r4,dpl
	mov	r5,dph
	dec	sp
	dec	sp
	pop	ar6
	pop	ar7
	mov	a,r4
	add	a,r7
	mov	r7,a
	mov	a,r5
	addc	a,r6
	mov	r6,a
	mov	a,r7
	add	a,r7
	mov	r7,a
	mov	a,r6
	rlc	a
	add	a,#0x80
	mov	r6,a
	mov	r5,#0x00
;	vga.h:48: *(mem) = c;
	mov	dpl,r7
	mov	dph,r6
	mov	b,r5
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	lcall	__gptrput
;	vga.h:49: mem++;
	inc	r7
	cjne	r7,#0x00,00103$
	inc	r6
00103$:
;	vga.h:50: *(mem) = vga_color;
	mov	dpl,r7
	mov	dph,r6
	mov	b,r5
	mov	a,_vga_color
	lcall	__gptrput
;	vga.h:51: }
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'vga_setBackColor'
;------------------------------------------------------------
;col                       Allocated to registers r7 
;------------------------------------------------------------
;	vga.h:53: void vga_setBackColor(uint8_t col) {
;	-----------------------------------------
;	 function vga_setBackColor
;	-----------------------------------------
_vga_setBackColor:
	mov	r7,dpl
;	vga.h:56: vga_color &= 0xf0;
	anl	_vga_color,#0xf0
;	vga.h:57: vga_color |= (col & 0x0f);
	anl	ar7,#0x0f
	mov	a,r7
	orl	_vga_color,a
;	vga.h:59: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'vga_setFrontColor'
;------------------------------------------------------------
;col                       Allocated to registers r7 
;------------------------------------------------------------
;	vga.h:61: void vga_setFrontColor(uint8_t col) {
;	-----------------------------------------
;	 function vga_setFrontColor
;	-----------------------------------------
_vga_setFrontColor:
	mov	r7,dpl
;	vga.h:63: vga_color &= 0x0f;
	anl	_vga_color,#0x0f
;	vga.h:64: vga_color |= (col & 0xf0);
	anl	ar7,#0xf0
	mov	a,r7
	orl	_vga_color,a
;	vga.h:65: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'vga_fillRect'
;------------------------------------------------------------
;y                         Allocated to stack - _bp -3
;w                         Allocated to stack - _bp -4
;h                         Allocated to stack - _bp -5
;color                     Allocated to stack - _bp -6
;x                         Allocated to stack - _bp +1
;i                         Allocated to registers r6 
;j                         Allocated to registers r3 
;c                         Allocated to registers 
;i0                        Allocated to registers r5 
;j0                        Allocated to registers r4 
;mem                       Allocated to registers r2 r5 r7 
;sloc0                     Allocated to stack - _bp +2
;------------------------------------------------------------
;	vga.h:67: void vga_fillRect(uint8_t x, uint8_t y, uint8_t w, uint8_t h,
;	-----------------------------------------
;	 function vga_fillRect
;	-----------------------------------------
_vga_fillRect:
	push	_bp
	mov	_bp,sp
	push	dpl
	inc	sp
	inc	sp
	inc	sp
;	vga.h:77: for (i = y, i0 = y + h; i < i0; i++) {
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	ar6,@r0
	mov	a,_bp
	add	a,#0xfb
	mov	r0,a
	mov	a,@r0
	add	a,r6
	mov	r5,a
	mov	r0,_bp
	inc	r0
	mov	a,_bp
	add	a,#0xfc
	mov	r1,a
	mov	a,@r1
	add	a,@r0
	mov	r4,a
00107$:
	clr	c
	mov	a,r6
	subb	a,r5
	jc	00133$
	ljmp	00109$
00133$:
;	vga.h:78: mem = 0x8000 + ((i * VGA_WIDTH) << 1);
	mov	ar2,r6
	mov	r3,#0x00
	push	ar6
	push	ar5
	push	ar4
	push	ar2
	push	ar3
	mov	dptr,#0x0050
	lcall	__mulint
	mov	r2,dpl
	mov	r3,dph
	dec	sp
	dec	sp
	pop	ar4
	pop	ar5
	pop	ar6
	mov	a,r2
	add	a,r2
	mov	r2,a
	mov	a,r3
	rlc	a
	add	a,#0x80
	mov	r3,a
	mov	r0,_bp
	inc	r0
	inc	r0
	mov	@r0,ar2
	inc	r0
	mov	@r0,ar3
	inc	r0
	mov	@r0,#0x00
;	vga.h:79: for (j = x, j0 = x + w; j < j0; j++) {
	mov	r0,_bp
	inc	r0
	mov	ar3,@r0
00104$:
	clr	c
	mov	a,r3
	subb	a,r4
	jnc	00108$
;	vga.h:80: *mem = 1;
	push	ar5
	mov	r0,_bp
	inc	r0
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	mov	a,#0x01
	lcall	__gptrput
;	vga.h:81: mem++;
	mov	r0,_bp
	inc	r0
	inc	r0
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar7,@r0
;	vga.h:82: *mem = 1;
	mov	dpl,r2
	mov	dph,r5
	mov	b,r7
	mov	a,#0x01
	lcall	__gptrput
;	vga.h:83: mem++;
	mov	r0,_bp
	inc	r0
	inc	r0
	add	a,r2
	mov	@r0,a
	clr	a
	addc	a,r5
	inc	r0
	mov	@r0,a
	inc	r0
	mov	@r0,ar7
;	vga.h:79: for (j = x, j0 = x + w; j < j0; j++) {
	inc	r3
	pop	ar5
	sjmp	00104$
00108$:
;	vga.h:77: for (i = y, i0 = y + h; i < i0; i++) {
	inc	r6
	ljmp	00107$
00109$:
;	vga.h:87: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'vga_setScrollStart'
;------------------------------------------------------------
;start                     Allocated to registers 
;------------------------------------------------------------
;	vga.h:89: void vga_setScrollStart(uint8_t start) {
;	-----------------------------------------
;	 function vga_setScrollStart
;	-----------------------------------------
_vga_setScrollStart:
	mov	_scroll_start,dpl
;	vga.h:91: scroll_start = start;
;	vga.h:92: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'vga_setScrollMargins'
;------------------------------------------------------------
;bottom                    Allocated to stack - _bp -3
;top                       Allocated to registers 
;------------------------------------------------------------
;	vga.h:94: void vga_setScrollMargins(uint8_t top, uint8_t bottom) {
;	-----------------------------------------
;	 function vga_setScrollMargins
;	-----------------------------------------
_vga_setScrollMargins:
	push	_bp
	mov	_bp,sp
	mov	_scroll_top,dpl
;	vga.h:97: scroll_bottom = bottom;
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	_scroll_bottom,@r0
;	vga.h:98: }
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'putchar'
;------------------------------------------------------------
;c                         Allocated to registers r6 r7 
;------------------------------------------------------------
;	vt100.c:10: int putchar (int c) {
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
_putchar:
	mov	r6,dpl
	mov	r7,dph
;	vt100.c:12: while (!TI) /* assumes UART is initialized */
00101$:
;	vt100.c:14: TI = 0;
;	assignBit
	jbc	_TI,00120$
	sjmp	00101$
00120$:
;	vt100.c:15: SBUF = c;
	mov	ar5,r6
	mov	_SBUF,r5
;	vt100.c:17: if ((char)c == '\n') putchar('\r');
	cjne	r5,#0x0a,00105$
	mov	dptr,#0x000d
	push	ar7
	push	ar6
	lcall	_putchar
	pop	ar6
	pop	ar7
00105$:
;	vt100.c:18: return c;
	mov	dpl,r6
	mov	dph,r7
;	vt100.c:19: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'getchar'
;------------------------------------------------------------
;	vt100.c:21: int getchar(void) {
;	-----------------------------------------
;	 function getchar
;	-----------------------------------------
_getchar:
;	vt100.c:22: while (!RI)
00101$:
;	vt100.c:24: RI=0;
;	assignBit
	jbc	_RI,00114$
	sjmp	00101$
00114$:
;	vt100.c:26: return SBUF;
	mov	r6,_SBUF
	mov	r7,#0x00
	mov	dpl,r6
	mov	dph,r7
;	vt100.c:28: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_vt100_reset'
;------------------------------------------------------------
;	vt100.c:86: void _vt100_reset(void){
;	-----------------------------------------
;	 function _vt100_reset
;	-----------------------------------------
__vt100_reset:
;	vt100.c:89: term.char_height = 1;
	mov	(_term + 0x0008),#0x01
;	vt100.c:90: term.char_width = 1;
	mov	(_term + 0x0007),#0x01
;	vt100.c:91: term.back_color = 0x00;
	mov	(_term + 0x0009),#0x00
;	vt100.c:92: term.front_color = 0xff;
	mov	(_term + 0x000a),#0xff
;	vt100.c:93: term.cursor_x = term.cursor_y = term.saved_cursor_x = term.saved_cursor_y = 0;
	mov	(_term + 0x0004),#0x00
	mov	(_term + 0x0003),#0x00
	mov	(_term + 0x0002),#0x00
	mov	(_term + 0x0001),#0x00
;	vt100.c:94: term.narg = 0;
	mov	(_term + 0x000c),#0x00
;	vt100.c:95: term.state = _st_idle;
	mov	((_term + 0x0016) + 0),#__st_idle
	mov	((_term + 0x0016) + 1),#(__st_idle >> 8)
;	vt100.c:96: term.ret_state = 0;
	clr	a
	mov	((_term + 0x001a) + 0),a
	mov	((_term + 0x001a) + 1),a
;	vt100.c:97: term.scroll_value = 0; 
	mov	(_term + 0x000b),a
;	vt100.c:98: term.scroll_start_row = 0;
	mov	(_term + 0x0005),a
;	vt100.c:99: term.scroll_end_row = VT100_HEIGHT; // outside of screen = whole screen scrollable
	mov	(_term + 0x0006),#0x18
;	vt100.c:100: term.flags.cursor_wrap = 0;
;	vt100.c:101: term.flags.origin_mode = 0; 
	mov	r0,#_term
	mov	a,@r0
	anl	a,#0xfe&0xfb
	mov	@r0,a
;	vt100.c:102: vga_setFrontColor(term.front_color);
	mov	dpl,(_term + 0x000a)
	lcall	_vga_setFrontColor
;	vt100.c:103: vga_setBackColor(term.back_color);
	mov	dpl,(_term + 0x0009)
	lcall	_vga_setBackColor
;	vt100.c:104: vga_setScrollMargins(0, 0); 
	clr	a
	push	acc
	mov	dpl,#0x00
	lcall	_vga_setScrollMargins
	dec	sp
;	vt100.c:105: vga_setScrollStart(0); 
	mov	dpl,#0x00
;	vt100.c:106: }
	ljmp	_vga_setScrollStart
;------------------------------------------------------------
;Allocation info for local variables in function '_vt100_resetScroll'
;------------------------------------------------------------
;	vt100.c:108: void _vt100_resetScroll(void){
;	-----------------------------------------
;	 function _vt100_resetScroll
;	-----------------------------------------
__vt100_resetScroll:
;	vt100.c:109: term.scroll_start_row = 0;
	mov	(_term + 0x0005),#0x00
;	vt100.c:110: term.scroll_end_row = VT100_HEIGHT;
	mov	(_term + 0x0006),#0x18
;	vt100.c:111: term.scroll_value = 0; 
;	vt100.c:112: vga_setScrollMargins(0, 0);
	clr	a
	mov	(_term + 0x000b),a
	push	acc
	mov	dpl,#0x00
	lcall	_vga_setScrollMargins
	dec	sp
;	vt100.c:113: vga_setScrollStart(0); 
	mov	dpl,#0x00
;	vt100.c:114: }
	ljmp	_vga_setScrollStart
;------------------------------------------------------------
;Allocation info for local variables in function 'VT100_CURSOR_Y'
;------------------------------------------------------------
;t                         Allocated to stack - _bp +1
;scroll_height             Allocated to stack - _bp +6
;row                       Allocated to registers r2 r4 
;sloc0                     Allocated to stack - _bp +4
;------------------------------------------------------------
;	vt100.c:118: uint16_t VT100_CURSOR_Y(struct vt100 *t){
;	-----------------------------------------
;	 function VT100_CURSOR_Y
;	-----------------------------------------
_VT100_CURSOR_Y:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
	mov	a,sp
	add	a,#0x04
	mov	sp,a
;	vt100.c:120: if(t->cursor_y < t->scroll_start_row || t->cursor_y >= t->scroll_end_row){
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r4,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x05
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r7
	lcall	__gptrget
	mov	r7,a
	clr	c
	mov	a,r4
	xrl	a,#0x80
	mov	b,r7
	xrl	b,#0x80
	subb	a,b
	jc	00103$
	mov	r0,_bp
	inc	r0
	mov	a,#0x06
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r3
	mov	dph,r5
	mov	b,r6
	lcall	__gptrget
	mov	r6,a
	clr	c
	mov	a,r4
	xrl	a,#0x80
	mov	b,r6
	xrl	b,#0x80
	subb	a,b
	jc	00104$
00103$:
;	vt100.c:121: return t->cursor_y * VT100_CHAR_HEIGHT; 
	mov	a,r4
	mov	r3,a
	rlc	a
	subb	a,acc
	mov	r5,a
	mov	dpl,r3
	mov	dph,r5
	sjmp	00107$
00104$:
;	vt100.c:124: uint16_t scroll_height = t->scroll_end_row - t->scroll_start_row;
	mov	a,r6
	rlc	a
	subb	a,acc
	mov	r5,a
	mov	a,r7
	rlc	a
	subb	a,acc
	mov	r3,a
	mov	a,r6
	clr	c
	subb	a,r7
	mov	r7,a
	mov	a,r5
	subb	a,r3
	mov	r3,a
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	@r0,ar7
	inc	r0
	mov	@r0,ar3
;	vt100.c:125: uint16_t row = t->cursor_y + t->scroll_value; 
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	@r0,ar4
	mov	a,r4
	rlc	a
	subb	a,acc
	inc	r0
	mov	@r0,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x0b
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r3
	mov	dph,r4
	mov	b,r7
	lcall	__gptrget
	mov	r3,a
	rlc	a
	subb	a,acc
	mov	r7,a
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,r3
	add	a,@r0
	mov	r3,a
	mov	a,r7
	inc	r0
	addc	a,@r0
	mov	r7,a
	mov	ar2,r3
	mov	ar4,r7
;	vt100.c:126: if(t->cursor_y + t->scroll_value >= t->scroll_end_row)
	clr	c
	mov	a,r3
	subb	a,r6
	mov	a,r7
	xrl	a,#0x80
	mov	b,r5
	xrl	b,#0x80
	subb	a,b
	jc	00102$
;	vt100.c:127: row -= scroll_height; 
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	a,r2
	clr	c
	subb	a,@r0
	mov	r2,a
	mov	a,r4
	inc	r0
	subb	a,@r0
	mov	r4,a
00102$:
;	vt100.c:136: return row * VT100_CHAR_HEIGHT; 
	mov	dpl,r2
	mov	dph,r4
00107$:
;	vt100.c:155: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_vt100_clearLines'
;------------------------------------------------------------
;start_line                Allocated to stack - _bp -4
;end_line                  Allocated to stack - _bp -6
;t                         Allocated to stack - _bp +1
;c                         Allocated to registers 
;cy                        Allocated to registers 
;sloc0                     Allocated to stack - _bp +4
;------------------------------------------------------------
;	vt100.c:157: void _vt100_clearLines(struct vt100 *t, uint16_t start_line, uint16_t end_line){
;	-----------------------------------------
;	 function _vt100_clearLines
;	-----------------------------------------
__vt100_clearLines:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
	inc	sp
;	vt100.c:158: for(int c = start_line; c <= end_line; c++){
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	ar3,@r0
	inc	r0
	mov	ar4,@r0
00103$:
	mov	ar2,r3
	mov	ar7,r4
	mov	a,_bp
	add	a,#0xfa
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,r2
	inc	r0
	mov	a,@r0
	subb	a,r7
	jnc	00116$
	ljmp	00105$
00116$:
;	vt100.c:159: uint16_t cy = t->cursor_y;
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r2
	mov	dph,r6
	mov	b,r7
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	lcall	__gptrget
	mov	@r0,a
;	vt100.c:160: t->cursor_y = c; 
	mov	ar5,r3
	mov	dpl,r2
	mov	dph,r6
	mov	b,r7
	mov	a,r5
	lcall	__gptrput
;	vt100.c:161: vga_fillRect(0, VT100_CURSOR_Y(t), VT100_SCREEN_WIDTH, VT100_CHAR_HEIGHT, 0x0000);
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	push	ar4
	push	ar3
	lcall	_VT100_CURSOR_Y
	mov	r6,dpl
	clr	a
	push	acc
	inc	a
	push	acc
	mov	a,#0x50
	push	acc
	push	ar6
	mov	dpl,#0x00
	lcall	_vga_fillRect
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	pop	ar3
	pop	ar4
;	vt100.c:162: t->cursor_y = cy;
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,@r0
	lcall	__gptrput
;	vt100.c:158: for(int c = start_line; c <= end_line; c++){
	inc	r3
	cjne	r3,#0x00,00117$
	inc	r4
00117$:
	ljmp	00103$
00105$:
;	vt100.c:167: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_vt100_scroll'
;------------------------------------------------------------
;lines                     Allocated to stack - _bp -4
;t                         Allocated to stack - _bp +1
;scroll_height             Allocated to stack - _bp +7
;scroll_start              Allocated to registers r5 r7 
;sloc0                     Allocated to stack - _bp +8
;sloc1                     Allocated to stack - _bp +4
;------------------------------------------------------------
;	vt100.c:170: void _vt100_scroll(struct vt100 *t, int16_t lines){
;	-----------------------------------------
;	 function _vt100_scroll
;	-----------------------------------------
__vt100_scroll:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
	mov	a,sp
	add	a,#0x05
	mov	sp,a
;	vt100.c:172: if(!lines) return;
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	inc	r0
	orl	a,@r0
	jnz	00102$
	ljmp	00108$
00102$:
;	vt100.c:175: uint16_t scroll_height = t->scroll_end_row - t->scroll_start_row;
	mov	r0,_bp
	inc	r0
	mov	a,#0x06
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	rlc	a
	subb	a,acc
	mov	r4,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x05
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r3
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r7,a
	mov	r5,a
	rlc	a
	subb	a,acc
	mov	r6,a
	mov	a,_bp
	add	a,#0x07
	mov	r0,a
	mov	a,r2
	clr	c
	subb	a,r5
	mov	@r0,a
	mov	a,r4
	subb	a,r6
	inc	r0
	mov	@r0,a
	mov	a,_bp
	add	a,#0x07
;	vt100.c:181: if(lines > 0){
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	clr	c
	clr	a
	subb	a,@r0
	mov	a,#(0x00 ^ 0x80)
	inc	r0
	mov	b,@r0
	xrl	b,#0x80
	subb	a,b
	jc	00123$
	ljmp	00106$
00123$:
;	vt100.c:182: _vt100_clearLines(t, t->scroll_start_row, t->scroll_start_row+lines-1); 
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	add	a,r5
	mov	r5,a
	inc	r0
	mov	a,@r0
	addc	a,r6
	mov	r6,a
	dec	r5
	cjne	r5,#0xff,00124$
	dec	r6
00124$:
	mov	a,r7
	mov	r3,a
	rlc	a
	subb	a,acc
	mov	r7,a
	push	ar5
	push	ar6
	push	ar3
	push	ar7
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_clearLines
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:184: t->scroll_value = (t->scroll_value + lines) % scroll_height;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0b
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	inc	r0
	mov	ar2,@r0
	mov	dpl,r5
	mov	dph,r4
	mov	b,r2
	lcall	__gptrget
	mov	r3,a
	rlc	a
	subb	a,acc
	mov	r7,a
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	add	a,r3
	mov	r3,a
	inc	r0
	mov	a,@r0
	addc	a,r7
	mov	r7,a
	push	ar5
	push	ar4
	push	ar2
	mov	a,_bp
	add	a,#0x07
	mov	r0,a
	mov	a,@r0
	push	acc
	inc	r0
	mov	a,@r0
	push	acc
	mov	dpl,r3
	mov	dph,r7
	lcall	__moduint
	mov	r6,dpl
	mov	r7,dph
	dec	sp
	dec	sp
	pop	ar2
	pop	ar4
	pop	ar5
	mov	dpl,r5
	mov	dph,r4
	mov	b,r2
	mov	a,r6
	lcall	__gptrput
	ljmp	00107$
00106$:
;	vt100.c:188: } else if(lines < 0){
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	inc	r0
	mov	a,@r0
	jb	acc.7,00125$
	ljmp	00107$
00125$:
;	vt100.c:189: _vt100_clearLines(t, t->scroll_end_row - lines, t->scroll_end_row - 1); 
	mov	a,r2
	add	a,#0xff
	mov	r6,a
	mov	a,r4
	addc	a,#0xff
	mov	r7,a
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,r2
	clr	c
	subb	a,@r0
	mov	r2,a
	mov	a,r4
	inc	r0
	subb	a,@r0
	mov	r4,a
	push	ar6
	push	ar7
	push	ar2
	push	ar4
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_clearLines
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:191: t->scroll_value = (scroll_height + t->scroll_value + lines) % scroll_height; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x0b
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r4,a
	rlc	a
	subb	a,acc
	mov	r3,a
	mov	a,_bp
	add	a,#0x07
	mov	r0,a
	mov	a,_bp
	add	a,#0x04
	mov	r1,a
	mov	a,r4
	add	a,@r0
	mov	@r1,a
	mov	a,r3
	inc	r0
	addc	a,@r0
	inc	r1
	mov	@r1,a
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	ar2,@r0
	inc	r0
	mov	ar4,@r0
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,r2
	add	a,@r0
	mov	r2,a
	mov	a,r4
	inc	r0
	addc	a,@r0
	mov	r4,a
	push	ar7
	push	ar6
	push	ar5
	mov	a,_bp
	add	a,#0x07
	mov	r0,a
	mov	a,@r0
	push	acc
	inc	r0
	mov	a,@r0
	push	acc
	mov	dpl,r2
	mov	dph,r4
	lcall	__moduint
	mov	r3,dpl
	mov	r4,dph
	dec	sp
	dec	sp
	pop	ar5
	pop	ar6
	pop	ar7
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,r3
	lcall	__gptrput
00107$:
;	vt100.c:196: uint16_t scroll_start = (t->scroll_start_row + t->scroll_value) * VT100_CHAR_HEIGHT; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x05
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	rlc	a
	subb	a,acc
	mov	r7,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x0b
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r3
	mov	dph,r4
	mov	b,r6
	lcall	__gptrget
	mov	r3,a
	rlc	a
	subb	a,acc
	mov	r6,a
	mov	a,r3
	add	a,r5
	mov	r5,a
	mov	a,r6
	addc	a,r7
;	vt100.c:197: vga_setScrollStart(scroll_start); 
	mov	dpl,r5
	lcall	_vga_setScrollStart
00108$:
;	vt100.c:216: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'abs'
;------------------------------------------------------------
;x                         Allocated to registers r6 r7 
;------------------------------------------------------------
;	vt100.c:218: int16_t abs(int16_t x) {
;	-----------------------------------------
;	 function abs
;	-----------------------------------------
_abs:
	mov	r6,dpl
;	vt100.c:219: if (x < 0) return -x;
	mov	a,dph
	mov	r7,a
	jnb	acc.7,00102$
	clr	c
	clr	a
	subb	a,r6
	mov	dpl,a
	clr	a
	subb	a,r7
	mov	dph,a
	ret
00102$:
;	vt100.c:220: return x;
	mov	dpl,r6
	mov	dph,r7
;	vt100.c:221: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_vt100_move'
;------------------------------------------------------------
;right_left                Allocated to stack - _bp -4
;bottom_top                Allocated to stack - _bp -6
;term                      Allocated to stack - _bp +1
;new_x                     Allocated to stack - _bp +6
;new_y                     Allocated to stack - _bp +8
;to_scroll                 Allocated to stack - _bp +4
;sloc0                     Allocated to stack - _bp +4
;------------------------------------------------------------
;	vt100.c:224: void _vt100_move(struct vt100 *term, int16_t right_left, int16_t bottom_top){
;	-----------------------------------------
;	 function _vt100_move
;	-----------------------------------------
__vt100_move:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
	mov	a,sp
	add	a,#0x06
	mov	sp,a
;	vt100.c:226: int16_t new_x = right_left + term->cursor_x; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r7,a
	rlc	a
	subb	a,acc
	mov	r6,a
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,r7
	add	a,@r0
	mov	r7,a
	mov	a,r6
	inc	r0
	addc	a,@r0
	mov	r6,a
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	@r0,ar7
	inc	r0
	mov	@r0,ar6
;	vt100.c:227: if(new_x > VT100_WIDTH){
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	clr	c
	mov	a,#0x50
	subb	a,@r0
	mov	a,#(0x00 ^ 0x80)
	inc	r0
	mov	b,@r0
	xrl	b,#0x80
	subb	a,b
	jc	00144$
	ljmp	00108$
00144$:
;	vt100.c:228: if(term->flags.cursor_wrap){
	push	ar2
	push	ar3
	push	ar4
	mov	r0,_bp
	inc	r0
	mov	ar3,@r0
	inc	r0
	mov	ar4,@r0
	inc	r0
	mov	ar5,@r0
	mov	dpl,r3
	mov	dph,r4
	mov	b,r5
	lcall	__gptrget
	pop	ar4
	pop	ar3
	pop	ar2
	jnb	acc.0,00102$
;	vt100.c:229: bottom_top += new_x / VT100_WIDTH;
	push	ar4
	push	ar3
	push	ar2
	mov	a,#0x50
	push	acc
	clr	a
	push	acc
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	lcall	__divsint
	mov	r5,dpl
	mov	r7,dph
	dec	sp
	dec	sp
	mov	a,_bp
	add	a,#0xfa
	mov	r0,a
	mov	a,r5
	add	a,@r0
	mov	@r0,a
	mov	a,r7
	inc	r0
	addc	a,@r0
	mov	@r0,a
;	vt100.c:230: term->cursor_x = new_x % VT100_WIDTH - 1;
	mov	a,#0x50
	push	acc
	clr	a
	push	acc
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	lcall	__modsint
	mov	r6,dpl
	mov	r7,dph
	dec	sp
	dec	sp
	pop	ar2
	pop	ar3
	pop	ar4
	dec	r6
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,r6
	lcall	__gptrput
	ljmp	00109$
00102$:
;	vt100.c:232: term->cursor_x = VT100_WIDTH;
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#0x50
	lcall	__gptrput
	ljmp	00109$
00108$:
;	vt100.c:234: } else if(new_x < 0){
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	inc	r0
	mov	a,@r0
	jnb	acc.7,00105$
;	vt100.c:235: bottom_top += new_x / VT100_WIDTH - 1;
	push	ar4
	push	ar3
	push	ar2
	mov	a,#0x50
	push	acc
	clr	a
	push	acc
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	lcall	__divsint
	mov	r6,dpl
	mov	r7,dph
	dec	sp
	dec	sp
	pop	ar2
	pop	ar3
	pop	ar4
	dec	r6
	cjne	r6,#0xff,00147$
	dec	r7
00147$:
	mov	a,_bp
	add	a,#0xfa
	mov	r0,a
	mov	a,r6
	add	a,@r0
	mov	@r0,a
	mov	a,r7
	inc	r0
	addc	a,@r0
	mov	@r0,a
;	vt100.c:236: term->cursor_x = VT100_WIDTH - (abs(new_x) % VT100_WIDTH) + 1; 
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	push	ar4
	push	ar3
	push	ar2
	lcall	_abs
	mov	a,#0x50
	push	acc
	clr	a
	push	acc
	lcall	__modsint
	mov	r6,dpl
	mov	r7,dph
	dec	sp
	dec	sp
	pop	ar2
	pop	ar3
	pop	ar4
	mov	a,#0x51
	clr	c
	subb	a,r6
	mov	r6,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrput
	sjmp	00109$
00105$:
;	vt100.c:238: term->cursor_x = new_x;
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	ar7,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,r7
	lcall	__gptrput
00109$:
;	vt100.c:241: if(bottom_top){
	mov	a,_bp
	add	a,#0xfa
	mov	r0,a
	mov	a,@r0
	inc	r0
	orl	a,@r0
	jnz	00148$
	ljmp	00118$
00148$:
;	vt100.c:242: int16_t new_y = term->cursor_y + bottom_top;
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r4,a
	rlc	a
	subb	a,acc
	mov	r3,a
	mov	a,_bp
	add	a,#0xfa
	mov	r0,a
	mov	a,@r0
	add	a,r4
	mov	r4,a
	inc	r0
	mov	a,@r0
	addc	a,r3
	mov	r3,a
	mov	a,_bp
	add	a,#0x08
	mov	r0,a
	mov	@r0,ar4
	inc	r0
	mov	@r0,ar3
;	vt100.c:243: int16_t to_scroll = 0;
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	clr	a
	mov	@r0,a
	inc	r0
	mov	@r0,a
;	vt100.c:248: if(new_y >= term->scroll_end_row){
	mov	r0,_bp
	inc	r0
	mov	a,#0x06
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r4,a
	mov	r2,a
	rlc	a
	subb	a,acc
	mov	r3,a
	mov	a,_bp
	add	a,#0x08
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,r2
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	mov	b,r3
	xrl	b,#0x80
	subb	a,b
	jc	00114$
;	vt100.c:251: to_scroll = (new_y - term->scroll_end_row) + 1; 
	mov	a,_bp
	add	a,#0x08
	mov	r0,a
	mov	a,@r0
	clr	c
	subb	a,r2
	mov	r2,a
	inc	r0
	mov	a,@r0
	subb	a,r3
	mov	r3,a
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,#0x01
	add	a,r2
	mov	@r0,a
	clr	a
	addc	a,r3
	inc	r0
	mov	@r0,a
;	vt100.c:253: term->cursor_y = term->scroll_end_row - 1; //new_y - to_scroll; 
	dec	r4
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,r4
	lcall	__gptrput
	sjmp	00115$
00114$:
;	vt100.c:256: } else if(new_y < term->scroll_start_row){
	mov	r0,_bp
	inc	r0
	mov	a,#0x05
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r4,a
	mov	r2,a
	rlc	a
	subb	a,acc
	mov	r3,a
	mov	a,_bp
	add	a,#0x08
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,r2
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	mov	b,r3
	xrl	b,#0x80
	subb	a,b
	jnc	00111$
;	vt100.c:257: to_scroll = (new_y - term->scroll_start_row); 
	mov	a,_bp
	add	a,#0x08
	mov	r0,a
	mov	a,@r0
	clr	c
	subb	a,r2
	mov	r2,a
	inc	r0
	mov	a,@r0
	subb	a,r3
	mov	r3,a
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	@r0,ar2
	inc	r0
	mov	@r0,ar3
;	vt100.c:258: term->cursor_y = term->scroll_start_row; //new_y - to_scroll; 
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,r4
	lcall	__gptrput
	sjmp	00115$
00111$:
;	vt100.c:263: term->cursor_y = new_y;
	mov	a,_bp
	add	a,#0x08
	mov	r0,a
	mov	ar4,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,r4
	lcall	__gptrput
00115$:
;	vt100.c:265: _vt100_scroll(term, to_scroll);
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,@r0
	push	acc
	inc	r0
	mov	a,@r0
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_scroll
	dec	sp
	dec	sp
00118$:
;	vt100.c:267: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_vt100_drawCursor'
;------------------------------------------------------------
;t                         Allocated to registers 
;------------------------------------------------------------
;	vt100.c:269: void _vt100_drawCursor(struct vt100 *t){
;	-----------------------------------------
;	 function _vt100_drawCursor
;	-----------------------------------------
__vt100_drawCursor:
;	vt100.c:274: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_vt100_putc'
;------------------------------------------------------------
;ch                        Allocated to stack - _bp -3
;t                         Allocated to stack - _bp +1
;x                         Allocated to registers r5 
;y                         Allocated to registers r6 
;------------------------------------------------------------
;	vt100.c:277: void _vt100_putc(struct vt100 *t, uint8_t ch){
;	-----------------------------------------
;	 function _vt100_putc
;	-----------------------------------------
__vt100_putc:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
;	vt100.c:280: if(ch < 0x20 || ch > 0x7e){
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	cjne	@r0,#0x20,00110$
00110$:
	jc	00101$
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	a,@r0
	add	a,#0xff - 0x7e
	jc	00112$
	ljmp	00102$
00112$:
00101$:
;	vt100.c:282: _vt100_putc(t, '0'); 
	mov	a,#0x30
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_putc
	dec	sp
;	vt100.c:283: _vt100_putc(t, 'x'); 
	mov	a,#0x78
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_putc
	dec	sp
;	vt100.c:284: _vt100_putc(t, hex[((ch & 0xf0) >> 4)]);
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	ar3,@r0
	mov	r4,#0x00
	mov	a,#0xf0
	anl	a,r3
	mov	r2,a
	clr	a
	xch	a,r2
	swap	a
	anl	a,#0x0f
	xrl	a,r2
	xch	a,r2
	anl	a,#0x0f
	xch	a,r2
	xrl	a,r2
	xch	a,r2
	jnb	acc.3,00113$
	orl	a,#0xfffffff0
00113$:
	mov	r7,a
	mov	a,r2
	add	a,#__vt100_putc_hex_131072_135
	mov	dpl,a
	mov	a,r7
	addc	a,#(__vt100_putc_hex_131072_135 >> 8)
	mov	dph,a
	clr	a
	movc	a,@a+dptr
	mov	r7,a
	push	ar4
	push	ar3
	push	ar7
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_putc
	dec	sp
	pop	ar3
	pop	ar4
;	vt100.c:285: _vt100_putc(t, hex[(ch & 0x0f)]);
	anl	ar3,#0x0f
	mov	r4,#0x00
	mov	a,r3
	add	a,#__vt100_putc_hex_131072_135
	mov	dpl,a
	mov	a,r4
	addc	a,#(__vt100_putc_hex_131072_135 >> 8)
	mov	dph,a
	clr	a
	movc	a,@a+dptr
	mov	r7,a
	push	ar7
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_putc
	dec	sp
;	vt100.c:286: return;
	ljmp	00104$
00102$:
;	vt100.c:290: uint8_t x = VT100_CURSOR_X(t);
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x07
	add	a,@r0
	mov	r4,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r4
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r4,a
	mov	b,r4
	mov	a,r5
	mul	ab
	mov	r5,a
;	vt100.c:291: uint8_t y = VT100_CURSOR_Y(t);
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	push	ar5
	lcall	_VT100_CURSOR_Y
	mov	r6,dpl
	pop	ar5
;	vt100.c:293: vga_setFrontColor(t->front_color);
	mov	r0,_bp
	inc	r0
	mov	a,#0x0a
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r3
	mov	dph,r4
	mov	b,r7
	lcall	__gptrget
	mov	dpl,a
	push	ar6
	push	ar5
	lcall	_vga_setFrontColor
;	vt100.c:294: vga_setBackColor(t->back_color); 
	mov	r0,_bp
	inc	r0
	mov	a,#0x09
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r3
	mov	dph,r4
	mov	b,r7
	lcall	__gptrget
	mov	dpl,a
	lcall	_vga_setBackColor
	pop	ar5
	pop	ar6
;	vt100.c:295: vga_drawChar(x, y, ch);
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	a,@r0
	push	acc
	push	ar6
	mov	dpl,r5
	lcall	_vga_drawChar
	dec	sp
	dec	sp
;	vt100.c:298: _vt100_move(t, 1, 0); 
	clr	a
	push	acc
	push	acc
	inc	a
	push	acc
	clr	a
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_move
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:299: _vt100_drawCursor(t); 
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_drawCursor
00104$:
;	vt100.c:300: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_st_command_arg'
;------------------------------------------------------------
;ev                        Allocated to stack - _bp -3
;arg                       Allocated to stack - _bp -4
;term                      Allocated to stack - _bp +1
;__2621440002              Allocated to registers 
;__2621440003              Allocated to stack - _bp +6
;c                         Allocated to registers 
;sloc0                     Allocated to stack - _bp +10
;sloc1                     Allocated to stack - _bp +4
;------------------------------------------------------------
;	vt100.c:302: STATE(_st_command_arg, term, ev, arg) {
;	-----------------------------------------
;	 function _st_command_arg
;	-----------------------------------------
__st_command_arg:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
	mov	a,sp
	add	a,#0x04
	mov	sp,a
;	vt100.c:303: switch(ev){
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	cjne	@r0,#0x01,00137$
	sjmp	00138$
00137$:
	ljmp	00113$
00138$:
;	vt100.c:305: if(isdigit(arg)){ // a digit argument
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,_bp
	add	a,#0x06
	mov	r1,a
	mov	a,@r0
	mov	@r1,a
	inc	r1
	mov	@r1,#0x00
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	ar2,@r0
	inc	r0
	mov	ar7,@r0
;	c:\program files\sdcc\include\ctype.h:62: return ((unsigned char)c >= '0' && (unsigned char)c <= '9');
	cjne	r2,#0x30,00139$
00139$:
	mov	b0,c
	jnc	00140$
	ljmp	00109$
00140$:
	mov	a,r2
	add	a,#0xff - 0x39
	mov	b0,c
	jnc	00141$
	ljmp	00109$
00141$:
;	vt100.c:306: term->args[term->narg] = term->args[term->narg] * 10 + (arg - '0');
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	add	a,acc
	add	a,r2
	mov	r2,a
	clr	a
	addc	a,r3
	mov	r3,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r6,a
	inc	dptr
	lcall	__gptrget
	mov	r7,a
	push	ar4
	push	ar3
	push	ar2
	push	ar6
	push	ar7
	mov	dptr,#0x000a
	lcall	__mulint
	xch	a,r0
	mov	a,_bp
	add	a,#0x04
	xch	a,r0
	mov	@r0,dpl
	inc	r0
	mov	@r0,dph
	dec	sp
	dec	sp
	pop	ar2
	pop	ar3
	pop	ar4
	mov	a,_bp
	add	a,#0x06
	mov	r0,a
	mov	a,@r0
	add	a,#0xd0
	mov	r5,a
	inc	r0
	mov	a,@r0
	addc	a,#0xff
	mov	r7,a
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,r5
	add	a,@r0
	mov	r5,a
	mov	a,r7
	inc	r0
	addc	a,@r0
	mov	r7,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,r5
	lcall	__gptrput
	inc	dptr
	mov	a,r7
	lcall	__gptrput
	ljmp	00113$
00109$:
;	vt100.c:307: } else if(arg == ';') { // separator
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x3b,00106$
;	vt100.c:308: term->narg++;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r4,a
	inc	r4
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,r4
	lcall	__gptrput
	ljmp	00113$
00106$:
;	vt100.c:311: term->narg++;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r4,a
	inc	r4
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,r4
	lcall	__gptrput
;	vt100.c:312: if(term->ret_state){
	mov	r0,_bp
	inc	r0
	mov	a,#0x1a
	add	a,@r0
	mov	r6,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r6
	mov	dph,r5
	mov	b,r7
	lcall	__gptrget
	mov	r6,a
	inc	dptr
	lcall	__gptrget
	mov	r7,a
	orl	a,r6
	jz	00103$
;	vt100.c:313: term->state = term->ret_state;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	inc	r0
	mov	ar5,@r0
	mov	dpl,r3
	mov	dph,r4
	mov	b,r5
	mov	a,r6
	lcall	__gptrput
	inc	dptr
	mov	a,r7
	lcall	__gptrput
	sjmp	00104$
00103$:
;	vt100.c:316: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
00104$:
;	vt100.c:319: term->state(term, ev, arg);
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	inc	dptr
	lcall	__gptrget
	mov	r6,a
	push	ar6
	push	ar5
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	push	acc
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	a,@r0
	push	acc
	lcall	00145$
	sjmp	00146$
00145$:
	push	ar5
	push	ar6
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	ret
00146$:
	dec	sp
	dec	sp
	pop	ar5
	pop	ar6
;	vt100.c:323: }
00113$:
;	vt100.c:324: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_st_esc_question'
;------------------------------------------------------------
;ev                        Allocated to stack - _bp -3
;arg                       Allocated to stack - _bp -4
;term                      Allocated to registers r5 r6 r7 
;__2621440005              Allocated to registers 
;__2621440006              Allocated to registers 
;c                         Allocated to registers 
;sloc0                     Allocated to stack - _bp +10
;sloc1                     Allocated to stack - _bp +1
;------------------------------------------------------------
;	vt100.c:326: STATE(_st_esc_question, term, ev, arg) {
;	-----------------------------------------
;	 function _st_esc_question
;	-----------------------------------------
__st_esc_question:
	push	_bp
	mov	_bp,sp
	inc	sp
	inc	sp
	inc	sp
	mov	r5,dpl
	mov	r6,dph
	mov	r7,b
;	vt100.c:329: switch(ev){
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	cjne	@r0,#0x01,00172$
	sjmp	00173$
00172$:
	ljmp	00126$
00173$:
;	vt100.c:331: if(isdigit(arg)){ // start of an argument
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	ar4,@r0
;	c:\program files\sdcc\include\ctype.h:62: return ((unsigned char)c >= '0' && (unsigned char)c <= '9');
	cjne	r4,#0x30,00174$
00174$:
	mov	b0,c
	jc	00122$
	mov	a,r4
	add	a,#0xff - 0x39
	mov	b0,c
	jc	00122$
;	vt100.c:332: term->ret_state = _st_esc_question; 
	mov	a,#0x1a
	add	a,r5
	mov	r2,a
	clr	a
	addc	a,r6
	mov	r3,a
	mov	ar4,r7
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_esc_question
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_esc_question >> 8)
	lcall	__gptrput
;	vt100.c:333: _st_command_arg(term, ev, arg);
	push	ar7
	push	ar6
	push	ar5
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	push	acc
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	a,@r0
	push	acc
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__st_command_arg
	dec	sp
	dec	sp
	pop	ar5
	pop	ar6
	pop	ar7
;	vt100.c:334: term->state = _st_command_arg;
	mov	a,#0x16
	add	a,r5
	mov	r2,a
	clr	a
	addc	a,r6
	mov	r3,a
	mov	ar4,r7
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_command_arg
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_command_arg >> 8)
	lcall	__gptrput
	ljmp	00126$
00122$:
;	vt100.c:335: } else if(arg == ';'){ // arg separator. 
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x3b,00177$
	ljmp	00126$
00177$:
;	vt100.c:338: switch(arg) {
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	clr	a
	cjne	@r0,#0x68,00178$
	inc	a
00178$:
	mov	r4,a
	jnz	00103$
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x69,00181$
	ljmp	00116$
00181$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x6c,00182$
	sjmp	00183$
00182$:
	ljmp	00116$
00183$:
;	vt100.c:341: case 'h': {
00103$:
;	vt100.c:343: switch(term->args[0]){
	push	ar4
	mov	a,#0x0d
	add	a,r5
	mov	r2,a
	clr	a
	addc	a,r6
	mov	r3,a
	mov	ar4,r7
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	inc	dptr
	lcall	__gptrget
	mov	r3,a
	clr	c
	mov	a,#0x09
	subb	a,r2
	clr	a
	subb	a,r3
	pop	ar4
	jnc	00184$
	ljmp	00113$
00184$:
	mov	a,r2
	add	a,#(00185$-3-.)
	movc	a,@a+pc
	mov	dpl,a
	mov	a,r2
	add	a,#(00186$-3-.)
	movc	a,@a+pc
	mov	dph,a
	clr	a
	jmp	@a+dptr
00185$:
	.db	00113$
	.db	00113$
	.db	00113$
	.db	00113$
	.db	00113$
	.db	00113$
	.db	00109$
	.db	00110$
	.db	00113$
	.db	00113$
00186$:
	.db	00113$>>8
	.db	00113$>>8
	.db	00113$>>8
	.db	00113$>>8
	.db	00113$>>8
	.db	00113$>>8
	.db	00109$>>8
	.db	00110$>>8
	.db	00113$>>8
	.db	00113$>>8
;	vt100.c:369: case 6: {
00109$:
;	vt100.c:372: term->flags.origin_mode = (arg == 'h')?1:0; 
	mov	r0,_bp
	inc	r0
	mov	@r0,ar5
	inc	r0
	mov	@r0,ar6
	inc	r0
	mov	@r0,ar7
	mov	a,r4
	jz	00131$
	mov	r2,#0x01
	mov	r3,#0x00
	sjmp	00132$
00131$:
	mov	r2,#0x00
	mov	r3,#0x00
00132$:
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	mov	a,r2
	add	a,r2
	add	a,acc
	anl	a,#0x04
	push	b
	push	acc
	lcall	__gptrget
	pop	b
	anl	a,#0xfb
	orl	a,b
	pop	b
	lcall	__gptrput
;	vt100.c:373: break;
;	vt100.c:375: case 7: {
	sjmp	00113$
00110$:
;	vt100.c:378: term->flags.cursor_wrap = (arg == 'h')?1:0; 
	mov	r0,_bp
	inc	r0
	mov	@r0,ar5
	inc	r0
	mov	@r0,ar6
	inc	r0
	mov	@r0,ar7
	mov	a,r4
	jz	00133$
	mov	r3,#0x01
	mov	r4,#0x00
	sjmp	00134$
00133$:
	mov	r3,#0x00
	mov	r4,#0x00
00134$:
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	mov	a,r3
	anl	a,#0x01
	push	b
	push	acc
	lcall	__gptrget
	pop	b
	anl	a,#0xfe
	orl	a,b
	pop	b
	lcall	__gptrput
;	vt100.c:392: }
00113$:
;	vt100.c:393: term->state = _st_idle;
	mov	a,#0x16
	add	a,r5
	mov	r2,a
	clr	a
	addc	a,r6
	mov	r3,a
	mov	ar4,r7
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:394: break; 
;	vt100.c:398: default:  
	sjmp	00117$
00116$:
;	vt100.c:399: term->state = _st_idle; 
	mov	a,#0x16
	add	a,r5
	mov	r2,a
	clr	a
	addc	a,r6
	mov	r3,a
	mov	ar4,r7
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:401: }
00117$:
;	vt100.c:402: term->state = _st_idle;
	mov	a,#0x16
	add	a,r5
	mov	r5,a
	clr	a
	addc	a,r6
	mov	r6,a
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:405: }
00126$:
;	vt100.c:406: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_st_esc_sq_bracket'
;------------------------------------------------------------
;ev                        Allocated to stack - _bp -3
;arg                       Allocated to stack - _bp -4
;term                      Allocated to stack - _bp +1
;__2621440008              Allocated to registers 
;__2621440009              Allocated to registers 
;c                         Allocated to registers 
;n                         Allocated to registers r6 r5 
;n                         Allocated to registers r6 r5 
;n                         Allocated to registers r6 r5 
;n                         Allocated to registers r6 r5 
;y                         Allocated to registers 
;x                         Allocated to stack - _bp +12
;y                         Allocated to stack - _bp +14
;n                         Allocated to registers r6 r7 
;c                         Allocated to registers r4 r5 
;n                         Allocated to stack - _bp +12
;top_margin                Allocated to registers r7 r6 
;bottom_margin             Allocated to registers r2 r5 
;sloc0                     Allocated to stack - _bp +4
;sloc1                     Allocated to stack - _bp +7
;sloc2                     Allocated to stack - _bp +9
;------------------------------------------------------------
;	vt100.c:408: STATE(_st_esc_sq_bracket, term, ev, arg) {
;	-----------------------------------------
;	 function _st_esc_sq_bracket
;	-----------------------------------------
__st_esc_sq_bracket:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
	mov	a,sp
	add	a,#0x0c
	mov	sp,a
;	vt100.c:410: switch(ev){
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	cjne	@r0,#0x01,00399$
	sjmp	00400$
00399$:
	ljmp	00194$
00400$:
;	vt100.c:412: if(isdigit(arg)){ // start of an argument
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	ar4,@r0
;	c:\program files\sdcc\include\ctype.h:62: return ((unsigned char)c >= '0' && (unsigned char)c <= '9');
	cjne	r4,#0x30,00401$
00401$:
	mov	b0,c
	jc	00192$
	mov	a,r4
	add	a,#0xff - 0x39
	mov	b0,c
	jc	00192$
;	vt100.c:413: term->ret_state = _st_esc_sq_bracket; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x1a
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_esc_sq_bracket
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_esc_sq_bracket >> 8)
	lcall	__gptrput
;	vt100.c:414: _st_command_arg(term, ev, arg);
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	push	acc
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	mov	a,@r0
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__st_command_arg
	dec	sp
	dec	sp
;	vt100.c:415: term->state = _st_command_arg;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_command_arg
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_command_arg >> 8)
	lcall	__gptrput
	ljmp	00200$
00192$:
;	vt100.c:416: } else if(arg == ';'){ // arg separator. 
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x3b,00404$
	ljmp	00200$
00404$:
;	vt100.c:419: switch(arg){
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x3d,00405$
00405$:
	jnc	00406$
	ljmp	00186$
00406$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	add	a,#0xff - 0x79
	jnc	00407$
	ljmp	00186$
00407$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	add	a,#0xc3
	mov	r4,a
	add	a,#(00408$-3-.)
	movc	a,@a+pc
	mov	dpl,a
	mov	a,r4
	add	a,#(00409$-3-.)
	movc	a,@a+pc
	mov	dph,a
	clr	a
	jmp	@a+dptr
00408$:
	.db	00184$
	.db	00186$
	.db	00185$
	.db	00176$
	.db	00102$
	.db	00105$
	.db	00108$
	.db	00111$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00115$
	.db	00186$
	.db	00124$
	.db	00137$
	.db	00151$
	.db	00151$
	.db	00186$
	.db	00186$
	.db	00152$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00154$
	.db	00186$
	.db	00186$
	.db	00115$
	.db	00160$
	.db	00159$
	.db	00184$
	.db	00186$
	.db	00186$
	.db	00159$
	.db	00161$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00186$
	.db	00177$
	.db	00156$
	.db	00186$
	.db	00157$
	.db	00186$
	.db	00186$
	.db	00155$
	.db	00184$
00409$:
	.db	00184$>>8
	.db	00186$>>8
	.db	00185$>>8
	.db	00176$>>8
	.db	00102$>>8
	.db	00105$>>8
	.db	00108$>>8
	.db	00111$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00115$>>8
	.db	00186$>>8
	.db	00124$>>8
	.db	00137$>>8
	.db	00151$>>8
	.db	00151$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00152$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00154$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00115$>>8
	.db	00160$>>8
	.db	00159$>>8
	.db	00184$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00159$>>8
	.db	00161$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00177$>>8
	.db	00156$>>8
	.db	00186$>>8
	.db	00157$>>8
	.db	00186$>>8
	.db	00186$>>8
	.db	00155$>>8
	.db	00184$>>8
;	vt100.c:420: case 'A': {// move cursor up (cursor stops at top margin)
00102$:
;	vt100.c:421: int n = (term->narg > 0)?term->args[0]:1;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	jz	00205$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r2,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r3
	mov	dph,r2
	mov	b,r4
	lcall	__gptrget
	mov	r3,a
	inc	dptr
	lcall	__gptrget
	mov	r4,a
	sjmp	00206$
00205$:
	mov	r3,#0x01
	mov	r4,#0x00
00206$:
	mov	ar6,r3
	mov	ar5,r4
;	vt100.c:422: term->cursor_y -= n;
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	clr	c
	subb	a,r6
;	vt100.c:423: if(term->cursor_y < 0) term->cursor_y = 0; 
	mov	r7,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrput
	jnb	acc.7,00104$
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	clr	a
	lcall	__gptrput
00104$:
;	vt100.c:424: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:425: break;
	ljmp	00200$
;	vt100.c:427: case 'B': { // cursor down (cursor stops at bottom margin)
00105$:
;	vt100.c:428: int n = (term->narg > 0)?term->args[0]:1;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	jz	00207$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r2,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r3
	mov	dph,r2
	mov	b,r4
	lcall	__gptrget
	mov	r3,a
	inc	dptr
	lcall	__gptrget
	mov	r4,a
	sjmp	00208$
00207$:
	mov	r3,#0x01
	mov	r4,#0x00
00208$:
	mov	ar6,r3
	mov	ar5,r4
;	vt100.c:429: term->cursor_y += n;
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	add	a,r6
	mov	r7,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrput
;	vt100.c:430: if(term->cursor_y > VT100_HEIGHT) term->cursor_y = VT100_HEIGHT; 
	clr	c
	mov	a,#(0x18 ^ 0x80)
	mov	b,r7
	xrl	b,#0x80
	subb	a,b
	jnc	00107$
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#0x18
	lcall	__gptrput
00107$:
;	vt100.c:431: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:432: break;
	ljmp	00200$
;	vt100.c:434: case 'C': { // cursor right (cursor stops at right margin)
00108$:
;	vt100.c:435: int n = (term->narg > 0)?term->args[0]:1;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	jz	00209$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r2,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r3
	mov	dph,r2
	mov	b,r4
	lcall	__gptrget
	mov	r3,a
	inc	dptr
	lcall	__gptrget
	mov	r4,a
	sjmp	00210$
00209$:
	mov	r3,#0x01
	mov	r4,#0x00
00210$:
	mov	ar6,r3
	mov	ar5,r4
;	vt100.c:436: term->cursor_x += n;
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	add	a,r6
	mov	r7,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrput
;	vt100.c:437: if(term->cursor_x > VT100_WIDTH) term->cursor_x = VT100_WIDTH;
	clr	c
	mov	a,#(0x50 ^ 0x80)
	mov	b,r7
	xrl	b,#0x80
	subb	a,b
	jnc	00110$
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#0x50
	lcall	__gptrput
00110$:
;	vt100.c:438: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:439: break;
	ljmp	00200$
;	vt100.c:441: case 'D': { // cursor left
00111$:
;	vt100.c:442: int n = (term->narg > 0)?term->args[0]:1;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	jz	00211$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r2,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r3
	mov	dph,r2
	mov	b,r4
	lcall	__gptrget
	mov	r3,a
	inc	dptr
	lcall	__gptrget
	mov	r4,a
	sjmp	00212$
00211$:
	mov	r3,#0x01
	mov	r4,#0x00
00212$:
	mov	ar6,r3
	mov	ar5,r4
;	vt100.c:443: term->cursor_x -= n;
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	clr	c
	subb	a,r6
;	vt100.c:444: if(term->cursor_x < 0) term->cursor_x = 0;
	mov	r7,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrput
	jnb	acc.7,00113$
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	clr	a
	lcall	__gptrput
00113$:
;	vt100.c:445: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:446: break;
	ljmp	00200$
;	vt100.c:449: case 'H': { // move cursor to position (default 0;0)
00115$:
;	vt100.c:451: term->cursor_x = (term->narg >= 1)?(term->args[1]-1):0; 
	mov	r0,_bp
	inc	r0
	mov	a,_bp
	add	a,#0x09
	mov	r1,a
	mov	a,#0x01
	add	a,@r0
	mov	@r1,a
	clr	a
	inc	r0
	addc	a,@r0
	inc	r1
	mov	@r1,a
	inc	r0
	mov	a,@r0
	inc	r1
	mov	@r1,a
	mov	r0,_bp
	inc	r0
	mov	a,_bp
	add	a,#0x04
	mov	r1,a
	mov	a,#0x0c
	add	a,@r0
	mov	@r1,a
	clr	a
	inc	r0
	addc	a,@r0
	inc	r1
	mov	@r1,a
	inc	r0
	mov	a,@r0
	inc	r1
	mov	@r1,a
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__gptrget
	mov	r7,a
	cjne	r7,#0x01,00418$
00418$:
	mov	b0,c
	jc	00213$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	a,#0x02
	add	a,r2
	mov	r2,a
	clr	a
	addc	a,r3
	mov	r3,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	dec	r2
	mov	a,r2
	rlc	a
	subb	a,acc
	mov	r7,a
	sjmp	00214$
00213$:
	mov	r2,#0x00
	mov	r7,#0x00
00214$:
	mov	ar7,r2
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	mov	a,r7
	lcall	__gptrput
;	vt100.c:452: term->cursor_y = (term->narg == 2)?(term->args[0]-1):0;
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__gptrget
	mov	r4,a
	cjne	r4,#0x02,00215$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	dec	r2
	mov	a,r2
	rlc	a
	subb	a,acc
	mov	r4,a
	sjmp	00216$
00215$:
	mov	r2,#0x00
	mov	r4,#0x00
00216$:
	mov	ar4,r2
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,r4
	lcall	__gptrput
;	vt100.c:453: if(term->flags.origin_mode) {
	mov	r0,_bp
	inc	r0
	mov	ar2,@r0
	inc	r0
	mov	ar3,@r0
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	jnb	acc.2,00119$
;	vt100.c:454: term->cursor_y += term->scroll_start_row;
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,_bp
	add	a,#0x07
	mov	r0,a
	lcall	__gptrget
	mov	@r0,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x05
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	mov	a,_bp
	add	a,#0x07
	mov	r0,a
	mov	a,_bp
	add	a,#0x07
	mov	r1,a
	mov	a,r2
	add	a,@r0
	mov	@r1,a
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,_bp
	add	a,#0x07
	mov	r0,a
	mov	a,@r0
	lcall	__gptrput
;	vt100.c:455: if(term->cursor_y >= term->scroll_end_row){
	mov	r0,_bp
	inc	r0
	mov	a,#0x06
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r4,a
	mov	a,_bp
	add	a,#0x07
	mov	r0,a
	clr	c
	mov	a,@r0
	xrl	a,#0x80
	mov	b,r4
	xrl	b,#0x80
	subb	a,b
	jc	00119$
;	vt100.c:456: term->cursor_y = term->scroll_end_row - 1;
	dec	r4
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,r4
	lcall	__gptrput
00119$:
;	vt100.c:459: if(term->cursor_x > VT100_WIDTH) term->cursor_x = VT100_WIDTH;
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__gptrget
	mov	r4,a
	clr	c
	mov	a,#(0x50 ^ 0x80)
	mov	b,r4
	xrl	b,#0x80
	subb	a,b
	jnc	00121$
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	mov	a,#0x50
	lcall	__gptrput
00121$:
;	vt100.c:460: if(term->cursor_y > VT100_HEIGHT) term->cursor_y = VT100_HEIGHT; 
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r4,a
	clr	c
	mov	a,#(0x18 ^ 0x80)
	mov	b,r4
	xrl	b,#0x80
	subb	a,b
	jnc	00123$
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#0x18
	lcall	__gptrput
00123$:
;	vt100.c:461: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:462: break;
	ljmp	00200$
;	vt100.c:464: case 'J':{// clear screen from cursor up or down
00124$:
;	vt100.c:465: uint16_t y = VT100_CURSOR_Y(term); 
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	_VT100_CURSOR_Y
;	vt100.c:466: if(term->narg == 0 || (term->narg == 1 && term->args[0] == 0)){
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r7,a
	jz	00132$
	cjne	r7,#0x01,00427$
	mov	a,r7
	sjmp	00428$
00427$:
	clr	a
00428$:
	mov	r7,a
	jz	00133$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r4,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r4
	mov	dph,r5
	mov	b,r6
	lcall	__gptrget
	mov	r4,a
	inc	dptr
	lcall	__gptrget
	mov	r5,a
	orl	a,r4
	jnz	00133$
00132$:
;	vt100.c:468: _vt100_clearLines(term, term->cursor_y, VT100_HEIGHT - 1); 
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r4,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r4
	mov	dph,r5
	mov	b,r6
	lcall	__gptrget
	mov	r4,a
	rlc	a
	subb	a,acc
	mov	r6,a
	mov	a,#0x17
	push	acc
	clr	a
	push	acc
	push	ar4
	push	ar6
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_clearLines
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	ljmp	00134$
00133$:
;	vt100.c:469: } else if(term->narg == 1 && term->args[0] == 1){
	mov	a,r7
	jz	00129$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r4,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r4
	mov	dph,r5
	mov	b,r6
	lcall	__gptrget
	mov	r4,a
	inc	dptr
	lcall	__gptrget
	mov	r5,a
	cjne	r4,#0x01,00129$
	cjne	r5,#0x00,00129$
;	vt100.c:471: _vt100_clearLines(term, 0, term->cursor_y); 
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r4,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r4
	mov	dph,r5
	mov	b,r6
	lcall	__gptrget
	mov	r4,a
	rlc	a
	subb	a,acc
	mov	r6,a
	push	ar4
	push	ar6
	clr	a
	push	acc
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_clearLines
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	sjmp	00134$
00129$:
;	vt100.c:472: } else if(term->narg == 1 && term->args[0] == 2){
	mov	a,r7
	jz	00134$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	inc	dptr
	lcall	__gptrget
	mov	r6,a
	cjne	r5,#0x02,00134$
	cjne	r6,#0x00,00134$
;	vt100.c:474: _vt100_clearLines(term, 0, VT100_HEIGHT - 1);
	mov	a,#0x17
	push	acc
	clr	a
	push	acc
	push	acc
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_clearLines
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:476: _vt100_resetScroll(); 
	lcall	__vt100_resetScroll
00134$:
;	vt100.c:478: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:479: break;
	ljmp	00200$
;	vt100.c:481: case 'K':{// clear line from cursor right/left
00137$:
;	vt100.c:482: uint16_t x = VT100_CURSOR_X(term);
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	mov	r0,_bp
	inc	r0
	mov	a,#0x07
	add	a,@r0
	mov	r4,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r4
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r4,a
	clr	F0
	mov	b,r4
	mov	a,r5
	jnb	acc.7,00437$
	cpl	F0
	cpl	a
	inc	a
00437$:
	mul	ab
	jnb	F0,00438$
	cpl	a
	add	a,#0x01
	xch	a,b
	cpl	a
	addc	a,#0x00
	xch	a,b
00438$:
	mov	r5,a
	mov	r7,b
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	mov	@r0,ar5
	inc	r0
	mov	@r0,ar7
;	vt100.c:483: uint16_t y = VT100_CURSOR_Y(term);
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	_VT100_CURSOR_Y
	mov	r4,dpl
	mov	r5,dph
	mov	a,_bp
	add	a,#0x0e
	mov	r0,a
	mov	@r0,ar4
	inc	r0
	mov	@r0,ar5
;	vt100.c:485: if(term->narg == 0 || (term->narg == 1 && term->args[0] == 0)){
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r7
	lcall	__gptrget
	mov	r7,a
	jz	00145$
	cjne	r7,#0x01,00440$
	mov	a,r7
	sjmp	00441$
00440$:
	clr	a
00441$:
	mov	r7,a
	jz	00146$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r6
	lcall	__gptrget
	mov	r2,a
	inc	dptr
	lcall	__gptrget
	mov	r3,a
	orl	a,r2
	jnz	00146$
00145$:
;	vt100.c:488: vga_fillRect(x, y, VT100_SCREEN_WIDTH - x, VT100_CHAR_HEIGHT, term->back_color);
	mov	r0,_bp
	inc	r0
	mov	a,#0x09
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r6
	lcall	__gptrget
	mov	r2,a
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	mov	ar6,@r0
	mov	ar3,r6
	mov	a,#0x50
	clr	c
	subb	a,r3
	mov	r3,a
	mov	a,_bp
	add	a,#0x0e
	mov	r0,a
	mov	ar5,@r0
	push	ar2
	mov	a,#0x01
	push	acc
	push	ar3
	push	ar5
	mov	dpl,r6
	lcall	_vga_fillRect
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	ljmp	00147$
00146$:
;	vt100.c:489: } else if(term->narg == 1 && term->args[0] == 1){
	mov	a,r7
	jz	00142$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r4,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r4
	mov	dph,r5
	mov	b,r6
	lcall	__gptrget
	mov	r4,a
	inc	dptr
	lcall	__gptrget
	mov	r5,a
	cjne	r4,#0x01,00142$
	cjne	r5,#0x00,00142$
;	vt100.c:491: vga_fillRect(0, y, x + VT100_CHAR_WIDTH, VT100_CHAR_HEIGHT, term->back_color);
	mov	r0,_bp
	inc	r0
	mov	a,#0x09
	add	a,@r0
	mov	r4,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar6,@r0
	mov	dpl,r4
	mov	dph,r5
	mov	b,r6
	lcall	__gptrget
	mov	r4,a
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	mov	ar6,@r0
	inc	r6
	mov	a,_bp
	add	a,#0x0e
	mov	r0,a
	mov	ar5,@r0
	push	ar4
	mov	a,#0x01
	push	acc
	push	ar6
	push	ar5
	mov	dpl,#0x00
	lcall	_vga_fillRect
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	sjmp	00147$
00142$:
;	vt100.c:492: } else if(term->narg == 1 && term->args[0] == 2){
	mov	a,r7
	jz	00147$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	inc	dptr
	lcall	__gptrget
	mov	r6,a
	cjne	r5,#0x02,00147$
	cjne	r6,#0x00,00147$
;	vt100.c:494: vga_fillRect(0, y, VT100_SCREEN_WIDTH, VT100_CHAR_HEIGHT, term->back_color);
	mov	r0,_bp
	inc	r0
	mov	a,#0x09
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	mov	a,_bp
	add	a,#0x0e
	mov	r0,a
	mov	ar4,@r0
	push	ar5
	mov	a,#0x01
	push	acc
	mov	a,#0x50
	push	acc
	push	ar4
	mov	dpl,#0x00
	lcall	_vga_fillRect
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
00147$:
;	vt100.c:496: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:497: break;
	ljmp	00200$
;	vt100.c:501: case 'M': // delete lines (args[0] = number of lines)
00151$:
;	vt100.c:502: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:503: break; 
	ljmp	00200$
;	vt100.c:504: case 'P': {// delete characters args[0] or 1 in front of cursor
00152$:
;	vt100.c:506: int n = ((term->narg > 0)?term->args[0]:1);
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	jz	00217$
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r6,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r6
	mov	dph,r5
	mov	b,r7
	lcall	__gptrget
	mov	r6,a
	inc	dptr
	lcall	__gptrget
	mov	r7,a
	sjmp	00218$
00217$:
	mov	r6,#0x01
	mov	r7,#0x00
00218$:
;	vt100.c:507: _vt100_move(term, -n, 0);
	clr	c
	clr	a
	subb	a,r6
	mov	r4,a
	clr	a
	subb	a,r7
	mov	r5,a
	push	ar7
	push	ar6
	clr	a
	push	acc
	push	acc
	push	ar4
	push	ar5
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_move
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
	pop	ar6
	pop	ar7
;	vt100.c:508: for(int c = 0; c < n; c++){
	mov	r4,#0x00
	mov	r5,#0x00
00198$:
	clr	c
	mov	a,r4
	subb	a,r6
	mov	a,r5
	xrl	a,#0x80
	mov	b,r7
	xrl	b,#0x80
	subb	a,b
	jnc	00153$
;	vt100.c:509: _vt100_putc(term, ' ');
	push	ar7
	push	ar6
	push	ar5
	push	ar4
	mov	a,#0x20
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_putc
	dec	sp
	pop	ar4
	pop	ar5
	pop	ar6
	pop	ar7
;	vt100.c:508: for(int c = 0; c < n; c++){
	inc	r4
	cjne	r4,#0x00,00198$
	inc	r5
	sjmp	00198$
00153$:
;	vt100.c:511: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:512: break;
	ljmp	00200$
;	vt100.c:514: case 'c':{ // query device code
00154$:
;	vt100.c:516: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:517: break; 
	ljmp	00200$
;	vt100.c:519: case 'x': {
00155$:
;	vt100.c:520: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:521: break;
	ljmp	00200$
;	vt100.c:523: case 's':{// save cursor pos
00156$:
;	vt100.c:524: term->saved_cursor_x = term->cursor_x;
	mov	r0,_bp
	inc	r0
	mov	a,#0x03
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrput
;	vt100.c:525: term->saved_cursor_y = term->cursor_y;
	mov	r0,_bp
	inc	r0
	mov	a,#0x04
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrput
;	vt100.c:526: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:527: break;
	ljmp	00200$
;	vt100.c:529: case 'u':{// restore cursor pos
00157$:
;	vt100.c:530: term->cursor_x = term->saved_cursor_x;
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	r0,_bp
	inc	r0
	mov	a,#0x03
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrput
;	vt100.c:531: term->cursor_y = term->saved_cursor_y; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	r0,_bp
	inc	r0
	mov	a,#0x04
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrput
;	vt100.c:533: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:534: break;
	ljmp	00200$
;	vt100.c:537: case 'l': {
00159$:
;	vt100.c:538: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:539: break;
	ljmp	00200$
;	vt100.c:542: case 'g': {
00160$:
;	vt100.c:543: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:544: break;
	ljmp	00200$
;	vt100.c:546: case 'm': { // sets colors. Accepts up to 3 args
00161$:
;	vt100.c:548: if(!term->narg){
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	jnz	00259$
;	vt100.c:549: term->front_color = 0xff;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0a
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#0xff
	lcall	__gptrput
;	vt100.c:550: term->back_color = 0x00;
	mov	r0,_bp
	inc	r0
	mov	a,#0x09
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	clr	a
	lcall	__gptrput
;	vt100.c:552: while(term->narg){
00259$:
	mov	r0,_bp
	inc	r0
	mov	a,_bp
	add	a,#0x09
	mov	r1,a
	mov	a,#0x0d
	add	a,@r0
	mov	@r1,a
	clr	a
	inc	r0
	addc	a,@r0
	inc	r1
	mov	@r1,a
	inc	r0
	mov	a,@r0
	inc	r1
	mov	@r1,a
00173$:
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	jnz	00454$
	ljmp	00175$
00454$:
;	vt100.c:553: term->narg--; 
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r4,a
	dec	r4
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
;	vt100.c:554: int n = term->args[term->narg];
	mov	a,r4
	lcall	__gptrput
	add	a,acc
	mov	r4,a
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	mov	a,r4
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	inc	r0
	mov	ar2,@r0
	mov	dpl,r3
	mov	dph,r4
	mov	b,r2
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	lcall	__gptrget
	mov	@r0,a
	inc	dptr
	lcall	__gptrget
	inc	r0
	mov	@r0,a
;	vt100.c:565: if(n == 0){ // all attributes off
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	mov	a,@r0
	inc	r0
	orl	a,@r0
	jnz	00165$
;	vt100.c:566: term->front_color = 0xff;
	push	ar5
	push	ar6
	push	ar7
	mov	r0,_bp
	inc	r0
	mov	a,#0x0a
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r2
	mov	dph,r6
	mov	b,r7
	mov	a,#0xff
	lcall	__gptrput
;	vt100.c:567: term->back_color = 0x00;
	mov	r0,_bp
	inc	r0
	mov	a,#0x09
	add	a,@r0
	mov	r3,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r4,a
	inc	r0
	mov	ar5,@r0
	mov	dpl,r3
	mov	dph,r4
	mov	b,r5
	clr	a
	lcall	__gptrput
;	vt100.c:569: vga_setFrontColor(term->front_color);
	mov	dpl,r2
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	dpl,a
	push	ar7
	push	ar6
	push	ar5
	push	ar4
	push	ar3
	lcall	_vga_setFrontColor
	pop	ar3
	pop	ar4
	pop	ar5
;	vt100.c:570: vga_setBackColor(term->back_color);
	mov	dpl,r3
	mov	dph,r4
	mov	b,r5
	lcall	__gptrget
	mov	dpl,a
	push	ar5
	lcall	_vga_setBackColor
	pop	ar5
	pop	ar6
	pop	ar7
;	vt100.c:627: term->state = _st_idle; 
	pop	ar7
	pop	ar6
	pop	ar5
;	vt100.c:570: vga_setBackColor(term->back_color);
00165$:
;	vt100.c:572: if(n >= 30 && n < 38){ // fg colors
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,#0x1e
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	subb	a,#0x80
	jc	00170$
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,#0x26
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00170$
;	vt100.c:573: term->front_color = colors[n-30]; 
	push	ar5
	push	ar6
	push	ar7
	mov	r0,_bp
	inc	r0
	mov	a,#0x0a
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	mov	a,@r0
	add	a,#0xe2
	mov	r7,a
	rlc	a
	subb	a,acc
	mov	r6,a
	mov	a,r7
	add	a,#__st_esc_sq_bracket_colors_458753_206
	mov	dpl,a
	mov	a,r6
	addc	a,#(__st_esc_sq_bracket_colors_458753_206 >> 8)
	mov	dph,a
	clr	a
	movc	a,@a+dptr
	mov	r7,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrput
;	vt100.c:574: vga_setFrontColor(term->front_color);
	mov	dpl,r7
	push	ar7
	push	ar6
	push	ar5
	lcall	_vga_setFrontColor
	pop	ar5
	pop	ar6
	pop	ar7
	pop	ar7
	pop	ar6
	pop	ar5
	ljmp	00173$
00170$:
;	vt100.c:575: } else if(n >= 40 && n < 48){
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,#0x28
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00458$
	ljmp	00173$
00458$:
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,#0x30
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	subb	a,#0x80
	jc	00459$
	ljmp	00173$
00459$:
;	vt100.c:576: term->back_color = colors[n-40]; 
	push	ar5
	push	ar6
	push	ar7
	mov	r0,_bp
	inc	r0
	mov	a,#0x09
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	a,_bp
	add	a,#0x0c
	mov	r0,a
	mov	a,@r0
	add	a,#0xd8
	mov	r7,a
	rlc	a
	subb	a,acc
	mov	r6,a
	mov	a,r7
	add	a,#__st_esc_sq_bracket_colors_458753_206
	mov	dpl,a
	mov	a,r6
	addc	a,#(__st_esc_sq_bracket_colors_458753_206 >> 8)
	mov	dph,a
	clr	a
	movc	a,@a+dptr
	mov	r7,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrput
;	vt100.c:577: vga_setBackColor(term->back_color); 
	mov	dpl,r7
	push	ar7
	push	ar6
	push	ar5
	lcall	_vga_setBackColor
	pop	ar5
	pop	ar6
	pop	ar7
	pop	ar7
	pop	ar6
	pop	ar5
	ljmp	00173$
00175$:
;	vt100.c:580: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:581: break;
	ljmp	00200$
;	vt100.c:584: case '@': // Insert Characters          
00176$:
;	vt100.c:585: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:586: break; 
	ljmp	00200$
;	vt100.c:587: case 'r': // Set scroll region (top and bottom margins)
00177$:
;	vt100.c:590: if(term->narg == 2 && term->args[0] < term->args[1]){
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	cjne	r5,#0x02,00460$
	sjmp	00461$
00460$:
	ljmp	00179$
00461$:
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r6,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r5,a
	inc	r0
	mov	ar7,@r0
	mov	a,#0x02
	add	a,r6
	mov	r2,a
	clr	a
	addc	a,r5
	mov	r3,a
	mov	ar4,r7
	mov	dpl,r6
	mov	dph,r5
	mov	b,r7
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	lcall	__gptrget
	mov	@r0,a
	inc	dptr
	lcall	__gptrget
	inc	r0
	mov	@r0,a
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r5,a
	inc	dptr
	lcall	__gptrget
	mov	r7,a
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,r5
	inc	r0
	mov	a,@r0
	subb	a,r7
	jnc	00179$
;	vt100.c:593: term->scroll_start_row = term->args[0] - 1;
	mov	r0,_bp
	inc	r0
	mov	a,_bp
	add	a,#0x04
	mov	r1,a
	mov	a,#0x05
	add	a,@r0
	mov	@r1,a
	clr	a
	inc	r0
	addc	a,@r0
	inc	r1
	mov	@r1,a
	inc	r0
	mov	a,@r0
	inc	r1
	mov	@r1,a
	mov	a,_bp
	add	a,#0x09
	mov	r0,a
	mov	ar7,@r0
	dec	r7
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	mov	a,r7
	lcall	__gptrput
;	vt100.c:594: term->scroll_end_row = term->args[1] - 1; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x06
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	dec	r2
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,r2
	lcall	__gptrput
;	vt100.c:595: uint16_t top_margin = term->scroll_start_row * VT100_CHAR_HEIGHT;
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__gptrget
	mov	r7,a
	rlc	a
	subb	a,acc
;	vt100.c:596: uint16_t bottom_margin = VT100_SCREEN_HEIGHT -
	mov	a,r2
	rlc	a
	subb	a,acc
	mov	r5,a
	mov	a,#0x18
	clr	c
	subb	a,r2
	mov	r2,a
	clr	a
	subb	a,r5
;	vt100.c:598: vga_setScrollMargins(top_margin, bottom_margin);
	push	ar2
	mov	dpl,r7
	lcall	_vga_setScrollMargins
	dec	sp
	sjmp	00180$
00179$:
;	vt100.c:601: _vt100_resetScroll(); 
	lcall	__vt100_resetScroll
00180$:
;	vt100.c:603: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:604: break;  
	ljmp	00200$
;	vt100.c:607: case '=':{ // argument follows... 
00184$:
;	vt100.c:609: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:610: break; 
;	vt100.c:612: case '?': // '[?' escape mode
	sjmp	00200$
00185$:
;	vt100.c:613: term->state = _st_esc_question;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_esc_question
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_esc_question >> 8)
	lcall	__gptrput
;	vt100.c:614: break; 
;	vt100.c:615: default: { // unknown sequence
	sjmp	00200$
00186$:
;	vt100.c:617: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:623: break;
;	vt100.c:625: default: { // switch (ev)
	sjmp	00200$
00194$:
;	vt100.c:627: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:629: }
00200$:
;	vt100.c:630: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_st_esc_left_br'
;------------------------------------------------------------
;ev                        Allocated to stack - _bp -3
;arg                       Allocated to stack - _bp -4
;term                      Allocated to registers r5 r6 r7 
;------------------------------------------------------------
;	vt100.c:632: STATE(_st_esc_left_br, term, ev, arg) {
;	-----------------------------------------
;	 function _st_esc_left_br
;	-----------------------------------------
__st_esc_left_br:
	push	_bp
	mov	_bp,sp
	mov	r5,dpl
	mov	r6,dph
	mov	r7,b
;	vt100.c:633: switch(ev){
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	cjne	@r0,#0x01,00109$
;	vt100.c:635: switch(arg) {  
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x30,00129$
	sjmp	00105$
00129$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x41,00130$
	sjmp	00105$
00130$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x42,00131$
	sjmp	00105$
00131$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x4f,00106$
;	vt100.c:640: case 'O':
00105$:
;	vt100.c:642: term->state = _st_idle;
	mov	a,#0x16
	add	a,r5
	mov	r2,a
	clr	a
	addc	a,r6
	mov	r3,a
	mov	ar4,r7
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:643: break;
;	vt100.c:644: default:
	sjmp	00109$
00106$:
;	vt100.c:645: term->state = _st_idle;
	mov	a,#0x16
	add	a,r5
	mov	r5,a
	clr	a
	addc	a,r6
	mov	r6,a
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:649: }
00109$:
;	vt100.c:650: }
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_st_esc_right_br'
;------------------------------------------------------------
;ev                        Allocated to stack - _bp -3
;arg                       Allocated to stack - _bp -4
;term                      Allocated to registers r5 r6 r7 
;------------------------------------------------------------
;	vt100.c:652: STATE(_st_esc_right_br, term, ev, arg) {
;	-----------------------------------------
;	 function _st_esc_right_br
;	-----------------------------------------
__st_esc_right_br:
	push	_bp
	mov	_bp,sp
	mov	r5,dpl
	mov	r6,dph
	mov	r7,b
;	vt100.c:653: switch(ev){
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	cjne	@r0,#0x01,00109$
;	vt100.c:655: switch(arg) {  
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x30,00129$
	sjmp	00105$
00129$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x41,00130$
	sjmp	00105$
00130$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x42,00131$
	sjmp	00105$
00131$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x4f,00106$
;	vt100.c:660: case 'O':
00105$:
;	vt100.c:662: term->state = _st_idle;
	mov	a,#0x16
	add	a,r5
	mov	r2,a
	clr	a
	addc	a,r6
	mov	r3,a
	mov	ar4,r7
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:663: break;
;	vt100.c:664: default:
	sjmp	00109$
00106$:
;	vt100.c:665: term->state = _st_idle;
	mov	a,#0x16
	add	a,r5
	mov	r5,a
	clr	a
	addc	a,r6
	mov	r6,a
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:669: }
00109$:
;	vt100.c:670: }
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_st_esc_hash'
;------------------------------------------------------------
;ev                        Allocated to stack - _bp -3
;arg                       Allocated to stack - _bp -4
;term                      Allocated to registers r5 r6 r7 
;------------------------------------------------------------
;	vt100.c:672: STATE(_st_esc_hash, term, ev, arg) {
;	-----------------------------------------
;	 function _st_esc_hash
;	-----------------------------------------
__st_esc_hash:
	push	_bp
	mov	_bp,sp
	mov	r5,dpl
	mov	r6,dph
	mov	r7,b
;	vt100.c:673: switch(ev){
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	cjne	@r0,#0x01,00106$
;	vt100.c:675: switch(arg) {  
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x38,00103$
;	vt100.c:679: term->state = _st_idle;
	mov	a,#0x16
	add	a,r5
	mov	r2,a
	clr	a
	addc	a,r6
	mov	r3,a
	mov	ar4,r7
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:680: break;
;	vt100.c:682: default:
	sjmp	00106$
00103$:
;	vt100.c:683: term->state = _st_idle;
	mov	a,#0x16
	add	a,r5
	mov	r5,a
	clr	a
	addc	a,r6
	mov	r6,a
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:686: }
00106$:
;	vt100.c:687: }
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_st_escape'
;------------------------------------------------------------
;ev                        Allocated to stack - _bp -3
;arg                       Allocated to stack - _bp -4
;term                      Allocated to stack - _bp +1
;c                         Allocated to stack - _bp +4
;c                         Allocated to stack - _bp +4
;c                         Allocated to stack - _bp +4
;c                         Allocated to stack - _bp +4
;------------------------------------------------------------
;	vt100.c:689: STATE(_st_escape, term, ev, arg) {
;	-----------------------------------------
;	 function _st_escape
;	-----------------------------------------
__st_escape:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
	inc	sp
	inc	sp
;	vt100.c:692: switch(ev){
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	cjne	@r0,#0x01,00269$
	sjmp	00270$
00269$:
	ljmp	00129$
00270$:
;	vt100.c:699: switch(arg){
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x1b,00271$
	ljmp	00143$
00271$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x23,00272$
	ljmp	00108$
00272$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x28,00273$
	ljmp	00104$
00273$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x29,00274$
	ljmp	00106$
00274$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x37,00275$
	ljmp	00115$
00275$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x38,00276$
	ljmp	00117$
00276$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x3c,00277$
	ljmp	00125$
00277$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x3d,00278$
	ljmp	00118$
00278$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x3e,00279$
	ljmp	00119$
00279$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x44,00280$
	ljmp	00111$
00280$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x45,00281$
	ljmp	00113$
00281$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x48,00282$
	ljmp	00125$
00282$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x4d,00283$
	ljmp	00112$
00283$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x4e,00284$
	ljmp	00125$
00284$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x4f,00285$
	ljmp	00125$
00285$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x50,00286$
	ljmp	00110$
00286$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x5a,00287$
	ljmp	00120$
00287$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x5b,00288$
	sjmp	00102$
00288$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x63,00289$
	ljmp	00121$
00289$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x73,00290$
	ljmp	00115$
00290$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x75,00291$
	ljmp	00117$
00291$:
	ljmp	00127$
;	vt100.c:700: case '[': { // command
00102$:
;	vt100.c:702: CLEAR_ARGS; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	clr	a
	lcall	__gptrput
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	clr	a
	mov	@r0,a
	inc	r0
	mov	@r0,a
00132$:
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,#0x04
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00103$
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,@r0
	add	a,@r0
	mov	r5,a
	inc	r0
	mov	a,@r0
	rlc	a
	mov	r7,a
	mov	a,r5
	add	a,r2
	mov	r5,a
	mov	a,r7
	addc	a,r3
	mov	r7,a
	mov	ar6,r4
	mov	dpl,r5
	mov	dph,r7
	mov	b,r6
	clr	a
	lcall	__gptrput
	inc	dptr
	lcall	__gptrput
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	inc	@r0
	cjne	@r0,#0x00,00293$
	inc	r0
	inc	@r0
00293$:
	sjmp	00132$
00103$:
;	vt100.c:703: term->state = _st_esc_sq_bracket;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_esc_sq_bracket
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_esc_sq_bracket >> 8)
	lcall	__gptrput
;	vt100.c:704: break;
	ljmp	00143$
;	vt100.c:706: case '(': /* ESC ( */  
00104$:
;	vt100.c:707: CLEAR_ARGS;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	clr	a
	lcall	__gptrput
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	clr	a
	mov	@r0,a
	inc	r0
	mov	@r0,a
00135$:
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,#0x04
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00105$
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,@r0
	add	a,@r0
	mov	r2,a
	inc	r0
	mov	a,@r0
	rlc	a
	mov	r4,a
	mov	a,r2
	add	a,r5
	mov	r2,a
	mov	a,r4
	addc	a,r6
	mov	r4,a
	mov	ar3,r7
	mov	dpl,r2
	mov	dph,r4
	mov	b,r3
	clr	a
	lcall	__gptrput
	inc	dptr
	lcall	__gptrput
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	inc	@r0
	cjne	@r0,#0x00,00295$
	inc	r0
	inc	@r0
00295$:
	sjmp	00135$
00105$:
;	vt100.c:708: term->state = _st_esc_left_br;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_esc_left_br
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_esc_left_br >> 8)
	lcall	__gptrput
;	vt100.c:709: break; 
	ljmp	00143$
;	vt100.c:710: case ')': /* ESC ) */  
00106$:
;	vt100.c:711: CLEAR_ARGS;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	clr	a
	lcall	__gptrput
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	clr	a
	mov	@r0,a
	inc	r0
	mov	@r0,a
00138$:
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,#0x04
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00107$
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,@r0
	add	a,@r0
	mov	r2,a
	inc	r0
	mov	a,@r0
	rlc	a
	mov	r4,a
	mov	a,r2
	add	a,r5
	mov	r2,a
	mov	a,r4
	addc	a,r6
	mov	r4,a
	mov	ar3,r7
	mov	dpl,r2
	mov	dph,r4
	mov	b,r3
	clr	a
	lcall	__gptrput
	inc	dptr
	lcall	__gptrput
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	inc	@r0
	cjne	@r0,#0x00,00297$
	inc	r0
	inc	@r0
00297$:
	sjmp	00138$
00107$:
;	vt100.c:712: term->state = _st_esc_right_br;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_esc_right_br
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_esc_right_br >> 8)
	lcall	__gptrput
;	vt100.c:713: break;  
	ljmp	00143$
;	vt100.c:714: case '#': // ESC # 
00108$:
;	vt100.c:715: CLEAR_ARGS;
	mov	r0,_bp
	inc	r0
	mov	a,#0x0c
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	clr	a
	lcall	__gptrput
	mov	r0,_bp
	inc	r0
	mov	a,#0x0d
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	clr	a
	mov	@r0,a
	inc	r0
	mov	@r0,a
00141$:
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,#0x04
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00109$
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	mov	a,@r0
	add	a,@r0
	mov	r2,a
	inc	r0
	mov	a,@r0
	rlc	a
	mov	r4,a
	mov	a,r2
	add	a,r5
	mov	r2,a
	mov	a,r4
	addc	a,r6
	mov	r4,a
	mov	ar3,r7
	mov	dpl,r2
	mov	dph,r4
	mov	b,r3
	clr	a
	lcall	__gptrput
	inc	dptr
	lcall	__gptrput
	mov	a,_bp
	add	a,#0x04
	mov	r0,a
	inc	@r0
	cjne	@r0,#0x00,00299$
	inc	r0
	inc	@r0
00299$:
	sjmp	00141$
00109$:
;	vt100.c:716: term->state = _st_esc_hash;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_esc_hash
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_esc_hash >> 8)
	lcall	__gptrput
;	vt100.c:717: break;  
	ljmp	00143$
;	vt100.c:718: case 'P': //ESC P (DCS, Device Control String)
00110$:
;	vt100.c:719: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:720: break;
	ljmp	00143$
;	vt100.c:721: case 'D': // moves cursor down one line and scrolls if necessary
00111$:
;	vt100.c:723: _vt100_move(term, 0, 1); 
	mov	a,#0x01
	push	acc
	clr	a
	push	acc
	push	acc
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_move
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:724: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:725: break; 
	ljmp	00143$
;	vt100.c:726: case 'M': // Cursor up
00112$:
;	vt100.c:728: _vt100_move(term, 0, -1); 
	mov	a,#0xff
	push	acc
	push	acc
	clr	a
	push	acc
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_move
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:729: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:730: break; 
	ljmp	00143$
;	vt100.c:731: case 'E': // next line
00113$:
;	vt100.c:733: _vt100_move(term, 0, 1);
	mov	a,#0x01
	push	acc
	clr	a
	push	acc
	push	acc
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_move
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:734: term->cursor_x = 0; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	clr	a
	lcall	__gptrput
;	vt100.c:735: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:736: break;  
	ljmp	00143$
;	vt100.c:738: case 's':  
00115$:
;	vt100.c:739: term->saved_cursor_x = term->cursor_x;
	mov	r0,_bp
	inc	r0
	mov	a,#0x03
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrput
;	vt100.c:740: term->saved_cursor_y = term->cursor_y;
	mov	r0,_bp
	inc	r0
	mov	a,#0x04
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrput
;	vt100.c:741: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:742: break;  
	ljmp	00143$
;	vt100.c:744: case 'u': 
00117$:
;	vt100.c:745: term->cursor_x = term->saved_cursor_x;
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	r0,_bp
	inc	r0
	mov	a,#0x03
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrput
;	vt100.c:746: term->cursor_y = term->saved_cursor_y; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x02
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	r0,_bp
	inc	r0
	mov	a,#0x04
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrput
;	vt100.c:747: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:748: break; 
	ljmp	00143$
;	vt100.c:749: case '=': // Keypad into applications mode 
00118$:
;	vt100.c:750: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:751: break; 
	ljmp	00143$
;	vt100.c:752: case '>': // Keypad into numeric mode   
00119$:
;	vt100.c:753: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:754: break;  
	ljmp	00143$
;	vt100.c:755: case 'Z': // Report terminal type 
00120$:
;	vt100.c:757: term->send_response("\033[?1;0c");  
	mov	r0,_bp
	inc	r0
	mov	a,#0x18
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r5,a
	inc	dptr
	lcall	__gptrget
	mov	r6,a
	push	ar6
	push	ar5
	lcall	00300$
	sjmp	00301$
00300$:
	push	ar5
	push	ar6
	mov	dptr,#___str_1
	mov	b,#0x80
	ret
00301$:
	pop	ar5
	pop	ar6
;	vt100.c:760: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:761: break;    
	ljmp	00143$
;	vt100.c:762: case 'c': // Reset terminal to initial state 
00121$:
;	vt100.c:763: _vt100_reset();
	lcall	__vt100_reset
;	vt100.c:764: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:765: break;  
;	vt100.c:769: case '<': // Exit vt52 mode
	sjmp	00143$
00125$:
;	vt100.c:771: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:772: break; 
;	vt100.c:777: default: { // unknown sequence - return to normal mode
	sjmp	00143$
00127$:
;	vt100.c:778: term->state = _st_idle;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:783: break;
;	vt100.c:785: default: {
	sjmp	00143$
00129$:
;	vt100.c:787: term->state = _st_idle; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_idle
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_idle >> 8)
	lcall	__gptrput
;	vt100.c:789: }
00143$:
;	vt100.c:790: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function '_st_idle'
;------------------------------------------------------------
;ev                        Allocated to stack - _bp -3
;arg                       Allocated to stack - _bp -4
;term                      Allocated to stack - _bp +1
;tab_stop                  Allocated to registers 
;to_put                    Allocated to registers 
;------------------------------------------------------------
;	vt100.c:793: STATE(_st_idle, term, ev, arg) {
;	-----------------------------------------
;	 function _st_idle
;	-----------------------------------------
__st_idle:
	push	_bp
	mov	_bp,sp
	push	dpl
	push	dph
	push	b
;	vt100.c:796: switch(ev){
	mov	a,_bp
	add	a,#0xfd
	mov	r0,a
	cjne	@r0,#0x01,00164$
	sjmp	00165$
00164$:
	ljmp	00117$
00165$:
;	vt100.c:798: switch(arg){
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x05,00166$
	sjmp	00102$
00166$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x07,00167$
	ljmp	00117$
00167$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x08,00168$
	ljmp	00105$
00168$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x09,00169$
	ljmp	00107$
00169$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x0a,00170$
	sjmp	00103$
00170$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x0d,00171$
	ljmp	00104$
00171$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x1b,00172$
	ljmp	00112$
00172$:
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	cjne	@r0,#0x7f,00173$
	ljmp	00106$
00173$:
	ljmp	00113$
;	vt100.c:800: case 5: // AnswerBack for vt100's  
00102$:
;	vt100.c:801: term->send_response("X"); // should send SCCS_ID?
	mov	r0,_bp
	inc	r0
	mov	a,#0x18
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	inc	dptr
	lcall	__gptrget
	mov	r3,a
	push	ar3
	push	ar2
	lcall	00174$
	sjmp	00175$
00174$:
	push	ar2
	push	ar3
	mov	dptr,#___str_2
	mov	b,#0x80
	ret
00175$:
	pop	ar2
	pop	ar3
;	vt100.c:802: break;  
	ljmp	00117$
;	vt100.c:803: case '\n': { // new line
00103$:
;	vt100.c:804: _vt100_move(term, 0, 1);
	mov	a,#0x01
	push	acc
	clr	a
	push	acc
	push	acc
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_move
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:805: term->cursor_x = 0; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	clr	a
	lcall	__gptrput
;	vt100.c:808: break;
	ljmp	00117$
;	vt100.c:810: case '\r': { // carrage return (0x0d)
00104$:
;	vt100.c:811: term->cursor_x = 0; 
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	clr	a
	lcall	__gptrput
;	vt100.c:814: break;
	ljmp	00117$
;	vt100.c:816: case '\b': { // backspace 0x08
00105$:
;	vt100.c:817: _vt100_move(term, -1, 0); 
	clr	a
	push	acc
	push	acc
	dec	a
	push	acc
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_move
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:821: break;
	ljmp	00117$
;	vt100.c:823: case KEY_DEL: { // del - delete character under cursor
00106$:
;	vt100.c:827: _vt100_putc(term, ' ');
	mov	a,#0x20
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_putc
	dec	sp
;	vt100.c:828: _vt100_move(term, -1, 0);
	clr	a
	push	acc
	push	acc
	dec	a
	push	acc
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_move
	mov	a,sp
	add	a,#0xfc
	mov	sp,a
;	vt100.c:830: break;
	ljmp	00117$
;	vt100.c:832: case '\t': { // tab
00107$:
;	vt100.c:835: int to_put = tab_stop - (term->cursor_x % tab_stop); 
	mov	r0,_bp
	inc	r0
	mov	a,#0x01
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	inc	r0
	mov	ar4,@r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	lcall	__gptrget
	mov	r2,a
	rlc	a
	subb	a,acc
	mov	r4,a
	mov	a,#0x04
	push	acc
	clr	a
	push	acc
	mov	dpl,r2
	mov	dph,r4
	lcall	__modsint
	mov	r3,dpl
	mov	r4,dph
	dec	sp
	dec	sp
	mov	a,#0x04
	clr	c
	subb	a,r3
	mov	r3,a
	clr	a
	subb	a,r4
	mov	r4,a
;	vt100.c:836: while(to_put--) _vt100_putc(term, ' ');
00108$:
	mov	ar2,r3
	mov	ar7,r4
	dec	r3
	cjne	r3,#0xff,00176$
	dec	r4
00176$:
	mov	a,r2
	orl	a,r7
	jz	00117$
	push	ar4
	push	ar3
	mov	a,#0x20
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_putc
	dec	sp
	pop	ar3
	pop	ar4
;	vt100.c:844: case KEY_ESC: {// escape
	sjmp	00108$
00112$:
;	vt100.c:845: term->state = _st_escape;
	mov	r0,_bp
	inc	r0
	mov	a,#0x16
	add	a,@r0
	mov	r5,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r6,a
	inc	r0
	mov	ar7,@r0
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	mov	a,#__st_escape
	lcall	__gptrput
	inc	dptr
	mov	a,#(__st_escape >> 8)
	lcall	__gptrput
;	vt100.c:846: break;
;	vt100.c:848: default: {
	sjmp	00117$
00113$:
;	vt100.c:849: _vt100_putc(term, arg);
	mov	a,_bp
	add	a,#0xfc
	mov	r0,a
	mov	a,@r0
	push	acc
	mov	r0,_bp
	inc	r0
	mov	dpl,@r0
	inc	r0
	mov	dph,@r0
	inc	r0
	mov	b,@r0
	lcall	__vt100_putc
	dec	sp
;	vt100.c:856: }
00117$:
;	vt100.c:857: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'vt100_init'
;------------------------------------------------------------
;send_response             Allocated to registers r6 r7 
;------------------------------------------------------------
;	vt100.c:860: void vt100_init(void (*send_response)(char *str)){
;	-----------------------------------------
;	 function vt100_init
;	-----------------------------------------
_vt100_init:
	mov	r6,dpl
	mov	r7,dph
;	vt100.c:861: term.send_response = send_response; 
	mov	((_term + 0x0018) + 0),r6
	mov	((_term + 0x0018) + 1),r7
;	vt100.c:862: _vt100_reset(); 
;	vt100.c:863: }
	ljmp	__vt100_reset
;------------------------------------------------------------
;Allocation info for local variables in function 'vt100_putc'
;------------------------------------------------------------
;c                         Allocated to registers r7 
;------------------------------------------------------------
;	vt100.c:866: void vt100_putc(uint8_t c){
;	-----------------------------------------
;	 function vt100_putc
;	-----------------------------------------
_vt100_putc:
;	vt100.c:900: putchar(c);
	mov	r6,#0x00
	mov	dph,r6
;	vt100.c:902: }
	ljmp	_putchar
;------------------------------------------------------------
;Allocation info for local variables in function 'vt100_puts'
;------------------------------------------------------------
;str                       Allocated to registers 
;------------------------------------------------------------
;	vt100.c:904: void vt100_puts(const char *str){
;	-----------------------------------------
;	 function vt100_puts
;	-----------------------------------------
_vt100_puts:
	mov	r5,dpl
	mov	r6,dph
	mov	r7,b
;	vt100.c:905: while(*str){
00101$:
	mov	dpl,r5
	mov	dph,r6
	mov	b,r7
	lcall	__gptrget
	mov	r4,a
	jz	00104$
;	vt100.c:906: vt100_putc(*str++);
	inc	r5
	cjne	r5,#0x00,00116$
	inc	r6
00116$:
	mov	dpl,r4
	push	ar7
	push	ar6
	push	ar5
	lcall	_vt100_putc
	pop	ar5
	pop	ar6
	pop	ar7
	sjmp	00101$
00104$:
;	vt100.c:908: }
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'spf'
;------------------------------------------------------------
;s                         Allocated to stack - _bp -5
;args                      Allocated to stack - _bp +2
;fmt                       Allocated to registers r7 
;c                         Allocated to registers r5 
;d                         Allocated to registers r4 
;b                         Allocated to registers r7 
;sloc0                     Allocated to stack - _bp +1
;------------------------------------------------------------
;	vt100.c:912: void spf(uint8_t *s, ...) {
;	-----------------------------------------
;	 function spf
;	-----------------------------------------
_spf:
	push	_bp
	mov	_bp,sp
	inc	sp
	inc	sp
;	vt100.c:914: uint8_t fmt = 0, c, d, b = 0;
;	vt100.c:916: va_start(args, s);
	clr	a
	mov	r7,a
	mov	r6,a
	mov	a,_bp
	add	a,#0xfb
	mov	r5,a
	mov	r0,_bp
	inc	r0
	inc	r0
	mov	@r0,ar5
	mov	a,_bp
	add	a,#0xfb
	mov	r0,a
	mov	ar2,@r0
	inc	r0
	mov	ar3,@r0
	inc	r0
	mov	ar4,@r0
	mov	r5,#0x00
00111$:
;	vt100.c:918: for(; *s; ) {
	mov	dpl,r2
	mov	dph,r3
	mov	b,r4
	mov	r0,_bp
	inc	r0
	lcall	__gptrget
	mov	@r0,a
	mov	r0,_bp
	inc	r0
	mov	a,@r0
	jnz	00145$
	ljmp	00120$
00145$:
;	vt100.c:920: switch (fmt) {
	cjne	r7,#0x00,00146$
	sjmp	00101$
00146$:
	cjne	r7,#0x25,00147$
	sjmp	00105$
00147$:
	cjne	r7,#0x64,00148$
	sjmp	00106$
00148$:
	ljmp	00107$
;	vt100.c:921: case 0:
00101$:
;	vt100.c:922: if (*s == '%') fmt = *s;
	mov	r0,_bp
	inc	r0
	cjne	@r0,#0x25,00103$
	push	ar5
	mov	r0,_bp
	inc	r0
	mov	ar5,@r0
	mov	ar7,r5
	pop	ar5
	ljmp	00107$
00103$:
;	vt100.c:923: else buf[b++] = *s;
	push	ar5
	mov	ar5,r6
	inc	r6
	mov	a,r5
	add	a,#_buf
	mov	r0,a
	mov	r1,_bp
	inc	r1
	mov	a,@r1
	mov	@r0,a
;	vt100.c:924: break;
	pop	ar5
	ljmp	00107$
;	vt100.c:925: case '%':
00105$:
;	vt100.c:926: fmt = *s;
	push	ar2
	push	ar3
	push	ar4
	mov	r0,_bp
	inc	r0
	mov	ar4,@r0
	mov	ar7,r4
;	vt100.c:927: c = (uint8_t)va_arg(args, uint16_t);
	mov	r0,_bp
	inc	r0
	inc	r0
	mov	a,@r0
	add	a,#0xfe
	mov	r4,a
	mov	r0,_bp
	inc	r0
	inc	r0
	mov	@r0,ar4
	mov	ar1,r4
	mov	ar5,@r1
;	vt100.c:929: break;
	pop	ar4
	pop	ar3
	pop	ar2
;	vt100.c:930: case 'd':
	sjmp	00107$
00106$:
;	vt100.c:932: buf[b++] = (d = c / 10) + '0';
	push	ar2
	push	ar3
	push	ar4
	mov	a,r6
	inc	a
	mov	r7,a
	mov	a,r6
	add	a,#_buf
	mov	r1,a
	mov	ar3,r5
	mov	r4,#0x00
	push	ar7
	push	ar5
	push	ar2
	push	ar1
	mov	a,#0x0a
	push	acc
	clr	a
	push	acc
	mov	dpl,r3
	mov	dph,r4
	lcall	__divsint
	mov	r3,dpl
	dec	sp
	dec	sp
	pop	ar1
	pop	ar2
	pop	ar5
	pop	ar7
	mov	ar4,r3
	mov	a,#0x30
	add	a,r3
	mov	@r1,a
;	vt100.c:933: c -= d * 10;
	mov	a,r4
	mov	b,#0x0a
	mul	ab
	mov	r4,a
	mov	ar3,r5
	mov	a,r3
	clr	c
	subb	a,r4
	mov	r5,a
;	vt100.c:934: buf[b++] = c + '0';	
	mov	a,r7
	mov	r4,a
	inc	a
	mov	r6,a
	mov	a,r4
	add	a,#_buf
	mov	r1,a
	mov	ar4,r5
	mov	a,#0x30
	add	a,r4
	mov	@r1,a
;	vt100.c:935: fmt = 0;
	mov	r7,#0x00
;	vt100.c:936: continue;
	pop	ar4
	pop	ar3
	pop	ar2
	ljmp	00111$
;	vt100.c:937: }
00107$:
;	vt100.c:938: s++;
	inc	r2
	cjne	r2,#0x00,00151$
	inc	r3
00151$:
	mov	a,_bp
	add	a,#0xfb
	mov	r0,a
	mov	@r0,ar2
	inc	r0
	mov	@r0,ar3
	inc	r0
	mov	@r0,ar4
	ljmp	00111$
00120$:
	mov	a,_bp
	add	a,#0xfb
	mov	r0,a
	mov	@r0,ar2
	inc	r0
	mov	@r0,ar3
	inc	r0
	mov	@r0,ar4
;	vt100.c:940: buf[b] = 0;
	mov	a,r6
	add	a,#_buf
	mov	r0,a
	mov	@r0,#0x00
;	vt100.c:942: va_end(args);
;	vt100.c:943: }
	mov	sp,_bp
	pop	_bp
	ret
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;c                         Allocated to registers r7 
;c                         Allocated to registers r6 r7 
;c                         Allocated to registers r6 r7 
;text                      Allocated to stack - _bp +1
;c                         Allocated to stack - _bp +10
;c                         Allocated to registers r6 r7 
;c                         Allocated to registers r6 r7 
;c                         Allocated to registers r6 r7 
;c                         Allocated to registers r6 r7 
;c                         Allocated to registers r6 r7 
;c                         Allocated to registers r6 r7 
;------------------------------------------------------------
;	vt100.c:945: void main(void) {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
_main:
	push	_bp
	mov	a,sp
	mov	_bp,a
	add	a,#0x0b
	mov	sp,a
;	vt100.c:949: vga_init();
	lcall	_vga_init
;	vt100.c:951: vt100_init(NULL);
	mov	dptr,#0x0000
	lcall	_vt100_init
;	vt100.c:975: vt100_puts("\033[c\033[2J\033[m\033[r\033[?6l\033[1;1H");
	mov	dptr,#___str_6
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:979: for(c = 0; c < VT100_WIDTH; c++){
	mov	r7,#0x00
00118$:
;	vt100.c:980: vt100_putc('*'); 
	mov	dpl,#0x2a
	push	ar7
	lcall	_vt100_putc
	pop	ar7
;	vt100.c:979: for(c = 0; c < VT100_WIDTH; c++){
	inc	r7
	cjne	r7,#0x50,00314$
00314$:
	jc	00118$
;	vt100.c:984: for(c = 0; c < VT100_HEIGHT; c++){
	mov	r7,#0x00
00120$:
;	vt100.c:985: spf("\033[%d;1H*\033[%d;%dH*", c + 1, c + 1, VT100_WIDTH);
	mov	ar5,r7
	mov	r6,#0x00
	inc	r5
	cjne	r5,#0x00,00316$
	inc	r6
00316$:
	push	ar7
	mov	a,#0x50
	push	acc
	clr	a
	push	acc
	push	ar5
	push	ar6
	push	ar5
	push	ar6
	mov	a,#___str_7
	push	acc
	mov	a,#(___str_7 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_spf
	mov	a,sp
	add	a,#0xf7
	mov	sp,a
;	vt100.c:986: vt100_puts(buf);
	mov	dptr,#_buf
	mov	b,#0x40
	lcall	_vt100_puts
	pop	ar7
;	vt100.c:984: for(c = 0; c < VT100_HEIGHT; c++){
	inc	r7
	cjne	r7,#0x18,00317$
00317$:
	jc	00120$
;	vt100.c:990: spf("\033[%d;1H", VT100_HEIGHT);
	mov	a,#0x18
	push	acc
	clr	a
	push	acc
	mov	a,#___str_8
	push	acc
	mov	a,#(___str_8 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_spf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	vt100.c:991: vt100_puts(buf); 
	mov	dptr,#_buf
	mov	b,#0x40
	lcall	_vt100_puts
;	vt100.c:992: for(c = 0; c < VT100_WIDTH; c++){
	mov	r7,#0x00
00122$:
;	vt100.c:993: vt100_putc('*');
	mov	dpl,#0x2a
	push	ar7
	lcall	_vt100_putc
	pop	ar7
;	vt100.c:992: for(c = 0; c < VT100_WIDTH; c++){
	inc	r7
	cjne	r7,#0x50,00319$
00319$:
	jc	00122$
;	vt100.c:996: vt100_puts("\033[2;2H");
	mov	dptr,#___str_9
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:998: for(c = 0; c < VT100_WIDTH - 2; c++){
	mov	r7,#0x00
00124$:
;	vt100.c:999: vt100_putc('+'); 
	mov	dpl,#0x2b
	push	ar7
	lcall	_vt100_putc
	pop	ar7
;	vt100.c:998: for(c = 0; c < VT100_WIDTH - 2; c++){
	inc	r7
	cjne	r7,#0x4e,00321$
00321$:
	jc	00124$
;	vt100.c:1002: for(c = 1; c < VT100_HEIGHT - 1; c++){
	mov	r7,#0x01
00126$:
;	vt100.c:1003: spf("\033[%d;2H+\033[%d;%dH+", c + 1, c + 1, VT100_WIDTH - 1);
	mov	ar5,r7
	mov	r6,#0x00
	inc	r5
	cjne	r5,#0x00,00323$
	inc	r6
00323$:
	push	ar7
	mov	a,#0x4f
	push	acc
	clr	a
	push	acc
	push	ar5
	push	ar6
	push	ar5
	push	ar6
	mov	a,#___str_10
	push	acc
	mov	a,#(___str_10 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_spf
	mov	a,sp
	add	a,#0xf7
	mov	sp,a
;	vt100.c:1004: vt100_puts(buf);
	mov	dptr,#_buf
	mov	b,#0x40
	lcall	_vt100_puts
	pop	ar7
;	vt100.c:1002: for(c = 1; c < VT100_HEIGHT - 1; c++){
	inc	r7
	cjne	r7,#0x17,00324$
00324$:
	jc	00126$
;	vt100.c:1007: spf("\033[%d;2H", VT100_HEIGHT - 1);
	mov	a,#0x17
	push	acc
	clr	a
	push	acc
	mov	a,#___str_11
	push	acc
	mov	a,#(___str_11 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_spf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	vt100.c:1008: vt100_puts(buf); 
	mov	dptr,#_buf
	mov	b,#0x40
	lcall	_vt100_puts
;	vt100.c:1009: for(c = 0; c < VT100_WIDTH - 2; c++){
	mov	r7,#0x00
00128$:
;	vt100.c:1010: vt100_putc('+');
	mov	dpl,#0x2b
	push	ar7
	lcall	_vt100_putc
	pop	ar7
;	vt100.c:1009: for(c = 0; c < VT100_WIDTH - 2; c++){
	inc	r7
	cjne	r7,#0x4e,00326$
00326$:
	jc	00128$
;	vt100.c:1021: vt100_puts("\033[10;6H");
	mov	dptr,#___str_12
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1022: for(int c = 0; c < 30; c++){
	mov	r6,#0x00
	mov	r7,#0x00
00131$:
	clr	c
	mov	a,r6
	subb	a,#0x1e
	mov	a,r7
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00107$
;	vt100.c:1023: vt100_putc('E');
	mov	dpl,#0x45
	push	ar7
	push	ar6
	lcall	_vt100_putc
	pop	ar6
	pop	ar7
;	vt100.c:1022: for(int c = 0; c < 30; c++){
	inc	r6
	cjne	r6,#0x00,00131$
	inc	r7
	sjmp	00131$
00107$:
;	vt100.c:1026: vt100_puts("\033[11;6H");
	mov	dptr,#___str_13
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1028: vt100_puts("\0337\033[35;10H\0338");
	mov	dptr,#___str_14
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1029: vt100_puts("E\033[11;35HE");
	mov	dptr,#___str_15
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1031: vt100_puts("\033[12;6HE\033[28CE");
	mov	dptr,#___str_16
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1033: vt100_puts("\033[30D\033[BE\033[28CE");
	mov	dptr,#___str_17
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1034: vt100_puts("\033[15;6H\033[AE\033[28CE");
	mov	dptr,#___str_18
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1035: vt100_puts("\033[15;6HE\033[15;35HE"); 
	mov	dptr,#___str_19
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1037: vt100_puts("\033[16;6H");
	mov	dptr,#___str_20
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1038: for(int c = 0; c < 30; c++){
	mov	r6,#0x00
	mov	r7,#0x00
00134$:
	clr	c
	mov	a,r6
	subb	a,#0x1e
	mov	a,r7
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00108$
;	vt100.c:1039: vt100_putc('E');
	mov	dpl,#0x45
	push	ar7
	push	ar6
	lcall	_vt100_putc
	pop	ar6
	pop	ar7
;	vt100.c:1038: for(int c = 0; c < 30; c++){
	inc	r6
	cjne	r6,#0x00,00134$
	inc	r7
	sjmp	00134$
00108$:
;	vt100.c:1042: const char *text[] = {"This must be an unbroken a", "rea of text with 1 free bo", "rder around the text.     "};
	mov	r1,_bp
	inc	r1
	mov	@r1,#___str_3
	inc	r1
	mov	@r1,#(___str_3 >> 8)
	inc	r1
	mov	@r1,#0x80
	dec	r1
	dec	r1
	mov	a,#0x03
	add	a,r1
	mov	r0,a
	mov	@r0,#___str_4
	inc	r0
	mov	@r0,#(___str_4 >> 8)
	inc	r0
	mov	@r0,#0x80
	mov	a,#0x06
	add	a,r1
	mov	r0,a
	mov	@r0,#___str_5
	inc	r0
	mov	@r0,#(___str_5 >> 8)
	inc	r0
	mov	@r0,#0x80
;	vt100.c:1043: for(int c = 0; c < 3; c++){
	mov	a,_bp
	add	a,#0x0a
	mov	r0,a
	clr	a
	mov	@r0,a
	inc	r0
	mov	@r0,a
	mov	r4,a
	mov	r5,a
00137$:
	mov	a,_bp
	add	a,#0x0a
	mov	r0,a
	clr	c
	mov	a,@r0
	subb	a,#0x03
	inc	r0
	mov	a,@r0
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00109$
;	vt100.c:1044: spf("\033[%d;8H", c + 12);
	mov	a,_bp
	add	a,#0x0a
	mov	r0,a
	mov	a,#0x0c
	add	a,@r0
	mov	r2,a
	clr	a
	inc	r0
	addc	a,@r0
	mov	r3,a
	push	ar5
	push	ar4
	push	ar1
	push	ar2
	push	ar3
	mov	a,#___str_21
	push	acc
	mov	a,#(___str_21 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_spf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	vt100.c:1045: vt100_puts(buf);
	mov	dptr,#_buf
	mov	b,#0x40
	lcall	_vt100_puts
	pop	ar1
	pop	ar4
	pop	ar5
;	vt100.c:1046: vt100_puts(text[c]);
	mov	a,r4
	add	a,r1
	mov	r0,a
	push	ar1
	mov	ar2,@r0
	inc	r0
	mov	ar3,@r0
	inc	r0
	mov	ar7,@r0
	dec	r0
	dec	r0
	mov	dpl,r2
	mov	dph,r3
	mov	b,r7
	push	ar5
	push	ar4
	push	ar1
	lcall	_vt100_puts
	pop	ar1
	pop	ar4
	pop	ar5
;	vt100.c:1043: for(int c = 0; c < 3; c++){
	mov	a,#0x03
	add	a,r4
	mov	r4,a
	clr	a
	addc	a,r5
	mov	r5,a
	mov	a,_bp
	add	a,#0x0a
	mov	r0,a
	inc	@r0
	cjne	@r0,#0x00,00333$
	inc	r0
	inc	@r0
00333$:
	pop	ar1
	ljmp	00137$
00109$:
;	vt100.c:1051: vt100_puts("\033[10;40H"); 
	mov	dptr,#___str_22
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1052: for(int c = 0; c < 10; c++){
	mov	r6,#0x00
	mov	r7,#0x00
00140$:
	clr	c
	mov	a,r6
	subb	a,#0x0a
	mov	a,r7
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00110$
;	vt100.c:1054: vt100_puts("E\033[1CF\033[3D\033[B");
	mov	dptr,#___str_23
	mov	b,#0x80
	push	ar7
	push	ar6
	lcall	_vt100_puts
	pop	ar6
	pop	ar7
;	vt100.c:1052: for(int c = 0; c < 10; c++){
	inc	r6
	cjne	r6,#0x00,00140$
	inc	r7
	sjmp	00140$
00110$:
;	vt100.c:1064: vt100_puts("\033[24;1H");
	mov	dptr,#___str_24
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1065: for(int c = 0; c < 7; c++){
	mov	r6,#0x00
	mov	r7,#0x00
00143$:
	clr	c
	mov	a,r6
	subb	a,#0x07
	mov	a,r7
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00111$
;	vt100.c:1066: vt100_puts("\033D");
	mov	dptr,#___str_25
	mov	b,#0x80
	push	ar7
	push	ar6
	lcall	_vt100_puts
	pop	ar6
	pop	ar7
;	vt100.c:1065: for(int c = 0; c < 7; c++){
	inc	r6
	cjne	r6,#0x00,00143$
	inc	r7
	sjmp	00143$
00111$:
;	vt100.c:1069: getchar();
	lcall	_getchar
;	vt100.c:1070: getchar();
	lcall	_getchar
;	vt100.c:1075: vt100_puts("\033[1;1H");
	mov	dptr,#___str_26
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1076: for(int c = 0; c < 7; c++){
	mov	r6,#0x00
	mov	r7,#0x00
00146$:
	clr	c
	mov	a,r6
	subb	a,#0x07
	mov	a,r7
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00112$
;	vt100.c:1077: vt100_puts("\033M");
	mov	dptr,#___str_27
	mov	b,#0x80
	push	ar7
	push	ar6
	lcall	_vt100_puts
	pop	ar6
	pop	ar7
;	vt100.c:1076: for(int c = 0; c < 7; c++){
	inc	r6
	cjne	r6,#0x00,00146$
	inc	r7
	sjmp	00146$
00112$:
;	vt100.c:1080: getchar();
	lcall	_getchar
;	vt100.c:1082: vt100_puts("\033[24;1H");
	mov	dptr,#___str_24
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1083: for(int c = 0; c < 7; c++){
	mov	r6,#0x00
	mov	r7,#0x00
00149$:
	clr	c
	mov	a,r6
	subb	a,#0x07
	mov	a,r7
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00113$
;	vt100.c:1084: vt100_puts("\033D");
	mov	dptr,#___str_25
	mov	b,#0x80
	push	ar7
	push	ar6
	lcall	_vt100_puts
	pop	ar6
	pop	ar7
;	vt100.c:1083: for(int c = 0; c < 7; c++){
	inc	r6
	cjne	r6,#0x00,00149$
	inc	r7
	sjmp	00149$
00113$:
;	vt100.c:1089: for(c = 1; c < VT100_WIDTH - 1; c++){
	mov	r7,#0x01
00151$:
;	vt100.c:1092: spf("\033[1;%dH*\033[B\033[D+\033[A", c + 1); 
	mov	ar5,r7
	mov	r6,#0x00
	inc	r5
	cjne	r5,#0x00,00342$
	inc	r6
00342$:
	push	ar7
	push	ar5
	push	ar6
	mov	a,#___str_28
	push	acc
	mov	a,#(___str_28 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_spf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	vt100.c:1093: vt100_puts(buf);
	mov	dptr,#_buf
	mov	b,#0x40
	lcall	_vt100_puts
	pop	ar7
;	vt100.c:1089: for(c = 1; c < VT100_WIDTH - 1; c++){
	inc	r7
	cjne	r7,#0x4f,00343$
00343$:
	jc	00151$
;	vt100.c:1096: for(c = 2; c < VT100_WIDTH - 2; c++){
	mov	r7,#0x02
00153$:
;	vt100.c:1098: spf("\033[32;%dH \033[B\033[D \033[A", c + 1); 
	mov	ar5,r7
	mov	r6,#0x00
	inc	r5
	cjne	r5,#0x00,00345$
	inc	r6
00345$:
	push	ar7
	push	ar5
	push	ar6
	mov	a,#___str_29
	push	acc
	mov	a,#(___str_29 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_spf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	vt100.c:1099: vt100_puts(buf);
	mov	dptr,#_buf
	mov	b,#0x40
	lcall	_vt100_puts
	pop	ar7
;	vt100.c:1096: for(c = 2; c < VT100_WIDTH - 2; c++){
	inc	r7
	cjne	r7,#0x4e,00346$
00346$:
	jc	00153$
;	vt100.c:1103: for(int c = 1; c < VT100_HEIGHT; c++){
	mov	r6,#0x01
	mov	r7,#0x00
00156$:
	clr	c
	mov	a,r6
	subb	a,#0x18
	mov	a,r7
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00116$
;	vt100.c:1104: spf("\033[%d;1H*+\033[%d;%dH+*", c + 1, c + 1, VT100_WIDTH - 1);
	mov	a,#0x01
	add	a,r6
	mov	r4,a
	clr	a
	addc	a,r7
	mov	r5,a
	push	ar5
	push	ar4
	mov	a,#0x4f
	push	acc
	clr	a
	push	acc
	push	ar4
	push	ar5
	push	ar4
	push	ar5
	mov	a,#___str_30
	push	acc
	mov	a,#(___str_30 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_spf
	mov	a,sp
	add	a,#0xf7
	mov	sp,a
;	vt100.c:1105: vt100_puts(buf);
	mov	dptr,#_buf
	mov	b,#0x40
	lcall	_vt100_puts
	pop	ar4
	pop	ar5
;	vt100.c:1103: for(int c = 1; c < VT100_HEIGHT; c++){
	mov	ar6,r4
	mov	ar7,r5
	sjmp	00156$
00116$:
;	vt100.c:1109: for(int c = 1; c < VT100_WIDTH - 1; c++){
	mov	r6,#0x01
	mov	r7,#0x00
00159$:
	clr	c
	mov	a,r6
	subb	a,#0x4f
	mov	a,r7
	xrl	a,#0x80
	subb	a,#0x80
	jnc	00117$
;	vt100.c:1110: spf("\033[23;%dH+\033[B\033[D*\033[A", c + 1); 
	mov	a,#0x01
	add	a,r6
	mov	r4,a
	clr	a
	addc	a,r7
	mov	r5,a
	push	ar5
	push	ar4
	push	ar4
	push	ar5
	mov	a,#___str_31
	push	acc
	mov	a,#(___str_31 >> 8)
	push	acc
	mov	a,#0x80
	push	acc
	lcall	_spf
	mov	a,sp
	add	a,#0xfb
	mov	sp,a
;	vt100.c:1111: vt100_puts(buf);
	mov	dptr,#_buf
	mov	b,#0x40
	lcall	_vt100_puts
	pop	ar4
	pop	ar5
;	vt100.c:1109: for(int c = 1; c < VT100_WIDTH - 1; c++){
	mov	ar6,r4
	mov	ar7,r5
	sjmp	00159$
00117$:
;	vt100.c:1114: vt100_puts("\033[13;6HShould see two columns of E F"); 
	mov	dptr,#___str_32
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1115: vt100_puts("\033[14;6HText box must start at line 3"); 
	mov	dptr,#___str_33
	mov	b,#0x80
	lcall	_vt100_puts
;	vt100.c:1118: getchar();
	lcall	_getchar
;	vt100.c:1141: }
	mov	sp,_bp
	pop	_bp
	ret
	.area CSEG    (CODE)
	.area CONST   (CODE)
__vt100_putc_hex_131072_135:
	.ascii "0123456789abcdef"
	.db 0x00
__st_esc_sq_bracket_colors_458753_206:
	.db #0x00	; 0
	.db #0x01	; 1
	.db #0x02	; 2
	.db #0x04	; 4
	.db #0x03	; 3
	.db #0x05	; 5
	.db #0x06	; 6
	.db #0x07	; 7
	.area CONST   (CODE)
___str_1:
	.db 0x1b
	.ascii "[?1;0c"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_2:
	.ascii "X"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_3:
	.ascii "This must be an unbroken a"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_4:
	.ascii "rea of text with 1 free bo"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_5:
	.ascii "rder around the text.     "
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_6:
	.db 0x1b
	.ascii "[c"
	.db 0x1b
	.ascii "[2J"
	.db 0x1b
	.ascii "[m"
	.db 0x1b
	.ascii "[r"
	.db 0x1b
	.ascii "[?6l"
	.db 0x1b
	.ascii "[1;1H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_7:
	.db 0x1b
	.ascii "[%d;1H*"
	.db 0x1b
	.ascii "[%d;%dH*"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_8:
	.db 0x1b
	.ascii "[%d;1H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_9:
	.db 0x1b
	.ascii "[2;2H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_10:
	.db 0x1b
	.ascii "[%d;2H+"
	.db 0x1b
	.ascii "[%d;%dH+"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_11:
	.db 0x1b
	.ascii "[%d;2H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_12:
	.db 0x1b
	.ascii "[10;6H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_13:
	.db 0x1b
	.ascii "[11;6H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_14:
	.db 0x1b
	.ascii "7"
	.db 0x1b
	.ascii "[35;10H"
	.db 0x1b
	.ascii "8"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_15:
	.ascii "E"
	.db 0x1b
	.ascii "[11;35HE"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_16:
	.db 0x1b
	.ascii "[12;6HE"
	.db 0x1b
	.ascii "[28CE"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_17:
	.db 0x1b
	.ascii "[30D"
	.db 0x1b
	.ascii "[BE"
	.db 0x1b
	.ascii "[28CE"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_18:
	.db 0x1b
	.ascii "[15;6H"
	.db 0x1b
	.ascii "[AE"
	.db 0x1b
	.ascii "[28CE"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_19:
	.db 0x1b
	.ascii "[15;6HE"
	.db 0x1b
	.ascii "[15;35HE"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_20:
	.db 0x1b
	.ascii "[16;6H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_21:
	.db 0x1b
	.ascii "[%d;8H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_22:
	.db 0x1b
	.ascii "[10;40H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_23:
	.ascii "E"
	.db 0x1b
	.ascii "[1CF"
	.db 0x1b
	.ascii "[3D"
	.db 0x1b
	.ascii "[B"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_24:
	.db 0x1b
	.ascii "[24;1H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_25:
	.db 0x1b
	.ascii "D"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_26:
	.db 0x1b
	.ascii "[1;1H"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_27:
	.db 0x1b
	.ascii "M"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_28:
	.db 0x1b
	.ascii "[1;%dH*"
	.db 0x1b
	.ascii "[B"
	.db 0x1b
	.ascii "[D+"
	.db 0x1b
	.ascii "[A"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_29:
	.db 0x1b
	.ascii "[32;%dH "
	.db 0x1b
	.ascii "[B"
	.db 0x1b
	.ascii "[D "
	.db 0x1b
	.ascii "[A"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_30:
	.db 0x1b
	.ascii "[%d;1H*+"
	.db 0x1b
	.ascii "[%d;%dH+*"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_31:
	.db 0x1b
	.ascii "[23;%dH+"
	.db 0x1b
	.ascii "[B"
	.db 0x1b
	.ascii "[D*"
	.db 0x1b
	.ascii "[A"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_32:
	.db 0x1b
	.ascii "[13;6HShould see two columns of E F"
	.db 0x00
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_33:
	.db 0x1b
	.ascii "[14;6HText box must start at line 3"
	.db 0x00
	.area CSEG    (CODE)
	.area XINIT   (CODE)
	.area CABS    (ABS,CODE)
