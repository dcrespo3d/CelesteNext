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

#include "smoke.h"

#include "sprite_manager.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "util_math.h"
#include "tables.h"

#define VX040 102   // 0.4
#define VY010  26   // 0.1

static s16 fpx[SMOKE_COUNT];
static s16 fpy[SMOKE_COUNT];
static u8  sta[SMOKE_COUNT];

static s16 scx[SMOKE_COUNT];
static s16 scy[SMOKE_COUNT];

static bool must_draw = false;

void smoke_init(s16 x, s16 y)
{
    for (u8 i = 0; i < SMOKE_COUNT; i++) {
        if (sta[i] == 0) {
            sta[i] = (rndtable_next() & 0x0C) | 0x01;
            fpx[i] = x + (s16)(randi_11() << 8);
            fpy[i] = y + (s16)(randi_11() << 8);
            break;
        }
    }
}

void smoke_clear()
{
    for (u8 i = 0; i < SMOKE_COUNT; i++) {
        sta[i] = 0;
        sprite_clear_slot(SLOT_SMOKE + i);
    }
    must_draw = false;
}

extern bool actnDown;

void smoke_update()
{
    must_draw = false;
    for (u8 i = 0; i < SMOKE_COUNT; i++) {
        if (!sta[i]) continue;
        must_draw = true;
        fpx[i] += VX040;
        fpy[i] -= VY010;
        scx[i] = X_SCREEN_4_FIXPOS(fpx[i]);
        scy[i] = Y_SCREEN_4_FIXPOS(fpy[i]);
    }
}

void smoke_draw()
{
    if (!must_draw) return;

    SpriteDef sdef;
    sdef.pal = 0;
    sdef.scale = 0;

    for (u8 i = 0; i < SMOKE_COUNT; i++) {
        u8 state = sta[i];
        if (!state) continue;
        // DBG8X(0,0,i);
        u8 frame = state >> 4;
        frame++;
        if (frame > 15) {
            sta[i] = 0;
            sprite_clear_slot(SLOT_SMOKE + i);
        }
        else {
            sdef.slot = SLOT_SMOKE + i;
            sdef.x = scx[i];
            sdef.y = scy[i];
            // DBG16X(0,1,sdef.x);
            // DBG16X(0,2,sdef.y);
            sdef.mirrot = state & 0x0C;
            sdef.pat = SPAT_SMOKE;
            if (frame > 5 ) sdef.pat++;
            if (frame > 10) sdef.pat++;
            sta[i] = (state & 0x0E) | (frame << 4);

            sprite_update(&sdef);
}    }

}

