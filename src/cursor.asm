;   cursor.asm
; Cursor location and button input handling routines

INCLUDE "hardware.inc"
INCLUDE "defs.asm"
INCLUDE "hram.asm"
INCLUDE "config.asm"

SECTION "Cursor and buttons", ROM0

; Loads all buttons' values into A. Lowest nibble is joypad, highest is
; A/B/Start/Select. 1 = pressed
; OUT:
;     A: resulting byte
;     B: destroyed
ReadButtons::
    ld a, P1F_5
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    and a, $0F
    ld b, a
    ld a, P1F_4
    ld [rP1], a
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    ld a, [rP1]
    and a, $0F
    swap a
    or a, b
    cpl
    ret

; Updates the cursor location according to joypad button values, without any of
; both axes exiting the 0-7 range. Also updates address of cursor tile
; IN:
;     C: button values' byte (generated by ReadButtons)
;     hCursorX, hCursorY: current cursor location
;     hCursorTileAddr: current cursor tile address
; OUT:
;     A:  destroyed
;     HL: destroyed
;     hCursorX, hCursorY: new cursor location
;     hCursorTileAddr: new cursor tile address
UpdateCursor::
.checkRight
    bit 0, c
    jr nz, .right
.checkLeft
    bit 1, c
    jr nz, .left
.checkUp
    bit 2, c
    jr nz, .up
.checkDown
    bit 3, c
    jr nz, .down
.end
    ret

IF WRAP_FROM_CORNERS
.right
    ld hl, hCursorX
    rrc [hl]
    ld hl, hCursorTileAddr
    ld a, [hl]
    jr c, .wrapFromLeft
    add a, 2
    ld [hl+], a
    jr nc, .checkUp
    inc [hl]
    jr .checkUp
.wrapFromLeft
    sub a, 14
    ld [hl+], a
    jr nc, .checkUp
    dec [hl]
    jr .checkUp
.left
    ld hl, hCursorX
    rlc [hl]
    ld hl, hCursorTileAddr
    ld a, [hl]
    jr c, .wrapFromRight
    sub a, 2
    ld [hl+], a
    jr nc, .checkUp
    dec [hl]
    jr .checkUp
.wrapFromRight
    add a, 14
    ld [hl+], a
    jr nc, .checkUp
    inc [hl]
    jr .checkUp
.up
    ld hl, hCursorY
    ld a, [hl]
    and a, a
    jr z, .wrapFromBottom
    dec [hl]
    ld hl, hCursorTileAddr
    ld a, [hl]
    sub a, 64
    ld [hl+], a
    ret nc
    dec [hl]
    ret
.wrapFromBottom
    ld a, 7
    ld [hl], a
    ld hl, hCursorTileAddr
    ld a, [hl]
    add a, (14 * 32) & $FF
    ld [hl+], a
    ld a, [hl]
    adc a, ((14 * 32) & $FF00) >> 8
    ld [hl], a
    ret
.down
    ld hl, hCursorY
    ld a, [hl]
    cp a, 7
    jr z, .wrapFromTop
    inc [hl]
    ld hl, hCursorTileAddr
    ld a, 64
    add a, [hl]
    ld [hl+], a
    ret nc
    inc [hl]
    ret
.wrapFromTop
    xor a
    ld [hl], a
    ld hl, hCursorTileAddr
    ld a, [hl]
    sub a, (14 * 32) & $FF
    ld [hl+], a
    ld a, [hl]
    sbc a, ((14 * 32) & $FF00) >> 8
    ld [hl], a
    ret
ELSE
.right
    ld hl, hCursorX
    ld a, [hl]
    rrca
    jr c, .checkUp
    ld [hl], a
    ld hl, hCursorTileAddr
    ld a, [hl]
    add a, 2
    ld [hl+], a
    jr nc, .checkUp
    inc [hl]
    jr .checkUp
.left
    ld hl, hCursorX
    ld a, [hl]
    rlca
    jr c, .checkUp
    ld [hl], a
    ld hl, hCursorTileAddr
    ld a, [hl]
    sub a, 2
    ld [hl+], a
    jr nc, .checkUp
    dec [hl]
    jr .checkUp
.up
    ld hl, hCursorY
    ld a, [hl]
    and a
    ret z
    dec [hl]
    ld hl, hCursorTileAddr
    ld a, [hl]
    sub a, 64
    ld [hl+], a
    ret nc
    dec [hl]
    ret
.down
    ld hl, hCursorY
    ld a, [hl]
    cp a, 7
    ret z
    inc [hl]
    ld hl, hCursorTileAddr
    ld a, 64
    add a, [hl]
    ld [hl+], a
    ret nc
    inc [hl]
    ret
ENDC ; WRAP_FROM_CORNERS
