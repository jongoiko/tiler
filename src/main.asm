;   main.asm
; Main program

INCLUDE "hardware.inc"
INCLUDE "defs.asm"

SECTION "Header", ROM0[$100]

Entry:
    di
    jp Start

REPT $150 - $104
    db 00
ENDR

SECTION "Main program", ROM0

Start:

    WaitVBlank

    xor a
    ld [rLCDC], a   ; Turn LCD off

; Load tiles
    ld hl, $9000
    ld bc, TilesStart
    ld de, TilesEnd - TilesStart

.copy
    ld a, [bc]
    ld [hl+], a
    inc bc
    dec de
    ld a, d
    or e
    jr nz, .copy

; the Nintendo logo seems to leave some garbage bytes in the tilemap, so we
; should clear it for good measure

    ld hl, _SCRN0
    ld bc, _SRAM - 1 - _SCRN0

.clear
    xor a
    ld [hl+], a
    dec bc
    ld a, b
    or c
    jr nz, .clear
    
; Set stack pointer to top of internal RAM to free up space for HRAM variables
    ld sp, _RAMBANK - 1

    call DrawUI
    
; Initialize cursor position
    ld a, $80
    ld hl, hCursorX
    ld [hl+], a
    ld [hl], 0
    ld hl, hCursorTileAddr
    ld a, CURSOR_TILE_ADDR_START & $00FF
    ld [hl+], a
    ld a, (CURSOR_TILE_ADDR_START & $FF00) >> 8
    ld [hl], a
    
; Zero out the block where the edited tile will be stored
    xor a
    ld hl, hTile
    ld b, 16
.loop
    ld [hl+], a
    dec b
    jr nz, .loop

    ld hl, CURSOR_TILE_ADDR_START
    ld [hl], CURSOR_TILENUM

; Set up and start LCD
    ld a, %11100100
    ld [rBGP], a

    xor a
    ld [rSCY], a
    ld [rSCX], a
    ld [rNR52], a

    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a
 
    ld d, 0

; Read button values and update cursor location accordingly. Once a direction
; is pressed, it waits until all are released to make sure that the cursor is
; updated only once per button press. This is done using the D register's 0
; and 1 bits as indicators for the joypad and ABSS buttons, respectively
MainLoop:
    call ReadButtons
    ld c, a
    and a, $0F
    jr z, .joypadReleased
    bit 0, d
    jr z, .joypadPressed
.checkABSS
    ld a, c
    and a, $F0
    jr z, .ABSSReleased
    bit 1, d
    jr z, .ABSSPressed
    jr MainLoop
.joypadReleased
    res 0, d
    jr .checkABSS
.ABSSReleased
    res 1, d
    jr MainLoop
.joypadPressed
    LoadCursorAddr2HL
    inc hl
    WaitVBlank
    ld a, [hl-]
    ld [hl], a  ; Clear old cursor tile address using tile number next to it
    call UpdateCursor
    LoadCursorAddr2HL
    WaitVBlank
    ld [hl], CURSOR_TILENUM ; Draw cursor at updated location
    set 0, d
    jr MainLoop
.ABSSPressed
    call GetColorAtTile
    bit 4, c
    jr z, .checkB
    inc b
    jr .updatePixel
.checkB
    bit 5, c
    jr z, .pixelUpdated
    dec b
.updatePixel
    ld c, b
    call SetColorAtTile
.pixelUpdated
    LoadCursorAddr2HL
    inc hl
    ld a, b
    and a, 3
    ld c, a
    WaitVBlank
    ld [hl], c
    ld a, l
    add a, 32
    ld l, a
    jr nc, .noCarry
    inc h
.noCarry
    ld [hl], c
    dec hl
    ld [hl], c
    set 1, d
    jr MainLoop

SECTION "Tiles", ROM0
TilesStart:
INCLUDE "tiles.asm"
TilesEnd:
