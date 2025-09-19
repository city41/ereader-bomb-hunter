
    ;; these are indexes into the palette
    MINIMAP_UNDISCOVERED = 1
    MINIMAP_DISCOVERED = 2
    _MM_CAMERA_INDEX = 3
    MINIMAP_FLAGGED = 4
    _MM_OOB_INDEX = 5


    ;; camera and tile regions are slightly different, due to DrawRect
    ;; not able to handle negative parameters

    _MM_TILE_REGION_X = 0
    _MM_TILE_REGION_Y = 6
    _MM_TILE_REGION_W = 5
    _MM_TILE_REGION_H = 2

    _MM_TILE_X_OFFSET_PX = 1
    _MM_TILE_Y_OFFSET_PX = 0

    _MM_CAMERA_REGION_X = 0
    _MM_CAMERA_REGION_Y = 5
    _MM_CAMERA_REGION_W = 5
    _MM_CAMERA_REGION_H = 3

    _MM_CAMERA_X_OFFSET_PX = 1
    _MM_CAMERA_Y_OFFSET_PX = 8

minimap_pre_init:
    ;; the tiles region
    ; ERAPI_CreateRegion()
    ; h = bg# (0-3)
    ; l = palette bank (0-15)
    ; d = left
    ; e = top
    ; b = width
    ; c = height
    ld h, BG_INDEX_MINIMAP_TILES
    ld l, PALETTE_INDEX_MINIMAP
    ld d, _MM_TILE_REGION_X
    ld e, _MM_TILE_REGION_Y
    ld b, _MM_TILE_REGION_W
    ld c, _MM_TILE_REGION_H
    rst 0
    .db ERAPI_CreateRegion
    ld  (_mm_region_tiles_handle), a

    ; ERAPI_SetBackgroundPalette()
    ; hl = pointer to palette data
    ; d = palette index
    ; e = palette offset
    ; c  = number of colors
    ld hl, _mm_palette
    ld d, PALETTE_INDEX_MINIMAP
    ld e, 0
    ld c, 6
    rst 0
    .db ERAPI_SetBackgroundPalette

    ;; fill the minimap with oob to start
    ld d, 0
    ld e, _MM_OOB_INDEX
    rst 0
    .db ERAPI_SetRegionColor

    ld h, a
    ;; fill the rect
    ld l, 1
    ;; set up left
    ld b, _MM_TILE_X_OFFSET_PX
    ;; set up right, 30+_MM_TILE_X_OFFSET_PX-1
    ld d, 29 + _MM_TILE_X_OFFSET_PX
    ;; set up top
    ld e, _MM_TILE_Y_OFFSET_PX
    ;; set up bottom, which is 16+_MM_TILE_Y_OFFSET_PX-1
    ld c, 15 + _MM_TILE_Y_OFFSET_PX

    rst 0
    .db ERAPI_DrawRect
    ret

minimap_init:
    ;; set up the offsets based on chosen diff
    ld a, (difficulty_choice)
    cp 0 ; easy
    jr nz, minimap_init__not_easy
    ;; set offsets for easy board size
    ld a, 10
    ld (_mm_difficulty_offset_x), a
    ld a, 4
    ld (_mm_difficulty_offset_y), a
    jr minimap_init__diff_offset_done

    minimap_init__not_easy:
    cp 1 ; medium
    jr nz, minimap_init__not_medium
    ;; set offsets for medium board size
    ld a, 7
    ld (_mm_difficulty_offset_x), a
    ;; height is already zero, good to go
    jr minimap_init__diff_offset_done

    minimap_init__not_medium:
    ;; offsets of 0,0 already work for hard, nothing to do
    minimap_init__diff_offset_done:

    ;; the camera region
    ; ERAPI_CreateRegion()
    ; h = bg# (0-3)
    ; l = palette bank (0-15)
    ; d = left
    ; e = top
    ; b = width
    ; c = height
    ld h, BG_INDEX_MINIMAP_CAMERA
    ld l, PALETTE_INDEX_MINIMAP
    ld d, _MM_CAMERA_REGION_X
    ld e, _MM_CAMERA_REGION_Y
    ld b, _MM_CAMERA_REGION_W
    ld c, _MM_CAMERA_REGION_H
    rst 0
    .db ERAPI_CreateRegion
    ld  (_mm_region_camera_handle), a

    ;; fill the minimap with undiscovered
    ld a, (_mm_region_tiles_handle)
    ld d, 0
    ld e, MINIMAP_UNDISCOVERED
    rst 0
    .db ERAPI_SetRegionColor

    ld h, a
    ;; fill the rect
    ld l, 1
    ;; set up left x
    ld a, (_mm_difficulty_offset_x)
    add _MM_TILE_X_OFFSET_PX
    ld b, a
    ;; set up right x, which is b+w-1
    ld a, (p_playfield_w)
    add b
    dec a
    ld d, a
    ;; set up top x
    ld a, (_mm_difficulty_offset_y)
    add _MM_TILE_Y_OFFSET_PX
    ld e, a
    ;; set up bottom x, which is e+h-1
    ld a, (p_playfield_h)
    add e
    dec a
    ld c, a

    rst 0
    .db ERAPI_DrawRect

    ret

