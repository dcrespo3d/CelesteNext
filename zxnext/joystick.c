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

#include "joystick.h"
#include "print_tile.h"

#define JOY_UP    0x08
#define JOY_DOWN  0x04
#define JOY_LEFT  0x02
#define JOY_RIGHT 0x01
#define JOY_BUT1  0x10
#define JOY_BUT2  0x20
#define JOY_BUT3  0x40
#define JOY_BUT4  0x80

const char* joystick_ch4short = "\x13\x12\x11\x10\x0C\x0D\x0E\x0F";

void joystick_print_debug(u8 x, u8 y)
{
    print_set_pos(x, y);
    print_str("joy:");
    print_hex_byte(joydata);
}

void joystick_codes_debug(u8 x, u8 y)
{
    print_set_pos(x, y);
    print_str("any:");
    print_hex_nibble(joystick_any());

    print_str(" cnt:");
    print_hex_byte(joystick_count());

    print_str(" cod:");
    u8 joycode = joystick_code();
    print_hex_word(joycode);

    print_str(" shrt: ");
    u8 shortcode = joystick_short_for_code(joycode);
    print_hex_byte(shortcode);

    print_str(" chr: ");
    if (shortcode != 0xFF)
        print_char(joystick_ch4short[shortcode]);
    else
        print_char('-');
}

