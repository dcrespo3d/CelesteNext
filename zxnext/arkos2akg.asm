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

SECTION PAGE_54_MUSIC
ORG $0000

PLY_AKG_OPCODE_SBC_HL_BC_MSB: equ $ed
	;Opcode for "sbc hl,bc", MSB.
PLY_AKG_OPCODE_SBC_HL_BC_LSB: equ $42
	;Opcode for "sbc hl,bc", LSB.
PLY_AKG_OPCODE_SUB_IMMEDIATE: equ $d6
	;Opcode for "sub x".
PLY_AKG_OPCODE_DEC_HL: equ $2b
	;Opcode for "dec hl".
PLY_AKG_OPCODE_OR_A: equ $b7
	;0 * 2 = 0, no carry.
PLY_AKG_OPCODE_SCF: equ $37                         ;Opcode for "scf".
PLY_AKG_OPCODE_ADD_HL_BC_MSB: equ $00               ;Opcode for "add hl,bc", MSB (fake, it is only 8 bits).
PLY_AKG_OPCODE_ADD_HL_BC_LSB: equ $09               ;Opcode for "add hl,bc", LSB.
PLY_AKG_OPCODE_ADD_A_IMMEDIATE: equ $c6             ;Opcode for "add a,x".
PLY_AKG_OPCODE_INC_HL: equ $23
;Opcode for "inc hl".

PLAYER:                     ;$C000

PUBLIC _PLY_AKG_Start       ;$C000
_PLY_AKG_Start:
	jp _PLY_AKG_Init        ;demo $C000
    jp _PLY_AKG_Play        ;demo $C003
    jp PLY_AKG_InitTableOrA_End ;demo $C006


PUBLIC _PLY_AKG_Init
_PLY_AKG_Init:				;demo $C009
	ld de,4
    add hl,de

    ld de,PLY_AKG_ARPEGGIOSTABLE+1;
    ldi
    ldi

    ld de,PLY_AKG_PITCHESTABLE+1;
    ldi
    ldi
    ld de,PLY_AKG_INSTRUMENTSTABLE+1;
    ldi
    ldi
    ld c,(hl)	            ;demo $C022
    inc hl
    ld b,(hl)
    inc hl

    ld (PLY_AKG_CHANNEL_READEFFECTS_EFFECTBLOCKS1+1),bc;<

    ld (PLY_AKG_CHANNEL_READEFFECTS_EFFECTBLOCKS2+1),bc;<
    add a,a
    ld e,a
    ld d,0
    add hl,de
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld de,5					;demo $C037
    add hl,de
    ld de,PLY_AKG_CHANNEL3_READCELLEND+1
    ldi
    ld de,PLY_AKG_CHANNEL1_NOTE+1
    ldi
    ld (PLY_AKG_READLINKER+1),hl
    ld hl,PLY_AKG_InitTable0
    ld bc, 0x0E00			;demo $C04B
    call PLY_AKG_Init_ReadWordsAndFill
    inc c
    ld hl,PLY_AKG_INITTABLE0_END
    ld b,3
    call PLY_AKG_Init_ReadWordsAndFill
    ld hl,PLY_AKG_INITTABLE1_END
    ld bc, 0xDB7			;demo $C05D
    call PLY_AKG_Init_ReadWordsAndFill
    ld a, 0xFF				;demo $C063

    ld (PLY_AKG_PSGREG13_OLDVALUE+1),a;
    ld hl,(PLY_AKG_INSTRUMENTSTABLE+1)
    ld e,(hl)
    inc hl
    ld d,(hl)
    ex de,hl
    inc hl

    ld (PLY_AKG_ENDWITHOUTLOOP+1),hl;<
    ld (PLY_AKG_CHANNEL1_PTINSTRUMENT+1),hl;<
    ld (PLY_AKG_CHANNEL2_PTINSTRUMENT+1),hl;<
    ld (PLY_AKG_CHANNEL3_PTINSTRUMENT+1),hl;<
ret 	                    ;demo $C07C

;Fills all the read addresses with a byte.
;IN:    HL = table where the addresses are.
;       B = how many items in the table + 1.
;       C = byte to fill.
                            ;demo $C07D
PLY_AKG_Init_ReadWordsAndFill_Loop:	;OK
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,c
	ld (de),a

PLY_AKG_Init_ReadWordsAndFill:  ;$C083
        djnz PLY_AKG_Init_ReadWordsAndFill_Loop
ret							;demo $C085

;error different than source
;Table initializing some data with 0.
PLY_AKG_InitTable0:			;demo $C086

	PLY_AKG_Offset1b: equ 1	;attention test with 1, was 0
	PLY_AKG_Offset2b: equ 0 ;attention test with 1, was 0
;----------------------
	defw PLY_AKG_Channel1_InvertedVolumeIntegerAndDecimal + PLY_AKG_Offset1b
	defw PLY_AKG_Channel1_InvertedVolumeIntegerAndDecimal + PLY_AKG_Offset1b + 1
;PLY_AKG_Offset2b must NOT be used here.
	defw PLY_AKG_Channel2_InvertedVolumeIntegerAndDecimal + PLY_AKG_Offset1b
	defw PLY_AKG_Channel2_InvertedVolumeIntegerAndDecimal + PLY_AKG_Offset1b + 1
	defw PLY_AKG_Channel3_InvertedVolumeIntegerAndDecimal + PLY_AKG_Offset1b
	defw PLY_AKG_Channel3_InvertedVolumeIntegerAndDecimal + PLY_AKG_Offset1b + 1
;----------------------
	defw PLY_AKG_CHANNEL1_PITCHTABLE_END+1
    defw PLY_AKG_CHANNEL1_PITCHTABLE_END+2
    defw PLY_AKG_CHANNEL2_PITCHTABLE_END+1
    defw PLY_AKG_CHANNEL2_PITCHTABLE_END+2
    defw PLY_AKG_CHANNEL3_PITCHTABLE_END+1
    defw PLY_AKG_CHANNEL3_PITCHTABLE_END+2
;----------------------
    defw PLY_AKG_RETRIG+1

PLY_AKG_INITTABLE0_END:     ;demo $C0A0

PLY_AKG_INITTABLE1:         ;demo $C0A4
	defw PLY_AKG_PatternDecreasingHeight+1
    defw PLY_AKG_TICKDECREASINGCOUNTER+1

PLY_AKG_INITTABLE1_END:     ;demo $C0A4

PLY_AKG_INITTABLEORA:       ;demo $C0A4
	defw PLY_AKG_CHANNEL1_ISVOLUMESLIDE
    defw PLY_AKG_CHANNEL2_ISVOLUMESLIDE
    defw PLY_AKG_CHANNEL3_ISVOLUMESLIDE
    defw PLY_AKG_CHANNEL1_ISARPEGGIOTABLE
    defw PLY_AKG_CHANNEL2_ISARPEGGIOTABLE
    defw PLY_AKG_CHANNEL3_ISARPEGGIOTABLE
    defw PLY_AKG_CHANNEL1_ISPITCHTABLE
    defw PLY_AKG_CHANNEL2_ISPITCHTABLE
    defw PLY_AKG_CHANNEL3_ISPITCHTABLE
    defw PLY_AKG_CHANNEL1_ISPITCH
    defw PLY_AKG_CHANNEL2_ISPITCH
    defw PLY_AKG_CHANNEL3_ISPITCH

PLY_AKG_InitTableOrA_End:   ;demo $C0BC

PUBLIC _PLY_AKG_STOP
_PLY_AKG_STOP:				;demo $C0BC
	ld (PLY_AKG_PSGREG13_END+1),sp	;< notice stack
	;Only useful because the PLY_AKG_SendPSGRegisters
	;restores it at the end.
	;All the volumes to 0, all sound/noise channels stopped.

    xor a		            ;demo $C0C0
    ld l,a
    ld h,a
    ld (PLY_AKG_PSGREG8),a
    ld (PLY_AKG_PSGREG9),hl
    ld a, 0x3F		;%00111111 = 63
    jp PLY_AKG_SENDPSGREGISTERS	;$C0CB

;Plays one frame of the subsong.
PUBLIC _PLY_AKG_Play        ;demo $C0CE
_PLY_AKG_Play:
	ld (PLY_AKG_PSGREG13_END+1),sp
    xor a
    ld (PLY_AKG_EVENT),a

;Decreases the tick counter. If 0 is reached, a new line must be read.
PLY_AKG_TICKDECREASINGCOUNTER:
	ld a, 1                	;demo $C0D6
    dec a
    jp nz,PLY_AKG_SETSPEEDBEFOREPLAYSTREAMS
;Jumps if there is no new line: continues playing the sound stream.

;New line! Is the Pattern ended? Not as long as there are lines to read.
PLY_AKG_PatternDecreasingHeight:
	ld a, 1                 ;demo $C0DC

    dec a
    jr nz,PLY_AKG_SetCurrentLineBeforeReadLine
;Jumps if the pattern isn't ended.
;New pattern!
;Reads the Linker. This is called at the start of the song, or at the end of every position.

PLY_AKG_READLINKER:
PLY_AKG_READLINKER_PTLINKER:
	ld sp, 0                ;demo $C0E1

;Reads the address of each Track.
    pop hl
    ld a,l
    or h
    jr nz,PLY_AKG_READLINKER_NOLOOP
	;Reached the end of the song?

;End of the song.
    pop hl	;HL is the loop address.
    ld sp,hl
    pop hl
;Reads once again the address of Track 1, in the pattern looped to.

PLY_AKG_READLINKER_NOLOOP:	;demo $C0EC
	ld (PLY_AKG_CHANNEL1_READTRACK+1),hl
    pop hl
    ld (PLY_AKG_CHANNEL2_READTRACK+1),hl
    pop hl
    ld (PLY_AKG_CHANNEL3_READTRACK+1),hl
;Reads the address of the LinkerBlock.
    pop hl
    ld (PLY_AKG_READLINKER+1),sp
    ld sp,hl

;Reads the LinkerBlock. SP = LinkerBlock.
;Reads the height and transposition1.
    pop hl
    ld c,l
;Stores the pattern height, used below.

    ld a,h
    ld (PLY_AKG_CHANNEL1_AFTERNOTEKNOWN+1),a
    pop hl
    ld a,l
    ld (PLY_AKG_CHANNEL2_AFTERNOTEKNOWN+1),a
    ld a,h
    ld (PLY_AKG_CHANNEL3_AFTERNOTEKNOWN+1),a
    pop hl
    ld (PLY_AKG_SPEEDTRACK_PTTRACK+1),hl
    pop hl
    ld (PLY_AKG_EVENTTRACK_PTTRACK+1),hl
    xor a		            ;$C114
    ld (PLY_AKG_ReadLine+1),a
    ld (PLY_AKG_SPEEDTRACK_END+1),a
    ld (PLY_AKG_EVENTTRACK_END+1),a
    ld (PLY_AKG_CHANNEL1_READCELLEND+1),a
    ld (PLY_AKG_CHANNEL2_READCELLEND+1),a
    ld a,c		            ;$C124

							;demo $C125
PLY_AKG_SetCurrentLineBeforeReadLine:
	ld (PLY_AKG_PatternDecreasingHeight + PLY_AKG_Offset1b),a

	;Reads the new line (notes, effects, Special Tracks, etc.).

PLY_AKG_ReadLine:			;demo $C128
        ;Reads the Speed Track.

PLY_AKG_SPEEDTRACK_WAITCOUNTER:
	ld a, 0 		        ;demo $C128
    sub 1
    jr nc,PLY_AKG_SPEEDTRACK_MUSTWAIT
;Jump if there are still lines to wait.
;No more lines to wait. Reads a new data.
;It may be an event value or a wait value.

PLY_AKG_SPEEDTRACK_PTTRACK:	;demo $C12E
	ld hl, 0
    ld a,(hl)
    inc hl
    srl a
    jr c,PLY_AKG_SPEEDTRACK_STOREPOINTERANDWAITCOUNTER
    jr nz,PLY_AKG_SPEEDTRACK_NORMALVALUE
    ld a,(hl)
    inc hl

                            ;demo $C13B
PLY_AKG_SPEEDTRACK_NORMALVALUE:
	ld (PLY_AKG_CHANNEL3_READCELLEND+1),a
    xor a

                            ;demo $C13F
PLY_AKG_SPEEDTRACK_STOREPOINTERANDWAITCOUNTER:
	ld (PLY_AKG_SPEEDTRACK_PTTRACK+1),hl

                            ;demo $C142
PLY_AKG_SPEEDTRACK_MUSTWAIT:
	ld (PLY_AKG_ReadLine+1),a

                            ;demo $C145
PLY_AKG_SPEEDTRACK_END:

                            ;demo $C145
PLY_AKG_EVENTTRACK_WAITCOUNTER:
	ld a, 0
    sub 1
    jr nc,PLY_AKG_EVENTTRACK_MUSTWAIT

                            ;demo $C14B
PLY_AKG_EVENTTRACK_PTTRACK:
	ld hl, 0
    ld a,(hl)
    inc hl
    srl a	;Bit 0: wait?
    jr c,PLY_AKG_EVENTTRACK_STOREPOINTERANDWAITCOUNTER
	;Jump if wait: A is the wait value.

	;Value found. If 0, escape value (rare).
    jr nz,PLY_AKG_EVENTTRACK_NORMALVALUE
	;Escape code. Reads the right value.
    ld a,(hl)
    inc hl

                            ;demo $C158
PLY_AKG_EVENTTRACK_NORMALVALUE:
	ld (PLY_AKG_EVENT),a
    xor a	;Next time, a new value is read.

                            ;demo $C15C
PLY_AKG_EVENTTRACK_STOREPOINTERANDWAITCOUNTER:
	ld (PLY_AKG_EVENTTRACK_PTTRACK+1),hl

                            ;demo $C15F
PLY_AKG_EVENTTRACK_MUSTWAIT:
	ld (PLY_AKG_SPEEDTRACK_END+1),a

                            ;demo $C162
PLY_AKG_EVENTTRACK_END:

                            ;demo $C162
PLY_AKG_CHANNEL1_WAITCOUNTER:
	ld a, 0	;Lines to wait?
    sub 1
    jr c,PLY_AKG_CHANNEL1_READTRACK
    ld (PLY_AKG_EVENTTRACK_END+1),a	;Still some lines to wait.
    jp PLY_AKG_CHANNEL1_READCELLEND

                            ;demo $C16E
