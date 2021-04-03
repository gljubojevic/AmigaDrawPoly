	Section	"AmigaParty25Intro",CODE_F

	INCDIR	"AmigaParty25:Include/"
	INCLUDE	"LVO3.1/exec_lib.i"
	INCLUDE	"LVO3.1/dos_lib.i"
	INCLUDE	"LVO3.1/graphics_lib.i"
	INCLUDE	"graphics/gfxbase.i"
	INCLUDE	"exec/interrupts.i"
	INCLUDE	"exec/Memory.i"
	INCLUDE	"exec/exec.i"
	INCLUDE	"exec/execbase.i"
	INCLUDE	"dos/dos.i"
	INCLUDE	"hardware/intbits.i"	
	INCLUDE	"hardware/cia.i"
	INCLUDE	"libraries/dosextens.i"
	INCLUDE	"devices/input.i"
	INCLUDE	"devices/inputevent.i"
	INCLUDE	"resources/misc.i"

	INCDIR	"AmigaParty25:"

DEBUGING	=	1	;use 1 if debuging
COPPERINT	=	1	;use 1 if Copper int othervise is vertb int
INPUTHANDLER	=	0	;use 1 if using input handler
DOSLIB		=	0	;use 1 if dos library is needed
MUSICPLAYER	=	1	;use 1 if music replay is needed


AmigaParty25Intro:	
	movem.l	d0-a6,-(sp)
	lea	$dff000,a6			;Custom Chip Address in a6

	bsr	Init_Routine			;Init Routine
	tst.l	d0				;Check Ok?
	beq.s	Intro_Init
	bra.w	Intro_Exit

Intro_Init:
;***********************************
;Intro init
;***********************************
	IF 	MUSICPLAYER=1
	movem.l	d0-a6,-(sp)
	move.l	#MusicModule,pr_module
	jsr	pr_init
	movem.l	(sp)+,d0-a6
	ENDIF

	bsr	Logo_Init
	bsr	Titles_Init
	bsr	Background_Init
	bsr	HScroll_Init

	move.l	#Copper,$080(a6)
	bsr	Wait_VerticalBlank

	move.w	#0,VTBInt_Stop			;Start Interrupt
Intro_MainLoop:
;***********************************
;TODO: Main code here
;***********************************

	IF	INPUTHANDLER=1
	tst.b	ESCKey
	beq.s	Intro_MainLoop
	ELSE
	btst	#$6,$bfe001
	bne.s	Intro_MainLoop
	ENDIF


Intro_exit:
	move.w	#-1,VTBInt_Stop			;Stop Interrupt

	IF 	MUSICPLAYER=1
	movem.l	d0-a6,-(sp)
	jsr	pr_end
	movem.l	(sp)+,d0-a6
	ENDIF

	bsr	Restore_Routine
	movem.l	(sp)+,d0-a6
	rts


VTBInt_Handler:
	movem.l	d0-a6,-(sp)
	add.l	#$01,VTBInt_Counter
	tst.w	VTBInt_Stop
	bne.s	VTBInt_End
	lea	$dff000,a6

;***********************************
;interrupt code here
;***********************************
	IF 	MUSICPLAYER=1
	movem.l	d0-a6,-(sp)
	jsr	pr_music
	movem.l	(sp)+,d0-a6
	ENDIF

	bsr	Logo_Interrupt
	bsr	Titles_Interrupt
	bsr	Background_Interrupt
	bsr	HScroll_Interrupt

VTBInt_End:
	movem.l	(sp)+,d0-a6
	moveq	#$00,d0
	rts

;***************************************************
;Logo show
;***************************************************

Logo_Init:	
	movem.l	d0-d2/a0-a1,-(sp)

	move.l	#LogoPic,d0
	move.l	#320/8,d1
	moveq.l	#5-1,d2
	lea	LogoOnlyCopper_BP,a0
	bsr	Write_CopperListBitmaps

	;lea	LogoPicPal,a1
	;lea	LogoOnlyCopper_Col,a0
	;move.l	#32-1,d0
	;bsr	Write_CopperListColors

	move.w	#(256-LogoPic_Height)/2,Logo_VStart	;Center Logo
	bsr.w	Logo_MoveToPos

	lea	Copper_Link_Next,a0			;Link copper end
	move.l	#Copper_End,d0
	move.w	d0,$6(a0)
	swap	d0
	move.w	d0,$2(a0)

	lea	Logo_State(pc),a0
	move.w	#0,(a0)			;Set first logo state

	movem.l	(sp)+,d0-d2/a0-a1
	rts

Logo_State:	dc.w	0


