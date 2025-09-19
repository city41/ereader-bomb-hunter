
    .area CODE (ABS)
    .org 0x100

    rst 8
    .db ERAPI_SuppressStartPauseScreen

    call game_init

main_loop:
    call game_frame

    ld a, #1
    halt
    jr main_loop
