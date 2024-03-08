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

#ifndef __music_player_h__
#define __music_player_h__

#include "types.h"

extern u8 song_celeste1[];
extern u8 song_silence[];

void music_song_init(u8* song);

// subsongs
#define SS_MENU          6
#define SS_FIRST_LEVELS  0
#define SS_SECOND_LEVELS 4
#define SS_THIRD_LEVELS  2
#define SS_INTERMISSION  1
#define SS_FANFARE       3
#define SS_SILENCE       5


void music_subsong_init(u8 subsong);

void music_song_play_frame();

// #include "util_next.h"

// #define AVOID_MUSIC_STUTTER { \
//     waitForScanline(255); \
//     music_song_play_frame(); \
// }

#endif
