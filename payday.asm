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

PLAYER_DIRECTION_LEFT   = %00001000
PLAYER_DIRECTION_UP     = %00000100
PLAYER_DIRECTION_RIGHT  = %00000010
PLAYER_DIRECTION_DOWN   = %00000001

BULLET_DIRECTION_LEFT   = %00001000
BULLET_DIRECTION_UP     = %00000100
BULLET_DIRECTION_RIGHT  = %00000010
BULLET_DIRECTION_DOWN   = %00000001

BULLET_ACTIVE_BOOLEAN   = %10000000
BULLET_DESTROY_BOOLEAN  = %01000000
BULLET_SPEED            = 1

SPRITE_TOP_ATTRIBUTE    = %00000000
SPRITE_BOTTOM_ATTRIBUTE = %00000001
SPRITE_FLIP_HORIZONTAL  = %01000000

TILE_SIZE       = 8
SCREEN_LEFT_X   = 1
SCREEN_RIGHT_X  = 254
SCREEN_TOP_Y    = 1
SCREEN_BOTTOM_Y = 224

    .rsset $0000
joypad1_state           .rs 1
player_direction        .rs 1   ;8 bits only %0000XXXX if there is a 1 then player is facing that direction LEFT=%00001000 UP=%00000100 RIGHT=%00000010 DOWN=%00000001
bullet_info             .rs 1   ;bullet_active=%X0000000 and bullet_destroy=%0X000000 and bullet_direction=%0000XXXX
nametable_adress        .rs 2


    .rsset $0200
sprite_player_top       .rs 4
sprite_player_bottom    .rs 4
sprite_gun              .rs 4
sprite_bullet           .rs 4

    .rsset $0000
SPRITE_Y                .rs 1
SPRITE_TILE             .rs 1
SPRITE_ATTRIB           .rs 1
SPRITE_X                .rs 1


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

    ; Write the bg color for title screen
    LDA #$0F
    STA PPUDATA
    LDA #$30
    STA PPUDATA
    LDA #$15
    STA PPUDATA
    LDA #$00
    STA PPUDATA

    ; Write the bg color for bank
    LDA #$0F
    STA PPUDATA
    LDA #$39
    STA PPUDATA
    LDA #$38
    STA PPUDATA
    LDA #$15
    STA PPUDATA




    ; Write adress 3f10 to the PPU (Sprite pallet)
    LDA #$3F
    STA PPUADDR
    LDA #$10
    STA PPUADDR


    ; Write the pallet color for player top sprite
    LDA #$0F          ;bg color is transparency
    STA PPUDATA
    LDA #$15
    STA PPUDATA
    LDA #$20
    STA PPUDATA
    LDA #$01
    STA PPUDATA

    ; Write pallet color for player bottom sprite
    LDA #$0F          ;bg color is transparency
    STA PPUDATA
    LDA #$0E
    STA PPUDATA
    LDA #$2D
    STA PPUDATA
    LDA #$27
    STA PPUDATA

    ; Write pallet color for Money
    LDA #$0F          ;bg color is transparency
    STA PPUDATA
    LDA #$09
    STA PPUDATA
    LDA #$19
    STA PPUDATA
    LDA #$29
    STA PPUDATA



    ;Write sprite data for sprite_player_top
    LDA #120    ;Y pos
    STA sprite_player_top + SPRITE_Y
    LDA #$04      ;Tile number
    STA sprite_player_top + SPRITE_TILE
    LDA #0      ;Attribute
    STA sprite_player_top + SPRITE_ATTRIB
    LDA #128    ;X pos
    STA sprite_player_top + SPRITE_X

    ;Write sprite data for sprite_player_bottom
    LDA #128    ;Y pos
    STA sprite_player_bottom + SPRITE_Y
    LDA #$14      ;Tile number
    STA sprite_player_bottom + SPRITE_TILE
    LDA #1      ;Attribute
    STA sprite_player_bottom + SPRITE_ATTRIB
    LDA #128    ;X pos
    STA sprite_player_bottom + SPRITE_X

    

    ;Set player direction LEFT, because that is the direction the sprites start
    LDA #PLAYER_DIRECTION_LEFT
    STA player_direction
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

    

    ;Generate initial level

    ;Load attribute data
    LDA #$23           ;Write adress $23C0 to PPuADDR register
    STA PPUADDR
    LDA #$C0
    STA PPUADDR

    LDA #%00000000
    LDX #64
LoadAttributes_Loop:
    STA PPUDATA
    DEX
    BNE LoadAttributes_Loop



    RTS ;End subroutine
;--------------------
NametableData:
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF 
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF 
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5A, $5B, $53, $54, $55, $56, $57, $58, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6A, $6B, $63, $64, $65, $66, $67, $68, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7A, $7B, $73, $74, $75, $76, $77, $78, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8A, $8B, $8C, $8D, $8E, $8F, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $90, $91, $92, $93, $94, $95, $96, $97, $98, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF 
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF 
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF 
    .db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .db $00 ;null terminator
