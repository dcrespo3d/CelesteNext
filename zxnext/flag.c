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

#pragma codeseg PAGE_58
#pragma constseg PAGE_58

#include "flag.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "banner.h"
#include "sfx_player.h"
#include "util_math.h"
#include "score.h"
#include "keyb.h"
#include "screen_controller.h"
#include "screen_enter.h"
#include "screen_scores.h"
#include "screen_main.h"
#include "player.h"

extern GameObject* player;

static bool messageShown;

static u8 framectr;
static u8 frameinc;

typedef struct {
    u8 curtslot;
    s8 dx;
} FlagData;

#define data ((FlagData*)go->derived_data)


void flag_init_paged(GameObject* go)
{
    go->type = TYPE_FLAG;
    go->posx += (5 << 8);
    // go->posx -= (32<<8);    // DEBUG
    // go->posy += (48<<8);    // DEBUG
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_FLAG;
    go->derived_data = game_malloc(sizeof(FlagData));
    go->derived_update = flag_update;
    go->derived_draw = flag_draw;
    messageShown = false;
    framectr = frameinc = 0;
    data->dx = 0;
    data->curtslot = game_sprite_slot_next();
    game_sprite_slot_next();
    game_sprite_slot_next();
    game_sprite_slot_next();
}

// static s8 waiter = 40;

static void show_press_enter();

void flag_update_paged(GameObject* go)
{
    if (framectr >= 6) {
        framectr = 0;
        frameinc++; 
        if (frameinc >= 3)
            frameinc = 0;
        go->sdef.pat = SPAT_FLAG + frameinc;
    }
    framectr++;

    s16 x = WORLD_4_FIXPOS(player->posx);
    data->dx = 2 * MIN(24, 40-ABS(x+4-64));

    // while (waiter--) return; 
    
    GameObject* hit = game_collide_player(go, 0, 0);
    if (!messageShown && hit != NULL)
    {
        messageShown = true;
        banner_end_game();
        sfx_play_summitflag();
        show_press_enter();
    }

    if (messageShown && zxkeyENT())
    {
        if (score_can_enter_table())
            sc_switch_screen(ses_init, ses_update, NULL);
        else
            sc_switch_screen(sma_init, sma_update, sma_exit);
    }
}

static void show_press_enter()
{
    s16 x = FIXPOS_4_GRID(6);
    s16 y = FIXPOS_4_GRID(13);
    x = X_SCREEN_4_FIXPOS(x);
    y = Y_SCREEN_4_FIXPOS(y);

    SpriteDef sdef;
    sdef.slot = game_sprite_slot_next();
    sdef.x = x;
    sdef.y = y;
    sdef.mirrot = ATTR_____;
    sdef.scale = SCALE_X4 | SCALE_Y2;
    sdef.pat = SPAT_LETTERBOX;
    sdef.pal = SPAL_BLACK;
    sprite_update(&sdef);

    sdef.slot = game_sprite_slot_next();
    sdef.scale = SCALE_X2 | SCALE_Y2;
    sdef.pal = SPAL_WHITE;
    sdef.pat = SPAT_PRESSENTER;
    sprite_update(&sdef);

    sdef.slot = game_sprite_slot_next();
    sdef.x += 32;
    sdef.pat++;
    sprite_update(&sdef);
}

void flag_draw_paged(GameObject* go)
{
    SpriteDef sdef;
    sdef.pat = SPAT_LETTERBOX;
    sdef.pal = SPAL_BLACK;
    sdef.mirrot = ATTR_____;
    sdef.scale = SCALE_X4 | SCALE_Y8;

    sdef.slot = data->curtslot;
    sdef.x = -32 + data->dx;
    sdef.y = 0;
    sprite_update(&sdef);

    sdef.slot++;
    sdef.y = 128;
    sprite_update(&sdef);

    sdef.slot++;
    sdef.x = 288 - data->dx;
    sprite_update(&sdef);

    sdef.slot++;
    sdef.y = 0;
    sprite_update(&sdef);
}
