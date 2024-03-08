;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Celeste Classic (remake) - for ZX Spectrum Next / N-Go
;
;  (c) 2024 David Crespo - https://github.com/dcrespo3d
;                          https://davidprograma.itch.io
;                          https://www.youtube.com/@Davidprograma
;
;  Based on Celeste Classic for Pico-8 - (c) 2015 Maddy Thorson, Noel Berry
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.  
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
; 
;  You should have received a copy of the GNU General Public License
;  along with this program.  If not, see <https://www.gnu.org/licenses/>. 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION code_user

; EXTERN PLY_AKG_INIT
; EXTERN PLY_AKG_PLAY
EXTERN _PLY_AKG_Init
EXTERN _PLY_AKG_Play
EXTERN readNextReg
EXTERN _current_song
EXTERN _current_subsong
EXTERN _turbosound_select_ay1
EXTERN _turbosound_select_ay2

_prev_page_a: defb 0
_prev_page_b: defb 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC music_pagein
music_pagein:
    ; store current pages
    LD A,   $50
    CALL    readNextReg
    LD      (_prev_page_a), A
    LD A,   $51
    CALL    readNextReg
    LD      (_prev_page_b), A

    ; set music player and songs pages
    NEXTREG $50, 54
    NEXTREG $51, 55

    RET

PUBLIC music_pageout
music_pageout:
    ; restore original pages
    LD      A, (_prev_page_a)
    NEXTREG $50, A
    LD      A, (_prev_page_b)
    NEXTREG $51, A

    RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _music_song_init_asm

_music_song_init_asm:
    CALL    _turbosound_select_ay1

    CALL    music_pagein

    ; initialize player with song
    ld hl, (_current_song)   ; The address of the music.
    ld a,0                   ; What subsong to play (starts at 0)?
    call _PLY_AKG_Init       ; Call the init method of the player.

    ; REMEMBER PITFALL!!
    ; ld hl, _song_meteo        ; direct symbol
    ; ld hl, (_current_song)    ; indirect symbol !!!

    CALL    music_pageout

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _music_subsong_init_asm

_music_subsong_init_asm:
    CALL    _turbosound_select_ay1

    CALL    music_pagein

    ; initialize player with song
    LD      hl, (_current_song)   ; The address of the music.
    LD      a, (_current_subsong) ; What subsong to play (starts at 0)?
    call _PLY_AKG_Init       ; Call the init method of the player.

    ; REMEMBER PITFALL!!
    ; ld hl, _song_meteo        ; direct symbol
    ; ld hl, (_current_song)    ; indirect symbol !!!

    CALL    music_pageout

    RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _music_song_play_frame_asm

_music_song_play_frame_asm:
    CALL    _turbosound_select_ay1
    
    CALL    music_pagein

    ; set music player and songs pages
    NEXTREG $50, 54
    NEXTREG $51, 55

    ; play one frame of music
    call    _PLY_AKG_Play

    CALL    music_pageout

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

REG_MIXER:       EQU     7
REG_ENV_SHAPE:   EQU     13

PUBLIC _sound_panic

_sound_panic:
    CALL    _turbosound_select_ay1
    
    LD D, $FF
    LD A, REG_MIXER

    LD BC, $FFFD
    OUT (C), A

    LD BC, $BFFD
    OUT (C), D

    LD D, $00
    LD A, REG_ENV_SHAPE

    LD BC, $FFFD
    OUT (C), A

    LD BC, $BFFD
    OUT (C), D

    RET
