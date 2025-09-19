    ;; tile frames
    _PG_UNDISCOVERED_FRAME = 11
    _PG_DISCOVERED_EMPTY_FRAME = 0
    _PG_FLAGGED_FRAME = 9
    _PG_REVEALED_AFTER_GAME_BAD_FLAG_FRAME = 10
    _PG_HOLE_FRAME = 12
    _PG_OUT_OF_BOUNDS_FRAME = 13
    _PG_REVEALED_AFTER_GAME_OVER_BOMB_FRAME = 14
    _PG_DISCOVERED_BOMB_FRAME = 17

    _PG_SCREEN_W = 15
    _PG_SCREEN_H = 10

    _pg_tiles_playfield_size = _pg_tiles_playfield_end - _pg_tiles_playfield
    _pg_palette_playfield_size = _pg_palette_playfield_end - _pg_palette_playfield

playfield_gfx_render:
    call _pg_playfield_render

    ld  a, BG_INDEX_PLAYFIELD
    ld  de, _pg_background
    rst 0
    .db ERAPI_LoadCustomBackground
    ret

playfield_gfx_open_hole:
    ;; fully closed
    call playfield_gfx_render

    ld a, 1
    halt

    ;; one opening
    ld a, 7
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_HOLE_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld  a, BG_INDEX_PLAYFIELD
    ld  de, _pg_background
    rst 0
    .db ERAPI_LoadCustomBackground

    ld a, 2
    halt

    ;; three openings
    ld a, 6
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_HOLE_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld a, 8
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_HOLE_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld  a, BG_INDEX_PLAYFIELD
    ld  de, _pg_background
    rst 0
    .db ERAPI_LoadCustomBackground

    ld a, 2
    halt

    ;; five openings
    ld a, 5
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_HOLE_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld a, 9
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_HOLE_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld  a, BG_INDEX_PLAYFIELD
    ld  de, _pg_background
    rst 0
    .db ERAPI_LoadCustomBackground

    ld a, 2
    halt
    ret

playfield_gfx_close_hole:
    ;; close the outer 2, from 5->3
    ld a, 5
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_UNDISCOVERED_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld a, 9
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_UNDISCOVERED_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld  a, BG_INDEX_PLAYFIELD
    ld  de, _pg_background
    rst 0
    .db ERAPI_LoadCustomBackground

    ld a, 2
    halt

    ;; close the outer 2, from 3->1
    ld a, 6
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_UNDISCOVERED_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld a, 8
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_UNDISCOVERED_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld  a, BG_INDEX_PLAYFIELD
    ld  de, _pg_background
    rst 0
    .db ERAPI_LoadCustomBackground

    ld a, 2
    halt

    ;; close the final opening
    ld a, 7
    ld (_pg_cur_tile_x), a
    ld a, 5
    ld (_pg_cur_tile_y), a
    ld a, _PG_UNDISCOVERED_FRAME
    ld (_pg_cur_tile_frame), a
    call _pg_render_tile

    ld  a, BG_INDEX_PLAYFIELD
    ld  de, _pg_background
    rst 0
    .db ERAPI_LoadCustomBackground

    ld a, 2
    halt

    ;; since this function is only called once, use it
    ;; as a hook to also seed the random bomb seed
    rst 8
    .db ERAPI_Rand
    ld h, a
    rst 8
    .db ERAPI_Rand
    ld l, a
    ld (_pg_random_bomb_seed), hl
    ret

_pg_playfield_render:
    ;; render one column at a time
    ;; load how many columns there are
    ld a, _PG_SCREEN_W
    ld b, a
    ;; the current column index
    ld a, 0

    playfield_gfx_render__loop:
    call _pg_render_column
    inc a
    djnz playfield_gfx_render__loop
    ret


