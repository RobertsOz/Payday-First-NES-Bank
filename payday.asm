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
PLAYER_START_X_POS      = 128
PLAYER_START_Y_POS      = 200

BULLET_DIRECTION_LEFT   = %00001000
BULLET_DIRECTION_UP     = %00000100
BULLET_DIRECTION_RIGHT  = %00000010
BULLET_DIRECTION_DOWN   = %00000001

BULLET_ACTIVE_BOOLEAN   = %10000000
BULLET_DESTROY_BOOLEAN  = %01000000
BULLET_SPEED            = 3
BULLET_HITBOX           = 2

SPRITE_TOP_ATTRIBUTE    = %00000000
SPRITE_BOTTOM_ATTRIBUTE = %00000001
SPRITE_GREEN_ATTRIBUTE  = %00000010
SPRITE_ENEMY_ATTRIBUTE  = %00000011
SPRITE_FLIP_HORIZONTAL  = %01000000

BOOL = %00000001

TILE_SIZE       = 8
SCREEN_LEFT_X   = 7
SCREEN_RIGHT_X  = 249
SCREEN_TOP_Y    = 25
SCREEN_BOTTOM_Y = 224
SCROLL_BANK_X   = 255

;[P]layer_[T]op/[B]ottom_[Direction] = Tile
P_T_Left        = $04
P_T_Up          = $05
P_T_Down        = $06
P_B_Left        = $14
P_B_Up          = $15
P_B_Down        = $16
;Unarmed
P_T_Left_Un     = $24
P_T_Up_Un       = $25
P_T_Down_Un     = $26
P_B_Left_Un     = $34
P_B_Up_Un       = $35

;Bank Manager Tiles (_After is when the heist is started)
Manager_Top             = $07
Manager_Top_After       = $08
Manager_Bottom          = $17
Manager_Bottom_After    = $18
Manager_Card            = $45

SPRITE_ARROW            = $46
SPRITE_ARROW_X          = 12
SPRITE_ARROW_Y          = 112
SPRITE_GATE             = $41
SPRITE_GATE_X           = 12
SPRITE_GATE_Y           = 103
SPRITE_DRILL            = $47
SPRITE_DRILL_OUTLINE    = $48
SPRITE_DRILL_X          = 124
SPRITE_DRILL_Y          = 27

MANAGER_POSITION_X      = 200
MANAGER_POSITION_Y      = 100
SPRITE_HITBOX_WIDTH     = 8
SPRITE_HITBOX_HEIGHT    = 16

SPRITE_ENEMY_START_X    = 128
SPRITE_ENEMY_START_Y    = 200
SPRITE_ENEMY_T_TILE     = $27
SPRITE_ENEMY_B_TILE     = $37
ENEMY_SPEED             = 2
    .rsset $0000
current_gamestate       .rs 1
joypad1_state           .rs 1
player_direction        .rs 1   ;8 bits only %0000XXXX if there is a 1 then player is facing that direction LEFT=%00001000 UP=%00000100 RIGHT=%00000010 DOWN=%00000001
bullet_info             .rs 1   ;bullet_active=%X0000000 and bullet_destroy=%0X000000 and bullet_direction=%0000XXXX
current_top_collision   .rs 1
enemy_dead              .rs 1
enemy_respawn           .rs 1
nametable_adress        .rs 2


    .rsset $0200
sprite_player_top       .rs 4
sprite_player_bottom    .rs 4
sprite_bullet           .rs 4
sprite_manager_top      .rs 4
sprite_manager_bottom   .rs 4
sprite_manager_card     .rs 4
sprite_arrow            .rs 4
sprite_gate             .rs 4
sprite_drill            .rs 4
sprite_enemy_top        .rs 4
sprite_enemy_bottom     .rs 4

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
    JSR LoadNametableSubroutine   ;Load backgrounds
    JSR Initialise_Game

    LDA #%10000000 ;Enamble NMI
    STA PPUCTRL

    LDA #%00011000 ;Enable Sprites and Background
    STA PPUMASK

    LDA #0
    STA PPUSCROLL ;Set x scroll
    STA PPUSCROLL ;Set y scroll



