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

// https://k1.spdns.de/Develop/Hardware/AVR/mixed%20docs.../doc/sdccman.html/node100.html
// on SDCC, segment names for pragma are limited to 8 characters
// codeseg <name>- Use this name (max. 8 characters) for the code segment. See option --codeseg.
// constseg <name>- Use this name (max. 8 characters) for the const segment. See option --constseg. 

#pragma codeseg PAGE_58
#pragma constseg PAGE_58

// also, ORG $0000 must be defined in a placeholder ASM file
// for code to be generated from address $0000 (lower 16K).
// if not, code will be generated by default from address $C000

#include <string.h>
#include "bigchest.h"
#include "screen_game.h"
#include "gamedefs.h"
#include "print_tile.h"
#include "smoke.h"
#include "tables.h"
#include "screen_game.h"
#include "util_math.h"
#include "cloudlayer.h"
#include "music_player.h"
#include "sfx_player.h"

#define RAY_COUNT 20
#define STAR_COUNT 8

typedef struct {
    SpriteDef sdef;
    s8 state;
    s8 timer;
} BigchestData;

static u8 slot0;
static s16 rx0, ry0;
static s8 rx[RAY_COUNT];
static s8 ry[RAY_COUNT];

static s16 spdy;
static u8 phase;

static GameObject* orb;

#define data ((BigchestData*)go->derived_data)

static void rays_init();
static void rays_update();
static void rays_draw();
static void rays_clear();

static void orb_init();
static void orb_update();
static void orb_draw();
static void orb_clear();

void bigchest_init_paged(GameObject* go)
{
    rx0 = X_SCREEN_4_FIXPOS(go->posx);
    ry0 = Y_SCREEN_4_FIXPOS(go->posy);
    go->type = TYPE_BIGCHEST;
    go->sdef.slot = game_sprite_slot_next();
    go->sdef.pat = SPAT_BIGCHEST;
    go->sdef.scale = SCALE_X2 | SCALE_Y2;
    go->derived_data = game_malloc(sizeof(BigchestData));
    go->derived_update = bigchest_update;
    go->derived_draw = bigchest_draw;
    go->hbw = 16;
    memcpy(&data->sdef, &go->sdef, sizeof(SpriteDef));
    data->sdef.x = X_SCREEN_4_FIXPOS(go->posx);
    data->sdef.y = Y_SCREEN_4_FIXPOS(go->posy);
    data->sdef.slot = game_sprite_slot_next();
    data->sdef.pat += 1;
    data->state = 0;
    slot0 = game_sprite_slot_next();
    orb = NULL;
}

extern s8 djump;
extern s8 max_djump;

void bigchest_update_paged(GameObject* go)
{
    if (data->state == 0) {
        GameObject* hit = game_collide_player(go, 0, 8);
        if (hit != NULL && gobj_is_solid(hit, 0, 1))
        {
            pause_player = true;
            hit->spdx = 0;
            hit->spdy = 0;
            data->state = 1;
            smoke_init(go->posx,          go->posy);
            smoke_init(go->posx + (8<<8), go->posy);
            data->sdef.pat = 0;
            data->timer = 60; //60;
            rays_init();
            music_subsong_init(SS_FANFARE);
        }
    }
    else if (data->state == 1) {
        data->timer -= 1;
        game_shake = 5;
        game_flash_bg = true;
        if (data->timer <= 45)
            rays_update();
        if (data->timer == 0) {
            data->state = 2;
            game_shake = 0;
            game_flash_bg = false;
            pause_player = false;
            cloudlayer_set_new();
            rays_clear();
            rx0 = go->posx;
            ry0 = go->posy;
            orb_init();
        }
    }
    else if (data->state == 2) {
        orb_update();
        GameObject* hit = game_collide_player(orb, 0, 0);
        if (hit != NULL && orb->spdy == 0) {
            data->state = 3;
            game_freeze = 10;
            game_shake = 10;
            max_djump = 2;
            djump = 2;
            sfx_play_takeorb();
            // music_subsong_init(SS_THIRD_LEVELS);
            phase = 0;
        }
    }
    else if (data->state == 3) {
        phase++;
        if (phase == 25) {
            data->state = 4;
            music_subsong_init(SS_THIRD_LEVELS);
        }
    }
}

