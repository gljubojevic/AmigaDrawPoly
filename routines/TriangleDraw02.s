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
DO_NextTriangle:
	move.w	(a3)+,d3		; d3 - color
	bmi.s	DO_Done			; no more triangles
	movem.w	(a3)+,d0-d2		; vextex pointers
	move.l	(a1,d0.w),d0	; d0 X0,Y0
	move.l	(a1,d1.w),d1	; d1 X1,Y1
	move.l	(a1,d2.w),d2	; d2 X2,Y2
	; TODO: Check visible
	bsr.s	DrawTriangle
	bra.s	DO_NextTriangle
DO_Done:
	movem.l (sp)+,d0-a6
	rts

; Draw triangle to video memory, draws top to bottom
; Note: Uses edge buffer
; d0 - X0,Y0
; d1 - X1,Y1
; d2 - X2,Y2
; d3 - color
; a0 - Video memory
; a1 - YTable offsets
DT_FixPoint=8	;interpolation precision
;
DrawTriangle:
	cmp.w	d1,d0	;Y1 < Y0
	ble.s	DT_Sort1
	exg.l	d1,d0
DT_Sort1:
	cmp.w	d2,d0	;Y2 < Y0
	ble.s	DT_Sort2
	exg.l	d2,d0
DT_Sort2:
	cmp.w	d2,d1	;Y2 < Y1
	ble.s	DT_Sorted
	exg.l	d2,d1
DT_Sorted:
	move.w	d2,d4	;Y2
	sub.w	d0,d4	;Y2-Y0
	beq.w	DT_Done	;trinagle is 0 size
	lea		DT_Edges(pc),a4
	move.w	d4,(a4)+	;Total height of triangle

	move.w	d2,d5	;Y2
	sub.w	d1,d5	;Y2-Y1
	move.w	d1,d6	;Y1
	sub.w	d0,d6	;Y1-Y0

	add.w	d0,d0	;Y0
	move.w	(a2,d0.w),(a4)+	;Y0 offset in video moemory

	swap	d0		;X0
	swap	d1		;X1
	swap	d2		;X2

	move.w	d2,d7	;X2
	sub.w	d1,d7	;X2-X1

	sub.w	d0,d2	;X2-X0
	ext.l	d2
	asl.l	#DT_FixPoint,d2
	divs	d4,d2 	;(X2-X0) / (Y2-Y0)
	ext.l	d2

	sub.w	d0,d1	;X1-X0
	ext.l	d0
	asl.l	#DT_FixPoint,d0	;Xleft
	move.l	d0,d4			;XRight
	tst.w	d6
	beq.s	DT_SkipFirstHalf	;Avoid division by zero

	ext.l	d1
	asl.l	#DT_FixPoint,d1
	divs	d6,d1	;(X1-X0) / (Y1-Y0)
	ext.l	d1
	subq.l	#1,d6
DT_FirstHalf:
	move.l	d0,(a4)+
	add.l	d2,d0	;XLeft  + ((X2-X0) / (Y2-Y0))
	move.l	d4,(a4)+
	add.l	d1,d4	;XRight + ((X1-X0) / (Y1-Y0))
	dbf		d6,DT_FirstHalf

DT_SkipFirstHalf:
	tst.w	d5
	beq.s	DT_NoSecondHalf	; no second trinagle

	ext.l	d7
	asl.l	#DT_FixPoint,d7
	divs	d5,d7
	ext.l	d7		;(X2-X1) / (Y2-Y1)
	subq.l	#1,d5
DT_SecondHalf:
	move.l	d0,(a4)+
	add.l	d2,d0	;XLeft  + ((X2-X0) / (Y2-Y0))
	move.l	d4,(a4)+
	add.l	d7,d4	;XRight + ((X2-X1) / (Y2-Y1))
	dbf		d5,DT_SecondHalf
DT_NoSecondHalf:
;Draw horizontal lines
; d3 - Color
	move.w	#$00f0,$180(a6)

	move.l	a3,-(sp)
	lea		DT_Edges(pc),a4	;Edges in a5
	movem.w	(a4)+,d0/d1		;Height, Y offest
	lea		(a0,d1.w),a5	;Video memory frist Y cord
	moveq	#$1f,d4			;Mask size
DTHL_NextLine
	movem.l	(a4)+,d1/d2		;X1,X2
	asr.l	#DT_FixPoint,d1
	asr.l	#DT_FixPoint,d2
	cmp.w	d1,d2
	beq.s	DTHL_NoLine
	bgt.s	DTHL_OrderOk
	exg		d1,d2
DTHL_OrderOk:

	move.w	d1,d5	;Left mask
	and.w	d4,d5
	moveq.l	#-1,d6
	lsr.l	d5,d6
	asr.w	#5,d1	;Left offset
	lsl.w	#2,d1

	move.w	d2,d5	;Right mask
	and.w	d4,d5
	moveq.l	#-1,d7
	lsr.l	d5,d7
	not.l	d7
	asr.w	#5,d2	;Right offset
	lsl.w	#2,d2

	cmp.w	d1,d2
	bne.s	DTHL_NotSameLong
	eor.l	d6,d7
	not.l	d7
	or.l	d7,(a5,d1.w)	;TODO: Colors
	lea		Scr3D_LBytes(a5),a5
	dbf		d0,DTHL_NextLine
	move.l	(sp)+,a3
	rts

DTHL_NotSameLong:
	lea		(a5,d1.w),a3
	or.l	d6,(a3)+
	subq.w	#4,d2
	sub.w	d1,d2
	beq.s	DTHL_LastLong
	lsr.w	#2,d2
	subq.w	#1,d2
	moveq	#-1,d5	;$ffffffff
DTHL_NextLong:
	or.l	d5,(a3)+	;TODO: Colors
	dbf		d2,DTHL_NextLong
DTHL_LastLong:
	or.l	d7,(a3)+	;TODO: Colors

DTHL_NoLine:
	lea		Scr3D_LBytes(a5),a5
	dbf		d0,DTHL_NextLine
	move.l	(sp)+,a3

DT_Done;
	rts

DT_Edges:
	dc.w	0				;height of triangle
	dc.w	0				;video memory y offet
	ds.l	Scr3D_Height*2	;edges X1, X2

;put closer to routines
Scr3D_YTable:
	ds.w	Scr3D_Height,0
