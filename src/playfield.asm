; - undiscovered                                 - [10000000] - 0x80 - 128
; - undiscovered, flagged (incorrectly, no bomb) - [10100000] - 0xa0 - 160
; - undiscovered, flagged (correctly, bomb)      - [11100000] - 0xd0 - 224
; - discovered, bomb, hit by player              - [01000000] - 0x40 - 64
; - discovered, bomb, revealed after game over   - [01010000] - 0x50 - 80
; - discovered, empty                            - [00000000] - 0
; - discovered, bomb count 1                     - [00000001] - 1
; - discovered, bomb count 2                     - [00000010] - 2
; - discovered, bomb count 3                     - [00000011] - 3
; - discovered, bomb count 4                     - [00000100] - 4
; - discovered, bomb count 5                     - [00000101] - 5
; - discovered, bomb count 6                     - [00000110] - 6
; - discovered, bomb count 7                     - [00000111] - 7
; - discovered, bomb count 8                     - [00001000] - 8
; - undiscovered, empty                          - [10000000] - 128
; - undiscovered, bomb count 1                   - [10000001] - 129
; - undiscovered, bomb count 2                   - [10000010] - 130
; - undiscovered, bomb count 3                   - [10000011] - 131
; - undiscovered, bomb count 4                   - [10000100] - 132
; - undiscovered, bomb count 5                   - [10000101] - 133
; - undiscovered, bomb count 6                   - [10000110] - 134
; - undiscovered, bomb count 7                   - [10000111] - 135
; - undiscovered, bomb count 8                   - [10001000] - 136

;  76543210
; [SBFRCCCC]

; S - state = 1 undiscovered, 0 discovered
; B - bomb = 0 no bomb, 1 bomb
; F - flagged = 0 not flagged, 1 flagged
; C - bomb adjacency count, 0-8 inclusive
; R - bomb revealed after game over

    PLAYFIELD_UNDISCOVERED = 128
    PLAYFIELD_UNDISCOVERED_FLAGGED = 160
    PLAYFIELD_BOMB_FLAG = 0x40
    PLAYFIELD_FLAGGED_FLAG = 0x20
    ;; all bits are set except for the flagged bit
    ;; used to unflag tiles
    PLAYFIELD_CLEAR_FLAGGED_MASK = 0xdf
    PLAYFIELD_BOMB_HIT_BY_PLAYER = 64
    PLAYFIELD_REVEALED_AFTER_GAME_OVER_BOMB = 80

    PLAYFIELD_UNDISCOVERED_FLAGGED_CORRECTLY_BOMB = 224

    P_REVEAL_RENDER_THRESHOLD = 12

    _P_MAX_PLAYFIELD_WIDTH = 30
    _P_MAX_PLAYFIELD_HEIGHT = 16
    _P_MAX_PLAYFIELD_SIZE = _P_MAX_PLAYFIELD_WIDTH * _P_MAX_PLAYFIELD_HEIGHT

playfield_init:
    ;; set up the parameters based on chosen difficulty
    ld hl, _p_easy
    ld a, (difficulty_choice)
    cp 3
    jr nz, playfield_init__animals_not_chosen
    ;; animal was chosen, which is really just expert
    dec a
    playfield_init__animals_not_chosen:
    ld b, 0
    ld c, a
    ;; five times since the difficulty structs are three bytes
    add hl, bc
    add hl, bc
    add hl, bc
    add hl, bc
    add hl, bc

    ;; width
    ld a, (hl)
    ld (p_playfield_w), a
    ;; height
    inc hl
    ld a, (hl)
    ld (p_playfield_h), a
    ;; bomb count
    inc hl
    ld a, (hl)
    ld (p_bomb_count), a
    ld (p_outstanding_bomb_count), a
    ;; camera x
    inc hl
    ld a, (hl)
    ld (p_playfield_camera_x), a
    ;; cursor x needs to be adjusted based on starting camera too
    ld b, a
    ld a, (cursor_board_x)
    add b
    ld (cursor_board_x), a
    ;; camera y
    inc hl
    ld a, (hl)
    ld (p_playfield_camera_y), a
    ;; cursor y needs to be adjusted based on starting camera too
    ld b, a
    ld a, (cursor_board_y)
    add b
    ld (cursor_board_y), a

    ld b, _P_MAX_PLAYFIELD_WIDTH
    ld hl, p_playfield
    ld a, PLAYFIELD_UNDISCOVERED

    playfield_init__outer_loop:
    push bc
    ld b, _P_MAX_PLAYFIELD_HEIGHT
    playfield_init__inner_loop:
    ld (hl), a
    inc hl
    djnz playfield_init__inner_loop
    pop bc
    djnz playfield_init__outer_loop

    ;; set up undiscovered count
    ld a, (p_playfield_w)
    ld e, a
    ld a, (p_playfield_h)
    rst 8
    .db ERAPI_Mul8
    ;; hl now has w*h
    ld (p_undiscovered_count), hl
    ret

