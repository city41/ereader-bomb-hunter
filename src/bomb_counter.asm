    _BC_NEGATIVE_X = 17
    _BC_NEGATIVE_Y = 32

bomb_counter_init:
    ;; fill in the minimap background where the counter is with a color
    ;; this is needed due to how the backgrounds are laid out and is a bit of a hack
    ; ERAPI_CreateRegion()
    ; h = bg# (0-3)
    ; l = palette bank (0-15)
    ; d = left
    ; e = top
    ; b = width
    ; c = height
    ld h, BG_INDEX_MINIMAP_TILES
    ld l, PALETTE_INDEX_BOMB_COUNT_BG
    ld d, 0
    ld e, 3
    ld b, 4
    ld c, 2
    rst 0
    .db ERAPI_CreateRegion

    ;; now fill the region with the color index corresponding
    ;; to the dark blue of the frame
    ld d, 0
    ld e, 4
    rst 0
    .db ERAPI_SetRegionColor

    rst 0
    .db ERAPI_ClearRegion

    ; load the negative sign
    ; ERAPI_SpriteCreate()
    ; e  = pal#
    ; hl = sprite data
    ld  e, 0x05
    ld  hl, _bc_sprite_negative
    rst 0
    .db ERAPI_SpriteCreate
    ld  (_bc_handle_negative), hl

    ; move it into position
    ld de, _BC_NEGATIVE_X
    ld bc, _BC_NEGATIVE_Y
    rst 0
    .db ERAPI_SetSpritePos

    ; and hide it
    rst 0
    .db ERAPI_SpriteHide

    ;; first init the number drawing
    ld hl, _bc_number
    rst 0
    .db ERAPI_DrawNumber

    ; ERAPI_SetBackgroundPalette()
    ; hl = pointer to palette data
    ; d = palette index
    ; e = palette offset
    ; c  = number of colors
    ; ld hl, _bc_font_palette_bg
    ; ld d, PALETTE_INDEX_BOMB_COUNT
    ; ld e, 15
    ; ld c, 1
    ; rst 0
    ; .db ERAPI_SetBackgroundPalette

    ; ERAPI_SetBackgroundPalette()
    ; hl = pointer to palette data
    ; d = palette index
    ; e = palette offset
    ; c  = number of colors
    ; ld hl, _bc_font_palette_fg
    ; ld d, PALETTE_INDEX_BOMB_COUNT
    ; ld e, 1
    ; ld c, 2
    ; rst 0
    ; .db ERAPI_SetBackgroundPalette

    ;; purposly falling through

;; gets the latest outstanding bomb value
;; and renders it into the HUD
bomb_counter_update:
    ; we will have to show or hide the negative sign
    ; so just load its handle now
    ld hl, (_bc_handle_negative)
    ld a, (p_outstanding_bomb_count)

    ;; is a negative?
    cp 128
    ;; is this number positive? no massaging needed
    jr c, bomb_counter_update__positive
    ;; this number is negative, need to arrive at
    ;; the negative value ourselves as DrawNumber only supports unsigned
    ld d, a
    ld a, 255
    sub d
    inc a
    ;; a now has the negative value

    ;; show the negative sign
    rst 0
    .db ERAPI_SpriteShow
    jr bomb_counter_update__draw_number

    bomb_counter_update__positive:

    ;; hide the negative sign
    rst 0
    .db ERAPI_SpriteHide

    bomb_counter_update__draw_number:
    ld d, 0
    ld e, a

    ld hl, _bc_number
    rst 0
    .db ERAPI_DrawNumberNewValue
    ret

    .even
_bc_number:
    .db BG_INDEX_BOMB_COUNT
    .db PALETTE_INDEX_BOMB_COUNT ; palette #
    .db 2 ; x in tiles
    .db 3 ; y in tiles
    .dw 4112 ; system sprite to use as the font
    .db 2 ; number of digits
    .db 0 ; number of extra zeroes on right
    .db 0 ; 0 fill with spaces, 1 fill with zeroes
    .db 0 ; loaded sprite?
    .dw 0 ; value

_bc_font_palette_bg:
    .dw 0x47
_bc_font_palette_fg:
    .dw 0x7fff, 0x7fff

    .even
_bc_sprite_negative:
    .dw _bc_tiles_negative  ; tiles
    .dw _pg_palette_playfield; palette
    .db 0x01          ; width
    .db 0x01          ; height
    .db 0x01          ; frames per bank
    .db 0x02          ; ?
    .db 0x00          ; hitbox width
    .db 0x00          ; hitbox height
    .db 0x01          ; total frames

    .even
_bc_handle_negative:
    .ds 2