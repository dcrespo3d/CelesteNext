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

PUBLIC _joydata
PUBLIC _joyUp
PUBLIC _joyDown
PUBLIC _joyLeft
PUBLIC _joyRight
PUBLIC _joyBut1
PUBLIC _joyBut2
PUBLIC _joyBut3
PUBLIC _joyBut4

._joydata    defb 0

._joyUp      defb 0
._joyDown    defb 0
._joyLeft    defb 0
._joyRight   defb 0
._joyBut1    defb 0
._joyBut2    defb 0
._joyBut3    defb 0
._joyBut4    defb 0

JOY_UP    EQU $8
JOY_DOWN  EQU $4
JOY_LEFT  EQU $2
JOY_RIGHT EQU $1
JOY_BUT1  EQU $10
JOY_BUT2  EQU $20
JOY_BUT3  EQU $40
JOY_BUT4  EQU $80

PUBLIC _joystick_init
_joystick_init:
    RET

PUBLIC _joystick_update
_joystick_update:
    LD C, $1F
    IN A, (C)
    LD (_joydata), A

    LD HL, _joyUp
    LD B, 6
    XOR A
joystick_update_clear_loop:
    LD (HL), A
    INC HL
    DJNZ joystick_update_clear_loop

    LD A, (_joydata)
    LD B, A

    LD A, B
    AND JOY_UP
    JR Z, ASMPC+7   ; skip next two instructions
    LD A, 1
    LD (_joyUp), A

    LD A, B
    AND JOY_DOWN
    JR Z, ASMPC+7   ; skip next two instructions
    LD A, 1
    LD (_joyDown), A

    LD A, B
    AND JOY_LEFT
    JR Z, ASMPC+7   ; skip next two instructions
    LD A, 1
    LD (_joyLeft), A

    LD A, B
    AND JOY_RIGHT
    JR Z, ASMPC+7   ; skip next two instructions
    LD A, 1
    LD (_joyRight), A

    LD A, B
    AND JOY_BUT1
    JR Z, ASMPC+7   ; skip next two instructions
    LD A, 1
    LD (_joyBut1), A

    LD A, B
    AND JOY_BUT2
    JR Z, ASMPC+7   ; skip next two instructions
    LD A, 1
    LD (_joyBut2), A

    LD A, B
    AND JOY_BUT3
    JR Z, ASMPC+7   ; skip next two instructions
    LD A, 1
    LD (_joyBut3), A

    LD A, B
    AND JOY_BUT4
    JR Z, ASMPC+7   ; skip next two instructions
    LD A, 1
    LD (_joyBut4), A

    RET

PUBLIC _joystick_any
_joystick_any:
    LD      HL, 1
    LD      A, (_joydata)
    CP      A, 0
    JR      NZ, ASMPC+5
    LD      HL ,0
    RET

EXTERN count_bits_upto_8

PUBLIC _joystick_count
_joystick_count:
    LD      HL ,0
    LD      A, (_joydata)
    CALL    count_bits_upto_8
    RET
    
PUBLIC _joystick_code
_joystick_code:
    LD      H, 0
    LD      A, (_joydata)
    LD      L, A
    RET

EXTERN  get_first_set_bit

PUBLIC _joystick_short_for_code
_joystick_short_for_code:
    ; retrieve parameter restoring stack
    POP     BC      ; return address
    POP     DE      ; code
    PUSH    DE      ; restore stack
    PUSH    BC      ; restore stack

    LD      HL, 0
    LD      A, E
    call get_first_set_bit

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; input: joycode (u16 arg from stack)
; output: joypress state (1 or 0 in HL)
; clobbers: A DE HL

PUBLIC _joystick_is_pressed
_joystick_is_pressed:
    ; retrieve parameter restoring stack
    POP     HL      ; return address
    POP     DE      ; code
    PUSH    DE      ; restore stack
    PUSH    HL      ; restore stack

    LD      HL, _joydata
    LD      A, (HL)
    AND     A, E

    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET
    