playfield_camera_right:
    ld a, (p_playfield_camera_x)
    inc a
    ld (p_playfield_camera_x), a
    ret

playfield_camera_left:
    ld a, (p_playfield_camera_x)
    dec a
    ld (p_playfield_camera_x), a
    ret

playfield_camera_down:
    ld a, (p_playfield_camera_y)
    inc a
    ld (p_playfield_camera_y), a
    ret

playfield_camera_up:
    ld a, (p_playfield_camera_y)
    dec a
    ld (p_playfield_camera_y), a
    ret

;; loads the playfield up with bombs
;; will not place a bomb at _p_no_bomb_col/row
_p_load_bombs:
    ;; loop counter
    ld a, (p_bomb_count)
    ld b, a

    _p_load_bombs__loop:
    ld a, (p_playfield_w)
    rst 8
    ; a is randomly populated [0-a)
    .db ERAPI_RandMax
    ;; move the random column into memory
    ld (_p_load_bombs_col), a
    ld a, (p_playfield_h)
    rst 8
    .db ERAPI_RandMax
    ;; move the random row into memory
    ld (_p_load_bombs_row), a

    ;; have we chosen the safe spot?
    ld a, (_p_no_bomb_col)
    ld d, a
    ld a, (_p_load_bombs_col)
    cp d
    ;; if the columns dont match, can't be the safe spot
    jr nz, _p_load_bombs__not_safe_spot
    ;; if we got here, the columns match
    ld a, (_p_no_bomb_row)
    ld d, a
    ld a, (_p_load_bombs_row)
    cp d
    ;; if the rows match, this is the safe spot, try again
    jr z, _p_load_bombs__loop

    _p_load_bombs__not_safe_spot:
    ;; now to get the value at this row/col
    ;; save the loop counter
    push bc
    ;; move the row into c
    ld a, (_p_load_bombs_row)
    ld c, a
    ld a, (_p_load_bombs_col)
    ld b, a
    ;; now that b=col and c=row, can get the value
    call playfield_get_tile_value
    pop bc
    ;; copy the value into d for safe keeping
    ld d, a
    ;; is there already a bomb in this spot?
    and PLAYFIELD_BOMB_FLAG
    ;; there is already a bomb here, so try again
    jr nz, _p_load_bombs__loop

    ;; there is no bomb here, place one
    ;; need to get a pointer to the tile
    push bc
    ld a, (_p_load_bombs_col)
    ld b, a
    ld a, (_p_load_bombs_row)
    ld c, a
    ;; with b=col and c=row, can get a pointer to the tile
    call _p_get_pointer_to_tile
    pop bc

    ;; restore the tile value into a
    ld a, d
    ;; set the bomb flag
    or PLAYFIELD_BOMB_FLAG
    ;; now a has the proper value, stick it back in the playfield
    ld (hl), a
    call _p_inc_surrounding_bomb_count
    ;; and let's go do it again
    djnz _p_load_bombs__loop
    ret

