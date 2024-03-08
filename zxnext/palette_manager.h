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

#ifndef _palette_manager_h_
#define _palette_manager_h_

#include "types.h"

void palette_load_tilemap(u8* pal_data);
void palette_load_sprites(u8* pal_data);
void palette_load_layer2(u8* pal_data);

void palette_load_layer2_2(u8* pal_data);

// #define PALETTE_TILEMAP 48
// #define PALETTE_SPRITES 32
// #define PALETTE_LAYER_2 16

// void palette_load(u8 dest_pal, u8* pal_data);
// void palette_load(u8* pal_data);

// bits 6-4 of 7-0
// %000 	ULA first palette
// %100 	ULA second palette
// %001 	Layer 2 first palette
// %101 	Layer 2 second palette
// %010 	Sprites first palette
// %110 	Sprites second palette
// %011 	Tilemap first palette
// %111 	Tilemap second palette 

#endif