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

PUBLIC _curr_print_symbol
PUBLIC _curr_pos_x
PUBLIC _curr_pos_y
PUBLIC _last_pos_x
PUBLIC _last_pos_y

_tmstart:           DEFW    $4000
_curr_print_posptr: DEFW    $4000

_curr_print_attr:   DEFB    0
_curr_print_symbol: DEFB    0

_curr_pos_x:        DEFB    0
_curr_pos_y:        DEFB    0

_last_pos_x:        DEFB    0
_last_pos_y:        DEFB    0

DBT_OFFSET:         EQU     128



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_set_pos_asm

_print_set_pos_asm:
    LD      A, (_curr_pos_x)
    LD      (_last_pos_x), A
    LD      B, A
    
    LD      A, (_curr_pos_y)
    LD      (_last_pos_y), A
    LD      C, A

    LD  H, 0
    LD  L, C
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    LD  DE, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, DE   ; 80*y
    LD  DE, HL

    LD  H, 0
    LD  L, B
    ADD HL, HL   ; 2*x
    ADD HL, DE   ; 2*x + 80*y
    LD  DE, HL

    LD  HL, (_tmstart)
    ADD HL, DE
    LD  (_curr_print_posptr), HL

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_set_attr

_print_set_attr:
    LD HL, 2
    ADD HL, SP
    LD A, (HL)

    LD (_curr_print_attr), A
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_set_color
_print_set_color:
    LD HL, 2
    ADD HL, SP
    LD A, (HL)

    SWAPNIB
    AND A, %11110000

    LD (_curr_print_attr), A

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_set_symbol
_print_set_symbol:
    LD HL, 2
    ADD HL, SP
    LD A, (HL)

    LD (_curr_print_symbol), A

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_symbol
_print_symbol:
    LD  HL, (_curr_print_posptr)
    LD  A, (_curr_print_symbol)
    LD (HL), A
    INC HL

    LD  A, (_curr_print_attr)
    LD (HL), A
    INC HL

    LD (_curr_print_posptr), HL

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_char
_print_char:
    LD HL, 2
    ADD HL, SP
    LD L, (HL)
    LD A, L

    CP A, '\n'
    JR NZ, print_char_char

    LD      A, (_last_pos_x)
    INC     A
    LD      (_curr_pos_x), A

    LD      A, (_last_pos_y)
    LD      (_curr_pos_y), A

    CALL _print_set_pos_asm

    RET
    
    ; SUB A, 96
    ; LD A, L
    ; JR C, print_char_ge96
    ; SUB A, 32

    ; print_char_ge96:

print_char_char:
    LD HL, (_curr_print_posptr)
    ADD A, DBT_OFFSET
    LD (HL), A
    INC HL

    LD A, (_curr_print_attr)
    LD (HL), A
    INC HL

    LD (_curr_print_posptr), HL

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PUBLIC _print_block
; _print_block:
;     LD HL, 2
;     ADD HL, SP
;     LD L, (HL)
;     LD A, L
    
;     LD HL, (_curr_print_posptr)
;     LD (HL), A
;     INC HL

;     LD A, (_curr_print_attr)
;     LD (HL), A
;     INC HL

;     LD (_curr_print_posptr), HL

