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

#include "hair.h"
#include "sprite_manager.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "util_math.h"

#define HAIR_COUNT 5

static s16 fpx[HAIR_COUNT];
static s16 fpy[HAIR_COUNT];

static s16 scx[HAIR_COUNT];
static s16 scy[HAIR_COUNT];

void hair_init(s16 x, s16 y)
{
    for (u8 i = 0; i < HAIR_COUNT; i++) {
        fpx[i] = x;
        fpy[i] = y;
        scy[i] = 256;
    }
}

void hair_clear()
{
    for (u8 i = 0; i < HAIR_COUNT; i++) {
        sprite_clear_slot(SLOT_HAIR + i);
    }
}

extern bool actnDown;

void hair_update(s16 x, s16 y, u8 attr)
{
    s16 facing = ((attr & ATTR_X___) != 0) ? 1152 : -128;
    s16 dy = actnDown ? 512 : 256;
    s16 lastx = x + facing;
    s16 lasty = y + dy;
    for (u8 i = 0; i < HAIR_COUNT; i++) {
        fpx[i] += 21 * ((lastx       - fpx[i]) >> 5);
        fpy[i] += 21 * ((lasty + 123 - fpy[i]) >> 5);
        lastx = fpx[i];
        lasty = fpy[i];
        scx[i] = X_SCREEN_4_FIXPOS(lastx);
        scy[i] = Y_SCREEN_4_FIXPOS(lasty);
    }
}

void hair_draw(u8 pal)
{
    SpriteDef sdef;
    sdef.slot = SLOT_HAIR;
    sdef.pal = pal;
    sdef.mirrot = ATTR_____;
    sdef.pat = SPAT_HAIR;
    sdef.scale = 0;

    for (u8 i = 0; i < HAIR_COUNT; i++) {
        sdef.x = scx[i];
        sdef.y = scy[i];

        sprite_update(&sdef);

        sdef.slot++;
        if (i == 1) sdef.pat--;
    }

}

