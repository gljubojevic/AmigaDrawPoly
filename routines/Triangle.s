Triangle:
	dc.w	$0,$0,$0			;$00 Alfa,Beta,Gama
	dc.w	$0,$0,$800			;$06 TX,TY,TZ
	dc.l	Triangle_Vtx		;$0c
	dc.l	Triangle_Vtx_Rot	;$10
	dc.l	Triangle_Tri		;$14
Triangle_Tri:	;color, vtx1, vtx2, vtx3
	dc.w	1,	0*6, 1*6, 2*6	;front
	dc.w	$ffff
Triangle_Vtx:	;X, Y, Z
	dc.w	-200*2,	-200*2,	-200*2	;00
	dc.w	200*2,	-200*2,	-200*2	;01
	dc.w	200*2,	200*2,	-200*2	;02
	dc.w	$ffff
Triangle_Vtx_Rot:	;space for rotated vertex
	dc.w	170, 50,	0	;00
	dc.w	50,	120,	0	;01
	dc.w	310, 250,	0	;02
	dc.w	$ffff
