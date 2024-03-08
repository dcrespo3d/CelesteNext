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

; Configuration that can be included to Arkos Tracker 2 players.
; It indicates what parts of code are useful to the song/sound effects, to save both memory and CPU.
; The players may or may not take advantage of these flags, it is up to them.

; You can either:
; - Include this to the source that also includes the player (BEFORE the player is included) (recommended solution).
; - Include this at the beginning of the player code.
; - Copy/paste this directly in the player.
; If you use one player but several songs, don't worry, these declarations will stack up.
; If no configuration is used, the player will use default values (full code used).

	PLY_CFG_SFX_ConfigurationIsPresent = 1
	PLY_CFG_SFX_NoSoftNoHard = 1
	PLY_CFG_SFX_NoSoftNoHard_Noise = 1
	PLY_CFG_SFX_SoftOnly = 1
	PLY_CFG_SFX_SoftOnly_Noise = 1
