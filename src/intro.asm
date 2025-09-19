    _I_BOMB_DROP_VELOCITY = 600

intro_run:
    ;; inlining this actually increases file size...
    call _i_automove_bombs

    ;; load the playfield cover sprite
    ; ERAPI_SpriteCreate()
    ; e  = pal#
    ; hl = sprite data
    ld  e, 0x04
    ld  hl, _i_sprite_playfield_cover
    rst 0
    .db ERAPI_SpriteCreate
    ld (_i_playfield_cover_handle), hl

    ; ERAPI_SetSpritePos()
    ; hl = handle
    ; de = x
    ; bc = y
    ld   de, 120
    ld   bc, 128
    rst  0
    .db  ERAPI_SetSpritePos

    push hl
    call playfield_gfx_open_hole

    ld a, 30
    halt
    call sound_play_bomb_fall_sfx

    ld a, 50
    halt
    call sound_play_bomb_land_sfx

    ld a, 30
    halt

    call playfield_gfx_close_hole

    ;; free the cover sprite
    pop hl
    rst 0
    .db ERAPI_SpriteFree

    call _i_free_bombs
    ret

_i_automove_bombs:
    ;; create bomb sprite 1
    ld  e, 0x03
    ld  hl, _i_sprite_bomb
    rst 0
    .db ERAPI_SpriteCreate
    ld (_i_bomb_handles), hl

    ; ERAPI_SetSpritePos()
    ; hl = handle
    ; de = x
    ; bc = y
    ld   de, 120
    ld   bc, -8
    rst  0
    .db  ERAPI_SetSpritePos

    ld a, 3
    rst 8
    .db ERAPI_RandMax
    ld e, a
    rst 0
    .db ERAPI_SetSpriteFrame

    ld de, 0
    ld bc, _I_BOMB_DROP_VELOCITY
    rst 0
    .db ERAPI_SpriteAutoMove

    ;; create bomb sprite 2
    ld  e, 0x03
    ld  hl, _i_sprite_bomb
    rst 0
    .db ERAPI_SpriteCreate
    ld (_i_bomb_handles + 2), hl

    ; ERAPI_SetSpritePos()
    ; hl = handle
    ; de = x
    ; bc = y
    ld   de, 116
    ld   bc, -32
    rst  0
    .db  ERAPI_SetSpritePos

    ld a, 3
    rst 8
    .db ERAPI_RandMax
    ld e, a
    rst 0
    .db ERAPI_SetSpriteFrame

    ld de, 0
    ld bc, _I_BOMB_DROP_VELOCITY
    rst 0
    .db ERAPI_SpriteAutoMove

    ;; create bomb sprite 3
    ld  e, 0x03
    ld  hl, _i_sprite_bomb
    rst 0
    .db ERAPI_SpriteCreate
    ld (_i_bomb_handles + 4), hl

    ; ERAPI_SetSpritePos()
    ; hl = handle
    ; de = x
    ; bc = y
    ld   de, 124
    ld   bc, -52
    rst  0
    .db  ERAPI_SetSpritePos

    ld a, 3
    rst 8
    .db ERAPI_RandMax
    ld e, a
    rst 0
    .db ERAPI_SetSpriteFrame

    ld de, 0
    ld bc, _I_BOMB_DROP_VELOCITY
    rst 0
    .db ERAPI_SpriteAutoMove

    ;; create bomb sprite 4
    ld  e, 0x03
    ld  hl, _i_sprite_bomb
    rst 0
    .db ERAPI_SpriteCreate
    ld (_i_bomb_handles + 6), hl

    ; ERAPI_SetSpritePos()
    ; hl = handle
    ; de = x
    ; bc = y
    ld   de, 120
    ld   bc, -73
    rst  0
    .db  ERAPI_SetSpritePos

    ld a, 3
    rst 8
    .db ERAPI_RandMax
    ld e, a
    rst 0
    .db ERAPI_SetSpriteFrame

    ld de, 0
    ld bc, _I_BOMB_DROP_VELOCITY
    rst 0
    .db ERAPI_SpriteAutoMove
    ret

_i_free_bombs:
    ld b, 4

    _i_free_bombs__loop:
    ;; get pointer to strt of list
    ld hl, _i_bomb_handles
    ;; index into that list how far we are based on b counter
    ld d, 0
    ld e, b
    ;; dec because b loops are one based
    dec e
    ;; move the pointer forward
    add hl, de
    add hl, de
    ;; load the handle
    ld e, (hl)
    inc hl
    ld d, (hl)
    ;; move it to hl
    push de
    pop hl

    rst 0
    .db ERAPI_SpriteFree
    djnz _i_free_bombs__loop
    ret

    .even
_i_sprite_bomb:
    ; _i_tiles_bomb is defined in playfieldTiles.tiles.asm
    .dw _i_tiles_bomb  ; tiles
    .dw _pg_palette_playfield; palette
    .db 0x02          ; width
    .db 0x02          ; height
    .db 0x01          ; frames per bank
    .db 0x00          ; ?
    .db 0x0          ; hitbox width
    .db 0x0          ; hitbox height
    .db 0x01          ; total number of frames


    .even
_i_sprite_playfield_cover:
    .dw _i_tiles_playfield_cover  ; tiles
    .dw _pg_palette_playfield; palette
    .db 0x03        ; width
    .db 0x08          ; height
    .db 0x02          ; frames per bank
    .db 0x00          ; ?
    .db 0x0          ; hitbox width
    .db 0x0          ; hitbox height
    .db 0x02          ; total frames
    .even

_i_playfield_cover_handle:
    .dw 0

_i_bomb_handles:
    .dw 0
    .dw 0
    .dw 0
    .dw 0

