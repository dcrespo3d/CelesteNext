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

#include "player.h"
#include "sprite_manager.h"
#include "print_tile.h"
#include "control.h"
#include "keyb.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "game_object.h"
#include "util_math.h"
#include "tables.h"
#include "print_tile.h"
#include "hair.h"
#include "death.h"
#include "persist.h"
#include "level.h"
#include "smoke.h"
#include "sfx_player.h"

GameObject* player;

// constants
#define MAXRUN    256
#define GND_ACCEL 154   // 0.6    x 256 =  153.6
#define AIR_ACCEL 102   // 0.4    x 256 =  102.4
#define ICE_ACCEL  13   // 0.05   x 256 =   12.8
#define DECEL      38   // 0.15   x 256 =   38.4
#define MAX_FALL  512   // 2.0    x 256 =  512.0 
#define GRAVITY    54   // 0.21   x 256 =   53.76
#define WALL_FALL 102   // 0.4    x 256 =  102.4

#define PARAB_TOP  38   // 0.15   x 256 =   38.4

#define DASH500  1280   // 5.0    x 256 = 1280.0 
#define DASH353   905   // 3.5355 x 256 =  905.088
#define DASH200   512   // 2.0    x 256 =  512.0
#define DASH150   384   // 1.5    x 256 =  384.0
#define DASH106   272   // 1.06065x 256 =  271.5264
#define DASH100   256

static u8 color_table[4] = { SPAL_BLUE, SPAL_RED, SPAL_GREEN, SPAL_WHITE };

// variables
bool p_jump;
bool p_dash;
s8   grace;
s8   jbuffer;
s8   max_djump;
s8   djump;
s8   dash_time;
s8   dash_effect_time;
s16  dash_target_x;
s16  dash_target_y;
s16  dash_accel_x;
s16  dash_accel_y;
s16  spr_off;
bool was_on_ground;

static u8 spawn_state;
static s8 spawn_delay;
static u16 spawn_target_y;

static bool dead;

static void update_spawn_state(GameObject* _gobj);

void player_init(GameObject* go)
{
    player = go;
    go->type = TYPE_PLAYER;
    go->collideable = false;
    go->derived_update = player_update;
    go->derived_draw = player_draw;

    spawn_target_y = go->posy;
    go->posy = 192 << 8;
    hair_init(go->posx, go->posy);

    p_jump = false;
    p_dash = false;
    grace = 0;
    jbuffer = 0;
    // max_djump = 1;   // initialized in sga_init_level
    djump = max_djump;
    dash_time = 0;
    dash_effect_time = 0;
    dash_target_x = 0;
    dash_target_y = 0;
    dash_accel_x = 0;
    dash_accel_y = 0;

    was_on_ground = false;

    spawn_state = 4;
    spawn_delay = 0;

    go->sdef.slot = SLOT_PLAYER;
    // psdef.x = 0;
    // psdef.y = 0;
    go->sdef.pal = 0;
    go->sdef.mirrot = 0;
    go->sdef.pat = 1;
    go->sdef.scale = 0;
    go->hbx = 1;
    go->hby = 3;
    go->hbw = 6;
    go->hbh = 5;

    dead = false;

    sfx_play_spawn();
}

void player_clear()
{
    sprite_clear_slot(SLOT_PLAYER);
    hair_clear();
}

void player_kill(GameObject* go)
{
    // player_clear();
    sfx_play_death();
    dead = true;
    death_init(go->posx, go->posy);
    go->base_draw = false;
    game_kill_player();
}

static void debug_controls()
{
    print_set_pos(0, 0);
    if (actnJump)   print_char('J');
    else            print_char(' ');
    if (actnUp    ) print_char('U');
    else            print_char(' ');
    if (actnDash)   print_char('D');
    else            print_char(' ');
    print_set_pos(0, 1);
    if (actnLeft  ) print_char('L');
    else            print_char(' ');
    if (actnDown  ) print_char('D');
    else            print_char(' ');
    if (actnRight ) print_char('R');
    else            print_char(' ');
    
    u8 kcnt = keyb_count();
    print_set_pos(36,31)
    if (kcnt == 1) print_hex_word(keyb_code());
    else           print_str("----");
}

