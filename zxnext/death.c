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

#include "death.h"

#include "sprite_manager.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "util_math.h"

#define DEATH_COUNT 8

static s16 fpx[DEATH_COUNT];
static s16 fpy[DEATH_COUNT];

static s16 scx[DEATH_COUNT];
static s16 scy[DEATH_COUNT];

static bool enabled = false;
static s8 frame;
static u8 pat;
static u8 pal;

#define A 768
#define B 576

static s16 vx[DEATH_COUNT] = {-A, -B,  0,  B,  A,  B,  0, -B};
static s16 vy[DEATH_COUNT] = { 0, -B, -A, -B,  0,  B,  A,  B};

void death_init(s16 x, s16 y)
{
    x = (x + 512) & 0xFF00;
    y = (y + 512) & 0xFF00;
    for (u8 i = 0; i < DEATH_COUNT; i++) {
        fpx[i] = x;
        fpy[i] = y;
    }
    enabled = true;
    frame = 10;
    death_update();
}

void death_clear()
{
    for (u8 i = 0; i < DEATH_COUNT; i++)
        sprite_clear_slot(SLOT_DEATH + i);
    enabled = false;
}

extern bool actnDown;

void death_update()
{
    if (!enabled) return;
    frame -= 1;
    if (frame < 0) return;

    for (u8 i = 0; i < DEATH_COUNT; i++) {
        fpx[i] += vx[i];
        fpy[i] += vy[i];
        scx[i] = X_SCREEN_4_FIXPOS(fpx[i]);
        scy[i] = Y_SCREEN_4_FIXPOS(fpy[i]);
    }

    pat = SPAT_DEATH + (frame >> 1);
    pal = ((frame & 1) != 0) ? SPAL_LIGHT_PEACH : SPAL_PINK;

}

void death_draw()
{
    if (!enabled) return;
    if (frame < 0) {
        death_clear();
        return;
    }

    SpriteDef sdef;
    sdef.slot = SLOT_DEATH;
    sdef.pal = pal;
    sdef.mirrot = ATTR_____;
    sdef.pat = pat;
    sdef.scale = 0;

    for (u8 i = 0; i < DEATH_COUNT; i++) {
        sdef.x = scx[i];
        sdef.y = scy[i];

        sprite_update(&sdef);

        sdef.slot++;
    }

}

