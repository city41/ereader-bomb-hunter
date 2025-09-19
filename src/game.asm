    _G_CURSOR_BOUNDS_LEFT = 3
    _G_CURSOR_BOUNDS_RIGHT = 11
    _G_CURSOR_BOUNDS_TOP = 2
    _G_CURSOR_BOUNDS_BOTTOM = 8

game_init:
    ; ERAPI_SetBackgroundMode()
    ; a = mode (0-2)
    ld a, #0
    rst 0
    .db ERAPI_SetBackgroundMode


    call _g_load_hud
    call cursor_init
    call minimap_pre_init
    call bomb_counter_init

    ; ERAPI_FadeIn()
    ; a = number of frames
    ld a, 30
    rst 0
    .db ERAPI_FadeIn

    call playfield_gfx_render

    ld a, 98
    ld e, BG_INDEX_BACKDROP
    rst 0
    .db ERAPI_LoadSystemBackground

    call difficulty_menu

    ld a, (difficulty_choice)
    cp 3
    call z, animals_roulette

    ;; clear the difficulty/animal region
    ;; this is a hack doing it here but uses less code
    ;; because we want to the region to stay up for animals,
    ;; but the user won't always choose animals
    
    ld a, (_d_region)
    ld d, 0
    ld e, 0
    rst 0
    .db ERAPI_SetRegionColor
    rst 0
    .db ERAPI_ClearRegion

    ld a, 1
    halt

    call playfield_init
    call playfield_gfx_render

    call intro_run

    ld a, 5
    halt

    call bomb_counter_update
    call minimap_init
    call minimap_camera
    ld a, (difficulty_choice)
    cp 3
    call z, animals_discover

    ld de, 4262 ; ready
    ld a, 10
    rst 0
    .db ERAPI_CreateSystemSprite
    ;; center it
    ld de, 120
    ld bc, 80
    rst 0
    .db ERAPI_SetSpritePos
    ld a, 1
    halt

    push hl
    call sound_play_ready_sfx
    pop hl

    ld a, 44
    halt

    ;; hide ready
    rst 0
    .db ERAPI_SpriteHide

    call cursor_render


    ld de, 4261 ; go
    ld a, 10
    rst 0
    .db ERAPI_CreateSystemSprite
    ;; center it
    ld de, 120
    ld bc, 80
    rst 0
    .db ERAPI_SetSpritePos
    ld a, 1
    halt

    push hl
    call sound_play_go_sfx
    pop hl

    ld a, 29
    halt

    ;; hide go
    rst 0
    .db ERAPI_SpriteHide

    call sound_play_bgm1

    ret


game_frame:
    call repeat_input_read

    ld hl, (input_repeat_pressed)
    ld a, l
    and ERAPI_KEY_RIGHT
    call nz, _g_handle_right

    ld hl, (input_repeat_pressed)
    ld a, l
    and ERAPI_KEY_LEFT
    call nz, _g_handle_left

    ld hl, (input_repeat_pressed)
    ld a, l
    and ERAPI_KEY_DOWN
    call nz, _g_handle_down

    ld hl, (input_repeat_pressed)
    ld a, l
    and ERAPI_KEY_UP
    call nz, _g_handle_up

    ld hl, (SYS_INPUT_JUST)
    ld a, l
    and ERAPI_KEY_A
    call nz, _g_handle_a

    ld hl, (SYS_INPUT_JUST)
    ld a, l
    and ERAPI_KEY_B
    call nz, _g_handle_b

    ld hl, (SYS_INPUT_JUST)
    ld a, h
    and ERAPI_KEY_L
    call nz, sound_toggle_bgm

    ld a, (game_finished)
    cp 1
    ret z

    ;; see if the game has been won
    ld hl, (p_undiscovered_count)
    ld a, h
    cp 0
    ;; if h isn't zero, then there's >255 undiscovered tiles
    ret nz
    ;; now compare undiscoverd count to bomb count
    ld b, l
    ld a, (p_bomb_count)
    cp b
    ;; not the same? there's still more tiles to discover
    ret nz

    ;; they are the same? the only tiles left are bombs, ie player has won
    call sound_stop_bgm1

    ;; was this medium difficulty? if so, record the achievement if needed
    ld a, (difficulty_choice)
    cp 1
    jp nz, _game_frame__skip_save_achievement
    ;; has it already been recorded?
    ld a, (_g_achievement_recorded)
    cp 1
    jp z, _game_frame__skip_save_achievement
    ;; it hasn't been recorded this session, record it
    ld b, ACHIEVEMENTS_BOMBHUNTER
    call common_save_achievement_if_needed
    ld a, b
    cp 1
    call z, common_play_achievement_sfx
    ld a, 1
    ld (_g_achievement_recorded), a

    _game_frame__skip_save_achievement:
    ld a, 1
    ld (game_finished), a

    ;; turn over all the bombs
    call _p_game_over_reveal_board
    call playfield_gfx_render

    ;; wait just a bit
    ld a, 60
    halt

    ld de, 4255 ; all clear
    call sound_play_win_sfx
    ld a, 10
    rst 0
    .db ERAPI_CreateSystemSprite

    ;; center it
    ld de, 120
    ld bc, 80
    rst 0
    .db ERAPI_SetSpritePos

    ;; stall a bit to hear the jingle
    ld a, 220
    halt

    ret

_g_restart:
    call sound_stop_bgm1
    ld a, 1 ;; restart parameter
    rst 8
    .db ERAPI_Exit

game_on_lose:
    ld de, 4150 ; game over
    ld a, 10
    rst 0
    .db ERAPI_CreateSystemSprite

    ;; center it
    ld de, 120
    ld bc, 80
    rst 0
    .db ERAPI_SetSpritePos

    ld a, 1
    ld (game_finished), a
    ret