Logo_Interrupt:
	movem.l	d0-a6,-(sp)
	cmp.w	#0,Logo_State
	bne.s	Logo_FadeIn

	move.w	#(256-LogoPic_Height)/2,Logo_VStart		;Center Logo
	bsr.w	Logo_MoveToPos

	lea	LogoPicPal,a0
	lea	LogoOnlyCopper_Col,a1
	move.l	#32-1,d0
	jsr	FadeIn				;Start Logo Fade In
	add.w	#1,Logo_State			;Next state
	bra.s	Logo_Interrupt_End

Logo_FadeIn:
	cmp.w	#1,Logo_State
	bne.s	Logo_MoveToTop

	jsr	FadeInOut
	jsr	FadeInOut_Finished
	bne.s	Logo_Interrupt_End
	add.w	#1,Logo_State			;Next state
	bra.s	Logo_Interrupt_End

Logo_MoveToTop:
	cmp.w	#2,Logo_State
	bne.s	Logo_Interrupt_End
	bsr.s	Logo_MoveToPos
	tst.w	Logo_VStart
	bgt.s	Logo_Interrupt_End
	add.w	#1,Logo_State			;Next state
	;add.w	#1,Background_State		;Kickstart background
	add.w	#1,Titles_State			;Kickstart titles


Logo_Interrupt_End:
	movem.l	(sp)+,d0-a6
	rts


Logo_MoveToPos:
	movem.l	d0/a0,-(sp)
	move.w	Logo_VStart(pc),d0
	ble.s	Logo_MoveToPos_End

	add.w	#$2c,d0
	lea	LogoPosition_Start,a0
	bsr.w	Write_DoubleCopperWait

	add.w	#LogoPic_Height,d0
	lea	LogoPosition_End,a0
	bsr.w	Write_DoubleCopperWait
	
	sub.w	#2,Logo_VStart
Logo_MoveToPos_End:
	movem.l	(sp)+,d0/a0
	rts

Logo_VStart:	dc.w	0


;***************************************************
;Titles show
;***************************************************

Titles_Init:
	movem.l	d0-a6,-(sp)

	lea	Titles_State(pc),a0
	move.w	#-1,0(a0)
	move.w	#0,2(a0)

	movem.l	(sp)+,d0-a6
	rts

Titles_State:	dc.w	0	;State
		dc.w	0	;Frame Counter


Titles_Interrupt:
	movem.l	d0-a6,-(sp)
	lea	Titles_State(pc),a0

Titles_Interrupt_Title01:
	cmp.w	#0,(a0)
	bne.s	Titles_Interrupt_Title02

	lea	TitlePic_01,a1
	lea	TitlePic_Empty,a2
	bsr.w	Titles_SetCopper

	add.w	#1,2(a0)
	cmp.w	#50,2(a0)
	ble.w	Titles_Interrupt_End
	add.w	#1,0(a0)
	move.w	#0,2(a0)

	bra.w	Titles_Interrupt_End


Titles_Interrupt_Title02:
	cmp.w	#1,(a0)
	bne.s	Titles_Interrupt_Title03

	lea	TitlePic_01,a1
	lea	TitlePic_02,a2
	bsr.w	Titles_SetCopper

	add.w	#1,2(a0)
	cmp.w	#50,2(a0)
	ble.s	Titles_Interrupt_End
	add.w	#1,0(a0)
	move.w	#0,2(a0)
	bra.s	Titles_Interrupt_End


Titles_Interrupt_Title03:
	cmp.w	#2,(a0)
	bne.s	Titles_Interrupt_Title04

	lea	TitlePic_03,a1
	lea	TitlePic_02,a2
	bsr.s	Titles_SetCopper


	add.w	#1,2(a0)
	cmp.w	#50,2(a0)
	ble.s	Titles_Interrupt_End
	add.w	#1,0(a0)
	move.w	#0,2(a0)
	bra.s	Titles_Interrupt_End

Titles_Interrupt_Title04:
	cmp.w	#3,(a0)
	bne.s	Titles_Interrupt_End

	lea	TitlePic_03,a1
	lea	TitlePic_04,a2
	bsr.s	Titles_SetCopper

	add.w	#1,2(a0)
	cmp.w	#50,2(a0)
	ble.s	Titles_Interrupt_End
	add.w	#1,0(a0)
	move.w	#0,2(a0)
	add.w	#1,Background_State		;Kickstart background

Titles_Interrupt_End:
	movem.l	(sp)+,d0-a6
	rts


	
Titles_SetCopper:
	movem.l	d0-a6,-(sp)

	lea	Copper_Link_Next,a0		;Link titles to copper
	move.l	#Titles_Copper,d0
	move.w	d0,$6(a0)
	swap	d0
	move.w	d0,$2(a0)

	move.l	a1,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	lea	Titles_BP,a0
	bsr	Write_CopperListBitmaps

	move.l	a2,d0
	moveq.l	#0,d2
	bsr	Write_CopperListBitmaps

	move.w	Logo_VStart(pc),d0
	add.w	#$2c+LogoPic_Height,d0
	lea	Titles_Con,a0
	bsr	Write_DoubleCopperWait

	lea	12(a0),a0
	add.w	#58,d0
	bsr	Write_DoubleCopperWait

	addq.l	#8,a0
	move.l	#Copper_End,d0			;Link copper back
	move.w	d0,$6(a0)
	swap	d0
	move.w	d0,$2(a0)

	movem.l	(sp)+,d0-a6
	rts
	

