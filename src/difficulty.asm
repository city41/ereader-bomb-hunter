    _D_TEXT_Y_OFFSET = 51

    _D_REGION_BG_COLOR_INDEX = 6
difficulty_menu:

    ; ERAPI_CreateRegion()
    ; h = bg# (0-3)
    ; l = palette bank (0-15)
    ; d = left
    ; e = top
    ; b = width
    ; c = height
    ld h, BG_INDEX_DIFFICULTY
    ld l, PALETTE_INDEX_DIFFICULTY_MENU
    ld d, 12
    ld e, 0
    ld b, 6
    ld c, 20
    rst 0
    .db ERAPI_CreateRegion
    ld (_d_region), a

    ld d, _D_REGION_BG_COLOR_INDEX
    ld e, _D_REGION_BG_COLOR_INDEX
    rst 0
    .db ERAPI_SetRegionColor

    ;; as clear region is really "fill region with current region color"
    rst 0
    .db ERAPI_ClearRegion

    ;; load the diamond diff sprite
    ; ERAPI_SpriteCreate()
    ; e  = pal#
    ; hl = sprite data
    ld  e, #0x02
    ld  hl, _d_sprite_diamonds
    rst 0
    .db ERAPI_SpriteCreate
    ld (_d_handle_diamonds), hl

    ; move it into position
    ld de, 120
    ld bc, 78
    rst 0
    .db ERAPI_SetSpritePos

    ;; move the cursor next to easy
    ld a, 0
    call _d_pos_cursor

    difficulty_menu__loop:
    ld a, 1
    halt

    ld hl, (SYS_INPUT_JUST)
    ld a, l
    and ERAPI_KEY_UP
    call nz, _d_handle_up

    ld hl, (SYS_INPUT_JUST)
    ld a, l
    and ERAPI_KEY_DOWN
    call nz, _d_handle_down

    ld hl, (SYS_INPUT_JUST)
    ld a, l
    and ERAPI_KEY_A
    jr z, difficulty_menu__loop

    ;; a was pressed, clean up and exit

    ;; if L-shoulder, R-shoulder, select and start are all pressed,
    ;; change expert bomb count to 9
    ld hl, (SYS_INPUT_RAW)
    ld a, l
    and ERAPI_KEY_START
    jr z, difficulty_menu__skip_9
    ld a, l
    and ERAPI_KEY_SELECT
    jr z, difficulty_menu__skip_9
    ld a, h
    and ERAPI_KEY_L
    jr z, difficulty_menu__skip_9
    ld a, h
    and ERAPI_KEY_R
    jr z, difficulty_menu__skip_9
    ;; all were held down, drop bombs
    ld hl, _p_hard + 2
    ld a, 9
    ld (hl), a

    difficulty_menu__skip_9: 
    call sound_play_cursor_choice_sfx
    ;; delay a bit, mostly to hear the sfx
    ld a, 30
    halt

    ld a, (_d_region)
    rst 0
    .db ERAPI_ClearRegion

    ;; hide the cursor
    ld hl, (_c_handle_cursor)
    ld de, 260
    ld bc, 0
    rst 0
    .db ERAPI_SetSpritePos
    ld hl, (_d_handle_diamonds)
    rst 0
    .db ERAPI_SetSpritePos

    ret

_d_handle_up:
    ld a, (difficulty_choice)
    dec a
    cp 0xff
    jr nz, _d_finalize_move
    ld a, 3
    jr _d_finalize_move

_d_handle_down:
    ld a, (difficulty_choice)
    inc a
    cp 4
    jr nz, _d_finalize_move
    ld a, 0

    _d_finalize_move:
    ld (difficulty_choice), a
    call _d_pos_cursor
    call sound_play_cursor_move_sfx
    ret

;; positions the cursor based on the current selection
;;
;; parameters:
;; a: current choice
_d_pos_cursor:
    ld e, 16
    rst 8
    .db ERAPI_Mul8
    ld bc, 59
    add hl, bc
    push hl
    pop bc

    ld hl, (_c_handle_cursor)
    ld de, 86
    rst 0
    .db ERAPI_SetSpritePos
    ret

difficulty_choice:
    .db 0

_d_region:
    .db 0

    .even
_d_sprite_diamonds:
    .dw _d_tiles_diamonds  ; tiles
    .dw _pg_palette_playfield; palette
    .db 0x03          ; width
    .db 0x08          ; height
    .db 0x01          ; frames per bank
    .db 0x02          ; ?
    .db 0x00          ; hitbox width
    .db 0x00          ; hitbox height
    .db 0x01          ; total frames
_d_handle_diamonds:
    .dw 0