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

#include "banner.h"
#include "types.h"
#include "sprite_manager.h"
#include "print_tile.h"
#include "gamedefs.h"
#include "screen_game.h"
#include <string.h>

static bool must_draw_timer;
static bool must_draw_level;
static bool must_draw_endgame;
static bool must_clear_banner;
static u8 banner_countdown;

#define DIGIT_COUNT 8
#define DEATH_COUNT 4
#define FRUIT_COUNT 2

static u8 slot_banner;
static u8 timer_digits[DIGIT_COUNT];
static u8 death_digits[DEATH_COUNT];
static u8 fruit_digits[FRUIT_COUNT];

static u8 ld1, ld2, ld3, ld4;

#define TIMER_X0 (32 + 4*2)
#define TIMER_Y0 (4*2)

#define LEVEL_X0 (32 + 24*2)
#define LEVEL_Y0 (58*2)

#define LEVEL_OLDSITE 11
#define LEVEL_SUMMIT 30

void banner_init()
{
    must_draw_timer = false;
    must_draw_level = false;
    must_draw_endgame = false;
    must_clear_banner = false;
    banner_countdown = 0;
}

const extern u8 level_idx;

static void calc_timer_digits()
{
    u8 dec, uni;
    u8* ptr = timer_digits;

    dec = 0;
    uni = gth;
    while (uni >= 10) {
        uni -= 10;
        dec++;
    }

    *ptr++ = SPAT_DIGIT+dec;
    *ptr++ = SPAT_DIGIT+uni;
    *ptr++ = SPAT_DIGIT+16;

    dec = 0;
    uni = gtm;
    while (uni >= 10) {
        uni -= 10;
        dec++;
    }

    *ptr++ = SPAT_DIGIT+dec;
    *ptr++ = SPAT_DIGIT+uni;
    *ptr++ = SPAT_DIGIT+16;

    dec = 0;
    uni = gts;
    while (uni >= 10) {
        uni -= 10;
        dec++;
    }

    *ptr++ = SPAT_DIGIT+dec;
    *ptr++ = SPAT_DIGIT+uni;
}

static void calc_level_digits()
{
    u8 lnum = 1+level_idx;
    ld1 = 0;
    while (lnum >= 10) {
        lnum -= 10;
        ld1++;
    }
    ld2 = lnum;

    if (ld1 > 0)
        ld1 += SPAT_DIGIT;
    ld2 += SPAT_DIGIT;
    ld3 = SPAT_DIGIT+10;
    ld4 = SPAT_DIGIT+11;

}

void banner_start_level()
{
    slot_banner = SLOT_BANNER;
    must_draw_timer = true;
    must_draw_level = true;

    calc_timer_digits();
    calc_level_digits();

    banner_countdown = 30;
}

void banner_end_game()
{
    slot_banner = SLOT_BANNER;
    must_draw_endgame = true;
}

void banner_update()
{
    if (banner_countdown > 0) {
        banner_countdown--;
        if (banner_countdown == 0)
            must_clear_banner = true;
    }

}

static void draw_timer();
static void draw_level();
static void clear_banner();
static void draw_endgame();

void banner_draw()
{
    if (must_draw_timer || must_draw_level)
        clear_banner();

    if (must_draw_timer) {
        must_draw_timer = false;
        draw_timer();
    }
    if (must_draw_level) {
        must_draw_level = false;
        draw_level();
    }
    if (must_draw_endgame) {
        must_draw_endgame = false;
        draw_endgame();
    }
    if (must_clear_banner) {
        must_clear_banner = false;
        clear_banner();
    }
}

static void draw_timer()
{
    SpriteDef sdef;
    sdef.slot = slot_banner;
    sdef.mirrot = ATTR_____;
    sdef.pal = SPAL_BLACK;
    sdef.x = TIMER_X0;
    sdef.y = TIMER_Y0;
    sdef.pat = SPAT_TIMERBG;
    sdef.scale = SCALE_X4 | SCALE_Y2;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.x += 2;
    sprite_update(&sdef);

    sdef.slot++;
    sdef.y += 2;
    sdef.pal = SPAL_WHITE;
    sdef.scale = SCALE_X1 | SCALE_Y1;

    for (u8 i = 0; i < DIGIT_COUNT; i++) {
        sdef.pat = timer_digits[i];

        sprite_update(&sdef);
        
        sdef.slot++;
        sdef.x += 8;
    }

    slot_banner = sdef.slot;
}

