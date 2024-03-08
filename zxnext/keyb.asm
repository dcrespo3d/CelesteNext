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

extern readNextReg

PUBLIC _zxkey54321
PUBLIC _zxkey67890
PUBLIC _zxkeyTREWQ
PUBLIC _zxkeyYUIOP
PUBLIC _zxkeyGFDSA
PUBLIC _zxkeyHJKLe
PUBLIC _zxkeyVCXZc
PUBLIC _zxkeyBNMys
PUBLIC _nxkey0    
PUBLIC _nxkey1    

._zxkey54321 defb 0
._zxkey67890 defb 0
._zxkeyTREWQ defb 0
._zxkeyYUIOP defb 0
._zxkeyGFDSA defb 0
._zxkeyHJKLe defb 0
._zxkeyVCXZc defb 0
._zxkeyBNMys defb 0
._nxkey0     defb 0
._nxkey1     defb 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _keyb_init

_keyb_init:
    ; Cancel entries in 8x5 matrix for extended keys
    NEXTREG $68,$10
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _keyb_read_spectrum_next

_keyb_read_spectrum_next:
    LD A, $B0
    CALL readNextReg
    LD (_nxkey0), A

    LD A, $B1
    CALL readNextReg
    LD (_nxkey1), A
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _keyb_read_spectrum_std

_keyb_read_spectrum_std:
    PUSH BC

    LD   C, $FE
    LD   B, $F7 ;12345
    IN   A, (C)
    NEG
    DEC  A
    AND  A, $1F
    LD  (_zxkey54321), A

    LD   C, $FE
    LD   B, $EF ;09876
    IN   A, (C)
    NEG
    DEC  A
    AND  A, $1F
    LD  (_zxkey67890), A

    LD   C, $FE
    LD   B, $FB ;QWERT
    IN   A, (C)
    NEG
    DEC  A
    AND  A, $1F
    LD  (_zxkeyTREWQ), A

    LD   C, $FE
    LD   B, $DF ;POIUY
    IN   A, (C)
    NEG
    DEC  A
    AND  A, $1F
    LD  (_zxkeyYUIOP), A

    LD   C, $FE
    LD   B, $FD ;ASDFG
    IN   A, (C)
    NEG
    DEC  A
    AND  A, $1F
    LD  (_zxkeyGFDSA), A

    LD   C, $FE
    LD   B, $BF ;-LKJH
    IN   A, (C)
    NEG
    DEC  A
    AND  A, $1F
    LD  (_zxkeyHJKLe), A

    LD   C, $FE
    LD   B, $FE ;-ZXCV
    IN   A, (C)
    NEG
    DEC  A
    AND  A, $1F
    LD  (_zxkeyVCXZc), A

    LD   C, $FE
    LD   B, $7F ;--MNB
    IN   A, (C)
    NEG
    DEC  A
    AND  A, $1F
    LD  (_zxkeyBNMys), A

    POP BC

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _keyb_any
_keyb_any:
    LD      HL, 1
    LD      A, (_zxkey54321)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      A, (_zxkey67890)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      A, (_zxkeyTREWQ)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      A, (_zxkeyYUIOP)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      A, (_zxkeyGFDSA)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      A, (_zxkeyHJKLe)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      A, (_zxkeyVCXZc)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      A, (_zxkeyBNMys)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      A, (_nxkey0)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      A, (_nxkey1)
    CP      A, 0
    JR      Z, ASMPC+3
    RET
    LD      HL, 0
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC get_first_set_bit
get_first_set_bit:
    LD      L, 0
    LD      B, 8
gfsb_loop:
    RRCA
    JR      NC, ASMPC+3
    RET
    INC     L
    DJNZ    gfsb_loop
    LD      L, $FF
    RET

