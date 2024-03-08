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

#include "flyfruit.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "util_math.h"
#include "flyfruit.h"
#include "sfx_player.h"

typedef struct {
    bool taken;
    bool fly;
    u8 step;
    s16 starty;
    u8 slotL;
    u8 slotR;
} FlyFruitData;

#define data ((FlyFruitData*)go->derived_data)

#define POINTS_DURATION 30

void flyfruit_init_paged(GameObject* go)
{
    go->type = TYPE_FRUIT;
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_FLYFRUIT;
    go->derived_data = game_malloc(sizeof(FlyFruitData));
    go->derived_update = flyfruit_update;
    go->derived_draw = flyfruit_draw;
    // game_malloc zeroes block, no need to initialize zero values
    // data->taken = false;
    // data->fly = false;
    // data->step = 0;
    data->starty = go->posy;
    data->slotL = game_sprite_slot_next();
    data->slotR = game_sprite_slot_next();
}

extern s8 djump;
extern s8 max_djump;

#define FF350 896   // 3.5
#define FF025  64   // 0.25

void flyfruit_update_paged(GameObject* go)
{
    u8 step = data->step;
    if (!data->taken) {
        GameObject* hit = game_collide_player(go, 0, 0);
        if (hit != NULL) {
            djump = max_djump;
            game_fruit_take();
            data->taken = true;
            go->sdef.pat = SPAT_POINTS;
            go->sdef.scale = SCALE_X2|SCALE_Y2;
            go->posx -= (3<<8);
            go->posy -= (6<<8);
            go->spdy = -64; // -0.25
            step = 0;
            sprite_clear_slot(data->slotL);
            sprite_clear_slot(data->slotR);
            sfx_play_fruitcaught();
        }
        else if (data->fly) {
            // TODO: sfx
            go->spdy = APPR(go->spdy, -FF350, FF025);
            if (go->posy < FIXPOS_4_WORLD(-16))
                go->enabled = false;
        }
        else {
            if (game_has_dashed) {
                data->fly = true;
                sfx_play_fruitflown();
            }
            step += 14;
            go->spdy = sintable[step];
        }
    }
    else {
        go->sdef.pal = (step & 1) ? SPAL_WHITE : SPAL_RED;
        step++;
        if (step >= POINTS_DURATION) {
            sprite_clear_slot(go->sdef.slot);
            go->enabled = false;
        }
    }
    data->step = step;
}

void flyfruit_draw_paged(GameObject* go)
{
    if (data->taken) return;

    u8 off = 0;
    if (!data->fly) {
        s16 dy = go->posy - data->starty;
        s8 s = SIGN(dy);
        if (go->spdy < 0)
            off = 1 + MAX(0, s);
    }

    SpriteDef sdef;
    sdef.slot = data->slotL;
    sdef.x = X_SCREEN_4_FIXPOS(go->posx) - 12;
    sdef.y = Y_SCREEN_4_FIXPOS(go->posy) - 4;
    sdef.pal = 0;
    sdef.mirrot = ATTR_X___;
    sdef.pat = SPAT_WING + off;
    sdef.scale = 0;
    sprite_update(&sdef);
    sdef.slot = data->slotR;
    sdef.x += 24;
    sdef.mirrot = ATTR_____;
    sprite_update(&sdef);
}
