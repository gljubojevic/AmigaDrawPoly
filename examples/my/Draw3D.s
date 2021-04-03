;----------
;d0.w - Clip up
;d1.w - Clip left
;d2.w - Clip down
;d3.w - Clip right
;d4.w - Bitmap width
;d5.w - Max X
;d6.w - Max Y
;a0.l - Object
;a1.l - Workplane
;a2.l - Showplane
;----------
Draw3D_Init:
	movem.l	d0-d7/a0-a6,-(sp)

	move.l	a0,D3D_Object		;Store 3D object reference
	move.l	a1,Workplane		;Store address of work plane
	move.l	a2,Showplane		;Store address of show plane

	lea	D3D_ClipCords(pc),a3	;Store clip coordinates
	move.w	d0,(a3)+
	move.w	d1,(a3)+
	move.w	d2,(a3)+
	move.w	d3,(a3)+

	lea	D3D_NoBitmaps(pc),a3	;Store no of bitmaps
	move.w	d4,(a3)+

	bsr.s	l_TablesForm

	movem.l	(sp)+,d0-d7/a0-a6
	rts

Up	=	0
Left	=	0
Down	=	31
Right	=	31

D3D_ClipCords:	dc.w	0	;Up
		dc.w	0	;Left
		dc.w	0	;Down
		dc.w	0	;Right
D3D_NoBitmaps:	dc.w	0	;Number of bitmaps


L_BMaps=2			;Number of bitmaps
L_BMapWid=80			;Width of one bitmap
L_Width=l_BMaps*l_BMapWid	;Width for line routine
L_YTableHeight=256		;Max Y cordinate

l_TablesForm:
	movem.l	d0-d1/a0,-(sp)

	lea	L_YTable,a0
	move.l	#L_YTableHeight,d0
	moveq	#0,d1
l_YTableLoop:	
	move.w	d1,(a0)+
	addi.w	#L_Width,d1
	dbra	d0,L_YTableLoop

	lea	L_SizeTable,a0
	move.l	#320,d0
	moveq	#0,d1
l_STableLoop:
	move.l	d1,d2
	lsl.w	#$0006,d2	
	add.w	#$0042,d2
	move.w	d2,(a0)+
	addi.l	#1,d1
	dbra	d0,l_STableLoop

	movem.l	(sp)+,d0-d1/a0
	rts


Blitter_Fill_Cube:
	move.l	a0,-(sp)
	move.l	WorkPlane(pc),a0
	lea	$13b2(a0),a0
BFC_Wait_Blitter:
	btst	#$0006,$0002(a6)
	bne.s	BFC_Wait_Blitter
	move.l	#$09f0001a,$0040(a6)
	move.l	#$ffffffff,$0044(a6)
	move.l	a0,$0050(a6)
	move.l	a0,$0054(a6)
	move.l	#$004c004c,$0064(a6)
	move.w	#$1002,$0058(a6)
	move.l	(sp)+,a0
	rts


Cube_Copy:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Workplane,a0
	lea	$13fe(a0),a0
	move.l	a0,a1
	subq.l	#$04,a1		;Source
CC_Wait_Blitter:
	btst	#6,$2(a6)
	bne.s	CC_Wait_Blitter
	move.l	#$09f00002,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$00040004,$64(a6)
	move.l	a1,$50(a6)
	move.l	a0,$54(a6)
	move.w	#$1026,$58(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts


Clear_Cube:
	move.l	a0,-(sp)
	move.l	Workplane,a0
Clear_Wait_Blitter:
	btst	#6,$2(a6)
	bne.s	Clear_Wait_Blitter
	move.l	#$01000000,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$004c004c,$64(a6)
	move.l	a0,$54(a6)
	move.w	#$1002,$58(a6)
	move.l	(sp)+,a0
	rts


Draw3D_SwapBuffers:
	movem.l	d0/a0-a1,-(sp)
	lea	Workplane(pc),a0
	lea	Showplane(pc),a1
	move.l	(a0),d0
	move.l	(a1),(a0)
	move.l	d0,(a1)
	movem.l	(sp)+,d0/a0-a1
	rts


Draw_Object_Test:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	D3D_Object(pc),a0		;Object Data in a0
	move.l	$14(a0),a1			;Object Rotated Dots in a1
	move.l	(a0),a0				;Object Poligon Data in a0
	lea	DOT_Line_Area,a2		;Line Area in a2
	lea	DOT_Clipped,a3			;Clipped Line Area in a3
	bra.s	DOT_Next_Poligon		;Jump to first Poligon Test
