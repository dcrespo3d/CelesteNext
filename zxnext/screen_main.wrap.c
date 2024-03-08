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

#include "screen_main.h"
#include "paging.h"
#include "snowlayer.h"

extern void sma_init_paged();
extern void sma_update_paged();

#define PAGE_58 58

void sma_init()
{
    storePrevPagesAtSlots0and1();
    putPagesAtSlots0and1(PAGE_58);
    sma_init_paged();
    restorePrevPagesAtSlots0and1();
}

void sma_update()
{
    storePrevPagesAtSlots0and1();
    putPagesAtSlots0and1(PAGE_58);
    sma_update_paged();
    restorePrevPagesAtSlots0and1();
}

void sma_exit()
{
    // snow_clear();
}

