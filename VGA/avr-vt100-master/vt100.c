#include <at89x52.h>
#include <stdio.h>
#include <ctype.h>
#include <math.h>
#include <stdarg.h>

#include "vt100.h"
#include "vga.h"

int putchar (int c) {
	
	while (!TI) /* assumes UART is initialized */
	;
	TI = 0;
	SBUF = c;
	
	if ((char)c == '\n') putchar('\r');
	return c;
}

int getchar(void) {
	while (!RI)
	;
	RI=0;
	
	return SBUF;

}
#define KEY_ESC 0x1b
#define KEY_DEL 0x7f
#define KEY_BELL 0x07

#define STATE(NAME, TERM, EV, ARG) void NAME(struct vt100 *TERM, uint8_t EV, uint8_t ARG) 

// states 
enum {
	STATE_IDLE,
	STATE_ESCAPE,
	STATE_COMMAND
};

// events that are passed into states
enum {
	EV_CHAR = 1,
};

#define MAX_COMMAND_ARGS 4
static struct vt100 {
	union flags {
		uint8_t val;
		struct {
			// 0 = cursor remains on last column when it gets there
			// 1 = lines wrap after last column to next line
			uint8_t cursor_wrap : 1; 
			uint8_t scroll_mode : 1;
			uint8_t origin_mode : 1; 
		}; 
	} flags;
	
	//uint16_t screen_width, screen_height;
	// cursor position on the screen (0, 0) = top left corner. 
	int8_t cursor_x, cursor_y;
	int8_t saved_cursor_x, saved_cursor_y; // used for cursor save restore
	int8_t scroll_start_row, scroll_end_row; 
	// character width and height
	uint8_t char_width, char_height;
	// colors used for rendering current characters
	uint8_t back_color, front_color;
	// the starting y-position of the screen scroll
	int8_t scroll_value; 
	// command arguments that get parsed as they appear in the terminal
	uint8_t narg; uint16_t args[MAX_COMMAND_ARGS];
	// current arg pointer (we use it for parsing) 
	uint8_t carg;
	
	void (*state)(struct vt100 *term, uint8_t ev, uint8_t arg);
	void (*send_response)(char *str);
	void (*ret_state)(struct vt100 *term, uint8_t ev, uint8_t arg) ; 
} term;

STATE(_st_idle, term, ev, arg);
STATE(_st_esc_sq_bracket, term, ev, arg);
STATE(_st_esc_question, term, ev, arg);
STATE(_st_esc_hash, term, ev, arg);

void _vt100_reset(void){
	//term.screen_width = VT100_SCREEN_WIDTH;
  //term.screen_height = VT100_SCREEN_HEIGHT;
  term.char_height = 1;
  term.char_width = 1;
  term.back_color = 0x00;
  term.front_color = 0xff;
  term.cursor_x = term.cursor_y = term.saved_cursor_x = term.saved_cursor_y = 0;
  term.narg = 0;
  term.state = _st_idle;
  term.ret_state = 0;
  term.scroll_value = 0; 
  term.scroll_start_row = 0;
  term.scroll_end_row = VT100_HEIGHT; // outside of screen = whole screen scrollable
  term.flags.cursor_wrap = 0;
  term.flags.origin_mode = 0; 
  vga_setFrontColor(term.front_color);
	vga_setBackColor(term.back_color);
	vga_setScrollMargins(0, 0); 
	vga_setScrollStart(0); 
}

void _vt100_resetScroll(void){
	term.scroll_start_row = 0;
	term.scroll_end_row = VT100_HEIGHT;
	term.scroll_value = 0; 
	vga_setScrollMargins(0, 0);
	vga_setScrollStart(0); 
}

#define VT100_CURSOR_X(TERM) (TERM->cursor_x * TERM->char_width)