;Infinite loop
forever:
    JMP forever

;--------------------
Initialise_Game: ;Start Initialise_Game subroutine
    
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
    LDA #$26
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

    ; Write pallet color for Enemies
    LDA #$0F          ;bg color is transparency
    STA PPUDATA
    LDA #$0E
    STA PPUDATA
    LDA #$2C
    STA PPUDATA
    LDA #$27
    STA PPUDATA

    ;Set gamestate to 0 
    LDA #$00
    STA current_gamestate ;Set current gamestate to $00
    ;Set player direction LEFT, because that is the direction the sprites start
    LDA #PLAYER_DIRECTION_LEFT
    STA player_direction
    LDA #SPRITE_GATE_Y
    STA current_top_collision
    

    RTS ;End Initialise_Game subroutine
;-------------------- Loadnametable macro
                    ;               \1       \2         \3      \4
LoadNamtable .macro ; parameters: adress1, adress2, nametable, attribute
    LDA \1           ;Write adress $[adress1][adress2] to PPuADDR register
    STA PPUADDR
    LDA \2
    STA PPUADDR
    
    LDA #LOW(\3)
    STA nametable_adress
    LDA #HIGH(\3)
    STA nametable_adress+1
.LoadNametable_OuterLoop\@:
    LDY #0
.LoadNametable_InnerLoop\@:
    LDA [nametable_adress], y
    BEQ .LoadNametable_End\@
    STA PPUDATA
    INY
    BNE .LoadNametable_InnerLoop\@
    INC nametable_adress+1
    JMP .LoadNametable_OuterLoop\@
    
.LoadNametable_End\@:
    ;Load attribute
    LDA #$27           ;Write adress $27C0 to PPuADDR register
    STA PPUADDR
    LDA #$C0
    STA PPUADDR

    LDA \4
    LDX #64
.LoadAttributes_Loop\@:
    STA PPUDATA
    DEX
    BNE .LoadAttributes_Loop\@
    
    .endm
;-------------------- LoadNametableSubroutine subroutine
LoadNametableSubroutine:
;Load nametable data for Title Screen

    LoadNamtable #$20, #$00, NametableData, #%00000000
;-----Bank Data
;Load nametable For Bank
    LoadNamtable #$24, #$00, BankNametableData, #%01010101
    
; ;------Vault Data

    RTS ;End of LoadNametableSubroutine Subroutine

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
BankNametableData:
    .db $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21 
    .db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $09, $0A, $0B, $0C, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10
    .db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $19, $1A, $1B, $1C, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10
    .db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $29, $2A, $2B, $2C, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
    .db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $39, $3A, $3B, $3C, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
    .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23
    .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23
    .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
    .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
    .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
    .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23
    .db $30, $13, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $42, $23 
    .db $30, $43, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $44 
    .db $30, $30, $30, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41 
    .db $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $30, $30, $30, $30, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31 
    .db $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $23, $30, $30, $13, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11 
    .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20 
    .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
    .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20 
    .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
    .db $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $23, $30, $30, $13, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11 
    .db $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $30, $30, $30, $30, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32, $32 
    .db $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $30, $30, $30, $30, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31, $31 
    .db $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $23, $30, $30, $13, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11 
    .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20 
    .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
    .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20
    .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
    .db $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $11, $23, $30, $30, $13, $11, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20
    .db $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $11, $23, $30, $30, $13, $11, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10, $20, $10 
    .db $00 ;null terminator
;--------------------
;-------------------- ReadInput Subroutine
ReadInput:
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

    RTS ;End ReadInput Subroutine
;-------------------- Movement Subroutine
Movement:



;React to RIGHT button
    LDA joypad1_state
    AND #BUTTON_RIGHT
    BEQ ReadRIGHT_Done ;if recieve input do this, else jump to ReadA_Done
    ;Increment x pos of sprite
    LDA sprite_player_top + SPRITE_X
    CLC
    ADC #1
    CMP #SCREEN_RIGHT_X
    BEQ hitWall_Right
    STA sprite_player_top + SPRITE_X    
    STA sprite_player_bottom + SPRITE_X ;The x position for both sprites is identical, so increment both