;; For the given tile at (_p_load_bombs_col,_p_load_bombs_row),
;; increments the surrounding tile bomb count
;;
;; parameters
;; _p_load_bombs_col
;; _p_load_bombs_row
_p_inc_surrounding_bomb_count:
    push bc

    ;; first check entire left column
    ld a, (_p_load_bombs_col)
    dec a
    cp -1
    jr z, _p_inc_surrounding_bomb_count__skip_l
    ;; we have a left column
    ;; do we have upper left?
    ld a, (_p_load_bombs_row)
    dec a
    cp -1
    jr z, _p_inc_surrounding_bomb_count__skip_ul
    ;; ok we have upper left, increment it
    ld a, (_p_load_bombs_col)
    dec a
    ld b, a
    ld a, (_p_load_bombs_row)
    dec a
    ld c, a
    call _p_inc_bomb_count
    _p_inc_surrounding_bomb_count__skip_ul:
    ;; we have left, increment it
    ld a, (_p_load_bombs_col)
    dec a
    ld b, a
    ld a, (_p_load_bombs_row)
    ld c, a
    call _p_inc_bomb_count
    ;; now do we have lower left?
    ld a, (p_playfield_h)
    ld d, a
    ld a, (_p_load_bombs_row)
    inc a
    ;; did we just go off the playfield?
    cp d
    jr z, _p_inc_surrounding_bomb_count__skip_ll
    ;; ok we have lower left, increment it
    ld a, (_p_load_bombs_col)
    dec a
    ld b, a
    ld a, (_p_load_bombs_row)
    inc a
    ld c, a
    call _p_inc_bomb_count

    _p_inc_surrounding_bomb_count__skip_ll:
    _p_inc_surrounding_bomb_count__skip_l:

    ;; then entire right column
    ld a, (p_playfield_w)
    ld d, a
    ld a, (_p_load_bombs_col)
    inc a
    ;; did we just go off the playfield?
    cp d
    jr z, _p_inc_surrounding_bomb_count__skip_r
    ;; ok there is a right column
    ;; do we have upper right?
    ld a, (_p_load_bombs_row)
    dec a
    cp -1
    jr z, _p_inc_surrounding_bomb_count__skip_ur
    ;; ok we have upper right, increment it
    ld a, (_p_load_bombs_col)
    inc a
    ld b, a
    ld a, (_p_load_bombs_row)
    dec a
    ld c, a
    call _p_inc_bomb_count
    _p_inc_surrounding_bomb_count__skip_ur:
    ;; we have right, increment it
    ld a, (_p_load_bombs_col)
    inc a
    ld b, a
    ld a, (_p_load_bombs_row)
    ld c, a
    call _p_inc_bomb_count
    ;; now do we have lower right?
    ld a, (p_playfield_h)
    ld d, a
    ld a, (_p_load_bombs_row)
    inc a
    ;; did we just go off the playfield?
    cp d
    jr z, _p_inc_surrounding_bomb_count__skip_lr
    ;; ok we have lower right, increment it
    ld a, (_p_load_bombs_col)
    inc a
    ld b, a
    ld a, (_p_load_bombs_row)
    inc a
    ld c, a
    call _p_inc_bomb_count

    _p_inc_surrounding_bomb_count__skip_lr:
    _p_inc_surrounding_bomb_count__skip_r:
    ;; then above
    ;; do we have above?
    ld a, (_p_load_bombs_row)
    dec a
    cp -1
    jr z, _p_inc_surrounding_bomb_count__skip_u
    ;; ok we have above, increment it
    ld a, (_p_load_bombs_col)
    ld b, a
    ld a, (_p_load_bombs_row)
    dec a
    ld c, a
    call _p_inc_bomb_count

    _p_inc_surrounding_bomb_count__skip_u:
    ;; finally, below
    ld a, (p_playfield_h)
    ld d, a
    ld a, (_p_load_bombs_row)
    inc a
    ;; did we just go off the playfield?
    cp d
    jr z, _p_inc_surrounding_bomb_count__skip_d
    ;; ok we have below, increment it
    ld a, (_p_load_bombs_col)
    ld b, a
    ld a, (_p_load_bombs_row)
    inc a
    ld c, a
    call _p_inc_bomb_count
    _p_inc_surrounding_bomb_count__skip_d:

    pop bc
    ret