;***************************************************
;Background show
;***************************************************

Background_Rows	=	4	;Number of cube background rows

Background_Init:
	movem.l	d0-d7/a0-a6,-(sp)

	lea	Background_LastBM,a0
	move.l	#$aaaaaaaa,d0
	move.l	#32*5-1,d1
BI_FillBM:
	move.l	#640/8/4-1,d2
BI_FillBMRow:
	move.l	d0,(a0)+
	dbf	d2,BI_FillBMRow
	eor.l	#$ffffffff,d0
	lea	640/8*1(a0),a0
	dbf	d1,BI_FillBM

	move.w	#15,d0
	move.w	#15,d1
	move.w	#128,d2
	lea	Cube,a0
	jsr	RotateXYZ_Setup

	move.w	#0,d0
	move.w	#0,d1
	move.w	#31,d2
	move.w	#31,d3
	move.w	#640/8,d4
	move.w	#320,d5
	move.w	#256,d6
	lea	Cube,a0
	lea	Cubes_VidMem00,a1
	lea	Cubes_VidMem01,a2
	jsr	Draw3D_Init

	jsr	RotateXYZ
	jsr	Draw_Object_Test

	;bsr	Background_Write_CopperList

	lea	Background_State(pc),a0
	move.w	#-1,(a0)			;Set background state

	movem.l	(sp)+,d0-d7/a0-a6
	rts


Background_Interrupt:
	movem.l	d0-a6,-(sp)
	cmp.w	#0,Background_State(pc)
	bne.s	Background_Interrupt_End

	jsr	Clear_Cube
	jsr	Draw_Object
	jsr	Blitter_Fill_Cube
	jsr	Cube_Copy
	jsr	Draw3D_SwapBuffers

	bsr	Background_Write_CopperList

	move.w	#$0030,d0
	move.w	#$0018,d1
	move.w	#$0020,d2
	jsr	RotateXYZ_IncAngles

	jsr	RotateXYZ
	jsr	Draw_Object_Test

Background_Interrupt_End:
	movem.l	(sp)+,d0-a6
	rts

Background_State:
	dc.w	0


Background_Write_CopperList:
	movem.l	d0-d7/a0-a1,-(sp)

	lea	Copper_Link_Next,a0		;Link background to copper
	lea	Background_Con,a1
	move.l	a1,d0
	move.w	d0,$6(a0)
	swap	d0
	move.w	d0,$2(a0)

	lea	24(a1),a0
	move.l	#Background_LastBM,d0		;Set last bitmap
	move.w	d0,$6(a0)
	swap	d0
	move.w	d0,$2(a0)

	move.w	Logo_VStart(pc),d5
	add.w	#LogoPic_Height+2,d5
	add.w	#$002c,d5		;Calc end of logo

	lea	Background_BP,a0
	lea	Background_Colors(pc),a1
	lea	Background_Table(pc),a2
	lea	Background_RowCon,a3
	move.l	Showplane,d3		;First BP in d0
	move.l	#$50,d4
	moveq	#Background_Rows-1,d6	;Number of cube rows
BWCL_Next_Row:

	;----------
	;a0 - Copper waits
	;----------
	move.w	d5,d0			;d0 - Y Pos
	bsr	Write_DoubleCopperWait
	addq.l	#8,a0			;Skip waits
	addq.l	#4,a0			;Skip BPL0CON

	move.l	d3,d0			;d0 - Picture pointer
	move.l	d4,d1			;d1 - Offset to next bitmap
	add.l	(a2)+,d0		;Offset to next cube
	moveq.l	#2-1,d2			;d2 - No bitmaps-1
	bsr	Write_CopperListBitmaps	;All Trashed after

	;----------
	;a0 - Colors copper
	;a1 - Colors
	;----------
	moveq.l	#4-1,d0			;d0 - No Colors - 1
	bsr	Write_CopperListColors	;All Trashed after

	;Set jump to enable bitmaps
	move.l	a3,d0			;Background_RowCon
	move.w	d0,$06(a0)		;Store address
	swap	d0			;for
	move.w	d0,$02(a0)		;Copper2 Jump

	;Wait one line to enable bitmaps 
	addq.l	#$1,d5
	move.w	d5,d0			;d0 - Y Pos
	exg	a0,a3
	bsr	Write_DoubleCopperWait
	exg	a0,a3
	move.w	d0,d5

	;Set correct copper jump  to skip jump
	;This jump is later used to insert scroll copper
	add.l	#12,a0			;Skip copper jumps (Next row)
	move.l	a0,d0			;Copper jumps to d0

	;Set return jumps in Con row
	move.w	d0,12+$06(a3)		;Store address
	swap	d0			;for
	move.w	d0,12+$02(a3)		;Copper2 Jump

	add.l	#24,a3			;Next set of con setup
	add.w	#32,d5			;Next cubes row

	dbf	d6,BWCL_Next_Row

	;Fix end of bg copper
	move.w	d5,d0			;d0 - Y Pos
	subq.w	#1,d0
	bsr	Write_DoubleCopperWait	;Write last wait at end
	addq.l	#8,a0			;Skip waits
	move.l	#Copper_End,d0
	move.w	d0,$6(a0)
	swap	d0
	move.w	d0,$2(a0)

	movem.l	(sp)+,d0-d7/a0-a1
	rts