uint16_t VT100_CURSOR_Y(struct vt100 *t){
	// if within the top or bottom margin areas then normal addressing
	if(t->cursor_y < t->scroll_start_row || t->cursor_y >= t->scroll_end_row){
		return t->cursor_y * VT100_CHAR_HEIGHT; 
	} else {
		// otherwise we are inside scroll area
		uint16_t scroll_height = t->scroll_end_row - t->scroll_start_row;
		uint16_t row = t->cursor_y + t->scroll_value; 
		if(t->cursor_y + t->scroll_value >= t->scroll_end_row)
			row -= scroll_height; 
		// if scroll_value == 0: y = t->cursor_y;
		// if scroll_value == 1 && scroll_start_row == 2 && scroll_end_row == 38:
		// 		y = t->cursor_y + scroll_value; 
		//uint16_t row = (t->cursor_y - t->scroll_start_row) % scroll_height; 
		/*uint16_t skip = t->scroll_value - t->scroll_start_row; 
		uint16_t row = t->cursor_y + skip;
		uint16_t scroll_height = t->scroll_end_row - t->scroll_start_row; 
		//row = (row % scroll_height);// + t->scroll_start_row;*/
		return row * VT100_CHAR_HEIGHT; 
	}
	/*uint16_t y = 0;
	if(t->cursor_y >= t->top_margin && t->cursor_y < t->bottom_margin){
		y = t->cursor_y * VT100_CHAR_HEIGHT;
		if(t->scroll >= (t->top_margin * VT100_CHAR_HEIGHT)){
			y += t->scroll - t->top_margin * VT100_CHAR_HEIGHT;
		}
	} else if(t->cursor_y < t->top_margin){
		y = (t->cursor_y * VT100_CHAR_HEIGHT);
	} else if(t->cursor_y >= t->bottom_margin){
		y = (t->cursor_y * VT100_CHAR_HEIGHT);
		if(t->scroll >= (t->top_margin * VT100_CHAR_HEIGHT)){
			y += t->scroll - t->top_margin * VT100_CHAR_HEIGHT;
		}
	}
	//y = ((t->cursor_y - (VT100_HEIGHT - t->bottom_margin)) * VT100_CHAR_HEIGHT);// % VT100_SCREEN_HEIGHT;
	//y = ((t->cursor_y * VT100_CHAR_HEIGHT) + t->scroll) % VT100_SCREEN_HEIGHT; 
	return y % VT100_SCREEN_HEIGHT;*/
}

void _vt100_clearLines(struct vt100 *t, uint16_t start_line, uint16_t end_line){
	for(int c = start_line; c <= end_line; c++){
		uint16_t cy = t->cursor_y;
		t->cursor_y = c; 
		vga_fillRect(0, VT100_CURSOR_Y(t), VT100_SCREEN_WIDTH, VT100_CHAR_HEIGHT, 0x0000);
		t->cursor_y = cy;
	}
	/*uint16_t start = ((start_line * t->char_height) + t->scroll) % VT100_SCREEN_HEIGHT;
	uint16_t h = (end_line - start_line) * VT100_CHAR_HEIGHT;
	vga_fillRect(0, start, VT100_SCREEN_WIDTH, h, 0x0000); */
}

// scrolls the scroll region up (lines > 0) or down (lines < 0)
void _vt100_scroll(struct vt100 *t, int16_t lines){
	
	if(!lines) return;

	// get height of scroll area in rows
	uint16_t scroll_height = t->scroll_end_row - t->scroll_start_row;

	//printf_tiny("_vt100_scroll lines:%d scroll_start_row:%d scroll_end_row:%d\n", lines, t->scroll_start_row, t->scroll_end_row);


	// clearing of lines that we have scrolled up or down
	if(lines > 0){
		_vt100_clearLines(t, t->scroll_start_row, t->scroll_start_row+lines-1); 
		// update the scroll value (wraps around scroll_height)
		t->scroll_value = (t->scroll_value + lines) % scroll_height;
		// scrolling up so clear first line of scroll area
		//uint16_t y = (t->scroll_start_row + t->scroll_value) * VT100_CHAR_HEIGHT; 
		//vga_fillRect(0, y, VT100_SCREEN_WIDTH, lines * VT100_CHAR_HEIGHT, 0x0000);
	} else if(lines < 0){
		_vt100_clearLines(t, t->scroll_end_row - lines, t->scroll_end_row - 1); 
		// make sure that the value wraps down 
		t->scroll_value = (scroll_height + t->scroll_value + lines) % scroll_height; 
		// scrolling down - so clear last line of the scroll area
		//uint16_t y = (t->scroll_start_row + t->scroll_value) * VT100_CHAR_HEIGHT; 
		//vga_fillRect(0, y, VT100_SCREEN_WIDTH, lines * VT100_CHAR_HEIGHT, 0x0000);
	}
	uint16_t scroll_start = (t->scroll_start_row + t->scroll_value) * VT100_CHAR_HEIGHT; 
	vga_setScrollStart(scroll_start); 
	
	/*
	int16_t pixels = lines * VT100_CHAR_HEIGHT;
	uint16_t scroll_min = t->top_margin * VT100_CHAR_HEIGHT;
	uint16_t scroll_max = t->bottom_margin * VT100_CHAR_HEIGHT;

	// starting position must be between top and bottom margin
	// scroll_start == top margin - no scroll at all
	if(t->scroll >= scroll_min){
		// clear the top n lines
		vga_fillRect(0, t->scroll, VT100_SCREEN_WIDTH, pixels, 0x0000); 
		t->scroll += pixels;
	} else {
		vga_fillRect(0, scroll_min, VT100_SCREEN_WIDTH, pixels, 0x0000); 
		t->scroll = scroll_min + pixels;
	}
	t->scroll = t->scroll % VT100_SCREEN_HEIGHT; 
	vga_setScrollStart(t->scroll);*/
}

int16_t abs(int16_t x) {
	if (x < 0) return -x;
	return x;
}

