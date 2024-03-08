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

#include <arch/zxn.h>
#include <string.h>

#include "gamedefs.h"
#include "screen_game.h"
#include "snowlayer.h"
#include "letterbox.h"
#include "types.h"
#include "sprite_manager.h"
#include "player.h"
#include "level.h"
#include "keyb.h"
#include "tables.h"
#include "print_tile.h"
#include "smoke.h"
#include "util_next.h"

#include "spring.h"
#include "fruit.h"
#include "flyfruit.h"
#include "fallfloor.h"
#include "key.h"
#include "chest.h"
#include "balloon.h"
#include "platform.h"
#include "tombstone.h"
#include "bigchest.h"
#include "cloudlayer.h"
#include "fakewall.h"
#include "banner.h"
#include "flag.h"
#include "music_player.h"

#include "keyb.h"
#include "screen_controller.h"
#include "screen_main.h"
#include "persist.h"

// level globals
#define INITIAL_LEVEL 0
u8 level_idx;
GameObject objarr[GAME_OBJECT_COUNT];
s8   game_freeze = 0;
s8   game_shake = 0;
bool game_has_dashed = false;
bool game_has_key = false;
bool game_flash_bg = false;

bool game_in_progress = false;

static u8 flash_bg_index;

u16 game_deaths;

bool will_restart = false;
s8   delay_restart = 0;

bool pause_player = false;
bool flash_bg = false;

// game time hours, minutes, seconds, frames
u8 gth, gtm, gts, gtf;

static void sga_init_level();
static void sga_init_time();
static void sga_update_time();

static void _update_shake();
static void   _draw_shake();

static void clear_fruit_table();
static void break_update();

void sga_init()
{
    game_in_progress = true;

    level_idx = INITIAL_LEVEL;

    sprite_clear_all_slots();
    level_clear_tilemap();

    sga_init_time();
    banner_init();

    cloudlayer_init();
    snow_init();
    letterbox_enable();

    flash_bg_index = 0;
    game_deaths = 0;
    clear_fruit_table();

    sga_init_level();
}

static void _update()
{
    // TODO: frames

    // cancel if freeze
    if (game_freeze > 0) {
        game_freeze -= 1;
        return;
    }

    cloudlayer_update();

    // screenshake
    _update_shake();

    // restart (soon)
    if (will_restart && delay_restart > 0) {
        delay_restart -= 1;
        if (delay_restart == 0) {
            will_restart = false;
            static u8 rctr = 0;
            // DBG8X(0,0,rctr++);
            sga_init_level();
        }
    }

    // update each object
    for (u8 i = 0; i < GAME_OBJECT_COUNT; i++) {
        if (!objarr[i].enabled) continue;
        gobj_move  (&objarr[i]);
        gobj_update(&objarr[i]);
    }

    smoke_update();
    snow_update();
    banner_update();
    break_update();
}

static u8 flash_bg_ctr = 0;

static void perform_flash_bg()
{
    if (flash_bg_ctr++ >= 4) {
        flash_bg_ctr = 0;
        flash_bg_index++;
        if (flash_bg_index >= 6)
            flash_bg_index = 0;
        cloudlayer_load_palette(flash_bg_index);
    }

}

static void _draw()
{
    if (game_freeze > 0)
        return;

    if (game_flash_bg)
        perform_flash_bg();

    _draw_shake();

    letterbox_draw();

    // draw objects
    for (u8 i = 0; i < GAME_OBJECT_COUNT; i++) {
        if (!objarr[i].enabled) continue;
        gobj_draw(&objarr[i]);
    }

    smoke_draw();
    snow_draw();

    banner_draw();
}

