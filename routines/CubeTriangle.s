CubeTriangle:
	dc.w	$0,$0,$0			;$00 Alfa,Beta,Gama
	dc.w	$0,$0,$800			;$06 TX,TY,TZ
	dc.l	Cube_Vtx			;$0c
	dc.l	Cube_Vtx_Rot		;$10
	dc.l	Cube_Tri			;$14
Cube_Tri:	;color, vtx1, vtx2, vtx3
	dc.w	1,	0*6, 1*6, 2*6	;front
	dc.w	2,	0*6, 2*6, 3*6
	dc.w	3,	0*6, 4*6, 1*6	;top
	dc.w	1,	4*6, 5*6, 1*6
	dc.w	2,	3*6, 2*6, 7*6	;bottom
	dc.w	3,	6*6, 7*6, 2*6
	dc.w	1,	5*6, 4*6, 6*6	;back
	dc.w	2,	7*6, 6*6, 4*6
	dc.w	3,	4*6, 0*6, 7*6	;left
	dc.w	1,	3*6, 7*6, 0*6
	dc.w	2,	1*6, 5*6, 6*6	;right
	dc.w	3,	1*6, 6*6, 2*6
	dc.w	$ffff
Cube_Vtx:	;X, Y, Z
	dc.w	-200*2,	-200*2,	-200*2	;00
	dc.w	200*2,	-200*2,	-200*2	;01
	dc.w	200*2,	200*2,	-200*2	;02
	dc.w	-200*2,	200*2,	-200*2	;03
	dc.w	-200*2,	-200*2,	200*2	;04
	dc.w	200*2,	-200*2,	200*2	;05
	dc.w	200*2,	200*2,	200*2	;06
	dc.w	-200*2,	200*2,	200*2	;07
	dc.w	$ffff
Cube_Vtx_Rot:	;space for rotated vertex
	ds.w	8*3*2,0	
	dc.w	$ffff
