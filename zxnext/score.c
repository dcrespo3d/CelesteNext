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

#include "score.h"
#include "screen_game.h"
#include <string.h>
#include "print_tile.h"

bool score_can_enter_table()
{
    return (score_get_table_index() < SCORE_COUNT);
}

s8 score_get_table_index()
{
    if (gth > 0)
        return SCORE_COUNT;

    s8 idx = 0;
    for (; idx < SCORE_COUNT; idx++) {
        Score* score = &scores[idx];
        if      (gtm <  score->min) break;
        else if (gtm == score->min) {
            if  (gts <= score->sec) break;
        }
    }
    return idx;
}

void score_enter_name(const char* name)
{
    s8 idx = score_get_table_index();
    if (idx >= SCORE_COUNT)
        return;

    s8 cnt = SCORE_COUNT - idx - 1;
    for (s8 i = cnt-1; i >= 0; i--)
        memcpy(&scores[idx+i+1], &scores[idx+i], sizeof(Score));

     s8 slen = strlen(name);
    if (slen > NAME_SIZE) slen = NAME_SIZE;

    Score* score = &scores[idx];

    char* dstname = &score->name[0];
    memset(dstname, 0, NAME_ALLOC);
    memcpy(dstname, name, slen);

    score->min = gtm;
    score->sec = gts;
    score->fruit = game_fruit_count();
    score->death = game_deaths;
}
    