DOT_Poligon_Start:
	addq.l	#$04,a0
DOT_Next_Poligon:
	move.l	(a0)+,d4			;Color,Flag in d4
	move.l	(a0)+,d5			;0Dot,1Dot in d5
	move.l	(a1,d5.w),d1			;X1,Y1 in d1
	swap	d5				;Get 0Dot Offset
	move.l	(a1,d5.w),d0			;X0,Y1 in d0
	move.w	(a0)+,d5			;Get 2Dot Offset
	move.l	(a1,d5.w),d2			;X2,Y2 in d2
	sub.w	d0,d1				;(X1-X0) in d1.w
	sub.w	d0,d2				;(X2-X0) in d2.w
	move.w	d1,d3				;(X1-X0) in d3.w
	move.w	d2,d5				;(X2-X0) in d5.w
	swap	d0				;Get X0
	swap	d1				;Get X1
	swap	d2				;Get X2
	sub.w	d0,d1				;(Y1-Y0) in d1
	sub.w	d0,d2				;(Y2-Y0) in d2
	muls	d2,d3				;(Y2-Y0)*(X1-X0) in d3
	muls	d1,d5				;(X2-X0)*(Y1-Y0) in d5
	sub.l	d5,d3				;(Y2-Y0)*(X1-X0)+(X2-X0)*(Y1-Y0) in d4
	blt.s	DOT_Poligon_Visible
DOT_Poligon_Invisible:
	cmp.w	#$ffff,(a0)			;Test if Object End
	beq.w	DOT_End				;It is Object End
	cmp.w	#$aaaa,(a0)+			;Test if Poligon End
	bne.s	DOT_Poligon_Invisible		;Not End Search Poligon End
	bra.s	DOT_Next_Poligon		;Do Next Poligon
DOT_Poligon_Visible:
	swap	d4				;Color in d4.w
	subq.l	#$06,a0				;Address of first Offset
DOT_Next_Line:
	move.w	(a0)+,d5			;Offset in d5
	movem.w	$00(a1,d5.w),d0/d1		;X0,Y0 in d0,d1
	move.w	(a0),d5				;Next Offset in d5
	movem.w	$00(a1,d5.w),d2/d3		;X1,Y1 in d2,d3

Clipping:
	move.w	#Up,d5			;Up in d5
	cmp.w	d5,d1			;Test Y0 on Up
	bge.s	Cl_X0_Test_Left		;Y0 is Ok on Up Edge
	cmp.w	d5,d3			;Test Y1 on Up
	blt.w	Cl_Line_Out		;Line is out of Screen
	move.w	d2,d6			;X1 in d6
	sub.w	d0,d6			;(X1-X0) in d6
	sub.w	d1,d5			;(Up-Y0) in d5
	muls	d6,d5			;(X1-X0)*(Up-Y0) in d5
	move.w	d3,d6			;Y1 in d6
	sub.w	d1,d6			;(Y1-Y0) in d6
	divs	d6,d5			;(X1-X0)*(Up-Y0)/(Y1-Y0) in d5
	add.w	d5,d0			;X0New=(X1-X0)*(Up-Y0)/(Y1-Y0)+X0 in d0
	move.w	#Up,d1			;Y0=Up
Cl_X0_Test_Left:
	move.w	#Left,d5		;Left in d5
	cmp.w	d5,d0			;Test X0 on Left
	bge.s	Cl_Y0_Test_Down		;X0 is Ok on Left Edge
	cmp.w	d5,d2			;Test X1 on Left
	blt.w	Cl_Line_Out		;Line is out of Screen
	move.w	d3,d6			;Y1 in d6
	sub.w	d1,d6			;(Y1-Y0) in d6
	sub.w	d0,d5			;(Left-X0) in d5
	muls	d6,d5			;(Y1-Y0)*(Left-X0) in d5
	move.w	d2,d6			;X1 in d6
	sub.w	d0,d6			;(X1-X0) in d6
	divs	d6,d5			;(Y1-Y0)*(Left-X0)/(X1-X0) in d5
	add.w	d5,d1			;Y0New=(Y1-Y0)*(Left-X0)/(X1-X0)+Y0 in d1
	move.w	#Left,d0		;X0=Left
