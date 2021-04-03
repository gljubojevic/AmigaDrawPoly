	movem.l	d0-d7/a0-a6,-(sp)
	lea	$dff000,a6
	bsr.w	SetWASPlane
	bsr.w	Write_CopperList
	lea	CopperList(pc),a0
	move.l	a0,$80(a6)
	bsr	l_TablesForm
	lea	OldIntena(pc),a0
	lea	Level3IntSave(pc),a1
	lea	CopperInterrupt(pc),a2
	move.w 	$1c(a6),(a0)
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$9c(a6)
	move.l	$6c,(a1)
	move.l	a2,$6c
	lea	Cube(pc),a0
	move.l	a0,Curent_Object
	bsr	RotateXYZ
	bsr	Draw_Object_Test
	move.w	#$c010,$9a(a6)

test:	btst	#$6,$bfe001
	bne.s	test

	lea	OldIntena(pc),a0
	lea	Level3IntSave(pc),a1
	ori.w	#$8000,(a0)
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$9c(a6)
	move.l	(a1),$6c
	move.w	(a0),$9a(a6)
	move.l	$4,a5
	move.l	$9c(a5),a5
	move.l	38(a5),$80(a6)			;old clist
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Write_CopperList:
	movem.l	d0-d1/a0-a1,-(sp)
	lea	Colors,a0
	lea	Cl_BP+2,a1
	move.l	Workplane(pc),d0	;First BP in d0
	move.l	d0,d2			;First BP in d2
	add.l	#$28,d2			;Second BP in d2
	move.l	d0,d1			;First BP Lo in d1
	swap	d0			;First BP Hi in d0
	move.l	d2,d3			;Second BP Lo in d3
	swap	d2			;Second BP Hi in d2
	moveq	#$0f,d4
WCL_Next_Row:
	move.w	d0,(a1)+
	addq.l	#$02,a1
	move.w	d1,(a1)+
	addq.l	#$02,a1
	move.w	d2,(a1)+
	addq.l	#$02,a1
	move.w	d3,(a1)+

	addq.l	#$02,a1
	move.w	(a0)+,(a1)+
	addq.l	#$02,a1
	move.w	(a0)+,(a1)+
	addq.l	#$02,a1
	move.w	(a0)+,(a1)+
	addq.l	#$02,a1
	move.w	(a0)+,(a1)+
	lea	$000a(a1),a1
	dbf	d4,WCL_Next_Row

	lea	Cl_Mod(pc),a1
	move.w	#$0028,$0002(a1)
	move.w	#$0028,$0006(a1)
	lea	Cl_Con(pc),a1
	move.w	#$2200,$0002(a1)
	move.w	#$0000,$0006(a1)
	move.w	#$0000,$000a(a1)
	movem.l	(sp)+,d0-d1/a0-a1
	rts

SetWASPlane:
	movem.l	a0-a2,-(sp)
	lea	Workplane(pc),a0
	lea	Showplane(pc),a1
	lea	VideoMemory00(pc),a2
	move.l	a2,(a0)
	lea	$500(a2),a2
	move.l	a2,(a1)
	movem.l	(sp)+,a0-a2
	rts

L_BMaps=2			;Mumber of bitmaps
L_BMapWid=40			;Width of one bitmap
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
	lea	$4d8(a0),a0
BFC_Wait_Blitter:
	btst	#$0006,$0002(a6)
	bne.s	BFC_Wait_Blitter
	move.l	#$09f0001a,$0040(a6)
	move.l	#$ffffffff,$0044(a6)
	move.l	a0,$0050(a6)
	move.l	a0,$0054(a6)
	move.l	#$00260026,$0064(a6)
	move.w	#$801,$0058(a6)
	move.l	(sp)+,a0
	rts

	rem
Cube_Copy:
	movem.l	a0-a1,-(sp)
	move.l	Workplane,a0		;Workplane in a0
	move.l	a0,a1
	addq.l	#$02,a1			;Destination in a1
CC_Wait_Blitter:
	btst	#6,$2(a6)
	bne.s	CC_Wait_Blitter
	move.l	#$09f00000,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$00260026,$64(a6)
	move.l	a0,$50(a6)
	move.l	a1,$54(a6)
	move.w	#$0801,$58(a6)
	movem.l	(sp)+,a0-a1
	rts
	erem

