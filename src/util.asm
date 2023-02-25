;   util.asm
; Utility subroutines

SECTION "Util", ROM0

Strcpy::
.copy
    ld a, [bc]
    and a
    ret z
    inc bc
    ld [hl+], a
    jr .copy
