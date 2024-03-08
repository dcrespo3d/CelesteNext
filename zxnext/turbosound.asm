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

PUBLIC _turbosound_init
PUBLIC _turbosound_select_ay1
PUBLIC _turbosound_select_ay2

EXTERN readNextReg

_turbosound_init:
    ; https://wiki.specnext.dev/Peripheral_3_Register
    LD      A, $08
    CALL    readNextReg
    OR      A, %00000010
    NEXTREG $08, A
    RET

_turbosound_select_ay1:
    ; https://wiki.specnext.dev/Turbo_Sound_Next_Control
    LD      BC, $FFFD
    LD      A, %11111101
    OUT     (C), A
    RET

_turbosound_select_ay2:
    ; https://wiki.specnext.dev/Turbo_Sound_Next_Control
    LD      BC, $FFFD
    LD      A, %11111110
    OUT     (C), A
    RET    