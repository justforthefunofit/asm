; =========================================================
; CONSTANTS
; =========================================================

BORDER      = $d020
BACKGROUND  = $d021
TEXTCOLOR   = $0286

SID_OSC3    = $d41b
SID_FREQLO  = $d40e
SID_FREQHI  = $d40f
SID_CTRL    = $d412

CHROUT      = $ffd2
STOPKEY     = $ffe1
BASIC_WARM  = $a474

old_border   = $fb
old_bg       = $fc

; =========================================================
; BASIC AUTORUN LOADER
; 10 SYS2061   (2061 = $080D)
; =========================================================

* = $0801 ; start adress for the basic program

        byte $0b,$08        ; pointer to next BASIC line ($080B)
        byte $0a,$00        ; line number 10
        byte $9e,$20        ; SYS
        byte $32,$35,$30,$30 ; "2500" 
        byte $00
        byte $00,$00


; =========================================================
; MACHINE CODE (IMMEDIATELY AFTER BASIC)
; =========================================================

* = $09C4   ; start adress for the assembly code sys2500


start
        lda BORDER
        sta OLD_BORDER      ; save border color on stack
        lda BACKGROUND
        sta OLD_BG          ; save background color

        lda #$00
        sta BORDER          ; border = black
        sta BACKGROUND      ; background = black


; ---------------------------------------------------------
; Main loop
; ---------------------------------------------------------
mainloop
        jsr $ffe4           ; GETIN (A = key, 0 = no key)
        bne exit_program    ; exit if any key pressed


        jsr sound_init

        lda SID_OSC3        ; generate random text color
        and #$0f
        sta TEXTCOLOR

; ---------------------------------------------------------
; wandering visual artifact
; ---------------------------------------------------------
        lda #$71
        jsr CHROUT
        lda #$9d
        jsr CHROUT
        lda #$12
        jsr CHROUT
        lda #$20
        jsr CHROUT
        lda #$92
        jsr CHROUT
        lda #$9d
        jsr CHROUT

; ---------------------------------------------------------
; based on random jump to a cursor movement
; ---------------------------------------------------------

        jsr sound_init
        lda SID_OSC3
        and #$03
        cmp #$00
        beq case0
        cmp #$01
        beq case1
        cmp #$02
        beq case2
        cmp #$03
        beq case3


print_and_loop
        jsr CHROUT
        jmp mainloop


; ---------------------------------------------------------
; Cursor movement cases
; ---------------------------------------------------------
case0
        lda #$91            ; cursor up
        jmp print_and_loop

case1
        lda #$1d            ; cursor right
        jmp print_and_loop

case2
        lda #$11            ; cursor down
        jmp print_and_loop

case3
        lda #$9d            ; cursor left
        jmp print_and_loop


; ---------------------------------------------------------
; Exit cleanly and restore screen
; ---------------------------------------------------------
exit_program
        lda old_border
        sta BORDER          ; restore border
        lda old_bg
        sta BACKGROUND      ; restore background
        jmp BASIC_WARM     ; READY.


; ---------------------------------------------------------
; SID sound initialization
; ---------------------------------------------------------
sound_init
        lda #$ff
        sta SID_FREQLO
        sta SID_FREQHI
        lda #$80
        sta SID_CTRL
        rts
