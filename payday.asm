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


    ;Write sprite data for sprite 0
    LDA #120    ;Y pos
    STA $0200
    LDA #0      ;Tile number
    STA $0201
    LDA #0      ;Attribute
    STA $0202
    LDA #128    ;X pos
    STA $0203

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
;Increment x pos of sprite
    LDA $0203
    CLC
    ADC #1
    STA $0203

;Increment y pos of sprite
    LDA $0200
    CLC
    ADC #1
    STA $0200


;Tell OAM where the sprites will be stored
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