Cube_Copy:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Workplane,a0
	lea	$4fe(a0),a0
	move.l	a0,a1
	subq.l	#$02,a1		;Source
CC_Wait_Blitter:
	btst	#6,$2(a6)
	bne.s	CC_Wait_Blitter
	move.l	#$09f00002,$40(a6)
	move.l	#$ffffffff,$44(a6)
	move.l	#$00020002,$64(a6)
	move.l	a1,$50(a6)
	move.l	a0,$54(a6)
	move.w	#$0813,$58(a6)
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
	move.l	#$00260026,$64(a6)
	move.l	a0,$54(a6)
	move.w	#$0801,$58(a6)
	move.l	(sp)+,a0
	rts


CopperInterrupt:
	movem.l	d0-d7/a0-a6,-(sp)
;	move.w	#$0f00,$180(a6)

	bsr	Clear_Cube
	bsr	Draw_Object
	bsr	Blitter_Fill_Cube
	bsr	Cube_Copy
	bsr	Write_CopperList
	lea	Workplane(pc),a0
	lea	ShowPlane(pc),a1
	move.l	(a0),d0
	move.l	(a1),d1
	move.l	d0,(a1)
	move.l	d1,(a0)

	move.l	Curent_Object(pc),a0
	add.w	#$0060,$04(a0)
	add.w	#$0020,$06(a0)
	add.w	#$0010,$08(a0)

	bsr	RotateXYZ
	bsr	Draw_Object_Test

;	move.w	#$0000,$180(a6)
CI_End:	movem.l	(sp)+,d0-d7/a0-a6
	move.w	#$0010,$9c(a6)
	rte

Up	=	0
Left	=	0
Down	=	15
Right	=	15

Draw_Object_Test:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Curent_Object(pc),a0		;Object Data in a0
	move.l	$14(a0),a1			;Object Rotated Dots in a1
	move.l	(a0),a0				;Object Poligon Data in a0
	lea	DOT_Line_Area(pc),a2		;Line Area in a2
	lea	DOT_Clipped(pc),a3		;Clipped Line Area in a3
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
	lea	L_YTable(pc),a1		;L_YTable in a1
	lea	L_SizeTable(pc),a2	;L_SizeTable in a2
	lea	DOT_Line_Area(pc),a3	;Line Area in a3
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
	lea	DOT_Clipped(pc),a3
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
	lea	$00(a0,d1.w),a3
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

