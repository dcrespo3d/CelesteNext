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

#include "control.h"

// default keys

u16 keycodeUp     = 0x0304; // I
u16 keycodeDown   = 0x0504; // K
u16 keycodeLeft   = 0x0508; // J
u16 keycodeRight  = 0x0502; // L
// u16 keycodeUp     = 0x0108; // 7
// u16 keycodeDown   = 0x0110; // 6
// u16 keycodeLeft   = 0x0010; // 5
// u16 keycodeRight  = 0x0104; // 8
u16 keycodeJump   = 0x0602; // Z
u16 keycodeDash   = 0x0604; // X

// u16 keycodeUp     = 0x0201; // Q
// u16 keycodeDown   = 0x0401; // A
// u16 keycodeLeft   = 0x0302; // O
// u16 keycodeRight  = 0x0301; // P
// u16 keycodeJump   = 0x0501; // ENTER
// u16 keycodeDash   = 0x0701; // SPACE

// default joystick assignment
u8 joycodeUp     = 0x08;
u8 joycodeDown   = 0x04;
u8 joycodeLeft   = 0x02;
u8 joycodeRight  = 0x01;
u8 joycodeJump   = 0x10;
u8 joycodeDash   = 0x20;