PLY_AKG_CHANNEL1_READTRACK:

                            ;demo $C16E
PLY_AKG_CHANNEL1_PTTRACK:
	ld hl, 0	;Points on the Cell to read.
;Reads note data. It can be a note, a wait...
    ld c,(hl)	;C = data (b5-0) + effect? (b6) + new Instrument? (b7).
    inc hl
    ld a,c
    and %111111;63 ;%111111	;A = data.
    cp  60 
;0-59: note. "cp" is preferred to "sub" so that the "note" branch (the slowest) is note-ready.

    jr c,PLY_AKG_CHANNEL1_NOTE
    sub 60 
    jp z,PLY_AKG_CHANNEL1_MAYBEEFFECTS
;60 = no note, but maybe effects.

    dec a
    jr z,PLY_AKG_CHANNEL1_WAIT	;61 = wait, no effect.
    dec a
    jr z,PLY_AKG_CHANNEL1_SMALLWAIT
;62 = small wait, no effect.
;63 = escape code for note, maybe effects.
;Reads the note in the next byte (HL has already been incremented).
    ld a,(hl)
    inc hl
    jr PLY_AKG_CHANNEL1_AFTERNOTEKNOWN

                            ;demo $C189
PLY_AKG_CHANNEL1_SMALLWAIT:
	ld a,c	;Uses bit 6/7 to indicate how many lines to wait.
    rlca
    rlca
    and 3
    inc a	;This wait start at 2 lines, to 5.
    ld (PLY_AKG_EVENTTRACK_END+1),a
    jr PLY_AKG_CHANNEL1_BEFOREEND_STORECELLPOINTER

                            ;demo $C194
PLY_AKG_CHANNEL1_WAIT:
	ld a,(hl)
;Reads the wait value on the next byte (HL has already been incremented).
    ld (PLY_AKG_EVENTTRACK_END+1),a
    inc hl
    jr PLY_AKG_CHANNEL1_BEFOREEND_STORECELLPOINTER
;Little subcode put here, called just below. A bit dirty, but avoids long jump.

                            ;demo $$C19B
PLY_AKG_CHANNEL1_SAMEINSTRUMENT:
;No new instrument. The instrument pointer must be reset.

                            ;demo $$C19B
PLY_AKG_CHANNEL1_PTBASEINSTRUMENT:
	ld de, 0
    ld (PLY_AKG_CHANNEL1_PTINSTRUMENT+1),de
    jr PLY_AKG_CHANNEL1_AFTERINSTRUMENT
;A note has been found, plus maybe an Instrument and effects. A = note. C = still has the New Instrument/Effects flags.

                            ;demo $C1A4
PLY_AKG_CHANNEL1_NOTE:
;Declares this only for the first channel, else refers to it.

                            ;demo $C1A4
PLY_AKG_BASENOTEINDEX:
	add a, 0
	;The encoded note is only from a 4 octave range, but the first note depends on he best window, determined by the song generator.

                            ;demo $C1A6
PLY_AKG_CHANNEL1_AFTERNOTEKNOWN:

                            ;demo $C1A6
PLY_AKG_CHANNEL1_TRANSPOSITION:
	add a, 0	;Adds the Track transposition.
    ld (PLY_AKG_CHANNEL1_TRACKNOTE+1),a

;HL = next data. C = data byte.
    rl c
    jr nc,PLY_AKG_CHANNEL1_SAMEINSTRUMENT
;Gets the new Instrument.
    ld a,(hl)
    inc hl
    exx
;Declares this only for the first channel, else refers to it.
    ld l,a
    ld h, 0
    add hl,hl

                            ;demo $C1B6
PLY_AKG_INSTRUMENTSTABLE:
	ld de, 0
	;Points on the Instruments table of the music (set on song initialization).

    add hl,de
    ld sp,hl
    pop hl
    ld a,(hl)	;Gets the speed.
    inc hl		;No need to store an "original speed" if "force instrument speed" effect is not used.

    ld (PLY_AKG_CHANNEL1_INSTRUMENTORIGINALSPEED+1),a
    ld (PLY_AKG_CHANNEL1_PTINSTRUMENT+1),hl
    ld (PLY_AKG_CHANNEL1_SAMEINSTRUMENT+1),hl
	;Useful when playing another note with the same instrument.
    exx

                            ;demo $C1C8
PLY_AKG_CHANNEL1_AFTERINSTRUMENT:
;There is a new note. The instrument pointer has already been reset.
;-------------------------------------------------------
;Instrument number is set.
;Arpeggio and Pitch Table are reset.

;HL must be preserved!
;But it is faster to use HL than DE when storing 16 bits value.
;So it is stored in DE for now.
	ex de,hl

;The track pitch and glide, instrument step are reset.
    xor a
    ld l,a
    ld h,a
    ld (PLY_AKG_CHANNEL1_PITCHTABLE_END+1),hl
    ld (PLY_AKG_CHANNEL1_ARPEGGIOTABLECURRENTSTEP+1),a
    ld (PLY_AKG_CHANNEL1_PITCHTABLECURRENTSTEP+1),a
    ld (PLY_AKG_CHANNEL1_INSTRUMENTSTEP+2),a
;If the "force instrument speed" effect is used, the instrument speed must be reset to its original value.

                            ;demo $C1D8
PLY_AKG_CHANNEL1_INSTRUMENTORIGINALSPEED:
	ld a, 0
    ld (PLY_AKG_CHANNEL1_INSTRUMENTSPEED+1),a
    ld a, 183 
    ld (PLY_AKG_CHANNEL1_ISPITCH),a
;Resets the speed of the Arpeggio and the Pitch.
    ld a,(PLY_AKG_CHANNEL1_ARPEGGIOBASESPEED)
    ld (PLY_AKG_CHANNEL1_ARPEGGIOTABLESPEED),a
    ld a,(PLY_AKG_CHANNEL1_PITCHBASESPEED)
    ld (PLY_AKG_CHANNEL1_PITCHTABLESPEED),a
    ld hl,(PLY_AKG_CHANNEL1_ARPEGGIOTABLEBASE)
;Points to the first value of the Arpeggio.
    ld (PLY_AKG_CHANNEL1_ARPEGGIOTABLE+1),hl
    ld hl,(PLY_AKG_CHANNEL1_PITCHTABLEBASE)
;Points to the first value of the Pitch.
    ld (PLY_AKG_CHANNEL1_PITCHTABLE+1),hl
    ex de,hl
    rl c
    jp c,PLY_AKG_CHANNEL1_READEFFECTS
;No effects. Nothing more to read for this cell.

                            ;demo $C200
PLY_AKG_CHANNEL1_BEFOREEND_STORECELLPOINTER:
	ld (PLY_AKG_CHANNEL1_READTRACK+1),hl

                            ;demo $C203
PLY_AKG_CHANNEL1_READCELLEND:

                            ;demo $C203
PLY_AKG_CHANNEL2_WAITCOUNTER:
	ld a, 0	;Lines to wait?
    sub 1
    jr c,PLY_AKG_CHANNEL2_READTRACK
    ld (PLY_AKG_CHANNEL1_READCELLEND+1),a	;Still some lines to wait.
    jp PLY_AKG_CHANNEL2_READCELLEND

                            ;demo $C20F
PLY_AKG_CHANNEL2_READTRACK:

                            ;demo $C20F
PLY_AKG_CHANNEL2_PTTRACK:
	ld hl, 0	;Points on the Cell to read.
;Reads note data. It can be a note, a wait...
    ld c,(hl)	;C = data (b5-0) + effect? (b6) + new Instrument? (b7).
    inc hl
    ld a,c
    and %111111	;63 ;%111111	;A = data.
    cp 60 
;0-59: note. "cp" is preferred to "sub" so that the "note" branch (the slowest) is note-ready.

    jr c,PLY_AKG_CHANNEL2_NOTE
    sub 60 
    jp z,PLY_AKG_CHANNEL1_READEFFECTSEND
;60 = no note, but maybe effects.

    dec a
    jr z,PLY_AKG_CHANNEL2_WAIT	;61 = wait, no effect.
    dec a
    jr z,PLY_AKG_CHANNEL2_SMALLWAIT
;62 = small wait, no effect.
;63 = escape code for note, maybe effects.
;Reads the note in the next byte (HL has already been incremented).
    ld a,(hl)
    inc hl
    jr PLY_AKG_CHANNEL2_AFTERNOTEKNOWN

                            ;demo $C22A
;Small wait, no effect.
PLY_AKG_CHANNEL2_SMALLWAIT:
	ld a,c	;Uses bit 6/7 to indicate how many lines to wait.
    rlca
    rlca
    and 3
    inc a	;This wait start at 2 lines, to 5.
    ld (PLY_AKG_CHANNEL1_READCELLEND+1),a
    jr PLY_AKG_CHANNEL2_BEFOREEND_STORECELLPOINTER

                            ;demo  $C235
PLY_AKG_CHANNEL2_WAIT:
	ld a,(hl)
;Reads the wait value on the next byte (HL has already been incremented).
    ld (PLY_AKG_CHANNEL1_READCELLEND+1),a
    inc hl
    jr PLY_AKG_CHANNEL2_BEFOREEND_STORECELLPOINTER
;Little subcode put here, called just below. A bit dirty, but avoids long jump.

                            ;demo $C23C
PLY_AKG_CHANNEL2_SAMEINSTRUMENT:
;No new instrument. The instrument pointer must be reset.

                            ;demo $C23C
PLY_AKG_CHANNEL2_PTBASEINSTRUMENT:
	ld de, 0
    ld (PLY_AKG_CHANNEL2_PTINSTRUMENT+1),de
    jr PLY_AKG_CHANNEL2_AFTERINSTRUMENT
;A note has been found, plus maybe an Instrument and effects. A = note. C = still has the New Instrument/Effects flags.

                            ;demo $C245
PLY_AKG_CHANNEL2_NOTE:
;Declares this only for the first channel, else refers to it.
	ld b,a
    ld a,(PLY_AKG_CHANNEL1_NOTE+1)
    add a,b

                            ;demo $C24A
PLY_AKG_CHANNEL2_AFTERNOTEKNOWN:

                            ;demo $C24A
PLY_AKG_CHANNEL2_TRANSPOSITION:
	add a, 0	;Adds the Track transposition.
    ld (PLY_AKG_CHANNEL2_TRACKNOTE+1),a

;HL = next data. C = data byte.
    rl c
    jr nc,PLY_AKG_CHANNEL2_SAMEINSTRUMENT
;Gets the new Instrument.
    ld a,(hl)
    inc hl
    exx
;Declares this only for the first channel, else refers to it.
    ld e,a
    ld d, 0
    ld hl,(PLY_AKG_INSTRUMENTSTABLE+1)
    add hl,de
    add hl,de
    ld sp,hl
    pop hl
    ld a,(hl)
    inc hl
    ld (PLY_AKG_CHANNEL2_INSTRUMENTORIGINALSPEED+1),a
    ld (PLY_AKG_CHANNEL2_PTINSTRUMENT+1),hl
    ld (PLY_AKG_CHANNEL2_SAMEINSTRUMENT+1),hl
    exx

                            ;demo $C26C
PLY_AKG_CHANNEL2_AFTERINSTRUMENT:
;There is a new note. The instrument pointer has already been reset.
;-------------------------------------------------------------------
;Instrument number is set.
;Arpeggio and Pitch Table are reset.

;HL must be preserved!
;But it is faster to use HL than DE when storing 16 bits value.
;So it is stored in DE for now.
	ex de,hl

;The track pitch and glide, instrument step are reset.
    xor a
    ld l,a
    ld h,a
    ld (PLY_AKG_CHANNEL2_PITCHTABLE_END+1),hl
    ld (PLY_AKG_CHANNEL2_ARPEGGIOTABLECURRENTSTEP+1),a
    ld (PLY_AKG_CHANNEL2_PITCHTABLECURRENTSTEP+1),a
    ld (PLY_AKG_CHANNEL2_INSTRUMENTSTEP+2),a
;If the "force instrument speed" effect is used, the instrument speed must be reset to its original value.

                            ;demo $C27C
PLY_AKG_CHANNEL2_INSTRUMENTORIGINALSPEED:
	ld a, 0
    ld (PLY_AKG_CHANNEL2_INSTRUMENTSPEED+1),a
    ld a,183 
    ld (PLY_AKG_CHANNEL2_ISPITCH),a
;Resets the speed of the Arpeggio and the Pitch.
    ld a,(PLY_AKG_CHANNEL2_ARPEGGIOBASESPEED)
    ld (PLY_AKG_CHANNEL2_ARPEGGIOTABLESPEED),a
    ld a,(PLY_AKG_CHANNEL2_PITCHBASESPEED)
    ld (PLY_AKG_CHANNEL2_PITCHTABLESPEED),a
    ld hl,(PLY_AKG_CHANNEL2_ARPEGGIOTABLEBASE)
;Points to the first value of the Arpeggio.
    ld (PLY_AKG_CHANNEL2_ARPEGGIOTABLE+1),hl
    ld hl,(PLY_AKG_CHANNEL2_PITCHTABLEBASE)
;Points to the first value of the Pitch.
    ld (PLY_AKG_CHANNEL2_PITCHTABLE+1),hl
    ex de,hl
    rl c
    jp c,PLY_AKG_CHANNEL2_READEFFECTS
;No effects. Nothing more to read for this cell.

                            ;demo $C2A4
PLY_AKG_CHANNEL2_BEFOREEND_STORECELLPOINTER:
	ld (PLY_AKG_CHANNEL2_READTRACK+1),hl

                            ;demo $C2A7
PLY_AKG_CHANNEL2_READCELLEND:

                            ;demo $C2A7
PLY_AKG_CHANNEL3_WAITCOUNTER:
	ld a, 0	;Lines to wait?
    sub 1
    jr c,PLY_AKG_CHANNEL3_READTRACK
    ld (PLY_AKG_CHANNEL2_READCELLEND+1),a	;Still some lines to wait.
    jp PLY_AKG_CHANNEL3_READCELLEND

                            ;demo $C2B3
PLY_AKG_CHANNEL3_READTRACK:

                            ;demo $C2B3
PLY_AKG_CHANNEL3_PTTRACK:
	ld hl, 0	;Points on the Cell to read.
