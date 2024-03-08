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

PUBLIC readNextReg

readNextReg:
; Input
;       A = nextreg to read
; Output:
;       A = value in nextreg
; Uses:
;       A, [currently selected NextReg on I/O port $243B]
    push    bc
    ld      bc, $243B   ; TBBLUE_REGISTER_SELECT_P_243B
    out     (c),a
    inc     b       ; bc = TBBLUE_REGISTER_ACCESS_P_253B
    in      a,(c)   ; read desired NextReg state
    pop     bc
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _setCpuSpeed28

_setCpuSpeed28:
; CPU SPEED
; register $07, bits 1-0
; %00 = 3.5MHz
; %01 = 7MHz
; %10 = 14MHz
; %11 = 28MHz (works since core 3.0)
    ld      a, $07
    call    readNextReg
    and     a, %11111100
    or      a, %00000011
    nextreg $07, a
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Peripheral 3 $08
; Bit Effect
;  7   1 unlock / 0 lock port Memory Paging Control $7FFD (page 41) paging
;  6   1 to disable RAM and I/O port contention (0 after soft reset)
;  5   AY stereo mode (0 = ABC, 1 = ACB) (0 after hard reset)
;  4   Enable internal speaker (1 after hard reset)
;  3   Enable 8-bit DACs (A,B,C,D) (0 after hard reset)
;  2   Enable port $FF Timex video mode read (0 after hard reset)
;  1   Enable Turbosound (currently selected AY is frozen when disabled) (0 after hard reset)
;  0   Implement Issue 2 keyboard (port $FE reads as early ZX boards) (0 after hard reset

PUBLIC _disableContention

_disableContention:
    LD      A, $08
    CALL    readNextReg
    OR      A, %01000000
    NEXTREG $08, A
    RET

putSomethingToUlaScreen:
    push    hl
    ld      hl, $4000
    ld      a, $AA
    ld     (hl), a
    ld      hl, $5800
    ld      a, $AA
    ld     (hl), a
    pop     hl
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _getActiveVideoLineWord

_getActiveVideoLineWord:
    LD      A, $1E
    CALL    readNextReg
    AND     A, 1
    LD      H, A
    LD      A, $1F
    CALL    readNextReg
    LD      L, A
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _get_sp

_get_sp:
    LD      HL, SP
    RET

PUBLIC _set_sp

_set_sp:
    POP     BC
    POP     HL
    LD      SP, HL
    LD      HL, BC
    DEC     HL
    DEC     HL
    JP      (HL)