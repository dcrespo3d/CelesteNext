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
defw 0 ; avoid song potentially placed at $0000, it could be mistaken with NULL
PUBLIC _song_silence
_song_silence:
; Celeste 0, AKG format, v1.0.

; Generated by Arkos Tracker 2.

Celeste0_Start:
Celeste0_StartDisarkGenerateExternalLabel:

Celeste0_DisarkByteRegionStart0:
	defb "AT20"
Celeste0_DisarkPointerRegionStart1:
	defw Celeste0_ArpeggioTable	; The address of the Arpeggio table.
	defw Celeste0_PitchTable	; The address of the Pitch table.
	defw Celeste0_InstrumentTable	; The address of the Instrument table.
	defw Celeste0_EffectBlockTable	; The address of the Effect Block table.
Celeste0_DisarkPointerRegionEnd1:


; The addresses of each Subsong:
Celeste0_DisarkPointerRegionStart2:
	defw Celeste0_Subsong0_Start
Celeste0_DisarkPointerRegionEnd2:

; Declares all the Arpeggios.
Celeste0_ArpeggioTable:
Celeste0_DisarkPointerRegionStart3:
Celeste0_DisarkPointerRegionEnd3:

; Declares all the Pitches.
Celeste0_PitchTable:
Celeste0_DisarkPointerRegionStart4:
Celeste0_DisarkPointerRegionEnd4:

; Declares all the Instruments.
Celeste0_InstrumentTable:
Celeste0_DisarkPointerRegionStart5:
	defw Celeste0_EmptyInstrument
Celeste0_DisarkPointerRegionEnd5:

Celeste0_EmptyInstrument:
	defb 0	; The speed (>0, 0 for 256).
Celeste0_EmptyInstrument_Loop:	defb 0	; No Soft no Hard. Volume: 0. Noise? false.

	defb 6	; Loop to silence.


; The indexes of the effect blocks used by this song.
Celeste0_EffectBlockTable:

Celeste0_DisarkByteRegionEnd0:

; Subsong 0
; ----------------------
Celeste0_Subsong0_DisarkByteRegionStart0:
Celeste0_Subsong0_Start:
	defb 2	; ReplayFrequency (0=12.5hz, 1=25, 2=50, 3=100, 4=150, 5=300).
	defb 0	; Digichannel (0-2).
	defb 1	; PSG count (>0).
	defb 0	; Loop start index (>=0).
	defb 0	; End index (>=0).
	defb 7	; Initial speed (>=0).
	defb 0	; Base note index (>=0).

Celeste0_Subsong0_Linker:
Celeste0_Subsong0_DisarkPointerRegionStart1:
; Position 0
Celeste0_Subsong0_Linker_Loop:
	defw Celeste0_Subsong0_Track0
	defw Celeste0_Subsong0_Track0
	defw Celeste0_Subsong0_Track0
	defw Celeste0_Subsong0_LinkerBlock0

Celeste0_Subsong0_DisarkPointerRegionEnd1:
	defw 0	; Loop.
Celeste0_Subsong0_DisarkWordForceReference2:
	defw Celeste0_Subsong0_Linker_Loop

Celeste0_Subsong0_LinkerBlock0:
	defb 8	; Height.
	defb 0	; Transposition 0.
	defb 0	; Transposition 1.
	defb 0	; Transposition 2.
Celeste0_Subsong0_DisarkWordForceReference3:
	defw Celeste0_Subsong0_SpeedTrack0	; SpeedTrack address.
Celeste0_Subsong0_DisarkWordForceReference4:
	defw Celeste0_Subsong0_EventTrack0	; EventTrack address.

Celeste0_Subsong0_Track0:
	defb 61, 127	; Waits for 128 lines.


; The speed tracks
Celeste0_Subsong0_SpeedTrack0:
	defb 255	; Wait for 128 lines.

; The event tracks
Celeste0_Subsong0_EventTrack0:
	defb 255	; Wait for 128 lines.

Celeste0_Subsong0_DisarkByteRegionEnd0:
