;*************************************************************************
;Cyberlabs intro startup code for system friendly intros
;Copy code below to beginning of intro code and uncoment it
;Customize to and use it
;NOTE: Remember to include CyberlabsIntroStartupCopper.s
;*************************************************************************
;	Section	"Intro",CODE_F
;
;	INCDIR	"Include:"
;	INCLUDE	"LVO3.1/exec_lib.i"
;	INCLUDE	"LVO3.1/dos_lib.i"
;	INCLUDE	"LVO3.1/graphics_lib.i"
;	INCLUDE	"graphics/gfxbase.i"
;	INCLUDE	"exec/interrupts.i"
;	INCLUDE	"exec/Memory.i"
;	INCLUDE	"exec/exec.i"
;	INCLUDE	"exec/execbase.i"
;	INCLUDE	"dos/dos.i"
;	INCLUDE	"hardware/intbits.i"	
;	INCLUDE	"hardware/dmabits.i"
;	INCLUDE	"hardware/cia.i"
;	INCLUDE	"libraries/dosextens.i"
;	INCLUDE	"devices/input.i"
;	INCLUDE	"devices/inputevent.i"
;	INCLUDE	"resources/misc.i"
;
;	INCDIR	"Intro:"
;
;DEBUGING	=	1	;use 1 if debuging
;COPPERINT	=	1	;use 1 if Copper int othervise is vertb int
;INPUTHANDLER	=	0	;use 1 if using input handler
;DOSLIB		=	0	;use 1 if dos library is needed
;DMA_ACTIVATE	= 	(DMAF_SETCLR|DMAF_SPRITE|DMAF_RASTER|DMAF_COPPER)
;
;Intro:	
;	movem.l	d0-a6,-(sp)
;	lea	$dff000,a6			;Custom Chip Address in a6
;
;	bsr	Init_Routine			;Init Routine
;	tst.l	d0				;Check Ok?
;	beq.s	Intro_Init
;	bra.w	Intro_Exit
;Intro_Init:
;;***********************************
;;TODO: Intro init
;;***********************************
;
;	move.w	#0,VTBInt_Stop			;Start Interrupt
;Intro_MainLoop:
;;***********************************
;;TODO: Main code here
;;***********************************
;
;	IF	INPUTHANDLER=1
;	tst.b	ESCKey
;	beq.s	Intro_MainLoop
;	ELSE
;	btst	#$6,$bfe001
;	bne.s	Intro_MainLoop
;	ENDIF
;
;Intro_Exit:
;	bsr	Restore_Routine
;	movem.l	(sp)+,d0-a6
;	rts
;
;VTBInt_Handler:
;	movem.l	d0-a6,-(sp)
;	add.l	#$01,VTBInt_Counter
;	tst.w	VTBInt_Stop
;	bne.s	VTBInt_End
;	lea	$dff000,a6
;
;;***********************************
;;TODO: interrupt code here
;;***********************************
;
;VTBInt_End:
;	movem.l	(sp)+,d0-a6
;	moveq	#$00,d0
;	rts
;
;	INCLUDE	"CyberlabsIntroStartup.s"
;
;	Section	"Intro Routines",CODE_F
;*************************************************************************



;***************************************************
;System init routines
;***************************************************

;Routine That Will init all Stuff
;OutPut:	d0	Error code 0(Ok)
Init_Routine:
	movem.l	d1-a6,-(sp)

	IF	DEBUGING=0
	sub.l	a1,a1			;Clear a1
	CALLEXEC	FindTask	;Find Task
	move.l	d0,a4			;Task Ptr in a4
	moveq	#$00,d0
	tst.l	pr_CLI(a4)		;Test if Started From Cli
	bne.s	IR_Started_From_CLI
	lea	pr_MsgPort(a4),a0	;Task Msg Port Ptr in a0
	CALLEXEC	WaitPort	;Wait For Message from Wb
	lea	pr_MsgPort(a4),a0	;Task Msg Port Ptr in a0
	CALLEXEC	GetMsg		;Get Workbench Message
