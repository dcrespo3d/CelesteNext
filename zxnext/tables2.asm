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

EXTERN _rndtable

ridx: DEFB 0

PUBLIC _rndtable_init
_rndtable_init:
    LD      A, R
    LD      (ridx), A
    LD      H, 0
    LD      L, A
    RET

PUBLIC _rndtable_next
_rndtable_next:
    LD      A, (ridx)
    LD      B, 0
    LD      C, A
    INC     A
    LD      (ridx), A

    LD      HL, _rndtable
    ADD     HL, BC
    LD      L, (HL)
    LD      H, 0
    RET

randi_11_table:
    DEFB -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1

PUBLIC _randi_11
_randi_11:
    CALL    _rndtable_next
    LD      A, L
    AND     A, $0F
    LD      B, 0
    LD      C, A
    LD      HL, randi_11_table
    ADD     HL, BC
    LD      L, (HL)
    LD      H, 0
    RET
