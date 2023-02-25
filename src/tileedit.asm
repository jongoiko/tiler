;   tileedit.asm
; Routines for editing the tile data

INCLUDE "defs.asm"

SECTION "Tile editing", ROM0

; Get color at pixel corresponding to cursor.
; IN:
;     hCursorX, hCursorY: cursor position
; OUT:
;     B:  resulting color code
;     A:  destroyed
;     HL: destroyed
GetColorAtTile::
    LoadCurrentRow2HL
    ld a, [hCursorX]
    and a, [hl]
    jr z, .zeroBit
    ld b, 1
    jr .leastSignificantDone
.zeroBit
    ld b, 0
.leastSignificantDone
    inc hl
    ld a, [hCursorX]
    and a, [hl]
    ret z
    ld a, b
    or a, 2
    ld b, a
    ret

; Set color at pixel corresponding to cursor.
; IN:
;     hCursorX, hCursorY: cursor position
;     C (two lowest bits): color code to write
; OUT:
;     A:  destroyed
;     HL: destroyed
SetColorAtTile::
    LoadCurrentRow2HL
    bit 0, c
    call SetZBitHL
    inc hl
    bit 1, c
    call SetZBitHL
    ret

; Helper for SetColorAtTile. Sets bit indicated by hCursorX in HL to the value
; of the Z flag.
; IN:
;     HL: byte to set bit from
;     Z flag: what to set it to
; OUT:
;     A:    destroyed
;     [HL]: resulting byte
SetZBitHL:
    ld a, [hCursorX]
    jr z, .zeroBit
    or a, [hl]
    ld [hl], a
    ret
.zeroBit
    cpl
    and a, [hl]
    ld [hl], a
    ret