IR_Started_From_CLI:
	move.l	d0,WBMessage		;Save WBMessage
	ENDIF

	IF	DOSLIB=1
	moveq	#$00,d0
	lea	DosName(pc),a1
	CALLEXEC	OpenLibrary
	tst.l	d0
	bne.s	IR_DOS_Open
	moveq	#$01,d0			;ERROR Dos.Library Not Open
	bra.w	IR_ERROR_End
IR_DOS_Open:
	move.l	d0,_DOSBase
	ENDIF

	sub.l	a1,a1			;Find current executing task
	CALLEXEC	FindTask
	move.l	d0,a1

	IF	INPUTHANDLER=1
	move.l	#20,d0			;20=Max Task Pri For Input Handler
	CALLEXEC	SetTaskPri
	bsr	SetInputHandler
	ELSE
	move.l	#128,d0
	CALLEXEC	SetTaskPri
	CALLEXEC	Forbid		;Stop Multi Tasking
	ENDIF

	moveq	#$00,d0
	lea	GfxName(pc),a1
	CALLEXEC	OpenLibrary
	tst.l	d0
	bne.s	IR_Gfx_Open
	moveq	#$07,d0				;ERROR Gfx Library Not Open
	bra	IR_ERROR_End
IR_Gfx_Open:
	move.l	d0,_GfxBase
	move.l	_GfxBase(pc),a6
	move.l	gb_ActiView(a6),ActiveView

	move.w	gb_DisplayFlags(a6),d0	;For genlock testing

	sub.l	a1,a1
	CALLGRAF	LoadView
	CALLGRAF	WaitTOF
	CALLGRAF	WaitTOF
	move.l	#Dummy_Copper,$dff080
	CALLGRAF	WaitTOF
	CALLGRAF	WaitTOF
	CALLGRAF	WaitBlit
	CALLGRAF	WaitBlit
	CALLGRAF	OwnBlitter
	CALLGRAF	WaitBlit
	CALLGRAF	WaitBlit

	move.w	#-1,VTBInt_Stop			;Stop Interrupt
	bsr	VTBStart_Interrupt

	move.w	$dff00a,MouseOld
	moveq	#$00,d0				;No ERROR
IR_ERROR_End:
	movem.l	(sp)+,d1-a6
	rts


Restore_Routine:
	movem.l	d0-a6,-(sp)

	bsr	VTBStop_Interrupt

	tst.l	_GfxBase
	beq.w	RR_ERROR_IN_Gfx_INIT
	CALLGRAF	WaitBlit
	CALLGRAF	WaitBlit
	CALLGRAF	DisownBlitter
	move.l	ActiveView(pc),a1
	CALLGRAF	LoadView
	CALLGRAF	WaitTOF
	CALLGRAF	WaitTOF
	move.l	gb_copinit(a6),a0
	move.l	a0,$dff080
	CALLGRAF	WaitTOF
	CALLGRAF	WaitTOF
	move.l	_GfxBase,a1
	CALLEXEC	CloseLibrary
RR_ERROR_IN_Gfx_INIT:

	IF	INPUTHANDLER=1
	bsr	RemoveInputHandler
	ELSE
	CALLEXEC	Permit		;Resume Multi Tasking
	ENDIF


	IF	DOSLIB=1
	tst.l	_DOSBase
	beq.s	RR_ERROR_No_DOS_Open
	move.l	_DOSBase,a1
	CALLEXEC	CloseLibrary
RR_ERROR_No_DOS_Open:
	ENDIF

	IF	DEBUGING=0
	tst.l	WBMessage
	beq.s	RR_Not_Started_From_WB
	CALLEXEC	Forbid
	move.l	WBMessage(pc),a1
	CALLEXEC	ReplyMsg
RR_Not_Started_From_WB:
	ENDIF

	movem.l	(sp)+,d0-a6
	rts


WBMessage:	dc.l	0