hitWall_Right:
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
    CMP #SCREEN_LEFT_X
    BEQ hitWall_Left
    STA sprite_player_top + SPRITE_X    
    STA sprite_player_bottom + SPRITE_X ;The x position for both sprites is identical, so decrement both
hitWall_Left:
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
    CMP current_top_collision
    BEQ hitWall_Top
    STA sprite_player_top + SPRITE_Y
    CLC                                 
    ADC #TILE_SIZE
    STA sprite_player_bottom + SPRITE_Y ;The y position of the bottom sprite is offset by TILE_SIZE = 8
hitWall_Top:
    LDA #PLAYER_DIRECTION_UP            ;Set UP direction to True
    STA player_direction                ;Write it into player direction
ReadUP_Done: ;end if

;React to DOWN button
    LDA joypad1_state
    AND #BUTTON_DOWN
    BEQ ReadDOWN_Done ;if recieve input do this, else jump to ReadA_Done
    ;Increment Y pos of sprite
    LDA sprite_player_bottom + SPRITE_Y
    CLC
    ADC #1
    CMP #SCREEN_BOTTOM_Y
    BEQ hitWall_Bottom
    STA sprite_player_bottom + SPRITE_Y
    SEC 
    SBC #TILE_SIZE                      ;The y position of the bottom sprite is offset by TILE_SIZE = 8
    STA sprite_player_top + SPRITE_Y
hitWall_Bottom:
    LDA #PLAYER_DIRECTION_DOWN          ;Set DOWN direction to True
    STA player_direction                ;Write it into player direction
ReadDOWN_Done: ;end if

    RTS ; Movement Subroutine END
;-------------------- UpdateSpriteDirection Macro
                                ;           \1                 \2                   \3       \4    \5      \6      \7    \8
UpdateSpriteDirections .macro ; parameters: top_color_pallete, bottom_color_pallete, t_left, t_up, t_down, b_left, b_up, b_right
    ;Update player_sprite_tile based on the current player_direction
    ;Reset the flip of sprites incase it was flipped.
    LDA \1
    STA sprite_player_top+SPRITE_ATTRIB             
    LDA \2
    STA sprite_player_bottom+SPRITE_ATTRIB
;.Direction_Left:
    LDA player_direction        
    AND #PLAYER_DIRECTION_LEFT
    BEQ .Direction_Up
    LDA \3
    STA sprite_player_top+SPRITE_TILE
    LDA \6
    STA sprite_player_bottom+SPRITE_TILE
    JMP .Direction_Set
.Direction_Up:
    LDA player_direction 
    AND #PLAYER_DIRECTION_UP  
    BEQ .Direction_Right
    LDA \4
    STA sprite_player_top+SPRITE_TILE
    LDA \7
    STA sprite_player_bottom+SPRITE_TILE
    JMP .Direction_Set
.Direction_Right:
    LDA player_direction 
    AND #PLAYER_DIRECTION_RIGHT  
    BEQ .Direction_Down
    LDA sprite_player_top+SPRITE_ATTRIB
    ORA #SPRITE_FLIP_HORIZONTAL                     ;|+------- Flip sprite horizontally(From nes dev wiki)
    STA sprite_player_top+SPRITE_ATTRIB    
    LDA sprite_player_bottom+SPRITE_ATTRIB
    ORA #SPRITE_FLIP_HORIZONTAL                  
    STA sprite_player_bottom+SPRITE_ATTRIB
    LDA \3
    STA sprite_player_top+SPRITE_TILE
    LDA \6
    STA sprite_player_bottom+SPRITE_TILE
    JMP .Direction_Set
.Direction_Down:
    LDA \5
    STA sprite_player_top+SPRITE_TILE
    LDA \8
    STA sprite_player_bottom+SPRITE_TILE
.Direction_Set:
    .endm
;-------------------- ShootInput Subroutine
ShootInput:
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

    RTS ;End of ShootInput Subroutine
;--------------------   UpdateBullet Subroutine
UpdateBullet:
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
    JMP Destroy_Negative
