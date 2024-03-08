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

#include "keyb.h"
#include "print_tile.h"

void keyb_read_spectrum_next();
void keyb_read_spectrum_std();

void keyb_print_debug(u8 x, u8 y)
{
    print_set_pos(x, y);
    print_char('1');
    print_hex_byte(zxkey54321);
    print_char(' ');
    print_char('0');
    print_hex_byte(zxkey67890);
    print_char(' ');
    print_char('Q');
    print_hex_byte(zxkeyTREWQ);
    print_char(' ');
    print_char('P');
    print_hex_byte(zxkeyYUIOP);
    print_char(' ');
    print_char('A');
    print_hex_byte(zxkeyGFDSA);
    print_char(' ');
    print_char('e');
    print_hex_byte(zxkeyHJKLe);
    print_char(' ');
    print_char('c');
    print_hex_byte(zxkeyVCXZc);
    print_char(' ');
    print_char('s');
    print_hex_byte(zxkeyBNMys);
    print_char(' ');

    print_char('n');
    print_hex_byte(nxkey0);
    print_char(' ');
    print_char('N');
    print_hex_byte(nxkey1);
    print_char(' ');
}

void keyb_codes_debug(u8 x, u8 y)
{
    print_set_pos(x, y);
    print_str("any:");
    print_hex_nibble(keyb_any());

    print_str(" cnt:");
    print_hex_byte(keyb_count());

    print_str(" cod:");
    u16 keycode = keyb_code();
    print_hex_word(keycode);

    print_str(" shrt: ");
    u8 shortcode = keyb_short_for_code(keycode);
    print_hex_byte(shortcode);

    print_str(" chr: ");
    if (shortcode != 0xFF)
        print_char(keyb_ch4short[shortcode]);
    else
        print_char('-');
}

void keyb_update()
{
    keyb_read_spectrum_std();
    keyb_read_spectrum_next();
}

const char* keyb_ch4short = ""\
"12345---"\
"09876---"\
"QWERT---"\
"POIUY---"\
"ASDFG---"\
"\x1DLKJH---"\
"\x1EZXCV---"\
"\x1C\x1FMNB---"\
"\x13\x12\x11\x10.,\";"\
"\x1B\x1A\x19\x18\x17\x16\x15\x14";
