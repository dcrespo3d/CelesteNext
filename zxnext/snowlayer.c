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

#include "snowlayer.h"
#include "tables.h"
#include "sprite_manager.h"
#include "print_tile.h"
#include "gamedefs.h"

static u16 sx[SNOW_COUNT];  // x
static u16 sy[SNOW_COUNT];  // y
static u16 ss[SNOW_COUNT];  // speed
static u8  so[SNOW_COUNT];  // offset
static u8  st[SNOW_COUNT];  // type

static u16 xmin;
static u16 xmax;

static bool menu_inited = false;

void snow_init()
{
    menu_inited = false;
    for (u8 i = 0; i < SNOW_COUNT; i++) {
        sx[i] = (64 + (rndtable_next() >> 1)) << 8;
        sy[i] = (64 + (rndtable_next() >> 1)) << 8;
        ss[i] = 256 + (rndtable_next() << 2);
        so[i] = rndtable_next();
        st[i] = rndtable_next();
    }
    xmin = (60 << 8);
    xmax = (196 << 8);
}

void snow_init_menu()
{
    if (menu_inited) return;
    menu_inited = true;
    
    for (u8 i = 0; i < SNOW_COUNT; i++) {
        sx[i] = rndtable_next() << 8;
        sy[i] = rndtable_next() << 8;
        ss[i] = 256 + (rndtable_next() << 2);
        so[i] = rndtable_next();
        st[i] = rndtable_next();
    }
    xmin = (28 << 8);
    xmax = (228 << 8);
}

void snow_update()
{
    u16 x, y, s;
    u8 o;
    s16 dy;
    s16 sio;
    for (u8 i = 0; i < SNOW_COUNT; i++) {
        x = sx[i];
        y = sy[i];
        s = ss[i];
        o = so[i];
        x += s;
        if (x > xmax) {
            x = xmin;
            y = (64 + (rndtable_next() >> 1)) << 8;
            s = 256 + (rndtable_next() << 2);
        }
        else {
            // sio = (s16)(sintable[o]);
            sio = sintable[o];
            if (sio > 0x7F) sio |= 0xFF00;
            dy = 2 * sio;
            y += dy;
        }
        o += 1 + (s >> 6);
        sx[i] = x;
        sy[i] = y;
        so[i] = o;
        ss[i] = s;
    }

    // print_set_pos(36, 30);
    // print_hex_word(sio);
}

void snow_draw()
{
    SpriteDef sdef;
    sdef.slot = SLOT_SNOW;
    sdef.mirrot = 0;
    sdef.scale = 0;
    u8 typ;

    for (u8 i = 0; i < SNOW_COUNT; i++) {
        sdef.x = (((sx[i] >> 8) - 64) << 1) + 32;
        sdef.y = (((sy[i] >> 8) - 64) << 1);
        typ = st[i];
        sdef.pal = 9;
        if (typ & 1) sdef.pal += 6;
        sdef.pat = SPAT_SNOW;
        if (typ & 2) sdef.pat += 1;
        sprite_update_asm(&sdef);
        sdef.slot++;
    }

}

void snow_clear()
{
    u8 slot = SLOT_SNOW;
    for (u8 i = 0; i < SNOW_COUNT; i++)
        sprite_clear_slot(slot++);
}