RotateXYZ:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a7,Stack_Save			;Save Stack pointer
	move.l	Curent_Object(pc),a0		;Adr. of Obj. data in a0
	addq.l	#$04,a0				;Get Address of Angles in a0
	lea	R_CalculationsBefore(pc),a1	;Adr. of Calc. Field in a1
	lea	R_SinCosTable(pc),a2		;Adr. of Sin & Cos Table in a2
	movem.w	(a0),d0-d2		;Put Curent Alpha,Beta & Gama in d0-d2
	move.w	#$1ffe,d3		;Get mask in d3
	and.w	d3,d0			;Alpha Ok!
	and.w	d3,d1			;Beta Ok!
	and.w	d3,d2			;Gama Ok!
	movem.w	d0-d2,(a0)		;Put Curent Alpha,Beta & Gama in table.
	addq.l	#$06,a0			;This part of table is finished
	move.w	(a2,d0.w),d3		;Get Sin(Alpha) in d3
	move.w	(a2,d1.w),d4		;Get Sin(Beta) in d4
	move.w	(a2,d2.w),d5		;Get Sin(Gama) in d5
	lea	$800(a2),a2		;Address of Cos table in a3
	move.w	(a2,d0.w),d0		;Get Cos(Alpha) in d0
	move.w	(a2,d1.w),d1		;Get Cos(Beta) in d1
	move.w	(a2,d2.w),d2		;Get Cos(Gama) in d2
	move.w	d1,d6			;Cos(Beta) in d6
	muls	d2,d6			;Cos(Beta)Cos(Gama) in d6
	add.l	d6,d6
	swap	d6
	move.w	d6,$00(a1)		;A Part Finished
	move.w	d1,d6			;Cos(Beta) in d6
	muls	d5,d6			;Cos(Beta)Sin(Gama) in d6
	add.l	d6,d6
	swap	d6
	neg.w	d6			;-Cos(Beta)Sin(Gama) in d6
	move.w	d6,$02(a1)		;B Part Finished
	move.w	d4,$04(a1)		;C Part Finished
	move.w	d1,d6			;Cos(Beta) in d6
	muls	d3,d6			;Sin(Alpha)Cos(Beta) in d6
	add.l	d6,d6
	swap	d6
	neg.w	d6			;-Sin(Alpha)Cos(Beta) in d6
	move.w	d6,$0a(a1)		;F Part Finished
	muls	d0,d1			;Cos(Alpha)Cos(Beta) in d1
	add.l	d1,d1
	swap	d1
	move.w	d1,$10(a1)		;I Part Finished
	move.w	d0,d6			;Cos(Alpha) in d6
	move.w	d3,d7			;Sin(Alpha) in d7
	muls	d5,d0			;Cos(Alpha)Sin(Gama) in d0
	add.l	d0,d0
	swap	d0
	muls	d2,d6			;Cos(Alpha)Cos(Gama) in d6
	add.l	d6,d6
	swap	d6
	muls	d5,d3			;Sin(Alpha)Sin(Gama) in d3
	add.l	d3,d3
	swap	d3
	muls	d2,d7			;Sin(Alpha)Cos(Gama) in d7
	add.l	d7,d7
	swap	d7
	move.w	d7,d1			;Sin(Alpha)Cos(Gama) in d1
	muls	d4,d1			;Sin(Alpha)Sin(Beta)Cos(Gama) in d1
	add.l	d1,d1
	swap	d1
	add.w	d0,d1			;Cos(Alpha)Sin(Gama)+Sin(Alpha)Sin(Beta)Cos(Gama) in d1
	move.w	d1,$06(a1)		;D Part Finished
	move.w	d3,d1			;Sin(Alpha)Sin(Gama) in d1
	muls	d4,d1			;Sin(Alpha)Sin(Beta)Sin(Gama) in d1
	add.l	d1,d1
	swap	d1
	neg.w	d1			;-Sin(Alpha)Sin(Beta)Sin(Gama) in d1
	add.w	d6,d1			;Cos(Alpha)Cos(Gama)-Sin(Alpha)Sin(Beta)Sin(Gama) in d1
	move.w	d1,$08(a1)		;E Part Finished
	muls	d4,d6			;Cos(Alpha)Sin(Beta)Cos(Gama) in d6
	add.l	d6,d6
	swap	d6
	neg.w	d6			;-Cos(Alpha)Sin(Beta)Cos(Gama) in d6
	add.w	d3,d6			;Sin(Alpha)Sin(Gama)-Cos(Alpha)Sin(Beta)Cos(Gama) in d6
	move.w	d6,$0c(a1)		;G Part Finished
	muls	d4,d0			;Cos(Alpha)Sin(Beta)Sin(Gama) in d0
	add.l	d0,d0
	swap	d0
	add.w	d7,d0			;Sin(Alpha)Cos(Gama)+Cos(Alpha)Sin(Beta)Sin(Gama) in d0
	move.w	d0,$0e(a1)		;H Part Finished
	movem.w	(a0)+,a3/a4/a5		;TX in a3  TY in a4  TZ in a5
	move.l	$0004(a0),a2		;Rotated Dots Area in a2
	move.l	(a0),a0			;Dots Area in a0
	move.w	#7,a6			;X Screen Center in a6
	move.w	#7,a7			;Y Screen Center in a7
