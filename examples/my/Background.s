	movem.l	d0-d7/a0-a6,-(sp)
	lea	$dff000,a6
	bsr.w	l_TablesForm
	lea	VideoMemory00,a0
	lea	VideoMemory01,a1
	lea	ShowPlane(pc),a2
	lea	Workplane(pc),a3
	move.l	a0,(a2)
	move.l	a1,(a3)
	bsr.w	Write_CopperList
	lea	CopperList(pc),a0
	move.l	a0,$80(a6)
	move.w	#$0020,$96(a6)

	bsr	Perspektive
	bsr	RotateZ
	
	lea	OldIntena(pc),a0
	lea	Level3IntSave(pc),a1
	lea	CopperInterrupt(pc),a2
	move.w 	$1c(a6),(a0)
	move.w	#$7fff,$9a(a6)
	move.w	#$7fff,$9c(a6)
	move.l	$6c,(a1)
	move.l	a2,$6c
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
	move.w	#$8020,$96(a6)
	move.l	$4,a5
	move.l	$9c(a5),a5
	move.l	38(a5),$80(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Clear_Screen:
	movem.l	a0-a5/d0-d7,-(sp)
CS_Wait_Blitter:
	btst	#$0006,$0002(a6)
	bne.s	CS_Wait_Blitter
	move.l	#$01000000,$0040(a6)
	move.w	#$0000,$0066(a6)
	move.l	Workplane(pc),$0054(a6)
	move.w	#$2254,$0058(a6)
	moveq	#$00,d0
	moveq	#$00,d1
	moveq	#$00,d2
	moveq	#$00,d3
	moveq	#$00,d4
	moveq	#$00,d5
	moveq	#$00,d6
	moveq	#$00,d7
	suba.l	a0,a0
	suba.l	a1,a1
	suba.l	a2,a2
	suba.l	a3,a3
	suba.l	a4,a4
	suba.l	a5,a5
	move.l	WorkPlane(pc),a6
	lea	$2800(a6),a6
	REPT	85
	movem.l	d0-d7/a0-a5,-(a6)
	ENDR
	lea	$dff000,a6
	movem.l	(sp)+,a0-a5/d0-d7
	rts

Blitter_Fill_Screen:
	move.l	a0,-(sp)
	move.l	WorkPlane(pc),a0
	lea	$27fe(a0),a0
BFS_Wait_Blitter:
	btst	#$0006,$0002(a6)
	bne.s	BFS_Wait_Blitter
	move.l	#$09f0001a,$0040(a6)
	move.l	#$ffffffff,$0044(a6)
	move.l	a0,$0050(a6)
	move.l	a0,$0054(a6)
	move.l	#$00000000,$0064(a6)
	move.w	#$4014,$0058(a6)
	move.l	(sp)+,a0
	rts

;* Z - Rotate
;X=X0*Cos(Gama)-Y0*Sin(Gama)
;Y=X0*Sin(Gama)+Y0*Cos(Gama)

RotateZ:
	movem.l	d0-d7/a0-a6,-(sp)
	lea	R_SinCosTable,a0	;Sin Table
	lea	$800(a0),a1		;Cos Table
	move.l	Curent_Object,a2	;Object Address in a2
	movem.w	$4(a2),d3-d5		;Alfa,Beta,Gama in d3,d4,d5
	move.w	#$1ffe,d6
	and.w	d6,d3
	and.w	d6,d4
	and.w	d6,d5
	movem.w	d3-d5,$4(a2)
	move.w	$00(a0,d5.w),d0		;Sin (Gama)
	move.w	$00(a1,d5.w),d1		;Cos (Gama)
	move.w	#160,d2			;Centar X
	move.w	#128,d3			;Centar Y
	lea	Draw_Dots00,a0
	lea	Draw_Dots01,a1
;	move.l	$0010(a2),a0		;Dots in a0
;	move.l	$0014(a2),a1		;Rotated Dots in a1
R_Next_Dot:
	move.w	(a0)+,d4		;X in d4
	move.w	(a0)+,d5		;Y in d5
	move.w	d4,d6			;X in d6
	move.w	d5,d7			;Y in d7
	muls	d0,d6			;X*Sin (Gama) in d6
	muls	d0,d7			;Y*Sin (Gama) in d7
	muls	d1,d4			;X*Cos (Gama) in d4
	muls	d1,d5			;Y*Cos (Gama) in d5
	sub.l	d7,d4			;X=X*Cos (Gama) - Y*Sin (Gama) in d4
	add.l	d6,d5			;Y=X*Sin (Gama) + Y*Cos (Gama) in d5
	swap	d4			;X/32768
	swap	d5			;Y/32768
	add.w	d2,d4
	add.w	d3,d5
	move.w	d4,(a1)+		;Save X Cord in Rotated Dots
	move.w	d5,(a1)+		;Save Y Cord in Rotated Dots
	cmp.w	#$ffff,(a0)		;Test end of dots
	bne.s	R_Next_Dot		;Do ti for Next Dot
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Perspektive:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	Curent_Object,a0
	lea	Draw_Dots00,a1
	movem.w	$000a(a0),d0-d2		;TX,TY,TZ
	move.w	#160,d3			;Centar X
	swap	d3
	move.w	#128,d3			;Centar Y
	swap	d3
	move.l	$0010(a0),a0		;Dots in a0
	move.w	#500,d4			;Zaslon u d4
P_Next_Dot:
	movem.w	(a0)+,d5-d7		;X,Y,Z
	add.w	d0,d5			;X+TX
	add.w	d1,d6			;Y+TY
	add.w	d2,d7			;Z+TZ
	add.w	d4,d7			;Z+Zaslon
	muls	d4,d5			;Zaslon*X
	muls	d4,d6			;Zaslon*Y
	divs	d7,d5			;Zaslon*X/Z+Zaslon
	divs	d7,d6			;Zaslon*Y/Z+Zaslon
;	add.w	d3,d5
;	swap	d3
;	add.w	d3,d6
;	swap	d3
	add.w	d5,d5
	add.w	d6,d6
	move.w	d5,(a1)+
	move.w	d6,(a1)+
	cmp.w	#$ffff,(a0)
	bne.s	P_Next_Dot
	move.w	#$ffff,(a1)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Draw_2D_Object:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	WorkPlane,a0
	lea	L_YTable,a1
	lea	L_SizeTable,a2
	lea	Clipped_Area,a3
	move.l	Curent_Object,a4
	move.l	$0000(a4),a4		;Poligon Data
	lea	Draw_Dots01,a5		;Dots
D2DO_Wait_Blitter:
	btst	#6,$2(a6)
	bne.s	D2DO_Wait_Blitter
	move.l	#$ffff8000,$72(a6)	;BLTBDAT,BLTADAT
	move.l	#$ffffffff,$44(a6)	;BLTAFWM,BLTALWM
	move.w	#L_Width,$60(a6)	;BLTCMOD
	move.w	#L_Width,$66(a6)	;BLTDMOD
	bra.s	D2DO_Next_Line
D2DO_Poligon_Start:
	addq.l	#$04,a4
D2DO_Next_Line:
	move.w	(a4)+,d4		;First Cord
	move.w	(a4),d5			;Secund Cord
	movem.w	(a5,d4.w),d0-d1		;X0,Y0
	movem.w	(a5,d5.w),d2-d3		;X1,Y1
	bsr.w	Line
	cmp.w	#$aaaa,$0002(a4)
	beq.s	D2DO_Poligon_Start
	cmp.w	#$ffff,$0002(a4)
	bne.s	D2DO_Next_Line
	move.w	#$aaaa,(a3)

D2DO_Draw_Clipped:
	lea	Clipped_Area,a4
D2DO_Next_Clipped_Line:
	cmp.w	#$aaaa,(a4)
	beq.s	D2DO_End
	move.w	(a4)+,d1
	move.w	(a4)+,d3
	bsr.w	Vertical_Line
	bra.s	D2DO_Next_Clipped_Line
D2DO_End:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CopperInterrupt:
	movem.l	d0-d7/a0-a6,-(sp)
;	move.w	#$0f00,$180(a6)

	bsr	Clear_Screen
	bsr	Draw_2D_Object
	bsr	Blitter_Fill_Screen

	move.l	Curent_Object,a0
	add.w	#$0010,$0008(a0)
	bsr	RotateZ

	move.l	WorkPlane,a0
	move.l	ShowPlane,WorkPlane
	move.l	a0,ShowPlane
	bsr	Write_CopperList

;	move.w	#$0000,$180(a6)
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	#$0010,$9c(a6)
	rte

Up	=	0
Left	=	0
Down	=	255
Right	=	319


L_BMaps		=	1
L_BMapWid	=	40
L_Width		=	l_BMaps*l_BMapWid
L_YTableHeight	=	256
L_STableHeight	=	320

Line:
	cmp.w	d1,d3
	beq	CL_Line_Out
	move.w	#Up,d5
	cmp.w	d5,d1
	bge.s	Cl_X0_Test_Left
	cmp.w	d5,d3
	blt.w	Cl_Line_Out
	move.w	d2,d6
	sub.w	d0,d6
	sub.w	d1,d5
	muls	d6,d5
	move.w	d3,d6
	sub.w	d1,d6
	divs	d6,d5
	add.w	d5,d0
	move.w	#Up,d1
Cl_X0_Test_Left:
	move.w	#Left,d5
	cmp.w	d5,d0
	bge.s	Cl_Y0_Test_Down
	cmp.w	d5,d2
	blt.w	Cl_Line_Out
	move.w	d3,d6
	sub.w	d1,d6
	sub.w	d0,d5
	muls	d6,d5
	move.w	d2,d6
	sub.w	d0,d6
	divs	d6,d5
	add.w	d5,d1
	move.w	#Left,d0
Cl_Y0_Test_Down:
	move.w	#Down,d5
	cmp.w	d5,d1
	ble.s	Cl_X0_Test_Right
	cmp.w	d5,d3
	bgt.w	Cl_Line_Out
	move.w	d2,d6
	sub.w	d0,d6
	sub.w	d1,d5
	muls	d6,d5
	move.w	d3,d6
	sub.w	d1,d6
	divs	d6,d5
	add.w	d5,d0
	move.w	#Down,d1
Cl_X0_Test_Right:
	move.w	#Right,d5
	cmp.w	d5,d0
	ble.s	Cl_Y1_Test_Up
	cmp.w	d5,d2
	bgt.s	Cl_Line_Out_Right
	move.w	d1,(a3)+ 
	move.w	d3,d6
	sub.w	d1,d6
	sub.w	d0,d5
	muls	d6,d5
	move.w	d2,d6
	sub.w	d0,d6
	divs	d6,d5
	add.w	d5,d1
	move.w	#Right,d0
	cmp.w	#Down,d1
	ble.s	Cl_X0_Y0Down_Ok
	move.w	#Down,(a3)+
	bra.s	Cl_Y1_Test_Up
Cl_X0_Y0Down_Ok:
	cmp.w	#Up,d1
	bge.s	Cl_X0_Y0Up_Ok
	move.w	#Up,(a3)+
	bra.s	Cl_Y1_Test_Up
Cl_X0_Y0Up_Ok:
	move.w	d1,(a3)+
	bra.s	Cl_Y1_Test_Up

Cl_Line_Out_Right:
	move.w	d1,(a3)+
	cmp.w	#Up,d3
	bge.s	ClLOR_Test_Y1_Down
	move.w	#Up,(a3)+
	bra.w	Cl_Line_Out
ClLOR_Test_Y1_Down:
	cmp.w	#Down,d3
	ble.s	ClLOR_Test_End
	move.w	#Down,(a3)+
	bra.w	Cl_Line_Out
ClLOR_Test_End:
	move.w	d3,(a3)+
	bra.w	Cl_Line_Out

Cl_Y1_Test_Up:
	move.w	#Up,d5
	cmp.w	d5,d3
	bge.s	Cl_X1_Test_Left
	cmp.w	d5,d1
	blt.w	Cl_Line_Out
	move.w	d2,d6
	sub.w	d0,d6
	sub.w	d3,d5
	muls	d6,d5
	move.w	d3,d6
	sub.w	d1,d6
	divs	d6,d5
	add.w	d5,d2
	move.w	#Up,d3
Cl_X1_Test_Left:
	move.w	#Left,d5
	cmp.w	d5,d2
	bge.s	Cl_Y1_Test_Down
	cmp.w	d5,d0
	blt.w	Cl_Line_Out
	move.w	d3,d6
	sub.w	d1,d6
	sub.w	d2,d5
	muls	d6,d5
	move.w	d2,d6
	sub.w	d0,d6
	divs	d6,d5
	add.w	d5,d3
	move.w	#Left,d2
Cl_Y1_Test_Down:
	move.w	#Down,d5
	cmp.w	d5,d3
	ble.s	Cl_X1_Test_Right
	cmp.w	d5,d1
	bgt.w	Cl_Line_Out
	move.w	d2,d6
	sub.w	d0,d6
	sub.w	d3,d5
	muls	d6,d5
	move.w	d3,d6
	sub.w	d1,d6
	divs	d6,d5
	add.w	d5,d2
	move.w	#Down,d3
Cl_X1_Test_Right:
	move.w	#Right,d5
	cmp.w	d5,d2
	ble.s	Clipping_End
	cmp.w	d5,d0
	bgt.w	Cl_Line_Out
	move.w	d3,(a3)+
	move.w	d3,d6
	sub.w	d1,d6
	sub.w	d2,d5
	muls	d6,d5
	move.w	d2,d6
	sub.w	d0,d6
	divs	d6,d5
	add.w	d5,d3
	move.w	#Right,d2
	cmp.w	#Down,d3
	ble.s	Cl_X1_Y1Down_Ok
	move.w	#Down,(a3)+
	bra.s	Clipping_End
Cl_X1_Y1Down_Ok:
	cmp.w	#Up,d3
	bge.s	Cl_X1_Y1Up_Ok
	move.w	#Up,(a3)+
	bra.s	Clipping_End
Cl_X1_Y1Up_Ok:
	move.w	d3,(a3)+
Clipping_End:
	cmp.w	d1,d3
	beq	CL_Line_Out
	bhi.s	L_NoChange
	exg	d2,d0
	exg	d3,d1
L_NoChange:
	subq	#1,d3
	sub.w	d1,d3
	sub.w	d0,d2
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

	move.l	a3,-(sp)

	add.w	d1,d1
	move.w	0(a1,d1.w),d1
	lea	0(a0,d1.w),a3
	move.w	d0,d1
	lsr.w	#4,d1
	add.w	d1,d1
	lea	0(a3,d1.w),a3
	andi.w	#$000f,d0
	ror.w	#$0004,d0
	ori.w	#$0b4a,d0

	add.w	d3,d3
	move.w	d3,d6
	sub.w	d2,d6
	bpl.s	L_NoSignFlag
	ori.w	#$0040,d5
L_NoSignFlag:
	move.w	d6,d1
	sub.w	d2,d1
	add.w	d2,d2
	move.w	(a2,d2.w),d2

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
	move.l	(sp)+,a3
Cl_Line_Out:
	rts

Vertical_Line:
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
	lea	$26(a0,d1.w),a3
	move.w	d3,d1
	neg.w	d1
	add.w	d3,d3
	move.w	$00(a2,d3.w),d2
	neg.w	d3
	ext.l	d3
VL_Waitblit0:
	btst	#6,$2(a6)
	bne.s	VL_Waitblit0
	move.l	d3,$62(a6)		;BLTBMOD 2dy,BLTAMOD 2dy-2dx
	move.w	d1,$52(a6)		;BLTAPTL 2dy-dx
	move.l	d5,$40(a6)		;BLTCON0,BLTCON1
	move.l	a3,$48(a6)		;BLTCPTH,BLTCPTL
	move.l	a3,$54(a6)		;BLTDPTH,BLTDPTL
	move.w	d2,$58(a6)		;BLTSIZE
VL_End:	rts

Write_CopperList:
	movem.l	d0/a0-a1,-(sp)
	move.l	ShowPlane(pc),a0
	lea	Cl_BP(pc),a1
	move.l	a0,d0
	move.w	d0,6(a1)
	swap	d0
	move.w	d0,2(a1)
	lea	Cl_Col(pc),a0
	lea	Colors(pc),a1
	moveq	#$01,d0
WCL_NextColor:
	move.w	(a1)+,$0002(a0)
	addq.l	#$04,a0
	dbf	d0,WCL_NextColor
	lea	 Cl_Mod(pc),a0
	move.w	#$0000,$0002(a0)
	move.w	#$0000,$0006(a0)
	lea	Cl_Con(pc),a0
	move.w	#$1200,$0002(a0)
	move.w	#$0000,$0006(a0)
	move.w	#$0000,$000a(a0)
	movem.l	(sp)+,d0/a0-a1
	rts

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
	move.l	#L_STableHeight,d0
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

ShowPlane:	dc.l	0
Workplane:	dc.l	0
OldIntena:	dc.w	0
Level3IntSave:	dc.l	0
Curent_Object:	dc.l	Chess_Plane

Colors:	dc.w	$0000,$0fff

Chess_Plane:
	dc.l	Chess_Plane_Poligons		;$00
	dc.w	$0000,$0000,$0000		;$04 Alfa,Beta,Gama
	dc.w	$0000,$0000,$0300		;$0a TX,TY,TZ
	dc.l	Chess_Plane_Dots		;$10
	dc.l	Chess_Plane_Rotated_Dots	;$14
Chess_Plane_Poligons:

;Horizontal Stripes

	dc.w	0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,8*4
	dc.w	9*4,10*4,11*4,12*4,13*4,14*4,15*4,16*4
	dc.w	33*4,32*4,31*4,30*4,29*4,28*4,27*4,26*4
	dc.w	25*4,24*4,23*4,22*4,21*4,20*4,19*4,18*4,17*4,0*4,$aaaa

	dc.w	34*4,35*4,36*4,37*4,38*4,39*4,40*4,41*4,42*4
	dc.w	43*4,44*4,45*4,46*4,47*4,48*4,49*4,50*4,67*4
	dc.w	66*4,65*4,64*4,63*4,62*4,61*4,60*4,59*4,58*4
	dc.w	57*4,56*4,55*4,54*4,53*4,52*4,51*4,34*4,$aaaa

	dc.w	68*4,69*4,70*4,71*4,72*4,73*4,74*4,75*4,76*4
	dc.w	77*4,78*4,79*4,80*4,81*4,82*4,83*4,84*4,101*4
	dc.w	100*4,99*4,98*4,97*4,96*4,95*4,94*4,93*4,92*4
	dc.w	91*4,90*4,89*4,88*4,87*4,86*4,85*4,68*4,$aaaa

	dc.w	102*4,103*4,104*4,105*4,106*4,107*4,108*4,109*4,110*4
	dc.w	111*4,112*4,113*4,114*4,115*4,116*4,117*4,118*4,135*4
	dc.w	134*4,133*4,132*4,131*4,130*4,129*4,129*4,127*4,126*4
	dc.w	125*4,124*4,123*4,122*4,121*4,120*4,119*4,102*4,$aaaa

	dc.w	136*4,137*4,138*4,139*4,140*4,141*4,142*4,143*4,144*4
	dc.w	145*4,146*4,147*4,148*4,149*4,150*4,151*4,152*4,169*4
	dc.w	168*4,167*4,166*4,165*4,164*4,163*4,162*4,161*4,160*4
	dc.w	159*4,158*4,157*4,156*4,155*4,154*4,153*4,136*4,$aaaa
	
	dc.w	170*4,171*4,172*4,173*4,174*4,175*4,176*4,177*4,178*4
	dc.w	179*4,180*4,181*4,182*4,183*4,184*4,185*4,186*4,203*4
	dc.w	202*4,201*4,200*4,199*4,198*4,197*4,196*4,195*4,194*4
	dc.w	193*4,192*4,191*4,190*4,189*4,188*4,187*4,170*4,$aaaa

	dc.w	204*4,205*4,206*4,207*4,208*4,209*4,210*4,211*4,212*4
	dc.w	213*4,214*4,215*4,216*4,217*4,218*4,219*4,220*4,237*4
	dc.w	236*4,235*4,234*4,233*4,232*4,231*4,230*4,229*4,228*4
	dc.w	227*4,226*4,225*4,224*4,223*4,222*4,221*4,204*4,$aaaa

	dc.w	238*4,239*4,240*4,241*4,242*4,243*4,244*4,245*4,246*4
	dc.w	247*4,248*4,249*4,250*4,251*4,252*4,253*4,254*4,271*4
	dc.w	270*4,269*4,268*4,267*4,266*4,265*4,264*4,263*4,262*4
	dc.w	261*4,260*4,259*4,258*4,257*4,256*4,255*4,238*4,$aaaa

;Vertical Stripes

	dc.w	0*4,1*4,18*4,35*4,52*4,69*4,86*4,103*4,120*4
	dc.w	137*4,154*4,171*4,188*4,205*4,222*4,239*4,256*4,273*4
	dc.w	272*4,255*4,238*4,221*4,204*4,187*4,170*4,153*4,136*4
	dc.w	119*4,102*4,85*4,68*4,51*4,34*4,17*4,0*4,$aaaa

	dc.w	2*4,3*4,20*4,37*4,54*4,71*4,88*4,105*4,122*4
	dc.w	139*4,156*4,173*4,190*4,207*4,224*4,241*4,258*4,275*4
	dc.w	274*4,257*4,240*4,223*4,206*4,189*4,172*4,155*4,138*4
	dc.w	121*4,104*4,87*4,70*4,53*4,36*4,19*4,2*4,$aaaa

	dc.w	4*4,5*4,22*4,39*4,56*4,73*4,90*4,107*4,124*4
	dc.w	141*4,158*4,175*4,192*4,209*4,226*4,243*4,260*4,277*4
	dc.w	276*4,259*4,242*4,225*4,208*4,191*4,174*4,157*4,140*4
	dc.w	123*4,106*4,89*4,72*4,55*4,38*4,21*4,4*4,$aaaa

	dc.w	6*4,7*4,24*4,41*4,58*4,75*4,92*4,109*4,126*4
	dc.w	143*4,160*4,177*4,194*4,211*4,228*4,245*4,262*4,279*4
	dc.w	278*4,261*4,244*4,227*4,210*4,193*4,176*4,159*4,142*4
	dc.w	125*4,108*4,91*4,74*4,57*4,40*4,23*4,6*4,$aaaa

	dc.w	8*4,9*4,26*4,43*4,60*4,77*4,94*4,111*4,128*4
	dc.w	145*4,162*4,179*4,196*4,213*4,230*4,247*4,264*4,281*4
	dc.w	280*4,263*4,246*4,229*4,212*4,195*4,178*4,161*4,144*4
	dc.w	127*4,110*4,93*4,76*4,59*4,42*4,25*4,8*4,$aaaa

	dc.w	10*4,11*4,28*4,45*4,62*4,79*4,96*4,113*4,130*4
	dc.w	147*4,164*4,181*4,198*4,215*4,232*4,249*4,266*4,283*4
	dc.w	282*4,265*4,248*4,231*4,214*4,197*4,180*4,163*4,146*4
	dc.w	129*4,112*4,95*4,78*4,61*4,44*4,27*4,10*4,$aaaa

	dc.w	12*4,13*4,30*4,47*4,64*4,81*4,98*4,115*4,132*4
	dc.w	149*4,166*4,183*4,200*4,217*4,234*4,251*4,268*4,285*4
	dc.w	284*4,267*4,250*4,233*4,216*4,199*4,182*4,165*4,148*4
	dc.w	131*4,114*4,97*4,80*4,63*4,46*4,29*4,12*4,$aaaa

	dc.w	14*4,15*4,32*4,49*4,66*4,83*4,100*4,117*4,134*4
	dc.w	151*4,168*4,185*4,202*4,219*4,236*4,253*4,270*4,287*4
	dc.w	286*4,269*4,252*4,235*4,218*4,201*4,184*4,167*4,150*4
	dc.w	133*4,116*4,99*4,82*4,65*4,48*4,31*4,14*4,$ffff
Chess_Plane_Dots:
	dc.w	-400*2,-400*2,400*2		;00
	dc.w	-350*2,-400*2,400*2
	dc.w	-300*2,-400*2,400*2
	dc.w	-250*2,-400*2,400*2
	dc.w	-200*2,-400*2,400*2
	dc.w	-150*2,-400*2,400*2
	dc.w	-100*2,-400*2,400*2
	dc.w	-050*2,-400*2,400*2
	dc.w	0000*2,-400*2,400*2
	dc.w	0050*2,-400*2,400*2
	dc.w	0100*2,-400*2,400*2
	dc.w	0150*2,-400*2,400*2
	dc.w	0200*2,-400*2,400*2
	dc.w	0250*2,-400*2,400*2
	dc.w	0300*2,-400*2,400*2
	dc.w	0350*2,-400*2,400*2
	dc.w	0400*2,-400*2,400*2

	dc.w	-400*2,-350*2,400*2		;17
	dc.w	-350*2,-350*2,400*2
	dc.w	-300*2,-350*2,400*2
	dc.w	-250*2,-350*2,400*2
	dc.w	-200*2,-350*2,400*2
	dc.w	-150*2,-350*2,400*2
	dc.w	-100*2,-350*2,400*2
	dc.w	-050*2,-350*2,400*2
	dc.w	0000*2,-350*2,400*2
	dc.w	0050*2,-350*2,400*2
	dc.w	0100*2,-350*2,400*2
	dc.w	0150*2,-350*2,400*2
	dc.w	0200*2,-350*2,400*2
	dc.w	0250*2,-350*2,400*2
	dc.w	0300*2,-350*2,400*2
	dc.w	0350*2,-350*2,400*2
	dc.w	0400*2,-350*2,400*2

	dc.w	-400*2,-300*2,400*2		;34
	dc.w	-350*2,-300*2,400*2
	dc.w	-300*2,-300*2,400*2
	dc.w	-250*2,-300*2,400*2
	dc.w	-200*2,-300*2,400*2
	dc.w	-150*2,-300*2,400*2
	dc.w	-100*2,-300*2,400*2
	dc.w	-050*2,-300*2,400*2
	dc.w	0000*2,-300*2,400*2
	dc.w	0050*2,-300*2,400*2
	dc.w	0100*2,-300*2,400*2
	dc.w	0150*2,-300*2,400*2
	dc.w	0200*2,-300*2,400*2
	dc.w	0250*2,-300*2,400*2
	dc.w	0300*2,-300*2,400*2
	dc.w	0350*2,-300*2,400*2
	dc.w	0400*2,-300*2,400*2

	dc.w	-400*2,-250*2,400*2		;51
	dc.w	-350*2,-250*2,400*2
	dc.w	-300*2,-250*2,400*2
	dc.w	-250*2,-250*2,400*2
	dc.w	-200*2,-250*2,400*2
	dc.w	-150*2,-250*2,400*2
	dc.w	-100*2,-250*2,400*2
	dc.w	-050*2,-250*2,400*2
	dc.w	0000*2,-250*2,400*2
	dc.w	0050*2,-250*2,400*2
	dc.w	0100*2,-250*2,400*2
	dc.w	0150*2,-250*2,400*2
	dc.w	0200*2,-250*2,400*2
	dc.w	0250*2,-250*2,400*2
	dc.w	0300*2,-250*2,400*2
	dc.w	0350*2,-250*2,400*2
	dc.w	0400*2,-250*2,400*2

	dc.w	-400*2,-200*2,400*2		;68
	dc.w	-350*2,-200*2,400*2
	dc.w	-300*2,-200*2,400*2
	dc.w	-250*2,-200*2,400*2
	dc.w	-200*2,-200*2,400*2
	dc.w	-150*2,-200*2,400*2
	dc.w	-100*2,-200*2,400*2
	dc.w	-050*2,-200*2,400*2
	dc.w	0000*2,-200*2,400*2
	dc.w	0050*2,-200*2,400*2
	dc.w	0100*2,-200*2,400*2
	dc.w	0150*2,-200*2,400*2
	dc.w	0200*2,-200*2,400*2
	dc.w	0250*2,-200*2,400*2
	dc.w	0300*2,-200*2,400*2
	dc.w	0350*2,-200*2,400*2
	dc.w	0400*2,-200*2,400*2

	dc.w	-400*2,-150*2,400*2		;85
	dc.w	-350*2,-150*2,400*2
	dc.w	-300*2,-150*2,400*2
	dc.w	-250*2,-150*2,400*2
	dc.w	-200*2,-150*2,400*2
	dc.w	-150*2,-150*2,400*2
	dc.w	-100*2,-150*2,400*2
	dc.w	-050*2,-150*2,400*2
	dc.w	0000*2,-150*2,400*2
	dc.w	0050*2,-150*2,400*2
	dc.w	0100*2,-150*2,400*2
	dc.w	0150*2,-150*2,400*2
	dc.w	0200*2,-150*2,400*2
	dc.w	0250*2,-150*2,400*2
	dc.w	0300*2,-150*2,400*2
	dc.w	0350*2,-150*2,400*2
	dc.w	0400*2,-150*2,400*2

	dc.w	-400*2,-100*2,400*2		;102
	dc.w	-350*2,-100*2,400*2
	dc.w	-300*2,-100*2,400*2
	dc.w	-250*2,-100*2,400*2
	dc.w	-200*2,-100*2,400*2
	dc.w	-150*2,-100*2,400*2
	dc.w	-100*2,-100*2,400*2
	dc.w	-050*2,-100*2,400*2
	dc.w	0000*2,-100*2,400*2
	dc.w	0050*2,-100*2,400*2
	dc.w	0100*2,-100*2,400*2
	dc.w	0150*2,-100*2,400*2
	dc.w	0200*2,-100*2,400*2
	dc.w	0250*2,-100*2,400*2
	dc.w	0300*2,-100*2,400*2
	dc.w	0350*2,-100*2,400*2
	dc.w	0400*2,-100*2,400*2

	dc.w	-400*2,-50*2,400*2		;119
	dc.w	-350*2,-50*2,400*2
	dc.w	-300*2,-50*2,400*2
	dc.w	-250*2,-50*2,400*2
	dc.w	-200*2,-50*2,400*2
	dc.w	-150*2,-50*2,400*2
	dc.w	-100*2,-50*2,400*2
	dc.w	-050*2,-50*2,400*2
	dc.w	 000*2,-50*2,400*2
	dc.w	0050*2,-50*2,400*2
	dc.w	0100*2,-50*2,400*2
	dc.w	0150*2,-50*2,400*2
	dc.w	0200*2,-50*2,400*2
	dc.w	0250*2,-50*2,400*2
	dc.w	0300*2,-50*2,400*2
	dc.w	0350*2,-50*2,400*2
	dc.w	0400*2,-50*2,400*2

	dc.w	-400*2,0*2,400*2		;136
	dc.w	-350*2,0*2,400*2
	dc.w	-300*2,0*2,400*2
	dc.w	-250*2,0*2,400*2
	dc.w	-200*2,0*2,400*2
	dc.w	-150*2,0*2,400*2
	dc.w	-100*2,0*2,400*2
	dc.w	-050*2,0*2,400*2
	dc.w	 000*2,0*2,400*2
	dc.w	0050*2,0*2,400*2
	dc.w	0100*2,0*2,400*2
	dc.w	0150*2,0*2,400*2
	dc.w	0200*2,0*2,400*2
	dc.w	0250*2,0*2,400*2
	dc.w	0300*2,0*2,400*2
	dc.w	0350*2,0*2,400*2
	dc.w	0400*2,0*2,400*2

	dc.w	-400*2,50*2,400*2		;153
	dc.w	-350*2,50*2,400*2
	dc.w	-300*2,50*2,400*2
	dc.w	-250*2,50*2,400*2
	dc.w	-200*2,50*2,400*2
	dc.w	-150*2,50*2,400*2
	dc.w	-100*2,50*2,400*2
	dc.w	-050*2,50*2,400*2
	dc.w	 000*2,50*2,400*2
	dc.w	0050*2,50*2,400*2
	dc.w	0100*2,50*2,400*2
	dc.w	0150*2,50*2,400*2
	dc.w	0200*2,50*2,400*2
	dc.w	0250*2,50*2,400*2
	dc.w	0300*2,50*2,400*2
	dc.w	0350*2,50*2,400*2
	dc.w	0400*2,50*2,400*2

	dc.w	-400*2,100*2,400*2		;170
	dc.w	-350*2,100*2,400*2
	dc.w	-300*2,100*2,400*2
	dc.w	-250*2,100*2,400*2
	dc.w	-200*2,100*2,400*2
	dc.w	-150*2,100*2,400*2
	dc.w	-100*2,100*2,400*2
	dc.w	-050*2,100*2,400*2
	dc.w	0000*2,100*2,400*2
	dc.w	0050*2,100*2,400*2
	dc.w	0100*2,100*2,400*2
	dc.w	0150*2,100*2,400*2
	dc.w	0200*2,100*2,400*2
	dc.w	0250*2,100*2,400*2
	dc.w	0300*2,100*2,400*2
	dc.w	0350*2,100*2,400*2
	dc.w	0400*2,100*2,400*2

	dc.w	-400*2,150*2,400*2		;187
	dc.w	-350*2,150*2,400*2
	dc.w	-300*2,150*2,400*2
	dc.w	-250*2,150*2,400*2
	dc.w	-200*2,150*2,400*2
	dc.w	-150*2,150*2,400*2
	dc.w	-100*2,150*2,400*2
	dc.w	-050*2,150*2,400*2
	dc.w	0000*2,150*2,400*2
	dc.w	0050*2,150*2,400*2
	dc.w	0100*2,150*2,400*2
	dc.w	0150*2,150*2,400*2
	dc.w	0200*2,150*2,400*2
	dc.w	0250*2,150*2,400*2
	dc.w	0300*2,150*2,400*2
	dc.w	0350*2,150*2,400*2
	dc.w	0400*2,150*2,400*2

	dc.w	-400*2,200*2,400*2		;204
	dc.w	-350*2,200*2,400*2
	dc.w	-300*2,200*2,400*2
	dc.w	-250*2,200*2,400*2
	dc.w	-200*2,200*2,400*2
	dc.w	-150*2,200*2,400*2
	dc.w	-100*2,200*2,400*2
	dc.w	-050*2,200*2,400*2
	dc.w	0000*2,200*2,400*2
	dc.w	0050*2,200*2,400*2
	dc.w	0100*2,200*2,400*2
	dc.w	0150*2,200*2,400*2
	dc.w	0200*2,200*2,400*2
	dc.w	0250*2,200*2,400*2
	dc.w	0300*2,200*2,400*2
	dc.w	0350*2,200*2,400*2
	dc.w	0400*2,200*2,400*2

	dc.w	-400*2,250*2,400*2		;221
	dc.w	-350*2,250*2,400*2
	dc.w	-300*2,250*2,400*2
	dc.w	-250*2,250*2,400*2
	dc.w	-200*2,250*2,400*2
	dc.w	-150*2,250*2,400*2
	dc.w	-100*2,250*2,400*2
	dc.w	-050*2,250*2,400*2
	dc.w	0000*2,250*2,400*2
	dc.w	0050*2,250*2,400*2
	dc.w	0100*2,250*2,400*2
	dc.w	0150*2,250*2,400*2
	dc.w	0200*2,250*2,400*2
	dc.w	0250*2,250*2,400*2
	dc.w	0300*2,250*2,400*2
	dc.w	0350*2,250*2,400*2
	dc.w	0400*2,250*2,400*2

	dc.w	-400*2,300*2,400*2		;238
	dc.w	-350*2,300*2,400*2
	dc.w	-300*2,300*2,400*2
	dc.w	-250*2,300*2,400*2
	dc.w	-200*2,300*2,400*2
	dc.w	-150*2,300*2,400*2
	dc.w	-100*2,300*2,400*2
	dc.w	-050*2,300*2,400*2
	dc.w	0000*2,300*2,400*2
	dc.w	0050*2,300*2,400*2
	dc.w	0100*2,300*2,400*2
	dc.w	0150*2,300*2,400*2
	dc.w	0200*2,300*2,400*2
	dc.w	0250*2,300*2,400*2
	dc.w	0300*2,300*2,400*2
	dc.w	0350*2,300*2,400*2
	dc.w	0400*2,300*2,400*2

	dc.w	-400*2,350*2,400*2		;255
	dc.w	-350*2,350*2,400*2
	dc.w	-300*2,350*2,400*2
	dc.w	-250*2,350*2,400*2
	dc.w	-200*2,350*2,400*2
	dc.w	-150*2,350*2,400*2
	dc.w	-100*2,350*2,400*2
	dc.w	-050*2,350*2,400*2
	dc.w	0000*2,350*2,400*2
	dc.w	0050*2,350*2,400*2
	dc.w	0100*2,350*2,400*2
	dc.w	0150*2,350*2,400*2
	dc.w	0200*2,350*2,400*2
	dc.w	0250*2,350*2,400*2
	dc.w	0300*2,350*2,400*2
	dc.w	0350*2,350*2,400*2
	dc.w	0400*2,350*2,400*2

	dc.w	-400*2,400*2,400*2		;272
	dc.w	-350*2,400*2,400*2
	dc.w	-300*2,400*2,400*2
	dc.w	-250*2,400*2,400*2
	dc.w	-200*2,400*2,400*2
	dc.w	-150*2,400*2,400*2
	dc.w	-100*2,400*2,400*2
	dc.w	-050*2,400*2,400*2
	dc.w	0000*2,400*2,400*2
	dc.w	0050*2,400*2,400*2
	dc.w	0100*2,400*2,400*2
	dc.w	0150*2,400*2,400*2
	dc.w	0200*2,400*2,400*2
	dc.w	0250*2,400*2,400*2
	dc.w	0300*2,400*2,400*2
	dc.w	0350*2,400*2,400*2
	dc.w	0400*2,400*2,400*2
	dc.w	$ffff				;289
Chess_Plane_Rotated_Dots:
	blk.w	870,0
	dc.w	$ffff

Draw_Dots00:	blk.w	580,0
Draw_Dots01:	blk.w	580,0

CopperList:
	dc.w	$01fc,$0000
	dc.w	$009c,$8010			;INTREQ
	dc.w	$008e,$2c81			;DIWSTRT
	dc.w	$0090,$2cc1			;DIWSTOP
	dc.w	$0092,$0038			;DDFSTRT
	dc.w	$0094,$00d0			;DDFSTOP
Cl_Con:	dc.w	$0100,$0000			;BPLCON0
	dc.w	$0102,$0000			;BPLCON1
	dc.w	$0104,$0000			;BPLCON2
Cl_Mod:	dc.w	$0108,$0000			;BPL1MOD
	dc.w	$010a,$0000			;BPL2MOD
Cl_BP:	dc.w	$00e0,$0000,$00e2,$0000		;BPL0PTH,BPL0PTL
Cl_Col:	dc.w	$0180,$0000,$0182,$0fff		;COLOR00,COLOR01
	dc.w	$ffff,$fffe			;End of Copper List

L_YTable:	blk.w	512,0
L_SizeTable:	blk.w	512,0
	AUTO	CS\R_SinCosTable\0\450\5120\32767\0\W1\yy
R_SinCosTable:	blk.w	5120,0
Clipped_Area:	blk.l	10240,0
VideoMemory00:	blk.b	10240,0
VideoMemory01:	blk.b	10240,0