UpdateBullet_Up:
    LDA bullet_info
    AND #BULLET_DIRECTION_UP
    BEQ UpdateBullet_Right
    LDA sprite_bullet + SPRITE_Y
    SEC
    SBC #BULLET_SPEED
    STA sprite_bullet + SPRITE_Y
    JMP Destroy_Negative
UpdateBullet_Right:
    LDA bullet_info
    AND #BULLET_DIRECTION_RIGHT
    BEQ UpdateBullet_Down
    LDA sprite_bullet + SPRITE_X
    CLC
    ADC #BULLET_SPEED
    STA sprite_bullet + SPRITE_X
    JMP Destroy_Positive
UpdateBullet_Down:
    LDA sprite_bullet + SPRITE_Y
    CLC
    ADC #BULLET_SPEED
    STA sprite_bullet + SPRITE_Y
Destroy_Positive: ;Destroy the bullet Positive overflowed
    BCC UpdateBullet_End
    JSR Destroy_bullet  ;Destroy bullet subroutine
    JMP UpdateBullet_End
Destroy_Negative: ;Destroy the bullet Negative overflowed
    BCS UpdateBullet_End
    JSR Destroy_bullet  ;Destroy bullet subroutine

UpdateBullet_End:
    
    RTS ;End of UpdateBullet Subroutine
;-------------------- Destroy_bullet subroutine
Destroy_bullet:
    LDA #0
    STA sprite_bullet+SPRITE_X ;Set bullet X to 0 so the bullet doesn't poke out of the right side of the screen
    STA bullet_info
    RTS ;End Destroy bullet subroutine

;-------------------- Initialise_Player Subroutine
Initialise_Bank:
;Write sprite data for Manager
    ;Top
    LDA #SPRITE_ENEMY_ATTRIBUTE
    STA sprite_manager_top + SPRITE_ATTRIB
    STA sprite_manager_bottom + SPRITE_ATTRIB
    LDA #Manager_Top
    STA sprite_manager_top + SPRITE_TILE
    LDA #MANAGER_POSITION_X
    STA sprite_manager_top + SPRITE_X
    LDA #MANAGER_POSITION_Y
    STA sprite_manager_top + SPRITE_Y
    
    ;Bottom
    LDA #Manager_Bottom
    STA sprite_manager_bottom + SPRITE_TILE
    LDA #MANAGER_POSITION_X
    STA sprite_manager_bottom + SPRITE_X
    LDA #MANAGER_POSITION_Y+TILE_SIZE
    STA sprite_manager_bottom + SPRITE_Y
    
;Gate
    LDA #SPRITE_GREEN_ATTRIBUTE
    STA sprite_gate + SPRITE_ATTRIB
    LDA #SPRITE_GATE
    STA sprite_gate + SPRITE_TILE
    LDA #SPRITE_GATE_Y
    STA sprite_gate + SPRITE_Y
    LDA #SPRITE_GATE_X
    STA sprite_gate + SPRITE_X
;Write sprite data for sprite_player_top
    LDA #PLAYER_START_Y_POS    ;Y pos
    STA sprite_player_top + SPRITE_Y
    LDA #PLAYER_START_X_POS    ;X pos
    STA sprite_player_top + SPRITE_X
    STA sprite_player_bottom + SPRITE_X ;X pos of the bottom sprite is the same
    
;Write sprite data for sprite_player_bottom
    LDA #PLAYER_START_Y_POS+TILE_SIZE    ;Y pos +8 because 1 sprite is 8 pixels
    STA sprite_player_bottom + SPRITE_Y
    
    RTS ;End Initialise_Player Subroutine
;-------------------- Init Vault_1 subroutine
Initialise_Vault:
;Set up enemy sprite
    LDA #SPRITE_ENEMY_T_TILE
    STA sprite_enemy_top+SPRITE_TILE
    LDA #SPRITE_ENEMY_B_TILE
    STA sprite_enemy_bottom+SPRITE_TILE
    LDA #SPRITE_ENEMY_START_X
    STA sprite_enemy_top+SPRITE_X
    STA sprite_enemy_bottom+SPRITE_X
    LDA #SPRITE_ENEMY_START_Y
    STA sprite_enemy_top+SPRITE_Y
    LDA #SPRITE_ENEMY_START_Y+TILE_SIZE
    STA sprite_enemy_bottom+SPRITE_Y
    LDA #SPRITE_ENEMY_ATTRIBUTE
    STA sprite_enemy_top + SPRITE_ATTRIB
    STA sprite_enemy_bottom + SPRITE_ATTRIB

    RTS ;End Initialise_Vault Subroutine
