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

#ifndef __types_h__
#define __types_h__

// for bool
#include <stdbool.h>
// for NULL and others
#include <stddef.h>

// unsigned byte
typedef unsigned char ubyte;
typedef unsigned char u8;
// unsigned word
typedef unsigned short uword;
typedef unsigned short u16;

// signed byte
typedef signed char sbyte;
typedef signed char s8;
// signed word
typedef signed short sword;
typedef signed short s16;

// extract high nibble of a byte
#define HINIB(a_byte) (a_byte >> 4)

// extract low nibble of a byte
#define LONIB(a_byte) (a_byte & 0xF)

// join two nibbles into a byte (unchecked)
#define JOINIB(hi, lo) ((hi << 4) | lo)

// FunPtr is a pointer to a function accepting no arguments
// and returning void
typedef void (*FunPtr)();

#endif // __types_h__
