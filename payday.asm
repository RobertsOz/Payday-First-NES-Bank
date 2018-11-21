    .inesprg 1
    .ineschr 1
    .inesmap 0
    .inesmir 1

;    -------------------------------

PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014
JOYPAD1   = $4016
JOYPAD2   = $4017

BUTTON_A        = %10000000
BUTTON_B        = %01000000
BUTTON_SELECT   = %00100000
BUTTON_START    = %00010000
BUTTON_UP       = %00001000
BUTTON_DOWN     = %00000100
BUTTON_LEFT     = %00000010
BUTTON_RIGHT    = %00000001


    .rsset $0000
joypad1_state       .rs 1
bullet_active       .rs 1
nametable_adress    .rs 2
scroll_x            .rs 1
scroll_page         .rs 1




    .rsset $0200
sprite_player       .rs 4
sprite_gun          .rs 4
sprite_bullet       .rs 4

    .rsset $0000
SPRITE_Y            .rs 1
SPRITE_TILE         .rs 1
SPRITE_ATTRIB       .rs 1
SPRITE_X            .rs 1


    .bank 0
    .org $C000

; Init
RESET:
    SEI
    CLD
    LDX #$40
    STX $4017
    LDX #$ff
    TXS
    INX
    STX PPUCTRL
    STX PPUMASK
    STX $4010

;-----

    BIT PPUSTATUS

vblankwait1:
    BIT PPUSTATUS
    BPL vblankwait1

;-----

    TXA
clrmem:
    LDA #0
    STA $000,x
    STA $100,x
    STA $300,x
    STA $400,x
    STA $500,x
    STA $600,x
    STA $700,x


    LDA #$FF
    STA $200,x

    INX
    BNE clrmem

;-----

vblankwait2:
    BIT PPUSTATUS
    BPL vblankwait2

    ; End of Init
    
    JSR Initialise_Game

    LDA #%10000000 ;Enamble NMI
    STA PPUCTRL

    LDA #%00011000 ;Enable Sprites and Background
    STA PPUMASK

    LDA #0
    STA PPUSCROLL ;Set x scroll
    Sta PPUSCROLL ;Set y scroll


;Infinite loop
forever:
    JMP forever

;--------------------
Initialise_Game: ;Start subroutine
    ; Reset the PPU high/low latch
    LDA PPUSTATUS

    ; Write adress 3f00 to the PPU (Background pallet)
    LDA #$3F
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    ; Write the bg color pallet 1
    LDA #$10
    STA PPUDATA
    LDA #$19
    STA PPUDATA
    LDA #$29
    STA PPUDATA
    LDA #$09
    STA PPUDATA

    ; Write the bg color pallet 2
    LDA #$10
    STA PPUDATA
    LDA #$15
    STA PPUDATA
    LDA #$25
    STA PPUDATA
    LDA #$05
    STA PPUDATA

    ; Write adress 3f10 to the PPU (Sprite pallet)
    LDA #$3F
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    ; Write the bg color
    LDA #3
    STA PPUDATA

    ; Write the pallet color sprite 0
    LDA #$15
    STA PPUDATA
    LDA #$20
    STA PPUDATA
    LDA #$01
    STA PPUDATA

    ; Write pallet color sprite 1
    LDA #3
    STA PPUDATA
    LDA #$0E
    STA PPUDATA
    LDA #$2D
    STA PPUDATA
    LDA #$27
    STA PPUDATA



    ;Write sprite data for sprite 0
    LDA #120    ;Y pos
    STA sprite_player + SPRITE_Y
    LDA #0      ;Tile number
    STA sprite_player + SPRITE_TILE
    LDA #0      ;Attribute
    STA sprite_player + SPRITE_ATTRIB
    LDA #128    ;X pos
    STA sprite_player + SPRITE_X

    ;Write sprite data for sprite 1
    LDA #60    ;Y pos
    STA sprite_gun + SPRITE_Y
    LDA #1      ;Tile number
    STA sprite_gun + SPRITE_TILE
    LDA #1      ;Attribute
    STA sprite_gun + SPRITE_ATTRIB
    LDA #190    ;X pos
    STA sprite_gun + SPRITE_X

    ;Load nametable data 1
    LDA #$20           ;Write adress $2000 to PPuADDR register
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    
    LDA #LOW(NametableData)
    STA nametable_adress
    LDA #HIGH(NametableData)
    STA nametable_adress+1
LoadNametable_OuterLoop:
    LDY #0
LoadNametable_InnerLoop:
    LDA [nametable_adress], y
    BEQ LoadNametable_End
    STA PPUDATA
    INY
    BNE LoadNametable_InnerLoop
    INC nametable_adress+1
    JMP LoadNametable_OuterLoop
LoadNametable_End:

    ;Load attribute data
    LDA #$23           ;Write adress $23C0 to PPuADDR register
    STA PPUADDR
    LDA #$C0
    STA PPUADDR

    LDA #%01010101
    LDX #64
LoadAttributes_Loop:
    STA PPUDATA
    DEX
    BNE LoadAttributes_Loop

    ;Load nametable data 2
    LDA #$24           ;Write adress $2400 to PPuADDR register
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    
    LDA #LOW(NametableData)
    STA nametable_adress
    LDA #HIGH(NametableData)
    STA nametable_adress+1
