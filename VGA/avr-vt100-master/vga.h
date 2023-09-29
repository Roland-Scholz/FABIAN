#pragma once
typedef unsigned char uint8_t;
typedef signed char int8_t;
typedef int int16_t;
typedef unsigned int uint16_t;

// Color definitions

#define	VGA_BLACK   0X0000
#define	VGA_BLUE    0X001F
#define	VGA_RED     0XF800
#define	VGA_GREEN   0X07E0
#define VGA_CYAN    0X07FF
#define VGA_MAGENTA 0XF81F
#define VGA_YELLOW  0XFFE0  
#define VGA_WHITE   0XFFFF

#define VGA_WIDTH 80
#define VGA_HEIGHT 24

#ifdef __cplusplus
extern "C" {
#endif

void vga_init(void);
void vga_drawChar(uint8_t x, uint8_t y, uint8_t c);
void vga_setBackColor(uint8_t col); 
void vga_setFrontColor(uint8_t col);
void vga_fillRect(uint8_t x, uint8_t y, uint8_t w, uint8_t h,
  uint8_t color);

void vga_setScrollStart(uint8_t start); 
void vga_setScrollMargins(uint8_t top, uint8_t bottom);

static uint8_t vga_color, scroll_start, scroll_top, scroll_bottom;

void vga_init(void) {
	//printf_tiny("vga_init\n");
}


void vga_drawChar(uint8_t x, uint8_t y, uint8_t c) {
	//printf_tiny("vga_drawChar %d %d %d %x\n", x, y, c, vga_color);
	uint8_t *mem = (uint8_t *)(0x8000);
	
	mem += (x + y * VGA_WIDTH) << 1;
	
	*(mem) = c;
	mem++;
	*(mem) = vga_color;
}

void vga_setBackColor(uint8_t col) {
	//printf_tiny("vga_setBackColor %d\n", col);
	
	vga_color &= 0xf0;
	vga_color |= (col & 0x0f);
	
}

void vga_setFrontColor(uint8_t col) {
	//printf_tiny("vga_setFrontColor %d\n", col);
	vga_color &= 0x0f;
	vga_color |= (col & 0xf0);
}

void vga_fillRect(uint8_t x, uint8_t y, uint8_t w, uint8_t h,
  uint8_t color) {
	
	uint8_t i, j, c, i0, j0;
	uint8_t *mem;
	
	//printf_tiny("vga_fillRect %d %d %d %d %d \n", x, y, w, h, color);
	
	c = color << 4;
	
	for (i = y, i0 = y + h; i < i0; i++) {
		mem = 0x8000 + ((i * VGA_WIDTH) << 1);
		for (j = x, j0 = x + w; j < j0; j++) {
			*mem = 1;
			mem++;
			*mem = 1;
			mem++;
		}
	}
	
}

void vga_setScrollStart(uint8_t start) {
	//printf_tiny("vga_setScrollStart %d\n", start);
	scroll_start = start;
}

void vga_setScrollMargins(uint8_t top, uint8_t bottom) {
	//printf_tiny("vga_setScrollMargins %d %d\n", top, bottom);
	scroll_top = top;
	scroll_bottom = bottom;
}


#ifdef __cplusplus
}
#endif