;; increments the bomb count at (b,c)
;; parameters
;; b: column
;; c: row
_p_inc_bomb_count:
    ;; load the pointer to (b,c) into hl
    call _p_get_pointer_to_tile
    ;; get the tile value
    ld a, (hl)
    ;; increment its bomb count
    inc a
    ;; and save it back
    ld (hl), a
    ret

;; sets an undiscovered tile to flagged
;;
;; parameters
;; b: column
;; c: row
playfield_flag_tile:
    ;; first, make sure this tile is undiscovered
    call _p_get_pointer_to_tile
    ld a, (hl)
    cp PLAYFIELD_UNDISCOVERED
    ;; if this tile has already been discovered, nothing to do
    ret c

    ;; stash the tile value
    ld d, a

    ;; ok this is an undiscovered tile, has it already been flagged?
    and PLAYFIELD_FLAGGED_FLAG
    cp 0
    jr z, playfield_flag_tile__needs_flagging
    ;; this tile needs unflagging
    ld a, d
    ;; clear out the flagged flag
    and PLAYFIELD_CLEAR_FLAGGED_MASK
    ld (hl), a

    ;; update the minimap
    ld e, MINIMAP_UNDISCOVERED
    call minimap_change_tile

    ;; and increment outstanding bombs
    ld a, (p_outstanding_bomb_count)
    inc a
    ld (p_outstanding_bomb_count), a

    ret

    playfield_flag_tile__needs_flagging:
    ld a, d
    or PLAYFIELD_UNDISCOVERED_FLAGGED
    ld (hl), a

    ;; update the minimap
    ld e, MINIMAP_FLAGGED
    call minimap_change_tile

    ;; and decrement outstanding bombs
    ld a, (p_outstanding_bomb_count)
    dec a
    ld (p_outstanding_bomb_count), a

    ret

;; clears the undiscovered bit on the queried tile
;; and then recursively discovers the surrounding tiles
;;
;; parameters
;; b: column
;; c: row
playfield_discover_tile:
    ;; is this tile flagged? if so, don't allow discovery
    call _p_get_pointer_to_tile
    ld a, (hl)
    and PLAYFIELD_FLAGGED_FLAG
    ret nz

    ;; is this the first discovery? then load all the bombs, avoiding (b,c)
    ;; to ensure the first click is always a safe one

    ;; buuuuut, dont do this in animal mode
    ld a, (difficulty_choice)
    cp 3
    jr z, playfield_discover_tile__skip_first_discovery

    ld a, (p_first_discovery)
    cp 0
    jr z, playfield_discover_tile__skip_first_discovery
    ;; this is the first discovery
    ;; clear the first discovery flag so we only do this once
    ld a, 0
    ld (p_first_discovery), a

    ld a, b
    ld (_p_no_bomb_col), a
    ld a, c
    ld (_p_no_bomb_row), a
    push bc
    call _p_load_bombs
    pop bc

    playfield_discover_tile__skip_first_discovery:
    ld a, 0
    ld (_p_reveal_sfx_played), a
    call _p_discover_tile

    ;; now that the playfield has been updated, render to the screen
    call playfield_gfx_render
    ;; no need to halt, that will happen in the main game loop
    ret

