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

PUBLIC _sfx_init
PUBLIC _sfx_update
PUBLIC _sfx_play_jump
PUBLIC _sfx_play_walljump
PUBLIC _sfx_play_dash
PUBLIC _sfx_play_death
PUBLIC _sfx_play_spawn
PUBLIC _sfx_play_spawnstep
PUBLIC _sfx_play_balloonpop
PUBLIC _sfx_play_balloonrespawn
PUBLIC _sfx_play_springrelease
PUBLIC _sfx_play_dashdepleted
PUBLIC _sfx_play_fruitcaught
PUBLIC _sfx_play_fruitflown
PUBLIC _sfx_play_floorbreak
PUBLIC _sfx_play_chestopen
PUBLIC _sfx_play_key
PUBLIC _sfx_play_dashland
PUBLIC _sfx_play_summitflag
PUBLIC _sfx_play_takeorb

EXTERN music_pagein
EXTERN music_pageout
EXTERN _song_silence
EXTERN _song_celeste1
EXTERN PLY_AKG_INIT
EXTERN PLY_AKG_PLAY

EXTERN SoundEffects
EXTERN PLY_AKG_INITSOUNDEFFECTS
EXTERN PLY_AKG_PLAYSOUNDEFFECT

EXTERN readNextReg

EXTERN _turbosound_select_ay2

_prev_page_a: defb 0
_prev_page_b: defb 0


_sfx_init:
    CALL    _turbosound_select_ay2

    CALL    music_pagein

    ; set music player and songs pages
    NEXTREG $50, 54
    NEXTREG $51, 55

    ; initialize player with song
    ld hl, _song_silence   ; The address of the music.
    ld a,0                   ; What subsong to play (starts at 0)?
    call PLY_AKG_INIT        ; Call the init method of the player.
    ; call _PLY_AKG_Init      ; Call the init method of the player.

    ; REMEMBER PITFALL!!
    ; ld hl, _song_meteo        ; direct symbol
    ; ld hl, (_current_song)    ; indirect symbol !!!

    ; initialize sound effects
    LD      HL, SoundEffects
    CALL    PLY_AKG_INITSOUNDEFFECTS

    CALL    music_pageout

    RET

_sfx_update:
    CALL    _turbosound_select_ay2

    CALL    music_pagein

    ; set music player and songs pages
    NEXTREG $50, 54
    NEXTREG $51, 55

    ; play one frame of silence and sound effects
    CALL    PLY_AKG_PLAY

    CALL    music_pageout

    RET


_sfx_play_jump:
    LD      L, 2
    JR      _sfx_play_A

_sfx_play_walljump:
    LD      L, 1
    JR      _sfx_play_A

_sfx_play_dash:
    LD      L, 3
    JR      _sfx_play_A

_sfx_play_spawn:
    LD      L, 5
    JR      _sfx_play_A

_sfx_play_spawnstep:
    LD      L, 6
    JR      _sfx_play_A

_sfx_play_dashdepleted:
    LD      L, 10
    JR      _sfx_play_A

_sfx_play_A:
    CALL    _turbosound_select_ay2

    CALL    music_pagein

    ; play sound effect
    LD      a,l     ; soundEffectNumber (>=1)
    LD      c,2     ; channel ;(0-2)
    LD      b,0     ; invertedVolume ;(0-16 (0=full volume))
    CALL    PLY_AKG_PLAYSOUNDEFFECT

    CALL    music_pageout

    RET

_sfx_play_death:
    LD      L, 4
    JR      _sfx_play_B

_sfx_play_balloonpop:
    LD      L, 7
    JR      _sfx_play_B

_sfx_play_balloonrespawn:
    LD      L, 8
    JR      _sfx_play_B

_sfx_play_springrelease:
    LD      L, 9
    JR      _sfx_play_B

_sfx_play_fruitcaught:
    LD      L, 11
    JR      _sfx_play_B

_sfx_play_fruitflown:
    LD      L, 12
    JR      _sfx_play_B

_sfx_play_floorbreak:
    LD      L, 13
    JR      _sfx_play_B

_sfx_play_chestopen:
    LD      L, 14
    JR      _sfx_play_B

_sfx_play_dashland:
    LD      L, 16
    JR      _sfx_play_B

_sfx_play_summitflag:
    LD      L, 17
    JR      _sfx_play_B

_sfx_play_takeorb:
    LD      L, 18
    JR      _sfx_play_B


_sfx_play_B:
    CALL    _turbosound_select_ay2

    CALL    music_pagein

    ; play sound effect
    LD      a,l     ; soundEffectNumber (>=1)
    LD      c,1     ; channel ;(0-2)
    LD      b,0     ; invertedVolume ;(0-16 (0=full volume))
    CALL    PLY_AKG_PLAYSOUNDEFFECT

    CALL    music_pageout

    RET

_sfx_play_key:
    LD      L, 15
    JR      _sfx_play_C

_sfx_play_C:
    CALL    _turbosound_select_ay2

    CALL    music_pagein

    ; play sound effect
    LD      a,l     ; soundEffectNumber (>=1)
    LD      c,2     ; channel ;(0-2)
    LD      b,0     ; invertedVolume ;(0-16 (0=full volume))
    CALL    PLY_AKG_PLAYSOUNDEFFECT

    CALL    music_pageout

    RET