_GfxBase:	dc.l	0
ActiveView:	dc.l	0
GfxName:	GRAFNAME
		EVEN

	IF	DOSLIB=1
_DOSBase:	dc.l	0
DosName:	DOSNAME
		EVEN
	ENDIF


;***************************************************
;Interrupt Routines
;***************************************************

VTBStart_Interrupt:
	movem.l	d0-a6,-(sp)

	lea	VTBInt_Struct(pc),a0
	move.b	#NT_INTERRUPT,LN_TYPE(a0)
	move.b	#128,LN_PRI(a0)
	move.l	#VTBInt_Name,LN_NAME(a0)
	move.l	#VTBInt_Data,IS_DATA(a0)
	move.l	#VTBInt_Handler,IS_CODE(a0)

	IF	COPPERINT=1
	move.l	#INTB_COPER,d0
	ELSE
	move.l	#INTB_VERTB,d0
	ENDIF

	lea	VTBInt_Struct(pc),a1
	CALLEXEC	AddIntServer
	move.w	#$01,VTBInt_Started
	movem.l	(sp)+,d0-a6
	rts


VTBStop_Interrupt:
	movem.l	d0-a6,-(sp)
	move.w	#-1,VTBInt_Stop			;Stop Interrupt

	tst.w	VTBInt_Started
	beq.s	VTBInt_Not_Started

	IF	COPPERINT=1
	move.l	#INTB_COPER,d0
	ELSE
	move.l	#INTB_VERTB,d0
	ENDIF

	lea	VTBInt_Struct(pc),a1
	CALLEXEC	RemIntServer	
VTBInt_Not_Started:
	movem.l	(sp)+,d0-a6
	rts


VTBInt_Started:	dc.w	0
VTBInt_Counter:	dc.l	0
VTBInt_Stop:	dc.w	0
VTBInt_Data:	dc.w	0
VTBInt_Struct:	ds.b	IS_SIZE

	IF	COPPERINT=1
VTBInt_Name:	dc.b	"Cyberlabs Copper Interrupt",0
	ELSE
VTBInt_Name:	dc.b	"Cyberlabs VerticalBlank Interrupt",0
	ENDIF

	EVEN

;***************************************************
;Input handler routines
;TODO: Fix this code doesn't look good for
;unchaining different types of events
;***************************************************
	IF	INPUTHANDLER=1

SetInputHandler:
	movem.l	d0-a6,-(sp)
	moveq.l	#-1,d0
	CALLEXEC	AllocSignal
	move.l	d0,d2
	sub.l	a1,a1
	CALLEXEC	FindTask
	lea	InpEvPort,a1
	clr.b	LN_PRI(a1)
	clr.l	LN_NAME(a1)
	move.b	#NT_MSGPORT,LN_TYPE(a1)
	move.b	d2,MP_SIGBIT(a1)
	move.l	d0,MP_SIGTASK(a1)
	CALLEXEC	AddPort
	moveq	#0,d0
	moveq	#0,d1
	lea	InputDevName,a0
	lea	InpEvIOReq,a1
	move.l	#InpEvPort,14(a1)
	CALLEXEC	OpenDevice
	lea	InpEvIOReq,a1
	move.w	#IND_ADDHANDLER,IO_COMMAND(a1)
	move.b	#1,IO_FLAGS(a1)
	move.l	#InpEvStuff,IO_DATA(a1)
	CALLEXEC	DoIO
	move.w	#$01,IH_Installed
	movem.l	(sp)+,d0-a6
	rts


RemoveInputHandler:
	movem.l	d0-a6,-(sp)
	tst.w	IH_Installed
	beq.s	RIH_Not_Installed
	lea	InpEvIOReq,a1
	move.w	#IND_REMHANDLER,IO_COMMAND(a1)
	move.b	#1,IO_FLAGS(a1)
	move.l	#InpEvStuff,IO_DATA(a1)
	CALLEXEC	DoIO
	lea	InpEvIOReq,a1
	CALLEXEC	CloseDevice
	lea	InpEvPort,a1
	CALLEXEC	RemPort
	lea	InpEvPort,a1
	moveq	#$00,d0
	move.b	MP_SIGBIT(a1),d0
	CALLEXEC	FreeSignal
