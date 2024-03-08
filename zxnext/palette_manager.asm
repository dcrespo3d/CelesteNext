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

;---------------------------------------------------------------------

EXTERN _tileset_palette

PUBLIC _palette_load_tilemap
PUBLIC _palette_load_sprites
PUBLIC _palette_load_layer2
PUBLIC _palette_load_layer2_2

;---------------------------------------------------------------------
_palette_load_tilemap:
    NEXTREG $43, %00110000		    ; Auto increment, select first tilemap palette
    JR      palette_load_common

_palette_load_sprites:
    NEXTREG $43, %00100000		    ; Auto increment, select first sprite palette
    JR      palette_load_common

_palette_load_layer2:
    NEXTREG $43, %00010000		    ; Auto increment, select first layer2 palette
    JR      palette_load_common

_palette_load_layer2_2:
    NEXTREG $43, %00010000		    ; Auto increment, select first layer2 palette
    JR      palette_load_common_2

palette_load_common:
    NEXTREG $40, 0

    ; retrieve parameters restoring stack
    POP     DE      ; return address
    POP     HL      ; palette address
    PUSH    HL      ; restore stack
    PUSH    DE      ; restore stack

    ; Copy palette
    LD      B,  0
    CALL    palette_load		    ; Call routine for copying

    RET

palette_load_common_2:
    NEXTREG $40, 0

    ; retrieve parameters restoring stack
    POP     DE      ; return address
    POP     HL      ; palette address
    PUSH    HL      ; restore stack
    PUSH    DE      ; restore stack

    ; Copy palette
    LD      B,  2
    CALL    palette_load		    ; Call routine for copying

    RET

;---------------------------------------------------------------------
; HL = memory location of the palette
palette_load_256:
	LD B, 0			; This variant always starts with 0
;---------------------------------------------------------------------
; HL = memory location of the palette
; B = number of colours to copy
palette_load:
	LD A, (HL)			; Load RRRGGGBB into A
	INC HL				; Increment to next entry
	NEXTREG $44, A		; Send entry to Next HW
	LD A, (HL)			; Load 0000000B into A
	INC HL				; Increment to next entry
	NEXTREG $44, A		; Send entry to Next HW
	DJNZ palette_load	; Repeat until B=0
	RET

;---------------------------------------------------------------------

