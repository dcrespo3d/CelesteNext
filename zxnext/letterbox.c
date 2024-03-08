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

#include "letterbox.h"

#include "gamedefs.h"
#include "sprite_manager.h"

SpriteDef sdef;

bool enabled;

void letterbox_enable()
{
    enabled = true;
}

void letterbox_disable()
{
    if (enabled) {
        for (u8 i = 0; i < 8; i++)
            sprite_clear_slot(SLOT_LETTERBOX + i);
        enabled = false;
    }
}

bool letterbox_get_enabled()
{
    return enabled;
}

void letterbox_draw()
{
    if (!enabled) return;

    sdef.slot = SLOT_LETTERBOX;
    sdef.x = -32;
    sdef.y = 0;
    sdef.pal = SPAL_BLACK;
    sdef.mirrot = 0;
    sdef.pat = SPAT_LETTERBOX;
    sdef.scale = SCALE_X4 | SCALE_Y8;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.x = 288;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.y = 128;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.x = -32;

    sprite_update(&sdef);

    sdef.scale = SCALE_X8 | SCALE_Y2;

    sdef.slot++;
    sdef.x = -32;
    sdef.y = -32;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.x += 128;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.x += 128;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.y = 256;
    sdef.x = -32;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.x += 128;

    sprite_update(&sdef);

    sdef.slot++;
    sdef.x += 128;

    sprite_update(&sdef);
}


