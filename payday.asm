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

    .rsset $0010
joypad1_state   .rs 1


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
    
    
    ; Reset the PPU high/low latch
    LDA PPUSTATUS
    ; Write adress 3f10 to the PPU
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
    LDA #$26
    STA PPUDATA



    ;Write sprite data for sprite 0
    LDA #120    ;Y pos
    STA $0200
    LDA #0      ;Tile number
    STA $0201
    LDA #0      ;Attribute
    STA $0202
    LDA #128    ;X pos
    STA $0203

    ;Write sprite data for sprite 1
    LDA #60    ;Y pos
    STA $0204
    LDA #1      ;Tile number
    STA $0205
    LDA #1      ;Attribute
    STA $0206
    LDA #190    ;X pos
    STA $0207

    LDA #%10000000 ;Enamble NMI
    STA PPUCTRL

    LDA #%00010000 ;Enable Sprites
    STA PPUMASK



;Infinite loop
forever:
    JMP forever

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
    LDA $0203
    CLC
    ADC #1
    STA $0203
ReadRIGHT_Done: ;end if

;React to LEFT button
    LDA joypad1_state
    AND #BUTTON_LEFT
    BEQ ReadLEFT_Done ;if recieve input do this, else jump to ReadA_Done
    ;Decrement x pos of sprite
    LDA $0203
    SEC
    SBC #1
    STA $0203
ReadLEFT_Done: ;end if

;React to UP button
    LDA joypad1_state
    AND #BUTTON_UP
    BEQ ReadUP_Done ;if recieve input do this, else jump to ReadA_Done
    ;Decrement Y pos of sprite
    LDA $0200
    SEC
    SBC #1
    STA $0200
ReadUP_Done: ;end if

;React to DOWN button
    LDA joypad1_state
    AND #BUTTON_DOWN
    BEQ ReadDOWN_Done ;if recieve input do this, else jump to ReadA_Done
    ;Increment Y pos of sprite
    LDA $0200
    CLC
    ADC #1
    STA $0200
ReadDOWN_Done: ;end if




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