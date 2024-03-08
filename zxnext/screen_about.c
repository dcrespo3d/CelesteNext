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

#include "screen_about.h"
#include "level.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "keyb.h"
#include "control.h"
#include "screen_controller.h"
#include "screen_main.h"
#include "string.h"
#include "snowlayer.h"

// VERSION NUMBER
#define VER "1.0"
#define VERX 36
#define VERY 30

#define TXT1 "Celeste Classic for Spectrum Next"
#define TXT1X 3
#define TXT1Y 4

#define TXT2 "Unofficial remake by David Crespo"
#define TXT2X 3
#define TXT2Y 7

#define TXT3 "davidprograma.itch.io"
#define TXT3X 9
#define TXT3Y 9
#define TXT4 "youtube.com/@Davidprograma"
#define TXT4X 7
#define TXT4Y 10
#define TXT5 "github.com/dcrespo3d"
#define TXT5X 10
#define TXT5Y 11

#define TXT6 "Based on Celeste for Pico-8"
#define TXT6X 6
#define TXT6Y 14

#define TXT7 "by Maddy Thorson and Noel Berry"
#define TXT7X 4
#define TXT7Y 15

#define TXT8 "lexaloffle.com/bbs/?tid=2145"
#define TXT8X 6
#define TXT8Y 17

#define TXT9 "celestegame.com"
#define TXT9X 12
#define TXT9Y 18

#define TXTA "Developed with these great tools"
#define TXTAX 4
#define TXTAY 21

#define TXTB "Godot Engine  |  Z88DK   | Pico-8"
#define TXTBX 4
#define TXTBY 23

//////////////1234567890123456789012345678901234567890
#define TXTC "Arkos Tracker 2 | Aseprite | Python"
#define TXTCX 2
#define TXTCY 24

//////////////1234567890123456789012345678901234567890
#define TXTD "press any key"
#define TXTDX 13
#define TXTDY 27


static bool prev_any_key;

void sab_init_paged()
{
    level_clear_tilemap();

    print_set_color(SPAL_ORANGE);
    print_set_pos(TXT1X, TXT1Y); print_str(TXT1);

    print_set_color(SPAL_LIGHT_GREY);
    print_set_pos(TXT2X, TXT2Y); print_str(TXT2);

    print_set_color(SPAL_BLUE);
    print_set_pos(TXT3X, TXT3Y); print_str(TXT3);
    print_set_pos(TXT4X, TXT4Y); print_str(TXT4);
    print_set_pos(TXT5X, TXT5Y); print_str(TXT5);

    print_set_color(SPAL_LIGHT_GREY);
    print_set_pos(TXT6X, TXT6Y); print_str(TXT6);
    print_set_pos(TXT7X, TXT7Y); print_str(TXT7);
    
    print_set_color(SPAL_BLUE);
    print_set_pos(TXT8X, TXT8Y); print_str(TXT8);
    print_set_pos(TXT9X, TXT9Y); print_str(TXT9);    

    print_set_color(SPAL_LIGHT_GREY);
    print_set_pos(TXTAX, TXTAY); print_str(TXTA);

    print_set_color(SPAL_LAVENDER);
    print_set_pos(TXTBX, TXTBY); print_str(TXTB);
    print_set_pos(TXTCX, TXTCY); print_str(TXTC);

    print_set_color(SPAL_LIGHT_GREY);
    print_set_pos(TXTDX, TXTDY); print_str(TXTD);

    // VERSION NUMBER
    print_set_color(SPAL_DARK_GREY);
    print_set_pos(VERX, VERY); print_str(VER);

    prev_any_key = true;
}

void sab_update_paged()
{
    snow_draw();
    snow_update();

    bool any_key = actnJump || actnDash || keyb_any();
    if (any_key && !prev_any_key)
        sc_switch_screen(sma_init, sma_update, sma_exit);
    prev_any_key = any_key;
}