LoadNametable2_OuterLoop:
    LDY #0
LoadNametable2_InnerLoop:
    LDA [nametable_adress], y
    BEQ LoadNametable2_End
    STA PPUDATA
    INY
    BNE LoadNametable2_InnerLoop
    INC nametable_adress+1
    JMP LoadNametable2_OuterLoop
LoadNametable2_End:

    ;Load attribute data 2
    LDA #$27           ;Write adress $27C0 to PPuADDR register
    STA PPUADDR
    LDA #$C0
    STA PPUADDR

    LDA #%00000000
    LDX #64
LoadAttributes2_Loop:
    STA PPUDATA
    DEX
    BNE LoadAttributes2_Loop




    RTS ;End subroutine
;--------------------
NametableData:
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $10, $11, $12, $13, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $20, $21, $22, $23, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $10, $11, $12, $13, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $20, $21, $22, $23, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $10, $11, $12, $13, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $10, $11, $12, $13, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $20, $21, $22, $23, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $20, $21, $22, $23, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03 
    .db $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $30, $31, $32, $33, $03, $03, $03, $03, $03, $03, $03, $03
    .db $00 ;null terminator

;--------------------
; NMI called every frame
NMI:
;Init first controller
    LDA #1
    STA JOYPAD1
    LDA #0
    STA JOYPAD1

    ;Read JOYPAD1 state
    LDX #0 ;X=0
    STX joypad1_state
ReadController:
    LDA JOYPAD1
    LSR A
    ROL joypad1_state
    INX
    CPX #8 ;Compare if X is 8
    BNE ReadController


;React to RIGHT button
    LDA joypad1_state
    AND #BUTTON_RIGHT
    BEQ ReadRIGHT_Done ;if recieve input do this, else jump to ReadA_Done
    ;Increment x pos of sprite
    LDA sprite_player + SPRITE_X
    CLC
    ADC #1
    STA sprite_player + SPRITE_X
ReadRIGHT_Done: ;end if

;React to LEFT button
    LDA joypad1_state
    AND #BUTTON_LEFT
    BEQ ReadLEFT_Done ;if recieve input do this, else jump to ReadA_Done
    ;Decrement x pos of sprite
    LDA sprite_player + SPRITE_X
    SEC
    SBC #1
    STA sprite_player + SPRITE_X
ReadLEFT_Done: ;end if

;React to UP button
    LDA joypad1_state
    AND #BUTTON_UP
    BEQ ReadUP_Done ;if recieve input do this, else jump to ReadA_Done
    ;Decrement Y pos of sprite
    LDA sprite_player + SPRITE_Y
    SEC
    SBC #1
    STA sprite_player + SPRITE_Y
ReadUP_Done: ;end if

;React to DOWN button
    LDA joypad1_state
    AND #BUTTON_DOWN
    BEQ ReadDOWN_Done ;if recieve input do this, else jump to ReadA_Done
    ;Increment Y pos of sprite
    LDA sprite_player + SPRITE_Y
    CLC
    ADC #1
    STA sprite_player + SPRITE_Y
ReadDOWN_Done: ;end if

;React to A button
    LDA joypad1_state
    AND #BUTTON_A
    BEQ ReadA_Done ;if recieve input do this, else jump to ReadA_Done
    ; Spawn a bullet if one is not active
    LDA bullet_active
    BNE ReadA_Done
    ; No bullet active, spawn one
    LDA #1
    STA bullet_active
    LDA sprite_player + SPRITE_Y    ;Y pos
    STA sprite_bullet + SPRITE_Y
    LDA #2                          ;Tile number
    STA sprite_bullet + SPRITE_TILE
    LDA #1                          ;Attribute
    STA sprite_bullet + SPRITE_ATTRIB
    LDA sprite_player + SPRITE_X    ;X pos
    STA sprite_bullet + SPRITE_X
ReadA_Done: ;end if

;Update bullet
    LDA bullet_active
    BEQ UpdateBullet_Done
    LDA sprite_bullet + SPRITE_X
    SEC
    SBC #1
    STA sprite_bullet + SPRITE_X
    BCS UpdateBullet_Done
    ; If carry flag is clear, bullet has left the screen -- destroy it
    LDA #0
    STA bullet_active
UpdateBullet_Done:

    
    ;Scroll
    LDA scroll_x
    CLC
    ADC #1
    STA scroll_x
    STA PPUSCROLL
    BCC Scroll_NoWrap
    ; scroll_x has wrapped, so switch, scroll_page
    LDA scroll_page
    EOR #1
    STA scroll_page
    ORA #%10000000
    STA PPUCTRL
Scroll_NoWrap:
    LDA #0
    STA PPUSCROLL



;Copy sprite data to the PPU
    LDA #0
    STA OAMADDR
    LDA #$02
    STA OAMDMA

    RTI  ;Return from interrupt

;----------------
    .bank 1
    .org $FFFA
    .dw NMI
    .dw RESET
    .dw 0
;--------------
    .bank 2
    .org $0000
    ;Graphics here
    .incbin "payday.chr"