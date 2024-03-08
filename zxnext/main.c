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

#include <im2.h>
#include <z80.h>
#include <intrinsic.h>
#include <string.h>
#include <arch/zxn.h>

#include "util_next.h"
#include "tilemap_manager.h"

#include "print_tile.h"

#include "control.h"
#include "keyb.h"

#include "sprite_manager.h"
#include "gamedefs.h"

#include "palette_manager.h"
#include "palette_data.h"
#include "turbosound.h"
#include "music_player.h"
#include "sfx_player.h"
#include "persist.h"

#include "tables.h"

#include "screen_controller.h"
#include "screen_game.h"
#include "screen_main.h"
#include "screen_about.h"
#include "screen_control.h"
#include "screen_scores.h"
#include "screen_enter.h"

// MEMORY MAP
/*

NOTE: STACK POINTER SET AT VALUE INDICATED IN FILE pragma.inc

FE00 - FFFF  stack
FDFD - FDEF  im2 isr jump
FD01 - FDFC  unused
FC00 - FD00  jump table - 257 FD bytes

#pragma output REGISTER_SP = 0xFFFE
#pragma output CRT_STACK_SIZE = 500

see reference info at
https://github.com/z88dk/z88dk/blob/master/doc/ZXSpectrumZSDCCnewlib_08_Interrupts.md
https://www.z88dk.org/forum/viewtopic.php?t=9930
https://github.com/z88dk/z88dk/wiki/CRT
https://github.com/jsmolina/z88dk-tutorial-sp1
*/

// GRAPHIC MEMORY MAP
/*

4000 - 49FF  [0A00 - 2560] tilemap
4A00 - 4FFF  [0600 - 1536] empty
5000 - 57FF  [0800 - 2048] level decompression area
5800 - 5AFF  [0600 -  768] ULA attribute area - must be all zeros!
5B00 - 5BFF  [0100 -  256] rndtable
5C00 - 5CFF  [0100 -  256] sintable
5D00 - 5DFF  [0100 -  256] coltable
5E00 - 5EFF  [0100 -  256] heap
5F00 - 5FFF  [0100 -  256] empty
6000 - 7FFF  [2000 - 8192] tileset

*/
void onVBlank();


IM2_DEFINE_ISR(update_im2)
{
    onVBlank();
}

void setup_im2()
{
    intrinsic_di();
    im2_init((void *) 0xFC00);
    memset((void *) 0xFC00, 0xFD, 257);
    z80_bpoke(0xFDFD, 0xC3);
    z80_wpoke(0xFDFE, (uint16_t) update_im2);
    intrinsic_ei();
}

u16 vblank_ctr = 0;

void onVBlank()
{
    vblank_ctr++;
    music_song_play_frame();
    sfx_update();
}

bool slomo = false;
u16 wait_ctr = 0;
u16 frame_ctr = 0;
extern bool game_in_progress;

void update_frame();
void print_tallies();

void main(void)
{
    zx_border(0);
    
    setCpuSpeed28();
    disableContention();

    rndtable_init();

    control_init();

    tilemap_setup();
    tilemap_clear_buf();
    palette_load_tilemap(tileset_palette);

    print_set_color(SPAL_LIGHT_GREY);
    print_set_pos(9, 27);
    print_str("Celeste is loading");

    // pitfall: seems like three continuous file reads
    // hang the machine when the file does not exists
    // (it is handled with errno in code, but still hangs).
    // It can be mitigated with a slight wait between file accesses.

    persist_init();
    print_char('.');
    waitForScanline(255);

    persist_load_control();
    print_char('.');
    waitForScanline(255);

    persist_load_scores();
    print_char('.');
    waitForScanline(255);

    sprite_setup();
    sprite_load_defs();
    palette_load_sprites(sprites_palette);

    setup_im2();

    turbosound_init();
    // music_song_init(song_silence);
    music_song_init(song_celeste1);
    music_subsong_init(SS_SILENCE);
    sfx_init();

    sc_switch_screen(sma_init, sma_update, sma_exit);
    // sc_switch_screen(sab_init, sab_update, NULL);
    // sc_switch_screen(sga_init, sga_update, sga_exit);
    // sc_switch_screen(sco_init, sco_update, NULL);
    // sc_switch_screen(shs_init, shs_update, NULL);
    // sc_switch_screen(ses_init, ses_update, NULL);


    while(true) {
        waitForScanline(255);   // 256 bad, don't know why (yet)

        wait_ctr++;

        if (!zxkeySYM() || !is_debug) {
            slomo = false;
            // skip each frame
            if (vblank_ctr & 1)
                update_frame();
        }
        else {
            slomo = true;
            // slow motion
            if ((vblank_ctr & 31) == 31)
                update_frame();
        }

        if (is_debug && game_in_progress)
            print_tallies();
    }
}

void update_frame()
{
    frame_ctr++;

    control_update();
    sc_update();
}

void print_tallies()
{
    u8 x = 0, y = 18;

    print_set_pos(0, y++);
    print_str("VBLK");
    print_set_pos(0, y++);
    print_hex_word(vblank_ctr);

    y++;

    print_set_pos(0, y++);
    print_str("WAIT");
    print_set_pos(0, y++);
    print_hex_word(wait_ctr);

    y++;

    print_set_pos(0, y++);
    print_str("FRAM");
    print_set_pos(0, y++);
    print_hex_word(frame_ctr);
}

