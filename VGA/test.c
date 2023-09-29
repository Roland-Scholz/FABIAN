typedef unsigned char uchar;

#include <stdio.h>
#include <mcs51/at89x52.h>

void dummy () {
__asm
	.ascii "                "
	.ascii "                "
	.ascii "                "
	.ascii "                "
	.ascii "                "
	.ascii "                "
	.ascii "                "
	.ascii "                "
	.ascii "                "
	.ascii "            "
	
	.db 0xA5,0xE5,0xE0,0xA5		;SIGNITURE BYTES
	.db 35,0,0,0			;ID (35=PROG), id (253=startup)
	.db 0,0,0,0			;PROMPT CODE VECTOR
	.db 0,0,0,0			;RESERVED
	.db 0,0,0,0			;RESERVED
	.db 0,0,0,0			;RESERVED
	.db 0,0,0,0			;USER DEFINED
	.db 255,255,255,255		;LENGTH AND CHECKSUM (255=UNUSED)
	.ascii "test.c"			;MAX 31 CHARACTERS, PLUS THE ZERO
	.db 0,0
	.ascii "        "
	.ascii "        "
	.ascii "       "
	;.db 0
	
__endasm;
}

void main(int argc, char** argv) {
  uchar c = 128;

  printf_tiny("Hallo Welt!\n");
  printf_tiny("Hallo Welt!\n");
  
  printf_tiny("char\t %d %x\n", sizeof(char), 0xCAFE);
  printf_tiny("int\t %d\n", sizeof(int));
  printf_tiny("char\t %d\n", c);
  
  //putchar('X');
  
  getchar();
 // __asm
 // 	ljmp 0
 // __endasm;
}

void putchar (char c) {
	while (!TI) /* assumes UART is initialized */
	;
	TI = 0;
	SBUF = c;
	
	if (c == '\n') putchar('\r');
}

char getchar() {
	while (!RI)
	;
	RI=0;
	
	return SBUF;
}

