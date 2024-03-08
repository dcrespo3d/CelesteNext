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

#ifndef screen_game_h
#define screen_game_h

#include "types.h"
#include "game_object.h"

void sga_init();
void sga_update();
void sga_exit();

// write to this variable to set shake (frames to be shaking)
extern s8   game_shake;
extern s8   game_freeze;
extern bool game_has_dashed;
extern bool game_has_key;
extern bool game_flash_bg;
extern u16  game_deaths;

extern bool pause_player;

// game time hours, minutes, seconds, frames
extern u8 gth;
extern u8 gtm;
extern u8 gts;
extern u8 gtf;

u8 game_sprite_slot_next();
u8* game_malloc(u8 size);

void game_next_level();
void game_kill_player();

bool        game_check_type    (GameObject* go, u8 type, u8 dx, u8 dy);
GameObject* game_collide_type  (GameObject* go, u8 type, u8 dx, u8 dy);
bool        game_check_player  (GameObject* go,          u8 dx, u8 dy);
GameObject* game_collide_player(GameObject* go,          u8 dx, u8 dy);

GameObject* game_create_object();

void game_fruit_take();
bool game_fruit_is_taken();
u8   game_fruit_count();

#endif