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

#include "flag.h"
#include "paging.h"

#include "print_tile.h"

extern void flag_init_paged  (GameObject* go);
extern void flag_update_paged(GameObject* go);
extern void flag_draw_paged  (GameObject* go);

#define PAGE_58_EXTRACODE 58

void flag_init(GameObject* go)
{
    storePrevPagesAtSlots0and1();
    putPagesAtSlots0and1(PAGE_58_EXTRACODE);
    flag_init_paged(go);
    restorePrevPagesAtSlots0and1();
}

void flag_update(GameObject* go)
{
    storePrevPagesAtSlots0and1();
    putPagesAtSlots0and1(PAGE_58_EXTRACODE);
    flag_update_paged(go);
    restorePrevPagesAtSlots0and1();
}

void flag_draw(GameObject* go)
{
    storePrevPagesAtSlots0and1();
    putPagesAtSlots0and1(PAGE_58_EXTRACODE);
    flag_draw_paged(go);
    restorePrevPagesAtSlots0and1();
}

