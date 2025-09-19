    ANIMAL_CHOICE_LION = 0
    ANIMAL_CHOICE_SNAKE = 1
    ANIMAL_CHOICE_ELEPHANT = 2

animals_roulette:
    ; load the animals
    ; ERAPI_SpriteCreate()
    ; e  = pal#
    ; hl = sprite data
    ld  e, 0x07
    ld  hl, _a_sprite_animals
    rst 0
    .db ERAPI_SpriteCreate
    ld (_a_handle_animals), hl

    ; move it into position
    ld de, 120
    ld bc, 73
    rst 0
    .db ERAPI_SetSpritePos

    
    animals_roulette__loop:

    ld a, (animal_choice)
    inc a
    cp 3
    jr nz, _a_skip_wrap
    ld a, 0
    _a_skip_wrap:
    ld (animal_choice), a

    call _d_pos_cursor
    cp 0
    call z, sound_play_cursor_move_sfx

    ld a, 1
    halt

    ld hl, (SYS_INPUT_JUST)
    ld a, l
    and ERAPI_KEY_A
    jr nz, animals_roulette__chosen

    jr animals_roulette__loop

    animals_roulette__chosen:

    call sound_play_cursor_choice_sfx

    ld a, 60
    halt

    ;; hide the cursor
    ld hl, (_c_handle_cursor)
    ld de, 260
    ld bc, 0
    rst 0
    .db ERAPI_SetSpritePos
    ;; hide the animals
    ld hl, (_a_handle_animals)
    rst 0
    .db ERAPI_SetSpritePos


    ret

;; uses the chosen animal to discover a "shape" corresponding to that animal
;; lion: claw swipes down
;; snake: crawls across the playfield
;; elephant: four big foot prints
animals_discover:
    ;; first load the bombs
    ld a, 100
    ld (_p_no_bomb_col), a
    ld (_p_no_bomb_row), a
    call _p_load_bombs

    ld a, (animal_choice)
    cp ANIMAL_CHOICE_LION
    jr z, _a_lion
    cp ANIMAL_CHOICE_SNAKE
    jr z, _a_snake
    cp ANIMAL_CHOICE_ELEPHANT
    jp z, _a_elephant

_a_lion:
    call sound_play_recursive_reveal
    ld a, 10
    rst 8
    .db ERAPI_RandMax

    ;; the first "claw" column is in a

    ;; loop counter
    ld b, 16
    ;; row counter
    ld c, 0

    _a_lion__loop:
    push bc
    push af

    ;; discover the tile at (a, c)
    ld b, a
    ;; uncover first column
    call _a_discover

    ;; second column
    ld a, b
    add 2
    ld b, a
    call _a_discover

    ;; third column
    ld a, b
    add 3
    ld b, a
    call _a_discover

    call playfield_gfx_render
    ld a, 1
    halt

    pop af
    pop bc
    inc c
    djnz _a_lion__loop
    ret

_a_snake:
    call sound_play_recursive_reveal
    ld a, 5
    rst 8
    .db ERAPI_RandMax
    ;; a is now 5-8
    add 4

    ;; starting row
    ld c, a
    ;; starting column
    ld b, 0

    _a_snake__loop:

    call _a_snake_discover

    ;; are we done?
    ld a, b
    ;; if we are in the 29th column, we are done
    cp 29
    ret z

    ;; now move onto next tile
    ld a, 6
    rst 8
    .db ERAPI_RandMax
    cp 0
    jr nz, _a_snake__not_going_up
    ;; going up
    dec c
    ld a, c
    cp 0xff
    ;; if we haven't gone negative, we are still good
    ;; loop and go again
    jr nz, _a_snake__going_up_skip_wrap
    ;; otherwise wrap to the other side of the board
    ld c, 15

    _a_snake__going_up_skip_wrap:
    ;; in a new tile, discover it
    call _a_snake_discover

    ;; then go right and loop
    jr _a_snake__done_vertical

    _a_snake__not_going_up:
    cp 1
    jr nz, _a_snake__not_going_down
    ;; going down
    inc c
    ld a, c
    cp 16
    ;; if we haven't gone beyond the bottom, we are still good
    ;; loop and go again
    jr nz, _a_snake__going_down_skip_wrap
    ;; otherwise wrap to the other side of the board
    ld c, 0
    _a_snake__going_down_skip_wrap:
    ;; in a new tile, discover it
    call _a_snake_discover

    ;; then go right and loop
    _a_snake__done_vertical:
    _a_snake__not_going_down:
    ;; going right
    inc b
    jr _a_snake__loop

