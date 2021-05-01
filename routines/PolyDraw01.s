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
	move.l	20(a1),a2		;a2 - pointer to triangles
	move.l	16(a1),a1		;a2 - ponter to rotated vertex
DO_NextPoly:
	move.w	(a2),d0			; vtx1 idx
	bmi		DO_Done			; end of polys
	movem.w	2(a2),d1-d2		; vtx2, vtx3 idx
	move.l	(a1,d0.w),d0	; d0 X0,Y0
	move.l	(a1,d1.w),d1	; d1 X1,Y1
	move.l	(a1,d2.w),d2	; d2 X2,Y2
	bsr		DO_IsVisible

	;process lines for poly
	lea		DO_Lines(pc),a4
	movem.w	(a2)+,d0-d1		;vtx1,vtx2
	move.l	(a1,d0.w),d0	;d0 X0,Y0
	move.l	(a1,d1.w),d1	;d1 X1,Y1
	;TODO: Clip line
	move.l	d0,(a4)+		; First line to draw
	move.l	d1,(a4)+		;
DO_NextLine:
	move.l	d1,d0			;Last point to first
	move.w	(a2)+,d1
	bmi.s	DO_Draw			; Color is read
	move.l	(a1,d1.w),d1	; d1 X1,Y1
	;TODO: Clip line
	move.l	d1,(a4)+		;last clipped cord
	bra		DO_NextLine
DO_Draw:
	ext.l	d1
	move.l	d1,(a4)+		;Store color to finish poly

	movem.l	a1-a2,-(sp)
	bsr.s	DrawPoly
	movem.l	(sp)+,a1-a2

	bra.s	DO_NextPoly
DO_Done:
	movem.l (sp)+,d0-a6
	rts

;TODO: Check visible
; d0 X0,Y0
; d1 X1,Y1
; d2 X2,Y2
DO_IsVisible:
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
	dc.w	0	;YMax
	dc.w	0	;YMin

; a0 - Video memory
DP_FixPoint=8					;interpolation precision
DP_FixPoint16=16-DP_FixPoint	;shift to move to upper 16 bit
DP_UseREPT=1					;Use REPT instead of dbf
;
DrawPoly:
	lea		DO_YMinMax(pc),a1
	lea		DO_Lines(pc),a2
	move.l	(a2)+,d1		;X1,Y1
	move.w	d1,(a1)+		;Reset YMax
	move.w	d1,(a1)+		;Reset YMin
	move.l	(a2)+,d2		;X2,Y2 NOTE: Must be at least 1 line to draw
DP_NextLine:
	move.w	#$0f00,$dff180

	subq.l	#4,a1			;Pointer to YMax,YMin
	cmp.w	(a1)+,d2		;Check YMax,YMin
	ble.s	DP_NotYMax
	move.w	d2,-2(a1)
DP_NotYMax:
	cmp.w	(a1)+,d2
	bge.s	DP_NotYMin
	move.w	d2,-2(a1)
DP_NotYMin:

	move.l	d2,d5			;save X2,Y2
	move.w	d2,d7			;Y2
	lea		DP_Edges(pc),a3
	sub.w	d1,d7			;dy = Y2-Y1
	;beq.w	DP_NoLine		;TODO: Remove this from data no need to draw horizontal lines
	bpl.s	DP_NotRevered	;is it top/down line
	lea		Scr3D_Height*2(a3),a3
	neg.w	d7				;Swap to draw line top to bottom
	exg		d1,d2			;convert to top/down line X1,Y1<->X2,Y2
DP_NotRevered:
	add.w	d1,d1			;Y1*2
	lea		(a3,d1.w),a3	;Y1 Edge buffer offset
	swap	d1				;get X1
	ext.l	d1
	swap	d2				;get X2
	ext.l	d2
	sub.l	d1,d2			;dx = X2-X1
	asl.l	#DP_FixPoint,d2
	divs	d7,d2			;dx / dy
	ext.l	d2				;get result in long and check if negative slope
	asl.l	#DP_FixPoint16,d2	;align decimal point 16bits
	bpl.w	DP_NotNegativeInc

	move.w	#$00ff,$dff180
	neg.l	d2				;make positive so we can use subx
	swap	d2				;decimal in upper 16bit, whole part lower 16bit

	IF		DP_UseREPT
	neg.w	d7
	add.w	#Scr3D_Height,d7
	add.w	d7,d7
	add.w	d7,d7
	jmp		(pc,d7.w)		;must have vasm -nowarn=2069
	REPT	Scr3D_Height
	move.w	d1,(a3)+
	subx.l	d2,d1			; X1 - (dx / dy)
	ENDR
	ELSE
	subq.w	#1,d7
