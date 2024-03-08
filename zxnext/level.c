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

#include <arch/zxn.h>
#include <string.h>
#include "level.h"
#include "tables.h"
#include "player.h"
#include "print_tile.h"
#include "gamedefs.h"
#include "util_math.h"
#include "paging.h"

static void level_load_tilemap(u8 level_idx);
static void level_load_data(u8 level_idx);

void level_load(u8 level_idx)
{
    storePrevPagesAtSlots0and1();

    player_clear();

    level_load_tilemap(level_idx);
    level_load_data(level_idx);

    restorePrevPagesAtSlots0and1();
}

void level_load_data(u8 level_idx)
{
	// ; load bank/page for game data
    ZXN_WRITE_REG(0x50, 50);
    ZXN_WRITE_REG(0x51, 51);

    u8* src;

    src = (u8*)0x0000;
    src += 256 * level_idx;

    memcpy(coltable, src, 256);
}

// level decompression area
#define LDAREA  0x5000
// block size = 1k; there are two blocks: tile and attribute
#define BLKSIZE 0x0400
// tilemap area
#define TMAREA  0x4000
// tilemap size
#define TMSIZE  2560

void level_clear_tilemap()
{
    memset((void*)TMAREA, 0, TMSIZE);
}

static void level_decompress_block(u8* src, u8* dst);
static void level_deinterlace_blocks();
extern void level_deinterlace_blocks_asm();

void level_load_tilemap(u8 level_idx)
{
	// ; load bank/page for game tilemap
    u8 page = 40 + ((level_idx & 0xF8) >> 2);
    ZXN_WRITE_REG(0x50, page);
    ZXN_WRITE_REG(0x51, page+1);

    // DBG8(0, 0, level_idx); print_char(' ');
    // DBG8(0, 1, page);

    u8* src;
    u8* dst;

    src = (u8*)(0x0000 + 2048 * (level_idx & 0x07));
    dst = (u8*)(LDAREA);

    level_decompress_block(src, dst);

    src += BLKSIZE;
    dst += BLKSIZE;

    level_decompress_block(src, dst);

    level_deinterlace_blocks_asm();

    // src = (u8*)0x0000;
    // dst = (u8*)0x4000;

    // src += 2048 * (level_idx & 0x07);

    // dst += 2 * 4;

    // for (u8 j = 0; j < 32; j++) {
    //     for (u8 i = 0; i < 32; i++) {
    //         *dst++ = *src++;
    //         dst++;
    //     }
    //     dst += 2 * 8;
    // }

    // src = (u8*)0x0400;
    // dst = (u8*)0x4001;

    // src += 2048 * (level_idx & 0x07);

    // dst += 2 * 4;

    // for (u8 j = 0; j < 32; j++) {
    //     for (u8 i = 0; i < 32; i++) {
    //         *dst++ = *src++;
    //         dst++;
    //     }
    //     dst += 2 * 8;
    // }
}

static void level_decompress_block(u8* src, u8* dst)
{
    memcpy(dst, src, BLKSIZE);
}

// static void level_deinterlace_blocks()
// {
//     u8* src = (u8*)(LDAREA);
//     u8* dst = (u8*)(TMAREA);

//     dst += 2 * 4;

//     for (u8 j = 0; j < 32; j++) {
//         for (u8 i = 0; i < 32; i++) {
//             *dst = *src;
//             src += BLKSIZE;
//             dst ++;
//             *dst = *src;
//             src -= BLKSIZE;
//             src++;
//             dst++;
//         }
//         dst += 2 * 8;
//     }
// }

// static void level_deinterlace_blocks_orig()
// {
//     u8* src = (u8*)(LDAREA);
//     u8* dst = (u8*)(TMAREA);

//     dst += 2 * 4;

//     for (u8 j = 0; j < 32; j++) {
//         for (u8 i = 0; i < 32; i++) {
//             *dst++ = *src++;
//             dst++;
//         }
//         dst += 2 * 8;
//     }