Background_Table:	
	dc.l	0,4,8,12,16,20,24,28


Background_Colors:
	dc.w	$0000,$0006,$0007,$0008
	dc.w	$0000,$0007,$0008,$0009
	dc.w	$0000,$0008,$0009,$000a
	dc.w	$0000,$0009,$000a,$000b
	dc.w	$0000,$000a,$000b,$000c
	dc.w	$0000,$000b,$000c,$000d
	dc.w	$0000,$000c,$000d,$000e
	dc.w	$0000,$000d,$000e,$000f

;***************************************************
;Horizontal Scroll
;***************************************************

	
HScroll_Init:
	movem.l	d0-a6,-(sp)

	lea	HScroll01(pc),a0	;a0.l - Scroll struct
	lea	HScroll01_Text(pc),a1	;a1.l - Text treminated by zero
	lea	HScroll_Font32,a2	;a2.l - Font
	lea	HScroll01_VidMem,a3	;a3.l - Video memory
	lea	HScroll01_CopperBP,a4	;a4.l - Copper bitmaps
	lea	HScroll01_CopperSC,a5	;a5.l - Copper scroll reg
	move.w	#1,d0			;d0.w - Speed
	move.w	#352,d1			;d1.w - Screen width
	move.w	#3,d2			;d2.w - No bitmaps
	move.w	#32,d3			;d3.w - Font letter width
	move.w	#25,d4			;d4.w - Font letter height
	move.w	#10,d5			;d5.w - Font letters in row
	move.w	#$0f,d6			;d6.w - Scroll playfield mask
	jsr	HorizontalScroll_Init


	lea	HScroll02(pc),a0	;a0.l - Scroll struct
	lea	HScroll02_Text(pc),a1	;a1.l - Text treminated by zero
	lea	HScroll_Font32x32,a2	;a2.l - Font
	lea	HScroll02_VidMem,a3	;a3.l - Video memory
	lea	HScroll02_CopperBP,a4	;a4.l - Copper bitmaps
	lea	HScroll02_CopperSC,a5	;a5.l - Copper scroll reg
	move.w	#2,d0			;d0.w - Speed
	move.w	#352,d1			;d1.w - Screen width
	move.w	#3,d2			;d2.w - No bitmaps
	move.w	#32,d3			;d3.w - Font letter width
	move.w	#32,d4			;d4.w - Font letter height
	move.w	#10,d5			;d5.w - Font letters in row
	move.w	#$0f,d6			;d6.w - Scroll playfield mask
	jsr	HorizontalScroll_Init

	lea	HScroll03(pc),a0	;a0.l - Scroll struct
	lea	HScroll03_Text(pc),a1	;a1.l - Text treminated by zero
	lea	HScroll_Font32x32,a2	;a2.l - Font
	lea	HScroll03_VidMem,a3	;a3.l - Video memory
	lea	HScroll03_CopperBP,a4	;a4.l - Copper bitmaps
	lea	HScroll03_CopperSC,a5	;a5.l - Copper scroll reg
	move.w	#3,d0			;d0.w - Speed
	move.w	#352,d1			;d1.w - Screen width
	move.w	#3,d2			;d2.w - No bitmaps
	move.w	#32,d3			;d3.w - Font letter width
	move.w	#32,d4			;d4.w - Font letter height
	move.w	#10,d5			;d5.w - Font letters in row
	move.w	#$0f,d6			;d6.w - Scroll playfield mask
	jsr	HorizontalScroll_Init

	lea	HScroll04(pc),a0	;a0.l - Scroll struct
	lea	HScroll04_Text(pc),a1	;a1.l - Text treminated by zero
	lea	HScroll_Font32x32,a2	;a2.l - Font
	lea	HScroll04_VidMem,a3	;a3.l - Video memory
	lea	HScroll04_CopperBP,a4	;a4.l - Copper bitmaps
	lea	HScroll04_CopperSC,a5	;a5.l - Copper scroll reg
	move.w	#3,d0			;d0.w - Speed
	move.w	#352,d1			;d1.w - Screen width
	move.w	#3,d2			;d2.w - No bitmaps
	move.w	#32,d3			;d3.w - Font letter width
	move.w	#32,d4			;d4.w - Font letter height
	move.w	#10,d5			;d5.w - Font letters in row
	move.w	#$0f,d6			;d6.w - Scroll playfield mask
	jsr	HorizontalScroll_Init

	movem.l	(sp)+,d0-a6
	rts


