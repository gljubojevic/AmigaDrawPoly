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
	move.w	(a1,d0.w),(a4)+	;Y0 offset in video moemory

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
	add.l	d2,d0	;XLeft  + ((X2-X0) / (Y2-Y0))
	move.l	d0,(a4)+
	add.l	d1,d4	;XRight + ((X1-X0) / (Y1-Y0))
	move.l	d4,(a4)+
	dbf		d6,DT_FirstHalf

DT_SkipFirstHalf:
	tst.w	d5
	beq.s	DT_NoSecondHalf	; no second trinagle

	ext.l	d7
	asl.l	#DT_FixPoint,d7
	divs	d5,d7
	ext.l	d7		;(X2-X1) / (Y2-Y1)
DT_SecondHalf:
	add.l	d2,d0	;XLeft  + ((X2-X0) / (Y2-Y0))
	move.l	d0,(a4)+
	add.l	d7,d4	;XRight + ((X2-X1) / (Y2-Y1))
	move.l	d4,(a4)+
	dbf		d5,DT_SecondHalf
DT_NoSecondHalf:
;Draw horizontal lines
; d3 - Color
	;move.w	#$00f0,$180(a6)

	lea		DT_Edges(pc),a4	;Edges in a5
	move.w	(a4)+,d0		;Height
	;subq.w	#1,d0
	;bmi.s	DT_Done
	move.w	(a4)+,d1		;Y offest
	lea		(a0,d1.w),a5	;Video memory frist Y cord
DTHL_NextLine
	movem.l	(a4)+,d1/d2		;X1,X2
	asr.l	#DT_FixPoint,d1
	asr.l	#DT_FixPoint,d2
	cmp.l	d1,d2
	beq.s	DTHL_NoLine
	bgt.s	DTHL_OrderOk
	exg.l	d1,d2
DTHL_OrderOk:
	moveq	#$0f,d4

	move.l	d1,d6
	and.l	d4,d6
	add.w	d6,d6
	move.w	DTHL_MaskLeft(pc,d6.w),d6
	asr.l	#4,d1
	add.l	d1,d1

	move.l	d2,d7
	and.l	d4,d7
	add.w	d7,d7
	move.w	DTHL_MaskRight(pc,d7.w),d7
	asr.l	#4,d2
	add.l	d2,d2

	cmp.l	d1,d2
	bne.s	DTHL_NotSameWord
	eor.w	d6,d7
	not.w	d7
	or.w	d7,(a5,d1.w)
	;TODO: Colors
	bra.s	DTHL_NoLine

DTHL_NotSameWord:
	or.w	d6,(a5,d1.w)
	or.w	d7,(a5,d2.w)
	;TODO: Colors
	subq	#2,d2
	cmp.w	d1,d2
	beq.s	DTHL_NoLine
	moveq	#-1,d5	;$ffffffff
DTHL_NextWord:
	addq.w	#2,d1
	or.w	d5,(a5,d1.w)
	;TODO: Colors
	cmp.w	d2,d1
	blt.s	DTHL_NextWord

DTHL_NoLine:
	lea		Scr3D_LBytes(a5),a5
	dbf		d0,DTHL_NextLine

DT_Done;
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

DT_Edges:
	dc.w	0				;height of triangle
	dc.w	0				;video memory y offet
	ds.l	Scr3D_Height*2	;edges X1, X2