;Reads note data. It can be a note, a wait...
    ld c,(hl)	;C = data (b5-0) + effect? (b6) + new Instrument? (b7).
    inc hl
    ld a,c
    and %111111	;63 ;%111111	;A = data.
    cp 60 
;0-59: note. "cp" is preferred to "sub" so that the "note" branch (the slowest) is note-ready.

    jr c,PLY_AKG_CHANNEL3_NOTE
    sub 60 
    jp z,PLY_AKG_CHANNEL2_READEFFECTSEND
;60 = no note, but maybe effects.

    dec a
    jr z,PLY_AKG_CHANNEL3_WAIT	;61 = wait, no effect.
    dec a
    jr z,PLY_AKG_CHANNEL3_SMALLWAIT
;62 = small wait, no effect.
;63 = escape code for note, maybe effects.
;Reads the note in the next byte (HL has already been incremented).
    ld a,(hl)
    inc hl
    jr PLY_AKG_CHANNEL3_AFTERNOTEKNOWN

                            ;demo $C2CE
;Small wait, no effect.
PLY_AKG_CHANNEL3_SMALLWAIT:
	ld a,c	;Uses bit 6/7 to indicate how many lines to wait.
    rlca
    rlca
    and 3
    inc a	;This wait start at 2 lines, to 5.
    ld (PLY_AKG_CHANNEL2_READCELLEND+1),a
    jr PLY_AKG_CHANNEL3_BEFOREEND_STORECELLPOINTER

                            ;demo $C2D9
PLY_AKG_CHANNEL3_WAIT:
	ld a,(hl)
;Reads the wait value on the next byte (HL has already been incremented).
    ld (PLY_AKG_CHANNEL2_READCELLEND+1),a
    inc hl
    jr PLY_AKG_CHANNEL3_BEFOREEND_STORECELLPOINTER
;Little subcode put here, called just below. A bit dirty, but avoids long jump.

                            ;demo $C2E0
PLY_AKG_CHANNEL3_SAMEINSTRUMENT:
;No new instrument. The instrument pointer must be reset.

                            ;demo $C2E0
PLY_AKG_CHANNEL3_PTBASEINSTRUMENT:
	ld de, 0
    ld (PLY_AKG_CHANNEL3_PTINSTRUMENT+1),de
    jr PLY_AKG_CHANNEL3_AFTERINSTRUMENT
;A note has been found, plus maybe an Instrument and effects. A = note. C = still has the New Instrument/Effects flags.

                            ;demo $C2E9
PLY_AKG_CHANNEL3_NOTE:
;Declares this only for the first channel, else refers to it.
	ld b,a
    ld a,(PLY_AKG_CHANNEL1_NOTE+1)
    add a,b

                            ;demo $C2EE
PLY_AKG_CHANNEL3_AFTERNOTEKNOWN:

                            ;demo $C2EE
PLY_AKG_CHANNEL3_TRANSPOSITION:
	add a, 0	;Adds the Track transposition.
    ld (PLY_AKG_CHANNEL3_TRACKNOTE+1),a

;HL = next data. C = data byte.
    rl c
    jr nc,PLY_AKG_CHANNEL3_SAMEINSTRUMENT
;Gets the new Instrument.
    ld a,(hl)
    inc hl
    exx
;Declares this only for the first channel, else refers to it.
    ld e,a
    ld d, 0
    ld hl,(PLY_AKG_INSTRUMENTSTABLE+1)
    add hl,de
    add hl,de
    ld sp,hl
    pop hl
    ld a,(hl)
    inc hl
    ld (PLY_AKG_CHANNEL3_INSTRUMENTORIGINALSPEED+1),a
    ld (PLY_AKG_CHANNEL3_PTINSTRUMENT+1),hl
    ld (PLY_AKG_CHANNEL3_SAMEINSTRUMENT+1),hl
    exx

                            ;demo $C310
PLY_AKG_CHANNEL3_AFTERINSTRUMENT:
;There is a new note. The instrument pointer has already been reset.
;---------------------------------------------------------
;Instrument number is set.
;Arpeggio and Pitch Table are reset.

;HL must be preserved!
;But it is faster to use HL than DE when storing 16 bits value.
;So it is stored in DE for now.
	ex de,hl

;The track pitch and glide, instrument step are reset.
    xor a
    ld l,a
    ld h,a
    ld (PLY_AKG_CHANNEL3_PITCHTABLE_END+1),hl
    ld (PLY_AKG_CHANNEL3_ARPEGGIOTABLECURRENTSTEP+1),a
    ld (PLY_AKG_CHANNEL3_PITCHTABLECURRENTSTEP+1),a
    ld (PLY_AKG_CHANNEL3_INSTRUMENTSTEP+2),a
;If the "force instrument speed" effect is used, the instrument speed must be reset to its original value.

                            ;demo $C320
PLY_AKG_CHANNEL3_INSTRUMENTORIGINALSPEED:
	ld a, 0
    ld (PLY_AKG_CHANNEL3_INSTRUMENTSPEED+1),a
    ld a, 183 
    ld (PLY_AKG_CHANNEL3_ISPITCH),a
;Resets the speed of the Arpeggio and the Pitch.
    ld a,(PLY_AKG_CHANNEL3_ARPEGGIOBASESPEED)
    ld (PLY_AKG_CHANNEL3_ARPEGGIOTABLESPEED),a
    ld a,(PLY_AKG_CHANNEL3_PITCHBASESPEED)
    ld (PLY_AKG_CHANNEL3_PITCHTABLESPEED),a
    ld hl,(PLY_AKG_CHANNEL3_ARPEGGIOTABLEBASE)
;Points to the first value of the Arpeggio.
    ld (PLY_AKG_CHANNEL3_ARPEGGIOTABLE+1),hl
    ld hl,(PLY_AKG_CHANNEL3_PITCHTABLEBASE)
;Points to the first value of the Pitch.
    ld (PLY_AKG_CHANNEL3_PITCHTABLE+1),hl
    ex de,hl
    rl c
    jp c,PLY_AKG_CHANNEL3_READEFFECTS
;No effects. Nothing more to read for this cell.

                            ;demo $C348
PLY_AKG_CHANNEL3_BEFOREEND_STORECELLPOINTER:
	ld (PLY_AKG_CHANNEL3_READTRACK+1),hl

                            ;demo $C34B
PLY_AKG_CHANNEL3_READCELLEND:

                            ;demo $C34B
PLY_AKG_CURRENTSPEED:
	ld a, 0

                            ;demo $C34D
PLY_AKG_SETSPEEDBEFOREPLAYSTREAMS:
	ld (PLY_AKG_TICKDECREASINGCOUNTER+1),a

                            ;demo $C352
PLY_AKG_CHANNEL1_INVERTEDVOLUMEINTEGER: equ $ +2

                            ;demo $C350
PLY_AKG_Channel1_InvertedVolumeIntegerAndDecimal:
	ld hl, 0

                            ;demo $C353
PLY_AKG_CHANNEL1_ISVOLUMESLIDE:
	or a
;Is there a Volume Slide ? Automodified. SCF if yes, OR A if not.
    jr nc,PLY_AKG_CHANNEL1_VOLUMESLIDE_END

                            ;demo $C356
PLY_AKG_CHANNEL1_VOLUMESLIDEVALUE:
	ld de, 0
;May be negative.
    add hl,de
;Went below 0?
    bit 7,h
    jr z,PLY_AKG_CHANNEL1_VOLUMENOTOVERFLOW
    ld h, 0
;No need to set L to 0... Shouldn't make any hearable difference.
    jr PLY_AKG_CHANNEL1_VOLUMESETAGAIN

                            ;demo $C362
PLY_AKG_CHANNEL1_VOLUMENOTOVERFLOW:
;Higher than 15?
	ld a,h
    cp 16 
    jr c,PLY_AKG_CHANNEL1_VOLUMESETAGAIN
    ld h, 15 

                            ;demo $C369
PLY_AKG_CHANNEL1_VOLUMESETAGAIN:
	ld (PLY_AKG_Channel1_InvertedVolumeIntegerAndDecimal+1),hl

                            ;demo $C36C
PLY_AKG_CHANNEL1_VOLUMESLIDE_END:
	ld a,h
    ld (PLY_AKG_CHANNEL1_GENERATEDCURRENTINVERTEDVOLUME+1),a
    ld c, 0

;Use Arpeggio table? OUT: C = value.
                            ;demo $C372
;----------------------------------------
PLY_AKG_CHANNEL1_ISARPEGGIOTABLE:
;Is there an arpeggio table? Automodified. SCF if yes, OR A if not.
	or a
    jr nc,PLY_AKG_CHANNEL1_ARPEGGIOTABLE_END

                            ;demo $C375
PLY_AKG_CHANNEL1_ARPEGGIOTABLE:
	ld hl, 0
;Points on the data, after the header.
    ld a,(hl)
    cp 128	;Loop?
    jr nz,PLY_AKG_CHANNEL1_ARPEGGIOTABLE_AFTERLOOPTEST
;Loop. Where to?
    inc hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld a,(hl)
;Reads the value. Safe, we know there is no loop here.

;HL = pointer on what is follows.
;A = value to use.
                            ;demo $C383
PLY_AKG_CHANNEL1_ARPEGGIOTABLE_AFTERLOOPTEST:
	ld c,a
;Checks the speed. If reached, the pointer can be saved to read a new value next time.

    ld a,(PLY_AKG_CHANNEL1_ARPEGGIOTABLESPEED)
    ld d,a

                            ;demo $C388
PLY_AKG_CHANNEL1_ARPEGGIOTABLECURRENTSTEP:
	ld a, 0
    inc a
    cp d	;From 1 to 256.
    jr c,PLY_AKG_CHANNEL1_ARPEGGIOTABLE_BEFOREEND_SAVESTEP
;C, not NZ, because the current step may be higher than the limit if Force Speed effect is used.
;Stores the pointer to read a new value next time.

    inc hl
    ld (PLY_AKG_CHANNEL1_ARPEGGIOTABLE+1),hl
    xor a

                            ;demo $C393
PLY_AKG_CHANNEL1_ARPEGGIOTABLE_BEFOREEND_SAVESTEP:
	ld (PLY_AKG_CHANNEL1_ARPEGGIOTABLECURRENTSTEP+1),a

                            ;demo $C396
PLY_AKG_CHANNEL1_ARPEGGIOTABLE_END:
	ld de, 0

;Use Pitch table? OUT: DE = pitch value.
;C must NOT be modified!
;-----------------------
                            ;demo $C399
PLY_AKG_CHANNEL1_ISPITCHTABLE:
	or a
;Is there an arpeggio table? Automodified. SCF if yes, OR A if not.
    jr nc,PLY_AKG_CHANNEL1_PITCHTABLE_END

                            ;demo $C39C
PLY_AKG_CHANNEL1_PITCHTABLE:
	ld sp, 0
;Points on the data, after the header.
    pop de		;Reads the value.
    pop hl		;Reads the pointer to the next value. Manages the loop automatically!

;Checks the speed. If reached, the pointer can be saved (advance in the Pitch).
    ld a,(PLY_AKG_CHANNEL1_PITCHTABLESPEED)
    ld b,a

                            ;demo $C3A5
PLY_AKG_CHANNEL1_PITCHTABLECURRENTSTEP:
	ld a, 0
    inc a
    cp b

;From 1 to 256.
    jr c,PLY_AKG_CHANNEL1_PITCHTABLE_BEFOREEND_SAVESTEP
;C, not NZ, because the current step may be higher than the limit if Force Speed effect is used.

;Advances in the Pitch.

;Pitch management. The Glide is embedded, but relies on the Pitch (Pitch can exist without Glide, but Glide can not without Pitch).
;Do NOT modify C or DE.
;--------------------------------------------------------

    ld (PLY_AKG_CHANNEL1_PITCHTABLE+1),hl
    xor a

                            ;demo $C3AF
PLY_AKG_CHANNEL1_PITCHTABLE_BEFOREEND_SAVESTEP:
	ld (PLY_AKG_CHANNEL1_PITCHTABLECURRENTSTEP+1),a

                            ;demo $C3B2
PLY_AKG_CHANNEL1_PITCHTABLE_END:

                            ;demo $C3B2
PLY_AKG_CHANNEL1_PITCH:
	ld hl, 0	;No pitch.
;Nothing to declare if ROM.
;Some dirty duplication in case there is no pitch up/down/glide. The "real" vars are a bit below.



                            ;demo $C3B5
PLY_AKG_CHANNEL1_ISPITCH:
	or a
    jr nc,PLY_AKG_CHANNEL1_PITCH_END

    defb 221
    defb 105

                            ;demo $C3BA
PLY_AKG_CHANNEL1_PITCHTRACK:
	ld bc, 0
	;Value from the user. ALWAYS POSITIVE. Does not evolve. B is always 0.
    or a

                            ;demo $C3BE
PLY_AKG_CHANNEL1_PITCHTRACKADDORSBC_16BITS:
	nop
    add hl,bc
	;WILL BE AUTOMODIFIED to add or sbc. But SBC requires 2*8 bits! Damn.

                            ;demo $C3C0
PLY_AKG_CHANNEL1_PITCHTRACKDECIMALCOUNTER:
	ld a, 0

                            ;demo $C3C3
PLY_AKG_CHANNEL1_PITCHTRACKDECIMALVALUE: equ $ +1

                            ;demo $C3C2
PLY_AKG_CHANNEL1_PITCHTRACKDECIMALINSTR:
	add a, 0
;Value from the user. WILL BE AUTOMODIFIED to add or sub.
    ld (PLY_AKG_CHANNEL1_PITCHTRACKDECIMALCOUNTER+1),a
    jr nc,PLY_AKG_CHANNEL1_PITCHNOCARRY

                            ;demo $C3C9
PLY_AKG_CHANNEL1_PITCHTRACKINTEGERADDORSUB:
	inc hl	;WILL BE AUTOMODIFIED to inc hl/dec hl

                            ;demo $C3CA
PLY_AKG_CHANNEL1_PITCHNOCARRY:
	ld (PLY_AKG_CHANNEL1_PITCHTABLE_END+1),hl

                            ;demo $C3CD
PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS:
;This must be placed at the any location to allow reaching the variables via IX/IY.

                            ;demo $C3CD
;Glide?
PLY_AKG_CHANNEL1_GLIDEDIRECTION:
	ld a, 0
