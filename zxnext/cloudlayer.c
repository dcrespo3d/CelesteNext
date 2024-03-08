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

#include "cloudlayer.h"
#include <string.h>
#include <arch/zxn.h>
#include "print_tile.h"

void system_set_layers_order_SUL();
void system_set_global_transparency_0();
void tilemap_set_transparent_index_0();

void layer2_setup_320x256();
void layer2_set_visible();
void layer2_set_invisible();

void layer2_set_dummy_pattern();

void layer2_load_cloud_pattern();

void cloudlayer_init()
{
    system_set_layers_order_SUL();
    system_set_global_transparency_0();
    tilemap_set_transparent_index_0();

    layer2_setup_320x256();

    // set layer2 ram starting page to 16K page 9
    ZXN_WRITE_REG(0x12, 9);

    // layer2_set_dummy_pattern();
    layer2_load_cloud_pattern();

    layer2_set_visible();
}

void cloudlayer_clear()
{
    layer2_set_invisible();
}

static s16 l2_hoffset = 0;

void cloudlayer_update()
{
    // https://wiki.specnext.dev/Layer_2_X_Offset_Register
    // https://wiki.specnext.dev/Layer_2_X_Offset_MSB_Register
    u8 ohi = (l2_hoffset >> 8) & 1;
    u8 olo = (l2_hoffset     ) & 0xFF;
    ZXN_WRITE_REG(0x71, ohi);
    ZXN_WRITE_REG(0x16, olo);

    l2_hoffset -= 4;
    if (l2_hoffset < 0) l2_hoffset += 320;
}

// #define L2_RED 0xE0 // 111 000 00
// #define L2_YEL 0xFC // 111 111 00
// #define L2_GRE 0x1C // 000 111 00
// #define L2_CYA 0x1F // 000 111 11
// #define L2_BLU 0x03 // 000 000 11
// #define L2_MAG 0xE3 // 111 000 11 

// #define L2_RED 0x20 // 001 000 00
// #define L2_YEL 0x24 // 001 001 00
// #define L2_GRE 0x04 // 000 001 00
// #define L2_CYA 0x05 // 000 001 01
// #define L2_BLU 0x01 // 000 000 01
// #define L2_MAG 0x21 // 001 000 01 

#define L2_RED 0x40 // 010 000 00
#define L2_YEL 0x48 // 010 010 00
#define L2_GRE 0x08 // 000 010 00
#define L2_CYA 0x09 // 000 010 01
#define L2_BLU 0x01 // 000 000 01
#define L2_MAG 0x41 // 010 000 01 

void layer2_set_dummy_pattern()
{
    // https://wiki.specnext.dev/Layer_2_RAM_Page_Register
    // set layer2 ram starting page to 16K page 9
    __asm__("NEXTREG 0x12, 9");

    __asm__("NEXTREG 0x50, 18");
    __asm__("NEXTREG 0x51, 19");
    memset((u8*)0x0000, L2_RED, (size_t)0x4000);

    __asm__("NEXTREG 0x50, 20");
    __asm__("NEXTREG 0x51, 21");
    memset((u8*)0x0000, L2_YEL, (size_t)0x4000);

    __asm__("NEXTREG 0x50, 22");
    __asm__("NEXTREG 0x51, 23");
    memset((u8*)0x0000, L2_GRE, (size_t)0x4000);

    __asm__("NEXTREG 0x50, 24");
    __asm__("NEXTREG 0x51, 25");
    memset((u8*)0x0000, L2_CYA, (size_t)0x4000);

    __asm__("NEXTREG 0x50, 26");
    __asm__("NEXTREG 0x51, 27");
    memset((u8*)0x0000, L2_BLU, (size_t)0x4000);
}

#include "palette_manager.h"
extern u8 cloudlayer_palette[];

#include "paging.h"

#define PAGE_56_CLOUDLAYER 56

void cloudlayer_load_palette(u8 palidx)
{
    storePrevPagesAtSlots0and1();
    putPagesAtSlots0and1(PAGE_56_CLOUDLAYER);
    palette_load_layer2_2(cloudlayer_palette + 4 * palidx);
    restorePrevPagesAtSlots0and1();
}

void cloudlayer_set_old()
{
    cloudlayer_load_palette(0);
}

void cloudlayer_set_new()
{
    cloudlayer_load_palette(16);
}

void layer2_load_cloud_pattern()
{
    cloudlayer_load_palette(0);

    u8* srcdata = (u8*)0x0000;
    u16 blksize = 0x200;
    u8* cmpdata = (u8*)0x5000;
    u8 dstpage = 18;
    for (u8 m = 0; m < 5; m++) {
        ZXN_WRITE_REG(0x50, 56);
        ZXN_WRITE_REG(0x51, 57);
        memcpy(cmpdata, srcdata, blksize);
        srcdata += blksize;

        ZXN_WRITE_REG(0x50, dstpage++);
        ZXN_WRITE_REG(0x51, dstpage++);
        u8* srcdata = cmpdata;
        u8* dstdata = (u8*)0x0000;
        for (u8 k = 0; k < 32; k++) {
            for (u8 j = 0; j < 16; j++) {
                u8 val = *srcdata++;
                for (u8 i = 0; i < 8; i++) {
                    u8 pix = 0;
                    if (val & 1)
                        pix = 1;
                    *dstdata++ = pix;
                    *dstdata++ = pix;
                    val >>= 1;
                }
            }
            memcpy(dstdata, dstdata-256, 256);
            dstdata += 256;
        }
    }

}