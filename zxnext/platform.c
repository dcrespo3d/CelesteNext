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

#include "platform.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "util_math.h"

typedef struct {
    u16 last;
} PlatformData;

#define data ((PlatformData*)go->derived_data)

#define SPD065 166 // 0.65

void platform_init(GameObject* go)
{
    go->type = TYPE_PLATFORM;
    go->posx -= (4 << 8);
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_PLATFORM;
    go->sdef.scale = SCALE_X2 | SCALE_Y2;
    go->derived_data = game_malloc(sizeof(PlatformData));
    go->derived_update = platform_update;
    go->hbw = 16;
    data->last = go->posx;
}

void platform_init_left (GameObject* go)
{
    platform_init(go);
    go->spdx = -SPD065;
}

void platform_init_right(GameObject* go)
{
    platform_init(go);
    go->spdx = SPD065;
}

#define X_LEFT_LIMIT  FIXPOS_4_WORLD(-16)
#define X_RIGHT_LIMIT FIXPOS_4_WORLD(128)

void platform_update(GameObject* go)
{
    if      (go->posx < X_LEFT_LIMIT ) go->posx = X_RIGHT_LIMIT;
    else if (go->posx > X_RIGHT_LIMIT) go->posx = X_LEFT_LIMIT;
    if (!game_check_player(go, 0, 0)) {
        GameObject* hit = game_collide_player(go, 0, -1);
        if (hit != NULL) {
            gobj_move_x(hit, go->posx - data->last, 256);
        }
    }
    data->last = go->posx;
}