PUBLIC _keyb_short_for_code
_keyb_short_for_code:
    ; retrieve parameter restoring stack
    POP     BC      ; return address
    POP     DE      ; code
    PUSH    DE      ; restore stack
    PUSH    BC      ; restore stack

    LD      HL, 0
    LD      A, E
    call get_first_set_bit

    LD      A, D
    RLCA
    RLCA
    RLCA
    OR      A, L
    LD      L, A

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _keyb_code
_keyb_code:
    LD      HL, 0

    LD      A, (_zxkey54321)
    AND     A, $1F
    JR      Z, ASMPC+4
    LD      L, A
    RET

    INC     H
    LD      A, (_zxkey67890)
    AND     A, $1F
    JR      Z, ASMPC+4
    LD      L, A
    RET

    INC     H
    LD      A, (_zxkeyTREWQ)
    AND     A, $1F
    JR      Z, ASMPC+4
    LD      L, A
    RET

    INC     H
    LD      A, (_zxkeyYUIOP)
    AND     A, $1F
    JR      Z, ASMPC+4
    LD      L, A
    RET

    INC     H
    LD      A, (_zxkeyGFDSA)
    AND     A, $1F
    JR      Z, ASMPC+4
    LD      L, A
    RET

    INC     H
    LD      A, (_zxkeyHJKLe)
    AND     A, $1F
    JR      Z, ASMPC+4
    LD      L, A
    RET

    INC     H
    LD      A, (_zxkeyVCXZc)
    AND     A, $1F
    JR      Z, ASMPC+4
    LD      L, A
    RET

    INC     H
    LD      A, (_zxkeyBNMys)
    AND     A, $1F
    JR      Z, ASMPC+4
    LD      L, A
    RET

    INC     H
    LD      A, (_nxkey0)
    AND     A, $FF
    JR      Z, ASMPC+4
    LD      L, A
    RET

    INC     H
    LD      A, (_nxkey1)
    AND     A, $FF
    JR      Z, ASMPC+4
    LD      L, A
    RET

    LD      HL, 0
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; input: keycode (u16 arg from stack)
; output: keypress state (1 or 0 in HL)
; clobbers: A BC DE HL

PUBLIC _keyb_is_pressed
_keyb_is_pressed:
    ; retrieve parameter restoring stack
    POP     BC      ; return address
    POP     DE      ; code
    PUSH    DE      ; restore stack
    PUSH    BC      ; restore stack

    LD      B, 0
    LD      C, D

    LD      HL, _zxkey54321
    ADD     HL, BC

    LD      A, (HL)
    AND     A, E

    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; counts bits in number (up to 5)
; input: A - number to count bits
; input: HL - previous count of "1" bits
; output: HL - added count of "1" bits in number
; clobbers: A B HL
count_bits_upto_5:
    LD      B, 5
cbu5_loop:
    RRCA
    JR      NC, ASMPC + 3
    INC     HL
    DJNZ    cbu5_loop
    RET

PUBLIC count_bits_upto_8
; counts bits in number (up to 8)
; input: A - number to count bits
; input: HL - previous count of "1" bits
; output: HL - added count of "1" bits in number
; clobbers: A B HL
count_bits_upto_8:
    LD      B, 8
cbu8_loop:
    RRCA
    JR      NC, ASMPC + 3
    INC     HL
    DJNZ    cbu8_loop
    RET

; counts number of pressed keys (standard spectrum + next)
; output: HL - number of pressed keys
; clobbers: A B HL
PUBLIC _keyb_count
_keyb_count:
    LD      HL, 0
    LD      A, (_zxkey54321)
    CALL    count_bits_upto_5
    LD      A, (_zxkey67890)
    CALL    count_bits_upto_5
    LD      A, (_zxkeyTREWQ)
    CALL    count_bits_upto_5
    LD      A, (_zxkeyYUIOP)
    CALL    count_bits_upto_5
    LD      A, (_zxkeyGFDSA)
    CALL    count_bits_upto_5
    LD      A, (_zxkeyHJKLe)
    CALL    count_bits_upto_5
    LD      A, (_zxkeyVCXZc)
    CALL    count_bits_upto_5
    LD      A, (_zxkeyBNMys)
    CALL    count_bits_upto_5
    LD      A, (_nxkey0)
    CALL    count_bits_upto_8
    LD      A, (_nxkey1)
    CALL    count_bits_upto_8
    RET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _zxkey1
_zxkey1:
    LD      A, (_zxkey54321)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkey2
_zxkey2:
    LD      A, (_zxkey54321)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkey3
_zxkey3:
    LD      A, (_zxkey54321)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkey4
_zxkey4:
    LD      A, (_zxkey54321)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkey5
_zxkey5:
    LD      A, (_zxkey54321)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkey6
_zxkey6:
    LD      A, (_zxkey67890)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkey7
_zxkey7:
    LD      A, (_zxkey67890)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkey8
_zxkey8:
    LD      A, (_zxkey67890)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkey9
