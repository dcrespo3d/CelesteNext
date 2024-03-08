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

#include "music_player.h"
#include "print_tile.h"

u8* current_song = 0;

u8 prev_page_a;
u8 prev_page_b;

void sound_panic();
void music_song_init_asm();
void music_subsong_init_asm();
void music_song_play_frame_asm();

void music_song_init(u8* song)
{
    if (current_song == song)
        return;

    current_song = song;

    if (!current_song) {
        sound_panic();
        return;
    }

    music_song_init_asm();
}

u8 current_subsong = 255;

void music_subsong_init(u8 subsong)
{
    if (current_subsong == subsong)
        return;

    current_subsong = subsong;

    music_subsong_init_asm();
}


void music_song_play_frame()
{
    if (!current_song)
        return;

    music_song_play_frame_asm();
}
