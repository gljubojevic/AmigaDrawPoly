	SECTION	"Intro",CODE_F

	INCDIR	"Include"
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
	INCLUDE	"hardware/dmabits.i"
	INCLUDE	"hardware/cia.i"
	INCLUDE	"libraries/dosextens.i"
	INCLUDE	"devices/input.i"
	INCLUDE	"devices/inputevent.i"
	INCLUDE	"resources/misc.i"

	INCDIR	""

DEBUGING		=	1	;use 1 if debuging
COPPERINT		=	1	;use 1 if Copper int othervise is vertb int
INPUTHANDLER	=	0	;use 1 if using input handler
DOSLIB			=	0	;use 1 if dos library is needed
DMA_ACTIVATE	= 	(DMAF_SETCLR|DMAF_SPRITE|DMAF_RASTER|DMAF_COPPER)

Intro:
	movem.l	d0-a6,-(sp)
	lea	$dff000,a6			;Custom Chip Address in a6

	bsr		Init_Routine	;Init Routine
	tst.l	d0				;Check Ok?
	beq.s	Intro_Init
	bra.w	Intro_Exit
Intro_Init:
;***********************************
; Intro init
;***********************************
    bsr		Video_Init
	bsr		Video_swap

	move.l	#Copper,$080(a6)	; set copper
	bsr		Wait_VerticalBlank
	bsr		Wait_VerticalBlank
	move.w	#DMA_ACTIVATE,$0096(a6)	;Enable DMA

	move.w	#0,VTBInt_Stop		; Start Interrupt
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

Intro_Exit:
	bsr	Restore_Routine
	movem.l	(sp)+,d0-a6
	rts

VTBInt_Handler:
	movem.l	d0-a6,-(sp)
	add.l	#$01,VTBInt_Counter
	tst.w	VTBInt_Stop
	bne.s	VTBInt_End
	lea		$dff000,a6

;***********************************
; interrupt code here
;***********************************
	move.w	#$0f00,$180(a6)	; Mark start

	move.l	VideoMem(pc),a0
	lea	Video_YTable,a1
;	lea	CubeTriangle,a2
	lea	Triangle,a2
	bsr.w	DrawObject
	bsr.w	Video_swap

	move.w	#$0000,$180(a6)	; Mark end

VTBInt_End:
	movem.l	(sp)+,d0-a6
	moveq	#$00,d0
	rts

	INCLUDE	"routines/CyberlabsIntroStartup.s"

;***************************************************
;Intro routines
;***************************************************

; 3D Screen dimensions
Scr3D_Width		= 320
Scr3D_Height	= 256
Scr3D_Bitmaps	= 2
Scr3D_WBytes	= Scr3D_Width/8					;bytes single line bitmap
Scr3D_LBytes	= Scr3D_WBytes*Scr3D_Bitmaps	;bytes interleaved line all bitmaps 
Scr3D_VideoMem	= Scr3D_LBytes*Scr3D_Height		;video memeory size

Video_Init:
	movem.l	d0-d2/a0-a1,-(sp)

    lea 	VideoMem(pc),a0
    move.l 	#VideoMem01,$0(a0)
    move.l 	#VideoMem02,$4(a0)

	moveq.l	#1<<Scr3D_Bitmaps-1,d0
	lea		Copper_Col,a0
	lea		VideoColors(pc),a1
	bsr		Write_CopperListColors

	lea		Video_YTable,a0
	moveq	#0,d0
	move.l	#Scr3D_Height-1,d1
VI_NextYOffset:
	move.w	d0,(a0)+
	add.w	#Scr3D_WBytes*Scr3D_Bitmaps,d0
	dbf		d1,VI_NextYOffset

	movem.l	(sp)+,d0-d2/a0-a1
    rts

Video_swap:	
	movem.l	d0-d2/a0,-(sp)

    lea		VideoMem(pc),a0
	move.l	$0000(a0),d0			;draw buffer for show
	move.l	$0004(a0),$0000(a0)		;set new draw buffer
	move.l	d0,$0004(a0)			;set current show buffer

	move.l	#Scr3D_WBytes,d1
	moveq.l	#Scr3D_Bitmaps-1,d2
	lea		Copper_BP,a0
	bsr		Write_CopperListBitmaps

	movem.l	(sp)+,d0-d2/a0
	rts