void bigchest_draw_paged(GameObject* go)
{
    sprite_update(&data->sdef);
    if (data->state == 1)
        rays_draw();
    else if (data->state == 2)
        orb_draw();
    else if (data->state == 3) {
        if (orb->enabled)
            orb_clear();
    }
}

static void rays_init()
{
    for (u8 i = 0; i < RAY_COUNT; i++) {
        // rx[i] = rndtable_next() & 0x0F;
        ry[i] = -1;
    }
}

static void rays_update()
{
    for (u8 i = 0; i < RAY_COUNT; i++) {
        if (ry[i] == -1) {
            ry[i] = 0;
            rx[i] = rndtable_next() & 0x0F;
            break;
        }
    }
}

static void rays_draw()
{
    SpriteDef sdef;
    sdef.pal = SPAL_WHITE;
    sdef.pat = SPAT_CHESTRAY;
    sdef.mirrot = ATTR_____;
    for (u8 i = 0; i < RAY_COUNT; i++) {
        s8 y = ry[i];
        if (y < 0) continue;
        sdef.x = rx0 + 2 * rx[i];
        sdef.y = ry0;
        if (y == 0) {
            sdef.scale = SCALE_X1 | SCALE_Y1;
        }
        else if (y == 1) {
            sdef.scale = SCALE_X1 | SCALE_Y2;
            sdef.y -= 16;
        }
        else if (y == 2) {
            sdef.scale = SCALE_X1 | SCALE_Y4;
            sdef.y -= 48;
        }
        else if (y == 3) {
            sdef.scale = SCALE_X1 | SCALE_Y8;
            sdef.y -= 112;
        }
        else {
            sdef.scale = SCALE_X1 | SCALE_Y8;
            sdef.y -= 112;
            sdef.y -= 42 * (y-4);
            if (sdef.y < -128) {
                sdef.y = -128;
                y = -2;
            }
        }
        sdef.slot = slot0 + i;
        sprite_update(&sdef);
        ry[i] = y + 1;
    }
}

static void rays_clear()
{
    for (u8 i = 0; i < RAY_COUNT; i++) {
        sprite_clear_slot(slot0 + i);
    }
}

static void orb_init()
{
    orb = game_create_object();

    orb->sdef.slot = game_sprite_slot_next();
    orb->sdef.pat = SPAT_ORB;
    orb->posx = rx0 + (4 << 8);
    orb->posy = ry0 + (8 << 8);
    orb->spdy = (-4 << 8);

    slot0 = game_sprite_slot_next();
    for (u8 i = 1; i < STAR_COUNT; i++)
        game_sprite_slot_next();

    phase = 0;
}

static void orb_update()
{
    orb->spdy = APPR(orb->spdy, 0, 136);

#define RADIUS 32
#define OFFSET 800

    u8 ph = phase;
    for (u8 i = 0; i < STAR_COUNT; i++) {
        u16 co = sintable[(ph     ) & 0xFF];
        u16 si = sintable[(ph + 64) & 0xFF];
        co *= RADIUS;
        si *= RADIUS;
        co += OFFSET;
        si += OFFSET;

        rx[i] = co >> 8;
        ry[i] = si >> 8;

        ph += 32;
    }

    phase += 9;
}

static void orb_draw()
{
    s16 x0 = X_SCREEN_4_FIXPOS(orb->posx);
    s16 y0 = Y_SCREEN_4_FIXPOS(orb->posy);

    SpriteDef sdef;
    sdef.slot = slot0;
    sdef.x = x0;
    sdef.y = y0;
    sdef.mirrot = ATTR_____;
    sdef.pal = SPAL_WHITE;
    sdef.pat = SPAT_STAR;
    sdef.scale = SCALE_X1 | SCALE_Y1;

    for (u8 i = 0; i < STAR_COUNT; i++) {
        sdef.x = x0 + rx[i];
        sdef.y = y0 + ry[i];

        sprite_update(&sdef);

        sdef.slot++;
    }
}

static void orb_clear()
{
    orb->enabled = false;
    sprite_clear_slot(orb->sdef.slot);
    for (u8 i = 0; i < STAR_COUNT; i++)
        sprite_clear_slot(slot0 + i);
}