;0 = no glide. 1 = glide/pitch up. 2 = glide/pitch down.
    or a	;Is there a Glide?
    jr z,PLY_AKG_CHANNEL1_GLIDE_END
    ld (PLY_AKG_CHANNEL1_AFTERARPEGGIOPITCHVARIABLES+1),hl
    ld c,l
    ld b,h
;Finds the period of the current note.
    ex af,af'
    ld a,(PLY_AKG_CHANNEL1_TRACKNOTE+1)
    add a,a
;Encoded on 7 bits, so no problem.
    ld l,a
    ex af,af'
    ld h, 0
    ld sp, PLY_AKG_PERIODTABLE
    add hl,sp
    ld sp,hl
    pop hl		;HL = current note period.
    dec sp
    dec sp
;We will need this value if the glide is over, it is faster to reuse the stack.
    add hl,bc
;HL is now the current period (note period + track pitch).

                            ;demo $C3E9
PLY_AKG_CHANNEL1_GLIDETOREACH:
	ld bc, 0
;Period to reach (note given by the user, converted to period).

;Have we reached the glide destination?
;Depends on the direction.
    rra		;If 1, the carry is set. If 2, no.
    jr nc,PLY_AKG_CHANNEL1_GLIDEDOWNCHECK

;Glide up. Check.
;The glide period should be lower than the current pitch.
    or a
    sbc hl,bc
    jr nc,PLY_AKG_CHANNEL1_AFTERARPEGGIOPITCHVARIABLES
;If not reached yet, continues the pitch.

    jr PLY_AKG_CHANNEL1_GLIDEOVER

                            ;demo $C3F6
PLY_AKG_CHANNEL1_GLIDEDOWNCHECK:
;The glide period should be higher than the current pitch.
	sbc hl,bc	;No carry, no need to remove it.
    jr c,PLY_AKG_CHANNEL1_AFTERARPEGGIOPITCHVARIABLES
;If not reached yet, continues the pitch.

                            ;demo $C3FA
PLY_AKG_CHANNEL1_GLIDEOVER:
;The glide is over. However, it may be over, so we can't simply use the current pitch period. We have to set the exact needed value.
	ld l,c
    ld h,b
    pop bc
    or a
    sbc hl,bc
    ld (PLY_AKG_CHANNEL1_PITCHTABLE_END+1),hl
    ld a, 183
    ld (PLY_AKG_CHANNEL1_ISPITCH),a
;Skips the HL restoration, the one we have is fine and will give us the right pitch to use.
    jr PLY_AKG_CHANNEL1_GLIDE_END

                            ;demo $C40A
PLY_AKG_CHANNEL1_ARPEGGIOTABLESPEED:
	defb 0

                            ;demo $C40B
PLY_AKG_CHANNEL1_ARPEGGIOBASESPEED:
	defb 0

                            ;demo $C40C
PLY_AKG_CHANNEL1_ARPEGGIOTABLEBASE:
	defb 0
    defb 0

                            ;demo $C40E
PLY_AKG_CHANNEL1_PITCHTABLESPEED:
	defb 0

                            ;demo $C40F
PLY_AKG_CHANNEL1_PITCHBASESPEED:
	defb 0

                            ;demo $C410
PLY_AKG_CHANNEL1_PITCHTABLEBASE:
	defb 0
    defb 0

                            ;demo $C412
PLY_AKG_CHANNEL1_AFTERARPEGGIOPITCHVARIABLES:

                            ;demo $C412
PLY_AKG_CHANNEL1_GLIDE_BEFOREEND:

                            ;demo $C412
PLY_AKG_CHANNEL1_GLIDE_SAVEHL:
	ld hl, 0	;Restores HL.

                            ;demo $C415
PLY_AKG_CHANNEL1_GLIDE_END:
	;defb 221
    ;defb 77
	ld c, IXL

                            ;demo $C417
PLY_AKG_CHANNEL1_PITCH_END:
	add hl,de	;Adds the Pitch Table value.
    ld (PLY_AKG_CHANNEL1_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS+1),hl
    ld a,c
    ld (PLY_AKG_CHANNEL1_GENERATEDCURRENTARPNOTE+1),a

                            ;demo $C421
PLY_AKG_CHANNEL2_INVERTEDVOLUMEINTEGER: equ $ +2

                            ;demo $C41F
PLY_AKG_Channel2_InvertedVolumeIntegerAndDecimal:
	ld hl, 0

                            ;demo $C422
PLY_AKG_CHANNEL2_ISVOLUMESLIDE:
	or a
;Is there a Volume Slide ? Automodified. SCF if yes, OR A if not.
    jr nc,PLY_AKG_CHANNEL2_VOLUMESLIDE_END

                            ;demo $C425
PLY_AKG_CHANNEL2_VOLUMESLIDEVALUE:
	ld de, 0
;May be negative.
    add hl,de
;Went below 0?
    bit 7,h
    jr z,PLY_AKG_CHANNEL2_VOLUMENOTOVERFLOW
    ld h, 0
;No need to set L to 0... Shouldn't make any hearable difference.
    jr PLY_AKG_CHANNEL2_VOLUMESETAGAIN

                            ;demo $C431
PLY_AKG_CHANNEL2_VOLUMENOTOVERFLOW:
;Higher than 15?
	ld a,h
    cp 16
    jr c,PLY_AKG_CHANNEL2_VOLUMESETAGAIN
    ld h, 15

                            ;demo $C438
PLY_AKG_CHANNEL2_VOLUMESETAGAIN:
	ld (PLY_AKG_Channel2_InvertedVolumeIntegerAndDecimal+1),hl

                            ;demo $C43B
PLY_AKG_CHANNEL2_VOLUMESLIDE_END:
	ld a,h
    ld (PLY_AKG_CHANNEL2_GENERATEDCURRENTINVERTEDVOLUME+1),a
    ld c, 0

;Use Arpeggio table? OUT: C = value.
                            ;demo $C441
;----------------------------------------
PLY_AKG_CHANNEL2_ISARPEGGIOTABLE:
;Is there an arpeggio table? Automodified. SCF if yes, OR A if not.
	or a
    jr nc,PLY_AKG_CHANNEL2_ARPEGGIOTABLE_END

                            ;demo $C444
PLY_AKG_CHANNEL2_ARPEGGIOTABLE:
	ld hl, 0
;Points on the data, after the header.
    ld a,(hl)
    cp 128		;Loop?
    jr nz,PLY_AKG_CHANNEL2_ARPEGGIOTABLE_AFTERLOOPTEST
;Loop. Where to?
    inc hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld a,(hl)
;Reads the value. Safe, we know there is no loop here.

;HL = pointer on what is follows.
;A = value to use.
                            ;demo $C452
PLY_AKG_CHANNEL2_ARPEGGIOTABLE_AFTERLOOPTEST:
	ld c,a
;Checks the speed. If reached, the pointer can be saved to read a new value next time.
    ld a,(PLY_AKG_CHANNEL2_ARPEGGIOTABLESPEED)
    ld d,a

                            ;demo $C457
PLY_AKG_CHANNEL2_ARPEGGIOTABLECURRENTSTEP:
	ld a, 0
    inc a
    cp d	;From 1 to 256.
    jr c,PLY_AKG_CHANNEL2_ARPEGGIOTABLE_BEFOREEND_SAVESTEP
;C, not NZ, because the current step may be higher than the limit if Force Speed effect is used.
;Stores the pointer to read a new value next time.

    inc hl
    ld (PLY_AKG_CHANNEL2_ARPEGGIOTABLE+1),hl
    xor a

                            ;demo $C462
PLY_AKG_CHANNEL2_ARPEGGIOTABLE_BEFOREEND_SAVESTEP:
	ld (PLY_AKG_CHANNEL2_ARPEGGIOTABLECURRENTSTEP+1),a

                            ;demo $C465
PLY_AKG_CHANNEL2_ARPEGGIOTABLE_END:
	ld de, 0

;Use Pitch table? OUT: DE = pitch value.
;C must NOT be modified!
;-----------------------
                            ;demo $C468
PLY_AKG_CHANNEL2_ISPITCHTABLE:
	or a
;Is there an arpeggio table? Automodified. SCF if yes, OR A if not.
    jr nc,PLY_AKG_CHANNEL2_PITCHTABLE_END

                            ;demo $C46B
PLY_AKG_CHANNEL2_PITCHTABLE:
	ld sp, 0
;Points on the data, after the header.
	pop de		;Reads the value.
    pop hl		;Reads the pointer to the next value. Manages the loop automatically!

;Checks the speed. If reached, the pointer can be saved (advance in the Pitch).
    ld a,(PLY_AKG_CHANNEL2_PITCHTABLESPEED)
    ld b,a

;demo $C474
PLY_AKG_CHANNEL2_PITCHTABLECURRENTSTEP:
	ld a, 0
    inc a
    cp b

;From 1 to 256.
    jr c,PLY_AKG_CHANNEL2_PITCHTABLE_BEFOREEND_SAVESTEP
;C, not NZ, because the current step may be higher than the limit if Force Speed effect is used.

;Advances in the Pitch.

;Pitch management. The Glide is embedded, but relies on the Pitch (Pitch can exist without Glide, but Glide can not without Pitch).
;Do NOT modify C or DE.
;--------------------------------------------------------
    ld (PLY_AKG_CHANNEL2_PITCHTABLE+1),hl
    xor a

;demo $C47E
PLY_AKG_CHANNEL2_PITCHTABLE_BEFOREEND_SAVESTEP:
	ld (PLY_AKG_CHANNEL2_PITCHTABLECURRENTSTEP+1),a

;demo $C481
PLY_AKG_CHANNEL2_PITCHTABLE_END:

;demo $C481
PLY_AKG_CHANNEL2_PITCH:
	ld hl, 0	;No pitch.
;Nothing to declare if ROM.
;Some dirty duplication in case there is no pitch up/down/glide. The "real" vars are a bit below.

PLY_AKG_CHANNEL2_ISPITCH:		;demo $C484
	or a
    jr nc,PLY_AKG_CHANNEL2_PITCH_END

    defb 221
    defb 105

PLY_AKG_CHANNEL2_PITCHTRACK:	;demo $C489
	ld bc, 0
;Value from the user. ALWAYS POSITIVE. Does not evolve. B is always 0.
    or a

;demo $C48D
PLY_AKG_CHANNEL2_PITCHTRACKADDORSBC_16BITS:
	nop
    add hl,bc
;WILL BE AUTOMODIFIED to add or sbc. But SBC requires 2*8 bits! Damn.

;demo $C48F
PLY_AKG_CHANNEL2_PITCHTRACKDECIMALCOUNTER:
	ld a, 0

PLY_AKG_CHANNEL2_PITCHTRACKDECIMALVALUE: equ $ +1

;demo $C491
PLY_AKG_CHANNEL2_PITCHTRACKDECIMALINSTR:
	add a, 0
;Value from the user. WILL BE AUTOMODIFIED to add or sub.
    ld (PLY_AKG_CHANNEL2_PITCHTRACKDECIMALCOUNTER+1),a
    jr nc,PLY_AKG_CHANNEL2_PITCHNOCARRY

;demo $C498
PLY_AKG_CHANNEL2_PITCHTRACKINTEGERADDORSUB:
	inc hl	;WILL BE AUTOMODIFIED to inc hl/dec hl

;demo $C499
PLY_AKG_CHANNEL2_PITCHNOCARRY:
	ld (PLY_AKG_CHANNEL2_PITCHTABLE_END+1),hl

;demo $C49C
PLY_AKG_CHANNEL2_SOUNDSTREAM_RELATIVEMODIFIERADDRESS:
;This must be placed at the any location to allow reaching the variables via IX/IY.

;Glide?
PLY_AKG_CHANNEL2_GLIDEDIRECTION:	;demo $C49C
	ld a, 0
;0 = no glide. 1 = glide/pitch up. 2 = glide/pitch down.
    or a	;Is there a Glide?
    jr z,PLY_AKG_CHANNEL2_GLIDE_END
    ld (PLY_AKG_CHANNEL2_AFTERARPEGGIOPITCHVARIABLES+1),hl
    ld c,l
    ld b,h
;Finds the period of the current note.
    ex af,af'
    ld a,(PLY_AKG_CHANNEL2_TRACKNOTE+1)
    add a,a
;Encoded on 7 bits, so no problem.
    ld l,a
    ex af,af'
    ld h, 0
    ld sp, PLY_AKG_PERIODTABLE
    add hl,sp
    ld sp,hl
    pop hl		;HL = current note period.
    dec sp
    dec sp
;We will need this value if the glide is over, it is faster to reuse the stack.
    add hl,bc
;HL is now the current period (note period + track pitch).

PLY_AKG_CHANNEL2_GLIDETOREACH:		;demo $C4B8
	ld bc, 0
;Period to reach (note given by the user, converted to period).

;Have we reached the glide destination?
;Depends on the direction.
    rra		;If 1, the carry is set. If 2, no.
    jr nc,PLY_AKG_CHANNEL2_GLIDEDOWNCHECK

;Glide up. Check.
;The glide period should be lower than the current pitch.
    or a
    sbc hl,bc
    jr nc,PLY_AKG_CHANNEL2_AFTERARPEGGIOPITCHVARIABLES

;If not reached yet, continues the pitch.
    jr PLY_AKG_CHANNEL2_GLIDEOVER
;If not reached yet, continues the pitch.

PLY_AKG_CHANNEL2_GLIDEDOWNCHECK:
;The glide period should be higher than the current pitch.
	sbc hl,bc	;No carry, no need to remove it.
    jr c,PLY_AKG_CHANNEL2_AFTERARPEGGIOPITCHVARIABLES

PLY_AKG_CHANNEL2_GLIDEOVER:
;The glide is over. However, it may be over, so we can't simply use the current pitch period. We have to set the exact needed value.
	ld l,c
    ld h,b
    pop bc
    or a
    sbc hl,bc
    ld (PLY_AKG_CHANNEL2_PITCHTABLE_END+1),hl
    ld a, 183
    ld (PLY_AKG_CHANNEL2_ISPITCH),a
;Skips the HL restoration, the one we have is fine and will give us the right pitch to use.
    jr PLY_AKG_CHANNEL2_GLIDE_END

PLY_AKG_CHANNEL2_ARPEGGIOTABLESPEED:	;demo $C4D9
	defb 0

PLY_AKG_CHANNEL2_ARPEGGIOBASESPEED:		;demo $C4DA
	defb 0

PLY_AKG_CHANNEL2_ARPEGGIOTABLEBASE:		;demo $C4DB
	defb 0
    defb 0

PLY_AKG_CHANNEL2_PITCHTABLESPEED:		;demo $C4DD
	defb 0

PLY_AKG_CHANNEL2_PITCHBASESPEED:		;demo $C4DE
	defb 0

PLY_AKG_CHANNEL2_PITCHTABLEBASE:		;demo $C4DF
	defb 0
    defb 0

;demo $C4E1
PLY_AKG_CHANNEL2_AFTERARPEGGIOPITCHVARIABLES:
PLY_AKG_CHANNEL2_GLIDE_BEFOREEND:

;demo $C4E1

PLY_AKG_CHANNEL2_GLIDE_SAVEHL:			;demo $C4E1
	ld hl, 0	;Restores HL.

PLY_AKG_CHANNEL2_GLIDE_END:				;demo $C4E4
	ld c, IXL

PLY_AKG_CHANNEL2_PITCH_END:				;demo $C4E6
	add hl,de	;Adds the Pitch Table value.
    ld (PLY_AKG_CHANNEL2_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS+1),hl
    ld a,c
    ld (PLY_AKG_CHANNEL2_GENERATEDCURRENTARPNOTE+1),a

PLY_AKG_CHANNEL3_INVERTEDVOLUMEINTEGER: equ $ +1

;demo $C4EE
PLY_AKG_Channel3_InvertedVolumeIntegerAndDecimal:
	ld hl, 0

PLY_AKG_CHANNEL3_ISVOLUMESLIDE:			;demo $C4F1
	or a
;Is there a Volume Slide ? Automodified. SCF if yes, OR A if not.
    jr nc,PLY_AKG_CHANNEL3_VOLUMESLIDE_END

PLY_AKG_CHANNEL3_VOLUMESLIDEVALUE:		;demo $C4F4
	ld de, 0
;May be negative.
    add hl,de
;Went below 0?
    bit 7,h
    jr z,PLY_AKG_CHANNEL3_VOLUMENOTOVERFLOW
    ld h, 0
;No need to set L to 0... Shouldn't make any hearable difference.
    jr PLY_AKG_CHANNEL3_VOLUMESETAGAIN

PLY_AKG_CHANNEL3_VOLUMENOTOVERFLOW:		;demo $C500
;Higher than 15?
	ld a,h
    cp 16
    jr c,PLY_AKG_CHANNEL3_VOLUMESETAGAIN
    ld h, 15

PLY_AKG_CHANNEL3_VOLUMESETAGAIN:		;demo $C507
	ld (PLY_AKG_Channel3_InvertedVolumeIntegerAndDecimal+1),hl

PLY_AKG_CHANNEL3_VOLUMESLIDE_END:		;demo $C50A
	ld a,h
    ld (PLY_AKG_CHANNEL3_GENERATEDCURRENTINVERTEDVOLUME+1),a
    ld c, 0

;Use Arpeggio table? OUT: C = value.
;----------------------------------------
PLY_AKG_CHANNEL3_ISARPEGGIOTABLE:		;demo $C510
;Is there an arpeggio table? Automodified. SCF if yes, OR A if not.
	or a
    jr nc,PLY_AKG_CHANNEL3_ARPEGGIOTABLE_END

PLY_AKG_CHANNEL3_ARPEGGIOTABLE:			;demo $C513
	ld hl, 0
;Points on the data, after the header.
    ld a,(hl)
    cp 128		;Loop?
    jr nz,PLY_AKG_CHANNEL3_ARPEGGIOTABLE_AFTERLOOPTEST
;Loop. Where to?
    inc hl
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    ld a,(hl)
;Reads the value. Safe, we know there is no loop here.

;demo $C521
PLY_AKG_CHANNEL3_ARPEGGIOTABLE_AFTERLOOPTEST:
	ld c,a
    ld a,(PLY_AKG_CHANNEL3_ARPEGGIOTABLESPEED)
    ld d,a

;demo $C526
PLY_AKG_CHANNEL3_ARPEGGIOTABLECURRENTSTEP:
	ld a, 0
    inc a
    cp d
    jr c,PLY_AKG_CHANNEL3_ARPEGGIOTABLE_BEFOREEND_SAVESTEP
    inc hl
    ld (PLY_AKG_CHANNEL3_ARPEGGIOTABLE+1),hl
    xor a

;demo $C531
PLY_AKG_CHANNEL3_ARPEGGIOTABLE_BEFOREEND_SAVESTEP:
	ld (PLY_AKG_CHANNEL3_ARPEGGIOTABLECURRENTSTEP+1),a

PLY_AKG_CHANNEL3_ARPEGGIOTABLE_END:		;demo $C534
	ld de, 0

PLY_AKG_CHANNEL3_ISPITCHTABLE:			;demo $C537
	or a
    jr nc,PLY_AKG_CHANNEL3_PITCHTABLE_END

PLY_AKG_CHANNEL3_PITCHTABLE:			;demo $C53A
	ld sp, 0
;Points on the data, after the header.
    pop de		;Reads the value.
    pop hl		;Reads the pointer to the next value. Manages the loop automatically!

;Checks the speed. If reached, the pointer can be saved (advance in the Pitch).
    ld a,(PLY_AKG_CHANNEL3_PITCHTABLESPEED)
    ld b,a

;demo $C543
PLY_AKG_CHANNEL3_PITCHTABLECURRENTSTEP:
	ld a, 0
    inc a
    cp b

;From 1 to 256.
    jr c,PLY_AKG_CHANNEL3_PITCHTABLE_BEFOREEND_SAVESTEP
;C, not NZ, because the current step may be higher than the limit if Force Speed effect is used.

;Advances in the Pitch.

;Pitch management. The Glide is embedded, but relies on the Pitch (Pitch can exist without Glide, but Glide can not without Pitch).
;Do NOT modify C or DE.
;--------------------------------------------------------
    ld (PLY_AKG_CHANNEL3_PITCHTABLE+1),hl
    xor a

;demo $C54D
PLY_AKG_CHANNEL3_PITCHTABLE_BEFOREEND_SAVESTEP:
	ld (PLY_AKG_CHANNEL3_PITCHTABLECURRENTSTEP+1),a

PLY_AKG_CHANNEL3_PITCHTABLE_END:		;demo $C550

PLY_AKG_CHANNEL3_PITCH:					;demo $C550
	ld hl, 0	;No pitch.
;Nothing to declare if ROM.
;Some dirty duplication in case there is no pitch up/down/glide. The "real" vars are a bit below.

PLY_AKG_CHANNEL3_ISPITCH:				;demo $C553
	or a
    jr nc,PLY_AKG_CHANNEL3_PITCH_END

    defb 221
    defb 105

PLY_AKG_CHANNEL3_PITCHTRACK:			;demo $C558
	ld bc, 0
;Value from the user. ALWAYS POSITIVE. Does not evolve. B is always 0.
    or a

;demo $C55C
PLY_AKG_CHANNEL3_PITCHTRACKADDORSBC_16BITS:
	nop
    add hl,bc
;WILL BE AUTOMODIFIED to add or sbc. But SBC requires 2*8 bits! Damn.

;demo $C55E
PLY_AKG_CHANNEL3_PITCHTRACKDECIMALCOUNTER:
	ld a, 0

PLY_AKG_CHANNEL3_PITCHTRACKDECIMALVALUE: equ $ +1

;demo $C560
PLY_AKG_CHANNEL3_PITCHTRACKDECIMALINSTR:
	add a, 0
;Value from the user. WILL BE AUTOMODIFIED to add or sub.
    ld (PLY_AKG_CHANNEL3_PITCHTRACKDECIMALCOUNTER+1),a
    jr nc,PLY_AKG_CHANNEL3_PITCHNOCARRY

;demo $C567
PLY_AKG_CHANNEL3_PITCHTRACKINTEGERADDORSUB:
	inc hl	;WILL BE AUTOMODIFIED to inc hl/dec hl

PLY_AKG_CHANNEL3_PITCHNOCARRY:			;demo $C568
	ld (PLY_AKG_CHANNEL3_PITCHTABLE_END+1),hl

;demo $C56B
PLY_AKG_CHANNEL3_SOUNDSTREAM_RELATIVEMODIFIERADDRESS:
;This must be placed at the any location to allow reaching the variables via IX/IY.

;Glide?
PLY_AKG_CHANNEL3_GLIDEDIRECTION:		;demo $C56B
	ld a, 0
;0 = no glide. 1 = glide/pitch up. 2 = glide/pitch down.
    or a	;Is there a Glide?
    jr z,PLY_AKG_CHANNEL3_GLIDE_END
    ld (PLY_AKG_CHANNEL3_AFTERARPEGGIOPITCHVARIABLES+1),hl
    ld c,l
    ld b,h
;Finds the period of the current note.
    ex af,af'
    ld a,(PLY_AKG_CHANNEL3_TRACKNOTE+1)
    add a,a
;Encoded on 7 bits, so no problem.
    ld l,a
    ex af,af'
    ld h, 0
    ld sp, PLY_AKG_PERIODTABLE
    add hl,sp
    ld sp,hl
    pop hl		;HL = current note period.
    dec sp
    dec sp
;We will need this value if the glide is over, it is faster to reuse the stack.
    add hl,bc
;HL is now the current period (note period + track pitch).

PLY_AKG_CHANNEL3_GLIDETOREACH:			;demo $C587
	ld bc, 0
;Period to reach (note given by the user, converted to period).

;Have we reached the glide destination?
;Depends on the direction.
    rra		;If 1, the carry is set. If 2, no.
    jr nc,PLY_AKG_CHANNEL3_GLIDEDOWNCHECK

;Glide up. Check.
;The glide period should be lower than the current pitch.
    or a
    sbc hl,bc
    jr nc,PLY_AKG_CHANNEL3_AFTERARPEGGIOPITCHVARIABLES
;If not reached yet, continues the pitch.

    jr PLY_AKG_CHANNEL3_GLIDEOVER

PLY_AKG_CHANNEL3_GLIDEDOWNCHECK:		;demo $C594
;The glide period should be higher than the current pitch.
	sbc hl,bc	;No carry, no need to remove it.
    jr c,PLY_AKG_CHANNEL3_AFTERARPEGGIOPITCHVARIABLES
;If not reached yet, continues the pitch.

PLY_AKG_CHANNEL3_GLIDEOVER:				;demo $C598
;The glide is over. However, it may be over, so we can't simply use the current pitch period. We have to set the exact needed value.
	ld l,c
    ld h,b
    pop bc
    or a
    sbc hl,bc
    ld (PLY_AKG_CHANNEL3_PITCHTABLE_END+1),hl
    ld a, 183
    ld (PLY_AKG_CHANNEL3_ISPITCH),a
;Skips the HL restoration, the one we have is fine and will give us the right pitch to use.
    jr PLY_AKG_CHANNEL3_GLIDE_END

PLY_AKG_CHANNEL3_ARPEGGIOTABLESPEED:	;demo $C5A8
	defb 0

PLY_AKG_CHANNEL3_ARPEGGIOBASESPEED:		;demo $C5A9
	defb 0

PLY_AKG_CHANNEL3_ARPEGGIOTABLEBASE:		;demo $C5AA
	defb 0
    defb 0

PLY_AKG_CHANNEL3_PITCHTABLESPEED:		;demo $C5AC
	defb 0

PLY_AKG_CHANNEL3_PITCHBASESPEED:		;demo $C5AD
	defb 0

PLY_AKG_CHANNEL3_PITCHTABLEBASE:		;demo $C5AE
	defb 0
    defb 0

;demo $C5B0
PLY_AKG_CHANNEL3_AFTERARPEGGIOPITCHVARIABLES:

PLY_AKG_CHANNEL3_GLIDE_BEFOREEND:		;demo $C5B0

PLY_AKG_CHANNEL3_GLIDE_SAVEHL:			;demo $C5B0
	ld hl, 0	;Restores HL.

PLY_AKG_CHANNEL3_GLIDE_END:				;demo $C5B3
	defb 221
    defb 77

PLY_AKG_CHANNEL3_PITCH_END:				;demo $C5B5
	add hl,de	;Adds the Pitch Table value.
    ld (PLY_AKG_CHANNEL3_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS+1),hl
    ld a,c
    ld (PLY_AKG_CHANNEL3_GENERATEDCURRENTARPNOTE+1),a
    ld sp,(PLY_AKG_PSGREG13_END+1)

;demo $C5C1
PLY_AKG_CHANNEL1_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS:

;demo $C5C1
PLY_AKG_CHANNEL1_GENERATEDCURRENTPITCH:
	ld hl, 0
;The pitch to add to the real note, according to the Pitch Table + Pitch/Glide effect.

PLY_AKG_CHANNEL1_TRACKNOTE:				;demo $C5C4
	ld a, 0

;demo $C5C6
PLY_AKG_CHANNEL1_GENERATEDCURRENTARPNOTE:
	add a, 0
    ld e,a
    ld d, 0
    exx

PLY_AKG_CHANNEL1_INSTRUMENTSTEP:		;demo $C5CC
	ld IYL, 0

PLY_AKG_CHANNEL1_PTINSTRUMENT:			;demo $C5CF
	ld hl, 0	;Instrument data to read (past the header).

										;demo $C5D2
PLY_AKG_CHANNEL1_GENERATEDCURRENTINVERTEDVOLUME:
;ld de,%11100000 * 256 + 15
;R7, shift twice TO THE LEFT. By default, the noise is cut (111), the sound is on (most usual case).

	ld de,%11100000 * 256 + 15
	;ld de,#57359 ;possible error in converting source!	
;ld de,%11100000 * 256 + 15

    call PLY_AKG_READINSTRUMENTCELL

	ld a, IYL
    inc a

PLY_AKG_CHANNEL1_INSTRUMENTSPEED:		;demo $C5DB
	cp 0
    jr c,PLY_AKG_CHANNEL1_SETINSTRUMENTSTEP
;Checks C, not only NZ because since the speed can be changed via an effect, the step can get beyond the limit, this must be taken in account.
;The speed is reached. We can go to the next line on the next frame.

    ld (PLY_AKG_CHANNEL1_PTINSTRUMENT+1),hl
    xor a

