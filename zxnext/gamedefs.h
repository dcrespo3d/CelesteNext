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

#ifndef gamedefs_h
#define gamedefs_h

#include "types.h"

#define GAME_OBJECT_COUNT 20
#define LEVEL_COUNT 32
#define LEVEL_OLD_SITE  11
#define LEVEL_BIG_CHEST 21
#define LEVEL_SUMMIT    30
#define LEVEL_AFTER_BIG_CHEST 22
#define LEVEL_MENU 31

// sprite patterns
#define SPAT_PLAYER      1
#define SPAT_PLAYER_1    1
#define SPAT_PLAYER_2    2
#define SPAT_PLAYER_3    3
#define SPAT_PLAYER_4    4
#define SPAT_PLAYER_5    5
#define SPAT_PLAYER_6    6
#define SPAT_PLAYER_7    7
#define SPAT_SPRING      8
#define SPAT_CHEST      10
#define SPAT_BALLOON    12
#define SPAT_CORD       13
#define SPAT_PLATFORM_L 16
#define SPAT_PLATFORM_R 17
#define SPAT_KEY        18
#define SPAT_FALLFLOOR  21
#define SPAT_FRUIT      24
#define SPAT_FLYFRUIT   25
#define SPAT_WING       29
#define SPAT_SMOKE      26
#define SPAT_BIGCHEST   32
#define SPAT_TOMBSTONE  34
#define SPAT_PLATFORM   35
#define SPAT_ORB        36
#define SPAT_FLAG       37
#define SPAT_DEATH      40
#define SPAT_SNOW       40
#define SPAT_STAR       45
#define SPAT_HAIR       46
#define SPAT_LETTERBOX  47
#define SPAT_CHESTRAY   48
#define SPAT_POINTS     49
#define SPAT_FAKEWALL   50
#define SPAT_DIGIT      64
#define SPAT_OLDSITE    76
#define SPAT_SUMMIT     78
#define SPAT_COLON      80
#define SPAT_LEVELBG    81
#define SPAT_TIMERBG    82
#define SPAT_ENDGAMEBG  83
#define SPAT_SKULL      84
#define SPAT_PRESSENTER 88

// count for multisprites
#define SMOKE_COUNT     24
#define SNOW_COUNT      24
#define BANNER_COUNT    24

// sprite slots
#define SLOT_GAMEOBJECT 0
#define SLOT_DEATH      36
#define SLOT_HAIR       38
#define SLOT_PLAYER     43
#define SLOT_SMOKE      44
#define SLOT_SNOW       68    
#define SLOT_BANNER     92
#define SLOT_LETTERBOX 116
#define SLOT_BRKCOUNT  126

#define TYPE_PLAYER     SPAT_PLAYER
#define TYPE_SPRING     SPAT_SPRING
#define TYPE_FRUIT      SPAT_FRUIT
#define TYPE_FLYFRUIT   SPAT_FLYFRUIT
#define TYPE_FALLFLOOR  SPAT_FALLFLOOR
#define TYPE_KEY        SPAT_KEY
#define TYPE_CHEST      SPAT_CHEST
#define TYPE_BALLOON    SPAT_BALLOON
#define TYPE_PLATFORM   SPAT_PLATFORM_L
#define TYPE_TOMBSTONE  SPAT_TOMBSTONE
#define TYPE_BIGCHEST   SPAT_BIGCHEST
#define TYPE_FAKEWALL   176     // (u8)(48-128)
#define TYPE_FLAG       SPAT_FLAG

// palettes - red is substituted by one of these
#define SPAL_RED          0
#define SPAL_DARK_GREEN   1
#define SPAL_GREEN        2
#define SPAL_DARK_BLUE    3
#define SPAL_BLUE         4
#define SPAL_DARK_GREY    5
#define SPAL_DARK_PURPLE  6
#define SPAL_LAVENDER     7
#define SPAL_BROWN        8
#define SPAL_LIGHT_GREY   9
#define SPAL_BLACK       10
#define SPAL_PINK        11
#define SPAL_ORANGE      12
#define SPAL_YELLOW      13
#define SPAL_LIGHT_PEACH 14
#define SPAL_WHITE       15

// collision masks
#define MASK_FLOOR      0x01
#define MASK_ICE        0x02
#define MASK_NASTY      0x04

#define SPIKES_RIGHT    0x10
#define SPIKES_UP       0x20
#define SPIKES_LEFT     0x40
#define SPIKES_DOWN     0x80

/*

COORDINATE SYSTEMS

WORLD RANGE:
- x = [0, 127]
- y = [0, 127]

FIXED POINT 8.8 RANGE:
- x = [64*256, 191*256]
- y = [64*256, 191*256]

SCREEN RANGE:
- x = [32, 287]
- y = [0, 255]]

*/

#define FP4W(w) ((64+w)<<8)



#endif