;--------------------
;--------------------
; NametableData:
;     .db $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21 
;     .db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10 
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23
;     .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
;     .db $30, $43, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $44 
;     .db $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41 
;     .db $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $30, $30, $30, $30, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31 
;     .db $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $23, $30, $30, $13, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11 
;     .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20 
;     .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
;     .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20 
;     .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
;     .db $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $23, $30, $30, $13, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11 
;     .db $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $30, $30, $30, $30, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32 
;     .db $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $30, $30, $30, $30, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31 
;     .db $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $23, $30, $30, $13, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11 
;     .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20 
;     .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
;     .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20
;     .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
;     .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20
;     .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
;     .db $00 ;null terminator
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
    LDA sprite_player_top + SPRITE_X
    CLC
    ADC #1
    STA sprite_player_top + SPRITE_X    
    STA sprite_player_bottom + SPRITE_X ;The x position for both sprites is identical, so increment both
    LDA #PLAYER_DIRECTION_RIGHT         ;Set RIGHT direction to True
    STA player_direction                ;Write it into player direction
    
ReadRIGHT_Done: ;end if

;React to LEFT button
    LDA joypad1_state
    AND #BUTTON_LEFT
    BEQ ReadLEFT_Done ;if recieve input do this, else jump to ReadA_Done
    ;Decrement x pos of sprite
    LDA sprite_player_top + SPRITE_X
    SEC
    SBC #1
    STA sprite_player_top + SPRITE_X    
    STA sprite_player_bottom + SPRITE_X ;The x position for both sprites is identical, so decrement both
    LDA #PLAYER_DIRECTION_LEFT          ;Set LEFT direction to True
    STA player_direction                ;Write it into player direction
ReadLEFT_Done: ;end if

;React to UP button
    LDA joypad1_state
    AND #BUTTON_UP
    BEQ ReadUP_Done ;if recieve input do this, else jump to ReadA_Done
    ;Decrement Y pos of sprite
    LDA sprite_player_top + SPRITE_Y
    SEC
    SBC #1
    STA sprite_player_top + SPRITE_Y
    CLC                                 
    ADC #TILE_SIZE
    STA sprite_player_bottom + SPRITE_Y ;The y position of the bottom sprite is offset by TILE_SIZE = 8
    LDA #PLAYER_DIRECTION_UP            ;Set UP direction to True
    STA player_direction                ;Write it into player direction
ReadUP_Done: ;end if

;React to DOWN button
    LDA joypad1_state
    AND #BUTTON_DOWN
    BEQ ReadDOWN_Done ;if recieve input do this, else jump to ReadA_Done
    ;Increment Y pos of sprite
    LDA sprite_player_top + SPRITE_Y
    CLC
    ADC #1
    STA sprite_player_top + SPRITE_Y
    CLC
    ADC #TILE_SIZE
    STA sprite_player_bottom + SPRITE_Y ;The y position of the bottom sprite is offset by TILE_SIZE = 8
    LDA #PLAYER_DIRECTION_DOWN          ;Set UP direction to True
    STA player_direction                ;Write it into player direction
ReadDOWN_Done: ;end if

;Update player_sprite_tile based on the current player_direction
    ;Reset the flip of sprites incase it was flipped.
    LDA #SPRITE_TOP_ATTRIBUTE
    STA sprite_player_top+SPRITE_ATTRIB             
    LDA #SPRITE_BOTTOM_ATTRIBUTE
    STA sprite_player_bottom+SPRITE_ATTRIB
;Direction_Left:
    LDA player_direction        
    AND #PLAYER_DIRECTION_LEFT
    BEQ Direction_Up
    LDA #$04
    STA sprite_player_top+SPRITE_TILE
    LDA #$14
    STA sprite_player_bottom+SPRITE_TILE
    JMP Direction_Set
Direction_Up:
    LDA player_direction 
    AND #PLAYER_DIRECTION_UP  
    BEQ Direction_Right
    LDA #$05
    STA sprite_player_top+SPRITE_TILE
    LDA #$15
    STA sprite_player_bottom+SPRITE_TILE
    JMP Direction_Set
Direction_Right:
    LDA player_direction 
    AND #PLAYER_DIRECTION_RIGHT  
    BEQ Direction_Down
    LDA sprite_player_top+SPRITE_ATTRIB
    ORA #SPRITE_FLIP_HORIZONTAL                     ;|+------- Flip sprite horizontally(From nes dev wiki)
    STA sprite_player_top+SPRITE_ATTRIB    
    LDA sprite_player_bottom+SPRITE_ATTRIB
    ORA #SPRITE_FLIP_HORIZONTAL                  
    STA sprite_player_bottom+SPRITE_ATTRIB
    LDA #$04
    STA sprite_player_top+SPRITE_TILE
    LDA #$14
    STA sprite_player_bottom+SPRITE_TILE
    JMP Direction_Set
Direction_Down:
    LDA #$06
    STA sprite_player_top+SPRITE_TILE
    LDA #$16
    STA sprite_player_bottom+SPRITE_TILE
Direction_Set:
    


