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

#include "spring.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "fallfloor.h"
#include "sfx_player.h"

typedef struct {
    s8 hide_in;
    s8 hide_for;
    s8 delay;
} SpringData;

#define data ((SpringData*)go->derived_data)

void spring_init(GameObject* go)
{
    go->type = TYPE_SPRING;
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_SPRING;
    go->derived_data = game_malloc(sizeof(SpringData));
    go->derived_update = spring_update;
    data->hide_in = 0;
    data->hide_for = 0;
}

extern s8 djump;
extern s8 max_djump;

void spring_update(GameObject* go)
{
    if (data->hide_for > 0) {
        data->hide_for -= 1;
        if (data->hide_for == 0) {
            go->sdef.pat = SPAT_SPRING;
            data->delay = 0;
        }
    }
    else if (go->sdef.pat == SPAT_SPRING) {
        GameObject* hit = game_collide_player(go, 0, 0);
        if (hit != NULL && hit->spdy >= 0) {
            go->sdef.pat = SPAT_SPRING + 1;
            hit->posy = go->posy - (4 << 8);
            hit->spdx = 51 * (hit->spdx >> 8);  // * 0.2
            hit->spdy = -(3 << 8); 
            djump = max_djump;
            data->delay = 10;
            smoke_init(go->posx, go->posy);

            // breakable below us
            GameObject* below = game_collide_type(go, TYPE_FALLFLOOR, 0, 1);
            // DBG16X(0,0,(u16)below);
            if (below != NULL)
                fallfloor_break(below);

            sfx_play_springrelease();
        }
    }
    else if (data->delay > 0) {
        data->delay -= 1;
        if (data->delay == 0) {
            go->sdef.pat = SPAT_SPRING;
        }
    }
    // begin hiding
    if (data->hide_in > 0) {
        data->hide_in -= 1;
        if (data->hide_in == 0) {
            data->hide_for = 60;
            go->sdef.pat = 0;
        }
    }

}

void spring_break (GameObject* go)
{
    data->hide_in = 15;
}

