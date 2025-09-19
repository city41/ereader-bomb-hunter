    ; ERAPI_PlaySystemSound()
    ; hl=sound number

    SOUND_BGM1=129

sound_play_bgm1:
    ld hl, SOUND_BGM1
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_stop_bgm1:
    ld hl, SOUND_BGM1
    rst 8
    .db ERAPI_PauseSound
    ret

sound_play_game_over:
    ld hl, 83
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_play_bomb_fall_sfx:
    ld hl, 20
    rst 8
    .db ERAPI_PlaySystemSound
    ret
    
sound_play_bomb_land_sfx:
    ld hl, 21
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_play_ready_sfx:
    ld hl, 176
    rst 8
    .db ERAPI_PlaySystemSound
    ret
    
sound_play_go_sfx:
    ld hl, 177
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_play_cursor_move_sfx:
    ld hl, 24
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_play_cursor_choice_sfx:
    ld hl, 3
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_play_recursive_reveal:
    ld hl, 16
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_play_nonrecursive_reveal:
    ld hl, 31
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_play_explosion:
    ld hl, 30
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_play_win_sfx:
    ld hl, 84
    rst 8
    .db ERAPI_PlaySystemSound
    ret

sound_toggle_bgm:
    ;; if game is finished, can't toggle
    ld a, (game_finished)
    cp 1
    ret z

    ld a, (_s_bgm_playing)
    cp 0
    jr z, sound_toggle_bgm__turn_bgm_on
    ;; music is on, turn it off
    ld a, 0
    ld (_s_bgm_playing), a
    call sound_stop_bgm1
    ret

    sound_toggle_bgm__turn_bgm_on:
    ;; music is off, turn it on
    ld a, 1
    ld (_s_bgm_playing), a
    call sound_play_bgm1
    ret


_s_bgm_playing:
    .db 1