static void draw_level()
{
    SpriteDef sdef;
    sdef.slot = slot_banner;
    sdef.mirrot = ATTR_____;
    sdef.pal = SPAL_BLACK;
    sdef.x = LEVEL_X0;
    sdef.y = LEVEL_Y0;
    sdef.pat = SPAT_LEVELBG;
    sdef.scale = SCALE_X8 | SCALE_Y2;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.x += 80;
    sprite_update(&sdef);

    if (level_idx == LEVEL_OLDSITE) {
        sdef.slot++;
        sdef.x = LEVEL_X0 + (25*2);
        sdef.y += (4*2);
        sdef.pal = SPAL_WHITE;
        sdef.scale = SCALE_X2 | SCALE_Y2;
        sdef.pat = SPAT_OLDSITE;
        sprite_update(&sdef);

        sdef.slot++;
        sdef.x += 32;
        sdef.pat++;
        sprite_update(&sdef);
        return;
    }
    if (level_idx == LEVEL_SUMMIT) {
        sdef.slot++;
        sdef.x = LEVEL_X0 + (25*2);
        sdef.y += (4*2);
        sdef.pal = SPAL_WHITE;
        sdef.scale = SCALE_X2 | SCALE_Y2;
        sdef.pat = SPAT_SUMMIT;
        sprite_update(&sdef);

        sdef.slot++;
        sdef.x += 32;
        sdef.pat++;
        sprite_update(&sdef);
        return;
    }

    sdef.slot++;
    sdef.x = LEVEL_X0 + (29*2);
    sdef.y += (4*2);
    sdef.pal = SPAL_WHITE;
    sdef.scale = SCALE_X1 | SCALE_Y1;
    sdef.pat = ld1;

    sprite_update(&sdef);
    
    sdef.slot++;
    sdef.x += 8;
    sdef.pat = ld2;
    sprite_update(&sdef);

    sdef.slot++;
    sdef.x += 8;
    sdef.pat = ld3;
    sprite_update(&sdef);

    sdef.slot++;
    sdef.x += 24;
    sdef.pat = ld4;
    sprite_update(&sdef);

    slot_banner = sdef.slot;
}

#define ENDGAME_X0 (32 + 32*2)
#define ENDGAME_Y0 (8*2)

static void draw_endgame()
{
    SpriteDef sdef;
    sdef.slot = slot_banner;
    sdef.mirrot = ATTR_____;
    sdef.pal = SPAL_BLACK;
    sdef.x = ENDGAME_X0;
    sdef.y = ENDGAME_Y0;
    sdef.pat = SPAT_TIMERBG;
    sdef.scale = SCALE_X8 | SCALE_Y8;
    sprite_update(&sdef);

    sdef.scale = SCALE_X1 | SCALE_Y1;

    sdef.slot++;
    sdef.x = ENDGAME_X0 + 8;
    sdef.y = ENDGAME_Y0 + 8;
    sdef.pat = SPAT_FRUIT;
    sdef.pal = SPAL_RED;
    sprite_update(&sdef);

    sdef.pal = SPAL_WHITE;

    u8 fruit_count = game_fruit_count();
    // fruit_count = 12;
    ubyte_to_dec_bytes(fruit_count);

    u8 iFirstNonZero = 0;
    while (iFirstNonZero < UBDB_COUNT-1) {
        if (ubyte_dec_bytes[iFirstNonZero])
            break;
        iFirstNonZero++;
    }

    sdef.x = ENDGAME_X0 + 8 + 20;
    sdef.y = ENDGAME_Y0 + 8 + 4;
    for (u8 i = iFirstNonZero; i < UBDB_COUNT; i++) {
        u8 digit = ubyte_dec_bytes[i];
        sdef.slot++;
        sdef.pat = SPAT_DIGIT + digit;
        sprite_update(&sdef);
        sdef.x += 8;
    }

    sdef.slot++;
    sdef.x = ENDGAME_X0 + 60;
    sdef.y = ENDGAME_Y0 + 8 + 2;
    sdef.pat = SPAT_SKULL;
    sdef.pal = SPAL_LIGHT_GREY;
    sprite_update(&sdef);

    sdef.pal = SPAL_WHITE;

    uword_to_dec_bytes(game_deaths);
    // uword_to_dec_bytes(1234);

    iFirstNonZero = 0;
    while (iFirstNonZero < UWDB_COUNT-1) {
        if (uword_dec_bytes[iFirstNonZero])
            break;
        iFirstNonZero++;
    }

    DBG8(0, 8, iFirstNonZero);

    sdef.x = ENDGAME_X0 + 60 + 20;
    sdef.y = ENDGAME_Y0 + 8 + 4;
    for (u8 i = iFirstNonZero; i < UWDB_COUNT; i++) {
        u8 digit = uword_dec_bytes[i];
        sdef.slot++;
        sdef.pat = SPAT_DIGIT + digit;
        sprite_update(&sdef);
        sdef.x += 8;
    }

    sdef.x = ENDGAME_X0 + 30;
    sdef.y = ENDGAME_Y0 + 32 + 4;

    for (u8 i = 0; i < DIGIT_COUNT; i++) {
        sdef.pat = timer_digits[i];
        sdef.slot++;
        sprite_update(&sdef);
        sdef.x += 8;
    }
}

static void clear_banner()
{
    for (u8 i = 0; i < BANNER_COUNT; i++) {
        sprite_clear_slot(SLOT_BANNER + i);
    }
}