// moves the cursor relative to current cursor position and scrolls the screen
void _vt100_move(struct vt100 *term, int16_t right_left, int16_t bottom_top){
	// calculate how many lines we need to move down or up if x movement goes outside screen
	int16_t new_x = right_left + term->cursor_x; 
	if(new_x > VT100_WIDTH){
		if(term->flags.cursor_wrap){
			bottom_top += new_x / VT100_WIDTH;
			term->cursor_x = new_x % VT100_WIDTH - 1;
		} else {
			term->cursor_x = VT100_WIDTH;
		}
	} else if(new_x < 0){
		bottom_top += new_x / VT100_WIDTH - 1;
		term->cursor_x = VT100_WIDTH - (abs(new_x) % VT100_WIDTH) + 1; 
	} else {
		term->cursor_x = new_x;
	}

	if(bottom_top){
		int16_t new_y = term->cursor_y + bottom_top;
		int16_t to_scroll = 0;
		// bottom margin 39 marks last line as static on 40 line display
		// therefore, we would scroll when new cursor has moved to line 39
		// (or we could use new_y > VT100_HEIGHT here
		// NOTE: new_y >= term->scroll_end_row ## to_scroll = (new_y - term->scroll_end_row) +1
		if(new_y >= term->scroll_end_row){
			//scroll = new_y / VT100_HEIGHT;
			//term->cursor_y = VT100_HEIGHT;
			to_scroll = (new_y - term->scroll_end_row) + 1; 
			// place cursor back within the scroll region
			term->cursor_y = term->scroll_end_row - 1; //new_y - to_scroll; 
			//scroll = new_y - term->bottom_margin; 
			//term->cursor_y = term->bottom_margin; 
		} else if(new_y < term->scroll_start_row){
			to_scroll = (new_y - term->scroll_start_row); 
			term->cursor_y = term->scroll_start_row; //new_y - to_scroll; 
			//scroll = new_y / (term->bottom_margin - term->top_margin) - 1;
			//term->cursor_y = term->top_margin; 
		} else {
			// otherwise we move as normal inside the screen
			term->cursor_y = new_y;
		}
		_vt100_scroll(term, to_scroll);
	}
}

void _vt100_drawCursor(struct vt100 *t){
	//uint16_t x = t->cursor_x * t->char_width;
	//uint16_t y = t->cursor_y * t->char_height;

	//vga_fillRect(x, y, t->char_width, t->char_height, t->front_color); 
}

// sends the character to the display and updates cursor position
void _vt100_putc(struct vt100 *t, uint8_t ch){
	//printf_tiny("_vt100_putc 1\n");

	if(ch < 0x20 || ch > 0x7e){
		static const char hex[] = "0123456789abcdef"; 
		_vt100_putc(t, '0'); 
		_vt100_putc(t, 'x'); 
		_vt100_putc(t, hex[((ch & 0xf0) >> 4)]);
		_vt100_putc(t, hex[(ch & 0x0f)]);
		return;
	}
	
	// calculate current cursor position in the display ram
	uint8_t x = VT100_CURSOR_X(t);
	uint8_t y = VT100_CURSOR_Y(t);
	
	vga_setFrontColor(t->front_color);
	vga_setBackColor(t->back_color); 
	vga_drawChar(x, y, ch);

	// move cursor right
	_vt100_move(t, 1, 0); 
	_vt100_drawCursor(t); 
}

STATE(_st_command_arg, term, ev, arg) {
	switch(ev){
		case EV_CHAR: {
			if(isdigit(arg)){ // a digit argument
				term->args[term->narg] = term->args[term->narg] * 10 + (arg - '0');
			} else if(arg == ';') { // separator
				term->narg++;
			} else { // no more arguments
				// go back to command state 
				term->narg++;
				if(term->ret_state){
					term->state = term->ret_state;
				}
				else {
					term->state = _st_idle;
				}
				// execute next state as well because we have already consumed a char!
				term->state(term, ev, arg);
			}
			break;
		}
	}
}

