;;
;; This is the main entry point of Bomb Hunter. The game was juuuuuust spilling over into three data strips
;; (ie, two cards), which I really did not want. I wrote a script that explored including the files in
;; different orders, assembling, compressing, and seeing how big the result was. This ordering resulted
;; in favorable compression that kept the game down to two strips (a single card).
;;
;; TODO: get rid of this for the open source version, as it's just added complexity for little gain.
;;

.even
.include "main.asm"
.even
_a_tiles_animals:
.include "animals.tiles.asm"
.even
_bc_tiles_negative:
.include "negativeSign.tiles.asm"
.even
_c_tiles_cursor:
.include "cursor.tiles.asm"
.even
_d_tiles_diamonds:
.include "difficultyDiamonds.tiles.asm"
.even
_g_tiles_hud:
.include "hud.tiles.asm"
.even
.include "bg_indexes.asm"
.even
.include "palette_indexes.asm"
.even
.include "common/erapi.asm"
.even
.include "common/input.asm"
.even
.include "common/repeat_input.asm"
.even
.include "common/achievement_constants.asm"
.even
.include "common/save_achievement_if_needed.asm"
.even
.include "common/play_achievement_sfx.asm"
.even
.include "playfield_gfx.asm"
.even
.include "playfield.asm"
.even
.include "cursor.asm"
.even
.include "intro.asm"
.even
.include "sound.asm"
.even
.include "minimap.asm"
.even
.include "bomb_counter.asm"
.even
.include "difficulty.asm"
.even
_pg_tiles_playfield:
.include "playfieldTiles.tiles.asm"
_pg_tiles_playfield_end:
.even
_pg_palette_playfield:
.include "playfieldTiles.shared.palette.asm"
_pg_palette_playfield_end:
.even
.even
.include "game.asm"
.even
_i_tiles_playfield_cover:
.include "bombDropIntroPlayfieldCover.tiles.asm"
.even
.include "animals.asm"