DP_DXNegative:
	move.w	d1,(a3)+
	subx.l	d2,d1			; X1 - (dx / dy)
	dbf		d7,DP_DXNegative
	ENDIF
	move.l	d5,d1
	move.l	(a2)+,d2		;X2,Y2 or color
	bpl.w	DP_NextLine		;not color do next line
	bra.w	DP_FillHLines	;done with lines

DP_NotNegativeInc:
	move.w	#$00ff,$dff180
	swap	d2				;decimal in upper 16bit, whole part lower 16bit

	IF		DP_UseREPT
	neg.w	d7
	add.w	#Scr3D_Height,d7
	add.w	d7,d7
	add.w	d7,d7
	jmp		(pc,d7.w)		;must have vasm -nowarn=2069
	REPT	Scr3D_Height
	move.w	d1,(a3)+
	addx.l	d2,d1			; X1 + (dx / dy)
	ENDR
	ELSE
	subq.w	#1,d7
DP_DXPositive:
	move.w	d1,(a3)+
	addx.l	d2,d1			; X1 + (dx / dy)
	dbf		d7,DP_DXPositive
	ENDIF

DP_NoLine:
	move.l	d5,d1
	move.l	(a2)+,d2		;X2,Y2 or color
	bpl.w	DP_NextLine		;not color do next line

; a0 - Video memory
; a1 - ;YMin, YMax (end)
; d2 - color as negative number
DP_FillHLines:
	move.w	#$00f0,$dff180

	subq.l	#4,a1			;Pointer to YMin, YMax
	movem.w	(a1)+,d0-d1		;YMax, YMin
	sub.w	d1,d0			;dy = YMin - YMax
	subq.w	#1,d0
	add.w	d1,d1
	lea		Scr3D_YTable(pc),a3
	move.w	(a3,d1.w),d2			;Y Video offset
	lea		(a0,d2.w),a3			;Y Video address
	lea		DP_Edges(pc),a1			;Edges
	adda.w	d1,a1					;Left edge
	lea		Scr3D_Height*2(a1),a2	;Right edge

; Draw horizontal lines
HL_Next:
	move.w	(a1)+,d2		;X1
	move.w	(a2)+,d3		;X2

	lea		Scr3D_XMask(pc),a4
	move.w	d2,d6
	add.w	d6,d6
	move.w	(a4,d6.w),d6	;Left mask
	move.w	d3,d7
	add.w	d7,d7
	move.w	(a4,d7.w),d7	;Right mask
	not.w	d7

	lsr.w	#4,d2	;Left offset
	add.w	d2,d2

	lsr.w	#4,d3	;Right offset
	add.w	d3,d3

	cmp.w	d2,d3
	bne.s	HL_NotSameLong
	eor.w	d6,d7			;Start and end on same offset
	not.w	d7
	or.w	d7,(a3,d2.w)	;TODO: Colors
	lea		Scr3D_LBytes(a3),a3
	dbf		d0,HL_Next
	rts

HL_NotSameLong:
	lea		(a3,d2.w),a4
	or.w	d6,(a4)+
	subq.w	#2,d3
	cmp.w	d2,d3
	beq.s	HL_LastWord
	moveq	#-1,d5		;$ffffffff - fill patern
	sub.w	d2,d3
	lsr.w	#1,d3
	subq.w	#1,d3

	IF		DP_UseREPT
	neg.w	d3
	add.w	#(Scr3D_WBytes/2)-1,d3
	add.w	d3,d3
	jmp		(pc,d3.w)	;must have vasm -nowarn=2069
	REPT	(Scr3D_WBytes/2)-1
	or.w	d5,(a4)+	;TODO: Colors
	ENDR
	ELSE
HL_NextWord:
	or.w	d5,(a4)+	;TODO: Colors
	dbf		d3,HL_NextWord
	ENDIF
HL_LastWord:
	or.w	d7,(a4)+	;TODO: Colors

	lea		Scr3D_LBytes(a3),a3
	dbf		d0,HL_Next
	rts

DP_Edges:
	ds.w	Scr3D_Height	;X1 Left edges
	ds.w	Scr3D_Height	;X2 Right edges

;put closer to routines
Scr3D_XMask:
	ds.w	Scr3D_Width,0
Scr3D_YTable:
	ds.w	Scr3D_Height,0