_zxkey9:
    LD      A, (_zxkey67890)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkey0
_zxkey0:
    LD      A, (_zxkey67890)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyQ
_zxkeyQ:
    LD      A, (_zxkeyTREWQ)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyW
_zxkeyW:
    LD      A, (_zxkeyTREWQ)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyE
_zxkeyE:
    LD      A, (_zxkeyTREWQ)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyR
_zxkeyR:
    LD      A, (_zxkeyTREWQ)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyT
_zxkeyT:
    LD      A, (_zxkeyTREWQ)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyY
_zxkeyY:
    LD      A, (_zxkeyYUIOP)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyU
_zxkeyU:
    LD      A, (_zxkeyYUIOP)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyI
_zxkeyI:
    LD      A, (_zxkeyYUIOP)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyO
_zxkeyO:
    LD      A, (_zxkeyYUIOP)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyP
_zxkeyP:
    LD      A, (_zxkeyYUIOP)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyA
_zxkeyA:
    LD      A, (_zxkeyGFDSA)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyS
_zxkeyS:
    LD      A, (_zxkeyGFDSA)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyD
_zxkeyD:
    LD      A, (_zxkeyGFDSA)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyF
_zxkeyF:
    LD      A, (_zxkeyGFDSA)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyG
_zxkeyG:
    LD      A, (_zxkeyGFDSA)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyH
_zxkeyH:
    LD      A, (_zxkeyHJKLe)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyJ
_zxkeyJ:
    LD      A, (_zxkeyHJKLe)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyK
_zxkeyK:
    LD      A, (_zxkeyHJKLe)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyL
_zxkeyL:
    LD      A, (_zxkeyHJKLe)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyENT
_zxkeyENT:
    LD      A, (_zxkeyHJKLe)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyCAP
_zxkeyCAP:
    LD      A, (_zxkeyVCXZc)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyZ
_zxkeyZ:
    LD      A, (_zxkeyVCXZc)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyX
_zxkeyX:
    LD      A, (_zxkeyVCXZc)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyC
_zxkeyC:
    LD      A, (_zxkeyVCXZc)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyV
_zxkeyV:
    LD      A, (_zxkeyVCXZc)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyB
_zxkeyB:
    LD      A, (_zxkeyBNMys)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyN
_zxkeyN:
    LD      A, (_zxkeyBNMys)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeyM
_zxkeyM:
    LD      A, (_zxkeyBNMys)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeySYM
_zxkeySYM:
    LD      A, (_zxkeyBNMys)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _zxkeySPC
_zxkeySPC:
    LD      A, (_zxkeyBNMys)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeySemicolon
_nxkeySemicolon:
    LD      A, (_nxkey0)
    AND     A, 0x80
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyQuote
_nxkeyQuote:
    LD      A, (_nxkey0)
    AND     A, 0x40
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyComma
_nxkeyComma:
    LD      A, (_nxkey0)
    AND     A, 0x20
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyPeriod
_nxkeyPeriod:
    LD      A, (_nxkey0)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyUp
_nxkeyUp:
    LD      A, (_nxkey0)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyDown
_nxkeyDown:
    LD      A, (_nxkey0)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyLeft
_nxkeyLeft:
    LD      A, (_nxkey0)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyRight
_nxkeyRight:
    LD      A, (_nxkey0)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyDel
_nxkeyDel:
    LD      A, (_nxkey1)
    AND     A, 0x80
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyEdit
_nxkeyEdit:
    LD      A, (_nxkey1)
    AND     A, 0x40
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyBreak
_nxkeyBreak:
    LD      A, (_nxkey1)
    AND     A, 0x20
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyInvVideo
_nxkeyInvVideo:
    LD      A, (_nxkey1)
    AND     A, 0x10
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyTruVideo
_nxkeyTruVideo:
    LD      A, (_nxkey1)
    AND     A, 0x08
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyGraph
_nxkeyGraph:
    LD      A, (_nxkey1)
    AND     A, 0x04
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyCapsLock
_nxkeyCapsLock:
    LD      A, (_nxkey1)
    AND     A, 0x02
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

PUBLIC _nxkeyExtend
_nxkeyExtend:
    LD      A, (_nxkey1)
    AND     A, 0x01
    LD      HL, 0
    JR      Z, ASMPC+3
    INC     HL
    RET

