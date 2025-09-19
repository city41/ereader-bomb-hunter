
common_play_achievement_sfx:
    ld hl, 11
    rst 8
    .db ERAPI_PlaySystemSound
    ret