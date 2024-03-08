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

#include "tombstone.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include <string.h>

// typedef struct {
// } TombstoneData;

// #define data ((TombstoneData*)go->derived_data)

static bool messageShown;

#define MSGX0 8
#define MSGY0 24

static const char* msgline0 = "                        ";
static const char* msgline1 = " -- Celeste Mountain -- ";
static const char* msgline2 = " this memorial to those ";
static const char* msgline3 = " perished on the climb  ";

#define TMPBUF 0x5000
#define TMDATA 0x4000 + 80*MSGY0
#define BKSIZE 80*5

void tombstone_init(GameObject* go)
{
    go->type = TYPE_TOMBSTONE;
    go->hbw = go->hbh = 16;
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_TOMBSTONE;
    go->sdef.scale = SCALE_X2 | SCALE_Y2;
    // go->derived_data = game_malloc(sizeof(TombstoneData));
    go->derived_update = tombstone_update;
    messageShown = false;
}

void tombstone_update(GameObject* go)
{
    GameObject* hit = game_collide_player(go, 0, 8);
    if (!messageShown && hit != NULL) {
        memcpy((u8*)TMPBUF, (u8*)TMDATA, BKSIZE);
        messageShown = true;
        print_set_pos(MSGX0, MSGY0+0); print_str(msgline0);
        print_set_pos(MSGX0, MSGY0+1); print_str(msgline1);
        print_set_pos(MSGX0, MSGY0+2); print_str(msgline2);
        print_set_pos(MSGX0, MSGY0+3); print_str(msgline3);
        print_set_pos(MSGX0, MSGY0+4); print_str(msgline0);
    }
    else if (messageShown && hit == NULL) {
        memcpy((u8*)TMDATA, (u8*)TMPBUF, BKSIZE);
        messageShown = false;
    }
}
