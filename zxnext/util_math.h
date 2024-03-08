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

#ifndef util_math_h
#define util_math_h

#define ABS(x) ((x)<(0)?(-(x)):(x))
#define MAX(a,b) ((a)>(b)?(a):(b))
#define MIN(a,b) ((a)<(b)?(a):(b))
#define APPR(val, target, amount) (((val)>(target))?(MAX(((val)-(amount)),(target))):(MIN(((val)+(amount)),(target))))
#define SIGN(x) ((x)==(0)?(0):((x)<(0)?(-1):(1)))

// returns sign(param)*target
#define APPLY_SIGN(param,target) ((param)<(0)?(-(target)):((param)>(0)?(target):(0)))

#define TILE_INDEX_FOR_IJ(i,j) ((i)+((j)<<4))

#define WORLD_4_FIXPOS(fp) (((fp)>>8)-64)
#define FIXPOS_4_WORLD(w) ((64+w)<<8)
#define FIXPOS_4_GRID(cr) ((64+((cr)<<3))<<8)

#define X_SCREEN_4_FIXPOS(fp) (((((fp) >> 8) - 64) << 1) + 32)
#define Y_SCREEN_4_FIXPOS(fp) (((((fp) >> 8) - 64) << 1)     )


#endif
