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

#include "fruit.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "sfx_player.h"

typedef struct {
    s16 starty;
    u8 offset;
    bool taken;
} FruitData;

#define data ((FruitData*)go->derived_data)

#define POINTS_DURATION 30

void fruit_init(GameObject* go)
{
    go->type = TYPE_FRUIT;
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_FRUIT;
    go->derived_data = game_malloc(sizeof(FruitData));
    go->derived_update = fruit_update;
    data->starty = go->posy;
    data->offset = 0;
    data->taken = false;
}

extern s8 djump;
extern s8 max_djump;

void fruit_update(GameObject* go)
{
    u8 offset = data->offset;
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
            offset = 0;
            sfx_play_fruitcaught();
        }
        else {
            offset += 6;
            go->posy = data->starty + 5 * sintable[offset];
        }
    }
    else {
        go->sdef.pal = (offset & 1) ? SPAL_WHITE : SPAL_RED;
        offset++;
        if (offset >= POINTS_DURATION) {
            sprite_clear_slot(go->sdef.slot);
            go->enabled = false;
        }
    }
    data->offset = offset;

}