HScroll_WriteCopper:
	movem.l	d0-a6,-(sp)

	move.w	Logo_VStart(pc),d5
	add.w	#LogoPic_Height+1,d5
	add.w	#$002c,d5

	lea	HScroll01_CopperBP,a0
	lea	Background_BP,a1
	bsr	HScroll_LinkCopper

	add.w	#32,d5
	lea	HScroll02_CopperBP,a0
	lea	56(a1),a1
	bsr	HScroll_LinkCopper

	add.w	#32,d5
	lea	HScroll03_CopperBP,a0
	lea	56(a1),a1
	bsr	HScroll_LinkCopper
	
	add.w	#32,d5
	lea	HScroll04_CopperBP,a0
	lea	56(a1),a1
	bsr	HScroll_LinkCopper

	movem.l	(sp)+,d0-a6
	rts

HScroll_LinkCopper:
	movem.l	d0/a0,-(sp)

	exg.l	a0,a1
	move.w	d5,d0
	bsr	Write_DoubleCopperWait
	move.w	d0,d5
	exg.l	a0,a1
	addq.w	#1,d5	

	move.l	a1,d0
	add.l	#56,d0
	move.w	d0,76+6(a0)
	swap	d0
	move.w	d0,76+2(a0)
		
	move.l	a0,d0
	move.w	d0,44+6(a1)
	swap	d0
	move.w	d0,44+2(a1)

	lea	60(a0),a0
	move.w	d5,d0
	bsr	Write_DoubleCopperWait
	move.w	d0,d5

	movem.l	(sp)+,d0/a0
	rts


HScroll_Interrupt:
	movem.l	d0-a6,-(sp)

	;cmp.w	#3,Logo_State(pc)	;Check logo done
	cmp.w	#4,Titles_State(pc)	;Check titles done
	blt.s	HScroll_Interrupt_End

	cmp.w	#0,Background_State(pc)	;Check BG started
	bne.s	HScroll_Interrupt_End


	lea	HScroll01(pc),a0
	jsr	HorizontalScroll

	lea	HScroll02(pc),a0
	jsr	HorizontalScroll

	lea	HScroll03(pc),a0
	jsr	HorizontalScroll

	lea	HScroll04(pc),a0
	jsr	HorizontalScroll


	bsr	HScroll_WriteCopper

HScroll_Interrupt_End:
	movem.l	(sp)+,d0-a6
	rts


HScroll01:
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


HScroll02:
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

HScroll03:
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

HScroll04:
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

HScroll01_Text:
	dc.b	"11111 SCROLL MADE BY QUILLE ",0
	EVEN

HScroll02_Text:
	dc.b	"22222 SCROLL",1,50," MADE",2,6," BY QUILLE ",2,1,0
	EVEN

HScroll03_Text:
	dc.b	2,3,"OVO  JE  MALI  EKSPERIMENT KAKO CE RADITI SCROLL "
	dc.b	2,4," CODE   ",92,93,1,60
	dc.b	2,2," -REALITY-  ",1,50
	dc.b	0
	EVEN

HScroll04_Text:
	dc.b	2,4,"TEXT NA SCROLLLU ISPOD MORA BITI JEDNAKE DULJINE "
	dc.b	2,2," QUILLE ",102,103,1,110
	dc.b	2,2," -CYBERLABS ",1,50
	dc.b	0
	EVEN

;***************************************************
;Intro startup code
;***************************************************

	INCLUDE	"CyberlabsIntroStartup.s"

;***************************************************
;Intro routines
;***************************************************

	Section	"Intro Routines",CODE_F

	INCLUDE	"FadeInOut.s"
	INCLUDE	"RotateXYZ.s"
	INCLUDE	"Draw3D.s"
	INCLUDE	"HorizontalScroll.s"

;***************************************************
;Music routine
;***************************************************

	INCLUDE	"ProRunner2.0.s"

;***************************************************
;Fast Data
;***************************************************

	Section	"Fast Data",DATA_F

	CNOP	0,8
	INCLUDE	"CubeObject.s"

	CNOP	0,8
HScroll_Font32:
	INCIFF	"Fonts/Knight32_8.iff"

HScroll_Font32x32:
	INCIFF	"Fonts/Annonce32_8Col_face.iff"

;***************************************************
;Fast BSS Data
;***************************************************

	Section	"Fast BSS Data",BSS_F

	CNOP	0,8


