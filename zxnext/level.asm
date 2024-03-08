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

LDAREA: EQU $5000
TMAREA: EQU $4000
BSZINC: EQU $0400
BSZDEC: EQU $FC00

SRCPTR: EQU LDAREA
DSTPTR: EQU TMAREA + 8

; warning: LDAREA must be page-aligned (256 bytes)

PUBLIC _level_deinterlace_blocks_asm
_level_deinterlace_blocks_asm:
    LD      DE, SRCPTR
    LD      HL, DSTPTR
    LD      C, 0
ldba_outer:
    LD      B, 32
ldba_inner:
    LD      A, (DE)
    LD      (HL), A

    INC     D
    INC     D
    INC     D
    INC     D
    INC     HL 

    LD      A, (DE)
    LD      (HL), A

    DEC     D
    DEC     D
    DEC     D
    DEC     D
    INC     DE
    INC     HL

    DJNZ    ldba_inner

    PUSH    BC
    LD      BC, 16
    ADD     HL, BC
    POP     BC

    INC     C
    LD      A, C
    CP      A, 32
    JR      NZ, ldba_outer
    RET