PLY_AKG_CHANNEL1_SETINSTRUMENTSTEP:		;demo $C5E3
	ld (PLY_AKG_CHANNEL1_INSTRUMENTSTEP+2),a

;Saves the software period and volume for the PSG to send later.
    ld a,e
    ld (PLY_AKG_PSGREG8),a
	;Reaches register/label 8/9/10.

    rr d
    exx
    ld (PLY_AKG_PSGREG01_INSTR+1),hl

										;demo $C5F0
PLY_AKG_CHANNEL2_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS:

;demo $C5F0
PLY_AKG_CHANNEL2_GENERATEDCURRENTPITCH:
	ld hl, 0
;The pitch to add to the real note, according to the Pitch Table + Pitch/Glide effect.

PLY_AKG_CHANNEL2_TRACKNOTE:				;demo $C5F3
	ld a, 0

										;demo $C5F5
PLY_AKG_CHANNEL2_GENERATEDCURRENTARPNOTE:
	add a, 0
    ld e,a
    ld d, 0
    exx

PLY_AKG_CHANNEL2_INSTRUMENTSTEP:		;demo $C5FB
	ld IYL, 0

PLY_AKG_CHANNEL2_PTINSTRUMENT:			;demo $C5FE
	ld hl, 0	;Instrument data to read (past the header).

;demo $C601
PLY_AKG_CHANNEL2_GENERATEDCURRENTINVERTEDVOLUME:
	ld e,15
    nop
    call PLY_AKG_READINSTRUMENTCELL

	ld a, IYL
    inc a

PLY_AKG_CHANNEL2_INSTRUMENTSPEED:		;demo $C60A
	cp 0
    jr c,PLY_AKG_CHANNEL2_SETINSTRUMENTSTEP
;Checks C, not only NZ because since the speed can be changed via an effect, the step can get beyond the limit, this must be taken in account.
;The speed is reached. We can go to the next line on the next frame.
    ld (PLY_AKG_CHANNEL2_PTINSTRUMENT+1),hl
    xor a

PLY_AKG_CHANNEL2_SETINSTRUMENTSTEP:		;demo $C612
	ld (PLY_AKG_CHANNEL2_INSTRUMENTSTEP+2),a

;Saves the software period and volume for the PSG to send later.
    ld a,e
    ld (PLY_AKG_PSGREG9),a
	;Reaches register/label 8/9/10.
    rr d
    exx
    ld (PLY_AKG_PSGREG23_INSTR+1),hl

										;demo $C61F
PLY_AKG_CHANNEL3_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS:

;demo $C61F
PLY_AKG_CHANNEL3_GENERATEDCURRENTPITCH:
	ld hl,0
;The pitch to add to the real note, according to the Pitch Table + Pitch/Glide effect.

PLY_AKG_CHANNEL3_TRACKNOTE:				;demo $C622
	ld a,0

										;demo $C624
PLY_AKG_CHANNEL3_GENERATEDCURRENTARPNOTE:
	add a, 0
    ld e,a
    ld d, 0
    exx

PLY_AKG_CHANNEL3_INSTRUMENTSTEP:		;demo $C62A
	ld IYL, 0

PLY_AKG_CHANNEL3_PTINSTRUMENT:			;demo $C62D
	ld hl, 0	;Instrument data to read (past the header).

										;demo $C630
PLY_AKG_CHANNEL3_GENERATEDCURRENTINVERTEDVOLUME:
	ld e, 15
    nop
    call PLY_AKG_READINSTRUMENTCELL
	ld a, IYL
    inc a

PLY_AKG_CHANNEL3_INSTRUMENTSPEED:		;demo $C639
	cp 0
    jr c,PLY_AKG_CHANNEL3_SETINSTRUMENTSTEP
;Checks C, not only NZ because since the speed can be changed via an effect, the step can get beyond the limit, this must be taken in account.
;The speed is reached. We can go to the next line on the next frame.
    ld (PLY_AKG_CHANNEL3_PTINSTRUMENT+1),hl
    xor a

PLY_AKG_CHANNEL3_SETINSTRUMENTSTEP:		;demo $C641
	ld (PLY_AKG_CHANNEL3_INSTRUMENTSTEP+2),a
;Saves the software period and volume for the PSG to send later.
    ld a,e
    ld (PLY_AKG_PSGREG10),a
	;Reaches register/label 8/9/10.

    ld a,d
    exx
    ld (PLY_AKG_PSGREG45_INSTR+1),hl

;Sends the registers to the PSG. Only general registers are sent, the specific ones have already been sent.
;IN:    A = R7.
PLY_AKG_SENDPSGREGISTERS:				;demo $C64D
	ex af,af'
    ld de, $BFFF
    ld bc, $FFFD
    ld a, 1

PLY_AKG_PSGREG01_INSTR:					;demo $C656
	ld hl, 0
	out (c), 0

    ld b,d
    out (c),l       ;$bffd + value
    ld b,e
    out (c),a       ;$fffd + register.
    ld b,d
    out (c),h       ;$bffd + value
    ld b,e

PLY_AKG_PSGREG23_INSTR:					;demo $C665
	ld hl, 0
    inc a
    out (c),a       ;$fffd + register.
    ld b,d
    out (c),l       ;$bffd + value
    ld b,e
    inc a
    out (c),a       ;$fffd + register.
    ld b,d
    out (c),h       ;$bffd + value
    ld b,e

PLY_AKG_PSGREG45_INSTR:					;demo $C676
	ld hl, 0
    inc a
    out (c),a       ;$fffd + register.
    ld b,d
    out (c),l       ;$bffd + value
    ld b,e
    inc a
    out (c),a       ;$fffd + register.
    ld b,d
    out (c),h       ;$bffd + value
    ld b,e

;demo $C688
PLY_AKG_PSGREG6:    equ PLY_AKG_PSGREG6_8_INSTR + 1

;demo $C689
PLY_AKG_PSGREG8:    equ PLY_AKG_PSGREG6_8_INSTR + 2

PLY_AKG_PSGREG6_8_INSTR:				;demo $C687
	ld hl, 0

	;Register 7. The value is A.
    inc a
    out (c),a       ;$fffd + register.
    ld b,d
    out (c),l       ;$bffd + value
    ld b,e
    inc a
    out (c),a
    ld b,d
    ex af,af'
    out (c),a
    ex af,af'
    ld b,e
    inc a
    out (c),a
    ld b,d
    out (c),h
    ld b,e

;demo $C6A2
PLY_AKG_PSGREG9:    equ PLY_AKG_PSGREG9_10_INSTR + 1

;demo $C6A3
PLY_AKG_PSGREG10:   equ PLY_AKG_PSGREG9_10_INSTR + 2

;demo $C6A1
PLY_AKG_PSGREG9_10_INSTR:
	ld hl,0

	inc a
	out (c),a       ;#fffd + register.
	ld b,d
	out (c),l       ;#bffd + value
	ld b,e

	inc a
	out (c),a       ;#fffd + register.
	ld b,d
	out (c),h       ;#bffd + value
	ld b,e

PLY_AKG_PSGHARDWAREPERIOD_INSTR:		;demo $C6B2
	ld hl, 0
    inc a
    out (c),a       ;$fffd + register.
    ld b,d
    out (c),l       ;$bffd + value
    ld b,e

    inc a
    out (c),a       ;$fffd + register.
    ld b,d
    out (c),h       ;$bffd + value
    ld b,e

    inc a   ;Selects R13 now, even if not changed, because A will be modified.
    out (c),a   ;#fffd + register.

PLY_AKG_PSGREG13_OLDVALUE:				;demo $C6C6
	ld a, 255

PLY_AKG_RETRIG:							;demo $C6C8
	or 0
;0 = no retrig. Else, should be >0xf to be sure the old value becomes a sentinel (i.e. unreachable) value.

PLY_AKG_PSGREG13_INSTR:					;demo $C6CA
	ld l, 0          ;Register 13.
    cp l
;Is the new value still the same? If yes, the new value must not be set again.
    jr z,PLY_AKG_PSGREG13_END
    ld a,l
    ld (PLY_AKG_PSGREG13_OLDVALUE+1),a	;Different R13.
    ld b,d
    out (c),a
    xor a
    ld (PLY_AKG_RETRIG+1),a

PLY_AKG_PSGREG13_END:					;demo $C6DA

PLY_AKG_SAVESP:							;demo $C6DA
	ld sp, 0

PLY_AKG_SAVESP_END:
ret

PLY_AKG_CHANNEL1_MAYBEEFFECTS:			;demo $C6DE
;There is one wait in all cases.
	ld (PLY_AKG_EVENTTRACK_END+1),a
    bit 6,c         ;Effects?
    jp z,PLY_AKG_CHANNEL1_BEFOREEND_STORECELLPOINTER

;Reads the effects.
;IN:    HL = Points on the effect blocks
;OUT:   HL = Points after on the effect blocks
PLY_AKG_CHANNEL1_READEFFECTS:			;demo $C6E6
	ld iy,PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS
    ld ix,PLY_AKG_CHANNEL1_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS
    ld de,PLY_AKG_CHANNEL1_BEFOREEND_STORECELLPOINTER
;Only adds a jump if this is not the last channel, as the code only need to jump below.
    jr PLY_AKG_CHANNEL3_READEFFECTSEND

PLY_AKG_CHANNEL1_READEFFECTSEND:		;demo $C6F3

PLY_AKG_CHANNEL2_MAYBEEFFECTS:			;demo $C6F3
;There is one wait in all cases.
	ld (PLY_AKG_CHANNEL1_READCELLEND+1),a
    bit 6,c
    jp z,PLY_AKG_CHANNEL2_BEFOREEND_STORECELLPOINTER

;Reads the effects.
;IN:    HL = Points on the effect blocks
;OUT:   HL = Points after on the effect blocks
PLY_AKG_CHANNEL2_READEFFECTS:			;demo $C6FB
	ld iy,PLY_AKG_CHANNEL2_SOUNDSTREAM_RELATIVEMODIFIERADDRESS
    ld ix,PLY_AKG_CHANNEL2_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS
    ld de,PLY_AKG_CHANNEL2_BEFOREEND_STORECELLPOINTER
;Only adds a jump if this is not the last channel, as the code only need to jump below.
    jr PLY_AKG_CHANNEL3_READEFFECTSEND

PLY_AKG_CHANNEL2_READEFFECTSEND:		;demo $C708

PLY_AKG_CHANNEL3_MAYBEEFFECTS:			;demo $C708
;There is one wait in all cases.
	ld (PLY_AKG_CHANNEL2_READCELLEND+1),a
    bit 6,c
    jp z,PLY_AKG_CHANNEL3_BEFOREEND_STORECELLPOINTER

;Reads the effects.
;IN:    HL = Points on the effect blocks
;OUT:   HL = Points after on the effect blocks
PLY_AKG_CHANNEL3_READEFFECTS:			;demo $C710
	ld iy,PLY_AKG_CHANNEL3_SOUNDSTREAM_RELATIVEMODIFIERADDRESS
    ld ix,PLY_AKG_CHANNEL3_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS
    ld de,PLY_AKG_CHANNEL3_BEFOREEND_STORECELLPOINTER

PLY_AKG_CHANNEL3_READEFFECTSEND:		;demo $C71B

;IN:    HL = Points on the effect blocks
;       DE = Where to go to when over.
;       IX = Address from which the data of the instrument are modified.
;       IY = Address from which data of the channels (pitch, volume, etc) are modified.
;OUT:   HL = Points after on the effect blocks

PLY_AKG_CHANNEL_READEFFECTS:			;demo $C71B
	ld (PLY_AKG_CHANNEL_READEFFECTS_ENDJUMP+1),de

;HL will be very useful, so we store the pointer in DE.
    ex de,hl

;Reads the effect block. It may be an index or a relative address.
    ld a,(de)
    inc de
    sla a
    jr c,PLY_AKG_CHANNEL_READEFFECTS_RELATIVEADDRESS
;Index.
    exx
    ld l,a
    ld h,0

										;demo $C72A
PLY_AKG_CHANNEL_READEFFECTS_EFFECTBLOCKS1:
	ld de,0
    add hl,de	;The index is already *2.
    ld e,(hl)	;Gets the address referred by the table.
    inc hl
    ld d,(hl)

										;demo $C731
PLY_AKG_CHANNEL_RE_EFFECTADDRESSKNOWN:
;DE points on the current effect block header/data.
	ld a,(de)	;Gets the effect number/more effect flag.
    inc de
    ld (PLY_AKG_CHANNEL_RE_EFFECTRETURN+1),a
;Stores the flag indicating whether there are more effects.

	;Gets the effect number.
    and 254	;%11111110
    ld l,a
    ld h, 0
    ld sp,PLY_AKG_EFFECTTABLE
    add hl,sp	;Effect is already * 2.
    ld sp,hl	;Jumps to the effect code.
ret 	;All the effects return here.

PLY_AKG_CHANNEL_RE_EFFECTRETURN:		;demo $C741
;Is there another effect?

										;demo $C741
PLY_AKG_CHANNEL_RE_READNEXTEFFECTINBLOCK:
	ld a, 0
;Bit 0 indicates whether there are more effects.
    rra
    jr c,PLY_AKG_CHANNEL_RE_EFFECTADDRESSKNOWN
;No more effects.

    exx
    ex de,hl

									;demo $C748
PLY_AKG_CHANNEL_READEFFECTS_ENDJUMP:
	jp 0
;PLY_AKG_Channel1/2/3_BeforeEnd_StoreCellPointer

									;demo $C74B
PLY_AKG_CHANNEL_READEFFECTS_RELATIVEADDRESS:
	srl a	;A was the relative MSB. Only 7 relevant bits.
    exx
    ld h,a
    exx
    ld a,(de)	;Reads the relative LSB.
    inc de
    exx
    ld l,a

									;demo $C754
PLY_AKG_CHANNEL_READEFFECTS_EFFECTBLOCKS2:
	ld de, 0
    add hl,de
    jr PLY_AKG_CHANNEL_RE_EFFECTADDRESSKNOWN