//     src = (u8*)(LDAREA + BLKSIZE);
//     dst = (u8*)(TMAREA + 1);

//     dst += 2 * 4;

//     for (u8 j = 0; j < 32; j++) {
//         for (u8 i = 0; i < 32; i++) {
//             *dst++ = *src++;
//             dst++;
//         }
//         dst += 2 * 8;
//     }
// }



void level_create_coltable()
{
    u8* ptr = coltable;
    for (u16 i = 0; i < 256; i++) {
        u8 val = *ptr;
        if      ((val & 0xF0) == 0x10) val = MASK_FLOOR | MASK_ICE;
        else if ((val & 0xF0) == 0x20) val = MASK_FLOOR;
        else if (val == 0x34)          val = MASK_FLOOR;
        else if ((val & 0x3C) == 0x3C) val = MASK_NASTY | (0x10 << (val & 3));
        else                           val = 0;
        *ptr++ = val;
    }

    // level_debug_coltable();
}

void level_debug_coltable()
{
    u8* ptr = coltable;
    for (u8 j = 0; j < 16; j++) {
        for (u8 i = 0; i < 16; i++) {
            u8 col = *ptr++;
            DBG4X(4+2*i,2*j,col);
            // DBG4X(4+2*i,2*j,col>>4);
            // DBG8X(4+2*i,2*j,col);
        }
    }
}

u8 level_tile_flag_at(s8 x, s8 y, s8 w, s8 h, u8 flag)
{
    s8 i0 = MAX( 0, ( x      >> 3));
    s8 i1 = MIN(15, ((x+w-1) >> 3));
    s8 j0 = MAX( 0, ( y      >> 3));
    s8 j1 = MIN(15, ((y+h-1) >> 3));
    for (s8 i = i0; i <= i1; i++) {
        for (s8 j = j0; j <= j1; j++) {
            u8 idx = TILE_INDEX_FOR_IJ(i, j);
            u8 tile = coltable[idx];
            if ((tile & flag) != 0)
                return tile;
        }
    }
    return 0;
}

bool level_solid_at(s8 x, s8 y, s8 w, s8 h)
{
    u8 tile = level_tile_flag_at(x, y, w, h, MASK_FLOOR);
    return tile != 0;
}

bool level_ice_at(s8 x, s8 y, s8 w, s8 h)
{
    u8 tile = level_tile_flag_at(x, y, w, h, MASK_ICE);
    return tile != 0;
}

bool level_spikes_at(s8 x, s8 y, s8 w, s8 h, s8 xspd, s8 yspd)
{
    // DBGTEXT(0,0,"----")
    s8 x2 = x+w-1;
    s8 y2 = y+h-1;
    // DBG8X(0,1,x);
    // DBG8X(0,2,y);
    // DBG8X(0,5,w);
    // DBG8X(0,6,h);
    // DBG8X(0,8,(y2&7));    
    s8 i0 = MAX( 0, (x  >> 3));
    s8 i1 = MIN(15, (x2 >> 3));
    s8 j0 = MAX( 0, (y  >> 3));
    s8 j1 = MIN(15, (y2 >> 3));
    for (s8 i = i0; i <= i1; i++) {
        for (s8 j = j0; j <= j1; j++) {
            u8 idx = TILE_INDEX_FOR_IJ(i, j);
            u8 tile = coltable[idx];
            if ((tile & MASK_NASTY) != 0) {
                tile = tile & 0xF0;
                // DBG8X(0,0,tile);
                if      (tile == 0x20 && ((y2&7)>=6 || y+h==j*8+8) && yspd>=0)
                    return true;
                else if (tile == 0x80 && (y&7)<=2 && yspd<=0)
                    return true;
                else if (tile == 0x10 && (x&7)<=2 && xspd<=0)
                    return true;
                else if (tile == 0x40 && (((x+w-1)&7)>=6 || x+w==i*8+8) && xspd>=0)
                    return true;
            }
        }
    }
    return false;

}

