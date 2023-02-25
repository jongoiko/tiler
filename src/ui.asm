;   ui.asm
; The subroutine DrawUI draws the box the currently being edited tile will be
; shown in. WARNING: as these tiles are static and the subroutine is only
; supposed to be called once (before turning the LCD on), it doesn't wait for
; VBlank

INCLUDE "fontmap.asm"

BOX_START_POS EQU $9801

TLCORNER_TILENUM   EQU 5
TLINE_TILENUM      EQU 6
TRCORNER_TILENUM   EQU 7
RLINE_TILENUM      EQU 8
BRCORNER_TILENUM   EQU 9
BLINE_TILENUM      EQU 10
BLCORNER_TILENUM   EQU 11
LLINE_TILENUM      EQU 12
LFADEDLINE_TILENUM EQU 13
RFADEDLINE_TILENUM EQU 14

UPPER_TEXT EQUS "\" tiler \""
TEXT_LEN   EQU STRLEN(UPPER_TEXT)
TEXT_POS   EQU $980A - TEXT_LEN / 2

SECTION "UI", ROM0

; Draw the UI.
; OUT:
;     Addresses starting from BOX_START_POS corresponding to the UI will be set
;     as such.
;     A:  destroyed
;     B:  destroyed
;     HL: destroyed
DrawUI::
; Draw the box
    ld a, TLCORNER_TILENUM
    ld [BOX_START_POS], a
    
    ld hl, BOX_START_POS+1
    ld b, 16
    ld a, TLINE_TILENUM
.drawTLines
    ld [hl+], a
    dec b
    jr nz, .drawTLines

    ld [hl], TRCORNER_TILENUM

    ld b, 17
.drawRLines
    ld a, l
    add a, 32
    ld l, a
    jr nc, .noCarry
    inc h
.noCarry
    ld [hl], RLINE_TILENUM
    dec b
    jr nz, .drawRLines
   
    ld [hl], BRCORNER_TILENUM

    ld b, 16
.drawBLines
    dec l
    ld [hl], BLINE_TILENUM
    dec b
    jr nz, .drawBLines

    dec l
    ld [hl], BLCORNER_TILENUM
    
    ld b, 16
.drawLLines
    ld a, l
    sub a, 32
    ld l, a
    jr nc, .noCarry_
    dec h
.noCarry_
    ld [hl], LLINE_TILENUM
    dec b
    jr nz, .drawLLines

; Draw the text and its borders
    ld hl, TEXT_POS -1
    ld [hl], LFADEDLINE_TILENUM
    
    ld bc, .upperText
    ld hl, TEXT_POS
    call Strcpy
    
    ld hl, TEXT_POS + TEXT_LEN
    ld [hl], RFADEDLINE_TILENUM

    ret
.upperText:
    db UPPER_TEXT, 0
