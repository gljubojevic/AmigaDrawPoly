; New format for easier draw
; - main difference is format of polygons
; - e.g. vtx1, vtx2, vtx3, vtx1, color 
; - poly endd with first point
; - color is negative to mark poly end
Triangle:
	dc.w	$0,$0,$0			;$00 Alfa,Beta,Gama
	dc.w	$0,$0,$800			;$06 TX,TY,TZ
	dc.l	Triangle_Vtx		;$0c
	dc.l	Triangle_Vtx_Rot	;$10
	dc.l	Triangle_Tri		;$14
Triangle_Tri:	
	dc.w	0*6, 1*6, 2*6, 0*6, -1	;front
	;dc.w	0*6, 1*6, 2*6, 0*6, -1	;front
	dc.w	$ffff				; marker for last poly
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
