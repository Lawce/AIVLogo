.db "NES", $1A, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0

.org $8000

.define PPUCTRL $2000
.define PPUMASK $2001
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUSCROLL $2005
.define PPUADDR $2006
.define PPUDATA $2007
.define OAMDMA $4014
.define JOYPAD1 $4016
.define JOYPAD2 $4017
.define scroll_x $06
.define scroll_y $07
.define buttons $01
.define nametable_pos $02
.define tile_pos $03
.define index_1 $04
.define index_2 $05
.define mask_bitmask #%00011110

start:
    LDA #%10000000
    STA PPUCTRL
    LDA mask_bitmask
    STA PPUMASK

    LDA #$3f
    STA PPUADDR
    LDA #0
    STA PPUADDR

    LDA #$0f
    STA PPUDATA
    LDA #$20
    STA PPUDATA
    LDA #$28
    STA PPUDATA
    LDA #$20
    STA PPUDATA

    LDA #$3f
    STA PPUADDR
    LDA #$10
    STA PPUADDR

    LDA #$1c
    STA PPUDATA
    LDA #$19
    STA PPUDATA
    LDA #$16
    STA PPUDATA
    LDA #$24
    STA PPUDATA

    LDA #0
    STA OAMADDR
    LDA #$22
    STA OAMDATA
    LDA #$94
    STA OAMDATA
    LDA #%10000001
    STA OAMDATA
    LDA #$22
    STA OAMDATA

    LDA #$20
    STA nametable_pos
    LDA #$00
    STA tile_pos

    JSR draw

    LDA #$24
    STA nametable_pos
    LDA #$00
    STA tile_pos

    JSR draw

loop:
    JMP loop

readjoy:
    LDA #$01
    STA JOYPAD1
    STA buttons
    LSR A
    STA JOYPAD1
joyloop:
    LDA JOYPAD1
    LSR A
    ROL buttons
    BCC joyloop
    RTS



moveright:
  LDA buttons
  AND #%00000001

  BEQ skip_left_scroll

  LDA #3

  STA OAMADDR
  LDA scroll_x

  CMP #250
  BEQ skip_max_x
  JMP increase_x

  skip_max_x:
    rts

  increase_x:
    INC scroll_x

  STA OAMDATA

  skip_left_scroll:

  rts

moveleft:
  LDA buttons
  AND #%00000010
  
  BEQ skip_right_scroll

  LDA #3

  STA OAMADDR
  LDA scroll_x

  CMP #0
  BEQ skip_min_x
  JMP decrease_x

  skip_min_x:
    rts

  decrease_x:
    DEC scroll_x

  
  STA OAMDATA

  skip_right_scroll:

  rts


moveup:
  LDA buttons
  AND #%00001000

  BEQ skip_up_scroll

  LDA #0

  STA OAMADDR
  LDA scroll_y

  CMP #5
  BEQ skip_min_y
  JMP decrease_y

  skip_min_y:
    rts

  decrease_y:
    DEC scroll_y


  STA OAMDATA

  skip_up_scroll:

  rts

movedown:
  LDA buttons
  AND #%00000100

  BEQ skip_down_scroll

  LDA #0

  STA OAMADDR
  LDA scroll_y

  CMP #232
  BEQ skip_max_y
  JMP increase_y

  skip_max_y:
    rts

  increase_y:
    INC scroll_y

  STA OAMDATA

  skip_down_scroll:

  rts
nmi:
    PHA
    JSR readjoy
    PLA

    JSR movedown
    JSR moveup
    JSR moveleft
    JSR moveright


    LDA scroll_x
    STA PPUSCROLL
    LDA scroll_y
    STA PPUSCROLL

    RTI


draw:
  LDA #%10000100
  STA PPUCTRL
  
  LDX #$10
  STX index_1
  STX index_2

increment:
  LDA nametable_pos
  STA PPUADDR

  LDA tile_pos
  STA PPUADDR

  loop2:
    STA PPUDATA
    CLC
    ADC #$10
    STA tile_pos
    DEC index_1
    BNE loop2

  INC tile_pos
  LDX #$10
  STX index_1
  DEC index_2


  BNE increment
rts


irq:
    RTI

.goto $FFFA

.dw nmi
.dw start
.dw irq

.incbin "aiv256.chr"