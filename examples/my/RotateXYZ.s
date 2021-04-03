;----------
;d0.w - Screen center X
;d1.w - Screen center Y
;d2.w - Projection plane Z
;a0.l - Object to work on
;----------
RotateXYZ_Setup:
	move.l	a1,-(sp)
	lea	R_Curent_Object(pc),a1
	move.l	a0,(a1)+		;R_Curent_Object
	move.w	d0,(a1)+		;R_Screen_CenterX
	move.w	d1,(a1)+		;R_Screen_CenterY
	move.w	d2,(a1)+		;R_Project_Plane
	move.l	(sp)+,a1
	rts


;----------
;d0.w - Alpha
;d1.w - Beta
;d2.w - Gama
;----------
RotateXYZ_IncAngles:
	move.l	a0,-(sp)
	move.l	R_Curent_Object(pc),a0		;Adr. of Obj. data in a0
	addq.l	#$04,a0				;Get Address of Angles in a0
	add.w	d0,(a0)+
	add.w	d1,(a0)+
	add.w	d2,(a0)+
	move.l	(sp)+,a0
	rts


;New Routine for rotating dots
;
;XYZ - Rotate
;X=X0*(Cos(Beta)Cos(Gama))-Y0*(Cos(Beta)Sin(Gama))+Z0*Sin(Beta)	-->A,B,C
;
;Y=X0*(Cos(Alpha)Sin(Gama)+Sin(Alpha)Sin(Beta)Cos(Gama))	-->D
; +Y0*(Cos(Alpha)Cos(Gama)-Sin(Alpha)Sin(Beta)Sin(Gama))	-->E
; -Z0*(Sin(Alpha)Cos(Beta))					-->F
;
;Z=X0*(Sin(Alpha)Sin(Gama)-Cos(Alpha)Sin(Beta)Cos(Gama))	-->G
; +Y0*(Sin(Alpha)Cos(Gama)+Cos(Alpha)Sin(Beta)Sin(Gama))	-->H
; +Z0*(Cos(Alpha)Cos(Beta))					-->I
;

RotateXYZ:
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	R_Curent_Object(pc),a0		;Adr. of Obj. data in a0
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
	move.l	a0,a3
	move.l	$000a(a0),a2		;Rotated Dots Area in a2
	move.l	$0006(a0),a0		;Dots Area in a0
	move.w	R_Screen_CenterX(pc),a4	;X Screen Center in a4
	move.w	R_Screen_CenterX(pc),a5	;Y Screen Center in a5
R_RotateNextDot:
	movem.w	(a0)+,d3-d5		;X0-->d3.w  Y0-->d4.w  Z0-->d5.w
	movem.w	(a1)+,d0-d2		;A --)d0.w  B -->d1.w  C -->d2.w
	muls	d3,d0			;d0=A*X0
	muls	d4,d1			;d1=B*Y0
	muls	d5,d2			;d2=C*Z0
	add.l	d1,d0			;d0=A*X0+B*Y0
	add.l	d2,d0			;d0=A*X0+B*Y0+C*Z0
	swap	d0			;X/32768
	add.w	(a3)+,d0		;X+TX
	move.w	d0,d6			;X in d6 ****
	movem.w	(a1)+,d0-d2		;D -->d0.w  E -->d1.w  F -->d2.w
	muls	d3,d0			;D0=D*X0
	muls	d4,d1			;D1=E*Y0
	muls	d5,d2			;d2=F*Z0
	add.l	d0,d1			;D0=D*X0+E*Y0
	add.l	d2,d1			;D0=D*X0+E*Y0+F*Z0
	swap	d1			;Y/32768
	add.w	(a3)+,d1		;Y+TY
	move.w	d1,d7			;Y in d7 ****
	movem.w	(a1)+,d0-d2		;G -->d0.w  H -->d1.w  I -->d2.w
	muls	d3,d0			;G*X0
	muls	d4,d1			;H*Y0
	muls	d5,d2			;I*Z0
	add.l	d1,d2			;d2=H*Y0+I*Z0
	add.l	d0,d2			;d2=G*X0+H*Y0+I*Z0
	swap	d2			;Z/32768
	add.w	(a3)+,d2		;Z+TZ
	move.w	R_Project_Plane(pc),d3	;Zaslon in d3
	add.w	d3,d2			;Z+Zaslon in d2
	muls	d3,d6			;Zaslon*X
	muls	d3,d7			;Zaslon*Y
	divs	d2,d6			;(Zaslon*X)/(Z+Zaslon)
	divs	d2,d7			;(Zaslon*Y)/(Z+Zaslon)
	add.w	a4,d6			;
	add.w	a5,d7			;
	move.w	d6,(a2)+		;X Rotated in Memory
	move.w	d7,(a2)+		;Y Rotated in Memory
	move.w	d2,(a2)+		;Z Rotated in Memory  !!!!!!
	lea	-$12(a1),a1
	subq.l	#$06,a3
	cmp.w	#$ffff,(a0)
	bne.s	R_RotateNextDot
	movem.l	(sp)+,d0-d7/a0-a6
	rts

R_Curent_Object:	dc.l	0
R_Screen_CenterX:	dc.w	160
R_Screen_CenterY:	dc.w	128
R_Project_Plane:	dc.w	512

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