;React to A button
    LDA joypad1_state
    AND #BUTTON_A
    BEQ ReadA_Done ;if recieve input do this, else jump to ReadA_Done
    ; Spawn a bullet if one is not active
    LDA bullet_info
    AND #BULLET_ACTIVE_BOOLEAN
    BNE ReadA_Done
    ; LDA #BULLET_ACTIVE_BOOLEAN
    ; STA bullet_info
    ; No bullet active, spawn one
    LDA player_direction
    CLC 
    ADC #BULLET_ACTIVE_BOOLEAN
    STA bullet_info                ;set the direction the bullet was shot
    AND #PLAYER_DIRECTION_LEFT
    BEQ Shoot_Up
    LDA sprite_player_bottom + SPRITE_Y    ;Y pos
    CLC
    ADC #1                          ;+1 to shoot from the gun
    STA sprite_bullet + SPRITE_Y
    LDA #2                          ;Tile number
    STA sprite_bullet + SPRITE_TILE
    LDA #1                          ;Attribute
    STA sprite_bullet + SPRITE_ATTRIB
    LDA sprite_player_bottom + SPRITE_X    ;X pos
    STA sprite_bullet + SPRITE_X
    JMP ReadA_End
ReadA_Done:
    JMP ReadA_End
Shoot_Up:
    LDA player_direction        
    AND #PLAYER_DIRECTION_UP
    BEQ Shoot_Right
    LDA sprite_player_top + SPRITE_Y    ;Y pos
    STA sprite_bullet + SPRITE_Y
    LDA #2                          ;Tile number
    STA sprite_bullet + SPRITE_TILE
    LDA #1                          ;Attribute
    STA sprite_bullet + SPRITE_ATTRIB
    LDA sprite_player_top + SPRITE_X   ;X pos
    CLC
    ADC #5                          ;+5 to shoot more from the center of the sprite
    STA sprite_bullet + SPRITE_X
    JMP ReadA_End
Shoot_Right:
    LDA player_direction        
    AND #PLAYER_DIRECTION_RIGHT
    BEQ Shoot_Down
    LDA sprite_player_bottom + SPRITE_Y    ;Y pos
    CLC
    ADC #1                          ;+1 to shoot from the gun
    STA sprite_bullet + SPRITE_Y
    LDA #2                          ;Tile number
    STA sprite_bullet + SPRITE_TILE
    LDA #1                          ;Attribute
    STA sprite_bullet + SPRITE_ATTRIB
    LDA sprite_player_bottom + SPRITE_X    ;X pos
    CLC
    ADC #6      ;+6 to shoot from the right side
    STA sprite_bullet + SPRITE_X
    JMP ReadA_End
Shoot_Down:
    LDA sprite_player_bottom + SPRITE_Y    ;Y pos
    CLC
    ADC #6
    STA sprite_bullet + SPRITE_Y
    LDA #2                          ;Tile number
    STA sprite_bullet + SPRITE_TILE
    LDA #1                          ;Attribute
    STA sprite_bullet + SPRITE_ATTRIB
    LDA sprite_player_bottom + SPRITE_X    ;X pos
    ADC #1
    STA sprite_bullet + SPRITE_X
ReadA_End: ;end if

;Update bullet
    LDA bullet_info
    AND #BULLET_ACTIVE_BOOLEAN
    BEQ UpdateBullet_End
;UpdateBullet_Left:
    LDA bullet_info
    AND #BULLET_DIRECTION_LEFT
    BEQ UpdateBullet_Up
    LDA sprite_bullet + SPRITE_X
    SEC
    SBC #BULLET_SPEED
    STA sprite_bullet + SPRITE_X
    JMP UpdateBullet_Done
UpdateBullet_Up:
    LDA bullet_info
    AND #BULLET_DIRECTION_UP
    BEQ UpdateBullet_Right
    LDA sprite_bullet + SPRITE_Y
    SEC
    SBC #BULLET_SPEED
    STA sprite_bullet + SPRITE_Y
    JMP UpdateBullet_Done
UpdateBullet_Right:
    LDA bullet_info
    AND #BULLET_DIRECTION_RIGHT
    BEQ UpdateBullet_Down
    LDA sprite_bullet + SPRITE_X
    CLC
    ADC #BULLET_SPEED
    STA sprite_bullet + SPRITE_X
    JMP UpdateBullet_Done
UpdateBullet_Down:
    LDA sprite_bullet + SPRITE_Y
    CLC
    ADC #BULLET_SPEED
    STA sprite_bullet + SPRITE_Y
UpdateBullet_Done:

UpdateBullet_Destroy_Left:
    LDA sprite_bullet + SPRITE_X
    CMP #SCREEN_LEFT_X
    BNE UpdateBullet_Destroy_Up
    JMP Destroy_bullet
UpdateBullet_Destroy_Up:
    LDA sprite_bullet + SPRITE_Y
    CMP #SCREEN_TOP_Y
    BNE UpdateBullet_End
Destroy_bullet:
    LDA #0
    STA bullet_info
UpdateBullet_End:

    

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