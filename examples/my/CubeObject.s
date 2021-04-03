Cube:
	dc.l	Cube_Poligons			;$00
	dc.w	0,0,0				;$04 Alfa,Beta,Gama
	dc.w	0,0,$800			;$0a TX,TY,TZ
	dc.l	Cube_Dots			;$10
	dc.l	Cube_Rotated_Dots		;$14
	dc.l	Cube_Normal_Vektors		;$18
Cube_Poligons:
	dc.w	1,0,0*6,1*6,2*6,3*6,0*6,$aaaa
	dc.w	2,0,0*6,4*6,5*6,1*6,0*6,$aaaa
	dc.w	3,0,1*6,5*6,6*6,2*6,1*6,$aaaa
	dc.w	1,0,5*6,4*6,7*6,6*6,5*6,$aaaa
	dc.w	2,0,3*6,2*6,6*6,7*6,3*6,$aaaa
	dc.w	3,0,7*6,4*6,0*6,3*6,7*6,$ffff
Cube_Normal_Vektors:
	dc.w	0,0,16*2
	dc.w	0,16*2,0
	dc.w	-16*2,0,0
	dc.w	0,0,-16*2
	dc.w	0,-16*2,0
	dc.w	16*2,0,0
	dc.w	$ffff
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