STATE(_st_esc_question, term, ev, arg) {
	// DEC mode commands
	//printf_tiny("_st_esc_question %d %d\n", ev, arg);
	switch(ev){
		case EV_CHAR: {
			if(isdigit(arg)){ // start of an argument
				term->ret_state = _st_esc_question; 
				_st_command_arg(term, ev, arg);
				term->state = _st_command_arg;
			} else if(arg == ';'){ // arg separator. 
				// skip. And also stay in the command state
			} else {
				switch(arg) {
					case 'l': 
						// dec mode: OFF (arg[0] = function)
					case 'h': {
						// dec mode: ON (arg[0] = function)
						switch(term->args[0]){
							case 1: { // cursor keys mode
								// h = esc 0 A for cursor up
								// l = cursor keys send ansi commands
								break;
							}
							case 2: { // ansi / vt52
								// h = ansi mode
								// l = vt52 mode
								break;
							}
							case 3: {
								// h = 132 chars per line
								// l = 80 chars per line
								break;
							}
							case 4: {
								// h = smooth scroll
								// l = jump scroll
								break;
							}
							case 5: {
								// h = black on white bg
								// l = white on black bg
								break;
							}
							case 6: {
								// h = cursor relative to scroll region
								// l = cursor independent of scroll region
								term->flags.origin_mode = (arg == 'h')?1:0; 
								break;
							}
							case 7: {
								// h = new line after last column
								// l = cursor stays at the end of line
								term->flags.cursor_wrap = (arg == 'h')?1:0; 
								break;
							}
							case 8: {
								// h = keys will auto repeat
								// l = keys do not auto repeat when held down
								break;
							}
							case 9: {
								// h = display interlaced
								// l = display not interlaced
								break;
							}
							// 10-38 - all quite DEC speciffic commands so omitted here
						}
						term->state = _st_idle;
						break; 
					}
					case 'i': /* Printing */  
					case 'n': /* Request printer status */
					default:  
						term->state = _st_idle; 
						break;
				}
				term->state = _st_idle;
			}
		}
	}
}