;-------------------- CheckCollision Macro

CheckCollision .macro 
    ;             \1        \2        \3            \4             \5        \6              \7          \8             \9
    ; parameters: object_x, object_y, object_hit_w, object_hit_h , collision_x, collision_y, collision_w, collision_h, no_collision_label
    ; If there is a collision, execution continues immediately after this macro
    ; Else, jump to no_collision_label
    ;Check collision with bullet
    LDA \5   ;Calculate x_enemy - width_bullet - 1 (x1-w2-1)
    SEC 
    SBC \3+1                         
    CMP \1                          ;Compare with x_bullet(x2)
    BCS \9                          ;Branch if x1-w2 >= x2
    CLC
    ADC \3+1+\7                     ;Calculate x_enemy + w_enemy(x1+w1),assume w1 =8
    CMP \1                          ;Compare with x_bullet(x2)
    BCC \9                          ;Branching if x1+w1 < x2

    LDA \6                          ;Calculate y_enemy - width_bullet(y1-h2)
    SEC 
    SBC \4+1                           
    CMP \2                          ;Compare with y_bullet(y2)
    BCS \9                          ;Branch if y1-h2 >= y2
    CLC
    ADC \4+1+\8                     ;Calculate y_enemy + h_enemy(y1+h1),assume h1 =8
    CMP \2                          ;Compare with y_bullet(y2)
    BCC \9                          ;Branching if y1+h1 < y2

    .endm
;-------------------- Base Control Loop
ControlSubroutine:
    JSR ReadInput               ;Jump to subroutine to Read Input of the controller
    JSR Movement                ;Jump to subroutine to Reacto to directional pad input

    ;Do UpdateSpriteDirections macro to Update Sprite direction based on the last input (from Controls subroutine)
    ;1:Top sprite pallet, 2:Bottom sprite pallet, 3:4:5:Player top Sprites, 6:7:8:Player bottom Sprites
    UpdateSpriteDirections #SPRITE_TOP_ATTRIBUTE, #SPRITE_BOTTOM_ATTRIBUTE, #P_T_Left, #P_T_Up, #P_T_Down, #P_B_Left, #P_B_Up, #P_B_Down
    
    JSR ShootInput              ;Jump to subroutine to Read if A has been pressed, then shoot a bullet in the direction the player is facing
    JSR UpdateBullet            ;Jump to subroutine to Update the bullet in the direction it was shot

    RTS
;-------------------- Update Enemy subroutine
UpdateEnemy:
    LDA sprite_player_top+SPRITE_X
    STA sprite_enemy_top+SPRITE_X
    STA sprite_enemy_bottom+SPRITE_X
    LDA sprite_enemy_bottom+SPRITE_Y
    SEC
    SBC #ENEMY_SPEED
    STA sprite_enemy_bottom+SPRITE_Y
    SBC #TILE_SIZE  ;add tile sizefor top sprite(Because bottomsprite is in the Acummulator)
    STA sprite_enemy_top+SPRITE_Y

    ;check collision and kill player if there is collision
    CheckCollision sprite_player_top+SPRITE_X, sprite_player_top+SPRITE_Y, #SPRITE_HITBOX_WIDTH, #SPRITE_HITBOX_HEIGHT, sprite_enemy_top+SPRITE_X, sprite_enemy_top+SPRITE_Y, #SPRITE_HITBOX_WIDTH, #SPRITE_HITBOX_HEIGHT, Enemy_NoCollision
    JMP RESET ;Start the game again
Enemy_NoCollision:
    RTS ;end Update Enemy subroutine
;--------------------
; NMI called every frame
NMI:
    LDA current_gamestate
;Gamestate_TitleScreen:
    CMP #$00    ;TitleScreen Gamestate
    BNE Gamestate_Bank_0
    JMP TitleScreen
