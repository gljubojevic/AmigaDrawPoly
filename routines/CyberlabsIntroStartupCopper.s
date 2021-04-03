;***************************************************
;Chip Data
;***************************************************
;	SECTION	"Startup Chip Data",DATA_C

	CNOP	0,8
Dummy_Copper:
	dc.w	$01fc,$0000
	dc.w	$0100,$0000			;BPLCON0
	dc.w	$0102,$0000			;BPLCON1
	dc.w	$0104,$0000			;BPLCON2
	dc.w	$0106,$0000			;BPLCON3
	dc.w	$010c,$0000			;BPLCON4
	dc.w	$0180,$0000
	IF	COPPERINT=1
	dc.w	$009c,$8010			;INTREQ
	ENDIF
	dc.w	$ffff,$fffe			;End of Copper List
	dc.w	$ffff,$fffe			;End of Copper List
