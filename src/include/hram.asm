;   hram.asm
; HRAM data addresses

SECTION "HRAM addresses", HRAM

hCursorX::  ; Cursor X position: stored as a byte with a single bit set
    ds 1    ; corresponding to the position from 0 to 7

hCursorY::
    ds 1    ; Cursor Y position, pointer to row in hTile

hCursorTileAddr::   ; Address where cursor tile should be put in tilemap
    ds 2

ds 12

hTile::     ; $FF90: Tile being edited
    ds 16
