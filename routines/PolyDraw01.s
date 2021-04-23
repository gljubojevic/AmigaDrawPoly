Scr3D_TablesInit:
	movem.l	d0-d3/a0,-(sp)
	lea		Scr3D_YTable(pc),a0
	moveq	#0,d0
	move.l	#Scr3D_Height-1,d1
VI_NextYOffset:
	move.w	d0,(a0)+
	add.w	#Scr3D_WBytes*Scr3D_Bitmaps,d0
	dbf		d1,VI_NextYOffset

	lea		Scr3D_XMask(pc),a0
	moveq	#0,d0
	move.l	#Scr3D_Width-1,d1
VI_NextXMask:
	move.l	d0,d2
	and.l	#$0f,d2
	moveq.l	#-1,d3
	lsr.w	d2,d3
	move.w	d3,(a0)+
	addq.l	#1,d0
	dbf		d1,VI_NextXMask
	movem.l	(sp)+,d0-d3/a0
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
	move.l	#-3,(a4)+	; color negative number as marker to stop calculating edges
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
; color - negative number as marker to stop calculating edges
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
;
DrawPoly:
	lea		DO_Lines(pc),a4
	lea		DO_YMinMax(pc),a5
	move.l	(a4)+,d1		;X1,Y1
	move.w	d1,(a5)+		;Reset YMin
	move.w	d1,(a5)+		;Reset YMax
	move.l	(a4)+,d2		;X2,Y2 NOTE: Must be at least 1 line to draw
DP_NextLine:

	subq.l	#4,a5			;Pointer to YMin, YMax
	cmp.w	(a5)+,d2		;Check YMin, YMax
	bge.s	DP_NotYMin
	move.w	d2,-2(a5)
DP_NotYMin:
	cmp.w	(a5)+,d2
	ble.s	DP_NotYMax
	move.w	d2,-2(a5)
DP_NotYMax:

	move.l	d2,d5			;save X2,Y2
	move.w	d2,d7			;Y2
	lea		DP_Edges(pc),a6
	sub.w	d1,d7			;dy = Y2-Y1
	beq.w	DP_NoLine		;TODO: Remove this from data no need to draw horizontal lines
	bpl.s	DP_NotRevered	;is it top/down line
	lea		Scr3D_Height*2(a6),a6
	neg.w	d7				;Swap to draw line top to bottom
	exg		d1,d2			;convert to top/down line X1,Y1<->X2,Y2
DP_NotRevered:
	add.w	d1,d1			;Y1*2
	lea		(a6,d1.w),a6	;Y1 Edge buffer offset
	swap	d1				;get X1
	swap	d2				;get X2
	sub.w	d1,d2			;dx = X2-X1
	ext.l	d2
	asl.l	#DP_FixPoint,d2
	divs	d7,d2			;dx / dy
	moveq	#0,d3			;prepare decimal increment
	ext.l	d2				;get result in long and check if negative slope
	bpl.s	DP_NotNegativeInc
	moveq	#-1,d3			; decimal increment is negative
DP_NotNegativeInc:
	asl.l	#DP_FixPoint16,d2	;align decimal point 16bits
	move.w	d2,d4			;decimal part
	swap	d2				;whole part

	move.w	#$00ff,$dff180

	neg.w	d7
	add.w	#Scr3D_Height,d7
	add.w	d7,d7
	move.w	d7,d6
	add.w	d7,d7
	add.w	d6,d7
	jmp		(pc,d7.w)		;must have vasm -nowarn=2069
	REPT	Scr3D_Height
	move.w	d1,(a6)+
	add.w	d4,d3			; add decimal part for overflow
	addx.w	d2,d1			; X1 + (dx / dy)
	ENDR

DP_NoLine:
	move.l	d5,d1
	move.l	(a4)+,d2		;X2,Y2 or color
	bpl.w	DP_NextLine

DP_FillHLines:
	move.w	#$00f0,$dff180

	subq.l	#4,a5			;Pointer to YMin, YMax
	movem.w	(a5)+,d0-d1		;YMin, YMax
	sub.w	d0,d1			;dy = YMin - YMax
	subq.w	#1,d1
	add.w	d0,d0
	move.w	(a2,d0.w),d2			;Y Video offset
	lea		(a0,d2.w),a6			;Y Video address
	lea		DP_Edges(pc),a4			;Edges
	adda.w	d0,a4					;Left edge
	lea		Scr3D_Height*2(a4),a5	;Right edge

; Draw horizontal lines
	move.l	a3,-(sp)
HL_Next:
	movem.w	(a4)+,d2		;X1
	movem.w	(a5)+,d3		;X2

	move.w	d2,d6
	add.w	d6,d6
	move.w	d3,d7
	add.w	d7,d7
	lea		Scr3D_XMask(pc),a3
	move.w	(a3,d6.w),d6	;Left mask
	move.w	(a3,d7.w),d7	;Right mask
	not.w	d7

	lsr.w	#4,d2	;Left offset
	add.w	d2,d2

	lsr.w	#4,d3	;Right offset
	add.w	d3,d3

	cmp.w	d2,d3
	bne.s	HL_NotSameLong
	eor.w	d6,d7			;Start and end on same offset
	not.w	d7
	or.w	d7,(a6,d2.w)	;TODO: Colors
	lea		Scr3D_LBytes(a6),a6
	dbf		d1,HL_Next
	move.l	(sp)+,a3
	rts

HL_NotSameLong:
	lea		(a6,d2.w),a3
	or.w	d6,(a3)+
	subq.w	#2,d3
	cmp.w	d2,d3
	beq.s	HL_LastLong
	moveq	#-1,d5		;$ffffffff - fill patern
	sub.w	d2,d3
	lsr.w	#1,d3
	subq.w	#1,d3
	neg.w	d3
	add.w	#(Scr3D_WBytes/2)-1,d3
	add.w	d3,d3
	jmp		(pc,d3.w)	;must have vasm -nowarn=2069
HL_NextLong:
	REPT	(Scr3D_WBytes/2)-1
	or.w	d5,(a3)+	;TODO: Colors
	ENDR
HL_LastLong:
	or.w	d7,(a3)+	;TODO: Colors

	lea		Scr3D_LBytes(a6),a6
	dbf		d1,HL_Next
	move.l	(sp)+,a3
	rts

DP_Edges:
	ds.w	Scr3D_Height	;X1 Left edges
	ds.w	Scr3D_Height	;X2 Right edges

;put closer to routines
Scr3D_XMask:
	ds.w	Scr3D_Width,0
Scr3D_YTable:
	ds.w	Scr3D_Height,0