RIH_Not_Installed:
	movem.l	(sp)+,d0-a6
	rts

IH_Installed:	dc.w	0

InpEvPort	ds.b	MP_SIZE
InpEvIOReq	ds.b	IOSTD_SIZE

InpEvStuff
	dc.l	0,0
	dc.b	2,100 		; type, priority
	dc.l	InpEvName
	dc.l	0,Input_Handler

InpEvName:	dc.b	"Cyberlabs Input Handler",0
InputDevName:	dc.b	"input.device",0
		EVEN

Input_Handler: 				; A0-InputEvent, A1-Data Area
	movem.l	d1/a0-a3,-(sp)
	sub.l	a2,a2
	move.l	a0,a1
InpCheck:
	move.b	ie_Class(A1),d0 	; ie_Class
	cmp.b	#IECLASS_RAWKEY,d0    	; RAWKEY
	beq.s	InpRawkey
	cmp.b	#IECLASS_RAWMOUSE,d0  	; RAWMOUSE
	beq.s	InpRawmouse
	move.l	a1,a2
InpNext:
	move.l	(a1),a1
	move.l	a1,d0
	bne.w	InpCheck
inphend:
	move.l	a0,d0
	movem.l	(sp)+,d1/a0-a3
	rts

InpRawkey:
	bsr	InpUnchain
	move.w	6(a1),d0
	bsr	ProcessRawkey
	bra	InpNext

InpRawmouse:
	bsr	InpUnchain
;	move.w	MarkerX,d0
;	move.w	MarkerY,d1
;	add.w	10(a1),d0
;	add.w	12(a1),d1
;	move.w	d0,MarkerX
;	move.w	d1,MarkerY
	add.w	10(a1),MarkerX(pc)
	add.w	12(a1),MarkerY(pc)
	bra	InpNext

InpUnchain:
	move.l	a2,d0
	bne.s	InpUnc2
	move.l	(a1),a0
	rts

InpUnc2:
	move.l	(a1),(a2)
	rts


ProcessRawkey:
	movem.l	d0,-(sp)
	cmp.b	LastRawKey(pc),d0
	beq.w	PRK_Finish
	cmp.b	#$63,d0			;Test if CTRL Pressed
	bne.s	PRK_Test_CTRL_Rel
	move.b	#$01,CTRLKey
PRK_Test_CTRL_Rel:
	cmp.b	#$e3,d0			;Test if CTRL Released
	bne.s	PRK_Test_ESC
	move.b	#$00,CTRLKey
PRK_Test_ESC:
	cmp.b	#$45,d0			;ESC Pressed
	bne.s	PRK_Test_ESC_Rel
	move.b	#$01,ESCKey
PRK_Test_ESC_Rel:
	cmp.b	#$C5,d0
	bne.s	PRK_Test_Arrow_Left
	move.b	#$00,ESCKey
PRK_Test_Arrow_Left:
	cmp.b	#$4f,d0			;Left Arrow Pressed
	bne.s	PRK_Test_Arrow_Right
	move.b	#$01,ArrowLeft
PRK_Test_Arrow_Right:
	cmp.b	#$4e,d0			;Right Arrow Pressed
	bne.s	PRK_Test_Arrow_Up
	move.b	#$01,ArrowRight
PRK_Test_Arrow_Up:
	cmp.b	#$4c,d0			;Up Arrow Pressed
	bne.s	PRK_Test_Arrow_Down
	move.b	#$01,ArrowUp
PRK_Test_Arrow_Down:
	cmp.b	#$4d,d0			;Down Arrow Pressed
	bne.s	PRK_Test_F1
	move.b	#$01,ArrowDown