Cl_Y0_Test_Down:
	move.w	#Down,d5		;Down in d5
	cmp.w	d5,d1			;Test Y0 on Down
	ble.s	Cl_X0_Test_Right	;Y0 is Ok on Down Edge
	cmp.w	d5,d3			;Test Y1 on Down
	bgt.w	Cl_Line_Out		;Line is out of Screen
	move.w	d2,d6			;X1 in d6
	sub.w	d0,d6			;(X1-X0) in d6
	sub.w	d1,d5			;(Down-Y0) in d5
	muls	d6,d5			;(X1-X0)*(Down-Y0) in d5
	move.w	d3,d6			;Y1 in d6
	sub.w	d1,d6			;(Y1-Y0) in d6
	divs	d6,d5			;(X1-X0)*(Down-Y0)/(Y1-Y0) in d5
	add.w	d5,d0			;X0New=(X1-X0)*(Down-Y0)/(Y1-Y0)+X0 in d0
	move.w	#Down,d1		;Y0=Down
Cl_X0_Test_Right:
	move.w	#Right,d5		;Right in d5
	cmp.w	d5,d0			;Test X0 on Right
	ble.s	Cl_Y1_Test_Up		;X0 is Ok on Right
	cmp.w	d5,d2			;Test X1 on Right
	bgt.s	Cl_Line_Out_Right	;Line is out of Screen on Right
	move.w	d4,(a3)+		;Color of Clipped line in Area
	move.w	d1,(a3)+		;Y0 of Clipped Line in Area 
	move.w	d3,d6			;Y1 in d6
	sub.w	d1,d6			;(Y1-Y0) in d6
	sub.w	d0,d5			;(Right-X0) in d5
	muls	d6,d5			;(Y1-Y0)*(Right-X0) in d5
	move.w	d2,d6			;X1 in d6
	sub.w	d0,d6			;(X1-X0) in d6
	divs	d6,d5			;(Y1-Y0)*(Right-X0)/(X1-X0) in d5
	add.w	d5,d1			;Y0New=(Y1-Y0)*(Right-X0)/(X1-X0)+Y0 in d1
	move.w	#Right,d0		;X0=Right
	cmp.w	#Down,d1		;Test Clipped Y0 on Down
	ble.s	Cl_X0_Y0Down_Ok
	move.w	#Down,(a3)+
	bra.s	Cl_Y1_Test_Up		;Skip Line Out Right
Cl_X0_Y0Down_Ok:
	cmp.w	#Up,d1			;Test Clipped Y0 on Up
	bge.s	Cl_X0_Y0Up_Ok
	move.w	#Up,(a3)+
	bra.s	Cl_Y1_Test_Up		;Skip Line Out Right
Cl_X0_Y0Up_Ok:
	move.w	d1,(a3)+		;Y1 of Clipped Line in Area
	bra.s	Cl_Y1_Test_Up		;Skip Line Out Right

Cl_Line_Out_Right:
	move.w	d4,(a3)+		;Color of Line out in Clipped Area
	move.w	d1,(a3)+		;Y0 of Line out in Clipped Area
	cmp.w	#Up,d3			;Test Y1 on Up
	bge.s	ClLOR_Test_Y1_Down	;Y1 is Ok on Up Edge
	move.w	#Up,(a3)+		;Up in Clipped Area
	bra.w	Cl_Line_Out		;Line is out
ClLOR_Test_Y1_Down:
	cmp.w	#Down,d3		;Test Y1 on Down
	ble.s	ClLOR_Test_End		;Y1 is Ok on Down Edge
	move.w	#Down,(a3)+		;Down in Clipped Area
	bra.w	Cl_Line_Out		;Line is out
ClLOR_Test_End:
	move.w	d3,(a3)+		;Y1 in Line Clipped Area
	bra.w	Cl_Line_Out		;Line in out

Cl_Y1_Test_Up:
	move.w	#Up,d5			;Up in d5
	cmp.w	d5,d3			;Test Y1 on Up
	bge.s	Cl_X1_Test_Left		;Y1 is Ok on Up
	cmp.w	d5,d1
	blt.w	Cl_Line_Out
	move.w	d2,d6			;X1 in d6
	sub.w	d0,d6			;(X1-X0) in d6
	sub.w	d3,d5			;(Up-Y1) in d5
	muls	d6,d5			;(X1-X0)*(Up-Y1) in d5
	move.w	d3,d6			;Y1 in d6
	sub.w	d1,d6			;(Y1-Y0) in d6
	divs	d6,d5			;(X1-X0)*(Up-Y1)/(Y1-Y0) in d5
	add.w	d5,d2			;X1New=(X1-X0)*(Up-Y1)/(Y1-Y0)+X1 in d2
	move.w	#Up,d3			;Y1=Up
