    ;; nudges for the cursor so it points exactly at the current tile
    _C_OFFSET_X = -2
    _C_OFFSET_Y = 8
cursor_init:
    ; ERAPI_SpriteCreate()
    ; e  = pal#
    ; hl = sprite data
    ld  e, #0x02
    ld  hl, _c_sprite_cursor
    rst 0
    .db ERAPI_SpriteCreate
    ld  (_c_handle_cursor), hl

    ;; auto animate the hand back and forth for a simple bob
    ;; hl = sprite handle
    ;; de = sprite frame duration in system frames
    ;; bc =
    ;; bc: 0 = Start Animating Forever
    ;;     1 = Stop Animation
    ;;     2 > Number of frames to animate for -2 (ex. 12 animates for 10 frames)
    ld de, 45
    ld bc, 0
    rst 0
    .db ERAPI_SpriteAutoAnimate

    ret

cursor_go_left_in_board:
    ld a, (cursor_board_x)
    dec a
    ld (cursor_board_x), a
    ret

cursor_go_left_on_screen:
    ld a, (cursor_screen_x)
    dec a
    ld (cursor_screen_x), a
    ret

cursor_go_right_in_board:
    ld a, (cursor_board_x)
    inc a
    ld (cursor_board_x), a
    ret

cursor_go_right_on_screen:
    ld a, (cursor_screen_x)
    inc a
    ld (cursor_screen_x), a
    ret

cursor_go_up_in_board:
    ld a, (cursor_board_y)
    dec a
    ld (cursor_board_y), a
    ret

cursor_go_up_on_screen:
    ld a, (cursor_screen_y)
    dec a
    ld (cursor_screen_y), a
    ret

cursor_go_down_in_board:
    ld a, (cursor_board_y)
    inc a
    ld (cursor_board_y), a
    ret

cursor_go_down_on_screen:
    ld a, (cursor_screen_y)
    inc a
    ld (cursor_screen_y), a
    ret

cursor_render:
    ;; load up cursor screen x
    ld a, (cursor_screen_x)
    ld d, 0
    ld e, a
    ld hl, 16
    rst 8
    ;; hl = hl*de
    .db ERAPI_Mul16
    ;; add in the offset
    ld b, -1 ;; this allows the 8 bit negative value to become 16 bit
    ld c, _C_OFFSET_X
    add hl, bc
    ;; save tile x to the stack
    push hl

    ;; load up cursor screen y
    ld a, (cursor_screen_y)
    ld d, 0
    ld e, a
    ld hl, 16
    rst 8
    ;; hl = hl*de
    .db ERAPI_Mul16
    ;; add in the offset
    ld b, 0
    ld c, _C_OFFSET_Y
    add hl, bc
    ;; save tile y to the stack
    push hl

    ;; load tile y where ERAPI needs it
    pop bc
    ;; load tile x where ERAPI needs it
    pop de

    ; move the cursor
    ; ERAPI_SetSpritePos()
    ; hl = handle
    ; de = x
    ; bc = y
    ld hl, (_c_handle_cursor)
    rst  0
    .db  ERAPI_SetSpritePos
    ret

    .even
_c_sprite_cursor:
    .dw _c_tiles_cursor  ; tiles
    .dw _pg_palette_playfield; palette
    .db 0x02          ; width
    .db 0x02          ; height
    .db 0x02          ; frames
    .db 0x02          ; ?
    .db 0x00          ; hitbox width
    .db 0x00          ; hitbox height
    .db 0x01          ; total frames

    .even
_c_handle_cursor:
    .ds 2

cursor_board_x:
    .db 7
cursor_board_y:
    .db 5
cursor_screen_x:
    .db 7
cursor_screen_y:
    .db 5