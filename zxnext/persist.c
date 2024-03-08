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

#include "persist.h"
#include <string.h>
#include <arch/zxn/esxdos.h>
#include <errno.h>

// PITFALL avoided: disabled interrupts BEFORE file operation.
// It may be caused by my implementation of paging not being reentrant.
#include <intrinsic.h>
#include "paging.h"

#include "control.h"
#include "score.h"

static void persist_check_debug();

///////////////////////////////////////////////////////////////////////////////

void persist_init()
{
    persist_check_debug();
}

///////////////////////////////////////////////////////////////////////////////

#define DEBUG_FN "6031769" // back to 1983!
bool is_debug = false;

void persist_check_debug()
{
    intrinsic_di();

    storePrevPagesAtSlots0and1();
    putRomPagesAtSlots0and1();

    is_debug = false;
    errno = 0;
    ubyte filehandle = esxdos_f_open(DEBUG_FN,
        ESXDOS_MODE_R | ESXDOS_MODE_OE);
    if (!errno) {
        is_debug = true;
    }

    restorePrevPagesAtSlots0and1();

    intrinsic_ei();
}

///////////////////////////////////////////////////////////////////////////////

#define CNTDATA_FN "celeste.cnt"
#define CNTDATA_SZ 16
static ubyte cntdata[CNTDATA_SZ];

static void serialize_cntdata()
{
    u16* wptr = (u16*)cntdata;
    *wptr++ = keycodeUp;
    *wptr++ = keycodeDown;
    *wptr++ = keycodeLeft;
    *wptr++ = keycodeRight;
    *wptr++ = keycodeJump;
    *wptr++ = keycodeDash;
}

static void deserialize_cntdata()
{
    u16* wptr = (u16*)cntdata;
    keycodeUp     = *wptr++;
    keycodeDown   = *wptr++;
    keycodeLeft   = *wptr++;
    keycodeRight  = *wptr++;
    keycodeJump   = *wptr++;
    keycodeDash   = *wptr++;
}

void persist_load_control()
{
    intrinsic_di();

    storePrevPagesAtSlots0and1();
    putRomPagesAtSlots0and1();
    
    serialize_cntdata();

    errno = 0;
    ubyte filehandle = esxdos_f_open(CNTDATA_FN,
        ESXDOS_MODE_R | ESXDOS_MODE_OE);
    if (!errno) {
        esxdos_f_read(filehandle, cntdata, CNTDATA_SZ);
        esxdos_f_close(filehandle);
    }

    deserialize_cntdata();

    restorePrevPagesAtSlots0and1();

    intrinsic_ei();
}

void persist_save_control()
{
    intrinsic_di();

    storePrevPagesAtSlots0and1();
    putRomPagesAtSlots0and1();

    serialize_cntdata();

    errno = 0;
    ubyte filehandle = esxdos_f_open(CNTDATA_FN,
        ESXDOS_MODE_W | ESXDOS_MODE_CT);
    if (!errno) {
        esxdos_f_write(filehandle, cntdata, CNTDATA_SZ);
        esxdos_f_close(filehandle);
    }

    restorePrevPagesAtSlots0and1();

    intrinsic_ei();
}

///////////////////////////////////////////////////////////////////////////////

#define SCORES_FN "celeste.sco"
#define SCORES_SZ (SCORE_COUNT * sizeof(Score))

void persist_load_scores()
{
    intrinsic_di();

    storePrevPagesAtSlots0and1();
    putRomPagesAtSlots0and1();

    errno = 0;
    ubyte filehandle = esxdos_f_open(SCORES_FN,
        ESXDOS_MODE_R | ESXDOS_MODE_OE);
    if (!errno) {
        esxdos_f_read(filehandle, scores, SCORES_SZ);
        esxdos_f_close(filehandle);
    }

    restorePrevPagesAtSlots0and1();

    intrinsic_ei();
}

void persist_save_scores()
{
    intrinsic_di();

    storePrevPagesAtSlots0and1();
    putRomPagesAtSlots0and1();

    errno = 0;
    ubyte filehandle = esxdos_f_open(SCORES_FN,
        ESXDOS_MODE_W | ESXDOS_MODE_CT);
    if (!errno) {
        esxdos_f_write(filehandle, scores, SCORES_SZ);
        esxdos_f_close(filehandle);
    }

    restorePrevPagesAtSlots0and1();

    intrinsic_ei();
}



/*

#define TESTDATA_FN "celeste.txt"
#define TESTDATA "celeste\n"
#define TESTDATA_SZ 8

void test_write_file()
{
    intrinsic_di();

    storePrevPagesAtSlots0and1();
    putRomPagesAtSlots0and1();

    errno = 0;
    ubyte filehandle = esxdos_f_open(TESTDATA_FN,
        ESXDOS_MODE_W | ESXDOS_MODE_CT);
    if (!errno) {
        esxdos_f_write(filehandle, TESTDATA, TESTDATA_SZ);
        esxdos_f_close(filehandle);
    }

    restorePrevPagesAtSlots0and1();

    intrinsic_ei();
}

*/