Cl_X1_Test_Left:
	move.w	#Left,d5		;Left in d5
	cmp.w	d5,d2			;Test X1 on Left
	bge.s	Cl_Y1_Test_Down		;X1 is Ok on Left
	cmp.w	d5,d0
	blt.s	Cl_Line_Out
	move.w	d3,d6			;Y1 in d6
	sub.w	d1,d6			;(Y1-Y0) in d6
	sub.w	d2,d5			;(Left-X1) in d5
	muls	d6,d5			;(Y1-Y0)*(Left-X1) in d5
	move.w	d2,d6			;X1 in d6
	sub.w	d0,d6			;(X1-X0) in d6
	divs	d6,d5			;(Y1-Y0)*(Left-X1)/(X1-X0) in d5
	add.w	d5,d3			;Y1New=(Y1-Y0)*(Left-X1)/(X1-X0)+Y1 in d3
	move.w	#Left,d2		;X1=Left
Cl_Y1_Test_Down:
	move.w	#Down,d5		;Down in d5
	cmp.w	d5,d3			;Test Y1 on Down
	ble.s	Cl_X1_Test_Right	;Y1 is Ok on Down
	cmp.w	d5,d1
	bgt.s	Cl_Line_Out
	move.w	d2,d6			;X1 in d6
	sub.w	d0,d6			;(X1-X0) in d6
	sub.w	d3,d5			;(Down-Y1) in d5
	muls	d6,d5			;(X1-X0)*(Down-Y1) in d5
	move.w	d3,d6			;Y1 in d6
	sub.w	d1,d6			;(Y1-Y0) in d6
	divs	d6,d5			;(X1-X0)*(Down-Y1)/(Y1-Y0) in d5
	add.w	d5,d2			;X1New=(X1-X0)*(Down-Y1)/(Y1-Y0)+X1 in d2
	move.w	#Down,d3		;Y1=Down
Cl_X1_Test_Right:
	move.w	#Right,d5		;Right in d5
	cmp.w	d5,d2			;Test X1 on Right
	ble.s	Clipping_End		;X1 is Ok on Right
	cmp.w	d5,d0
	bgt.s	Cl_Line_Out
	move.w	d4,(a3)+		;Color of Clipped Line in Area
	move.w	d3,(a3)+		;Y0 of Clipped Line in Area
	move.w	d3,d6			;Y1 in d6
	sub.w	d1,d6			;(Y1-Y0) in d6
	sub.w	d2,d5			;(Right-X1) in d5
	muls	d6,d5			;(Y1-Y0)*(Right-X1) in d5
	move.w	d2,d6			;X1 in d6
	sub.w	d0,d6			;(X1-X0) in d6
	divs	d6,d5			;(Y1-Y0)*(Right-X1)/(X1-X0) in d5
	add.w	d5,d3			;Y1New=(Y1-Y0)*(Right-X1)/(X1-X0)+Y1 in d3
	move.w	#Right,d2		;X1=Right
	cmp.w	#Down,d3		;Test Clipped Y1 on Down
	ble.s	Cl_X1_Y1Down_Ok
	move.w	#Down,(a3)+
	bra.s	Clipping_End
Cl_X1_Y1Down_Ok:
	cmp.w	#Up,d3			;Test Clipped Y1 on Up
	bge.s	Cl_X1_Y1Up_Ok
	move.w	#Up,(a3)+
	bra.s	Clipping_End
Cl_X1_Y1Up_Ok:
	move.w	d3,(a3)+		;Y1 of Clipped Line in Area
Clipping_End:
	move.w	d4,(a2)+			;Color in Line Area
	move.w	d0,(a2)+			;X0 in Line Area
	move.w	d1,(a2)+			;Y0 in Line Area
	move.w	d2,(a2)+			;X1 in Line Area
	move.w	d3,(a2)+			;Y1 in Line Area
