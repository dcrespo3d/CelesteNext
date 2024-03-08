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

#include "screen_enter.h"
#include "level.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "keyb.h"
#include "control.h"
#include "screen_controller.h"
#include "screen_scores.h"
#include "string.h"
#include "snowlayer.h"
#include "score.h"
#include "persist.h"

//////////////1234567890123456789012345678901234567890

#define PX 13
#define PY 14

static bool ignore_first;
static u16 prev_code;
static char name[NAME_ALLOC];
static char name_idx;

static bool preview;

static void clear_name();
static void show_instructions();

void ses_init_paged()
{
    level_clear_tilemap();

    snow_init_menu();
    snow_draw();

    print_set_color(SPAL_BLUE);
    DBGTEXT(11, 5, "CONGRATULATIONS!");

    print_set_color(SPAL_ORANGE);
    DBGTEXT(10, 7, "YOU BEAT THE GAME!");

    show_instructions();

    prev_code = 0;
    ignore_first = true;
    preview = false;
}

static void show_instructions()
{
    print_set_color(SPAL_LIGHT_GREY);
    if (!preview)
        DBGTEXT(4, 10, "Type your name and press ENTER:")
    else
        DBGTEXT(4, 10, "                               ")

    print_set_color(SPAL_RED);

    print_set_color(SPAL_LIGHT_GREY);
    if (!preview)
        DBGTEXT(3, 18, " [only A-Z, 0-9, space, delete)  ")
    else
        DBGTEXT(3, 18, "ENTER to confirm, DELETE to retry")


}

static void clear_name()
{
    memset(name, 0, NAME_ALLOC);
    name_idx = 0;
    prev_code = 0;
    ignore_first = true;
}

static void process_keycode(u16 keycode)
{
    if (name_idx >= NAME_SIZE)
        return;

    u8 keyshort = keyb_short_for_code(keycode);
    char ch = keyb_ch4short[keyshort];
    if (ch == 28) ch = 32;
    if (ch == 32 || (ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9'))
        name[name_idx++] = ch;
}

static u8 flash_key = 0;
static char get_flash_cursor()
{
    // if (flash_key & 8 != 0)   // WRONG!
    if ((flash_key & 8) != 0)
        return '\x60';
    else
        return ' ';
}

static void print_name()
{
    print_set_color(SPAL_RED);
    print_set_pos(PX, PY);
    print_str("             ");
    print_set_pos(PX, PY+1);
    if (!preview)
        print_str("\07\07\07\07\07\07\07\07\07\07\07\07");
    else
        print_str("            ");
    print_set_pos(PX, PY);
    print_str(name);
    if (!preview && name_idx < NAME_SIZE)
        print_char(get_flash_cursor());
    else
        print_char(' '); 
}

static void confirm_name()
{
    score_enter_name(name);

    print_set_color(SPAL_ORANGE);
    DBGTEXT(3, 18, "            saving...            ")

    persist_save_scores();
    sc_switch_screen(shs_init, shs_update, NULL);
}

void ses_update_paged()
{
    snow_draw();
    snow_update();
    
    show_instructions();
    print_name();

    flash_key++;

    u16 keycode = keyb_code();
    if (ignore_first && keycode != 0) {
        prev_code = keycode;
        return;
    }
    ignore_first = false;

    if (keycode != 0 && keycode != prev_code && prev_code == 0) 
        process_keycode(keycode);
    prev_code = keycode;

    if (nxkeyDel() || (zxkey0() && zxkeyCAP())) {
        clear_name();
        preview = false;
    }

    static bool pent = false;
    bool ent = zxkeyENT();
    if (ent && !pent) {
        if (!preview)
            preview = true;
        else
            confirm_name();
    }
    pent = ent;

    // else if (zxkeyENT())
    //     confirm_name();
}