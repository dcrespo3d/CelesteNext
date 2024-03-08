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
#include "persist.h"
#include "snowlayer.h"

//////////////1234567890123456789012345678901234567890
#define TXT1 "Both keyboard and kempston joystick"
#define TXT2 "or gamepad can used simultaneously"
#define TXT2A "(two button joystick recommended)"

#define TXT3 "Hold Break (Caps+Space) for more"
#define TXT4 "than 3 seconds to terminate game"

#define TXT5 "Press ENTER to redefine keys"
#define TXT6 "or any other key to exit"

static bool redefine_in_progress;
static bool pkey_ent;
static bool pkey_any;
static void print_keys();

static s8 active_key_idx;

void sco_init_paged()
{
    level_clear_tilemap();

    snow_init_menu();
    snow_draw();

    active_key_idx = 6;
    print_keys();

    redefine_in_progress = false;
    pkey_any = pkey_ent = true;
}

static u8 get_key_color(s8 kidx)
{
    if (active_key_idx > 5)
        return SPAL_BLUE;
    else if (active_key_idx == kidx)
        return SPAL_ORANGE;
    else
        return SPAL_DARK_GREY;
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

static char get_key_char(s8 kidx, u16 keycode)
{
    if (active_key_idx > 5 || active_key_idx > kidx)
        return keyb_ch4short[keyb_short_for_code(keycode)];        
    else if (active_key_idx == kidx)
        return get_flash_cursor();
    else return ' ';
}

static void print_keys()
{
    print_set_color(SPAL_LIGHT_GREY);
    if (active_key_idx > 5)
        DBGTEXT(13, 3, "Current keys:")
    else
        DBGTEXT(13, 3, "Press key for");

    print_set_color(get_key_color(0));
    DBGTEXT(14,  6, "UP    \x10 : ");
    print_char(get_key_char(0, keycodeUp));

    print_set_color(get_key_color(1));
    DBGTEXT(14,  8, "DOWN  \x11 : ");
    print_char(get_key_char(1, keycodeDown));

    print_set_color(get_key_color(2));
    DBGTEXT(14, 10, "LEFT  \x12 : ");
    print_char(get_key_char(2, keycodeLeft));

    print_set_color(get_key_color(3));
    DBGTEXT(14, 12, "RIGHT \x13 : ");
    print_char(get_key_char(3, keycodeRight));

    print_set_color(get_key_color(4));
    DBGTEXT(14, 14, "JUMP  \x0C : ");
    print_char(get_key_char(4, keycodeJump));

    print_set_color(get_key_color(5));
    DBGTEXT(14, 16, "DASH  \x0D : ");
    print_char(get_key_char(5, keycodeDash));

    if (active_key_idx > 5)
        print_set_color(SPAL_ORANGE);
    else
        print_set_color(SPAL_BLACK);
    DBGTEXT(6, 19, TXT5);
    DBGTEXT(8, 20, TXT6);

    if (active_key_idx > 5)
        print_set_color(SPAL_LIGHT_GREY);
    else
        print_set_color(SPAL_BLACK);
    DBGTEXT(3, 23, TXT1);
    DBGTEXT(3, 24, TXT2);
    DBGTEXT(3, 25, TXT2A);
    DBGTEXT(4, 27, TXT3);
    DBGTEXT(4, 28, TXT4);

    flash_key++;
    print_set_color(SPAL_LIGHT_GREY);
}

static bool key_already_used(u16 keycode)
{
    if (keycode == keycodeUp)    return true;
    if (keycode == keycodeDown)  return true;
    if (keycode == keycodeLeft)  return true;
    if (keycode == keycodeRight) return true;
    if (keycode == keycodeJump)  return true;
    if (keycode == keycodeDash)  return true;

    return false;
}

static void perform_redefine()
{
    print_keys();

    bool key_any = keyb_any();
    if (key_any && pkey_any)
        return;
    pkey_any = key_any;

    u16 new_keycode = keyb_code();
    if (!new_keycode) return;
    if (key_already_used(new_keycode)) return;

    if (active_key_idx == 0) keycodeUp    = new_keycode;
    if (active_key_idx == 1) keycodeDown  = new_keycode;
    if (active_key_idx == 2) keycodeLeft  = new_keycode;
    if (active_key_idx == 3) keycodeRight = new_keycode;
    if (active_key_idx == 4) keycodeJump  = new_keycode;
    if (active_key_idx == 5) keycodeDash  = new_keycode;

    pkey_any = true;
    active_key_idx++;

    if (active_key_idx == 6) {
        print_set_color(SPAL_ORANGE);
        DBGTEXT(15, 19, "Saving ...");
        persist_save_control();
        print_keys();
        redefine_in_progress = false;
    }
}

void sco_update_paged()
{
    snow_draw();
    snow_update();

    if (redefine_in_progress) {
        perform_redefine();
        return;
    }

    bool key_ent = zxkeyENT();
    if (key_ent && !pkey_ent) {
        keycodeUp = keycodeDown = 0;
        keycodeLeft = keycodeRight = 0;
        keycodeJump = keycodeDash = 0;
        active_key_idx = 0;
        pkey_any = true;
        redefine_in_progress = true;
    }
    pkey_ent = key_ent;

    if (redefine_in_progress) return;

    bool key_any = actnJump || actnDash || keyb_any();
    if (key_any && !pkey_any) {
        sc_switch_screen(sma_init, sma_update, sma_exit);
    }
    pkey_any = key_any;
}