Cl_Line_Out:
	cmp.w	#$aaaa,$0002(a0)		;Test if Poligon End
	beq.w	DOT_Poligon_Start		;It is Poligon End	
	cmp.w	#$ffff,$0002(a0)		;Test if Object End
	bne.w	DOT_Next_Line			;It is Not Poligon End
DOT_End:
	move.w	#$aaaa,(a2)			;Mark End of Line Area
	move.w	#$aaaa,(a3)			;Mark End of Clipped Area
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Draw_Object:
	movem.l	d0-d7/a0-a5,-(sp)
	lea	$dff000,a6		;Custom Address in a6
	move.l	WorkPlane(pc),a0	;Workplane in a0
	lea	L_YTable,a1		;L_YTable in a1
	lea	L_SizeTable,a2		;L_SizeTable in a2
	lea	DOT_Line_Area,a3	;Line Area in a3
DO_Wait_Blitter:
	btst	#$06,$02(a6)
	bne.s	DO_Wait_Blitter
	move.l	#$ffff8000,$72(a6)	;BLTBDAT,BLTADAT
	move.l	#$ffffffff,$44(a6)	;BLTAFWM,BLTALWM
	move.w	#L_Width,$60(a6)	;BLTCMOD
	move.w	#L_Width,$66(a6)	;BLTDMOD
DO_Next_Line:
	cmp.w	#$aaaa,(a3)		;Test if end
	beq.s	DO_Draw_Clipped
	move.w	(a3)+,d4		;Get Color in d4
	movem.w	(a3)+,d0-d3
	bsr.s	Line
	bra.s	DO_Next_Line
DO_Draw_Clipped:
	lea	DOT_Clipped,a3
DO_Next_Clipped_Line:
	cmp.w	#$aaaa,(a3)
	beq.s	DO_End
	move.w	(a3)+,d4
	move.w	(a3)+,d1
	move.w	(a3)+,d3
	bsr.w	Vertical_Line
	bra.s	DO_Next_Clipped_Line
DO_End:	movem.l	(sp)+,d0-d7/a0-a5
	rts

Line:	movem.l	d2-d7/a0-a3,-(sp)
	cmp.w	d1,d3			;Compare y0 and y1
	beq	L_End			;if y0=y1 then no line
	bgt.s	L_NoChange		;if y1>y0 then Cords ok !!
	exg	d2,d0			;Exchange x0 with x1
	exg	d3,d1			;Exchange y0 with y1
L_NoChange:
	subq	#1,d3			;y1=y1-1
	sub.w	d1,d3			;Calculate dy=y1-y0
	sub.w	d0,d2			;Calculate dx=x1-x0
	bmi.s	L_dxNeg
	moveq	#19,d5
	cmp.w	d2,d3
	blt.s	L_Finish
	exg	d2,d3
	moveq	#3,d5
	bra.s	L_Finish
L_dxNeg:
	neg	d2
	moveq	#23,d5
	cmp.w	d2,d3
	blt.s	L_Finish
	exg	d2,d3
	moveq	#11,d5
L_Finish:
	add.w	d1,d1		;y1 * 4 calc offset
	move.w	0(a1,d1.w),d1	;Get y offset from table
	lea	0(a0,d1.w),a3	;Calc Address of pixel row
	move.w	d0,d1		;x0 in d1
	lsr.w	#4,d1		;x0 / 16
	add.w	d1,d1		;x0 * 2 For Address of First Pixel
	lea	0(a3,d1.w),a3	;Adress of First Pixel in a2
	andi.w	#$000f,d0	;Get Shift in d0
	ror.w	#$0004,d0	;place Shift value
	ori.w	#$0b4a,d0	;b4a-or mode and bca-normal mode
	add.w	d3,d3		;dy*2 This is for BLTBMOD
	move.w	d3,d6		;dx in d6
	sub.w	d2,d6		;d6=2dy-dx This is for BLTAPTL
	bpl.s	L_NoSignFlag	;test for sign flag
	ori.w	#$0040,d5
L_NoSignFlag:
	move.w	d6,d1		;2dy-dx in d1
	sub.w	d2,d1		;d1=2dy-2dx This is for BLTAMOD
	add.w	d2,d2		;Add 1 to Height and 1 to width
	move.w	(a2,d2.w),d2	;Set BLTSIZE in d2

	btst	#0,d4			;Test for 0 Bit Plane
	beq.s	L_NothingOn0BM		;if 0 then go to next Bit Map