R_RotateNextDot:
	movem.w	(a0)+,d3-d5		;X0-->d3.w  Y0-->d4.w  Z0-->d5.w
	movem.w	(a1)+,d0-d2		;A --)d0.w  B -->d1.w  C -->d2.w
	muls	d3,d0			;d0=A*X0
	muls	d4,d1			;d1=B*Y0
	muls	d5,d2			;d2=C*Z0
	add.l	d1,d0			;d0=A*X0+B*Y0
	add.l	d2,d0			;d0=A*X0+B*Y0+C*Z0
	swap	d0			;X/32768
	add.w	a3,d0			;X+TX
	move.w	d0,d6			;X in d6 ****
	movem.w	(a1)+,d0-d2		;D -->d0.w  E -->d1.w  F -->d2.w
	muls	d3,d0			;D0=D*X0
	muls	d4,d1			;D1=E*Y0
	muls	d5,d2			;d2=F*Z0
	add.l	d0,d1			;D0=D*X0+E*Y0
	add.l	d2,d1			;D0=D*X0+E*Y0+F*Z0
	swap	d1			;Y/32768
	add.w	a4,d1			;Y+TY
	move.w	d1,d7			;Y in d7 ****
	movem.w	(a1)+,d0-d2		;G -->d0.w  H -->d1.w  I -->d2.w
	muls	d3,d0			;G*X0
	muls	d4,d1			;H*Y0
	muls	d5,d2			;I*Z0
	add.l	d1,d2			;d2=H*Y0+I*Z0
	add.l	d0,d2			;d2=G*X0+H*Y0+I*Z0
	swap	d2			;Z/32768
	add.w	a5,d2			;Z+TZ
	move.w	#128,d3			;Zaslon in d3
	add.w	d3,d2			;Z+Zaslon in d2
	muls	d3,d6			;Zaslon*X
	muls	d3,d7			;Zaslon*Y
	divs	d2,d6			;(Zaslon*X)/(Z+Zaslon)
	divs	d2,d7			;(Zaslon*Y)/(Z+Zaslon)
	add.w	a6,d6			;
	add.w	a7,d7			;
	move.w	d6,(a2)+		;X Rotated in Memory
	move.w	d7,(a2)+		;Y Rotared in Memory
;	move.w	d2,(a2)+		;Z Rotated in Memory  !!!!!!
	lea	-$12(a1),a1
	cmp.w	#$ffff,(a0)
	bne.s	R_RotateNextDot
	move.l	Stack_Save,a7
	movem.l	(sp)+,d0-d7/a0-a6
	rts

R_CalculationsBefore:
	dc.w	0	;A  $00(An)
	dc.w	0	;B  $02(An)
	dc.w	0	;C  $04(An)
	dc.w	0	;D  $06(An)
	dc.w	0	;E  $08(An)
	dc.w	0	;F  $0a(An)
	dc.w	0	;G  $0c(An)
	dc.w	0	;H  $0e(An)
	dc.w	0	;I  $10(An)

	AUTO	CS\R_SinCosTable\0\450\5120\32767\0\W1\yy
R_SinCosTable:	blk.w	5120,0

Cube:
	dc.l	Cube_Poligons			;$00
	dc.w	0,0,0				;$04 Alfa,Beta,Gama
	dc.w	0,0,$1000			;$0a TX,TY,TZ
	dc.l	Cube_Dots			;$10
	dc.l	Cube_Rotated_Dots		;$14
Cube_Poligons:
	dc.w	1,0,0*4,1*4,2*4,3*4,0*4,$aaaa
	dc.w	2,0,0*4,4*4,5*4,1*4,0*4,$aaaa
	dc.w	3,0,1*4,5*4,6*4,2*4,1*4,$aaaa
	dc.w	1,0,5*4,4*4,7*4,6*4,5*4,$aaaa
	dc.w	2,0,3*4,2*4,6*4,7*4,3*4,$aaaa
	dc.w	3,0,7*4,4*4,0*4,3*4,7*4,$ffff
Cube_Dots:
	dc.w	-200*2,-200*2,-200*2		;00
	dc.w	200*2,-200*2,-200*2		;01
	dc.w	200*2,200*2,-200*2		;02
	dc.w	-200*2,200*2,-200*2		;03
	dc.w	-200*2,-200*2,200*2		;04
	dc.w	200*2,-200*2,200*2		;05
	dc.w	200*2,200*2,200*2		;06
	dc.w	-200*2,200*2,200*2		;07
	dc.w	$ffff
Cube_Rotated_Dots:
	dc.w	0,0,0				;00
	dc.w	0,0,0				;01
	dc.w	0,0,0				;02
	dc.w	0,0,0				;03
	dc.w	0,0,0				;04
	dc.w	0,0,0				;05
	dc.w	0,0,0				;06
	dc.w	0,0,0				;07
	dc.w	$ffff

Curent_Object:	dc.l	0
OldIntena:	dc.w	0
Level3IntSave:	dc.l	0
Stack_Save:	dc.l	0
Workplane:	dc.l	0
Showplane:	dc.l	0