void sga_update()
{
    _draw();

    if (is_debug) {
        // draw tally
        print_set_pos(0, 27);
        print_char('D');
        u16 dlin = getLinesSinceBottomSync();
        if (dlin < 10) print_char(' ');
        if (dlin < 100) print_char(' ');
        print_dec_word(dlin);
    }

    _update();

    sga_update_time();

    if (is_debug) {
        // update tally
        print_set_pos(0, 28);
        print_char('U');
        u16 ulin = getLinesSinceBottomSync();
        if (ulin < 10) print_char(' ');
        if (ulin < 100) print_char(' ');
        print_dec_word(ulin);

        // DEBUG: NEXT LEVEL
        static bool pnextlev = false;
        bool nextlev = zxkeySPC();
        if (nextlev && !pnextlev && !zxkeyCAP())
            game_next_level();

        pnextlev = nextlev;

        // DEBUG: reset
        static bool preset = false;
        bool reset = zxkey0();
        if (reset && !preset)
            sga_init();

        preset = reset;

        // DEBUG: debugcol
        static bool pdebugcol = false;
        bool debugcol = zxkeyCAP() && zxkeyC();
        if (debugcol && !pdebugcol)
            level_debug_coltable();

        pdebugcol = debugcol;        

        // DEBUG: letterbox
        static bool plben = false;
        bool lben = zxkeyCAP() && zxkeyL();
        if (lben && !plben) {
            if (letterbox_get_enabled())
                letterbox_disable();
            else
                letterbox_enable();
        }

        plben = lben;
    }
}

void sga_exit()
{
    letterbox_disable();
    sprite_clear_all_slots();
    cloudlayer_clear();
    game_in_progress = false;   
}

///////////////////////////////////////////////////////////////////////////////

static u8 timer_fps;

void sga_init_time()
{
    gth = gtm = gts = gtf = 0;

    // https://wiki.specnext.dev/Peripheral_1_Register
    u8 peri1reg = ZXN_READ_REG(0x05);
    if (peri1reg & 0x04)
        timer_fps = 30;
    else
        timer_fps = 25;

    if (is_debug) {
        DBGTEXT(36, 0, "DAPR");
        DBGTEXT(36, 1, "2024");
        DBG8   (36, 31, 2*timer_fps);
        DBGTEXT(38, 31,"HZ");
    }        
}

void sga_update_time()
{
    // gts++; // debug
    if (level_idx < LEVEL_SUMMIT)
        gtf++;

    if (gtf >= timer_fps) {
        gtf = 0;
        gts++;
    }

    if (gts >= 60) {
        gts = 0;
        gtm++;
    }

    if (gtm >= 60) {
        gtm = 0;
        gth++;
    }

    if (is_debug) {
        DBG8R(37, 26, gth);
        DBG8R(37, 27, gtm);
        DBG8R(37, 28, gts);
        DBG8R(37, 29, gtf);
    }
}

///////////////////////////////////////////////////////////////////////////////

static bool prev_break = false;
static s8 fctr = 0;
static s8 sctr = 0;

#define SECONDS_FOR_BREAK 3

static void break_update()
{
    bool actn_break = (zxkeyCAP() && zxkeySPC()) || nxkeyBreak();
    if (!actn_break) {
        fctr = timer_fps;
        sctr = SECONDS_FOR_BREAK;
        sprite_clear_slot(SLOT_BRKCOUNT);
    }
    else {
        SpriteDef sdef;
        sdef.slot = SLOT_BRKCOUNT;
        sdef.pal = SPAL_ORANGE;
        sdef.pat = SPAT_DIGIT + sctr;
        sdef.mirrot = ATTR_____;
        sdef.scale = SCALE_X1 | SCALE_Y1;
        sdef.x = 301;
        sdef.y = 8;
        sprite_update(&sdef);
        fctr--;
        if (fctr == 0) {
            fctr = timer_fps;
            sctr--;
            if (sctr == 0)
                fctr = 5;
            else if (sctr < 0)
                sc_switch_screen(sma_init, sma_update, sma_exit);
        }
    }
    prev_break = actn_break;
}

///////////////////////////////////////////////////////////////////////////////

void game_next_level()
{
    if (++level_idx >= LEVEL_COUNT) level_idx = 0;
    sga_init_level();
}

///////////////////////////////////////////////////////////////////////////////

void game_kill_player()
{
    // sfx_timer = 12
    game_deaths += 1;
    game_shake = 10;
	// destroy_object(player.hair)
	// destroy_object(player)
	// init_death(player.pos.x, player.pos.y)
    will_restart = true;
    delay_restart = 15;
}

///////////////////////////////////////////////////////////////////////////////

static bool fruit_table[LEVEL_COUNT];

static void clear_fruit_table()
{
    memset(fruit_table, 0, LEVEL_COUNT);
}

bool game_fruit_is_taken()
{
    return fruit_table[level_idx];
}

void game_fruit_take()
{
    fruit_table[level_idx] = true;
}