;---------------------------------
;Codes that read InstrumentCells.
;IN:    HL = pointer on the Instrument data cell to read.
;       IX = can be modified.
;       IYL = Instrument step (>=0). Useful for retrig.
;       SP = normal use of the stack, do not pervert it!
;       D = register 7, as if it was the channel 3 (so, bit 2 and 5 filled only).
;             By default, the noise is OFF, the sound is ON, so no need to do anything if these values match.
;       E = inverted volume.
;       A = SET BELOW: first byte of the data, shifted of 3 bits to the right.
;       B = SET BELOW: first byte of the data, unmodified.
;       HL' = track pitch.
;       DE' = 0 / note (instrument + Track transposition).
;       BC' = temp, use at will.

;OUT:   HL = new pointer on the Instrument (may be on the empty sound). If not relevant, any value can be returned, it doesn't matter.
;       IYL = Not 0 if retrig for this channel.
;       D = register 7, updated, as if it was the channel 1 (so, bit 2 and 5 filled only).
;       E = volume to encode (0-16).
;       HL' = software period. If not relevant, do not set it.
;       DE' = output period.

PLY_AKG_BitForSound: equ 2
PLY_AKG_BitForNoise: equ 5

PLY_AKG_READINSTRUMENTCELL:				;demo $C75A
	ld a,(hl)	;Gets the first byte of the cell.
    inc hl
    ld b,a	;Stores the first byte, handy in many cases.

	;What type if the cell?
    rra
    jp c,PLY_AKG_S_OR_H_OR_SAH_OR_ENDWITHLOOP
;No Soft No Hard, or Soft To Hard, or Hard To Soft, or End without loop.
    rra
    jr c,PLY_AKG_STH_OR_ENDWITHOUTLOOP

	;No Soft No Hard, or Hard to Soft.
    rra
    jr c,PLY_AKG_HARDTOSOFT

PLY_AKG_NOSOFTNOHARD:					;demo $C767
	and %1111		;and %1111
;Necessary, we don't know what is in the 4th bit of A.

    sub e
;Decreases the volume, watching for overflow.

    jr nc,PLY_AKG_NOSOFTNOHARD+6
    xor a
    ld e,a		;Sets the volume.
    rl b		;Noise?
    jr nc,PLY_AKG_NSNH_NONOISE
    ld a,(hl)
    inc hl
    ld (PLY_AKG_PSGREG6),a
    set PLY_AKG_BitForSound,d
;Noise, no sound (both non-default values).

    res PLY_AKG_BitForNoise,d
ret

PLY_AKG_NSNH_NONOISE:					;demo $C77C
	set PLY_AKG_BitForSound,d
;No noise (default), no sound.
ret

;----------------
;"Soft only".
;----------------
PLY_AKG_SOFT:							;demo $C77F
;Calculates the volume.
	and %1111		;and %1111
;Necessary, we don't know what crap is in the 4th bit of A.
    sub e
;Decreases the volume, watching for overflow.
    jr nc,PLY_AKG_SOFTONLY_HARDONLY_TESTSIMPLE_COMMON-1
;Checks for overflow.
    xor a
    ld e,a	;Sets the volume.

									;demo $C786
PLY_AKG_SOFTONLY_HARDONLY_TESTSIMPLE_COMMON:
;This code is also used by "Hard only".
;Simple sound? Gets the bit, let the subroutine do the job.
	rl b
    jr nc,PLY_AKG_S_NOTSIMPLE
;Simple.
    ld c, 0		;This will force the noise to 0.
    jr PLY_AKG_S_AFTERSIMPLETEST

PLY_AKG_S_NOTSIMPLE:				;demo $C78E
;Not simple. Reads and keeps the next byte, containing the noise. WARNING, the following code must NOT modify the Carry!
	ld b,(hl)
    ld c,b
    inc hl

PLY_AKG_S_AFTERSIMPLETEST:			;demo $C791
	call PLY_AKG_S_OR_H_CHECKIFSIMPLEFIRST_CALCULATEPERIOD
;Noise?
    ld a,c
    and %11111			;and %11111
    ret z
;if noise not present, sound present, we can stop here, R7 is fine.
;Noise is present.
    ld (PLY_AKG_PSGREG6),a
    res PLY_AKG_BitForNoise,d		;Noise present.
ret

PLY_AKG_HARDTOSOFT:					;demo $C79E
	call PLY_AKG_STOH_HTOS_SANDH_COMMON
;We have the ratio jump calculated and the primary period too. It must be divided to get the software frequency.
    ld (PLY_AKG_HS_JUMPRATIO+1),a
    ld a,b
;Stores where to jump after the JumpRatio label. Only BC' is free...
    exx		;The hardware period can be stored.
    ld (PLY_AKG_PSGHARDWAREPERIOD_INSTR+1),hl

PLY_AKG_HS_JUMPRATIO:				;demo $C7A9
	jr PLY_AKG_HS_JUMPRATIO+2
    sla l
    rl h
    sla l
    rl h
    sla l
    rl h
    sla l
    rl h
    sla l
    rl h
    sla l
    rl h
    sla l
    rl h		;Any Software pitch shift?
    rla
    jr nc,PLY_AKG_SH_NOSOFTWAREPITCHSHIFT
;Pitch shift. Reads it.
    exx
    ld a,(hl)
    inc hl
    exx
    add a,l
    ld l,a
    exx
    ld a,(hl)
    inc hl
    exx
    adc a,h
    ld h,a

PLY_AKG_SH_NOSOFTWAREPITCHSHIFT:	;demo $C7D6
	exx
ret

;------------------------------
;End without loop. Put here to
;satisfy the JR range below.
;------------------------------
PLY_AKG_ENDWITHOUTLOOP:				;demo $C7D8
;Loops to the "empty" instrument, and makes another iteration.

PLY_AKG_EMPTYINSTRUMENTDATAPT:		;demo $C7D8
	ld hl,0

;No need to read the data, consider a void value.
    inc hl
    xor a
    ld b,a
    jr PLY_AKG_NOSOFTNOHARD

PLY_AKG_STH_OR_ENDWITHOUTLOOP:		;demo $C7E0
	rra
    jr c,PLY_AKG_ENDWITHOUTLOOP

;-----------------
;"Soft to Hard".
;-----------------

    call PLY_AKG_STOH_HTOS_SANDH_COMMON
;We have the ratio jump calculated and the primary period too. It must be divided to get the hardware frequency.

    ld (PLY_AKG_SH_JUMPRATIO+1),a
    ld a,b
;Saves the original frequency in DE.
    exx
    ld e,l
    ld d,h

PLY_AKG_SH_JUMPRATIO:				;demo $C7ED
	jr PLY_AKG_SH_JUMPRATIO+2
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l
    srl h
    rr l
    jr nc,PLY_AKG_SH_JUMPRATIOEND
    inc hl

PLY_AKG_SH_JUMPRATIOEND:			;demo $C80E
;Any Hardware pitch shift?
	rla
    jr nc,PLY_AKG_SH_NOHARDWAREPITCHSHIFT
    exx
    ld a,(hl)
    inc hl
    exx
    add a,l
    ld l,a
    exx
    ld a,(hl)
    inc hl
    exx
    adc a,h
    ld h,a

PLY_AKG_SH_NOHARDWAREPITCHSHIFT:	;demo $C81D
	ld (PLY_AKG_PSGHARDWAREPERIOD_INSTR+1),hl
    ex de,hl
    exx
ret

									;demo $C823
PLY_AKG_S_OR_H_OR_SAH_OR_ENDWITHLOOP:
	rra
    jr c,PLY_AKG_H_OR_ENDWITHLOOP
    rra
    jp nc,PLY_AKG_SOFT
    exx
    push hl
    push de
    exx
    call PLY_AKG_STOH_HTOS_SANDH_COMMON
    exx
    ld (PLY_AKG_PSGHARDWAREPERIOD_INSTR+1),hl
    pop de
    pop hl
    exx
    rl b
    jp PLY_AKG_S_OR_H_CHECKIFSIMPLEFIRST_CALCULATEPERIOD

PLY_AKG_H_OR_ENDWITHLOOP:			;demo $C83D
;Second bit of the type.
	rra
    jr c,PLY_AKG_ENDWITHLOOP
    ld e, 16
;Third bit of the type.
    rra
    jr nc,PLY_AKG_H_AFTERRETRIG
    ld c,a

	ld a, IYL
    or a
    jr nz,PLY_AKG_H_RETRIGEND
    ld a,e
    ld (PLY_AKG_RETRIG+1),a

PLY_AKG_H_RETRIGEND:				;demo $C84F
	ld a,c

PLY_AKG_H_AFTERRETRIG:				;demo $C850
;Calculates the hardware envelope. The value given is from 8-15, but encoded as 0-7.
	and 7		;and %111
    add a,8
    ld (PLY_AKG_PSGREG13_INSTR+1),a
;Use the code of Soft Only to calculate the period and the noise.
    call PLY_AKG_SOFTONLY_HARDONLY_TESTSIMPLE_COMMON

;The period is actually an hardware period. We don't care about the software period, the sound channel is cut.
    exx
    ld (PLY_AKG_PSGHARDWAREPERIOD_INSTR+1),hl
    exx
    set PLY_AKG_BitForSound,d
ret

;----------------
;End with loop.
;----------------
PLY_AKG_ENDWITHLOOP:				;demo $C862
;Loops to the encoded pointer, and makes another iteration.
	ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    jp PLY_AKG_READINSTRUMENTCELL

									;demo $C869
PLY_AKG_S_OR_H_CHECKIFSIMPLEFIRST_CALCULATEPERIOD:
;Simple sound? Checks the carry.
	jr nc,PLY_AKG_S_OR_H_NEXTBYTE
;No more bytes to read, the sound is "simple". The software period must still be calculated.
;Calculates the note period from the note of the track. This is the same code as below.
    exx
    ex de,hl
;Now HL = track note + transp, DE is track pitch.
    add hl,hl
    ld bc, PLY_AKG_PERIODTABLE
    add hl,bc
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    add hl,de		;Adds the track pitch.
    exx
;Important: the bits must be shifted so that B is in the same state as if it were not a "simple" sound.
    rl b
    rl b
    rl b		;No need to modify R7.
ret

PLY_AKG_S_OR_H_NEXTBYTE:			;demo $C87F
;Not simple. Reads the next bits to know if there is pitch/arp/forced software period.
;Forced period?
	rl b
    jr c,PLY_AKG_S_OR_H_FORCEDPERIOD
;No forced period. Arpeggio?
    rl b
    jr nc,PLY_AKG_S_OR_H_AFTERARPEGGIO
    ld a,(hl)
    inc hl
    exx
    add a,e
;We don't care about overflow, no time for that.
    ld e,a
    exx

PLY_AKG_S_OR_H_AFTERARPEGGIO:		;demo $C88D
	rl b
    jr nc,PLY_AKG_S_OR_H_AFTERPITCH
;Reads the pitch. Slow, but shouldn't happen so often.
    ld a,(hl)
    inc hl
    exx
    add a,l
    ld l,a
;Adds the cell pitch to the track pitch, in two passes.
    exx
    ld a,(hl)
    inc hl
    exx
    adc a,h
    ld h,a
    exx

PLY_AKG_S_OR_H_AFTERPITCH:			;demo $C89D
;Calculates the note period from the note of the track.
	exx
    ex de,hl
;Now HL = track note + transp, DE is track pitch.
    add hl,hl
    ld bc, PLY_AKG_PERIODTABLE
    add hl,bc
    ld a,(hl)
    inc hl
    ld h,(hl)
    ld l,a
    add hl,de		;Adds the track pitch.
    exx
ret

PLY_AKG_S_OR_H_FORCEDPERIOD:		;demo $C8AB
;Reads the period. A bit slow, but doesn't happen often.
	ld a,(hl)
    inc hl
    exx
    ld l,a
    exx
    ld a,(hl)
    inc hl
    exx
    ld h,a
    exx
;The pitch and arpeggios have been skipped, since the period is forced, the bits must be compensated.
    rl b
    rl b
ret

;------------------------------------------------------
;Common code for SoftToHard and HardToSoft, and even
; Soft And Hard. The same register constraints as the
;methods above apply.
;OUT:   HL' = frequency.
;       A = shifted inverted ratio (xxx000),
;			ready to be used in a JR to
;			multiply/divide the frequency.
;       B = bit states, shifted four times to
;			the left (for StoH/HtoS, the msb
;			will be "pitch shift?")
;			(hardware for SoftTohard,
;			software for HardToSoft).
PLY_AKG_STOH_HTOS_SANDH_COMMON:		;demo $C8BA
	ld e, 16	;Sets the hardware volume.
    rra
    jr nc,PLY_AKG_SHOHS_AFTERRETRIG
    ld c,a
;Retrig is only set if we are on the first step of the instrument!


	ld a, IYL
    or a
    jr nz,PLY_AKG_SHOHS_RETRIGEND
    dec a
    ld (PLY_AKG_RETRIG+1),a

PLY_AKG_SHOHS_RETRIGEND:			;demo $C8C9
	ld a,c

PLY_AKG_SHOHS_AFTERRETRIG:			;demo $C8CA
;Calculates the hardware envelope. The value given is from 8-15, but encoded as 0-7.
	and 7		;and %111
    add a, 8
    ld (PLY_AKG_PSGREG13_INSTR+1),a

;Noise? If yes, reads the next byte.
    rl b
    jr nc,PLY_AKG_SHOHS_AFTERNOISE
;Noise is present.
    ld a,(hl)
    inc hl
    ld (PLY_AKG_PSGREG6),a
;Noise present.
    res PLY_AKG_BitForNoise,d

PLY_AKG_SHOHS_AFTERNOISE:			;demo $C8DC
	ld c,(hl)
    ld b,c
    inc hl
    rl b
    call PLY_AKG_S_OR_H_CHECKIFSIMPLEFIRST_CALCULATEPERIOD
    ld a,c
    rla
    rla
    and 28
ret

PLY_AKG_EFFECTTABLE:				;demo $C8EA
	defw PLY_AKG_EFFECT_RESETFULLVOLUME
    defw PLY_AKG_EFFECT_RESET
    defw PLY_AKG_EFFECT_VOLUME
    defw PLY_AKG_EFFECT_ARPEGGIOTABLE
    defw PLY_AKG_EFFECT_ARPEGGIOTABLESTOP
    defw PLY_AKG_EFFECT_PITCHTABLE
    defw PLY_AKG_EFFECT_PITCHTABLESTOP
    defw PLY_AKG_EFFECT_VOLUMESLIDE
    defw PLY_AKG_EFFECT_VOLUMESLIDESTOP
    defw PLY_AKG_EFFECT_PITCHUP
    defw PLY_AKG_EFFECT_PITCHDOWN
    defw PLY_AKG_EFFECT_PITCHSTOP
    defw PLY_AKG_EFFECT_GLIDEWITHNOTE
    defw PLY_AKG_EFFECT_GLIDE_READSPEED
    defw PLY_AKG_EFFECT_LEGATO
    defw PLY_AKG_EFFECT_FORCEINSTRUMENTSPEED
    defw PLY_AKG_EFFECT_FORCEARPEGGIOSPEED
    defw PLY_AKG_EFFECT_FORCEPITCHSPEED

