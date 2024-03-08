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

#include "key.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "sfx_player.h"

// static u8  aspr[8] = {0, 1,  2, 1, 0, 1, 2, 1};
// static u8  ainv[8] = {0, 0,  8, 8, 8, 8, 0, 0}; // 0 = ATTR_____, 8 = ATTR_X___
// static u8 table[8] = {0, 1, 10, 9, 8, 9, 2, 1};

static u8 table[16] = {0, 0, 0, 1, 1, 10, 9, 9, 8, 8, 8, 9, 9, 2, 1, 1};

typedef struct {
    u8 frame;
} KeyData;

#define data ((KeyData*)go->derived_data)

#define POINTS_DURATION 30

void key_init(GameObject* go)
{
    // DEBUG TEST
    // go->posx -= (32 << 8);
    // go->posy -= (24 << 8);
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_KEY;
    go->derived_data = game_malloc(sizeof(KeyData));
    go->derived_update = key_update;
}

extern s8 djump;
extern s8 max_djump;

void key_update(GameObject* go)
{
    u8 idx = (data->frame >> 2) & 0x0F;
    data->frame++;
    go->sdef.pat = SPAT_KEY + (table[idx] & 3);
    go->sdef.mirrot = (table[idx] & 8);

    if (game_check_player(go, 0, 0)) {
        go->enabled = false;
        sprite_clear_slot(go->sdef.slot);
        game_has_key = true;
        sfx_play_key();
    }
}