;; the private version of discover tile
;; TODO: don't recurse if hit a bomb
_p_discover_tile:
    ;; save off (b,c)
    push bc

    ;; first are we even on the playfield?
    ld a, b
    cp 0
    ;; we have gone off the left side
    jp c, playfield_discover_tile__done ;; c flag set -> a < 0
    ld a, c
    cp 0
    ;; we have gone off the top
    jp c, playfield_discover_tile__done ;; c flag set -> a < 0

    ld a, (p_playfield_w)
    ld d, a
    ld a, b
    cp d
    ;; we have gone off the right
    jp nc, playfield_discover_tile__done ;; c flag cleared -> a >= w

    ld a, (p_playfield_h)
    ld d, a
    ld a, c
    cp d
    ;; we have gone off the bottom
    jr nc, playfield_discover_tile__done ;; c flag cleared -> a >= h

    ;; we are in the playfield, carry on...

    ;; update the minimap
    ;; this is being done even if the tile is a bomb,
    ;; which is technically not correct but not a big deal and simpler
    ld e, MINIMAP_DISCOVERED
    ;; b and c are already what it expects
    call minimap_change_tile

    call _p_get_pointer_to_tile
    ;; pull the tile value into a
    ld a, (hl)
    ;; stash a to the side
    ld d, a
    ;; is this tile already discovered?
    cp PLAYFIELD_UNDISCOVERED
    ;; if it is, nothing to do
    ;; this is an important base case to end the recursion
    jr c, playfield_discover_tile__done ;; c flag set -> a < 128

    ;; is this a bomb?
    and PLAYFIELD_BOMB_FLAG
    jr z, _p_discover_tile__not_bomb
    ;; this is a bomb
    ;; reveal it
    ld a, PLAYFIELD_BOMB_HIT_BY_PLAYER
    ;; and put the value back into the playfield
    ld (hl), a
    ;; show it to the user
    call playfield_gfx_render
    ld a, 1
    halt
    ;; and end the game
    call sound_play_explosion
    pop bc
    call _p_show_explosion
    call _p_game_over_reveal_board
    ld a, 1
    ;; tell render to reveal incorrect flags
    ld (p_game_over), a
    call playfield_gfx_render
    ld a, 1
    halt
    ld b, 0
    call game_on_lose
    ret

    _p_discover_tile__not_bomb:
    ;; decrement undiscovered count
    push hl
    ld hl, (p_undiscovered_count)
    dec hl
    ld (p_undiscovered_count), hl
    pop hl

    ;; restore a
    ld a, d
    ;; was this tile flagged? if so, the flag is about to be wiped out
    ;; so we need to update the outstanding count
    and PLAYFIELD_FLAGGED_FLAG
    cp 0
    jr z, _p_discover_tile__not_flagged
    ;; ok this was a flagged tile, so need to increment outstanding
    ld a, (p_outstanding_bomb_count)
    inc a
    ld (p_outstanding_bomb_count), a

    _p_discover_tile__not_flagged:
    ;; restore a
    ld a, d
    ;; update the minimap
    ;; b and c are already what it expects
    ld e, MINIMAP_DISCOVERED
    call minimap_change_tile

    ;; tile &= 0x5f, which will ensure the top bit (undiscovered)
    ;; and the third bit (flagged) are cleared
    and 0x5f
    ;; and put the value back into the playfield
    ld (hl), a

    ;; if the bomb count is zero, then we need to recursively discover all surrounding tiles
    cp 0
    ;; not zero? this tile has a bomb count, no recursion
    jr nz, playfield_discover_tile__skip_recursion ;; z flag cleared -> a != 0

    pop bc
    ;; play the recursive sfx, but only once
    ld a, (_p_reveal_sfx_played)
    cp 1
    jr z, playfield_discover_tile__done_skip_recursive_sfx
    call sound_play_recursive_reveal
    ld a, 1
    ld (_p_reveal_sfx_played), a
    playfield_discover_tile__done_skip_recursive_sfx:
    call _p_discover_surrounding_tiles
    jr playfield_discover_tile__done_skip_pop

    playfield_discover_tile__skip_recursion:
    ;; play the non recursive sfx, but only once
    ld a, (_p_reveal_sfx_played)
    cp 1
    jr z, playfield_discover_tile__done
    call sound_play_nonrecursive_reveal
    ld a, 1
    ld (_p_reveal_sfx_played), a

    playfield_discover_tile__done:
    pop bc
    playfield_discover_tile__done_skip_pop:
    ret

