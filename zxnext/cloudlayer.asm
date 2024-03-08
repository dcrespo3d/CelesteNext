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

EXTERN readNextReg

PUBLIC _layer2_setup_320x256
PUBLIC _layer2_set_visible
PUBLIC _layer2_set_invisible

PUBLIC _system_set_layers_order_SUL
PUBLIC _system_set_global_transparency_0
PUBLIC _tilemap_set_transparent_index_0

_layer2_setup_320x256:
    ; https://wiki.specnext.dev/Layer_2_Control_Register
    NEXTREG $70, %00010000

    ; Setup window clip for 320x256 resolution
    NEXTREG $1C, 1              ; Reset Layer 2 clip window reg index
    NEXTREG $18, 0              ; X1; X2 next line
    NEXTREG $18, 159            ; 320 / 2 - 1
    NEXTREG $18, 0              ; Y1; Y2 next line
    NEXTREG $18, 255            ; 256 - 1

    RET

_layer2_set_visible:
    LD      BC, $123B
    LD      A, 2
    OUT     (C), A
    RET

_layer2_set_invisible:
    LD      BC, $123B
    LD      A, 0
    OUT     (C), A
    RET

_system_set_layers_order_SUL:
    ; Sprites over ULA/tilemap over Layer2
    ; https://wiki.specnext.dev/Sprite_and_Layers_System_Register
    LD      A, $15
    CALL    readNextReg
    AND     A, %11100011
    OR      A, %00001000    ; ---010--
    NEXTREG $15, A
    RET

_system_set_global_transparency_0:
    NEXTREG $14, 0
    RET

_tilemap_set_transparent_index_0:
    NEXTREG $4C, 0
    RET