_g_handle_right:
    ;; dont allow the cursor to go beyond the playfield
    ld a, (cursor_board_x)
    ld b, a
    ld a, (p_playfield_w)
    sub 2
    cp b
    ret c

    call sound_play_cursor_move_sfx
    ;; go right within the board itself
    call cursor_go_right_in_board

    ;; now either move the cursor on screen if it is within the bounding area
    ;; otherwise, scroll the playfield
    ld a, (cursor_screen_x)
    cp _G_CURSOR_BOUNDS_RIGHT
    
    jr c, _g_handle_right__move_cursor_on_screen
    ;; if we got here, the cursor is against the boundary
    ;; so instead need to scroll the playfield
    call playfield_camera_right
    call playfield_gfx_render
    call minimap_camera
    ret

    _g_handle_right__move_cursor_on_screen:
    ;; if got here, the cursor needs to move
    call cursor_go_right_on_screen
    call cursor_render
    ret

_g_handle_left:
    ;; dont allow the cursor to go beyond the playfield
    ld a, (cursor_board_x)
    cp 0
    ret z

    call sound_play_cursor_move_sfx
    ;; go left within the board itself
    call cursor_go_left_in_board

    ;; now either move the cursor on screen if it is within the bounding area
    ;; otherwise, scroll the playfield
    ld a, (cursor_screen_x)
    cp _G_CURSOR_BOUNDS_LEFT+1
    
    jr nc, _g_handle_left__move_cursor_on_screen
    ;; if we got here, the cursor is against the boundary
    ;; so instead need to scroll the playfield
    call playfield_camera_left
    call playfield_gfx_render
    call minimap_camera
    ret

    _g_handle_left__move_cursor_on_screen:
    ;; if got here, the cursor needs to move
    call cursor_go_left_on_screen
    call cursor_render
    ret

_g_handle_up:
    ;; dont allow the cursor to go beyond the playfield
    ld a, (cursor_board_y)
    cp 0
    ret z

    call sound_play_cursor_move_sfx
    ;; go up within the board itself
    call cursor_go_up_in_board

    ;; now either move the cursor on screen if it is within the bounding area
    ;; otherwise, scroll the playfield
    ;; special case: easy always moves the cursor and never the camera
    ld a, (difficulty_choice)
    cp 0
    jr z, _g_handle_up__move_cursor_on_screen

    ld a, (cursor_screen_y)
    cp _G_CURSOR_BOUNDS_TOP+1
    
    jr nc, _g_handle_up__move_cursor_on_screen
    ;; if we got here, the cursor is against the boundary
    ;; so instead need to scroll the playfield
    call playfield_camera_up
    call playfield_gfx_render
    call minimap_camera
    ret

    _g_handle_up__move_cursor_on_screen:
    ;; if got here, the cursor needs to move
    call cursor_go_up_on_screen
    call cursor_render
    ret

_g_handle_down:
    ;; dont allow the cursor to go beyond the playfield
    ld a, (cursor_board_y)
    ld b, a
    ld a, (p_playfield_h)
    sub 2
    cp b
    ret c

    call sound_play_cursor_move_sfx
    ;; go down within the board itself
    call cursor_go_down_in_board

    ;; now either move the cursor on screen if it is within the bounding area
    ;; otherwise, scroll the playfield
    ;; special case: easy always moves the cursor and never the camera
    ld a, (difficulty_choice)
    cp 0
    jr z, _g_handle_down__move_cursor_on_screen

    ld a, (cursor_screen_y)
    cp _G_CURSOR_BOUNDS_BOTTOM
    
    jr c, _g_handle_down__move_cursor_on_screen
    ;; if we got here, the cursor is against the boundary
    ;; so instead need to scroll the playfield
    call playfield_camera_down
    call playfield_gfx_render
    call minimap_camera
    ret

    _g_handle_down__move_cursor_on_screen:
    ;; if got here, the cursor needs to move
    call cursor_go_down_on_screen
    call cursor_render
    ret


_g_handle_a:
    ;; if game is over, waiting for user to press a to restart
    ld a, (game_finished)
    cp 1
    ;; they pressed a
    jp z, _g_restart

    _g_handle_a__game_not_over:
    ld a, (cursor_board_x)
    ld b, a
    ld a, (cursor_board_y)
    ld c, a
    call playfield_discover_tile
    ;; incase recursive discovery wiped out some flags
    call bomb_counter_update
    ret

_g_handle_b:
    ;; if game is over, don't allow flagging
    ld a, (game_finished)
    cp 1
    ret z

    ld a, (cursor_board_x)
    ld b, a
    ld a, (cursor_board_y)
    ld c, a
    call playfield_flag_tile
    call playfield_gfx_render
    call bomb_counter_update
    ret

_g_load_hud:
    ; ERAPI_SpriteCreate()
    ; e  = pal#
    ; hl = sprite data
    ld  e, 14
    ld  hl, _g_sprite_hud
    rst 0
    .db ERAPI_SpriteCreate

    ; move it into position
    ld de, 21
    ld bc, 45
    rst 0
    .db ERAPI_SetSpritePos
    ret

_game_r_count:
    .db 0

game_finished:
    .db 0

_g_achievement_recorded:
    .db 0

    .even
_g_sprite_hud:
    .dw _g_tiles_hud  ; tiles
    .dw _pg_palette_playfield ; palette
    .db 0x05          ; width
    .db 0x07          ; height
    .db 0x01          ; frames per bank
    .db 0x02          ; ?
    .db 0x00          ; hitbox width
    .db 0x00          ; hitbox height
    .db 0x01          ; total frames