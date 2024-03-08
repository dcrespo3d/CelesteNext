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
#include "screen_game.h"
#include "screen_about.h"
#include "screen_control.h"
#include "screen_scores.h"
#include "music_player.h"

#include "snowlayer.h"

#define TXT4 "use keyboard or kempston"
#define TXT4X 8
#define TXT4Y 29

#define DIR1X 7
#define DIR1Y 27

#define DIR2X 7
#define DIR2Y 26

#define MENUX 13
#define MENUY 16
#define MENU1 "  Start Game"
#define MENU2 "  Redefine Keys"
#define MENU3 "  High Scores"
#define MENU4 "  About Game"

#define SYM_JB1 140
#define SYM_JB2 141
#define SYM_JB3 142
#define SYM_JB4 143
#define SYM_JDU 144
#define SYM_JDD 145
#define SYM_JDL 146
#define SYM_JDR 147

static u8 opt = 0;
static void print_menu();
static bool pselect, pup, pdown;

void sma_init_paged()
{
    music_subsong_init(SS_MENU);

    level_clear_tilemap();

    snow_init_menu();
    snow_draw();
    
    level_load(LEVEL_MENU);

    print_set_color(SPAL_LAVENDER);
    print_set_pos(DIR1X, DIR1Y);
    u8 sym = SYM_JDU;
    for (u8 i = 0; i < 6; i++) {
        print_set_symbol(sym);
        print_symbol();
        print_set_pos_inc(5, 0);
        if (sym++ == SYM_JDR) sym = SYM_JB1;
    }

    print_set_color(SPAL_LIGHT_GREY);
    print_set_pos(TXT4X, TXT4Y); print_str(TXT4);
    print_set_pos(DIR2X, DIR2Y);
    print_char(keyb_ch4short[keyb_short_for_code(keycodeUp)]);
    print_set_pos_inc(5, 0);
    print_char(keyb_ch4short[keyb_short_for_code(keycodeDown)]);
    print_set_pos_inc(5, 0);
    print_char(keyb_ch4short[keyb_short_for_code(keycodeLeft)]);
    print_set_pos_inc(5, 0);
    print_char(keyb_ch4short[keyb_short_for_code(keycodeRight)]);
    print_set_pos_inc(5, 0);
    print_char(keyb_ch4short[keyb_short_for_code(keycodeJump)]);
    print_set_pos_inc(5, 0);
    print_char(keyb_ch4short[keyb_short_for_code(keycodeDash)]);

    opt = 0;
    print_menu();
    pselect = pup = pdown = true;
}

static void print_menu()
{
    print_set_color(opt == 0 ? SPAL_RED : SPAL_LAVENDER);
    print_set_pos(MENUX, MENUY); print_str(MENU1);
    print_set_color(opt == 1 ? SPAL_RED : SPAL_LAVENDER);
    print_set_pos(MENUX, MENUY+2); print_str(MENU2);
    print_set_color(opt == 2 ? SPAL_RED : SPAL_LAVENDER);
    print_set_pos(MENUX, MENUY+4); print_str(MENU3);
    print_set_color(opt == 3 ? SPAL_RED : SPAL_LAVENDER);
    print_set_pos(MENUX, MENUY+6); print_str(MENU4);

    print_set_color(SPAL_RED);
    print_set_pos(MENUX, MENUY+2*opt); print_char('>');
}


void sma_update_paged()
{
    snow_draw();
    snow_update();

    u8 newopt = opt;

    bool down = actnDown || nxkeyDown();
    bool up   = actnUp   || nxkeyUp();
    if  (down && !pdown) newopt++;
    else if (up && !pup) newopt--;
    pdown = down;
    pup   = up;

    if (opt != newopt) {
        opt  = newopt & 3;
        print_menu();
    }

    bool select = actnJump || actnDash || zxkeyENT() || zxkeySPC();
    if (select && !pselect)
    {
        if (opt == 0) {
            sc_switch_screen(sga_init, sga_update, sga_exit);
        }
        else if (opt == 1) {
            sc_switch_screen(sco_init, sco_update, NULL);
        }
        else if (opt == 2) {
            sc_switch_screen(shs_init, shs_update, NULL);
        }
        else if (opt == 3) {
            sc_switch_screen(sab_init, sab_update, NULL);
        }
    }
    pselect = select;

}
