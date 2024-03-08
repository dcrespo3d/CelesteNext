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

#include "sprite_manager.h"

#include <arch/zxn.h>

extern u16 shake_spr_x;
extern u16 shake_spr_y;

void sprite_update_c(SpriteDef* sprdef)
{
    u16 sx = sprdef->x + shake_spr_x;
    u16 sy = sprdef->y + shake_spr_y;
    ZXN_WRITE_REG(0x34, sprdef->slot);
    ZXN_WRITE_REG(0x35, sx);
    ZXN_WRITE_REG(0x36, sy);
    u8 val37 = JOINIB(sprdef->pal, sprdef->mirrot);
    val37 |= (sx >> 8) & 1;
    ZXN_WRITE_REG(0x37, val37);
    ZXN_WRITE_REG(0x38, 0xC0 | (sprdef->pat >> 1));
    u8 val39 = 0x80 | ((sprdef->pat & 1) << 6);
    val39 |= (sy >> 8) & 1;
    val39 |= sprdef->scale;
    ZXN_WRITE_REG(0x39, val39);
}


