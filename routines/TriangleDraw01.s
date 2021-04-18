Scr3D_TablesInit:
	movem.l	d0-d3/a0,-(sp)
	lea		Scr3D_YTable,a0
	moveq	#0,d0
	move.l	#Scr3D_Height-1,d1
VI_NextYOffset:
	move.w	d0,(a0)+
	add.w	#Scr3D_WBytes*Scr3D_Bitmaps,d0
	dbf		d1,VI_NextYOffset
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
	beq.s	DT_Done	;trinagle is 0 size
	move.w	d2,d5	;Y2
	sub.w	d1,d5	;Y2-Y1
	move.w	d1,d6	;Y1
	sub.w	d0,d6	;Y1-Y0

	add.w	d0,d0	;Y0
	move.w	(a2,d0.w),d0	;Y0 offset in video moemory
	lea		(a0,d0.w),a4	;a4 - Video memory at Y0

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
DT_FirstHalf:
	bsr.s	DT_HorizontalLine
	add.l	d2,d0	;XLeft  + ((X2-X0) / (Y2-Y0))
	add.l	d1,d4	;XRight + ((X1-X0) / (Y1-Y0))
	lea		Scr3D_LBytes(a4),a4
	dbf		d6,DT_FirstHalf

DT_SkipFirstHalf:
	tst.w	d5
	beq.s	DT_Done	; no second trinagle

	ext.l	d7
	asl.l	#DT_FixPoint,d7
	divs	d5,d7
	ext.l	d7		;(X2-X1) / (Y2-Y1)
DT_SecondHalf:
	bsr.s	DT_HorizontalLine
	add.l	d2,d0	;XLeft  + ((X2-X0) / (Y2-Y0))
	add.l	d7,d4	;XRight + ((X2-X1) / (Y2-Y1))
	lea		Scr3D_LBytes(a4),a4
	dbf		d5,DT_SecondHalf

DT_Done;
	rts

; d0 X1
; d4 X2
; d3 - color
; a4 - Video memory Y cord
DT_HorizontalLine:
	movem.l d0/d4-d7,-(sp)
;	move.w	#$00f0,$180(a6)
	asr.l	#DT_FixPoint,d0
	asr.l	#DT_FixPoint,d4
	cmp.l	d0,d4
	beq.s	DTHL_Done
	bgt.s	DTHL_OrderOk
	exg.l	d0,d4
DTHL_OrderOk:
	moveq	#$0f,d5

	move.l	d0,d6
	and.l	d5,d6
	add.w	d6,d6
	move.w	DTHL_MaskLeft(pc,d6.w),d6
	asr.l	#4,d0
	add.l	d0,d0

	move.l	d4,d7
	and.l	d5,d7
	add.w	d7,d7
	move.w	DTHL_MaskRight(pc,d7.w),d7
	asr.l	#4,d4
	add.l	d4,d4

	cmp.l	d0,d4
	bne.s	DTHL_NotSameWord
	eor.w	d6,d7
	not.w	d7
	or.w	d7,(a4,d0.w)
	;TODO: Colors
	bra.s	DTHL_Done

DTHL_NotSameWord:
	or.w	d6,(a4,d0.w)
	or.w	d7,(a4,d4.w)
	;TODO: Colors
	subq	#2,d4
	cmp.w	d0,d4
	beq.s	DTHL_Done
	move.w	#$ffff,d5
DTHL_NextWord:
	addq.w	#2,d0
	or.w	d5,(a4,d0.w)
	;TODO: Colors
	cmp.w	d4,d0
	blt.s	DTHL_NextWord

DTHL_Done:
;	move.w	#$0f00,$180(a6)
	movem.l (sp)+,d0/d4-d7
	rts

DTHL_MaskLeft:
	dc.w	%1111111111111111	;0
	dc.w	%0111111111111111	;1
	dc.w	%0011111111111111	;2
	dc.w	%0001111111111111	;3
	dc.w	%0000111111111111	;4
	dc.w	%0000011111111111	;5
	dc.w	%0000001111111111	;6
	dc.w	%0000000111111111	;7
	dc.w	%0000000011111111	;8
	dc.w	%0000000001111111	;9
	dc.w	%0000000000111111	;A
	dc.w	%0000000000011111	;B
	dc.w	%0000000000001111	;C
	dc.w	%0000000000000111	;D
	dc.w	%0000000000000011	;E
	dc.w	%0000000000000001	;F

DTHL_MaskRight:
	dc.w	%1000000000000000	;0
	dc.w	%1100000000000000	;1
	dc.w	%1110000000000000	;2
	dc.w	%1111000000000000	;3
	dc.w	%1111100000000000	;4
	dc.w	%1111110000000000	;5
	dc.w	%1111111000000000	;6
	dc.w	%1111111100000000	;7
	dc.w	%1111111110000000	;8
	dc.w	%1111111111000000	;9
	dc.w	%1111111111100000	;A
	dc.w	%1111111111110000	;B
	dc.w	%1111111111111000	;C
	dc.w	%1111111111111100	;D
	dc.w	%1111111111111110	;E
	dc.w	%1111111111111111	;F

;put closer to routines
Scr3D_YTable:
	ds.w	Scr3D_Height,0