u8 game_fruit_count()
{
    u8 fcnt = 0;
    for (u8 i = 0; i < LEVEL_COUNT; i++) {
        if (fruit_table[i]) fcnt++;
    }
    return fcnt;
}


///////////////////////////////////////////////////////////////////////////////

static void sga_disable_all_game_objects() {
    for (u8 i = 0; i < GAME_OBJECT_COUNT; i++) {
        objarr[i].enabled = false;
    }
}

static u8 sprite_slot = SLOT_GAMEOBJECT;

static void sga_clear_all_sprite_slots() {
    for (u8 slot = SLOT_GAMEOBJECT; slot < sprite_slot; slot++)
        sprite_clear_slot(slot);
}

static u8* gobj_heap_ptr;

// PITFALL: must be u8[], NOT u8*
// when using u8*, pointer points to NULL (0x0000), corrupting whatever is
// there (in this case, master level collision table, beginning with level 1)
extern u8 gobj_heap[];

#define DBG_HEAP() { \
    DBG16X(0,31,gobj_heap_ptr - gobj_heap); \
    DBGTEXT(0,31,"H") \
}

static GameObject* player = NULL;

///////////////////////////////////////////////////////////////////////////////
//
//   ###
//    #     #    #    #   #####
//    #     ##   #    #     #
//    #     # #  #    #     #
//    #     #  # #    #     #
//    #     #   ##    #     #
//   ###    #    #    #     #
//
///////////////////////////////////////////////////////////////////////////////

extern s8 max_djump;

static u8 gidx = 0;

static void sga_init_level()
{
    smoke_clear();

    level_load(level_idx);

    if (level_idx <= LEVEL_BIG_CHEST) {
        cloudlayer_set_old();
        max_djump = 1;
    }
    else {
        cloudlayer_set_new();
        max_djump = 2;
    }

    if (level_idx < LEVEL_OLD_SITE)
        music_subsong_init(SS_FIRST_LEVELS);
    else if (level_idx == LEVEL_OLD_SITE)
        music_subsong_init(SS_INTERMISSION);
    else if (level_idx < LEVEL_BIG_CHEST)
        music_subsong_init(SS_SECOND_LEVELS);
    else if (level_idx == LEVEL_BIG_CHEST)
        music_subsong_init(SS_INTERMISSION);
    else if (level_idx < LEVEL_SUMMIT)
        music_subsong_init(SS_THIRD_LEVELS);
    else if (level_idx == LEVEL_SUMMIT)
        music_subsong_init(SS_INTERMISSION);

    game_has_dashed = false;
    game_has_key = false;

    sga_disable_all_game_objects();
    sga_clear_all_sprite_slots();

    // reset sprite slot
    sprite_slot = SLOT_GAMEOBJECT;

    // reset malloc heap
    gobj_heap_ptr = gobj_heap;
    DBG_HEAP();

    DBGTEXT(0,30,"LE");
    DBG8R(1,30,level_idx);

    gidx = 0;

    u8* ptr = coltable;
    u8 val; 
    for (u8 j = 0; j < 16; j++) {
        for (u8 i = 0; i < 16; i++) {
            val = *ptr;
            val -= 128;
            if (val == TYPE_PLAYER) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                player_init(go);
                player = go;
            }
            else if (val == TYPE_SPRING) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                spring_init(go);
            }
            else if (val == TYPE_FRUIT && !game_fruit_is_taken()) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                fruit_init(go);
            }
            else if (val == TYPE_FLYFRUIT && !game_fruit_is_taken()) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                flyfruit_init(go);
            }
            // else if (val == TYPE_FALLFLOOR && i == 4 && j == 15) {
            else if (val == TYPE_FALLFLOOR) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                fallfloor_init(go);
            }
            else if (val == TYPE_KEY) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                key_init(go);
            }
            else if (val == TYPE_CHEST) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                chest_init(go);
            }
            else if (val == TYPE_BALLOON) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                balloon_init(go);
            }
            // else if (val == SPAT_PLATFORM_L && i == 12 && j == 13) {
            else if (val == SPAT_PLATFORM_L) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                platform_init_left(go);
            }
            else if (val == SPAT_PLATFORM_R) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                platform_init_right(go);
            }
            else if (val == TYPE_TOMBSTONE) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                tombstone_init(go);
            }
            else if (val == TYPE_BIGCHEST) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                bigchest_init(go);
            }
            else if (val == TYPE_FAKEWALL) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                fakewall_init(go);
            }
            else if (val == TYPE_FLAG) {
                GameObject* go = &objarr[gidx++];
                gobj_init(go, i, j);
                flag_init(go);
            }
            ptr++;
        }
    }

    level_create_coltable();

    banner_start_level();
}

