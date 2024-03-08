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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _tilemap_setup

START_OF_BANK_5:		EQU $4000
START_OF_TILEMAP:		EQU $4000	; Just after
START_OF_TILESET:		EQU $6000	; SEE tileset.asm

OFFSET_OF_MAP:			EQU (START_OF_TILEMAP - START_OF_BANK_5) >> 8
OFFSET_OF_TILESET:		EQU (START_OF_TILESET - START_OF_BANK_5) >> 8


_tilemap_setup:

	; Enable tilemap mode
	NEXTREG $6B, %10000001		; 40x32, 16-bit entries
	NEXTREG $6C, %00000000		; palette offset, visuals

	; Test
	; NEXTREG $4C, %00000001
	; NEXTREG $68, %10000000

	; Tell hardware where to find tiles
	NEXTREG $6E, OFFSET_OF_MAP	; MSB of tilemap in bank 5
	NEXTREG $6F, OFFSET_OF_TILESET	; MSB of tilemap definitions

    RET

;;--------------------------------------------------------------------
;; subroutines
;;--------------------------------------------------------------------

PUBLIC _tilemap_load_default_palette
EXTERN _tileset_palette

_tilemap_load_default_palette:
	; Setup tilemap palette
	NEXTREG $43, %00110000		    ; Auto increment, select first tilemap palette
	NEXTREG $40, 0

	LD		HL, _tileset_palette
	CALL	copyPalette256
	RET

;---------------------------------------------------------------------
; HL = memory location of the palette
copyPalette256:
	LD B, 0			; This variant always starts with 0
;---------------------------------------------------------------------
; HL = memory location of the palette
; B = number of colours to copy
copyPalette:
	LD A, (HL)			; Load RRRGGGBB into A
	INC HL				; Increment to next entry
	NEXTREG $44, A		; Send entry to Next HW
	LD A, (HL)			; Load 0000000B into A
	INC HL				; Increment to next entry
	NEXTREG $44, A		; Send entry to Next HW
	DJNZ copyPalette	; Repeat until B=0
	RET

;---------------------------------------------------------------------
; HL = memory location of tile definitons
; BC = size of tile defitions in bytes.
copyTileDefinitions:
	LD DE, START_OF_TILESET
	LDIR
	RET

;---------------------------------------------------------------------
; HL = memory location of tilemap
; copyTileMap40x32:
; 	LD BC, 40*32*2		; This variant always load 40x32
; 	JR copyTileMap
; copyTileMap80x32:
; 	LD BC, 80*32*2		; This variant always loads 80x32
;---------------------------------------------------------------------
; HL = memory location of tilemap
; BC = size of tilemap in bytes
copyTileMap:
	LD DE, START_OF_TILEMAP
	LDIR
	RET

;;--------------------------------------------------------------------
;; data
;;--------------------------------------------------------------------

; palette:
; 	INCBIN "res/tileset_palette.bin"
; paletteLength: EQU $-palette

PUBLIC _tilemap_clear_buf
_tilemap_clear_buf:
    LD      HL, $4000
    LD      B, 5
tcb2:
    PUSH    BC
    LD      B, 0
tcb1:
	LD		A, 0		; blank: index 0
    LD      (HL), A
    INC     HL
	LD		A, 0
    LD      (HL), A		; blank: palette 0
    INC     HL
    DJNZ    tcb1
    POP     BC
    DJNZ    tcb2
	RET


; set_tilemap_offset:
;     LD A, b
;     NEXTREG $30, A