void player_update(GameObject* go)
{
    // debug_controls();

    if (spawn_state != 0) {
        update_spawn_state(go);
        hair_update(go->posx, go->posy, 0);
        return;
    }

    // dead state: just update death anim
    if (dead) {
        death_update();
        return;
    }
    else if (is_debug && zxkey1()) {
        player_kill(go);
        return;
    }

    if (pause_player) return;

    // read_inputs(); // implicit

    // horiz_dir
    s8 hdir = 0;
    if (actnLeft)   hdir -= 1;
    if (actnRight)  hdir += 1;

    // vert dir
    s8 vdir = 0;
    if (actnUp)     vdir -= 1;
    if (actnDown)   vdir += 1;

    // go->spdx = hdir << 8;
    // go->spdy = vdir << 8;

    // spikes collide
    s8 spx = WORLD_4_FIXPOS(go->posx) + go->hbx;
    s8 spy = WORLD_4_FIXPOS(go->posy) + go->hby;
    if (level_spikes_at(spx, spy, go->hbw, go->hbh, go->spdx >> 8, go->spdy >> 8))
        player_kill(go);
    // DBG8X(0, 0, spx);
    // DBG8X(0, 1, spy);

    // bottom_death
#define Y_BOTTOM_LIMIT FIXPOS_4_WORLD(128)
    if (go->posy > Y_BOTTOM_LIMIT)
        player_kill(go);


    bool on_ground = gobj_is_solid(go, 0, 1);
    bool on_ice    = gobj_is_ice  (go, 0, 1);
    // DBGTEXT(36,0,"GND"); print_hex_nibble(on_ground);
    // DBGTEXT(36,1,"ICE"); print_hex_nibble(on_ice);

    // smoke particles
    if (on_ground && !was_on_ground)
        smoke_init(go->posx, go->posy + (4 << 8));

    // jump
    bool jump = actnJump && (!p_jump);
    p_jump = actnJump;
    if (jump)
        jbuffer = 4;
    else if (jbuffer > 0)
        jbuffer -= 1;

    // dash
    bool dash = actnDash && (!p_dash);
    p_dash = actnDash;

    // DBG4X(36,3,dash);
    // DBG4X(36,4,p_dash);

    if (on_ground) {
        grace = 6;
        if (djump < max_djump) {
            if (!dead) sfx_play_dashland();
            djump = max_djump;
        }
    }
    else if (grace > 0)
        grace -= 1;

    // DBGTEXT(36,3,"DT");
    // DBG8X(38,3,dash_time);

    dash_effect_time -= 1;
    if (dash_time > 0) {
        smoke_init(go->posx, go->posy);
        dash_time -= 1;
        go->spdx = APPR(go->spdx, dash_target_x, dash_accel_x);
        go->spdy = APPR(go->spdy, dash_target_y, dash_accel_y);
    }
    else {
        // not dashing
        s16 accel = GND_ACCEL;

        if (!on_ground)
            accel = AIR_ACCEL;
        else if (on_ice)
            accel = ICE_ACCEL;

        if (ABS(go->spdx) > MAXRUN) {
            if (go->spdx < 0)
                go->spdx = APPR(go->spdx, -MAXRUN, DECEL);
            else
                go->spdx = APPR(go->spdx, MAXRUN, DECEL);
        }
        else
            go->spdx = APPR(go->spdx, hdir << 8, accel);

        // facing
        if (go->spdx != 0) {
            if (go->spdx < 0)
                go->sdef.mirrot = ATTR_X___;
            else
                go->sdef.mirrot = ATTR_____;
        }

        // gravity
        s16 max_fall = MAX_FALL;
        s16 gravity = GRAVITY;

        if (ABS(go->spdy) <= PARAB_TOP)
            gravity >>= 1;

        // wall slide
        if (hdir != 0 && gobj_is_solid(go, hdir, 0) && !gobj_is_ice(go, hdir, 0)) {
            max_fall = WALL_FALL;
            if (rndtable_next() < 52)
                smoke_init(go->posx + (6*hdir << 8), go->posy);
        }

        // apply gravity to speed
        if (!on_ground)
            go->spdy = APPR(go->spdy, max_fall, gravity);

        // jump
        if (jbuffer > 0) {
            if (grace > 0) {
                // normal jump
                sfx_play_jump();
                jbuffer = 0;
                grace = 0;
                go->spdy -= (2 << 8);
                smoke_init(go->posx, go->posy + (4 << 8));
            }
            else {
                // wall jump
                s8 wall_dir = 0;
                if      (gobj_is_solid(go, -3, 0)) wall_dir = -1;
                else if (gobj_is_solid(go,  3, 0)) wall_dir =  1;
                if (wall_dir != 0) {
                    sfx_play_walljump();
                    jbuffer = 0;
                    go->spdy = (-2 << 8);
                    if (wall_dir < 0)
                        go->spdx = ( 2 << 8);
                    else
                        go->spdx = (-2 << 8);
                    if (!gobj_is_ice(go, 3*wall_dir, 0))
                        smoke_init(go->posx + 6*wall_dir, go->posy);
                }
            }
        }

        // dash
        if (djump > 0 && dash) {
            smoke_init(go->posx, go->posy);
            djump -= 1;
            dash_time = 4;
            game_has_dashed = true;
            dash_effect_time = 10;
            if (hdir < 0) {
                // left
                if (vdir < 0) {
                    // up
                    go->spdx = -DASH353;
                    go->spdy = -DASH353;
                    dash_target_x = -DASH200;
                    dash_target_y = -DASH150;
                    dash_accel_x = DASH150;
                    dash_accel_y = DASH150;
                }
                else if (vdir > 0) {
                    // down
                    go->spdx = -DASH353;
                    go->spdy =  DASH353;
                    dash_target_x = -DASH200;
                    dash_target_y =  DASH200;
                    dash_accel_x = DASH150;
                    dash_accel_y = DASH150;
                }
                else {
                    // vert center
                    go->spdx = -DASH500;
                    go->spdy =  0;
                    dash_target_x = -DASH200;
                    dash_target_y =  0;
                    dash_accel_x = DASH106;
                    dash_accel_y = DASH150;
                }
            }
            else if (hdir > 0) {
                // right
                if (vdir < 0) {
                    // up
                    go->spdx =  DASH353;
                    go->spdy = -DASH353;
                    dash_target_x =  DASH200;
                    dash_target_y = -DASH150;
                    dash_accel_x = DASH150;
                    dash_accel_y = DASH150;
                }
                else if (vdir > 0) {
                    // down
                    go->spdx =  DASH353;
                    go->spdy =  DASH353;
                    dash_target_x =  DASH200;
                    dash_target_y =  DASH200;
                    dash_accel_x = DASH150;
                    dash_accel_y = DASH150;
                }
                else {
                    // vert center
                    go->spdx =  DASH500;
                    go->spdy =  0;
                    dash_target_x =  DASH200;
                    dash_target_y =  0;
                    dash_accel_x = DASH106;
                    dash_accel_y = DASH150;
                }
            }
            else {
                // horiz center
                if (vdir < 0) {
                    // up
                    go->spdx = 0;
                    go->spdy = -DASH500;
                    dash_target_x = 0;
                    dash_target_y = -DASH150;
                    dash_accel_x = DASH150;
                    dash_accel_y = DASH106;
                }
                else if (vdir > 0) {
                    // down
                    go->spdx = 0;
                    go->spdy = DASH500;
                    dash_target_x = 0;
                    dash_target_y = DASH200;
                    dash_accel_x = DASH150;
                    dash_accel_y = DASH106;
                }
                else {
                    // effective horiz dir
                    s8 ehdir = ((go->sdef.mirrot & ATTR_X___) != 0) ? -1 : 1;
                    if (ehdir < 0) {
                        go->spdx = -DASH100;
                        go->spdy = 0;
                        dash_target_x = -DASH200;
                        dash_target_y = 0;
                        dash_accel_x = DASH106;
                        dash_accel_y = DASH150;
                    }
                    else {
                        go->spdx = DASH100;
                        go->spdy = 0;
                        dash_target_x = DASH200;
                        dash_target_y = 0;
                        dash_accel_x = DASH106;
                        dash_accel_y = DASH150;
                    }
                }
            }

            sfx_play_dash();
            game_freeze = 2;
            game_shake = 6;

            // debug traces

            // DBG16X(36,4,go->spdx);
            // DBG16X(36,5,go->spdy);
            // DBG16X(36,6,dash_target_x);
            // DBG16X(36,7,dash_target_y);
            // DBG16X(36,8,dash_accel_x);
            // DBG16X(36,9,dash_accel_y);

            // DBG16X(36,4,ABS(go->spdx));
            // DBG16X(36,5,ABS(go->spdy));
            // DBG16X(36,6,ABS(dash_target_x));
            // DBG16X(36,7,ABS(dash_target_y));
            // DBG16X(36,8,ABS(dash_accel_x));
            // DBG16X(36,9,ABS(dash_accel_y));
        }
        else if (dash && djump <= 0) {
            // dash depleted
            sfx_play_dashdepleted();
            smoke_init(go->posx, go->posy);
        }
    }

    // animation
    spr_off += 64;
    if (!on_ground) {
        if (gobj_is_solid(go, hdir, 0))
            go->sdef.pat = SPAT_PLAYER_5;
        else
            go->sdef.pat = SPAT_PLAYER_3;
    }
    else if (vdir > 0)
        go->sdef.pat = SPAT_PLAYER_6;
    else if (vdir < 0)
        go->sdef.pat = SPAT_PLAYER_7;
    else if (go->spdx == 0 || hdir == 0)
        go->sdef.pat = SPAT_PLAYER_1;
    else
        go->sdef.pat = SPAT_PLAYER_1 + ((spr_off >> 8) & 3);

    if (spr_off > (4 << 8)) spr_off -= (4 << 8);

    // next room
#define Y_TOP_LIMIT FIXPOS_4_WORLD(-4)
    if (go->posy < Y_TOP_LIMIT)
        game_next_level();

    was_on_ground = on_ground;

#define X_LEFT_LIMIT  FIXPOS_4_WORLD(-1)
#define X_RIGHT_LIMIT FIXPOS_4_WORLD(121)

    // check screen horizontal limits
    
    if (go->posx < X_LEFT_LIMIT) {
        go->posx = X_LEFT_LIMIT;
        go->spdx = 0;
    }
    if (go->posx > X_RIGHT_LIMIT) {
        go->posx = X_RIGHT_LIMIT;
        go->spdx = 0;
    }

    hair_update(go->posx, go->posy, go->sdef.mirrot);
}