STATE(_st_esc_sq_bracket, term, ev, arg) {
	//printf_tiny("_st_esc_sq_bracket %d %d\n", (int)ev, (int)arg);
	switch(ev){
		case EV_CHAR: {
			if(isdigit(arg)){ // start of an argument
				term->ret_state = _st_esc_sq_bracket; 
				_st_command_arg(term, ev, arg);
				term->state = _st_command_arg;
			} else if(arg == ';'){ // arg separator. 
				// skip. And also stay in the command state
			} else { // otherwise we execute the command and go back to idle
				switch(arg){
					case 'A': {// move cursor up (cursor stops at top margin)
						int n = (term->narg > 0)?term->args[0]:1;
						term->cursor_y -= n;
						if(term->cursor_y < 0) term->cursor_y = 0; 
						term->state = _st_idle; 
						break;
					} 
					case 'B': { // cursor down (cursor stops at bottom margin)
						int n = (term->narg > 0)?term->args[0]:1;
						term->cursor_y += n;
						if(term->cursor_y > VT100_HEIGHT) term->cursor_y = VT100_HEIGHT; 
						term->state = _st_idle; 
						break;
					}
					case 'C': { // cursor right (cursor stops at right margin)
						int n = (term->narg > 0)?term->args[0]:1;
						term->cursor_x += n;
						if(term->cursor_x > VT100_WIDTH) term->cursor_x = VT100_WIDTH;
						term->state = _st_idle; 
						break;
					}
					case 'D': { // cursor left
						int n = (term->narg > 0)?term->args[0]:1;
						term->cursor_x -= n;
						if(term->cursor_x < 0) term->cursor_x = 0;
						term->state = _st_idle; 
						break;
					}
					case 'f': 
					case 'H': { // move cursor to position (default 0;0)
						// cursor stops at respective margins
						term->cursor_x = (term->narg >= 1)?(term->args[1]-1):0; 
						term->cursor_y = (term->narg == 2)?(term->args[0]-1):0;
						if(term->flags.origin_mode) {
							term->cursor_y += term->scroll_start_row;
							if(term->cursor_y >= term->scroll_end_row){
								term->cursor_y = term->scroll_end_row - 1;
							}
						}
						if(term->cursor_x > VT100_WIDTH) term->cursor_x = VT100_WIDTH;
						if(term->cursor_y > VT100_HEIGHT) term->cursor_y = VT100_HEIGHT; 
						term->state = _st_idle; 
						break;
					}
					case 'J':{// clear screen from cursor up or down
						uint16_t y = VT100_CURSOR_Y(term); 
						if(term->narg == 0 || (term->narg == 1 && term->args[0] == 0)){
							// clear down to the bottom of screen (including cursor)
							_vt100_clearLines(term, term->cursor_y, VT100_HEIGHT - 1); 
						} else if(term->narg == 1 && term->args[0] == 1){
							// clear top of screen to current line (including cursor)
							_vt100_clearLines(term, 0, term->cursor_y); 
						} else if(term->narg == 1 && term->args[0] == 2){
							// clear whole screen
							_vt100_clearLines(term, 0, VT100_HEIGHT - 1);
							// reset scroll value
							_vt100_resetScroll(); 
						}
						term->state = _st_idle; 
						break;
					}
					case 'K':{// clear line from cursor right/left
						uint16_t x = VT100_CURSOR_X(term);
						uint16_t y = VT100_CURSOR_Y(term);

						if(term->narg == 0 || (term->narg == 1 && term->args[0] == 0)){
							// clear to end of line (to \n or to edge?)
							// including cursor
							vga_fillRect(x, y, VT100_SCREEN_WIDTH - x, VT100_CHAR_HEIGHT, term->back_color);
						} else if(term->narg == 1 && term->args[0] == 1){
							// clear from left to current cursor position
							vga_fillRect(0, y, x + VT100_CHAR_WIDTH, VT100_CHAR_HEIGHT, term->back_color);
						} else if(term->narg == 1 && term->args[0] == 2){
							// clear whole current line
							vga_fillRect(0, y, VT100_SCREEN_WIDTH, VT100_CHAR_HEIGHT, term->back_color);
						}
						term->state = _st_idle; 
						break;
					}
					
					case 'L': // insert lines (args[0] = number of lines)
					case 'M': // delete lines (args[0] = number of lines)
						term->state = _st_idle;
						break; 
					case 'P': {// delete characters args[0] or 1 in front of cursor
						// TODO: this needs to correctly delete n chars
						int n = ((term->narg > 0)?term->args[0]:1);
						_vt100_move(term, -n, 0);
						for(int c = 0; c < n; c++){
							_vt100_putc(term, ' ');
						}
						term->state = _st_idle;
						break;
					}
					case 'c':{ // query device code
						//term->send_response("\e[?1;0c"); 
						term->state = _st_idle; 
						break; 
					}
					case 'x': {
						term->state = _st_idle;
						break;
					}
					case 's':{// save cursor pos
						term->saved_cursor_x = term->cursor_x;
						term->saved_cursor_y = term->cursor_y;
						term->state = _st_idle; 
						break;
					}
					case 'u':{// restore cursor pos
						term->cursor_x = term->saved_cursor_x;
						term->cursor_y = term->saved_cursor_y; 
						//_vt100_moveCursor(term, term->saved_cursor_x, term->saved_cursor_y);
						term->state = _st_idle; 
						break;
					}
					case 'h':
					case 'l': {
						term->state = _st_idle;
						break;
					}
					
					case 'g': {
						term->state = _st_idle;
						break;
					}
					case 'm': { // sets colors. Accepts up to 3 args
						// [m means reset the colors to default
						if(!term->narg){
							term->front_color = 0xff;
							term->back_color = 0x00;
						}
						while(term->narg){
							term->narg--; 
							int n = term->args[term->narg];
							static const uint8_t colors[] = {
								0x00, // black
								0x01, // red
								0x02, // green
								0x04, // yellow
								0x03, // blue
								0x05, // magenta
								0x06, // cyan
								0x07  // white
							};
							if(n == 0){ // all attributes off
								term->front_color = 0xff;
								term->back_color = 0x00;
								
								vga_setFrontColor(term->front_color);
								vga_setBackColor(term->back_color);
							}
							if(n >= 30 && n < 38){ // fg colors
								term->front_color = colors[n-30]; 
								vga_setFrontColor(term->front_color);
							} else if(n >= 40 && n < 48){
								term->back_color = colors[n-40]; 
								vga_setBackColor(term->back_color); 
							}
						}
						term->state = _st_idle; 
						break;
					}
					
					case '@': // Insert Characters          
						term->state = _st_idle;
						break; 
					case 'r': // Set scroll region (top and bottom margins)
						// the top value is first row of scroll region
						// the bottom value is the first row of static region after scroll
						if(term->narg == 2 && term->args[0] < term->args[1]){
							// [1;40r means scroll region between 8 and 312
							// bottom margin is 320 - (40 - 1) * 8 = 8 pix
							term->scroll_start_row = term->args[0] - 1;
							term->scroll_end_row = term->args[1] - 1; 
							uint16_t top_margin = term->scroll_start_row * VT100_CHAR_HEIGHT;
							uint16_t bottom_margin = VT100_SCREEN_HEIGHT -
								(term->scroll_end_row * VT100_CHAR_HEIGHT); 
							vga_setScrollMargins(top_margin, bottom_margin);
							//vga_setScrollStart(0); // reset scroll 
						} else {
							_vt100_resetScroll(); 
						}
						term->state = _st_idle; 
						break;  
					case 'i': // Printing  
					case 'y': // self test modes..
					case '=':{ // argument follows... 
						//term->state = _st_screen_mode;
						term->state = _st_idle; 
						break; 
					}
					case '?': // '[?' escape mode
						term->state = _st_esc_question;
						break; 
					default: { // unknown sequence
						
						term->state = _st_idle;
						break;
					}
				}
				//term->state = _st_idle;
			} // else
			break;
		}
		default: { // switch (ev)
			// for all other events restore normal mode
			term->state = _st_idle; 
		}
	}
}

STATE(_st_esc_left_br, term, ev, arg) {
	switch(ev){
		case EV_CHAR: {
			switch(arg) {  
				case 'A':  
				case 'B':  
					// translation map command?
				case '0':  
				case 'O':
					// another translation map command?
					term->state = _st_idle;
					break;
				default:
					term->state = _st_idle;
			}
			//term->state = _st_idle;
		}
	}
}

STATE(_st_esc_right_br, term, ev, arg) {
	switch(ev){
		case EV_CHAR: {
			switch(arg) {  
				case 'A':  
				case 'B':  
					// translation map command?
				case '0':  
				case 'O':
					// another translation map command?
					term->state = _st_idle;
					break;
				default:
					term->state = _st_idle;
			}
			//term->state = _st_idle;
		}
	}
}

