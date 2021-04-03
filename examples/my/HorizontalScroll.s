;***************************************************
;Horizontal Scroll
;***************************************************
;Font and screen bitmaps are interleaved
;Supported fonts are 16 or 32 px wide
;Supported commands in text:
;1 - Pause, next byte is pause in frames
;2 - Set Speed, next byte is new speed max 16px

	REM
;Example scroll setup
	lea	HScroll_Example(pc),a0	;a0.l - Scroll struct
	lea	HScroll_Text(pc),a1	;a1.l - Text treminated by zero
	lea	HScroll_Font32,a2	;a2.l - Font
	lea	HScroll_VidMem,a3	;a3.l - Video memory
	lea	HScroll_CopperBP,a4	;a4.l - Copper bitmaps
	lea	HScroll_CopperSC,a5	;a5.l - Copper scroll reg

	move.w	#1,d0			;d0.w - Speed
	move.w	#320,d1			;d1.w - Screen width
	move.w	#3,d2			;d2.w - No bitmaps
	move.w	#32,d3			;d3.w - Font letter width
	move.w	#25,d4			;d4.w - Font letter height
	move.w	#10,d5			;d5.w - Font letters in row
	move.w	#$ff,d6			;d6.w - Scroll playfield mask

	bsr	HorizontalScroll_Init
	rts

;Example scroll interrupt
	lea	HScroll_Example(pc),a0	;a0.l - Scroll struct
	bsr	HorizontalScroll
	rts



HScroll_Example:
	dc.w	0	;00 Pause scroll timer
	dc.w	0	;02 Scroll speed px
	dc.w	0	;04 XPos
	dc.w	0	;06 LetterPos
	dc.w	0	;08 No bitmaps
	dc.w	0	;10 Screen width px
	dc.w	0	;12 Font letter width px
	dc.w	0	;14 Font letter height px
	dc.w	0	;16 Font letters in row
	dc.w	0	;18 Scroll playfield mask
	dc.l	0	;20 Current letter pointer
	dc.l	0	;24 Text Pointer
	dc.l	0	;28 Font address
	dc.l	0	;32 Video memory
	dc.l	0	;36 Copper bitmaps
	dc.l	0	;40 Copper scroll reg
	dc.l	0	;44 Screen next offset
	dc.l	0	;48 Screen font modulo
	dc.l	0	;52 Font modulo
	dc.l	0	;56 Font row modulo

HScroll_Text:
	dc.b	"SCROLL MADE BY QUILLE ",0
	EVEN


	;Copper example
HScroll_CopperBP:
	dc.w	$00e0,$0000,$00e2,$0000		;BPL1PTH,BPL1PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL2PTH,BPL2PTL
	dc.w	$00e8,$0000,$00ea,$0000		;BPL3PTH,BPL3PTL
	dc.w	$0100,$3200			;pali bitne mape
HScroll_CopperSC:
	dc.w	$0102,$0000			;horizontal scroll code
	dc.w	$0108,$0170			;modulo
	dc.w	$010A,$0170			;modulo
	dc.w	$FFFF,$FFFE
	dc.w	$FFFF,$FFFE

	CNOP	0,8
HScroll_Font32:
	INCIFF	"AmigaParty25:Fonts/Knight32_8.iff"

	CNOP	0,8
HScroll_VidMem:	ds.b	320*2/8*32*3	;Width*2/8*Height*Bitmaps

	EREM

;----------
;a0.l - Scroll struct
;a1.l - Text treminated by zero
;a2.l - Font
;a3.l - Video memory
;a4.l - Copper bitmaps
;a5.l - Copper scroll reg
;d0.w - Speed
;d1.w - Screen width
;d2.w - No bitmaps
;d3.w - Font letter width
;d4.w - Font letter height
;d5.w - Font letters in row
;d6.w - Scroll playfield mask
;----------
HorizontalScroll_Init:
	movem.l	d0-a6,-(sp)

	move.w	#0,00(a0)	;00 Pause scroll timer
	move.w	d0,02(a0)	;02 Scroll speed px
	move.w	#0,04(a0)	;04 XPos
	move.w	#0,06(a0)	;06 LetterPos
	move.w	d2,08(a0)	;08 No bitmaps
	move.w	d1,10(a0)	;10 Screen width px
	move.w	d3,12(a0)	;12 Font letter width px
	move.w	d4,14(a0)	;14 Font letter height px
	move.w	d5,16(a0)	;16 Font letters in row
	move.w	d6,18(a0)	;18 Scroll playfield mask

	move.l	a1,20(a0)	;20 Current letter pointer
	move.l	a1,24(a0)	;24 Text Pointer
	move.l	a2,28(a0)	;28 Font address
	move.l	a3,32(a0)	;32 Video memory
	move.l	a4,36(a0)	;36 Copper bitmaps
	move.l	a5,40(a0)	;40 Copper scroll reg

	move.w	d1,d6
	asr.w	#3,d6		
	ext.l	d6		;Screen Width / 8
	move.l	d6,44(a0)	;44 Screen next offset

	add.l	d6,d6		;Screen width / 8 * 2
	move.l	d6,48(a0)	;48 Screen font modulo

	move.w	d3,d7
	asr.w	#3,d7
	ext.l	d7		;Font letter width / 8
	muls.w	d7,d5		;Letters in row * Font letter width / 8
	move.l	d5,52(a0)	;52 Font modulo

	muls.w	d4,d5		;Height * Font modulo
	muls.w	d2,d5		;No bitmaps * Height * Font modulo
	move.l	d5,56(a0)	;56 Font row modulo
	
	movem.l	(sp)+,d0-a6
	rts