static bool hair_flash = true;
static u8 hair_flash_ctr = 0;

void player_draw(GameObject* go)
{
    // dead state: just draw death anim
    if (dead) {
        death_draw();
        return;
    }

    u8 color = color_table[djump];
    if (djump == 2) {
        if (hair_flash) color = SPAL_WHITE;
        hair_flash_ctr++;
        if (hair_flash_ctr > 2) {
            hair_flash_ctr = 0;
            hair_flash = !hair_flash;
        }
    }
    go->sdef.pal = color;

    hair_draw(color);
}

///////////////////////////////////////////////////////////////////////////////

extern s8 game_shake;

static void update_spawn_state(GameObject* go)
{
    switch(spawn_state) {
        case 4: // just spawned
            go->sdef.pat = SPAT_PLAYER_3;
            go->posy = 192 << 8;
            go->spdy = -4 << 8;
            spawn_state = 3;
            spawn_delay = 0;
            go->solids = false;
            break;
        case 3: // jumping up
            if (go->posy < spawn_target_y + (16 << 8)) {
                spawn_state = 2;
                spawn_delay = 2;
            }
            break;
        case 2: // falling
            go->spdy += 128; // 0.5
            if (go->spdy > 0 && spawn_delay > 0) {
                go->spdy = 0;
                spawn_delay -= 1;
            }
            if (go->spdy > 0 && go->posy > spawn_target_y) {
                go->posy = spawn_target_y;
                go->spdy = 0;
                spawn_state = 1;
                spawn_delay = 5;
                game_shake = 5;
                smoke_init(go->posx, go->posy + (4 << 8));
                sfx_play_spawnstep();
            }
            break;
        case 1: // landing
            spawn_delay -= 1;
            go->sdef.pat = SPAT_PLAYER_6;
            if (spawn_delay < 0) {
                spawn_state = 0;
                go->solids = true;
                go->collideable = true;
                go->sdef.pat = SPAT_PLAYER_1;     // unneeded
            }

            break;
    }

}
