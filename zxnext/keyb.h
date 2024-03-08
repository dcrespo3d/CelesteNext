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

#ifndef __zxkeyb_h__
#define __zxkeyb_h__

#include "types.h"

void keyb_init();
void keyb_update();

void keyb_print_debug(u8 x, u8 y);
void keyb_codes_debug(u8 x, u8 y);

bool keyb_is_pressed(u16 keycode);

extern u8 zxkey54321;
extern u8 zxkey67890;
extern u8 zxkeyTREWQ;
extern u8 zxkeyYUIOP;
extern u8 zxkeyGFDSA;
extern u8 zxkeyHJKLe;
extern u8 zxkeyVCXZc;
extern u8 zxkeyBNMys;
extern u8 nxkey0;
extern u8 nxkey1;

// returns true if any key is pressed
bool keyb_any();

// returns number of keys pressed
u8 keyb_count();

// returns code of pressed key, 0 if none pressed
// if more than one key is pressed,
// the result is undefined.
u16 keyb_code();

// returns short/compact version of code
u8 keyb_short_for_code(u16 code);

// character for short key code
extern const char* keyb_ch4short;

bool zxkey1();
bool zxkey2();
bool zxkey3();
bool zxkey4();
bool zxkey5();
bool zxkey6();
bool zxkey7();
bool zxkey8();
bool zxkey9();
bool zxkey0();

bool zxkeyQ();
bool zxkeyW();
bool zxkeyE();
bool zxkeyR();
bool zxkeyT();
bool zxkeyY();
bool zxkeyU();
bool zxkeyI();
bool zxkeyO();
bool zxkeyP();

bool zxkeyA();
bool zxkeyS();
bool zxkeyD();
bool zxkeyF();
bool zxkeyG();
bool zxkeyH();
bool zxkeyJ();
bool zxkeyK();
bool zxkeyL();
bool zxkeyENT();

bool zxkeyCAP();
bool zxkeyZ();
bool zxkeyX();
bool zxkeyC();
bool zxkeyV();
bool zxkeyB();
bool zxkeyN();
bool zxkeyM();
bool zxkeySYM();
bool zxkeySPC();

bool nxkeySemicolon();
bool nxkeyQuote();
bool nxkeyComma();
bool nxkeyPeriod();
bool nxkeyUp();
bool nxkeyDown();
bool nxkeyLeft();
bool nxkeyRight();

bool nxkeyDel();
bool nxkeyEdit();
bool nxkeyBreak();
bool nxkeyInvVideo();
bool nxkeyTruVideo();
bool nxkeyGraph();
bool nxkeyCapsLock();
bool nxkeyExtend();


#endif // _zxkeyb_h_
