;; writes an achievement into flash memory if it was not already
;; accomplished. If it is newly accomplished in this call, it will
;; play the achievement sound effect
;;
;; each series should have their own function for this, to keep size down
;;
;; parameters
;; b: game bit mask
;;
;; returns
;; b: 1 if saving was needed, 0 if not
common_save_achievement_if_needed:
    ld hl, ACHIEVEMENTS_FLASH_INDEX
    ld de, _c_loaded_flash
    rst 8
    .db ERAPI_FlashLoadUserData

    ld hl, _c_loaded_flash
    ld a, (hl)

    and b
    ;; this achievement has already been accomplished
    ;; nothing to do
    jr z, common_save_achievement_if_needed__skip_early_exit

    ;; achievement has already been saved, let the caller know and bail
    ld b, 0
    ret 

    common_save_achievement_if_needed__skip_early_exit:

    ;; load the current achievement byte
    ld a, (hl)
    ;; tack on this new achievement
    or b
    ;; save it back to memory
    ld (hl), a

    ;; and save it back to flash
    ld hl, ACHIEVEMENTS_FLASH_INDEX
    ld de, _c_loaded_flash
    rst 8
    .db ERAPI_FlashSaveUserData

    ;; let the caller know we saved it to flash, ie this
    ;; accomplishment was newly achieved
    ld b, 1
    ret

_c_loaded_flash:
    .ds 16

