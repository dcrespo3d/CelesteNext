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

#include "fallfloor.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "spring.h"
#include "sfx_player.h"

typedef struct {
    s8 state;
    s8 delay;
} FallFloorData;

#define data ((FallFloorData*)go->derived_data)

#define POINTS_DURATION 30

void fallfloor_init(GameObject* go)
{
    go->type = TYPE_FALLFLOOR;
    go->collideable = true;
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_FALLFLOOR;
    go->derived_data = game_malloc(sizeof(FallFloorData));
    go->derived_update = fallfloor_update;
    // game_malloc zeroes block, no need to initialize zero values
    // data->state = 0;
    // data->delay = 0;
}

void fallfloor_update(GameObject* go)
{
    // idling
    if (data->state == 0) {
        if (game_check_player(go,0,-1) ||
            game_check_player(go,-1,0) ||
            game_check_player(go, 1, 0))
            fallfloor_break(go);
        go->sdef.pat = SPAT_FALLFLOOR;
    }
    // shaking
    else if (data->state == 1) {
        data->delay -= 1;
        if (data->delay == 0) {
            data->state = 2;
            data->delay = 60;
            go->collideable = false;
        }
        else {
            u8 off = 0;
            if (data->delay < 10) off++;
            if (data->delay <  5) off++;
            go->sdef.pat = SPAT_FALLFLOOR + off;
        }
    }
    // invisible, waiting to reset
    else if (data->state == 2) {
        data->delay -= 1;
        if (data->delay == 0) {
            data->state = 0;
            go->collideable = true;
            smoke_init(go->posx, go->posy);
        }
        go->sdef.pat = 0;
    }
}

void fallfloor_break(GameObject* go)
{
    if (data->state == 0) {
        data->state = 1;
        data->delay = 15;
        smoke_init(go->posx, go->posy);
        GameObject* hit = game_collide_type(go, TYPE_SPRING, 0, -1);
        // DBG16X(0,0,(u16)hit);
        if (hit != NULL)
            spring_break(hit);
        sfx_play_floorbreak();
    }
}