PLY_AKG_EFFECT_RESETFULLVOLUME:		;demo $C90E
	xor a
    jr PLY_AKG_EFFECT_RESETVOLUME_AFTERREADING

PLY_AKG_EFFECT_RESET:				;demo $C911
	ld a,(de)
    inc de

									;demo $C913
PLY_AKG_EFFECT_RESETVOLUME_AFTERREADING:
	;ld (iy-123),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_INVERTEDVOLUMEINTEGER - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	;The current pitch is reset.
	
    xor a
	
    ;ld (iy-26),a;	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),a
	
	
	
	;ld (iy-25),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b + 1),a
	
	;ld a, 183    ;line 3105	;Disark output
	ld a,PLY_AKG_OPCODE_OR_A
    
    ;ld (iy-24),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISPITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
    ;ld (iy-52),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISPITCHTABLE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
	
    ;ld (iy-91),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISARPEGGIOTABLE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
	
    ;ld (iy-122),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISVOLUMESLIDE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_VOLUME:				;demo $C92E
	ld a,(de)
    inc de
	
    ;ld (iy-123),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_INVERTEDVOLUMEINTEGER - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
    ;ld (iy-122),183	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISVOLUMESLIDE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),PLY_AKG_OPCODE_OR_A
	
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_ARPEGGIOTABLE:		;demo $C93A
	ld a,(de)
    inc de
	
	;Finds the address of the Arpeggio.
    ld l,a
    ld h, 0
    add hl,hl

PLY_AKG_ARPEGGIOSTABLE:				;demo $C940
	ld bc, 0
    add hl,bc
    ld c,(hl)
    inc hl
    ld b,(hl)
    inc hl
	
	;Reads the speed.
    ld a,(bc)
    inc bc
	
	
    ;ld (iy+61),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ARPEGGIOTABLESPEED - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0),a
	
    ;ld (iy+62),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ARPEGGIOBASESPEED - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0),a
	
	
    ;ld (iy-87),c	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ARPEGGIOTABLE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),c
	
    ;ld (iy-86),b	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ARPEGGIOTABLE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b + 1),b
	
    ;ld (iy+63),c	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ARPEGGIOTABLEBASE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0),c
	
    ;ld (iy+64),b	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ARPEGGIOTABLEBASE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 1),b
	
    ld (iy-91),55	;Disark output

	
    xor a
	
    ;ld (iy-68),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ARPEGGIOTABLECURRENTSTEP - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),a
	
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_ARPEGGIOTABLESTOP:	;demo $C967

	;ld (iy-91),183	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISARPEGGIOTABLE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),PLY_AKG_OPCODE_OR_A
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_PITCHTABLE:			;demo $C99B
	ld a,(de)
    inc de
    ld l,a
    ld h, 0
    add hl,hl

PLY_AKG_PITCHESTABLE:				;demo $C974
	ld bc, 0
    add hl,bc
    ld c,(hl)
    inc hl
    ld b,(hl)
    inc hl
	
	;Reads the speed.
    ld a,(bc)
    inc bc
	
    ;ld (iy+65),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTABLESPEED - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
    ;ld (iy+66),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHBASESPEED - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
    ;ld (iy-48),c	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTABLE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),c
	
    ;ld (iy-47),b	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTABLE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b + 1),b
	
	
    ;ld (iy+67),c	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTABLEBASE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0),c
	
    ;ld (iy+68),b	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTABLEBASE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 1),b
	
    ;ld (iy-52),55	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISPITCHTABLE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),PLY_AKG_OPCODE_SCF
	
	
    xor a
    ;ld (iy-39),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTABLECURRENTSTEP - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),a
	
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_PITCHTABLESTOP:		;demo $C99B

	;ld (iy-52),183	;Disark output
	;Only the pitch is stopped, but the value remains.
	ld (iy + PLY_AKG_CHANNEL1_ISPITCHTABLE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),PLY_AKG_OPCODE_OR_A
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_VOLUMESLIDE:			;demo $C99B
	ld a,(de)	;Reads the slide.
    inc de
	
    ;ld (iy-118),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_VOLUMESLIDEVALUE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),a
	
	
    ld a,(de)
    inc de
	
	
    ;ld (iy-117),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_VOLUMESLIDEVALUE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b + 1),a
	
    ;ld (iy-122),55	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISVOLUMESLIDE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),PLY_AKG_OPCODE_SCF
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_VOLUMESLIDESTOP:		;demo $C9B3
	;Only stops the slide, don't reset the value.
	;ld (iy-122),183	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISVOLUMESLIDE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),PLY_AKG_OPCODE_OR_A
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_PITCHDOWN:			;demo $C9BA

	;ld (iy-15),0	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKADDORSBC_16BITS - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_ADD_HL_BC_MSB
	
    ;ld (iy-14),9	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKADDORSBC_16BITS - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 1), PLY_AKG_OPCODE_ADD_HL_BC_LSB
	
    ;ld (iy-11),198	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKDECIMALINSTR - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_ADD_A_IMMEDIATE
	
    ;ld (iy-4),35	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKINTEGERADDORSUB - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_INC_HL

PLY_AKG_EFFECT_PITCHUPDOWN_COMMON:	;demo $C9CA
	;The Pitch up will jump here.
	;Authorizes the pitch, disabled the glide.

	;ld (iy-24),55	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISPITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),PLY_AKG_OPCODE_SCF
	
    ;ld (iy+1),0		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_GLIDEDIRECTION - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),0
	
    ld a,(de)		;Reads the Pitch.
    inc de
	
    ;ld (iy-10),a		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKDECIMALVALUE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
    ld a,(de)
    inc de
	
    ;ld (iy-18),a		;Disark output
	;ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKDECIMALVALUE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a;to test
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACK - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),a
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN
	
 

PLY_AKG_EFFECT_PITCHUP:				;demo $C9DF

	;Changes the sign of the operations.
	;ld (iy-15),237	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKADDORSBC_16BITS - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_SBC_HL_BC_MSB
	
    ;ld (iy-14),66	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKADDORSBC_16BITS - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 1), PLY_AKG_OPCODE_SBC_HL_BC_LSB
	
    ;ld (iy-11),214	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKDECIMALINSTR - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_SUB_IMMEDIATE
	
    ;ld (iy-4),43	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKINTEGERADDORSUB - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_DEC_HL
	
    jr PLY_AKG_EFFECT_PITCHUPDOWN_COMMON

PLY_AKG_EFFECT_PITCHSTOP:			;demo $C9F1

	;ld (iy-24),183	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISPITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),PLY_AKG_OPCODE_OR_A
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_GLIDEWITHNOTE:		;demo $C9F8
	ld a,(de)
    inc de
    ld (PLY_AKG_EFFECT_GLIDEWITHNOTESAVEDE+1),de
	;Have to save, no more registers. Damn.
	;Finds the period related to the note, stores it.
    add a,a	;The note is 7 bits only, so it fits.
    ld l,a
    ld h, 0
    ld bc, PLY_AKG_PERIODTABLE
    add hl,bc
    ld sp,hl
    pop de	;DE = period to reach.
	
    ;ld (iy+29),e	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_GLIDETOREACH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),e
	
	
    ;ld (iy+30),d	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_GLIDETOREACH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b + 1),d
	
	;Calculates the period of the current note to calculate the difference.
    ;ld a,(ix+4)		;Disark output
	ld a,(ix + PLY_AKG_CHANNEL1_TRACKNOTE - PLY_AKG_CHANNEL1_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b)
	
	
    add a,a
    ld l,a
    ld h,0
    add hl,bc
    ld sp,hl
    pop hl	;HL = current period.
	;Adds the current Track Pitch to have the current period, else the direction may be biased.
	
    ;ld c,(iy-26)	;Disark output
	ld c,(iy + PLY_AKG_CHANNEL1_PITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b)
	
    ;ld b,(iy-25)	;Disark output
	ld b,(iy + PLY_AKG_CHANNEL1_PITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b + 1)
	
	
    add hl,bc
    or a
    sbc hl,de

PLY_AKG_EFFECT_GLIDEWITHNOTESAVEDE:		;demo $CA22
	ld de, 0	;Retrieves DE. This does not modified the Carry.
    jr c,PLY_AKG_EFFECT_GLIDE_PITCHDOWN
	;Pitch up
	
    ;ld (iy+1),1		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_GLIDEDIRECTION - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),1
	
    ;ld (iy-15),237		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKADDORSBC_16BITS - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_SBC_HL_BC_MSB
	
    ;ld (iy-14),66		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKADDORSBC_16BITS - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 1), PLY_AKG_OPCODE_SBC_HL_BC_LSB
	
    ;ld (iy-11),214		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKDECIMALINSTR - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_SUB_IMMEDIATE
	
    ;ld (iy-4),43		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKINTEGERADDORSUB - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_DEC_HL
	;Reads the Speed, which is actually the "pitch".

PLY_AKG_EFFECT_GLIDE_READSPEED:		;demo $CA3B

;stopped
PLY_AKG_EFFECT_GLIDESPEED:			;demo $CA3B
	;This is an effect.
	ld a,(de)
    inc de
	
    ;ld (iy-10),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKDECIMALVALUE - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a      ;No offset, the value is directly targeted.
	
    ld a,(de)
    inc de
	
    ;ld (iy-18),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACK - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),a
	
	;Enables the pitch, as the Glide relies on it. The Glide is enabled below, via its direction.
    ld a, 55
	
    ;ld (iy-24),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISPITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

PLY_AKG_EFFECT_GLIDE_PITCHDOWN:		;demo $CA4D

	;Pitch down.
	;ld (iy+1),2		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_GLIDEDIRECTION - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),2
	
    ;ld (iy-15),0		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKADDORSBC_16BITS - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_ADD_HL_BC_MSB
	
    ;ld (iy-14),9		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKADDORSBC_16BITS - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 1), PLY_AKG_OPCODE_ADD_HL_BC_LSB
	
    ;ld (iy-11),198		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKDECIMALINSTR - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_ADD_A_IMMEDIATE
	
    ;ld (iy-4),35		;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTRACKINTEGERADDORSUB - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + 0), PLY_AKG_OPCODE_INC_HL
	
    jr PLY_AKG_EFFECT_GLIDE_READSPEED

PLY_AKG_EFFECT_LEGATO:				;demo $CA63
	;Reads and sets the new note to play.
	ld a,(de)
    inc de
	
    ;ld (ix+4),a		;Disark output
	ld (ix + PLY_AKG_CHANNEL1_TRACKNOTE - PLY_AKG_CHANNEL1_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),a
	
    ;ld a, 183		;Disark output
	ld a,PLY_AKG_OPCODE_OR_A
	
    ;ld (iy-24),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ISPITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
    xor a
	
    ;ld (iy-26),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),a
	
    ;ld (iy-25),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCH - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b + 1),a
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN
	;PLY_CFG_UseEffect_ForceInstrumentSpeed

									;demo $CA77
PLY_AKG_EFFECT_FORCEINSTRUMENTSPEED:
	;Is IT possible to use a Force Arpeggio even if there is no Arpeggio. Unlikely, but...
	;Reads and sets the new speed.
	ld a,(de)
    inc de
	
    ;ld (ix+27),a	;Disark output
	ld (ix + PLY_AKG_CHANNEL1_INSTRUMENTSPEED - PLY_AKG_CHANNEL1_PLAYINSTRUMENT_RELATIVEMODIFIERADDRESS + PLY_AKG_Offset1b),a
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

									;demo $CA7F
PLY_AKG_EFFECT_FORCEARPEGGIOSPEED:
	ld a,(de)
    inc de
	
    ;ld (iy+61),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_ARPEGGIOTABLESPEED - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

									;demo $CA87
PLY_AKG_EFFECT_FORCEPITCHSPEED:
	;Reads and sets the new speed.
	ld a,(de)
    inc de
	
    ;ld (iy+65),a	;Disark output
	ld (iy + PLY_AKG_CHANNEL1_PITCHTABLESPEED - PLY_AKG_CHANNEL1_SOUNDSTREAM_RELATIVEMODIFIERADDRESS),a
	
    jp PLY_AKG_CHANNEL_RE_EFFECTRETURN

                            ;demo $CA8F
PLY_AKG_EVENT:
	defb 0

                            ;demo $CA90
PLY_AKG_PERIODTABLE:
; Octave 0
	defw 6778, 6398, 6039, 5700, 5380, 5078, 4793, 4524, 4270, 4030, 3804, 3591
; Octave 1
	defw 3389, 3199, 3019, 2850, 2690, 2539, 2397, 2262, 2135, 2015, 1902, 1795
; Octave 2
	defw 1695, 1599, 1510, 1425, 1345, 1270, 1198, 1131, 1068, 1008, 951, 898
; Octave 3
	defw 847, 800, 755, 712, 673, 635, 599, 566, 534, 504, 476, 449
; Octave 4
	defw 424, 400, 377, 356, 336, 317, 300, 283, 267, 252, 238, 224
; Octave 5
	defw 212, 200, 189, 178, 168, 159, 150, 141, 133, 126, 119, 112
; Octave 6
	defw 106, 100, 94, 89, 84, 79, 75, 71, 67, 63, 59, 56
; Octave 7
	defw 53, 50, 47, 45, 42, 40, 37, 35, 33, 31, 30, 28
; Octave 8
	defw 26, 25, 24, 22, 21, 20, 19, 18, 17, 16, 15, 14
;Octave 9
	defw 13, 12, 12, 11, 11, 10, 9, 9, 8, 8, 7, 7
; Octave 10
	defw 7, 6, 6, 6, 5, 5, 5, 4
PLY_AKG_PERIODTABLE_END:

						;demo $CB90
PLY_AKG_END:

; Player is 2960 bytes long
;------------------------------------------

