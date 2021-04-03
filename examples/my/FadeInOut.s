;***************************************************
;Fade In/Out
;***************************************************

;----------
;d0.w - No colors
;a0.l - Picture colors
;a1.l - Copper colors
;----------
FadeIn:
	bsr.s	FIO_Setup
	move.w	#$0,FIO_Step
	move.w	#$1,FIO_Direction
	move.w	#$f,FIO_Counter		;Write last starts fade
	rts

;----------
;d0.w - No colors
;a0.l - Picture colors
;a1.l - Copper colors
;----------
FadeOut:
	bsr.s	FIO_Setup
	move.w	#$f,FIO_Step
	move.w	#-1,FIO_Direction
	move.w	#$f,FIO_Counter		;Write last starts fade
	rts

FIO_Setup:
	move.w	#$0,FIO_Counter		;Stop current fade if any
	move.w	d0,FIO_NoColors
	move.l	a0,FIO_Colors
	move.l	a1,FIO_Copper
	rts

FadeInOut_Finished:
	tst.w	FIO_Counter(pc)		;Check finished
	rts

FIO_Counter:	dc.w	0
FIO_Direction:	dc.w	0
FIO_Step:	dc.w	0
FIO_NoColors:	dc.w	0
FIO_Colors:	dc.l	0
FIO_Copper:	dc.l	0

FadeInOut:
	tst.w	FIO_Counter(pc)		;Check finished
	beq.s	FIO_Done
	movem.l	d0-d5/a0-a1,-(sp)

	move.l	FIO_Colors(pc),a0	;Address of Colors from Picture
	move.l	FIO_Copper(pc),a1	;Address of Colors in Copper List

	move.w	FIO_Step(pc),d0		;Current step to d0
	move.w	FIO_NoColors(pc),d1	;Number of Colors in d1
FIO_NextColor:
	move.w	#$0f00,d2		;Set Mask for Red Component in d2
	moveq	#$00,d3			;Clear target color in d3
	move.w	(a0)+,d4		;Get Color in d4

	move.w	d4,d5			;Put Color in d5
	and.w	d2,d5			;Get Red Component in d5
	mulu	d0,d5			;d5*Pass Cnt.
	lsr.w	#4,d5			;d5/16
	and.w	d2,d5			;Get Red Component in d5
	or.w	d5,d3			;Red Component over
	lsr.w	#4,d2			;Set Mask for Green Component in d3

	move.w	d4,d5			;Put Color in d5
	and.w	d2,d5			;Get Green Component in d5
	mulu	d0,d5			;d5*Pass Cnt.
	lsr.w	#4,d5			;d5/16
	and.w	d2,d5			;Get Green Component in d5
	or.w	d5,d3			;Green Component over
	lsr.w	#4,d2			;Set Mask for Blue Component in d3

	move.w	d4,d5			;Put Color in d5
	and.w	d2,d5			;Get Blue Component in d5
	mulu	d0,d5			;d5*Pass Cnt.
	lsr.w	#4,d5			;d5/16
	and.w	d2,d5			;Get Blue Component in d5
	or.w	d5,d3			;Blue Component over

	move.w	d3,$0002(a1)		;Color to copper
	lea	$0004(a1),a1		;Address of next Color in a1

	dbf	d1,FIO_NextColor

	add.w	FIO_Direction(pc),d0
	move.w	d0,FIO_Step		;Calc next step
	sub.w	#$01,FIO_Counter	;Decrement counter

	movem.l	(sp)+,d0-d5/a0-a1
FIO_Done:
	rts
