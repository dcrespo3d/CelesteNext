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

#include "fakewall.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "fruit.h"
#include "util_math.h"
#include "sfx_player.h"

// typedef struct {
//     s8 timer;
// } FakewallData;

#define data ((FakewallData*)go->derived_data)

extern s8 dash_effect_time;
extern s8 dash_time;

void fakewall_init(GameObject* go)
{
    DBGTEXT(1,30,"F");
    go->type = TYPE_FAKEWALL;
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_FAKEWALL;
    go->sdef.scale = SCALE_X2 | SCALE_Y2;
    go->hbw = go->hbh = 16;
    go->derived_update = fakewall_update;
}

void fakewall_update(GameObject* go)
{
    go->hbx = go->hby = -1;
    go->hbw = go->hbh = 18;
    GameObject* hit = game_collide_player(go, 0, 0);
    go->hbx = go->hby = 0;
    go->hbw = go->hbh = 16;
    if (hit != NULL && dash_effect_time > 0) {
        hit->spdx = -APPLY_SIGN(hit->spdx, 384);
        hit->spdy = -384;
        dash_time = -1;

        smoke_init(go->posx           , go->posy);
        smoke_init(go->posx + (8 << 8), go->posy);
        smoke_init(go->posx           , go->posy + (8 << 8));
        smoke_init(go->posx + (8 << 8), go->posy + (8 << 8));

        // reuse for fruit
        sprite_clear_slot(go->sdef.slot);
        if (!game_fruit_is_taken()) {
            go->posx += (4 << 8);
            go->posy += (4 << 8);
            go->hbw = go->hbh = 8;
            go->sdef.scale = SCALE_X1 | SCALE_Y1;
            fruit_init(go);
        }
        else {
            go->enabled = false;
        }
        sfx_play_chestopen();
    }
}