u8 game_sprite_slot_next()
{
    return sprite_slot++;
}

u8* game_malloc(u8 size)
{
    u8* res = gobj_heap_ptr;
    memset(res, 0, size);
    gobj_heap_ptr += size;
    DBG_HEAP();

    return res;
}

GameObject* game_create_object()
{
    GameObject* go = &objarr[gidx++];
    gobj_init(go, 0, 0);
    return go;
}


///////////////////////////////////////////////////////////////////////////////
//
//   #####
//  #     #   ####   #       #        #   #####   ######
//  #        #    #  #       #        #   #    #  #
//  #        #    #  #       #        #   #    #  #####
//  #        #    #  #       #        #   #    #  #
//  #     #  #    #  #       #        #   #    #  #
//   #####    ####   ######  ######   #   #####   ######
//
///////////////////////////////////////////////////////////////////////////////

bool game_check_type(GameObject* go, u8 type, u8 dx, u8 dy)
{
    return game_collide_type(go, type, dx, dy) != NULL;
}

GameObject* game_collide_type(GameObject* go, u8 type, u8 dx, u8 dy)
{
    if (!go->collideable) return NULL;
    for (u8 i = 0; i < GAME_OBJECT_COUNT; i++) {
        GameObject* other = &objarr[i];
        // if (go->type == TYPE_FALLFLOOR && type == TYPE_SPRING)
        //     DBG8(37,i,other->type);
        if (!other->enabled)     continue;
        if (!other->collideable) continue;
        if (other->type != type) continue;
        if (other == go)         continue;
        // if (go->type == TYPE_PLAYER && type == TYPE_FALLFLOOR && dx == 0 && dy == 1) {
        //     DBG8X(0,0,dx);
        //     DBG8X(0,1,dy);
        //     TALLY(2);
        // }
        if (gobj_check_objects(go, other, dx, dy))
            return other;
    }
    return NULL;
}

bool game_check_player(GameObject* go, u8 dx, u8 dy)
{
    if (!player->collideable) return false;
    if (!go->collideable) return false;
    return gobj_check_objects(go, player, dx, dy);
}

GameObject* game_collide_player(GameObject* go, u8 dx, u8 dy)
{
    if (!player->collideable) return NULL;
    if (!go->collideable) return NULL;
    if (gobj_check_objects(go, player, dx, dy))
        return player;
    else
        return NULL;
}

///////////////////////////////////////////////////////////////////////////////
//
// game shake
//
//       -2   -1    0    1    2
//                      13E  13C
//  X     4    2    0   318  316
//  Y     4    2    0   254  252
//                       FE   FC
//
//       -2   -1    0    1    2
// cnt    2    1    2    1    2
//

u16 shake_til_table_x[8] = {4, 4, 2, 0, 0, 318, 316, 316};
u8  shake_til_table_y[8] = {4, 4, 2, 0, 0, 254, 252, 252};

u16 shake_til_spr[8] = {0xFFFC, 0xFFFC, 0xFFFE, 0x0000, 0x0000, 0x0002, 0x0004, 0x0004};

u16 shake_spr_x;
u16 shake_spr_y;

static u16 shake_til_x;
static u8 shake_til_y;

extern bool slomo;

static void _update_shake()
{
    if (slomo) game_shake = 0;

    if (game_shake > 0) {
        game_shake -= 1;

        u8 ix = rndtable_next() & 7;
        shake_til_x = shake_til_table_x[ix];
        shake_spr_x = shake_til_spr    [ix];
        u8 iy = rndtable_next() & 7;
        shake_til_y = shake_til_table_y[iy];
        shake_spr_y = shake_til_spr    [iy];
    }
    else {
        shake_spr_x = 0;
        shake_spr_y = 0;
        shake_til_x = 0;
        shake_til_y = 0;
    }
}

static void _draw_shake()
{
    ZXN_WRITE_REG(0x2F, shake_til_x >> 8);
    ZXN_WRITE_REG(0x30, shake_til_x);
    ZXN_WRITE_REG(0x31, shake_til_y);
}