minimap_camera:
    ;; is this easy? if so, no camera frame
    ld a, (difficulty_choice)
    cp 0
    ret z

    ;; set color to transparent
    ld a, (_mm_region_camera_handle)
    ld d, 0
    ld e, 0
    rst 0
    .db ERAPI_SetRegionColor

    ;; as clear region is really "fill region with current region color"
    rst 0
    .db ERAPI_ClearRegion

    ld d, 0
    ld e, _MM_CAMERA_INDEX
    rst 0
    .db ERAPI_SetRegionColor

    ;; left
    ld a, (p_playfield_camera_x)
    add _MM_CAMERA_X_OFFSET_PX
    ;; go back one pixel, otherwise the frame is obscuring a column of the map
    ;; that is currently visible
    dec a
    ;; do right first
    add 16
    ld d, a
    ;; now go back to left and see if it is negative
    sub 16
    cp 40
    jp c, minimap_camera__skip_clamp_left
    ;; left has gone negative, need to clamp it to zero
    ld a, 0
    minimap_camera__skip_clamp_left:
    ld b, a
    ;; now add the difficulty offset
    ld a, (_mm_difficulty_offset_x)
    add b
    ld b, a
    ;; does right need to be clamped?
    ld a, d
    cp 31 + _MM_CAMERA_X_OFFSET_PX
    jp c, minimap_camera__skip_clamp_right
    dec d
    minimap_camera__skip_clamp_right:

    ;; top 
    ld a, (p_playfield_camera_y)
    add _MM_CAMERA_Y_OFFSET_PX
    ld c, a
    ld a, (_mm_difficulty_offset_y)
    add c
    ;; go up one pixel, otherwise the frame is obscuring a column of the map
    ;; that is currently visible
    dec a
    ld c, a
    ;; bottom
    add 11
    ld e, a

    ld a, (_mm_region_camera_handle)
    ld h, a
    ld l, 0

    rst 0
    .db ERAPI_DrawRect
    ret

;; changes a tile in the minimap
;;
;; parameters
;; b: x
;; c: y
;; e: what to change it to, ie MINIMAP_DISCOVERED
minimap_change_tile:
    push de
    push af

    ld a, (_mm_region_tiles_handle)
    ld d, 0
    rst 0
    .db ERAPI_SetRegionColor

    ;; set up x with the pixel offset and difficulty offset
    ld a, (_mm_difficulty_offset_x)
    add b
    add _MM_TILE_X_OFFSET_PX
    ld d, a

    ;; set up y with the pixel offset and difficulty offset
    ld a, (_mm_difficulty_offset_y)
    add c
    add _MM_TILE_Y_OFFSET_PX
    ld e, a

    ld a, (_mm_region_tiles_handle)
    rst 0
    .db ERAPI_SetPixel

    pop af
    pop de

    ret

    .even
_mm_palette:
    ;; transparency, undiscovered, discovered, camera, flagged, out of bounds
    .dw 0x7c1f, 0x768d, 0x77bc, 0x27e9, 0x151c, 0

_mm_region_tiles_handle:
    .db 0
_mm_region_camera_handle:
    .db 0
_mm_difficulty_offset_x:
    .db 0
_mm_difficulty_offset_y:
    .db 0