L_Waitblit0:
	btst	#6,$2(a6)
	bne.s	L_Waitblit0
	move.w	d3,$62(a6)		;BLTBMOD 2dy
	move.w	d1,$64(a6)		;BLTAMOD 2dy-2dx
	move.w	d6,$52(a6)		;BLTAPTL 2dy-dx
	move.w	d0,$40(a6)		;BLTCON0
	move.w	d5,$42(a6)		;BLTCON1
	move.l	a3,$48(a6)		;BLTCPTH,BLTCPTL
	move.l	a3,$54(a6)		;BLTDPTH,BLTDPTL
	move.w	d2,$58(a6)		;BLTSIZE
L_NothingOn0BM:
	lea	L_BMapWid(a3),a3	;Adress of next Bit Map in a2
	btst	#1,d4			;Test for 1 Bit Plane
	beq.s	L_End			;if 0 then go to next Bit Map
L_WaitBlit1:
	btst	#6,$2(a6)
	bne.s	L_WaitBlit1
	move.w	d3,$62(a6)		;BLTBMOD 2dy
	move.w	d1,$64(a6)		;BLTAMOD 2dy-2dx
	move.w	d6,$52(a6)		;BLTAPTL 2dy-dx
	move.w	d0,$40(a6)		;BLTCON0
	move.w	d5,$42(a6)		;BLTCON1
	move.l	a3,$48(a6)		;BLTCPTH,BLTCPTL
	move.l	a3,$54(a6)		;BLTDPTH,BLTDPTL
	move.w	d2,$58(a6)		;BLTSIZE
L_End:	movem.l	(sp)+,d2-d7/a0-a3
	rts

Vertical_Line:
	movem.l	d2-d7/a0-a3,-(sp)
	cmp.w	d1,d3
	beq.s	VL_End
	bgt.s	VL_NoChange
	exg	d1,d3
VL_NoChange:
	subq.w	#$01,d3
	sub.w	d1,d3
	move.l	#$fb4a0043,d5
	add.w	d1,d1
	move.w	$00(a1,d1.w),d1
	lea	$02(a0,d1.w),a3
	move.w	d3,d1			;dx in d1
	neg.w	d1
	add.w	d3,d3
	move.w	$00(a2,d3.w),d2		;BLTSIZE in d2
	neg.w	d3
	ext.l	d3

	btst	#0,d4			;Test for 0 Bit Plane
	beq.s	VL_NothingOn0BM		;if 0 then go to next Bit Map
VL_Waitblit0:
	btst	#6,$2(a6)
	bne.s	VL_Waitblit0
	move.l	d3,$62(a6)		;BLTBMOD 2dy,BLTAMOD 2dy-2dx
	move.w	d1,$52(a6)		;BLTAPTL 2dy-dx
	move.l	d5,$40(a6)		;BLTCON0,BLTCON1
	move.l	a3,$48(a6)		;BLTCPTH,BLTCPTL
	move.l	a3,$54(a6)		;BLTDPTH,BLTDPTL
	move.w	d2,$58(a6)		;BLTSIZE
VL_NothingOn0BM:
	lea	L_BMapWid(a3),a3	;Adress of next Bit Map in a2
	btst	#1,d4			;Test for 1 Bit Plane
	beq.s	VL_End			;if 0 then go to next Bit Map
VL_WaitBlit1:
	btst	#6,$2(a6)
	bne.s	VL_WaitBlit1
	move.l	d3,$62(a6)		;BLTBMOD 2dy,BLTAMOD 2dy-2dx
	move.w	d1,$52(a6)		;BLTAPTL 2dy-dx
	move.l	d5,$40(a6)		;BLTCON0,BLTCON1
	move.l	a3,$48(a6)		;BLTCPTH,BLTCPTL
	move.l	a3,$54(a6)		;BLTDPTH,BLTDPTL
	move.w	d2,$58(a6)		;BLTSIZE
VL_End:	movem.l	(sp)+,d2-d7/a0-a3
	rts

D3D_Object:	dc.l	0
Workplane:	dc.l	0
Showplane:	dc.l	0

;***************************************************
;Fast BSS Data
;***************************************************
;
;	Section	"Draw3D BSS Data",BSS_F
;
;	CNOP	0,8

DOT_Line_Area:	ds.w	1024
DOT_Clipped:	ds.w	512

L_YTable:	ds.w	257
L_SizeTable:	ds.w	321
