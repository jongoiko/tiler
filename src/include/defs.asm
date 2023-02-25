;   defs.asm
; Definitions and macros

CURSOR_TILE_ADDR_START EQU $9822

CURSOR_TILENUM EQU 4

MACRO WaitVBlank
.wait\@ 
    ld a, [$FF44]
    cp a, 144
    jr c, .wait\@
    ENDM

MACRO LoadCurrentRow2HL
    ld a, [hCursorY]
    ld hl, hTile
    add a, a
    add a, l
    ld l, a
    jr nc, .noCarry\@
    inc h
.noCarry\@
    ENDM

MACRO LoadCursorAddr2HL
    ld hl, hCursorTileAddr
    ld a,[hl+]
    ld h,[hl]
    ld l,a
    ENDM