;; the player lost, shows where all bombs and all wrong flags are
_p_game_over_reveal_board:
    ld a, (p_playfield_h)
    ld b, a
    ld c, 0 ;; row
    ld d, 0 ;; column
    _p_game_over_reveal_board__outer_loop:
    push bc
    ld a, (p_playfield_w)
    ld b, a
    _p_game_over_reveal_board__inner_loop:
    push bc
    ld b, d
    call _p_get_pointer_to_tile
    ld a, (hl)
    ;; save a to the side
    ld b, a
    ;; let's see if there is a bomb here
    and PLAYFIELD_BOMB_FLAG
    ;; restore a now, in case we jump
    ld a, b
    jp z, _p_game_over_reveal_board__not_a_bomb
    ;; this is a bomb, was it flagged?
    and PLAYFIELD_FLAGGED_FLAG
    ld a, b
    ;; jump if this is a correctly flagged bomb, nothing to change
    jp nz, _p_game_over_reveal_board__done_with_tile
    ;; this is an unflagged bomb, reveal it, unless it's the tripping bomb
    cp 128
    jp c, _p_game_over_reveal_board__skip_set_to_revealed_bomb

    ld a, PLAYFIELD_REVEALED_AFTER_GAME_OVER_BOMB
    ld (hl), a
    _p_game_over_reveal_board__skip_set_to_revealed_bomb:
    ld b, d
    ld e, MINIMAP_FLAGGED
    call minimap_change_tile
    jr _p_game_over_reveal_board__done_with_tile

    _p_game_over_reveal_board__not_a_bomb:
    ;; this isn't a bomb, was it incorrectly flagged?
    and PLAYFIELD_FLAGGED_FLAG
    ;; jump if this was not flagged, which is correct so nothing to do
    jp z, _p_game_over_reveal_board__done_with_tile
    ;; this tile was incorrectly flagged, all we need to do is update the minimap
    ;; the incorrect flag will show up in the playfield via playfield_gfx_render
    ld e, MINIMAP_UNDISCOVERED
    ld b, d
    call minimap_change_tile

    _p_game_over_reveal_board__done_with_tile:
    pop bc
    ;; move to next column
    inc d
    djnz _p_game_over_reveal_board__inner_loop
    pop bc
    ;; move to next row
    inc c
    ;; go back to first column
    ld d, 0
    djnz _p_game_over_reveal_board__outer_loop
    ret

;; shows and animates the system explosion sprite at (b,c)
;;
;; parameters
;; b: col
;; c: row
_p_show_explosion: 
    ld de, 4102 ; explosion
    ld a, 10
    rst 0
    .db ERAPI_CreateSystemSprite
    ;; save sprite handle, we'll need it later
    push hl

    ;; position it, use the logical (b,c) and where the current
    ;; camera position is to figure out the screen position for the bomb
    ld a, (p_playfield_camera_x)
    ld d, a
    ld a, b
    sub d
    ;; a is now the onscreen x tile
    ld e, 16
    rst 8
    ;; hl = a*e
    .db ERAPI_Mul8
    ;; hl is now close, we just need to add 8 to center onto the tile
    ld de, 8
    add hl, de
    ;; hl now holds the onscreen x in pixels, push it onto the stack
    push hl

    ld a, (p_playfield_camera_y)
    ld d, a
    ld a, c
    sub d
    ;; a is now the onscreen y tile
    ld e, 16
    rst 8
    ;; hl = a*e
    .db ERAPI_Mul8
    ;; hl is now close, we just need to add 8 to center onto the tile
    ld de, 8
    add hl, de
    ;; hl now holds the onscreen y in pixels, push it onto the stack
    push hl

    pop bc ; move y to where erapi needs it
    pop de ; move x to where erapi needs it
    pop hl ; pop the sprite handle back into place
    rst 0
    .db ERAPI_SetSpritePos

    ;; hl = sprite handle
    ;; de = sprite frame duration in system frames
    ;; bc =
    ;; bc: 0 = Start Animating Forever
    ;;     1 = Stop Animation
    ;;     2 > Number of frames to animate for -2 (ex. 12 animates for 10 frames)
    ld de, 5
    ld bc, 0
    rst 0
    .db ERAPI_SpriteAutoAnimate

    ld a, 40
    halt

    ld bc, 1
    rst 0
    .db ERAPI_SpriteAutoAnimate

    rst 0
    .db ERAPI_SpriteHide

    ret



