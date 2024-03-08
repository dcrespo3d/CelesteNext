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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; public control variables
; available to C from control.h

PUBLIC _actnUp
PUBLIC _actnDown
PUBLIC _actnLeft
PUBLIC _actnRight
PUBLIC _actnJump
PUBLIC _actnDash

PUBLIC _prevUp
PUBLIC _prevDown
PUBLIC _prevLeft
PUBLIC _prevRight
PUBLIC _prevJump
PUBLIC _prevDash

_actnUp:     DB 0
_actnDown:   DB 0
_actnLeft:   DB 0
_actnRight:  DB 0
_actnJump:   DB 0
_actnDash:   DB 0

_prevUp:     DB 0
_prevDown:   DB 0
_prevLeft:   DB 0
_prevRight:  DB 0
_prevJump:   DB 0
_prevDash:   DB 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  control initialization: key, joy
;

PUBLIC _control_init

EXTERN _keyb_init
EXTERN _joystick_init

_control_init:
    CALL    _keyb_init
    CALL    _joystick_init
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  control update
;

PUBLIC _control_update

EXTERN _keyb_update
EXTERN _joystick_update

EXTERN _zxkeyQ
EXTERN _zxkeyA
EXTERN _zxkeyO
EXTERN _zxkeyP
EXTERN _zxkeyENT

EXTERN _nxkeyUp
EXTERN _nxkeyDown
EXTERN _nxkeyLeft
EXTERN _nxkeyRight

EXTERN _joyLeft
EXTERN _joyRight
EXTERN _joyUp
EXTERN _joyDown
EXTERN _joyBut1
EXTERN _joyBut2
EXTERN _joyBut3
EXTERN _joyBut4

EXTERN _keycodeUp
EXTERN _keycodeDown
EXTERN _keycodeLeft
EXTERN _keycodeRight
EXTERN _keycodeJump
EXTERN _keycodeDash

EXTERN _joycodeUp
EXTERN _joycodeDown
EXTERN _joycodeLeft
EXTERN _joycodeRight
EXTERN _joycodeJump
EXTERN _joycodeDash

EXTERN _keyb_is_pressed
EXTERN _joystick_is_pressed

_control_update:
    CALL    _keyb_update
    CALL    _joystick_update

    ; update previous menu entries

    LD      A, (_actnUp)
    LD      (_prevUp), A

    LD      A, (_actnDown)
    LD      (_prevDown), A

    LD      A, (_actnLeft)
    LD      (_prevLeft), A

    LD      A, (_actnRight)
    LD      (_prevRight), A

    LD      A, (_actnJump)
    LD      (_prevJump), A

    LD      A, (_actnDash)
    LD      (_prevDash), A

    ; menu controls

    LD      HL, (_keycodeUp)
    PUSH    HL
    CALL    _keyb_is_pressed
    POP     DE
    LD      A, L
    LD      B, A
    LD      HL, (_joycodeUp);
    PUSH    HL
    CALL    _joystick_is_pressed
    POP     DE
    LD      A, B
    OR      A, L
    LD      (_actnUp), A

    LD      HL, (_keycodeDown)
    PUSH    HL
    CALL    _keyb_is_pressed
    POP     DE
    LD      A, L
    LD      B, A
    LD      HL, (_joycodeDown);
    PUSH    HL
    CALL    _joystick_is_pressed
    POP     DE
    LD      A, B
    OR      A, L
    LD      (_actnDown), A

    LD      HL, (_keycodeLeft)
    PUSH    HL
    CALL    _keyb_is_pressed
    POP     DE
    LD      A, L
    LD      B, A
    LD      HL, (_joycodeLeft);
    PUSH    HL
    CALL    _joystick_is_pressed
    POP     DE
    LD      A, B
    OR      A, L
    LD      (_actnLeft), A

    LD      HL, (_keycodeRight)
    PUSH    HL
    CALL    _keyb_is_pressed
    POP     DE
    LD      A, L
    LD      B, A
    LD      HL, (_joycodeRight);
    PUSH    HL
    CALL    _joystick_is_pressed
    POP     DE
    LD      A, B
    OR      A, L
    LD      (_actnRight), A

    LD      HL, (_keycodeJump)
    PUSH    HL
    CALL    _keyb_is_pressed
    POP     DE
    LD      A, L
    LD      B, A
    LD      HL, (_joycodeJump);
    PUSH    HL
    CALL    _joystick_is_pressed
    POP     DE
    LD      A, B
    OR      A, L
    LD      (_actnJump), A

    LD      HL, (_keycodeDash)
    PUSH    HL
    CALL    _keyb_is_pressed
    POP     DE
    LD      A, L
    LD      B, A
    LD      HL, (_joycodeDash);
    PUSH    HL
    CALL    _joystick_is_pressed
    POP     DE
    LD      A, B
    OR      A, L
    LD      (_actnDash), A

    ; don't forget RET instruction (keeps happening)
    RET