_a_snake_discover:
    ;; save row/column
    push bc
    call _a_discover
    call minimap_change_tile
    call playfield_gfx_render
    ld a, 1
    halt
    ;; restore row/column
    pop bc
    ret
    
_a_elephant:
    ld a, 5
    rst 8
    .db ERAPI_RandMax
    add 3
    ;; a is now 3-7
    ld b, a

    ld a, 4
    rst 8
    .db ERAPI_RandMax
    add 9
    ;; a is now 9-12
    ld c, a

    dec c
    dec b
    ;; (b,c) is now the upper part of first footprint

    ;; first foot print
    call _a_elephant_print

    ;; second print
    ;; move to next (b,c)
    ld a, b
    add 6
    ld b, a
    ld a, c
    sub 6
    ld c, a

    call _a_elephant_print

    ;; third print
    ;; move to next (b,c)
    ld a, b
    add 6
    ld b, a
    ld a, c
    add 6
    ld c, a

    call _a_elephant_print

    ;; fourth print
    ;; move to next (b,c)
    ld a, b
    add 6
    ld b, a
    ld a, c
    sub 6
    ld c, a

    call _a_elephant_print
    ret

;; given a starting tile in (b,c)
;; discovers an elephant print
_a_elephant_print:
    push bc
    push af

    inc b
    call _a_discover
    inc b
    call _a_discover
    dec b
    dec b
    inc c
    call _a_discover
    inc b
    call _a_discover
    inc b
    call _a_discover
    inc b
    call _a_discover
    dec b
    dec b
    dec b
    inc c
    call _a_discover
    inc b
    call _a_discover
    inc b
    call _a_discover
    inc b
    call _a_discover
    dec b
    dec b
    inc c
    call _a_discover
    inc b
    call _a_discover

    call playfield_gfx_render
    ld a, 1
    halt

    call sound_play_recursive_reveal
    ld a, 30
    halt

    pop af
    pop bc
    ret

;; discovers the tile at (b,c)
;; assumes the tile at (b,c) has not already been discovered
;; if it has, p_undiscovered_count will drift off
_a_discover:
    push af
    call _p_get_pointer_to_tile
    ;; load the tile into a
    ld a, (hl)

    ;; is it a bomb?
    ld d, a
    and PLAYFIELD_BOMB_FLAG
    jr z, _a_discover__not_bomb
    ;; this is a bomb, we need to flag it
    ;; first, decrement outstanding bomb count
    ld a, (p_outstanding_bomb_count)
    dec a
    ld (p_outstanding_bomb_count), a
    push hl
    call bomb_counter_update
    pop hl
    ld e, MINIMAP_FLAGGED
    ld a, PLAYFIELD_UNDISCOVERED_FLAGGED_CORRECTLY_BOMB 
    jr _a_discover__save

    _a_discover__not_bomb:
    ;; decrement undiscovered count
    push hl
    ld hl, (p_undiscovered_count)
    dec hl
    ld (p_undiscovered_count), hl
    pop hl

    ld e, MINIMAP_DISCOVERED
    ld a, d
    ;; uncover it
    and 0x7f
    _a_discover__save:
    ;; and save it back
    ld (hl), a
    call minimap_change_tile
    pop af
    ret

    .even
_a_sprite_animals:
    .dw _a_tiles_animals  ; tiles
    .dw _pg_palette_playfield; palette
    .db 0x02          ; width
    .db 0x06          ; height
    .db 0x01          ; frames per bank
    .db 0x02          ; ?
    .db 0x00          ; hitbox width
    .db 0x00          ; hitbox height
    .db 0x01          ; total frames

_a_handle_animals:
    .dw 0

animal_choice:
    .db 2