PRK_Test_F1:
	cmp.b	#$50,d0
	bne.s	PRK_Test_F2
	move.b	#$01,F1Key
PRK_Test_F2:
	cmp.b	#$51,d0
	bne.s	PRK_Test_F3
	move.b	#$01,F2Key
PRK_Test_F3:
	cmp.b	#$52,d0
	bne.s	PRK_Test_F4
	move.b	#$01,F3Key
PRK_Test_F4:
	cmp.b	#$53,d0
	bne.s	PRK_Test_F5
	move.b	#$01,F4Key
PRK_Test_F5:
	cmp.b	#$54,d0
	bne.s	PRK_Finish
	move.b	#$01,F5Key
PRK_Finish:
	move.b	d0,LastRawKey
	move.l	(sp)+,d0
	rts

MarkerX:	dc.w	0
MarkerY:	dc.w	0

LastRawKey:	dc.b	0
ESCKey:		dc.b	0
CTRLKey:	dc.b	0
ArrowLeft:	dc.b	0
ArrowRight:	dc.b	0
ArrowUp:	dc.b	0
ArrowDown:	dc.b	0
F1Key:		dc.b	0
F2Key:		dc.b	0
F3Key:		dc.b	0
F4Key:		dc.b	0
F5Key:		dc.b	0
		EVEN
	ENDIF


;***************************************************
;Utility routines
;***************************************************

Wait_VerticalBlank:
	movem.l	d1,-(sp)
WVB_WaitLoop:
	move.l	$0004(a6),d1
	and.l	#$0001ff00,d1
	cmp.l	#$00013800,d1		;$00013800 last vertical position !!
	bne.s	WVB_WaitLoop
	movem.l	(sp)+,d1
	rts

Wait_Blitter:
	btst	#$06,$002(a6)
	bne.s	Wait_Blitter
	rts

WaitMouseLeftPressed:
	btst	#$6,$bfe001
	bne.s	WaitMouseLeftPressed
WaitMouseLeftReleased:
	btst	#$6,$bfe001
	beq.s	WaitMouseLeftReleased
	rts


;d0.w,d1.w	- Current mouse X,Y
;New position is calculated end returened in d0,d1
Mouse:	movem.l	d2/a0,-(sp)
	lea	MouseOld(pc),a0
	move.w	(a0),d2
	move.w	$000a(a6),d0
	move.w	d0,(a0)
	move.w	d0,d1
	sub.b	d2,d0
	lsr.w	#$08,d1
	lsr.w	#$08,d2
	sub.w	d2,d1
	ext.w	d1
	ext.w	d0
	movem.l	(sp)+,d2/a0
	rts

MouseOld:	dc.w	0

;----------
;d0 - Picture pointer
;d1 - Offset to next bitmap
;d2 - No bitmaps-1
;a0 - Copper bitplanes
;All Trashed after
;----------
Write_CopperListBitmaps:
	move.w	d0,6(a0)
	swap	d0
	move.w	d0,2(a0)
	swap	d0
	add.l	d1,d0
	addq.l	#$8,a0
	dbf	d2,Write_CopperListBitmaps
	rts

;----------
;d0 - No Colors - 1
;a0 - Colors copper
;a1 - Colors
;All Trashed after
;----------
Write_CopperListColors:
	move.w	(a1)+,$0002(a0)		;Color to copper
	addq.l	#$4,a0			;Address of next Color in a0
	dbf	d0,Write_CopperListColors
	rts


;----------
;d0 - Y Pos
;a0 - Copper waits
;Note: Y pos is fixed for overflow of $ff
;----------
Write_DoubleCopperWait:
	move.l	d1,-(sp)
	move.b	d0,$0000(a0)
	move.b	d0,$0004(a0)
	move.w	#$00ff,d1
	cmp.w	d1,d0
	ble.s	WDCW_NotOverFF
	move.b	d1,$0000(a0)
	sub.w	d1,d0
WDCW_NotOverFF:
	move.l	(sp)+,d1
	rts