;***************************************************
;Chip Data
;***************************************************

	SECTION	"Chip Data",DATA_C

	CNOP	0,8
Copper:
	dc.w	$01fc,$0000
	dc.w	$008e,$2c81		;Screen Size
	dc.w	$0090,$2cc1		;Screen Size
	dc.w	$0092,$0038		;H-start
	dc.w	$0094,$00d0		;H-stop
	dc.w	$0100,$0200		;Bit-Plane control reg.
	dc.w	$0102,$0000		;Hor-Scroll
	dc.w	$0104,$0010		;Sprite/Gfx priority
	dc.w	$0106,$0c00		;BPLCON3 Default DPF color offsets
	dc.w	$010c,$0000		;BPLCON4
	dc.w	$0180,$0000
Copper_Spr:
	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000

LogoOnlyCopper_BP:
	dc.w	$00e0,$0000,$00e2,$0000
	dc.w	$00e4,$0000,$00e6,$0000
	dc.w	$00e8,$0000,$00ea,$0000
	dc.w	$00ec,$0000,$00ee,$0000
	dc.w	$00f0,$0000,$00f2,$0000
LogoPosition_Start:
	dc.w	$00e1,$fffe,$00e1,$80fe
	dc.w	$0100,$5200		;Bit-Plane control reg.
	dc.w	$0108,$00a0		;Modolu (odd)
	dc.w	$010A,$00a0		;Modolu (even)
LogoOnlyCopper_Col:
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$0188,$0000,$018A,$0000
	dc.w	$018C,$0000,$018E,$0000
	dc.w	$0190,$0000,$0192,$0000
	dc.w	$0194,$0000,$0196,$0000
	dc.w	$0198,$0000,$019A,$0000
	dc.w	$019C,$0000,$019E,$0000
	dc.w	$01A0,$0000,$01A2,$0000
	dc.w	$01A4,$0000,$01A6,$0000
	dc.w	$01A8,$0000,$01AA,$0000
	dc.w	$01AC,$0000,$01AE,$0000
	dc.w	$01B0,$0000,$01B2,$0000
	dc.w	$01B4,$0000,$01B6,$0000
	dc.w	$01B8,$0000,$01BA,$0000
	dc.w	$01BC,$0000,$01BE,$0000
LogoPosition_End:
	dc.w	$00e1,$fffe,$00e1,$80fe
	dc.w	$0100,$0200		;Bit-Plane control reg.
	dc.w	$0180,$0000

Copper_Link_Next:
	dc.w	$0084,$0000,$0086,$0000		;COP2LCH,COP2LCL
	dc.w	$008a,$0000			;COPJMP2

Copper_End:
	dc.w	$0100,$0200			;Bit-Plane control reg.

	REM
	dc.w	$ffe1,$fffe,$00e2,$80fe
	dc.w	$0180,$0f00
	dc.w	$00e1,$fffe,$00e2,$80fe
	dc.w	$0180,$000f
	dc.w	$01e1,$fffe,$00e2,$80fe
	dc.w	$0180,$00f0
	EREM

	IF	COPPERINT=1
	dc.w	$009c,$8010			;INTREQ
	ENDIF
	dc.w	$ffff,$fffe			;End of Copper List
	dc.w	$ffff,$fffe			;End of Copper List


	CNOP	0,8
Titles_Copper:
	dc.w	$0100,$0200			;BPLCON0
	dc.w	$0102,$0000			;BPLCON1
	dc.w	$0108,$0000			;BPL1MOD
	dc.w	$010a,$0000			;BPL2MOD
Titles_BP:
	dc.w	$00e0,$0000,$00e2,$0000		;BPL1PTH,BPL1PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL2PTH,BPL2PTL
Titles_Cols:
	dc.w	$0180,$0000,$0182,$0fff		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0fff		;COLOR02,COLOR03
Titles_Con:
	dc.w	$00e1,$fffe,$00e1,$80fe		;Wait
	dc.w	$0100,$2600			;BPLCON0
	dc.w	$00e1,$fffe,$00e1,$80fe		;Wait
	dc.w	$0084,$0000,$0086,$0000		;COP2LCH,COP2LCL
	dc.w	$008a,$0000			;COPJMP1->Return back


	CNOP	0,8
Background_Con:
	dc.w	$0092,$0030			;H-start Early for scroll
	dc.w	$0094,$00d0			;H-stop
	dc.w	$0100,$0200			;BPLCON0
	dc.w	$0102,$0000			;BPLCON1
	dc.w	$0108,$0000			;BPL1MOD
	dc.w	$010a,$0076			;BPL2MOD 2nd playfield
	dc.w	$00f4,$0000,$00f6,$0000		;BPL6PTH,BPL6PTL
	dc.w	$0198,$0000,$019A,$0008		;COLOR12,COLOR13
	dc.w	$019C,$000a,$019E,$000e		;COLOR14,COLOR15