; Video memory pointers
VideoMem:
    dc.l    0   ; draw buffer
    dc.l    0   ; show buffer

VideoColors:
	dc.w	$0000,$0fff,$0f00,$0007

; Draw 3D object after transformation on screen
; a0 - Video memory
; a1 - YTable offsets
; a2 - Object pointer
DrawObject:
	movem.l d0-a6,-(sp)
	move.l	20(a2),a3		;a3 - pointer to triangles
	move.l	16(a2),a2		;a2 - ponter to rotated vertex
DO_NextTriangle:
	move.w	(a3)+,d3		; d3 - color
	bmi.s	DO_Done			; no more triangles
	movem.w	(a3)+,d0-d2		; vextex pointers
	move.l	(a2,d0.w),d0	; d0 X0,Y0
	move.l	(a2,d1.w),d1	; d1 X1,Y1
	move.l	(a2,d2.w),d2	; d2 X2,Y2
	; TODO: Check visible
	bsr.s	DrawTriangle
	bra.s	DO_NextTriangle
DO_Done:
	movem.l (sp)+,d0-a6
	rts

	;First version no edge buffer
	;INCLUDE "routines/TriangleDraw01.s"

	;Secnod version with edge buffer
	INCLUDE "routines/TriangleDraw02.s"

;***************************************************
;Fast Data
;***************************************************
	SECTION	"Intro data",DATA_F
;	INCLUDE "routines/CubeTriangle.s"
	INCLUDE "routines/Triangle.s"

Video_YTable:
	ds.w	Scr3D_Height,0

;***************************************************
;Chip Data
;***************************************************
	SECTION	"Chip Data",DATA_C

	INCLUDE "routines/CyberlabsIntroStartupCopper.s"

	CNOP	0,8
Copper:
	dc.w	$01fc,$0000
	dc.w	$008e,$2c81		;Screen Size
	dc.w	$0090,$2cc1		;Screen Size
	dc.w	$0092,$0038		;H-start
	dc.w	$0094,$00d0		;H-stop
	dc.w	$0100,$2200		;Bit-Plane control reg.
	dc.w	$0102,$0000		;Hor-Scroll
	dc.w	$0104,$0010		;Sprite/Gfx priority
	dc.w	$0106,$0c00		;BPLCON3 Default DPF color offsets
	dc.w	$0108,$0028		;Modolo (odd)
	dc.w	$010A,$0028		;Modolo (even)
	dc.w	$010c,$0000		;BPLCON4
Copper_Spr:
	dc.w	$0120,$0000,$0122,$0000
	dc.w	$0124,$0000,$0126,$0000
	dc.w	$0128,$0000,$012a,$0000
	dc.w	$012c,$0000,$012e,$0000
	dc.w	$0130,$0000,$0132,$0000
	dc.w	$0134,$0000,$0136,$0000
	dc.w	$0138,$0000,$013a,$0000
	dc.w	$013c,$0000,$013e,$0000
Copper_BP:
	dc.w	$00e0,$0000,$00e2,$0000	;BPL1PTH,BPL1PTL
	dc.w	$00e4,$0000,$00e6,$0000	;BPL2PTH,BPL2PTL
Copper_Col:
	dc.w	$0180,$0000,$0182,$0000
	dc.w	$0184,$0000,$0186,$0000
	dc.w	$2c01,$fffe
	IF	COPPERINT=1
	dc.w	$009c,$8010			;INTREQ
	ENDIF
	dc.w	$ffff,$fffe			;End of Copper List
	dc.w	$ffff,$fffe			;End of Copper List

;***************************************************
;Chip BSS Data
;***************************************************
	SECTION	"Chip BSS Data",BSS_C

	CNOP	0,8
VideoMem01:	ds.b	Scr3D_VideoMem

	CNOP	0,8
VideoMem02:	ds.b	Scr3D_VideoMem
