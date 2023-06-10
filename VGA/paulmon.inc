phex1		EQU 002Eh		;print a single hex digit
cout		EQU 0030h            	;Send Acc to serial port
cin		EQU 0032h             	;Get Acc from serial port
phex		EQU 0034h            	;Print Hex value of Acc
phex16		EQU 0036h          	;Print Hex value of DPTR
pstr		EQU 0038h            	;Print string pointed to by DPTR,
                                	;must be terminated by 0 or a high bit set
                                	;pressing ESC will stop the printing
ghex		EQU 003Ah            	;Get Hex input into Acc
                                	;Carry set if ESC has been pressed
ghex16		EQU 003Ch          	;Get Hex input into DPTR
                                	;Carry set if ESC has been pressed
esc		EQU 003Eh             	;Check for ESC key
					;Carry set if ESC has been pressed
upper		EQU 0040h           	;Convert Acc to uppercase
					;Non-ASCII values are unchanged
autobaud	EQU 0042h        	;Initialize serial port
pcstr		EQU 0045h		;print string in compressed format (no docs)
pcstr_h		EQU 0045h
newline		EQU 0048h		;print CR/LF (13 and 10)
lenstr		EQU 004Ah		;return the length of a string @DPTR (in R0)
pint8u		EQU 004Dh		;print Acc at an integer, 0 to 255
pint8		EQU 0050h		;print Acc at an integer, -128 to 127
pint16u		EQU 0053h		;print DPTR as an integer, 0 to 65535
smart_wr	EQU 0056h		;write Acc @DPTR (RAM or flash), C=1 if error
prgm		EQU 0059h		;write Acc @DPTR to Flash ROM, C=1 if error
erall		EQU 005Ch		;erase the Flash ROM chip, C=1 if error
find		EQU 005Fh		;find next prog header in memory
cin_filter	EQU 0062h		;like cin, but scan for arrow keys, pgup/pgdn
asc2hex		EQU 0065h		;convert character 0-9,A-F to number 0-15.