Background_BP:
	REPT	Background_Rows
	dc.w	$00e1,$fffe,$00e1,$fffe
	dc.w	$0100,$0200			;BPLCON0
	dc.w	$00e4,$0000,$00e6,$0000		;BPL2PTH,BPL2PTL
	dc.w	$00ec,$0000,$00ee,$0000		;BPL4PTH,BPL4PTL
	dc.w	$0190,$0000,$0192,$0000		;COLOR08,COLOR09
	dc.w	$0194,$0000,$0196,$0000		;COLOR10,COLOR11
	dc.w	$0084,$0000,$0086,$0000		;COP2LCH,COP2LCL
	dc.w	$008a,$0000			;COPJMP2
	ENDR

Background_Link_End:
	dc.w	$00e1,$fffe,$00e1,$fffe
	dc.w	$0084,$0000,$0086,$0000		;COP2LCH,COP2LCL
	dc.w	$008a,$0000			;COPJMP2
	dc.w	$ffff,$fffe			;End of Copper List
	dc.w	$ffff,$fffe			;End of Copper List


	CNOP	0,8
Background_RowCon:
	REPT	Background_Rows
	dc.w	$00e1,$fffe,$00e1,$fffe		;Wait
	dc.w	$0100,$6600			;BPLCON0
	dc.w	$0084,$0000,$0086,$0000		;COP2LCH,COP2LCL
	dc.w	$008a,$0000			;COPJMP1->Return back
	ENDR

	
	CNOP	0,8
HScroll01_CopperBP:				;In Playfield 1
	dc.w	$00e0,$0000,$00e2,$0000		;BPL1PTH,BPL1PTL
	dc.w	$00e8,$0000,$00ea,$0000		;BPL3PTH,BPL3PTL
	dc.w	$00f0,$0000,$00f2,$0000		;BPL5PTH,BPL5PTL
	dc.w	$0180,$0000,$0182,$0EEE		;COLOR00,COLOR01
	dc.w	$0184,$0258,$0186,$09CE		;COLOR02,COLOR03
	dc.w	$0188,$069C,$018A,$046A		;COLOR04,COLOR05
	dc.w	$018C,$0046,$018E,$048A		;COLOR06,COLOR07
	dc.w	$0108,$00dc+2			;modulo
	dc.w	$00e1,$fffe,$00e1,$fffe		;Wait start of line
	dc.w	$0100,$6600			;BPLCON0
HScroll01_CopperSC:
	dc.w	$0102,$0000			;BPLCON1
	dc.w	$0084,$0000,$0086,$0000		;COP2LCH,COP2LCL
	dc.w	$008a,$0000			;COPJMP1->Return back


	CNOP	0,8
HScroll02_CopperBP:				;In Playfield 1
	dc.w	$00e0,$0000,$00e2,$0000		;BPL1PTH,BPL1PTL
	dc.w	$00e8,$0000,$00ea,$0000		;BPL3PTH,BPL3PTL
	dc.w	$00f0,$0000,$00f2,$0000		;BPL5PTH,BPL5PTL
	dc.w	$0180,$0000,$0182,$077a		;COLOR00,COLOR01
	dc.w	$0184,$0559,$0186,$088c		;COLOR02,COLOR03
	dc.w	$0188,$0448,$018A,$0aad		;COLOR04,COLOR05
	dc.w	$018C,$0ccf,$018E,$0336		;COLOR06,COLOR07
	dc.w	$0108,$00dc+2			;modulo
	dc.w	$00e1,$fffe,$00e1,$fffe		;Wait start of line
	dc.w	$0100,$6600			;BPLCON0
HScroll02_CopperSC:
	dc.w	$0102,$0000			;BPLCON1
	dc.w	$0084,$0000,$0086,$0000		;COP2LCH,COP2LCL
	dc.w	$008a,$0000			;COPJMP1->Return back


	CNOP	0,8
HScroll03_CopperBP:				;In Playfield 1
	dc.w	$00e0,$0000,$00e2,$0000		;BPL1PTH,BPL1PTL
	dc.w	$00e8,$0000,$00ea,$0000		;BPL3PTH,BPL3PTL
	dc.w	$00f0,$0000,$00f2,$0000		;BPL5PTH,BPL5PTL
	dc.w	$0180,$0000,$0182,$077a		;COLOR00,COLOR01
	dc.w	$0184,$0559,$0186,$088c		;COLOR02,COLOR03
	dc.w	$0188,$0448,$018A,$0aad		;COLOR04,COLOR05
	dc.w	$018C,$0ccf,$018E,$0336		;COLOR06,COLOR07
	dc.w	$0108,$00dc+2			;modulo
	dc.w	$00e1,$fffe,$00e1,$fffe		;Wait start of line
	dc.w	$0100,$6600			;BPLCON0
