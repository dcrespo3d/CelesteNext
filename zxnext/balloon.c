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

#include "balloon.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "string.h"
#include "util_math.h"
#include "sfx_player.h"

typedef struct {
    s16 starty;
    bool visible;
    u8 offset;
    s8 timer;
    s8 modctr;
    s8 modval;
    SpriteDef cord;
} BalloonData;

#define data ((BalloonData*)go->derived_data)

void balloon_init(GameObject* go)
{
    go->derived_data = game_malloc(sizeof(BalloonData));
    data->cord.slot = game_sprite_slot_next();
    data->cord.pat = SPAT_CORD;
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_BALLOON;
    go->derived_update = balloon_update;
    go->derived_draw = balloon_draw;
    go->hbx = go->hby = -1;
    go->hbw = go->hbh = 10;
    data->visible = true;
    data->starty = go->posy;
}

extern s8 djump;
extern s8 max_djump;

void balloon_update(GameObject* go)
{
    if (data->visible) {
        data->offset += 3;
        go->posy = data->starty + (sintable[data->offset] << 2);
        data->modctr++;
        if (data->modctr > 12) {
            data->modctr = 0;
            data->modval++;
            if (data->modval > 2)
                data->modval = 0;
        }
        data->cord.pat = SPAT_CORD + data->modval;
        GameObject* hit = game_collide_player(go, 0, 0);
        if (hit != NULL) {
            sfx_play_balloonpop();
            smoke_init(go->posx, go->posy);
            djump = max_djump;
            data->visible = false;
            data->timer = 60;
            data->cord.pat = 0;
            go->sdef.pat = 0;
        }
    }
    else if (data->timer > 0) {
        data->timer -= 1;
    }
    else {
        smoke_init(go->posx, go->posy);
        data->cord.pat = SPAT_CORD;
        go->sdef.pat = SPAT_BALLOON;
        data->visible = true;
        data->offset = 0;
        sfx_play_balloonrespawn();
    }

}

void balloon_draw(GameObject* go)
{
    data->cord.x = X_SCREEN_4_FIXPOS(go->posx);
    data->cord.y = Y_SCREEN_4_FIXPOS(go->posy) + 12;
    sprite_update(&data->cord);
}