Colors:	dc.w	$0000,$0000,$0aa0,$0ff0
	dc.w	$0111,$0551,$0aa1,$0ff1
	dc.w	$0222,$0552,$0aa2,$0ff2
	dc.w	$0333,$0553,$0aa3,$0ff3
	dc.w	$0444,$0554,$0aa4,$0ff4
	dc.w	$0555,$0555,$0aa5,$0ff5
	dc.w	$0666,$0556,$0aa6,$0ff6
	dc.w	$0777,$0557,$0aa7,$0ff7
	dc.w	$0888,$0558,$0aa8,$0ff8
	dc.w	$0999,$0559,$0aa9,$0ff9
	dc.w	$0aaa,$055a,$0aaa,$0ffa
	dc.w	$0bbb,$055b,$0aab,$0ffb
	dc.w	$0ccc,$055c,$0aac,$0ffc
	dc.w	$0ddd,$055d,$0aad,$0ffd
	dc.w	$0eee,$055e,$0aae,$0ffe
	dc.w	$0fff,$055f,$0aaf,$0fff

CopperList:
	dc.w	$01fc,$0000
	dc.w	$0180,$0000
	dc.w	$009c,$8010			;INTREQ
	dc.w	$008e,$2c81			;DIWSTRT
	dc.w	$0090,$2cc1			;DIWSTOP
	dc.w	$0092,$0038			;DDFSTRT
	dc.w	$0094,$00d0			;DDFSTOP
Cl_Spr:	dc.w	$0120,$0000,$0122,$0000		;SPR0PTH,SPR0PTL
	dc.w	$0124,$0000,$0126,$0000		;SPR1PTH,SPR1PTL
	dc.w	$0128,$0000,$012A,$0000		;SPR2PTH,SPR2PTL
	dc.w	$012C,$0000,$012E,$0000		;SPR3PTH,SPR3PTL
	dc.w	$0130,$0000,$0132,$0000		;SPR4PTH,SPR4PTL
	dc.w	$0134,$0000,$0136,$0000		;SPR5PTH,SPR5PTL
	dc.w	$0138,$0000,$013A,$0000		;SPR6PTH,SPR6PTL
	dc.w	$013C,$0000,$013E,$0000		;SPR7PTH,SPR7PTL
Cl_Mod:	dc.w	$0108,$0000			;BPL1MOD
	dc.w	$010a,$0000			;BPL2MOD
Cl_Con:	dc.w	$0100,$0000			;BPLCON0
	dc.w	$0102,$0000			;BPLCON1
	dc.w	$0104,$0000			;BPLCON2

	dc.w	$2c01,$fffe
Cl_BP:	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
Cl_Col:	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$3c01,$fffe
	dc.w	$3c01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$4c01,$fffe
	dc.w	$4c01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$5c01,$fffe
	dc.w	$5c01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$6c01,$fffe
	dc.w	$6c01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$7c01,$fffe
	dc.w	$7c01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$8c01,$fffe
	dc.w	$8c01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$9c01,$fffe
	dc.w	$9c01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$ac01,$fffe
	dc.w	$ac01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$bc01,$fffe
	dc.w	$bc01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$cc01,$fffe
	dc.w	$cc01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$dc01,$fffe
	dc.w	$dc01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$ec01,$fffe
	dc.w	$ec01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$fc01,$fffe
	dc.w	$fc01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$ffe1,$fffe
	dc.w	$0c01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03

	dc.w	$1c01,$fffe
	dc.w	$1c01,$fffe
	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
	dc.w	$00e4,$0000,$00e6,$0000		;BPL1PTH,BPL1PTL
	dc.w	$0180,$0000,$0182,$0000		;COLOR00,COLOR01
	dc.w	$0184,$0000,$0186,$0000		;COLOR02,COLOR03
	dc.w	$ffff,$fffe			;End of Copper List


DOT_Line_Area:	blk.b	2048,0
DOT_Clipped:	blk.b	1024,0
L_YTable:	blk.w	257,0
L_SizeTable:	blk.w	321,0

VideoMemory00:	blk.b	1280,0		;320*16*2 size picture
VideoMemory01:	blk.b	1280,0		;320*16*2 size picture