HScroll03_CopperSC:
	dc.w	$0102,$0000			;BPLCON1
	dc.w	$0084,$0000,$0086,$0000		;COP2LCH,COP2LCL
	dc.w	$008a,$0000			;COPJMP1->Return back


	CNOP	0,8
HScroll04_CopperBP:				;In Playfield 1
	dc.w	$00e0,$0000,$00e2,$0000		;BPL1PTH,BPL1PTL
	dc.w	$00e8,$0000,$00ea,$0000		;BPL3PTH,BPL3PTL
	dc.w	$00f0,$0000,$00f2,$0000		;BPL5PTH,BPL5PTL
	dc.w	$0180,$0000,$0182,$077a		;COLOR00,COLOR01
	dc.w	$0184,$0559,$0186,$088c		;COLOR02,COLOR03
	dc.w	$0188,$0448,$018A,$0aad		;COLOR04,COLOR05
	dc.w	$018C,$0ccf,$018E,$0336		;COLOR06,COLOR07
	dc.w	$0108,$00dc+2			;modulo
	dc.w	$00e1,$fffe,$00e1,$fffe		;Wait start of line
	dc.w	$0100,$6600			;BPLCON0
HScroll04_CopperSC:
	dc.w	$0102,$0000			;BPLCON1
	dc.w	$0084,$0000,$0086,$0000		;COP2LCH,COP2LCL
	dc.w	$008a,$0000			;COPJMP1->Return back


	;Dual playfield bitmaps PF1
	;dc.w	$00e0,$0000,$00e2,$0000		;BPL1PTH,BPL1PTL
	;dc.w	$00e8,$0000,$00ea,$0000		;BPL3PTH,BPL3PTL
	;dc.w	$00f0,$0000,$00f2,$0000		;BPL5PTH,BPL5PTL
	;Dual playfield bitmaps PF2
	;dc.w	$00e4,$0000,$00e6,$0000		;BPL2PTH,BPL2PTL
	;dc.w	$00ec,$0000,$00ee,$0000		;BPL4PTH,BPL4PTL
	;dc.w	$00f4,$0000,$00f6,$0000		;BPL6PTH,BPL6PTL
	;Dual playfield colors PF1
	;dc.w	$0180,$0000,$0182,$0EEE		;COLOR00,COLOR01
	;dc.w	$0184,$0258,$0186,$09CE		;COLOR02,COLOR03
	;dc.w	$0188,$069C,$018A,$046A		;COLOR04,COLOR05
	;dc.w	$018C,$0046,$018E,$048A		;COLOR06,COLOR07
	;Dual playfield colors PF1
	;dc.w	$0190,$0000,$0192,$0EEE		;COLOR08,COLOR09
	;dc.w	$0194,$0258,$0196,$09CE		;COLOR10,COLOR11
	;dc.w	$0198,$069C,$019A,$046A		;COLOR12,COLOR13
	;dc.w	$019C,$0046,$019E,$048A		;COLOR14,COLOR15


	IF 	MUSICPLAYER=1

	CNOP	0,8
MusicModule:
	INCBIN	"Music/NahKolor_v7.mod"

	ENDIF

	CNOP	0,8
LogoPic:
	INCBIN	"Pictures/REALITY-25.raw"
LogoPicPal:
	INCBIN	"Pictures/REALITY-25.pal"
LogoPic_Height	=	98


	CNOP	0,8
TitlePic_01:
	INCIFF	"Pictures/ap-300-1-2.iff"

	CNOP	0,8
TitlePic_02:
	INCIFF	"Pictures/ap-300-2-2.iff"

	CNOP	0,8
TitlePic_03:
	INCIFF	"Pictures/ap-300-3-2.iff"

	CNOP	0,8
TitlePic_04:
	INCIFF	"Pictures/ap-300-4-2.iff"
	

;***************************************************
;Chip BSS Data
;***************************************************

	Section	"Chip BSS Data",BSS_C

	CNOP	0,8
Cubes_VidMem00:		ds.b	320*2/8*32*2	;size picture

	CNOP	0,8
Cubes_VidMem01:		ds.b	320*2/8*32*2	;size picture

	CNOP	0,8
Background_LastBM:	ds.b	320*2/8*32*5*3

	CNOP	0,8
HScroll01_VidMem:	ds.b	352*2/8*32*3	;Width*2/8*Height*Bitmaps
	CNOP	0,8
HScroll02_VidMem:	ds.b	352*2/8*32*3	;Width*2/8*Height*Bitmaps
	CNOP	0,8
HScroll03_VidMem:	ds.b	352*2/8*32*3	;Width*2/8*Height*Bitmaps
	CNOP	0,8
HScroll04_VidMem:	ds.b	352*2/8*32*3	;Width*2/8*Height*Bitmaps
	CNOP	0,8
TitlePic_Empty:		ds.b	320/8*58