STATE(_st_esc_hash, term, ev, arg) {
	switch(ev){
		case EV_CHAR: {
			switch(arg) {  
				case '8': {
					// self test: fill the screen with 'E'
					
					term->state = _st_idle;
					break;
				}
				default:
					term->state = _st_idle;
			}
		}
	}
}

STATE(_st_escape, term, ev, arg) {
	//printf_tiny("_st_escape %d %d\n", (int)ev, (int)arg);

	switch(ev){
		case EV_CHAR: {
			#define CLEAR_ARGS \
				{ term->narg = 0;\
				for(int c = 0; c < MAX_COMMAND_ARGS; c++)\
					term->args[c] = 0; }\
			
			switch(arg){
				case '[': { // command
					// prepare command state and switch to it
					CLEAR_ARGS; 
					term->state = _st_esc_sq_bracket;
					break;
				}
				case '(': /* ESC ( */  
					CLEAR_ARGS;
					term->state = _st_esc_left_br;
					break; 
				case ')': /* ESC ) */  
					CLEAR_ARGS;
					term->state = _st_esc_right_br;
					break;  
				case '#': // ESC # 
					CLEAR_ARGS;
					term->state = _st_esc_hash;
					break;  
				case 'P': //ESC P (DCS, Device Control String)
					term->state = _st_idle; 
					break;
				case 'D': // moves cursor down one line and scrolls if necessary
					// move cursor down one line and scroll window if at bottom line
					_vt100_move(term, 0, 1); 
					term->state = _st_idle;
					break; 
				case 'M': // Cursor up
					// move cursor up one line and scroll window if at top line
					_vt100_move(term, 0, -1); 
					term->state = _st_idle;
					break; 
				case 'E': // next line
					// same as '\r\n'
					_vt100_move(term, 0, 1);
					term->cursor_x = 0; 
					term->state = _st_idle;
					break;  
				case '7': // Save attributes and cursor position  
				case 's':  
					term->saved_cursor_x = term->cursor_x;
					term->saved_cursor_y = term->cursor_y;
					term->state = _st_idle;
					break;  
				case '8': // Restore them  
				case 'u': 
					term->cursor_x = term->saved_cursor_x;
					term->cursor_y = term->saved_cursor_y; 
					term->state = _st_idle;
					break; 
				case '=': // Keypad into applications mode 
					term->state = _st_idle;
					break; 
				case '>': // Keypad into numeric mode   
					term->state = _st_idle;
					break;  
				case 'Z': // Report terminal type 
					// vt 100 response
					term->send_response("\033[?1;0c");  
					// unknown terminal     
						//out("\033[?c");
					term->state = _st_idle;
					break;    
				case 'c': // Reset terminal to initial state 
					_vt100_reset();
					term->state = _st_idle;
					break;  
				case 'H': // Set tab in current position 
				case 'N': // G2 character set for next character only  
				case 'O': // G3 "               "     
				case '<': // Exit vt52 mode
					// ignore
					term->state = _st_idle;
					break; 
				case KEY_ESC: { // marks start of next escape sequence
					// stay in escape state
					break;
				}
				default: { // unknown sequence - return to normal mode
					term->state = _st_idle;
					break;
				}
			}
			#undef CLEAR_ARGS
			break;
		}
		default: {
			// for all other events restore normal mode
			term->state = _st_idle; 
		}
	}
}


STATE(_st_idle, term, ev, arg) {
	//printf_tiny("_st_idle %d %d\n", (int)ev, (int)arg);

	switch(ev){
		case EV_CHAR: {
			switch(arg){
				
				case 5: // AnswerBack for vt100's  
					term->send_response("X"); // should send SCCS_ID?
					break;  
				case '\n': { // new line
					_vt100_move(term, 0, 1);
					term->cursor_x = 0; 
					//_vt100_moveCursor(term, 0, term->cursor_y + 1);
					// do scrolling here! 
					break;
				}
				case '\r': { // carrage return (0x0d)
					term->cursor_x = 0; 
					//_vt100_move(term, 0, 1);
					//_vt100_moveCursor(term, 0, term->cursor_y); 
					break;
				}
				case '\b': { // backspace 0x08
					_vt100_move(term, -1, 0); 
					// backspace does not delete the character! Only moves cursor!
					//vga_drawChar(term->cursor_x * term->char_width,
					//	term->cursor_y * term->char_height, ' ');
					break;
				}
				case KEY_DEL: { // del - delete character under cursor
					// Problem: with current implementation, we can't move the rest of line
					// to the left as is the proper behavior of the delete character
					// fill the current position with background color
					_vt100_putc(term, ' ');
					_vt100_move(term, -1, 0);
					//_vt100_clearChar(term, term->cursor_x, term->cursor_y); 
					break;
				}
				case '\t': { // tab
					// tab fills characters on the line until we reach a multiple of tab_stop
					int tab_stop = 4;
					int to_put = tab_stop - (term->cursor_x % tab_stop); 
					while(to_put--) _vt100_putc(term, ' ');
					break;
				}
				case KEY_BELL: { // bell is sent by bash for ex. when doing tab completion
					// sound the speaker bell?
					// skip
					break; 
				}
				case KEY_ESC: {// escape
					term->state = _st_escape;
					break;
				}
				default: {
					_vt100_putc(term, arg);
					break;
				}
			}
			break;
		}
		default: {}
	}
}