;----------
;a0.l - Scroll struct
;----------
HorizontalScroll:
	movem.l	d0-a6,-(sp)
	move.w	00(a0),d1	;Check for pause
	beq.s	HS_Not_Pause
	subq.w	#1,d1
	move.w	d1,00(a0)
	bra.w	HS_SetCopper
HS_Not_Pause:
	move.w	04(a0),d1	;XPos in d1
	add.w	02(a0),d1	;XPos + Speed 
	cmp.w	10(a0),d1	;Check end of screen
	blt.s	HS_NotEndOfScreen
	sub.w	10(a0),d1	;oduzimam ukupnu duzinu video mem.
HS_NotEndOfScreen:
	move.w	d1,04(a0)	;Store XPos

	move.w  06(a0),d0	;LetterPos -> d0
	lsr.w   #5,d1		;XPos / 32
	move.w  d1,06(a0)	;d1->LetterPos

	cmp.w   d0,d1		;Should we insert letter 
	beq	HS_SetCopper

	move.l	20(a0),a1		;Current letter pointer -> a1
	moveq	#$0,d0
HS_Read_Letter:
	move.b	(a1)+,d0		;Letter -> d0
	bne.s	HS_Check_For_PauseCmd	;Not scroll end
	move.l	24(a0),a1		;Text pointer -> a1
	move.b  (a1)+,d0		;Letter -> d0

HS_Check_For_PauseCmd:
	cmp.b	#$1,d0			;Check for Pause command
	bne.s	HS_Check_For_SpeedCmd
	move.b	(a1)+,d0		;Read pause value
	move.w	d0,00(a0)		;Set pause counter
	bra.s	HS_Read_Letter

HS_Check_For_SpeedCmd:
	cmp.b	#$2,d0			;Check for Speed command
	bne.s	HS_NotCommand
	move.b	(a1)+,d0		;Read speed value
	move.w	d0,02(a0)		;Set speed value
	bra.s	HS_Read_Letter

HS_NotCommand:
	move.l  a1,20(a0)		;a1 -> Current letter pointer

	asl.w	#$2,d1		;d1*4->d1, Letter offset in bytes 
	move.l	32(a0),a1	;Video memory -> a1
	lea     (a1,d1.w),a1	;Letter insert address -> a1
	move.l	a1,a2
	add.l	44(a0),a2	;Letter next offset in a2

	move.l	28(a0),a3	;Font addres -> a3
	subi.w  #$20,d0		;Letter - Space -> d0
	divs.w	16(a0),d0	;Letter / Letters in row
	move.l	56(a0),d1	;Letter row size ->d1
	muls.w	d0,d1		;Letter row * Letter wow size
	lea	(a3,d1.w),a3
	swap	d0
	asl.w	#$2,d0
	lea	(a3,d0.w),a3	;Letter address in a3
	
	move.w	14(a0),d0	;Letter height -> d0
	mulu.w	08(a0),d0	;Letter height * No bitmaps ->d0
	subq.l	#$1,d0
HS_CopyLetters:
	move.l	(a3),d1		;Letter line in d1
	move.l  d1,(a1)		;Letter line in vm
	move.l  d1,(a2)		;Letter line in vm
	add.l	52(a0),a3	;Next letter line
	add.l	48(a0),a1	;Next letter line in vm
	add.l	48(a0),a2	;Next letter line in vm
	dbf     d0,HS_CopyLetters

HS_SetCopper:
	move.w	04(a0),d0	;Current PosX -> d0
 	lsr.w   #4,d0		;d0/16
 	add.w   d0,d0		;d0*2
 	addi.w  #$4,d0		;d0+4 preskoci 1 slovo
 	add.l	32(a0),d0	;Video memory + Scroll offset

 	move.l	36(a0),a1	;adr. iz copper liste ->a1
 	move.w	08(a0),d1	;No Bitmaps
	subq.w	#1,d1
HS_SetBitmaps:
	move.w	d0,06(a1)
	swap	d0
	move.w	d0,02(a1)
	swap    d0
	add.l	48(a0),d0	;dodaje duzinu video memorije d0
	addq.w  #8,a1		;adr. u cop. sljedece  bitne mape
	dbf     D1,HS_SetBitmaps

	move.w	04(a0),d0	;Current XPos -> d0
 	not.w	d0		;komplememt d0
 	andi.w	#$f,d0		;ostavi samo prva 4 bita
 	move.w	d0,d1		;d0->d1
 	lsl.w	#4,d1		;pomjeri bitove u d1 lijevo za 4
	or.w	d1,d0		;upali bitove iz d1 u d0
	and.w	18(a0),d0
	move.l	40(a0),a1
	move.w	d0,02(a1)	;stavi d0 u horiz scroll code u cop. 

	movem.l	(sp)+,d0-a6
 	rts
