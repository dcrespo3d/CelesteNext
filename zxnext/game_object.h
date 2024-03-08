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

#ifndef game_object_h
#define game_object_h

#include "types.h"
#include "sprite_manager.h"

typedef struct GAMEOBJECT GameObject;

typedef void (*GFunPtr)(GameObject* go);

typedef struct GAMEOBJECT
{
    bool enabled;
    bool solids;
    bool collideable;
    u8 type;
    SpriteDef sdef;  
    u16 posx;
    u16 posy;
    s16 spdx;
    s16 spdy;
    s16 remx;
    s16 remy;
    s8 hbx;
    s8 hby;
    u8 hbw;
    u8 hbh;
    u8*     derived_data;
    GFunPtr derived_draw;
    GFunPtr derived_update;
    bool base_draw;
}
GameObject;

void gobj_init  (GameObject* go, u8 col, u8 row);
void gobj_draw  (GameObject* go);

void gobj_move  (GameObject* go);
void gobj_update(GameObject* go);

void gobj_move_x(GameObject* go, s16 amount, s16 start);
void gobj_move_y(GameObject* go, s16 amount, s16 start);

bool gobj_is_solid(GameObject* go, s8 dx, s8 dy);
bool gobj_is_ice  (GameObject* go, s8 dx, s8 dy);

bool gobj_check_objects(GameObject* A, GameObject* B, u8 dx, u8 dy);

#endif