void vt100_init(void (*send_response)(char *str)){
  term.send_response = send_response; 
	_vt100_reset(); 
}


void vt100_putc(uint8_t c){
	//printf_tiny("%d : ", c);
	/*char *buffer = 0; 
	switch(c){
		case KEY_UP:         buffer="\e[A";    break;
		case KEY_DOWN:       buffer="\e[B";    break;
		case KEY_RIGHT:      buffer="\e[C";    break;
		case KEY_LEFT:       buffer="\e[D";    break;
		case KEY_BACKSPACE:  buffer="\b";      break;
		case KEY_IC:         buffer="\e[2~";   break;
		case KEY_DC:         buffer="\e[3~";   break;
		case KEY_HOME:       buffer="\e[7~";   break;
		case KEY_END:        buffer="\e[8~";   break;
		case KEY_PPAGE:      buffer="\e[5~";   break;
		case KEY_NPAGE:      buffer="\e[6~";   break;
		case KEY_SUSPEND:    buffer="\x1A";    break;      // ctrl-z
		case KEY_F(1):       buffer="\e[[A";   break;
		case KEY_F(2):       buffer="\e[[B";   break;
		case KEY_F(3):       buffer="\e[[C";   break;
		case KEY_F(4):       buffer="\e[[D";   break;
		case KEY_F(5):       buffer="\e[[E";   break;
		case KEY_F(6):       buffer="\e[17~";  break;
		case KEY_F(7):       buffer="\e[18~";  break;
		case KEY_F(8):       buffer="\e[19~";  break;
		case KEY_F(9):       buffer="\e[20~";  break;
		case KEY_F(10):      buffer="\e[21~";  break;
	}
	if(buffer){
		while(*buffer){
			term.state(&term, EV_CHAR, *buffer++);
		}
	} else {
		term.state(&term, EV_CHAR, 0x0000 | c);
	}*/
	putchar(c);
	//term.state(&term, EV_CHAR, 0x0000 | c);
}

void vt100_puts(const char *str){
	while(*str){
		vt100_putc(*str++);
	}
}

static char buf[32]; 

void spf(uint8_t *s, ...) {
	va_list args;
	uint8_t fmt = 0, c, d, b = 0;
	
	va_start(args, s);
	
	for(; *s; ) {
		
		switch (fmt) {
			case 0:
				if (*s == '%') fmt = *s;
				else buf[b++] = *s;
				break;
			case '%':
				fmt = *s;
				c = (uint8_t)va_arg(args, uint16_t);
				//printf_tiny("c: %d\n", c);
				break;
			case 'd':
				//printf_tiny("c: %d\n", c);
				buf[b++] = (d = c / 10) + '0';
				c -= d * 10;
				buf[b++] = c + '0';	
				fmt = 0;
				continue;
		}
		s++;
	}
	buf[b] = 0;
	
	va_end(args);
}

