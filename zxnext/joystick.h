///////////////////////////////////////////////////////////////////////////////
//
//  Celeste Classic (remake) - for ZX Spectrum Next / N-Go
//
//  (c) 2024 David Crespo - https://github.com/dcrespo3d
//                          https://davidprograma.itch.io
//                          https://www.youtube.com/@Davidprograma
//
//  Based on Celeste Classic for Pico-8 - (c) 2015 Maddy Thorson, Noel Berry
//
///////////////////////////////////////////////////////////////////////////////
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.  
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>. 
//
///////////////////////////////////////////////////////////////////////////////

#ifndef __joystick_h__
#define __joystick_h__

#include "types.h"

extern ubyte joyLeft;  // left
extern ubyte joyRight; // right
extern ubyte joyUp;    // up
extern ubyte joyDown;  // down
extern ubyte joyBut1;  // button 1
extern ubyte joyBut2;  // button 2
extern ubyte joyBut3;  // button 1
extern ubyte joyBut4;  // button 2

extern ubyte joydata;  // raw joystick data

void joystick_init();

void joystick_update();

void joystick_print_debug(u8 x, u8 y);
void joystick_codes_debug(u8 x, u8 y);


// returns true if any joystick dir/btn is pressed
bool joystick_any();

// returns number of joystick dir/btns pressed
u8 joystick_count();

// returns code of pressed joystick dir/btn, 0 if none pressed
// if more than one is pressed,
// the result is undefined.
u8 joystick_code();

// returns short/compact version of code
u8 joystick_short_for_code(u8 code);

// character for short key code
extern const char* joystick_ch4short;

#endif