Gamestate_Bank_0:
    CMP #$01    ;Bank_0 Gamestate
    BNE Gamestate_Bank_1
    JMP Bank_0
Gamestate_Bank_1:
    CMP #$02    ;Bank_1 Gamestate
    BNE Gamestate_Bank_2
    JMP Bank_1
Gamestate_Bank_2:
    CMP #$03   ;Bank_2 Gamestate
    BNE Gamestate_Bank_3
    JMP Bank_2
Gamestate_Bank_3:
    CMP #$04   ;Bank_3 Gamestate
    BNE Gamestate_Vault_0
    JMP Bank_3
Gamestate_Vault_0:
    CMP #$05    ;Vault_0 Gamestate
    BNE Gamestate_Vault_1
    JMP Vault_0
Gamestate_Vault_1:
    CMP #$06    ;Vault_1 Gamestate
    BNE Gamestate_Vault_2
    JMP Vault_1
Gamestate_Vault_2:

TitleScreen:    ;Gamestate $00
    JSR ReadInput

    ;React to Start Press
    LDA joypad1_state
    AND #BUTTON_START       
    BEQ ReadStart_Done      ;If recieve input do this, else jump to ReadStart_Done
    
    ;Scroll screen to Bank Nametable
    LDA #SCROLL_BANK_X
    STA PPUSCROLL           ;Set x scroll
    JSR Initialise_Bank   ;Draw player
    LDA #$01
    STA current_gamestate   ;Switch Gamestate 
ReadStart_Done:             ;End If

    JMP NMI_End             ;Do NMI Loop

Bank_0:         ;Gamestate $01
    JSR ReadInput               ;Jump to subroutine to Read Input of the controller
    JSR Movement                ;Jump to subroutine to Reacto to directional pad input

    ;Do UpdateSpriteDirections macro to Update Sprite direction based on the last input (from Controls subroutine)
    ;1:Top sprite pallet, 2:Bottom sprite pallet, 3:4:5:Player top Sprites, 6:7:8:Player bottom Sprites
    UpdateSpriteDirections #SPRITE_BOTTOM_ATTRIBUTE, #SPRITE_BOTTOM_ATTRIBUTE, #P_T_Left_Un, #P_T_Up_Un, #P_T_Down_Un, #P_B_Left_Un, #P_B_Up_Un, #P_B_Up_Un
    
    ;React to B Press To start the Heist
    LDA joypad1_state
    AND #BUTTON_B      
    BEQ ReadB_Done              ;If recieve input do this, else jump to ReadStart_Done
    ;Set manager sprite to Hands up
    LDA #Manager_Top_After
    STA sprite_manager_top + SPRITE_TILE
    LDA #Manager_Bottom_After
    STA sprite_manager_bottom + SPRITE_TILE
    LDA #$02
    STA current_gamestate       ;Switch Gamestate
ReadB_Done:
    JMP NMI_End                 ;Do NMI Loop

Bank_1:         ;Gamestate $02
    JSR ControlSubroutine

    ;Check Bullet collision against Manager
    CheckCollision sprite_bullet+SPRITE_X, sprite_bullet+SPRITE_Y, #BULLET_HITBOX, #BULLET_HITBOX, sprite_manager_top+SPRITE_X, sprite_manager_top+SPRITE_Y, SPRITE_HITBOX_WIDTH, SPRITE_HITBOX_HEIGHT, Manager_NoCollision
    ;If bullet hit manager do this
    LDA #0          ;Set manager tile to 0 (Which is blank)
    STA sprite_manager_top+SPRITE_TILE
    STA sprite_manager_bottom+SPRITE_TILE
    JSR Destroy_bullet ;Destroy bullet
    ;Spawn card
    LDA #Manager_Card
    STA sprite_manager_card + SPRITE_TILE
    LDA #SPRITE_GREEN_ATTRIBUTE
    STA sprite_manager_card + SPRITE_ATTRIB
    LDA #MANAGER_POSITION_X
    STA sprite_manager_card + SPRITE_X
    LDA #MANAGER_POSITION_Y+TILE_SIZE
    STA sprite_manager_card + SPRITE_Y
    LDA #$03
    STA current_gamestate