;     RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_str
_print_str:
    POP BC
    POP HL
    PUSH HL
    PUSH BC
    LD A, (HL)
    CP 0
    JR Z, print_str_end
    print_str_loop:
        LD D, 0
        LD E, A
        PUSH HL
        PUSH DE
        CALL _print_char
        POP DE
        POP HL
        INC HL
        LD A, (HL)
        CP 0
    JR NZ, print_str_loop

    print_str_end:
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _hex_char_for_val
_hex_char_for_val:
    LD HL, 2
    ADD HL, SP
    LD L, (HL)

    LD A, L
    SUB A, 10
    LD A, L
    JR C, hex_char_for_val_ge10
    ADD A, 7

    hex_char_for_val_ge10:
    ADD A, 0x30     ; + '0'
    LD H, 0
    LD L, A

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_hex_word
_print_hex_word:
    POP BC
    POP HL
    PUSH HL
    PUSH BC
    
    LD  A, H
    SWAPNIB
    AND A, %00001111
    LD  E, A

    LD  A, H
    AND A, %00001111
    LD  D, A

    LD  A, L
    SWAPNIB
    AND A, %00001111
    LD  C, A

    LD  A, L
    AND A, %00001111
    LD  B, A

    ; PUSH DE   ; not needed as called routines do not clobber DE
    ; PUSH BC   ; not needed as called routines do not clobber BC
    LD H, 0
    LD L, E
    PUSH HL
    CALL _hex_char_for_val
    INC SP
    INC SP
    PUSH HL
    CALL _print_char
    INC SP
    INC SP
    ; POP BC   ; not needed as called routines do not clobber BC
    ; POP DE   ; not needed as called routines do not clobber DE

    LD H, 0
    LD L, D
    PUSH HL
    CALL _hex_char_for_val
    INC SP
    INC SP
    PUSH HL
    CALL _print_char
    INC SP
    INC SP

    LD H, 0
    LD L, C
    PUSH HL
    CALL _hex_char_for_val
    INC SP
    INC SP
    PUSH HL
    CALL _print_char
    INC SP
    INC SP

    LD H, 0
    LD L, B
    PUSH HL
    CALL _hex_char_for_val
    INC SP
    INC SP
    PUSH HL
    CALL _print_char
    INC SP
    INC SP

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_print_dec_word_flag: DEFB 0

PUBLIC _print_dec_word
_print_dec_word:
    POP BC
    POP HL      ; HL <- val
    PUSH HL
    PUSH BC

    XOR A
    CP H
    JR NZ, print_dec_word_0
    CP L
    JR NZ, print_dec_word_0
    LD L, '0'
    PUSH HL
    CALL _print_char
    POP HL
    RET

print_dec_word_0:
    XOR A
    LD (_print_dec_word_flag), A

    LD BC, -10000
    CALL print_dec_word_1
    LD BC, -1000
    CALL print_dec_word_1
    LD BC, -100
    CALL print_dec_word_1
    LD C, -10
    CALL print_dec_word_1
    LD C, B

print_dec_word_1:
    LD A, '0' - 1
print_dec_word_2:
    INC A
    ADD HL, BC
    JR  C, print_dec_word_2
    SBC HL, BC

    LD D, A
    LD A, (_print_dec_word_flag)
    CP A, 1
    LD A, D
    JR Z, print_dec_word_noskip

    CP A, '0'
    JR Z, print_dec_word_skip

print_dec_word_noskip:
    LD D,0
    LD E,A
    PUSH HL
    ; PUSH BC     ; not needed as called routines do not clobber BC
    PUSH DE
    CALL _print_char
    POP DE
    ; POP BC      ; not needed as called routines do not clobber BC
    POP HL

    LD A, 1
    LD (_print_dec_word_flag), A

print_dec_word_skip:    
    
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_hex_byte
_print_hex_byte:
    LD  HL, 2
    ADD HL, SP
    LD  L, (HL)

    LD  A, L
    SWAPNIB
    AND A, %00001111
    LD  C, A

    LD  A, L
    AND A, %00001111
    LD  B, A

    ; PUSH BC   ; not needed as called routines do not clobber BC
    LD H, 0
    LD L, C
    PUSH HL
    CALL _hex_char_for_val
    INC SP
    INC SP
    PUSH HL
    CALL _print_char
    INC SP
    INC SP
    ; POP BC   ; not needed as called routines do not clobber BC

    LD H, 0
    LD L, B
    PUSH HL
    CALL _hex_char_for_val
    INC SP
    INC SP
    PUSH HL
    CALL _print_char
    INC SP
    INC SP

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_dec_byte
_print_dec_byte:
    LD  HL, 2
    ADD HL, SP
    LD  A, (HL)

    CP  A, 0
    JR  NZ, print_dec_byte_0
    LD  H, 0
    LD  L, '0'
    PUSH HL
    CALL _print_char
    POP  HL
    RET

