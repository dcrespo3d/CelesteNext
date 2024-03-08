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

#pragma codeseg PAGE_58
#pragma constseg PAGE_58

#include "screen_main.h"
#include "level.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "keyb.h"
#include "control.h"
#include "screen_controller.h"
#include "screen_scores.h"
#include "music_player.h"
#include "score.h"
#include "string.h"

#include "snowlayer.h"

#define TXT1 "HIGH SCORES"
#define TXT1X 14
#define TXT1Y 3

//////////////   123456789012  00:00  00  0000
//////////////1  Madeline
#define TXT2 "#  Name           Time   \x06  \x0B"
#define TXT2X 4
#define TXT2Y 6

#define DUMMY   "Madeline      00:00  00  000"

#define MINX 21
#define SECX 18

#define TXT0X 4
#define TXT0Y 8

#define TXTD "press any key"
#define TXTDX 13
#define TXTDY 28

static bool prev_any_key;

static u8 colors[9] = {
    SPAL_WHITE,
    SPAL_ORANGE,
    SPAL_YELLOW,
    SPAL_GREEN,
    SPAL_BLUE,
    SPAL_LAVENDER,
    SPAL_PINK,
    SPAL_LIGHT_PEACH,
    SPAL_LIGHT_GREY,
};

void shs_init_paged()
{
    music_subsong_init(SS_MENU);

    level_clear_tilemap();

    snow_init_menu();
    snow_draw();

    print_set_color(SPAL_LIGHT_GREY);
    print_set_pos(TXT1X, TXT1Y); print_str(TXT1);
    // print_set_color(SPAL_RED);
    print_set_pos(TXT2X, TXT2Y); print_str(TXT2);

    u8 y = TXT0Y;
    char name[NAME_ALLOC];

// #define TEST_FORMAT

    // for (u8 i = 0; i < SCORE_COUNT + 1; i++) // DEBUG
    for (u8 i = 0; i < SCORE_COUNT; i++)
    {
        print_set_color(colors[i]);
        print_set_pos(TXT0X, y);
        print_hex_nibble(1+i);
        print_char(' ');
        print_char(' ');
        Score* score = &scores[i];
    
#ifdef TEST_FORMAT
        memcpy(name, "123456789012", NAME_SIZE);
        u8 min = i * 3;
        u8 sec = i * 3;
        u8 fruit = i * 3;
        u16 death = i * 438;
#else
        memcpy(name, score->name, NAME_SIZE);
        u8 min = score->min;
        u8 sec = score->sec;
        u8 fruit = score->fruit;
        u16 death = score->death;
#endif
        name[NAME_SIZE] = 0;
        print_str(name);
    
        print_set_pos(MINX, y);
        if (min < 10) print_char(' ');
        print_dec_byte(min);
        print_char(':');
        if (sec < 10) print_char('0');
        print_dec_byte(sec);

        print_char(' ');
        print_char(' ');

        if (fruit < 10) print_char(' ');
        print_dec_byte(fruit);

        print_char(' ');
        print_char(' ');

        print_dec_word(death);

        y += 2;
    }


    print_set_color(SPAL_LIGHT_GREY);
    print_set_pos(TXTDX, TXTDY); print_str(TXTD);

    prev_any_key = true;
}

void shs_update_paged()
{
    snow_draw();
    snow_update();

    bool any_key = actnJump || actnDash || keyb_any();
    if (any_key && !prev_any_key)
        sc_switch_screen(sma_init, sma_update, sma_exit);
    prev_any_key = any_key;
}