Manager_NoCollision:
    JMP NMI_End                 ;Do NMI Loop

        

Bank_2:         ;Gamestate $03
    JSR ControlSubroutine
    ;Check collision against Manager Card
    CheckCollision sprite_player_top+SPRITE_X, sprite_player_top+SPRITE_Y, #SPRITE_HITBOX_WIDTH, #SPRITE_HITBOX_HEIGHT, sprite_manager_card+SPRITE_X, sprite_manager_card+SPRITE_Y, #SPRITE_HITBOX_WIDTH, #SPRITE_HITBOX_WIDTH, ManagerCard_NoCollision
    LDA #0
    STA sprite_manager_card+SPRITE_TILE ;set sprite to tile 0
    LDA #SPRITE_ARROW
    STA sprite_arrow+SPRITE_TILE
    LDA #SPRITE_GREEN_ATTRIBUTE
    STA sprite_arrow + SPRITE_ATTRIB
    LDA #SPRITE_ARROW_X
    STA sprite_arrow + SPRITE_X
    LDA #SPRITE_ARROW_Y
    STA sprite_arrow + SPRITE_Y
    LDA #$04
    STA current_gamestate
ManagerCard_NoCollision:
    JMP NMI_End                 ;Do NMI Loop

Bank_3:         ;Gamestate $04
    JSR ControlSubroutine
    ;Check Collision against arrow to go to the Vault
    CheckCollision sprite_player_top+SPRITE_X, sprite_player_top+SPRITE_Y, #SPRITE_HITBOX_WIDTH, #SPRITE_HITBOX_HEIGHT, sprite_arrow+SPRITE_X, sprite_arrow+SPRITE_Y, #SPRITE_HITBOX_WIDTH, #SPRITE_HITBOX_WIDTH, Arrow_NoCollision
    ;Set player position for next gamestate
    LDA #0
    STA sprite_arrow+SPRITE_TILE ;set sprite tile to 0
    STA sprite_gate+SPRITE_TILE
    LDA #SCREEN_TOP_Y
    STA current_top_collision
    LDA #$05
    STA current_gamestate
    LDA #SPRITE_DRILL_OUTLINE
    STA sprite_drill +SPRITE_TILE
    LDA #SPRITE_DRILL_X
    STA sprite_drill +SPRITE_X
    LDA #SPRITE_DRILL_Y
    STA sprite_drill +SPRITE_Y
    LDA #SPRITE_ENEMY_ATTRIBUTE
    STA sprite_drill+SPRITE_ATTRIB
Arrow_NoCollision:
    JMP NMI_End                 ;Do NMI Loop
    
Vault_0:
    JSR ControlSubroutine
    CheckCollision sprite_player_top+SPRITE_X, sprite_player_top+SPRITE_Y, #SPRITE_HITBOX_WIDTH, #SPRITE_HITBOX_HEIGHT, sprite_drill+SPRITE_X, sprite_drill+SPRITE_Y, #SPRITE_HITBOX_WIDTH, #SPRITE_HITBOX_WIDTH, Drill_NoCollision
    LDA #SPRITE_DRILL
    STA sprite_drill+SPRITE_TILE
    LDA #$06
    STA current_gamestate
    JSR Initialise_Vault
Drill_NoCollision:
    JMP NMI_End                 ;Do NMI Loop

Vault_1:
    JSR ControlSubroutine
    JSR UpdateEnemy
    ;Check bullet collision
    CheckCollision sprite_bullet+SPRITE_X, sprite_bullet+SPRITE_Y, #BULLET_HITBOX, #BULLET_HITBOX, sprite_enemy_top+SPRITE_X, sprite_enemy_top+SPRITE_Y, SPRITE_HITBOX_WIDTH, SPRITE_HITBOX_HEIGHT, Enemy_NoBulletCollision
    JSR Destroy_bullet
    LDA #0
    STA sprite_enemy_top+SPRITE_TILE
    STA sprite_enemy_bottom+SPRITE_TILE
    JSR Initialise_Vault
Enemy_NoBulletCollision:
    JMP NMI_End                 ;Do NMI Loop

NMI_End:
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