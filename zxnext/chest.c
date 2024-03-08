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

#include "chest.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "fruit.h"
#include "sfx_player.h"

typedef struct {
    s8 timer;
    s16 startx;
} ChestData;

#define data ((ChestData*)go->derived_data)

#define POINTS_DURATION 30

void chest_init(GameObject* go)
{
    go->posx -= (4 << 8);
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_CHEST;
    go->derived_data = game_malloc(sizeof(ChestData));
    go->derived_update = chest_update;
    data->timer = 20;
    data->startx = go->posx;
    
}

void chest_update(GameObject* go)
{
    if (game_has_key)
    {
        data->timer -= 1;
        go->posx = data->startx + (randi_11() << 8);
        if (data->timer == 0) {
            sprite_clear_slot(go->sdef.slot);
            if (!game_fruit_is_taken()) {
                go->posy -= (4 << 8);
                fruit_init(go);
            }
            else {
                go->enabled = false;
            }
            sfx_play_chestopen();
        }
    }
}