;; discovers all the tiles surrounding (b,c)
;;
;; parameters
;; b: col
;; c: row
_p_discover_surrounding_tiles:
    ;; left
    ;; save (b,c)
    push bc
    ld a, b
    dec a
    ld b, a
    call _p_discover_tile
    pop bc

    ;; upper left
    ;; save (b,c)
    push bc
    ld a, b
    dec a
    ld b, a
    ld a, c
    dec a
    ld c, a
    call _p_discover_tile
    pop bc

    ;; upper
    ;; save (b,c)
    push bc
    ld a, c
    dec a
    ld c, a
    call _p_discover_tile
    pop bc

    ;; upper right
    ;; save (b,c)
    push bc
    ld a, b
    inc a
    ld b, a
    ld a, c
    dec a
    ld c, a
    call _p_discover_tile
    pop bc

    ;; right
    ;; save (b,c)
    push bc
    ld a, b
    inc a
    ld b, a
    call _p_discover_tile
    pop bc

    ;; lower right
    ;; save (b,c)
    push bc
    ld a, b
    inc a
    ld b, a
    ld a, c
    inc a
    ld c, a
    call _p_discover_tile
    pop bc

    ;; lower
    ;; save (b,c)
    push bc
    ld a, c
    inc a
    ld c, a
    call _p_discover_tile
    pop bc

    ;; lower left
    ;; save (b,c)
    push bc
    ld a, b
    dec a
    ld b, a
    ld a, c
    inc a
    ld c, a
    call _p_discover_tile
    pop bc

    ret

;; returns the current value of the queried tile
;; parameters
;; b: column
;; c: row
;; return
;; a = tile value
playfield_get_tile_value:
    push hl
    call _p_get_pointer_to_tile
    ld a, (hl)
    pop hl
    ret

;; sets hl to point to the queried tile
;;
;; parameters
;; b: column
;; c: row
;;
;; returns
;; hl: pointer to the tile 
_p_get_pointer_to_tile:
    push de
    push bc

    ;; pointer = base + row * p_playfield_w + column

    ;; de = c (row)
    ld d, 0
    ld e, c
    ld a, (p_playfield_w)
    ;; hl = p_playfield_w
    ld h, 0
    ld l, a

    rst 8
    ;; hl=hl*de
    .db ERAPI_Mul16
    ;; hl is now row * p_playfield_w

    ;; hl is now row * p_playfield_w + column
    ld a, b
    ld b, 0
    ld c, a 
    add hl, bc
    ;; bc = hl
    push hl
    pop bc
    ld hl, p_playfield
    add hl, bc

    pop bc
    pop de
    ret


p_playfield_w:
    .db 0
p_playfield_h:
    .db 0
p_outstanding_bomb_count:
    .db 0
p_bomb_count:
    .db 0

_p_easy:
    .db 9   ;; width
    .db 9   ;; height
    .db 10  ;; bomb count
    .db -3   ;; starting camera x
    .db -1   ;; starting camera y
_p_medium:
    .db 16  ;; width
    .db 16  ;; height
    .ifdef DEBUG
        .db 1  ;; bomb count
    .else
        .db 40  ;; bomb count
    .endif
    .db 0   ;; starting camera x
    .db 0   ;; starting camera y
_p_hard:
    .db 30  ;; width
    .db 16  ;; height
    .db 99  ;; bomb count
    .db 0   ;; starting camera x
    .db 0   ;; starting camera y

p_first_discovery:
    .db 1
p_undiscovered_count:
    .dw 0
p_playfield_camera_x:
    .db 0
p_playfield_camera_y:
    .db 0
_p_load_bombs_col:
    .db 0
_p_load_bombs_row:
    .db 0
_p_no_bomb_col:
    .db 0
_p_no_bomb_row:
    .db 0
_p_reveal_sfx_played:
    .db 0
p_playfield:
    .ds _P_MAX_PLAYFIELD_SIZE
p_game_over:
    .db 0