print_dec_byte_0:
    LD H, 0

    LD C, -100
    CALL print_dec_byte_1
    LD C, -10
    CALL print_dec_byte_1
    LD C, -1

print_dec_byte_1:
    LD B, '0' - 1
print_dec_byte_2:
    INC B
    ADD A, C
    JR  C, print_dec_byte_2
    SBC A, C

    LD  D, A
    LD  A, H
    CP  A, 1
    LD  A, D
    JR  Z, print_dec_byte_noskip

    LD  D, A
    LD  A, B
    CP  A, '0'
    LD  A, D
    JR  Z, print_dec_byte_skip

print_dec_byte_noskip:
    LD  L, A
    LD  A, B
    LD  D, 0
    LD  E, A
    PUSH HL
    PUSH DE
    CALL _print_char
    POP DE
    POP HL
    LD  A, L

    LD  H, 1

print_dec_byte_skip:

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_hex_nibble
_print_hex_nibble:
    LD  HL, 2
    ADD HL, SP
    LD  L, (HL)

    LD  A, L
    AND A, %00001111
    LD  B, A

    LD H, 0
    LD L, B
    PUSH HL
    CALL _hex_char_for_val
    INC SP
    INC SP
    PUSH HL
    CALL _print_char
    INC SP
    INC SP

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _print_frame
_print_frame:
    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _uword_dec_bytes
_uword_dec_bytes: DEFS 6, 0

PUBLIC _uword_to_dec_bytes
_uword_to_dec_bytes:
    POP BC
    POP HL      ; HL <- val
    PUSH HL
    PUSH BC

    LD      DE, _uword_dec_bytes
    LD      A, 0

    LD      (DE), A
    INC     DE
    LD      (DE), A
    INC     DE
    LD      (DE), A
    INC     DE
    LD      (DE), A
    INC     DE
    LD      (DE), A
    INC     DE

    LD      DE, _uword_dec_bytes

    LD BC, -10000
    CALL uword_to_dec_bytes_1
    LD BC, -1000
    CALL uword_to_dec_bytes_1
    LD BC, -100
    CALL uword_to_dec_bytes_1
    LD C, -10
    CALL uword_to_dec_bytes_1
    LD C, B

uword_to_dec_bytes_1:
    LD A, -1
uword_to_dec_bytes_2:
    INC A
    ADD HL, BC
    JR  C, uword_to_dec_bytes_2
    SBC HL, BC

    LD      (DE), A
    INC     DE

    RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PUBLIC _ubyte_dec_bytes
_ubyte_dec_bytes: DEFS 3, 0

PUBLIC _ubyte_to_dec_bytes
_ubyte_to_dec_bytes:
    LD      DE, _ubyte_dec_bytes
    LD      A, 0

    LD      (DE), A
    INC     DE
    LD      (DE), A
    INC     DE
    LD      (DE), A
    INC     DE

    LD      DE, _ubyte_dec_bytes

    LD      HL, 2
    ADD     HL, SP
    LD      A, (HL)

ubyte_to_dec_bytes_0:
    LD      C, -100
    CALL    ubyte_to_dec_bytes_1
    LD      C, -10
    CALL    ubyte_to_dec_bytes_1
    LD      C, -1

ubyte_to_dec_bytes_1:
    LD      B, -1
ubyte_to_dec_bytes_2:
    INC     B
    ADD     A, C
    JR      C, ubyte_to_dec_bytes_2
    SBC     A, C

    PUSH    AF
    LD      A, B
    LD      (DE), A
    INC     DE
    POP     AF

    RET