;; renders a single column of tiles
;; parameters
;; a: column index
_pg_render_column:
    push bc
    push de
    ;; load the column height
    ;; move column index to the side
    ld d, a
    ld a, _PG_SCREEN_H
    ld b, a
    ;; restore column index
    ld a, d
    ;; row index
    ld c, 0

    _pg_render_column__loop:
    ;; move column index to the side
    ld d, a
    ;; load up cur frame
    push de
    push bc

    ;; parameters, b: column, c: row
    ld b, a
    ;; c is already row
    call _pg_get_frame_index
    pop bc
    pop de

    ld (_pg_cur_tile_frame), a

    ;; load y
    ld a, c
    ld (_pg_cur_tile_y), a

    ;; and x

    ;; get the camera offset into a
    ld a, d
    ld (_pg_cur_tile_x), a

    ;; now render tile will render the tile based on the camera's location
    call _pg_render_tile

    inc c
    djnz _pg_render_column__loop

    pop de
    pop bc

    ret

;; given a screen x/y location
;; - adjusts to the logical board location using camera x/y
;; - if the result is out of bounds, returns the out of bounds frame
;; - else returns that tile's frame based on its logical board value
;;
;; parameters
;; b: screen column
;; c: screen row
;; returns
;; a: the frame index
_pg_get_frame_index:
    ;; once the camera is applied, are we outside of the board?
    ld a, (p_playfield_camera_x)
    add b
    ld b, a
    ;; a and b are now the logical x
    ;; let's see if it is out of bounds
    push bc
    ld hl, p_playfield_w
    ld b, (hl)
    cp b
    pop bc
    jr nc, _pg_get_frame_index__out_of_bounds

    ;; now y, is it out of bounds?
    ld a, (p_playfield_camera_y)
    add c
    ld c, a
    ;; a and c are now the logical y
    ;; let's see if it is out of bounds
    push bc
    ld hl, p_playfield_h
    ld b, (hl)
    cp b
    pop bc
    jr nc, _pg_get_frame_index__out_of_bounds

    ;; if we got here, we are not out of bounds, proceed to get
    ;; the frame based on the newly set logical values in b and c

    ;; same parameters, a will be the tile value
    call playfield_get_tile_value
    ;; save it to the side
    ld d, a
    ;; if >= 128, undiscovered, else discovered
    cp PLAYFIELD_UNDISCOVERED
    jr c, _pg_get_frame_index__skip_undiscovered
    ;; this is an undiscovered tile
    ;; is it flagged?
    and PLAYFIELD_FLAGGED_FLAG
    jr z, _pg_get_frame__undiscovered_not_flagged

    ;; this is a flagged tile
    ;; is the game over?
    ld a, (p_game_over)
    cp 0
    jp z, _pg_get_frame_index__show_correct_flag
    ;; this is game over, we need to reveal incorrect flags
    ld a, d
    and PLAYFIELD_BOMB_FLAG
    jp nz, _pg_get_frame_index__show_correct_flag
    ;; this was flagged incorrectly
    ld a, _PG_REVEALED_AFTER_GAME_BAD_FLAG_FRAME
    ret

    _pg_get_frame_index__show_correct_flag:
    ld a, _PG_FLAGGED_FRAME
    ret

    _pg_get_frame__undiscovered_not_flagged:
    ld a, _PG_UNDISCOVERED_FRAME
    ret

    _pg_get_frame_index__skip_undiscovered:
    ;; this is a discovered tile
    ;; is this a revealed after game over bomb?
    cp PLAYFIELD_REVEALED_AFTER_GAME_OVER_BOMB
    jr nz, _pg_get_frame_index__not_revealed_after_game_over_bomb
    ;; "randomly" choose one of the bombs
    call _pg_set_random_bomb_seed

    add _PG_REVEALED_AFTER_GAME_OVER_BOMB_FRAME
    ret
   
    _pg_get_frame_index__not_revealed_after_game_over_bomb:

    ;; does it have a bomb?
    ld c, PLAYFIELD_BOMB_FLAG
    and c
    jr z, _pg_get_frame_index__skip_bomb
    ;; ok there is a bomb here
    ;; "randomly" choose one of the bombs
    call _pg_set_random_bomb_seed

    add _PG_DISCOVERED_BOMB_FRAME
    ret

    _pg_get_frame_index__skip_bomb:
    ;; there is no bomb, so the frame is based on its bomb count,
    ;; which is just the tile's value, which we stashed into d
    ld a, d
    ret

    _pg_get_frame_index__out_of_bounds:
    ;; this tile is beyond the bounds of the board
    ld a, _PG_OUT_OF_BOUNDS_FRAME
    ret

