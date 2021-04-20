Scr3D_TablesInit:
	movem.l	d0-d1/a0,-(sp)
	lea		Scr3D_YTable,a0
	moveq	#0,d0
	move.l	#Scr3D_Height-1,d1
VI_NextYOffset:
	move.w	d0,(a0)+
	add.w	#Scr3D_WBytes*Scr3D_Bitmaps,d0
	dbf		d1,VI_NextYOffset
	movem.l	(sp)+,d0-d1/a0
	rts

; Draw 3D object after transformation on screen
; a0 - Video memory
; a1 - Object pointer
DrawObject:
	movem.l d0-a6,-(sp)
	lea	Scr3D_YTable(pc),a2
	move.l	20(a1),a3		;a3 - pointer to triangles
	move.l	16(a1),a1		;a2 - ponter to rotated vertex
DO_NextPoly:
	move.w	(a3)+,d3		; d3 - color
	bmi.s	DO_Done			; no more triangles
	movem.w	(a3)+,d0-d2		; vextex pointers
	move.l	(a1,d0.w),d0	; d0 X0,Y0
	move.l	(a1,d1.w),d1	; d1 X1,Y1
	move.l	(a1,d2.w),d2	; d2 X2,Y2
	; TODO: Check visible
	lea		DO_Lines(pc),a4	;Just temp copy for now
	move.l	d0,(a4)+
	move.l	d1,(a4)+
	move.l	d2,(a4)+
	move.l	d0,(a4)+
	; TODO: Clippping
	bsr.s	DrawPoly
	bra.s	DO_NextPoly
DO_Done:
	movem.l (sp)+,d0-a6
	rts

; Coordinate of polygon lines e.g.
; X1,Y1
; X2,Y2
; X3,Y3
; X1,Y1 - must end with first cord to close poly
DO_Lines:
	ds.l	8

; Min and Max Y coord of poly
DO_YMinMax:
	dc.w	0	;YMin
	dc.w	0	;YMax

; a0 - Video memory
; a1 - YTable offsets
; a4 - Line cords
; a4 - Min, Max Y
DP_FixPoint=8					;interpolation precision
DP_FixPoint16=16-DP_FixPoint	;shift to move to upper 16 bit
DP_OnlyOutline=1				;Draw only outline no fill
;
DrawPoly:
	lea		DO_Lines(pc),a4
	lea		DO_YMinMax(pc),a5
	moveq	#3-1,d0			;hardcoded for now
	movem.w	(a4)+,d1-d2		;X1,Y1
	move.w	d2,(a5)+
	move.w	d2,(a5)+
DP_NextLine:
	movem.w	(a4)+,d3-d4		;X2,Y2

	lea		DO_YMinMax(pc),a5
	cmp.w	(a5)+,d4
	bge.s	DP_NotYMin
	move.w	d4,-2(a5)
DP_NotYMin:
	cmp.w	(a5)+,d4
	ble.s	DP_NotYMax
	move.w	d4,-2(a5)
DP_NotYMax:

	move.w	d3,d5			;X2
	move.w	d4,d6			;Y2
	move.w	d4,d7			;Y2
	lea		DP_Edges(pc),a5
	sub.w	d2,d7			;dy = Y2-Y1
	beq.s	DP_NoLine		;TODO: Remove this from data no need to draw horizontal lines
	bpl.s	DP_NotRevered
	lea		Scr3D_Height*2(a5),a5
	neg.w	d7				;Swap to draw line top to bottom
	exg		d1,d3			;X1<->X2
	exg		d2,d4			;Y1<->Y2
DP_NotRevered:
	sub.w	d1,d3			;dx = X2-X1
	add.w	d2,d2			;Y1*2
	lea		(a5,d2.w),a5	;Y1 Edge buffer offset
	ext.l	d3
	asl.l	#DP_FixPoint,d3
	divs	d7,d3			;dx / dy
	ext.l	d3
	asl.l	#DP_FixPoint16,d3	;integert part to upper 16bits
	move.w	d3,d4				;decimal part to lower 16bits
	moveq	#0,d2
	swap	d3
	tst.w	d3
	bpl.s	DP_NotNegativeInc
	moveq	#-1,d2
DP_NotNegativeInc:
	subq.w	#1,d7
DP_NextLinePoint:
	move.w	d1,(a5)+
	add.w	d4,d2			; add decimal part for overflow
	addx.w	d3,d1			; X1 + (dx / dy)
	dbf		d7,DP_NextLinePoint

DP_NoLine:
	move.w	d5,d1
	move.w	d6,d2
	dbf		d0,DP_NextLine

	move.w	#$00f0,$dff180

	IF DP_OnlyOutline
; Draw outline
	movem.w	DO_YMinMax(pc),d0-d1
	sub.w	d0,d1
	subq.w	#1,d1
	add.w	d0,d0
	move.w	(a2,d0.w),d2
	lea		(a0,d2.w),a6
	lea		DP_Edges(pc,d0.w),a4	;Left edge
	lea		Scr3D_Height*2(a4),a5	;Right edge
	moveq	#7,d4
HL_Next:
	move.w	(a4)+,d2
	move.w	d2,d3
	not.w	d3
	and.w	d4,d3
	lsr.w	#3,d2
	bset	d3,(a6,d2.w)

	move.w	(a5)+,d2
	move.w	d2,d3
	not.w	d3
	and.w	d4,d3
	lsr.w	#3,d2
	bset	d3,(a6,d2.w)

	lea		Scr3D_LBytes(a6),a6
	dbf		d1,HL_Next
	ENDIF

	rts

DP_Edges:
	ds.w	Scr3D_Height	;X1 Left edges
	ds.w	Scr3D_Height	;X2 Right edges

;put closer to routines
Scr3D_YTable:
	ds.w	Scr3D_Height,0
