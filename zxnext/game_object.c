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

#include "game_object.h"
#include "sprite_manager.h"
#include "print_tile.h"
#include "util_math.h"
#include "level.h"
#include "gamedefs.h"
#include "string.h"
#include "screen_game.h"

void gobj_init(GameObject* go, u8 col, u8 row)
{
    memset(go, 0, sizeof(GameObject));

    go->enabled = true;
    go->collideable = true;
    // go->type = 0;
    // go->solids = false;
    go->posx = FIXPOS_4_GRID(col);
    go->posy = FIXPOS_4_GRID(row);
    // go->spdx = 0;
    // go->spdy = 0;
    // go->remx = 0;
    // go->remy = 0;
    // go->hbx = 0;
    // go->hby = 0;
    go->hbw = 8;
    go->hbh = 8;
    // go->derived_data = NULL;
    // go->derived_draw = NULL;
    // go->derived_update = NULL;
    go->base_draw = true;
}

void gobj_draw(GameObject* go)
{
    if (go->derived_draw) go->derived_draw(go);

    if (!go->base_draw) return;

    go->sdef.x = X_SCREEN_4_FIXPOS(go->posx);
    go->sdef.y = Y_SCREEN_4_FIXPOS(go->posy);
    sprite_update(&go->sdef);
}

void gobj_update(GameObject* go)
{
    if (go->derived_update) go->derived_update(go);
}

void gobj_move(GameObject* go)
{
    if (go->spdx == 0 && go->spdy == 0) return;

    s16 amount;
    // horizontal
    go->remx += go->spdx;
    amount = (go->remx + 128) & 0xFF00;
    go->remx -= amount;
    // debug traces
    // DBG16X(0,3,go->posx);
    // DBG16X(0,4,go->spdx);
    // DBG16X(0,5,go->remx);
    // DBG16X(0,6,amount);
    gobj_move_x(go, amount, 0);
    // vertical
    go->remy += go->spdy;
    amount = (go->remy + 128) & 0xFF00;
    // debug traces
    // DBG16X(0, 8,go->posy);
    // DBG16X(0, 9,go->spdy);
    // DBG16X(0,10,go->remy);
    // DBG16X(0,11,amount);
    go->remy -= amount;
    gobj_move_y(go, amount, 0);
}

void gobj_move_x(GameObject* go, s16 amount, s16 start)
{
    if (go->solids) {
        s16 step = SIGN(amount) << 8;
        s16 end = 256 + ABS(amount);
        for (s16 i = start; i < end; i += 256) {
            if (!gobj_is_solid(go, (step >> 8), 0)) {
                go->posx += step;
            }
            else {
                go->spdx = 0;
                go->remx = 0;
            }
        }
    }
    else {
        go->posx += amount;
    }

}

void gobj_move_y(GameObject* go, s16 amount, s16 start)
{
    if (go->solids) {
        s16 step = SIGN(amount) << 8;
        s16 end = 256 + ABS(amount);
        for (s16 i = start; i < end; i += 256) {
            if (!gobj_is_solid(go, 0, (step >> 8))) {
                go->posy += step;
            }
            else {
                go->spdy = 0;
                go->remy = 0;
            }
        }
    }
    else {
        go->posy += amount;
    }
}

bool gobj_is_solid(GameObject* go, s8 dx, s8 dy)
{
    if (dy > 0 && !game_check_type(go, TYPE_PLATFORM, dx, 0) && game_check_type(go, TYPE_PLATFORM, dx, dy))
        return true;

    s8 wx = WORLD_4_FIXPOS(go->posx);
    wx += go->hbx;
    wx += dx;
    s8 wy = WORLD_4_FIXPOS(go->posy);
    wy += go->hby;
    wy += dy;
    if (level_solid_at(wx, wy, go->hbw, go->hbh))
        return true;
    else if (game_check_type(go, TYPE_FALLFLOOR, dx, dy))
        return true;
    else if (game_check_type(go, TYPE_FAKEWALL, dx, dy))
        return true;
    else
        return false;
}

bool gobj_is_ice(GameObject* go, s8 dx, s8 dy)
{
    s8 wx = WORLD_4_FIXPOS(go->posx);
    wx += go->hbx;
    wx += dx;
    s8 wy = WORLD_4_FIXPOS(go->posy);
    wy += go->hby;
    wy += dy;
    if (level_ice_at(wx, wy, go->hbw, go->hbh))
        return true;
    else
        return false;
}

bool gobj_check_objects(GameObject* A, GameObject* B, u8 dx, u8 dy)
{
    // debug traces
    // if (A->type == TYPE_PLAYER && B->type == TYPE_FALLFLOOR && dx == 0 && dy == 1)
    // {
    //     TALLY(15);
    // }

    // perform comparison far from 255 | 0 boundary
    u8 ax = 64 + WORLD_4_FIXPOS(A->posx) + dx;
    u8 bx = 64 + WORLD_4_FIXPOS(B->posx);
    u8 ax0 = ax  + A->hbx;
    u8 ax1 = ax0 + A->hbw;
    u8 bx0 = bx  + B->hbx;
    u8 bx1 = bx0 + B->hbw;

    if (ax1 <= bx0) return false;
    if (bx1 <= ax0) return false;

    u8 ay = 64 + WORLD_4_FIXPOS(A->posy) + dy;
    u8 by = 64 + WORLD_4_FIXPOS(B->posy);
    u8 ay0 = ay  + A->hby;
    u8 ay1 = ay0 + A->hbh;
    u8 by0 = by  + B->hby;
    u8 by1 = by0 + B->hbh;

    if (ay1 <= by0) return false;
    if (by1 <= ay0) return false;

    // debug traces
    // if (A->type == TYPE_PLAYER && B->type == TYPE_FALLFLOOR && dx == 0 && dy == 1)
    // {
    //     DBG8X(0,1,ax0);
    //     DBG8X(0,2,ax1);
    //     DBG8X(0,3,ay0);
    //     DBG8X(0,4,ay1);
    //     DBG8X(0,5,bx0);
    //     DBG8X(0,6,bx1);
    //     DBG8X(0,7,by0);
    //     DBG8X(0,8,by1);

    //     DBG4X(0, 10, ax1 <= bx0);
    //     DBG4X(0, 11, bx1 <= ax0);
    //     DBG4X(0, 12, ay1 <= by0);
    //     DBG4X(0, 13, by1 <= ay0);
    // }

    return true;
}