_pg_set_random_bomb_seed:
    ld hl, (_pg_random_bomb_seed)
    rst 0
    .db ERAPI_RandomSeed

    _pg_set_random_bomb_seed__first_loop:
    ld a, 3
    rst 8
    .db ERAPI_RandMax
    djnz _pg_set_random_bomb_seed__first_loop

    ld b, c
    _pg_set_random_bomb_seed__second_loop:
    ld a, 3
    rst 8
    .db ERAPI_RandMax
    djnz _pg_set_random_bomb_seed__second_loop
    ret

;; 
;; renders one 16x16 tile into the playfield
;;
;; parameters
;; _pg_cur_tile_frame: 1 = undiscovered, 2 = discovered
;; _pg_cur_tile_y: row
;; _pg_cur_tile_x: col
_pg_render_tile:
    push af
    push bc

    ;; get the starting tile index
    ;; which is frame * 4, as each tile is 2x2
    ld a, (_pg_cur_tile_frame)
    ld e, 4
    rst 8
    ;; hl = a*e
    .db ERAPI_Mul8

    ;; the starting tile index is now in hl
    ;; move it to de
    ld d, h
    ld e, l

    ;; get the starting pointer
    ;; y * 64 because the map is 256x256px
    ;; which is 32x32 tiles
    ;; but tile entries are words, so 64x64
    ;; since the tiles in minesweeper are 16x16 and not 8x8
    ;; we multiply both y and x by 2
    ;; hl = _pg_map_playfield + (y*2*64) + (x*2*2)
    push de
    ld de, 64*2
    ld a, (_pg_cur_tile_y)
    ld h, 0
    ld l, a
    rst 8
    ;; hl = hl*de
    .db ERAPI_Mul16
    ;; hl is now the starting y value
    ;; now add on the x
    ld a, (_pg_cur_tile_x)
    ;; de = x
    ld d, 0
    ld e, a
    ;; hl += x*2*2
    add hl, de
    add hl, de
    add hl, de
    add hl, de

    ;; de = hl
    ld d, h
    ld e, l
    ld hl, _pg_map_playfield
    ;; hl is finally pointed at the first tile address
    add hl, de

    ;; we'll use this to move the hl pointer 30 tiles
    ;; forward to get to the next row in the map
    ;; this is because the map is 32x32 tiles in size
    ;; and we drop in two tiles then move to start of next row
    ;; so 60 is the magic number to arrive at the next row
    ld bc, 60

    ;; now drop the tiles into the map
    pop de ;; restore the starting tile index
    ;; first row
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    inc de ; move to next tile
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    inc de ; move to next tile
    ;; move to the right spot in the next row
    add hl, bc
    ;; second row
    ld (hl), e
    inc hl
    ld (hl), d
    inc hl
    inc de ; move to next tile
    ld (hl), e
    inc hl
    ld (hl), d

    pop bc
    pop af

    ret



_pg_background:
    .dw _pg_tiles_playfield
    .dw _pg_palette_playfield
    .dw _pg_map_playfield
    .dw _pg_tiles_playfield_size / 0x20   ; number of tiles
    .dw 1 ;; number of palettes, due to palette trimming, this needs to be hard coded

    .even
_pg_map_playfield:
    .ds 2048

_pg_cur_tile_frame:
    .ds 1
_pg_cur_tile_x:
    .db 0
_pg_cur_tile_y:
    .db 0
_pg_cur_tile_y_end:
_pg_random_bomb_seed:
    .dw 0