void main(void) {
	uint8_t c;
	
	//uart_init(UART_BAUD_SELECT(38400, F_CPU));
	vga_init();
	//vga_setRotation(0);
	vt100_init(NULL);
	/*
	auto respond = [=](char *str){
		uart_puts(str); 
	}; 
	vt100_init(respond);
	*/
	

	// just clear the screen initially
	//for(int c = 0; c < 320; c++){
	//	vga_drawFastHLine(0, c, 320, 0x0000);
	//}

	//sei();
	
	// reset terminal and disable auto wrap
	//vt100_puts("hallo");
	
	
	//spf("hallo%d%d\n", 5, 6);
	//printf_tiny("%s", buf);
	
	// clear screen
	vt100_puts("\033[c\033[2J\033[m\033[r\033[?6l\033[1;1H");
	
	// draw a line of "*"
	
	for(c = 0; c < VT100_WIDTH; c++){
		vt100_putc('*'); 
	}

	// draw left and right border
	for(c = 0; c < VT100_HEIGHT; c++){
		spf("\033[%d;1H*\033[%d;%dH*", c + 1, c + 1, VT100_WIDTH);
		vt100_puts(buf);
	}

// draw bottom line
	spf("\033[%d;1H", VT100_HEIGHT);
	vt100_puts(buf); 
	for(c = 0; c < VT100_WIDTH; c++){
		vt100_putc('*');
	}
	// draw inner border of +
	vt100_puts("\033[2;2H");
	// draw a line of "*"
	for(c = 0; c < VT100_WIDTH - 2; c++){
		vt100_putc('+'); 
	}
	// draw left and right border
	for(c = 1; c < VT100_HEIGHT - 1; c++){
		spf("\033[%d;2H+\033[%d;%dH+", c + 1, c + 1, VT100_WIDTH - 1);
		vt100_puts(buf);
	}
	// draw bottom line
	spf("\033[%d;2H", VT100_HEIGHT - 1);
	vt100_puts(buf); 
	for(c = 0; c < VT100_WIDTH - 2; c++){
		vt100_putc('+');
	}

	// draw middle window
	// EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
	// E                            E
	// E This must be an unbroken a E
	// E rea of text with 1 free bo E
	// E rder around the text.      E
	// E                            E
	// EEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
	vt100_puts("\033[10;6H");
	for(int c = 0; c < 30; c++){
		vt100_putc('E');
	}
	// test normal movement
	vt100_puts("\033[11;6H");
	// test cursor store and restore...
	vt100_puts("\0337\033[35;10H\0338");
	vt100_puts("E\033[11;35HE");
	// goto 12;6, print E, move cursor 29 (already moved +1) to right and print E
	vt100_puts("\033[12;6HE\033[28CE");
	// move cursor 31 to left, 1 down, print E, move 30 right, print E
	vt100_puts("\033[30D\033[BE\033[28CE");
	vt100_puts("\033[15;6H\033[AE\033[28CE");
	vt100_puts("\033[15;6HE\033[15;35HE"); 
	
	vt100_puts("\033[16;6H");
	for(int c = 0; c < 30; c++){
		vt100_putc('E');
	}

	const char *text[] = {"This must be an unbroken a", "rea of text with 1 free bo", "rder around the text.     "};
	for(int c = 0; c < 3; c++){
		spf("\033[%d;8H", c + 12);
		vt100_puts(buf);
		vt100_puts(text[c]);
	}


	// now lets draw two parallel columns of Es
	vt100_puts("\033[10;40H"); 
	for(int c = 0; c < 10; c++){
		// draw E (cursor moves right), step one right, draw F, step 3 left and 1 down
		vt100_puts("E\033[1CF\033[3D\033[B");
	}
	
	
	// Test index (escD - down with scroll)
	// Test reverse index (escM)
	// next line (escE) - cr + index
	// save and restore cursor

	// move to last line and scroll down 8 lines
	vt100_puts("\033[24;1H");
	for(int c = 0; c < 7; c++){
		vt100_puts("\033D");
	}
	
	getchar();
	getchar();
	
	
	//_delay_ms(100); 
	// now scroll same number of lines back and then back again (to test up scroll)
	vt100_puts("\033[1;1H");
	for(int c = 0; c < 7; c++){
		vt100_puts("\033M");
	}
	
	getchar();
	
	vt100_puts("\033[24;1H");
	for(int c = 0; c < 7; c++){
		vt100_puts("\033D");
	}

	// we now have the Es at the third line (or we SHOULD have)
	// refill the top border and clear bottom borders
	for(c = 1; c < VT100_WIDTH - 1; c++){
		// we print * then move down and left, print + and go back right and top
		// (good way to test cursor navigation keys)
		spf("\033[1;%dH*\033[B\033[D+\033[A", c + 1); 
		vt100_puts(buf);
	}
	// clear the border that scrolled up
	for(c = 2; c < VT100_WIDTH - 2; c++){
		// space, down, left, space, up
		spf("\033[32;%dH \033[B\033[D \033[A", c + 1); 
		vt100_puts(buf);
	}
	
	// redraw left and right border
	for(int c = 1; c < VT100_HEIGHT; c++){
		spf("\033[%d;1H*+\033[%d;%dH+*", c + 1, c + 1, VT100_WIDTH - 1);
		vt100_puts(buf);
	}
	
	// fill border at the bottom
	for(int c = 1; c < VT100_WIDTH - 1; c++){
		spf("\033[23;%dH+\033[B\033[D*\033[A", c + 1); 
		vt100_puts(buf);
	}
	// draw the explanation string
	vt100_puts("\033[13;6HShould see two columns of E F"); 
	vt100_puts("\033[14;6HText box must start at line 3"); 

	
	getchar();
	
	//vt100_puts("\ec\e[?7l");

/*	
	while(1){
		//unsigned int data = uart_getc();
		//if(data == UART_NO_DATA) continue;
		//if(data == 0xb4){ // ´ key on my kb
		//	test_colors();
		//	_delay_ms(5000); 
		//	test_cursor();
		//	_delay_ms(5000);
		//	test_edit();
		//	_delay_ms(5000);
		//	test_scroll();
		//	_delay_ms(5000);
		
		//vt100_putc(data);
		//uart_putc(data);
	}
*/	
	//return 0; 
}