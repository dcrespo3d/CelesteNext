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

#ifndef sfxplayer_h
#define sfxplayer_h

#include "types.h"

void sfx_init();
void sfx_update();

void sfx_play_jump();
void sfx_play_walljump();
void sfx_play_dash();
void sfx_play_death();
void sfx_play_spawn();
void sfx_play_spawnstep();
void sfx_play_balloonpop();
void sfx_play_balloonrespawn();
void sfx_play_springrelease();
void sfx_play_dashdepleted();
void sfx_play_fruitcaught();
void sfx_play_fruitflown();
void sfx_play_floorbreak();
void sfx_play_chestopen();
void sfx_play_key();
void sfx_play_dashland();
void sfx_play_summitflag();
void sfx_play_takeorb();

#endif
