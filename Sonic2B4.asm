; Sonic 2 Beta 4 Disassembly (Version 1.0) By Esrael L. G. Neto (www.sonichacking.com)
; "Sonic The Hedgehog 2 (Beta 4 - Sep 18,1992,16.26) (hidden-palace.org).bin" Rom by drx (http://www.hidden-palace.org/)
;
; Hidden Palace uses a copy of Hill Top 2's level layout
; Rhinobot's tiles were edited to use another palette
; If you beat CNz and DHz Boss, the drills/catcher will be ejected inwards
; depending on which direction the boss is facing. This also occurs in Sonic 2 Final.
; (I have fixed this in Sonic 2 Delta 0)
;
; Leftovers from the previous build:
; - Rings Layout
; - Uncompressed Hill Top Foreground
; - PLC Pointers
; - Tiles Main Table

  include "macros.asm"
  include "Constants.asm"

; ASSEMBLY OPTIONS:
skipChecksumCheck = 0
;	| If 1, disables the unnecessary (and slow) bootup checksum calculation
;

; Rom Start
		dc.l	System_Stack,EntryPoint,BusError,addressError
		dc.l	IllegalInstr,ZeroDivide,ChkInstr,TrapvInstr
		dc.l	PrivilegeViolation,Trace,Line1010Emu,Line1111Emu
		dc.l	ErrorException,ErrorException,ErrorException,ErrorException
		dc.l	ErrorException,ErrorException,ErrorException,ErrorException
		dc.l	ErrorException,ErrorException,ErrorException,ErrorException
		dc.l	ErrorException,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l	VBlank,ErrorTrap,HBlank,ErrorTrap
		dc.l	ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l	ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l	ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l	ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l	ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l	ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l	ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.l	ErrorTrap,ErrorTrap,ErrorTrap,ErrorTrap
		dc.b    'SEGA MEGA DRIVE '					; console name
		dc.b    '(C)SEGA 1991.APR'					; release date (same as Sonic 1)
		dc.b    'SONIC THE             HEDGEHOG 2                '	; title - domestic
		dc.b    'SONIC THE             HEDGEHOG 2                '	; title - overseas
		dc.b    'GM 00001051-00'                                        ; serial number
Checksum:	dc.w    $264A							; checksum
		dc.b    'J               '                                      ; I/O support
		dc.l    0                                                       ; ROM start
ROMEnd:		dc.l    $FFFFF                                                  ; ROM end (1 MB)
		dc.l    $FF0000							; RAM start
		dc.l    $FFFFFF							; RAM end
		dc.b    '                '					; SRAM support (no SRAM)
		dc.b    '                                                '	; Notes
		dc.b    'JUE             '					; Reigon (Japanese, US, and Europe)
ErrorTrap:
		nop
		nop
		bra.s	ErrorTrap
EntryPoint:
		tst.l	Z80_Port_1_Control
		bne.s	PortA_OK
		tst.w	Z80_Expansion_Control
PortA_OK:
		bne.s	PortC_OK
		lea	InitValues(pc),a5
		movem.w	(a5)+,d5-d7
		movem.l	(a5)+,a0-a4
		move.b	$FFFFEF01(a1),d0
		and.b	#$F,d0
		beq.s	SkipSecurity
		move.l	#'SEGA',$2F00(a1)
SkipSecurity:
		move.w	(a4),d0
		moveq	#0,d0
		move.l	d0,a6
		move.l	a6,USP
		moveq	#$17,d1
VDPInitLoop:
		move.b	(a5)+,d5
		move.w	d5,(a4)
		add.w	d7,d5
		dbra	d1,VDPInitLoop
		move.l	(a5)+,(a4)
		move.w	d0,(a3)
		move.w	d7,(a1)
		move.w	d7,(a2)
WaitForZ80:
		btst D0,(a1)
		bne.s	WaitForZ80
		moveq	#$25,d2
Z80InitLoop:
		move.b	(a5)+,(a0)+
		dbra	d2,Z80InitLoop
		move.w	d0,(a2)
		move.w	d0,(a1)
		move.w	d7,(a2)
ClearRAMLoop:
		move.l	d0,-(a6)
		dbra	d6,ClearRAMLoop
		move.l	(a5)+,(a4)
		move.l	(a5)+,(a4)
		moveq	#$1F,d3
ClearCRAMLoop:
		move.l	d0,(a3)
		dbra	d3,ClearCRAMLoop
		move.l	(a5)+,(a4)
		moveq	#$13,d4
ClearVSRAMLoop:
		move.l	d0,(a3)
		dbra	d4,ClearVSRAMLoop
		moveq	#3,d5
PSGInitLoop:
		move.b	(a5)+,$11(a3)
		dbra	d5,PSGInitLoop
		move.w	d0,(a2)
		movem.l	(a6),d0-a6
		move	#$2700,sr
PortC_OK:
		bra.s	GameProgram
InitValues:
		dc.w	$8000,$3FFF,$100 ; Z80 RAM start	location
		dc.l	Z80_RAM ; Z80 bus request
		dc.l	Z80_Bus_Request ; Z80 reset
		dc.l	Z80_Reset ; VDP data port
		dc.l	VDP_data_port ; VDP control port
		dc.l	VDP_control_port
		dc.w	$414,$303C,$76C,$0,$0,$FF00,$8137,$1
		dc.w	$100,$FF,$FF00,$80,$4000,$80,$AF01,$D91F
		dc.w	$1127,$21,$2600,$F977,$EDB0,$DDE1,$FDE1,$ED47
		dc.w	$ED4F,$D1E1,$F108,$D9C1,$D1E1,$F1F9,$F3ED,$5636
		dc.w	$E9E9,$8104,$8F02,$C000,$0,$4000,$10,$9FBF
		dc.w	$DFFF
GameProgram:
		tst.w	(VDP_control_port)
		btst	#6,($A1000D)
		beq.s	ChecksumCheck
		cmp.l	#'init',(Checksum_fourcc).w
		beq	AlreadyInit
ChecksumCheck:

    if skipChecksumCheck=0	; checksum code
		move.l	#ErrorTrap,a0
		move.l	#ROMEnd,a1
		move.l	(a1),d0
		move.l	#$7FFFF,d0
		moveq	#0,d1
ChksumChkLoop:
		add.w	(a0)+,d1
		cmp.l	a0,d0
		bcc.s	ChksumChkLoop
		move.l	#Checksum,a1
		cmp.w	(a1),d1
		nop     	; checksum error got nop'd out
		nop
    endif
		lea	(System_Stack).w,a6
		moveq	#0,d7
		move.w	#$7F,d6
ClearSomeRAMLoop:
		move.l	d7,(a6)+

		dbra	d6,ClearSomeRAMLoop
		move.b	(Z80_Version),d0
		and.b	#$C0,d0
		move.b	d0,(Graphics_Flags).w
		move.l	#'init',(Checksum_fourcc).w
AlreadyInit:
		lea	($FF0000),a6
		moveq	#0,d7 
		move.w	#$3F7F,d6 
ClearRemainingRAMLoop: 
		move.l	d7,(a6)+ 
		dbra	d6,ClearRemainingRAMLoop 
		bsr.w	VDPRegSetup 
		bsr.w	SoundDriverLoad 
		bsr.w	JoypadInit 
		move.b	#0,(Game_Mode).w
MainGameLoop: 
		move.b	(Game_Mode).w,d0
		and.w	#$1C,d0
		jsr	GameModeArray(pc,d0) 
		bra.s	MainGameLoop 
GameModeArray: 
		bra.w	SegaScreen
		bra.w	TitleScreen 
		bra.w	Level 
		bra.w	Level 
		bra.w	SpecialStage 
		bra.w	Continue 
		bra.w	Go_Versus_Mode_Results 
		bra.w	Go_Versus_Mode_Menu 
    if skipChecksumCheck=0
;===============================================================================
; ChecksumError
;
; Leftover subroutine from Sonic 1 showing a red
; screen when the checksum was	wrong
; [ Begin ]
;===============================================================================
ChecksumError: 
		bsr.w	VDPRegSetup 
		move.l	#$C00000,(VDP_control_port)
		moveq	#$3F,d7
ChksumErr_RedFill: 
		move.w	#$E,(VDP_data_port)
		dbra	d7,ChksumErr_RedFill 
ChksumErr_InfLoop: 
		bra.s	ChksumErr_InfLoop 
;===============================================================================
; ChecksumError
;
; Leftover subroutine from Sonic 1 showing a red
; screen when the checksum was	wrong
; [ End ]
;===============================================================================
    endif
BusError: 
		move.b	#2,($FFFFFC44).w
		bra.s	ErrorMsg_TwoAddresses 
AddressError: 
		move.b	#4,($FFFFFC44).w
		bra.s	ErrorMsg_TwoAddresses 
IllegalInstr: 
		move.b	#6,($FFFFFC44).w
		addq.l	#2,2(sp)
		bra.s	ErrorMessage 
ZeroDivide: 
		move.b	#8,($FFFFFC44).w
		bra.s	ErrorMessage 
ChkInstr: 
		move.b	#$A,($FFFFFC44).w
		bra.s	ErrorMessage 
TrapvInstr: 
		move.b	#$C,($FFFFFC44).w
		bra.s	ErrorMessage 
PrivilegeViolation: 
		move.b	#$E,($FFFFFC44).w
		bra.s	ErrorMessage 
Trace: 
		move.b	#$10,($FFFFFC44).w
		bra.s	ErrorMessage 
Line1010Emu: 
		move.b	#$12,($FFFFFC44).w
		addq.l	#2,2(sp)
		bra.s	ErrorMessage 
Line1111Emu: 
		move.b	#$14,($FFFFFC44).w
		addq.l	#2,2(sp)
		bra.s	ErrorMessage 
ErrorException: 
		move.b	#0,($FFFFFC44).w
		bra.s	ErrorMessage 
ErrorMsg_TwoAddresses: 
		move	#$2700,sr
		addq.w	#2,a7
		move.l	(sp)+,($FFFFFC40).w
		addq.w	#2,a7
		movem.l	d0-d7/a0-a7,($FFFFFC00).w
		bsr.w	ShowErrorMsg 
		move.l	2(sp),d0
		bsr.w	ShowErrAddress 
		move.l	($FFFFFC40).w,d0
		bsr.w	ShowErrAddress 
		bra.s	ErrorMsg_Wait 
ErrorMessage: 
		move	#$2700,sr
		movem.l	d0-d7/a0-a7,($FFFFFC00).w
		bsr.w	ShowErrorMsg 
		move.l	2(sp),d0
		bsr.w	ShowErrAddress
ErrorMsg_Wait: 
		bsr.w	Error_WaitForC
		movem.l	($FFFFFC00).w,d0-d7/a0-a7
		move	#$2300,sr
		rte
ShowErrorMsg: 
		lea	(VDP_data_port),a6
		move.l	#$78000003,(VDP_control_port)
		lea	(art_Menu_Text),a0 
		move.w	#$27F,d1
Error_LoadGfx: 
		move.w	(a0)+,(a6)
		dbra	d1,Error_LoadGfx
		moveq	#0,d0
		move.b	($FFFFFC44).w,d0
		move.w	Error_Text(pc,d0),d0 
		lea	Error_Text(pc,d0),a0 
		move.l	#$46040003,(VDP_control_port)
		moveq	#$12,d1
loc_4C6: 
		moveq	#0,d0
		move.b	(a0)+,d0
		add.w	#$790,d0
		move.w	d0,(a6)
		dbra	d1,loc_4C6
		rts
;--------------------------------------------------------------------------------
Error_Text: 
		dc.w	ErrTxt_Exception-Error_Text
		dc.w	ErrTxt_BusError-Error_Text
		dc.w	ErrTxt_AddressError-Error_Text
		dc.w	ErrTxt_IllegalInstr-Error_Text
		dc.w	ErrTxt_ZeroDivide-Error_Text
		dc.w	ErrTxt_ChkIntruction-Error_Text
		dc.w	ErrTxt_TrapvInstr-Error_Text
		dc.w	ErrTxt_PrivilegeViol-Error_Text
		dc.w	ErrTxt_Trace-Error_Text
		dc.w	ErrTxt_Line1010Emul-Error_Text
		dc.w	ErrTxt_Line1111Emul-Error_Text
ErrTxt_Exception:	dc.b	'ERROR EXCEPTION    '
ErrTxt_BusError: 	dc.b	'BUS ERROR          ' 
ErrTxt_AddressError: 	dc.b	'ADDRESS ERROR      '   
ErrTxt_IllegalInstr: 	dc.b	'ILLEGAL INSTRUCTION' 
ErrTxt_ZeroDivide: 	dc.b	'@ERO DIVIDE        ' 
ErrTxt_ChkIntruction:	dc.b	'CHK INSTRUCTION    '
ErrTxt_TrapvInstr:	dc.b	'TRAPV INSTRUCTION  '
ErrTxt_PrivilegeViol:	dc.b	'PRIVILEGE VIOLATION'
ErrTxt_Trace: 		dc.b	'TRACE              '
ErrTxt_Line1010Emul: 	dc.b	'LINE 1010 EMULATOR '
ErrTxt_Line1111Emul: 	dc.b	'LINE 1111 EMULATOR ' 
		even
ShowErrAddress: 
		move.w	#$7CA,(a6)
		moveq	#7,d2
ShowErrAddress_DigitLoop: 
		rol.l	#4,d0
		bsr.s	ShowErrDigit 
		dbra	d2,ShowErrAddress_DigitLoop 
		rts
;--------------------------------------------------------------------------------
ShowErrDigit: 
		move.w	d0,d1
		and.w	#$F,d1
		cmp.w	#$A,d1
		bcs.s	ShowErrDigit_NoOverflow 
		addq.w	#7,d1
ShowErrDigit_NoOverflow: 
		add.w	#$7C0,d1
		move.w	d1,(a6)
		rts
;--------------------------------------------------------------------------------
Error_WaitForC: 
		bsr.w	ReadJoypads 
		cmp.b	#$20,(Ctrl_1_Press).w
		bne.w	Error_WaitForC
		rts
;--------------------------------------------------------------------------------
Art_Menu_Text:
		incbin 'artunc/art_menu.dat'
		even
Go_Versus_Mode_Menu: 
		jmp	Versus_Mode_Menu 
Go_Versus_Mode_Results: 
		jmp	Versus_Mode_Results 
;===============================================================================
; Sub Routine HBlank
; [ Begin ]
;===============================================================================
HBlank: 
		movem.l	d0-d7/a0-a6,-(sp)
		tst.b	(Delay_Time).w
		beq	loc_B9A
loc_B2C: 
		move.w	(VDP_control_port),d0
		and.w	#8,d0
		beq.s	loc_B2C
		move.l	#$40000010,(VDP_control_port)
		move.l	($FFFFF616).w,(VDP_data_port)
		btst	#6,(Graphics_Flags).w
		beq.s	loc_B5A
		move.w	#$700,d0
loc_B56: 
		dbra	d0,loc_B56
loc_B5A:
		move.b	(Delay_Time).w,d0
		move.b	#0,(Delay_Time).w
		move.w	#1,($FFFFF644).w
		and.w	#$3E,d0
		move.w	loc_B80(pc,d0),d0
		jsr	loc_B80(pc,d0)
loc_B76: 
		addq.l	#1,($FFFFFE0C).w
		movem.l	(sp)+,d0-d7/a0-a6
		rte
loc_B80:
		dc.w	loc_B9A-loc_B80
		dc.w	loc_CFE-loc_B80
		dc.w	loc_D6E-loc_B80
		dc.w	loc_D84-loc_B80
		dc.w	loc_D94-loc_B80
		dc.w	loc_F36-loc_B80
		dc.w	loc_120A-loc_B80
		dc.w	loc_12F8-loc_B80
		dc.w	loc_D8A-loc_B80
		dc.w	loc_1308-loc_B80
		dc.w	loc_D38-loc_B80
		dc.w	loc_1314-loc_B80
		dc.w	loc_1314-loc_B80
loc_B9A:
		cmp.b	#$8C,(Game_Mode).w
		beq.s	loc_BD2
		cmp.b	#8,(Game_Mode).w
		beq.s	loc_BD2
		cmp.b	#$C,(Game_Mode).w
		beq.s	loc_BD2
		
loc_BBA:
		stopZ80
		bsr.w	loc_15A4
		startZ80
		bra.s	loc_B76
loc_BD2:
		tst.b	($FFFFF730).w
		beq	loc_C74
		move.w	(VDP_control_port),d0
		btst	#6,(Graphics_Flags).w
		beq.s	loc_BF0
		move.w	#$700,d0
loc_BEC: 
		dbra	d0,loc_BEC
loc_BF0:
		move.w	#1,($FFFFF644).w
loc_BFE:
		stopZ80
		tst.b	($FFFFF64E).w
		bne.s	loc_C34
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bra.s	loc_C58
loc_C34:
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
loc_C58:
		move.w	($FFFFF624).w,(a5)
		move.w	#$8230,(VDP_control_port)
		bsr.w	loc_15A4
		startZ80
		bra.w	loc_B76
loc_C74:
		move.w	(VDP_control_port),d0
		move.l	#$40000010,(VDP_control_port)
		move.l	($FFFFF616).w,(VDP_data_port)
		btst	#6,(Graphics_Flags).w
		beq.s	loc_C9C
		move.w	#$700,d0
loc_C98: 
		dbra	d0,loc_C98
loc_C9C:
		move.w	#1,($FFFFF644).w
		move.w	($FFFFF624).w,(VDP_control_port)
		move.w	#$8230,(VDP_control_port)
		move.l	($FFFFF61E).w,($FFFFEEEC).w
loc_CC0:
		stopZ80
		lea	(VDP_control_port),a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bsr.w	loc_15A4
		startZ80
		bra.w	loc_B76
loc_CFE:
		bsr.w	loc_13B8
		lea	(VDP_control_port),a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bsr.w	loc_15FA
		tst.w	(Demo_Time_left).w
		beq	loc_D36
		subq.w	#1,(Demo_Time_left).w
loc_D36:
		rts
;--------------------------------------------------------------------------------
loc_D38:
		move.b	($FFFFFE0F).w,d0
		and.w	#$F,d0
		bne.s	loc_D60
loc_D4A:
		stopZ80
		bsr.w	ReadJoypads 
		startZ80
loc_D60:
		tst.w	(Demo_Time_left).w
		beq	loc_D6C
		subq.w	#1,(Demo_Time_left).w
loc_D6C:
		rts
;--------------------------------------------------------------------------------
loc_D6E:
		bsr.w	loc_13B8
		bsr.w	loc_1BDC
		tst.w	(Demo_Time_left).w
		beq	loc_D82
		subq.w	#1,(Demo_Time_left).w
loc_D82:
		rts
;--------------------------------------------------------------------------------
loc_D84:
		bsr.w	loc_13B8
		rts
;--------------------------------------------------------------------------------
loc_D8A:
		cmp.b	#$10,(Game_Mode).w
		beq	loc_F10
loc_D94:
loc_D9C:
		stopZ80
		bsr.w	ReadJoypads 
		tst.b	($FFFFF622).w
		beq.s	loc_E06
		lea	(VDP_control_port),a5
		tst.w	(Game_paused).w
		bne.w	loc_E56
		subq.b	#1,($FFFFF622).w
		bne.s	loc_DCA
		move.b	#0,($FFFFF623).w
loc_DCA:
		cmp.b	#$10,($FFFFF622).w
		bcs.s	loc_E06
		lea	(VDP_data_port),a6
		move.l	#$C00000,(VDP_control_port)
		move.w	#$EEE,d0
		move.w	#$1F,d1
loc_DEA: 
		move.w	d0,(a6)
		dbra	d1,loc_DEA
		move.l	#$C0420000,(VDP_control_port)
		move.w	#$1F,d1
loc_DFE: 
		move.w	d0,(a6)
		dbra	d1,loc_DFE
		bra.s	loc_E56
loc_E06:
		tst.b	($FFFFF64E).w
		bne.s	loc_E32
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bra.s	loc_E56
loc_E32:
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
loc_E56:
		move.w	($FFFFF624).w,(a5)
		move.w	#$8230,(VDP_control_port)
		lea	(VDP_control_port),a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		lea	(VDP_control_port),a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bsr.w	Process_DMA 
		bsr.w	loc_15A4
		startZ80
		movem.l	($FFFFEE00).w,d0-d7
		movem.l	d0-d7,($FFFFEE60).w
		movem.l	($FFFFEE20).w,d0-d7
		movem.l	d0-d7,($FFFFEE80).w
		movem.l	($FFFFEE50).w,d0-d3
		movem.l	d0-d3,($FFFFEEA0).w
		move.l	($FFFFF61E).w,($FFFFEEEC).w
		cmp.b	#$5C,($FFFFF625).w
		bcc.s	DemoTime
		move.b	#1,($FFFFF64F).w
		rts
;--------------------------------------------------------------------------------
DemoTime:
		bsr.w	J_LoadTilesAsYouMove 
		jsr	HudUpdate 
		bsr.w	loc_1BF8
		tst.w	(Demo_Time_left).w
		beq	DemoTime_End 
		subq.w	#1,(Demo_Time_left).w
DemoTime_End: 
		rts
;--------------------------------------------------------------------------------
loc_F10:
loc_F18:
		stopZ80
		bsr.w	ReadJoypads 
		jsr	(loc_15A4)
		startZ80
		rts
;--------------------------------------------------------------------------------
loc_F36:
loc_F3E:
		stopZ80
		bsr.w	ReadJoypads 
		bsr.w	loc_11A6
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		lea	(VDP_control_port),a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		tst.b	($FFFFDB0F).w
		beq.s	loc_FC4
		lea	(VDP_control_port),a5
		move.l	#$940193C0,(a5)
		move.l	#$96EB9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bra.s	loc_FE8
loc_FC4:
		lea	(VDP_control_port),a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
loc_FE8:
		tst.b	($FFFFDB0E).w
		beq.s	loc_100E
		moveq	#0,d0
		move.b	($FFFFDB0D).w,d0
		cmp.b	#4,d0
		bge.s	loc_100E
		add.b	d0,d0
		tst.b	($FFFFDB0C).w
		beq.s	loc_1006
		add.w	#8,d0
loc_1006:
		move.w	loc_1038(pc,d0),d0
		jsr	loc_1038(pc,d0)
loc_100E:
		bsr.w	loc_11BE
		add.b	#1,($FFFFDB0D).w
		move.b	($FFFFDB0D).w,d0
		cmp.b	d1,d0
		blt.s	loc_1052
		move.b	#0,($FFFFDB0D).w
		lea	(VDP_control_port),a6
		tst.b	($FFFFDB0C).w
		beq.s	loc_1048
		move.w	#$8230,(a6)
		bra.s	loc_104C
loc_1038:
		dc.w	loc_110E-loc_1038
		dc.w	loc_1134-loc_1038
		dc.w	loc_115A-loc_1038
		dc.w	loc_1180-loc_1038
		dc.w	loc_1076-loc_1038
		dc.w	loc_109C-loc_1038
		dc.w	loc_10C2-loc_1038
		dc.w	loc_10E8-loc_1038
loc_1048:
		move.w	#$8220,(a6)
loc_104C:
		eor.b	#1,($FFFFDB0C).w
loc_1052:
		bsr.w	Process_DMA 
		jsr	(loc_15A4)
		startZ80
		bsr.w	loc_1BF8
		tst.w	(Demo_Time_left).w
		beq	loc_1074
		subq.w	#1,(Demo_Time_left).w
loc_1074:
		rts
;--------------------------------------------------------------------------------
loc_1076:
		lea	(VDP_control_port),a5
		move.l	#$94039380,(a5)
		move.l	#$96E89500,(a5)
		move.w	#$977F,(a5)
		move.w	#$4000,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		rts
;--------------------------------------------------------------------------------
loc_109C:
		lea	(VDP_control_port),a5
		move.l	#$94039380,(a5)
		move.l	#$96E89500,(a5)
		move.w	#$977F,(a5)
		move.w	#$4700,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		rts
;--------------------------------------------------------------------------------
loc_10C2:
		lea	(VDP_control_port),a5
		move.l	#$94039380,(a5)
		move.l	#$96E89500,(a5)
		move.w	#$977F,(a5)
		move.w	#$4E00,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		rts
;--------------------------------------------------------------------------------
loc_10E8:
		lea	(VDP_control_port),a5
		move.l	#$94039380,(a5)
		move.l	#$96E89500,(a5)
		move.w	#$977F,(a5)
		move.w	#$5500,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		rts
;--------------------------------------------------------------------------------
loc_110E:
		lea	(VDP_control_port),a5
		move.l	#$94039380,(a5)
		move.l	#$96E89500,(a5)
		move.w	#$977F,(a5)
		move.w	#$4000,(a5)
		move.w	#$82,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		rts
;--------------------------------------------------------------------------------
loc_1134:
		lea	(VDP_control_port),a5
		move.l	#$94039380,(a5)
		move.l	#$96E89500,(a5)
		move.w	#$977F,(a5)
		move.w	#$4700,(a5)
		move.w	#$82,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		rts
;--------------------------------------------------------------------------------
loc_115A:
		lea	(VDP_control_port),a5
		move.l	#$94039380,(a5)
		move.l	#$96E89500,(a5)
		move.w	#$977F,(a5)
		move.w	#$4E00,(a5)
		move.w	#$82,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		rts
;--------------------------------------------------------------------------------
loc_1180:
		lea	(VDP_control_port),a5
		move.l	#$94039380,(a5)
		move.l	#$96E89500,(a5)
		move.w	#$977F,(a5)
		move.w	#$5500,(a5)
		move.w	#$82,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		rts
;--------------------------------------------------------------------------------
loc_11A6:
		moveq	#0,d0
		move.w	($FFFFDB30).w,d0
		move.l	#$40000010,(VDP_control_port)
		move.l	d0,(VDP_data_port)
		rts
;--------------------------------------------------------------------------------
loc_11BE:
		move.w	($FFFFDB16).w,d0
		cmp.w	($FFFFDB12).w,d0
		beq.s	loc_11D4
		move.l	($FFFFDB12).w,($FFFFDB16).w
		move.b	#0,($FFFFDB1F).w
loc_11D4:
		sub.b	#1,($FFFFDB1F).w
		bgt.s	loc_11FA
		lea	(loc_1202),a0
		move.w	($FFFFDB16).w,d0
		lsr.w	#1,d0
		move.b	0(a0,d0),d1
		move.b	d1,($FFFFDB21).w
		move.b	d1,($FFFFDB1F).w
		subq.b	#1,($FFFFDB21).w
		rts
;--------------------------------------------------------------------------------
loc_11FA:
		move.b	($FFFFDB21).w,d1
		addq.b	#1,d1
		rts
;--------------------------------------------------------------------------------
loc_1202:
		dc.b	$3C,$1E,$F,$A,$8,$6,$5,$0
loc_120A:
loc_1212:
		stopZ80
		bsr.w	ReadJoypads 
		tst.b	($FFFFF64E).w
		bne.s	loc_124C
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bra.s	loc_1270
loc_124C:
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
loc_1270:
		move.w	($FFFFF624).w,(a5)
		lea	(VDP_control_port),a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		lea	(VDP_control_port),a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bsr.w	Process_DMA 
		jsr	Load_Title_Cards_Mappings 
		jsr	(loc_15A4)
		startZ80
		movem.l	($FFFFEE00).w,d0-d7
		movem.l	d0-d7,($FFFFEE60).w
		movem.l	($FFFFEE50).w,d0/d1
		movem.l	d0/d1,($FFFFEEA0).w
		move.l	($FFFFF61E).w,($FFFFEEEC).w
		bsr.w	loc_1BDC
		rts
;--------------------------------------------------------------------------------
loc_12F8:
		bsr.w	loc_13B8
		addq.b	#1,($FFFFF628).w
		move.b	#$E,(Delay_Time).w
		rts
;--------------------------------------------------------------------------------
loc_1308:
		bsr.w	loc_13B8
		move.w	($FFFFF624).w,(a5)
		bra.w	loc_1BDC
loc_1314:
loc_131C:
		stopZ80
		bsr.w	ReadJoypads 
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		lea	(VDP_control_port),a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		lea	(VDP_control_port),a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bsr.w	Process_DMA 
		bsr.w	loc_15A4
		startZ80
		bsr.w	loc_1BDC
		tst.w	(Demo_Time_left).w
		beq	loc_13B6
		subq.w	#1,(Demo_Time_left).w
loc_13B6:
		rts
;--------------------------------------------------------------------------------
loc_13B8:
loc_13C0:
		stopZ80
		bsr.w	ReadJoypads 
		tst.b	($FFFFF64E).w
		bne.s	loc_13FA
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bra.s	loc_141E
loc_13FA:
		lea	(VDP_control_port),a5
		move.l	#$94009340,(a5)
		move.l	#$96FD9540,(a5)
		move.w	#$977F,(a5)
		move.w	#$C000,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
loc_141E:
		lea	(VDP_control_port),a5
		move.l	#$94019340,(a5)
		move.l	#$96FC9500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		lea	(VDP_control_port),a5
		move.l	#$940193C0,(a5)
		move.l	#$96F09500,(a5)
		move.w	#$977F,(a5)
		move.w	#$7C00,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		bsr.w	loc_15A4
		startZ80
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine HBlank
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine VBlank
; [ Begin ]
;===============================================================================
VBlank: 
		tst.w	($FFFFF644).w
		beq	loc_151E
		tst.w	($FFFFFFD8).w
		beq	VBlank_Not2pMode 
		move.w	#0,($FFFFF644).w
		move.l	a5,-(sp)
		move.l	d0,-(sp)
loc_148E: 
		move.w	(VDP_control_port),d0
		and.w	#4,d0
		beq.s	loc_148E
		move.w	(VDP_Reg0_Val).w,d0
		and.b	#$BF,d0
		move.w	d0,(VDP_control_port)
		move.w	#$8228,(VDP_control_port)
		move.l	#$40000010,(VDP_control_port)
		move.l	($FFFFEEEC).w,(VDP_data_port)
loc_14CA:
		stopZ80
		lea	(VDP_control_port),a5
		move.l	#$94019340,(a5)
		move.l	#$96EE9580,(a5)
		move.w	#$977F,(a5)
		move.w	#$7800,(a5)
		move.w	#$83,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		startZ80
loc_1500: 
		move.w	(VDP_control_port),d0
		and.w	#4,d0
		beq.s	loc_1500
		move.w	(VDP_Reg0_Val).w,d0
		or.b	#$40,d0
		move.w	d0,(VDP_control_port)
		move.l	(sp)+,d0
		move.l	(sp)+,a5
loc_151E:
		rte
VBlank_Not2pMode: 
		move	#$2700,sr
		move.w	#0,($FFFFF644).w
		movem.l	a0/a1,-(sp)
		lea	(VDP_data_port),a1
		lea	($FFFFFA80).w,a0
		move.l	#$C00000,4(a1)
		rept 32
		move.l	(a0)+,(a1)
		endr
		move.w	#$8ADF,4(a1)
		movem.l	(sp)+,a0/a1
		tst.b	($FFFFF64F).w
		bne.s	loc_1592
		rte
loc_1592:
		clr.b	($FFFFF64F).w
		movem.l	d0-d7/a0-a6,-(sp)
		bsr.w	DemoTime 
		movem.l	(sp)+,d0-d7/a0-a6
		rte
loc_15A4:
		lea	($FFFFE0),a0
		lea	($A01B80),a1
		cmp.b	#$80,8(a1)
		bne.s	loc_15D8
		move.b	0(a0),d0
		beq.s	loc_15D8
		clr.b	0(a0)
		move.b	d0,d1
		sub.b	#$FE,d1
		bcs.s	loc_15D4
		add.b	#$7F,d1
		move.b	d1,3(a1)
		bra.s	loc_15D8
loc_15D4:
		move.b	d0,8(a1)
loc_15D8:
		moveq	#3,d1
loc_15DA: 
		move.b	1(a0,d1),d0
		beq.s	loc_15EE
		tst.b	9(a1,d1)
		bne.s	loc_15EE
		clr.b	1(a0,d1)
		move.b	d0,9(a1,d1)
loc_15EE:
		dbra	d1,loc_15DA
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine VBlank
; [ End ]
;=============================================================================== 
J_LoadTilesAsYouMove: 
		jmp	LoadTilesAsYouMove 
loc_15FA:
		jmp	(loc_36798) 
;===============================================================================
; Sub Routine JoypadInit
; [ Begin ]
;=============================================================================== 
JoypadInit: 
		stopZ80
		moveq	#$40,d0
		move.b	d0,($A10009)
		move.b	d0,($A1000B)
		move.b	d0,($A1000D)
		startZ80
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine JoypadInit
; [ End ]
;===============================================================================
		 
;===============================================================================
; Sub Routine JoypadInit
; [ Begin ]
;=============================================================================== 
ReadJoypads: 
		lea	(Ctrl_1).w,a0
		lea	($A10003),a1
		bsr.s	Joypad_Read 
		addq.w	#2,a1
Joypad_Read: 
		move.b	#0,(a1)
		nop
		nop
		move.b	(a1),d0
		lsl.b	#2,d0
		and.b	#$C0,d0
		move.b	#$40,(a1)
		nop
		nop
		move.b	(a1),d1
		and.b	#$3F,d1
		or.b	d1,d0
		not.b	d0
		move.b	(a0),d1
		eor.b	d0,d1
		move.b	d0,(a0)+
		and.b	d0,d1
		move.b	d1,(a0)+
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine VDPRegSetup
; [ Begin ]
;=============================================================================== 
VDPRegSetup: 
		lea	(VDP_control_port),a0
		lea	(VDP_data_port),a1
		lea	(VDPRegSetup_Array),a2 
		moveq	#$12,d7
VDPRegSetup_Loop: 
		move.w	(a2)+,(a0)
		dbra	d7,VDPRegSetup_Loop 
		move.w	(VDPReg_01),d0 
		move.w	d0,(VDP_Reg0_Val).w
		move.w	#$8ADF,($FFFFF624).w
		moveq	#0,d0
		move.l	#$40000010,(VDP_control_port)
		move.w	d0,(a1)
		move.w	d0,(a1)
		move.l	#$C00000,(VDP_control_port)
		move.w	#$3F,d7
VDPRegSetup_ClearCRAM: 
		move.w	d0,(a1)
		dbra	d7,VDPRegSetup_ClearCRAM 
		clr.l	($FFFFF616).w
		clr.l	($FFFFF61A).w
		move.l	d1,-(sp)
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$94FF93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000080,(a5)
		move.w	#0,(VDP_data_port)
VDPRegSetup_DMAWait: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	VDPRegSetup_DMAWait 
		move.w	#$8F02,(a5)
		move.l	(sp)+,d1
		rts
;--------------------------------------------------------------------------------
VDPRegSetup_Array: 
		dc.w	$8004
VDPReg_01: 
		dc.w	$8134,$8230,$8328,$8407,$857C,$8600,$8700,$8800
		dc.w	$8900,$8A00,$8B00,$8C81,$8D3F,$8E00,$8F02,$9001
		dc.w	$9100,$9200
;===============================================================================
; Sub Routine ClearScreen
; [ Begin ]
;=============================================================================== 
ClearScreen:
		stopZ80
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$9400933F,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000080,(a5)
		move.w	#0,(VDP_data_port)
ClearScreen_DMAWait: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	ClearScreen_DMAWait 
		move.w	#$8F02,(a5)
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000083,(a5)
		move.w	#0,(VDP_data_port)
ClearScreen_DMA2Wait: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	ClearScreen_DMA2Wait 
		move.w	#$8F02,(a5)
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$60000083,(a5)
		move.w	#0,(VDP_data_port)
loc_17AC: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_17AC
		move.w	#$8F02,(a5)
		tst.w	($FFFFFFD8).w
		beq.s	loc_17EC
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$940F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$60000082,(a5)
		move.w	#0,(VDP_data_port)
loc_17E0: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_17E0
		move.w	#$8F02,(a5)
loc_17EC:
		clr.l	($FFFFF616).w
		clr.l	($FFFFF61A).w
		lea	($FFFFF800).w,a1
		moveq	#0,d0
		move.w	#$A0,d1
ClearScreen_ClearBuffer1: 
		move.l	d0,(a1)+
		dbra	d1,ClearScreen_ClearBuffer1 
		lea	($FFFFE000).w,a1
		moveq	#0,d0
		move.w	#$100,d1
ClearScreen_ClearBuffer2: 
		move.l	d0,(a1)+
		dbra	d1,ClearScreen_ClearBuffer2 
		startZ80
		rts
;--------------------------------------------------------------------------------
SoundDriverLoad: 
		nop
		jmp	Sound_Driver 
		; These lines are unused
		move.w	#$100,(Z80_Bus_Request)
		move.w	#$100,(Z80_Reset)
		lea	(Z80_RAM),a1
		move.b	#$F3,(a1)+
		move.b	#$F3,(a1)+
		move.b	#$C3,(a1)+
		move.b	#0,(a1)+
		move.b	#0,(a1)+
		move.w	#0,(Z80_Reset)
		nop
		nop
		nop
		nop
		move.w	#$100,(Z80_Reset)
		move.w	#0,(Z80_Bus_Request)
		rts
;--------------------------------------------------------------------------------
Play_Music: 
		move.b	d0,(Music_to_play).w
		rts
;--------------------------------------------------------------------------------
Play_Sfx:
		move.b	d0,(SFX_to_play).w
		rts
;--------------------------------------------------------------------------------
Play_Unknow: 
		move.b	d0,(SFX_to_play_2).w
		rts
;--------------------------------------------------------------------------------
Play_Sfx_Ex:
		tst.b	render_flags(a0)
		bpl.s	loc_188E
		move.b	d0,(SFX_to_play).w
loc_188E:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pause
; [ Begin ]
;=============================================================================== 
Pause: 
		nop 
		tst.b	(Life_count).w
		beq	Unpause 
		tst.w	(Game_paused).w
		bne.s	Pause_AlreadyPaused 
		btst	#7,(Ctrl_1_Press).w
		beq.s	Pause_DoNothing 
Pause_AlreadyPaused: 
		move.w	#1,(Game_paused).w
		move.b	#$FE,(Music_to_play).w
Pause_Loop: 
		move.b	#$10,(Delay_Time).w
		bsr.w	DelayProgram 
		tst.b	($FFFFFFD1).w
		beq.s	Pause_CheckStart 
		btst	#6,(Ctrl_1_Press).w
		beq.s	Pause_CheckBC 
		move.b	#4,(Game_Mode).w
		nop
		bra.s	loc_18EE
Pause_CheckBC: 
		btst	#4,(Ctrl_1_Held).w
		bne.s	loc_18FC
		btst	#5,(Ctrl_1_Press).w
		bne.s	loc_18FC
Pause_CheckStart: 
		btst	#7,(Ctrl_1_Press).w
		beq.s	Pause_Loop 
loc_18EE:
		move.b	#$FF,(Music_to_play).w
Unpause: 
		move.w	#0,(Game_paused).w
Pause_DoNothing: 
		rts
;--------------------------------------------------------------------------------
loc_18FC:
		move.w	#1,(Game_paused).w
		move.b	#$FF,(Music_to_play).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pause
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine ShowVDPGraphics
; [ Begin ]
;=============================================================================== 
ShowVDPGraphics: 
		lea	(VDP_data_port),a6
		move.l	#$800000,d4
ShowVDPGraphics_LineLoop: 
		move.l	d0,4(a6)
		move.w	d1,d3
ShowVDPGraphics_TileLoop: 
		move.w	(a1)+,(a6)
		dbra	d3,ShowVDPGraphics_TileLoop 
		add.l	d4,d0
		dbra	d2,ShowVDPGraphics_LineLoop 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine ShowVDPGraphics
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine ShowVDPGraphics_SS
; [ Begin ]
;=============================================================================== 
ShowVDPGraphics_SS: 
		lea	(VDP_data_port),a6
		move.l	#$1000000,d4
ShowVDPGraphicsSS_TileLoop: 
		move.l	d0,4(a6)
		move.w	d1,d3
ShowVDPGraphicsSS_LineLoop: 
		move.w	(a1)+,(a6)
		dbra	d3,ShowVDPGraphicsSS_LineLoop 
		add.l	d4,d0
		dbra	d2,ShowVDPGraphicsSS_TileLoop 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine ShowVDPGraphics_SS
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine DMA_68KtoVRAM 
; [ Begin ]
;=============================================================================== 
DMA_68KtoVRAM: 
		move.l	($FFFFDCFC).w,a1
		cmp.w	#$DCFC,a1
		beq.s	DMA_68KtoVRAM_NoDMA 
		move.w	#$9300,d0
		move.b	d3,d0
		move.w	d0,(a1)+
		move.w	#$9400,d0
		lsr.w	#8,d3
		move.b	d3,d0
		move.w	d0,(a1)+
		move.w	#$9500,d0
		lsr.l	#1,d1
		move.b	d1,d0
		move.w	d0,(a1)+
		move.w	#$9600,d0
		lsr.l	#8,d1
		move.b	d1,d0
		move.w	d0,(a1)+
		move.w	#$9700,d0
		lsr.l	#8,d1
		move.b	d1,d0
		move.w	d0,(a1)+
		and.l	#$FFFF,d2
		lsl.l	#2,d2
		lsr.w	#2,d2
		swap.w	d2
		or.l	#$40000080,d2
		move.l	d2,(a1)+
		move.l	a1,($FFFFDCFC).w
		cmp.w	#$DCFC,a1
		beq.s	DMA_68KtoVRAM_NoDMA 
		move.w	#0,(a1)
DMA_68KtoVRAM_NoDMA: 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine DMA_68KtoVRAM 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Process_DMA 
; [ Begin ]
;=============================================================================== 
Process_DMA: 
		lea	(VDP_control_port),a5
		lea	($FFFFDC00).w,a1
Process_DMA_Loop: 
		move.w	(a1)+,d0
		beq.s	Process_DMA_End 
		move.w	d0,(a5)
		move.w	(a1)+,(a5)
		move.w	(a1)+,(a5)
		move.w	(a1)+,(a5)
		move.w	(a1)+,(a5)
		move.w	(a1)+,(a5)
		move.w	(a1)+,(a5)
		cmp.w	#$DCFC,a1
		bne.s	Process_DMA_Loop 
Process_DMA_End: 
		move.w	#0,($FFFFDC00).w
		move.l	#$FFFFDC00,($FFFFDCFC).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Process_DMA 
; [ End ]
;=============================================================================== 
		
;===============================================================================
; Sub Routine NemesisDec
; [ Begin ] 
;=============================================================================== 
NemesisDec: 
		movem.l	d0-d7/a0/a1/a3-a5,-(sp)
		lea	(NemesisDec_Output),a3
		lea	(VDP_data_port),a4
		bra.s	loc_19F6
NemesisDec_ToRAM: 
		movem.l	d0-d7/a0/a1/a3-a5,-(sp)
		lea	(NemesisDec_OutputRAM),a3 
loc_19F6:
		lea	($FFFFAA00).w,a1
		move.w	(a0)+,d2
		lsl.w	#1,d2
		bcc.s	loc_1A04
		add.w	#$A,a3
loc_1A04:
		lsl.w	#2,d2
		move.w	d2,a5
		moveq	#8,d3
		moveq	#0,d2
		moveq	#0,d4
		bsr.w	NemesisDec4 
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		move.w	#$10,d6
		bsr.s	loc_1A24
		movem.l	(sp)+,d0-d7/a0/a1/a3-a5
		rts
;--------------------------------------------------------------------------------
loc_1A24:
		move.w	d6,d7
		subq.w	#8,d7
		move.w	d5,d1
		lsr.w	d7,d1
		cmp.b	#$FC,d1
		bcc.s	loc_1A70
		and.w	#$FF,d1
		add.w	d1,d1
		move.b	0(a1,d1),d0
		ext.w	d0
		sub.w	d0,d6
		cmp.w	#9,d6
		bcc.s	loc_1A4C
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
loc_1A4C:
		move.b	1(a1,d1),d1
		move.w	d1,d0
		and.w	#$F,d1
		and.w	#$F0,d0
loc_1A5A: 
		lsr.w	#4,d0
loc_1A5C: 
		lsl.l	#4,d4
		or.b	d1,d4
		subq.w	#1,d3
		bne.s	loc_1A6A
		jmp	(a3)
;===============================================================================
; Sub Routine NemesisDec
; [ End ] 
;===============================================================================

;===============================================================================
; Sub Routine NemesisDec3
; [ Begin ] 
;=============================================================================== 
NemesisDec3: 
		moveq	#0,d4
		moveq	#8,d3
loc_1A6A:
		dbra	d0,loc_1A5C
		bra.s	loc_1A24
loc_1A70:
		subq.w	#6,d6
		cmp.w	#9,d6
		bcc.s	loc_1A7E
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
loc_1A7E:
		subq.w	#7,d6
		move.w	d5,d1
		lsr.w	d6,d1
		move.w	d1,d0
		and.w	#$F,d1
		and.w	#$70,d0
		cmp.w	#9,d6
		bcc.s	loc_1A5A
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
		bra.s	loc_1A5A
;===============================================================================
; Sub Routine NemesisDec3
; [ End ] 
;=============================================================================== 
NemesisDec_Output: 
		move.l	d4,(a4)
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemesisDec3 
		rts
;--------------------------------------------------------------------------------
; NemesisDec_Output_XOR: 
		eor.l	d4,d2
		move.l	d2,(a4)
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemesisDec3 
		rts
;--------------------------------------------------------------------------------
NemesisDec_OutputRAM: 
		move.l	d4,(a4)+
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemesisDec3 
		rts
;--------------------------------------------------------------------------------
; NemesisDec_OutputRAM_XOR: 
		eor.l	d4,d2
		move.l	d2,(a4)+
		subq.w	#1,a5
		move.w	a5,d4
		bne.s	NemesisDec3 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine NemesisDec4
; [ Begin ] 
;=============================================================================== 
NemesisDec4: 
		move.b	(a0)+,d0
loc_1ACA: 
		cmp.b	#$FF,d0
		bne.s	loc_1AD2
		rts
;--------------------------------------------------------------------------------
loc_1AD2:
		move.w	d0,d7
loc_1AD4: 
		move.b	(a0)+,d0
		cmp.b	#$80,d0
		bcc.s	loc_1ACA
		move.b	d0,d1
		and.w	#$F,d7
		and.w	#$70,d1
		or.w	d1,d7
		and.w	#$F,d0
		move.b	d0,d1
		lsl.w	#8,d1
		or.w	d1,d7
		moveq	#8,d1
		sub.w	d0,d1
		bne.s	loc_1B02
		move.b	(a0)+,d0
		add.w	d0,d0
		move.w	d7,0(a1,d0)
		bra.s	loc_1AD4
loc_1B02:
		move.b	(a0)+,d0
		lsl.w	d1,d0
		add.w	d0,d0
		moveq	#1,d5
		lsl.w	d1,d5
		subq.w	#1,d5
loc_1B0E: 
		move.w	d7,0(a1,d0)
		addq.w	#2,d0
		dbra	d5,loc_1B0E
		bra.s	loc_1AD4
;===============================================================================
; Sub Routine NemesisDec4
; [ End ] 
;=============================================================================== 

;===============================================================================
; Sub Routine LoadPLC
; [ Begin ] 
;=============================================================================== 
LoadPLC: 
		movem.l	a1/a2,-(sp)
		lea	(ArtLoadCues),a1 
		add.w	d0,d0
		move.w	0(a1,d0),d0
		lea	0(a1,d0),a1
		lea	(Plc_Buffer).w,a2
loc_1B32: 
		tst.l	(a2)
		beq.s	loc_1B3A
		addq.w	#6,a2
		bra.s	loc_1B32
loc_1B3A:
		move.w	(a1)+,d0
		bmi.s	loc_1B46
loc_1B3E: 
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbra	d0,loc_1B3E
loc_1B46:
		movem.l	(sp)+,a1/a2
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine LoadPLC
; [ End ] 
;=============================================================================== 
		
;===============================================================================
; Sub Routine LoadPLC2
; [ Begin ] 
;=============================================================================== 
LoadPLC2: 
		movem.l	a1/a2,-(sp)
		lea	(ArtLoadCues),a1 
		add.w	d0,d0
		move.w	0(a1,d0),d0
		lea	0(a1,d0),a1
		bsr.s	ClearPLC 
		lea	(Plc_Buffer).w,a2
		move.w	(a1)+,d0
		bmi.s	loc_1B72
loc_1B6A: 
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		dbra	d0,loc_1B6A
loc_1B72:
		movem.l	(sp)+,a1/a2
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine LoadPLC2
; [ End ] 
;=============================================================================== 
		
;===============================================================================
; Sub Routin ClearPLC
; [ Begin ]
;=============================================================================== 
ClearPLC: 
		lea	(Plc_Buffer).w,a2
		moveq	#$1F,d0
loc_1B7E: 
		clr.l	(a2)+
		dbra	d0,loc_1B7E
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routin ClearPLC
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routin RunPLC
; [ Begin ]
;=============================================================================== 
RunPLC: 
		tst.l	(Plc_Buffer).w
		beq.s	loc_1BDA
		tst.w	($FFFFF6F8).w
		bne.s	loc_1BDA
		move.l	(Plc_Buffer).w,a0
		lea	NemesisDec_Output(pc),a3 
		nop
		lea	($FFFFAA00).w,a1
		move.w	(a0)+,d2
		bpl.s	loc_1BA8
		add.w	#$A,a3
loc_1BA8:
		and.w	#$7FFF,d2
		move.w	d2,($FFFFF6F8).w
		bsr.w	NemesisDec4 
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
		moveq	#0,d0
		move.l	a0,(Plc_Buffer).w
		move.l	a3,($FFFFF6E0).w
		move.l	d0,($FFFFF6E4).w
		move.l	d0,($FFFFF6E8).w
		move.l	d0,($FFFFF6EC).w
		move.l	d5,($FFFFF6F0).w
		move.l	d6,($FFFFF6F4).w
loc_1BDA:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routin RunPLC
; [ End ]
;=============================================================================== 
loc_1BDC:
		tst.w	($FFFFF6F8).w
		beq	loc_1C74
		move.w	#6,($FFFFF6FA).w
		moveq	#0,d0
		move.w	($FFFFF684).w,d0
		add.w	#$C0,($FFFFF684).w
		bra.s	loc_1C10
loc_1BF8: 
		tst.w	($FFFFF6F8).w
		beq.s	loc_1C74
		move.w	#3,($FFFFF6FA).w
		moveq	#0,d0
		move.w	($FFFFF684).w,d0
		add.w	#$60,($FFFFF684).w
loc_1C10:
		lea	(VDP_control_port),a4
		lsl.l	#2,d0
		lsr.w	#2,d0
		or.w	#$4000,d0
		swap.w	d0
		move.l	d0,(a4)
		subq.w	#4,a4
		move.l	(Plc_Buffer).w,a0
		move.l	($FFFFF6E0).w,a3
		move.l	($FFFFF6E4).w,d0
		move.l	($FFFFF6E8).w,d1
		move.l	($FFFFF6EC).w,d2
		move.l	($FFFFF6F0).w,d5
		move.l	($FFFFF6F4).w,d6
		lea	($FFFFAA00).w,a1
loc_1C44: 
		move.w	#8,a5
		bsr.w	NemesisDec3 
		subq.w	#1,($FFFFF6F8).w
		beq.s	loc_1C76
		subq.w	#1,($FFFFF6FA).w
		bne.s	loc_1C44
		move.l	a0,(Plc_Buffer).w
		move.l	a3,($FFFFF6E0).w
		move.l	d0,($FFFFF6E4).w
		move.l	d1,($FFFFF6E8).w
		move.l	d2,($FFFFF6EC).w
		move.l	d5,($FFFFF6F0).w
		move.l	d6,($FFFFF6F4).w
loc_1C74:
		rts
;--------------------------------------------------------------------------------
loc_1C76:
		lea	(Plc_Buffer).w,a0
		moveq	#$15,d0
loc_1C7C: 
		move.l	6(a0),(a0)+
		dbra	d0,loc_1C7C
		rts
;--------------------------------------------------------------------------------
		
;===============================================================================
; Sub Routin RunPLC_ROM
; [ Begin ]
;=============================================================================== 
RunPLC_ROM: 
		lea	(ArtLoadCues),a1 
		add.w	d0,d0
		move.w	0(a1,d0),d0
		lea	0(a1,d0),a1
		move.w	(a1)+,d1
loc_1C98: 
		move.l	(a1)+,a0
		moveq	#0,d0
		move.w	(a1)+,d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		or.w	#$4000,d0
		swap.w	d0
		move.l	d0,(VDP_control_port)
		bsr.w	NemesisDec 
		dbra	d1,loc_1C98
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routin RunPLC_ROM
; [ End ]
;===============================================================================
 
;===============================================================================
; Sub Routine EnigmaDec
; [ Begin ] 
;=============================================================================== 
EnigmaDec:
		movem.l	d0-d7/a1-a5,-(sp)
		move.w	d0,a3
		move.b	(a0)+,d0
		ext.w	d0
		move.w	d0,a5
		move.b	(a0)+,d4
		lsl.b	#3,d4
		move.w	(a0)+,a2
		add.w	a3,a2
		move.w	(a0)+,a4
		add.w	a3,a4
		move.b	(a0)+,d5
		asl.w	#8,d5
		move.b	(a0)+,d5
		moveq	#$10,d6
loc_1CD8: 
		moveq	#7,d0
		move.w	d6,d7
		sub.w	d0,d7
		move.w	d5,d1
		lsr.w	d7,d1
		and.w	#$7F,d1
		move.w	d1,d2
		cmp.w	#$40,d1
		bcc.s	loc_1CF2
		moveq	#6,d0
		lsr.w	#1,d2
loc_1CF2:
		bsr.w	loc_1E26
		and.w	#$F,d2
		lsr.w	#4,d1
		add.w	d1,d1
		jmp	loc_1D4E(pc,d1)
loc_1D02: 
		move.w	a2,(a1)+
		addq.w	#1,a2
		dbra	d2,loc_1D02
		bra.s	loc_1CD8
loc_1D0C: 
		move.w	a4,(a1)+
		dbra	d2,loc_1D0C
		bra.s	loc_1CD8
loc_1D14: 
		bsr.w	loc_1D76
loc_1D18: 
		move.w	d1,(a1)+
		dbra	d2,loc_1D18
		bra.s	loc_1CD8
loc_1D20: 
		bsr.w	loc_1D76
loc_1D24: 
		move.w	d1,(a1)+
		addq.w	#1,d1
		dbra	d2,loc_1D24
		bra.s	loc_1CD8
loc_1D2E: 
		bsr.w	loc_1D76
loc_1D32: 
		move.w	d1,(a1)+
		subq.w	#1,d1
		dbra	d2,loc_1D32
		bra.s	loc_1CD8
loc_1D3C: 
		cmp.w	#$F,d2
		beq.s	loc_1D5E
loc_1D42: 
		bsr.w	loc_1D76
		move.w	d1,(a1)+
		dbra	d2,loc_1D42
		bra.s	loc_1CD8 
loc_1D4E:
		bra.s	loc_1D02
		bra.s	loc_1D02
		bra.s	loc_1D0C
		bra.s	loc_1D0C
		bra.s	loc_1D14
		bra.s	loc_1D20
		bra.s	loc_1D2E
		bra.s	loc_1D3C 
loc_1D5E:
		subq.w	#1,a0
		cmp.w	#$10,d6
		bne.s	loc_1D68
		subq.w	#1,a0
loc_1D68:
		move.w	a0,d0
		lsr.w	#1,d0
		bcc.s	loc_1D70
		addq.w	#1,a0
loc_1D70:
		movem.l	(sp)+,d0-d7/a1-a5
		rts
;--------------------------------------------------------------------------------
loc_1D76:
		move.w	a3,d3
		move.b	d4,d1
		add.b	d1,d1
		bcc.s	loc_1D88
		subq.w	#1,d6
		btst D6,d5
		beq.s	loc_1D88
		or.w	#$8000,d3
loc_1D88:
		add.b	d1,d1
		bcc.s	loc_1D96
		subq.w	#1,d6
		btst D6,d5
		beq.s	loc_1D96
		add.w	#$4000,d3
loc_1D96:
		add.b	d1,d1
		bcc.s	loc_1DA4
		subq.w	#1,d6
		btst D6,d5
		beq.s	loc_1DA4
		add.w	#$2000,d3
loc_1DA4:
		add.b	d1,d1
		bcc.s	loc_1DB2
		subq.w	#1,d6
		btst D6,d5
		beq.s	loc_1DB2
		or.w	#$1000,d3
loc_1DB2:
		add.b	d1,d1
		bcc.s	loc_1DC0
		subq.w	#1,d6
		btst D6,d5
		beq.s	loc_1DC0
		or.w	#$800,d3
loc_1DC0:
		move.w	d5,d1
		move.w	d6,d7
		sub.w	a5,d7
		bcc.s	loc_1DF0
		move.w	d7,d6
		add.w	#$10,d6
		neg.w	d7
		lsl.w	d7,d1
		move.b	(a0),d5
		rol.b	d7,d5
		add.w	d7,d7
		and.w	loc_1E06-2(pc,d7),d5
		add.w	d5,d1
loc_1DDE: 
		move.w	a5,d0
		add.w	d0,d0
		and.w	loc_1E06-2(pc,d0),d1
		add.w	d3,d1
		move.b	(a0)+,d5
		lsl.w	#8,d5
		move.b	(a0)+,d5
		rts
;--------------------------------------------------------------------------------
loc_1DF0:
		beq.s	loc_1E02
		lsr.w	d7,d1
		move.w	a5,d0
		add.w	d0,d0
		and.w	loc_1E06-2(pc,d0),d1
		add.w	d3,d1
		move.w	a5,d0
		bra.s	loc_1E26
loc_1E02:
		moveq	#$10,d6
		bra.s	loc_1DDE
loc_1E06:
		dc.w	$1,$3,$7,$F,$1F,$3F,$7F,$FF
		dc.w	$1FF,$3FF,$7FF,$FFF,$1FFF,$3FFF,$7FFF,$FFFF 
loc_1E26:
		sub.w	d0,d6
		cmp.w	#9,d6
		bcc.s	loc_1E34
		addq.w	#8,d6
		asl.w	#8,d5
		move.b	(a0)+,d5
loc_1E34:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine EnigmaDec
; [ End ] 
;=============================================================================== 

;===============================================================================
; Sub Routine KosinskiDec
; [ Begin ] 
;=============================================================================== 
KosinskiDec: 
		subq.l	#2,a7
		move.b	(a0)+,1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4
loc_1E42: 
		lsr.w	#1,d5
		move SR,d6
		dbra	d4,loc_1E54
		move.b	(a0)+,1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4
loc_1E54: 
		move D6,CCR
		bcc.s	loc_1E5C
		move.b	(a0)+,(a1)+
		bra.s	loc_1E42
loc_1E5C:
		moveq	#0,d3
		lsr.w	#1,d5
		move SR,d6
		dbra	d4,loc_1E70
		move.b	(a0)+,1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4
loc_1E70: 
		move D6,CCR
		bcs.s	loc_1EA0
		lsr.w	#1,d5
		dbra	d4,loc_1E84
		move.b	(a0)+,1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4
loc_1E84: 
		roxl.w	#1,d3
		lsr.w	#1,d5
		dbra	d4,loc_1E96
		move.b	(a0)+,1(sp)
		move.b	(a0)+,(sp)
		move.w	(sp),d5
		moveq	#$F,d4
loc_1E96: 
		roxl.w	#1,d3
		addq.w	#1,d3
		moveq	#$FFFFFFFF,d2
		move.b	(a0)+,d2
		bra.s	loc_1EB6
loc_1EA0:
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		moveq	#$FFFFFFFF,d2
		move.b	d1,d2
		lsl.w	#5,d2
		move.b	d0,d2
		and.w	#7,d1
		beq.s	loc_1EC2
		move.b	d1,d3
		addq.w	#1,d3
loc_1EB6:
		move.b	0(a1,d2),d0
		move.b	d0,(a1)+
		dbra	d3,loc_1EB6
		bra.s	loc_1E42
loc_1EC2:
		move.b	(a0)+,d1
		beq.s	loc_1ED2
		cmp.b	#1,d1
		beq	loc_1E42
		move.b	d1,d3
		bra.s	loc_1EB6
loc_1ED2:
		addq.l	#2,a7
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine KosinskiDec
; [ End ] 
;=============================================================================== 
		nop ; Filler
;===============================================================================
; Sub Routine PalCycle_Load
; [ Begin ]
;=============================================================================== 
PalCycle_Load: 
		bsr.w	loc_2634
		moveq	#0,d2
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		move.w	PalCycle(pc,d0),d0 
		jmp	PalCycle(pc,d0) 
		rts
;--------------------------------------------------------------------------------
PalCycle: 
		dc.w	PalCycle_GHz-PalCycle 
		dc.w	PalCycle_Null-PalCycle 
		dc.w	PalCycle_Wz-PalCycle 
		dc.w	PalCycle_Null-PalCycle 
		dc.w	PalCycle_Mz-PalCycle 
		dc.w	PalCycle_Mz-PalCycle 
		dc.w	PalCycle_SFz-PalCycle 
		dc.w	PalCycle_HTz-PalCycle 
		dc.w	PalCycle_HPz-PalCycle 
		dc.w	PalCycle_Null-PalCycle 
		dc.w	PalCycle_OOz-PalCycle 
		dc.w	PalCycle_DHz-PalCycle 
		dc.w	PalCycle_CNz-PalCycle 
		dc.w	PalCycle_CPz-PalCycle 
		dc.w	PalCycle_DEz-PalCycle 
		dc.w	PalCycle_NGHz-PalCycle 
		dc.w	PalCycle_SCz-PalCycle 
PalCycle_Null: 
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
PalCycle_GHz: 
		lea	(Pal_GHzCyc),a0 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_1F40
		move.w	#7,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		addq.w	#1,($FFFFF632).w
		and.w	#3,d0
		lsl.w	#3,d0
		move.l	0(a0,d0),($FFFFFB26).w
		move.l	4(a0,d0),($FFFFFB3C).w
loc_1F40:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
PalCycle_Wz: 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_1F70
		move.w	#2,($FFFFF634).w
		lea	(Pal_WzCyc),a0 
		move.w	($FFFFF632).w,d0
		subq.w	#2,($FFFFF632).w
		bcc.s	loc_1F64
		move.w	#6,($FFFFF632).w
loc_1F64:
		lea	($FFFFFB66).w,a1
		move.l	0(a0,d0),(a1)+
		move.l	4(a0,d0),(a1)
loc_1F70:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
PalCycle_Mz: 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_1FA2
		move.w	#$11,($FFFFF634).w
		lea	(Pal_MzCyc1),a0 
		move.w	($FFFFF632).w,d0
		addq.w	#2,($FFFFF632).w
		cmp.w	#$C,($FFFFF632).w
		bcs.s	loc_1F9A
		move.w	#0,($FFFFF632).w
loc_1F9A:
		lea	($FFFFFB4A).w,a1
		move.w	0(a0,d0),(a1)
loc_1FA2:
		subq.w	#1,($FFFFF666).w
		bpl.s	loc_1FD6
		move.w	#2,($FFFFF666).w
		lea	(Pal_MzCyc2),a0 
		move.w	($FFFFF652).w,d0
		addq.w	#2,($FFFFF652).w
		cmp.w	#6,($FFFFF652).w
		bcs.s	loc_1FCA
		move.w	#0,($FFFFF652).w
loc_1FCA:
		lea	($FFFFFB42).w,a1
		move.l	0(a0,d0),(a1)+
		move.w	4(a0,d0),(a1)
loc_1FD6:
		subq.w	#1,($FFFFF668).w
		bpl.s	loc_2006
		move.w	#9,($FFFFF668).w
		lea	(Pal_MzCyc3),a0 
		move.w	($FFFFF654).w,d0
		addq.w	#2,($FFFFF654).w
		cmp.w	#$14,($FFFFF654).w
		bcs.s	loc_1FFE
		move.w	#0,($FFFFF654).w
loc_1FFE:
		lea	($FFFFFB5E).w,a1
		move.w	0(a0,d0),(a1)
loc_2006:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
PalCycle_HTz: 
		lea	(Pal_HTzCyc1),a0 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_203A
		move.w	#0,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		addq.w	#1,($FFFFF632).w
		and.w	#$F,d0
		move.b	Pal_HTzCyc2(pc,d0),($FFFFF635).w	
		lsl.w	#3,d0
		move.l	0(a0,d0),($FFFFFB26).w
		move.l	4(a0,d0),($FFFFFB3C).w
loc_203A:
		rts
;--------------------------------------------------------------------------------
Pal_HTzCyc2: 
		dc.b	$B,$B,$B,$A,$8,$A,$B,$B,$B,$B,$D,$F,$D,$B,$B,$B
;------------------------------------------------------------------------------- 
PalCycle_HPz: 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_208C
		move.w	#4,($FFFFF634).w
		lea	(Pal_HPzCyc1),a0 
		move.w	($FFFFF632).w,d0
		subq.w	#2,($FFFFF632).w
		bcc.s	loc_206E
		move.w	#6,($FFFFF632).w
loc_206E:
		lea	($FFFFFB72).w,a1
		move.l	0(a0,d0),(a1)+
		move.l	4(a0,d0),(a1)
		lea	(Pal_HPzCyc2),a0 
		lea	($FFFFFAF2).w,a1
		move.l	0(a0,d0),(a1)+
		move.l	4(a0,d0),(a1)
loc_208C:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
PalCycle_OOz: 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_20BA
		move.w	#7,($FFFFF634).w
		lea	(Pal_OOzCyc),a0 
		move.w	($FFFFF632).w,d0
		addq.w	#2,($FFFFF632).w
		and.w	#6,($FFFFF632).w
		lea	($FFFFFB54).w,a1
		move.l	0(a0,d0),(a1)+
		move.l	4(a0,d0),(a1)
loc_20BA:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
PalCycle_DHz: 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_20E2
		move.w	#1,($FFFFF634).w
		lea	(Pal_DHzCyc),a0 
		move.w	($FFFFF632).w,d0
		addq.w	#2,($FFFFF632).w
		and.w	#6,($FFFFF632).w
		move.w	0(a0,d0),($FFFFFB36).w
loc_20E2:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
PalCycle_CNz: 
		subq.w	#1,($FFFFF634).w
		bpl loc_2182
		move.w	#7,($FFFFF634).w
		lea	(Pal_CNzCyc1),a0 
		move.w	($FFFFF632).w,d0
		addq.w	#2,($FFFFF632).w
		cmp.w	#6,($FFFFF632).w
		bcs.s	loc_210E
		move.w	#0,($FFFFF632).w
loc_210E:
		lea	0(a0,d0),a0
		lea	(Normal_palette).w,a1
		move.w	0(a0),$4A(a1)
		move.w	6(a0),$4C(a1)
		move.w	$C(a0),$4E(a1)
		move.w	$12(a0),$56(a1)
		move.w	$18(a0),$58(a1)
		move.w	$1E(a0),$5A(a1)
		lea	(Pal_CNzCyc2),a0 
		lea	0(a0,d0),a0
		move.w	0(a0),$64(a1)
		move.w	6(a0),$66(a1)
		move.w	$C(a0),$68(a1)
		lea	(Pal_CNzCyc3),a0 
		move.w	($FFFFF650).w,d0
		addq.w	#2,($FFFFF650).w
		cmp.w	#$24,($FFFFF650).w
		bcs.s	loc_2172
		move.w	#0,($FFFFF650).w
loc_2172:
		lea	($FFFFFB72).w,a1
		move.w	4(a0,d0),(a1)+
		move.w	2(a0,d0),(a1)+
		move.w	0(a0,d0),(a1)+
loc_2182:
		tst.b	($FFFFF7AA).w
		beq	loc_220A
		subq.w	#1,($FFFFF666).w
		bpl loc_220A
		move.w	#3,($FFFFF666).w
		move.w	($FFFFF652).w,d0
		addq.w	#2,($FFFFF652).w
		cmp.w	#6,($FFFFF652).w
		bcs.s	loc_21AE
		move.w	#0,($FFFFF652).w
loc_21AE:
		lea	(Pal_CNzCyc4),a0 
		lea	0(a0,d0),a0
		lea	(Normal_palette).w,a1
		move.w	0(a0),$24(a1)
		move.w	6(a0),$26(a1)
		move.w	$C(a0),$28(a1)
		lea	(Pal_CNzCyc5),a0 
		move.w	($FFFFF654).w,d0
		addq.w	#2,($FFFFF654).w
		cmp.w	#$14,($FFFFF654).w
		bcs.s	loc_21EA
		move.w	#0,($FFFFF654).w
loc_21EA:
		move.w	0(a0,d0),$3C(a1)
		lea	(Pal_CNzCyc6),a0 
		move.w	($FFFFF656).w,d0
		addq.w	#2,($FFFFF656).w
		and.w	#$E,($FFFFF656).w
		move.w	0(a0,d0),$3E(a1)
loc_220A:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
PalCycle_CPz: 
PalCycle_DEz: 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_227C
		move.w	#7,($FFFFF634).w
		lea	(Pal_CPzCyc1),a0 
		move.w	($FFFFF632).w,d0
		addq.w	#6,($FFFFF632).w
		cmp.w	#$36,($FFFFF632).w
		bcs.s	loc_2234
		move.w	#0,($FFFFF632).w
loc_2234:
		lea	($FFFFFB78).w,a1
		move.l	0(a0,d0),(a1)+
		move.w	4(a0,d0),(a1)
		lea	(Pal_CPzCyc2),a0 
		move.w	($FFFFF652).w,d0
		addq.w	#2,($FFFFF652).w
		cmp.w	#$2A,($FFFFF652).w
		bcs.s	loc_225C
		move.w	#0,($FFFFF652).w
loc_225C:
		move.w	0(a0,d0),($FFFFFB7E).w
		lea	(Pal_CPzCyc3),a0 
		move.w	($FFFFF654).w,d0
		addq.w	#2,($FFFFF654).w
		and.w	#$1E,($FFFFF654).w
		move.w	0(a0,d0),($FFFFFB5E).w
loc_227C:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
PalCycle_NGHz: 
		lea	(Pal_GHzCyc),a0 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_22AA
		move.w	#5,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		addq.w	#1,($FFFFF632).w
		and.w	#3,d0
		lsl.w	#3,d0
		lea	($FFFFFB44).w,a1
		move.l	0(a0,d0),(a1)+
		move.l	4(a0,d0),(a1)
loc_22AA:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
PalCycle_SFz: 
PalCycle_SCz: 
		subq.w	#1,($FFFFF634).w
		bpl.s	loc_22F2
		move.w	#1,($FFFFF634).w
		lea	(Pal_SFzCyc1),a0 
		tst.b	($FFFFF72E).w
		beq.s	loc_22D0
		move.w	#5,($FFFFF634).w
		lea	(Pal_SFzCyc2),a0 
loc_22D0:
		move.w	($FFFFF632).w,d0
		addq.w	#8,($FFFFF632).w
		cmp.w	#$20,($FFFFF632).w
		bcs.s	loc_22E6
		move.w	#0,($FFFFF632).w
loc_22E6:
		lea	($FFFFFB4E).w,a1
		move.l	0(a0,d0),(a1)+
		move.l	4(a0,d0),(a1)
loc_22F2:
		subq.w	#1,($FFFFF666).w
		bpl.s	loc_2320
		move.w	#3,($FFFFF666).w
		lea	(Pal_SFzCyc3),a0 
		move.w	($FFFFF652).w,d0
		addq.w	#2,($FFFFF652).w
		cmp.w	#$44,($FFFFF652).w
		bcs.s	loc_231A
		move.w	#0,($FFFFF652).w
loc_231A:
		move.w	0(a0,d0),($FFFFFB5C).w
loc_2320:
		subq.w	#1,($FFFFF668).w
		bpl.s	loc_234E
		move.w	#5,($FFFFF668).w
		lea	(Pal_SFzCyc4),a0 
		move.w	($FFFFF654).w,d0
		addq.w	#2,($FFFFF654).w
		cmp.w	#$18,($FFFFF654).w
		bcs.s	loc_2348
		move.w	#0,($FFFFF654).w
loc_2348:
		move.w	0(a0,d0),($FFFFFB5E).w
loc_234E:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
; Pal_S1TitleCyc: 
		dc.w	$C42,$E86,$ECA,$EEC,$EEC,$C42,$E86,$ECA
		dc.w	$ECA,$EEC,$C42,$E86,$E86,$ECA,$EEC,$C42 
;------------------------------------------------------------------------------- 
Pal_GHzCyc: 
		dc.w	$A86,$E86,$EA8,$ECA,$ECA,$A86,$E86,$EA8
		dc.w	$EA8,$ECA,$A86,$E86,$E86,$EA8,$ECA,$A86
;------------------------------------------------------------------------------- 
Pal_HTzCyc1: 
		dc.w	$E,$6E,$AE,$EE,$EE,$E,$6E,$AE
		dc.w	$2CE,$EE,$E,$6E,$6E,$4EE,$8EE,$2E
		dc.w	$4E,$8E,$6EE,$AEE,$8EE,$2E,$6E,$4EE
		dc.w	$2CE,$EE,$E,$6E,$6E,$2CE,$EE,$E
		dc.w	$E,$6E,$AE,$EE,$CE,$C,$4E,$8E
		dc.w	$6E,$AC,$A,$2E,$C,$4C,$8E,$8
		dc.w	$A,$2E,$6E,$AC,$CE,$C,$4E,$8E
		dc.w	$AE,$EE,$E,$6E,$6E,$AE,$EE,$E
;------------------------------------------------------------------------------- 
Pal_WzCyc: 
		dc.w	$248,$46A,$48C,$6CE,$248,$46A,$48C,$6CE 
;------------------------------------------------------------------------------- 
Pal_MzCyc1: 
		dc.w	$6,$8,$A,$C,$A,$8 
Pal_MzCyc2: 
		dc.w	$422,$866,$ECC,$422,$866,$ECC 
Pal_MzCyc3: 
		dc.w	$A0,$0,$EE,$0,$2E,$0,$E2E,$0
		dc.w	$E80,$0
;------------------------------------------------------------------------------- 
Pal_HPzCyc1: 
		dc.w	$E44,$E82,$EA8,$EEE,$E44,$E82,$EA8,$EEE
Pal_HPzCyc2: 
		dc.w	$E84,$EA6,$EC6,$EE6,$E84,$EA6,$EC6,$EE6
;------------------------------------------------------------------------------- 
Pal_OOzCyc: 
		dc.w	$400,$602,$804,$806,$400,$602,$804,$806 
;------------------------------------------------------------------------------- 
Pal_DHzCyc: 
		dc.w	$C,$6E,$CE,$8EE
;------------------------------------------------------------------------------- 
Pal_CNzCyc1: 
		dc.w	$E,$EE,$6E,$6E,$E,$EE,$EE,$6E
		dc.w	$E,$EC,$80,$C4,$C4,$EC,$80,$80
		dc.w	$C4,$EC 
Pal_CNzCyc2: 
		dc.w	$C06,$C0A,$C2E,$C0A,$C2E,$C06,$C2E,$C06
		dc.w	$C0A
Pal_CNzCyc3: 
		dc.w	$8E,$AE,$EC,$EEE,$EA,$E4,$6C0,$CC4
		dc.w	$E80,$E40,$E04,$C08,$C2E,$80E,$40E,$E
		dc.w	$4E,$6E,$8E,$AE
Pal_CNzCyc4: 
		dc.w	$6E,$AE,$EE,$AE,$EE,$6E,$EE,$6E
		dc.w	$AE 
Pal_CNzCyc5: 
		dc.w	$A0E,$C0C,$EA0,$AE,$EA,$AE0,$EA,$AE
		dc.w	$EA0,$C0C
Pal_CNzCyc6: 
		dc.w	$E,$C,$A,$8,$6,$8,$A,$C 
;------------------------------------------------------------------------------- 
Pal_CPzCyc1: 
		dc.w	$E40,$C00,$C00,$E60,$C20,$C00,$E40,$E40
		dc.w	$C00,$C20,$E60,$C20,$C00,$E40,$C40,$C00
		dc.w	$C20,$E40,$C00,$C00,$E60,$C20,$C00,$E40
		dc.w	$E20,$C00,$C20
Pal_CPzCyc2: 
		dc.w	$E0,$C2,$A4,$86,$68,$4A,$2C,$E
		dc.w	$20C,$40A,$608,$806,$A04,$C02,$E00,$C20
		dc.w	$A40,$860,$680,$4A0,$2C0
Pal_CPzCyc3: 
		dc.w	$E,$C,$A,$8,$6,$4,$2,$4
		dc.w	$6,$8,$A,$C,$E,$2E,$4E,$2E 
;------------------------------------------------------------------------------- 
Pal_SFzCyc1: 
		dc.w	$4EE,$2AE,$6E,$2C,$EEE,$4EE,$2AE,$6E
		dc.w	$4EE,$2AE,$6E,$2C,$2AE,$6E,$2C,$28
Pal_SFzCyc2: 
		dc.w	$0,$444,$444,$444,$444,$0,$444,$444
		dc.w	$444,$444,$0,$444,$444,$444,$444,$0 
Pal_SFzCyc3: 
		dc.w	$E0,$A0,$60,$20,$0,$200,$600,$A20
		dc.w	$E60,$A20,$600,$200,$0,$2,$6,$A
		dc.w	$E,$4E,$E,$A,$6,$2,$0,$22
		dc.w	$66,$AA,$EE,$AA,$66,$22,$0,$20
		dc.w	$60,$A0 
Pal_SFzCyc4: 
		dc.w	$EC0,$0,$E0E,$0,$EE,$0,$E0,$0
		dc.w	$8E,$0,$EEE,$0 
;===============================================================================
; Sub Routine PalCycle_Load
; [ End; ]
;=============================================================================== 
loc_2634:
		tst.b	($FFFFF65F).w
		beq.s	loc_2676
		bmi.s	loc_2678
		subq.b	#1,($FFFFF65E).w
		bpl.s	loc_2676
		move.b	#3,($FFFFF65E).w
		lea	(loc_26AE),a0
		move.w	($FFFFF65C).w,d0
		addq.w	#8,($FFFFF65C).w
		cmp.w	#$30,($FFFFF65C).w
		bcs.s	loc_266A
		move.b	#$FF,($FFFFF65F).w
		move.b	#0,($FFFFB02A).w
loc_266A:
		lea	($FFFFFB04).w,a1
		move.l	0(a0,d0),(a1)+
		move.l	4(a0,d0),(a1)
loc_2676:
		rts
;--------------------------------------------------------------------------------
loc_2678:
		subq.b	#1,($FFFFF65E).w
		bpl.s	loc_2676
		move.b	#7,($FFFFF65E).w
		lea	(loc_26AE),a0
		move.w	($FFFFF65C).w,d0
		addq.w	#8,($FFFFF65C).w
		cmp.w	#$78,($FFFFF65C).w
		bcs.s	loc_26A0
		move.w	#$30,($FFFFF65C).w
loc_26A0:
		lea	($FFFFFB04).w,a1
		move.l	0(a0,d0),(a1)+
		move.l	4(a0,d0),(a1)
		rts
;--------------------------------------------------------------------------------
loc_26AE: 
		dc.w	$A22,$C42,$E44,$E66,$844,$A64,$E66,$E88
		dc.w	$666,$A86,$E88,$EAA,$488,$AA8,$EAA,$ECC
		dc.w	$4AA,$ACA,$ECC,$EEE,$4CC,$AEC,$EEE,$EEE
		dc.w	$4EE,$AEE,$EEE,$EEE,$6EE,$EEE,$EEE,$EEE
		dc.w	$8EE,$EEE,$EEE,$EEE,$6EE,$CEE,$EEE,$EEE
		dc.w	$4EE,$AEE,$EEE,$EEE,$2EE,$8EE,$CEE,$EEE
		dc.w	$EE,$6EE,$AEE,$EEE,$EE,$4EE,$8EE,$CEE
		dc.w	$EE,$6EE,$AEE,$EEE,$EE,$8EE,$CEE,$EEE
		dc.w	$A20,$A40,$C60,$E80,$C42,$C62,$E82,$EA2
		dc.w	$E64,$E84,$EA4,$EC4,$E86,$EA6,$EC6,$EC6
		dc.w	$E86,$EC8,$EC8,$EC8,$E86,$ECA,$ECA,$ECA
		dc.w	$E86,$ECA,$ECA,$ECA,$E86,$ECA,$ECA,$ECA
		dc.w	$E08,$E28,$E2A,$E4C,$C2A,$E4A,$E4C,$E6E
		dc.w	$A4C,$E6C,$E6E,$E8E,$A6E,$E8E,$E8E,$E8E
		dc.w	$A6E,$E8E,$E8E,$E8E,$A6E,$E8E,$E8E,$E8E
		dc.w	$A6E,$E8E,$E8E,$E8E,$A6E,$E8E,$E8E,$E8E
		dc.w	$A24,$C44,$E46,$E68,$C46,$E66,$E68,$E8A
		dc.w	$E68,$E88,$E8A,$EAC,$E88,$EAA,$EAC,$ECC
		dc.w	$EA8,$ECC,$ECC,$ECC,$EA8,$ECC,$ECC,$ECC
		dc.w	$EA8,$ECC,$ECC,$ECC,$EA8,$ECC,$ECC,$ECC
;===============================================================================
; Sub Routine Pal_FadeTo
; [ Begin ]
;=============================================================================== 
Pal_FadeTo: 
		move.w	#$3F,($FFFFF626).w
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		moveq	#0,d1
		move.b	($FFFFF627).w,d0
loc_2806: 
		move.w	d1,(a0)+
		dbra	d0,loc_2806
		move.w	#$15,d4
loc_2810: 
		move.b	#$12,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.s	Pal_FadeIn 
		bsr.w	RunPLC 
		dbra	d4,loc_2810
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pal_FadeTo
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Pal_FadeIn
; [ Begin ]
;=============================================================================== 
Pal_FadeIn: 
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		lea	($FFFFFB80).w,a1
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		add.w	d0,a1
		move.b	($FFFFF627).w,d0
loc_283C: 
		bsr.s	Pal_AddColor
		dbra	d0,loc_283C
		tst.b	($FFFFF730).w
		beq.s	loc_2864
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		lea	($FFFFFA00).w,a1
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		add.w	d0,a1
		move.b	($FFFFF627).w,d0
loc_285E: 
		bsr.s	Pal_AddColor 
		dbra	d0,loc_285E
loc_2864:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pal_FadeIn
; [ End ]
;=============================================================================== 
 
;===============================================================================
; Sub Routine Pal_AddColor
; [ Begin ]
;=============================================================================== 
Pal_AddColor: 
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	Pal_NoAdd 
Pal_AddBlue: 
		move.w	d3,d1
		add.w	#$200,d1
		cmp.w	d2,d1
		bhi.s	Pal_AddGreen 
		move.w	d1,(a0)+
		rts
;--------------------------------------------------------------------------------
Pal_AddGreen: 
		move.w	d3,d1
		add.w	#$20,d1
		cmp.w	d2,d1
		bhi.s	Pal_AddRed 
		move.w	d1,(a0)+
		rts
;--------------------------------------------------------------------------------
Pal_AddRed: 
		addq.w	#2,(a0)+
		rts
;--------------------------------------------------------------------------------
Pal_NoAdd: 
		addq.w	#2,a0
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pal_AddColor
; [ End ]
;=============================================================================== 
		
;===============================================================================
; Sub Routine Pal_FadeFrom
; [ Begin ]
;=============================================================================== 
Pal_FadeFrom: 
		move.w	#$3F,($FFFFF626).w
		move.w	#$15,d4
loc_289C: 
		move.b	#$12,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.s	Pal_FadeOut 
		bsr.w	RunPLC 
		dbra	d4,loc_289C
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pal_FadeFrom
; [ Begin ]
;=============================================================================== 

;===============================================================================
; Sub Routine Pal_FadeOut
; [ Begin ]
;=============================================================================== 
Pal_FadeOut: 
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		move.b	($FFFFF627).w,d0
loc_28C2 
		bsr.s	Pal_DecColor 
		dbra	d0,loc_28C2
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		move.b	($FFFFF627).w,d0
loc_28D8: 
		bsr.s	Pal_DecColor 
		dbra	d0,loc_28D8
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pal_FadeOut
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Pal_DecColor
; [ Begin ]
;===============================================================================
Pal_DecColor: 
		move.w	(a0),d2
		beq.s	Pal_NoDec 
Pal_DecRed: 
		move.w	d2,d1
		and.w	#$E,d1
		beq.s	Pal_DecGreen 
		subq.w	#2,(a0)+
		rts
;--------------------------------------------------------------------------------
Pal_DecGreen: 
		move.w	d2,d1
		and.w	#$E0,d1
		beq.s	Pal_DecBlue 
		sub.w	#$20,(a0)+
		rts
;--------------------------------------------------------------------------------
Pal_DecBlue: 
		move.w	d2,d1
		and.w	#$E00,d1
		beq.s	Pal_NoDec 
		sub.w	#$200,(a0)+
		rts
;--------------------------------------------------------------------------------
Pal_NoDec: 
		addq.w	#2,a0
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pal_DecColor
; [ End ]
;=============================================================================== 
 
;===============================================================================
; Sub Routine Pal_MakeWhite
; [ Begin ]
;===============================================================================
Pal_MakeWhite: 
		move.w	#$3F,($FFFFF626).w
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		move.w	#$EEE,d1
		move.b	($FFFFF627).w,d0
loc_292A 
		move.w	d1,(a0)+
		dbra	d0,loc_292A
		move.w	#$15,d4
loc_2934: 
		move.b	#$12,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.s	Pal_WhiteToBlack 
		bsr.w	RunPLC 
		dbra	d4,loc_2934
		rts
;--------------------------------------------------------------------------------
Pal_WhiteToBlack: 
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		lea	($FFFFFB80).w,a1
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		add.w	d0,a1
		move.b	($FFFFF627).w,d0
loc_2960 
		bsr.s	Pal_DecColor2 
		dbra	d0,loc_2960
		tst.b	($FFFFF730).w
		beq.s	loc_2988
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		lea	($FFFFFA00).w,a1
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		add.w	d0,a1
		move.b	($FFFFF627).w,d0
loc_2982: 
		bsr.s	Pal_DecColor2 
		dbra	d0,loc_2982
loc_2988:
		rts
;--------------------------------------------------------------------------------
Pal_DecColor2: 
		move.w	(a1)+,d2
		move.w	(a0),d3
		cmp.w	d2,d3
		beq.s	loc_29B6
		move.w	d3,d1
		sub.w	#$200,d1
		bcs.s	loc_29A2
		cmp.w	d2,d1
		bcs.s	loc_29A2
		move.w	d1,(a0)+
		rts
;--------------------------------------------------------------------------------
loc_29A2:
		move.w	d3,d1
		sub.w	#$20,d1
		bcs.s	loc_29B2
		cmp.w	d2,d1
		bcs.s	loc_29B2
		move.w	d1,(a0)+
		rts
;--------------------------------------------------------------------------------
loc_29B2:
		subq.w	#2,(a0)+
		rts
;--------------------------------------------------------------------------------
loc_29B6:
		addq.w	#2,a0
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pal_MakeWhite
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Pal_MakeFlash 
; [ Begin ]
;===============================================================================
Pal_MakeFlash: 
		move.w	#$3F,($FFFFF626).w
		move.w	#$15,d4
loc_29C4: 
		move.b	#$12,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.s	Pal_ToWhite 
		bsr.w	RunPLC 
		dbra	d4,loc_29C4
		rts
;--------------------------------------------------------------------------------
Pal_ToWhite: 
		moveq	#0,d0
		lea	(Normal_palette).w,a0
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		move.b	($FFFFF627).w,d0
loc_29EA: 
		bsr.s	Pal_AddColor2 
		dbra	d0,loc_29EA
		moveq	#0,d0
		lea	($FFFFFA80).w,a0
		move.b	($FFFFF626).w,d0
		add.w	d0,a0
		move.b	($FFFFF627).w,d0
loc_2A00: 
		bsr.s	Pal_AddColor2 
		dbra	d0,loc_2A00
		rts
;--------------------------------------------------------------------------------
Pal_AddColor2: 
		move.w	(a0),d2
		cmp.w	#$EEE,d2
		beq.s	loc_2A44
		move.w	d2,d1
		and.w	#$E,d1
		cmp.w	#$E,d1
		beq.s	loc_2A20
		addq.w	#2,(a0)+
		rts
;--------------------------------------------------------------------------------
loc_2A20:
		move.w	d2,d1
		and.w	#$E0,d1
		cmp.w	#$E0,d1
		beq.s	loc_2A32
		add.w	#$20,(a0)+
		rts
;--------------------------------------------------------------------------------
loc_2A32:
		move.w	d2,d1
		and.w	#$E00,d1
		cmp.w	#$E00,d1
		beq.s	loc_2A44
		add.w	#$200,(a0)+
		rts
;--------------------------------------------------------------------------------
loc_2A44:
		addq.w	#2,a0
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Pal_MakeFlash 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine PalCycle_Sega 
; [ Begin ]
;=============================================================================== 
; PalCycle_Sega: 
		tst.b	($FFFFF635).w
		bne.s	loc_2AA8
		lea	(Normal_palette_line2).w,a1
		lea	(Pal_SegaCyc1),a0 
		moveq	#5,d1
		move.w	($FFFFF632).w,d0
loc_2A5E: 
		bpl.s	loc_2A68
		addq.w	#2,a0
		subq.w	#1,d1
		addq.w	#2,d0
		bra.s	loc_2A5E
loc_2A68:
		move.w	d0,d2
		and.w	#$1E,d2
		bne.s	loc_2A72
		addq.w	#2,d0
loc_2A72:
		cmp.w	#$60,d0
		bcc.s	loc_2A7C
		move.w	(a0)+,0(a1,d0)
loc_2A7C:
		addq.w	#2,d0
		dbra	d1,loc_2A68
		move.w	($FFFFF632).w,d0
		addq.w	#2,d0
		move.w	d0,d2
		and.w	#$1E,d2
		bne.s	loc_2A92
		addq.w	#2,d0
loc_2A92:
		cmp.w	#$64,d0
		blt.s	loc_2AA0
		move.w	#$401,($FFFFF634).w
		moveq	#$FFFFFFF4,d0
loc_2AA0:
		move.w	d0,($FFFFF632).w
		moveq	#1,d0
		rts
;--------------------------------------------------------------------------------
loc_2AA8:
		subq.b	#1,($FFFFF634).w
		bpl.s	loc_2AFA
		move.b	#4,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		add.w	#$C,d0
		cmp.w	#$30,d0
		bcs.s	loc_2AC6
		moveq	#0,d0
		rts
;--------------------------------------------------------------------------------
loc_2AC6:
		move.w	d0,($FFFFF632).w
		lea	(Pal_SegaCyc2),a0 
		lea	0(a0,d0),a0
		lea	($FFFFFB04).w,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)
		lea	(Normal_palette_line2).w,a1
		moveq	#0,d0
		moveq	#$2C,d1
loc_2AE6: 
		move.w	d0,d2
		and.w	#$1E,d2
		bne.s	loc_2AF0
		addq.w	#2,d0
loc_2AF0:
		move.w	(a0),0(a1,d0)
		addq.w	#2,d0
		dbra	d1,loc_2AE6
loc_2AFA:
		moveq	#1,d0
		rts
;--------------------------------------------------------------------------------
Pal_SegaCyc1: 
		dc.w	$EEE,$EEA,$EE4,$EC0,$EE4,$EEA
Pal_SegaCyc2: 
		dc.w	$EEC,$EEA,$EEA,$EEA,$EEA,$EEA,$EEC,$EEA
		dc.w	$EE4,$EC0,$EC0,$EC0,$EEC,$EEA,$EE4,$EC0
		dc.w	$EA0,$E60,$EEA,$EE4,$EC0,$EA0,$E80,$E00 
;===============================================================================
; Sub Routine PalCycle_Sega 
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine PalLoad1
; [ Begin ]
;=============================================================================== 
PalLoad1: 
		lea	(PalPointers),a1 
		lsl.w	#3,d0
		add.w	d0,a1
		move.l	(a1)+,a2
		move.w	(a1)+,a3
		add.w	#$80,a3
		move.w	(a1)+,d7
loc_2B4E: 
		move.l	(a2)+,(a3)+
		dbra	d7,loc_2B4E
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine PalLoad1
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine PalLoad2
; [ Begin ]
;=============================================================================== 
PalLoad2: 
		lea	(PalPointers),a1 
		lsl.w	#3,d0
		add.w	d0,a1
		move.l	(a1)+,a2
		move.w	(a1)+,a3
		move.w	(a1)+,d7
loc_2B66:
		move.l	(a2)+,(a3)+
		dbra	d7,loc_2B66
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine PalLoad2
; [ End ]
;=============================================================================== 
;===============================================================================
; Sub Routine PalLoad3_Water
; [ Begin ]
;=============================================================================== 
PalLoad3_Water: 
		lea	(PalPointers),a1 
		lsl.w	#3,d0
		add.w	d0,a1
		move.l	(a1)+,a2
		move.w	(a1)+,a3
		sub.w	#$80,a3
		move.w	(a1)+,d7
loc_2B82: 
		move.l	(a2)+,(a3)+
		dbra	d7,loc_2B82
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine PalLoad3_Water
; [ End ]
;=============================================================================== 
;===============================================================================
; Sub Routine PalLoad4_Water
; [ Begin ]
;=============================================================================== 
PalLoad4_Water: 
		lea	(PalPointers),a1 
		lsl.w	#3,d0
		add.w	d0,a1
		move.l	(a1)+,a2
		move.w	(a1)+,a3
		sub.w	#$100,a3
		move.w	(a1)+,d7
loc_2B9E:
		move.l	(a2)+,(a3)+
		dbra	d7,loc_2B9E
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine PalLoad4_Water
; [ End ]
;=============================================================================== 
 
PalPointers: 
		dc.l	Pal_Sega_Bg,$FB00001F ; $0 Sega Logo -> loc_2CE6
		dc.l	Pal_Title_Screen,$FB00001F ; $1 Title Screen -> loc_2D66
		dc.l	Pal_Level_Select_Menu,$FB00001F ; $2 Level Select Menu -> loc_2DE6
		dc.l	Pal_Sonic_And_Miles,$FB00000F ; $3 Sonic & Miles -> loc_2E66
		dc.l	Pal_GHz,$FB200017 ; $4 Green Hill -> loc_2EA6
		dc.l	Pal_GHz,$FB200017 ; $5 -> loc_2EA6
		dc.l	Pal_Wz,$FB200017 ; $6 Wood -> loc_2F06
		dc.l	Pal_GHz,$FB200017 ; $7 -> loc_2EA6
		dc.l	Pal_Mz,$FB200017 ; $8 Metropolis -> loc_2F66
		dc.l	Pal_Mz,$FB200017 ; $9 Metropolis -> loc_2F66 
		dc.l	Pal_SFz,$FB200017 ; $A Sky Fortress -> loc_2FC6 
		dc.l	Pal_HTz,$FB200017 ; $B Hill Top -> loc_3026 
		dc.l	Pal_HPz,$FB200017 ; $C Hidden Palace -> loc_3086 
		dc.l	Pal_GHz,$FB200017 ; $D -> loc_2EA6
		dc.l	Pal_OOz,$FB200017 ; $E Oil Ocean -> loc_3166 
		dc.l	Pal_DHz,$FB200017 ; $F Dust Hill -> loc_31C6 
		dc.l	Pal_CNz,$FB200017 ; $10 Casino Night -> loc_3226 
		dc.l	Pal_CPz,$FB200017 ; $11 Chemical Plant -> loc_3286 
		dc.l	Pal_DEz,$FB200017 ; $12 Death Egg -> loc_3366 
		dc.l	Pal_NGHz,$FB200017 ; $13 Neo Green Hill -> loc_33C6 
		dc.l	Pal_SCz,$FB200017 ; $14 Sky Chase -> loc_34A6 
		dc.l	Pal_HPz_Water,$FB00001F ; $15 HPz Underwater -> loc_30E6
		dc.l	Pal_CPz_Water,$FB00001F ; $16 CPz Underwater -> loc_32E6 
		dc.l	Pal_NGHz_Water,$FB00001F ; $17 NGHz Underwater -> loc_3426 
		dc.l	Pal_Special_Stage_Main,$FB000017 ; $18 Special Stage Main -> loc_35E6
		dc.l	Pal_DHz_Boss,$FB200007 ; $19 DHz Boss -> loc_3506
		dc.l	loc_3526,$FB200007 ; $1A
		dc.l	Pal_Special_Stage_1,$FB600007 ; $1B Special Stage 1 -> loc_3646
		dc.l	Pal_Special_Stage_2,$FB600007 ; $1C Special Stage 2 -> loc_3666
		dc.l	Pal_Special_Stage_3,$FB600007 ; $1D Special Stage 3 -> loc_3686
		dc.l	Pal_Special_Stage_4,$FB600007 ; $1E Special Stage 4 -> loc_36A6
		dc.l	Pal_Special_Stage_5,$FB600007 ; $1F Special Stage 5 -> loc_36C6
		dc.l	Pal_Special_Stage_6,$FB600007 ; $20 Special Stage 6 -> loc_36E6
		dc.l	Pal_Special_Stage_7,$FB600007 ; $21 Special Stage 7 -> loc_3706
		dc.l	Pal_SS_Vs_Mode_1,$FB600007 ; $22 Special Stage Vs 1 -> loc_3726
		dc.l	Pal_SS_Vs_Mode_2,$FB600007 ; $23 Special Stage Vs 2 -> loc_3746
		dc.l	Pal_SS_Vs_Mode_3,$FB600007 ; $24 Special Stage Vs 3 -> loc_3766
		dc.l	loc_3546,$FB200007 ; $25
		dc.l	Pal_Versus_Mode_Menu,$FB00001F ; $26 Versus Mode Menu -> loc_3566
		dc.l	Pal_SS_Results,$FB00001F ; $27 Special Stage Results -> loc_3786
Pal_Sega_Bg: 
		incbin 'palettes/sega_bg.pal' 
Pal_Title_Screen:
		incbin 'palettes/titscreen.pal'
Pal_Level_Select_Menu: 
		incbin 'palettes/lvslmenu.pal'
Pal_Sonic_And_Miles 
		incbin 'palettes/sonic.pal'
Pal_GHz: 
		incbin 'palettes/ghz.pal'
Pal_Wz: 
		incbin 'palettes/wz.pal'
Pal_Mz: 
		incbin 'palettes/mz.pal'
Pal_SFz: 
		incbin 'palettes/sfz.pal'
Pal_HTz: 
		incbin 'palettes/htz.pal'
Pal_HPz: 
		incbin 'palettes/hpz.pal'
Pal_HPz_Water: 
		incbin 'palettes/hpz_uw.pal'
Pal_OOz: 
		incbin 'palettes/ooz.pal'
Pal_DHz: 
		incbin 'palettes/dhz.pal'
Pal_CNz: 
		incbin 'palettes/cnz.pal'
Pal_CPz: 
		incbin 'palettes/cpz.pal'
Pal_CPz_Water: 
		incbin 'palettes/cpz_uw.pal'
Pal_DEz: 
		incbin 'palettes/dez.pal'
Pal_NGHz: 
		incbin 'palettes/nghz.pal'
Pal_NGHz_Water: 
		incbin 'palettes/nghz_uw.pal'
Pal_SCz: 
		incbin 'palettes/scz.pal'
Pal_DHz_Boss: 
		incbin 'palettes/dhz_boss.pal'
loc_3526: 
		dc.w	$0,$0,$6E,$AE,$EE,$44,$EEE,$AAA
		dc.w	$888,$444,$666,$EC0,$EE,$88,$A0E,$E0
loc_3546: 
		dc.w	$6E,$0,$E80,$EC0,$EEA,$44,$EEE,$AAA
		dc.w	$888,$444,$666,$48E,$EE,$88,$6AE,$8CE 
Pal_Versus_Mode_Menu: 
		incbin 'palettes/vs_menu.pal'
Pal_Special_Stage_Main: 
		incbin 'palettes/ss_main.pal' 
Pal_Continue: ; Continue Load This Palette in Last Row
Pal_Special_Stage_1: 
		incbin 'palettes/ss_1.pal'
Pal_Special_Stage_2: 
		incbin 'palettes/ss_2.pal'
Pal_Special_Stage_3:
		incbin 'palettes/ss_3.pal'
Pal_Special_Stage_4: 
		incbin 'palettes/ss_4.pal'
Pal_Special_Stage_5: 
		incbin 'palettes/ss_5.pal'
Pal_Special_Stage_6: 
		incbin 'palettes/ss_6.pal'
Pal_Special_Stage_7: 
		incbin 'palettes/ss_7.pal'
Pal_SS_Vs_Mode_1: 
		incbin 'palettes/ss_vs_1.pal'
Pal_SS_Vs_Mode_2: 
		incbin 'palettes/ss_vs_2.pal'
Pal_SS_Vs_Mode_3: 
		incbin 'palettes/ss_vs_3.pal'
Pal_SS_Results: 
		incbin 'palettes/ssresult.pal'
		nop 
;===============================================================================
; Sub Routine DelayProgram
; [ Begin ]
;=============================================================================== 
DelayProgram: 
		move	#$2300,sr
loc_380C: 
		tst.b	(Delay_Time).w
		bne.s	loc_380C
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine DelayProgram
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine PseudoRandomNumber
; [ Begin ]
;=============================================================================== 
PseudoRandomNumber: 
		move.l	($FFFFF636).w,d1
		bne.s	loc_3820
		move.l	#$2A6D365A,d1
loc_3820:
		move.l	d1,d0
		asl.l	#2,d1
		add.l	d0,d1
		asl.l	#3,d1
		add.l	d0,d1
		move.w	d1,d0
		swap.w	d1
		add.w	d1,d0
		move.w	d0,d1
		swap.w	d1
		move.l	d1,($FFFFF636).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine PseudoRandomNumber
; [ End ]
;===============================================================================
		 
;===============================================================================
; Sub Routine CalcSine
; [ Begin ]
;=============================================================================== 
CalcSine: 
		and.w	#$FF,d0
		add.w	d0,d0
		add.w	#$80,d0
		move.w	Sine_Data(pc,d0),d1 
		sub.w	#$80,d0
		move.w	Sine_Data(pc,d0),d0 
		rts
;--------------------------------------------------------------------------------
Sine_Data: 
		dc.w	$0,$6,$C,$12,$19,$1F,$25,$2B
		dc.w	$31,$38,$3E,$44,$4A,$50,$56,$5C
		dc.w	$61,$67,$6D,$73,$78,$7E,$83,$88
		dc.w	$8E,$93,$98,$9D,$A2,$A7,$AB,$B0
		dc.w	$B5,$B9,$BD,$C1,$C5,$C9,$CD,$D1
		dc.w	$D4,$D8,$DB,$DE,$E1,$E4,$E7,$EA
		dc.w	$EC,$EE,$F1,$F3,$F4,$F6,$F8,$F9
		dc.w	$FB,$FC,$FD,$FE,$FE,$FF,$FF,$FF
		dc.w	$100,$FF,$FF,$FF,$FE,$FE,$FD,$FC
		dc.w	$FB,$F9,$F8,$F6,$F4,$F3,$F1,$EE
		dc.w	$EC,$EA,$E7,$E4,$E1,$DE,$DB,$D8
		dc.w	$D4,$D1,$CD,$C9,$C5,$C1,$BD,$B9
		dc.w	$B5,$B0,$AB,$A7,$A2,$9D,$98,$93
		dc.w	$8E,$88,$83,$7E,$78,$73,$6D,$67
		dc.w	$61,$5C,$56,$50,$4A,$44,$3E,$38
		dc.w	$31,$2B,$25,$1F,$19,$12,$C,$6
		dc.w	$0,$FFFA,$FFF4,$FFEE,$FFE7,$FFE1,$FFDB,$FFD5
		dc.w	$FFCF,$FFC8,$FFC2,$FFBC,$FFB6,$FFB0,$FFAA,$FFA4
		dc.w	$FF9F,$FF99,$FF93,$FF8B,$FF88,$FF82,$FF7D,$FF78
		dc.w	$FF72,$FF6D,$FF68,$FF63,$FF5E,$FF59,$FF55,$FF50
		dc.w	$FF4B,$FF47,$FF43,$FF3F,$FF3B,$FF37,$FF33,$FF2F
		dc.w	$FF2C,$FF28,$FF25,$FF22,$FF1F,$FF1C,$FF19,$FF16
		dc.w	$FF14,$FF12,$FF0F,$FF0D,$FF0C,$FF0A,$FF08,$FF07
		dc.w	$FF05,$FF04,$FF03,$FF02,$FF02,$FF01,$FF01,$FF01
		dc.w	$FF00,$FF01,$FF01,$FF01,$FF02,$FF02,$FF03,$FF04
		dc.w	$FF05,$FF07,$FF08,$FF0A,$FF0C,$FF0D,$FF0F,$FF12
		dc.w	$FF14,$FF16,$FF19,$FF1C,$FF1F,$FF22,$FF25,$FF28
		dc.w	$FF2C,$FF2F,$FF33,$FF37,$FF3B,$FF3F,$FF43,$FF47
		dc.w	$FF4B,$FF50,$FF55,$FF59,$FF5E,$FF63,$FF68,$FF6D
		dc.w	$FF72,$FF78,$FF7D,$FF82,$FF88,$FF8B,$FF93,$FF99
		dc.w	$FF9F,$FFA4,$FFAA,$FFB0,$FFB6,$FFBC,$FFC2,$FFC8
		dc.w	$FFCF,$FFD5,$FFDB,$FFE1,$FFE7,$FFEE,$FFF4,$FFFA
		dc.w	$0,$6,$C,$12,$19,$1F,$25,$2B
		dc.w	$31,$38,$3E,$44,$4A,$50,$56,$5C
		dc.w	$61,$67,$6D,$73,$78,$7E,$83,$88
		dc.w	$8E,$93,$98,$9D,$A2,$A7,$AB,$B0
		dc.w	$B5,$B9,$BD,$C1,$C5,$C9,$CD,$D1
		dc.w	$D4,$D8,$DB,$DE,$E1,$E4,$E7,$EA
		dc.w	$EC,$EE,$F1,$F3,$F4,$F6,$F8,$F9
		dc.w	$FB,$FC,$FD,$FE,$FE,$FF,$FF,$FF 
;===============================================================================
; Sub Routine CalcSine
; [ End ]
;===============================================================================
 
;===============================================================================
; Sub Routine CalcAngle
; [ Begin ]
;=============================================================================== 
CalcAngle: 
		movem.l	d3/d4,-(sp)
		moveq	#0,d3
		moveq	#0,d4
		move.w	d1,d3
		move.w	d2,d4
		or.w	d3,d4
		beq.s	loc_3B2E
		move.w	d2,d4
		tst.w	d3
		bpl loc_3AEC
		neg.w	d3
loc_3AEC:
		tst.w	d4
		bpl loc_3AF4
		neg.w	d4
loc_3AF4:
		cmp.w	d3,d4
		bcc loc_3B06
		lsl.l	#8,d4
		divu.w	d3,d4
		moveq	#0,d0
		move.b	angleData(pc,d4),d0 
		bra.s	loc_3B10
loc_3B06:
		lsl.l	#8,d3
		divu.w	d4,d3
		moveq	#$40,d0
		sub.b	angleData(pc,d3),d0 
loc_3B10:
		tst.w	d1
		bpl loc_3B1C
		neg.w	d0
		add.w	#$80,d0
loc_3B1C:
		tst.w	d2
		bpl loc_3B28
		neg.w	d0
		add.w	#$100,d0
loc_3B28:
		movem.l	(sp)+,d3/d4
		rts
;--------------------------------------------------------------------------------
loc_3B2E:
		move.w	#$40,d0
		movem.l	(sp)+,d3/d4
		rts
;--------------------------------------------------------------------------------
AngleData: 
		dc.b	$0,$0,$0,$0,$1,$1,$1,$1,$1,$1,$2,$2,$2,$2,$2,$2
		dc.b	$3,$3,$3,$3,$3,$3,$3,$4,$4,$4,$4,$4,$4,$5,$5,$5
		dc.b	$5,$5,$5,$6,$6,$6,$6,$6,$6,$6,$7,$7,$7,$7,$7,$7
		dc.b	$8,$8,$8,$8,$8,$8,$8,$9,$9,$9,$9,$9,$9,$A,$A,$A
		dc.b	$A,$A,$A,$A,$B,$B,$B,$B,$B,$B,$B,$C,$C,$C,$C,$C
		dc.b	$C,$C,$D,$D,$D,$D,$D,$D,$D,$E,$E,$E,$E,$E,$E,$E
		dc.b	$F,$F,$F,$F,$F,$F,$F,$10,$10,$10,$10,$10,$10,$10,$11,$11
		dc.b	$11,$11,$11,$11,$11,$11,$12,$12,$12,$12,$12,$12,$12,$13,$13,$13
		dc.b	$13,$13,$13,$13,$13,$14,$14,$14,$14,$14,$14,$14,$14,$15,$15,$15
		dc.b	$15,$15,$15,$15,$15,$15,$16,$16,$16,$16,$16,$16,$16,$16,$17,$17
		dc.b	$17,$17,$17,$17,$17,$17,$17,$18,$18,$18,$18,$18,$18,$18,$18,$18
		dc.b	$19,$19,$19,$19,$19,$19,$19,$19,$19,$19,$1A,$1A,$1A,$1A,$1A,$1A
		dc.b	$1A,$1A,$1A,$1B,$1B,$1B,$1B,$1B,$1B,$1B,$1B,$1B,$1B,$1C,$1C,$1C
		dc.b	$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D
		dc.b	$1D,$1D,$1D,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1F,$1F
		dc.b	$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$20,$20,$20,$20,$20,$20
		dc.b	$20,$0 
		nop 
;===============================================================================
; Sub Routine CalcAngle
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sega Screen
; [ Begin ]
;=============================================================================== 
SegaScreen: 
		move.b	#$FD,d0
		bsr.w	Play_Music 
		bsr.w	ClearPLC 
		bsr.w	Pal_FadeFrom 
		lea	(Misc_Variables).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
loc_3C56: 
		move.l	d0,(a1)+
		dbra	d1,loc_3C56
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
loc_3C66: 
		move.l	d0,(a1)+
		dbra	d1,loc_3C66
		lea	(VDP_control_port),a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8405,(a6)
		move.w	#$8700,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8C81,(a6)
		move.w	#$9003,(a6)
		clr.b	($FFFFF64E).w
		clr.w	($FFFFFFD8).w
		move	#$2700,sr
		move.w	(VDP_Reg0_Val).w,d0
		and.b	#$BF,d0
		move.w	d0,(VDP_control_port)
		bsr.w	ClearScreen 
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$941F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000083,(a5)
		move.w	#0,(VDP_data_port)
loc_3CCE: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_3CCE
		move.w	#$8F02,(a5)
		move.l	#$40200000,(VDP_control_port)
		lea	(Sega_Spr),a0 
		bsr.w	NemesisDec 
		move.l	#$50000000,(VDP_control_port)
		lea	(Sega_Blocks_Spr),a0 
		bsr.w	NemesisDec 
		move.l	#$51000000,(VDP_control_port)
		lea	(Metal_Sonic),a0 
		bsr.w	NemesisDec 
		lea	(RAM_Start),a1
		lea	(Sega_Mappings),a0 
		move.w	#0,d0
		bsr.w	EnigmaDec 
		lea	(RAM_Start),a1
		move.l	#$60000002,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	loc_3DF4
		tst.b	(Graphics_Flags).w
		bmi.s	loc_3D52
		lea	($FFFFB080).w,a1
		move.b	#$B1,(a1)
		move.b	#$4E,$28(a1)
loc_3D52:
		moveq	#0,d0
		bsr.w	PalLoad2 
		move.w	#$FFF6,($FFFFF632).w
		move.w	#0,($FFFFF634).w
		move.w	#0,($FFFFF662).w
		move.w	#0,($FFFFF660).w
		lea	($FFFFB040).w,a1
		move.b	#$B0,(a1)
		move.b	#$4C,$28(a1)
		move.w	#$F0,(Demo_Time_left).w
		move.w	(VDP_Reg0_Val).w,d0
		or.b	#$40,d0
		move.w	d0,(VDP_control_port)
loc_3D92: 
		move.b	#2,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.w	loc_3E14
		jsr	Build_Sprites 
		and.b	#$80,(Ctrl_1_Press).w
		bne.s	loc_3DE4
		tst.b	($FFFFF660).w
		beq.s	loc_3D92
		move.b	#$FA,d0
		bsr.w	Play_Sfx
		move.b	#2,(Delay_Time).w
		bsr.w	DelayProgram 
		move.w	#$B4,(Demo_Time_left).w
loc_3DCC:
		move.b	#$14,(Delay_Time).w
		bsr.w	DelayProgram 
		tst.w	(Demo_Time_left).w
		beq.s	loc_3DE4
		and.b	#$80,(Ctrl_1_Press).w
		beq.s	loc_3DCC
loc_3DE4:
		clr.w	($FFFFF660).w
		clr.w	($FFFFF662).w
		move.b	#4,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_3DF4:
		lea	(VDP_data_port),a6
		move.l	#$1000000,d4
loc_3E00: 
		move.l	d0,4(a6)
		move.w	d1,d3
loc_3E06:
		move.w	(a1)+,(a6)
		dbra	d3,loc_3E06
		add.l	d4,d0
		dbra	d2,loc_3E00
		rts
;--------------------------------------------------------------------------------
loc_3E14:
		jmp	Load_Objects 
;===============================================================================
; Sega Screen
; [ End ]
;=============================================================================== 
		cnop	0,4 ; Filler 
;===============================================================================
; Title Screen
; [ Begin ]
;=============================================================================== 
TitleScreen: 
		move.b	#$FD,d0
		bsr.w	Play_Music 
		bsr.w	ClearPLC 
		bsr.w	Pal_FadeFrom 
		move	#$2700,sr
		lea	(VDP_control_port),a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$9200,(a6)
		move.w	#$8B03,(a6)
		move.w	#$8720,(a6)
		clr.b	($FFFFF64E).w
		move.w	#$8C81,(a6)
		bsr.w	ClearScreen 
		lea	($FFFFAC00).w,a1
		moveq	#0,d0
		move.w	#$FF,d1
loc_3E68: 
		move.l	d0,(a1)+
		dbra	d1,loc_3E68
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
loc_3E78: 
		move.l	d0,(a1)+
		dbra	d1,loc_3E78
		lea	(Misc_Variables).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
loc_3E88: 
		move.l	d0,(a1)+
		dbra	d1,loc_3E88
		lea	($FFFFEE00).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
loc_3E98: 
		move.l	d0,(a1)+
		dbra	d1,loc_3E98
		lea	($FFFFFB80).w,a1
		moveq	#0,d0
		move.w	#$1F,d1
loc_3EA8: 
		move.l	d0,(a1)+
		dbra	d1,loc_3EA8
		moveq	#3,d0 ; Load Sonic Palette "Sonic Team Presents" Left Over
		bsr.w	PalLoad1 
		bsr.w	Pal_FadeTo 
		move	#$2700,sr
		move.l	#$40000000,(VDP_control_port)
		lea	(Title_Screen_Bg_Wings),a0 
		bsr.w	NemesisDec 
		move.l	#$40000001,(VDP_control_port)
		lea	(Title_Screen_Sonic_Miles),a0 
		bsr.w	NemesisDec 
		move.l	#$5E000001,(VDP_control_port)
		lea	(_1p2pVs_Spr),a0 
		bsr.w	NemesisDec 
		lea	(VDP_data_port),a6
		move.l	#$50000003,4(a6)
		lea	(art_Menu_Text),a5 
		move.w	#$28F,d1
loc_3F10: 
		move.w	(a5)+,(a6)
		dbra	d1,loc_3F10
		nop
		move.b	#0,($FFFFFE30).w
		move.b	#0,($FFFFFEE0).w
		move.w	#0,(Debug_placement_mode).w
		move.w	#0,($FFFFFFF0).w
		move.w	#0,($FFFFFFDA).w
		move.w	#0,($FFFFFE10).w
		move.w	#0,($FFFFF634).w
		bsr.w	Pal_FadeFrom 
		move	#$2700,sr
		lea	(RAM_Start),a1
		lea	(TS_Wings_Sonic_Mappings),a0 
		move.w	#0,d0
		bsr.w	EnigmaDec 
		lea	(RAM_Start),a1
		move.l	#$40000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	ShowVDPGraphics 
		lea	(RAM_Start),a1
		lea	(Title_Screen_Bg_Mappings),a0 
		move.w	#0,d0
		bsr.w	EnigmaDec 
		lea	(RAM_Start),a1
		move.l	#$60000003,d0
		moveq	#$1F,d1
		moveq	#$1B,d2
		bsr.w	ShowVDPGraphics 
		lea	(RAM_Start),a1
		lea	(Title_Screen_R_Bg_Mappings),a0 
		move.w	#0,d0
		bsr.w	EnigmaDec 
		lea	(RAM_Start),a1
		move.l	#$60400003,d0
		moveq	#$1F,d1
		moveq	#$1B,d2
		bsr.w	ShowVDPGraphics 
		moveq	#1,d0
		bsr.w	PalLoad1 
		move.b	#$99,d0
		bsr.w	Play_Music 
		move.b	#0,($FFFFFFFA).w
		move.w	#0,($FFFFFFD8).w
		move.w	#$178,(Demo_Time_left).w
		lea	($FFFFB080).w,a1
		moveq	#0,d0
		move.w	#$F,d1
loc_3FEC: 
		move.l	d0,(a1)+
		dbra	d1,loc_3FEC
		move.b	#$E,($FFFFB040).w
		move.b	#$E,($FFFFB080).w
		move.b	#1,($FFFFB09A).w
		move.b	#$F,($FFFFB0C0).w
		jsr	Load_Objects 
		jsr	Build_Sprites 
		moveq	#0,d0
		bsr.w	LoadPLC2 
		move.w	#0,($FFFFFFD4).w
		move.w	#0,($FFFFFFD6).w
		move.w	#$101,($FFFFFFD0).w
		move.w	#$101,($FFFFFFD2).w
		move.w	#4,($FFFFEED2).w
		move.w	#0,($FFFFE500).w
		lea	(Results_Data_2P).w,a1
		moveq	#$B,d0
loc_4046: 
		move.w	#$FFFF,(a1)+
		dbra	d0,loc_4046
		move.w	(VDP_Reg0_Val).w,d0
		or.b	#$40,d0
		move.w	d0,(VDP_control_port)
		bsr.w	Pal_FadeTo 
TitleScreen_Loop: 
		move.b	#4,(Delay_Time).w
		bsr.w	DelayProgram 
		jsr	Load_Objects 
		bsr.w	Bg_Scroll_Title_Screen 
		jsr	Build_Sprites 
		bsr.w	RunPLC 
		tst.b	(Graphics_Flags).w
		bpl.s	Code_Sequence_J 
		lea	(Level_Select_Code_J),a0 
		bra.s	Level_Select_Cheat_Test 
Code_Sequence_J: 
		lea	(Level_Select_Code_US),a0 
Level_Select_Cheat_Test: 
		move.w	($FFFFFFD4).w,d0
		add.w	d0,a0
		move.b	(Ctrl_1_Press).w,d0
		and.b	#$F,d0
		cmp.b	(a0),d0
		bne.s	Title_Cheat_NoMatch 
		addq.w	#1,($FFFFFFD4).w
		tst.b	d0
		bne.s	Title_Cheat_CountC 
		lea	($FFFFFFD0).w,a0
		move.w	($FFFFFFD6).w,d1
		lsr.w	#1,d1
		and.w	#3,d1
		beq.s	Title_Cheat_PlayRing 
		tst.b	(Graphics_Flags).w
		bpl.s	Title_Cheat_PlayRing 
		moveq	#1,d1
		move.b	d1,1(a0,d1)
Title_Cheat_PlayRing: 
		move.b	#1,0(a0,d1)
		move.b	#$B5,d0
		bsr.w	Play_Sfx
		bra.s	Title_Cheat_CountC 
Title_Cheat_NoMatch: 
		tst.b	d0
		beq.s	Title_Cheat_CountC 
		cmp.w	#9,($FFFFFFD4).w
		beq.s	Title_Cheat_CountC 
		move.w	#0,($FFFFFFD4).w
Title_Cheat_CountC: 
		move.b	(Ctrl_1_Press).w,d0
		and.b	#$20,d0
		beq.s	loc_40F8
		addq.w	#1,($FFFFFFD6).w
loc_40F8:
		tst.w	(Demo_Time_left).w
		beq	loc_42B4
		and.b	#$80,(Ctrl_1_Press).w
		beq	TitleScreen_Loop 
loc_410A: 
		moveq	#0,d0
		move.b	($FFFFB0DA).w,d0
		move.w	d0,($FFFFFFD8).w
		bne.w	PlayLevel
		tst.b	($FFFFFFD0).w
		beq	PlayLevel 
		cmp.b	#$C0,(Ctrl_1_Held).w
		bne.w	PlayLevel 
		move.b	#$91,d0
		bsr.w	Play_Music 
		moveq	#2,d0
		bsr.w	PalLoad2 
		lea	($FFFFE000).w,a1
		moveq	#0,d0
		move.w	#$DF,d1
LevelSelect_ClearScroll: 
		move.l	d0,(a1)+
		dbra	d1,LevelSelect_ClearScroll 
		move.l	d0,($FFFFF616).w
		move	#$2700,sr
		lea	(VDP_data_port),a6
		move.l	#$60000003,(VDP_control_port)
		move.w	#$3FF,d1
LevelSelect_ClearVRAM: 
		move.l	d0,(a6)
		dbra	d1,LevelSelect_ClearVRAM 
		bsr.w	loc_4430
LevelSelect_Loop: 
		move.b	#4,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.w	LevelSelect_Controls 
		bsr.w	RunPLC 
		tst.l	(Plc_Buffer).w
		bne.s	LevelSelect_Loop 
		and.b	#$F0,(Ctrl_1_Press).w
		beq.s	LevelSelect_Loop 
		move.w	($FFFFFF82).w,d0
		cmp.w	#$17,d0
		bne.s	loc_41AE
		btst	#6,(Ctrl_1_Press).w
		bne.s	LevelSelect_Loop 
		move.w	($FFFFFF84).w,d0
		add.w	#$80,d0
		bsr.w	Play_Sfx
		bra.s	LevelSelect_Loop 
loc_41AE:
		add.w	d0,d0
		move.w	Level_Select_Array(pc,d0),d0 
		bmi LevelSelect_Loop 
		cmp.w	#$4000,d0
		bne.s	Level_Select_Level 
		move.b	#$10,(Game_Mode).w
		clr.w	($FFFFFE10).w
		move.b	#3,(Life_count).w
		move.b	#3,($FFFFFEC6).w
		moveq	#0,d0
		move.w	d0,(Ring_count).w
		move.l	d0,($FFFFFE22).w
		move.l	d0,($FFFFFE26).w
		move.w	d0,($FFFFFED0).w
		move.l	d0,($FFFFFED2).w
		move.l	d0,($FFFFFED6).w
		move.l	#$1388,($FFFFFFC0).w
		move.l	#$1388,($FFFFFFC4).w
		rts
;--------------------------------------------------------------------------------
Level_Select_Array:
		dc.w	$0,$1 ; GHz
		dc.w	$400,$401,$500 ; Mz
		dc.w	$700,$701 ; HTz
		dc.w	$FFFF,$FFFF ; HPz - Disabled
		dc.w	$A00,$A01 ; OOz
		dc.w	$B00,$B01 ; DHz 
		dc.w	$C00,$C01 ; CNz
		dc.w	$D00,$D01 ; CPz
		dc.w	$F00,$F01 ; NGHz
		dc.w	$1000 ; SCz
		dc.w	$600 ; SFz
		dc.w	$E00 ; DEz
		dc.w	$4000 ; SS
		dc.w	$0 ; Sound Test
Level_Select_Level: 
		and.w	#$3FFF,d0
		move.w	d0,($FFFFFE10).w
PlayLevel: 
		move.b	#$C,(Game_Mode).w
		move.b	#3,(Life_count).w
		move.b	#3,($FFFFFEC6).w
		moveq	#0,d0
		move.w	d0,(Ring_count).w
		move.l	d0,($FFFFFE22).w
		move.l	d0,($FFFFFE26).w
		move.w	d0,($FFFFFED0).w
		move.l	d0,($FFFFFED2).w
		move.l	d0,($FFFFFED6).w
		move.b	d0,(Current_Special_Stage).w
		move.b	d0,($FFFFFFB0).w
		move.l	d0,($FFFFFFB2).w
		move.l	d0,($FFFFFFB6).w
		move.b	d0,($FFFFFE18).w
		move.l	#$1388,($FFFFFFC0).w
		move.l	#$1388,($FFFFFFC4).w
		move.b	#$F9,d0
		bsr.w	Play_Sfx
		tst.w	($FFFFFF8A).w
		beq.s	loc_42A2
		move.b	#$1C,(Game_Mode).w
		move.b	#0,(Current_Zone_2P).w
loc_42A2:
		rts
;--------------------------------------------------------------------------------
Level_Select_Code_US:
		dc.b	$1,$2,$2,$2,$2,$1,$0,$FF
Level_Select_Code_J: 
		dc.b	$1,$2,$2,$2,$2,$1,$0,$FF
loc_42B4:
		move.w	#$1E,(Demo_Time_left).w
loc_42BA: 
		move.b	#4,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.w	RunPLC 
		move.w	($FFFFB008).w,d0
		addq.w	#2,d0
		move.w	d0,($FFFFB008).w
		cmp.w	#$1C00,d0
		bcs.s	loc_42E0
		move.b	#0,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_42E0:
		and.b	#$80,(Ctrl_1_Press).w
		bne.w	loc_410A
		tst.w	(Demo_Time_left).w
		bne.w	loc_42BA
		move.b	#$F9,d0
		bsr.w	Play_Sfx
		move.w	($FFFFFFF2).w,d0
		and.w	#7,d0
		add.w	d0,d0
		move.w	demo_Mode_Level_Array(pc,d0),d0 
		move.w	d0,($FFFFFE10).w
		addq.w	#1,($FFFFFFF2).w
		cmp.w	#4,($FFFFFFF2).w
		bcs.s	loc_431E
		move.w	#0,($FFFFFFF2).w
loc_431E:
		move.w	#1,($FFFFFFF0).w
		move.b	#8,(Game_Mode).w
		cmp.w	#0,d0
		bne.s	loc_4336
		move.w	#1,($FFFFFFD8).w
loc_4336:
		cmp.w	#$600,d0
		bne.s	loc_434A
		move.b	#$10,(Game_Mode).w
		clr.w	($FFFFFE10).w
		clr.b	(Current_Special_Stage).w
loc_434A:
		move.b	#3,(Life_count).w
		move.b	#3,($FFFFFEC6).w
		moveq	#0,d0
		move.w	d0,(Ring_count).w
		move.l	d0,($FFFFFE22).w
		move.l	d0,($FFFFFE26).w
		move.w	d0,($FFFFFED0).w
		move.l	d0,($FFFFFED2).w
		move.l	d0,($FFFFFED6).w
		move.l	#$1388,($FFFFFFC0).w
		move.l	#$1388,($FFFFFFC4).w
		rts
;--------------------------------------------------------------------------------
Demo_Mode_Level_Array:
		dc.w	$D00,$0,$C00,$700,$500,$500,$500,$500
		dc.w	$400,$400,$400,$400
LevelSelect_Controls:
		move.b	(Ctrl_1_Press).w,d1
		and.b	#3,d1
		bne.s	loc_43AA
		subq.w	#1,($FFFFFF80).w
		bpl.s	loc_43E4
loc_43AA:
		move.w	#$B,($FFFFFF80).w
		move.b	(Ctrl_1_Held).w,d1
		and.b	#3,d1
		beq.s	loc_43E4
		move.w	($FFFFFF82).w,d0
		btst	#0,d1
		beq.s	loc_43CA
		subq.w	#1,d0
		bcc.s	loc_43CA
		moveq	#$17,d0
loc_43CA:
		btst	#1,d1
		beq.s	loc_43DA
		addq.w	#1,d0
		cmp.w	#$18,d0
		bcs.s	loc_43DA
		moveq	#0,d0
loc_43DA:
		move.w	d0,($FFFFFF82).w
		bsr.w	loc_4430
		rts
;--------------------------------------------------------------------------------
loc_43E4:
		cmp.w	#$17,($FFFFFF82).w
		bne.s	loc_442E
		move.w	($FFFFFF84).w,d0
		move.b	(Ctrl_1_Press).w,d1
		and.b	#$C,d1
		beq.s	loc_4416
		btst	#2,d1
		beq.s	loc_4406
		subq.b	#1,d0
		bcc.s	loc_4406
		moveq	#$7F,d0
loc_4406:
		btst	#3,d1
		beq.s	loc_4416
		addq.b	#1,d0
		cmp.w	#$80,d0
		bcs.s	loc_4416
		moveq	#0,d0
loc_4416:
		btst	#6,(Ctrl_1_Press).w
		beq.s	loc_4426
		add.b	#$10,d0
		and.b	#$7F,d0
loc_4426:
		move.w	d0,($FFFFFF84).w
		bsr.w	loc_4430
loc_442E:
		rts
;--------------------------------------------------------------------------------
loc_4430:
		lea	(Level_Select_Text),a1 
		lea	(VDP_data_port),a6
		move.l	#$608C0003,d4
		move.w	#$8680,d3
		moveq	#$17,d1
loc_4448: 
		move.l	d4,4(a6)
		bsr.w	loc_44CC
		add.l	#$800000,d4
		dbra	d1,loc_4448
		moveq	#0,d0
		move.w	($FFFFFF82).w,d0
		move.w	d0,d1
		move.l	#$608C0003,d4
		lsl.w	#7,d0
		swap.w	d0
		add.l	d0,d4
		lea	(Level_Select_Text),a1 
		mulu.w	#$1B,d1
		add.w	d1,a1
		move.w	#$C680,d3
		move.l	d4,4(a6)
		bsr.w	loc_44CC
		move.w	#$8680,d3
		cmp.w	#$17,($FFFFFF82).w
		bne.s	loc_4496
		move.w	#$C680,d3
loc_4496:
		move.l	#$6C300003,(VDP_control_port)
		move.w	($FFFFFF84).w,d0
		add.w	#$80,d0
		move.b	d0,d2
		lsr.b	#4,d0
		bsr.w	loc_44B8
		move.b	d2,d0
		bsr.w	loc_44B8
		rts
;--------------------------------------------------------------------------------
loc_44B8:
		and.w	#$F,d0
		cmp.b	#$A,d0
		bcs.s	loc_44C6
		add.b	#7,d0
loc_44C6:
		add.w	d3,d0
		move.w	d0,(a6)
		rts
;--------------------------------------------------------------------------------
loc_44CC:
		moveq	#$1A,d2
loc_44CE: 
		moveq	#0,d0
		move.b	(a1)+,d0
		bpl.s	loc_44DE
		move.w	#0,(a6)
		dbra	d2,loc_44CE
		rts
;--------------------------------------------------------------------------------
loc_44DE:
		add.w	d3,d0
		move.w	d0,(a6)
		dbra	d2,loc_44CE
		rts
;--------------------------------------------------------------------------------
_0 = $0
_1 = $1
_2 = $2 
_A = $11
_B = $12
_C = $13
_D = $14 
_E = $15
_F = $16
_G = $17
_H = $18
_I = $19
_J = $1A
_K = $1B
_L = $1C
_M = $1D
_N = $1E
_O = $1F
_P = $20
_Q = $21
_R = $22
_S = $23
_T = $24
_U = $25
_V = $26
_W = $27
_X = $28
_Y = $F
_Z = $10
__ = $FF 
Level_Select_Text: 
		dc.b	_G,_R,_E,_E,_N,__,_H,_I,_L,_L,__,_Z,_O,_N,_E,__,__,__,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_1
		dc.b	_M,_E,_T,_R,_O,_P,_O,_L,_I,_S,__,_Z,_O,_N,_E,__,__,__,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_1
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_2
		dc.b	_H,_I,_L,_L,__,_T,_O,_P,__,_Z,_O,_N,_E,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_1
		dc.b	_H,_I,_D,_D,_E,_N,__,_P,_A,_L,_A,_C,_E,__,_Z,_O,_N,_E,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_1
		dc.b	_O,_I,_L,__,_O,_C,_E,_A,_N,__,_Z,_O,_N,_E,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_1
		dc.b	_D,_U,_S,_T,__,_H,_I,_L,_L,__,_Z,_O,_N,_E,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_1
		dc.b	_C,_A,_S,_I,_N,_O,__,_N,_I,_G,_H,_T,__,_Z,_O,_N,_E,__,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_1
		dc.b	_C,_H,_E,_M,_I,_C,_A,_L,__,_P,_L,_A,_N,_T,__,_Z,_O,_N,_E,__,_S,_T,_A,_G,_E,__,_0
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_1
		dc.b	_N,_E,_O,__,_G,_R,_E,_E,_N,__,_H,_I,_L,_L,__,_Z,_O,_N,_E,__,_S,_T,_A,_G,_E,__,_0
		dc.b	__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_1
		dc.b	_S,_K,_Y,__,_C,_H,_A,_S,_E,__,_Z,_O,_N,_E,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	_S,_K,_Y,__,_F,_O,_R,_T,_R,_E,_S,_S,__,_Z,_O,_N,_E,__,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	_D,_E,_A,_T,_H,__,_E,_G,_G,__,_Z,_O,_N,_E,__,__,__,__,__,__,_S,_T,_A,_G,_E,__,_0
		dc.b	_S,_P,_E,_C,_I,_A,_L,__,_S,_T,_A,_G,_E,__,__,__,__,__,__,__,__,__,__,__,__,__,__
		dc.b	_S,_O,_U,_N,_D,__,_S,_E,_L,_E,_C,_T,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__
;===============================================================================
; Sub Routine Level Select Menu
; [ End ]
;=============================================================================== 
Unused_Code_1: 
		lea	(RAM_Start),a1
		move.w	#$2EB,d2
Unused_Code_1_Loop: 
		move.w	(a1),d0
		move.w	d0,d1
		and.w	#$F800,d1
		and.w	#$7FF,d0
		lsr.w	#1,d0
		or.w	d0,d1
		move.w	d1,(a1)+
		dbra	d2,Unused_Code_1_Loop 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Unused_Code_2: 
		lea	($FE0000),a1
		lea	($FE0080),a2
		lea	(RAM_Start),a3
		move.w	#$3F,d1
Unused_Code_2_Loop: 
		bsr.w	Unused_Code_4 
		bsr.w	Unused_Code_4 
		dbra	d1,Unused_Code_2_Loop 
		lea	($FE0000),a1
		lea	($FF0000),a2
		move.w	#$3F,d1
Unused_Code_2_Loop2: 
		move.w	#0,(a2)+
		dbra	d1,Unused_Code_2_Loop2 
		move.w	#$3FBF,d1
Unused_Code_2_Loop3: 
		move.w	(a1)+,(a2)+
		dbra	d1,Unused_Code_2_Loop3 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Unused_Code_3: 
		lea	($FE0000),a1
		lea	(RAM_Start),a3
		moveq	#$1F,d0
Unused_Code_3_Loop: 
		move.l	(a1)+,(a3)+
		dbra	d0,Unused_Code_3_Loop 
		moveq	#0,d7
		lea	($FE0000),a1
		move.w	#$FF,d5
Unused_Code_3_Loop2: 
		lea	(RAM_Start),a3
		move.w	d7,d6
Unused_Code_3_Loop3: 
		movem.l	a1-a3,-(sp)
		move.w	#$3F,d0
Unused_Code_3_Loop4: 
		cmpm.w	(a1)+,(a3)+
		bne.s	Unused_Code_3_0 
		dbra	d0,Unused_Code_3_Loop4 
		movem.l	(sp)+,a1-a3
		add.w	#$80,a1
		dbra	d5,Unused_Code_3_Loop2 
		bra.s	Unused_Code_3_1 
Unused_Code_3_0: 
		movem.l	(sp)+,a1-a3
		add.w	#$80,a3
		dbra	d6,Unused_Code_3_Loop3 
		moveq	#$1F,d0
Unused_Code_3_Loop5: 
		move.l	(a1)+,(a3)+
		dbra	d0,Unused_Code_3_Loop5 
		addq.l	#1,d7
		dbra	d5,Unused_Code_3_Loop2 
Unused_Code_3_1: 
		bra.s	Unused_Code_3_1 
;------------------------------------------------------------------------------- 
Unused_Code_4: 
		moveq	#7,d0
Unused_Code_4_Loop: 
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		dbra	d0,Unused_Code_4_Loop 
		add.w	#$80,a1
		add.w	#$80,a2
		rts
;--------------------------------------------------------------------------------
_1p2pVs_Spr: 
		incbin 'artnem/1p2pVs.nem'
;===============================================================================
; Title Screen
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Level
; [ Begin ]
;===============================================================================
PlayList: 
		dc.b	$82,$82,$85,$84,$85,$85,$8F,$86,$90,$8D,$84,$8B,$89,$8E,$8A,$87
		dc.b	$8D
		even
PlayList_2P: 
		dc.b	$8C,$82,$85,$84,$85,$85,$8F,$86,$90,$8D,$84,$83,$88,$8E,$8A,$87
		dc.b	$8D
		even
Level: 
		bset	#7,(Game_Mode).w
		tst.w	($FFFFFFF0).w
		bmi.s	Level_Init 
		move.b	#$F9,d0
		bsr.w	Play_Sfx
Level_Init: 
		bsr.w	ClearPLC 
		bsr.w	Pal_FadeFrom 
		tst.w	($FFFFFFF0).w
		bmi.s	loc_496E
		move	#$2700,sr
		bsr.w	ClearScreen 
		jsr	Load_Title_Cards_Art 
		move	#$2300,sr
		moveq	#0,d0
		move.w	d0,($FFFFFE04).w
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	(TilesMainTable),a2 
		lea	0(a2,d0),a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_4968
		bsr.w	LoadPLC 
loc_4968:
		moveq	#1,d0
		bsr.w	LoadPLC 
loc_496E:
		lea	($FFFFAC00).w,a1
		moveq	#0,d0
		move.w	#$FF,d1
loc_4978: 
		move.l	d0,(a1)+
		dbra	d1,loc_4978
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
loc_4988: 
		move.l	d0,(a1)+
		dbra	d1,loc_4988
		lea	($FFFFF628).w,a1
		moveq	#0,d0
		move.w	#$15,d1
loc_4998: 
		move.l	d0,(a1)+
		dbra	d1,loc_4998
		lea	(Misc_Variables).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
loc_49A8: 
		move.l	d0,(a1)+
		dbra	d1,loc_49A8
		lea	($FFFFFE60).w,a1
		moveq	#0,d0
		move.w	#$13,d1
loc_49B8: 
		move.l	d0,(a1)+
		dbra	d1,loc_49B8
		lea	($FFFFE700).w,a1
		moveq	#0,d0
		move.w	#$3F,d1
loc_49C8: 
		move.l	d0,(a1)+
		dbra	d1,loc_49C8
		cmp.w	#$D01,($FFFFFE10).w
		beq.s	Init_Water 
		cmp.b	#$F,($FFFFFE10).w
		beq.s	Init_Water 
		cmp.b	#8,($FFFFFE10).w
		bne.s	Init_No_Water 
Init_Water: 
		move.b	#1,($FFFFF730).w
		move.w	#0,($FFFFFFD8).w
Init_No_Water: 
		lea	(VDP_control_port),a6
		move.w	#$8B03,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$857C,(a6)
		move.w	#$9001,(a6)
		move.w	#$8004,(a6)
		move.w	#$8720,(a6)
		move.w	#$8C81,(a6)
		tst.b	($FFFFFFD2).w
		beq.s	loc_4A38
		btst	#5,(Ctrl_1_Held).w
		beq.s	loc_4A2A
		move.w	#$8C89,(a6)
loc_4A2A:
		btst	#6,(Ctrl_1_Held).w
		beq.s	loc_4A38
		move.b	#1,($FFFFFFFA).w
loc_4A38:
		move.w	#$8ADF,($FFFFF624).w
		tst.w	($FFFFFFD8).w
		beq.s	loc_4A52
		move.w	#$8A6B,($FFFFF624).w
		move.w	#$8014,(a6)
		move.w	#$8C87,(a6)
loc_4A52:
		move.w	($FFFFF624).w,(a6)
		move.l	#$FFFFDC00,($FFFFDCFC).w
		tst.b	($FFFFF730).w
		beq.s	LevelInit_NoWater 
		move.w	#$8014,(a6)
		moveq	#0,d0
		move.w	($FFFFFE10).w,d0
		sub.w	#$800,d0
		ror.b	#1,d0
		lsr.w	#6,d0
		and.w	#$FFFE,d0
		lea	(Water_Height_Array),a1 
		move.w	0(a1,d0),d0
		move.w	d0,($FFFFF646).w
		move.w	d0,($FFFFF648).w
		move.w	d0,($FFFFF64A).w
		clr.b	($FFFFF64D).w
		clr.b	($FFFFF64E).w
		move.b	#1,($FFFFF64C).w
LevelInit_NoWater: 
		moveq	#3,d0
		bsr.w	PalLoad2 
		tst.b	($FFFFF730).w
		beq.s	LevelInit_NoUndewaterPalette 
		moveq	#$15,d0
		cmp.b	#8,($FFFFFE10).w
		beq.s	LevelInit_UndewaterPalette 
		moveq	#$16,d0
		cmp.b	#$D,($FFFFFE10).w
		beq.s	LevelInit_UndewaterPalette 
		moveq	#$17,d0
LevelInit_UndewaterPalette: 
		bsr.w	PalLoad3_Water 
		tst.b	($FFFFFE30).w
		beq.s	LevelInit_NoUndewaterPalette 
		move.b	($FFFFFE53).w,($FFFFF64E).w
LevelInit_NoUndewaterPalette: 
		tst.w	($FFFFFFF0).w
		bmi.s	loc_4B2C
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lea	PlayList(pc),a1 
		tst.w	($FFFFFFD8).w
		beq.s	loc_4AEA
		lea	PlayList_2P(pc),a1 
loc_4AEA:
		move.b	0(a1,d0),d0
		move.w	d0,($FFFFFF90).w
		bsr.w	Play_Music 
		move.b	#$34,($FFFFB080).w
LevelInit_TitleCard:
		move.b	#$C,(Delay_Time).w
		bsr.w	DelayProgram 
		jsr	Load_Objects 
		jsr	Build_Sprites 
		bsr.w	RunPLC 
		move.w	($FFFFB088).w,d0
		cmp.w	($FFFFB0B0).w,d0
		bne.s	LevelInit_TitleCard 
		tst.l	(Plc_Buffer).w
		bne.s	LevelInit_TitleCard 
		jsr	Head_Up_Display_Base 
loc_4B2C:
		moveq	#3,d0
		bsr.w	PalLoad1 
		bsr.w	Level_Size_Load 
		bsr.w	Background_Scroll_Layer 
		clr.w	($FFFFF616).w
		move.w	#$FF20,($FFFFF61E).w
		lea	($FFFFE000).w,a1
		moveq	#0,d0
		move.w	#$FF,d1
loc_4B4E: 
		move.l	d0,(a1)+
		dbra	d1,loc_4B4E
		bsr.w	Load_8x8_Tiles
		bset	#2,($FFFFEE50).w
		bsr.w	Main_Level_Load_16_128_Blocks 
		jsr	Load_16x16_Mappings_For_Dyn_Sprites 
		bsr.w	Load_Tiles_From_Start 
		jsr	Null_Sub 
		bsr.w	Load_Colision_Index 
		bsr.w	Water_Effects 
		move.b	#1,(Object_RAM).w
		cmp.b	#6,($FFFFFE10).w
		beq.s	loc_4BB6
		cmp.b	#$E,($FFFFFE10).w
		beq.s	loc_4BB6
		cmp.b	#$10,($FFFFFE10).w
		beq.s	loc_4BB6
		move.b	#2,($FFFFB040).w
		move.w	($FFFFB008).w,($FFFFB048).w
		move.w	(Object_RAM+y_pos).w,($FFFFB04C).w
		sub.w	#$20,($FFFFB048).w
		add.w	#4,($FFFFB04C).w
loc_4BB6:
		move.b	#8,($FFFFB400).w
		move.b	#8,($FFFFB440).w
		move.w	#0,(Ctrl_1_Logical).w
		move.w	#0,($FFFFF66A).w
		move.w	#0,(Ctrl_1).w
		move.w	#0,($FFFFF606).w
		tst.b	($FFFFF730).w
		beq.s	loc_4BF8
		move.b	#4,($FFFFB780).w
		move.w	#$60,($FFFFB788).w
		move.b	#4,($FFFFB7C0).w
		move.w	#$120,($FFFFB7C8).w
loc_4BF8:
		cmp.b	#$D,($FFFFFE10).w
		bne.s	loc_4C06
		move.b	#$7C,($FFFFB580).w
loc_4C06:
		cmp.b	#$A,($FFFFFE10).w
		bne.s	loc_4C14
		move.b	#7,($FFFFB780).w
loc_4C14:
		moveq	#0,d0
		tst.b	($FFFFFE30).w
		bne.s	loc_4C34
		move.w	d0,(Ring_count).w
		move.l	d0,($FFFFFE22).w
		move.b	d0,($FFFFFE1B).w
		move.w	d0,($FFFFFED0).w
		move.l	d0,($FFFFFED2).w
		move.b	d0,($FFFFFEC7).w
loc_4C34:
		move.b	d0,($FFFFFE1A).w
		move.b	d0,($FFFFFECC).w
		move.b	d0,($FFFFFF4E).w
		move.w	d0,(Debug_placement_mode).w
		move.w	d0,($FFFFFE02).w
		move.b	d0,($FFFFF622).w
		move.b	d0,($FFFFF623).w
		move.w	d0,($FFFFFEF0).w
		move.w	d0,($FFFFFEF2).w
		move.w	d0,($FFFFFEF4).w
		move.w	d0,($FFFFFEF6).w
		bsr.w	Oscillate_Num_Init 
		move.b	#1,($FFFFFE1F).w
		move.b	#1,(Update_HUD_rings).w
		move.b	#1,($FFFFFE1E).w
		move.b	#1,($FFFFFECA).w
		jsr	Load_Object_Pos 
		jsr	Load_Ring_Pos 
		jsr	Load_Triangle_Pos 
		jsr	Load_Objects 
		jsr	Build_Sprites 
		bsr.w	J_Dynamic_Art_Cues 
		bsr.w	Test_End_Level_Art_Load 
		move.w	#4,($FFFFEED2).w
		move.w	#0,($FFFFE500).w
		move.w	#0,($FFFFF790).w
		move.w	#0,($FFFFF732).w
		lea	(Demo_Index),a1
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lsl.w	#2,d0
		move.l	0(a1,d0),a1
		tst.w	($FFFFFFF0).w
		bpl.s	loc_4CE4
		lea	(Demo_End_Index),a1 
		move.w	($FFFFFFF4).w,d0
		subq.w	#1,d0
		lsl.w	#2,d0
		move.l	0(a1,d0),a1
loc_4CE4:
		move.b	1(a1),($FFFFF792).w
		subq.b	#1,($FFFFF792).w
		lea	(Demo_Green_Hill_Miles),a1 
		move.b	1(a1),($FFFFF734).w
		subq.b	#1,($FFFFF734).w
		move.w	#$668,(Demo_Time_left).w
		tst.w	($FFFFFFF0).w
		bpl.s	loc_4D1E
		move.w	#$21C,(Demo_Time_left).w
		cmp.w	#4,($FFFFFFF4).w
		bne.s	loc_4D1E
		move.w	#$1FE,(Demo_Time_left).w
loc_4D1E:
		tst.b	($FFFFF730).w
		beq.s	loc_4D3E
		moveq	#$15,d0
		cmp.b	#8,($FFFFFE10).w
		beq.s	loc_4D3A
		moveq	#$16,d0
		cmp.b	#$D,($FFFFFE10).w
		beq.s	loc_4D3A
		moveq	#$17,d0
loc_4D3A:
		bsr.w	PalLoad4_Water 
loc_4D3E:
		move.w	#$FFFF,($FFFFB0BE).w
		move.b	#$E,($FFFFB1E4).w
		move.w	#$A,($FFFFB1F4).w
loc_4D50: 
		move.b	#$C,(Delay_Time).w
		bsr.w	DelayProgram 
		jsr	Load_Objects 
		jsr	Build_Sprites 
		bsr.w	RunPLC 
		tst.b	($FFFFB140).w
		bne.s	loc_4D50
		lea	($FFFFB080).w,a1
		move.b	#$16,$24(a1)
		move.w	#$3C,$1E(a1)
		move.b	#$16,$64(a1)
		move.w	#$3C,$5E(a1)
		tst.b	$80(a1)
		beq.s	loc_4D9E
		move.b	#$16,$A4(a1)
		move.w	#$3C,$9E(a1)
loc_4D9E:
		bclr	#7,(Game_Mode).w
Level_Main_Loop: 
		bsr.w	Pause 
		move.b	#8,(Delay_Time).w
		bsr.w	DelayProgram 
		addq.w	#1,($FFFFFE04).w
		bsr.w	loc_51DA
		bsr.w	Water_Effects 
		jsr	Load_Objects 
		tst.w	($FFFFFE02).w
		bne.w	Level 
		bsr.w	Background_Scroll_Layer 
		bsr.w	Change_Water_Surface_Pos 
		jsr	Load_Ring_Pos 
		cmp.b	#$C,($FFFFFE10).w
		bne.s	loc_4DE8
		jsr	Load_Triangle_Pos 
loc_4DE8:
		bsr.w	J_Dynamic_Art_Cues 
		bsr.w	PalCycle_Load 
		bsr.w	RunPLC 
		bsr.w	Oscillate_Num_Do 
		bsr.w	Change_Ring_Frame 
		bsr.w	End_Level_Art_Load 
		jsr	Build_Sprites 
		jsr	Load_Object_Pos 
		cmp.b	#8,(Game_Mode).w
		beq.s	loc_4E20
		cmp.b	#$C,(Game_Mode).w
		beq	Level_Main_Loop 
		rts
;--------------------------------------------------------------------------------
loc_4E20:
		tst.w	($FFFFFE02).w
		bne.s	loc_4E3E
		tst.w	(Demo_Time_left).w
		beq.s	loc_4E3E
		cmp.b	#8,(Game_Mode).w
		beq	Level_Main_Loop 
		move.b	#0,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_4E3E:
		cmp.b	#8,(Game_Mode).w
		bne.s	loc_4E58
		move.b	#0,(Game_Mode).w
		tst.w	($FFFFFFF0).w
		bpl.s	loc_4E58
		move.b	#$24,(Game_Mode).w
loc_4E58:
		move.w	#$3C,(Demo_Time_left).w
		move.w	#$3F,($FFFFF626).w
		clr.w	($FFFFF794).w
loc_4E68: 
		move.b	#8,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.w	loc_51DA
		jsr	Load_Objects 
		jsr	Build_Sprites 
		jsr	Load_Object_Pos 
		subq.w	#1,($FFFFF794).w
		bpl.s	loc_4E98
		move.w	#2,($FFFFF794).w
		bsr.w	Pal_FadeOut 
loc_4E98:
		tst.w	(Demo_Time_left).w
		bne.s	loc_4E68
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Change_Water_Surface_Pos
; [ Begin ]
;=============================================================================== 
Change_Water_Surface_Pos: 
		tst.b	($FFFFF730).w
		beq.s	loc_4EC8
		move.w	($FFFFEE00).w,d1
		btst	#0,($FFFFFE05).w
		beq.s	loc_4EB6
		add.w	#$20,d1
loc_4EB6:
		move.w	d1,d0
		add.w	#$60,d0
		move.w	d0,($FFFFB788).w
		add.w	#$120,d1
		move.w	d1,($FFFFB7C8).w
loc_4EC8:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Change_Water_Surface_Pos
; [ End ]
;===============================================================================
		 
;===============================================================================
; Sub Routine Water_Effects
; [ Begin ]
;=============================================================================== 
Water_Effects: 
		tst.b	($FFFFF730).w
		beq.s	loc_4F26
		tst.b	($FFFFEEDC).w
		bne.s	loc_4EE2
		cmp.b	#6,($FFFFB024).w
		bcc.s	loc_4EE2
		bsr.w	Dynamic_Water_Height 
loc_4EE2:
		clr.b	($FFFFF64E).w
		moveq	#0,d0
		cmp.b	#$F,($FFFFFE10).w
		beq.s	loc_4EF6
		move.b	($FFFFFE60).w,d0
		lsr.w	#1,d0
loc_4EF6:
		add.w	($FFFFF648).w,d0
		move.w	d0,($FFFFF646).w
		move.w	($FFFFF646).w,d0
		sub.w	(Camera_Y_pos).w,d0
		bcc.s	loc_4F18
		tst.w	d0
		bpl.s	loc_4F18
		move.b	#$DF,($FFFFF625).w
		move.b	#1,($FFFFF64E).w
loc_4F18:
		cmp.w	#$DF,d0
		bcs.s	loc_4F22
		move.w	#$DF,d0
loc_4F22:
		move.b	d0,($FFFFF625).w
loc_4F26:
		cmp.b	#$A,($FFFFFE10).w
		bne.s	loc_4F32
		bsr.w	loc_5074
loc_4F32:
		cmp.b	#6,($FFFFFE10).w
		bne.s	loc_4F3E
		bsr.w	loc_4FC6
loc_4F3E:
		rts
;--------------------------------------------------------------------------------
Water_Height_Array: 
		dc.w	$600,$600,$600,$600,$600,$600,$600,$600
		dc.w	$600,$600,$600,$710,$600,$600,$410,$510 
Dynamic_Water_Height: 
		moveq	#0,d0
		move.w	($FFFFFE10).w,d0
		sub.w	#$800,d0
		ror.b	#1,d0
		lsr.w	#6,d0
		and.w	#$FFFE,d0
		move.w	dynamic_Water_Index(pc,d0),d0 
		jsr	Dynamic_Water_Index(pc,d0) 
		moveq	#0,d1
		move.b	($FFFFF64C).w,d1
		move.w	($FFFFF64A).w,d0
		sub.w	($FFFFF648).w,d0
		beq.s	loc_4F92
		bcc.s	loc_4F8E
		neg.w	d1
loc_4F8E:
		add.w	d1,($FFFFF648).w
loc_4F92:
		rts
;--------------------------------------------------------------------------------
Dynamic_Water_Index: 
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; HPz 1
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; HPz 2
		dc.w	dynamic_Null_Water-dynamic_Water_Index ;
		dc.w	dynamic_Null_Water-dynamic_Water_Index ;
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; OOz 1
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; OOz 2
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; DHz 1
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; DHz 2
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; CNz 1
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; CNz 2
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; CPz 1
		dc.w	dynamic_CPz_Water-dynamic_Water_Index ; CPz 2
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; DEz 1
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; DEz 2
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; NGHz 1
		dc.w	dynamic_Null_Water-dynamic_Water_Index ; NGHz 2
Dynamic_Null_Water: 
		rts
;--------------------------------------------------------------------------------
Dynamic_CPz_Water: 
		cmp.w	#$1DE0,($FFFFEE00).w
		bcs.s	loc_4FC4
		move.w	#$510,($FFFFF64A).w
loc_4FC4:
		rts
;--------------------------------------------------------------------------------
loc_4FC6:
		tst.w	(Debug_placement_mode).w
		bne.w	loc_5062
		lea	(loc_5064),a2
		moveq	#1,d1
		lea	(Object_RAM).w,a1
loc_4FDA:
		move.w	8(a1),d0
		cmp.w	(a2),d0
		bcs loc_504C
		cmp.w	4(a2),d0
		bcc loc_504C
		move.w	$C(a1),d2
		cmp.w	2(a2),d2
		bcs loc_504C
		cmp.w	6(a2),d2
		bcc.s	loc_504C
		tst.b	($FFFFF7C9).w
		bne.w	loc_5062
		cmp.b	#4,$24(a1)
		bcc.s	loc_505E
		move.b	#1,($FFFFF7C7).w
		sub.w	#4,8(a1)
		move.w	#$FC00,$10(a1)
		move.w	#0,$12(a1)
		move.b	#$F,$1C(a1)
		bset	#1,$22(a1)
		btst	#0,(Ctrl_1_Held).w
		beq.s	loc_503E
		subq.w	#1,$C(a1)
loc_503E:
		btst	#1,(Ctrl_1_Held).w
		beq.s	loc_504A
		addq.w	#1,$C(a1)
loc_504A:
		rts
;--------------------------------------------------------------------------------
loc_504C:
		addq.w	#8,a2
		dbra	d1,loc_4FDA
		tst.b	($FFFFF7C7).w
		beq.s	loc_5062
		move.b	#0,$1C(a1)
loc_505E:
		clr.b	($FFFFF7C7).w
loc_5062:
		rts
;--------------------------------------------------------------------------------
loc_5064: 
		dc.b	$15,$0,$4,$0,$1A,$F0,$5,$80,$20,$F0,$6,$18,$25,$0,$6,$80
loc_5074:
		lea	(Object_RAM).w,a1
		move.b	(Ctrl_1_Held_Logical).w,d2
		bsr.s	loc_5086
		lea	($FFFFB040).w,a1
		move.b	($FFFFF66A).w,d2
loc_5086:
		btst	#1,$22(a1)
		bne.s	loc_50BA
		move.w	$C(a1),d0
		add.w	d0,d0
		and.w	#$F00,d0
		move.w	8(a1),d1
		lsr.w	#7,d1
		and.w	#$7F,d1
		add.w	d1,d0
		lea	($FFFF8000).w,a2
		move.b	0(a2,d0),d0
		lea	loc_51DA(pc),a2
		moveq	#$1F,d1
loc_50B2: 
		cmp.b	-(a2),d0 
		dbeq	D1,loc_50B2
		beq.s	loc_50CE
loc_50BA:
		tst.b	$2B(a1)
		bpl.s	loc_50CC
		move.w	#5,$2E(a1)
		and.b	#$7F,$2B(a1)
loc_50CC:
		rts
;--------------------------------------------------------------------------------
loc_50CE:
		lea	(loc_519A),a2
		move.b	0(a2,d1),d0
		beq.s	loc_512A
		move.b	$14(a1),d1
		tst.b	d0
		bpl.s	loc_50EE
		cmp.b	d0,d1
		ble.s	loc_50F8
		sub.w	#$40,$14(a1)
		bra.s	loc_50F8
loc_50EE:
		cmp.b	d0,d1
		bge.s	loc_50F8
		add.w	#$40,$14(a1)
loc_50F8:
		bclr	#0,$22(a1)
		tst.b	d1
		bpl.s	loc_5108
		bset	#0,$22(a1)
loc_5108:
		move.b	#$1B,$1C(a1)
		or.b	#$80,$2B(a1)
		move.b	($FFFFFE0F).w,d0
		and.b	#$1F,d0
		bne.s	loc_5128
		move.w	#$F0,d0
		jsr	Play_Sfx
loc_5128:
		rts
;--------------------------------------------------------------------------------
loc_512A:
		move.w	#4,d1
		move.w	$14(a1),d0
		btst	#2,d2
		beq.s	loc_514C
		move.b	#0,$1C(a1)
		bset	#0,$22(a1)
		sub.w	d1,d0
		tst.w	d0
		bpl.s	loc_514C
		sub.w	d1,d0
loc_514C:
		btst	#3,d2
		beq.s	loc_5166
		move.b	#0,$1C(a1)
		bclr	#0,$22(a1)
		add.w	d1,d0
		tst.w	d0
		bmi.s	loc_5166
		add.w	d1,d0
loc_5166:
		move.w	#4,d1
		tst.w	d0
		beq.s	loc_518E
		bmi.s	loc_5180
		sub.w	d1,d0
		bhi.s	loc_517E
		move.w	#0,d0
		move.b	#5,$1C(a1)
loc_517E:
		bra.s	loc_518E
loc_5180:
		add.w	d1,d0
		bhi.s	loc_518E
		move.w	#0,d0
		move.b	#5,$1C(a1)
loc_518E:
		move.w	d0,$14(a1)
		or.b	#$80,$2B(a1)
		rts
;--------------------------------------------------------------------------------
loc_519A:
		dc.b	$F8,$F8,$F8,$8,$8,$0,$0,$0,$F8,$F8,$0,$8,$8,$8,$0,$8
		dc.b	$8,$8,$0,$F8,$0,$0,$F8,$8,$F8,$F8,$F8,$8,$8,$8,$F8,$F8
		dc.b	$2F,$30,$31,$33,$35,$38,$3A,$3C,$63,$64,$83,$90,$91,$93,$A1,$A3
		dc.b	$BD,$C7,$C8,$CE,$D7,$D8,$E6,$EB,$EC,$ED,$F1,$F2,$F3,$F4,$FA,$FD
loc_51DA:
		tst.w	($FFFFFFF0).w
		bne.s	loc_5258
		rts
;--------------------------------------------------------------------------------

		lea	($FE8000),a1
		move.w	($FFFFF790).w,d0
		add.w	d0,a1
		move.b	(Ctrl_1).w,d0
		cmp.b	(a1),d0
		bne.s	loc_5204
		addq.b	#1,1(a1)
		cmp.b	#$FF,1(a1)
		beq.s	loc_5204
		bra.s	loc_5218
loc_5204:
		move.b	d0,2(a1)
		move.b	#0,3(a1)
		addq.w	#2,($FFFFF790).w
		and.w	#$3FF,($FFFFF790).w
loc_5218:
		cmp.b	#0,($FFFFFE10).w
		bne.s	loc_5256
		lea	($FEC000),a1
		move.w	($FFFFF732).w,d0
		add.w	d0,a1
		move.b	($FFFFF606).w,d0
		cmp.b	(a1),d0
		bne.s	loc_5242
		addq.b	#1,1(a1)
		cmp.b	#$FF,1(a1)
		beq.s	loc_5242
		bra.s	loc_5256
loc_5242:
		move.b	d0,2(a1)
		move.b	#0,3(a1)
		addq.w	#2,($FFFFF732).w
		and.w	#$3FF,($FFFFF732).w
loc_5256:
		rts
;--------------------------------------------------------------------------------
loc_5258:
		tst.b	(Ctrl_1).w
		bpl.s	loc_526A
		tst.w	($FFFFFFF0).w
		bmi.s	loc_526A
		move.b	#4,(Game_Mode).w
loc_526A:
		lea	(Demo_Index),a1 
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		cmp.b	#$10,(Game_Mode).w
		bne.s	loc_5280
		moveq	#6,d0
loc_5280:
		lsl.w	#2,d0
		move.l	0(a1,d0),a1
		move.w	($FFFFF790).w,d0
		add.w	d0,a1
		move.b	(a1),d0
		lea	(Ctrl_1).w,a0
		move.b	d0,d1
		moveq	#0,d2
		eor.b	d2,d0
		move.b	d1,(a0)+
		and.b	d1,d0
		move.b	d0,(a0)+
		subq.b	#1,($FFFFF792).w
		bcc.s	loc_52AE
		move.b	3(a1),($FFFFF792).w
		addq.w	#2,($FFFFF790).w
loc_52AE:
		cmp.b	#0,($FFFFFE10).w
		bne.s	loc_52E6
		lea	(Demo_Green_Hill_Miles),a1 
		move.w	($FFFFF732).w,d0
		add.w	d0,a1
		move.b	(a1),d0
		lea	($FFFFF606).w,a0
		move.b	d0,d1
		moveq	#0,d2
		eor.b	d2,d0
		move.b	d1,(a0)+
		and.b	d1,d0
		move.b	d0,(a0)+
		subq.b	#1,($FFFFF734).w
		bcc.s	loc_52E4
		move.b	3(a1),($FFFFF734).w
		addq.w	#2,($FFFFF732).w
loc_52E4:
		rts
;--------------------------------------------------------------------------------
loc_52E6:
		move.w	#0,($FFFFF606).w
		rts
;--------------------------------------------------------------------------------
Demo_Index: 
		dc.l	demo_Green_Hill
		dc.l	demo_Green_Hill 
		dc.l	demo_Green_Hill 
		dc.l	demo_Green_Hill 
		dc.l	demo_Green_Hill 
		dc.l	demo_Green_Hill 
		dc.l	demo_Green_Hill 
		dc.l	demo_Hill_Top 
		dc.l	demo_Casino_Night 
		dc.l	demo_Green_Hill 
		dc.l	demo_Green_Hill 
		dc.l	demo_Green_Hill 
		dc.l	demo_Casino_Night 
		dc.l	demo_Chemical_Plant 
		dc.l	demo_Green_Hill 
		dc.l	demo_Green_Hill 
		dc.l	demo_Green_Hill 

		dc.l	$FE8000,$FE8000,$FE8000,$FE8000
		dc.l	$FE8000,$FE8000,$FE8000,$FE8000
		dc.l	$FE8000,$FE8000,$FE8000,$FE8000
		dc.l	$FE8000,$FE8000,$FE8000,$FE8000
		dc.l	$FE8000
Demo_End_Index:
		dc.w	$8B,$837,$42,$85C,$6A,$85F,$2F,$82C
		dc.w	$21,$803,$2830,$808,$2E,$815,$F,$846
		dc.w	$1A,$8FF,$8CA,$0,$0,$0,$0,$0 
Load_Colision_Index: 
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lsl.w	#2,d0
		move.l	#$FFFFD000,($FFFFF796).w
		move.l	Primary_Colision_Index(pc,d0),a1 
		lea	($FFFFD000).w,a2
		bsr.s	loc_53C8
		move.l	Secundary_Colision_Index(pc,d0),a1 
		lea	($FFFFD600).w,a2
loc_53C8:
		move.w	#$2FF,d1
		moveq	#0,d2
loc_53CE: 
		move.b	(a1)+,d2
		move.w	d2,(a2)+
		dbra	d1,loc_53CE
		rts
;--------------------------------------------------------------------------------
Primary_Colision_Index: 
		dc.l	Green_Hill_Colision_1 
		dc.l	Null_Colision 
		dc.l	Metropolis_Colision 
		dc.l	Null_Colision 
		dc.l	Metropolis_Colision 
		dc.l	Metropolis_Colision 
		dc.l	Sky_Fortress_Colision_1 
		dc.l	Green_Hill_Colision_1 
		dc.l	Hidden_Palace_Colision 
		dc.l	Null_Colision 
		dc.l	Oil_Ocean_Colision 
		dc.l	dust_Hill_Colision 
		dc.l	Casino_Night_Colision_1 
		dc.l	Chemical_Plant_Colision_1 
		dc.l	Chemical_Plant_Colision_1 
		dc.l	Neo_Green_Hill_Colision_1 
		dc.l	Sky_Fortress_Colision_1 
Secundary_Colision_Index: 
		dc.l	Green_Hill_Colision_2 
		dc.l	Null_Colision 
		dc.l	Metropolis_Colision 
		dc.l	Null_Colision 
		dc.l	Metropolis_Colision 
		dc.l	Metropolis_Colision 
		dc.l	Sky_Fortress_Colision_2 
		dc.l	Green_Hill_Colision_2 
		dc.l	Hidden_Palace_Colision 
		dc.l	Null_Colision 
		dc.l	Oil_Ocean_Colision 
		dc.l	dust_Hill_Colision 
		dc.l	Casino_Night_Colision_2 
		dc.l	Chemical_Plant_Colision_2 
		dc.l	Chemical_Plant_Colision_2 
		dc.l	Neo_Green_Hill_Colision_2 
		dc.l	Sky_Fortress_Colision_2 
;===============================================================================
; Sub Routine Oscillate_Num_Init
; [ Begin ]
;=============================================================================== 
Oscillate_Num_Init 
		lea	($FFFFFE5E).w,a1
		lea	(Oscillate_Data),a2 
		moveq	#$20,d1
loc_546C: 
		move.w	(a2)+,(a1)+
		dbra	d1,loc_546C
		rts
;--------------------------------------------------------------------------------
Oscillate_Data: 
		dc.w	$7D,$80,$0,$80,$0,$80,$0,$80
		dc.w	$0,$80,$0,$80,$0,$80,$0,$80
		dc.w	$0,$80,$0,$3848,$EE,$2080,$B4,$3080
		dc.w	$10E,$5080,$1C2,$7080,$276,$80,$0,$4000
		dc.w	$FE 
;===============================================================================
; Sub Routine Oscillate_Num_Init
; [ End ]
;===============================================================================
		
;===============================================================================
; Sub Routine Oscillate_Num_Do
; [ Begin ]
;===============================================================================
Oscillate_Num_Do: 
		tst.w	($FFFFFFD8).w
		bne.s	loc_54C4
		cmp.b	#6,($FFFFB024).w
		bcc.s	loc_5512
loc_54C4:
		lea	($FFFFFE5E).w,a1
		lea	(Oscillate_Data2),a2 
		move.w	(a1)+,d3
		moveq	#$F,d1
loc_54D2:
		move.w	(a2)+,d2
		move.w	(a2)+,d4
		btst D1,d3
		bne.s	loc_54F2
		move.w	2(a1),d0
		add.w	d2,d0
		move.w	d0,2(a1)
		add.w	d0,0(a1)
		cmp.b	0(a1),d4
		bhi.s	loc_5508
		bset D1,d3
		bra.s	loc_5508
loc_54F2:
		move.w	2(a1),d0
		sub.w	d2,d0
		move.w	d0,2(a1)
		add.w	d0,0(a1)
		cmp.b	0(a1),d4
		bls.s	loc_5508
		bclr D1,d3
loc_5508:
		addq.w	#4,a1
		dbra	d1,loc_54D2
		move.w	d3,($FFFFFE5E).w
loc_5512:
		rts
;--------------------------------------------------------------------------------
Oscillate_Data2: 
		dc.w	$2,$10,$2,$18,$2,$20,$2,$30
		dc.w	$4,$20,$8,$8,$8,$40,$4,$40
		dc.w	$2,$38,$2,$38,$2,$20,$3,$30
		dc.w	$5,$50,$7,$70,$2,$40,$2,$40
;===============================================================================
; Sub Routine Oscillate_Num_Do
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Change_Ring_Frame
; [ Begin ]
;===============================================================================
Change_Ring_Frame: 
		subq.b	#1,($FFFFFEA0).w
		bpl.s	loc_556A
		move.b	#$B,($FFFFFEA0).w
		subq.b	#1,($FFFFFEA1).w
		and.b	#7,($FFFFFEA1).w
loc_556A:
		subq.b	#1,($FFFFFEA2).w
		bpl.s	loc_5580
		move.b	#7,($FFFFFEA2).w
		addq.b	#1,($FFFFFEA3).w
		and.b	#3,($FFFFFEA3).w
loc_5580:
		subq.b	#1,($FFFFFEA4).w
		bpl.s	loc_559E
		move.b	#7,($FFFFFEA4).w
		addq.b	#1,($FFFFFEA5).w
		cmp.b	#6,($FFFFFEA5).w
		bcs.s	loc_559E
		move.b	#0,($FFFFFEA5).w
loc_559E:
		tst.b	($FFFFFEA6).w
		beq.s	loc_55C0
		moveq	#0,d0
		move.b	($FFFFFEA6).w,d0
		add.w	($FFFFFEA8).w,d0
		move.w	d0,($FFFFFEA8).w
		rol.w	#7,d0
		and.w	#3,d0
		move.b	d0,($FFFFFEA7).w
		subq.b	#1,($FFFFFEA6).w
loc_55C0:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Change_Ring_Frame
; [ End ]
;=============================================================================== 
 
;===============================================================================
; Sub Routine Test_End_Level_Art_Load
; [ Begin ]
;=============================================================================== 
Test_End_Level_Art_Load: 
		move.w	#0,($FFFFFFC8).w
		tst.w	($FFFFFFD8).w
		bne.s	Set_End_Level_Flag 
		cmp.w	#1,($FFFFFE10).w
		beq	Dont_Set_End_Level_Flag 
		cmp.w	#$500,($FFFFFE10).w
		beq	Dont_Set_End_Level_Flag 
		cmp.w	#$600,($FFFFFE10).w
		beq	Dont_Set_End_Level_Flag 
		cmp.w	#$701,($FFFFFE10).w
		beq	Dont_Set_End_Level_Flag 
		cmp.w	#$A01,($FFFFFE10).w
		beq	Dont_Set_End_Level_Flag 
		cmp.w	#$B01,($FFFFFE10).w
		beq.s	Dont_Set_End_Level_Flag 
		cmp.w	#$C01,($FFFFFE10).w
		beq.s	Dont_Set_End_Level_Flag 
		cmp.w	#$D01,($FFFFFE10).w
		beq.s	Dont_Set_End_Level_Flag 
		cmp.w	#$E00,($FFFFFE10).w
		beq.s	Dont_Set_End_Level_Flag 
		cmp.w	#$F01,($FFFFFE10).w
		beq.s	Dont_Set_End_Level_Flag 
		cmp.w	#$1000,($FFFFFE10).w
		beq.s	Dont_Set_End_Level_Flag 
Set_End_Level_Flag: 
		move.w	#1,($FFFFFFC8).w
Dont_Set_End_Level_Flag: 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Test_End_Level_Art_Load
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine End_Level_Art_Load
; [ Begin ]
;=============================================================================== 
End_Level_Art_Load: 
		tst.w	($FFFFFFC8).w
		beq.s	Skip_End_Level_Art_Load 
		tst.w	(Debug_placement_mode).w
		bne.s	Skip_End_Level_Art_Load 
		move.w	($FFFFEE00).w,d0
		move.w	(Camera_Max_X_pos).w,d1
		sub.w	#$100,d1
		cmp.w	d1,d0
		blt.s	loc_5670
		tst.b	($FFFFFE1E).w
		beq.s	loc_5670
		cmp.w	(Camera_Min_X_pos).w,d1
		beq.s	loc_5670
		move.w	d1,(Camera_Min_X_pos).w
		tst.w	($FFFFFFD8).w
		bne.s	Skip_End_Level_Art_Load 
		moveq	#$27,d0
		bra.w	LoadPLC2 
loc_5670:
		tst.w	($FFFFFFD8).w
		beq.s	Skip_End_Level_Art_Load 
		move.w	($FFFFEE20).w,d0
		move.w	($FFFFEEFA).w,d1
		sub.w	#$100,d1
		cmp.w	d1,d0
		blt.s	Skip_End_Level_Art_Load 
		tst.b	($FFFFFECA).w
		beq.s	Skip_End_Level_Art_Load 
		cmp.w	($FFFFEEF8).w,d1
		beq.s	Skip_End_Level_Art_Load 
		move.w	d1,($FFFFEEF8).w
Skip_End_Level_Art_Load: 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine End_Level_Art_Load
; [ End ]
;=============================================================================== 
Demo_Green_Hill:
		dc.b	$0,$44,$8,$0,$28,$5,$8,$59,$28,$4,$8,$35,$28,$6,$8,$42
		dc.b	$28,$4,$8,$19,$0,$F,$8,$A,$28,$9,$8,$4A,$28,$9,$8,$10
		dc.b	$0,$5,$4,$1B,$2,$0,$8,$4B,$28,$2D,$8,$55,$28,$9,$8,$26
		dc.b	$28,$1C,$8,$19,$28,$8,$8,$FF,$8,$96,$28,$13,$8,$1D,$28,$19
		dc.b	$8,$2A,$28,$7,$9,$0,$1,$0,$5,$20,$4,$2,$5,$1,$0,$0
		dc.b	$8,$3A,$0,$25,$4,$A,$24,$9,$4,$1C,$0,$3,$8,$3A,$28,$6
		dc.b	$8,$C,$0,$16,$8,$0,$28,$F,$8,$33,$28,$7,$8,$4,$0,$46
		dc.b	$8,$6A,$0,$29,$80,$0,$C0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
Demo_Green_Hill_Miles:
		dc.b	$0,$46,$8,$1E,$28,$A,$8,$5E,$28,$30,$8,$66,$0,$F,$8,$F
		dc.b	$28,$2E,$8,$0,$0,$1F,$8,$12,$0,$13,$8,$A,$0,$16,$4,$D
		dc.b	$0,$8,$4,$10,$0,$30,$8,$6B,$28,$14,$8,$80,$A,$2,$2,$23
		dc.b	$0,$7,$8,$13,$28,$17,$8,$0,$0,$3,$4,$3,$5,$0,$1,$0
		dc.b	$9,$1,$8,$3C,$28,$7,$0,$18,$8,$4D,$28,$12,$8,$1,$0,$4
		dc.b	$8,$B,$0,$7,$8,$1B,$0,$9,$20,$5,$28,$13,$8,$4,$0,$21
		dc.b	$8,$11,$0,$20,$8,$51,$0,$B,$4,$57,$0,$D,$2,$27,$A,$0
		dc.b	$0,$2,$9,$1,$8,$2A,$28,$15,$8,$3,$28,$19,$8,$A,$0,$A
		dc.b	$8,$2,$28,$1B,$8,$33,$0,$27,$8,$3A,$9,$12,$1,$7,$0,$13
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
Demo_Hill_Top:
		dc.b	$0,$5,$1,$1D,$9,$3,$29,$5,$9,$10,$1,$0,$0,$13,$4,$0
		dc.b	$5,$A,$25,$7,$5,$10,$4,$1,$0,$C,$8,$4,$9,$C,$29,$A
		dc.b	$9,$10,$8,$3,$0,$1C,$20,$7,$0,$B,$4,$6,$0,$25,$20,$6
		dc.b	$0,$22,$8,$5,$0,$25,$4,$E,$0,$33,$8,$7,$0,$39,$8,$A
		dc.b	$28,$8,$8,$16,$0,$24,$8,$74,$28,$2,$29,$7,$9,$3,$0,$F
		dc.b	$8,$D,$0,$5,$4,$C,$0,$1,$20,$2,$28,$0,$2A,$8,$28,$2
		dc.b	$8,$1E,$0,$4,$4,$13,$0,$12,$8,$18,$28,$B,$8,$11,$0,$2C
		dc.b	$8,$C,$0,$D,$20,$4,$28,$3,$8,$5,$0,$22,$4,$12,$0,$4
		dc.b	$8,$1A,$0,$D,$4,$6,$0,$37,$8,$C,$0,$19,$8,$D,$0,$C
		dc.b	$4,$9,$0,$3,$8,$20,$0,$1A,$4,$6,$0,$22,$8,$9,$0,$9
		dc.b	$8,$16,$0,$2F,$8,$E,$28,$4,$20,$2,$0,$8,$4,$19,$0,$5
		dc.b	$8,$6,$28,$8,$8,$8,$0,$24,$8,$72,$A,$9,$2,$E,$A,$6B
		dc.b	$8A,$0,$40,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
Demo_Casino_Night:
		dc.b	$0,$40,$8,$33,$28,$6,$8,$39,$28,$5,$8,$D,$0,$25,$8,$10
		dc.b	$28,$2A,$8,$1C,$2,$0,$26,$3,$22,$0,$2A,$0,$28,$6,$8,$22
		dc.b	$2,$0,$6,$F,$4,$8,$6,$0,$2,$E,$6,$2F,$2,$79,$6,$1
		dc.b	$4,$43,$24,$F,$4,$17,$0,$9,$8,$1C,$28,$3,$8,$45,$0,$5
		dc.b	$8,$1A,$28,$33,$8,$72,$0,$F,$4,$15,$24,$10,$4,$B,$0,$24
		dc.b	$4,$1,$24,$8,$4,$7,$0,$6,$4,$4,$0,$1E,$24,$E,$4,$15
		dc.b	$0,$1E,$20,$3,$24,$F,$4,$0,$0,$7,$8,$12,$4,$9,$24,$F
		dc.b	$4,$6,$0,$A,$4,$62,$24,$12,$20,$4,$0,$21,$28,$E,$8,$16
		dc.b	$0,$19,$8,$29,$0,$63,$4,$15,$24,$9,$4,$39,$0,$31,$8,$25
		dc.b	$28,$2,$8,$12,$0,$93,$80,$0,$C0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
Demo_Chemical_Plant: 
		dc.b	$0,$1B,$1,$30,$0,$19,$8,$29,$28,$13,$8,$3,$0,$1D,$20,$3
		dc.b	$28,$1E,$8,$2,$0,$9,$4,$5,$0,$2E,$8,$1E,$28,$5,$20,$3
		dc.b	$0,$B,$4,$1,$5,$7,$4,$0,$0,$2F,$28,$3,$2A,$4,$A,$0
		dc.b	$8,$6,$0,$24,$8,$2,$28,$6,$8,$1,$0,$26,$8,$FF,$8,$14
		dc.b	$28,$A,$8,$3,$0,$60,$8,$E,$28,$7,$8,$C,$0,$8,$4,$B
		dc.b	$0,$23,$8,$5,$0,$93,$8,$19,$28,$11,$8,$78,$28,$F,$8,$FF
		dc.b	$8,$83,$28,$D,$8,$82,$0,$1F,$80,$0,$40,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
;===============================================================================
; Sub Routine Load_8x8_Tiles
; [ Begin ]
;=============================================================================== 
Load_8x8_Tiles:
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	(TilesMainTable),a2 
		lea	0(a2,d0),a2
		move.l	(a2)+,d0
		and.l	#$FFFFFF,d0
		move.l	d0,a0
		lea	(RAM_Start),a1
		bsr.w	KosinskiDec 
		move.w	a1,d3
		cmp.b	#7,($FFFFFE10).w
		bne.s	loc_5BD4
		move.w	#$3F80,d3
loc_5BD4:
		cmp.b	#6,($FFFFFE10).w
		bne.s	loc_5BE0
		move.w	#$60E0,d3
loc_5BE0:
		cmp.b	#$E,($FFFFFE10).w
		bne.s	loc_5BEC
		move.w	#$64C0,d3
loc_5BEC:
		move.w	d3,d7
		and.w	#$FFF,d3
		lsr.w	#1,d3
		rol.w	#4,d7
		and.w	#$F,d7
loc_5BFA: 
		move.w	d7,d2
		lsl.w	#7,d2
		lsl.w	#5,d2
		move.l	#$FFFFFF,d1
		move.w	d2,d1
		jsr	DMA_68KtoVRAM 
		move.w	d7,-(sp)
		move.b	#$C,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.w	RunPLC 
		move.w	(sp)+,d7
		move.w	#$800,d3
		dbra	d7,loc_5BFA
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Load_8x8_Tiles
; [ End ]
;=============================================================================== 
		nop ; Filler
J_Dynamic_Art_Cues: 
		jmp	Dynamic_Art_Cues 
;===============================================================================
; Sub Routine Level
; [ End ]
;=============================================================================== 
		cnop	0,4 ; Filler 
;===============================================================================
; Special Stage
; [ Begin ]
;=============================================================================== 
SpecialStage: 
		move.w	#$CA,d0
		bsr.w	Play_Sfx
		bsr.w	Pal_MakeFlash 
		tst.w	($FFFFFFD8).w
		beq.s	loc_5C52
		move.w	#0,($FFFFFFD8).w
		st (System_Stack).w
		bra.s	loc_5C56
loc_5C52:
		sf (System_Stack).w
loc_5C56:
		move	#$2700,sr
		lea	(VDP_control_port),a6
		move.w	#$8B03,(a6)
		move.w	#$8004,(a6)
		move.w	#$8ADF,($FFFFF624).w
		move.w	#$8230,(a6)
		move.w	#$8405,(a6)
		move.w	#$8C08,(a6)
		move.w	#$9003,(a6)
		move.w	#$8700,(a6)
		move.w	#$8D3F,(a6)
		move.w	#$857C,(a6)
		move.w	(VDP_Reg0_Val).w,d0
		and.b	#$BF,d0
		move.w	d0,(VDP_control_port)
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$941F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000082,(a5)
		move.w	#0,(VDP_data_port)
loc_5CBA: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_5CBA
		move.w	#$8F02,(a5)
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$941F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000083,(a5)
		move.w	#0,(VDP_data_port)
loc_5CE8: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_5CE8
		move.w	#$8F02,(a5)
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$941F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$60000082,(a5)
		move.w	#0,(VDP_data_port)
loc_5D16: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_5D16
		move.w	#$8F02,(a5)
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$9403937F,(a5)
		move.w	#$9780,(a5)
		move.l	#$7C000083,(a5)
		move.w	#0,(VDP_data_port)
loc_5D44: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_5D44
		move.w	#$8F02,(a5)
		clr.l	($FFFFF616).w
		clr.l	($FFFFF61A).w
		clr.b	($FFFFDB23).w
		lea	($FFFFF800).w,a1
		moveq	#0,d0
		move.w	#$A0,d1
loc_5D66: 
		move.l	d0,(a1)+
		dbra	d1,loc_5D66
		lea	($FFFFE000).w,a1
		moveq	#0,d0
		move.w	#$100,d1
loc_5D76: 
		move.l	d0,(a1)+
		dbra	d1,loc_5D76
		lea	($FFFFD000).w,a1
		moveq	#0,d0
		move.w	#$300,d1
loc_5D86: 
		move.l	d0,(a1)+
		dbra	d1,loc_5D86
		lea	($FFFFAC00).w,a1
		moveq	#0,d0
		move.w	#$FF,d1
loc_5D96: 
		move.l	d0,(a1)+
		dbra	d1,loc_5D96
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
loc_5DA6: 
		move.l	d0,(a1)+
		dbra	d1,loc_5DA6
		move	#$2300,sr
		lea	(VDP_control_port),a6
		move.w	#$8E02,(a6)
		bsr.w	loc_7898
		bsr.w	loc_78E2
		move.w	#0,($FFFFDB0A).w
		moveq	#$3C,d0
		bsr.w	RunPLC_ROM 
		clr.b	($FFFFF711).w
		move.l	#0,($FFFFEE00).w
		move.l	#0,(Camera_Y_pos).w
		move.l	#0,($FFFFEEF0).w
		move.l	#0,($FFFFEEF4).w
		move.b	#9,(Object_RAM).w	; Load Sonic Object
		move.b	#$10,($FFFFB040).w	; Load Miles Object
		move.b	#$5E,($FFFFB080).w	; Load Head up Display Object
		move.b	#$5F,($FFFFB0C0).w	; Load "START" and Flags Object
		move.b	#$87,($FFFFB100).w
		move.w	#$80,($FFFFF73E).w
		move.w	#$36,($FFFFF740).w
		bsr.w	loc_794E
		bsr.w	loc_79D0
		bsr.w	loc_82D4
		move.l	#$C0000,($FFFFDB12).w
loc_5E30: 
		move.b	#$A,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.w	RunPLC 
		tst.l	(Plc_Buffer).w
		bne.s	loc_5E30
		clr.w	(Ctrl_1).w
		clr.w	($FFFFF606).w
loc_5E4C: 
		move.b	#$A,(Delay_Time).w	
		bsr.w	DelayProgram 
		move.b	($FFFFDB0D).w,d0
		bne.s	loc_5E4C
		bsr.w	loc_6210
loc_5E60: 
		move.b	#$A,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.w	loc_6210
		bsr.w	loc_6128
		bsr.w	loc_6148
		move.b	($FFFFDB1F).w,d0
		subq.w	#1,d0
		bne.s	loc_5E60
		bsr.w	loc_79E0
		jsr	Load_Objects 
		jsr	Build_Sprites
		bsr.w	RunPLC 
		move.w	#$92,d0
		bsr.w	Play_Music 
		move.w	(VDP_Reg0_Val).w,d0
		or.b	#$40,d0
		move.w	d0,(VDP_control_port)
		bsr.w	Pal_MakeWhite 
loc_5EAC: 
		bsr.w	Pause 
		move.b	#$A,(Delay_Time).w
		bsr.w	DelayProgram 
		bsr.w	loc_6210
		bsr.w	loc_819E
		bsr.w	loc_6128
		bsr.w	loc_6148
		bsr.w	loc_79E0
		jsr	Load_Objects 
		jsr	Build_Sprites 
		bsr.w	RunPLC 
		tst.b	($FFFFDB23).w
		beq.s	loc_5EAC
		moveq	#$3D,d0
		bsr.w	LoadPLC 
loc_5EEA: 
		bsr.w	Pause 
		move.b	#$A,(Delay_Time).w
		bsr.w	DelayProgram 
		tst.b	($FFFFDB87).w
		beq.s	loc_5F0A
		and.w	#$8080,(Ctrl_1_Held).w
		and.w	#$8080,(Ctrl_2_Held).w
loc_5F0A:
		bsr.w	loc_6210
		bsr.w	loc_819E
		bsr.w	loc_6128
		bsr.w	loc_6148
		bsr.w	loc_79E0
		bsr.w	loc_6056
		jsr	Load_Objects 
		tst.b	($FFFFDB86).w
		bne.s	loc_5F40
		jsr	Build_Sprites 
		bsr.w	RunPLC 
		move.w	(Ctrl_1).w,(Ctrl_1_Logical).w
		bra.s	loc_5EEA
loc_5F40:
		move.b	($FFFFDB94).w,(Current_Special_Stage).w
		lea	($FFFFFFA0).w,a0
		move.w	(a0)+,d0
		add.w	(a0)+,d0
		add.w	(a0)+,d0
		add.w	(a0)+,d0
		add.w	(a0)+,d0
		add.w	(a0)+,d0
		cmp.w	($FFFFDB9A).w,d0
		bne.s	loc_5F60
		st ($FFFFFF42).w
loc_5F60:
		bsr.w	Pal_MakeFlash 
		tst.w	($FFFFFF8A).w
		bne.w	loc_6048
		move	#$2700,sr
		lea	(VDP_control_port),a6
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$9001,(a6)
		move.w	#$8C81,(a6)
		bsr.w	ClearScreen 
		bsr.w	J_Head_Up_Display_Base_00 
		move	#$2300,sr
		moveq	#$27,d0
		bsr.w	PalLoad2 
		moveq	#0,d0
		bsr.w	LoadPLC2 
		moveq	#$42,d0
		bsr.w	LoadPLC 
		move.w	(Ring_count).w,($FFFFF7D2).w
		move.w	($FFFFFED0).w,($FFFFF7D4).w
		clr.w	($FFFFFF8E).w
		tst.b	($FFFFFFB0).w
		beq.s	loc_5FC0
		move.w	#$3E8,($FFFFFF8E).w
loc_5FC0:
		move.b	#1,($FFFFFE1F).w
		move.b	#1,($FFFFF7D6).w
		move.w	#$9A,d0
		jsr	Play_Sfx
		lea	($FFFFAC00).w,a1
		moveq	#0,d0
		move.w	#$FF,d1
loc_5FE0: 
		move.l	d0,(a1)+
		dbra	d1,loc_5FE0
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
loc_5FF0: 
		move.l	d0,(a1)+
		dbra	d1,loc_5FF0
		move.b	#$6F,($FFFFB800).w
loc_5FFC: 
		move.b	#8,(Delay_Time).w
		bsr.w	DelayProgram 
		jsr	Load_Objects 
		jsr	Build_Sprites 
		bsr.w	RunPLC 
		tst.w	($FFFFFE02).w
		beq.s	loc_5FFC
		tst.l	(Plc_Buffer).w
		bne.s	loc_5FFC
		move.w	#$CA,d0
		bsr.w	Play_Sfx
		bsr.w	Pal_MakeFlash 
		tst.w	($FFFFFF8A).w
		bne.s	loc_6048
		move.w	#0,(Ctrl_1_Held).w
		move.w	#0,($FFFFF606).w
		move.b	#$C,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_6048:
		move.w	#3,($FFFFFF10).w
		move.b	#$18,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_6056:
		tst.b	($FFFFDB95).w
		beq	loc_6110
loc_605E: 
		moveq	#0,d0
		move.b	($FFFFFE0F).w,d0
		move.b	($FFFFDB97).w,d1
		and.b	d1,d0
		bne.w	loc_609E
		move.b	($FFFFDB96).w,d0
		and.b	#$F,d0
		add.b	#1,($FFFFDB96).w
		add.w	d0,d0
		move.w	loc_60D8(pc,d0),($FFFFFB6E).w
		tst.b	($FFFFDB0B).w
		bne.s	loc_609E
		tst.b	($FFFFDB0D).w
		bne.s	loc_609E
		sub.b	#4,($FFFFDB97).w
		bpl.s	loc_609E
		move.b	#1,($FFFFDB97).w
loc_609E:
		tst.b	($FFFFDB98).w
		beq.s	loc_60D6
		move.b	($FFFFFE0F).w,d0
		and.b	#3,d0
		bne.s	loc_60D6
		move.b	($FFFFDB99).w,d0
		add.b	#1,($FFFFDB99).w
		and.b	#3,d0
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	loc_60F8(pc,d0),($FFFFFB76).w
		move.w	loc_60FA(pc,d0),($FFFFFB78).w
		move.w	loc_60FC(pc,d0),($FFFFFB7A).w
loc_60D6:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_60D8: 
		dc.w	$EE,$2EE,$4EE,$6EE,$8EE,$AEE,$CEE,$EEE
		dc.w	$C,$AEA,$48E,$6E6,$6E8,$4EA,$2EC,$EC
;------------------------------------------------------------------------------- 
loc_60F8:
		dc.w	$EE
;------------------------------------------------------------------------------- 
loc_60FA:
		dc.w	$CC
;------------------------------------------------------------------------------- 
loc_60FC:
		dc.w	$88,$E0,$C0,$80,$EE0,$CC0,$880,$E0E
		dc.w	$C0C,$808 
;------------------------------------------------------------------------------- 
loc_6110:
		cmp.w	#$EE,($FFFFFB6E).w
		bne.w	loc_605E
		move.b	#7,($FFFFDB97).w
		move.b	#0,($FFFFDB96).w
		rts
;--------------------------------------------------------------------------------
loc_6128:
		cmp.b	#4,($FFFFDB0D).w
		bne.s	loc_6146
		move.l	#$FFFF6A60,a0
		moveq	#0,d0
		move.b	($FFFFDB10).w,d0
		add.w	d0,d0
		add.w	0(a0,d0),a0
		move.l	a0,($FFFFDB82).w
loc_6146:
		rts
;--------------------------------------------------------------------------------
loc_6148:
		cmp.b	#4,($FFFFDB0D).w
		bne.w	loc_61E8
		moveq	#0,d0
		move.b	($FFFFDB0A).w,d0
		cmp.b	($FFFFDB4C).w,d0
		beq	loc_61E8
		move.b	d0,($FFFFDB4C).w
		move.l	($FFFFDB8E).w,a1
		move.b	0(a1,d0),d3
		and.w	#$7F,d3
		lea	(loc_620A),a0
		move.b	0(a0,d3),d3
		subq.w	#1,d3
		add.w	d3,d3
		add.w	d3,d3
		move.l	($FFFFDB88).w,a0
loc_6184: 
		bsr.w	loc_7B8A
		bne.s	loc_61E8
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_61C8
		move.b	d0,d1
		and.b	#$40,d1
		bne.s	loc_61B0
		addq.w	#1,($FFFFDB9A).w
		move.b	#$60,(a1)
		add.w	d0,d0
		add.w	d0,d0
		add.w	d3,d0
		move.w	d0,$30(a1)
		move.b	(a0)+,$26(a1)
		bra.s	loc_6184
loc_61B0:
		and.w	#$3F,d0
		move.b	#$61,(a1)
		add.w	d0,d0
		add.w	d0,d0
		add.w	d3,d0
		move.w	d0,$30(a1)
		move.b	(a0)+,$26(a1)
		bra.s	loc_6184
loc_61C8:
		move.l	a0,($FFFFDB88).w
		addq.b	#1,d0
		beq.s	loc_61E8
		addq.b	#1,d0
		beq.s	loc_61E4
		addq.b	#1,d0
		beq.s	loc_61DE
		st ($FFFFDB95).w
		rts
;--------------------------------------------------------------------------------
loc_61DE:
		move.b	#$59,(a1)
		rts
;--------------------------------------------------------------------------------
loc_61E4:
		move.b	#$5A,(a1)
loc_61E8:
		rts
;--------------------------------------------------------------------------------
loc_61EA:
		dc.l	$40000002,$47000002,$4E000002,$55000002
		dc.l	$40000003,$47000003,$4E000003,$55000003
loc_620A: 
		dc.b	$18,$18,$C,$10,$7,$0
loc_6210:
		moveq	#0,d0
		move.b	($FFFFDB0D).w,d0
		cmp.b	#4,d0
		bge loc_7806
		add.w	d0,d0
		add.w	d0,d0
		bne.w	loc_62DE
		move.l	($FFFFDB2C).w,($FFFFDB28).w
		move.b	($FFFFDB10).w,($FFFFDB39).w
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		move.b	($FFFFDB0A).w,d1
		move.b	($FFFFDB0B).w,d2
		move.l	($FFFFDB8E).w,a1
		move.b	0(a1,d1),d3
		and.b	#$7F,d3
		move.b	d3,($FFFFDB08).w
		move.w	d3,d1
		add.w	d3,d3
		lea	(loc_6FE8),a1
		add.w	0(a1,d3),a1
		add.w	d2,a1
		moveq	#0,d4
		move.b	(a1),d4
		move.b	d4,($FFFFDB10).w
		lsl.w	#2,d4
		lea	(loc_7046),a1
		move.l	0(a1,d4),a0
		move.l	a0,a1
		moveq	#0,d2
		move.b	(a0)+,d2
		move.b	(a0)+,d2
		move.b	(a0)+,d2
		lsl.w	#8,d2
		move.b	(a0)+,d2
		addq.w	#4,d2
		add.w	d2,a1
		move.l	a1,a2
		moveq	#0,d2
		move.b	(a1)+,d2
		move.b	(a1)+,d2
		move.b	(a1)+,d2
		lsl.w	#8,d2
		move.b	(a1)+,d2
		addq.w	#4,d2
		add.w	d2,a2
		move.b	(a2)+,d2
		move.b	(a2)+,d2
		move.b	(a2)+,d2
		move.b	(a2)+,d2
		move.l	a0,($FFFFDB00).w
		move.l	a0,($FFFFDB2C).w
		move.l	a1,($FFFFDB04).w
		move.l	a2,($FFFFDB3A).w
		lea	loc_620A(pc),a4
		move.b	0(a4,d1),d2
		move.b	($FFFFDB0B).w,($FFFFDB09).w
		add.b	#1,($FFFFDB0B).w
		cmp.b	($FFFFDB0B).w,d2
		bne.s	loc_62DE
		move.b	#0,($FFFFDB0B).w
		move.b	($FFFFDB0A).w,($FFFFDB22).w
		add.b	#1,($FFFFDB0A).w
loc_62DE:
		tst.b	($FFFFDB0C).w
		beq.s	loc_62E8
		add.w	#$10,d0
loc_62E8:
		lea	loc_61EA(pc),a3
		move.l	0(a3,d0),a3
		move.l	a3,(VDP_control_port)
		lea	(VDP_data_port),a6
		bsr.w	loc_7806
		move.l	($FFFFDB00).w,a0
		move.l	($FFFFDB04).w,a1
		move.l	($FFFFDB3A).w,a2
		lea	($FFFFDB3E).w,a3
		movem.w	(a3)+,d2-d7
		lea	(loc_7126),a3
		lea	(loc_75EE),a4
		move.w	#$FFF8,a5
		moveq	#0,d0
		tst.b	($FFFFDB0E).w
		bne.w	loc_6996
loc_632E: 
		add.w	#1,a5
		cmp.w	#0,a5
		beq	loc_6964
loc_633A: 
		moveq	#0,d1
		subq.w	#1,d7
		bpl.s	loc_6344
		move.b	(a0)+,d6
		moveq	#7,d7
loc_6344:
		add.b	d6,d6
		bcc.s	loc_6394
		subq.b	#1,d5
		bpl.s	loc_6350
		move.b	(a1)+,d4
		moveq	#7,d5
loc_6350:
		add.b	d4,d4
		bcc.s	loc_6374
		moveq	#$A,d0
		sub.b	d5,d0
		subq.b	#3,d0
		add.w	d0,d0
		move.w	loc_6364(pc,d0),d0
		jmp	loc_6364(pc,d0)
loc_6364:
		dc.w	loc_650A-loc_6364
		dc.w	loc_64E0-loc_6364
		dc.w	loc_64B6-loc_6364
		dc.w	loc_648C-loc_6364
		dc.w	loc_6462-loc_6364
		dc.w	loc_6442-loc_6364
		dc.w	loc_6412-loc_6364
		dc.w	loc_63EA-loc_6364
loc_6374:
		moveq	#6,d0
		sub.b	d5,d0
		addq.b	#1,d0
		add.w	d0,d0
		move.w	loc_6384(pc,d0),d0
		jmp	loc_6384(pc,d0)
loc_6384:
		dc.w	loc_6626-loc_6384
		dc.w	loc_660E-loc_6384
		dc.w	loc_65E8-loc_6384
		dc.w	loc_65C2-loc_6384
		dc.w	loc_659C-loc_6384
		dc.w	loc_6576-loc_6384
		dc.w	loc_6550-loc_6384
		dc.w	loc_6534-loc_6384 
loc_6394:
		subq.b	#1,d3
		bpl.s	loc_63A8
		move.b	(a2)+,d2
		cmp.b	#$FF,d2
		bne.s	loc_63A6
		moveq	#0,d3
		bra.w	loc_632E
loc_63A6:
		moveq	#7,d3
loc_63A8:
		add.b	d2,d2
		bcc.s	loc_63CA
		moveq	#7,d0
		sub.b	d3,d0
		add.b	d0,d0
		move.w	loc_63BA(pc,d0),d0
		jmp	loc_63BA(pc,d0)
loc_63BA:
		dc.w	loc_67DA-loc_63BA
		dc.w	loc_679E-loc_63BA
		dc.w	loc_6762-loc_63BA
		dc.w	loc_6726-loc_63BA
		dc.w	loc_66EA-loc_63BA
		dc.w	loc_66AE-loc_63BA
		dc.w	loc_6672-loc_63BA
		dc.w	loc_6640-loc_63BA
loc_63CA:
		moveq	#6,d0
		sub.b	d3,d0
		addq.b	#1,d0
		add.b	d0,d0
		move.w	loc_63DA(pc,d0),d0
		jmp	loc_63DA(pc,d0)
loc_63DA:
		dc.w	loc_6940-loc_63DA
		dc.w	loc_691E-loc_63DA
		dc.w	loc_68EE-loc_63DA
		dc.w	loc_68BE-loc_63DA
		dc.w	loc_688E-loc_63DA
		dc.w	loc_685E-loc_63DA
		dc.w	loc_682E-loc_63DA
		dc.w	loc_6808-loc_63DA
loc_63EA:
		moveq	#0,d0
		move.b	(a1)+,d0
		lsl.w	#2,d0
		move.b	(a1)+,d4
		rol.b	#2,d4
		move.b	d4,d1
		and.b	#3,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#6,d5
		bra.w	loc_633A
loc_6412:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$200,d0
		move.b	(a1)+,d1
		lsl.w	#1,d1
		or.w	d1,d0
		move.b	(a1)+,d4
		rol.b	#1,d4
		move.b	d4,d1
		and.b	#1,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#7,d5
		bra.w	loc_633A
loc_6442:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$300,d0
		move.b	(a1)+,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#0,d5
		bra.w	loc_633A
loc_6462:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$380,d0
		move.b	(a1)+,d4
		ror.b	#1,d4
		move.b	d4,d1
		and.b	#$7F,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#1,d5
		bra.w	loc_633A
loc_648C:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$3C0,d0
		move.b	(a1)+,d4
		ror.b	#2,d4
		move.b	d4,d1
		and.b	#$3F,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#2,d5
		bra.w	loc_633A
loc_64B6:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$3E0,d0
		move.b	(a1)+,d4
		ror.b	#3,d4
		move.b	d4,d1
		and.b	#$1F,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#3,d5
		bra.w	loc_633A
loc_64E0:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$3F0,d0
		move.b	(a1)+,d4
		ror.b	#4,d4
		move.b	d4,d1
		and.b	#$F,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#4,d5
		bra.w	loc_633A
loc_650A:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$3F8,d0
		move.b	(a1)+,d4
		rol.b	#3,d4
		move.b	d4,d1
		and.b	#7,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#5,d5
		bra.w	loc_633A
loc_6534:
		move.b	(a1)+,d4
		ror.b	#2,d4
		move.b	d4,d0
		and.w	#$3F,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#2,d5
		bra.w	loc_633A
loc_6550:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$20,d0
		move.b	(a1)+,d4
		ror.b	#3,d4
		move.b	d4,d1
		and.b	#$1F,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#3,d5
		bra.w	loc_633A
loc_6576:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$30,d0
		move.b	(a1)+,d4
		ror.b	#4,d4
		move.b	d4,d1
		and.b	#$F,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#4,d5
		bra.w	loc_633A
loc_659C:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$38,d0
		move.b	(a1)+,d4
		rol.b	#3,d4
		move.b	d4,d1
		and.b	#7,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#5,d5
		bra.w	loc_633A
loc_65C2:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$3C,d0
		move.b	(a1)+,d4
		rol.b	#2,d4
		move.b	d4,d1
		and.b	#3,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#6,d5
		bra.w	loc_633A
loc_65E8:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$3E,d0
		move.b	(a1)+,d4
		rol.b	#1,d4
		move.b	d4,d1
		and.b	#1,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#7,d5
		bra.w	loc_633A
loc_660E:
		lsr.b	#2,d4
		and.w	#$3F,d4
		add.w	d4,d4
		move.w	0(a3,d4),d4
		or.w	#$6000,d4
		move.w	d4,(a6)
		moveq	#0,d5
		bra.w	loc_633A
loc_6626:
		ror.b	#2,d4
		move.b	d4,d0
		and.w	#$3F,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		or.w	#$6000,d0
		move.w	d0,(a6)
		moveq	#1,d5
		bra.w	loc_633A
loc_6640:
		move.b	(a2)+,d2
		ror.b	#1,d2
		move.b	d2,d0
		and.w	#$7F,d0
		moveq	#1,d3
		cmp.b	#$7F,d0
		beq	loc_632E
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6668: 
		move.w	d1,(a6)
		dbra	d0,loc_6668
		bra.w	loc_633A
loc_6672:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$40,d1
		move.b	(a2)+,d2
		ror.b	#2,d2
		move.b	d2,d0
		and.w	#$3F,d0
		or.b	d1,d0
		moveq	#2,d3
		cmp.b	#$7F,d0
		beq	loc_632E
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_66A4: 
		move.w	d1,(a6)
		dbra	d0,loc_66A4
		bra.w	loc_633A
loc_66AE:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$60,d1
		move.b	(a2)+,d2
		ror.b	#3,d2
		move.b	d2,d0
		and.w	#$1F,d0
		or.b	d1,d0
		moveq	#3,d3
		cmp.b	#$7F,d0
		beq	loc_632E
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_66E0: 
		move.w	d1,(a6)
		dbra	d0,loc_66E0
		bra.w	loc_633A
loc_66EA:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$70,d1
		move.b	(a2)+,d2
		ror.b	#4,d2
		move.b	d2,d0
		and.w	#$F,d0
		or.b	d1,d0
		moveq	#4,d3
		cmp.b	#$7F,d0
		beq	loc_632E
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_671C: 
		move.w	d1,(a6)
		dbra	d0,loc_671C
		bra.w	loc_633A
loc_6726:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$78,d1
		move.b	(a2)+,d2
		rol.b	#3,d2
		move.b	d2,d0
		and.w	#7,d0
		or.b	d1,d0
		moveq	#5,d3
		cmp.b	#$7F,d0
		beq	loc_632E
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6758: 
		move.w	d1,(a6)
		dbra	d0,loc_6758
		bra.w	loc_633A
loc_6762:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$7C,d1
		move.b	(a2)+,d2
		rol.b	#2,d2
		move.b	d2,d0
		and.w	#3,d0
		or.b	d1,d0
		moveq	#6,d3
		cmp.b	#$7F,d0
		beq	loc_632E
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6794: 
		move.w	d1,(a6)
		dbra	d0,loc_6794
		bra.w	loc_633A
loc_679E:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$7E,d1
		move.b	(a2)+,d2
		rol.b	#1,d2
		move.b	d2,d0
		and.w	#1,d0
		or.b	d1,d0
		moveq	#7,d3
		cmp.b	#$7F,d0
		beq	loc_632E
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_67D0: 
		move.w	d1,(a6)
		dbra	d0,loc_67D0
		bra.w	loc_633A
loc_67DA:
		lsr.b	#1,d2
		and.w	#$7F,d2
		moveq	#0,d3
		cmp.b	#$7F,d2
		beq	loc_632E
		add.w	#$40,d2
		add.w	d2,d2
		add.w	d2,d2
		move.w	0(a4,d2),d1
		move.w	2(a4,d2),d0
		or.w	#$E000,d1
loc_67FE: 
		move.w	d1,(a6)
		dbra	d0,loc_67FE
		bra.w	loc_633A
loc_6808:
		move.b	(a2)+,d2
		ror.b	#2,d2
		move.b	d2,d0
		and.w	#$3F,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#2,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6824: 
		move.w	d1,(a6)
		dbra	d0,loc_6824
		bra.w	loc_633A
loc_682E:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$20,d0
		move.b	(a2)+,d2
		ror.b	#3,d2
		move.b	d2,d1
		and.b	#$1F,d1
		or.b	d1,d0
		moveq	#3,d3
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6854: 
		move.w	d1,(a6)
		dbra	d0,loc_6854
		bra.w	loc_633A
loc_685E:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$30,d0
		move.b	(a2)+,d2
		ror.b	#4,d2
		move.b	d2,d1
		and.b	#$F,d1
		or.b	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#4,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6884: 
		move.w	d1,(a6)
		dbra	d0,loc_6884
		bra.w	loc_633A
loc_688E:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$38,d0
		move.b	(a2)+,d2
		rol.b	#3,d2
		move.b	d2,d1
		and.b	#7,d1
		or.b	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#5,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_68B4: 
		move.w	d1,(a6)
		dbra	d0,loc_68B4
		bra.w	loc_633A
loc_68BE:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$3C,d0
		move.b	(a2)+,d2
		rol.b	#2,d2
		move.b	d2,d1
		and.b	#3,d1
		or.b	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#6,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_68E4: 
		move.w	d1,(a6)
		dbra	d0,loc_68E4
		bra.w	loc_633A
loc_68EE:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$3E,d0
		move.b	(a2)+,d2
		rol.b	#1,d2
		move.b	d2,d1
		and.b	#1,d1
		or.b	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#7,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6914: 
		move.w	d1,(a6)
		dbra	d0,loc_6914
		bra.w	loc_633A
loc_691E:
		lsr.b	#2,d2
		and.w	#$3F,d2
		add.w	d2,d2
		add.w	d2,d2
		moveq	#0,d3
		move.w	0(a4,d2),d1
		move.w	2(a4,d2),d0
		or.w	#$E000,d1
loc_6936: 
		move.w	d1,(a6)
		dbra	d0,loc_6936
		bra.w	loc_633A
loc_6940:
		ror.b	#2,d2
		move.b	d2,d0
		and.w	#$3F,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#1,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_695A: 
		move.w	d1,(a6)
		dbra	d0,loc_695A
		bra.w	loc_633A
loc_6964:
		cmp.b	#3,($FFFFDB0D).w
		beq.s	loc_6982
		move.l	a0,($FFFFDB00).w
		move.l	a1,($FFFFDB04).w
		move.l	a2,($FFFFDB3A).w
		lea	($FFFFDB4A).w,a3
		movem.w	d2-d7,-(a3)
		rts
;--------------------------------------------------------------------------------
loc_6982:
		lea	($FFFFDB3E).w,a2
		moveq	#0,d0
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		rts
;--------------------------------------------------------------------------------
loc_6996:
		add.w	#1,a5
		cmp.w	#0,a5
		beq	loc_6964
		lea	($FFFFD000).w,a6
		swap.w	d0
		add.w	#$100,d0
		and.w	#$F00,d0
		add.w	d0,a6
		swap.w	d0
loc_69B4: 
		moveq	#0,d1
		subq.w	#1,d7
		bpl.s	loc_69BE
		move.b	(a0)+,d6
		moveq	#7,d7
loc_69BE:
		add.b	d6,d6
		bcc.s	loc_6A12
		subq.b	#1,d5
		bpl.s	loc_69CA
		move.b	(a1)+,d4
		moveq	#7,d5
loc_69CA:
		add.b	d4,d4
		bcc.s	loc_69F0
		move.w	#$A,d0
		sub.b	d5,d0
		subq.b	#3,d0
		add.w	d0,d0
		move.w	loc_69E0(pc,d0),d0
		jmp	loc_69E0(pc,d0) 
loc_69E0:
		dc.w	loc_6B8E-loc_69E0
		dc.w	loc_6B64-loc_69E0
		dc.w	loc_6B3A-loc_69E0
		dc.w	loc_6B10-loc_69E0
		dc.w	loc_6AE6-loc_69E0
		dc.w	loc_6AC6-loc_69E0
		dc.w	loc_6A96-loc_69E0
		dc.w	loc_6A6C-loc_69E0
loc_69F0:
		move.w	#6,d0
		sub.b	d5,d0
		addq.b	#1,d0
		add.w	d0,d0
		move.w	loc_6A02(pc,d0),d0
		jmp	loc_6A02(pc,d0)
loc_6A02:
		dc.w	loc_6CAA-loc_6A02
		dc.w	loc_6C92-loc_6A02
		dc.w	loc_6C6C-loc_6A02
		dc.w	loc_6C46-loc_6A02
		dc.w	loc_6C20-loc_6A02
		dc.w	loc_6BFA-loc_6A02
		dc.w	loc_6BD4-loc_6A02
		dc.w	loc_6BB8-loc_6A02
loc_6A12:
		subq.b	#1,d3
		bpl.s	loc_6A26
		move.b	(a2)+,d2
		cmp.b	#$FF,d2
		bne.s	loc_6A24
		moveq	#0,d3
		bra.w	loc_6996
loc_6A24:
		moveq	#7,d3
loc_6A26:
		add.b	d2,d2
		bcc.s	loc_6A4A
		move.w	#7,d0
		sub.b	d3,d0
		add.b	d0,d0
		move.w	loc_6A3A(pc,d0),d0
		jmp	loc_6A3A(pc,d0)
loc_6A3A:
		dc.w	loc_6E5E-loc_6A3A
		dc.w	loc_6E22-loc_6A3A
		dc.w	loc_6DE6-loc_6A3A
		dc.w	loc_6DAA-loc_6A3A
		dc.w	loc_6D6E-loc_6A3A
		dc.w	loc_6D32-loc_6A3A
		dc.w	loc_6CF6-loc_6A3A
		dc.w	loc_6CC4-loc_6A3A
loc_6A4A:
		move.w	#6,d0
		sub.b	d3,d0
		addq.b	#1,d0
		add.b	d0,d0
		move.w	loc_6A5C(pc,d0),d0
		jmp	loc_6A5C(pc,d0)
loc_6A5C:
		dc.w	loc_6FC4-loc_6A5C
		dc.w	loc_6FA2-loc_6A5C
		dc.w	loc_6F72-loc_6A5C
		dc.w	loc_6F42-loc_6A5C
		dc.w	loc_6F12-loc_6A5C
		dc.w	loc_6EE2-loc_6A5C
		dc.w	loc_6EB2-loc_6A5C
		dc.w	loc_6E8C-loc_6A5C
loc_6A6C:
		move.w	#0,d0
		move.b	(a1)+,d0
		lsl.w	#2,d0
		move.b	(a1)+,d4
		rol.b	#2,d4
		move.b	d4,d1
		and.b	#3,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#6,d5
		bra.w	loc_69B4
loc_6A96:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$200,d0
		move.b	(a1)+,d1
		lsl.w	#1,d1
		or.w	d1,d0
		move.b	(a1)+,d4
		rol.b	#1,d4
		move.b	d4,d1
		and.b	#1,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#7,d5
		bra.w	loc_69B4
loc_6AC6:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$300,d0
		move.b	(a1)+,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#0,d5
		bra.w	loc_69B4
loc_6AE6:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$380,d0
		move.b	(a1)+,d4
		ror.b	#1,d4
		move.b	d4,d1
		and.b	#$7F,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#1,d5
		bra.w	loc_69B4
loc_6B10:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$3C0,d0
		move.b	(a1)+,d4
		ror.b	#2,d4
		move.b	d4,d1
		and.b	#$3F,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#2,d5
		bra.w	loc_69B4
loc_6B3A:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$3E0,d0
		move.b	(a1)+,d4
		ror.b	#3,d4
		move.b	d4,d1
		and.b	#$1F,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#3,d5
		bra.w	loc_69B4
loc_6B64:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$3F0,d0
		move.b	(a1)+,d4
		ror.b	#4,d4
		move.b	d4,d1
		and.b	#$F,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#4,d5
		bra.w	loc_69B4
loc_6B8E:
		move.b	d4,d0
		lsl.w	#2,d0
		and.w	#$3F8,d0
		move.b	(a1)+,d4
		rol.b	#3,d4
		move.b	d4,d1
		and.b	#7,d1
		or.b	d1,d0
		add.w	#$40,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#5,d5
		bra.w	loc_69B4
loc_6BB8:
		move.b	(a1)+,d4
		ror.b	#2,d4
		move.b	d4,d0
		and.w	#$3F,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#2,d5
		bra.w	loc_69B4
loc_6BD4:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$20,d0
		move.b	(a1)+,d4
		ror.b	#3,d4
		move.b	d4,d1
		and.b	#$1F,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#3,d5
		bra.w	loc_69B4
loc_6BFA:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$30,d0
		move.b	(a1)+,d4
		ror.b	#4,d4
		move.b	d4,d1
		and.b	#$F,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#4,d5
		bra.w	loc_69B4
loc_6C20:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$38,d0
		move.b	(a1)+,d4
		rol.b	#3,d4
		move.b	d4,d1
		and.b	#7,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#5,d5
		bra.w	loc_69B4
loc_6C46:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$3C,d0
		move.b	(a1)+,d4
		rol.b	#2,d4
		move.b	d4,d1
		and.b	#3,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#6,d5
		bra.w	loc_69B4
loc_6C6C:
		move.b	d4,d0
		lsr.b	#2,d0
		and.w	#$3E,d0
		move.b	(a1)+,d4
		rol.b	#1,d4
		move.b	d4,d1
		and.b	#1,d1
		or.b	d1,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#7,d5
		bra.w	loc_69B4
loc_6C92:
		lsr.b	#2,d4
		and.w	#$3F,d4
		add.w	d4,d4
		move.w	0(a3,d4),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#0,d5
		bra.w	loc_69B4
loc_6CAA:
		ror.b	#2,d4
		move.b	d4,d0
		and.w	#$3F,d0
		add.w	d0,d0
		move.w	0(a3,d0),d0
		eor.w	#$6800,d0
		move.w	d0,-(a6)
		moveq	#1,d5
		bra.w	loc_69B4
loc_6CC4:
		move.b	(a2)+,d2
		ror.b	#1,d2
		move.b	d2,d0
		and.w	#$7F,d0
		moveq	#1,d3
		cmp.b	#$7F,d0
		beq	loc_6996
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6CEC: 
		move.w	d1,-(a6)
		dbra	d0,loc_6CEC
		bra.w	loc_69B4
loc_6CF6:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$40,d1
		move.b	(a2)+,d2
		ror.b	#2,d2
		move.b	d2,d0
		and.w	#$3F,d0
		or.b	d1,d0
		moveq	#2,d3
		cmp.b	#$7F,d0
		beq	loc_6996
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6D28: 
		move.w	d1,-(a6)
		dbra	d0,loc_6D28
		bra.w	loc_69B4
loc_6D32:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$60,d1
		move.b	(a2)+,d2
		ror.b	#3,d2
		move.b	d2,d0
		and.w	#$1F,d0
		or.b	d1,d0
		moveq	#3,d3
		cmp.b	#$7F,d0
		beq	loc_6996
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6D64: 
		move.w	d1,-(a6)
		dbra	d0,loc_6D64
		bra.w	loc_69B4
loc_6D6E:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$70,d1
		move.b	(a2)+,d2
		ror.b	#4,d2
		move.b	d2,d0
		and.w	#$F,d0
		or.b	d1,d0
		moveq	#4,d3
		cmp.b	#$7F,d0
		beq	loc_6996
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6DA0: 
		move.w	d1,-(a6)
		dbra	d0,loc_6DA0
		bra.w	loc_69B4
loc_6DAA:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$78,d1
		move.b	(a2)+,d2
		rol.b	#3,d2
		move.b	d2,d0
		and.w	#7,d0
		or.b	d1,d0
		moveq	#5,d3
		cmp.b	#$7F,d0
		beq	loc_6996
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6DDC: 
		move.w	d1,-(a6)
		dbra	d0,loc_6DDC
		bra.w	loc_69B4
loc_6DE6:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$7C,d1
		move.b	(a2)+,d2
		rol.b	#2,d2
		move.b	d2,d0
		and.w	#3,d0
		or.b	d1,d0
		moveq	#6,d3
		cmp.b	#$7F,d0
		beq	loc_6996
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6E18: 
		move.w	d1,-(a6)
		dbra	d0,loc_6E18
		bra.w	loc_69B4
loc_6E22:
		move.b	d2,d1
		lsr.b	#1,d1
		and.b	#$7E,d1
		move.b	(a2)+,d2
		rol.b	#1,d2
		move.b	d2,d0
		and.w	#1,d0
		or.b	d1,d0
		moveq	#7,d3
		cmp.b	#$7F,d0
		beq	loc_6996
		add.w	#$40,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6E54: 
		move.w	d1,-(a6)
		dbra	d0,loc_6E54
		bra.w	loc_69B4
loc_6E5E:
		lsr.b	#1,d2
		and.w	#$7F,d2
		moveq	#0,d3
		cmp.b	#$7F,d2
		beq	loc_6996
		add.w	#$40,d2
		add.w	d2,d2
		add.w	d2,d2
		move.w	0(a4,d2),d1
		move.w	2(a4,d2),d0
		or.w	#$E000,d1
loc_6E82: 
		move.w	d1,-(a6)
		dbra	d0,loc_6E82
		bra.w	loc_69B4
loc_6E8C:
		move.b	(a2)+,d2
		ror.b	#2,d2
		move.b	d2,d0
		and.w	#$3F,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#2,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6EA8: 
		move.w	d1,-(a6)
		dbra	d0,loc_6EA8
		bra.w	loc_69B4
loc_6EB2:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$20,d0
		move.b	(a2)+,d2
		ror.b	#3,d2
		move.b	d2,d1
		and.b	#$1F,d1
		or.b	d1,d0
		moveq	#3,d3
		add.w	d0,d0
		add.w	d0,d0
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6ED8: 
		move.w	d1,-(a6)
		dbra	d0,loc_6ED8
		bra.w	loc_69B4
loc_6EE2:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$30,d0
		move.b	(a2)+,d2
		ror.b	#4,d2
		move.b	d2,d1
		and.b	#$F,d1
		or.b	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#4,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6F08: 
		move.w	d1,-(a6)
		dbra	d0,loc_6F08
		bra.w	loc_69B4
loc_6F12:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$38,d0
		move.b	(a2)+,d2
		rol.b	#3,d2
		move.b	d2,d1
		and.b	#7,d1
		or.b	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#5,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6F38: 
		move.w	d1,-(a6)
		dbra	d0,loc_6F38
		bra.w	loc_69B4
loc_6F42:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$3C,d0
		move.b	(a2)+,d2
		rol.b	#2,d2
		move.b	d2,d1
		and.b	#3,d1
		or.b	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#6,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6F68: 
		move.w	d1,-(a6)
		dbra	d0,loc_6F68
		bra.w	loc_69B4
loc_6F72:
		move.b	d2,d0
		lsr.b	#2,d0
		and.w	#$3E,d0
		move.b	(a2)+,d2
		rol.b	#1,d2
		move.b	d2,d1
		and.b	#1,d1
		or.b	d1,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#7,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6F98: 
		move.w	d1,-(a6)
		dbra	d0,loc_6F98
		bra.w	loc_69B4
loc_6FA2:
		lsr.b	#2,d2
		and.w	#$3F,d2
		add.w	d2,d2
		add.w	d2,d2
		moveq	#0,d3
		move.w	0(a4,d2),d1
		move.w	2(a4,d2),d0
		or.w	#$E000,d1
loc_6FBA: 
		move.w	d1,-(a6)
		dbra	d0,loc_6FBA
		bra.w	loc_69B4
loc_6FC4:
		ror.b	#2,d2
		move.b	d2,d0
		and.w	#$3F,d0
		add.w	d0,d0
		add.w	d0,d0
		moveq	#1,d3
		move.w	0(a4,d0),d1
		move.w	2(a4,d0),d0
		or.w	#$E000,d1
loc_6FDE: 
		move.w	d1,-(a6)
		dbra	d0,loc_6FDE
		bra.w	loc_69B4
;-------------------------------------------------------------------------------
loc_6FE8:
		dc.w	loc_6FF2-loc_6FE8
		dc.w	loc_700A-loc_6FE8
		dc.w	loc_7022-loc_6FE8
		dc.w	loc_702E-loc_6FE8
		dc.w	loc_703E-loc_6FE8
loc_6FF2:
		dc.b	$26,$27,$28,$29,$2A,$2B,$26,$0,$1,$2,$3,$4,$5,$6,$7,$8
		dc.b	$9,$A,$B,$C,$D,$E,$F,$10
loc_700A:
		dc.b	$26,$27,$28,$29,$2A,$2B,$26,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D
		dc.b	$1E,$1F,$20,$21,$22,$23,$24,$25
loc_7022:
		dc.b	$26,$27,$28,$29,$2A,$2B,$26,$2C,$2D,$2E,$2F,$30
loc_702E:
		dc.b	$11,$12,$13,$14,$11,$12,$13,$14,$11,$12,$13,$14,$11,$12,$13,$14
loc_703E:
		dc.b	$31,$32,$33,$34,$35,$36,$37,$0 
;-------------------------------------------------------------------------------
loc_7046:
		dc.l	loc_C8310
		dc.l	loc_C87B4
		dc.l	loc_C8D82
		dc.l	loc_C933A
		dc.l	loc_C999E
		dc.l	loc_C9FCA
		dc.l	loc_CA686
		dc.l	loc_CAC8E
		dc.l	loc_CB1CC
		dc.l	loc_CB750
		dc.l	loc_CBCCA
		dc.l	loc_CC1EA
		dc.l	loc_CC65E
		dc.l	loc_CCAC8
		dc.l	loc_CCF8C
		dc.l	loc_CD40C
		dc.l	loc_CD856
		dc.l	loc_CDC98
		dc.l	loc_CE316
		dc.l	loc_CE8B2
		dc.l	loc_CEE0C
		dc.l	loc_CF408
		dc.l	loc_CF8B8
		dc.l	loc_CFDBA
		dc.l	loc_D01D2
		dc.l	loc_D0620
		dc.l	loc_D0A9E
		dc.l	loc_D0F2E
		dc.l	loc_D13F8
		dc.l	loc_D1984
		dc.l	loc_D206C
		dc.l	loc_D27B2
		dc.l	loc_D2E08
		dc.l	loc_D3364
		dc.l	loc_D390E
		dc.l	loc_D3FA2
		dc.l	loc_D45B6
		dc.l	loc_D4A3A
		dc.l	loc_D4EA8
		dc.l	loc_D531E
		dc.l	loc_D57B6
		dc.l	loc_D5C5C
		dc.l	loc_D6004
		dc.l	loc_D63F8
		dc.l	loc_D6830
		dc.l	loc_D6CC2
		dc.l	loc_D7184
		dc.l	loc_D758C
		dc.l	loc_D7A22
		dc.l	loc_D7EDA
		dc.l	loc_D852C
		dc.l	loc_D8A92
		dc.l	loc_D8FBA
		dc.l	loc_D956E
		dc.l	loc_D9B60
		dc.l	loc_D9FF4 
;------------------------------------------------------------------------------- 
loc_7126:
		dc.b	$80,$1,$80,$7,$80,$2C,$80,$B,$80,$24,$88,$24,$80,$39,$88,$2B
		dc.b	$80,$5D,$88,$5D,$80,$2B,$80,$4A,$80,$49,$80,$37,$88,$49,$80,$45
		dc.b	$88,$45,$88,$3A,$80,$48,$88,$50,$80,$36,$88,$37,$80,$3A,$80,$50
		dc.b	$88,$42,$80,$42,$88,$15,$80,$1D,$80,$4B,$88,$17,$88,$48,$88,$36
		dc.b	$80,$38,$88,$4B,$80,$15,$80,$21,$80,$17,$80,$33,$80,$1A,$80,$2A
		dc.b	$80,$5E,$80,$28,$80,$30,$88,$21,$88,$38,$88,$1A,$80,$25,$88,$5E
		dc.b	$88,$25,$88,$33,$80,$3,$88,$14,$80,$14,$80,$4,$80,$4E,$88,$3
		dc.b	$80,$C,$88,$2A,$80,$2,$80,$51,$80,$40,$80,$3D,$80,$19,$80,$52
		dc.b	$80,$9,$80,$5A,$88,$30,$88,$4E,$88,$52,$88,$51,$88,$9,$88,$40
		dc.b	$80,$2F,$88,$5A,$88,$18,$80,$34,$88,$19,$88,$2F,$88,$3D,$80,$3E
		dc.b	$80,$18,$88,$C,$80,$12,$88,$4,$80,$26,$88,$34,$88,$5,$80,$3B
		dc.b	$88,$3E,$88,$3B,$80,$0,$88,$2,$80,$5,$80,$D,$80,$55,$80,$AF
		dc.b	$80,$1C,$80,$1B,$88,$D,$80,$16,$88,$12,$80,$1F,$88,$32,$80,$13
		dc.b	$80,$92,$88,$26,$80,$10,$80,$4D,$80,$47,$88,$92,$88,$0,$80,$62
		dc.b	$80,$66,$80,$90,$80,$8,$88,$7C,$88,$67,$88,$F7,$80,$E,$80,$60
		dc.b	$80,$32,$80,$94,$88,$1C,$89,$5,$88,$B0,$80,$59,$80,$F,$80,$67
		dc.b	$80,$68,$88,$94,$80,$7C,$80,$B0,$80,$B1,$80,$6,$88,$41,$80,$87
		dc.b	$80,$93,$80,$CC,$88,$1F,$88,$68,$80,$41,$80,$8F,$88,$90,$80,$C2
		dc.b	$88,$13,$88,$C2,$80,$5C,$80,$64,$80,$D8,$88,$1B,$88,$CC,$88,$11
		dc.b	$88,$55,$88,$E2,$88,$F3,$80,$44,$88,$D8,$80,$85,$80,$A1,$80,$C1
		dc.b	$81,$19,$88,$89,$88,$A,$88,$22,$80,$3F,$80,$5B,$80,$7F,$88,$86
		dc.b	$88,$8,$80,$80,$88,$66,$88,$E0,$88,$C1,$80,$20,$80,$22,$80,$54
		dc.b	$80,$D2,$88,$59,$88,$B1,$88,$60,$89,$19,$88,$A4,$88,$8F,$80,$A
		dc.b	$80,$61,$80,$75,$80,$95,$80,$B6,$80,$E0,$88,$10,$88,$98,$88,$5B
		dc.b	$88,$D2,$88,$16,$80,$53,$80,$91,$80,$96,$80,$A4,$80,$DD,$80,$E6
		dc.b	$88,$7A,$88,$4D,$88,$E6,$80,$11,$80,$57,$80,$7A,$80,$86,$80,$9E
		dc.b	$80,$DA,$80,$58,$80,$DC,$80,$E3,$88,$63,$80,$3C,$80,$56,$80,$69
		dc.b	$80,$7E,$80,$AE,$80,$B5,$80,$B8,$80,$CD,$80,$FB,$80,$FF,$88,$5C
		dc.b	$88,$CD,$88,$74,$88,$EA,$88,$FF,$88,$B5,$80,$43,$80,$6C,$80,$74
		dc.b	$80,$77,$80,$89,$80,$97,$80,$9F,$80,$A0,$81,$13,$81,$1B,$88,$78
		dc.b	$88,$F,$88,$E1,$88,$FB,$89,$28,$80,$63,$80,$84,$80,$8D,$80,$CB
		dc.b	$80,$D7,$80,$E9,$81,$28,$81,$38,$88,$AE,$88,$EC,$80,$31,$80,$4C
		dc.b	$80,$E2,$80,$EA,$88,$64,$80,$29,$80,$2D,$80,$6D,$80,$78,$80,$88
		dc.b	$80,$B4,$80,$BE,$80,$CF,$80,$E1,$80,$E4,$88,$54,$88,$D6,$88,$D7
		dc.b	$88,$61,$89,$2B,$88,$47,$80,$35,$80,$6A,$80,$72,$80,$73,$80,$98
		dc.b	$80,$D5,$80,$D6,$81,$16,$81,$1E,$81,$26,$81,$27,$81,$2F,$81,$5D
		dc.b	$88,$69,$88,$88,$88,$75,$88,$97,$88,$B4,$88,$D1,$88,$D4,$88,$D5
		dc.b	$88,$CB,$88,$E4,$88,$91,$88,$62,$88,$6,$88,$B8,$80,$65,$80,$6E
		dc.b	$80,$71,$80,$7D,$80,$D1,$80,$E7,$80,$F9,$81,$8,$81,$2E,$81,$4B
		dc.b	$88,$81,$88,$85,$88,$77,$88,$7E,$88,$95,$88,$DF,$88,$87,$88,$6C
		dc.b	$88,$F5,$89,$8,$88,$79,$88,$6D,$89,$2A,$88,$AA,$80,$1E,$80,$27
		dc.b	$80,$46,$80,$5F,$80,$70,$80,$79,$80,$9A,$80,$AA,$80,$C3,$80,$D3
		dc.b	$80,$D4,$80,$DE,$80,$DF,$80,$F8,$81,$0,$81,$1,$81,$2B,$81,$33
		dc.b	$81,$36,$81,$43,$81,$51,$88,$2E,$88,$9E,$88,$99,$88,$D3,$88,$DD
		dc.b	$88,$DE,$88,$E9,$88,$EF,$88,$F0,$88,$F8,$89,$27,$88,$BE,$88,$96
		dc.b	$80,$4F,$80,$6F,$80,$81,$80,$8B,$80,$8E,$80,$9C,$80,$A3,$80,$B3
		dc.b	$80,$C0,$80,$CE,$80,$F0,$80,$F1,$80,$F5,$80,$F7,$81,$2,$81,$4
		dc.b	$81,$5,$81,$9,$81,$C,$81,$14,$81,$18,$81,$20,$81,$24,$81,$25
		dc.b	$81,$2A,$81,$30,$81,$32,$81,$37,$81,$59,$81,$65,$88,$3F,$88,$6B
		dc.b	$88,$80,$88,$53,$88,$C6,$88,$CF,$88,$D9,$88,$DC,$88,$56,$88,$B6
		dc.b	$88,$F9,$89,$2,$89,$4,$89,$15,$88,$6A,$89,$13,$88,$72,$88,$35
		dc.b	$89,$38,$89,$5D,$89,$43,$80,$23,$80,$76,$80,$7B,$80,$8A,$80,$9D
		dc.b	$80,$A6,$80,$A8,$80,$AC,$80,$B2,$80,$B7,$80,$BB,$80,$BC,$80,$BD
		dc.b	$80,$C6,$80,$E5,$80,$E8,$80,$EE,$80,$F4,$81,$A,$81,$D,$81,$11
		dc.b	$81,$15,$81,$1A,$81,$1F,$81,$22,$81,$23,$81,$39,$81,$3A,$81,$3C
		dc.b	$81,$42,$81,$44,$81,$47,$81,$48,$81,$5E,$81,$5F,$81,$63,$81,$68
		dc.b	$81,$6A,$81,$6C,$81,$70,$88,$E5,$88,$CE,$88,$EE,$88,$F1,$88,$84
		dc.b	$88,$FD,$89,$0,$88,$B9,$89,$17,$88,$71,$89,$9,$89,$D,$88,$65
		dc.b	$89,$25,$89,$22,$88,$31,$88,$3C,$89,$F,$88,$C5,$89,$33,$89,$37
		dc.b	$89,$1F,$80,$2E,$80,$6B,$80,$82,$80,$83,$80,$8C,$80,$99,$80,$9B
		dc.b	$80,$A2,$80,$A5,$80,$A7,$80,$A9,$80,$AB,$80,$AD,$80,$B9,$80,$BA
		dc.b	$80,$BF,$80,$C4,$80,$C5,$80,$C7,$80,$C8,$80,$C9,$80,$CA,$80,$D0
		dc.b	$80,$D9,$80,$DB,$80,$EB,$80,$EC,$80,$ED,$80,$EF,$80,$F2,$80,$F3
		dc.b	$80,$F6,$80,$FA,$80,$FC,$80,$FD,$80,$FE,$81,$3,$81,$6,$81,$7
		dc.b	$81,$B,$81,$E,$81,$F,$81,$10,$81,$12,$81,$17,$81,$1C,$81,$1D
		dc.b	$81,$21,$81,$29,$81,$2C,$81,$2D,$81,$31,$81,$34,$81,$35,$81,$3B
		dc.b	$81,$3D,$81,$3E,$81,$3F,$81,$40,$81,$41,$81,$45,$81,$46,$81,$49
		dc.b	$81,$4A,$81,$4C,$81,$4D,$81,$4E,$81,$4F,$81,$50,$81,$52,$81,$53
		dc.b	$81,$54,$81,$55,$81,$56,$81,$57,$81,$58,$81,$5A,$81,$5B,$81,$5C
		dc.b	$81,$60,$81,$61,$81,$62,$81,$64,$81,$66,$81,$67,$81,$69,$81,$6B
		dc.b	$81,$6D,$81,$6E,$81,$6F,$81,$71,$81,$72,$81,$73,$88,$6E,$88,$7D
		dc.b	$88,$C3,$88,$DB,$88,$E7,$88,$E8,$88,$EB,$88,$ED,$88,$F2,$88,$F6
		dc.b	$88,$FA,$88,$FC,$88,$FE,$88,$2D,$89,$3,$89,$6,$89,$7,$89,$B
		dc.b	$88,$73,$88,$9A,$89,$29,$89,$2C,$89,$2D,$89,$11,$89,$3C,$89,$20
		dc.b	$89,$46,$88,$A9,$88,$9C,$89,$16,$89,$4F,$89,$4C,$88,$6F,$89,$58
		dc.b	$89,$56,$89,$59,$89,$5A,$89,$61,$88,$7B,$89,$66,$89,$1C,$89,$18
		dc.b	$88,$A0,$88,$A3,$89,$67,$88,$A1 
;------------------------------------------------------------------------------- 
loc_75EE: 
		dc.w	$7,$1,$1,$1,$4A,$1,$39,$3
		dc.w	$1,$5,$28,$7,$2C,$1,$1,$2
		dc.w	$28,$5,$39,$1,$28,$9,$1,$4
		dc.w	$28,$6,$28,$3,$4A,$2,$1,$3
		dc.w	$28,$4,$39,$2,$39,$4,$1,$6
		dc.w	$7,$2,$2C,$2,$28,$1,$1D,$1
		dc.w	$28,$8,$28,$2,$7,$3,$1,$7
		dc.w	$28,$B,$39,$5,$1D,$3,$1D,$4
		dc.w	$1D,$2,$1D,$5,$28,$D,$B,$1
		dc.w	$28,$A,$39,$6,$39,$7,$2C,$3
		dc.w	$1D,$9,$4A,$3,$1D,$7,$28,$F
		dc.w	$1D,$B,$1D,$11,$1D,$D,$1D,$8
		dc.w	$28,$11,$1D,$6,$B,$2,$1D,$15
		dc.w	$28,$C,$1D,$A,$28,$E,$1,$8
		dc.w	$1D,$F,$28,$10,$7,$6,$1D,$13
		dc.w	$4A,$4,$1D,$17,$7,$4,$B,$3
		dc.w	$1D,$1B,$4A,$6,$1D,$1D,$4A,$5
		dc.w	$1,$9,$7,$5,$1D,$1E,$1D,$19
		dc.w	$1,$11,$1D,$C,$1D,$7F,$2C,$4
		dc.w	$1D,$E,$1D,$1C,$4A,$A,$1D,$1A
		dc.w	$4A,$7,$1D,$18,$B,$4,$1D,$12
		dc.w	$1D,$10,$1,$F,$B,$5,$1,$D
		dc.w	$1,$13,$4A,$9,$4A,$B,$4A,$C
		dc.w	$2C,$5,$1D,$14,$B,$7,$1D,$16
		dc.w	$1,$C,$1,$E,$4A,$8,$1D,$5F
		dc.w	$1,$A,$B,$6,$B,$8,$B,$A
		dc.w	$39,$8,$B,$9,$2C,$6,$1,$10
		dc.w	$B,$C,$1,$B,$1,$12,$7,$7
		dc.w	$1D,$1F,$28,$12,$B,$B,$2C,$7
		dc.w	$2C,$B,$1D,$23,$1,$15,$2C,$8
		dc.w	$1D,$2E,$1D,$3F,$1,$14,$B,$D
		dc.w	$2C,$9,$2C,$A,$1D,$25,$1D,$55
		dc.w	$1D,$71,$1D,$7C,$4A,$D,$2C,$C
		dc.w	$2C,$F,$2C,$10
;------------------------------------------------------------------------------- 
loc_7806:
		move.b	($FFFFDB0F).w,($FFFFDB11).w
		moveq	#0,d1
		move.l	($FFFFDB00).w,a0
		cmp.l	#$CE316,a0
		blt.s	loc_7846
		cmp.l	#$CE8B2,a0
		bge.s	loc_7846
		move.l	($FFFFDB8E).w,a5
		move.b	($FFFFDB0A).w,d1
		move.b	0(a5,d1),d1
		bpl.s	loc_7884
loc_7830: 
		st ($FFFFDB0E).w
		move.b	($FFFFDB0D).w,d0
		cmp.b	($FFFFDB21).w,d0
		blt loc_7896
		st ($FFFFDB0F).w
		rts
;--------------------------------------------------------------------------------
loc_7846:
		cmp.l	#$CCAC8,a0
		blt.s	loc_7866
		cmp.l	#$CCF8C,a0
		bge.s	loc_7866
		move.l	($FFFFDB8E).w,a5
		move.b	($FFFFDB0A).w,d1
		move.b	0(a5,d1),d1
		bpl.s	loc_7884
		bra.s	loc_7830
loc_7866:
		cmp.l	#$D0A9E,a0
		blt.s	loc_7896
		cmp.l	#$D0F2E,a0
		bge.s	loc_7896
		move.l	($FFFFDB8E).w,a5
		move.b	($FFFFDB0A).w,d1
		move.b	0(a5,d1),d1
		bmi.s	loc_7830
loc_7884:
		sf ($FFFFDB0E).w
		move.b	($FFFFDB0D).w,d0
		cmp.b	($FFFFDB21).w,d0
		blt.s	loc_7896
		sf ($FFFFDB0F).w
loc_7896:
		rts
;--------------------------------------------------------------------------------
loc_7898:
		lea	($FFFFE000).w,a1
		lea	($FFFFD700).w,a2
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		move.w	#$FF00,d1
		move.w	#$FE00,d2
		move.w	#$FD00,d3
		swap.w	d1
		swap.w	d2
		swap.w	d3
		moveq	#$1F,d4
loc_78BC: 
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.l	d2,(a1)+
		move.l	d3,(a1)+
		move.l	d3,(a1)+
		move.l	d3,(a2)+
		move.l	d3,(a2)+
		move.l	d2,(a2)+
		move.l	d2,(a2)+
		move.l	d1,(a2)+
		move.l	d1,(a2)+
		move.l	d0,(a2)+
		move.l	d0,(a2)+
		dbra	d4,loc_78BC
		rts
;--------------------------------------------------------------------------------
loc_78E2:
		lea	(SS_Tiles_8x8_Tiles),a0 
		lea	(RAM_Start),a1
		bsr.w	KosinskiDec 
		move.l	#$40000000,(VDP_control_port)
		lea	(VDP_data_port),a1
		move.l	#RAM_Start,a0
		move.w	(a0)+,d0
		subq.w	#1,d0
loc_790C: 
		move.l	(a0),(a1)
		move.l	(a0),(a1)
		move.l	(a0),(a1)
		move.l	(a0),(a1)
		move.l	(a0),(a1)
		move.l	(a0),(a1)
		move.l	(a0),(a1)
		move.l	(a0)+,(a1)
		dbra	d0,loc_790C
		lea	(SS_Mapings_00),a0 
		lea	($FFFF6A60),a1
		bsr.w	KosinskiDec 
		lea	(SS_Mapings_01),a0 
		lea	($FFFF855C).w,a1
		bsr.w	KosinskiDec 
		lea	(SS_Mapings_02),a0 
		lea	($FFFF8778).w,a1
		bsr.w	KosinskiDec 
		rts
;--------------------------------------------------------------------------------
loc_794E:
		move	#$2700,sr
		move.l	#RAM_Start,a1
		lea	(SS_Mappings_00),a0 
		move.w	#$700,d0
		bsr.w	EnigmaDec 
		move.l	#$FFFF0400,a1
		lea	(SS_Mappings_01),a0 
		move.w	#$700,d0
		bsr.w	EnigmaDec 
		lea	(RAM_Start),a1
		move.l	#$60000002,d0
		moveq	#$1F,d1
		moveq	#$1F,d2
		bsr.w	ShowVDPGraphics_SS 
		lea	(RAM_Start),a1
		move.l	#$60400002,d0
		moveq	#$1F,d1
		moveq	#$1F,d2
		bsr.w	ShowVDPGraphics_SS 
		lea	(RAM_Start),a1
		move.l	#$60800002,d0
		moveq	#$1F,d1
		moveq	#$1F,d2
		bsr.w	ShowVDPGraphics_SS 
		lea	(RAM_Start),a1
		move.l	#$60C00002,d0
		moveq	#$1F,d1
		moveq	#$1F,d2
		bsr.w	ShowVDPGraphics_SS 
		move	#$2300,sr
		rts
;--------------------------------------------------------------------------------
loc_79D0:
		lea	(SS_Sonic_Miles),a0 
		lea	($FF0000),a4
		bra.w	NemesisDec_ToRAM 
loc_79E0:
		bsr.w	loc_7A38
		bsr.w	loc_7ADC
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_79EA:
		dc.w	loc_7A00-loc_79EA
		dc.w	loc_7A05-loc_79EA
		dc.w	loc_7A0A-loc_79EA
		dc.w	loc_7A0F-loc_79EA
		dc.w	loc_7A14-loc_79EA
		dc.w	loc_7A19-loc_79EA
		dc.w	loc_7A1E-loc_79EA
		dc.w	loc_7A23-loc_79EA
		dc.w	loc_7A28-loc_79EA
		dc.w	loc_7A2D-loc_79EA
		dc.w	loc_7A32-loc_79EA
loc_7A00:
		dc.b	$2,$2,$2,$2,$2
loc_7A05:
		dc.b	$4,$4,$5,$4,$5
loc_7A0A:
		dc.b	$B,$B,$B,$B,$C
loc_7A0F:
		dc.b	$0,$0,$1,$0,$0
loc_7A14:
		dc.b	$1,$1,$1,$1,$1
loc_7A19:
		dc.b	$9,$9,$8,$9,$9
loc_7A1E:
		dc.b	$9,$9,$9,$9,$A
loc_7A23:
		dc.b	$7,$7,$6,$7,$7
loc_7A28:
		dc.b	$0,$1,$1,$1,$0
loc_7A2D:
		dc.b	$4,$3,$3,$3,$4
loc_7A32:
		dc.b	$0,$0,$FF,$0,$0,$0
;------------------------------------------------------------------------------- 
loc_7A38:
		moveq	#0,d7
		moveq	#0,d6
		moveq	#0,d0
		move.b	($FFFFDB09).w,d2
		move.b	($FFFFDB08).w,d0
		add.w	d0,d0
		move.w	loc_7A50(pc,d0),d0
		jmp	loc_7A50(pc,d0)
loc_7A50:
		dc.w	loc_7A5A-loc_7A50
		dc.w	loc_7A5A-loc_7A50
		dc.w	loc_7A5A-loc_7A50
		dc.w	loc_7A82-loc_7A50
		dc.w	loc_7A82-loc_7A50
loc_7A5A:
		moveq	#0,d1
		cmp.b	#1,d2
		blt.s	loc_7A84
		moveq	#2,d1
		cmp.b	#2,d2
		blt.s	loc_7A84
		moveq	#4,d1
		cmp.b	#$A,d2
		blt.s	loc_7A84
		moveq	#2,d1
		cmp.b	#$B,d2
		blt.s	loc_7A84
		moveq	#0,d1
		cmp.b	#$C,d2
		blt.s	loc_7A84
loc_7A82:
		rts
;--------------------------------------------------------------------------------
loc_7A84:
		moveq	#0,d0
		moveq	#0,d2
		move.b	($FFFFDB0D).w,d0
		lea	loc_79EA(pc),a0
		add.w	0(a0,d1),a0
		move.b	0(a0,d0),d2
		tst.b	($FFFFDB11).w
		bne.s	loc_7AA6
		tst.b	($FFFFDB0F).w
		beq.s	loc_7ABA
		bra.s	loc_7AB2
loc_7AA6:
		tst.b	($FFFFDB0F).w
		bne.s	loc_7ABA
		lea	($FFFFE002).w,a1
		bra.s	loc_7ACA
loc_7AB2:
		lea	($FFFFD702).w,a1
		neg.w	d2
		bra.s	loc_7ACA
loc_7ABA:
		lea	($FFFFE002).w,a1
		tst.b	($FFFFDB0F).w
		beq.s	loc_7ACA
		lea	($FFFFD702).w,a1
		neg.w	d2
loc_7ACA:
		move.w	#$FF,d0
loc_7ACE: 
		sub.w	d2,(a1)+
		add.l	#2,a1
		dbra	d0,loc_7ACE
		rts
;--------------------------------------------------------------------------------
loc_7ADC:
		move.w	($FFFFDB30).w,($FFFFDB34).w
		moveq	#0,d7
		moveq	#0,d0
		moveq	#0,d2
		move.b	($FFFFDB09).w,d2
		move.b	($FFFFDB08).w,d0
		add.w	d0,d0
		move.w	loc_7AFA(pc,d0),d0
		jmp	loc_7AFA(pc,d0)
loc_7AFA:
		dc.w	loc_7B06-loc_7AFA
		dc.w	loc_7B26-loc_7AFA
		dc.w	loc_7B04-loc_7AFA
		dc.w	loc_7B48-loc_7AFA
		dc.w	loc_7B04-loc_7AFA
loc_7B04:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_7B06:
		move.b	loc_7B0E(pc,d2),d1
		bpl.s	loc_7B66
		rts
;--------------------------------------------------------------------------------
loc_7B0E:
		dc.b	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$8,$8,$2,$4,$4,$4
		dc.b	$4,$4,$4,$A,$C,$E,$12,$10
;------------------------------------------------------------------------------- 
loc_7B26:
		st D7
		move.b	loc_7B30(pc,d2),d1
		bpl.s	loc_7B66
		rts
;--------------------------------------------------------------------------------
loc_7B30:
		dc.b	$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$10,$12,$E,$C,$A
		dc.b	$4,$4,$4,$4,$4,$4,$2,$0
;------------------------------------------------------------------------------- 
loc_7B48:
		tst.b	($FFFFDB87).w
		bne.s	loc_7B54
		move.b	loc_7B56(pc,d2),d1
		bpl.s	loc_7B66
loc_7B54:
		rts
;--------------------------------------------------------------------------------
loc_7B56:
		dc.b	$6,$6,$14,$14,$6,$6,$14,$14,$6,$6,$14,$14,$6,$6,$14,$14
;------------------------------------------------------------------------------- 
loc_7B66:
		moveq	#0,d0
		moveq	#0,d2
		move.b	($FFFFDB0D).w,d0
		lea	loc_79EA(pc),a0
		add.w	0(a0,d1),a0
		move.b	0(a0,d0),d2
		tst.b	d7
		bpl.s	loc_7B84
		add.w	d2,($FFFFDB30).w
		rts
;--------------------------------------------------------------------------------
loc_7B84:
		sub.w	d2,($FFFFDB30).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Special Stage
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine loc_7B8A
; [ Begin ]
;=============================================================================== 
loc_7B8A:
		lea	($FFFFB200).w,a1
		move.w	#$76,d5
loc_7B92: 
		tst.b	(a1)
		beq.s	loc_7B9E
		lea	$40(a1),a1
		dbra	d5,loc_7B92
loc_7B9E:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_7B8A
; [ End ]
;===============================================================================
loc_7BA0:
		move.l	a0,a1
		move.w	#$CFC0,d5
		sub.w	a0,d5
		lsr.w	#6,d5
		subq.w	#1,d5
		bcs.s	loc_7BBA
loc_7BAE: 
		tst.b	(a1)
		beq.s	loc_7BBA
		lea	$40(a1),a1
		dbra	d5,loc_7BAE
loc_7BBA:
		rts
;--------------------------------------------------------------------------------
Obj_0x5E_SS_Head_Up_Display: 
		include 'objects/obj_0x5E.asm'
Obj_0x5F_SS_Start_Flag: 
		include 'objects/obj_0x5F.asm'
;-------------------------------------------------------------------------------
loc_7E76:
		dc.w	loc_7E8C-loc_7E76
		dc.w	loc_7E96-loc_7E76
		dc.w	loc_7EA0-loc_7E76
		dc.w	loc_7EAA-loc_7E76
		dc.w	loc_7EB4-loc_7E76
		dc.w	loc_7EBE-loc_7E76
		dc.w	loc_7EC8-loc_7E76
		dc.w	loc_7ED2-loc_7E76
		dc.w	loc_7EDC-loc_7E76
		dc.w	loc_7EE6-loc_7E76
		dc.w	loc_7EF0-loc_7E76
loc_7E8C:
		dc.w	$1
		dc.l	$F8018012,$8009FFFC
loc_7E96:
		dc.w	$1
		dc.l	$F8018014,$800AFFFC
loc_7EA0:
		dc.w	$1
		dc.l	$F8018016,$800BFFFC
loc_7EAA:
		dc.w	$1
		dc.l	$F8018018,$800CFFFC
loc_7EB4:
		dc.w	$1
		dc.l	$F801801A,$800DFFFC
loc_7EBE:
		dc.w	$1
		dc.l	$F801801C,$800EFFFC
loc_7EC8:
		dc.w	$1
		dc.l	$F801801E,$800FFFFC
loc_7ED2:
		dc.w	$1
		dc.l	$F8018020,$8010FFFC
loc_7EDC:
		dc.w	$1
		dc.l	$F8018022,$8011FFFC
loc_7EE6:
		dc.w	$1
		dc.l	$F8018024,$8012FFFC
loc_7EF0:
		dc.w	$1
		dc.l	$FC04803A,$801DFFF8
;------------------------------------------------------------------------------- 
Obj_0x87: 
		include 'objects/obj_0x87.asm'
;===============================================================================
; Sub Routine loc_819E
; [ Begin ]
;=============================================================================== 
loc_819E: ; Called by Special Stage
		move.b	($FFFFDB0D).w,d0
		cmp.b	($FFFFDB21).w,d0
		beq.s	loc_81AA
		rts
;--------------------------------------------------------------------------------
loc_81AA:
		moveq	#0,d0
		move.b	($FFFFDB10).w,d0
		add.w	d0,d0
		lea	loc_81D8(pc,d0),a2
		move.b	(a2)+,d0
		tst.b	($FFFFDB0E).w
		beq.s	loc_81C0
		neg.b	d0
loc_81C0:
		ext.w	d0
		add.w	#$80,d0
		move.w	d0,($FFFFF73E).w
		move.b	(a2),d0
		ext.w	d0
		add.w	#$36,d0
		move.w	d0,($FFFFF740).w
		rts
;--------------------------------------------------------------------------------
loc_81D8:
		dc.w	$1300,$1300,$1300,$1300,$9F6,$E4,$E4,$E0
		dc.w	$DC,$D6,$F0,$6,$E,$10,$12,$12
		dc.w	$912,$0,$0,$0,$0,$1300,$1300,$1300
		dc.w	$1300,$B0C,$C,$12,$A,$8,$2,$10
		dc.w	$E0,$E1,$E2,$E5,$E8,$F2,$1300,$1300
		dc.w	$1300,$1300,$1300,$1300,$1300,$1300,$1300,$1300
		dc.w	$B00,$0,$0,$0,$0,$0,$0,$300
;===============================================================================
; Sub Routine loc_819E
; [ End ]
;=============================================================================== 
;===============================================================================
; Sub Routine loc_8248 - Special Stage
; [ Begin ]
;=============================================================================== 
loc_8248:
		moveq	#0,d1
		moveq	#1,d2
		move.w	(Current_Special_Stage).w,d0
		move.b	d0,d1
		lsr.w	#8,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d1,d0
		move.b	loc_8298(pc,d0),d1
		move.w	d1,($FFFFDB8C).w
		moveq	#0,d0
		cmp.w	#$64,d1
		blt.s	loc_8282
		addq.w	#1,d2
		sub.w	#$64,d1
		move.w	#$100,d0
		cmp.w	#$64,d1
		blt.s	loc_8282
		sub.w	#$64,d1
		add.w	#$100,d0
loc_8282:
		divu.w	#$A,d1
		lsl.w	#4,d1
		or.b	d1,d0
		swap.w	d1
		or.b	d1,d0
		move.w	d0,d1
		add.w	#1,(Current_Special_Stage).w
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_8298:
		dc.b	$14,$32,$46,$46,$23,$4B,$82,$BE,$28,$55,$96,$DC,$2D,$5F,$AA,$FA
		dc.b	$32,$69,$BE,$FA,$32,$69,$BE,$FA,$32,$69,$BE,$FA,$28,$50,$8C,$C8
		dc.b	$28,$50,$8C,$C8,$28,$50,$8C,$C8 
;===============================================================================
; Sub Routine loc_8248 - Special Stage
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine loc_82D4
; [ Begin ]
;=============================================================================== 
Special_Stage_Palette_Idx: 
		dc.w	$1B,$1C,$1D,$1E,$1F,$20,$21,$22
		dc.w	$23,$24
loc_82D4: ; Called by Special Stage
		and.w	#$FF00,(Current_Special_Stage).w
		move.b	#$FF,($FFFFDB4C).w
		move.w	#0,(Ring_count).w
		move.w	#0,($FFFFFED0).w
		move.b	#0,($FFFFFF42).w
		move.b	#0,($FFFFFFB0).w
		lea	($FFFFFFA0).w,a2
		moveq	#0,d0
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		move.w	d0,(a2)+
		move.b	#7,($FFFFDB97).w
		moveq	#$18,d0
		bsr.w	PalLoad1 
		lea	Special_Stage_Palette_Idx(pc),a1 
		moveq	#0,d0
		move.b	(Current_Special_Stage).w,d0
		move.b	d0,($FFFFDB94).w
		tst.b	(System_Stack).w
		beq.s	loc_8338
		cmp.b	#3,d0
		bcs.s	loc_8334
		move.b	#0,d0
loc_8334:
		addq.w	#7,d0
		bra.s	loc_835E
loc_8338:
		cmp.b	#7,d0
		bcs.s	loc_835E
		moveq	#0,d3
		moveq	#6,d4
		lea	($FFFFFFB2).w,a2
loc_8346: 
		tst.b	(a2)+
		beq.s	loc_8358
		addq.w	#1,d3
		dbra	d4,loc_8346
		move.l	(sp)+,d0
		move.l	(sp)+,d0
		bra.w	J_EntryPoint 
loc_8358:
		move.b	d3,(Current_Special_Stage).w
		move.w	d3,d0
loc_835E:
		add.w	d0,d0
		move.w	d0,d1
		move.w	0(a1,d0),d0
		bsr.w	PalLoad1 
		lea	($FFFF8778).w,a0
		add.w	0(a0,d1),a0
		move.l	a0,($FFFFDB88).w
		lea	($FFFF855C).w,a0
		add.w	0(a0,d1),a0
		move.l	a0,($FFFFDB8E).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_82D4
; [ End ]
;===============================================================================
 
J_DisplaySprite_00: 
		jmp	DisplaySprite 
J_DeleteObject_00: 
		jmp	DeleteObject 
loc_8390:
		jmp	(loc_31ED8)
J_EntryPoint: 
		jmp	EntryPoint 
loc_839C:
		jmp	(loc_31F8C)
J_SpeedToPos_00: 
		jmp	SpeedToPos 
J_Head_Up_Display_Base_00: 
		jmp	Head_Up_Display_Base 
		cnop	0,4 ; Filler 
;===============================================================================
; Sub Routine Continue
; [ Begin ]
;===============================================================================
TC_A = $4
TC_B = $404
TC_C = $804
TC_D = $C04
TC_F = $1004
TC_G = $1404
TC_H = $1804
TC_I = $1C02
TC_J = $1E04
TC_K = $2204
TC_L = $2604
TC_M = $2A06
TC_P = $3004
TC_Q = $3404
TC_R = $3804
TC_S = $3C04
TC_T = $4004
TC_U = $4404
TC_V = $4804
TC_W = $4C06
TC_X = $5204
TC_Y = $5604 
TC_Break = $FFFF 
Continue: 
		bsr.w	Pal_FadeFrom 
		move	#$2700,sr
		move.w	(VDP_Reg0_Val).w,d0
		and.b	#$BF,d0
		move.w	d0,(VDP_control_port)
		lea	(VDP_control_port),a6
		move.w	#$8004,(a6)
		move.w	#$8700,(a6)
		bsr.w	ClearScreen 
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
loc_83E2: 
		move.l	d0,(a1)+
		dbra	d1,loc_83E2
		bsr.w	loc_8536
		move.l	#$60000002,(VDP_control_port)
		lea	(Miles_In_Continue),a0 
		bsr.w	NemesisDec 
		move.l	#$64800002,(VDP_control_port)
		lea	(Mini_Sonic),a0 
		bsr.w	NemesisDec 
		moveq	#$A,d1
		jsr	Time_Count_Down 
		moveq	#$1B,d0
		bsr.w	PalLoad1 
		move.w	#0,($FFFFFB80).w
		move.b	#$9C,d0
		bsr.w	Play_Music 
		move.w	#$293,(Demo_Time_left).w
		clr.b	($FFFFF711).w
		clr.l	($FFFFEEF0).w
		move.l	#$1000000,($FFFFEEF4).w
		move.b	#$DB,(Object_RAM).w
		move.b	#$DB,($FFFFB040).w
		move.b	#6,($FFFFB064).w
		move.b	#$DA,($FFFFB080).w
		move.b	#$DA,($FFFFB0C0).w
		move.b	#4,($FFFFB0E4).w
		jsr	Load_Objects 
		jsr	Build_Sprites 
		move.b	#$16,(Delay_Time).w
		bsr.w	DelayProgram 
		move.w	(VDP_Reg0_Val).w,d0
		or.b	#$40,d0
		move.w	d0,(VDP_control_port)
		bsr.w	Pal_FadeTo 
loc_8492: 
		move.b	#$16,(Delay_Time).w
		bsr.w	DelayProgram 
		cmp.b	#4,($FFFFB024).w
		bcc.s	loc_84C0
		move	#$2700,sr
		move.w	(Demo_Time_left).w,d1
		divu.w	#$3C,d1
		and.l	#$F,d1
		jsr	Time_Count_Down 
		move	#$2300,sr
loc_84C0:
		jsr	Load_Objects 
		jsr	Build_Sprites 
		cmp.w	#$180,($FFFFB048).w
		bcc.s	loc_84EC
		cmp.b	#4,($FFFFB024).w
		bcc.s	loc_8492
		tst.w	(Demo_Time_left).w
		bne.w	loc_8492
		move.b	#0,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_84EC:
		move.b	#$C,(Game_Mode).w
		move.b	#3,(Life_count).w
		move.b	#3,($FFFFFEC6).w
		moveq	#0,d0
		move.w	d0,(Ring_count).w
		move.l	d0,($FFFFFE22).w
		move.l	d0,($FFFFFE26).w
		move.b	d0,($FFFFFE30).w
		move.w	d0,($FFFFFED0).w
		move.l	d0,($FFFFFED2).w
		move.l	d0,($FFFFFED6).w
		move.b	d0,($FFFFFEE0).w
		move.l	#$1388,($FFFFFFC0).w
		move.l	#$1388,($FFFFFFC4).w
		subq.b	#1,($FFFFFE18).w
		rts
;--------------------------------------------------------------------------------
loc_8536:
		move.l	#$70000002,(VDP_control_port)
		lea	(Title_Card_ZONE_123),a0 
		bsr.w	NemesisDec 
		lea	($FFFF8000).w,a4
		lea	(Title_Card_AY),a0 
		bsr.w	NemesisDec_ToRAM 
		lea	(Load_Continue_Font),a0 
		move.l	#$72000002,(VDP_control_port)
		lea	($FFFF8000).w,a1
		lea	(VDP_data_port),a6
loc_8572: 
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_858E
		lsl.w	#5,d0
		lea	0(a1,d0),a2
		moveq	#0,d1
		move.b	(a0)+,d1
		lsl.w	#3,d1
		subq.w	#1,d1
loc_8586: 
		move.l	(a2)+,(a6)
		dbra	d1,loc_8586
		bra.s	loc_8572
loc_858E:
		rts
;--------------------------------------------------------------------------------
Load_Continue_Font: 
		dc.w	TC_C,TC_T,TC_I,TC_U,TC_Break 
;------------------------------------------------------------------------------- 
Obj_0xDA_Continue_Counter: 
		include 'objects/obj_0xDA.asm'
;------------------------------------------------------------------------------- 
J_DisplaySprite_01: 
		jmp	DisplaySprite 
J_DeleteObject_01: 
		jmp	DeleteObject 
;------------------------------------------------------------------------------- 
Obj_0xDB_Sonic_Miles_Continue: 
		include 'objects/obj_0xDB.asm'
;------------------------------------------------------------------------------- 
		nop ; Filler
loc_8878:
		jmp	Modify_A1_SpriteAttr_2P 
loc_887E:
		jmp	ModifySpriteAttr_2P 
;===============================================================================
; Sub Routine Continue
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine Versus Mode Results
; [ Begin ]
;=============================================================================== 
Versus_Mode_Results: 
		bsr.w	Pal_FadeFrom 
		move	#$2700,sr
		move.w	(VDP_Reg0_Val).w,d0
		and.b	#$BF,d0
		move.w	d0,(VDP_control_port)
		bsr.w	ClearScreen 
		lea	(VDP_control_port),a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$8230,(a6)
		move.w	#$8700,(a6)
		move.w	#$8C81,(a6)
		move.w	#$9001,(a6)
		lea	($FFFFAC00).w,a1
		moveq	#0,d0
		move.w	#$FF,d1
loc_88CA: 
		move.l	d0,(a1)+
		dbra	d1,loc_88CA
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
loc_88DA: 
		move.l	d0,(a1)+
		dbra	d1,loc_88DA
		move.l	#$42000000,(VDP_control_port)
		lea	(Menu_Font),a0 
		bsr.w	NemesisDec 
		move.l	#$4C000000,(VDP_control_port)
		lea	(Versus_Result_Font),a0 
		bsr.w	NemesisDec 
		lea	(RAM_Start),a1
		lea	(Versus_Menu_Bg_Mappings),a0 
		move.w	#$6000,d0
		bsr.w	EnigmaDec 
		lea	(RAM_Start),a1
		move.l	#$60000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	ShowVDPGraphics 
		move.w	($FFFFFF10).w,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0
		lea	Map_Vs_Mode_Results_Idx(pc),a2 
		move.l	0(a2,d0),a0
		move.l	4(a2,d0),a2
		lea	(RAM_Start),a1
		move.w	#0,d0
		bsr.w	EnigmaDec 
		jsr	(a2)
		lea	(RAM_Start),a1
		move.l	#$40000003,d0 
		moveq	#$27,d1
		moveq	#$1B,d2 
		bsr.w	ShowVDPGraphics 
		clr.b	($FFFFF711).w
		clr.w	($FFFFF7F0).w
		lea	(Menu_Animate),a2 
		bsr.w	J_Dynamic_Normal 
		moveq	#0,d0
		bsr.w	LoadPLC2 
		moveq	#$26,d0 
		bsr.w	PalLoad1 
		moveq	#0,d0
		move.b	#$81,d0
		cmp.w	($FFFFFF90).w,d0
		beq.s	loc_899C
		move.w	d0,($FFFFFF90).w
		bsr.w	Play_Music 
loc_899C:
		move.w	#$707,(Demo_Time_left).w
		clr.w	($FFFFFFD8).w
		clr.l	($FFFFEE00).w
		clr.l	(Camera_Y_pos).w
		move.b	#$21,(Object_RAM).w
		move.b	#$16,(Delay_Time).w
		bsr.w	DelayProgram 
		move.w	(VDP_Reg0_Val).w,d0
		or.b	#$40,d0
		move.w	d0,(VDP_control_port)
		bsr.w	Pal_FadeTo 
loc_89D0: 
		move.b	#$16,(Delay_Time).w
		bsr.w	DelayProgram 
		lea	(Menu_Animate),a2 
		bsr.w	J_Dynamic_Normal 
		jsr	Load_Objects 
		jsr	Build_Sprites 
		bsr.w	RunPLC 
		tst.l	(Plc_Buffer).w
		bne.s	loc_89D0
		move.b	(Ctrl_1_Press).w,d0
		or.b	($FFFFF607).w,d0
		and.b	#$80,d0
		beq.s	loc_89D0
		move.w	($FFFFFF10).w,d0
		bne.w	loc_8A96
		tst.b	($FFFFFE11).w
		bne.s	loc_8A3A
		addq.b	#1,($FFFFFE11).w
		move.b	#1,($FFFFFF89).w
		move.b	#$C,(Game_Mode).w
		move.b	#0,($FFFFFE30).w
		move.b	#0,($FFFFFEE0).w
		move.w	#1,($FFFFFFD8).w
		rts
;--------------------------------------------------------------------------------
loc_8A3A:
		move.b	#2,($FFFFFF89).w
		bsr.w	loc_8F32
		lea	($FFFFFF38).w,a4
		clr.w	(a4)
		bsr.s	loc_8A7E
		bsr.s	loc_8A7E
		move.b	(a4),d1
		sub.b	1(a4),d1
		beq.s	loc_8A64
		move.w	#1,($FFFFFF10).w
		move.b	#$18,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_8A64:
		move.w	#3,($FFFFFF10).w
		move.b	#1,($FFFFF7CD).w
		move.b	#$10,(Game_Mode).w
		move.w	#1,($FFFFFFD8).w
		rts
;--------------------------------------------------------------------------------
loc_8A7E:
		moveq	#0,d1
		move.b	(a5),d1
		sub.b	1(a5),d1
		beq.s	loc_8A92
		bcs.s	loc_8A8E
		addq.b	#1,(a4)
		bra.s	loc_8A92
loc_8A8E:
		addq.b	#1,1(a4)
loc_8A92:
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_8A96:
		subq.w	#1,d0
		bne.s	loc_8AE8
loc_8A9A: 
		lea	(Results_Data_2P).w,a4
		moveq	#0,d0
		moveq	#0,d1
		move.w	(a4)+,d0
		add.l	d0,d1
		move.w	(a4)+,d0
		add.l	d0,d1
		addq.w	#2,a4
		move.w	(a4)+,d0
		add.l	d0,d1
		move.w	(a4)+,d0
		add.l	d0,d1
		addq.w	#2,a4
		move.w	(a4)+,d0
		add.l	d0,d1
		move.w	(a4)+,d0
		add.l	d0,d1
		addq.w	#2,a4
		move.w	(a4)+,d0
		add.l	d0,d1
		move.w	(a4)+,d0
		add.l	d0,d1
		move.w	(a4)+,d0
		add.l	d0,d1
		swap.w	d1
		tst.w	d1
		bne.s	loc_8AE0
		move.w	#2,($FFFFFF10).w
		move.b	#$18,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_8AE0:
		move.b	#$1C,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_8AE8:
		subq.w	#1,d0
		bne.s	loc_8AF4
		move.b	#0,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_8AF4:
		subq.w	#1,d0
		bne.s	loc_8B48
		cmp.b	#3,(Current_Zone_2P).w
		beq.s	loc_8B0E
		move.w	#1,($FFFFFF10).w
		move.b	#$18,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_8B0E:
		cmp.b	#2,($FFFFFF89).w
		beq.s	loc_8B3A
		addq.b	#1,($FFFFFF89).w
		move.w	#3,($FFFFFF10).w
		move.b	#1,($FFFFF7CD).w
		move.b	#$10,(Game_Mode).w
		move.w	#1,($FFFFFFD8).w
		move.w	#0,($FFFFFF90).w
		rts
;--------------------------------------------------------------------------------
loc_8B3A:
		move.w	#4,($FFFFFF10).w
		move.b	#$18,(Game_Mode).w
		rts
;--------------------------------------------------------------------------------
loc_8B48:
		bra.w	loc_8A9A 
;===============================================================================
; Sub Routine Versus Mode Results
; [ End ]
;=============================================================================== 
Obj_0x21_2P_Versus_Results: 
		include 'objects/obj_0x21.asm'
;===============================================================================
; Sub Routine Vs_Mode_Current_Act_Results
; [ Begin ]
;=============================================================================== 
Vs_Mode_Current_Act_Results:
		move.w	#$1F2,d2
		moveq	#0,d0
		bsr.w	loc_90FE
		move.w	#$216,d2
		moveq	#0,d1
		move.b	($FFFFFF89).w,d1
		addq.b	#1,d1
		bsr.w	loc_913C
		move.w	#$33E,d2
		move.l	($FFFFFE26).w,d1
		bsr.w	loc_9182
		move.w	#$352,d2
		move.l	($FFFFFED6).w,d1
		bsr.w	loc_9182
		move.w	#$3DA,d2
		moveq	#0,d0
		move.w	($FFFFFE22).w,d1
		bsr.w	loc_913C
		move.w	#$3E0,d2
		moveq	#0,d1
		move.b	($FFFFFE24).w,d1
		bsr.w	loc_913C
		move.w	#$3E6,d2
		moveq	#0,d1
		move.b	($FFFFFE25).w,d1
		mulu.w	#$1B0,d1
		lsr.l	#8,d1
		bsr.w	loc_913C
		move.w	#$3EE,d2
		moveq	#0,d0
		move.w	($FFFFFED2).w,d1
		bsr.w	loc_913C
		move.w	#$3F4,d2
		moveq	#0,d1
		move.b	($FFFFFED4).w,d1
		bsr.w	loc_913C
		move.w	#$3FA,d2
		moveq	#0,d1
		move.b	($FFFFFED5).w,d1
		mulu.w	#$1B0,d1
		lsr.l	#8,d1
		bsr.w	loc_913C
		move.w	#$486,d2
		moveq	#0,d0
		move.w	(Ring_count).w,d1
		bsr.w	loc_913C
		move.w	#$49A,d2
		move.w	($FFFFFED0).w,d1
		bsr.w	loc_913C
		move.w	#$526,d2
		moveq	#0,d0
		move.w	($FFFFFEF0).w,d1
		bsr.w	loc_913C
		move.w	#$53A,d2
		move.w	($FFFFFEF2).w,d1
		bsr.w	loc_913C
		move.w	#$5C6,d2
		moveq	#0,d0
		move.w	($FFFFFEF4).w,d1
		bsr.w	loc_913C
		move.w	#$5DA,d2
		move.w	($FFFFFEF6).w,d1
		bsr.w	loc_913C
		bsr.w	loc_8F04
		move.w	#$364,d2
		move.w	#$6000,d0
		move.l	($FFFFFE26).w,d1
		sub.l	($FFFFFED6).w,d1
		bsr.w	loc_90DE
		move.w	#$404,d2
		move.l	($FFFFFED2).w,d1
		sub.l	($FFFFFE22).w,d1
		bsr.w	loc_90DE
		move.w	#$4A4,d2
		moveq	#0,d1
		move.w	(Ring_count).w,d1
		sub.w	($FFFFFED0).w,d1
		bsr.w	loc_90DE
		move.w	#$544,d2
		moveq	#0,d1
		move.w	($FFFFFEF0).w,d1
		sub.w	($FFFFFEF2).w,d1
		bsr.w	loc_90DE
		move.w	#$5E4,d2
		moveq	#0,d1
		move.w	($FFFFFEF4).w,d1
		sub.w	($FFFFFEF6).w,d1
		bsr.w	loc_90DE
		move.w	#$706,d2
		moveq	#0,d0
		moveq	#0,d1
		move.b	(a4),d1
		bsr.w	loc_913C
		move.w	#$70E,d2
		moveq	#0,d1
		move.b	1(a4),d1
		bsr.w	loc_913C
		move.w	(a4),($FFFFFF38).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Vs_Mode_Current_Act_Results
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Vs_Mode_Current_Level_Results
; [ Begin ]
;=============================================================================== 
Vs_Mode_Current_Level_Results: 
		move.w	#$242,d2
		moveq	#0,d0
		bsr.w	loc_90FE
		bsr.w	loc_8F32
		lea	($FFFFFF38).w,a4
		clr.w	(a4)
		move.w	#$398,d6
		bsr.w	loc_8FD8
		move.w	#$488,d6
		bsr.w	loc_8FD8
		move.w	#$618,d6
		bsr.w	loc_8FD8
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Vs_Mode_Current_Level_Results
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine Vs_Mode_Global_Results
; [ Begin ]
;===============================================================================
Vs_Mode_Global_Results: 
		lea	(Results_Data_2P).w,a5
		lea	($FFFFFF38).w,a4
		clr.w	(a4)
		move.w	#$208,d6
		bsr.w	loc_8F52
		move.w	#$258,d6
		bsr.w	loc_8F52
		move.w	#$2A8,d6
		bsr.w	loc_8F52
		move.w	#$348,d6
		bsr.w	loc_8F52
		move.w	#$398,d6
		bsr.w	loc_8F52
		move.w	#$3E8,d6
		bsr.w	loc_8F52
		move.w	#$488,d6
		bsr.w	loc_8F52
		move.w	#$4D8,d6
		bsr.w	loc_8F52
		move.w	#$528,d6
		bsr.w	loc_8F52
		move.w	#$5C8,d6
		bsr.w	loc_8F52
		move.w	#$618,d6
		bsr.w	loc_8F52
		move.w	#$668,d6
		bsr.w	loc_8F52
		move.w	#$70A,d2
		moveq	#0,d0
		moveq	#0,d1
		move.b	(a4),d1
		bsr.w	loc_913C
		move.w	#$710,d2
		moveq	#0,d1
		move.b	1(a4),d1
		bsr.w	loc_913C
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Vs_Mode_Global_Results
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Vs_Mode_SS_Results 
; [ Begin ]
;=============================================================================== 
Vs_Mode_SS_Results: 
		move.w	#$266,d2
		moveq	#0,d1
		move.b	($FFFFFE17).w,d1
		addq.b	#1,d1
		bsr.w	loc_913C
		move.w	#$4D6,d2
		moveq	#0,d0
		move.w	($FFFFFFA0).w,d1
		bsr.w	loc_913C
		move.w	#$4E6,d2
		move.w	($FFFFFFA2).w,d1
		bsr.w	loc_913C
		move.w	#$576,d2
		moveq	#0,d0
		move.w	($FFFFFFA4).w,d1
		bsr.w	loc_913C
		move.w	#$586,d2
		move.w	($FFFFFFA6).w,d1
		bsr.w	loc_913C
		move.w	#$616,d2
		moveq	#0,d0
		move.w	($FFFFFFA8).w,d1
		bsr.w	loc_913C
		move.w	#$626,d2
		move.w	($FFFFFFAA).w,d1
		bsr.w	loc_913C
		bsr.w	loc_8F04
		move.w	#$6000,d0
		move.w	#$4F0,d2
		moveq	#0,d1
		move.w	($FFFFFFA0).w,d1
		sub.w	($FFFFFFA2).w,d1
		bsr.w	loc_90DE
		move.w	#$590,d2
		moveq	#0,d1
		move.w	($FFFFFFA4).w,d1
		sub.w	($FFFFFFA6).w,d1
		bsr.w	loc_90DE
		move.w	#$630,d2
		moveq	#0,d1
		move.w	($FFFFFFA8).w,d1
		sub.w	($FFFFFFAA).w,d1
		bsr.w	loc_90DE
		move.w	(a4),($FFFFFF38).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Vs_Mode_SS_Results 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Vs_Mode_All_SS_Results 
; [ Begin ]
;=============================================================================== 
Vs_Mode_All_SS_Results: 
		bsr.w	loc_8F32
		lea	($FFFFFF38).w,a4
		clr.w	(a4)
		move.w	#$4D4,d6
		bsr.w	loc_905C
		move.w	#$574,d6
		bsr.w	loc_905C
		move.w	#$614,d6
		bsr.w	loc_905C
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Vs_Mode_All_SS_Results 
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine loc_8F04
; [ Begin ]
;=============================================================================== 
loc_8F04: ; Called by Time Over / Game Over Object
		lea	(Results_Data_2P).w,a4
		move.b	(Current_Zone_2P).w,d0
		beq.s	loc_8F22
		lea	($FFFFFF26).w,a4
		subq.b	#1,d0
		beq.s	loc_8F22
		lea	($FFFFFF2C).w,a4
		subq.b	#1,d0
		beq.s	loc_8F22
		lea	($FFFFFF32).w,a4
loc_8F22:
		moveq	#0,d0
		move.b	($FFFFFF89).w,d0
		add.w	d0,d0
		lea	0(a4,d0),a4
		clr.w	(a4)
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_8F04
; [ End ]
;=============================================================================== 
		
;===============================================================================
; Sub Routine loc_8F32
; [ Begin ]
;=============================================================================== 
loc_8F32:
		lea	(Results_Data_2P).w,a5
		move.b	(Current_Zone_2P).w,d0
		beq.s	loc_8F50
		lea	($FFFFFF26).w,a5
		subq.b	#1,d0
		beq.s	loc_8F50
		lea	($FFFFFF2C).w,a5
		subq.b	#1,d0
		beq.s	loc_8F50
		lea	($FFFFFF32).w,a5
loc_8F50:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_8F32
; [ End ]
;=============================================================================== 
loc_8F52:
		move.w	(a5),d0
		bmi.s	loc_8F8A
		move.w	d6,d2
		moveq	#0,d0
		moveq	#0,d1
		move.b	(a5),d1
		bsr.w	loc_913C
		addq.w	#8,d6
		move.w	d6,d2
		moveq	#0,d1
		move.b	1(a5),d1
		bsr.w	loc_913C
		add.w	#$12,d6
		move.w	d6,d2
		move.w	#$6000,d0
		moveq	#0,d1
		move.b	(a5),d1
		sub.b	1(a5),d1
		bsr.w	loc_90DE
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_8F8A:
		addq.w	#4,d6
		not.w	d0
		bne.s	loc_8FB0
		lea	(Map_No_Game),a1 
		move.w	d6,d2
		bsr.w	loc_9124
		add.w	#$16,d6
		move.w	d6,d2
		lea	(Map_Blank),a1 
		bsr.w	loc_9124
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_8FB0:
		moveq	#0,d0
		lea	(Map_Game_Over),a1 
		move.w	d6,d2
		bsr.w	loc_9124
		add.w	#$16,d6
		move.w	d6,d2
		move.w	#$6000,d0
		moveq	#0,d1
		move.b	(a5),d1
		sub.b	1(a5),d1
		bsr.w	loc_90DE
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_8FD8:
		move.w	(a5),d0
		bmi.s	loc_9010
		move.w	d6,d2
		moveq	#0,d0
		moveq	#0,d1
		move.b	(a5),d1
		bsr.w	loc_913C
		addq.w	#8,d6
		move.w	d6,d2
		moveq	#0,d1
		move.b	1(a5),d1
		bsr.w	loc_913C
		add.w	#$C,d6
		move.w	d6,d2
		move.w	#$6000,d0
		moveq	#0,d1
		move.b	(a5),d1
		sub.b	1(a5),d1
		bsr.w	loc_90DE
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_9010:
		not.w	d0
		bne.s	loc_9034
		lea	(Map_No_Game),a1 
		move.w	d6,d2
		bsr.w	loc_9124
		add.w	#$14,d6
		move.w	d6,d2
		lea	(Map_Blank),a1 
		bsr.w	loc_9124
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_9034:
		moveq	#0,d0
		lea	(Map_Game_Over),a1 
		move.w	d6,d2
		bsr.w	loc_9124
		add.w	#$14,d6
		move.w	d6,d2
		move.w	#$6000,d0
		moveq	#0,d1
		move.b	(a5),d1
		sub.b	1(a5),d1
		bsr.w	loc_90DE
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_905C:
		move.w	(a5),d0
		bmi.s	loc_9096
		move.w	d6,d2
		moveq	#0,d0
		moveq	#0,d1
		move.b	(a5),d1
		bsr.w	loc_913C
		add.w	#$C,d6
		move.w	d6,d2
		moveq	#0,d1
		move.b	1(a5),d1
		bsr.w	loc_913C
		add.w	#$10,d6
		move.w	d6,d2
		move.w	#$6000,d0
		moveq	#0,d1
		move.b	(a5),d1
		sub.b	1(a5),d1
		bsr.w	loc_90DE
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_9096:
		not.w	d0
		bne.s	loc_90B8
		lea	(Map_No_Game),a1 
		move.w	d6,d2
		bsr.w	loc_9124
		add.w	#$14,d6
		move.w	d6,d2
		lea	(Map_Blank),a1 
		bsr.s	loc_9124
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_90B8:
		moveq	#0,d0
		lea	(Map_Game_Over),a1 
		move.w	d6,d2
		bsr.s	loc_9124
		add.w	#$14,d6
		move.w	d6,d2
		move.w	#$6000,d0
		moveq	#0,d1
		move.b	(a5),d1
		sub.b	1(a5),d1
		bsr.w	loc_90DE
		addq.w	#2,a5
		rts
;--------------------------------------------------------------------------------
loc_90DE:
		lea	(Map_Tied),a1 
		beq.s	loc_90FC
		bcs.s	loc_90F2
		lea	(Map_1P),a1 
		addq.b	#1,(a4)
		bra.s	loc_90FC
loc_90F2:
		lea	(Map_2P),a1 
		addq.b	#1,1(a4)
loc_90FC:
		bra.s	loc_9124
loc_90FE:
		lea	(Map_Emerald_Hill),a1 
		move.b	(Current_Zone_2P).w,d1
		beq.s	loc_9124
		lea	(Map_Mystic_Cave),a1 
		subq.b	#1,d1
		beq.s	loc_9124
		lea	(Map_Casino_Night),a1 
		subq.b	#1,d1
		beq.s	loc_9124
		lea	(Map_Special_Stage),a1 
loc_9124:
		lea	(RAM_Start),a2
		lea	0(a2,d2),a2
		moveq	#0,d1
		move.b	(a1)+,d1
loc_9132: 
		move.b	(a1)+,d0
		move.w	d0,(a2)+
		dbra	d1,loc_9132
		rts
;--------------------------------------------------------------------------------
loc_913C:
		lea	(RAM_Start),a2
		lea	0(a2,d2),a2
		lea	(loc_917C),a3
		moveq	#0,d2
		moveq	#2,d5
loc_9150: 
		moveq	#0,d3
		move.w	(a3)+,d4
loc_9154: 
		sub.w	d4,d1
		bcs.s	loc_915C
		addq.w	#1,d3
		bra.s	loc_9154
loc_915C:
		add.w	d4,d1
		tst.w	d5
		beq.s	loc_916C
		tst.w	d3
		beq.s	loc_9168
		moveq	#1,d2
loc_9168:
		tst.w	d2
		beq.s	loc_9174
loc_916C:
		add.b	#$10,d3
		move.b	d3,d0
		move.w	d0,(a2)
loc_9174:
		addq.w	#2,a2
		dbra	d5,loc_9150
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_917C:
		dc.w	$64,$A,$1 
;------------------------------------------------------------------------------- 
loc_9182:
		lea	(RAM_Start),a2
		lea	0(a2,d2),a2
		lea	(loc_91BE),a3
		moveq	#0,d2
		moveq	#5,d5
loc_9196: 
		moveq	#0,d3
		move.l	(a3)+,d4
loc_919A: 
		sub.l	d4,d1
		bcs.s	loc_91A2
		addq.w	#1,d3
		bra.s	loc_919A
loc_91A2:
		add.l	d4,d1
		tst.w	d3
		beq.s	loc_91AA
		moveq	#1,d2
loc_91AA:
		tst.w	d2
		beq.s	loc_91B6
		add.b	#$10,d3
		move.b	d3,d0
		move.w	d0,(a2)
loc_91B6:
		addq.w	#2,a2
		dbra	d5,loc_9196
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_91BE:
		dc.l	$186A0,$2710,$3E8,$64
		dc.l	$A,$1 
;------------------------------------------------------------------------------- 
___ = $0
__1 = $11
__2 = $12
__A = $1E
__B = $1F 
__C = $20
__D = $21
__E = $22
__F = $23
__G = $24
__H = $25 
__I = $26
__J = $27
__K = $28
__L = $29
__M = $2A 
__N = $2B 
__O = $2C
__P = $2D
__Q = $2E
__R = $2F
__S = $30
__T = $31
__U = $32
__V = $33
__W = $34
__X = $35
__Y = $36
__Z = $37
 
Map_Emerald_Hill: 
		dc.b	$B,__E,__M,__E,__R,__A,__L,__D,___,__H,__I,__L,__L 
Map_Mystic_Cave: 
		dc.b	$B,___,__M,__Y,__S,__T,__I,__C,___,__C,__A,__V,__E 
Map_Casino_Night: 
		dc.b	$B,__C,__A,__S,__I,__N,__O,___,__N,__I,__G,__H,__T
Map_Special_Stage: 
		dc.b	$C,__S,__P,__E,__C,__I,__A,__L,___,__S,__T,__A,__G,__E
Map_Special: 
		dc.b	$B,___,___,___,__S,__P,__E,__C,__I,__A,__L,___,___
Map_Zone: 
		dc.b	$4,__Z,__O,__N,__E,___ 
Map_Stage: 
		dc.b	$4,__S,__T,__A,__G,__E
Map_Game_Over: 
		dc.b	$8,__G,__A,__M,__E,___,__O,__V,__E,__R
; Map_Time_Over 
		dc.b	$8,__T,__I,__M,__E,___,__O,__V,__E,__R
Map_No_Game: 
		dc.b	$6,__N,__O,___,__G,__A,__M,__E
Map_Tied: 
		dc.b	$3,__T,__I,__E,__D
Map_1P: 
		dc.b	$2,___,__1,__P
Map_2P: 
		dc.b	$2,___,__2,__P
Map_Blank: 
		dc.b	$3,___,___,___,___
;-------------------------------------------------------------------------------
Menu_Animate: 
		dc.w	$0 ; Total of Animations 
		dc.l	($FF<<$18)|Sonic_Miles 
		dc.w	$20 ; VRam 
		dc.w	$60A ; Frames/Tiles
		dc.w	$C7,$A05,$1405,$1EC7,$1405,$A05 ; Frame Load/Frame Time
;------------------------------------------------------------------------------- 
Map_Vs_Mode_Results_Idx: 
		dc.l	Map_Vs_Mode_Current_Act_Results 
		dc.l	Vs_Mode_Current_Act_Results 
		dc.l	Map_Vs_Mode_Current_Level_Results 
		dc.l	Vs_Mode_Current_Level_Results 
		dc.l	Map_Vs_Mode_Global_Results 
		dc.l	Vs_Mode_Global_Results 
		dc.l	Map_Vs_Mode_SS_Results 
		dc.l	Vs_Mode_SS_Results 
		dc.l	Map_Vs_Mode_All_SS_Results 
		dc.l	Vs_Mode_All_SS_Results 
;-------------------------------------------------------------------------------
Map_Vs_Mode_Current_Act_Results: 
		incbin 'mapeni/vsactres.eni'
Map_Vs_Mode_Current_Level_Results: 
		incbin 'mapeni/vslvlres.eni'
Map_Vs_Mode_Global_Results: 
		incbin 'mapeni/vsgblres.eni'
Map_Vs_Mode_SS_Results:
		incbin 'mapeni/vs_ssres.eni'
Map_Vs_Mode_All_SS_Results: 
		incbin 'mapeni/vsall_ss.eni'
;-------------------------------------------------------------------------------
loc_9654:
		jmp	ModifySpriteAttr_2P 
J_Dynamic_Normal: 
		jmp	Dynamic_Normal 
;------------------------------------------------------------------------------- 

;===============================================================================
; Sub Routine Versus Mode Results
; [ Begin ]
;=============================================================================== 
Versus_Mode_Menu: 
		bsr.w	Pal_FadeFrom 
		move	#$2700,sr
		move.w	(VDP_Reg0_Val).w,d0
		and.b	#$BF,d0
		move.w	d0,(VDP_control_port)
		bsr.w	ClearScreen 
		lea	(VDP_control_port),a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$8230,(a6)
		move.w	#$8700,(a6)
		move.w	#$8C81,(a6)
		move.w	#$9001,(a6)
		move.l	#$FFFFDC00,($FFFFDCFC).w
		lea	($FFFFAC00).w,a1
		moveq	#0,d0
		move.w	#$FF,d1
loc_96AE: 
		move.l	d0,(a1)+
		dbra	d1,loc_96AE
		lea	(Object_RAM).w,a1
		moveq	#0,d0
		move.w	#$7FF,d1
loc_96BE: 
		move.l	d0,(a1)+
		dbra	d1,loc_96BE
		move.l	#$42000000,(VDP_control_port)
		lea	(Menu_Font),a0 
		bsr.w	NemesisDec 
		move.l	#$4C000000,(VDP_control_port)
		lea	(Menu_Frame),a0 
		bsr.w	NemesisDec 
		move.l	#$50000000,(VDP_control_port)
		lea	(Level_Icons),a0 
		bsr.w	NemesisDec 
		lea	(RAM_Start),a1
		lea	(Versus_Menu_Bg_Mappings),a0 
		move.w	#$6000,d0
		bsr.w	EnigmaDec 
		lea	(RAM_Start),a1
		move.l	#$60000003,d0
		moveq	#$27,d1
		moveq	#$1B,d2
		bsr.w	loc_9EB4
		lea	(RAM_Start),a1
		lea	(loc_9BD8),a0
		move.w	#$60,d0
		bsr.w	EnigmaDec 
		lea	($FFFF0198),a1
		lea	(loc_9BD8),a0
		move.w	#$2060,d0
		bsr.w	EnigmaDec 
		lea	($FFFF0330),a1
		lea	(loc_9E82),a0
		move.w	#$80,d0
		bsr.w	EnigmaDec
		lea	($FFFF0498),a2
		moveq	#$F,d1
loc_976C: 
		move.w	#$206B,(a2)+
		dbra	d1,loc_976C
		bsr.w	loc_98CA
		addq.b	#1,(Current_Zone_2P).w
		and.b	#3,(Current_Zone_2P).w
		bsr.w	loc_9968
		addq.b	#1,(Current_Zone_2P).w
		and.b	#3,(Current_Zone_2P).w
		bsr.w	loc_9968
		addq.b	#1,(Current_Zone_2P).w
		and.b	#3,(Current_Zone_2P).w
		bsr.w	loc_9968
		addq.b	#1,(Current_Zone_2P).w
		and.b	#3,(Current_Zone_2P).w
		clr.b	($FFFFFF89).w
		clr.w	($FFFFFF10).w
		clr.b	($FFFFF711).w
		clr.w	($FFFFF7F0).w
		lea	(Menu_Animate),a2 
		bsr.w	loc_9EBA
		moveq	#$26,d0
		bsr.w	PalLoad1 
		lea	(Normal_palette_line3).w,a1
		lea	(Second_palette_line3).w,a2
		moveq	#7,d1
loc_97D6: 
		move.l	(a1)+,(a2)+
		dbra	d1,loc_97D6
		move.b	#$91,d0
		bsr.w	Play_Music 
		move.w	#$707,(Demo_Time_left).w
		clr.w	($FFFFFFD8).w
		clr.l	($FFFFEE00).w
		clr.l	(Camera_Y_pos).w
		move.b	#$16,(Delay_Time).w
		bsr.w	DelayProgram 
		move.w	(VDP_Reg0_Val).w,d0
		or.b	#$40,d0
		move.w	d0,(VDP_control_port)
		bsr.w	Pal_FadeTo 
loc_9812: 
		move.b	#$16,(Delay_Time).w
		bsr.w	DelayProgram 
		move	#$2700,sr
		bsr.w	loc_9968
		bsr.w	loc_98A6
		bsr.w	loc_98CA
		move	#$2300,sr
		lea	(Menu_Animate),a2 
		bsr.w	loc_9EBA
		move.b	(Ctrl_1_Press).w,d0
		or.b	($FFFFF607).w,d0
		and.b	#$80,d0
		bne.s	loc_984C
		bra.w	loc_9812
loc_984C:
		bsr.w	loc_994A
		bmi.s	loc_985E
		move.w	#$ED,d0
		bsr.w	Play_Sfx
		bra.w	loc_9812
loc_985E:
		moveq	#0,d0
		move.b	(Current_Zone_2P).w,d0
		add.w	d0,d0
		move.w	loc_989E(pc,d0),d0
		bmi.s	loc_988A
		move.w	d0,($FFFFFE10).w
		move.w	#1,($FFFFFFD8).w
		move.b	#$C,(Game_Mode).w
		move.b	#0,($FFFFFE30).w
		move.b	#0,($FFFFFEE0).w
		rts
;--------------------------------------------------------------------------------
loc_988A:
		moveq	#0,d0
		move.b	d0,(Current_Special_Stage).w
		move.b	#$10,(Game_Mode).w
		move.w	#1,($FFFFFFD8).w
		rts
;--------------------------------------------------------------------------------
loc_989E:
		dc.w	$0,$B00,$C00,$FFFF
loc_98A6:
		move.b	(Ctrl_1_Press).w,d0
		or.b	($FFFFF607).w,d0
		move.b	d0,d1
		and.b	#3,d0
		beq.s	loc_98BC
		bchg	#1,(Current_Zone_2P).w
loc_98BC:
		and.b	#$C,d1
		beq.s	loc_98C8
		bchg	#0,(Current_Zone_2P).w
loc_98C8:
		rts
;--------------------------------------------------------------------------------
loc_98CA:
		moveq	#0,d0
		move.b	(Current_Zone_2P).w,d0
		lsl.w	#4,d0
		lea	(loc_99CA),a3
		lea	0(a3,d0),a3
		move.w	#$6000,d0
		lea	($FFFF0048),a2
		move.l	(a3)+,a1
		bsr.w	loc_9A0A
		lea	($FFFF0094),a2
		move.l	(a3)+,a1
		bsr.w	loc_9A0A
		lea	($FFFF00D8),a2
		move.l	4(a3),a1
		bsr.w	loc_994A
		bmi.s	loc_990E
		lea	($FFFF0468),a1
loc_990E:
		moveq	#2,d1
loc_9910: 
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		lea	$1A(a2),a2
		dbra	d1,loc_9910
		lea	(RAM_Start),a1
		move.l	(a3)+,d0
		moveq	#$10,d1
		moveq	#$B,d2
		bsr.w	loc_9EB4
		lea	(Pal_Levels_Icons),a1 
		moveq	#0,d0
		move.b	(a3),d0
		lsl.w	#5,d0
		lea	0(a1,d0),a1
		lea	(Normal_palette_line3).w,a2
		moveq	#7,d1
loc_9942: 
		move.l	(a1)+,(a2)+
		dbra	d1,loc_9942
		rts
;--------------------------------------------------------------------------------
loc_994A:
		moveq	#0,d0
		move.b	(Current_Zone_2P).w,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		add.w	d0,d0
		lea	(Results_Data_2P).w,a5
		lea	0(a5,d0),a5
		move.w	(a5),d0
		add.w	2(a5),d0
		rts
;--------------------------------------------------------------------------------
loc_9968:
		moveq	#0,d0
		move.b	(Current_Zone_2P).w,d0
		lsl.w	#4,d0
		lea	(loc_99CA),a3
		lea	0(a3,d0),a3
		moveq	#0,d0
		lea	($FFFF01E0),a2
		move.l	(a3)+,a1
		bsr.w	loc_9A0A
		lea	($FFFF022C),a2
		move.l	(a3)+,a1
		bsr.w	loc_9A0A
		lea	($FFFF0270),a2
		lea	($FFFF0498),a1
		bsr.w	loc_994A
		bmi.s	loc_99AC
		lea	($FFFF0468),a1
loc_99AC:
		moveq	#2,d1
loc_99AE: 
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		lea	$1A(a2),a2
		dbra	d1,loc_99AE
		lea	($FFFF0198),a1
		move.l	(a3)+,d0
		moveq	#$10,d1
		moveq	#$B,d2
		bra.w	loc_9EB4 
;-------------------------------------------------------------------------------
loc_99CA: 
		dc.l	Map_Emerald_Hill 
		dc.l	Map_Zone 
		dc.w	$4104,$3,$FF,$330
		dc.l	Map_Mystic_Cave 
		dc.l	Map_Zone 
		dc.w	$412C,$3,$5FF,$3A8
		dc.l	Map_Casino_Night 
		dc.l	Map_Zone 
		dc.w	$4784,$3,$6FF,$3C0
		dc.l	Map_Special 
		dc.l	Map_Stage 
		dc.w	$47AC,$3,$CFF,$450
;-------------------------------------------------------------------------------
loc_9A0A:
		moveq	#0,d1
		move.b	(a1)+,d1
loc_9A0E: 
		move.b	(a1)+,d0
		move.w	d0,(a2)+
		dbra	d1,loc_9A0E
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Pal_Levels_Icons: 
		incbin 'palettes/lvsicons.pal'
;===============================================================================
; Sub Routine Versus Mode Results
; [ Begin ]
;=============================================================================== 
loc_9BD8:
		incbin 'mapeni/vs_menu.eni'
loc_9E82:
		incbin 'mapeni/vsmenu2.eni'
loc_9EB4:
		jmp	ShowVDPGraphics 
loc_9EBA:
		jmp	Dynamic_Normal 
;===============================================================================
; Sub Routine Level_Size_Load
; [ Begin ]
;=============================================================================== 
Level_Size_Load: 
		clr.w	($FFFFEE50).w
		clr.w	($FFFFEE52).w
		clr.w	($FFFFEE54).w
		clr.w	($FFFFEE56).w
		clr.w	($FFFFEE58).w
		clr.w	($FFFFEE5A).w
		clr.w	($FFFFEE5C).w
		clr.w	($FFFFEE5E).w
		clr.w	($FFFFEEA0).w
		clr.w	($FFFFEEA2).w
		clr.w	($FFFFEEA4).w
		clr.w	($FFFFEEA6).w
		clr.w	($FFFFEEA8).w
		clr.w	($FFFFEEAA).w
		clr.w	($FFFFEEAC).w
		clr.w	($FFFFEEAE).w
		clr.b	($FFFFEEDC).w
		clr.b	($FFFFEEBC).w
		clr.b	($FFFFEEBD).w
		moveq	#0,d0
		move.b	d0,($FFFFEEDF).w
		move.w	($FFFFFE10).w,d0
		ror.b	#1,d0
		lsr.w	#4,d0
		lea	Level_Size_Array(pc,d0),a0 
		move.l	(a0)+,d0
		move.l	d0,(Camera_Min_X_pos).w
		move.l	d0,($FFFFEEC0).w
		move.l	d0,($FFFFEEF8).w
		move.l	(a0)+,d0
		move.l	d0,(Camera_Min_Y_pos).w
		move.l	d0,($FFFFEEC4).w
		move.l	d0,($FFFFEEFC).w
		move.w	#$1010,($FFFFEE40).w
		move.w	#$60,($FFFFEED8).w
		move.w	#$60,($FFFFEEDA).w
		bra.w	Level_Size_Check_Lamp_Post 
Level_Size_Array:
		dc.l	$29A0,$320,$2940,$420 ; GHz
		dc.l	$3FFF,$720,$3FFF,$720 ;
		dc.l	$3FFF,$720,$3FFF,$720 ; Wz
		dc.l	$3FFF,$720,$3FFF,$720 ; 
		dc.l	$2280,$FF000800,$1E80,$FF000800 ; Mz
		dc.l	$2A80,$FF000800,$3FFF,$FF000800 ; Mz
		dc.l	$3FFF,$720,$3FFF,$720 ; SFz
		dc.l	$2800,$720,$3280,$720 ; HTz
		dc.l	$3FFF,$720,$3FFF,$720 ; HPz
		dc.l	$3FFF,$720,$3FFF,$720 ; 
		dc.l	$2F80,$680,$2D00,$680 ; OOz
		dc.l	$2380,$3C00720,$3FFF,$600720 ; DHz
		dc.l	$27A0,$720,$2A80,$720 ; CNz
		dc.l	$2780,$720,$2A80,$720 ; CPz
		dc.l	$1000,$C800C8,$1000,$C800C8 ; DEz
		dc.l	$28C0,$2000600,$3FFF,$1800780 ; NGHz
		dc.l	$3FFF,$0,$3FFF,$720 ; SCz 
Level_Size_Check_Lamp_Post: 
		tst.b	($FFFFFE30).w
		beq.s	Level_Size_Start_Loc 
		jsr	Star_Post_Load_Info 
		move.w	($FFFFB008).w,d1
		move.w	(Object_RAM+y_pos).w,d0
		bra.s	Level_Size_Start_Loc_Loaded 
Level_Size_Start_Loc: 
		move.w	($FFFFFE10).w,d0
		ror.b	#1,d0
		lsr.w	#5,d0
		lea	Player_Start_Position_Array(pc,d0),a1 
		moveq	#0,d1
		move.w	(a1)+,d1
		move.w	d1,($FFFFB008).w
		moveq	#0,d0
		move.w	(a1),d0
		move.w	d0,(Object_RAM+y_pos).w
Level_Size_Start_Loc_Loaded: 
		sub.w	#$A0,d1
		bcc.s	loc_A09A
		moveq	#0,d1
loc_A09A:
		move.w	(Camera_Max_X_pos).w,d2
		cmp.w	d2,d1
		bcs.s	loc_A0A4
		move.w	d2,d1
loc_A0A4:
		move.w	d1,($FFFFEE00).w
		move.w	d1,($FFFFEE20).w
		sub.w	#$60,d0
		bcc.s	loc_A0B4
		moveq	#0,d0
loc_A0B4:
		cmp.w	(Camera_Max_Y_pos_now).w,d0
		blt.s	loc_A0BE
		move.w	(Camera_Max_Y_pos_now).w,d0
loc_A0BE:
		move.w	d0,(Camera_Y_pos).w
		move.w	d0,($FFFFEE24).w
		bsr.w	Background_Scroll_Speed 
		rts
;--------------------------------------------------------------------------------
Player_Start_Position_Array: 
		dc.l	$60028F,$6002AF ; GHz
		dc.l	$60028F,$6002AF ; 
		dc.l	$6001AC,$6001AC ; Wz
		dc.l	$60028F,$6002AF ;
		dc.l	$60028C,$6005EC ; Mz
		dc.l	$60020C,$6002AF ; Mz
		dc.l	$6004CC,$1E004CC ; SFz
		dc.l	$6003EF,$6006AF ; HTz
		dc.l	$23001AC,$23001AC ; HPz
		dc.l	$60028F,$6002AF ;
		dc.l	$6006AC,$60056C ; OOz
		dc.l	$6006AC,$6005AC ; DHz
		dc.l	$6002AC,$60058C ; CNz
		dc.l	$6001EC,$60012C ; CPz
		dc.l	$60012D,$60012D ; DEz
		dc.l	$60037E,$60037E ; NGHz
		dc.l	$1200070,$1400070 ; SCz 
Background_Scroll_Speed: 
		tst.b	($FFFFFE30).w
		bne.s	loc_A182
		move.w	d0,($FFFFEE0C).w
		move.w	d0,($FFFFEE14).w
		move.w	d1,($FFFFEE08).w
		move.w	d1,($FFFFEE10).w
		move.w	d1,($FFFFEE18).w
		move.w	d0,($FFFFEE2C).w
		move.w	d0,($FFFFEE34).w
		move.w	d1,($FFFFEE28).w
		move.w	d1,($FFFFEE30).w
		move.w	d1,($FFFFEE38).w
loc_A182:
		moveq	#0,d2
		move.b	($FFFFFE10).w,d2
		add.w	d2,d2
		move.w	Bg_Scroll_Speed_Index(pc,d2),d2 
		jmp	Bg_Scroll_Speed_Index(pc,d2) 
Bg_Scroll_Speed_Index: 
		dc.w	Bg_Scroll_Speed_GHz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_Null-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_Wz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_Null-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_Mz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_Mz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_SFz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_HTz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_HPz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_Null2-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_OOz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_DHz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_CNz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_CPz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_DEz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_NGHz-Bg_Scroll_Speed_Index 
		dc.w	Bg_Scroll_Speed_SCz-Bg_Scroll_Speed_Index 
;------------------------------------------------------------------------------- 
Bg_Scroll_Speed_GHz: 
		clr.l	($FFFFEE08).w
		clr.l	($FFFFEE0C).w
		clr.l	($FFFFEE14).w
		clr.l	($FFFFEE1C).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	($FFFFEE28).w
		clr.l	($FFFFEE2C).w
		clr.l	($FFFFEE34).w
		clr.l	($FFFFEE3C).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Bg_Scroll_Speed_Null: 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Bg_Scroll_Speed_Wz: 
		asr.w	#2,d0
		add.w	#$400,d0
		move.w	d0,($FFFFEE0C).w
		asr.w	#3,d1
		move.w	d1,($FFFFEE08).w
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_Speed_Mz: 
		asr.w	#2,d0
		move.w	d0,($FFFFEE0C).w
		asr.w	#3,d1
		move.w	d1,($FFFFEE08).w
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_Speed_SFz: 
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_Speed_HTz: 
		clr.l	($FFFFEE08).w
		clr.l	($FFFFEE0C).w
		clr.l	($FFFFEE14).w
		clr.l	($FFFFEE1C).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	($FFFFEE28).w
		clr.l	($FFFFEE2C).w
		clr.l	($FFFFEE34).w
		clr.l	($FFFFEE3C).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Bg_Scroll_Speed_HPz: 
		asr.w	#1,d0
		move.w	d0,($FFFFEE0C).w
		clr.l	($FFFFEE08).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 

		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0
		addq.w	#1,d0
		move.w	d0,($FFFFEE0C).w
		clr.l	($FFFFEE08).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Bg_Scroll_Speed_Null2: 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Bg_Scroll_Speed_OOz: 
		lsr.w	#3,d0
		add.w	#$50,d0
		move.w	d0,($FFFFEE0C).w
		clr.l	($FFFFEE08).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Bg_Scroll_Unused: 
		asl.l	#4,d0
		move.l	d0,d2
		asl.l	#1,d0
		add.l	d2,d0
		asr.l	#8,d0
		addq.w	#1,d0
		move.w	d0,($FFFFEE0C).w
		clr.l	($FFFFEE08).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Bg_Scroll_Unused2: 
		asr.w	#3,d0
		move.w	d0,($FFFFEE0C).w
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_Speed_DHz: 
		clr.l	($FFFFEE08).w
		clr.l	($FFFFEE28).w
		tst.b	($FFFFFE11).w
		bne.s	loc_A2A2
		divu.w	#3,d0
		sub.w	#$140,d0
		move.w	d0,($FFFFEE0C).w
		move.w	d0,($FFFFEE2C).w
		rts
;--------------------------------------------------------------------------------
loc_A2A2:
		divu.w	#6,d0
		sub.w	#$10,d0
		move.w	d0,($FFFFEE0C).w
		move.w	d0,($FFFFEE2C).w
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_Speed_CNz: 
		clr.l	($FFFFEE08).w
		clr.l	($FFFFEE0C).w
		clr.l	($FFFFEE2C).w
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_Speed_CPz: 
		lsr.w	#2,d0
		move.w	d0,($FFFFEE0C).w
		move.w	d0,($FFFFEE2C).w
		clr.l	($FFFFEE08).w
		clr.l	($FFFFEE10).w
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_Speed_DEz: 
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_Speed_NGHz: 
		tst.b	($FFFFFE11).w
		beq.s	loc_A2EA
		sub.w	#$E0,d0
		lsr.w	#1,d0
		move.w	d0,($FFFFEE0C).w
		bra.s	loc_A2F2
loc_A2EA:
		sub.w	#$180,d0
		move.w	d0,($FFFFEE0C).w
loc_A2F2:
		clr.l	($FFFFEE08).w
		clr.l	($FFFFEE14).w
		clr.l	($FFFFEE1C).w
		lea	($FFFFA800).w,a2
		clr.l	(a2)+
		clr.l	(a2)+
		clr.l	(a2)+
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Bg_Scroll_Speed_SCz: 
		clr.l	($FFFFEE08).w
		clr.l	($FFFFEE0C).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Level_Size_Load
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine Background Scroll 
; [ Begin ]
;=============================================================================== 
Background_Scroll_Layer: 
		tst.b	($FFFFEEDC).w
		beq.s	loc_A31C
		rts
;--------------------------------------------------------------------------------
loc_A31C:
		clr.w	($FFFFEE50).w
		clr.w	($FFFFEE52).w
		clr.w	($FFFFEE54).w
		clr.w	($FFFFEE56).w
		clr.w	($FFFFEE58).w
		clr.w	($FFFFEE5A).w
		clr.w	($FFFFEE5C).w
		clr.w	($FFFFEE5E).w
		cmp.b	#$10,($FFFFFE10).w
		bne.w	loc_A34E
		tst.w	(Debug_placement_mode).w
		beq	loc_A3D4
loc_A34E:
		lea	(Object_RAM).w,a0
		lea	($FFFFEE00).w,a1
		lea	(Camera_Min_X_pos).w,a2
		lea	($FFFFEE50).w,a3
		lea	($FFFFEEB0).w,a4
		lea	($FFFFEED0).w,a5
		lea	($FFFFE500).w,a6
		bsr.w	Scroll_Horizontal 
		lea	($FFFFEE40).w,a2
		bsr.w	Scroll_Horizontal_2 
		lea	(Camera_Y_pos).w,a1
		lea	(Camera_Min_X_pos).w,a2
		lea	($FFFFEEB2).w,a4
		bsr.w	Scroll_Vertical 
		lea	($FFFFEE41).w,a2
		bsr.w	Scroll_Vertical_2 
		tst.w	($FFFFFFD8).w
		beq.s	loc_A3D4
		lea	($FFFFB040).w,a0
		lea	($FFFFEE20).w,a1
		lea	($FFFFEEF8).w,a2
		lea	($FFFFEE58).w,a3
		lea	($FFFFEEB8).w,a4
		lea	($FFFFEED4).w,a5
		lea	($FFFFE600).w,a6
		bsr.w	Scroll_Horizontal 
		lea	($FFFFEE48).w,a2
		bsr.w	Scroll_Horizontal_2 
		lea	($FFFFEE24).w,a1
		lea	($FFFFEEF8).w,a2
		lea	($FFFFEEBA).w,a4
		bsr.w	Scroll_Vertical 
		lea	($FFFFEE49).w,a2
		bsr.w	Scroll_Vertical_2 
loc_A3D4:
		bsr.w	Dyn_Screen_Boss_Loader 
		move.w	(Camera_Y_pos).w,($FFFFF616).w
		move.w	($FFFFEE0C).w,($FFFFF618).w
		move.l	($FFFFEE00).w,($FFFFEEF0).w
		move.l	(Camera_Y_pos).w,($FFFFEEF4).w	
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		move.w	Bg_Scroll_Index(pc,d0),d0 
		jmp	Bg_Scroll_Index(pc,d0) 
Bg_Scroll_Index: 
		dc.w	Bg_Scroll_GHz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_Null-Bg_Scroll_Index 
		dc.w	Bg_Scroll_Wz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_Null-Bg_Scroll_Index 
		dc.w	Bg_Scroll_Mz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_Mz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_SFz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_HTz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_HPz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_Null-Bg_Scroll_Index 
		dc.w	Bg_Scroll_OOz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_DHz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_CNz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_CPz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_DEz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_NGHz-Bg_Scroll_Index 
		dc.w	Bg_Scroll_SCz-Bg_Scroll_Index 
Bg_Scroll_Title_Screen 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		move.w	($FFFFEE00).w,d0
		cmp.w	#$1C00,d0
		bcc.s	loc_A434
		addq.w	#8,d0
loc_A434:
		move.w	d0,($FFFFEE00).w
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE00).w,d2
		neg.w	d2
		moveq	#0,d0
		bra.s	loc_A462 
;===============================================================================
; Sub Routine Green Hill Background Scroll 
; [ Begin ]
;=============================================================================== 
Bg_Scroll_GHz: 
		tst.w	($FFFFFFD8).w
		bne.w	Bg_Scroll_GHz_2p 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		move.w	d0,d2
		swap.w	d0
loc_A462:
		move.w	#0,d0
		move.w	#$15,d1
loc_A46A: 
		move.l	d0,(a1)+
		dbra	d1,loc_A46A
		move.w	d2,d0
		asr.w	#6,d0
		move.w	#$39,d1
loc_A478: 
		move.l	d0,(a1)+
		dbra	d1,loc_A478
		move.w	d0,d3
		move.b	($FFFFFE0F).w,d1
		and.w	#7,d1
		bne.s	loc_A48E
		subq.w	#1,($FFFFA800).w
loc_A48E:
		move.w	($FFFFA800).w,d1
		and.w	#$1F,d1
		lea	(Bg_Scroll_Data),a2 
		lea	0(a2,d1),a2
		move.w	#$14,d1
loc_A4A4: 
		move.b	(a2)+,d0
		ext.w	d0
		add.w	d3,d0
		move.l	d0,(a1)+
		dbra	d1,loc_A4A4
		move.w	#0,d0
		move.w	#$A,d1
loc_A4B8: 
		move.l	d0,(a1)+
		dbra	d1,loc_A4B8
		move.w	d2,d0
		asr.w	#4,d0
		move.w	#$F,d1
loc_A4C6: 
		move.l	d0,(a1)+
		dbra	d1,loc_A4C6
		move.w	d2,d0
		asr.w	#4,d0
		move.w	d0,d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	#$F,d1
loc_A4DA: 
		move.l	d0,(a1)+
		dbra	d1,loc_A4DA
		move.l	d0,d4
		swap.w	d4
		move.w	d2,d0
		asr.w	#1,d0
		move.w	d2,d1
		asr.w	#3,d1
		sub.w	d1,d0
		ext.l	d0
		asl.l	#8,d0
		divs.w	#$30,d0
		ext.l	d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#3,d3
		move.w	#$E,d1
loc_A504: 
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		dbra	d1,loc_A504
		move.w	#8,d1
loc_A516: 
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		swap.w	d3
		add.l	d0,d3
		add.l	d0,d3
		swap.w	d3
		dbra	d1,loc_A516
		move.w	#$E,d1
loc_A52E: 
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		move.w	d4,(a1)+
		move.w	d3,(a1)+
		swap.w	d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		swap.w	d3
		dbra	d1,loc_A52E
		rts
;--------------------------------------------------------------------------------
Bg_Scroll_Data: 
		dc.b	$1,$2,$1,$3,$1,$2,$2,$1,$2,$3,$1,$2,$1,$2,$0,$0
		dc.b	$2,$0,$3,$2,$2,$3,$2,$2,$1,$3,$0,$0,$1,$0,$1,$3
		dc.b	$1,$2,$1,$3,$1,$2,$2,$1,$2,$3,$1,$2,$1,$2,$0,$0
		dc.b	$2,$0,$3,$2,$2,$3,$2,$2,$1,$3,$0,$0,$1,$0,$1,$3
		dc.b	$1,$2 
Bg_Scroll_GHz_2p: 
		move.b	($FFFFFE0F).w,d1
		and.w	#7,d1
		bne.s	loc_A59A
		subq.w	#1,($FFFFA800).w
loc_A59A:
		move.w	($FFFFEE0C).w,($FFFFF618).w
		and.l	#$FFFEFFFE,($FFFFF616).w
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE00).w,d0
		move.w	#$A,d1
		bsr.s	loc_A5E2
		moveq	#0,d0
		move.w	d0,($FFFFF620).w
		sub.w	#$E0,($FFFFF620).w
		move.w	($FFFFEE24).w,($FFFFF61E).w
		sub.w	#$E0,($FFFFF61E).w
		and.l	#$FFFEFFFE,($FFFFF61E).w
		lea	($FFFFE1B0).w,a1
		move.w	($FFFFEE20).w,d0
		move.w	#$E,d1
loc_A5E2:
		neg.w	d0
		move.w	d0,d2
		swap.w	d0
		move.w	#0,d0
loc_A5EC: 
		move.l	d0,(a1)+
		dbra	d1,loc_A5EC
		move.w	d2,d0
		asr.w	#6,d0
		move.w	#$1C,d1
loc_A5FA: 
		move.l	d0,(a1)+
		dbra	d1,loc_A5FA
		move.w	d0,d3
		move.w	($FFFFA800).w,d1
		and.w	#$1F,d1
		lea	Bg_Scroll_Data(pc),a2 
		lea	0(a2,d1),a2
		move.w	#$A,d1
loc_A616: 
		move.b	(a2)+,d0
		ext.w	d0
		add.w	d3,d0 
		move.l	d0,(a1)+
		dbra	d1,loc_A616
		move.w	#0,d0
		move.w	#4,d1
loc_A62A: 
		move.l	d0,(a1)+
		dbra	d1,loc_A62A
		move.w	d2,d0
		asr.w	#4,d0
		move.w	#7,d1
loc_A638:
		move.l	d0,(a1)+
		dbra	d1,loc_A638
		move.w	d2,d0
		asr.w	#4,d0
		move.w	d0,d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	#7,d1
loc_A64C: 
		move.l	d0,(a1)+
		dbra	d1,loc_A64C
		move.w	d2,d0
		asr.w	#1,d0
		move.w	d2,d1
		asr.w	#3,d1
		sub.w	d1,d0
		ext.l	d0
		asl.l	#8,d0
		divs.w	#$30,d0
		ext.l	d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#3,d3
		move.w	#$27,d1
loc_A672: 
		move.w	d2,(a1)+
		move.w	d3,(a1)+
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		dbra	d1,loc_A672
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Green Hill Background Scroll 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Wood Background Scroll 
; [ Begin ]
;===============================================================================
Bg_Scroll_Wz: 
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.w	($FFFFEEB2).w,d5
		ext.l	d5
		asl.l	#6,d5
		bsr.w	Scroll_Block_1 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		lea	($FFFFE000).w,a1
		move.w	#$DF,d1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	($FFFFEE08).w,d0
		neg.w	d0
loc_A6B2: 
		move.l	d0,(a1)+
		dbra	d1,loc_A6B2
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Wood Background Scroll 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Metropolis Background Scroll 
; [ Begin ]
;=============================================================================== 
Bg_Scroll_Mz: 
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.w	($FFFFEEB2).w,d5
		ext.l	d5
		asl.l	#6,d5
		bsr.w	Scroll_Block_1 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		lea	($FFFFE000).w,a1
		move.w	#$DF,d1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	($FFFFEE08).w,d0
		neg.w	d0
loc_A6EA: 
		move.l	d0,(a1)+
		dbra	d1,loc_A6EA
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Metropolis Background Scroll 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Metropolis Background Scroll 
; [ Begin ]
;=============================================================================== 
Bg_Scroll_SFz: 
		move.w	($FFFFEEB4).w,d4
		ext.l	d4
		asl.l	#8,d4
		moveq	#2,d6
		bsr.w	Scroll_Block_2 
		move.w	($FFFFEEB6).w,d5
		ext.l	d5
		lsl.l	#8,d5
		moveq	#6,d6
		bsr.w	Scroll_Block_3 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		move.l	($FFFFEE08).w,d0
		move.l	d0,d1
		lea	($FFFFA800).w,a2
		move.l	d0,(a2)+
		move.l	d1,(a2)+
		add.l	#$8000,(a2)+
		add.l	#$4000,(a2)+
		add.l	#$2000,(a2)+
		lea	(loc_A784),a3
		lea	($FFFFA800).w,a2
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE0C).w,d1
		and.w	#$7FF,d1
		moveq	#0,d0
		moveq	#0,d3
loc_A74E: 
		move.b	(a3)+,d0
		addq.w	#1,a3
		sub.w	d0,d1
		bcc.s	loc_A74E
		neg.w	d1
		move.w	#$DF,d2
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.b	$FFFFFFFF(a3),d3
		move.w	0(a2,d3),d0
		neg.w	d0
loc_A76E: 
		move.l	d0,(a1)+
		subq.w	#1,d1
		bne.s	loc_A77E
		move.b	(a3)+,d1
		move.b	(a3)+,d3
		move.w	0(a2,d3),d0
		neg.w	d0
loc_A77E:
		dbra	d2,loc_A76E
		rts
;--------------------------------------------------------------------------------
loc_A784:
		dc.w	$C000,$C000,$8000,$2008,$300C,$3010,$2008,$300C
		dc.w	$3010,$2008,$300C,$3010,$2008,$300C,$3010,$2008
		dc.w	$300C,$3010,$2008,$300C,$3010,$2008,$300C,$3010
		dc.w	$8004,$8004,$2008,$300C,$3010,$2008,$300C,$3010
		dc.w	$2008,$300C,$3010,$C000,$C000,$8000 
;===============================================================================
; Sub Routine Metropolis Background Scroll 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Hill Top Background Scroll 
; [ Begin ]
;=============================================================================== 
Bg_Scroll_HTz: 
		tst.w	($FFFFFFD8).w
		bne.w	loc_A97C
		tst.b	($FFFFEEBC).w
		bne.w	loc_A8FE
		move.w	($FFFFEE0C).w,($FFFFF618).w
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		move.w	d0,d2
		swap.w	d0
		move.w	d2,d0
		asr.w	#3,d0
		move.w	#$7F,d1
loc_A7FC: 
		move.l	d0,(a1)+
		dbra	d1,loc_A7FC
		move.l	d0,d4
		move.w	($FFFFA822).w,d0
		addq.w	#4,($FFFFA822).w
		sub.w	d0,d2
		move.w	d2,d0
		move.w	d0,d1
		asr.w	#1,d0
		asr.w	#4,d1
		sub.w	d1,d0
		ext.l	d0
		asl.l	#8,d0
		divs.w	#$70,d0
		ext.l	d0
		asl.l	#8,d0
		lea	($FFFFA800).w,a2
		moveq	#0,d3
		move.w	d1,d3
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,(a2)+
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,(a2)+
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,(a2)+
		move.w	d3,(a2)+
		swap.w	d3
		add.l	d0,d3
		add.l	d0,d3
		swap.w	d3 
		moveq	#3,d1
loc_A850: 
		move.w	d3,(a2)+
		move.w	d3,(a2)+
		move.w	d3,(a2)+
		swap.w	d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		swap.w	d3
		dbra	d1,loc_A850
		add.l	d0,d0
		add.l	d0,d0
		move.w	d3,d4
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,d4
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		move.l	d4,(a1)+
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,d4
		move.w	#6,d1
loc_A88E: 
		move.l	d4,(a1)+
		dbra	d1,loc_A88E
		swap.w	d3
		add.l	d0,d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,d4
		move.w	#7,d1
loc_A8A2: 
		move.l	d4,(a1)+
		dbra	d1,loc_A8A2
		swap.w	d3
		add.l	d0,d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,d4
		move.w	#9,d1
loc_A8B6: 
		move.l	d4,(a1)+
		dbra	d1,loc_A8B6
		swap.w	d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,d4
		move.w	#$E,d1
loc_A8CC: 
		move.l	d4,(a1)+
		dbra	d1,loc_A8CC
		swap.w	d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		swap.w	d3
		move.w	#2,d2
loc_A8E0: 
		move.w	d3,d4
		move.w	#$F,d1
loc_A8E6: 
		move.l	d4,(a1)+
		dbra	d1,loc_A8E6
		swap.w	d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		add.l	d0,d3
		swap.w	d3
		dbra	d2,loc_A8E0
		rts
;--------------------------------------------------------------------------------
loc_A8FE:
		move.w	($FFFFEEB4).w,d4
		ext.l	d4
		lsl.l	#8,d4
		moveq	#2,d6
		bsr.w	Scroll_Block_2 
		move.w	($FFFFEEB6).w,d5
		ext.l	d5
		lsl.l	#8,d5
		moveq	#0,d6
		bsr.w	Scroll_Block_3 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		move.w	(Camera_Y_pos).w,($FFFFF616).w
		move.w	($FFFFEE0C).w,($FFFFF618).w
		moveq	#0,d2
		tst.b	($FFFFEEBD).w
		beq.s	loc_A95A
		move.w	($FFFFFE04).w,d0
		and.w	#$3F,d0
		lea	Bg_Scroll_Data(pc),a1 
		lea	0(a1,d0),a1
		moveq	#0,d0
		move.b	(a1)+,d0
		add.w	d0,($FFFFF616).w
		add.w	d0,($FFFFF618).w
		add.w	d0,($FFFFEEF4).w
		move.b	(a1)+,d2
		add.w	d2,($FFFFEEF0).w
loc_A95A:
		lea	($FFFFE000).w,a1
		move.w	#$DF,d1
		move.w	($FFFFEE00).w,d0
		add.w	d2,d0
		neg.w	d0
		swap.w	d0
		move.w	($FFFFEE08).w,d0
		add.w	d2,d0
		neg.w	d0
loc_A974: 
		move.l	d0,(a1)+
		dbra	d1,loc_A974
		rts
;--------------------------------------------------------------------------------
loc_A97C:
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		asl.l	#6,d4
		move.w	($FFFFEEB2).w,d5
		ext.l	d5
		asl.l	#2,d5
		moveq	#0,d5
		bsr.w	Scroll_Block_1 
		move.b	#0,($FFFFEE52).w
		move.w	($FFFFEE0C).w,($FFFFF618).w
		and.l	#$FFFEFFFE,($FFFFF616).w
		lea	($FFFFE000).w,a1
		move.w	#$6F,d1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	($FFFFEE08).w,d0
		neg.w	d0
loc_A9BC: 
		move.l	d0,(a1)+
		dbra	d1,loc_A9BC
		move.w	($FFFFEEB8).w,d4
		ext.l	d4
		asl.l	#6,d4
		add.l	d4,($FFFFEE28).w
		moveq	#0,d0
		move.w	d0,($FFFFF620).w
		sub.w	#$E0,($FFFFF620).w
		move.w	($FFFFEE24).w,($FFFFF61E).w
		sub.w	#$E0,($FFFFF61E).w
		and.l	#$FFFEFFFE,($FFFFF61E).w
		lea	($FFFFE1B0).w,a1
		move.w	#$73,d1
		move.w	($FFFFEE20).w,d0
		neg.w	d0
		swap.w	d0
		move.w	($FFFFEE28).w,d0
		neg.w	d0
 loc_AA04: 
		move.l	d0,(a1)+
		dbra	d1,loc_AA04
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Hill Top Background Scroll 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Hidden Palace Background Scroll 
; [ Begin ]
;=============================================================================== 
Bg_Scroll_HPz: 
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		asl.l	#6,d4
		moveq	#2,d6
		bsr.w	Scroll_Block_2 
		move.w	($FFFFEEB2).w,d5
		ext.l	d5
		asl.l	#7,d5
		moveq	#6,d6
		bsr.w	Scroll_Block_3 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		lea	($FFFFA800).w,a1
		move.w	($FFFFEE00).w,d2
		neg.w	d2
		move.w	d2,d0
		asr.w	#1,d0
		move.w	#7,d1
loc_AA40: 
		move.w	d0,(a1)+
		dbra	d1,loc_AA40
		move.w	d2,d0
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#3,d0
		divs.w	#8,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		asr.w	#1,d3
		lea	($FFFFA860).w,a2
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,(a1)+
		move.w	d3,(a1)+
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		move.w	d3,-(a2)
		move.w	d3,-(a2)
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,(a1)+
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		move.w	d3,-(a2)
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		move.w	d3,(a1)+
		move.w	d3,-(a2)
		move.w	($FFFFEE08).w,d0
		neg.w	d0
		move.w	#$19,d1
loc_AAA2: 
		move.w	d0,(a1)+
		dbra	d1,loc_AAA2
		add.w	#$E,a1
		move.w	d2,d0
		asr.w	#1,d0
		move.w	#$17,d1
loc_AAB4: 
		move.w	d0,(a1)+
		dbra	d1,loc_AAB4
		lea	($FFFFA800).w,a2
		move.w	($FFFFEE0C).w,d0
		move.w	d0,d2
		and.w	#$3F0,d0
		lsr.w	#3,d0
		lea	0(a2,d0),a2
		bra.w	loc_B47C
;===============================================================================
; Sub Routine Hidden Palace Background Scroll 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Oil Ocean Background Scroll 
; [ Begin ]
;=============================================================================== 
Bg_Scroll_OOz: 
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.w	($FFFFEEB2).w,d5
		ext.l	d5
		asl.l	#5,d5
		bsr.w	Scroll_Block_1 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		lea	($FFFFE000).w,a1
		move.w	#$DF,d1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	($FFFFEE08).w,d0
		neg.w	d0
loc_AB02: 
		move.l	d0,(a1)+
		dbra	d1,loc_AB02
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Oil Ocean Background Scroll 
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Dust Hill Background Scroll 
; [ Begin ]
;===============================================================================
Bg_Scroll_DHz: 
		tst.w	($FFFFFFD8).w
		bne.w	loc_AC62
		move.w	(Camera_Y_pos).w,d0
		move.l	($FFFFEE0C).w,d3
		tst.b	($FFFFFE11).w
		bne.s	loc_AB2A
		divu.w	#3,d0
		sub.w	#$140,d0
		bra.s	loc_AB32
loc_AB2A:
		divu.w	#6,d0
		sub.w	#$10,d0
loc_AB32:
		swap.w	d0
		moveq	#6,d6
		bsr.w	Scroll_Block_3_D0 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		moveq	#0,d2
		tst.b	($FFFFEEBD).w
		beq.s	loc_AB6E
		move.w	($FFFFFE04).w,d0
		and.w	#$3F,d0
		lea	Bg_Scroll_Data(pc),a1 
		lea	0(a1,d0),a1
		moveq	#0,d0
		move.b	(a1)+,d0
		add.w	d0,($FFFFF616).w
		add.w	d0,($FFFFF618).w
		add.w	d0,($FFFFEEF4).w
		move.b	(a1)+,d2
		add.w	d2,($FFFFEEF0).w
loc_AB6E:
		lea	($FFFFA800).w,a2
		lea	$1E(a2),a3
		move.w	($FFFFEE00).w,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$A,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		move.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,$E(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,$C(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,$A(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,8(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,6(a2)
		move.w	d1,$10(a2)
		move.w	d1,$1C(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,4(a2)
		move.w	d1,$12(a2)
		move.w	d1,$1A(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,2(a2)
		move.w	d1,$14(a2)
		move.w	d1,$18(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,(a2)
		move.w	d1,$16(a2)
		lea	(DHz_Bg_Scroll_Data),a3 
		lea	($FFFFA800).w,a2
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE0C).w,d1
		moveq	#0,d0
loc_AC1C: 
		move.b	(a3)+,d0
		addq.w	#2,a2
		sub.w	d0,d1
		bcc.s	loc_AC1C
		neg.w	d1
		subq.w	#2,a2
		move.w	#$DF,d2
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	(a2)+,d0
		neg.w	d0
loc_AC38: 
		move.l	d0,(a1)+
		subq.w	#1,d1
		bne.s	loc_AC44
		move.b	(a3)+,d1
		move.w	(a2)+,d0
		neg.w	d0
loc_AC44:
		dbra	d2,loc_AC38
		rts
;--------------------------------------------------------------------------------
DHz_Bg_Scroll_Data: 
		dc.b	$25,$17,$12,$7,$7,$2,$2,$30,$D,$13,$20,$40,$20,$13,$D,$30
		dc.b	$2,$2,$7,$7,$20,$12,$17,$25
loc_AC62:
		moveq	#0,d0
		move.w	(Camera_Y_pos).w,d0
		tst.b	($FFFFFE11).w
		bne.s	loc_AC78
		divu.w	#3,d0
		sub.w	#$140,d0
		bra.s	loc_AC80
loc_AC78:
		divu.w	#6,d0
		sub.w	#$10,d0
loc_AC80:
		move.w	d0,($FFFFEE0C).w
		move.w	d0,($FFFFF618).w
		and.l	#$FFFEFFFE,($FFFFF616).w
		lea	($FFFFA800).w,a2
		lea	$1E(a2),a3
		move.w	($FFFFEE00).w,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$A,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		move.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,$E(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,$C(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,$A(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,8(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,6(a2)
		move.w	d1,$10(a2)
		move.w	d1,$1C(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,4(a2)
		move.w	d1,$12(a2)
		move.w	d1,$1A(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,2(a2)
		move.w	d1,$14(a2)
		move.w	d1,$18(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,(a2)
		move.w	d1,$16(a2)
		lea	(DHz_Bg_Scroll_Data_2P),a3 
		lea	($FFFFA800).w,a2
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE0C).w,d1
		lsr.w	#1,d1
		moveq	#0,d0
loc_AD40: 
		move.b	(a3)+,d0
		addq.w	#2,a2
		sub.w	d0,d1
		bcc.s	loc_AD40
		neg.w	d1
		subq.w	#2,a2
		move.w	#$6F,d2
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	(a2)+,d0
		neg.w	d0
loc_AD5C: 
		move.l	d0,(a1)+
		subq.w	#1,d1
		bne.s	loc_AD68
		move.b	(a3)+,d1
		move.w	(a2)+,d0
		neg.w	d0
loc_AD68:
		dbra	d2,loc_AD5C
		bra.s	loc_AD86 
DHz_Bg_Scroll_Data_2P: 
		dc.b	$13
DHz_Bg_Scroll_Data_2P_01: 
		dc.b	$B,$9,$4,$3,$1,$1,$18,$6,$A,$10,$20,$10,$A,$6,$18,$1
		dc.b	$1,$3,$4,$10,$9,$B,$13
loc_AD86:
		moveq	#0,d0
		move.w	($FFFFEE24).w,d0
		tst.b	($FFFFFE11).w
		bne.s	loc_AD9C
		divu.w	#3,d0
		sub.w	#$140,d0
		bra.s	loc_ADA4
loc_AD9C:
		divu.w	#6,d0
		sub.w	#$10,d0
loc_ADA4:
		move.w	d0,($FFFFEE2C).w
		move.w	d0,($FFFFF620).w
		sub.w	#$E0,($FFFFF620).w
		move.w	($FFFFEE24).w,($FFFFF61E).w
		sub.w	#$E0,($FFFFF61E).w
		and.l	#$FFFEFFFE,($FFFFF61E).w
		lea	($FFFFA800).w,a2
		lea	$1E(a2),a3
		move.w	($FFFFEE20).w,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$A,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		move.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,$E(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,$C(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,$A(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,8(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,6(a2)
		move.w	d1,$10(a2)
		move.w	d1,$1C(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,4(a2)
		move.w	d1,$12(a2)
		move.w	d1,$1A(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,2(a2)
		move.w	d1,$14(a2)
		move.w	d1,$18(a2)
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,(a2)
		move.w	d1,$16(a2)
		lea	DHz_Bg_Scroll_Data_2P_01(pc),a3 
		lea	($FFFFA800).w,a2
		lea	($FFFFE1B0).w,a1
		move.w	($FFFFEE2C).w,d1
		lsr.w	#1,d1
		moveq	#$17,d0
		bra.s	loc_AE78
loc_AE76: 
		move.b	(a3)+,d0
loc_AE78:
		addq.w	#2,a2
		sub.w	d0,d1
		bcc.s	loc_AE76
		neg.w	d1
		subq.w	#2,a2
		move.w	#$73,d2
		move.w	($FFFFEE20).w,d0
		neg.w	d0
		swap.w	d0
		move.w	(a2)+,d0
		neg.w	d0
loc_AE92: 
		move.l	d0,(a1)+
		subq.w	#1,d1
		bne.s	loc_AE9E
		move.b	(a3)+,d1
		move.w	(a2)+,d0
		neg.w	d0
loc_AE9E:
		dbra	d2,loc_AE92
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Dust Hill Background Scroll 
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Casino Night Background Scroll 
; [ Begin ]
;===============================================================================
Bg_Scroll_CNz: 
		tst.w	($FFFFFFD8).w
		bne.w	Bg_Scroll_CNz_2P 
		move.w	(Camera_Y_pos).w,d0
		lsr.w	#6,d0
		move.w	d0,($FFFFEE0C).w
		move.w	($FFFFEE0C).w,($FFFFF618).w
		move.w	($FFFFEE00).w,d2
		bsr.w	loc_AF3E
		lea	(CNz_Bg_Scroll_Data),a3 
		lea	($FFFFA800).w,a2
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE0C).w,d1
		moveq	#0,d0
loc_AED8: 
		move.b	(a3)+,d0
		addq.w	#2,a2
		sub.w	d0,d1
		bcc.s	loc_AED8
		neg.w	d1
		subq.w	#2,a2
		move.w	#$DF,d2
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	(a2)+,d0
		neg.w	d0
loc_AEF4: 
		move.l	d0,(a1)+
		subq.w	#1,d1
		bne.s	loc_AF02
loc_AEFA: 
		move.w	(a2)+,d0
		neg.w	d0
		move.b	(a3)+,d1
		beq.s	loc_AF08
loc_AF02:
		dbra	d2,loc_AEF4
		rts
;--------------------------------------------------------------------------------
loc_AF08:
		move.w	#$F,d1
		move.w	d0,d3
		move.b	($FFFFFE0F).w,d0
		lsr.w	#3,d0
		neg.w	d0
		and.w	#$1F,d0
		lea	Bg_Scroll_Data(pc),a4 
		lea	0(a4,d0),a4
loc_AF22: 
		move.b	(a4)+,d0
		ext.w	d0
		add.w	d3,d0
		move.l	d0,(a1)+
		dbra	d1,loc_AF22
		sub.w	#$10,d2
		bra.s	loc_AEFA
CNz_Bg_Scroll_Data: 
		dc.b	$10,$10,$10,$10,$10,$10,$10,$10,$0,$F0
loc_AF3E:
		lea	($FFFFA800).w,a1
		move.w	d2,d0
		asr.w	#3,d0
		sub.w	d2,d0
		ext.l	d0
		asl.l	#5,d0
		asl.l	#8,d0
		moveq	#0,d3
		move.w	d2,d3
		move.w	#6,d1
loc_AF56: 
		move.w	d3,(a1)+
		swap.w	d3
		add.l	d0,d3
		swap.w	d3
		dbra	d1,loc_AF56
		move.w	d2,d0
		asr.w	#3,d0
		move.w	d0,4(a1)
		asr.w	#1,d0
		move.w	d0,(a1)+
		move.w	d0,(a1)+
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Bg_Scroll_CNz_2P: 
		move.w	(Camera_Y_pos).w,d0
		lsr.w	#6,d0
		move.w	d0,($FFFFEE0C).w
		move.w	($FFFFEE0C).w,($FFFFF618).w
		and.l	#$FFFEFFFE,($FFFFF616).w
		move.w	($FFFFEE00).w,d2
		bsr.w	loc_AF3E
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE0C).w,d1
		moveq	#0,d0
		move.w	($FFFFEE00).w,d0
		move.w	#$6F,d2
		lea	(CNz_Bg_Scroll_Data_2P_01),a3 
		bsr.s	loc_AFF4
		move.w	($FFFFEE24).w,d0
		lsr.w	#6,d0
		move.w	d0,($FFFFEE2C).w
		move.w	d0,($FFFFF620).w
		sub.w	#$E0,($FFFFF620).w
		move.w	($FFFFEE24).w,($FFFFF61E).w
		sub.w	#$E0,($FFFFF61E).w
		and.l	#$FFFEFFFE,($FFFFF61E).w
		move.w	($FFFFEE20).w,d2
		bsr.w	loc_AF3E
		lea	($FFFFE1B0).w,a1
		move.w	($FFFFEE2C).w,d1
		moveq	#0,d0
		move.w	($FFFFEE20).w,d0
		move.w	#$73,d2
		lea	(CNz_Bg_Scroll_Data_2P),a3 
loc_AFF4:
		lsr.w	#1,d1
		lea	($FFFFA800).w,a2
		moveq	#0,d3
loc_AFFC: 
		move.b	(a3)+,d3
		addq.w	#2,a2
		sub.w	d3,d1
		bcc.s	loc_AFFC
		neg.w	d1
		subq.w	#2,a2
		neg.w	d0
		swap.w	d0
		move.w	(a2)+,d0
		neg.w	d0
loc_B010: 
		move.l	d0,(a1)+
		subq.w	#1,d1
		bne.s	loc_B01E
loc_B016: 
		move.w	(a2)+,d0
		neg.w	d0
		move.b	(a3)+,d1
		beq.s	loc_B024
loc_B01E:
		dbra	d2,loc_B010
		rts
;--------------------------------------------------------------------------------
loc_B024:
		move.w	#7,d1
		move.w	d0,d3
		move.b	($FFFFFE0F).w,d0
		lsr.w	#3,d0
		neg.w	d0
		and.w	#$1F,d0
		lea	Bg_Scroll_Data(pc),a4 
		lea	0(a4,d0),a4
loc_B03E: 
		move.b	(a4)+,d0
		ext.w	d0
		add.w	d3,d0
		move.l	d0,(a1)+
		dbra	d1,loc_B03E
		subq.w	#8,d2
		bra.s	loc_B016

		dc.b	$4
CNz_Bg_Scroll_Data_2P: 
		dc.b	$4
CNz_Bg_Scroll_Data_2P_01: 
		dc.b	$8,$8,$8,$8,$8,$8,$8,$8,$0,$78
;===============================================================================
; Sub Routine Casino Night Background Scroll 
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Chemical Plant Background Scroll 
; [ Begin ]
;===============================================================================
Bg_Scroll_CPz: 
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.w	($FFFFEEB2).w,d5
		ext.l	d5
		asl.l	#6,d5
		bsr.w	Scroll_Block_1 
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		asl.l	#7,d4
		moveq	#4,d6
		bsr.w	Scroll_Block_4 
		move.w	($FFFFEE0C).w,d0
		move.w	d0,($FFFFEE14).w
		move.w	d0,($FFFFF618).w
		move.b	($FFFFEE52).w,d0
		or.b	($FFFFEE54).w,d0
		move.b	d0,($FFFFEE56).w
		clr.b	($FFFFEE52).w
		clr.b	($FFFFEE54).w
		move.b	($FFFFFE0F).w,d1
		and.w	#7,d1
		bne.s	loc_B0AA
		subq.w	#1,($FFFFA800).w
loc_B0AA:
		lea	(loc_BB59),a0
		move.w	($FFFFEE0C).w,d0
		move.w	d0,d2
		and.w	#$3F0,d0
		lsr.w	#4,d0
		lea	0(a0,d0),a0
		move.w	d0,d4
		lea	($FFFFE000).w,a1
		move.w	#$E,d1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		and.w	#$F,d2
		move.w	($FFFFEE08).w,d0
		cmp.b	#$12,d4
		beq.s	loc_B128
		bcs.s	loc_B0E6
		move.w	($FFFFEE10).w,d0
loc_B0E6:
		neg.w	d0
		add.w	d2,d2
		jmp	loc_B100(pc,d2)
loc_B0EE: 
		move.w	($FFFFEE08).w,d0
		cmp.b	#$12,d4
		beq.s	loc_B132
		bcs.s	loc_B0FE
		move.w	($FFFFEE10).w,d0
loc_B0FE:
		neg.w	d0
loc_B100: 
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		addq.b	#1,d4
		dbra	d1,loc_B0EE
		rts
;--------------------------------------------------------------------------------
loc_B128:
		move.w	#$F,d0
		sub.w	d2,d0
		move.w	d0,d2
		bra.s	loc_B136
loc_B132:
		move.w	#$F,d2
loc_B136:
		move.w	($FFFFEE08).w,d3
		neg.w	d3
		move.w	($FFFFA800).w,d0
		and.w	#$1F,d0
		lea	Bg_Scroll_Data(pc),a2 
		lea	0(a2,d0),a2
loc_B14C: 
		move.b	(a2)+,d0
		ext.w	d0
		add.w	d3,d0
		move.l	d0,(a1)+
		dbra	d2,loc_B14C
		addq.b	#1,d4
		dbra	d1,loc_B0EE
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Chemical Plant Background Scroll 
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Death Egg Background Scroll 
; [ Begin ]
;===============================================================================
Bg_Scroll_DEz: 
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		asl.l	#8,d4
		move.w	($FFFFEEB2).w,d5
		ext.l	d5
		asl.l	#8,d5
		bsr.w	Scroll_Block_1 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		move.w	($FFFFEE00).w,d4
		lea	($FFFFA800).w,a2
		move.w	d4,(a2)+
		addq.w	#3,(a2)+
		addq.w	#2,(a2)+
		addq.w	#4,(a2)+
		addq.w	#1,(a2)+
		addq.w	#2,(a2)+
		addq.w	#4,(a2)+
		addq.w	#3,(a2)+
		addq.w	#4,(a2)+
		addq.w	#2,(a2)+
		addq.w	#6,(a2)+
		addq.w	#3,(a2)+
		addq.w	#4,(a2)+
		addq.w	#1,(a2)+
		addq.w	#2,(a2)+
		addq.w	#4,(a2)+
		addq.w	#3,(a2)+
		addq.w	#2,(a2)+
		addq.w	#3,(a2)+
		addq.w	#4,(a2)+
		addq.w	#1,(a2)+
		addq.w	#3,(a2)+
		addq.w	#4,(a2)+
		addq.w	#2,(a2)+
		addq.w	#1,(a2)
		move.w	(a2)+,d0
		moveq	#0,d1
		move.w	d0,d1
		lsr.w	#1,d0
		move.w	d0,(a2)+
		addq.w	#3,(a2)+
		addq.w	#2,(a2)+
		addq.w	#4,(a2)+
		swap.w	d1
		move.l	d1,d0
		lsr.l	#3,d1
		sub.l	d1,d0
		swap.w	d0
		move.w	d0,4(a2)
		swap.w	d0
		sub.l	d1,d0
		swap.w	d0
		move.w	d0,2(a2)
		swap.w	d0
		sub.l	d1,d0
		swap.w	d0
		move.w	d0,(a2)+
		addq.w	#4,a2
		addq.w	#1,(a2)+
		move.w	d4,(a2)+
		move.w	d4,(a2)+
		move.w	d4,(a2)+
		lea	(DEz_Bg_Scroll_Data),a3 
		lea	($FFFFA800).w,a2
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE0C).w,d1
		moveq	#0,d0
loc_B202: 
		move.b	(a3)+,d0
		addq.w	#2,a2
		sub.w	d0,d1
		bcc.s	loc_B202
		neg.w	d1
		subq.w	#2,a2
		move.w	#$DF,d2
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	(a2)+,d0
		neg.w	d0
loc_B21E: 
		move.l	d0,(a1)+
		subq.w	#1,d1
		bne.s	loc_B22A
		move.b	(a3)+,d1
		move.w	(a2)+,d0
		neg.w	d0
loc_B22A:
		dbra	d2,loc_B21E
		moveq	#0,d2
		tst.b	($FFFFEEBD).w
		beq.s	loc_B266
		subq.w	#1,($FFFFF660).w
		bpl.s	loc_B240
		clr.b	($FFFFEEBD).w
loc_B240:
		move.w	($FFFFFE04).w,d0
		and.w	#$3F,d0
		lea	Bg_Scroll_Data(pc),a1 
		lea	0(a1,d0),a1
		moveq	#0,d0
		move.b	(a1)+,d0
		add.w	d0,($FFFFF616).w
		add.w	d0,($FFFFF618).w
		add.w	d0,($FFFFEEF4).w
		move.b	(a1)+,d2
		add.w	d2,($FFFFEEF0).w
loc_B266:
		rts
;--------------------------------------------------------------------------------
DEz_Bg_Scroll_Data: 
		dc.b	$80,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8
		dc.b	$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$8,$3,$5,$8
		dc.b	$10,$80,$80,$80
;===============================================================================
; Sub Routine Death Egg Background Scroll 
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Neo Green Hill Background Scroll 
; [ Begin ]
;===============================================================================
Bg_Scroll_NGHz: 
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		muls.w	#$119,d4
		moveq	#2,d6
		bsr.w	Scroll_Block_2 
		move.w	($FFFFEEB2).w,d5
		ext.l	d5
		asl.l	#7,d5
		tst.b	($FFFFFE11).w
		bne.s	loc_B2AC
		asl.l	#1,d5
loc_B2AC:
		moveq	#6,d6
		bsr.w	Scroll_Block_3 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		moveq	#0,d2
		tst.b	($FFFFEEBD).w
		beq.s	loc_B2E6
		move.w	($FFFFFE04).w,d0
		and.w	#$3F,d0
		lea	Bg_Scroll_Data(pc),a1 
		lea	0(a1,d0),a1
		moveq	#0,d0
		move.b	(a1)+,d0
		add.w	d0,($FFFFF616).w
		add.w	d0,($FFFFF618).w
		add.w	d0,($FFFFEEF4).w
		move.b	(a1)+,d2
		add.w	d2,($FFFFEEF0).w
loc_B2E6:
		lea	($FFFFA800).w,a2
		lea	6(a2),a3
		move.w	($FFFFEE00).w,d0
		ext.l	d0
		asl.l	#4,d0
		divs.w	#$A,d0
		ext.l	d0
		asl.l	#4,d0
		asl.l	#8,d0
		move.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d1,d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		swap.w	d1
		add.l	d0,d1
		swap.w	d1
		move.w	d1,(a3)+
		move.w	d1,(a2)
		move.w	d1,4(a2)
		move.w	($FFFFEE08).w,d0
		move.w	d0,2(a2)
		move.w	d0,$16(a2)
		move.w	d0,0(a2)
		move.w	d0,4(a2)
		move.w	d0,$18(a2)
		move.w	d0,$1A(a2)
		move.w	d0,$1C(a2)
		move.w	d0,$1E(a2)
		lea	(NGHz_Bg_Scroll_Data),a3 
		lea	($FFFFA800).w,a2
		lea	($FFFFE000).w,a1
		move.w	($FFFFEE0C).w,d1
		moveq	#0,d0
loc_B37E: 
		move.b	(a3)+,d0
		addq.w	#2,a2
		sub.w	d0,d1
		bcc.s	loc_B37E
		neg.w	d1
		subq.w	#2,a2
		move.w	#$DF,d2
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	(a2)+,d0
		neg.w	d0
loc_B39A: 
		move.l	d0,(a1)+
		subq.w	#1,d1
		bne.s	loc_B3A6
		move.b	(a3)+,d1
		move.w	(a2)+,d0
		neg.w	d0
loc_B3A6:
		dbra	d2,loc_B39A
		rts
;--------------------------------------------------------------------------------
NGHz_Bg_Scroll_Data: 
		dc.b	$B0,$70,$30,$60,$15,$C,$E,$6,$C,$1F,$30,$C0,$F0,$F0,$F0,$F0
;===============================================================================
; Sub Routine Neo Green Hill Background Scroll 
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Sky Chase Background Scroll 
; [ Begin ]
;===============================================================================
Bg_Scroll_SCz: 
		tst.w	(Debug_placement_mode).w
		bne.w	Bg_Scroll_Null 
		lea	($FFFFEE00).w,a1
		lea	($FFFFEE50).w,a3
		lea	($FFFFEEB0).w,a4
		move.w	($FFFFF736).w,d0
		move.w	(a1),d4
		add.w	(a1),d0
		move.w	d0,d1
		sub.w	(a1),d1
		asl.w	#8,d1
		move.w	d0,(a1)
		move.w	d1,(a4)
		lea	($FFFFEE40).w,a2
		bsr.w	Scroll_Horizontal_2 
		lea	(Camera_Y_pos).w,a1
		lea	($FFFFEEB2).w,a4
		move.w	($FFFFF738).w,d0
		move.w	(a1),d4
		add.w	(a1),d0
		move.w	d0,d1
		sub.w	(a1),d1
		asl.w	#8,d1
		move.w	d0,(a1)
		move.w	d1,(a4)
		lea	($FFFFEE41).w,a2
		bsr.w	Scroll_Vertical_2 
		move.w	($FFFFEEB0).w,d4
		beq.s	loc_B416
		move.w	#$100,d4
loc_B416:
		ext.l	d4
		asl.l	#7,d4
		moveq	#0,d5
		bsr.w	Scroll_Block_1 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		lea	($FFFFE000).w,a1
		move.w	#$DF,d1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	($FFFFEE08).w,d0
		neg.w	d0
loc_B43C: 
		move.l	d0,(a1)+
		dbra	d1,loc_B43C
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Sky Chase Background Scroll 
; [ End ]
;=============================================================================== 
Bg_Scroll_Null: 
		move.w	($FFFFEEB0).w,d4
		ext.l	d4
		asl.l	#5,d4
		move.w	($FFFFEEB2).w,d5
		ext.l	d5
		asl.l	#6,d5
		bsr.w	Scroll_Block_1 
		move.w	($FFFFEE0C).w,($FFFFF618).w
		lea	($FFFFE000).w,a1
		move.w	#$DF,d1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		move.w	($FFFFEE08).w,d0
		neg.w	d0
loc_B474: 
		move.l	d0,(a1)+
		dbra	d1,loc_B474
		rts
;--------------------------------------------------------------------------------
 
		 
;===============================================================================
; Sub Routine Background Scroll 
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine loc_B47C
; [ Begin ]
;=============================================================================== 
loc_B47C:
		lea	($FFFFE000).w,a1
		move.w	#$E,d1
		move.w	($FFFFEE00).w,d0
		neg.w	d0
		swap.w	d0
		and.w	#$F,d2
		add.w	d2,d2
		move.w	(a2)+,d0
		jmp	loc_B49A(pc,d2)
loc_B498: 
		move.w	(a2)+,d0
loc_B49A:
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		move.l	d0,(a1)+
		dbra	d1,loc_B498
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_B47C
; [ End ]
;===============================================================================
		 
;===============================================================================
; Sub Routine Scroll Horizontal 2
; [ Begin ]
;=============================================================================== 
Scroll_Horizontal_2: 
		move.w	(a1),d0
		and.w	#$10,d0
		move.b	(a2),d1
		eor.b	d1,d0
		bne.s	loc_B4E0
		eor.b	#$10,(a2)
		move.w	(a1),d0
		sub.w	d4,d0
		bpl.s	loc_B4DC
		bset	#2,(a3)
		rts
;--------------------------------------------------------------------------------
loc_B4DC:
		bset	#3,(a3)
loc_B4E0:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Scroll Horizontal 2
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine Scroll Horizontal 
; [ Begin ]
;=============================================================================== 
Scroll_Horizontal: 
		move.w	(a1),d4
		tst.b	($FFFFF623).w
		bne.s	loc_B520
		move.w	(a5),d1
		beq.s	loc_B50C
		sub.w	#$100,d1
		move.w	d1,(a5)
		moveq	#0,d1
		move.b	(a5),d1
		lsl.b	#2,d1
		addq.b	#4,d1
		move.w	2(a5),d0
		sub.b	d1,d0
		move.w	0(a6,d0),d0
		and.w	#$3FFF,d0
		bra.s	loc_B510
loc_B50C:
		move.w	8(a0),d0
loc_B510:
		sub.w	(a1),d0
		sub.w	#$90,d0
		blt.s	loc_B522
		sub.w	#$10,d0
		bge.s	loc_B536
		clr.w	(a4)
loc_B520:
		rts
;--------------------------------------------------------------------------------
loc_B522:
		cmp.w	#$FFF0,d0
		bgt.s	loc_B52C
		move.w	#$FFF0,d0
loc_B52C:
		add.w	(a1),d0
		cmp.w	(a2),d0
		bgt.s	loc_B54C
		move.w	(a2),d0
		bra.s	loc_B54C
loc_B536:
		cmp.w	#$10,d0
		bcs.s	loc_B540
		move.w	#$10,d0
loc_B540:
		add.w	(a1),d0
		cmp.w	2(a2),d0
		blt.s	loc_B54C
		move.w	2(a2),d0
loc_B54C:
		move.w	d0,d1
		sub.w	(a1),d1
		asl.w	#8,d1
		move.w	d0,(a1)
		move.w	d1,(a4)
		rts
;--------------------------------------------------------------------------------
 
;===============================================================================
; Sub Routine Scroll Horizontal
; [ End ]
;===============================================================================
		 
;===============================================================================
; Sub Routine Scroll Vertical
; [ Begin ]
;=============================================================================== 
Scroll_Vertical: 
		moveq	#0,d1
		move.w	$C(a0),d0
		sub.w	(a1),d0
		cmp.w	#$FF00,(Camera_Min_Y_pos).w
		bne.s	loc_B56C
		and.w	#$7FF,d0
loc_B56C:
		btst	#2,$22(a0)
		beq.s	loc_B576
		subq.w	#5,d0
loc_B576:
		btst	#1,$22(a0)
		beq.s	loc_B596
		add.w	#$20,d0
		sub.w	($FFFFEED8).w,d0
		bcs.s	loc_B5E0
		sub.w	#$40,d0
		bcc.s	loc_B5E0
		tst.b	($FFFFEEDE).w
		bne.s	loc_B5F2
		bra.s	loc_B5A2
loc_B596:
		sub.w	($FFFFEED8).w,d0
		bne.s	loc_B5A6
		tst.b	($FFFFEEDE).w
		bne.s	loc_B5F2
loc_B5A2:
		clr.w	(a4)
		rts
;--------------------------------------------------------------------------------
loc_B5A6:
		cmp.w	#$60,($FFFFEED8).w
		bne.s	loc_B5CE
		move.w	$14(a0),d1
		bpl.s	loc_B5B6
		neg.w	d1
loc_B5B6:
		cmp.w	#$800,d1
		bcc.s	loc_B5E0
		move.w	#$600,d1
		cmp.w	#6,d0
		bgt.s	loc_B62E
		cmp.w	#$FFFA,d0
		blt.s	loc_B608
		bra.s	loc_B5F8
loc_B5CE:
		move.w	#$200,d1
		cmp.w	#2,d0
		bgt.s	loc_B62E
		cmp.w	#$FFFE,d0
		blt.s	loc_B608
		bra.s	loc_B5F8
loc_B5E0:
		move.w	#$1000,d1
		cmp.w	#$10,d0
		bgt.s	loc_B62E
		cmp.w	#$FFF0,d0
		blt.s	loc_B608
		bra.s	loc_B5F8
loc_B5F2:
		moveq	#0,d0
		move.b	d0,($FFFFEEDE).w
loc_B5F8:
		moveq	#0,d1
		move.w	d0,d1
		add.w	(a1),d1
		tst.w	d0
		bpl loc_B636
		bra.w	loc_B612
loc_B608:
		neg.w	d1
		ext.l	d1
		asl.l	#8,d1
		add.l	(a1),d1
		swap.w	d1
loc_B612:
		cmp.w	4(a2),d1
		bgt.s	loc_B64C
		cmp.w	#$FF00,d1
		bgt.s	loc_B628
		and.w	#$7FF,d1
		and.w	#$7FF,(a1)
		bra.s	loc_B64C
loc_B628:
		move.w	4(a2),d1
		bra.s	loc_B64C
loc_B62E:
		ext.l	d1
		asl.l	#8,d1
		add.l	(a1),d1
		swap.w	d1
loc_B636:
		cmp.w	6(a2),d1
		blt.s	loc_B64C
		sub.w	#$800,d1
		bcs.s	loc_B648
		sub.w	#$800,(a1)
		bra.s	loc_B64C
loc_B648:
		move.w	6(a2),d1
loc_B64C:
		move.w	(a1),d4
		swap.w	d1
		move.l	d1,d3
		sub.l	(a1),d3
		ror.l	#8,d3
		move.w	d3,(a4)
		move.l	d1,(a1)
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Scroll Vertical
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Scroll Vertical 2
; [ Begin ]
;=============================================================================== 
Scroll_Vertical_2: 
		move.w	(a1),d0
		and.w	#$10,d0
		move.b	(a2),d1
		eor.b	d1,d0
		bne.s	loc_B67C
		eor.b	#$10,(a2)
		move.w	(a1),d0
		sub.w	d4,d0
		bpl.s	loc_B678
		bset	#0,(a3)
		rts
;--------------------------------------------------------------------------------
loc_B678:
		bset	#1,(a3)
loc_B67C:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Scroll Vertical 2
; [ End ]
;=============================================================================== 
		
;===============================================================================
; Sub Routine Scroll_Block_1
; [ Begin ]
;=============================================================================== 
Scroll_Block_1: 
		move.l	($FFFFEE08).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,($FFFFEE08).w
		move.l	d0,d1
		swap.w	d1
		and.w	#$10,d1
		move.b	($FFFFEE42).w,d3
		eor.b	d3,d1
		bne.s	loc_B6B2
		eor.b	#$10,($FFFFEE42).w
		sub.l	d2,d0
		bpl.s	loc_B6AC
		bset	#2,($FFFFEE52).w
		bra.s	loc_B6B2
loc_B6AC:
		bset	#3,($FFFFEE52).w
loc_B6B2:
		move.l	($FFFFEE0C).w,d3
		move.l	d3,d0
		add.l	d5,d0
		move.l	d0,($FFFFEE0C).w
		move.l	d0,d1
		swap.w	d1
		and.w	#$10,d1
		move.b	($FFFFEE43).w,d2
		eor.b	d2,d1
		bne.s	loc_B6E6
		eor.b	#$10,($FFFFEE43).w
		sub.l	d3,d0
		bpl.s	loc_B6E0
		bset	#0,($FFFFEE52).w
		rts
;--------------------------------------------------------------------------------
loc_B6E0:
		bset	#1,($FFFFEE52).w
loc_B6E6:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Scroll_Block_1
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Scroll_Block_2
; [ Begin ]
;===============================================================================
Scroll_Block_2: 
		move.l	($FFFFEE08).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,($FFFFEE08).w
		move.l	d0,d1
		swap.w	d1
		and.w	#$10,d1
		move.b	($FFFFEE42).w,d3
		eor.b	d3,d1
		bne.s	loc_B71A
		eor.b	#$10,($FFFFEE42).w
		sub.l	d2,d0
		bpl.s	loc_B714
		bset D6,($FFFFEE52).w
		bra.s	loc_B71A
loc_B714:
		addq.b	#1,d6
		bset D6,($FFFFEE52).w
loc_B71A:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Scroll_Block_2
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Scroll_Block_3
; [ Begin ]
;=============================================================================== 
Scroll_Block_3: 
		move.l	($FFFFEE0C).w,d3
		move.l	d3,d0
		add.l	d5,d0
Scroll_Block_3_D0: 
		move.l	d0,($FFFFEE0C).w
		move.l	d0,d1
		swap.w	d1
		and.w	#$10,d1
		move.b	($FFFFEE43).w,d2
		eor.b	d2,d1
		bne.s	loc_B74E
		eor.b	#$10,($FFFFEE43).w
		sub.l	d3,d0
		bpl.s	loc_B748
		bset D6,($FFFFEE52).w
		rts
;--------------------------------------------------------------------------------
loc_B748:
		addq.b	#1,d6
		bset D6,($FFFFEE52).w
loc_B74E:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Scroll_Block_3
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Scroll_Block_4
; [ Begin ]
;=============================================================================== 
Scroll_Block_4: 
		move.l	($FFFFEE10).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,($FFFFEE10).w
		move.l	d0,d1
		swap.w	d1
		and.w	#$10,d1
		move.b	($FFFFEE44).w,d3
		eor.b	d3,d1
		bne.s	loc_B782
		eor.b	#$10,($FFFFEE44).w
		sub.l	d2,d0
		bpl.s	loc_B77C
		bset D6,($FFFFEE54).w
		bra.s	loc_B782
loc_B77C:
		addq.b	#1,d6
		bset D6,($FFFFEE54).w
loc_B782:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Scroll_Block_4
; [ End ]
;===============================================================================

		move.l	($FFFFEE18).w,d2
		move.l	d2,d0
		add.l	d4,d0
		move.l	d0,($FFFFEE18).w
		move.l	d0,d1
		swap.w	d1
		and.w	#$10,d1
		move.b	($FFFFEE46).w,d3
		eor.b	d3,d1
		bne.s	loc_B7B6
		eor.b	#$10,($FFFFEE46).w
		sub.l	d2,d0
		bpl.s	loc_B7B0
		bset D6,($FFFFEE56).w
		bra.s	loc_B7B6
loc_B7B0:
		addq.b	#1,d6
		bset D6,($FFFFEE56).w
loc_B7B6:
		rts
;--------------------------------------------------------------------------------
		lea	(VDP_control_port),a5
		lea	(VDP_data_port),a6
		lea	($FFFFEE52).w,a2
		lea	($FFFFEE08).w,a3
		lea	($FFFF8080).w,a4
		move.w	#$6000,d2
		bsr.w	loc_B94A
		lea	($FFFFEE54).w,a2
		lea	($FFFFEE10).w,a3
		bra.w	loc_BA1A 
;===============================================================================
; Sub Routine LoadTilesAsYouMove 
; [ Begin ]
;=============================================================================== 
LoadTilesAsYouMove: 
		lea	(VDP_control_port),a5
		lea	(VDP_data_port),a6
		lea	($FFFFEEA2).w,a2
		lea	($FFFFEE68).w,a3
		lea	($FFFF8080).w,a4
		move.w	#$6000,d2
		bsr.w	loc_B94A
		lea	($FFFFEEA4).w,a2
		lea	($FFFFEE70).w,a3
		bsr.w	loc_BA1A
		lea	($FFFFEEA6).w,a2
		lea	($FFFFEE78).w,a3
		bsr.w	loc_BB0A
		tst.w	($FFFFFFD8).w
		beq.s	loc_B836
		lea	($FFFFEEA8).w,a2
		lea	($FFFFEE80).w,a3
		lea	($FFFF8000).w,a4
		move.w	#$6000,d2
		bsr.w	loc_B8E4
loc_B836:
		lea	($FFFFEEA0).w,a2
		lea	($FFFFEE60).w,a3
		lea	($FFFF8000).w,a4
		move.w	#$4000,d2
		tst.b	($FFFFF72C).w
		beq.s	loc_B87E
		move.b	#0,($FFFFF72C).w
		moveq	#$FFFFFFF0,d4
		moveq	#$F,d6
loc_B856: 
		movem.l	d4-d6,-(sp)
		moveq	#$FFFFFFF0,d5
		move.w	d4,d1
		bsr.w	loc_C00E
		move.w	d1,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BD1A
		movem.l	(sp)+,d4-d6
		add.w	#$10,d4
		dbra	d6,loc_B856
		move.b	#0,($FFFFEEA0).w
		rts
;--------------------------------------------------------------------------------
loc_B87E:
		tst.b	(a2)
		beq.s	loc_B8E2
		bclr	#0,(a2)
		beq.s	loc_B898
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BD1A
loc_B898:
		bclr	#1,(a2)
		beq.s	loc_B8B2
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BD1A
loc_B8B2:
		bclr	#2,(a2)
		beq.s	loc_B8C8
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BC8C
loc_B8C8:
		bclr	#3,(a2)
		beq.s	loc_B8E2
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	loc_C00E
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	loc_BC8C
loc_B8E2:
		rts
;--------------------------------------------------------------------------------
loc_B8E4:
		tst.b	(a2)
		beq.s	loc_B948
		bclr	#0,(a2)
		beq.s	loc_B8FE
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C04A
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BD1A
loc_B8FE:
		bclr	#1,(a2)
		beq.s	loc_B918
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C04A
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BD1A
loc_B918:
		bclr	#2,(a2)
		beq.s	loc_B92E
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C04A
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BC8C
loc_B92E:
		bclr	#3,(a2)
		beq.s	loc_B948
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	loc_C04A
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	loc_BC8C
loc_B948:
		rts
;--------------------------------------------------------------------------------
loc_B94A:
		tst.b	(a2)
		beq	loc_BA18
		bclr	#0,(a2)
		beq.s	loc_B966
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BD1A
loc_B966:
		bclr	#1,(a2)
		beq.s	loc_B980
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BD1A
loc_B980:
		bclr	#2,(a2)
		beq.s	loc_B996
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_BC8C
loc_B996:
		bclr	#3,(a2)
		beq.s	loc_B9B0
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	loc_C00E
		moveq	#$FFFFFFF0,d4
		move.w	#$140,d5
		bsr.w	loc_BC8C
loc_B9B0:
		bclr	#4,(a2)
		beq.s	loc_B9C8
		moveq	#$FFFFFFF0,d4
		moveq	#0,d5
		bsr.w	loc_C010
		moveq	#$FFFFFFF0,d4
		moveq	#0,d5
		moveq	#$1F,d6
		bsr.w	loc_BD1E
loc_B9C8:
		bclr	#5,(a2)
		beq.s	loc_B9E4
		move.w	#$E0,d4
		moveq	#0,d5
		bsr.w	loc_C010
		move.w	#$E0,d4
		moveq	#0,d5
		moveq	#$1F,d6
		bsr.w	loc_BD1E
loc_B9E4:
		bclr	#6,(a2)
		beq.s	loc_B9FC
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		moveq	#$1F,d6
		bsr.w	loc_BD12
loc_B9FC:
		bclr	#7,(a2)
		beq.s	loc_BA18
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		move.w	#$E0,d4
		moveq	#$FFFFFFF0,d5
		moveq	#$1F,d6
		bsr.w	loc_BD12
loc_BA18:
		rts
;--------------------------------------------------------------------------------
loc_BA1A:
		tst.b	(a2)
		beq	loc_BA5C
		bclr	#0,(a2)
		beq.s	loc_BA3C
		move.w	#$70,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		move.w	#$70,d4
		moveq	#$FFFFFFF0,d5
		moveq	#2,d6
		bsr.w	loc_BC8E
loc_BA3C:
		bclr	#1,(a2)
		beq.s	loc_BA5C
		move.w	#$70,d4
		move.w	#$140,d5
		bsr.w	loc_C00E
		move.w	#$70,d4
		move.w	#$140,d5
		moveq	#2,d6
		bsr.w	loc_BC8E
loc_BA5C:
		rts
;--------------------------------------------------------------------------------
loc_BA5E:
		dc.b	$0
loc_BA5F:
		dc.b	$0,$0,$0,$0,$6,$6,$6,$6,$6,$6,$6,$6,$6,$6,$4,$4
		dc.b	$4,$4,$4,$4,$4,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2
		even 
loc_BA80:
		moveq	#$FFFFFFF0,d4
		bclr	#0,(a2)
		bne.s	loc_BA92
		bclr	#1,(a2)
		beq.s	loc_BADA
		move.w	#$E0,d4
loc_BA92:
		lea	loc_BA5F(pc),a0
		move.w	($FFFFEE0C).w,d0
		add.w	d4,d0
		and.w	#$1F0,d0
		lsr.w	#4,d0
		move.b	0(a0,d0),d0
		lea	(loc_BC06),a3
		move.w	0(a3,d0),a3
		beq.s	loc_BAC6
		moveq	#$FFFFFFF0,d5
		movem.l	d4/d5,-(sp)
		bsr.w	loc_C00E
		movem.l	(sp)+,d4/d5
		bsr.w	loc_BD1A
		bra.s	loc_BADA
loc_BAC6:
		moveq	#0,d5
		movem.l	d4/d5,-(sp)
		bsr.w	loc_C010
		movem.l	(sp)+,d4/d5
		moveq	#$1F,d6
		bsr.w	loc_BD1E
loc_BADA:
		tst.b	(a2)
		bne.s	loc_BAE0
		rts
;--------------------------------------------------------------------------------
loc_BAE0:
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		move.b	(a2),d0
		and.b	#$A8,d0
		beq.s	loc_BAF4
		lsr.b	#1,d0
		move.b	d0,(a2)
		move.w	#$140,d5
loc_BAF4:
		lea	loc_BA5E(pc),a0
		move.w	($FFFFEE0C).w,d0
		and.w	#$1F0,d0
		lsr.w	#4,d0
		lea	0(a0,d0),a0
		bra.w	loc_BC0E
loc_BB0A:
		tst.b	(a2)
		beq	loc_BB56
		cmp.b	#$D,($FFFFFE10).w
		beq	loc_BB9A
		bclr	#0,(a2)
		beq.s	loc_BB36
		move.w	#$40,d4
		moveq	#$FFFFFFF0,d5
		bsr.w	loc_C00E
		move.w	#$40,d4
		moveq	#$FFFFFFF0,d5
		moveq	#2,d6
		bsr.w	loc_BC8E
loc_BB36:
		bclr	#1,(a2)
		beq.s	loc_BB56
		move.w	#$40,d4
		move.w	#$140,d5
		bsr.w	loc_C00E
		move.w	#$40,d4
		move.w	#$140,d5
		moveq	#2,d6
		bsr.w	loc_BC8E
loc_BB56:
		rts
;--------------------------------------------------------------------------------
loc_BB58:
		dc.b	$2
loc_BB59: 
		dc.b	$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2,$2
		dc.b	$2,$2,$2,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4
		dc.b	$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4
		dc.b	$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$4
		even
loc_BB9A:
		moveq	#$FFFFFFF0,d4
		bclr	#0,(a2)
		bne.s	loc_BBAC
		bclr	#1,(a2)
		beq.s	loc_BBD6
		move.w	#$E0,d4
loc_BBAC:
		lea	loc_BB59(pc),a0
		move.w	($FFFFEE0C).w,d0
		add.w	d4,d0
		and.w	#$3F0,d0
		lsr.w	#4,d0
		move.b	0(a0,d0),d0
		move.w	loc_BC06(pc,d0),a3
		moveq	#$FFFFFFF0,d5
		movem.l	d4/d5,-(sp)
		bsr.w	loc_C00E
		movem.l	(sp)+,d4/d5
		bsr.w	loc_BD1A
loc_BBD6:
		tst.b	(a2)
		bne.s	loc_BBDC
		rts
;--------------------------------------------------------------------------------
loc_BBDC:
		moveq	#$FFFFFFF0,d4
		moveq	#$FFFFFFF0,d5
		move.b	(a2),d0
		and.b	#$A8,d0
		beq.s	loc_BBF0
		lsr.b	#1,d0
		move.b	d0,(a2)
		move.w	#$140,d5
loc_BBF0:
		lea	loc_BB58(pc),a0
		move.w	($FFFFEE0C).w,d0
		and.w	#$7F0,d0
		lsr.w	#4,d0
		lea	0(a0,d0),a0
		bra.w	loc_BC0E
loc_BC06:
		dc.w	$EE68,$EE68,$EE70,$EE78
loc_BC0E:
		tst.w	($FFFFFFD8).w
		bne.s	loc_BC50
		moveq	#$F,d6
		move.l	#$800000,d7
loc_BC1C: 
		moveq	#0,d0
		move.b	(a0)+,d0
		btst D0,(a2)
		beq.s	loc_BC44
		move.w	loc_BC06(pc,d0),a3
		movem.l	d4/d5/a0,-(sp)
		movem.l	d4/d5,-(sp)
		bsr.w	loc_BFCC
		movem.l	(sp)+,d4/d5
		bsr.w	loc_C00E
		bsr.w	loc_BEFC
		movem.l	(sp)+,d4/d5/a0
loc_BC44:
		add.w	#$10,d4
		dbra	d6,loc_BC1C
		clr.b	(a2)
		rts
;--------------------------------------------------------------------------------
loc_BC50:
		moveq	#$F,d6
		move.l	#$800000,d7
loc_BC58: 
		moveq	#0,d0
		move.b	(a0)+,d0
		btst D0,(a2)
		beq.s	loc_BC80
		move.w	loc_BC06(pc,d0),a3
		movem.l	d4/d5/a0,-(sp)
		movem.l	d4/d5,-(sp)
		bsr.w	loc_BFCC
		movem.l	(sp)+,d4/d5
		bsr.w	loc_C00E
		bsr.w	loc_BF82
		movem.l	(sp)+,d4/d5/a0
loc_BC80:
		add.w	#$10,d4
		dbra	d6,loc_BC58
		clr.b	(a2)
		rts
;--------------------------------------------------------------------------------
loc_BC8C:
		moveq	#$F,d6
loc_BC8E:
		add.w	(a3),d5
		add.w	4(a3),d4
		move.l	#$800000,d7
		move.l	d0,d1
		bsr.w	loc_BE26
		tst.w	($FFFFFFD8).w
		bne.s	loc_BCDC
loc_BCA6: 
		move.w	(a0),d3
		and.w	#$3FF,d3
		lsl.w	#3,d3
		lea	($FFFF9000).w,a1
		add.w	d3,a1
		move.l	d1,d0
		bsr.w	loc_BEFC
		add.w	#$10,a0
		add.w	#$100,d1
		and.w	#$FFF,d1
		add.w	#$10,d4
		move.w	d4,d0
		and.w	#$70,d0
		bne.s	loc_BCD6
		bsr.w	loc_BE26
loc_BCD6:
		dbra	d6,loc_BCA6
		rts
;--------------------------------------------------------------------------------
loc_BCDC:
		move.w	(a0),d3
		and.w	#$3FF,d3
		lsl.w	#3,d3
		lea	($FFFF9000).w,a1
		add.w	d3,a1
		move.l	d1,d0
		bsr.w	loc_BF82
		add.w	#$10,a0
		add.w	#$80,d1
		and.w	#$FFF,d1
		add.w	#$10,d4
		move.w	d4,d0
		and.w	#$70,d0
		bne.s	loc_BD0C
		bsr.w	loc_BE26
loc_BD0C:
		dbra	d6,loc_BCDC
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_B7E4 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine loc_BD12
; [ Begin ]
;=============================================================================== 
loc_BD12:
		add.w	(a3),d5
		add.w	4(a3),d4
		bra.s	loc_BD22
loc_BD1A: 
		moveq	#$15,d6
		add.w	(a3),d5
loc_BD1E: 
		add.w	4(a3),d4
loc_BD22:
		tst.w	($FFFFFFD8).w
		bne.s	loc_BDA0
		move.l	a2,-(sp)
		move.w	d6,-(sp)
		lea	($FFFFEF00).w,a2
		move.l	d0,d1
		or.w	d2,d1
		swap.w	d1
		move.l	d1,-(sp)
		move.l	d1,(a5)
		swap.w	d1
		bsr.w	loc_BE26
loc_BD40: 
		move.w	(a0),d3
		and.w	#$3FF,d3
		lsl.w	#3,d3
		lea	($FFFF9000).w,a1
		add.w	d3,a1
		bsr.w	loc_BE5C
		addq.w	#2,a0
		addq.b	#4,d1
		bpl.s	loc_BD62
		and.b	#$7F,d1
		swap.w	d1
		move.l	d1,(a5)
		swap.w	d1
loc_BD62:
		add.w	#$10,d5
		move.w	d5,d0
		and.w	#$70,d0
		bne.s	loc_BD72
		bsr.w	loc_BE26
loc_BD72:
		dbra	d6,loc_BD40
		move.l	(sp)+,d1
		add.l	#$800000,d1
		lea	($FFFFEF00).w,a2
		move.l	d1,(a5)
		swap.w	d1
		move.w	(sp)+,d6
loc_BD88: 
		move.l	(a2)+,(a6)
		addq.b	#4,d1
		bmi.s	loc_BD98
		or.b	#$80,d1
		swap.w	d1
		move.l	d1,(a5)
		swap.w	d1
loc_BD98:
		dbra	d6,loc_BD88
		move.l	(sp)+,a2
		rts
;--------------------------------------------------------------------------------
loc_BDA0:
		move.l	d0,d1
		or.w	d2,d1
		swap.w	d1
		move.l	d1,(a5)
		swap.w	d1
		tst.b	d1
		bmi.s	loc_BDEA
		bsr.w	loc_BE26
loc_BDB2: 
		move.w	(a0),d3
		and.w	#$3FF,d3
		lsl.w	#3,d3
		lea	($FFFF9000).w,a1
		add.w	d3,a1
		bsr.w	loc_BEBE
		addq.w	#2,a0
		addq.b	#4,d1
		bpl.s	loc_BDD4
		and.b	#$7F,d1
		swap.w	d1
		move.l	d1,(a5)
		swap.w	d1
loc_BDD4:
		add.w	#$10,d5
		move.w	d5,d0
		and.w	#$70,d0
		bne.s	loc_BDE4
		bsr.w	loc_BE26
loc_BDE4:
		dbra	d6,loc_BDB2
		rts
;--------------------------------------------------------------------------------
loc_BDEA:
		bsr.w	loc_BE26
loc_BDEE: 
		move.w	(a0),d3 
		and.w	#$3FF,d3
		lsl.w	#3,d3
		lea	($FFFF9000).w,a1
		add.w	d3,a1
		bsr.w	loc_BEBE
		addq.w	#2,a0
		addq.b	#4,d1
		bmi.s	loc_BE10
		or.b	#$80,d1
		swap.w	d1
		move.l	d1,(a5)
		swap.w	d1
loc_BE10:
		add.w	#$10,d5
		move.w	d5,d0
		and.w	#$70,d0
		bne.s	loc_BE20
		bsr.w	loc_BE26
loc_BE20:
		dbra	d6,loc_BDEE
		rts
;--------------------------------------------------------------------------------
loc_BE26:
		movem.l	d4/d5,-(sp)
		move.w	d4,d3
		add.w	d3,d3
		and.w	#$F00,d3
		lsr.w	#3,d5
		move.w	d5,d0
		lsr.w	#4,d0
		and.w	#$7F,d0
		add.w	d3,d0
		moveq	#$FFFFFFFF,d3
		clr.w	d3
		move.b	0(a4,d0),d3
		lsl.w	#7,d3
		and.w	#$70,d4
		and.w	#$E,d5
		add.w	d4,d3
		add.w	d5,d3
		move.l	d3,a0
		movem.l	(sp)+,d4/d5
		rts
;--------------------------------------------------------------------------------
loc_BE5C:
		btst	#3,(a0)
		bne.s	loc_BE88
		btst	#2,(a0)
		bne.s	loc_BE6E
		move.l	(a1)+,(a6)
		move.l	(a1)+,(a2)+
		rts
;--------------------------------------------------------------------------------
loc_BE6E:
		move.l	(a1)+,d3
		eor.l	#$8000800,d3
		swap.w	d3
		move.l	d3,(a6)
		move.l	(a1)+,d3
		eor.l	#$8000800,d3
		swap.w	d3
		move.l	d3,(a2)+
		rts
;--------------------------------------------------------------------------------
loc_BE88:
		btst	#2,(a0)
		bne.s	loc_BEA4
		move.l	(a1)+,d0
		move.l	(a1)+,d3
		eor.l	#$10001000,d3
		move.l	d3,(a6)
		eor.l	#$10001000,d0
		move.l	d0,(a2)+
		rts
;--------------------------------------------------------------------------------
loc_BEA4:
		move.l	(a1)+,d0
		move.l	(a1)+,d3
		eor.l	#$18001800,d3
		swap.w	d3
		move.l	d3,(a6)
		eor.l	#$18001800,d0
		swap.w	d0
		move.l	d0,(a2)+
		rts
;--------------------------------------------------------------------------------
loc_BEBE:
		btst	#3,(a0)
		bne.s	loc_BEDC
		btst	#2,(a0)
		bne.s	loc_BECE
		move.l	(a1)+,(a6)
		rts
;--------------------------------------------------------------------------------
loc_BECE:
		move.l	(a1)+,d3
		eor.l	#$8000800,d3
		swap.w	d3
		move.l	d3,(a6)
		rts
;--------------------------------------------------------------------------------
loc_BEDC:
		btst	#2,(a0)
		bne.s	loc_BEEE
		move.l	(a1)+,d3
		eor.l	#$10001000,d3
		move.l	d3,(a6)
		rts
;--------------------------------------------------------------------------------
loc_BEEE:
		move.l	(a1)+,d3
		eor.l	#$18001800,d3
		swap.w	d3
		move.l	d3,(a6)
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_BD12
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine loc_BEFC
; [ Begin ]
;=============================================================================== 
loc_BEFC: 
		or.w	d2,d0
		swap.w	d0
		btst	#3,(a0)
		bne.s	loc_BF38
		btst	#2,(a0)
		bne.s	loc_BF18
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		rts
;--------------------------------------------------------------------------------
loc_BF18:
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eor.l	#$8000800,d3
		swap.w	d3
		move.l	d3,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eor.l	#$8000800,d3
		swap.w	d3
		move.l	d3,(a6)
		rts
;--------------------------------------------------------------------------------
loc_BF38:
		btst	#2,(a0)
		bne.s	loc_BF5E
		move.l	d5,-(sp)
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d3
		eor.l	#$10001000,d3
		move.l	d3,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eor.l	#$10001000,d5
		move.l	d5,(a6)
		move.l	(sp)+,d5
		rts
;--------------------------------------------------------------------------------
loc_BF5E:
		move.l	d5,-(sp)
		move.l	d0,(a5)
		move.l	(a1)+,d5
		move.l	(a1)+,d3
		eor.l	#$18001800,d3
		swap.w	d3
		move.l	d3,(a6)
		add.l	d7,d0
		move.l	d0,(a5)
		eor.l	#$18001800,d5
		swap.w	d5
		move.l	d5,(a6)
		move.l	(sp)+,d5
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_BEFC
; [ Begin ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine loc_BF82
; [ Begin ]
;=============================================================================== 
loc_BF82: 
		or.w	d2,d0
		swap.w	d0
		btst	#3,(a0)
		bne.s	loc_BFA8
		btst	#2,(a0)
		bne.s	loc_BF98
		move.l	d0,(a5)
		move.l	(a1)+,(a6)
		rts
;--------------------------------------------------------------------------------
loc_BF98:
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eor.l	#$8000800,d3
		swap.w	d3
		move.l	d3,(a6)
		rts
;--------------------------------------------------------------------------------
loc_BFA8:
		btst	#2,(a0)
		bne.s	loc_BFBC
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eor.l	#$10001000,d3
		move.l	d3,(a6)
		rts
;--------------------------------------------------------------------------------
loc_BFBC:
		move.l	d0,(a5)
		move.l	(a1)+,d3
		eor.l	#$18001800,d3
		swap.w	d3
		move.l	d3,(a6)
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_BF82
; [ End ]
;===============================================================================
 
;===============================================================================
; Sub Routine loc_BFCC
; [ Begin ]
;=============================================================================== 
loc_BFCC:
		add.w	(a3),d5
		add.w	4(a3),d4
		lea	($FFFF9000).w,a1
		move.w	d4,d3
		add.w	d3,d3
		and.w	#$F00,d3
		lsr.w	#3,d5
		move.w	d5,d0
		lsr.w	#4,d0
		and.w	#$7F,d0
		add.w	d3,d0
		moveq	#$FFFFFFFF,d3
		clr.w	d3
		move.b	0(a4,d0),d3
		lsl.w	#7,d3
		and.w	#$70,d4
		and.w	#$E,d5
		add.w	d4,d3
		add.w	d5,d3
		move.l	d3,a0
		move.w	(a0),d3
		and.w	#$3FF,d3
		lsl.w	#3,d3
		add.w	d3,a1
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_BFCC
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine loc_C00E
; [ Begin ]
;=============================================================================== 
loc_C00E:
		add.w	(a3),d5
loc_C010: 
		tst.w	($FFFFFFD8).w
		bne.s	loc_C030
		add.w	4(a3),d4
		and.w	#$F0,d4
		and.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0
		swap.w	d0
		move.w	d4,d0
		rts
;--------------------------------------------------------------------------------
loc_C030:
		add.w	4(a3),d4
loc_C034: 
		and.w	#$1F0,d4
		and.w	#$1F0,d5
		lsl.w	#3,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#3,d0
		swap.w	d0
		move.w	d4,d0
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_C00E
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine loc_C04A
; [ Begin ]
;=============================================================================== 
loc_C04A:
		tst.w	($FFFFFFD8).w
		bne.s	loc_C06C
		add.w	4(a3),d4
		add.w	(a3),d5
		and.w	#$F0,d4
		and.w	#$1F0,d5
		lsl.w	#4,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#2,d0
		swap.w	d0
		move.w	d4,d0
		rts
;--------------------------------------------------------------------------------
loc_C06C:
		add.w	4(a3),d4
		add.w	(a3),d5
		and.w	#$1F0,d4
		and.w	#$1F0,d5
		lsl.w	#3,d4
		lsr.w	#2,d5
		add.w	d5,d4
		moveq	#2,d0
		swap.w	d0
		move.w	d4,d0
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_C04A
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Load_Tiles_From_Start
; [ Begin ]
;===============================================================================
Load_Tiles_From_Start: 
		lea	(VDP_control_port),a5
		lea	(VDP_data_port),a6
		lea	($FFFFEE08).w,a3
		lea	($FFFF8080).w,a4
		move.w	#$6000,d2
		moveq	#0,d4
		cmp.b	#$C,($FFFFFE10).w
		beq	loc_C0C0
		tst.w	($FFFFFFD8).w
		beq	loc_C0BE
		cmp.b	#$B,($FFFFFE10).w
		beq	loc_C11E
loc_C0BE:
		moveq	#$FFFFFFF0,d4
loc_C0C0:
		moveq	#$F,d6
loc_C0C2: 
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	loc_C00E
		move.w	d1,d4
		moveq	#0,d5
		moveq	#$1F,d6
		move	#$2700,sr
		bsr.w	loc_BD12
		move	#$2300,sr
		movem.l	(sp)+,d4-d6
		add.w	#$10,d4
		dbra	d6,loc_C0C2
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Load_Tiles_From_Start
; [ End ]
;=============================================================================== 
		moveq	#$FFFFFFF0,d4
		moveq	#$F,d6
loc_C0F2: 
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	loc_C04A
		move.w	d1,d4
		moveq	#0,d5
		moveq	#$1F,d6
		move	#$2700,sr
		bsr.w	loc_BD12
		move	#$2300,sr
		movem.l	(sp)+,d4-d6
		add.w	#$10,d4
		dbra	d6,loc_C0F2
		rts
;--------------------------------------------------------------------------------
loc_C11E:
		moveq	#0,d4
		moveq	#$1F,d6
loc_C122: 
		movem.l	d4-d6,-(sp)
		moveq	#0,d5
		move.w	d4,d1
		bsr.w	loc_C034
		move.w	d1,d4
		moveq	#0,d5
		moveq	#$1F,d6
		move	#$2700,sr
		bsr.w	loc_BD22
		move	#$2300,sr
		movem.l	(sp)+,d4-d6
		add.w	#$10,d4
		dbra	d6,loc_C122
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Main_Level_Load_16_128_Blocks
; [ Begin ]
;=============================================================================== 
Main_Level_Load_16_128_Blocks: 
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		lea	(TilesMainTable),a2 
		lea	0(a2,d0),a2
		move.l	a2,-(sp)
		addq.w	#4,a2
		move.l	(a2)+,d0
		and.l	#$FFFFFF,d0
		move.l	d0,a0
		lea	($FFFF9000).w,a1
		bsr.w	J_KosinskiDec 
		cmp.b	#7,($FFFFFE10).w
		bne.s	loc_C19A
		lea	($FFFF9980).w,a1
		lea	(Hill_Top_16x16_Map),a0 
		move.w	#$3FF,d2
loc_C194: 
		move.w	(a0)+,(a1)+
		dbra	d2,loc_C194
loc_C19A: 
		tst.w	($FFFFFFD8).w
		beq.s	loc_C1BE
		lea	($FFFF9000).w,a1
		move.w	#$BFF,d2
loc_C1A8: 
		move.w	(a1),d0
		move.w	d0,d1
		and.w	#$F800,d0
		and.w	#$7FF,d1
		lsr.w	#1,d1
		or.w	d1,d0
		move.w	d0,(a1)+
		dbra	d2,loc_C1A8
loc_C1BE:
		move.l	(a2)+,d0
		and.l	#$FFFFFF,d0
		move.l	d0,a0
		lea	(RAM_Start),a1
		bsr.w	J_KosinskiDec 
		bsr.w	loc_C1F0
		move.l	(sp)+,a2
		addq.w	#4,a2
		moveq	#0,d0
		move.b	(a2),d0
		beq.s	loc_C1E4
		bsr.w	J_LoadPLC 
loc_C1E4:
		addq.w	#4,a2
		moveq	#0,d0
		move.b	(a2),d0
		bsr.w	J_PalLoad2 
		rts
;--------------------------------------------------------------------------------
loc_C1F0:
		moveq	#0,d0
		move.w	($FFFFFE10).w,d0
		ror.b	#1,d0
		lsr.w	#6,d0
		lea	(Level_Layout),a0 
		move.w	0(a0,d0),d0
		lea	0(a0,d0.l),a0
		lea	($FFFF8000).w,a1
		bra.w	J_KosinskiDec 
		lea	($FFFF8000).w,a3
		move.w	#$3FF,d1
		moveq	#0,d0
loc_C21A: 
		move.l	d0,(a3)+
		dbra	d1,loc_C21A
		lea	($FFFF8000).w,a3
		moveq	#0,d1
		bsr.w	loc_C230
		lea	($FFFF8080).w,a3
		moveq	#2,d1
loc_C230:
		moveq	#0,d0
		move.w	($FFFFFE10).w,d0
		ror.b	#1,d0
		lsr.w	#5,d0
		add.w	d1,d0
		lea	(Level_Layout),a1 
		move.w	0(a1,d0),d0
		lea	0(a1,d0.l),a1
		moveq	#0,d1
		move.w	d1,d2
		move.b	(a1)+,d1
		move.b	(a1)+,d2
		move.l	d1,d5
		addq.l	#1,d5
		moveq	#0,d3
		move.w	#$80,d3
		divu.w	d5,d3
		subq.w	#1,d3
loc_C260:
		move.l	a3,a0
		move.w	d3,d4
loc_C264: 
		move.l	a1,-(sp)
		move.w	d1,d0
loc_C268: 
		move.b	(a1)+,(a0)+
		dbra	d0,loc_C268
		move.l	(sp)+,a1
		dbra	d4,loc_C264
		lea	0(a1,d5),a1
		lea	$100(a3),a3
		dbra	d2,loc_C260
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Main_Level_Load_16_128_Blocks
; [ Begin ]
;=============================================================================== 
		lea	($FE0000),a1
		lea	($FE0080),a2
		lea	(RAM_Start),a3
		move.w	#$3F,d1
loc_C298: 
		bsr.w	loc_C32A
		bsr.w	loc_C32A
		dbra	d1,loc_C298
		lea	($FE0000),a1
		lea	($FF0000),a2
		move.w	#$3F,d1
loc_C2B4: 
		move.w	#0,(a2)+
		dbra	d1,loc_C2B4
		move.w	#$3FBF,d1
loc_C2C0: 
		move.w	(a1)+,(a2)+
		dbra	d1,loc_C2C0 
		rts
;--------------------------------------------------------------------------------

		lea	($FE0000),a1
		lea	(RAM_Start),a3
		moveq	#$1F,d0
loc_C2D6: 
		move.l	(a1)+,(a3)+
		dbra	d0,loc_C2D6
		moveq	#0,d7
		lea	($FE0000),a1
		move.w	#$FF,d5
loc_C2E8: 
		lea	(RAM_Start),a3
		move.w	d7,d6
loc_C2F0: 
		movem.l	a1-a3,-(sp)
		move.w	#$3F,d0
loc_C2F8: 
		cmpm.w	(a1)+,(a3)+
		bne.s	loc_C30E
		dbra	d0,loc_C2F8
		movem.l	(sp)+,a1-a3
		add.w	#$80,a1
		dbra	d5,loc_C2E8
		bra.s	loc_C328
loc_C30E:
		movem.l	(sp)+,a1-a3
		add.w	#$80,a3
		dbra	d6,loc_C2F0
		moveq	#$1F,d0
loc_C31C: 
		move.l	(a1)+,(a3)+
		dbra	d0,loc_C31C
		addq.l	#1,d7
		dbra	d5,loc_C2E8
loc_C328:
		bra.s	loc_C328
loc_C32A:
		moveq	#7,d0
loc_C32C: 
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a1)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		move.l	(a3)+,(a2)+
		dbra	d0,loc_C32C
		add.w	#$80,a1
		add.w	#$80,a2
		rts
;--------------------------------------------------------------------------------
		nop
J_PalLoad2: 
		jmp	PalLoad2 
J_LoadPLC: 
		jmp	LoadPLC 
J_KosinskiDec: 
		jmp	KosinskiDec 
		dc.w	$0 ; Filler
;===============================================================================
; Sub Routine Dynamic Screen Size Boss
; [ Begin ]
;=============================================================================== 
Dyn_Screen_Boss_Loader: 
		moveq	#0,d0 
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		move.w	dynResize_Index(pc,d0),d0 
		jsr	DynResize_Index(pc,d0) 
		moveq	#2,d1
		move.w	(Camera_Max_Y_pos).w,d0
		sub.w	(Camera_Max_Y_pos_now).w,d0
		beq.s	loc_C39E
		bcc.s	loc_C3A0
		neg.w	d1
		move.w	(Camera_Y_pos).w,d0
		cmp.w	(Camera_Max_Y_pos).w,d0
		bls.s	loc_C394
		move.w	d0,(Camera_Max_Y_pos_now).w
		and.w	#$FFFE,(Camera_Max_Y_pos_now).w
loc_C394:
		add.w	d1,(Camera_Max_Y_pos_now).w
		move.b	#1,($FFFFEEDE).w
loc_C39E:
		rts
;--------------------------------------------------------------------------------
loc_C3A0:
		move.w	(Camera_Y_pos).w,d0
		add.w	#8,d0
		cmp.w	(Camera_Max_Y_pos_now).w,d0
		bcs.s	loc_C3BA
		btst	#1,(Object_RAM+status).w
		beq.s	loc_C3BA
		add.w	d1,d1
		add.w	d1,d1
loc_C3BA:
		add.w	d1,(Camera_Max_Y_pos_now).w
		move.b	#1,($FFFFEEDE).w
		rts
;--------------------------------------------------------------------------------
DynResize_Index: 
		dc.w	dynResize_GHz-dynResize_Index 
		dc.w	dynResize_Null_0-dynResize_Index 
		dc.w	dynResize_Wz-dynResize_Index 
		dc.w	dynResize_Null_1-dynResize_Index 
		dc.w	dynResize_Null_2-dynResize_Index 
		dc.w	dynResize_Mz-dynResize_Index 
		dc.w	dynResize_SFz-dynResize_Index 
		dc.w	dynResize_HTz-dynResize_Index 
		dc.w	dynResize_HPz-dynResize_Index 
		dc.w	dynResize_Null_3-dynResize_Index 
		dc.w	dynResize_OOz-dynResize_Index 
		dc.w	dynResize_DHz-dynResize_Index 
		dc.w	dynResize_CNz-dynResize_Index 
		dc.w	dynResize_CPz-dynResize_Index 
		dc.w	dynResize_DEz-dynResize_Index 
		dc.w	dynResize_NGHz-dynResize_Index 
		dc.w	dynResize_SCz-dynResize_Index 
;------------------------------------------------------------------------------- 
DynResize_GHz: 
		tst.b	($FFFFFE11).w
		bne.s	loc_C3F0
		rts
;--------------------------------------------------------------------------------
loc_C3F0:
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_C3FE(pc,d0),d0
		jmp	loc_C3FE(pc,d0)
loc_C3FE:
		dc.w	loc_C406-loc_C3FE
		dc.w	loc_C440-loc_C3FE
		dc.w	loc_C47E-loc_C3FE
		dc.w	loc_C4C8-loc_C3FE
loc_C406:
		tst.w	($FFFFFFD8).w
		bne.s	loc_C432
		cmp.w	#$2750,($FFFFEE00).w
		bcs.s	loc_C430
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		move.w	#$390,(Camera_Max_Y_pos).w
		move.w	#$390,($FFFFEEFE).w
		addq.b	#2,($FFFFEEDF).w
loc_C430:
		rts
;--------------------------------------------------------------------------------
loc_C432:
		move.w	#$2920,(Camera_Max_X_pos).w
		move.w	#$2920,($FFFFEEFA).w
		rts
;--------------------------------------------------------------------------------
loc_C440:
		cmp.w	#$28F0,($FFFFEE00).w
		bcs.s	loc_C47C
		move.w	#$28F0,(Camera_Min_X_pos).w
		move.w	#$2940,(Camera_Max_X_pos).w
		move.w	#$28F0,($FFFFEEF8).w
		move.w	#$2940,($FFFFEEFA).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F9,d0
		bsr.w	J_Play_Music 
		clr.b	($FFFFF73A).w
		move.b	#2,($FFFFF7AA).w
		moveq	#$29,d0
		bsr.w	J_LoadPLC_01 
loc_C47C:
		rts
;--------------------------------------------------------------------------------
loc_C47E:
		cmp.w	#$388,(Camera_Y_pos).w
		bcs.s	loc_C492
		move.w	#$388,(Camera_Min_Y_pos).w
		move.w	#$388,($FFFFEEFC).w
loc_C492:
		addq.b	#1,($FFFFF73A).w
		cmp.b	#$5A,($FFFFF73A).w
		bcs.s	loc_C4C6
		bsr.w	J_SingleObjectLoad 
		bne.s	loc_C4BA
		move.b	#$56,(a1)
		move.b	#$81,$28(a1)
		move.w	#$29D0,8(a1)
		move.w	#$426,$C(a1)
loc_C4BA:
		addq.b	#2,($FFFFEEDF).w
		move.w	#$93,d0
		bsr.w	J_Play_Music 
loc_C4C6:
		rts
;--------------------------------------------------------------------------------
loc_C4C8:
		tst.b	($FFFFF7A7).w
		beq.s	loc_C4E0
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	(Camera_Max_X_pos).w,($FFFFEEFA).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
loc_C4E0:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_Null_0: 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_Wz: 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_Null_1: 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_Null_2: 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_Mz: 
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_C4F8(pc,d0),d0
		jmp	loc_C4F8(pc,d0)
loc_C4F8:
		dc.w	loc_C500-loc_C4F8
		dc.w	loc_C526-loc_C4F8
		dc.w	loc_C564-loc_C4F8
		dc.w	loc_C59C-loc_C4F8
loc_C500:
		cmp.w	#$2980,($FFFFEE00).w
		bcs.s	loc_C524
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		move.w	#$400,(Camera_Max_Y_pos).w
		move.w	#$400,($FFFFEEFE).w
		addq.b	#2,($FFFFEEDF).w
loc_C524:
		rts
;--------------------------------------------------------------------------------
loc_C526:
		cmp.w	#$2A80,($FFFFEE00).w
		bcs.s	loc_C562
		move.w	#$2AB0,(Camera_Min_X_pos).w
		move.w	#$2AB0,(Camera_Max_X_pos).w
		move.w	#$2AB0,($FFFFEEF8).w
		move.w	#$2AB0,($FFFFEEFA).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F9,d0
		bsr.w	J_Play_Music 
		clr.b	($FFFFF73A).w
		move.b	#7,($FFFFF7AA).w
		moveq	#$2E,d0
		bsr.w	J_LoadPLC_01 
loc_C562:
		rts
;--------------------------------------------------------------------------------
loc_C564:
		cmp.w	#$400,(Camera_Y_pos).w
		bcs.s	loc_C578
		move.w	#$400,(Camera_Min_Y_pos).w
		move.w	#$400,($FFFFEEFC).w
loc_C578:
		addq.b	#1,($FFFFF73A).w
		cmp.b	#$5A,($FFFFF73A).w
		bcs.s	loc_C59A
		bsr.w	J_SingleObjectLoad 
		bne.s	loc_C58E
		move.b	#$54,(a1)
loc_C58E:
		addq.b	#2,($FFFFEEDF).w
		move.w	#$93,d0
		bsr.w	J_Play_Music 
loc_C59A:
		rts
;--------------------------------------------------------------------------------
loc_C59C:
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	(Camera_Max_X_pos).w,($FFFFEEFA).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_SFz: 
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_C5D0(pc,d0),d0
		jsr	loc_C5D0(pc,d0)
		move.w	($FFFFF660).w,d0
		move.w	loc_C5CA(pc,d0),d0
		jmp	loc_C5CA(pc,d0)
loc_C5CA:
		dc.w	loc_C6B8-loc_C5CA
		dc.w	loc_C6DA-loc_C5CA
		dc.w	loc_C6F2-loc_C5CA
loc_C5D0:
		dc.w	loc_C5D8-loc_C5D0
		dc.w	loc_C5FC-loc_C5D0
		dc.w	loc_C62E-loc_C5D0
		dc.w	loc_C672-loc_C5D0
loc_C5D8:
		move.l	($FFFFEE00).w,($FFFFEE08).w
		move.l	(Camera_Y_pos).w,($FFFFEE0C).w
		moveq	#0,d0
		move.w	d0,($FFFFEEB4).w
		move.w	d0,($FFFFEEB6).w
		move.w	d0,($FFFFEEE2).w
		move.w	d0,($FFFFEEE4).w
		addq.b	#2,($FFFFEEDF).w
		rts
;--------------------------------------------------------------------------------
loc_C5FC:
		cmp.w	#$2BC0,($FFFFEE00).w
		bcs.s	loc_C616
		cmp.w	#$580,(Camera_Y_pos).w
		bcs.s	loc_C616
		addq.b	#2,($FFFFEEDF).w
		move.w	#0,($FFFFF662).w
loc_C616:
		move.w	($FFFFEEB0).w,($FFFFEEB4).w
		move.w	($FFFFEEB2).w,($FFFFEEB6).w
		move.w	($FFFFEE00).w,d0
		move.w	(Camera_Y_pos).w,d1
		bra.w	loc_C8E6
loc_C62E:
		cmp.w	#$800,($FFFFEEE2).w
		beq.s	loc_C63A
		addq.w	#2,($FFFFEEE2).w
loc_C63A:
		cmp.w	#$600,($FFFFEEE2).w
		blt.s	loc_C65A
		move.w	($FFFFF662).w,d0
		moveq	#4,d1
		cmp.w	#$840,d0
		bcc.s	loc_C654
		add.w	d1,d0
		move.w	d0,($FFFFF662).w
loc_C654:
		lsr.w	#8,d0
		add.w	d0,($FFFFEEE4).w
loc_C65A:
		move.w	($FFFFEEB0).w,($FFFFEEB4).w
		move.w	($FFFFEEB2).w,($FFFFEEB6).w
		move.w	($FFFFEE00).w,d0
		move.w	(Camera_Y_pos).w,d1
		bra.w	loc_C8E6
loc_C672:
		cmp.w	#$FD40,($FFFFEEE2).w
		beq.s	loc_C6A0
		sub.w	#2,($FFFFEEE2).w
		cmp.w	#$1B81,($FFFFEEE4).w
		beq.s	loc_C6A0
		move.w	($FFFFF662).w,d0
		beq.s	loc_C69A
		moveq	#4,d1
		neg.w	d1
		add.w	d1,d0
		move.w	d0,($FFFFF662).w
		lsr.w	#8,d0
loc_C69A:
		addq.w	#1,d0
		add.w	d0,($FFFFEEE4).w
loc_C6A0:
		move.w	($FFFFEEB0).w,($FFFFEEB4).w
		move.w	($FFFFEEB2).w,($FFFFEEB6).w
		move.w	($FFFFEE00).w,d0
		move.w	(Camera_Y_pos).w,d1
		bra.w	loc_C8E6
loc_C6B8:
		cmp.w	#$2880,($FFFFEE00).w
		bcs.s	loc_C6D8
		cmp.w	#$400,(Camera_Y_pos).w
		bcs.s	loc_C6D8
		addq.w	#2,($FFFFF660).w
		moveq	#$3E,d0
		bsr.w	J_LoadPLC_01 
		move.w	#$2880,(Camera_Min_X_pos).w
loc_C6D8:
		rts
;--------------------------------------------------------------------------------
loc_C6DA:
		cmp.w	#$4E0,(Camera_Y_pos).w
		bcs.s	loc_C6F0
		addq.w	#2,($FFFFF660).w
		st ($FFFFF7CC).w
		moveq	#$3F,d0
		bsr.w	J_LoadPLC_01 
loc_C6F0:
		rts
;--------------------------------------------------------------------------------
loc_C6F2:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_HTz: 
		tst.b	($FFFFFE11).w
		bne.w	DynResize_HTz_2 
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_C70A(pc,d0),d0
		jmp	loc_C70A(pc,d0)
loc_C70A:
		dc.w	loc_C710-loc_C70A
		dc.w	loc_C77C-loc_C70A
		dc.w	loc_C882-loc_C70A
loc_C710:
		cmp.w	#$400,(Camera_Y_pos).w
		bcs.s	loc_C758
		cmp.w	#$1800,($FFFFEE00).w
		bcs.s	loc_C758
		move.b	#1,($FFFFEEBC).w
		move.l	($FFFFEE00).w,($FFFFEE08).w
		move.l	(Camera_Y_pos).w,($FFFFEE0C).w
		moveq	#0,d0
		move.w	d0,($FFFFEEB4).w
		move.w	d0,($FFFFEEB6).w
		move.w	d0,($FFFFEEE2).w
		move.w	#$140,($FFFFEEE4).w
		sub.w	#$100,($FFFFEE0C).w
		move.w	#0,($FFFFEEE6).w
		addq.b	#2,($FFFFEEDF).w
loc_C756: 
		rts
;--------------------------------------------------------------------------------
loc_C758:
		tst.b	($FFFFEEBC).w
		beq.s	loc_C756
		move.w	#$200,d0
		moveq	#0,d1
		move.w	d1,($FFFFEEB4).w
		move.w	d1,($FFFFEEB6).w
		bsr.w	loc_C8E6
		or.w	d0,d1
		bne.s	loc_C756
		move.b	#0,($FFFFEEBC).w
		rts
;--------------------------------------------------------------------------------
loc_C77C:
		cmp.w	#$1978,($FFFFEE00).w
		bcs loc_C80E
		cmp.w	#$1E00,($FFFFEE00).w
		bcs.s	loc_C796
		move.b	#0,($FFFFEEBD).w
		bra.s	loc_C80E
loc_C796:
		tst.b	($FFFFEEE8).w
		bne.s	loc_C7C6
		cmp.w	#$140,($FFFFEEE4).w
		beq.s	loc_C7F0
		move.w	($FFFFFE04).w,d0
		move.w	d0,d1
		and.w	#3,d0
		bne.s	loc_C80E
		addq.w	#1,($FFFFEEE4).w
		and.w	#$3F,d1
		bne.s	loc_C80E
		move.w	#$E1,d0
		jsr	Play_Sfx
		bra.s	loc_C80E
loc_C7C6:
		cmp.w	#$E0,($FFFFEEE4).w
		beq.s	loc_C7F0
		move.w	($FFFFFE04).w,d0
		move.w	d0,d1
		and.w	#3,d0
		bne.s	loc_C80E
		subq.w	#1,($FFFFEEE4).w
		and.w	#$3F,d1
		bne.s	loc_C80E
		move.w	#$E1,d0
		jsr	Play_Sfx
		bra.s	loc_C80E
loc_C7F0:
		move.b	#0,($FFFFEEBD).w
		subq.w	#1,($FFFFEEE6).w
		bpl.s	loc_C80E
		move.w	#$78,($FFFFEEE6).w
		eor.b	#1,($FFFFEEE8).w
		move.b	#1,($FFFFEEBD).w
loc_C80E:
		cmp.w	#$1800,($FFFFEE00).w
		bcs.s	loc_C836
		cmp.w	#$1F00,($FFFFEE00).w
		bcc.s	loc_C85C
		move.w	($FFFFEEB0).w,($FFFFEEB4).w
		move.w	($FFFFEEB2).w,($FFFFEEB6).w
		move.w	($FFFFEE00).w,d0
		move.w	(Camera_Y_pos).w,d1
		bra.w	loc_C8E6
loc_C836:
		move.l	#$4000000,($FFFFEE08).w
		moveq	#0,d0
		move.l	d0,($FFFFEE0C).w
		move.l	d0,($FFFFEEE2).w
		move.b	d0,($FFFFEEE8).w
		subq.b	#2,($FFFFEEDF).w
		move.w	#$F8,d0
		jsr	Play_Sfx
		rts
;--------------------------------------------------------------------------------
loc_C85C:
		move.l	#$4000000,($FFFFEE08).w
		moveq	#0,d0
		move.l	d0,($FFFFEE0C).w
		move.l	d0,($FFFFEEE2).w
		move.b	d0,($FFFFEEE8).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F8,d0
		jsr	Play_Sfx
		rts
;--------------------------------------------------------------------------------
loc_C882:
		cmp.w	#$1F00,($FFFFEE00).w
		bcc.s	loc_C8C2
		move.b	#1,($FFFFEEBC).w
		move.l	($FFFFEE00).w,($FFFFEE08).w
		move.l	(Camera_Y_pos).w,($FFFFEE0C).w
		moveq	#0,d0
		move.w	d0,($FFFFEEB4).w
		move.w	d0,($FFFFEEB6).w
		move.w	d0,($FFFFEEE2).w
		move.w	#$140,($FFFFEEE4).w
		sub.w	#$100,($FFFFEE0C).w
		move.w	#0,($FFFFEEE6).w
		subq.b	#2,($FFFFEEDF).w
loc_C8C0: 
		rts
;--------------------------------------------------------------------------------
loc_C8C2:
		tst.b	($FFFFEEBC).w
		beq.s	loc_C8C0
		move.w	#$200,d0
		moveq	#0,d1
		move.w	d1,($FFFFEEB4).w
		move.w	d1,($FFFFEEB6).w
		bsr.w	loc_C8E6
		or.w	d0,d1
		bne.s	loc_C8C0
		move.b	#0,($FFFFEEBC).w
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_C8E6:
		sub.w	($FFFFEE08).w,d0
		sub.w	($FFFFEEE2).w,d0
		bpl.s	loc_C8FC
		cmp.w	#$FFF0,d0
		bgt.s	loc_C8FA
		move.w	#$FFF0,d0
loc_C8FA:
		bra.s	loc_C906
loc_C8FC:
		cmp.w	#$10,d0
		bcs.s	loc_C906
		move.w	#$10,d0
loc_C906:
		move.b	d0,($FFFFEEB4).w
		sub.w	($FFFFEE0C).w,d1
		sub.w	($FFFFEEE4).w,d1
		bpl.s	loc_C920
		cmp.w	#$FFF0,d1
		bgt.s	loc_C91E
		move.w	#$FFF0,d1
loc_C91E:
		bra.s	loc_C92A
loc_C920:
		cmp.w	#$10,d1
		bcs.s	loc_C92A
		move.w	#$10,d1
loc_C92A:
		move.b	d1,($FFFFEEB6).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Unk_Sub_0: 
		btst	#0,($FFFFF606).w
		beq.s	Unk_Sub_1 
		tst.w	($FFFFEEE4).w
		beq.s	Unk_Sub_1 
		subq.w	#1,($FFFFEEE4).w
Unk_Sub_1: 
		btst	#1,($FFFFF606).w
		beq.s	Unk_Exit 
		cmp.w	#$700,($FFFFEEE4).w
		beq.s	Unk_Exit 
		addq.w	#1,($FFFFEEE4).w
Unk_Exit: 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_HTz_2: 
		bsr.w	DynResize_HTz_Boss 
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_C96A(pc,d0),d0
		jmp	loc_C96A(pc,d0)
loc_C96A:
		dc.w	loc_C97C-loc_C96A
		dc.w	loc_C9FE-loc_C96A
		dc.w	loc_CB04-loc_C96A
		dc.w	loc_CB68-loc_C96A
		dc.w	loc_CC66-loc_C96A
		dc.w	loc_CCF2-loc_C96A
		dc.w	loc_CD18-loc_C96A
		dc.w	loc_CD56-loc_C96A
		dc.w	loc_CD8E-loc_C96A
loc_C97C:
		cmp.w	#$14C0,($FFFFEE00).w
		bcs.s	loc_C9DA
		move.b	#1,($FFFFEEBC).w
		move.l	($FFFFEE00).w,($FFFFEE08).w
		move.l	(Camera_Y_pos).w,($FFFFEE0C).w
		moveq	#0,d0
		move.w	d0,($FFFFEEB4).w
		move.w	d0,($FFFFEEB6).w
		move.w	d0,($FFFFEEE2).w
		move.w	#$2C0,($FFFFEEE4).w
		sub.w	#$100,($FFFFEE0C).w
		move.w	#0,($FFFFEEE6).w
		addq.b	#2,($FFFFEEDF).w
		cmp.w	#$380,(Camera_Y_pos).w
		bcs.s	loc_C9D8
		move.w	#$F980,($FFFFEEE2).w
		add.w	#$480,($FFFFEE08).w
		move.w	#$300,($FFFFEEE4).w
		addq.b	#6,($FFFFEEDF).w
loc_C9D8:
		rts
;--------------------------------------------------------------------------------
loc_C9DA:
		tst.b	($FFFFEEBC).w
		beq.s	loc_C9D8
		move.w	#$200,d0
		moveq	#0,d1
		move.w	d1,($FFFFEEB4).w
		move.w	d1,($FFFFEEB6).w
		bsr.w	loc_C8E6
		or.w	d0,d1
		bne.s	loc_C9D8
		move.b	#0,($FFFFEEBC).w
		rts
;--------------------------------------------------------------------------------
loc_C9FE:
		cmp.w	#$1678,($FFFFEE00).w
		bcs loc_CA90
		cmp.w	#$1A00,($FFFFEE00).w
		bcs.s	loc_CA18
		move.b	#0,($FFFFEEBD).w
		bra.s	loc_CA90
loc_CA18:
		tst.b	($FFFFEEE8).w
		bne.s	loc_CA48
		cmp.w	#$2C0,($FFFFEEE4).w
		beq.s	loc_CA72
		move.w	($FFFFFE04).w,d0
		move.w	d0,d1
		and.w	#3,d0
		bne.s	loc_CA90
		addq.w	#1,($FFFFEEE4).w
		and.w	#$3F,d1
		bne.s	loc_CA90
		move.w	#$E1,d0
		jsr	Play_Sfx
		bra.s	loc_CA90
loc_CA48:
		cmp.w	#0,($FFFFEEE4).w
		beq.s	loc_CA72
		move.w	($FFFFFE04).w,d0
		move.w	d0,d1
		and.w	#3,d0
		bne.s	loc_CA90
		subq.w	#1,($FFFFEEE4).w
		and.w	#$3F,d1
		bne.s	loc_CA90
		move.w	#$E1,d0
		jsr	Play_Sfx
		bra.s	loc_CA90
loc_CA72:
		move.b	#0,($FFFFEEBD).w
		subq.w	#1,($FFFFEEE6).w
		bpl.s	loc_CA90
		move.w	#$78,($FFFFEEE6).w
		eor.b	#1,($FFFFEEE8).w
		move.b	#1,($FFFFEEBD).w
loc_CA90:
		cmp.w	#$14C0,($FFFFEE00).w
		bcs.s	loc_CAB8
		cmp.w	#$1B00,($FFFFEE00).w
		bcc.s	loc_CADE
		move.w	($FFFFEEB0).w,($FFFFEEB4).w
		move.w	($FFFFEEB2).w,($FFFFEEB6).w
		move.w	($FFFFEE00).w,d0
		move.w	(Camera_Y_pos).w,d1
		bra.w	loc_C8E6
loc_CAB8:
		move.l	#$4000000,($FFFFEE08).w
		moveq	#0,d0
		move.l	d0,($FFFFEE0C).w
		move.l	d0,($FFFFEEE2).w
		move.b	d0,($FFFFEEE8).w
		subq.b	#2,($FFFFEEDF).w
		move.w	#$F8,d0
		jsr	Play_Sfx
		rts
;--------------------------------------------------------------------------------
loc_CADE:
		move.l	#$4000000,($FFFFEE08).w
		moveq	#0,d0
		move.l	d0,($FFFFEE0C).w
		move.l	d0,($FFFFEEE2).w
		move.b	d0,($FFFFEEE8).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F8,d0
		jsr	Play_Sfx
		rts
;--------------------------------------------------------------------------------
loc_CB04:
		cmp.w	#$1B00,($FFFFEE00).w
		bcc.s	loc_CB44
		move.b	#1,($FFFFEEBC).w
		move.l	($FFFFEE00).w,($FFFFEE08).w
		move.l	(Camera_Y_pos).w,($FFFFEE0C).w
		moveq	#0,d0
		move.w	d0,($FFFFEEB4).w
		move.w	d0,($FFFFEEB6).w
		move.w	d0,($FFFFEEE2).w
		move.w	#$2C0,($FFFFEEE4).w
		sub.w	#$100,($FFFFEE0C).w
		move.w	#0,($FFFFEEE6).w
		subq.b	#2,($FFFFEEDF).w
loc_CB42: 
		rts
;--------------------------------------------------------------------------------
loc_CB44:
		tst.b	($FFFFEEBC).w
		beq.s	loc_CB42
		move.w	#$200,d0
		moveq	#0,d1
		move.w	d1,($FFFFEEB4).w
		move.w	d1,($FFFFEEB6).w
		bsr.w	loc_C8E6
		or.w	d0,d1
		bne.s	loc_CB42
		move.b	#0,($FFFFEEBC).w
		rts
;--------------------------------------------------------------------------------
loc_CB68:
		cmp.w	#$15F0,($FFFFEE00).w
		bcs loc_CBF2
		cmp.w	#$1AC0,($FFFFEE00).w
		bcc.s	loc_CBF2
		tst.b	($FFFFEEE8).w
		bne.s	loc_CBAA
		cmp.w	#$300,($FFFFEEE4).w
		beq.s	loc_CBD4
		move.w	($FFFFFE04).w,d0
		move.w	d0,d1
		and.w	#3,d0
		bne.s	loc_CBF2
		addq.w	#1,($FFFFEEE4).w
		and.w	#$3F,d1
		bne.s	loc_CBF2
		move.w	#$E1,d0
		jsr	Play_Sfx
		bra.s	loc_CBF2
loc_CBAA:
		cmp.w	#0,($FFFFEEE4).w
		beq.s	loc_CBD4
		move.w	($FFFFFE04).w,d0
		move.w	d0,d1
		and.w	#3,d0
		bne.s	loc_CBF2
		subq.w	#1,($FFFFEEE4).w
		and.w	#$3F,d1
		bne.s	loc_CBF2
		move.w	#$E1,d0
		jsr	Play_Sfx
		bra.s	loc_CBF2
loc_CBD4:
		move.b	#0,($FFFFEEBD).w
		subq.w	#1,($FFFFEEE6).w
		bpl.s	loc_CBF2
		move.w	#$78,($FFFFEEE6).w
		eor.b	#1,($FFFFEEE8).w
		move.b	#1,($FFFFEEBD).w
loc_CBF2:
		cmp.w	#$14C0,($FFFFEE00).w
		bcs.s	loc_CC1A
		cmp.w	#$1B00,($FFFFEE00).w
		bcc.s	loc_CC40
		move.w	($FFFFEEB0).w,($FFFFEEB4).w
		move.w	($FFFFEEB2).w,($FFFFEEB6).w
		move.w	($FFFFEE00).w,d0
		move.w	(Camera_Y_pos).w,d1
		bra.w	loc_C8E6
loc_CC1A:
		move.l	#$4000000,($FFFFEE08).w
		moveq	#0,d0
		move.l	d0,($FFFFEE0C).w
		move.l	d0,($FFFFEEE2).w
		move.b	d0,($FFFFEEE8).w
		subq.b	#6,($FFFFEEDF).w
		move.w	#$F8,d0
		jsr	Play_Sfx
		rts
;--------------------------------------------------------------------------------
loc_CC40:
		move.l	#$4000000,($FFFFEE08).w
		moveq	#0,d0
		move.l	d0,($FFFFEE0C).w
		move.l	d0,($FFFFEEE2).w
		move.b	d0,($FFFFEEE8).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F8,d0
		jsr	Play_Sfx
		rts
;--------------------------------------------------------------------------------
loc_CC66:
		cmp.w	#$1B00,($FFFFEE00).w
		bcc.s	loc_CCAE
		move.b	#1,($FFFFEEBC).w
		move.l	($FFFFEE00).w,($FFFFEE08).w
		move.l	(Camera_Y_pos).w,($FFFFEE0C).w
		moveq	#0,d0
		move.w	d0,($FFFFEEB4).w
		move.w	d0,($FFFFEEB6).w
		move.w	#$F980,($FFFFEEE2).w
		add.w	#$480,($FFFFEE08).w
		move.w	#$300,($FFFFEEE4).w
		sub.w	#$100,($FFFFEE0C).w
		move.w	#0,($FFFFEEE6).w
		subq.b	#2,($FFFFEEDF).w
loc_CCAC: 
		rts
;--------------------------------------------------------------------------------
loc_CCAE:
		tst.b	($FFFFEEBC).w
		beq.s	loc_CCAC
		move.w	#$200,d0
		moveq	#0,d1
		move.w	d1,($FFFFEEB4).w
		move.w	d1,($FFFFEEB6).w
		bsr.w	loc_C8E6
		or.w	d0,d1
		bne.s	loc_CCAC
		move.b	#0,($FFFFEEBC).w
		rts
;--------------------------------------------------------------------------------
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_HTz_Boss: 
		cmp.w	#$2B00,($FFFFEE00).w
		bcs.s	loc_CCF0
		cmp.b	#$A,($FFFFEEDF).w
		bge.s	loc_CCF0
		move.b	#$A,($FFFFEEDF).w
		move.b	#0,($FFFFEEBC).w
loc_CCF0:
		rts
;--------------------------------------------------------------------------------
loc_CCF2:
		cmp.w	#$2C00,($FFFFEE00).w
		bcs.s	loc_CD16
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		move.w	#$480,(Camera_Max_Y_pos).w
		move.w	#$480,($FFFFEEFE).w
		addq.b	#2,($FFFFEEDF).w
loc_CD16:
		rts
;--------------------------------------------------------------------------------
loc_CD18:
		cmp.w	#$2EDF,($FFFFEE00).w
		bcs.s	loc_CD54
		move.w	#$2EE0,(Camera_Min_X_pos).w
		move.w	#$2F5E,(Camera_Max_X_pos).w
		move.w	#$2EE0,($FFFFEEF8).w
		move.w	#$2F5E,($FFFFEEFA).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F9,d0
		bsr.w	J_Play_Music 
		clr.b	($FFFFF73A).w
		move.b	#3,($FFFFF7AA).w
		moveq	#$2A,d0
		bra.w	J_LoadPLC_01 
loc_CD54:
		rts
;--------------------------------------------------------------------------------
loc_CD56:
		cmp.w	#$478,(Camera_Y_pos).w
		bcs.s	loc_CD6A
		move.w	#$478,(Camera_Min_Y_pos).w
		move.w	#$478,($FFFFEEFC).w
loc_CD6A:
		addq.b	#1,($FFFFF73A).w
		cmp.b	#$5A,($FFFFF73A).w
		bcs.s	loc_CD8C
		bsr.w	J_SingleObjectLoad 
		bne.s	loc_CD80
		move.b	#$52,(a1)
loc_CD80:
		addq.b	#2,($FFFFEEDF).w
		move.w	#$93,d0
		bsr.w	J_Play_Music 
loc_CD8C:
		rts
;--------------------------------------------------------------------------------
loc_CD8E:
		tst.b	($FFFFF7A7).w
		beq.s	loc_CDA6
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	(Camera_Max_X_pos).w,($FFFFEEFA).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
loc_CDA6:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_HPz: 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_Null_3: 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_OOz: 
		tst.b	($FFFFFE11).w
		bne.s	loc_CDB4
		rts
;--------------------------------------------------------------------------------
loc_CDB4:
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_CDC2(pc,d0),d0
		jmp	loc_CDC2(pc,d0)
loc_CDC2:
		dc.w	loc_CDCA-loc_CDC2
		dc.w	loc_CDF6-loc_CDC2
		dc.w	loc_CE34-loc_CDC2
		dc.w	loc_CE6C-loc_CDC2
loc_CDCA:
		cmp.w	#$2668,($FFFFEE00).w
		bcs.s	loc_CDF4
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		move.w	#$2D8,($FFFFB78C).w
		move.w	#$1E0,(Camera_Max_Y_pos).w
		move.w	#$1E0,($FFFFEEFE).w
		addq.b	#2,($FFFFEEDF).w
loc_CDF4:
		rts
;--------------------------------------------------------------------------------
loc_CDF6:
		cmp.w	#$2880,($FFFFEE00).w
		bcs.s	loc_CE32
		move.w	#$2880,(Camera_Min_X_pos).w
		move.w	#$28C0,(Camera_Max_X_pos).w
		move.w	#$2880,($FFFFEEF8).w
		move.w	#$28C0,($FFFFEEFA).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F9,d0
		bsr.w	J_Play_Music 
		clr.b	($FFFFF73A).w
		move.b	#8,($FFFFF7AA).w
		moveq	#$2F,d0
		bra.w	J_LoadPLC_01 
loc_CE32:
		rts
;--------------------------------------------------------------------------------
loc_CE34:
		cmp.w	#$1D8,(Camera_Y_pos).w
		bcs.s	loc_CE48
		move.w	#$1D8,(Camera_Min_Y_pos).w
		move.w	#$1D8,($FFFFEEFC).w
loc_CE48:
		addq.b	#1,($FFFFF73A).w
		cmp.b	#$5A,($FFFFF73A).w
		bcs.s	loc_CE6A
		bsr.w	J_SingleObjectLoad 
		bne.s	loc_CE5E
		move.b	#$55,(a1)
loc_CE5E:
		addq.b	#2,($FFFFEEDF).w
		move.w	#$93,d0
		bsr.w	J_Play_Music 
loc_CE6A:
		rts
;--------------------------------------------------------------------------------
loc_CE6C:
		tst.b	($FFFFF7A7).w
		beq.s	loc_CE84
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	(Camera_Max_X_pos).w,($FFFFEEFA).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
loc_CE84:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_DHz: 
		tst.b	($FFFFFE11).w
		bne.s	loc_CE8E
		rts
;--------------------------------------------------------------------------------
loc_CE8E:
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_CE9C(pc,d0),d0
		jmp	loc_CE9C(pc,d0)
loc_CE9C:
		dc.w	loc_CEA4-loc_CE9C
		dc.w	loc_CEDE-loc_CE9C
		dc.w	loc_CF4E-loc_CE9C
		dc.w	loc_CF86-loc_CE9C
loc_CEA4:
		tst.w	($FFFFFFD8).w
		bne.s	loc_CED0
		cmp.w	#$2080,($FFFFEE00).w
		bcs.s	loc_CECE
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		move.w	#$5D0,(Camera_Max_Y_pos).w
		move.w	#$5D0,($FFFFEEFE).w
		addq.b	#2,($FFFFEEDF).w
loc_CECE:
		rts
;--------------------------------------------------------------------------------
loc_CED0:
		move.w	#$2100,(Camera_Max_X_pos).w
		move.w	#$2100,($FFFFEEFA).w
		rts
;--------------------------------------------------------------------------------
loc_CEDE:
		cmp.w	#$20F0,($FFFFEE00).w
		bcs.s	loc_CF4C
		move.w	#$20F0,(Camera_Max_X_pos).w
		move.w	#$20F0,(Camera_Min_X_pos).w
		move.w	#$20F0,($FFFFEEFA).w
		move.w	#$20F0,($FFFFEEF8).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F9,d0
		bsr.w	J_Play_Music 
		clr.b	($FFFFF73A).w
		move.l	#$6C000002,(VDP_control_port)
		lea	(VDP_data_port),a6
		lea	(DHz_Boss_Rocks),a2 
		moveq	#7,d0
loc_CF26: 
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		move.l	(a2)+,(a6)
		dbra	d0,loc_CF26
		move.b	#5,($FFFFF7AA).w
		moveq	#$2C,d0
		bsr.w	J_LoadPLC_01 
		moveq	#$19,d0
		bsr.w	J_PalLoad2_01 
loc_CF4C:
		rts
;--------------------------------------------------------------------------------
loc_CF4E:
		cmp.w	#$5C8,(Camera_Y_pos).w
		bcs.s	loc_CF62
		move.w	#$5C8,(Camera_Min_Y_pos).w
		move.w	#$5C8,($FFFFEEFC).w
loc_CF62:
		addq.b	#1,($FFFFF73A).w
		cmp.b	#$5A,($FFFFF73A).w
		bcs.s	loc_CF84
		bsr.w	J_SingleObjectLoad 
		bne.s	loc_CF78
		move.b	#$57,(a1)
loc_CF78:
		addq.b	#2,($FFFFEEDF).w
		move.w	#$93,d0
		bsr.w	J_Play_Music 
loc_CF84:
		rts
;--------------------------------------------------------------------------------
loc_CF86:
		tst.b	($FFFFEEBD).w
		beq.s	loc_CF9E
		move.w	($FFFFFE04).w,d0
		and.w	#$1F,d0
		bne.s	loc_CF9E
		move.w	#$E1,d0
		bsr.w	J_Play_Sfx
loc_CF9E:
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	(Camera_Max_X_pos).w,($FFFFEEFA).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_CNz: 
		jsr	Load_Slot_Machine_Sprites 
		tst.b	($FFFFFE11).w
		bne.s	loc_CFC0
		rts
;--------------------------------------------------------------------------------
loc_CFC0:
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_CFCE(pc,d0),d0
		jmp	loc_CFCE(pc,d0)
loc_CFCE:
		dc.w	loc_CFD6-loc_CFCE
		dc.w	loc_D016-loc_CFCE
		dc.w	loc_D05A-loc_CFCE
		dc.w	loc_D092-loc_CFCE
loc_CFD6:
		tst.w	($FFFFFFD8).w
		bne.s	loc_D008
		cmp.w	#$27C0,($FFFFEE00).w
		bcs.s	loc_D006
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		move.w	#$62E,(Camera_Max_Y_pos).w
		move.w	#$62E,($FFFFEEFE).w
		move.b	#$F9,($FFFF8C54).w
		addq.b	#2,($FFFFEEDF).w
loc_D006:
		rts
;--------------------------------------------------------------------------------
loc_D008:
		move.w	#$26A0,(Camera_Max_X_pos).w
		move.w	#$26A0,($FFFFEEFA).w
		rts
;--------------------------------------------------------------------------------
loc_D016:
		cmp.w	#$2890,($FFFFEE00).w
		bcs.s	loc_D058
		move.b	#$F9,($FFFF8C50).w
		move.w	#$2860,(Camera_Min_X_pos).w
		move.w	#$28E0,(Camera_Max_X_pos).w
		move.w	#$2860,($FFFFEEF8).w
		move.w	#$28E0,($FFFFEEFA).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F9,d0
		bsr.w	J_Play_Music 
		clr.b	($FFFFF73A).w
		move.b	#6,($FFFFF7AA).w
		moveq	#$2D,d0
		bra.w	J_LoadPLC_01 
loc_D058:
		rts
;--------------------------------------------------------------------------------
loc_D05A:
		cmp.w	#$4E0,(Camera_Y_pos).w
		bcs.s	loc_D06E
		move.w	#$4E0,(Camera_Min_Y_pos).w
		move.w	#$4E0,($FFFFEEFC).w
loc_D06E:
		addq.b	#1,($FFFFF73A).w
		cmp.b	#$5A,($FFFFF73A).w
		bcs.s	loc_D090
		bsr.w	J_SingleObjectLoad 
		bne.s	loc_D084
		move.b	#$51,(a1)
loc_D084:
		addq.b	#2,($FFFFEEDF).w
		move.w	#$93,d0
		bsr.w	J_Play_Music 
loc_D090:
		rts
;--------------------------------------------------------------------------------
loc_D092:
		cmp.w	#$2A00,($FFFFEE00).w
		bcs.s	loc_D0B8
		move.w	#$5D0,(Camera_Max_Y_pos).w
		move.w	#$5D0,($FFFFEEFE).w
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	(Camera_Max_X_pos).w,($FFFFEEFA).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
loc_D0B8:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_CPz: 
		tst.b	($FFFFFE11).w
		bne.s	loc_D0C2
		rts
;--------------------------------------------------------------------------------
loc_D0C2:
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_D0D0(pc,d0),d0
		jmp	loc_D0D0(pc,d0)
loc_D0D0:
		dc.w	loc_D0D8-loc_D0D0
		dc.w	loc_D0FE-loc_D0D0
		dc.w	loc_D13C-loc_D0D0
		dc.w	loc_D174-loc_D0D0
loc_D0D8:
		cmp.w	#$2680,($FFFFEE00).w
		bcs.s	loc_D0FC
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		move.w	#$450,(Camera_Max_Y_pos).w
		move.w	#$450,($FFFFEEFE).w
		addq.b	#2,($FFFFEEDF).w
loc_D0FC:
		rts
;--------------------------------------------------------------------------------
loc_D0FE:
		cmp.w	#$2A20,($FFFFEE00).w
		bcs.s	loc_D13A
		move.w	#$2A20,(Camera_Min_X_pos).w
		move.w	#$2A20,(Camera_Max_X_pos).w
		move.w	#$2A20,($FFFFEEF8).w
		move.w	#$2A20,($FFFFEEFA).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F9,d0
		bsr.w	J_Play_Music 
		clr.b	($FFFFF73A).w
		move.b	#1,($FFFFF7AA).w
		moveq	#$28,d0
		bra.w	J_LoadPLC_01 
loc_D13A:
		rts
;--------------------------------------------------------------------------------
loc_D13C:
		cmp.w	#$448,(Camera_Y_pos).w
		bcs.s	loc_D150
		move.w	#$448,(Camera_Min_Y_pos).w
		move.w	#$448,($FFFFEEFC).w
loc_D150:
		addq.b	#1,($FFFFF73A).w
		cmp.b	#$5A,($FFFFF73A).w
		bcs.s	loc_D172
		bsr.w	J_SingleObjectLoad 
		bne.s	loc_D166
		move.b	#$5D,(a1)
loc_D166:
		addq.b	#2,($FFFFEEDF).w
		move.w	#$93,d0
		bsr.w	J_Play_Music 
loc_D172:
		rts
;--------------------------------------------------------------------------------
loc_D174:
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	(Camera_Max_X_pos).w,($FFFFEEFA).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_DEz: 
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_D196(pc,d0),d0
		jmp	loc_D196(pc,d0)
loc_D196:
		dc.w	loc_D1A0-loc_D196
		dc.w	loc_D1D2-loc_D196
		dc.w	loc_D1D4-loc_D196
		dc.w	loc_D1EE-loc_D196
		dc.w	loc_D210-loc_D196
loc_D1A0:
		move.w	#$140,d0
		cmp.w	($FFFFEE00).w,d0
		bhi.s	loc_D1D0
		addq.b	#2,($FFFFEEDF).w
		bsr.w	J_SingleObjectLoad 
		bne.s	loc_D1D0
		move.b	#$AF,(a1)
		move.b	#$48,$28(a1)
		move.w	#$348,8(a1)
		move.w	#$A0,$C(a1)
		moveq	#$30,d0
		bra.w	J_LoadPLC_01 
loc_D1D0:
		rts
;--------------------------------------------------------------------------------
loc_D1D2:
		rts
;--------------------------------------------------------------------------------
loc_D1D4:
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		cmp.w	#$300,($FFFFEE00).w
		bcs.s	loc_D1EC
		addq.b	#2,($FFFFEEDF).w
		moveq	#$31,d0
		bra.w	J_LoadPLC_01 
loc_D1EC:
		rts
;--------------------------------------------------------------------------------
loc_D1EE:
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	#$680,d0
		cmp.w	($FFFFEE00).w,d0
		bhi.s	loc_D20E
		addq.b	#2,($FFFFEEDF).w
		move.w	d0,(Camera_Min_X_pos).w
		add.w	#$C0,d0
		move.w	d0,(Camera_Max_X_pos).w
loc_D20E:
		rts
;--------------------------------------------------------------------------------
loc_D210:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_NGHz: 
		tst.b	($FFFFFE11).w
		bne.s	loc_D21A
		rts
;--------------------------------------------------------------------------------
loc_D21A:
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_D228(pc,d0),d0
		jmp	loc_D228(pc,d0)
loc_D228:
		dc.w	loc_D230-loc_D228
		dc.w	loc_D262-loc_D228
		dc.w	loc_D29E-loc_D228
		dc.w	loc_D2CC-loc_D228
loc_D230:
		cmp.w	#$2800,($FFFFEE00).w
		bcs.s	loc_D260
		move.w	#$2800,(Camera_Min_X_pos).w
		move.w	#$400,(Camera_Max_Y_pos).w
		move.w	#$2800,($FFFFEEF8).w
		move.w	#$400,($FFFFEEFE).w
		addq.b	#2,($FFFFEEDF).w
		move.b	#4,($FFFFF7AA).w
		moveq	#$2B,d0
		bsr.w	J_LoadPLC_01 
loc_D260:
		rts
;--------------------------------------------------------------------------------
loc_D262:
		cmp.w	#$2A40,($FFFFEE00).w
		bcs.s	loc_D29C
		move.w	#$2A40,(Camera_Max_X_pos).w
		move.w	#$2A40,(Camera_Min_X_pos).w
		move.w	#$2A40,($FFFFEEFA).w
		move.w	#$2A40,($FFFFEEF8).w
		addq.b	#2,($FFFFEEDF).w
		move.w	#$F9,d0
		bsr.w	J_Play_Music 
		clr.b	($FFFFF73A).w
		bsr.w	J_SingleObjectLoad 
		bne.s	loc_D29C
		move.b	#$89,(a1)
loc_D29C:
		rts
;--------------------------------------------------------------------------------
loc_D29E:
		cmp.w	#$3F8,(Camera_Y_pos).w
		bcs.s	loc_D2B2
		move.w	#$3F8,(Camera_Min_Y_pos).w
		move.w	#$3F8,($FFFFEEFC).w
loc_D2B2:
		addq.b	#1,($FFFFF73A).w
		cmp.b	#$5A,($FFFFF73A).w
		bcs.s	loc_D2CA
		addq.b	#2,($FFFFEEDF).w
		move.w	#$93,d0
		bsr.w	J_Play_Music 
loc_D2CA:
		rts
;--------------------------------------------------------------------------------
loc_D2CC:
		move.w	($FFFFEE00).w,(Camera_Min_X_pos).w
		move.w	(Camera_Max_X_pos).w,($FFFFEEFA).w
		move.w	($FFFFEE00).w,($FFFFEEF8).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
DynResize_SCz: 
		tst.b	($FFFFFE11).w
		bne.w	loc_D366
		moveq	#0,d0
		move.b	($FFFFEEDF).w,d0
		move.w	loc_D2F6(pc,d0),d0
		jmp	loc_D2F6(pc,d0)
loc_D2F6:
		dc.w	loc_D300-loc_D2F6
		dc.w	loc_D312-loc_D2F6
		dc.w	loc_D332-loc_D2F6
		dc.w	loc_D34C-loc_D2F6
		dc.w	loc_D364-loc_D2F6
loc_D300:
		move.w	#1,($FFFFF736).w
		move.w	#0,($FFFFF738).w
		addq.b	#2,($FFFFEEDF).w
		rts
;--------------------------------------------------------------------------------
loc_D312:
		cmp.w	#$1180,($FFFFEE00).w
		bcs.s	loc_D330
		move.w	#$FFFF,($FFFFF736).w
		move.w	#1,($FFFFF738).w
		move.w	#$500,(Camera_Max_Y_pos).w
		addq.b	#2,($FFFFEEDF).w
loc_D330:
		rts
;--------------------------------------------------------------------------------
loc_D332:
		cmp.w	#$500,(Camera_Y_pos).w
		bcs.s	loc_D34A
		move.w	#1,($FFFFF736).w
		move.w	#0,($FFFFF738).w
		addq.b	#2,($FFFFEEDF).w
loc_D34A:
		rts
;--------------------------------------------------------------------------------
loc_D34C:
		cmp.w	#$1480,($FFFFEE00).w
		bcs.s	loc_D364
		move.w	#0,($FFFFF736).w
		move.w	#0,($FFFFF738).w
		addq.b	#2,($FFFFEEDF).w
loc_D364:
		rts
;--------------------------------------------------------------------------------
loc_D366:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Dynamic Screen Size Boss
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Boss Defeated Music Restore
; [ Begin ]
;===============================================================================
Boss_Defeated_Music_Restore: 
		move.w	($FFFFFF90).w,d0
		bra.w	J_Play_Music 
;===============================================================================
; Sub Routine Boss Defeated Music Restore
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Boss Defeated Load Flickies
; [ Begin ]
;===============================================================================
Boss_Defeated_Load_Flickies 
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		lea	(Flickies_Select_Array),a2 
		move.b	0(a2,d0),d0
		bsr.w	J_LoadPLC_01 
		moveq	#$41,d0
		bsr.w	J_LoadPLC_01 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Boss Defeated Load Flickies
; [ End ]
;===============================================================================

J_SingleObjectLoad: 
		jmp	SingleObjectLoad 
J_Play_Sfx:
		jmp	Play_Sfx
J_PalLoad2_01: 
		jmp	PalLoad2 
J_LoadPLC_01: 
		jmp	LoadPLC 
J_Play_Music: 
		jmp	Play_Music 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x11_Bridge: 
		include 'objects/obj_0x11.asm'
loc_D9C8:
		jmp	(loc_15DD4)
loc_D9CE:
		jmp	CalcSine 
;------------------------------------------------------------------------------- 
Obj_0x15_Swing_Platform: 
		include 'objects/obj_0x15.asm'
		nop ; Filler
loc_E030:
		jmp	(loc_15D1A)
loc_E036:
		jmp	CalcSine 
loc_E03C:
		jmp	(loc_1AD98) 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x17: 
		include 'objects/obj_0x17.asm'
		nop ; Filler
;------------------------------------------------------------------------------- 
Obj_0x18_Platforms 
		include 'objects/obj_0x18.asm'
		nop ; Filler
loc_E5DC:
		jmp	CalcSine 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x1A_Collapsing_Platforms:
		include 'objects/obj_0x1A.asm'
;------------------------------------------------------------------------------- 
Obj_0x1F_Collapsing_Platforms:
		include 'objects/obj_0x1F.asm'
		nop ; Filler
;------------------------------------------------------------------------------- 
Obj_0x1C_Misc: 
		include 'objects/obj_0x1C.asm'
;------------------------------------------------------------------------------- 
Obj_0x71_Mz_Hpz_Misc: 
		include 'objects/obj_0x71.asm'
;------------------------------------------------------------------------------- 
HTz_Misc_Mappings: 
		dc.w	loc_F0F6-HTz_Misc_Mappings
		dc.w	loc_F100-HTz_Misc_Mappings
loc_F0F6:
		dc.w	$1
		dc.l	$F8050002,$1FFF8
loc_F100:
		dc.w	$1
		dc.l	$F8050006,$3FFF8
;-------------------------------------------------------------------------------
loc_F10A:
		dc.w	loc_F10E-loc_F10A
		dc.w	loc_F118-loc_F10A
loc_F10E:
		dc.w	$1
		dc.l	$F8010000,$FFFC
loc_F118:
		dc.w	$1
		dc.l	$F8010002,$1FFFC
;-------------------------------------------------------------------------------
OOz_Misc_Mappings: 
		dc.w	loc_F12E-OOz_Misc_Mappings
		dc.w	loc_F138-OOz_Misc_Mappings
		dc.w	loc_F142-OOz_Misc_Mappings
		dc.w	loc_F154-OOz_Misc_Mappings
		dc.w	loc_F16E-OOz_Misc_Mappings
		dc.w	loc_F190-OOz_Misc_Mappings
loc_F12E:
		dc.w	$1
		dc.l	$F8010000,$FFFC
loc_F138:
		dc.w	$1
		dc.l	$F0030000,$FFFC
loc_F142:
		dc.w	$2
		dc.l	$E8010000,$FFFC,$F8030000,$FFFC
loc_F154:
		dc.w	$3
		dc.l	$D0030000,$FFFC,$F0030000,$FFFC
		dc.l	$10030000,$FFFC
loc_F16E:
		dc.w	$4
		dc.l	$C0030000,$FFFC,$E0030000,$FFFC
		dc.l	$30000,$FFFC,$20030000,$FFFC
loc_F190:
		dc.w	$7
		dc.l	$98000004,$2FFFC,$A0030000,$FFFC
		dc.l	$C0030000,$FFFC,$E0030000,$FFFC
		dc.l	$30000,$FFFC,$20030000,$FFFC
		dc.l	$40030000,$FFFC 
		
;------------------------------------------------------------------------------- 
OOz_Misc_Mappings_01: 
		dc.w	loc_F1D4-OOz_Misc_Mappings_01
		dc.w	loc_F1E6-OOz_Misc_Mappings_01
		dc.w	loc_F208-OOz_Misc_Mappings_01
		dc.w	loc_F222-OOz_Misc_Mappings_01
		dc.w	loc_F244-OOz_Misc_Mappings_01
loc_F1D4:
		dc.w	$2
		dc.l	$F0070005,$2FFE8,$F0070005,$20008
loc_F1E6:
		dc.w	$4
		dc.l	$E0070005,$2FFE8,$E0070005,$20008
		dc.l	$70005,$2FFE8,$70005,$20008
loc_F208:
		dc.w	$3
		dc.l	$D0070005,$2FFF8,$F0070005,$2FFF8
		dc.l	$10070005,$2FFF8
loc_F222:
		dc.w	$4
		dc.l	$C0070005,$2FFF8,$E0070005,$2FFF8
		dc.l	$70005,$2FFF8,$20070005,$2FFF8
loc_F244:
		dc.w	$5
		dc.l	$B0070005,$2FFF8,$D0070005,$2FFF8
		dc.l	$F0070005,$2FFF8,$10070005,$2FFF8
		dc.l	$30070005,$2FFF8 
;------------------------------------------------------------------------------- 
Mz_Misc_Mappings: 
		dc.w	loc_F274-Mz_Misc_Mappings
		dc.w	loc_F27E-Mz_Misc_Mappings
		dc.w	loc_F288-Mz_Misc_Mappings
loc_F274:
		dc.w	$1
		dc.l	$F8010004,$2FFFC
loc_F27E:
		dc.w	$1
		dc.l	$F8010006,$3FFFC
loc_F288:
		dc.w	$1
		dc.l	$FC0C0000,$FFF0 
;------------------------------------------------------------------------------- 
Mz_Lava_Bubble_Mappings: 
		dc.w	loc_F2A0-Mz_Lava_Bubble_Mappings
		dc.w	loc_F2AA-Mz_Lava_Bubble_Mappings
		dc.w	loc_F2B4-Mz_Lava_Bubble_Mappings
		dc.w	loc_F2BE-Mz_Lava_Bubble_Mappings
		dc.w	loc_F2C8-Mz_Lava_Bubble_Mappings
		dc.w	loc_F2D2-Mz_Lava_Bubble_Mappings
		dc.w	loc_F2DC-Mz_Lava_Bubble_Mappings
loc_F2A0:
		dc.w	$1
		dc.l	$2040000,$FFF8
loc_F2AA:
		dc.w	$1
		dc.l	$40000,$FFF8
loc_F2B4:
		dc.w	$1
		dc.l	$FE040000,$FFF8
loc_F2BE:
		dc.w	$1
		dc.l	$FC040000,$FFF8
loc_F2C8:
		dc.w	$1
		dc.l	$FC080002,$1FFF4
loc_F2D2:
		dc.w	$1
		dc.l	$FC0C0005,$2FFF0
loc_F2DC:
		dc.w	$0 
		nop ; Filler
;------------------------------------------------------------------------------- 
Obj_0x2A_Up_Down_Pillar: 
		include 'objects/obj_0x2A.asm'
;------------------------------------------------------------------------------- 
Obj_0x2D_Automatic_Door: 
		include 'objects/obj_0x2D.asm'
		nop ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x28_Flickies: 
		include 'objects/obj_0x28.asm'
;------------------------------------------------------------------------------- 
Obj_0x29_Enemy_Points: 
		include 'objects/obj_0x29.asm'
;------------------------------------------------------------------------------- 
loc_FB30:
		dc.w	loc_FB40-loc_FB30
		dc.w	loc_FB4A-loc_FB30
		dc.w	loc_FB36-loc_FB30
loc_FB36:
		dc.w	$1
		dc.l	$EC070000,$FFF8
loc_FB40:
		dc.w	$1
		dc.l	$F8050008,$4FFF8
loc_FB4A:
		dc.w	$1
		dc.l	$F805000C,$6FFF8 
;-------------------------------------------------------------------------------
loc_FB54:
		dc.w	loc_FB64-loc_FB54
		dc.w	loc_FB6E-loc_FB54
		dc.w	loc_FB5A-loc_FB54
loc_FB5A:
		dc.w	$1
		dc.l	$EC070000,$FFF8
loc_FB64:
		dc.w	$1
		dc.l	$F8090008,$4FFF4
loc_FB6E:
		dc.w	$1
		dc.l	$F809000E,$7FFF4 
;------------------------------------------------------------------------------- 
loc_FB78:
		dc.w	loc_FB88-loc_FB78
		dc.w	loc_FB92-loc_FB78
		dc.w	loc_FB7E-loc_FB78
loc_FB7E:
		dc.w	$1
		dc.l	$F4060000,$FFF8
loc_FB88:
		dc.w	$1
		dc.l	$F8090006,$3FFF4
loc_FB92:
		dc.w	$1
		dc.l	$F809000C,$6FFF4
;------------------------------------------------------------------------------- 
loc_FB9C:
		dc.w	loc_FBAC-loc_FB9C
		dc.w	loc_FBB6-loc_FB9C
		dc.w	loc_FBA2-loc_FB9C
loc_FBA2:
		dc.w	$1
		dc.l	$F4060000,$FFF8
loc_FBAC:
		dc.w	$1
		dc.l	$F8050006,$3FFF8
loc_FBB6:
		dc.w	$1
		dc.l	$F805000A,$5FFF8 
;------------------------------------------------------------------------------- 
loc_FBC0:
		dc.w	loc_FBD0-loc_FBC0
		dc.w	loc_FBDA-loc_FBC0
		dc.w	loc_FBC6-loc_FBC0
loc_FBC6:
		dc.w	$1
		dc.l	$F4060000,$FFF8
loc_FBD0:
		dc.w	$1
		dc.l	$F4060006,$3FFF8
loc_FBDA:
		dc.w	$1
		dc.l	$F406000C,$6FFF8 
;------------------------------------------------------------------------------- 
Enemy_Points_Mappings: 
		dc.w	loc_FBF2-Enemy_Points_Mappings
		dc.w	loc_FBFC-Enemy_Points_Mappings
		dc.w	loc_FC06-Enemy_Points_Mappings
		dc.w	loc_FC10-Enemy_Points_Mappings
		dc.w	loc_FC22-Enemy_Points_Mappings
		dc.w	loc_FC2C-Enemy_Points_Mappings
		dc.w	loc_FC3E-Enemy_Points_Mappings
loc_FBF2:
		dc.w	$1
		dc.l	$F8050002,$1FFF8
loc_FBFC:
		dc.w	$1
		dc.l	$F8050006,$3FFF8
loc_FC06:
		dc.w	$1
		dc.l	$F805000A,$5FFF8
loc_FC10:
		dc.w	$2
		dc.l	$F8010000,$FFF8,$F805000E,$70000
loc_FC22:
		dc.w	$1
		dc.l	$F8010000,$FFFC
loc_FC2C:
		dc.w	$2
		dc.l	$F8050002,$1FFF0,$F805000E,$70000
loc_FC3E:
		dc.w	$2
		dc.l	$F805000A,$5FFF0,$F805000E,$70000 
;------------------------------------------------------------------------------- 
loc_FC50:
		jmp	PseudoRandomNumber 
		dc.w	$0 ; Filler
;-------------------------------------------------------------------------------
Obj_0x25_Rings: 
		include 'objects/obj_0x25.asm'
;===============================================================================
; Sub Routine loc_FCD6
; [ Begin ]
;===============================================================================
loc_FCD6:
		tst.b	$3F(a0)
		bne.s	loc_FD20
loc_FCDC:
		addq.w	#1,($FFFFFEF0).w
loc_FCE0: 
		addq.w	#1,(Ring_count).w
		or.b	#1,(Update_HUD_rings).w
		move.w	#$B5,d0
		cmp.w	#$64,(Ring_count).w
		bcs.s	loc_FD1A
		bset	#1,($FFFFFE1B).w
		beq.s	loc_FD0E
		cmp.w	#$C8,(Ring_count).w
		bcs.s	loc_FD1A
		bset	#2,($FFFFFE1B).w
		bne.s	loc_FD1A
loc_FD0E:
		addq.b	#1,(Life_count).w
		addq.b	#1,($FFFFFE1C).w
		move.w	#$98,d0
loc_FD1A:
		jmp	Play_Unknow 
;===============================================================================
; Sub Routine loc_FCD6
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine loc_FD20
; [ Begin ]
;===============================================================================
loc_FD20:
		addq.w	#1,($FFFFFED0).w
		addq.w	#1,($FFFFFEF2).w
		tst.w	($FFFFFFD8).w
		beq.s	loc_FCE0
		or.b	#1,($FFFFFEC9).w
		move.w	#$B5,d0
		cmp.w	#$64,($FFFFFED0).w
		bcs.s	loc_FD64
		bset	#1,($FFFFFEC7).w
		beq.s	loc_FD58
		cmp.w	#$C8,($FFFFFED0).w
		bcs.s	loc_FD64
		bset	#2,($FFFFFEC7).w
		bne.s	loc_FD64
loc_FD58:
		addq.b	#1,($FFFFFEC6).w
		addq.b	#1,($FFFFFEC8).w
		move.w	#$98,d0
loc_FD64:
		jmp	Play_Unknow 
;===============================================================================
; Sub Routine loc_FD20
; [ End ]
;===============================================================================
Obj_0x37_Rings_Out: 
		include 'objects/obj_0x37.asm'
;------------------------------------------------------------------------------- 
Obj_S1_0x4B_Big_Ring: 
		include 'objects/objs1_4B.asm'
;-------------------------------------------------------------------------------
Obj_S1_0x7C_Big_Ring_Flash: 
		include 'objects/objs1_7C.asm'
;-------------------------------------------------------------------------------
Rings_Animate_Data: 
		dc.w	loc_1006E-Rings_Animate_Data
loc_1006E:
		dc.b	$5,$4,$5,$6,$7,$FC 
;-------------------------------------------------------------------------------
Rings_Mappings: 
		dc.w	loc_10086-Rings_Mappings
		dc.w	loc_10090-Rings_Mappings
		dc.w	loc_1009A-Rings_Mappings
		dc.w	loc_100A4-Rings_Mappings
		dc.w	loc_100AE-Rings_Mappings
		dc.w	loc_100B8-Rings_Mappings
		dc.w	loc_100C2-Rings_Mappings
		dc.w	loc_100CC-Rings_Mappings
		dc.w	loc_100D6-Rings_Mappings
loc_10086:
		dc.w	$1
		dc.l	$F8050000,$FFF8
loc_10090:
		dc.w	$1
		dc.l	$F8050004,$2FFF8
loc_1009A:
		dc.w	$1
		dc.l	$F8010008,$4FFFC
loc_100A4:
		dc.w	$1
		dc.l	$F8050804,$802FFF8
loc_100AE:
		dc.w	$1
		dc.l	$F805000A,$5FFF8
loc_100B8:
		dc.w	$1
		dc.l	$F805180A,$1805FFF8
loc_100C2:
		dc.w	$1
		dc.l	$F805080A,$805FFF8
loc_100CC:
		dc.w	$1
		dc.l	$F805100A,$1005FFF8
loc_100D6:
		dc.w	$0
;------------------------------------------------------------------------------- 
Big_Ring_Mappings: 
		dc.w	loc_100E0-Big_Ring_Mappings
		dc.w	loc_10132-Big_Ring_Mappings
		dc.w	loc_10174-Big_Ring_Mappings
		dc.w	loc_10196-Big_Ring_Mappings
loc_100E0:
		dc.w	$A
		dc.l	$E0080000,$FFE8,$E0080003,$10000
		dc.l	$E80C0006,$3FFE0,$E80C000A,$50000
		dc.l	$F007000E,$7FFE0,$F0070016,$B0010
		dc.l	$100C001E,$FFFE0,$100C0022,$110000
		dc.l	$18080026,$13FFE8,$18080029,$140000
loc_10132:
		dc.w	$8
		dc.l	$E00C002C,$16FFF0,$E8080030,$18FFE8
		dc.l	$E8090033,$190000,$F0070039,$1CFFE8
		dc.l	$F8050041,$200008,$8090045,$220000
		dc.l	$1008004B,$25FFE8,$180C004E,$27FFF0
loc_10174:
		dc.w	$4
		dc.l	$E0070052,$29FFF4,$E0030852,$8290004
		dc.l	$7005A,$2DFFF4,$3085A,$82D0004
loc_10196:
		dc.w	$8
		dc.l	$E00C082C,$816FFF0,$E8080830,$8180000
		dc.l	$E8090833,$819FFE8,$F0070839,$81C0008
		dc.l	$F8050841,$820FFE8,$8090845,$822FFE8
		dc.l	$1008084B,$8250000,$180C084E,$827FFF0
;------------------------------------------------------------------------------- 
Big_Ring_Flash_Mappings: 
		dc.w	loc_101E8-Big_Ring_Flash_Mappings
		dc.w	loc_101FA-Big_Ring_Flash_Mappings
		dc.w	loc_1021C-Big_Ring_Flash_Mappings
		dc.w	loc_1023E-Big_Ring_Flash_Mappings
		dc.w	loc_10260-Big_Ring_Flash_Mappings
		dc.w	loc_10282-Big_Ring_Flash_Mappings
		dc.w	loc_102A4-Big_Ring_Flash_Mappings
		dc.w	loc_102B6-Big_Ring_Flash_Mappings
loc_101E8:
		dc.w	$2
		dc.l	$E00F0000,$0,$F1000,$10000000
loc_101FA:
		dc.w	$4
		dc.l	$E00F0010,$8FFF0,$E0070020,$100010
		dc.l	$F1010,$1008FFF0,$71020,$10100010
loc_1021C:
		dc.w	$4
		dc.l	$E00F0028,$14FFE8,$E00B0038,$1C0008
		dc.l	$F1028,$1014FFE8,$B1038,$101C0008
loc_1023E:
		dc.w	$4
		dc.l	$E00F0834,$81AFFE0,$E00F0034,$1A0000
		dc.l	$F1834,$181AFFE0,$F1034,$101A0000
loc_10260:
		dc.w	$4
		dc.l	$E00B0838,$81CFFE0,$E00F0828,$814FFF8
		dc.l	$B1838,$181CFFE0,$F1828,$1814FFF8
loc_10282:
		dc.w	$4
		dc.l	$E0070820,$810FFE0,$E00F0810,$808FFF0
		dc.l	$71820,$1810FFE0,$F1810,$1808FFF0
loc_102A4:
		dc.w	$2
		dc.l	$E00F0800,$800FFE0,$F1800,$1800FFE0
loc_102B6:
		dc.w	$4
		dc.l	$E00F0044,$22FFE0,$E00F0844,$8220000
		dc.l	$F1044,$1022FFE0,$F1844,$18220000
;------------------------------------------------------------------------------- 
loc_102D8:
		jmp	CalcSine 
		dc.w	$0 ; Filler
Obj_0x26_Monitors: 
		include 'objects/obj_0x26.asm'
Obj_0x2E_Monitors_Contents: 
		include 'objects/obj_0x2E.asm'
Monitors_AnimateData: 
		dc.w	loc_108A2-Monitors_AnimateData
		dc.w	loc_108A6-Monitors_AnimateData
		dc.w	loc_108AE-Monitors_AnimateData
		dc.w	loc_108B6-Monitors_AnimateData
		dc.w	loc_108BE-Monitors_AnimateData
		dc.w	loc_108C6-Monitors_AnimateData
		dc.w	loc_108CE-Monitors_AnimateData
		dc.w	loc_108D6-Monitors_AnimateData
		dc.w	loc_108DE-Monitors_AnimateData
		dc.w	loc_108E6-Monitors_AnimateData
		dc.w	loc_108EE-Monitors_AnimateData
loc_108A2:
		dc.b	$1,$0,$1,$FF
loc_108A6:
		dc.b	$1,$0,$2,$2,$1,$2,$2,$FF
loc_108AE:
		dc.b	$1,$0,$3,$3,$1,$3,$3,$FF
loc_108B6:
		dc.b	$1,$0,$4,$4,$1,$4,$4,$FF
loc_108BE:
		dc.b	$1,$0,$5,$5,$1,$5,$5,$FF
loc_108C6:
		dc.b	$1,$0,$6,$6,$1,$6,$6,$FF
loc_108CE:
		dc.b	$1,$0,$7,$7,$1,$7,$7,$FF
loc_108D6:
		dc.b	$1,$0,$8,$8,$1,$8,$8,$FF
loc_108DE:
		dc.b	$1,$0,$9,$9,$1,$9,$9,$FF
loc_108E6:
		dc.b	$1,$0,$A,$A,$1,$A,$A,$FF
loc_108EE:
		dc.b	$2,$0,$1,$B,$FE,$1 
Monitors_Mappings: 
		dc.w	loc_1090C-Monitors_Mappings
		dc.w	loc_10916-Monitors_Mappings
		dc.w	loc_10928-Monitors_Mappings
		dc.w	loc_1093A-Monitors_Mappings
		dc.w	loc_1094C-Monitors_Mappings
		dc.w	loc_1095E-Monitors_Mappings
		dc.w	loc_10970-Monitors_Mappings
		dc.w	loc_10982-Monitors_Mappings
		dc.w	loc_10994-Monitors_Mappings
		dc.w	loc_109A6-Monitors_Mappings
		dc.w	loc_109B8-Monitors_Mappings
		dc.w	loc_109CA-Monitors_Mappings
loc_1090C:
		dc.w	$1
		dc.l	$EF0F0000,$FFF0
loc_10916:
		dc.w	$2
		dc.l	$F5050018,$CFFF8,$EF0F0000,$FFF0
loc_10928:
		dc.w	$2
		dc.l	$F5050154,$AAFFF8,$EF0F0000,$FFF0
loc_1093A:
		dc.w	$2
		dc.l	$F505001C,$EFFF8,$EF0F0000,$FFF0
loc_1094C:
		dc.w	$2
		dc.l	$F5050020,$10FFF8,$EF0F0000,$FFF0
loc_1095E:
		dc.w	$2
		dc.l	$F5052024,$2012FFF8,$EF0F0000,$FFF0
loc_10970:
		dc.w	$2
		dc.l	$F5050028,$14FFF8,$EF0F0000,$FFF0
loc_10982:
		dc.w	$2
		dc.l	$F505002C,$16FFF8,$EF0F0000,$FFF0
loc_10994:
		dc.w	$2
		dc.l	$F5050030,$18FFF8,$EF0F0000,$FFF0
loc_109A6:
		dc.w	$2
		dc.l	$F5050038,$1CFFF8,$EF0F0000,$FFF0
loc_109B8:
		dc.w	$2
		dc.l	$F5050034,$1AFFF8,$EF0F0000,$FFF0
loc_109CA:
		dc.w	$1
		dc.l	$FF0D0010,$8FFF0 
;===============================================================================
; Sub Routine Main_Level_Load_16_128_Blocks
; [ End ]
;=============================================================================== 

Obj_0x0E_Sonic_Miles
		include 'objects/obj_0x0E.asm'
Obj_0x0F_1Player2Vs: 
		include 'objects/obj_0x0F.asm'
;------------------------------------------------------------------------------- 
Unk_Sub_loc_10AC0:
		lea	(Unk_Animate_Data_loc_10AD8),a1
		bra.w	AnimateSprite 
;------------------------------------------------------------------------------- 
Unk_Animate_Data_loc_10ACA:
		dc.w	loc_10ACC-Unk_Animate_Data_loc_10ACA
loc_10ACC:
		dc.b	$7,$0,$1,$2,$3,$4,$5,$6,$7,$FE,$2,$0
;------------------------------------------------------------------------------- 
Unk_Animate_Data_loc_10AD8: 
		dc.w	loc_10ADA-Unk_Animate_Data_loc_10AD8
loc_10ADA:
		dc.b	$1F,$0,$1,$FF
;------------------------------------------------------------------------------- 
_1Player2Vs_Mappings: 
		dc.w	loc_10AE2-_1Player2Vs_Mappings
		dc.w	loc_10B1C-_1Player2Vs_Mappings
loc_10AE2:
		dc.w	$7
		dc.l	$F4000000,$FFD4,$F40C0001,$FFE4
		dc.l	$F4040005,$20004,$4002007,$2003FFD4
		dc.l	$40C2001,$2000FFE4,$4042005,$20020004
		dc.l	$4042008,$2004001C
loc_10B1C:
		dc.w	$7
		dc.l	$F4002000,$2000FFD4,$F40C2001,$2000FFE4
		dc.l	$F4042005,$20020004,$4000007,$3FFD4
		dc.l	$40C0001,$FFE4,$4040005,$20004
		dc.l	$4040008,$4001C 
		
Sonic_Miles_Mappings: 
		dc.w	Sonic_In_Title_Screen_Map-Sonic_Miles_Mappings 
		dc.w	Miles_In_Title_Screen_Map-Sonic_Miles_Mappings 
Sonic_In_Title_Screen_Map: 
		dc.w	$B 
		dc.l	$D40D0000,$FFD8,$CC0E0008,$4FFF8
		dc.l	$CC070014,$A0018,$E40F001C,$EFFE0
		dc.l	$E40B002C,$160000,$EC070038,$1C0018
		dc.l	$40F0040,$20FFD8,$40F0050,$28FFF8
		dc.l	$C060060,$300018,$24040066,$33FFE8
		dc.l	$240D0068,$34FFF8
Miles_In_Title_Screen_Map:
		dc.w	$A
		dc.l	$DC060070,$38FFEC,$F40F0076,$3BFFD4
		dc.l	$F40F0086,$43FFF4,$E4090096,$4BFFFC
		dc.l	$DC0B009C,$4E0014,$FC0800A8,$540014
		dc.l	$40500AB,$550014,$140400AF,$57FFD4
		dc.l	$140D00B1,$58FFE4,$140D00B9,$5C0004 
		nop ; Filler
;------------------------------------------------------------------------------- 
Obj_0x34_Title_Cards 
		include 'objects/obj_0x34.asm'
;------------------------------------------------------------------------------- 
Obj_0x39_Time_Over_Game_Over: 
		include 'objects/obj_0x39.asm'
;------------------------------------------------------------------------------- 
Obj_0x3A_Level_Results 
		include 'objects/obj_0x3A.asm'
;------------------------------------------------------------------------------- 
Obj_0x6F_Special_Stage_Results: 
		include 'objects/obj_0x6F.asm'
;------------------------------------------------------------------------------- 
Title_Cards_Mappings: 
		dc.w	loc_11600-Title_Cards_Mappings
		dc.w	loc_11600-Title_Cards_Mappings
		dc.w	loc_11600-Title_Cards_Mappings
		dc.w	loc_11600-Title_Cards_Mappings
		dc.w	loc_1165A-Title_Cards_Mappings
		dc.w	loc_1165A-Title_Cards_Mappings
		dc.w	loc_1193C-Title_Cards_Mappings
		dc.w	loc_116AC-Title_Cards_Mappings
		dc.w	loc_116E6-Title_Cards_Mappings
		dc.w	loc_11600-Title_Cards_Mappings
		dc.w	loc_11748-Title_Cards_Mappings
		dc.w	loc_1178A-Title_Cards_Mappings
		dc.w	loc_117DC-Title_Cards_Mappings
		dc.w	loc_11836-Title_Cards_Mappings
		dc.w	loc_1199E-Title_Cards_Mappings
		dc.w	loc_118A0-Title_Cards_Mappings
		dc.w	loc_118FA-Title_Cards_Mappings
		dc.w	loc_119E0-Title_Cards_Mappings
		dc.w	loc_11A02-Title_Cards_Mappings
		dc.w	loc_11A0C-Title_Cards_Mappings
		dc.w	loc_11A16-Title_Cards_Mappings
		dc.w	loc_11A20-Title_Cards_Mappings
		dc.w	loc_11A4A-Title_Cards_Mappings
loc_11600:
		dc.w	$B
		dc.l	$58580,$82C0FFC0,$985DE,$82EFFFD0
		dc.l	$58580,$82C0FFE8,$585E4,$82F2FFF8
		dc.l	$585E8,$82F40008,$585EC,$82F60018
		dc.l	$585F0,$82F80028,$585F4,$82FA0048
		dc.l	$185F8,$82FC0058,$585EC,$82F60060
		dc.l	$585EC,$82F60070
loc_1165A:
		dc.w	$A
		dc.l	$985DE,$82EFFFE0,$58580,$82C0FFF8
		dc.l	$585E4,$82F20008,$585E8,$82F40018
		dc.l	$58588,$82C40028,$585EC,$82F60038
		dc.l	$58588,$82C40048,$585F0,$82F80058
		dc.l	$185F4,$82FA0068,$585F6,$82FB0070
loc_116AC:
		dc.w	$7
		dc.l	$585DE,$82EF0008,$185E2,$82F10018
		dc.l	$585E4,$82F20020,$585E4,$82F20030
		dc.l	$585E8,$82F40050,$58588,$82C40060
		dc.l	$585EC,$82F60070
loc_116E6:
		dc.w	$C
		dc.l	$585DE,$82EFFFB8,$185E2,$82F1FFC8
		dc.l	$585E4,$82F2FFD0,$585E4,$82F2FFE0
		dc.l	$58580,$82C0FFF0,$58584,$82C20000
		dc.l	$585E8,$82F40020,$585EC,$82F60030
		dc.l	$585F0,$82F80040,$585EC,$82F60050
		dc.l	$585F4,$82FA0060,$58580,$82C00070
loc_11748:
		dc.w	$8
		dc.l	$58588,$82C4FFF8,$185DE,$82EF0008
		dc.l	$585E0,$82F00010,$58588,$82C40030
		dc.l	$585E4,$82F20040,$58580,$82C00050
		dc.l	$585E8,$82F40060,$58584,$82C20070
loc_1178A:
		dc.w	$A
		dc.l	$985DE,$82EFFFD0,$585E4,$82F2FFE8
		dc.l	$585E8,$82F4FFF8,$585EC,$82F60008
		dc.l	$185F0,$82F80018,$585F2,$82F90020
		dc.l	$585F2,$82F90040,$585F6,$82FB0050
		dc.l	$585FA,$82FD0060,$58580,$82C00070
loc_117DC:
		dc.w	$B
		dc.l	$585DE,$82EFFFD0,$585E2,$82F1FFE0
		dc.l	$585E6,$82F3FFF0,$185EA,$82F50000
		dc.l	$58584,$82C20008,$58588,$82C40018
		dc.l	$58584,$82C20038,$185EA,$82F50048
		dc.l	$585EC,$82F60050,$585F0,$82F80060
		dc.l	$585F4,$82FA0070
loc_11836:
		dc.w	$D
		dc.l	$585DE,$82EFFFA0,$585E2,$82F1FFB0
		dc.l	$58580,$82C0FFC0,$985E6,$82F3FFD0
		dc.l	$185EC,$82F6FFE8,$585DE,$82EFFFF0
		dc.l	$585EE,$82F70000,$585F2,$82F90010
		dc.l	$585F6,$82FB0030,$585F2,$82F90040
		dc.l	$585EE,$82F70050,$58584,$82C20060
		dc.l	$585FA,$82FD0070
loc_118A0:
		dc.w	$B
		dc.l	$585DE,$82EFFFD0,$585E2,$82F1FFE0
		dc.l	$585E6,$82F3FFF0,$585DE,$82EF0000
		dc.l	$585EA,$82F50010,$185EE,$82F70020
		dc.l	$585F0,$82F80028,$585F4,$82FA0048
		dc.l	$585E6,$82F30058,$185EE,$82F70068
		dc.l	$58584,$82C20070
loc_118FA:
		dc.w	$8
		dc.l	$585DE,$82EFFFF0,$585E2,$82F10000
		dc.l	$585E6,$82F30010,$585EA,$82F50030
		dc.l	$585EE,$82F70040,$585F2,$82F90050
		dc.l	$585DE,$82EF0060,$58580,$82C00070
loc_1193C:
		dc.w	$C
		dc.l	$985DE,$82EFFFB0,$185E4,$82F2FFC8
		dc.l	$58584,$82C2FFD0,$585E6,$82F3FFE0
		dc.l	$585EA,$82F50000,$58588,$82C40010
		dc.l	$585EE,$82F70020,$585F2,$82F90030
		dc.l	$585EE,$82F70040,$58580,$82C00050
		dc.l	$585F6,$82FB0060,$585F6,$82FB0070
loc_1199E:
		dc.w	$8
		dc.l	$585DE,$82EFFFF0,$58580,$82C00000
		dc.l	$585E2,$82F10010,$585E6,$82F30020
		dc.l	$585EA,$82F50030,$58580,$82C00050
		dc.l	$585EE,$82F70060,$585EE,$82F70070
loc_119E0:
		dc.w	$4
		dc.l	$5858C,$82C60001,$58588,$82C40010
		dc.l	$58584,$82C20020,$58580,$82C00030
loc_11A02:
		dc.w	$1
		dc.l	$7A590,$A2C80000
loc_11A0C:
		dc.w	$1
		dc.l	$BA598,$A2CC0000
loc_11A16:
		dc.w	$1
		dc.l	$BA5A4,$A2D20000
loc_11A20:
		dc.w	$5
		dc.l	$D85B0,$82D8FFB8,$D85B8,$82DCFFD8
		dc.l	$D85C0,$82E0FFF8,$D85C8,$82E40018
		dc.l	$585D0,$82E80038
loc_11A4A:
		dc.w	$7
		dc.l	$900385D4,$82EA0000,$B00385D4,$82EA0000
		dc.l	$D00385D4,$82EA0000,$F00385D4,$82EA0000
		dc.l	$100385D4,$82EA0000,$300385D4,$82EA0000
		dc.l	$500385D4,$82EA0000 
;-------------------------------------------------------------------------------
Time_Over_Game_Over_Mappings: 
		dc.w	loc_11A8C-Time_Over_Game_Over_Mappings
		dc.w	loc_11A9E-Time_Over_Game_Over_Mappings
		dc.w	loc_11AB0-Time_Over_Game_Over_Mappings
		dc.w	loc_11AC2-Time_Over_Game_Over_Mappings
loc_11A8C:
		dc.w	$2
		dc.l	$F80D0000,$FFB8,$F80D0008,$4FFD8
loc_11A9E:
		dc.w	$2
		dc.l	$F80D0014,$A0008,$F80D000C,$60028
loc_11AB0:
		dc.w	$2
		dc.l	$F809001C,$EFFC4,$F80D0008,$4FFDC
loc_11AC2:
		dc.w	$2
		dc.l	$F80D0014,$A000C,$F80D000C,$6002C
;-------------------------------------------------------------------------------
End_Level_Results_Mappings: 
		dc.w	loc_11AF0-End_Level_Results_Mappings
		dc.w	loc_11AF0-End_Level_Results_Mappings
		dc.w	loc_11AF0-End_Level_Results_Mappings
		dc.w	loc_11B32-End_Level_Results_Mappings
		dc.w	loc_11B6C-End_Level_Results_Mappings
		dc.w	loc_119E0-End_Level_Results_Mappings
		dc.w	loc_11A02-End_Level_Results_Mappings
		dc.w	loc_11A0C-End_Level_Results_Mappings
		dc.w	loc_11A16-End_Level_Results_Mappings
		dc.w	loc_11B8E-End_Level_Results_Mappings
		dc.w	loc_11BB8-End_Level_Results_Mappings
		dc.w	loc_11BEA-End_Level_Results_Mappings
		dc.w	loc_11C1C-End_Level_Results_Mappings
		dc.w	loc_11C26-End_Level_Results_Mappings
loc_11AF0:
		dc.w	$8
		dc.l	$585D0,$82E8FFC0,$58588,$82C4FFD0
		dc.l	$58584,$82C2FFE0,$185C0,$82E0FFF0
		dc.l	$585B4,$82DAFFF8,$585B8,$82DC0010
		dc.l	$58588,$82C40020,$585D4,$82EA0030
loc_11B32:
		dc.w	$7
		dc.l	$585D4,$82EAFFC8,$585BC,$82DEFFD8
		dc.l	$585CC,$82E6FFE8,$58588,$82C4FFF8
		dc.l	$585D8,$82EC0008,$585B8,$82DC0018
		dc.l	$585BC,$82DE0028
loc_11B6C:
		dc.w	$4
		dc.l	$585B0,$82D80000,$585B4,$82DA0010
		dc.l	$585D4,$82EA0020,$185DC,$82EE0030
loc_11B8E:
		dc.w	$5
		dc.l	$9A5E6,$A2F3FFB8,$5A5EC,$A2F6FFD0
		dc.l	$585F0,$82F8FFD4,$D8520,$82900038
		dc.l	$186F0,$83780058
loc_11BB8:
		dc.w	$6
		dc.l	$DA6DA,$A36DFFA4,$DA5DE,$A2EFFFCC
		dc.l	$1A6CA,$A365FFEC,$585F0,$82F8FFE8
		dc.l	$D8528,$82940038,$186F0,$83780058
loc_11BEA:
		dc.w	$6
		dc.l	$DA6D2,$A369FFA4,$DA5DE,$A2EFFFCC
		dc.l	$1A6CA,$A365FFEC,$585F0,$82F8FFE8
		dc.l	$D8530,$82980038,$186F0,$83780058
loc_11C1C:
		dc.w	$1
		dc.l	$685F4,$82FA0000
loc_11C26:
		dc.w	$1
		dc.l	$685FA,$82FD0000 
;-------------------------------------------------------------------------------
Special_Stage_Results_Mappings: 
		dc.w	loc_11C5C-Special_Stage_Results_Mappings
		dc.w	loc_11CBE-Special_Stage_Results_Mappings
		dc.w	loc_11CBE-Special_Stage_Results_Mappings
		dc.w	loc_11CBE-Special_Stage_Results_Mappings
		dc.w	loc_11D08-Special_Stage_Results_Mappings
		dc.w	loc_11D6A-Special_Stage_Results_Mappings
		dc.w	loc_11D74-Special_Stage_Results_Mappings
		dc.w	loc_11D7E-Special_Stage_Results_Mappings
		dc.w	loc_11D88-Special_Stage_Results_Mappings
		dc.w	loc_11D92-Special_Stage_Results_Mappings
		dc.w	loc_11D9C-Special_Stage_Results_Mappings
		dc.w	loc_11DA6-Special_Stage_Results_Mappings
		dc.w	loc_11DB0-Special_Stage_Results_Mappings
		dc.w	loc_11DD2-Special_Stage_Results_Mappings
		dc.w	loc_11E26-Special_Stage_Results_Mappings
		dc.w	loc_11E26-Special_Stage_Results_Mappings
		dc.w	loc_11E7A-Special_Stage_Results_Mappings
		dc.w	loc_11EAC-Special_Stage_Results_Mappings
		dc.w	loc_11DFC-Special_Stage_Results_Mappings
		dc.w	loc_11E50-Special_Stage_Results_Mappings
		dc.w	loc_11E50-Special_Stage_Results_Mappings
		dc.w	loc_11EDE-Special_Stage_Results_Mappings
loc_11C5C:
		dc.w	$C
		dc.l	$585B8,$82DCFFA0,$585B0,$82D8FFB0
		dc.l	$58580,$82C0FFC0,$58594,$82CAFFD0
		dc.l	$185A4,$82D2FFE0,$58590,$82C8FFE8
		dc.l	$585A6,$82D3FFF8,$585B8,$82DC0010
		dc.l	$585BC,$82DE0020,$58590,$82C8002D
		dc.l	$5859C,$82CE003D,$58580,$82C0004D
loc_11CBE:
		dc.w	$9
		dc.l	$585B8,$82DCFFB8,$58588,$82C4FFC8
		dc.l	$58584,$82C2FFD8,$185A4,$82D2FFE8
		dc.l	$58594,$82CAFFF0,$5859C,$82CE0008
		dc.l	$58588,$82C40018,$585BC,$82DE0028
		dc.l	$58590,$82C80040
loc_11D08:
		dc.w	$C
		dc.l	$58594,$82CAFF98,$585A0,$82D0FFA8
		dc.l	$58590,$82C8FFB8,$58588,$82C4FFC8
		dc.l	$585B8,$82DCFFD8,$58580,$82C0FFF0
		dc.l	$985AA,$82D50000,$58580,$82C00018
		dc.l	$585B4,$82DA0028,$58590,$82C80038
		dc.l	$585A6,$82D30048,$58598,$82CC0058
loc_11D6A:
		dc.w	$1
		dc.l	$5C6B0,$C3580000
loc_11D74:
		dc.w	$1
		dc.l	$5E6B0,$E3580000
loc_11D7E:
		dc.w	$1
		dc.l	$5C6B8,$C35C0000
loc_11D88:
		dc.w	$1
		dc.l	$5E6B8,$E35C0000
loc_11D92:
		dc.w	$1
		dc.l	$5E6B4,$E35A0000
loc_11D9C:
		dc.w	$1
		dc.l	$5C6B4,$C35A0000
loc_11DA6:
		dc.w	$1
		dc.l	$5A6B4,$A35A0000
loc_11DB0:
		dc.w	$4
		dc.l	$DA6CA,$A365FFA0,$1A6E0,$A370FFC0
		dc.l	$986E4,$83720028,$D86EA,$83750040
loc_11DD2:
		dc.w	$5
		dc.l	$1A6CA,$A365FFA0,$DA5D2,$A2E9FFA8
		dc.l	$DA6D2,$A369FFD0,$1A6CA,$A365FFF0
		dc.l	$D8528,$82940040
loc_11DFC:
		dc.w	$5
		dc.l	$1A6CA,$A365FFA0,$DA5D2,$A2E9FFA8
		dc.l	$DA6D2,$A369FFD0,$1A6CA,$A365FFF0
		dc.l	$186F0,$83780058
loc_11E26:
		dc.w	$5
		dc.l	$9A5F0,$A2F8FFA0,$5A5F6,$A2FBFFB8
		dc.l	$DA6D2,$A369FFD0,$1A6CA,$A365FFF0
		dc.l	$D8530,$82980040
loc_11E50:
		dc.w	$5
		dc.l	$9A5F0,$A2F8FFA0,$5A5F6,$A2FBFFB8
		dc.l	$DA6D2,$A369FFD0,$1A6CA,$A365FFF0
		dc.l	$186F0,$83780058
loc_11E7A:
		dc.w	$6
		dc.l	$9A5C8,$A2E4FFA0,$1A6CA,$A365FFB8
		dc.l	$DA5C0,$A2E0FFD0,$1A6CA,$A365FFF0
		dc.l	$D8520,$82900038,$186F0,$83780058
loc_11EAC:
		dc.w	$6
		dc.l	$DA5E2,$A2F1FF90,$9A5EA,$A2F5FFB0
		dc.l	$DA5C0,$A2E0FFD0,$1A6CA,$A365FFF0
		dc.l	$D8528,$82940038,$186F0,$83780058
loc_11EDE:
		dc.w	$2
		dc.l	$D8528,$82940038,$186F0,$83780058 
;===============================================================================
; Sub Routine Load_Title_Cards_Mappings
; [ Begin ]
;=============================================================================== 
Load_Title_Cards_Mappings: 
		lea	(VDP_data_port),a6
		tst.w	($FFFFB0BE).w
		bne.w	loc_11FDC
		moveq	#$3F,d5
		move.l	#$85DA85DA,d6
		tst.w	($FFFFFFD8).w
		beq.s	loc_11F14
		moveq	#$1F,d5
		move.l	#$82ED82ED,d6
loc_11F14:
		lea	($FFFFB176).w,a0
		moveq	#1,d7
loc_11F1A: 
		move.w	(a0)+,d0
		beq.s	loc_11F32
		clr.w	$FFFFFFFE(a0)
		jsr	loc_120FE(pc)
		move.l	d0,4(a6)
		move.w	d5,d4
loc_11F2C: 
		move.l	d6,(a6)
		dbra	d4,loc_11F2C
loc_11F32:
		dbra	d7,loc_11F1A
		moveq	#$26,d1
		sub.w	($FFFFB1BA).w,d1
		lsr.w	#1,d1
		subq.w	#1,d1
		moveq	#7,d5
		move.l	#$A5DCA5DC,d6
		tst.w	($FFFFFFD8).w
		beq.s	loc_11F56
		moveq	#3,d5
		move.l	#$A2EEA2EE,d6
loc_11F56:
		lea	($FFFFB1B6).w,a0
		moveq	#1,d7
loc_11F5C: 
		move.w	(a0)+,d0
		beq.s	loc_11F80
		clr.w	$FFFFFFFE(a0)
		jsr	loc_120FE(pc)
		move.w	d5,d4
loc_11F6A: 
		move.l	d0,4(a6)
		move.w	d1,d3
loc_11F70: 
		move.l	d6,(a6)
		dbra	d3,loc_11F70
		add.l	#$800000,d0
		dbra	d4,loc_11F6A
loc_11F80:
		dbra	d7,loc_11F5C
		move.w	($FFFFB1FA).w,d1
		subq.w	#1,d1
		moveq	#$D,d5
		move.l	#$85D885D8,d6
		tst.w	($FFFFFFD8).w
		beq.s	loc_11FA0
		moveq	#6,d5
		move.l	#$82EC82EC,d6
loc_11FA0:
		lea	($FFFFB1F6).w,a0
		moveq	#1,d7
		move.w	#$8F80,4(a6)
loc_11FAC: 
		move.w	(a0)+,d0
		beq.s	loc_11FD0
		clr.w	$FFFFFFFE(a0)
		jsr	loc_120FE(pc)
		move.w	d1,d4
loc_11FBA: 
		move.l	d0,4(a6)
		move.w	d5,d3
loc_11FC0: 
		move.l	d6,(a6)
		dbra	d3,loc_11FC0
		add.l	#$20000,d0
		dbra	d4,loc_11FBA
loc_11FD0:
		dbra	d7,loc_11FAC
		move.w	#$8F02,4(a6)
		rts
;--------------------------------------------------------------------------------
loc_11FDC:
		moveq	#9,d3
		moveq	#3,d4
		move.l	#$85DA85DA,d5
		move.l	#$A5DCA5DC,d6
		tst.w	($FFFFFFD8).w
		beq.s	loc_12002
		moveq	#4,d3
		moveq	#1,d4
		move.l	#$82ED82ED,d5
		move.l	#$A2EEA2EE,d6
loc_12002:
		lea	($FFFFB1F6).w,a0
		moveq	#1,d7
		move.w	#$8F80,4(a6)
loc_1200E: 
		move.w	(a0)+,d0
		beq.s	loc_1203A
		clr.w	$FFFFFFFE(a0)
		jsr	loc_120FE(pc)
		moveq	#3,d2
loc_1201C: 
		move.l	d0,4(a6)
		move.w	d3,d1
loc_12022: 
		move.l	d5,(a6)
		dbra	d1,loc_12022
		move.w	d4,d1
loc_1202A: 
		move.l	d6,(a6)
		dbra	d1,loc_1202A
		add.l	#$20000,d0
		dbra	d2,loc_1201C
loc_1203A:
		dbra	d7,loc_1200E
		move.w	#$8F02,4(a6)
		moveq	#7,d5
		move.l	#$85DA85DA,d6
		tst.w	($FFFFFFD8).w
		beq.s	loc_1205A
		moveq	#3,d5
		move.l	#$82ED82ED,d6
loc_1205A:
		lea	($FFFFB1B6).w,a0
		moveq	#1,d7
loc_12060: 
		move.w	(a0)+,d0
		beq.s	loc_12080
		clr.w	$FFFFFFFE(a0)
		jsr	loc_120FE(pc)
		move.w	d5,d4
loc_1206E: 
		move.l	d0,4(a6)
		move.l	d6,(a6)
		move.l	d6,(a6)
		add.l	#$800000,d0
		dbra	d4,loc_1206E
loc_12080:
		dbra	d7,loc_12060
		move.w	($FFFFB176).w,d4
		beq.s	loc_120F8
		lea	4(a6),a5
		tst.w	($FFFFFFD8).w
		beq.s	loc_120C4
		lea	($FFFFEE20).w,a3
		lea	($FFFF8000).w,a4
		move.w	#$6000,d2
		moveq	#1,d6
loc_120A2: 
		movem.l	d4-d6,-(sp)
		moveq	#$FFFFFFF0,d5
		move.w	d4,d1
		bsr.w	loc_C04A
		move.w	d1,d4
		moveq	#$FFFFFFF0,d5
		moveq	#$1F,d6
		bsr.w	loc_BD12
		movem.l	(sp)+,d4-d6
		add.w	#$10,d4
		dbra	d6,loc_120A2
loc_120C4:
		lea	($FFFFEE00).w,a3
		lea	($FFFF8000).w,a4
		move.w	#$4000,d2
		move.w	($FFFFB176).w,d4
		moveq	#1,d6
loc_120D6: 
		movem.l	d4-d6,-(sp)
		moveq	#$FFFFFFF0,d5
		move.w	d4,d1
		bsr.w	loc_C00E
		move.w	d1,d4
		moveq	#$FFFFFFF0,d5
		moveq	#$1F,d6
		bsr.w	loc_BD12
		movem.l	(sp)+,d4-d6
		add.w	#$10,d4
		dbra	d6,loc_120D6
loc_120F8:
		clr.w	($FFFFB176).w
		rts
;--------------------------------------------------------------------------------
loc_120FE: 
		and.l	#$FFFF,d0
		lsl.l	#2,d0
		lsr.w	#2,d0
		or.w	#$4000,d0
		swap.w	d0
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Load_Title_Cards_Mappings
; [ End ]
;===============================================================================
 
;===============================================================================
; Sub Routine Load_Title_Cards_Art
; [ Begin ]
;=============================================================================== 
TC_A = $4
TC_B = $404
TC_C = $804
TC_D = $C04
TC_F = $1004
TC_G = $1404
TC_H = $1804
TC_I = $1C02
TC_J = $1E04
TC_K = $2204
TC_L = $2604
TC_M = $2A06
TC_P = $3004
TC_Q = $3404
TC_R = $3804
TC_S = $3C04
TC_T = $4004
TC_U = $4404
TC_V = $4804
TC_W = $4C06
TC_X = $5204
TC_Y = $5604 
TC_Break = $FFFF

Load_Title_Cards_Art: 
		move.l	#$70000002,(VDP_control_port)
		lea	(Title_Card_ZONE_123),a0 
		bsr.w	loc_12244
		lea	($FFFF8000).w,a4
		lea	(Title_Card_AY),a0 
		bsr.w	loc_1224A
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		move.b	TC_Idx(pc,d0),d0 
		lea	TC_Loader(pc),a0 
		lea	0(a0,d0),a0
		move	#$2700,sr
		move.l	#$7BC00002,(VDP_control_port)
		lea	($FFFF8000).w,a1
		lea	(VDP_data_port),a6
loc_1215C: 
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_12178
		lsl.w	#5,d0
		lea	0(a1,d0),a2
		moveq	#0,d1
		move.b	(a0)+,d1
		lsl.w	#3,d1
		subq.w	#1,d1
loc_12170: 
		move.l	(a2)+,(a6)
		dbra	d1,loc_12170
		bra.s	loc_1215C
loc_12178:
		move	#$2300,sr
		rts
;--------------------------------------------------------------------------------
TC_Idx: 
		dc.b	Load_GHz-TC_Loader 
		dc.b	Load_GHz-TC_Loader 
		dc.b	Load_GHz-TC_Loader 
		dc.b	Load_GHz-TC_Loader 
		dc.b	Load_Mz-TC_Loader 
		dc.b	Load_Mz-TC_Loader 
		dc.b	Load_SFz-TC_Loader 
		dc.b	Load_HTz-TC_Loader 
		dc.b	Load_HPz-TC_Loader 
		dc.b	Load_GHz-TC_Loader 
		dc.b	Load_OOz-TC_Loader 
		dc.b	Load_DHz-TC_Loader 
		dc.b	Load_CNz-TC_Loader 
		dc.b	Load_CPz-TC_Loader 
		dc.b	Load_DEz-TC_Loader 
		dc.b	Load_NGHz-TC_Loader 
		dc.b	Load_SCz-TC_Loader 
		even 
TC_Loader: 
Load_GHz: 
		dc.w	TC_M,TC_R,TC_A,TC_L,TC_D,TC_H,TC_I,TC_Break 
Load_Mz: 
		dc.w	TC_M,TC_T,TC_R,TC_P,TC_L,TC_I,TC_S,TC_Break 
Load_HTz: 
		dc.w	TC_H,TC_I,TC_L,TC_T,TC_P,TC_Break 
Load_HPz: 
		dc.w	TC_H,TC_I,TC_D,TC_P,TC_A,TC_L,TC_C,TC_Break 
Load_OOz: 
		dc.w	TC_I,TC_L,TC_C,TC_A,TC_Break 
Load_DHz: 
		dc.w	TC_M,TC_Y,TC_S,TC_T,TC_I,TC_C,TC_A,TC_V,TC_Break 
Load_CNz: 
		dc.w	TC_C,TC_A,TC_S,TC_I,TC_G,TC_H,TC_T,TC_Break 
Load_CPz: 
		dc.w	TC_C,TC_H,TC_M,TC_I,TC_A,TC_L,TC_P,TC_T,TC_Break 
Load_NGHz: 
		dc.w	TC_A,TC_Q,TC_U,TC_T,TC_I,TC_C,TC_R,TC_Break 
Load_SCz: 
		dc.w	TC_S,TC_K,TC_Y,TC_C,TC_H,TC_A,TC_Break 
Load_SFz: 
		dc.w	TC_W,TC_I,TC_G,TC_F,TC_R,TC_T,TC_S,TC_Break 
Load_DEz: 
		dc.w	TC_D,TC_A,TC_T,TC_H,TC_G,TC_Break 
;===============================================================================
; Sub Routine Load_Title_Cards_Art
; [ End ]
;=============================================================================== 
 
loc_12244:
		jmp	NemesisDec 
loc_1224A:
		jmp	NemesisDec_ToRAM 
J_LoadPLC_02: 
		jmp	LoadPLC 
loc_12256:
		jmp	(loc_8F04) 
;------------------------------------------------------------------------------- 
Obj_0x36_Spikes: 
		include 'objects/obj_0x36.asm'
		nop ; Filler
;------------------------------------------------------------------------------- 
Obj_0x3B: 
		include 'objects/obj_0x3B.asm'
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x3C: 
		include 'objects/obj_0x3C.asm'
;===============================================================================
; Sub Routine loc_12770
; [ Begin ]
;=============================================================================== 
loc_12770:
		moveq	#0,d0
		move.b	$1A(a0),d0
		add.w	d0,d0
		move.l	4(a0),a3
		add.w	0(a3,d0),a3
		move.w	(a3)+,d1
		subq.w	#1,d1
		bset	#5,1(a0)
		move.b	0(a0),d4
		move.b	1(a0),d5
		move.l	a0,a1
		bra.s	loc_1279E
loc_12796: 
		bsr.w	S1SingleObjectLoad 
		bne.s	loc_127DA
		addq.w	#8,a3
loc_1279E:
		move.b	#4,$24(a1)
		move.b	d4,0(a1)
		move.l	a3,4(a1)
		move.b	d5,1(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	2(a0),2(a1)
		move.b	$18(a0),$18(a1)
		move.b	$19(a0),$19(a1)
		move.w	(a4)+,$10(a1)
		move.w	(a4)+,$12(a1)
		dbra	d1,loc_12796
loc_127DA:
		move.w	#$CB,d0
		jmp	Play_Sfx
;-------------------------------------------------------------------------------
loc_127E4:
		dc.w	$400,$FB00,$600,$FF00,$600,$100,$400,$500
		dc.w	$600,$FA00,$800,$FE00,$800,$200,$600,$600
;------------------------------------------------------------------------------- 
loc_12804:
		dc.w	$FA00,$FA00,$F800,$FE00,$F800,$200,$FA00,$600
		dc.w	$FC00,$FB00,$FA00,$FF00,$FA00,$100,$FC00,$500
;------------------------------------------------------------------------------- 
Obj_0x3C_Mappings: 
		dc.w	loc_1282A-Obj_0x3C_Mappings
		dc.w	loc_1286C-Obj_0x3C_Mappings
		dc.w	loc_128AE-Obj_0x3C_Mappings
loc_1282A:
		dc.w	$8
		dc.l	$E0050000,$FFF0,$F0050000,$FFF0
		dc.l	$50000,$FFF0,$10050000,$FFF0
		dc.l	$E0050004,$20000,$F0050004,$20000
		dc.l	$50004,$20000,$10050004,$20000
loc_1286C:
		dc.w	$8
		dc.l	$E0050004,$2FFF0,$F0050004,$2FFF0
		dc.l	$50004,$2FFF0,$10050004,$2FFF0
		dc.l	$E0050004,$20000,$F0050004,$20000
		dc.l	$50004,$20000,$10050004,$20000
loc_128AE:
		dc.w	$8
		dc.l	$E0050004,$2FFF0,$F0050004,$2FFF0
		dc.l	$50004,$2FFF0,$10050004,$2FFF0
		dc.l	$E0050008,$40000,$F0050008,$40000
		dc.l	$50008,$40000,$10050008,$40000 
;===============================================================================
; Sub Routine loc_12770
; [ End ]
;=============================================================================== 

		bra.w	Obj_Null 
;===============================================================================
; Sub Routine Load_Objects
; [ Begin ]
;===============================================================================
Load_Objects: 
		tst.b	($FFFFF623).w
		bne.s	loc_12930
		lea	(Object_RAM).w,a0
		moveq	#$7F,d7
		moveq	#0,d0
		cmp.b	#$10,(Game_Mode).w
		beq.s	loc_12918
		tst.w	($FFFFFFD8).w
		bne.s	loc_12918
		cmp.b	#6,($FFFFB024).w
		bcc.s	loc_12932
loc_12918:
		move.b	(a0),d0
		beq.s	loc_12928
		add.w	d0,d0
		add.w	d0,d0
		move.l	Object_List-4(pc,d0),a1 
		jsr	(a1)
		moveq	#0,d0
loc_12928:
		lea	$40(a0),a0
		dbra	d7,loc_12918
loc_12930:
		rts
;--------------------------------------------------------------------------------
loc_12932:
		moveq	#$1F,d7
		bsr.s	loc_12918
		moveq	#$5F,d7
loc_12938: 
		moveq	#0,d0
		move.b	(a0),d0
		beq.s	loc_12948 
		tst.b	1(a0)
		bpl.s	loc_12948
		bsr.w	DisplaySprite 
loc_12948:
		lea	$40(a0),a0
		dbra	d7,loc_12938
		rts
;--------------------------------------------------------------------------------
Object_List: 
		dc.l	Obj_0x01_Sonic 
		dc.l	Obj_0x02_Miles 
		dc.l	Obj_0x03_Layer_Switch 
		dc.l	Obj_0x04_Water_Surface 
		dc.l	Obj_0x05_Miles_Tail 
		dc.l	Obj_0x06_Spiral_Attributes 
		dc.l	Obj_0x07_0il_Attributes 
		dc.l	Obj_0x08_Dust_Water_Splash 
		dc.l	Obj_0x09_Sonic_In_Special_Stage 
		dc.l	Obj_0x0A_Sonic_Miles_Underwater 
		dc.l	Obj_0x0B_Open_Close_Platform 
		dc.l	Obj_0x0C 
		dc.l	Obj_0x0D_End_Panel 
		dc.l	Obj_0x0E_Sonic_Miles 
		dc.l	Obj_0x0F_1Player2Vs 
		dc.l	Obj_0x10_Miles_In_Special_Stage 
		dc.l	Obj_0x11_Bridge 
		dc.l	Obj_0x12_HPz_Master_Emerald 
		dc.l	Obj_0x13_HPz_Waterfalls 
		dc.l	Obj_0x14_See_saw 
		dc.l	Obj_0x15_Swing_Platform 
		dc.l	Obj_0x16_Teleferics 
		dc.l	Obj_0x17 
		dc.l	Obj_0x18_Platforms 
		dc.l	Obj_0x19_Rotating_Platforms 
		dc.l	Obj_0x1A_Collapsing_Platforms 
		dc.l	Obj_0x1B_Speed_Booster 
		dc.l	Obj_0x1C_Misc 
		dc.l	Obj_0x1D_Worms 
		dc.l	Obj_0x1E_Tube_Attributes 
		dc.l	Obj_0x1F_Collapsing_Platforms 
		dc.l	Obj_0x20_HTz_Boss_FireBall 
		dc.l	Obj_0x21_2P_Versus_Results 
		dc.l	Obj_0x22_Arrow_Shooter 
		dc.l	Obj_0x23_Pillar 
		dc.l	Obj_0x24_Oxygen_Bubbles 
		dc.l	Obj_0x25_Rings 
		dc.l	Obj_0x26_Monitors 
		dc.l	Obj_0x27_Object_Hit 
		dc.l	Obj_0x28_Flickies 
		dc.l	Obj_0x29_Enemy_Points 
		dc.l	Obj_0x2A_Up_Down_Pillar 
		dc.l	Obj_0x2B_Raising_Pillar 
		dc.l	Obj_0x2C_Leaves 
		dc.l	Obj_0x2D_Automatic_Door 
		dc.l	Obj_0x2E_Monitors_Contents 
		dc.l	Obj_0x2F_Breakable_Floor 
		dc.l	Obj_0x30 
		dc.l	Obj_0x31_Lava_Attributes 
		dc.l	Obj_0x32_Breakable_Obstacle 
		dc.l	Obj_0x33_Touch_Booster 
		dc.l	Obj_0x34_Title_Cards 
		dc.l	Obj_0x35_Invincibility 
		dc.l	Obj_0x36_Spikes 
		dc.l	Obj_0x37_Rings_Out 
		dc.l	Obj_0x38_Shield 
		dc.l	Obj_0x39_Time_Over_Game_Over 
		dc.l	Obj_0x3A_Level_Results 
		dc.l	Obj_0x3B 
		dc.l	Obj_0x3C 
		dc.l	Obj_0x3D_Break_Boost 
		dc.l	Obj_0x3E_Egg_Prison 
		dc.l	Obj_0x3F_Fans 
		dc.l	Obj_0x40_Diagonal_Springs 
		dc.l	Obj_0x41_Springs 
		dc.l	Obj_0x42_Steam_Vent 
		dc.l	Obj_0x43_Giant_Spikeball 
		dc.l	Obj_0x44_Red_Ball_Bumper 
		dc.l	Obj_0x45_Spring_Push_Boost 
		dc.l	Obj_0x46_Spring_Ball 
		dc.l	Obj_0x47_Switch 
		dc.l	Obj_0x48_Cannon 
		dc.l	Obj_0x49_Waterfall 
		dc.l	Obj_0x4A_Octus 
		dc.l	Obj_0x4B_Buzzer 
		dc.l	Obj_0x4C_Batbot 
		dc.l	Obj_0x4D_Rhinobot 
		dc.l	Obj_0x4E_Crocobot 
		dc.l	Obj_0x4F_Dinobot 
		dc.l	Obj_0x50_Aquis 
		dc.l	Obj_0x51_CNz_Boss 
		dc.l	Obj_0x52_HTz_Boss 
		dc.l	Obj_0x53_Mz_Boss_Balls_Robotniks 
		dc.l	Obj_0x54_Mz_Boss 
		dc.l	Obj_0x55_OOz_Boss 
		dc.l	Obj_0x56_GHz_Boss
		dc.l	Obj_0x57_DHz_Boss 
		dc.l	Obj_0x58_Boss_Explosions 
		dc.l	Obj_0x59_SS_Emerald_Rings_Check 
		dc.l	Obj_0x5A_SS_Rings_Check 
		dc.l	Obj_0x5B 
		dc.l	Obj_0x5C_Masher 
		dc.l	Obj_0x5D_CPz_Boss 
		dc.l	Obj_0x5E_SS_Head_Up_Display 
		dc.l	Obj_0x5F_SS_Start_Flag 
		dc.l	Obj_0x60_SS_Rings 
		dc.l	Obj_0x61_SS_Bomb
		dc.l	Obj_Null 
		dc.l	Obj_0x63 
		dc.l	Obj_0x64_Pistons 
		dc.l	Obj_0x65_Platform_Over_Gear 
		dc.l	Obj_0x66_Springs_Wall 
		dc.l	Obj_0x67_Teleport_Attributes 
		dc.l	Obj_0x68_Block_Harpon 
		dc.l	Obj_0x69_Screw_Nut 
		dc.l	Obj_0x6A_DHz_Three_Boxes_Mz_Ptfrm 
		dc.l	Obj_0x6B_Mz_Platform 
		dc.l	Obj_0x6C_Mz_Moving_Platforms 
		dc.l	Obj_0x6D_Harpoon 
		dc.l	Obj_0x6E_Machine 
		dc.l	Obj_0x6F_Special_Stage_Results 
		dc.l	Obj_0x70_Rotating_Gears 
		dc.l	Obj_0x71_Mz_Hpz_Misc 
		dc.l	Obj_0x72_Conveyor_Belt_Attributes 
		dc.l	Obj_0x73_Rotating_Rings 
		dc.l	Obj_0x74_Invisible_Block 
		dc.l	Obj_0x75_Spikeball_Chain 
		dc.l	Obj_0x76_Platform_Spikes 
		dc.l	Obj_0x77_Bridge 
		dc.l	Obj_0x78_Rotating_Platforms 
		dc.l	Obj_0x79_Star_Post 
		dc.l	Obj_0x7A_Platform_Horizontal 
		dc.l	Obj_0x7B_Spring_Tubes 
		dc.l	Obj_0x7C_Metal_Structure 
		dc.l	Obj_0x7D_Hidden_Bonus 
		dc.l	Obj_0x7E 
		dc.l	Obj_0x7F_Vines_Switch 
		dc.l	Obj_0x80_Vines_Chain_Hook 
		dc.l	Obj_0x81_Vertical_Bridge 
		dc.l	Obj_0x82_Falling_Pillar 
		dc.l	Obj_0x83_Three_Rotating_Platforms 
		dc.l	Obj_0x84_Auto_Spin 
		dc.l	Obj_0x85_CNz_Pinball_Spring 
		dc.l	Obj_0x86_CNz_Flippers 
		dc.l	Obj_0x87 
		dc.l	Obj_0x88 
		dc.l	Obj_0x89_NGHz_Boss 
		dc.l	Obj_0x8A 
		dc.l	Obj_0x8B_Palette_Cycling_Switch 
		dc.l	Obj_0x8C_NGHz_Whisp 
		dc.l	Obj_0x8D_Hidden_Grounder 
		dc.l	Obj_0x8E_Grounder 
		dc.l	Obj_0x8F_Wall_Hidden_Grounder 
		dc.l	Obj_0x90_Rock_Hidden_Grounder 
		dc.l	Obj_0x91_Chop_Chop 
		dc.l	Obj_0x92_Spiker 
		dc.l	Obj_0x93_Spiker_Spike_Fired 
		dc.l	Obj_0x94_Rexon_Body 
		dc.l	Obj_0x95_Sol 
		dc.l	Obj_0x96_Rexon_Body 
		dc.l	Obj_0x97_Rexon_Head 
		dc.l	Obj_0x98_Enemies_Weapons 
		dc.l	Obj_0x99_Nebula 
		dc.l	Obj_0x9A_Turtloid 
		dc.l	Obj_0x9B_Turtloid_Rider 
		dc.l	Obj_0x9C_Turtloid_Sub 
		dc.l	Obj_0x9D_Coconuts 
		dc.l	Obj_0x9E_Crawlton 
		dc.l	Obj_0x9F_Shellcracker 
		dc.l	Obj_0xA0_Shellcracker_Sub 
		dc.l	Obj_0xA1_Slicer 
		dc.l	Obj_0xA2_Slicer_Sub 
		dc.l	Obj_0xA3_Flasher 
		dc.l	Obj_0xA4_Asteron 
		dc.l	Obj_0xA5_Horizontal_Lander 
		dc.l	Obj_0xA6_Vertical_Lander 
		dc.l	Obj_0xA7_Grabber 
		dc.l	Obj_0xA8_Grabber_Sub 
		dc.l	Obj_0xA9_Grabber_Sub 
		dc.l	Obj_0xAA_Grabber_Sub 
		dc.l	Obj_0xAB 
		dc.l	Obj_0xAC_Balkiry 
		dc.l	Obj_0xAD_Clucker_Platform 
		dc.l	Obj_0xAE_Clucker 
		dc.l	Obj_0xAF_Metal_Sonic 
		dc.l	Obj_0xB0_Sonic_Sega_Logo 
		dc.l	Obj_0xB1_Sonic_Sega_Logo 
		dc.l	Obj_0xB2_Tornado 
		dc.l	Obj_0xB3_Clouds 
		dc.l	Obj_0xB4_Vertical_Helix 
		dc.l	Obj_0xB5_Horizontal_Helix 
		dc.l	Obj_0xB6_Platform_Helix 
		dc.l	Obj_0xB7_SFz_Vertical_Large_Laser 
		dc.l	Obj_0xB8_Cannon 
		dc.l	Obj_0xB9_Laser 
		dc.l	Obj_0xBA_Conveyor_Belt_Wheels 
		dc.l	Obj_0xBB 
		dc.l	Obj_0xBC_SFz_Rocket_Boost 
		dc.l	Obj_0xBD_SFz_Elevators 
		dc.l	Obj_0xBE_Hatchways 
		dc.l	Obj_0xBF_Engine_Part 
		dc.l	Obj_0xC0_Speed_Booster 
		dc.l	Obj_0xC1_SFz_Breakable_Wall 
		dc.l	Obj_0xC2_SFz_Boss_Access_Switch 
		dc.l	Obj_0xC3 
		dc.l	Obj_0xC4 
		dc.l	Obj_0xC5_SFz_Boss 
		dc.l	Obj_0xC6_Robotnik_Running 
		dc.l	Obj_0xC7_DEz_Final_Boss 
		dc.l	Obj_0xC8_Crawl 
		dc.l	Obj_Null 
		dc.l	Obj_Null 
		dc.l	Obj_Null 
		dc.l	Obj_Null 
		dc.l	Obj_Null 
		dc.l	Obj_Null 
		dc.l	Obj_Null 
		dc.l	Obj_Null 
		dc.l	Obj_Null 
		dc.l	Obj_0xD2_Green_Platform 
		dc.l	Obj_0xD3_CNz_Spikeball 
		dc.l	Obj_0xD4_CNz_Box 
		dc.l	Obj_0xD5_CNz_Elevator 
		dc.l	Obj_0xD6_CNz_Slot_Machine_Bonus 
		dc.l	Obj_0xD7_CNz_Blue_Bumper 
		dc.l	Obj_0xD8_CNz_Green_Bumper 
		dc.l	Obj_0xD9_SFz_Hang_Attributes 
		dc.l	Obj_0xDA_Continue_Counter 
		dc.l	Obj_0xDB_Sonic_Miles_Continue 
;===============================================================================
; Sub Routine Load_Objects
; [ End ]
;===============================================================================
Obj_Null: 
		bra.w	DeleteObject 
;=============================================================================== 
; Sub Routine ObjectFall
; [ Begin ] 
;=============================================================================== 
ObjectFall: 
		move.l	8(a0),d2
		move.l	$C(a0),d3
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	$12(a0),d0
		add.w	#$38,$12(a0)
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,8(a0)
		move.l	d3,$C(a0)
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine ObjectFall
; [ End ] 
;===============================================================================
 
;=============================================================================== 
; Sub Routine SpeedToPos
; [ Begin ] 
;=============================================================================== 
SpeedToPos: 
		move.l	8(a0),d2
		move.l	$C(a0),d3
		move.w	$10(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	$12(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,8(a0)
		move.l	d3,$C(a0)
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine SpeedToPos
; [ End ] 
;===============================================================================
 
;=============================================================================== 
; Sub Routine MarkObjGone
; [ Begin ] 
;===============================================================================
MarkObjGone: 
		tst.w	($FFFFFFD8).w
		beq.s	loc_12D1E
		bra.w	DisplaySprite 
loc_12D1E:
		move.w	8(a0),d0
		and.w	#$FF80,d0
		sub.w	($FFFFF7DA).w,d0
		cmp.w	#$280,d0
		bhi loc_12D36
		bra.w	DisplaySprite 
loc_12D36:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_12D48
		bclr	#7,2(a2,d0)
loc_12D48:
		bra.w	DeleteObject 
;=============================================================================== 
; Sub Routine MarkObjGone
; [ End ] 
;=============================================================================== 
loc_12D4C: 
		tst.w	($FFFFFFD8).w
		beq.s	loc_12D56
		bra.w	DisplaySprite 
loc_12D56:
		and.w	#$FF80,d0
		sub.w	($FFFFF7DA).w,d0
		cmp.w	#$280,d0
		bhi loc_12D6A
		bra.w	DisplaySprite 
loc_12D6A:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_12D7C
		bclr	#7,2(a2,d0)
loc_12D7C:
		bra.w	DeleteObject 
;=============================================================================== 
; Sub Routine MarkObjGone
; [ End ] 
;=============================================================================== 

loc_12D80:
		tst.w	($FFFFFFD8).w
		beq.s	loc_12D88
		rts
;--------------------------------------------------------------------------------
loc_12D88:
		move.w	8(a0),d0
		and.w	#$FF80,d0
		sub.w	($FFFFF7DA).w,d0
		cmp.w	#$280,d0
		bhi loc_12D9E
		rts
;--------------------------------------------------------------------------------
loc_12D9E:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_12DB0
		bclr	#7,2(a2,d0)
loc_12DB0:
		bra.w	DeleteObject 
loc_12DB4: 
		tst.w	($FFFFFFD8).w
		bne.s	loc_12DE8
		move.w	8(a0),d0
		and.w	#$FF80,d0
		sub.w	($FFFFF7DA).w,d0
		cmp.w	#$280,d0
		bhi loc_12DD2
		bra.w	DisplaySprite 
loc_12DD2:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_12DE4
		bclr	#7,2(a2,d0)
loc_12DE4:
		bra.w	DeleteObject 
loc_12DE8:
		move.w	8(a0),d0
		and.w	#$FF00,d0
		move.w	d0,d1
		sub.w	($FFFFF7DA).w,d0
		cmp.w	#$300,d0
		bhi loc_12E02
		bra.w	DisplaySprite 
loc_12E02:
		sub.w	($FFFFF7DC).w,d1
		cmp.w	#$300,d1
		bhi loc_12E12
		bra.w	DisplaySprite 
loc_12E12:
		lea	($FFFFFC00).w,a2
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_12E24
		bclr	#7,2(a2,d0)
loc_12E24:
		bra.w	DeleteObject 
;=============================================================================== 
; Sub Routine DeleteObject
; [ Begin ] 
;=============================================================================== 
DeleteObject: 
		move.l	a0,a1
Delete_A1_Object: 
		moveq	#0,d1
		moveq	#$F,d0
loc_12E2E: 
		move.l	d1,(a1)+
		dbra	d0,loc_12E2E
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine DeleteObject
; [ End ] 
;===============================================================================
 
;===============================================================================
; Sub Routine DisplaySprite
; [ Begin ]
;===============================================================================
DisplaySprite: 
		lea	($FFFFAC00).w,a1
		move.w	$18(a0),d0
		lsr.w	#1,d0
		and.w	#$380,d0
		add.w	d0,a1
		cmp.w	#$7E,(a1)
		bcc.s	loc_12E52
		addq.w	#2,(a1)
		add.w	(a1),a1
		move.w	a0,(a1)
loc_12E52:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine DisplaySprite
; [ End ]
;===============================================================================

;=============================================================================== 
; Sub Routine Display_A1_Sprite
; [ Begin ] 
;=============================================================================== 
Display_A1_Sprite: 
		lea	($FFFFAC00).w,a2
		move.w	$18(a1),d0
		lsr.w	#1,d0
		and.w	#$380,d0
		add.w	d0,a2
		cmp.w	#$7E,(a2)
		bcc.s	loc_12E70
		addq.w	#2,(a2)
		add.w	(a2),a2
		move.w	a1,(a2)
loc_12E70:
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine Display_A1_Sprite
; [ End ] 
;=============================================================================== 

;=============================================================================== 
; Sub Routine DisplaySprite_Param
; [ Begin ] 
;=============================================================================== 
DisplaySprite_Param: 
		lea	($FFFFAC00).w,a1
		add.w	d0,a1
		cmp.w	#$7E,(a1)
		bcc.s	loc_12E84
		addq.w	#2,(a1)
		add.w	(a1),a1
		move.w	a0,(a1)
loc_12E84:
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine DisplaySprite_Param
; [ End ] 
;=============================================================================== 

;===============================================================================
; Sub Routine AnimateSprite
; [ Begin ]
;===============================================================================
AnimateSprite: 
		moveq	#0,d0
		move.b	$1C(a0),d0
		cmp.b	$1D(a0),d0
		beq.s	loc_12EA2
		move.b	d0,$1D(a0)
		move.b	#0,$1B(a0)
		move.b	#0,$1E(a0)
loc_12EA2:
		subq.b	#1,$1E(a0)
		bpl.s	loc_12EDC
		add.w	d0,d0
		add.w	0(a1,d0),a1
		move.b	(a1),$1E(a0)
		moveq	#0,d1
		move.b	$1B(a0),d1
		move.b	1(a1,d1),d0
		bmi.s	loc_12EDE
loc_12EBE: 
		and.b	#$7F,d0
		move.b	d0,$1A(a0)
		move.b	$22(a0),d1
		and.b	#3,d1
		and.b	#$FC,1(a0)
		or.b	d1,1(a0)
		addq.b	#1,$1B(a0)
loc_12EDC:
		rts
;--------------------------------------------------------------------------------
loc_12EDE:
		addq.b	#1,d0
		bne.s	loc_12EEE
		move.b	#0,$1B(a0)
		move.b	1(a1),d0
		bra.s	loc_12EBE
loc_12EEE:
		addq.b	#1,d0
		bne.s	loc_12F02
		move.b	2(a1,d1),d0
		sub.b	d0,$1B(a0)
		sub.b	d0,d1
		move.b	1(a1,d1),d0
		bra.s	loc_12EBE
loc_12F02:
		addq.b	#1,d0
		bne.s	loc_12F0E
		move.b	2(a1,d1),$1C(a0)
		rts
;--------------------------------------------------------------------------------
loc_12F0E:
		addq.b	#1,d0
		bne.s	loc_12F22
		addq.b	#2,$24(a0)
		move.b	#0,$1E(a0)
		addq.b	#1,$1B(a0)
		rts
;--------------------------------------------------------------------------------
loc_12F22:
		addq.b	#1,d0
		bne.s	loc_12F32
		move.b	#0,$1B(a0)
		clr.b	$25(a0)
		rts
;--------------------------------------------------------------------------------
loc_12F32:
		addq.b	#1,d0
		bne.s	loc_12F3C
		addq.b	#2,$25(a0)
		rts
;--------------------------------------------------------------------------------
loc_12F3C:
		addq.b	#1,d0
		bne.s	loc_12F44
		addq.b	#2,$2A(a0)
loc_12F44:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine AnimateSprite
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine Build_Sprites
; [ Begin ]
;===============================================================================
Build_Sprites: 
		tst.w	($FFFFFFD8).w
		bne.w	loc_1329E
		lea	($FFFFF800).w,a2
		moveq	#0,d5
		moveq	#0,d4
		tst.b	($FFFFF711).w
		beq.s	loc_12F64
		bsr.w	loc_138C4
		bsr.w	loc_13ACA
loc_12F64:
		lea	($FFFFAC00).w,a4
		moveq	#7,d7
loc_12F6A: 
		tst.w	(a4)
		beq	loc_13044
		moveq	#2,d6
loc_12F72: 
		move.w	0(a4,d6),a0
		tst.b	(a0)
		beq	loc_13066
		tst.l	4(a0)
		beq	loc_13066
		and.b	#$7F,1(a0)
		move.b	1(a0),d0
		move.b	d0,d4
		btst	#6,d0
		bne.w	loc_1306C
		and.w	#$C,d0
		beq.s	loc_12FF0
		lea	($FFFFEEF0).w,a1
		moveq	#0,d0
		move.b	$19(a0),d0
		move.w	8(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi loc_1303C
		move.w	d3,d1
		sub.w	d0,d1
		cmp.w	#$140,d1
		bge loc_1303C
		add.w	#$80,d3
		btst	#4,d4
		beq.s	loc_12FFA
		moveq	#0,d0
		move.b	$16(a0),d0
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_1303C
		move.w	d2,d1
		sub.w	d0,d1
		cmp.w	#$E0,d1
		bge.s	loc_1303C
		add.w	#$80,d2
		bra.s	loc_13016
loc_12FF0:
		move.w	$A(a0),d2
		move.w	8(a0),d3
		bra.s	loc_13016
loc_12FFA:
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		add.w	#$80,d2
		and.w	#$7FF,d2
		cmp.w	#$60,d2
		bcs.s	loc_1303C
		cmp.w	#$180,d2
		bcc.s	loc_1303C
loc_13016:
		move.l	4(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_13032
		move.b	$1A(a0),d1
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_13036
loc_13032:
		bsr.w	loc_13162
loc_13036:
		or.b	#$80,1(a0)
loc_1303C:
		addq.w	#2,d6
		subq.w	#2,(a4)
		bne.w	loc_12F72
loc_13044:
		lea	$80(a4),a4
		dbra	d7,loc_12F6A
		move.b	d5,($FFFFF62C).w
		cmp.b	#$50,d5
		beq.s	loc_1305E
		move.l	#0,(a2)
		rts
;--------------------------------------------------------------------------------
loc_1305E:
		move.b	#0,$FFFFFFFB(a2)
		rts
;--------------------------------------------------------------------------------
loc_13066:
		move.w	($1).w,d0
		bra.s	loc_1303C
loc_1306C:
		move.l	a4,-(sp)
		lea	($FFFFEE00).w,a4
		move.w	2(a0),a3
		move.l	4(a0),a5
		moveq	#0,d0
		move.b	$E(a0),d0
		move.w	8(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi loc_13154
		move.w	d3,d1
		sub.w	d0,d1
		cmp.w	#$140,d1
		bge loc_13154
		add.w	#$80,d3
		btst	#4,d4
		beq.s	loc_130CC
		moveq	#0,d0
		move.b	$14(a0),d0
		move.w	$C(a0),d2
		sub.w	4(a4),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi loc_13154
		move.w	d2,d1
		sub.w	d0,d1
		cmp.w	#$E0,d1
		bge loc_13154
		add.w	#$80,d2
		bra.s	loc_130E8
loc_130CC:
		move.w	$C(a0),d2
		sub.w	4(a4),d2
		add.w	#$80,d2
		and.w	#$7FF,d2
		cmp.w	#$60,d2
		bcs.s	loc_13154
		cmp.w	#$180,d2
		bcc.s	loc_13154
loc_130E8:
		moveq	#0,d1
		move.b	$B(a0),d1
		beq.s	loc_13106
		add.w	d1,d1
		move.l	a5,a1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_13106
		move.w	d4,-(sp)
		bsr.w	loc_1315A
		move.w	(sp)+,d4
loc_13106:
		or.b	#$80,1(a0)
		lea	$10(a0),a6
		moveq	#0,d0
		move.b	$F(a0),d0
		subq.w	#1,d0
		bcs.s	loc_13154
loc_1311A: 
		swap.w	d0
		move.w	(a6)+,d3
		sub.w	(a4),d3
		add.w	#$80,d3
		move.w	(a6)+,d2
		sub.w	4(a4),d2
		add.w	#$80,d2
		and.w	#$7FF,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1
		add.w	d1,d1
		move.l	a5,a1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_1314E
		move.w	d4,-(sp)
		bsr.w	loc_1315A
		move.w	(sp)+,d4
loc_1314E:
		swap.w	d0
		dbra	d0,loc_1311A
loc_13154:
		move.l	(sp)+,a4
		bra.w	loc_1303C
loc_1315A:
		cmp.b	#$50,d5
		bcs.s	loc_1316C
		rts
;--------------------------------------------------------------------------------
loc_13162:
		move.w	2(a0),a3
		cmp.b	#$50,d5
		bcc.s	loc_131A2
loc_1316C: 
		btst	#0,d4
		bne.s	loc_131A4
		btst	#1,d4
		bne.w	loc_13204
loc_1317A: 
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	d3,d0
		and.w	#$1FF,d0
		bne.s	loc_1319C
		addq.w	#1,d0
loc_1319C:
		move.w	d0,(a2)+
		dbra	d1,loc_1317A
loc_131A2:
		rts
;--------------------------------------------------------------------------------
loc_131A4:
		btst	#1,d4
		bne.w	loc_1324C
loc_131AC: 
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		eor.w	#$800,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		neg.w	d0
		move.b	loc_131E4(pc,d4),d4
		sub.w	d4,d0
		add.w	d3,d0
		and.w	#$1FF,d0
		bne.s	loc_131DC
		addq.w	#1,d0
loc_131DC:
		move.w	d0,(a2)+
		dbra	d1,loc_131AC
		rts
;--------------------------------------------------------------------------------
loc_131E4:
		dc.b	$8,$8,$8,$8,$10,$10,$10,$10,$18,$18,$18,$18,$20,$20,$20,$20
loc_131F4: 
		dc.b	$8,$10,$18,$20,$8,$10,$18,$20,$8,$10,$18,$20,$8,$10,$18,$20
loc_13204:
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	loc_131F4(pc,d4),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		eor.w	#$1000,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	d3,d0
		and.w	#$1FF,d0
		bne.s	loc_13234
		addq.w	#1,d0
loc_13234:
		move.w	d0,(a2)+
		dbra	d1,loc_13204
		rts
;--------------------------------------------------------------------------------
loc_1323C:
		dc.b	$8,$10,$18,$20,$8,$10,$18,$20,$8,$10,$18,$20,$8,$10,$18,$20
loc_1324C:
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	loc_1323C(pc,d4),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	d4,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	a3,d0
		eor.w	#$1800,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		neg.w	d0
		move.b	loc_1328E(pc,d4),d4
		sub.w	d4,d0
		add.w	d3,d0
		and.w	#$1FF,d0
		bne.s	loc_13286
		addq.w	#1,d0
loc_13286:
		move.w	d0,(a2)+
		dbra	d1,loc_1324C
		rts
;--------------------------------------------------------------------------------
loc_1328E:
		dc.b	$8,$8,$8,$8,$10,$10,$10,$10,$18,$18,$18,$18,$20,$20,$20,$20
loc_1329E:
		lea	($FFFFF800).w,a2
		moveq	#2,d5
		moveq	#0,d4
		move.l	#$1D80F01,(a2)+
		move.l	#1,(a2)+
		move.l	#$1D80F02,(a2)+
		move.l	#0,(a2)+
		tst.b	($FFFFF711).w
		beq.s	loc_132CC
		bsr.w	loc_138CA
		bsr.w	loc_13B4A
loc_132CC:
		lea	($FFFFAC00).w,a4
		moveq	#7,d7
loc_132D2: 
		move.w	(a4),d0
		beq	loc_133AA
		move.w	d0,-(sp)
		moveq	#2,d6
loc_132DC: 
		move.w	0(a4,d6),a0
		tst.b	(a0)
		beq	loc_133A0
		and.b	#$7F,1(a0)
		move.b	1(a0),d0
		move.b	d0,d4
		btst	#6,d0
		bne.w	loc_134EA
		and.w	#$C,d0
		beq.s	loc_13350
		lea	($FFFFEE00).w,a1
		moveq	#0,d0
		move.b	$19(a0),d0
		move.w	8(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi loc_133A0
		move.w	d3,d1
		sub.w	d0,d1
		cmp.w	#$140,d1
		bge.s	loc_133A0
		add.w	#$80,d3
		btst	#4,d4
		beq.s	loc_1335E
		moveq	#0,d0
		move.b	$16(a0),d0
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_133A0
		move.w	d2,d1
		sub.w	d0,d1
		cmp.w	#$E0,d1
		bge.s	loc_133A0
		add.w	#$100,d2
		bra.s	loc_1337A
loc_13350:
		move.w	$A(a0),d2
		move.w	8(a0),d3
		add.w	#$80,d2
		bra.s	loc_1337A
loc_1335E:
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		add.w	#$80,d2
		cmp.w	#$60,d2
		bcs.s	loc_133A0
		cmp.w	#$180,d2
		bcc.s	loc_133A0
		add.w	#$80,d2
loc_1337A:
		move.l	4(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_13396
		move.b	$1A(a0),d1
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_1339A
loc_13396:
		bsr.w	loc_136FE
loc_1339A:
		or.b	#$80,1(a0)
loc_133A0:
		addq.w	#2,d6
		subq.w	#2,(sp)
		bne.w	loc_132DC
		addq.w	#2,a7
loc_133AA:
		lea	$80(a4),a4
		dbra	d7,loc_132D2
		move.b	d5,($FFFFF62C).w
		cmp.b	#$50,d5
		bcc.s	loc_133C4
		move.l	#0,(a2)
		bra.s	loc_133CA
loc_133C4:
		move.b	#0,$FFFFFFFB(a2)
loc_133CA:
		tst.w	($FFFFF644).w
		bne.s	loc_133CA
		lea	($FFFFDD00).w,a2
		moveq	#0,d5
		moveq	#0,d4
		tst.b	($FFFFF711).w
		beq.s	loc_133E6
		bsr.w	loc_138D0
		bsr.w	loc_13B60
loc_133E6:
		lea	($FFFFAC00).w,a4
		moveq	#7,d7
loc_133EC: 
		move.w	(a4),d0
		beq	loc_134C8
		move.w	d0,-(sp) 
		moveq	#2,d6
loc_133F6: 
		move.w	0(a4,d6),a0
		tst.b	(a0)
		beq	loc_134B4
		move.b	1(a0),d0
		move.b	d0,d4
		btst	#6,d0
		bne.w	loc_135D4
		and.w	#$C,d0
		beq.s	loc_13464
		lea	($FFFFEE20).w,a1
		moveq	#0,d0
		move.b	$19(a0),d0
		move.w	8(a0),d3
		sub.w	(a1),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi loc_134B4
		move.w	d3,d1
		sub.w	d0,d1
		cmp.w	#$140,d1
		bge.s	loc_134B4
		add.w	#$80,d3
		btst	#4,d4
		beq.s	loc_13472
		moveq	#0,d0
		move.b	$16(a0),d0
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi.s	loc_134B4
		move.w	d2,d1
		sub.w	d0,d1
		cmp.w	#$E0,d1
		bge.s	loc_134B4
		add.w	#$1E0,d2
		bra.s	loc_1348E
loc_13464:
		move.w	$A(a0),d2
		move.w	8(a0),d3
		add.w	#$160,d2
		bra.s	loc_1348E
loc_13472:
		move.w	$C(a0),d2
		sub.w	4(a1),d2
		add.w	#$80,d2
		cmp.w	#$60,d2
		bcs.s	loc_134B4
		cmp.w	#$180,d2
		bcc.s	loc_134B4
		add.w	#$160,d2
loc_1348E:
		move.l	4(a0),a1
		moveq	#0,d1
		btst	#5,d4
		bne.s	loc_134AA
		move.b	$1A(a0),d1
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_134AE
loc_134AA:
		bsr.w	loc_136FE
loc_134AE:
		or.b	#$80,1(a0)
loc_134B4:
		addq.w	#2,d6
		subq.w	#2,(sp)
		bne.w	loc_133F6
		addq.w	#2,a7
		tst.b	($FFFFF623).w
		bne.s	loc_134C8
		move.w	#0,(a4)
loc_134C8:
		lea	$80(a4),a4
		dbra	d7,loc_133EC
		move.b	d5,($FFFFF62C).w
		cmp.b	#$50,d5
		beq.s	loc_134E2
		move.l	#0,(a2)
		rts
;--------------------------------------------------------------------------------
loc_134E2:
		move.b	#0,$FFFFFFFB(a2)
		rts
;--------------------------------------------------------------------------------
loc_134EA:
		move.l	a4,-(sp)
		lea	($FFFFEE00).w,a4
		move.w	2(a0),a3
		move.l	4(a0),a5
		moveq	#0,d0
		move.b	$E(a0),d0
		move.w	8(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi loc_135CE
		move.w	d3,d1
		sub.w	d0,d1
		cmp.w	#$140,d1
		bge loc_135CE
		add.w	#$80,d3
		btst	#4,d4
		beq.s	loc_1354A
		moveq	#0,d0
		move.b	$14(a0),d0
		move.w	$C(a0),d2
		sub.w	4(a4),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi loc_135CE
		move.w	d2,d1
		sub.w	d0,d1
		cmp.w	#$E0,d1
		bge loc_135CE
		add.w	#$100,d2
		bra.s	loc_13566
loc_1354A:
		move.w	$C(a0),d2
		sub.w	4(a4),d2
		add.w	#$80,d2
		cmp.w	#$60,d2
		bcs.s	loc_135CE
		cmp.w	#$180,d2
		bcc.s	loc_135CE
		add.w	#$80,d2
loc_13566:
		moveq	#0,d1
		move.b	$B(a0),d1
		beq.s	loc_13584
		add.w	d1,d1
		move.l	a5,a1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_13584
		move.w	d4,-(sp)
		bsr.w	loc_136F6
		move.w	(sp)+,d4
loc_13584:
		or.b	#$80,1(a0)
		lea	$10(a0),a6
		moveq	#0,d0
		move.b	$F(a0),d0
		subq.w	#1,d0
		bcs.s	loc_135CE
loc_13598: 
		swap.w	d0
		move.w	(a6)+,d3
		sub.w	(a4),d3
		add.w	#$80,d3
		move.w	(a6)+,d2
		sub.w	4(a4),d2
		add.w	#$100,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1
		add.w	d1,d1
		move.l	a5,a1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_135C8
		move.w	d4,-(sp)
		bsr.w	loc_136F6
		move.w	(sp)+,d4
loc_135C8:
		swap.w	d0
		dbra	d0,loc_13598
loc_135CE:
		move.l	(sp)+,a4
		bra.w	loc_133A0
loc_135D4:
		move.l	a4,-(sp)
		lea	($FFFFEE20).w,a4
		move.w	2(a0),a3
		move.l	4(a0),a5
		moveq	#0,d0
		move.b	$E(a0),d0
		move.w	8(a0),d3
		sub.w	(a4),d3
		move.w	d3,d1
		add.w	d0,d1
		bmi loc_136B8
		move.w	d3,d1
		sub.w	d0,d1
		cmp.w	#$140,d1
		bge loc_136B8
		add.w	#$80,d3
		btst	#4,d4
		beq.s	loc_13634
		moveq	#0,d0
		move.b	$14(a0),d0
		move.w	$C(a0),d2
		sub.w	4(a4),d2
		move.w	d2,d1
		add.w	d0,d1
		bmi loc_136B8
		move.w	d2,d1
		sub.w	d0,d1
		cmp.w	#$E0,d1
		bge loc_136B8
		add.w	#$1E0,d2
		bra.s	loc_13650
loc_13634:
		move.w	$C(a0),d2
		sub.w	4(a4),d2
		add.w	#$80,d2
		cmp.w	#$60,d2
		bcs.s	loc_136B8
		cmp.w	#$180,d2
		bcc.s	loc_136B8
		add.w	#$160,d2
loc_13650:
		moveq	#0,d1
		move.b	$B(a0),d1
		beq.s	loc_1366E
		add.w	d1,d1
		move.l	a5,a1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_1366E
		move.w	d4,-(sp)
		bsr.w	loc_136F6
		move.w	(sp)+,d4
loc_1366E:
		or.b	#$80,1(a0)
		lea	$10(a0),a6
		moveq	#0,d0
		move.b	$F(a0),d0
		subq.w	#1,d0
		bcs.s	loc_136B8
loc_13682: 
		swap.w	d0
		move.w	(a6)+,d3
		sub.w	(a4),d3
		add.w	#$80,d3
		move.w	(a6)+,d2
		sub.w	4(a4),d2
		add.w	#$1E0,d2
		addq.w	#1,a6
		moveq	#0,d1
		move.b	(a6)+,d1
		add.w	d1,d1
		move.l	a5,a1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_136B2
		move.w	d4,-(sp)
		bsr.w	loc_136F6
		move.w	(sp)+,d4
loc_136B2:
		swap.w	d0
		dbra	d0,loc_13682
loc_136B8:
		move.l	(sp)+,a4
		bra.w	loc_134B4
;===============================================================================
; Sub Routine ModifySpriteAttr_2P
; [ Begin ]
;=============================================================================== 
ModifySpriteAttr_2P: 
		tst.w	($FFFFFFD8).w
		beq.s	loc_136D8
		move.w	2(a0),d0
		and.w	#$7FF,d0
		lsr.w	#1,d0
		and.w	#$F800,2(a0)
		add.w	d0,2(a0)
loc_136D8:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine ModifySpriteAttr_2P
; [ End ]
;===============================================================================
 
;===============================================================================
; Sub Routine Modify_A1_SpriteAttr_2P:
; [ Begin ]
;=============================================================================== 
Modify_A1_SpriteAttr_2P: 
		tst.w	($FFFFFFD8).w
		beq.s	ModifySpriteAttr_Not2P_Mode 
		move.w	2(a1),d0
		and.w	#$7FF,d0
		lsr.w	#1,d0
		and.w	#$F800,2(a1)
		add.w	d0,2(a1)
ModifySpriteAttr_Not2P_Mode: 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Modify_A1_SpriteAttr_2P:
; [ End ]
;=============================================================================== 
loc_136F6:
		cmp.b	#$50,d5
		bcs.s	loc_13716
		rts
;--------------------------------------------------------------------------------
loc_136FE:
		move.w	2(a0),a3
		cmp.b	#$50,d5
		bcc.s	loc_13742
		btst	#0,d4
		bne.s	loc_13754
		btst	#1,d4
		bne.w	loc_137B6
loc_13716:
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	loc_13744(pc,d4),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		add.w	d3,d0
		and.w	#$1FF,d0
		bne.s	loc_1373C
		addq.w	#1,d0
loc_1373C:
		move.w	d0,(a2)+
		dbra	d1,loc_13716
loc_13742:
		rts
;--------------------------------------------------------------------------------
loc_13744:
		dc.b	$0,$0,$1,$1,$4,$4,$5,$5,$8,$8,$9,$9,$C,$C,$D,$D
loc_13754:
		btst	#1,d4
		bne.w	loc_13812
loc_1375C:
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	loc_13744(pc,d4),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		eor.w	#$800,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		neg.w	d0
		move.b	loc_13796(pc,d4),d4
		sub.w	d4,d0
		add.w	d3,d0
		and.w	#$1FF,d0
		bne.s	loc_1378E
		addq.w	#1,d0
loc_1378E:
		move.w	d0,(a2)+
		dbra	d1,loc_1375C
		rts
;--------------------------------------------------------------------------------
loc_13796:
		dc.b	$8,$8,$8,$8,$10,$10,$10,$10,$18,$18,$18,$18,$20,$20,$20,$20
loc_137A6:
		dc.b	$8,$10,$18,$20,$8,$10,$18,$20,$8,$10,$18,$20,$8,$10,$18,$20
loc_137B6:
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	loc_137A6(pc,d4),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	loc_137F2(pc,d4),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		eor.w	#$1000,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		add.w	d3,d0
		and.w	#$1FF,d0
		bne.s	loc_137EA
		addq.w	#1,d0
loc_137EA:
		move.w	d0,(a2)+
		dbra	d1,loc_137B6
		rts
;--------------------------------------------------------------------------------
loc_137F2:
		dc.b	$0,$0,$1,$1,$4,$4,$5,$5,$8,$8,$9,$9,$C,$C,$D,$D
loc_13802:
		dc.b	$8,$10,$18,$20,$8,$10,$18,$20,$8,$10,$18,$20,$8,$10,$18,$20 
loc_13812:
		move.b	(a1)+,d0
		move.b	(a1),d4
		ext.w	d0
		neg.w	d0
		move.b	loc_13802(pc,d4),d4
		sub.w	d4,d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	loc_137F2(pc,d4),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	a3,d0
		eor.w	#$1800,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		neg.w	d0
		move.b	loc_13856(pc,d4),d4
		sub.w	d4,d0
		add.w	d3,d0
		and.w	#$1FF,d0
		bne.s	loc_1384E
		addq.w	#1,d0
loc_1384E:
		move.w	d0,(a2)+
		dbra	d1,loc_13812
		rts
;--------------------------------------------------------------------------------
loc_13856:
		dc.b	$8,$8,$8,$8,$10,$10,$10,$10,$18,$18,$18,$18,$20,$20,$20,$20
loc_13866:
		move.w	8(a0),d0
		sub.w	($FFFFEE00).w,d0
		bmi.s	loc_1388A
		cmp.w	#$140,d0
		bge.s	loc_1388A
		move.w	$C(a0),d1
		sub.w	(Camera_Y_pos).w,d1
		bmi.s	loc_1388A
		cmp.w	#$E0,d1
		bge.s	loc_1388A
		moveq	#0,d0
		rts
;--------------------------------------------------------------------------------
loc_1388A:
		moveq	#1,d0
		rts
;--------------------------------------------------------------------------------

		moveq	#0,d1
		move.b	$19(a0),d1
		move.w	8(a0),d0
		sub.w	($FFFFEE00).w,d0
		add.w	d1,d0
		bmi.s	loc_138BE
		add.w	d1,d1
		sub.w	d1,d0
		cmp.w	#$140,d0
		bge.s	loc_138BE
		move.w	$C(a0),d1
		sub.w	(Camera_Y_pos).w,d1
		bmi.s	loc_138BE
		cmp.w	#$E0,d1
		bge.s	loc_138BE
		moveq	#0,d0
		rts
;--------------------------------------------------------------------------------
loc_138BE:
		moveq	#1,d0
		rts
;--------------------------------------------------------------------------------
		nop
loc_138C4:
		jmp	(loc_3C648)
loc_138CA:
		jmp	(loc_3C69E)
loc_138D0:
		jmp	(loc_3C7E8) 
;===============================================================================
; Sub Routine loc_12F46
; [ End ]
;===============================================================================
		dc.w	$0 ; Filler
		
;===============================================================================
; Sub Routine Load_Ring_Pos
; [ Begin ]
;=============================================================================== 
Load_Ring_Pos: 
		moveq	#0,d0
		move.b	($FFFFF710).w,d0
		move.w	loc_138E6(pc,d0),d0
		jmp	loc_138E6(pc,d0)
loc_138E6:
		dc.w	loc_138EA-loc_138E6
		dc.w	loc_13934-loc_138E6
loc_138EA:
		addq.b	#2,($FFFFF710).w
		bsr.w	loc_13BF6
		lea	($FFFFE800).w,a1
		move.w	($FFFFEE00).w,d4
		subq.w	#8,d4
		bhi.s	loc_13906
		moveq	#1,d4
		bra.s	loc_13906
loc_13902: 
		lea	6(a1),a1
loc_13906:
		cmp.w	2(a1),d4
		bhi.s	loc_13902
		move.w	a1,($FFFFF712).w
		move.w	a1,($FFFFF716).w
		add.w	#$150,d4
		bra.s	loc_1391E
loc_1391A: 
		lea	6(a1),a1
loc_1391E:
		cmp.w	2(a1),d4
		bhi.s	loc_1391A
		move.w	a1,($FFFFF714).w
		move.w	a1,($FFFFF718).w
		move.b	#1,($FFFFF711).w
		rts
;--------------------------------------------------------------------------------
loc_13934:
		lea	($FFFFEF80).w,a2
		move.w	(a2)+,d1
		subq.w	#1,d1
		bcs.s	loc_1396A
loc_1393E: 
		move.w	(a2)+,d0
		beq.s	loc_1393E
		move.w	d0,a1
		subq.b	#1,(a1)
		bne.s	loc_13966
		move.b	#6,(a1)
		addq.b	#1,1(a1)
		cmp.b	#8,1(a1)
		bne.s	loc_13966
		move.w	#$FFFF,(a1)
		move.w	#0,$FFFFFFFE(a2)
		subq.w	#1,($FFFFEF80).w
loc_13966:
		dbra	d1,loc_1393E
loc_1396A:
		move.w	($FFFFF712).w,a1
		move.w	($FFFFEE00).w,d4
		subq.w	#8,d4
		bhi.s	loc_1397E
		moveq	#1,d4
		bra.s	loc_1397E
loc_1397A: 
		lea	6(a1),a1
loc_1397E:
		cmp.w	2(a1),d4
		bhi.s	loc_1397A
		bra.s	loc_13988
loc_13986: 
		subq.w	#6,a1
loc_13988:
		cmp.w	Checksum_fourcc(a1),d4
		bls.s	loc_13986
		move.w	a1,($FFFFF712).w
		move.w	($FFFFF714).w,a2
		add.w	#$150,d4
		bra.s	loc_139A0
loc_1399C: 
		lea	6(a2),a2
loc_139A0:
		cmp.w	2(a2),d4
		bhi.s	loc_1399C
		bra.s	loc_139AA
loc_139A8: 
		subq.w	#6,a2
loc_139AA:
		cmp.w	Checksum_fourcc(a2),d4
		bls.s	loc_139A8
		move.w	a2,($FFFFF714).w
		tst.w	($FFFFFFD8).w
		bne.s	loc_139C4
		move.w	a1,($FFFFF716).w
		move.w	a2,($FFFFF718).w
		rts
;--------------------------------------------------------------------------------
loc_139C4:
		move.w	($FFFFF716).w,a1
		move.w	($FFFFEE20).w,d4
		subq.w	#8,d4
		bhi.s	loc_139D8
		moveq	#1,d4
		bra.s	loc_139D8
loc_139D4: 
		lea	6(a1),a1
loc_139D8:
		cmp.w	2(a1),d4
		bhi.s	loc_139D4
		bra.s	loc_139E2
loc_139E0: 
		subq.w	#6,a1
loc_139E2:
		cmp.w	Checksum_fourcc(a1),d4
		bls.s	loc_139E0
		move.w	a1,($FFFFF716).w
		move.w	($FFFFF718).w,a2
		add.w	#$150,d4
		bra.s	loc_139FA
loc_139F6: 
		lea	6(a2),a2
loc_139FA:
		cmp.w	2(a2),d4
		bhi.s	loc_139F6
		bra.s	loc_13A04
loc_13A02: 
		subq.w	#6,a2
loc_13A04:
		cmp.w	Checksum_fourcc(a2),d4
		bls.s	loc_13A02
		move.w	a2,($FFFFF718).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Load_Ring_Pos
; [ End ]
;=============================================================================== 
		
;===============================================================================
; Sub Routine TouchRings
; [ Begin ]
;=============================================================================== 
TouchRings: 
		move.w	($FFFFF712).w,a1
		move.w	($FFFFF714).w,a2
		cmp.w	#$B000,a0
		beq.s	loc_13A26
		move.w	($FFFFF716).w,a1
		move.w	($FFFFF718).w,a2
loc_13A26:
		cmp.l	a1,a2
		beq	loc_13ABC
		cmp.w	#$5A,$30(a0)
		bcc loc_13ABC
		move.w	8(a0),d2
		move.w	$C(a0),d3
		sub.w	#8,d2
		moveq	#0,d5
		move.b	$16(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3
		cmp.b	#$4D,$1A(a0)
		bne.s	loc_13A5A
		add.w	#$C,d3
		moveq	#$A,d5
loc_13A5A:
		move.w	#6,d1
		move.w	#$C,d6
		move.w	#$10,d4
		add.w	d5,d5
loc_13A68: 
		tst.w	(a1)
		bne.w	loc_13AB2
		move.w	2(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_13A80
		add.w	d6,d0
		bcs.s	loc_13A86
		bra.w	loc_13AB2
loc_13A80:
		cmp.w	d4,d0
		bhi loc_13AB2
loc_13A86:
		move.w	4(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_13A98
		add.w	d6,d0
		bcs.s	loc_13A9E
		bra.w	loc_13AB2
loc_13A98:
		cmp.w	d5,d0
		bhi loc_13AB2
loc_13A9E:
		move.w	#$604,(a1)
		bsr.s	loc_13ABE
		lea	($FFFFEF82).w,a3
loc_13AA8: 
		tst.w	(a3)+
		bne.s	loc_13AA8
		move.w	a1,-(a3)
		addq.w	#1,($FFFFEF80).w
loc_13AB2:
		lea	6(a1),a1
		cmp.l	a1,a2
		bne.w	loc_13A68
loc_13ABC:
		rts
;--------------------------------------------------------------------------------
loc_13ABE:
		cmp.w	#$B000,a0
		beq	loc_FCDC
		bra.w	loc_FD20 
;===============================================================================
; Sub Routine Load_Ring_Pos
; [ End ]
;===============================================================================
		 
;===============================================================================
; Sub Routine loc_13ACA
; [ Begin ]
;===============================================================================
loc_13ACA:
		move.w	($FFFFF712).w,a0
		move.w	($FFFFF714).w,a4
		cmp.l	a0,a4
		bne.s	loc_13AD8
		rts
;--------------------------------------------------------------------------------
loc_13AD8:
		lea	($FFFFEE00).w,a3
loc_13ADC:
		tst.w	(a0)
		bmi loc_13B3E
		move.w	2(a0),d3
		sub.w	(a3),d3
		add.w	#$80,d3
		move.w	4(a0),d2
		sub.w	4(a3),d2
		and.w	#$7FF,d2
		add.w	#8,d2
		bmi.s	loc_13B3E
		cmp.w	#$F0,d2
		bge.s	loc_13B3E
		add.w	#$78,d2
		lea	(loc_13CBC),a1
		moveq	#0,d1
		move.b	1(a0),d1
		bne.s	loc_13B1A
		move.b	($FFFFFEA3).w,d1
loc_13B1A:
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		move.w	(a1)+,d0
		add.w	#$26BC,d0
		move.w	d0,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a2)+
loc_13B3E:
		lea	6(a0),a0
		cmp.l	a0,a4
		bne.w	loc_13ADC
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_13ACA
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine loc_13B4A
; [ Begin ]
;===============================================================================
loc_13B4A:
		lea	($FFFFEE00).w,a3
		move.w	#$78,d6
		move.w	($FFFFF712).w,a0
		move.w	($FFFFF714).w,a4
		cmp.l	a0,a4
		bne.s	loc_13B76
		rts
;--------------------------------------------------------------------------------
loc_13B60:
		lea	($FFFFEE20).w,a3
		move.w	#$158,d6
		move.w	($FFFFF716).w,a0
		move.w	($FFFFF718).w,a4
		cmp.l	a0,a4
		bne.s	loc_13B76
		rts
;--------------------------------------------------------------------------------
loc_13B76:
		tst.w	(a0)
		bmi loc_13BDA
		move.w	2(a0),d3
		sub.w	(a3),d3
		add.w	#$80,d3
		move.w	4(a0),d2
		sub.w	4(a3),d2
		and.w	#$7FF,d2
		add.w	#$88,d2
		bmi.s	loc_13BDA
		cmp.w	#$170,d2
		bge.s	loc_13BDA
		add.w	d6,d2
		lea	(loc_13CBC),a1
		moveq	#0,d1
		move.b	1(a0),d1
		bne.s	loc_13BB2
		move.b	($FFFFFEA3).w,d1
loc_13BB2:
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.b	(a1)+,d0
		ext.w	d0
		add.w	d2,d0
		move.w	d0,(a2)+
		move.b	(a1)+,d4
		move.b	loc_13BE6(pc,d4),(a2)+
		addq.b	#1,d5
		move.b	d5,(a2)+
		addq.w	#2,a1
		move.w	(a1)+,d0
		add.w	#$235E,d0
		move.w	d0,(a2)+
		move.w	(a1)+,d0
		add.w	d3,d0
		move.w	d0,(a2)+
loc_13BDA:
		lea	6(a0),a0
		cmp.l	a0,a4
		bne.w	loc_13B76
		rts
;--------------------------------------------------------------------------------
loc_13BE6:
		dc.b	$0,$0,$1,$1,$4,$4,$5,$5,$8,$8,$9,$9,$C,$C,$D,$D 
;===============================================================================
; Sub Routine loc_13B4A
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine loc_13BF6
; [ Begin ]
;===============================================================================
loc_13BF6:
		lea	($FFFFE800).w,a1
		moveq	#0,d0
		move.w	#$17F,d1
loc_13C00: 
		move.l	d0,(a1)+
		dbra	d1,loc_13C00
		lea	($FFFFEF80).w,a1
		move.w	#$F,d1
loc_13C0E: 
		move.l	d0,(a1)+
		dbra	d1,loc_13C0E
		moveq	#0,d5
		moveq	#0,d0
		move.w	($FFFFFE10).w,d0
		ror.b	#1,d0
		lsr.w	#6,d0
		lea	(Rings_Layout),a1 
		move.w	0(a1,d0),d0
		lea	0(a1,d0),a1
		lea	($FFFFE806).w,a2
loc_13C32: 
		move.w	(a1)+,d2
		bmi.s	loc_13C7A
		move.w	(a1)+,d3
		bmi.s	loc_13C5A
		move.w	d3,d0
		rol.w	#4,d0
		and.w	#7,d0
		and.w	#$FFF,d3
loc_13C46: 
		move.w	#0,(a2)+
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		add.w	#$18,d2
		addq.w	#1,d5
		dbra	d0,loc_13C46
		bra.s	loc_13C32
loc_13C5A:
		move.w	d3,d0
		rol.w	#4,d0
		and.w	#7,d0
		and.w	#$FFF,d3
loc_13C66: 
		move.w	#0,(a2)+
		move.w	d2,(a2)+
		move.w	d3,(a2)+
		add.w	#$18,d3
		addq.w	#1,d5
		dbra	d0,loc_13C66
		bra.s	loc_13C32
loc_13C7A:
		move.w	d5,($FFFFFF40).w
		move.w	#0,($FFFFFF42).w
		moveq	#$FFFFFFFF,d0
		move.l	d0,(a2)+
		lea	($FFFFE802).w,a1
		move.w	#$FE,d3
loc_13C90: 
		move.w	d3,d4
		lea	6(a1),a2
		move.w	(a1),d0
loc_13C98: 
		tst.w	(a2)
		beq.s	loc_13CAA
		cmp.w	(a2),d0
		bls.s	loc_13CAA
		move.l	(a1),d1
		move.l	(a2),d0
		move.l	d0,(a1)
		move.l	d1,(a2)
		swap.w	d0
loc_13CAA:
		lea	6(a2),a2
		dbra	d4,loc_13C98
		lea	6(a1),a1
		dbra	d3,loc_13C90
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_13BF6
; [ End ]
;===============================================================================
loc_13CBC:
		dc.w	loc_13CCC-loc_13CBC
		dc.w	loc_13CD4-loc_13CBC
		dc.w	loc_13CDC-loc_13CBC
		dc.w	loc_13CE4-loc_13CBC
		dc.w	loc_13CEC-loc_13CBC
		dc.w	loc_13CF4-loc_13CBC
		dc.w	loc_13CFC-loc_13CBC
		dc.w	loc_13D04-loc_13CBC
loc_13CCC:
		dc.l	$F8050000,$FFF8
loc_13CD4:
		dc.l	$F8050004,$2FFF8
loc_13CDC:
		dc.l	$F8010008,$4FFFC
loc_13CE4:
		dc.l	$F8050804,$802FFF8
loc_13CEC:
		dc.l	$F805000A,$5FFF8
loc_13CF4:
		dc.l	$F805180A,$1805FFF8
loc_13CFC:
		dc.l	$F805080A,$805FFF8
loc_13D04:
		dc.l	$F805100A,$1005FFF8
		
;===============================================================================
; Sub Routine Load Triangles Layout
; [ Begin ]
;===============================================================================
Load_Triangle_Pos: 
		moveq	#0,d0
		move.b	($FFFFF71A).w,d0
		move.w	loc_13D1A(pc,d0),d0
		jmp	loc_13D1A(pc,d0)
loc_13D1A: 
		dc.w	loc_13D1E-loc_13D1A
		dc.w	loc_13D72-loc_13D1A
loc_13D1E:
		addq.b	#2,($FFFFF71A).w
		lea	(CNz_Triangles_Act_1),a1
		tst.b	($FFFFFE11).w
		beq.s	loc_13D34
		lea	(CNz_Triangles_Act_2),a1 
loc_13D34:
		move.w	($FFFFEE00).w,d4
		subq.w	#8,d4
		bhi.s	loc_13D44
		moveq	#1,d4
		bra.s	loc_13D44
loc_13D40: 
		lea	6(a1),a1
loc_13D44:
		cmp.w	2(a1),d4
		bhi.s	loc_13D40
		move.l	a1,($FFFFF71C).w
		move.l	a1,($FFFFF724).w
		add.w	#$150,d4
		bra.s	loc_13D5C
loc_13D58: 
		lea	6(a1),a1
loc_13D5C: 
		cmp.w	2(a1),d4
		bhi.s	loc_13D58
		move.l	a1,($FFFFF720).w
		move.l	a1,($FFFFF728).w
		move.b	#1,($FFFFF71B).w
		rts
;--------------------------------------------------------------------------------
loc_13D72:
		move.l	($FFFFF71C).w,a1
		move.w	($FFFFEE00).w,d4
		subq.w	#8,d4
		bhi.s	loc_13D86
		moveq	#1,d4
		bra.s	loc_13D86
loc_13D82: 
		lea	6(a1),a1
loc_13D86:
		cmp.w	2(a1),d4
		bhi.s	loc_13D82
		bra.s	loc_13D90
loc_13D8E: 
		subq.w	#6,a1
loc_13D90:
		cmp.w	Checksum_fourcc(a1),d4
		bls.s	loc_13D8E
		move.l	a1,($FFFFF71C).w
		move.l	($FFFFF720).w,a2
		add.w	#$150,d4
		bra.s	loc_13DA8
loc_13DA4: 
		lea	6(a2),a2
loc_13DA8:
		cmp.w	2(a2),d4
		bhi.s	loc_13DA4
		bra.s	loc_13DB2
loc_13DB0: 
		subq.w	#6,a2
loc_13DB2:
		cmp.w	Checksum_fourcc(a2),d4
		bls.s	loc_13DB0
		move.l	a2,($FFFFF720).w
		tst.w	($FFFFFFD8).w
		bne.s	loc_13DCC
		move.l	a1,($FFFFF724).w
		move.l	a2,($FFFFF728).w
		rts
;--------------------------------------------------------------------------------
loc_13DCC:
		move.l	($FFFFF724).w,a1
		move.w	($FFFFEE20).w,d4
		subq.w	#8,d4
		bhi.s	loc_13DE0
		moveq	#1,d4
		bra.s	loc_13DE0
loc_13DDC: 
		lea	6(a1),a1
loc_13DE0:
		cmp.w	2(a1),d4
		bhi.s	loc_13DDC
		bra.s	loc_13DEA
loc_13DE8: 
		subq.w	#6,a1
loc_13DEA:
		cmp.w	Checksum_fourcc(a1),d4
		bls.s	loc_13DE8
		move.l	a1,($FFFFF724).w
		move.l	($FFFFF728).w,a2
		add.w	#$150,d4
		bra.s	loc_13E02
loc_13DFE: 
		lea	6(a2),a2
loc_13E02:
		cmp.w	2(a2),d4
		bhi.s	loc_13DFE
		bra.s	loc_13E0C
loc_13E0A: 
		subq.w	#6,a2
loc_13E0C:
		cmp.w	Checksum_fourcc(a2),d4
		bls.s	loc_13E0A
		move.l	a2,($FFFFF728).w
		rts
;--------------------------------------------------------------------------------
		
;===============================================================================
; Sub Routine Load Triangles Layout
; [ End ]
;=============================================================================== 
		
;===============================================================================
; Sub Routine Touch Response Triangles
; [ Begin ]
;=============================================================================== 
Touch_Response_CNz_Triangles: 
		move.l	($FFFFF71C).w,a1
		move.l	($FFFFF720).w,a2
		cmp.w	#$B000,a0
		beq.s	loc_13E2E
		move.l	($FFFFF724).w,a1
		move.l	($FFFFF728).w,a2
loc_13E2E:
		cmp.l	a1,a2
		beq	loc_13EC8
		move.w	8(a0),d2
		move.w	$C(a0),d3
		sub.w	#9,d2
		moveq	#0,d5
		move.b	$16(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3
		cmp.b	#$4D,$1A(a0)
		bne.s	loc_13E58
		add.w	#$C,d3
		moveq	#$A,d5
loc_13E58:
		move.w	#$12,d4
		add.w	d5,d5
loc_13E5E: 
		move.w	(a1),d0
		and.w	#$E,d0
		lea	loc_13EA8(pc,d0),a3
		moveq	#0,d1
		move.b	(a3)+,d1
		move.w	2(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_13E80
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_13E86
		bra.w	loc_13EBE
loc_13E80:
		cmp.w	d4,d0
		bhi loc_13EBE
loc_13E86:
		moveq	#0,d1
		move.b	(a3)+,d1
		move.w	4(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_13EA0
		add.w	d1,d1
		add.w	d1,d0
		bcs loc_13EB4
		bra.w	loc_13EBE
loc_13EA0:
		cmp.w	d5,d0
		bhi loc_13EBE
		bra.s	loc_13EB4
loc_13EA8:
		dc.b	$20,$20,$20,$20,$40,$8,$40,$8,$8,$40,$8,$40
loc_13EB4:
		move.w	(a1),d0
		move.w	loc_13ECA(pc,d0),d0
		jmp	loc_13ECA(pc,d0)
loc_13EBE:
		lea	6(a1),a1
		cmp.l	a1,a2
		bne.w	loc_13E5E
loc_13EC8:
		rts
;--------------------------------------------------------------------------------
loc_13ECA:
		dc.w	loc_13ED6-loc_13ECA
		dc.w	loc_13F88-loc_13ECA
		dc.w	loc_13FEE-loc_13ECA
		dc.w	loc_14046-loc_13ECA
		dc.w	loc_1409C-loc_13ECA
		dc.w	loc_140F4-loc_13ECA
loc_13ED6:
		move.w	4(a1),d0
		sub.w	$C(a0),d0
		neg.w	d0
		cmp.w	#$20,d0
		blt.s	loc_13EF0
		move.w	#$A00,$12(a0)
		bra.w	loc_1414A
loc_13EF0:
		move.w	2(a1),d0
		sub.w	8(a0),d0
		neg.w	d0
		cmp.w	#$20,d0
		blt.s	loc_13F0A
		move.w	#$A00,$10(a0)
		bra.w	loc_1414A
loc_13F0A:
		move.w	2(a1),d0
		sub.w	8(a0),d0
		cmp.w	#$20,d0
		blt.s	loc_13F1C
		move.w	#$20,d0
loc_13F1C:
		add.w	4(a1),d0
		subq.w	#8,d0
		move.w	$C(a0),d1
		add.w	#$E,d1
		sub.w	d1,d0
		bcc.s	loc_13F38
		move.w	#$20,d3
		bsr.s	loc_13F3A
		bra.w	loc_1414A
loc_13F38:
		rts
;--------------------------------------------------------------------------------
loc_13F3A:
		move.w	$10(a0),d1
		move.w	$12(a0),d2
		jsr	CalcAngle 
		move.b	d0,($FFFFFFDC).w
		sub.w	d3,d0
		move.w	d0,d1
		bpl.s	loc_13F54
		neg.w	d1
loc_13F54:
		neg.w	d0
		add.w	d3,d0
		move.b	d0,($FFFFFFDD).w
		move.b	d1,($FFFFFFDF).w
		cmp.b	#$38,d1
		bcs.s	loc_13F68
		move.w	d3,d0
loc_13F68:
		move.b	d0,($FFFFFFDE).w
		jsr	CalcSine 
		muls.w	#$F600,d1
		asr.l	#8,d1
		move.w	d1,$10(a0)
		muls.w	#$F600,d0
		asr.l	#8,d0
		move.w	d0,$12(a0)
		rts
;--------------------------------------------------------------------------------
loc_13F88:
		move.w	4(a1),d0
		sub.w	$C(a0),d0
		neg.w	d0
		cmp.w	#$20,d0
		blt.s	loc_13FA2
		move.w	#$A00,$12(a0)
		bra.w	loc_1414A
loc_13FA2:
		move.w	2(a1),d0
		sub.w	8(a0),d0
		cmp.w	#$20,d0
		blt.s	loc_13FBA
		move.w	#$F600,$10(a0)
		bra.w	loc_1414A
loc_13FBA:
		move.w	2(a1),d0
		sub.w	8(a0),d0
		neg.w	d0
		cmp.w	#$20,d0
		blt.s	loc_13FCE
		move.w	#$20,d0
loc_13FCE:
		add.w	4(a1),d0
		subq.w	#8,d0
		move.w	$C(a0),d1
		add.w	#$E,d1
		sub.w	d1,d0
		bcc.s	loc_13FEC
		move.w	#$60,d3
		bsr.w	loc_13F3A
		bra.w	loc_1414A
loc_13FEC:
		rts
;--------------------------------------------------------------------------------
loc_13FEE:
		move.w	4(a1),d0
		sub.w	$C(a0),d0
		neg.w	d0
		cmp.w	#8,d0
		blt.s	loc_14008
		move.w	#$A00,$12(a0)
		bra.w	loc_1414A
loc_14008:
		move.w	2(a1),d0
		sub.w	8(a0),d0
		cmp.w	#$40,d0
		blt.s	loc_14020
		move.w	#$F600,$10(a0)
		bra.w	loc_1414A
loc_14020:
		neg.w	d0
		cmp.w	#$40,d0
		blt.s	loc_14032
		move.w	#$A00,$10(a0)
		bra.w	loc_1414A
loc_14032:
		move.w	#$38,d3
		tst.w	d0
		bmi.s	loc_1403E
		move.w	#$48,d3
loc_1403E:
		bsr.w	loc_13F3A
		bra.w	loc_1414A
loc_14046:
		move.w	4(a1),d0
		sub.w	$C(a0),d0
		cmp.w	#8,d0
		blt.s	loc_1405E
		move.w	#$F600,$12(a0)
		bra.w	loc_1414A
loc_1405E:
		move.w	2(a1),d0
		sub.w	8(a0),d0
		cmp.w	#$40,d0
		blt.s	loc_14076
		move.w	#$F600,$10(a0)
		bra.w	loc_1414A
loc_14076:
		neg.w	d0
		cmp.w	#$40,d0
		blt.s	loc_14088
		move.w	#$A00,$10(a0)
		bra.w	loc_1414A
loc_14088:
		move.w	#$C8,d3
		tst.w	d0
		bmi.s	loc_14094
		move.w	#$B8,d3
loc_14094:
		bsr.w	loc_13F3A
		bra.w	loc_1414A
loc_1409C:
		move.w	2(a1),d0
		sub.w	8(a0),d0
		neg.w	d0
		cmp.w	#8,d0
		blt.s	loc_140B6
		move.w	#$A00,$10(a0)
		bra.w	loc_1414A
loc_140B6:
		move.w	4(a1),d0
		sub.w	$C(a0),d0
		cmp.w	#$40,d0
		blt.s	loc_140CE
		move.w	#$F600,$12(a0)
		bra.w	loc_1414A
loc_140CE:
		neg.w	d0
		cmp.w	#$40,d0
		blt.s	loc_140E0
		move.w	#$A00,$10(a0)
		bra.w	loc_1414A
loc_140E0:
		move.w	#8,d3
		tst.w	d0
		bmi.s	loc_140EC
		move.w	#$F8,d3
loc_140EC:
		bsr.w	loc_13F3A
		bra.w	loc_1414A
loc_140F4:
		move.w	2(a1),d0
		sub.w	8(a0),d0
		cmp.w	#8,d0
		blt.s	loc_1410C
		move.w	#$A00,$10(a0)
		bra.w	loc_1414A
loc_1410C:
		move.w	4(a1),d0
		sub.w	$C(a0),d0
		cmp.w	#$40,d0
		blt.s	loc_14124
		move.w	#$F600,$12(a0)
		bra.w	loc_1414A
loc_14124:
		neg.w	d0
		cmp.w	#$40,d0
		blt.s	loc_14136
		move.w	#$A00,$10(a0)
		bra.w	loc_1414A
loc_14136:
		move.w	#$78,d3
		tst.w	d0
		bmi.s	loc_14142
		move.w	#$88,d3
loc_14142:
		bsr.w	loc_13F3A
		bra.w	loc_1414A
loc_1414A:
		bset	#1,$22(a0)
		bclr	#4,$22(a0)
		bclr	#5,$22(a0)
		clr.b	$3C(a0)
		move.w	#$D9,d0
		jmp	Play_Sfx
;------------------------------------------------------------------------------- 
CNz_Triangles_Act_1:
		incbin 'objpos/tri_act1.dat'
CNz_Triangles_Act_2:
		incbin 'objpos/tri_act2.dat'
;===============================================================================
; Sub Routine Touch Response Triangles
; [ End ]
;=============================================================================== 
		nop ; Filler 
;===============================================================================
; Sub Routine Load_Object_Pos
; [ Begin ]
;===============================================================================
Load_Object_Pos: 
		moveq	#0,d0
		move.b	($FFFFF76C).w,d0
		move.w	loc_14402(pc,d0),d0
		jmp	loc_14402(pc,d0) 
loc_14402:
		dc.w	loc_14408-loc_14402
		dc.w	loc_144B4-loc_14402
		dc.w	loc_145FC-loc_14402 
loc_14408:
		addq.b	#2,($FFFFF76C).w
		move.w	($FFFFFE10).w,d0
		ror.b	#1,d0
		lsr.w	#6,d0
		lea	(Objects_Layout),a0
		move.l	a0,a1
		add.w	0(a0,d0),a0
		move.l	a0,($FFFFF770).w
		move.l	a0,($FFFFF774).w	
		move.l	a0,($FFFFF778).w
		move.l	a0,($FFFFF77C).w
		lea	($FFFFFC00).w,a2
		move.w	#$101,(a2)+
		move.w	#$5E,d0
loc_1443C: 
		clr.l	(a2)+
		dbra	d0,loc_1443C
		lea	($FFFFFC00).w,a2
		moveq	#0,d2
		move.w	($FFFFEE00).w,d6
		sub.w	#$80,d6
		bcc.s	loc_14454
		moveq	#0,d6
loc_14454:
		and.w	#$FF80,d6
		move.l	($FFFFF770).w,a0
loc_1445C: 
		cmp.w	(a0),d6
		bls.s	loc_1446E
		tst.b	2(a0)
		bpl.s	loc_1446A
		move.b	(a2),d2
		addq.b	#1,(a2)
loc_1446A:
		addq.w	#6,a0
		bra.s	loc_1445C
loc_1446E:
		move.l	a0,($FFFFF770).w
		move.l	a0,($FFFFF778).w
		move.l	($FFFFF774).w,a0
		sub.w	#$80,d6
		bcs.s	loc_14492
loc_14480: 
		cmp.w	(a0),d6
		bls.s	loc_14492
		tst.b	2(a0)
		bpl.s	loc_1448E
		addq.b	#1,1(a2)
loc_1448E:
		addq.w	#6,a0
		bra.s	loc_14480
loc_14492:
		move.l	a0,($FFFFF774).w
		move.l	a0,($FFFFF77C).w
		move.w	#$FFFF,($FFFFF76E).w
		move.w	#$FFFF,($FFFFF78C).w
		tst.w	($FFFFFFD8).w
		beq.s	loc_144B4
		addq.b	#2,($FFFFF76C).w
		bra.w	loc_14580 
loc_144B4:
		move.w	($FFFFEE00).w,d1
		sub.w	#$80,d1
		and.w	#$FF80,d1
		move.w	d1,($FFFFF7DA).w
		lea	($FFFFFC00).w,a2
		moveq	#0,d2
		move.w	($FFFFEE00).w,d6
		and.w	#$FF80,d6
		cmp.w	($FFFFF76E).w,d6
		beq	loc_1457E
		bge.s	loc_1453A
		move.w	d6,($FFFFF76E).w
		move.l	($FFFFF774).w,a0
		sub.w	#$80,d6
		bcs.s	loc_14516
loc_144EA: 
		cmp.w	$FFFFFFFA(a0),d6
		bge.s	loc_14516
		subq.w	#6,a0
		tst.b	2(a0)
		bpl.s	loc_14500
		subq.b	#1,1(a2)
		move.b	1(a2),d2
loc_14500:
		bsr.w	loc_14866
		bne.s	loc_1450A
		subq.w	#6,a0
		bra.s	loc_144EA
loc_1450A:
		tst.b	2(a0)
		bpl.s	loc_14514
		addq.b	#1,1(a2)
loc_14514:
		addq.w	#6,a0
loc_14516:
		move.l	a0,($FFFFF774).w
		move.l	($FFFFF770).w,a0
		add.w	#$300,d6
loc_14522: 
		cmp.w	$FFFFFFFA(a0),d6
		bgt.s	loc_14534
		tst.b	Checksum_fourcc(a0)
		bpl.s	loc_14530
		subq.b	#1,(a2)
loc_14530:
		subq.w	#6,a0
		bra.s	loc_14522
loc_14534:
		move.l	a0,($FFFFF770).w
		rts
;--------------------------------------------------------------------------------
loc_1453A:
		move.w	d6,($FFFFF76E).w
		move.l	($FFFFF770).w,a0
		add.w	#$280,d6
loc_14546: 
		cmp.w	(a0),d6
		bls.s	loc_1455A
		tst.b	2(a0)
		bpl.s	loc_14554
		move.b	(a2),d2
		addq.b	#1,(a2)
loc_14554:
		bsr.w	loc_14866
		beq.s	loc_14546
loc_1455A:
		move.l	a0,($FFFFF770).w
		move.l	($FFFFF774).w,a0
		sub.w	#$300,d6
		bcs.s	loc_1457A
loc_14568: 
		cmp.w	(a0),d6
		bls.s	loc_1457A
		tst.b	2(a0)
		bpl.s	loc_14576
		addq.b	#1,1(a2)
loc_14576:
		addq.w	#6,a0
		bra.s	loc_14568
loc_1457A:
		move.l	a0,($FFFFF774).w
loc_1457E:
		rts
;--------------------------------------------------------------------------------
loc_14580:
		moveq	#$FFFFFFFF,d0
		move.l	d0,($FFFFF780).w
		move.l	d0,($FFFFF784).w
		move.l	d0,($FFFFF788).w
		move.l	d0,($FFFFF78C).w
		move.w	#0,($FFFFF76E).w
		move.w	#0,($FFFFF78C).w
		lea	($FFFFFC00).w,a2
		move.w	(a2),($FFFFF78E).w
		moveq	#0,d2
		lea	($FFFFFC00).w,a5
		lea	($FFFFF770).w,a4
		lea	($FFFFF786).w,a1
		lea	($FFFFF789).w,a6
		moveq	#$FFFFFFFE,d6
		bsr.w	loc_14714
		lea	($FFFFF786).w,a1
		moveq	#$FFFFFFFF,d6
		bsr.w	loc_14714
		lea	($FFFFF786).w,a1
		moveq	#0,d6
		bsr.w	loc_14714
		lea	($FFFFF78E).w,a5
		lea	($FFFFF778).w,a4
		lea	($FFFFF789).w,a1
		lea	($FFFFF786).w,a6
		moveq	#$FFFFFFFE,d6
		bsr.w	loc_14714
		lea	($FFFFF789).w,a1
		moveq	#$FFFFFFFF,d6
		bsr.w	loc_14714
		lea	($FFFFF789).w,a1
		moveq	#0,d6
		bsr.w	loc_14714
loc_145FC:
		move.w	($FFFFEE00).w,d1
		and.w	#$FF00,d1
		move.w	d1,($FFFFF7DA).w
		move.w	($FFFFEE20).w,d1
		and.w	#$FF00,d1
		move.w	d1,($FFFFF7DC).w
		move.b	($FFFFEE00).w,d6
		and.w	#$FF,d6
		move.w	($FFFFF76E).w,d0
		cmp.w	($FFFFF76E).w,d6
		beq.s	loc_1463C
		move.w	d6,($FFFFF76E).w
		lea	($FFFFFC00).w,a5
		lea	($FFFFF770).w,a4
		lea	($FFFFF786).w,a1
		lea	($FFFFF789).w,a6
		bsr.s	loc_14666
loc_1463C:
		move.b	($FFFFEE20).w,d6
		and.w	#$FF,d6
		move.w	($FFFFF78C).w,d0
		cmp.w	($FFFFF78C).w,d6
		beq.s	loc_14664
		move.w	d6,($FFFFF78C).w
		lea	($FFFFF78E).w,a5
		lea	($FFFFF778).w,a4
		lea	($FFFFF789).w,a1
		lea	($FFFFF786).w,a6
		bsr.s	loc_14666
loc_14664:
		rts
;--------------------------------------------------------------------------------
loc_14666:
		lea	($FFFFFC00).w,a2
		moveq	#0,d2
		cmp.w	d0,d6
		beq	loc_1457E
		bge loc_14714
		move.b	2(a1),d2
		move.b	1(a1),2(a1)
		move.b	(a1),1(a1)
		move.b	d6,(a1)
		cmp.b	(a6),d2
		beq.s	loc_1469C
		cmp.b	1(a6),d2
		beq.s	loc_1469C
		cmp.b	2(a6),d2
		beq.s	loc_1469C
		bsr.w	loc_147F6
		bra.s	loc_146A0
loc_1469C:
		bsr.w	loc_147BA
loc_146A0:
		bsr.w	loc_14796
		bne.s	loc_146C4
		move.l	4(a4),a0
loc_146AA: 
		cmp.b	$FFFFFFFA(a0),d6
		bne.s	loc_146BE
		tst.b	Checksum_fourcc(a0)
		bpl.s	loc_146BA
		subq.b	#1,1(a5)
loc_146BA:
		subq.w	#6,a0
		bra.s	loc_146AA
loc_146BE:
		move.l	a0,4(a4)
		bra.s	loc_146FA
loc_146C4:
		move.l	4(a4),a0
		move.b	d6,(a1)
loc_146CA: 
		cmp.b	$FFFFFFFA(a0),d6
		bne.s	loc_146F6
		subq.w	#6,a0
		tst.b	2(a0)
		bpl.s	loc_146E0
		subq.b	#1,1(a5)
		move.b	1(a5),d2
loc_146E0:
		bsr.w	loc_148B0
		bne.s	loc_146EA
		subq.w	#6,a0
		bra.s	loc_146CA
loc_146EA:
		tst.b	2(a0)
		bpl.s	loc_146F4
		addq.b	#1,1(a5)
loc_146F4:
		addq.w	#6,a0
loc_146F6:
		move.l	a0,4(a4)
loc_146FA:
		move.l	(a4),a0
		addq.w	#3,d6
loc_146FE: 
		cmp.b	$FFFFFFFA(a0),d6
		bne.s	loc_14710
		tst.b	Checksum_fourcc(a0)
		bpl.s	loc_1470C
		subq.b	#1,(a5)
loc_1470C:
		subq.w	#6,a0
		bra.s	loc_146FE
loc_14710:
		move.l	a0,(a4)
		rts
;--------------------------------------------------------------------------------
loc_14714:
		addq.w	#2,d6
		move.b	(a1),d2
		move.b	1(a1),(a1)
		move.b	2(a1),1(a1)
		move.b	d6,2(a1)
		cmp.b	(a6),d2
		beq.s	loc_1473C
		cmp.b	1(a6),d2
		beq.s	loc_1473C
		cmp.b	2(a6),d2
		beq.s	loc_1473C
		bsr.w	loc_147F6
		bra.s	loc_14740
loc_1473C:
		bsr.w	loc_147BA
loc_14740:
		bsr.w	loc_14796
		bne.s	loc_1475C
		move.l	(a4),a0
loc_14748: 
		cmp.b	(a0),d6
		bne.s	loc_14758
		tst.b	2(a0)
		bpl.s	loc_14754
		addq.b	#1,(a5)
loc_14754:
		addq.w	#6,a0
		bra.s	loc_14748
loc_14758:
		move.l	a0,(a4)
		bra.s	loc_14776
loc_1475C:
		move.l	(a4),a0
		move.b	d6,(a1)
loc_14760: 
		cmp.b	(a0),d6
		bne.s	loc_14774
		tst.b	2(a0)
		bpl.s	loc_1476E
		move.b	(a5),d2
		addq.b	#1,(a5)
loc_1476E:
		bsr.w	loc_148B0
		beq.s	loc_14760
loc_14774:
		move.l	a0,(a4)
loc_14776:
		move.l	4(a4),a0
		subq.w	#3,d6
		bcs.s	loc_14790
loc_1477E: 
		cmp.b	(a0),d6
		bne.s	loc_14790
		tst.b	2(a0)
		bpl.s	loc_1478C
		addq.b	#1,1(a5)
loc_1478C:
		addq.w	#6,a0
		bra.s	loc_1477E
loc_14790:
		move.l	a0,4(a4)
		rts
;--------------------------------------------------------------------------------
loc_14796:
		move.l	a1,-(sp)
		lea	($FFFFF780).w,a1
		cmp.b	(a1)+,d6
		beq.s	loc_147B6
		cmp.b	(a1)+,d6
		beq.s	loc_147B6
		cmp.b	(a1)+,d6
		beq.s	loc_147B6
		cmp.b	(a1)+,d6
		beq.s	loc_147B6
		cmp.b	(a1)+,d6
		beq.s	loc_147B6
		cmp.b	(a1)+,d6
		beq.s	loc_147B6
		moveq	#1,d0
loc_147B6:
		move.l	(sp)+,a1
		rts
;--------------------------------------------------------------------------------
loc_147BA:
		lea	($FFFFF780).w,a1
		lea	($FFFFBE00).w,a3
		tst.b	(a1)+
		bmi.s	loc_147F2
		lea	($FFFFC100).w,a3
		tst.b	(a1)+
		bmi.s	loc_147F2
		lea	($FFFFC400).w,a3
		tst.b	(a1)+
		bmi.s	loc_147F2
		lea	($FFFFC700).w,a3
		tst.b	(a1)+
		bmi.s	loc_147F2
		lea	($FFFFCA00).w,a3
		tst.b	(a1)+
		bmi.s	loc_147F2
		lea	($FFFFCD00).w,a3
		tst.b	(a1)+
		bmi.s	loc_147F2
		nop
		nop
loc_147F2:
		subq.w	#1,a1
		rts
;--------------------------------------------------------------------------------
loc_147F6:
		lea	($FFFFF780).w,a1
		lea	($FFFFBE00).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_1482E
		lea	($FFFFC100).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_1482E
		lea	($FFFFC400).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_1482E
		lea	($FFFFC700).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_1482E
		lea	($FFFFCA00).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_1482E
		lea	($FFFFCD00).w,a3
		cmp.b	(a1)+,d2
		beq.s	loc_1482E
		nop
		nop
loc_1482E:
		move.b	#$FF,-(a1)
		movem.l	a1/a3,-(sp)
		moveq	#0,d1
		moveq	#$B,d2
loc_1483A: 
		tst.b	(a3)
		beq.s	loc_14856
		move.l	a3,a1
		moveq	#0,d0
		move.b	$23(a1),d0
		beq.s	loc_1484E
		bclr	#7,2(a2,d0)
loc_1484E:
		moveq	#$F,d0
loc_14850: 
		move.l	d1,(a1)+
		dbra	d0,loc_14850
loc_14856:
		lea	$40(a3),a3
		dbra	d2,loc_1483A
		moveq	#0,d2
		movem.l	(sp)+,a1/a3
		rts
;--------------------------------------------------------------------------------
loc_14866:
		tst.b	2(a0)
		bpl.s	loc_1487A
		bset	#7,2(a2,d2)
		beq.s	loc_1487A
		addq.w	#6,a0
		moveq	#0,d0
		rts
;--------------------------------------------------------------------------------
loc_1487A:
		bsr.w	SingleObjectLoad 
		bne.s	loc_148AE
		move.w	(a0)+,8(a1)
		move.w	(a0)+,d0
		bpl.s	loc_1488C
		move.b	d2,$23(a1)
loc_1488C:
		move.w	d0,d1
		and.w	#$FFF,d0
		move.w	d0,$C(a1)
		rol.w	#3,d1
		and.b	#3,d1
		move.b	d1,1(a1)
		move.b	d1,$22(a1)
		move.b	(a0)+,0(a1)
		move.b	(a0)+,$28(a1)
		moveq	#0,d0
loc_148AE:
		rts
;--------------------------------------------------------------------------------
loc_148B0:
		tst.b	2(a0)
		bpl.s	loc_148C4
		bset	#7,2(a2,d2)
		beq.s	loc_148C4
		addq.w	#6,a0
		moveq	#0,d0
		rts
;--------------------------------------------------------------------------------
loc_148C4:
		btst	#4,2(a0)
		beq.s	loc_148D4
		bsr.w	SingleObjectLoad 
		bne.s	loc_14908
		bra.s	loc_148DA
loc_148D4:
		bsr.w	Load_Object_List 
		bne.s	loc_14908
loc_148DA:
		move.w	(a0)+,8(a1)
		move.w	(a0)+,d0
		bpl.s	loc_148E6
		move.b	d2,$23(a1)
loc_148E6:
		move.w	d0,d1
		and.w	#$FFF,d0
		move.w	d0,$C(a1)
		rol.w	#3,d1
		and.b	#3,d1
		move.b	d1,1(a1)
		move.b	d1,$22(a1)
		move.b	(a0)+,0(a1)
		move.b	(a0)+,$28(a1)
		moveq	#0,d0
loc_14908:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Load_Object_Pos
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine SingleObjectLoad
; [ Begin ]
;===============================================================================
SingleObjectLoad: 
		lea	($FFFFB800).w,a1
		move.w	#$5F,d0
loc_14912:
		tst.b	(a1)
		beq.s	loc_1491E
		lea	$40(a1),a1
		dbra	d0,loc_14912
loc_1491E:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine SingleObjectLoad
; [ End ]
;===============================================================================
 
;=============================================================================== 
; Sub Routine S1SingleObjectLoad
; [ Begin ] 
;=============================================================================== 
S1SingleObjectLoad: 
		move.l	a0,a1
		move.w	#$D000,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.s	loc_1493A
loc_1492E: 
		tst.b	(a1)
		beq.s	loc_1493A
		lea	$40(a1),a1
		dbra	d0,loc_1492E
loc_1493A:
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine S1SingleObjectLoad
; [ End ] 
;===============================================================================
 
;===============================================================================
; Sub Routine Load_Object_List
; [ Begin ]
;===============================================================================
Load_Object_List: 
		move.l	a3,a1
		move.w	#$B,d0 
loc_14942: 
		tst.b	(a1)
		beq.s	loc_1494E
		lea	$40(a1),a1
		dbra	d0,loc_14942
loc_1494E:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Load_Object_List
; [ End ]
;=============================================================================== 
Obj_0x41_Springs
		include 'objects/obj_0x41.asm'
		nop ; Filler
;------------------------------------------------------------------------------- 
Obj_0x0D_End_Panel: 
		include 'objects/obj_0x0D.asm'
		nop ; Filler 
;=============================================================================== 
; Sub Routine SolidObject
; [ Begin ] 
;=============================================================================== 
SolidObject: 
		lea	(Object_RAM).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	loc_1577A
		movem.l	(sp)+,d1-d4
		lea	($FFFFB040).w,a1
		tst.b	1(a1)
		bpl loc_157BA
		addq.b	#1,d6
loc_1577A:
		btst D6,$22(a0)
		beq	loc_15A2C
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,$22(a1)
		bne.s	loc_1579E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_1579E
		cmp.w	d2,d0
		bcs.s	loc_157B2
loc_1579E:
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr D6,$22(a0)
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_157B2:
		move.w	d4,d2
		bsr.w	loc_15BCA
		moveq	#0,d4
loc_157BA:
		rts
;--------------------------------------------------------------------------------
loc_157BC: 
		lea	(Object_RAM).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	loc_157D2
		movem.l	(sp)+,d1-d4
		lea	($FFFFB040).w,a1
		addq.b	#1,d6
loc_157D2:
		btst D6,$22(a0)
		beq	loc_15A34
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,$22(a1)
		bne.s	loc_157F6
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_157F6
		cmp.w	d2,d0
		bcs.s	loc_1580A
loc_157F6:
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr D6,$22(a0)
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_1580A:
		move.w	d4,d2
		bsr.w	loc_15BCA
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine SolidObject
; [ End ] 
;=============================================================================== 
loc_15814: ; Called by Flippers
		lea	(Object_RAM).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	loc_1582A
		movem.l	(sp)+,d1-d4
		lea	($FFFFB040).w,a1
		addq.b	#1,d6 
;------------------------------------------------------------------------------- 
loc_1582A:
		btst D6,$22(a0)
		beq	loc_15972
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,$22(a1)
		bne.s	loc_1584E
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_1584E
		cmp.w	d2,d0
		bcs.s	loc_15862
loc_1584E:
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr D6,$22(a0)
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_15862:
		move.w	d4,d2
		bsr.w	loc_15C04
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
		lea	(Object_RAM).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	loc_15882
		movem.l	(sp)+,d1-d4
		lea	($FFFFB040).w,a1
		addq.b	#1,d6
loc_15882:
		btst D6,$22(a0)
		beq	loc_159CC
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,$22(a1)
		bne.s	loc_158A6
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_158A6
		cmp.w	d2,d0
		bcs.s	loc_158BA
loc_158A6:
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr D6,$22(a0)
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_158BA:
		move.w	d4,d2
		bsr.w	loc_15C46
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_158C4:
		lea	(Object_RAM).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	loc_158DA
		movem.l	(sp)+,d1-d4
		lea	($FFFFB040).w,a1
		addq.b	#1,d6
loc_158DA:
		btst D6,$22(a0)
		beq	loc_15930
		btst	#1,$22(a1)
		bne.s	loc_158FC
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_158FC
		add.w	d1,d1
		cmp.w	d1,d0
		bcs.s	loc_15910
loc_158FC:
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr D6,$22(a0)
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_15910:
		move.w	$C(a0),d0
		sub.w	d2,d0
		add.w	d3,d0
		moveq	#0,d1
		move.b	$16(a1),d1
		sub.w	d1,d0
		move.w	d0,$C(a1)
		sub.w	8(a0),d4
		sub.w	d4,8(a1)
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_15930:
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi loc_15B08
		move.w	d1,d4
		add.w	d4,d4
		cmp.w	d4,d0
		bhi loc_15B08
		move.w	$C(a0),d5
		add.w	d3,d5
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi loc_15B08
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc loc_15B08
		bra.w	loc_15A72
loc_15972: 
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi loc_15B08
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi loc_15B08
		move.w	d0,d5
		btst	#0,1(a0)
		beq.s	loc_15998
		not.w	d5
		add.w	d3,d5
loc_15998:
		lsr.w	#1,d5
		move.b	0(a2,d5),d3
		sub.b	(a2),d3
		ext.w	d3
		move.w	$C(a0),d5
		sub.w	d3,d5
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi loc_15B08
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc loc_15B08
		bra.w	loc_15A72
loc_159CC: 
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi loc_15B08
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi loc_15B08
		move.w	d0,d5
		btst	#0,1(a0)
		beq.s	loc_159F2
		not.w	d5
		add.w	d3,d5
loc_159F2:
		and.w	#$FFFE,d5
		move.b	0(a2,d5),d3
		move.b	1(a2,d5),d2
		ext.w	d2
		ext.w	d3
		move.w	$C(a0),d5
		sub.w	d3,d5
		move.w	$C(a1),d3
		sub.w	d5,d3
		move.b	$16(a1),d5
		ext.w	d5
		add.w	d5,d3
		addq.w	#4,d3
		bmi loc_15B08
		add.w	d5,d2
		move.w	d2,d4
		add.w	d5,d4
		cmp.w	d4,d3
		bcc loc_15B08
		bra.w	loc_15A72
loc_15A2C: 
		tst.b	1(a0)
		bpl loc_15B08
loc_15A34: 
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi loc_15B08
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi loc_15B08
		move.b	$16(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	$C(a1),d3
		sub.w	$C(a0),d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi loc_15B08
		and.w	#$7FF,d3
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bcc loc_15B08
loc_15A72:
		tst.b	$2A(a1)
		bmi loc_15B08
		cmp.b	#6,$24(a1)
		bcc loc_15B2E
		tst.w	(Debug_placement_mode).w
		bne.w	loc_15B2E
		move.w	d0,d5
		cmp.w	d0,d1
		bcc.s	loc_15A9A
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5
loc_15A9A:
		move.w	d3,d1
		cmp.w	d3,d2
		bcc.s	loc_15AA8
		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1
loc_15AA8:
		cmp.w	d1,d5
		bhi loc_15B32
loc_15AAE: 
		cmp.w	#4,d1
		bls.s	loc_15AFA
		tst.w	d0
		beq.s	loc_15AD4
		bmi.s	loc_15AC2
		tst.w	$10(a1)
		bmi.s	loc_15AD4
		bra.s	loc_15AC8
loc_15AC2:
		tst.w	$10(a1)
		bpl.s	loc_15AD4
loc_15AC8:
		move.w	#0,$14(a1)
		move.w	#0,$10(a1)
loc_15AD4:
		sub.w	d0,8(a1)
		btst	#1,$22(a1)
		bne.s	loc_15AFA
		move.l	d6,d4
		addq.b	#2,d4
		bset D4,$22(a0)
		bset	#5,$22(a1)
		move.w	d6,d4
		add.b	#$D,d4
		bset D4,d6
		moveq	#1,d4
		rts
;--------------------------------------------------------------------------------
loc_15AFA:
		bsr.s	loc_15B20
		move.w	d6,d4
		add.b	#$D,d4
		bset D4,d6
		moveq	#1,d4
		rts
;--------------------------------------------------------------------------------
loc_15B08:
		move.l	d6,d4
		addq.b	#2,d4
		btst D4,$22(a0)
		beq.s	loc_15B2E
		cmp.b	#2,$1C(a1)
		beq.s	loc_15B20
		move.w	#1,$1C(a1)
loc_15B20:
		move.l	d6,d4
		addq.b	#2,d4
		bclr D4,$22(a0)
		bclr	#5,$22(a1)
loc_15B2E:
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_15B32:
		tst.w	d3
		bmi.s	loc_15B3E
		cmp.w	#$10,d3
		bcs.s	loc_15B8E
		bra.s	loc_15B08
loc_15B3E:
		tst.w	$12(a1)
		beq.s	loc_15B60
		bpl.s	loc_15B54
		tst.w	d3
		bpl.s	loc_15B54
		sub.w	d3,$C(a1)
		move.w	#0,$12(a1)
loc_15B54:
		move.w	d6,d4
		add.b	#$F,d4
		bset D4,d6
		moveq	#$FFFFFFFE,d4
		rts
;--------------------------------------------------------------------------------
loc_15B60:
		btst	#1,$22(a1)
		bne.s	loc_15B54
		move.w	d0,d4
		bpl.s	loc_15B6E
		neg.w	d4
loc_15B6E:
		cmp.w	#$10,d4
		bcs loc_15AAE
		move.l	a0,-(sp)
		move.l	a1,a0
		jsr	Kill_Player 
		move.l	(sp)+,a0
		move.w	d6,d4
		add.b	#$F,d4
		bset D4,d6
		moveq	#$FFFFFFFE,d4
		rts
;--------------------------------------------------------------------------------
loc_15B8E:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	$19(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	8(a1),d1
		sub.w	8(a0),d1
		bmi.s	loc_15BC6
		cmp.w	d2,d1
		bcc.s	loc_15BC6
		tst.w	$12(a1)
		bmi.s	loc_15BC6
		sub.w	d3,$C(a1)
		subq.w	#1,$C(a1)
		bsr.w	loc_15E4C
		move.w	d6,d4
		add.b	#$11,d4
		bset D4,d6
		moveq	#$FFFFFFFF,d4
		rts
;--------------------------------------------------------------------------------
loc_15BC6:
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_15BCA:
		move.w	$C(a0),d0
		sub.w	d3,d0
		bra.s	loc_15BDA
		move.w	$C(a0),d0
		sub.w	#9,d0
loc_15BDA:
		tst.b	$2A(a1)
		bmi.s	loc_15C02
		cmp.b	#6,$24(a1)
		bcc.s	loc_15C02
		tst.w	(Debug_placement_mode).w
		bne.s	loc_15C02
		moveq	#0,d1
		move.b	$16(a1),d1
		sub.w	d1,d0
		move.w	d0,$C(a1)
		sub.w	8(a0),d2
		sub.w	d2,8(a1)
loc_15C02:
		rts
;--------------------------------------------------------------------------------
loc_15C04:
		btst	#3,$22(a1)
		beq.s	loc_15C44
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		lsr.w	#1,d0
		btst	#0,1(a0)
		beq.s	loc_15C24
		not.w	d0
		add.w	d1,d0
loc_15C24:
		move.b	0(a2,d0),d1
		ext.w	d1
		move.w	$C(a0),d0
		sub.w	d1,d0
		moveq	#0,d1
		move.b	$16(a1),d1
		sub.w	d1,d0
		move.w	d0,$C(a1)
		sub.w	8(a0),d2
		sub.w	d2,8(a1) 
loc_15C44:
		rts
;--------------------------------------------------------------------------------
loc_15C46:
		btst	#3,$22(a1)
		beq.s	loc_15C44
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		btst	#0,1(a0)
		beq.s	loc_15C64
		not.w	d0
		add.w	d1,d0
loc_15C64:
		and.w	#$FFFE,d0
		bra.s	loc_15C24 
loc_15C6A:
		lea	(Object_RAM).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	loc_15C80
		movem.l	(sp)+,d1-d4
		lea	($FFFFB040).w,a1
		addq.b	#1,d6
loc_15C80:
		btst D6,$22(a0)
		beq	loc_15DF2
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,$22(a1)
		bne.s	loc_15CA4
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_15CA4
		cmp.w	d2,d0
		bcs.s	loc_15CB8
loc_15CA4:
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr D6,$22(a0)
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_15CB8:
		move.w	d4,d2
		bsr.w	loc_15BCA
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_15CC2
; [ Begin ]
;===============================================================================
loc_15CC2:
		lea	(Object_RAM).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	loc_15CD8
		movem.l	(sp)+,d1-d4
		lea	($FFFFB040).w,a1
		addq.b	#1,d6
loc_15CD8:
		btst D6,$22(a0)
		beq	loc_15EC0
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,$22(a1)
		bne.s	loc_15CFC
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_15CFC
		cmp.w	d2,d0
		bcs.s	loc_15D10
loc_15CFC:
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr D6,$22(a0)
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_15D10:
		move.w	d4,d2
		bsr.w	loc_15C04
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_15CC2
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine loc_15D1A
; [ Begin ]
;===============================================================================
loc_15D1A:
		lea	(Object_RAM).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	loc_15D30
		movem.l	(sp)+,d1-d4
		lea	($FFFFB040).w,a1
		addq.b	#1,d6
loc_15D30:
		btst D6,$22(a0)
		beq	loc_15EF8
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,$22(a1)
		bne.s	loc_15D54
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_15D54
		cmp.w	d2,d0
		bcs.s	loc_15D68
loc_15D54:
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr D6,$22(a0)
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_15D68:
		move.w	d4,d2
		bsr.w	loc_15BCA
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_15D1A
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine loc_15D72
; [ Begin ]
;===============================================================================
loc_15D72: ; Called By CNz Elevators
		lea	(Object_RAM).w,a1
		moveq	#3,d6
		movem.l	d1-d4,-(sp)
		bsr.s	loc_15D88
		movem.l	(sp)+,d1-d4
		lea	($FFFFB040).w,a1
		addq.b	#1,d6
loc_15D88:
		btst D6,$22(a0)
		bne.s	loc_15D9A
		btst	#3,$22(a1)
		bne.s	loc_15DC6
		bra.w	loc_15DF2
loc_15D9A:
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,$22(a1)
		bne.s	loc_15DB6
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_15DB6
		cmp.w	d2,d0
		bcs.s	loc_15DCA
loc_15DB6:
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr D6,$22(a0)
loc_15DC6:
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_15DCA:
		move.w	d4,d2
		bsr.w	loc_15BCA
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_15D72
; [ End ]
;===============================================================================
loc_15DD4:
		tst.w	$12(a1)
		bmi loc_15EBE
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi loc_15EBE
		cmp.w	d2,d0
		bcc loc_15EBE
		bra.s	loc_15E10
loc_15DF2:
		tst.w	$12(a1)
		bmi loc_15EBE
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi loc_15EBE
		add.w	d1,d1
		cmp.w	d1,d0
		bcc loc_15EBE
loc_15E10: 
		move.w	$C(a0),d0
		sub.w	d3,d0
loc_15E16: 
		move.w	$C(a1),d2
		move.b	$16(a1),d1
		ext.w	d1
		add.w	d2,d1
		addq.w	#4,d1
		sub.w	d1,d0
		bhi loc_15EBE
		cmp.w	#$FFF0,d0
		bcs loc_15EBE
		tst.b	$2A(a1)
		bmi loc_15EBE
		cmp.b	#6,$24(a1)
		bcc loc_15EBE
		add.w	d0,d2
		addq.w	#3,d2
		move.w	d2,$C(a1)
loc_15E4C:
		btst	#3,$22(a1)
		beq.s	loc_15E68
		moveq	#0,d0
		move.b	$3D(a1),d0
		lsl.w	#6,d0
		add.l	#Object_RAM,d0
		move.l	d0,a3
		bclr D6,$22(a3)
loc_15E68:
		move.w	a0,d0
		sub.w	#$B000,d0
		lsr.w	#6,d0
		and.w	#$7F,d0
		move.b	d0,$3D(a1)
		move.b	#0,$26(a1)
		move.w	#0,$12(a1)
		move.w	$10(a1),$14(a1)
		btst	#1,$22(a1)
		beq.s	loc_15EAE
		move.l	a0,-(sp)
		move.l	a1,a0
		move.w	a0,d1
		sub.w	#$B000,d1
		bne.s	loc_15EA6
		jsr	(loc_16F34)
		bra.s	loc_15EAC
loc_15EA6:
		jsr	(loc_187E6)
loc_15EAC:
		move.l	(sp)+,a0
loc_15EAE:
		bset	#3,$22(a1)
		bclr	#1,$22(a1)
		bset D6,$22(a0)
loc_15EBE: 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_15EC0
; [ Begin ]
;===============================================================================
loc_15EC0:
		tst.w	$12(a1)
		bmi loc_15EBE
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi.s	loc_15EBE
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.s	loc_15EBE
		btst	#0,1(a0)
		beq.s	loc_15EE6
		not.w	d0
		add.w	d1,d0
loc_15EE6:
		lsr.w	#1,d0
		move.b	0(a2,d0),d3
		ext.w	d3
		move.w	$C(a0),d0
		sub.w	d3,d0
		bra.w	loc_15E16 
;===============================================================================
; Sub Routine loc_15EC0
; [ End ] 
;===============================================================================

;===============================================================================
; Sub Routine loc_15EF8
; [ Begin ] 
;===============================================================================
loc_15EF8:
		tst.w	$12(a1)
		bmi loc_15EBE
		move.w	8(a1),d0
		sub.w	8(a0),d0
		add.w	d1,d0
		bmi loc_15EBE
		add.w	d1,d1
		cmp.w	d1,d0
		bcc loc_15EBE
		move.w	$C(a0),d0
		sub.w	d3,d0
		bra.w	loc_15E16
;------------------------------------------------------------------------------- 
loc_15F20: ; Called by Object 0x30 
		lea	(Object_RAM).w,a1
		btst	#3,$22(a0)
		beq.s	loc_15F4E
		jsr	Sonic_HitFloor2 
		tst.w	d1
		beq.s	loc_15F38
		bpl.s	loc_15F4E
loc_15F38:
		lea	(Object_RAM).w,a1
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr	#3,$22(a0)
loc_15F4E:
		lea	($FFFFB040).w,a1
		btst	#4,$22(a0)
		beq.s	loc_15F7C
		jsr	Sonic_HitFloor2 
		tst.w	d1
		beq.s	loc_15F66
		bpl.s	loc_15F7C
loc_15F66:
		lea	($FFFFB040).w,a1
		bclr	#3,$22(a1)
		bset	#1,$22(a1)
		bclr	#4,$22(a0)
loc_15F7C:
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_15EF8
; [ End ] 
;===============================================================================
Obj_0x01_Sonic: 
		include 'objects/obj_0x01.asm'
;------------------------------------------------------------------------------- 
Obj_0x02_Miles: 
		include 'objects/obj_0x02.asm'
;------------------------------------------------------------------------------- 
Obj_0x05_Miles_Tail: 
		include 'objects/obj_0x05.asm'
		nop 
;------------------------------------------------------------------------------- ; Filler
Kill_Miles: 
		jmp	Kill_Player 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x0A_Sonic_Miles_Underwater: 
		include 'objects/obj_0x0A.asm'
;------------------------------------------------------------------------------- 
Obj_0x38_Shield: 
		include 'objects/obj_0x38.asm'
;------------------------------------------------------------------------------- 
Obj_0x35_Invincibility: 
		include 'objects/obj_0x35.asm'
;------------------------------------------------------------------------------- 
Shield_AnimateData: 
		dc.w	loc_19A92-Shield_AnimateData
loc_19A92:
		dc.b	$0,$5,$0,$5,$1,$5,$2,$5,$3,$5,$4,$FF 
;------------------------------------------------------------------------------- 
Shield_Mappings: 
		dc.w	loc_19AAA-Shield_Mappings
		dc.w	loc_19ACC-Shield_Mappings
		dc.w	loc_19AEE-Shield_Mappings
		dc.w	loc_19B10-Shield_Mappings
		dc.w	loc_19B32-Shield_Mappings
		dc.w	loc_19B54-Shield_Mappings
loc_19AAA:
		dc.w	$4
		dc.l	$F0050000,$FFF0,$F0050800,$8000000
		dc.l	$51000,$1000FFF0,$51800,$18000000
loc_19ACC:
		dc.w	$4
		dc.l	$F0050004,$2FFF0,$F0050804,$8020000
		dc.l	$51004,$1002FFF0,$51804,$18020000
loc_19AEE:
		dc.w	$4
		dc.l	$F0050008,$4FFF0,$F0050808,$8040000
		dc.l	$51008,$1004FFF0,$51808,$18040000
loc_19B10:
		dc.w	$4
		dc.l	$F005000C,$6FFF0,$F005080C,$8060000
		dc.l	$5100C,$1006FFF0,$5180C,$18060000
loc_19B32:
		dc.w	$4
		dc.l	$F0050010,$8FFF0,$F0050810,$8080000
		dc.l	$51010,$1008FFF0,$51810,$18080000
loc_19B54:
		dc.w	$4
		dc.l	$E00B0014,$AFFE8,$E00B0814,$80A0000
		dc.l	$B1014,$100AFFE8,$B1814,$180A0000 
;------------------------------------------------------------------------------- 
Invicibility_Stars_Mappings: 
		dc.w	loc_19B88-Invicibility_Stars_Mappings
		dc.w	loc_19B8A-Invicibility_Stars_Mappings
		dc.w	loc_19B94-Invicibility_Stars_Mappings
		dc.w	loc_19B9E-Invicibility_Stars_Mappings
		dc.w	loc_19BA8-Invicibility_Stars_Mappings
		dc.w	loc_19BB2-Invicibility_Stars_Mappings
		dc.w	loc_19BBC-Invicibility_Stars_Mappings
		dc.w	loc_19BC6-Invicibility_Stars_Mappings
		dc.w	loc_19BD0-Invicibility_Stars_Mappings
loc_19B88:
		dc.w	$0
loc_19B8A:
		dc.w	$1
		dc.l	$F8010000,$FFFC
loc_19B94:
		dc.w	$1
		dc.l	$F8010002,$1FFFC
loc_19B9E:
		dc.w	$1
		dc.l	$F8010004,$2FFFC
loc_19BA8:
		dc.w	$1
		dc.l	$F8010006,$3FFFC
loc_19BB2:
		dc.w	$1
		dc.l	$F8010008,$4FFFC
loc_19BBC:
		dc.w	$1
		dc.l	$F805000A,$5FFF8
loc_19BC6:
		dc.w	$1
		dc.l	$F805000E,$7FFF8
loc_19BD0:
		dc.w	$1
		dc.l	$F00F0012,$9FFF0 
;------------------------------------------------------------------------------- 
Obj_0x08_Dust_Water_Splash: 
		include 'objects/obj_0x08.asm'
;------------------------------------------------------------------------------- 
Obj_0x7E 
		include 'objects/obj_0x7E.asm'
;===============================================================================
; Sub Routine Sonic_Miles_AnglePos
; [ Begin ]
;===============================================================================
Sonic_Miles_AnglePos: 
		move.l	#$FFFFD000,($FFFFF796).w
		cmp.b	#$C,$3E(a0)
		beq.s	loc_1A0F0
		move.l	#$FFFFD600,($FFFFF796).w
loc_1A0F0:
		move.b	$3E(a0),d5
		btst	#3,$22(a0)
		beq.s	loc_1A108
		moveq	#0,d0
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
		rts
;--------------------------------------------------------------------------------
loc_1A108:
		moveq	#3,d0
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
		move.b	$26(a0),d0
		add.b	#$20,d0
		bpl.s	loc_1A12A
		move.b	$26(a0),d0
		bpl.s	loc_1A124
		subq.b	#1,d0
loc_1A124:
		add.b	#$20,d0
		bra.s	loc_1A136
loc_1A12A:
		move.b	$26(a0),d0
		bpl.s	loc_1A132
		addq.b	#1,d0
loc_1A132:
		add.b	#$1F,d0
loc_1A136:
		and.b	#$C0,d0
		cmp.b	#$40,d0
		beq	Sonic_WalkVertL 
		cmp.b	#$80,d0
		beq	Sonic_WalkCeiling 
		cmp.b	#$C0,d0
		beq	Sonic_WalkVertR 
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor 
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor 
		move.w	(sp)+,d0
		bsr.w	Sonic_Miles_Angle 
		tst.w	d1
		beq.s	loc_1A1C0
		bpl.s	loc_1A1C2
		cmp.w	#$FFF2,d1
		blt.s	loc_1A1C0
		add.w	d1,$C(a0)
loc_1A1C0:
		rts
;--------------------------------------------------------------------------------
loc_1A1C2:
		move.b	$10(a0),d0
		bpl.s	loc_1A1CA
		neg.b	d0
loc_1A1CA:
		addq.b	#4,d0
		cmp.b	#$E,d0
		bcs.s	loc_1A1D6
		move.b	#$E,d0
loc_1A1D6:
		cmp.b	d0,d1
		bgt.s	loc_1A1E0
loc_1A1DA: 
		add.w	d1,$C(a0)
		rts
;--------------------------------------------------------------------------------
loc_1A1E0:
		tst.b	$38(a0)
		bne.s	loc_1A1DA
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine Sonic_Miles_AnglePos
; [ Begin ] 
;===============================================================================
		 
;=============================================================================== 
; Sub Routine Sonic_Miles_Angle
; [ Begin ] 
;=============================================================================== 
Sonic_Miles_Angle: 
		move.b	($FFFFF76A).w,d2
		cmp.w	d0,d1
		ble.s	loc_1A208
		move.b	($FFFFF768).w,d2
		move.w	d0,d1
loc_1A208:
		btst	#0,d2
		bne.s	loc_1A224
		move.b	d2,d0
		sub.b	$26(a0),d0
		bpl.s	loc_1A218
		neg.b	d0
loc_1A218:
		cmp.b	#$20,d0
		bcc.s	loc_1A224
		move.b	d2,$26(a0)
		rts
;--------------------------------------------------------------------------------
loc_1A224:
		move.b	$26(a0),d2
		add.b	#$20,d2
		and.b	#$C0,d2
		move.b	d2,$26(a0)
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
Sonic_WalkVertR: 
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		neg.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall 
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall 
		move.w	(sp)+,d0
		bsr.w	Sonic_Miles_Angle 
		tst.w	d1
		beq.s	loc_1A2A4
		bpl.s	loc_1A2A6
		cmp.w	#$FFF2,d1
		blt.s	loc_1A2A4
		add.w	d1,8(a0)
loc_1A2A4:
		rts
;--------------------------------------------------------------------------------
loc_1A2A6:
		move.b	$12(a0),d0
		bpl.s	loc_1A2AE
		neg.b	d0
loc_1A2AE:
		addq.b	#4,d0
		cmp.b	#$E,d0
		bcs.s	loc_1A2BA
		move.b	#$E,d0
loc_1A2BA:
		cmp.b	d0,d1
		bgt.s	loc_1A2C4
loc_1A2BE: 
		add.w	d1,8(a0)
		rts
;--------------------------------------------------------------------------------
loc_1A2C4:
		tst.b	$38(a0)
		bne.s	loc_1A2BE
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
Sonic_WalkCeiling: 
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eor.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		move.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor 
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eor.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		move.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor 
		move.w	(sp)+,d0
		bsr.w	Sonic_Miles_Angle 
		tst.w	d1
		beq.s	loc_1A352
		bpl.s	loc_1A354
		cmp.w	#$FFF2,d1
		blt.s	loc_1A352
		sub.w	d1,$C(a0)
loc_1A352:
		rts
;--------------------------------------------------------------------------------
loc_1A354:
		move.b	$10(a0),d0
		bpl.s	loc_1A35C
		neg.b	d0
loc_1A35C:
		addq.b	#4,d0
		cmp.b	#$E,d0
		bcs.s	loc_1A368
		move.b	#$E,d0
loc_1A368:
		cmp.b	d0,d1
		bgt.s	loc_1A372
loc_1A36C: 
		sub.w	d1,$C(a0)
		rts
;--------------------------------------------------------------------------------
loc_1A372:
		tst.b	$38(a0)
		bne.s	loc_1A36C
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
Sonic_WalkVertL: 
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eor.w	#$F,d3
		lea	($FFFFF768).w,a4
		move.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall 
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eor.w	#$F,d3
		lea	($FFFFF76A).w,a4
		move.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall 
		move.w	(sp)+,d0
		bsr.w	Sonic_Miles_Angle 
		tst.w	d1
		beq.s	loc_1A400
		bpl.s	loc_1A402
		cmp.w	#$FFF2,d1
		blt.s	loc_1A400
		sub.w	d1,8(a0)
loc_1A400:
		rts
;--------------------------------------------------------------------------------
loc_1A402:
		move.b	$12(a0),d0
		bpl.s	loc_1A40A
		neg.b	d0
loc_1A40A:
		addq.b	#4,d0
		cmp.b	#$E,d0
		bcs.s	loc_1A416
		move.b	#$E,d0
loc_1A416:
		cmp.b	d0,d1
		bgt.s	loc_1A420
loc_1A41A: 
		sub.w	d1,8(a0)
		rts
;--------------------------------------------------------------------------------
loc_1A420:
		tst.b	$38(a0)
		bne.s	loc_1A41A
		bset	#1,$22(a0)
		bclr	#5,$22(a0)
		move.b	#1,$1D(a0)
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine Sonic_Miles_Angle
; [ End ] 
;=============================================================================== 
		
;=============================================================================== 
; Sub Routine Floor_ChkTile
; [ Begin ] 
;=============================================================================== 
Floor_ChkTile: 
		move.w	d2,d0
		add.w	d0,d0
		and.w	#$F00,d0
		move.w	d3,d1
		lsr.w	#3,d1
		move.w	d1,d4
		lsr.w	#4,d1
		and.w	#$7F,d1
		add.w	d1,d0
		moveq	#$FFFFFFFF,d1
		clr.w	d1
		lea	($FFFF8000).w,a1
		move.b	0(a1,d0),d1
		add.w	d1,d1
		move.w	loc_1A474(pc,d1),d1
		move.w	d2,d0
		and.w	#$70,d0
		add.w	d0,d1
		and.w	#$E,d4
		add.w	d4,d1
		move.l	d1,a1
		rts
;--------------------------------------------------------------------------------
loc_1A474:
		dc.w	$0,$80,$100,$180,$200,$280,$300,$380
		dc.w	$400,$480,$500,$580,$600,$680,$700,$780
		dc.w	$800,$880,$900,$980,$A00,$A80,$B00,$B80
		dc.w	$C00,$C80,$D00,$D80,$E00,$E80,$F00,$F80
		dc.w	$1000,$1080,$1100,$1180,$1200,$1280,$1300,$1380
		dc.w	$1400,$1480,$1500,$1580,$1600,$1680,$1700,$1780
		dc.w	$1800,$1880,$1900,$1980,$1A00,$1A80,$1B00,$1B80
		dc.w	$1C00,$1C80,$1D00,$1D80,$1E00,$1E80,$1F00,$1F80
		dc.w	$2000,$2080,$2100,$2180,$2200,$2280,$2300,$2380
		dc.w	$2400,$2480,$2500,$2580,$2600,$2680,$2700,$2780
		dc.w	$2800,$2880,$2900,$2980,$2A00,$2A80,$2B00,$2B80
		dc.w	$2C00,$2C80,$2D00,$2D80,$2E00,$2E80,$2F00,$2F80
		dc.w	$3000,$3080,$3100,$3180,$3200,$3280,$3300,$3380
		dc.w	$3400,$3480,$3500,$3580,$3600,$3680,$3700,$3780
		dc.w	$3800,$3880,$3900,$3980,$3A00,$3A80,$3B00,$3B80
		dc.w	$3C00,$3C80,$3D00,$3D80,$3E00,$3E80,$3F00,$3F80
		dc.w	$4000,$4080,$4100,$4180,$4200,$4280,$4300,$4380
		dc.w	$4400,$4480,$4500,$4580,$4600,$4680,$4700,$4780
		dc.w	$4800,$4880,$4900,$4980,$4A00,$4A80,$4B00,$4B80
		dc.w	$4C00,$4C80,$4D00,$4D80,$4E00,$4E80,$4F00,$4F80
		dc.w	$5000,$5080,$5100,$5180,$5200,$5280,$5300,$5380
		dc.w	$5400,$5480,$5500,$5580,$5600,$5680,$5700,$5780
		dc.w	$5800,$5880,$5900,$5980,$5A00,$5A80,$5B00,$5B80
		dc.w	$5C00,$5C80,$5D00,$5D80,$5E00,$5E80,$5F00,$5F80
		dc.w	$6000,$6080,$6100,$6180,$6200,$6280,$6300,$6380
		dc.w	$6400,$6480,$6500,$6580,$6600,$6680,$6700,$6780
		dc.w	$6800,$6880,$6900,$6980,$6A00,$6A80,$6B00,$6B80
		dc.w	$6C00,$6C80,$6D00,$6D80,$6E00,$6E80,$6F00,$6F80
		dc.w	$7000,$7080,$7100,$7180,$7200,$7280,$7300,$7380
		dc.w	$7400,$7480,$7500,$7580,$7600,$7680,$7700,$7780
		dc.w	$7800,$7880,$7900,$7980,$7A00,$7A80,$7B00,$7B80
		dc.w	$7C00,$7C80,$7D00,$7D80,$7E00,$7E80,$7F00,$7F80 
;=============================================================================== 
; Sub Routine Floor_ChkTile
; [ End ] 
;===============================================================================

;=============================================================================== 
; Sub Routine FindFloor
; [ Begin ] 
;=============================================================================== 
FindFloor: 
		bsr.w	Floor_ChkTile 
		move.w	(a1),d0
		move.w	d0,d4
		and.w	#$3FF,d0
		beq.s	loc_1A686
		btst D5,d4
		bne.s	loc_1A694
loc_1A686:
		add.w	a3,d2
		bsr.w	FindFloor2 
		sub.w	a3,d2
		add.w	#$10,d1
		rts
;--------------------------------------------------------------------------------
loc_1A694:
		move.l	($FFFFF796).w,a2
		add.w	d0,d0
		move.w	0(a2,d0),d0
		beq.s	loc_1A686
		lea	(angleMap),a2 
		move.b	0(a2,d0),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4
		beq.s	loc_1A6B8
		not.w	d1
		neg.b	(a4)
loc_1A6B8:
		btst	#$B,d4
		beq.s	loc_1A6C8
		add.b	#$40,(a4)
		neg.b	(a4)
		sub.b	#$40,(a4)
loc_1A6C8:
		and.w	#$F,d1
		add.w	d0,d1
		lea	(Colision_Array_1),a2 
		move.b	0(a2,d1),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_1A6E4
		neg.w	d0
loc_1A6E4:
		tst.w	d0
		beq.s	loc_1A686
		bmi.s	loc_1A700
		cmp.b	#$10,d0
		beq.s	loc_1A70C
		move.w	d2,d1
		and.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
;--------------------------------------------------------------------------------
loc_1A700:
		move.w	d2,d1
		and.w	#$F,d1
		add.w	d1,d0
		bpl loc_1A686
loc_1A70C:
		sub.w	a3,d2
		bsr.w	FindFloor2 
		add.w	a3,d2
		sub.w	#$10,d1
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine FindFloor
; [ End ] 
;=============================================================================== 

;=============================================================================== 
; Sub Routine FindFloor2
; [ Begin ] 
;=============================================================================== 
FindFloor2: 
		bsr.w	Floor_ChkTile 
		move.w	(a1),d0
		move.w	d0,d4
		and.w	#$3FF,d0
		beq.s	loc_1A72C
		btst D5,d4
		bne.s	loc_1A73A
loc_1A72C:
		move.w	#$F,d1
		move.w	d2,d0
		and.w	#$F,d0
		sub.w	d0,d1
		rts
;--------------------------------------------------------------------------------
loc_1A73A:
		move.l	($FFFFF796).w,a2
		add.w	d0,d0
		move.w	0(a2,d0),d0
		beq.s	loc_1A72C
		lea	(angleMap),a2 
		move.b	0(a2,d0),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4
		beq.s	loc_1A75E
		not.w	d1
		neg.b	(a4)
loc_1A75E:
		btst	#$B,d4
		beq.s	loc_1A76E
		add.b	#$40,(a4)
		neg.b	(a4)
		sub.b	#$40,(a4)
loc_1A76E:
		and.w	#$F,d1
		add.w	d0,d1 
		lea	(Colision_Array_1),a2 
		move.b	0(a2,d1),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_1A78A
		neg.w	d0
loc_1A78A:
		tst.w	d0
		beq.s	loc_1A72C
		bmi.s	loc_1A7A0
		move.w	d2,d1
		and.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
;--------------------------------------------------------------------------------
loc_1A7A0:
		move.w	d2,d1
		and.w	#$F,d1
		add.w	d1,d0
		bpl loc_1A72C
		not.w	d1
		rts
;--------------------------------------------------------------------------------
loc_1A7B0:
		bsr.w	Floor_ChkTile 
		move.w	(a1),d0
		move.w	d0,d4
		and.w	#$3FF,d0
		beq.s	loc_1A7C2
		btst D5,d4
		bne.s	loc_1A7C8
loc_1A7C2:
		move.w	#$10,d1
		rts
;--------------------------------------------------------------------------------
loc_1A7C8:
		move.l	($FFFFF796).w,a2
		add.w	d0,d0
		move.w	0(a2,d0),d0
		beq.s	loc_1A7C2
		lea	(angleMap),a2 
		move.b	0(a2,d0),(a4)
		lsl.w	#4,d0
		move.w	d3,d1
		btst	#$A,d4
		beq.s	loc_1A7EC
		not.w	d1
		neg.b	(a4)
loc_1A7EC:
		btst	#$B,d4
		beq.s	loc_1A7FC
		add.b	#$40,(a4)
		neg.b	(a4)
		sub.b	#$40,(a4)
loc_1A7FC:
		and.w	#$F,d1
		add.w	d0,d1
		lea	(Colision_Array_1),a2 
		move.b	0(a2,d1),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$B,d4
		beq.s	loc_1A818
		neg.w	d0
loc_1A818:
		tst.w	d0
		beq.s	loc_1A7C2
		bmi.s	loc_1A834
		cmp.b	#$10,d0
		beq.s	loc_1A840
		move.w	d2,d1
		and.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
;--------------------------------------------------------------------------------
loc_1A834:
		move.w	d2,d1
		and.w	#$F,d1
		add.w	d1,d0
		bpl loc_1A7C2
loc_1A840:
		sub.w	a3,d2
		bsr.w	FindFloor2 
		add.w	a3,d2
		sub.w	#$10,d1
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine FindFloor2
; [ End ] 
;=============================================================================== 
		
;=============================================================================== 
; Sub Routine FindWall
; [ Begin ] 
;=============================================================================== 
FindWall: 
		bsr.w	Floor_ChkTile 
		move.w	(a1),d0
		move.w	d0,d4
		and.w	#$3FF,d0
		beq.s	loc_1A860
		btst D5,d4
		bne.s	loc_1A86E
loc_1A860:
		add.w	a3,d3
		bsr.w	FindWall2 
		sub.w	a3,d3
		add.w	#$10,d1
		rts
;--------------------------------------------------------------------------------
loc_1A86E:
		move.l	($FFFFF796).w,a2
		add.w	d0,d0
		move.w	0(a2,d0),d0
		beq.s	loc_1A860
		lea	(angleMap),a2 
		move.b	0(a2,d0),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$B,d4
		beq.s	loc_1A89A
		not.w	d1
		add.b	#$40,(a4)
		neg.b	(a4)
		sub.b	#$40,(a4)
loc_1A89A:
		btst	#$A,d4
		beq.s	loc_1A8A2
		neg.b	(a4)
loc_1A8A2:
		and.w	#$F,d1
		add.w	d0,d1
		lea	(Colision_Array_2),a2 
		move.b	0(a2,d1),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$A,d4
		beq.s	loc_1A8BE
		neg.w	d0
loc_1A8BE:
		tst.w	d0
		beq.s	loc_1A860
		bmi.s	loc_1A8DA
		cmp.b	#$10,d0
		beq.s	loc_1A8E6
		move.w	d3,d1
		and.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
;--------------------------------------------------------------------------------
loc_1A8DA:
		move.w	d3,d1
		and.w	#$F,d1
		add.w	d1,d0
		bpl loc_1A860
loc_1A8E6:
		sub.w	a3,d3
		bsr.w	FindWall2 
		add.w	a3,d3
		sub.w	#$10,d1
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine FindWall
; [ End ] 
;=============================================================================== 

;=============================================================================== 
; Sub Routine FindWall2
; [ Begin ] 
;=============================================================================== 
FindWall2: 
		bsr.w	Floor_ChkTile 
		move.w	(a1),d0
		move.w	d0,d4
		and.w	#$3FF,d0
		beq.s	loc_1A906
		btst D5,d4
		bne.s	loc_1A914
loc_1A906:
		move.w	#$F,d1
		move.w	d3,d0
		and.w	#$F,d0
		sub.w	d0,d1
		rts
;--------------------------------------------------------------------------------
loc_1A914:
		move.l	($FFFFF796).w,a2
		add.w	d0,d0
		move.w	0(a2,d0),d0
		beq.s	loc_1A906
		lea	(angleMap),a2 
		move.b	0(a2,d0),(a4)
		lsl.w	#4,d0
		move.w	d2,d1
		btst	#$B,d4
		beq.s	loc_1A940
		not.w	d1
		add.b	#$40,(a4)
		neg.b	(a4)
		sub.b	#$40,(a4)
loc_1A940:
		btst	#$A,d4
		beq.s	loc_1A948
		neg.b	(a4)
loc_1A948:
		and.w	#$F,d1
		add.w	d0,d1
		lea	(Colision_Array_2),a2 
		move.b	0(a2,d1),d0
		ext.w	d0
		eor.w	d6,d4
		btst	#$A,d4
		beq.s	loc_1A964
		neg.w	d0
loc_1A964:
		tst.w	d0
		beq.s	loc_1A906
		bmi.s	loc_1A97A
		move.w	d3,d1
		and.w	#$F,d1
		add.w	d1,d0
		move.w	#$F,d1
		sub.w	d0,d1
		rts
;--------------------------------------------------------------------------------
loc_1A97A:
		move.w	d3,d1
		and.w	#$F,d1
		add.w	d1,d0
		bpl loc_1A906
		not.w	d1
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine FindWall2
; [ End ] 
;=============================================================================== 
Null_Sub: 
		rts
;--------------------------------------------------------------------------------

		lea	(Colision_Array_1),a1 
		lea	(Colision_Array_1),a2 
		move.w	#$FF,d3
loc_1A99C:
		moveq	#$10,d5
		move.w	#$F,d2
loc_1A9A2: 
		moveq	#0,d4
		move.w	#$F,d1
loc_1A9A8:
		move.w	(a1)+,d0
		lsr.l	d5,d0
		addx.w	d4,d4
		dbra	d1,loc_1A9A8
		move.w	d4,(a2)+
		sub.w	#$20,a1
		subq.w	#1,d5
		dbra	d2,loc_1A9A2
		add.w	#$20,a1
		dbra	d3,loc_1A99C
		lea	(Colision_Array_1),a1 
		lea	(Colision_Array_2),a2 
		bsr.s	loc_1A9E0
		lea	(Colision_Array_1),a1 
		lea	(Colision_Array_1),a2 
loc_1A9E0:
		move.w	#$FFF,d3
loc_1A9E4: 
		moveq	#0,d2
		move.w	#$F,d1
		move.w	(a1)+,d0
		beq.s	loc_1AA12
		bmi.s	loc_1A9FC
loc_1A9F0: 
		lsr.w	#1,d0
		bcc.s	loc_1A9F6
		addq.b	#1,d2
loc_1A9F6:
		dbra	d1,loc_1A9F0
		bra.s	loc_1AA14
loc_1A9FC:
		cmp.w	#$FFFF,d0
		beq.s	loc_1AA0E
loc_1AA02: 
		lsl.w	#1,d0
		bcc.s	loc_1AA08
		subq.b	#1,d2
loc_1AA08:
		dbra	d1,loc_1AA02
		bra.s	loc_1AA14
loc_1AA0E:
		move.w	#$10,d0
loc_1AA12:
		move.w	d0,d2
loc_1AA14:
		move.b	d2,(a2)+
		dbra	d3,loc_1A9E4
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine Sonic_WalkSpeed
; [ Begin ] 
;=============================================================================== 
Sonic_WalkSpeed: 
		move.l	#$FFFFD000,($FFFFF796).w
		cmp.b	#$C,$3E(a0)
		beq.s	loc_1AA34
		move.l	#$FFFFD600,($FFFFF796).w
loc_1AA34:
		move.b	$3F(a0),d5
		move.l	8(a0),d3
		move.l	$C(a0),d2
		move.w	$10(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d3
		move.w	$12(a0),d1
		ext.l	d1
		asl.l	#8,d1
		add.l	d1,d2
		swap.w	d2
		swap.w	d3
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
		move.b	d0,d1
		add.b	#$20,d0
		bpl.s	loc_1AA74
		move.b	d1,d0
		bpl.s	loc_1AA6E
		subq.b	#1,d0
loc_1AA6E:
		add.b	#$20,d0
		bra.s	loc_1AA7E
loc_1AA74:
		move.b	d1,d0
		bpl.s	loc_1AA7A
		addq.b	#1,d0
loc_1AA7A:
		add.b	#$1F,d0
loc_1AA7E:
		and.b	#$C0,d0
		beq	loc_1AB7E
		cmp.b	#$80,d0
		beq	loc_1AE36
		and.b	#$38,d1
		bne.s	loc_1AA96
		addq.w	#8,d2
loc_1AA96:
		cmp.b	#$40,d0
		beq	loc_1AEFE
		bra.w	loc_1AD7C
loc_1AAA2:
		move.l	#$FFFFD000,($FFFFF796).w
		cmp.b	#$C,$3E(a0)
		beq.s	loc_1AABA
		move.l	#$FFFFD600,($FFFFF796).w
loc_1AABA:
		move.b	$3F(a0),d5
		move.b	d0,($FFFFF768).w
		move.b	d0,($FFFFF76A).w
		add.b	#$20,d0
		and.b	#$C0,d0
		cmp.b	#$40,d0
		beq	loc_1AE8E
		cmp.b	#$80,d0
		beq	Sonic_DontRunOnWalls 
		cmp.b	#$C0,d0
		beq	loc_1AD14
loc_1AAE6:
		move.l	#$FFFFD000,($FFFFF796).w
		cmp.b	#$C,$3E(a0)
		beq.s	loc_1AAFE
		move.l	#$FFFFD600,($FFFFF796).w
loc_1AAFE:
		move.b	$3E(a0),d5
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor 
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor 
		move.w	(sp)+,d0
		move.b	#0,d2
loc_1AB5E: 
		move.b	($FFFFF76A).w,d3
		cmp.w	d0,d1
		ble.s	loc_1AB6C
		move.b	($FFFFF768).w,d3
		exg.l	d1,d0
loc_1AB6C:
		btst	#0,d3
		beq.s	loc_1AB74
		move.b	d2,d3
loc_1AB74:
		rts
;--------------------------------------------------------------------------------

		move.w	$C(a0),d2
		move.w	8(a0),d3
loc_1AB7E:
		add.w	#$A,d2
		lea	($FFFFF768).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindFloor 
		move.b	#0,d2
loc_1AB96: 
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	loc_1ABA2
		move.b	d2,d3
loc_1ABA2:
		rts
;--------------------------------------------------------------------------------
loc_1ABA4:
		move.w	8(a0),d3
		move.w	$C(a0),d2
		subq.w	#4,d2
		move.l	#$FFFFD000,($FFFFF796).w
		cmp.b	#$D,$3F(a0)
		beq.s	loc_1ABC6
		move.l	#$FFFFD600,($FFFFF796).w
loc_1ABC6:
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		move.w	#$10,a3
		move.w	#0,d6
		move.b	$3F(a0),d5
		bsr.w	FindFloor 
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	loc_1ABEC
		move.b	#0,d3
loc_1ABEC:
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine Sonic_WalkSpeed
; [ End ] 
;=============================================================================== 

;=============================================================================== 
; Sub Routine Sonic_HitFloor
; [ Begin ] 
;=============================================================================== 
Sonic_HitFloor: 
		move.w	8(a0),d3
Sonic_HitFloor_A0: 
		move.w	$C(a0),d2
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.l	#$FFFFD000,($FFFFF796).w
		cmp.b	#$C,$3E(a0)
		beq.s	loc_1AC18
		move.l	#$FFFFD600,($FFFFF796).w
loc_1AC18:
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		move.w	#$10,a3
		move.w	#0,d6
		move.b	$3E(a0),d5
		bsr.w	FindFloor 
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	loc_1AC3E
		move.b	#0,d3
loc_1AC3E:
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine Sonic_HitFloor
; [ End ] 
;=============================================================================== 

;=============================================================================== 
; Sub Routine Sonic_HitFloor2
; [ Begin ] 
;=============================================================================== 
Sonic_HitFloor2: 
		move.w	8(a1),d3 
		move.w	$C(a1),d2
		moveq	#0,d0
		move.b	$16(a1),d0
		ext.w	d0
		add.w	d0,d2
		move.l	#$FFFFD000,($FFFFF796).w
		cmp.b	#$C,$3E(a1)
		beq.s	loc_1AC6A
		move.l	#$FFFFD600,($FFFFF796).w
loc_1AC6A:
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		move.w	#$10,a3
		move.w	#0,d6
		move.b	$3E(a1),d5
		bsr.w	FindFloor 
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	loc_1AC90
		move.b	#0,d3
loc_1AC90:
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine Sonic_HitFloor2
; [ End ] 
;=============================================================================== 
		 
;=============================================================================== 
; Sub Routine ObjHitFloor
; [ Begin ] 
;=============================================================================== 
ObjHitFloor: 
		move.w	8(a0),d3
ObjHitFloor2: 
		move.w	$C(a0),d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		move.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5
		bsr.w	FindFloor 
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	loc_1ACC6
		move.b	#0,d3
loc_1ACC6:
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine ObjHitFloor
; [ End ] 
;=============================================================================== 

loc_1ACC8: 
		move.w	8(a1),d3
		move.w	$C(a1),d2
		move.b	$16(a1),d0
		ext.w	d0
		add.w	d0,d2
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		move.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5
		bra.w	FindFloor 
loc_1ACEE: 
		move.w	8(a0),d3
		move.w	$C(a0),d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d2
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		move.w	#$10,a3
		move.w	#0,d6
		moveq	#$C,d5
		bra.w	loc_1A7B0
loc_1AD14:
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall 
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF76A).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall 
		move.w	(sp)+,d0
		move.b	#$C0,d2
		bra.w	loc_1AB5E
loc_1AD74:
		move.w	$C(a0),d2
		move.w	8(a0),d3
loc_1AD7C:
		add.w	#$A,d3
		lea	($FFFFF768).w,a4
		move.w	#$10,a3
		move.w	#0,d6
		bsr.w	FindWall 
		move.b	#$C0,d2
		bra.w	loc_1AB96 
;=============================================================================== 
; Sub Routine loc_1AD98
; [ Begin ] 
;=============================================================================== 
loc_1AD98: 
		add.w	8(a0),d3
		move.w	$C(a0),d2
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		move.w	#$10,a3
		move.w	#0,d6
		moveq	#$D,d5
		bsr.w	FindWall 
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	loc_1ADC4
		move.b	#$C0,d3
loc_1ADC4:
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
; Sub Routine loc_1AD98
; [ End ] 
;=============================================================================== 
		
;=============================================================================== 
; Sub Routine Sonic_DontRunOnWalls
; [ Begin ] 
;=============================================================================== 
Sonic_DontRunOnWalls: 
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eor.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d3
		lea	($FFFFF768).w,a4
		move.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor 
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eor.w	#$F,d2
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d3
		lea	($FFFFF76A).w,a4
		move.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor 
		move.w	(sp)+,d0
		move.b	#$80,d2
		bra.w	loc_1AB5E
		move.w	$C(a0),d2
		move.w	8(a0),d3
;=============================================================================== 
; Sub Routine Sonic_DontRunOnWalls
; [ End ] 
;=============================================================================== 
loc_1AE36:
		sub.w	#$A,d2
		eor.w	#$F,d2
		lea	($FFFFF768).w,a4
		move.w	#$FFF0,a3
		move.w	#$800,d6
		bsr.w	FindFloor 
		move.b	#$80,d2
		bra.w	loc_1AB96
loc_1AE56: ; Called by Pillar Falling ( Neo Green Hill ) 
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d2
		eor.w	#$F,d2
		lea	($FFFFF768).w,a4
		move.w	#$FFF0,a3
		move.w	#$800,d6
		moveq	#$D,d5
		bsr.w	FindFloor 
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	loc_1AE8C
		move.b	#$80,d3
loc_1AE8C:
		rts
;--------------------------------------------------------------------------------
loc_1AE8E:
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		sub.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eor.w	#$F,d3
		lea	($FFFFF768).w,a4
		move.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall 
		move.w	d1,-(sp)
		move.w	$C(a0),d2
		move.w	8(a0),d3
		moveq	#0,d0
		move.b	$17(a0),d0
		ext.w	d0
		add.w	d0,d2
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		eor.w	#$F,d3
		lea	($FFFFF76A).w,a4
		move.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall 
		move.w	(sp)+,d0
		move.b	#$40,d2
		bra.w	loc_1AB5E
loc_1AEF6:
		move.w	$C(a0),d2
		move.w	8(a0),d3
loc_1AEFE:
		sub.w	#$A,d3
		eor.w	#$F,d3
		lea	($FFFFF768).w,a4
		move.w	#$FFF0,a3
		move.w	#$400,d6
		bsr.w	FindWall 
		move.b	#$40,d2
		bra.w	loc_1AB96
loc_1AF1E: ; Called by Arrow Shooter ( NGHz ) 
		add.w	8(a0),d3
		move.w	$C(a0),d2
		lea	($FFFFF768).w,a4
		move.b	#0,(a4)
		move.w	#$FFF0,a3
		move.w	#$400,d6
		moveq	#$D,d5
		bsr.w	FindWall 
		move.b	($FFFFF768).w,d3
		btst	#0,d3
		beq.s	loc_1AF4A
		move.b	#$40,d3
loc_1AF4A:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
Obj_0x79_Star_Post: 
		include 'objects/obj_0x79.asm'
loc_1B496:
		jmp	DeleteObject 
loc_1B49C:
		jmp	MarkObjGone 
loc_1B4A2:
		jmp	AnimateSprite 
;------------------------------------------------------------------------------- 
Obj_0x7D_Hidden_Bonus: 
		include 'objects/obj_0x7D.asm'
		nop ; Filler
;------------------------------------------------------------------------------- 
Obj_0x44_Red_Ball_Bumper: 
		include 'objects/obj_0x44.asm'
		nop ; Filler
loc_1B710:
		jmp	MarkObjGone 
loc_1B716:
		jmp	AnimateSprite 
;------------------------------------------------------------------------------- 
Obj_0x24_Oxygen_Bubbles: 
		include 'objects/obj_0x24.asm'
;-------------------------------------------------------------------------------
Sonic_Underwater_Mappings: 
		dc.w	loc_1BA90-Sonic_Underwater_Mappings
		dc.w	loc_1BA9A-Sonic_Underwater_Mappings
		dc.w	loc_1BA9A-Sonic_Underwater_Mappings
		dc.w	loc_1BAA4-Sonic_Underwater_Mappings
		dc.w	loc_1BAAE-Sonic_Underwater_Mappings
		dc.w	loc_1BAB8-Sonic_Underwater_Mappings
		dc.w	loc_1BAC2-Sonic_Underwater_Mappings
		dc.w	loc_1BACC-Sonic_Underwater_Mappings
		dc.w	loc_1BAEE-Sonic_Underwater_Mappings
		dc.w	loc_1BAEE-Sonic_Underwater_Mappings
		dc.w	loc_1BAEE-Sonic_Underwater_Mappings
		dc.w	loc_1BAEE-Sonic_Underwater_Mappings
		dc.w	loc_1BAEE-Sonic_Underwater_Mappings
		dc.w	loc_1BAEE-Sonic_Underwater_Mappings
		dc.w	loc_1BAF8-Sonic_Underwater_Mappings
		dc.w	loc_1BB02-Sonic_Underwater_Mappings
		dc.w	loc_1BB0C-Sonic_Underwater_Mappings
Miles_Underwater_Mappings: 
		dc.w	loc_1BA90-Miles_Underwater_Mappings
		dc.w	loc_1BA9A-Miles_Underwater_Mappings
		dc.w	loc_1BA9A-Miles_Underwater_Mappings
		dc.w	loc_1BAA4-Miles_Underwater_Mappings
		dc.w	loc_1BAAE-Miles_Underwater_Mappings
		dc.w	loc_1BAB8-Miles_Underwater_Mappings
		dc.w	loc_1BAC2-Miles_Underwater_Mappings
		dc.w	loc_1BACC-Miles_Underwater_Mappings
		dc.w	loc_1BB0E-Miles_Underwater_Mappings
		dc.w	loc_1BB0E-Miles_Underwater_Mappings
		dc.w	loc_1BB0E-Miles_Underwater_Mappings
		dc.w	loc_1BB0E-Miles_Underwater_Mappings
		dc.w	loc_1BB0E-Miles_Underwater_Mappings
		dc.w	loc_1BB0E-Miles_Underwater_Mappings
		dc.w	loc_1BAF8-Miles_Underwater_Mappings
		dc.w	loc_1BB02-Miles_Underwater_Mappings
		dc.w	loc_1BB0C-Miles_Underwater_Mappings
loc_1BA90:
		dc.w	$1
		dc.l	$FC00008D,$46FFFC
loc_1BA9A:
		dc.w	$1
		dc.l	$FC00008E,$47FFFC
loc_1BAA4:
		dc.w	$1
		dc.l	$F805008F,$47FFF8
loc_1BAAE:
		dc.w	$1
		dc.l	$F8050093,$49FFF8
loc_1BAB8:
		dc.w	$1
		dc.l	$F40A001C,$EFFF4
loc_1BAC2:
		dc.w	$1
		dc.l	$F00F0008,$4FFF0
loc_1BACC:
		dc.w	$4
		dc.l	$F0050018,$CFFF0,$F0050818,$80C0000
		dc.l	$51018,$100CFFF0,$51818,$180C0000
loc_1BAEE:
		dc.w	$1
		dc.l	$F4061F41,$1BA0FFF8
loc_1BAF8:
		dc.w	$1
		dc.l	$F8050000,$FFF8
loc_1BB02:
		dc.w	$1
		dc.l	$F8050004,$2FFF8
loc_1BB0C:
		dc.w	$0
loc_1BB0E:
		dc.w	$1
		dc.l	$F4061F31,$1B98FFF8 
;-------------------------------------------------------------------------------
J_DisplaySprite_02: 
		jmp	DisplaySprite 
loc_1BB1E:
		jmp	DeleteObject 
loc_1BB24:
		jmp	ModifySpriteAttr_2P 
loc_1BB2A:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x03_Layer_Switch: 
		include 'objects/obj_0x03.asm'
J_ModifySpriteAttr_2P: 
		jmp	ModifySpriteAttr_2P 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x0B_Open_Close_Platform: 
		include 'objects/obj_0x0B.asm'
		nop ; Filler
loc_1C040:
		jmp	MarkObjGone 
loc_1C046:
		jmp	ModifySpriteAttr_2P 
;-------------------------------------------------------------------------------
Obj_0x0C: 
		include 'objects/obj_0x0C.asm'
		nop ; Filler 
loc_1C144:
		jmp	MarkObjGone 
loc_1C14A:
		jmp	ModifySpriteAttr_2P 
loc_1C150:
		jmp	CalcSine 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x12_HPz_Master_Emerald: 
		include 'objects/obj_0x12.asm'
		nop
J_DisplaySprite_03: 
		jmp	DisplaySprite 
loc_1C1DA:
		jmp	DeleteObject 
loc_1C1E0:
		jmp	ModifySpriteAttr_2P 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x13_HPz_Waterfalls: 
		include 'objects/obj_0x13.asm'
J_DisplaySprite_04: 
		jmp	DisplaySprite 
loc_1C706:
		jmp	DeleteObject 
loc_1C70C:
		jmp	Modify_A1_SpriteAttr_2P 
loc_1C712:
		jmp	ModifySpriteAttr_2P 
;------------------------------------------------------------------------------- 
Obj_0x04_Water_Surface: 
		include 'objects/obj_0x04.asm'
;------------------------------------------------------------------------------- 
Obj_0x49_Waterfall: 
		include 'objects/obj_0x49.asm'
;------------------------------------------------------------------------------- 
Obj_0x31_Lava_Attributes: 
		include 'objects/obj_0x31.asm'
;------------------------------------------------------------------------------- 
Obj_0x74_Invisible_Block: 
		include 'objects/obj_0x74.asm'
;------------------------------------------------------------------------------- 
Obj_0x7C_Metal_Structure: 
		include 'objects/obj_0x7C.asm'
;------------------------------------------------------------------------------- 
Obj_0x27_Object_Hit: 
		include 'objects/obj_0x27.asm'
;------------------------------------------------------------------------------- 
Obj_0x84_Auto_Spin: 
		include 'objects/obj_0x84.asm'
;------------------------------------------------------------------------------- 
Obj_0x8B_Palette_Cycling_Switch: 
		include 'objects/obj_0x8B.asm'
;------------------------------------------------------------------------------- 
loc_1D2F0:
		jmp	DisplaySprite 
loc_1D2F6:
		jmp	DeleteObject 
loc_1D2FC:
		jmp	SingleObjectLoad 
loc_1D302:
		jmp	ModifySpriteAttr_2P 
loc_1D308: 
		jmp	(loc_13866) 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x06_Spiral_Attributes: 
		include 'objects/obj_0x06.asm'
J_CalcSine: 
		jmp	CalcSine 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x14_See_saw: 
		include 'objects/obj_0x14.asm'
loc_1DBE0:
		jmp	S1SingleObjectLoad 
loc_1DBE6:
		jmp	ModifySpriteAttr_2P 
loc_1DBEC:
		jmp	ObjectFall 
loc_1DBF2:
		jmp	(loc_12D4C) 
;------------------------------------------------------------------------------- 
Obj_0x16_Teleferics: 
		include 'objects/obj_0x16.asm'
		nop ; Filler
loc_1DE10:
		jmp	DeleteObject 
loc_1DE16:
		jmp	MarkObjGone 
loc_1DE1C:
		jmp	S1SingleObjectLoad 
loc_1DE22:
		jmp	ModifySpriteAttr_2P 
loc_1DE28:
		jmp	SpeedToPos 
loc_1DE2E:
		jmp	(loc_15C6A) 
;------------------------------------------------------------------------------- 
Obj_0x19_Rotating_Platforms 
		include 'objects/obj_0x19.asm'
		nop ; Filler
loc_1E0A8: 
		jmp	DisplaySprite 
loc_1E0AE:
		jmp	DeleteObject 
loc_1E0B4:
		jmp	ModifySpriteAttr_2P 
loc_1E0BA:
		jmp	(loc_15C6A)
loc_1E0C0:
		jmp	SpeedToPos 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x1B_Speed_Booster: 
		include 'objects/obj_0x1B.asm'
loc_1E218:
		jmp	MarkObjGone 
loc_1E21E:
		jmp	ModifySpriteAttr_2P 
;------------------------------------------------------------------------------- 
Obj_0x1D_Worms: 
		include 'objects/obj_0x1D.asm'
;------------------------------------------------------------------------------- 
		nop ; Filler 
loc_1E3A0: 
		jmp	MarkObjGone 
loc_1E3A6:
		jmp	S1SingleObjectLoad 
loc_1E3AC:
		jmp	Modify_A1_SpriteAttr_2P 
loc_1E3B2:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x1E_Tube_Attributes: 
		include 'objects/obj_0x1E.asm'
		nop ; Filler
loc_1EE0C:
		jmp	(loc_12D80) 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x20_HTz_Boss_FireBall: 
		include 'objects/obj_0x20.asm'
loc_1F0F8:
		jmp	DeleteObject 
loc_1F0FE:
		jmp	MarkObjGone 
loc_1F104:
		jmp	S1SingleObjectLoad 
loc_1F10A:
		jmp	AnimateSprite 
loc_1F110:
		jmp	ModifySpriteAttr_2P 
loc_1F116:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x2F_Breakable_Floor: 
		include 'objects/obj_0x2F.asm'
;------------------------------------------------------------------------------- 
Obj_0x32_Breakable_Obstacle: 
		include 'objects/obj_0x32.asm'
		nop ; Filler
loc_1F6C8:
		jmp	DisplaySprite 
loc_1F6CE:
		jmp	DeleteObject 
loc_1F6D4:
		jmp	SingleObjectLoad 
loc_1F6DA:
		jmp	MarkObjGone 
loc_1F6E0:
		jmp	ModifySpriteAttr_2P 
loc_1F6E6:
		jmp	(loc_12770)
loc_1F6EC:
		jmp	SolidObject 
loc_1F6F2:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x30 
		include 'objects/obj_0x30.asm'
loc_1F8EC:
		jmp	DeleteObject 
loc_1F8F2:
		jmp	(loc_3B6A4)
loc_1F8F8:
		jmp	(loc_12D80)
loc_1F8FE:
		jmp	(loc_15F20)
loc_1F904:
		jmp	(loc_157BC)
loc_1F90A:
		jmp	(loc_15814)
;------------------------------------------------------------------------------- 
Obj_0x33_Touch_Booster: 
		include 'objects/obj_0x33.asm'
loc_1FC48:
		jmp	MarkObjGone 
loc_1FC4E:
		jmp	S1SingleObjectLoad 
loc_1FC54:
		jmp	SolidObject 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x43_Giant_Spikeball: 
		include 'objects/obj_0x43.asm'
loc_1FE30:
		jmp	S1SingleObjectLoad 
loc_1FE36:
		jmp	ModifySpriteAttr_2P 
;------------------------------------------------------------------------------- 
Obj_0x07_0il_Attributes: 
		include 'objects/obj_0x07.asm'
		nop ; Filler 
loc_1FF08:
		jmp	Kill_Player 
loc_1FF0E:
		jmp	(loc_15C80) 
;------------------------------------------------------------------------------- 
Obj_0x45_Spring_Push_Boost: 
		include 'objects/obj_0x45.asm'
;------------------------------------------------------------------------------- 
Obj_0x46_Spring_Ball: 
		include 'objects/obj_0x46.asm'
		nop ; Filler 
loc_20AE0:
		jmp	DeleteObject 
loc_20AE6:
		jmp	SingleObjectLoad 
loc_20AEC:
		jmp	MarkObjGone 
loc_20AF2:
		jmp	ModifySpriteAttr_2P 
loc_20AF8:
		jmp	SolidObject 
loc_20AFE:
		jmp	(loc_157D2)
loc_20B04:
		jmp	(loc_158C4)
loc_20B0A:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x47_Switch 
		include 'objects/obj_0x47.asm'
		nop ; Filler 
loc_20BD8:
		jmp	MarkObjGone 
loc_20BDE:
		jmp	ModifySpriteAttr_2P 
loc_20BE4:
		jmp	SolidObject 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x3D_Break_Boost: 
		include 'objects/obj_0x3D.asm'
loc_20FF8:
		jmp	DisplaySprite 
loc_20FFE:
		jmp	DeleteObject 
loc_21004:
		jmp	MarkObjGone 
loc_2100A:
		jmp	S1SingleObjectLoad 
loc_21010:
		jmp	(loc_12D80)
loc_21016:
		jmp	ModifySpriteAttr_2P 
loc_2101C:
		jmp	(loc_12770)
loc_21022:
		jmp	SolidObject 
loc_21028:
		jmp	SpeedToPos 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x48_Cannon: 
		include 'objects/obj_0x48.asm'
loc_2143C:
		jmp	DisplaySprite 
loc_21442:
		jmp	MarkObjGone 
loc_21448:
		jmp	ModifySpriteAttr_2P 
		dc.w	$0 ; Filler
;-------------------------------------------------------------------------------
Obj_0x22_Arrow_Shooter: 
		include 'objects/obj_0x22.asm'
loc_21624:
		jmp	DeleteObject 
loc_2162A:
		jmp	SingleObjectLoad 
loc_21630:
		jmp	MarkObjGone 
loc_21636:
		jmp	AnimateSprite 
loc_2163C:
		jmp	ModifySpriteAttr_2P 
loc_21642:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x23_Pillar: 
		include 'objects/obj_0x23.asm'
;------------------------------------------------------------------------------- 
Obj_0x2B_Raising_Pillar 
		include 'objects/obj_0x2B.asm'
;-------------------------------------------------------------------------------
loc_21E90:
		jmp	DisplaySprite 
loc_21E96:
		jmp	DeleteObject 
loc_21E9C:
		jmp	MarkObjGone 
loc_21EA2:
		jmp	S1SingleObjectLoad 
loc_21EA8:
		jmp	ModifySpriteAttr_2P 
loc_21EAE:
		jmp	SolidObject 
loc_21EB4:
		jmp	SpeedToPos 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x2C_Leaves: 
		include 'objects/obj_0x2C.asm'
loc_22110:
		jmp	DisplaySprite 
loc_22116:
		jmp	DeleteObject 
loc_2211C:
		jmp	SingleObjectLoad 
loc_22122:
		jmp	PseudoRandomNumber 
loc_22128:
		jmp	CalcSine 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x40_Diagonal_Springs: 
		include 'objects/obj_0x40.asm'
loc_223DC:
		jmp	MarkObjGone 
loc_223E2:
		jmp	AnimateSprite 
loc_223E8:
		jmp	ModifySpriteAttr_2P 
loc_223EE:
		jmp	(loc_1582A) 
;------------------------------------------------------------------------------- 
Obj_0x42_Steam_Vent: 
		include 'objects/obj_0x42.asm'
loc_226BC:
		jmp	DisplaySprite 
loc_226C2:
		jmp	DeleteObject 
loc_226C8:
		jmp	SingleObjectLoad 
loc_226CE:
		jmp	MarkObjGone 
loc_226D4:
		jmp	ModifySpriteAttr_2P 
loc_226DA:
		jmp	(loc_157D2) 
;------------------------------------------------------------------------------- 
Obj_0x64_Pistons: 
		include 'objects/obj_0x64.asm'
loc_22894:
		jmp	ModifySpriteAttr_2P 
loc_2289A:
		jmp	SolidObject 
Obj_0x65_Platform_Over_Gear: 
;------------------------------------------------------------------------------- 
		include 'objects/obj_0x65.asm'
		nop ; Filler
;------------------------------------------------------------------------------- 
loc_22CF0:
		jmp	MarkObjGone 
loc_22CF6:
		jmp	S1SingleObjectLoad 
loc_22CFC:
		jmp	ModifySpriteAttr_2P 
loc_22D02:
		jmp	SolidObject 
;------------------------------------------------------------------------------- 
Obj_0x66_Springs_Wall: 
		include 'objects/obj_0x66.asm'
loc_22EF8:
		jmp	DisplaySprite 
loc_22EFE:
		jmp	DeleteObject 
loc_22F04:
		jmp	ModifySpriteAttr_2P 
loc_22F0A:
		jmp	(loc_157D2) 
;------------------------------------------------------------------------------- 
Obj_0x67_Teleport_Attributes: 
		include 'objects/obj_0x67.asm'
loc_23334:
		jmp	DisplaySprite 
loc_2333A:
		jmp	AnimateSprite 
loc_23340:
		jmp	(loc_12D80) 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x68_Block_Harpon: 
		include 'objects/obj_0x68.asm'
Obj_0x6D_Harpoon: 
		include 'objects/obj_0x6D.asm'
loc_23618:
		jmp	MarkObjGone 
loc_2361E:
		jmp	S1SingleObjectLoad 
loc_23624:
		jmp	ModifySpriteAttr_2P 
loc_2362A:
		jmp	SolidObject 
loc_23630:
		jmp	(loc_12D4C)
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x69_Screw_Nut: 
		include 'objects/obj_0x69.asm'
		nop ; Filler
loc_23844:
		jmp	MarkObjGone 
loc_2384A:
		jmp	ObjHitFloor 
loc_23850:
		jmp	ModifySpriteAttr_2P 
loc_23856:
		jmp	SolidObject 
loc_2385C:
		jmp	SpeedToPos 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x6A_DHz_Three_Boxes_Mz_Ptfrm 
		include 'objects/obj_0x6A.asm'
loc_23B08:
		jmp	S1SingleObjectLoad 
loc_23B0E:
		jmp	ModifySpriteAttr_2P 
loc_23B14:
		jmp	SolidObject 
loc_23B1A:
		jmp	(loc_12D4C) 
;------------------------------------------------------------------------------- 
Obj_0x6B_Mz_Platform: 
		include 'objects/obj_0x6B.asm'
		nop ; Filler
loc_23DC4:
		jmp	ModifySpriteAttr_2P 
loc_23DCA:
		jmp	SolidObject 
loc_23DD0:
		jmp	(loc_12D4C)
loc_23DD6:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x6C_Mz_Moving_Platforms: 
		include 'objects/obj_0x6C.asm'
		nop ; Filler
loc_24130:
		jmp	DisplaySprite 
loc_24136:
		jmp	DeleteObject 
loc_2413C:
		jmp	SingleObjectLoad 
loc_24142:
		jmp	ModifySpriteAttr_2P 
loc_24148:
		jmp	(loc_15C6A)
loc_2414E:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x6E_Machine: 
		include 'objects/obj_0x6E.asm'
loc_2435C:
		jmp	ModifySpriteAttr_2P 
loc_24362:
		jmp	SolidObject 
;------------------------------------------------------------------------------- 
Obj_0x70_Rotating_Gears: 
		include 'objects/obj_0x70.asm'
		nop ; Filler
loc_246D0:
		jmp	S1SingleObjectLoad 
loc_246D6:
		jmp	Modify_A1_SpriteAttr_2P 
loc_246DC:
		jmp	SolidObject 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x72_Conveyor_Belt_Attributes: 
		include 'objects/obj_0x72.asm'
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x73_Rotating_Rings: 
		include 'objects/obj_0x73.asm'
loc_24950:
		jmp	DisplaySprite 
loc_24956:
		jmp	SingleObjectLoad 
loc_2495C:
		jmp	Delete_A1_Object 
loc_24962:
		jmp	ModifySpriteAttr_2P 
loc_24968:
		jmp	SolidObject 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x75_Spikeball_Chain: 
		include 'objects/obj_0x75.asm'
		nop
loc_24B68:
		jmp	DisplaySprite_Param 
loc_24B6E:
		jmp	DisplaySprite 
loc_24B74:
		jmp	DeleteObject 
loc_24B7A:
		jmp	MarkObjGone 
loc_24B80:
		jmp	Delete_A1_Object 
loc_24B86:
		jmp	S1SingleObjectLoad 
loc_24B8C:
		jmp	ModifySpriteAttr_2P 
loc_24B92:
		jmp	CalcSine 
loc_24B98:
		jmp	SolidObject 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x76_Platform_Spikes: 
		include 'objects/obj_0x76.asm'
		nop ; Filler
loc_24D18:
		jmp	(loc_123EC)
loc_24D1E:
		jmp	ModifySpriteAttr_2P 
loc_24D24:
		jmp	SolidObject 
loc_24D2A:
		jmp	(loc_12D4C)
;------------------------------------------------------------------------------- 
Obj_0x77_Bridge: 
		include 'objects/obj_0x77.asm'
loc_24F60:
		jmp	MarkObjGone 
loc_24F66:
		jmp	ModifySpriteAttr_2P 
loc_24F6C:
		jmp	SolidObject 
		cnop	0,4 ; Filler 
;-------------------------------------------------------------------------------
Obj_0x78_Rotating_Platforms: 
		include 'objects/obj_0x78.asm'
loc_25130:
		jmp	S1SingleObjectLoad 
loc_25136:
		jmp	Modify_A1_SpriteAttr_2P 
loc_2513C:
		jmp	SolidObject 
loc_25142:
		jmp	(loc_12D4C) 
;------------------------------------------------------------------------------- 
Obj_0x7A_Platform_Horizontal: 
		include 'objects/obj_0x7A.asm'
loc_25320:
		jmp	DisplaySprite 
loc_25326:
		jmp	S1SingleObjectLoad 
loc_2532C:
		jmp	ModifySpriteAttr_2P 
loc_25332:
		jmp	(loc_15C6A) 
;------------------------------------------------------------------------------- 
Obj_0x7B_Spring_Tubes: 
		include 'objects/obj_0x7B.asm'
loc_25560:
		jmp	DisplaySprite 
loc_25566:
		jmp	DeleteObject 
loc_2556C:
		jmp	AnimateSprite 
loc_25572:
		jmp	ModifySpriteAttr_2P 
loc_25578:
		jmp	(loc_157D2)
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x7F_Vines_Switch: 
		include 'objects/obj_0x7F.asm'
loc_2570C:
		jmp	MarkObjGone 
loc_25712:
		jmp	ModifySpriteAttr_2P 
;------------------------------------------------------------------------------- 
Obj_0x80_Vines_Chain_Hook: 
		include 'objects/obj_0x80.asm'
		nop ; Filler 
loc_25BFC:
		jmp	MarkObjGone 
loc_25C02:
		jmp	ModifySpriteAttr_2P 
;------------------------------------------------------------------------------- 
Obj_0x81_Vertical_Bridge: 
		include 'objects/obj_0x81.asm'
		nop ; Filler 
loc_25E68:
		jmp	DisplaySprite_Param 
loc_25E6E:
		jmp	DisplaySprite 
loc_25E74:
		jmp	DeleteObject 
loc_25E7A:
		jmp	Delete_A1_Object 
loc_25E80:
		jmp	S1SingleObjectLoad 
loc_25E86:
		jmp	ModifySpriteAttr_2P 
loc_25E8C:
		jmp	CalcSine 
loc_25E92:
		jmp	SolidObject 
;------------------------------------------------------------------------------- 
Obj_0x82_Falling_Pillar: 
		include 'objects/obj_0x82.asm'
		nop ; Filler
loc_260E0:
		jmp	ObjHitFloor 
loc_260E6:
		jmp	ModifySpriteAttr_2P 
loc_260EC:
		jmp	(loc_1AE56)
loc_260F2:
		jmp	SolidObject 
loc_260F8:
		jmp	(loc_12D4C)
loc_260FE:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x83_Three_Rotating_Platforms: 
		include 'objects/obj_0x83.asm'
		nop ; Filler
loc_26380:
		jmp	DisplaySprite_Param 
loc_26386:
		jmp	DisplaySprite 
loc_2638C:
		jmp	DeleteObject 
loc_26392:
		jmp	Delete_A1_Object 
loc_26398:
		jmp	S1SingleObjectLoad 
loc_2639E:
		jmp	ModifySpriteAttr_2P 
loc_263A4:
		jmp	CalcSine 
loc_263AA:
		jmp	(loc_15C6A)
loc_263B0:
		jmp	(loc_12D4C)
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x3F_Fans: 
		include 'objects/obj_0x3F.asm'
		nop ; Filler
loc_26780:
		jmp	MarkObjGone 
loc_26786:
		jmp	ModifySpriteAttr_2P 
;------------------------------------------------------------------------------- 
Obj_0x85_CNz_Pinball_Spring: 
		include 'objects/obj_0x85.asm'
		nop
loc_26CD8:
		jmp	DisplaySprite_Param 
loc_26CDE:
		jmp	DeleteObject 
loc_26CE4:
		jmp	ModifySpriteAttr_2P 
loc_26CEA:
		jmp	(loc_157D2) 
;------------------------------------------------------------------------------- 
Obj_0x86_CNz_Flippers: 
		include 'objects/obj_0x86.asm'
		nop ; Filler
loc_270B4:
		jmp	MarkObjGone 
loc_270BA:
		jmp	AnimateSprite 
loc_270C0:
		jmp	ModifySpriteAttr_2P 
loc_270C6:
		jmp	CalcSine 
loc_270CC:
		jmp	(loc_157D2)
loc_270D2:
		jmp	(loc_15814)
;------------------------------------------------------------------------------- 
Obj_0xD2_Green_Platform: 
		include 'objects/obj_0xD2.asm'
		nop
loc_273E4: ; Filler
		jmp	(loc_12D80)
loc_273EA:
		jmp	ModifySpriteAttr_2P 
loc_273F0:
		jmp	SolidObject 
loc_273F6:
		jmp	(loc_12D4C)
;------------------------------------------------------------------------------- 
Obj_0xD3_CNz_Spikeball: 
		include 'objects/obj_0xD3.asm'
		nop
loc_27470:
		jmp	DisplaySprite 
loc_27476:
		jmp	DeleteObject 
loc_2747C:
		jmp	ModifySpriteAttr_2P 
loc_27482:
		jmp	SolidObject 
;------------------------------------------------------------------------------- 
Obj_0xD4_CNz_Box: 
		include 'objects/obj_0xD4.asm'
		nop
loc_2758C:
		jmp	ModifySpriteAttr_2P 
loc_27592:
		jmp	SolidObject 
loc_27598:
		jmp	(loc_12D4C)
loc_2759E:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0xD5_CNz_Elevator: 
		include 'objects/obj_0xD5.asm'
loc_276F0:
		jmp	MarkObjGone 
loc_276F6:
		jmp	ModifySpriteAttr_2P 
loc_276FC:
		jmp	(loc_15D72)
loc_27702:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0xD6_CNz_Slot_Machine_Bonus: 
		include 'objects/obj_0xD6.asm'
;===============================================================================
; Sub Routine Load_Slot_Machine_Sprites 
; [ Begin ] 
;=============================================================================== 
Load_Slot_Machine_Sprites: 
		lea	($FFFFFF4E).w,a4
		moveq	#0,d0
		move.b	0(a4),d0
		jmp	loc_27918(pc,d0)
loc_27918: 
		bra.w	loc_27932
		bra.w	loc_27980
		bra.w	loc_279A0
		bra.w	loc_27A56
		bra.w	loc_27A8E
		bra.w	loc_27BD4
		rts
;--------------------------------------------------------------------------------
loc_27932:
		move.l	a4,a1
		moveq	#8,d0
loc_27936: 
		clr.w	(a1)+
		dbra	d0,loc_27936
		move.b	($FFFFFE0F).w,d0
		move.b	d0,6(a4)
		ror.b	#3,d0
		move.b	d0,$A(a4)
		ror.b	#3,d0
		move.b	d0,$E(a4)
		move.b	#8,7(a4)
		move.b	#8,$B(a4)
		move.b	#8,$F(a4)
		move.b	#8,8(a4)
		move.b	#8,$C(a4)
		move.b	#8,$10(a4)
		move.b	#1,1(a4)
		addq.b	#4,0(a4)
		rts
;--------------------------------------------------------------------------------
loc_27980:
		bsr.w	loc_27BF0
		tst.b	1(a4)
		beq.s	loc_2798C
		rts
;--------------------------------------------------------------------------------
loc_2798C:
		move.b	#$18,0(a4)
		clr.w	8(a4)
		clr.w	$C(a4)
		clr.w	$10(a4)
		rts
;--------------------------------------------------------------------------------
loc_279A0:
		move.b	($FFFFFE0F).w,d0
		and.b	#7,d0
		subq.b	#4,d0
		add.b	#$30,d0
		move.b	d0,8(a4)
		move.b	($FFFFFE0F).w,d0
		rol.b	#4,d0
		and.b	#7,d0
		subq.b	#4,d0
		add.b	#$30,d0
		move.b	d0,$C(a4)
		move.b	($FFFFFE0E).w,d0
		and.b	#7,d0
		subq.b	#4,d0
		add.b	#$30,d0
		move.b	d0,$10(a4)
		move.b	#2,1(a4)
		clr.b	3(a4)
		clr.b	9(a4)
		clr.b	$D(a4)
		clr.b	$11(a4)
		addq.b	#4,0(a4)
		move.b	($FFFFFE0F).w,d0
		ror.b	#3,d0
		lea	(loc_27E1A),a2
loc_279FE: 
		sub.b	(a2),d0
		bcs.s	loc_27A06
		addq.w	#3,a2
		bra.s	loc_279FE
loc_27A06:
		cmp.b	#$FF,(a2)
		beq.s	loc_27A1A
		move.b	1(a2),4(a4)
		move.b	2(a2),5(a4)
		rts
;--------------------------------------------------------------------------------
loc_27A1A:
		move.b	d0,d1
		and.w	#7,d1
		lea	(loc_27E2F),a1
		move.b	0(a1,d0),4(a4)
		ror.b	#3,d0
		move.b	d0,d1
		and.w	#7,d1
		lea	(loc_27E37),a1
		move.b	0(a1,d1),d2
		lsl.b	#4,d2
		ror.b	#3,d0
		and.w	#7,d0
		lea	(loc_27E3F),a1
		or.b	0(a1,d0),d2
		move.b	d2,5(a4)
		rts
;--------------------------------------------------------------------------------
loc_27A56:
		bsr.w	loc_27BF0
		tst.b	1(a4)
		beq.s	loc_27A62
		rts
;--------------------------------------------------------------------------------
loc_27A62:
		add.b	#$30,8(a4)
		add.b	#$30,$C(a4)
		add.b	#$30,$10(a4)
		move.b	($FFFFFE0F).w,d0
		and.b	#$F,d0
		add.b	#$C,d0
		move.b	d0,1(a4)
		clr.b	2(a4)
		addq.b	#4,0(a4)
		rts
;--------------------------------------------------------------------------------
loc_27A8E:
		bsr.w	loc_27BF0
		cmp.b	#$C,9(a4)
		bne.s	loc_27AAC
		cmp.b	#$C,$D(a4)
		bne.s	loc_27AAC
		cmp.b	#$C,$11(a4)
		beq	loc_27BD4
loc_27AAC:
		moveq	#0,d0
		move.b	3(a4),d0
		lea	6(a4),a1
		add.w	d0,a1
		lea	(loc_27E2F),a3
		add.w	d0,d0
		add.w	d0,a3
		moveq	#0,d0
		move.b	3(a1),d0
		jmp	loc_27ACC(pc,d0)
loc_27ACC 
		bra.w	loc_27B1A
		bra.w	loc_27B56
		bra.w	loc_27BC0
		bra.w	loc_27BD2
loc_27ADC: 
		move.w	4(a4),d1
		move.b	3(a4),d0
		beq.s	loc_27AE8
		lsr.w	d0,d1
loc_27AE8:
		and.w	#7,d1
		cmp.b	#5,d1
		bgt.s	loc_27AF4
		rts
;--------------------------------------------------------------------------------
loc_27AF4:
		subq.b	#2,d1
		rts
;--------------------------------------------------------------------------------
loc_27AF8: 
		move.w	#$FFF0,d2
		and.w	#$F,d1
		move.b	3(a4),d0
		beq.s	loc_27B0A
		lsl.w	d0,d1
		rol.w	d0,d2
loc_27B0A:
		and.w	d2,4(a4)
		or.w	d1,4(a4)
		and.w	#$777,4(a4)
		rts
;--------------------------------------------------------------------------------
loc_27B1A:
		tst.b	3(a4)
		bne.s	loc_27B28
		tst.b	1(a4)
		bmi.s	loc_27B32
		rts
;--------------------------------------------------------------------------------
loc_27B28:
		cmp.b	#8,$FFFFFFFF(a1)
		bge.s	loc_27B32
		rts
;--------------------------------------------------------------------------------
loc_27B32:
		bsr.s	loc_27ADC
		move.w	(a1),d0
		sub.w	#$A0,d0
		lsr.w	#8,d0
		and.w	#7,d0
		move.b	0(a3,d0),d0
		cmp.b	d1,d0
		beq.s	loc_27B4A
		rts
;--------------------------------------------------------------------------------
loc_27B4A:
		addq.b	#4,3(a1)
		move.b	#$60,2(a1)
		rts
;--------------------------------------------------------------------------------
loc_27B56:
		bsr.s	loc_27ADC
		move.w	(a1),d0
		add.w	#$F0,d0
		and.w	#$700,d0
		lsr.w	#8,d0
		move.b	0(a3,d0),d0
		cmp.b	d0,d1
		beq.s	loc_27B94
		cmp.b	#$20,2(a1)
		bls.s	loc_27B7A
		sub.b	#$C,2(a1)
loc_27B7A:
		cmp.b	#$18,2(a1)
		bgt.s	loc_27B84
		rts
;--------------------------------------------------------------------------------
loc_27B84:
		cmp.b	#$80,1(a1)
		bls.s	loc_27B8E
		rts
;--------------------------------------------------------------------------------
loc_27B8E:
		subq.b	#2,2(a1)
		rts
;--------------------------------------------------------------------------------
loc_27B94:
		move.w	(a1),d0
		add.w	#$80,d0
		move.w	d0,d1
		and.w	#$700,d1
		sub.w	#$10,d1
		move.w	d1,(a1)
		lsr.w	#8,d0
		and.w	#7,d0
		move.b	0(a3,d0),d1
		bsr.w	loc_27AF8
		move.b	#$F8,2(a1)
		addq.b	#4,3(a1)
		rts
;--------------------------------------------------------------------------------
loc_27BC0:
		tst.b	1(a1)
		beq.s	loc_27BC8
		rts
;--------------------------------------------------------------------------------
loc_27BC8:
		clr.b	2(a1)
		addq.b	#4,3(a1)
		rts
;--------------------------------------------------------------------------------
loc_27BD2:
		rts
;--------------------------------------------------------------------------------
loc_27BD4:
		clr.w	8(a4)
		clr.w	$C(a4)
		clr.w	$10(a4)
		clr.b	1(a4)
		bsr.w	loc_27CC4
		move.b	#$18,0(a4)
		rts
;--------------------------------------------------------------------------------
loc_27BF0:
		moveq	#0,d0
		move.b	3(a4),d0
		lea	6(a4),a1
		add.w	d0,a1
		lea	(loc_27E2F),a3
		add.w	d0,a3
		add.w	d0,a3
		jmp	loc_27C0A(pc,d0)
loc_27C0A: 
		bra.w	loc_27C20
		bra.w	loc_27C2C
		clr.b	3(a4)
		subq.b	#1,1(a4)
		move.w	#$AE00,d2
		bra.s	loc_27C34
loc_27C20:
		addq.b	#4,3(a4)
		move.w	#$AA00,d2
		bra.w	loc_27C34
loc_27C2C:
		addq.b	#4,3(a4)
		move.w	#$AC00,d2
loc_27C34:
		move.w	(a1),d0
		move.b	2(a1),d1
		ext.w	d1
		sub.w	d1,(a1)
		move.w	(a1),d3
		and.w	#$7F8,d0
		and.w	#$7F8,d3
		cmp.w	d0,d3
		bne.s	loc_27C4E
		rts
;--------------------------------------------------------------------------------
loc_27C4E:
		bsr.w	loc_27C9E
		lea	($FFFFA000).w,a1
		move.w	#$1F,d1
loc_27C5A: 
		move.l	$80(a2),$80(a1)
		move.l	$100(a2),$100(a1)
		move.l	$180(a2),$180(a1)
		move.l	(a2)+,(a1)+
		addq.b	#8,d3
		bne.s	loc_27C7E
		add.w	#$100,d3
		and.w	#$700,d3
		bsr.w	loc_27C9E
loc_27C7E:
		dbra	d1,loc_27C5A
		move.l	#$FFA000,d1
		tst.w	($FFFFFFD8).w
		beq.s	loc_27C92
		add.w	#$4000,d2
loc_27C92:
		move.w	#$100,d3
		jsr	DMA_68KtoVRAM 
		rts
;--------------------------------------------------------------------------------
loc_27C9E:
		move.w	d3,d0
		lsr.w	#8,d0
		and.w	#7,d0
		move.b	0(a3,d0),d0
		and.w	#7,d0
		ror.w	#7,d0
		lea	(CNz_Slot_Machine_Checks),a2 
		add.w	d0,a2
		move.w	d3,d0
		and.w	#$F8,d0
		lsr.w	#1,d0
		add.w	d0,a2
		rts
;--------------------------------------------------------------------------------
loc_27CC4:
		move.b	5(a4),d2
		move.b	d2,d3
		and.w	#$F0,d2
		lsr.w	#4,d2
		and.w	#$F,d3
		moveq	#0,d0
		cmp.b	4(a4),d2
		bne.s	loc_27CDE
		addq.w	#4,d0
loc_27CDE:
		cmp.b	4(a4),d3
		bne.s	loc_27CE6
		addq.w	#8,d0
loc_27CE6:
		jmp	loc_27CEA(pc,d0)
loc_27CEA: 
		bra.w	loc_27D5A
		bra.w	loc_27D30
		bra.w	loc_27D02
		move.w	d2,d0
		bsr.w	loc_27DB0
		move.w	d0,4(a4)
		rts
;--------------------------------------------------------------------------------
loc_27D02:
		cmp.b	#3,d3
		bne.s	loc_27D18
		move.w	d2,d0
		bsr.w	loc_27DB0
		bsr.w	loc_27DBE
		move.w	d0,4(a4)
		rts
;--------------------------------------------------------------------------------
loc_27D18:
		cmp.b	#3,d2
		bne.w	loc_27D5A
		move.w	d3,d0
		bsr.w	loc_27DB0
		bsr.w	loc_27DE2
		move.w	d0,4(a4)
		rts
;--------------------------------------------------------------------------------
loc_27D30:
		cmp.b	#3,d2
		bne.s	loc_27D44
		move.w	d3,d0
		bsr.s	loc_27DB0
		bsr.w	loc_27DBE
		move.w	d0,4(a4)
		rts
;--------------------------------------------------------------------------------
loc_27D44:
		cmp.b	#3,d3
		bne.w	loc_27D5A
		move.w	d2,d0
		bsr.s	loc_27DB0
		bsr.w	loc_27DE2
		move.w	d0,4(a4)
		rts
;--------------------------------------------------------------------------------
loc_27D5A:
		cmp.b	d2,d3
		bne.s	loc_27D8E
		cmp.b	#3,4(a4)
		bne.s	loc_27D74
		move.w	d2,d0
		bsr.s	loc_27DB0
		bsr.w	loc_27DE2
		move.w	d0,4(a4)
		rts
;--------------------------------------------------------------------------------
loc_27D74:
		cmp.b	#3,d2
		bne.s	loc_27D8E
		move.b	4(a4),d0
		and.w	#$F,d0
		bsr.s	loc_27DB0
		bsr.w	loc_27DBE
		move.w	d0,4(a4)
		rts
;--------------------------------------------------------------------------------
loc_27D8E:
		moveq	#2,d1
		moveq	#0,d0
		cmp.b	#5,4(a4)
		bne.s	loc_27D9C
		add.w	d1,d0
loc_27D9C:
		cmp.b	#5,d2
		bne.s	loc_27DA4
		add.w	d1,d0
loc_27DA4:
		cmp.b	#5,d3
		bne.s	loc_27DAC
		add.w	d1,d0
loc_27DAC:
		move.w	d0,4(a4)
loc_27DB0:
		add.w	d0,d0
		lea	(loc_27E0E),a2
		move.w	0(a2,d0),d0
		rts
;--------------------------------------------------------------------------------
loc_27DBE:
		tst.w	d0
		bmi.s	loc_27DDE
		bsr.s	loc_27DFC
		abcd D2,d2
		abcd D1,d1
		abcd D3,d3
		abcd D1,d3
		moveq	#0,d1
		abcd D2,d2
		abcd D1,d1
		abcd D3,d3
		abcd D1,d3
		lsl.w	#8,d3
		move.w	d2,d0
		add.w	d3,d0
		rts
;--------------------------------------------------------------------------------
loc_27DDE:
		asl.w	#2,d0
		rts
;--------------------------------------------------------------------------------
loc_27DE2:
		tst.w	d0
		bmi.s	loc_27DF8
		bsr.s	loc_27DFC
		abcd D2,d2
		abcd D1,d1
		abcd D3,d3
		abcd D1,d3
		lsl.w	#8,d3
		move.w	d2,d0
		add.w	d3,d0
		rts
;--------------------------------------------------------------------------------
loc_27DF8:
		add.w	d0,d0
		rts
;--------------------------------------------------------------------------------
loc_27DFC:
		move.w	d0,d2
		and.w	#$FF,d2
		move.w	d0,d3
		and.w	#$F00,d3
		lsr.w	#8,d3
		moveq	#0,d1
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_27E0E: 
		dc.w	$30,$25,$FFFF,$150,$10,$20
;------------------------------------------------------------------------------- 
loc_27E1A:
		dc.b	$8,$3,$33,$12,$0,$0,$12,$1,$11,$24,$2,$22,$1E,$4,$44,$1E
		dc.b	$5,$55,$FF,$F,$FF 
;------------------------------------------------------------------------------- 
loc_27E2F:
		dc.b	$3,$0,$1,$4,$2,$5,$4,$1 
;------------------------------------------------------------------------------- 
loc_27E37:
		dc.b	$3,$0,$1,$4,$2,$5,$0,$2 
;------------------------------------------------------------------------------- 
loc_27E3F:
		dc.b	$3,$0,$1,$4,$2,$5,$4,$1 
;------------------------------------------------------------------------------- 
		even 
;===============================================================================
; Sub Routine Load_Slot_Machine_Sprites 
; [ End ] 
;=============================================================================== 
loc_27E48:
		jmp	SingleObjectLoad 
loc_27E4E:
		jmp	MarkObjGone 
loc_27E54:
		jmp	AnimateSprite 
loc_27E5A:
		jmp	ModifySpriteAttr_2P 
loc_27E60:
		jmp	(loc_157D2) 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0xD7_CNz_Blue_Bumper: 
		include 'objects/obj_0xD7.asm'
		nop ; Filler 
loc_280B4:
		jmp	DisplaySprite 
loc_280BA:
		jmp	MarkObjGone 
loc_280C0:
		jmp	AnimateSprite 
loc_280C6:
		jmp	ModifySpriteAttr_2P 
;------------------------------------------------------------------------------- 
Obj_0xD8_CNz_Green_Bumper: 
		include 'objects/obj_0xD8.asm'
loc_2832C:
		jmp	DeleteObject 
loc_28332:
		jmp	SingleObjectLoad 
loc_28338:
		jmp	MarkObjGone 
loc_2833E:
		jmp	AnimateSprite 
loc_28344:
		jmp	ModifySpriteAttr_2P 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0xD9_SFz_Hang_Attributes: 
		include 'objects/obj_0xD9.asm'
		nop ; Filler 
loc_2842C:
		jmp	(loc_12D80) 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x4C_Batbot: 
		include 'objects/obj_0x4C.asm'
		cnop	0,4 ; Filler 
loc_288A8:
		jmp	MarkObjGone 
loc_288AE:
		jmp	AnimateSprite 
loc_288B4:
		jmp	SpeedToPos 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x4E_Crocobot: 
		include 'objects/obj_0x4E.asm'
loc_28B9C:
		jmp	MarkObjGone 
loc_28BA2:
		jmp	AnimateSprite 
loc_28BA8:
		jmp	ObjectFall 
loc_28BAE:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x4A_Octus: 
		include 'objects/obj_0x4A.asm'
		dc.w	$0 ; Filler
J_DisplaySprite: 
		jmp	DisplaySprite 
J_DeleteObject: 
		jmp	DeleteObject 
J_MarkObjGone: 
		jmp	MarkObjGone 
loc_28E56:
		jmp	AnimateSprite 
J_ObjectFall: 
		jmp	ObjectFall 
loc_28E62:
		jmp	SpeedToPos 
;------------------------------------------------------------------------------- 
Obj_0x4F_Dinobot: 
		include 'objects/obj_0x4F.asm'
		cnop	0,4 ; Filler 
loc_28FAC:
		jmp	DisplaySprite 
loc_28FB2:
		jmp	DeleteObject 
loc_28FB8:
		jmp	AnimateSprite 
loc_28FBE:
		jmp	ObjectFall 
loc_28FC4:
		jmp	SpeedToPos 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x50_Aquis: 
		include 'objects/obj_0x50.asm'
loc_29310:
		jmp	DisplaySprite 
loc_29316:
		jmp	DeleteObject 
loc_2931C:
		jmp	SingleObjectLoad 
loc_29322:
		jmp	MarkObjGone 
loc_29328:
		jmp	AnimateSprite 
loc_2932E:
		jmp	(loc_32866)
loc_29334:
		jmp	(loc_3292A)
loc_2933A:
		jmp	(loc_32964)
loc_29340:
		jmp	SpeedToPos 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x4D_Rhinobot: 
		include 'objects/obj_0x4D.asm'
		cnop	0,4 ; Filler 
loc_29604:
		jmp	MarkObjGone 
loc_2960A:
		jmp	AnimateSprite 
loc_29610:
		jmp	ObjectFall 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x4B_Buzzer 
		include 'objects/obj_0x4B.asm'
		cnop	0,4 ; Filler 
loc_29908:
		jmp	DeleteObject 
loc_2990E:
		jmp	S1SingleObjectLoad 
loc_29914:
		jmp	AnimateSprite 
loc_2991A:
		jmp	Modify_A1_SpriteAttr_2P 
loc_29920:
		jmp	(loc_12DB4)
loc_29926:
		jmp	ModifySpriteAttr_2P 
loc_2992C:
		jmp	SpeedToPos 
		cnop	0,4 ; Filler 
;-------------------------------------------------------------------------------
Obj_0x5C_Masher: 
		include 'objects/obj_0x5C.asm'
		dc.w	$0 ; Filler
loc_29A1C:
		jmp	MarkObjGone 
loc_29A22:
		jmp	AnimateSprite 
loc_29A28:
		jmp	ModifySpriteAttr_2P 
loc_29A2E:
		jmp	SpeedToPos 
;-------------------------------------------------------------------------------
Obj_0x58_Boss_Explosions: 
		include 'objects/obj_0x58.asm'
;-------------------------------------------------------------------------------
Unk_loc_29AFE:
		move.b	$1A(a0),d0
		jsr	CalcSine 
		asr.w	#6,d0
		add.w	($FFFFF754).w,d0
		move.w	d0,$C(a0)
		move.w	($FFFFF750).w,8(a0)
		addq.b	#2,$1A(a0) 
;-------------------------------------------------------------------------------
loc_29B1C: ; Called By HTz Boss
		cmp.b	#8,$26(a0)
		bcc.s	loc_29B62
		tst.b	$32(a0)
		beq.s	loc_29B64
		tst.b	$20(a0)
		bne.s	loc_29B62
		tst.b	$14(a0)
		bne.s	loc_29B46
		move.b	#$20,$14(a0)
		move.w	#$AC,d0
		jsr	Play_Sfx
loc_29B46:
		lea	($FFFFFB22).w,a1
		moveq	#0,d0
		tst.w	(a1)
		bne.s	loc_29B54
		move.w	#$EEE,d0
loc_29B54:
		move.w	d0,(a1)
		subq.b	#1,$14(a0)
		bne.s	loc_29B62
		move.b	#$F,$20(a0)
loc_29B62:
		rts
;--------------------------------------------------------------------------------
loc_29B64:
		moveq	#$64,d0
		bsr.w	loc_29CC6
		move.w	#$B3,($FFFFF75C).w
		move.b	#8,$26(a0)
		moveq	#$40,d0
		bsr.w	loc_29CC0
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_29B7E:
		move.l	($FFFFF750).w,d2
		move.l	($FFFFF754).w,d3
		move.w	($FFFFF758).w,d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	($FFFFF75A).w,d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,($FFFFF750).w
		move.l	d3,($FFFFF754).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_29BA4:
		moveq	#0,d6
		move.l	a1,a4
		lea	($FFFFF740).w,a2
		lea	$B(a0),a3
		tst.b	(a3)
		bne.s	loc_29BB8
		addq.w	#2,a2
		bra.s	loc_29BBC
loc_29BB8:
		bsr.w	loc_29BCA
loc_29BBC:
		moveq	#0,d6
		move.b	$F(a0),d6
		subq.w	#1,d6
		bmi.s	loc_29C30
		lea	$15(a0),a3
loc_29BCA:
		move.l	a4,a1
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d4
		move.b	(a2)+,d0
		move.b	d0,d1
		lsr.b	#4,d1
		and.b	#$F,d0
		move.b	d0,d2
		cmp.b	d0,d1
		beq.s	loc_29BE6
		st D4
loc_29BE6:
		move.b	d0,d5
		lsl.b	#4,d5
		or.b	d0,d5
		move.b	(a2)+,d0
		move.b	d0,d1
		lsr.b	#4,d1
		tst.b	d4
		beq.s	loc_29BFA
		moveq	#0,d0
		moveq	#0,d1
loc_29BFA:
		and.b	#$F,d0
		sub.b	#1,d0
		bpl.s	loc_29C1C
		add.w	d2,d2
		add.w	0(a1,d2),a1
		move.b	(a1),d0
		move.b	1(a1,d1),d2
		bmi.s	loc_29C32
loc_29C12: 
		and.b	#$7F,d2
		move.b	d2,(a3)
		add.b	#1,d1
loc_29C1C:
		lsl.b	#4,d1
		or.b	d1,d0
		move.b	d0,$FFFFFFFF(a2)
		move.b	d5,$FFFFFFFE(a2)
		add.w	#6,a3
		dbra	d6,loc_29BCA
loc_29C30:
		rts
;--------------------------------------------------------------------------------
loc_29C32:
		addq.b	#1,d2
		bne.s	loc_29C40
		move.b	#0,d1
		move.b	1(a1),d2
		bra.s	loc_29C12
loc_29C40:
		addq.b	#1,d2
		bne.s	loc_29C4C
		add.b	#2,$26(a0)
		rts
;--------------------------------------------------------------------------------
loc_29C4C:
		addq.b	#1,d2
		bne.s	loc_29C5A
		and.b	#$F0,d5
		or.b	2(a1,d1),d5
		bra.s	loc_29C1C
loc_29C5A:
		addq.b	#1,d2
		bne.s	loc_29C6A
		moveq	#0,d3
		move.b	2(a1,d1),d1
		move.b	1(a1,d1),d2
		bra.s	loc_29C12
loc_29C6A:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Boss_Defeated
; [ Begin ]
;===============================================================================
Boss_Defeated: 
		move.b	($FFFFFE0F).w,d0
		and.b	#7,d0
		bne.s	loc_29CB2
		jsr	SingleObjectLoad 
		bne.s	loc_29CB2
		move.b	#$58,0(a1) ; Call Explosion Object
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		jsr	PseudoRandomNumber 
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		sub.w	#$20,d1
		add.w	d1,8(a1)
		lsr.w	#8,d0
		lsr.b	#2,d0
		sub.w	#$20,d0
		add.w	d0,$C(a1)
loc_29CB2:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Boss_Defeated
; [ End ]
;===============================================================================
loc_29CB4:
		jmp	DisplaySprite 
loc_29CBA:
		jmp	DeleteObject 
loc_29CC0:
		jmp	LoadPLC 
loc_29CC6:
		jmp	Add_Points 
loc_29CCC:
		jmp	ModifySpriteAttr_2P 
		dc.w	$0 ; Filler
;-------------------------------------------------------------------------------
Obj_0x5D_CPz_Boss: 
		include 'objects/obj_0x5D.asm'
loc_2B470:
		jmp	DisplaySprite 
loc_2B476:
		jmp	DeleteObject 
loc_2B47C:
		jmp	MarkObjGone 
loc_2B482:
		jmp	Play_Sfx
loc_2B488:
		jmp	Modify_A1_SpriteAttr_2P 
loc_2B48E:
		jmp	LoadPLC 
loc_2B494:
		jmp	Add_Points 
loc_2B49A:
		jmp	ModifySpriteAttr_2P 
loc_2B4A0:
		jmp	Boss_Defeated_Music_Restore 
loc_2B4A6:
		jmp	Boss_Defeated_Load_Flickies 
loc_2B4AC:
		jmp	ObjectFall 
loc_2B4B2:
		jmp	SpeedToPos 
;-------------------------------------------------------------------------------
Obj_0x56_GHz_Boss: 
		include 'objects/obj_0x56.asm'
		dc.w	$0 ; Filler
loc_2C198:
		jmp	DisplaySprite 
loc_2C19E:
		jmp	DeleteObject 
loc_2C1A4:
		jmp	MarkObjGone 
loc_2C1AA:
		jmp	Delete_A1_Object 
loc_2C1B0:
		jmp	Play_Sfx
loc_2C1B6:
		jmp	S1SingleObjectLoad 
loc_2C1BC:
		jmp	AnimateSprite 
loc_2C1C2:
		jmp	Modify_A1_SpriteAttr_2P 
loc_2C1C8:
		jmp	ObjHitFloor 
loc_2C1CE:
		jmp	LoadPLC 
loc_2C1D4:
		jmp	Add_Points 
loc_2C1DA:
		jmp	ModifySpriteAttr_2P 
loc_2C1E0:
		jmp	Boss_Defeated_Music_Restore 
loc_2C1E6:
		jmp	Boss_Defeated_Load_Flickies 
loc_2C1EC:
		jmp	ObjectFall 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x52_HTz_Boss: 
		include 'objects/obj_0x52.asm'
		dc.w	$0 ; Filler
loc_2C970:
		jmp	DisplaySprite 
loc_2C976:
		jmp	DeleteObject 
loc_2C97C:
		jmp	SingleObjectLoad 
loc_2C982:
		jmp	MarkObjGone 
loc_2C988:
		jmp	Play_Sfx
loc_2C98E:
		jmp	AnimateSprite 
loc_2C994:
		jmp	ObjHitFloor 
loc_2C99A:
		jmp	Obj_0x20_HTz_Boss_FireBall 
loc_2C9A0:
		jmp	ModifySpriteAttr_2P 
loc_2C9A6:
		jmp	Boss_Defeated_Music_Restore 
loc_2C9AC:
		jmp	Boss_Defeated_Load_Flickies 
		cnop	0,4 ; Filler 
;-------------------------------------------------------------------------------
Obj_0x89_NGHz_Boss: 
		include 'objects/obj_0x89.asm'
loc_2D45C:
		jmp	DisplaySprite 
loc_2D462:
		jmp	DeleteObject 
loc_2D468:
		jmp	SingleObjectLoad 
loc_2D46E:
		jmp	Play_Sfx
loc_2D474:
		jmp	S1SingleObjectLoad 
loc_2D47A:
		jmp	AnimateSprite 
loc_2D480:
		jmp	PseudoRandomNumber 
loc_2D486:
		jmp	LoadPLC 
loc_2D48C:
		jmp	Add_Points 
loc_2D492:
		jmp	Boss_Defeated_Music_Restore 
loc_2D498:
		jmp	Boss_Defeated_Load_Flickies 
loc_2D49E:
		jmp	(loc_15C6A)
loc_2D4A4:
		jmp	SolidObject 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x57_DHz_Boss: 
		include 'objects/obj_0x57.asm'
		cnop	0,4 ; Filler 
loc_2DDC8:
		jmp	DisplaySprite 
loc_2DDCE:
		jmp	DeleteObject 
loc_2DDD4:
		jmp	SingleObjectLoad 
loc_2DDDA:
		jmp	PseudoRandomNumber 
loc_2DDE0:
		jmp	LoadPLC 
loc_2DDE6:
		jmp	Add_Points 
loc_2DDEC:
		jmp	Boss_Defeated_Music_Restore 
loc_2DDF2:
		jmp	Boss_Defeated_Load_Flickies 
loc_2DDF8:
		jmp	ObjectFall 
		dc.w	$0 ; Filler
;------------------------------------------------------------------------------- 
Obj_0x51_CNz_Boss: 
		include 'objects/obj_0x51.asm'
		cnop	0,4 ; Filler 
loc_2E764:
		jmp	DisplaySprite 
loc_2E76A:
		jmp	DeleteObject 
loc_2E770:
		jmp	SingleObjectLoad 
loc_2E776:
		jmp	Play_Sfx
loc_2E77C:
		jmp	S1SingleObjectLoad 
loc_2E782:
		jmp	AnimateSprite 
loc_2E788:
		jmp	LoadPLC 
loc_2E78E:
		jmp	Add_Points 
loc_2E794:
		jmp	Boss_Defeated_Music_Restore 
loc_2E79A:
		jmp	Boss_Defeated_Load_Flickies 
;------------------------------------------------------------------------------- 
Obj_0x54_Mz_Boss: 
		include 'objects/obj_0x54.asm'
;------------------------------------------------------------------------------- 
Obj_0x53_Mz_Boss_Balls_Robotniks: 
		include 'objects/obj_0x53.asm'
loc_2F468:
		jmp	DisplaySprite 
loc_2F46E:
		jmp	DeleteObject 
loc_2F474:
		jmp	SingleObjectLoad 
loc_2F47A:
		jmp	Play_Sfx
loc_2F480:
		jmp	AnimateSprite 
loc_2F486:
		jmp	LoadPLC 
loc_2F48C:
		jmp	Add_Points 
loc_2F492:
		jmp	Boss_Defeated_Music_Restore 
loc_2F498:
		jmp	Boss_Defeated_Load_Flickies 
loc_2F49E:
		jmp	ObjectFall 
loc_2F4A4:
		jmp	SpeedToPos 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x55_OOz_Boss: 
		include 'objects/obj_0x55.asm'
loc_2FDB4:
		jmp	DisplaySprite 
loc_2FDBA:
		jmp	DeleteObject 
loc_2FDC0:
		jmp	SingleObjectLoad 
loc_2FDC6:
		jmp	MarkObjGone 
loc_2FDCC:
		jmp	Play_Sfx
loc_2FDD2:
		jmp	S1SingleObjectLoad 
loc_2FDD8:
		jmp	AnimateSprite 
loc_2FDDE:
		jmp	PseudoRandomNumber 
loc_2FDE4:
		jmp	ModifySpriteAttr_2P 
loc_2FDEA:
		jmp	CalcSine 
loc_2FDF0:
		jmp	Boss_Defeated_Music_Restore 
loc_2FDF6:
		jmp	Boss_Defeated_Load_Flickies 
loc_2FDFC:
		jmp	SpeedToPos 
		cnop	0,4 ; Filler 
;-------------------------------------------------------------------------------
Obj_0x09_Sonic_In_Special_Stage: 
		include 'objects/obj_0x09.asm'
;------------------------------------------------------------------------------- 
Obj_0x63: 
		include 'objects/obj_0x63.asm'
;------------------------------------------------------------------------------- 
loc_306FC:
		dc.w	loc_30720-loc_306FC
		dc.w	loc_3073A-loc_306FC
		dc.w	loc_30754-loc_306FC
		dc.w	loc_3076E-loc_306FC
		dc.w	loc_30788-loc_306FC
		dc.w	loc_307AA-loc_306FC
		dc.w	loc_307D4-loc_306FC
		dc.w	loc_307FE-loc_306FC
		dc.w	loc_30828-loc_306FC
		dc.w	loc_3084A-loc_306FC
		dc.w	loc_30874-loc_306FC
		dc.w	loc_3089E-loc_306FC
		dc.w	loc_308D0-loc_306FC
		dc.w	loc_308EA-loc_306FC
		dc.w	loc_30904-loc_306FC
		dc.w	loc_3091E-loc_306FC
		dc.w	loc_30938-loc_306FC
		dc.w	loc_3095A-loc_306FC
loc_30720:
		dc.w	$3
		dc.l	$E40F8000,$8000FFF0,$40A8010,$8008FFF0
		dc.l	$4018019,$800C0008
loc_3073A:
		dc.w	$3
		dc.l	$E40A8000,$8000FFF2,$FC0D8009,$8004FFF0
		dc.l	$C058011,$8008FFF7
loc_30754:
		dc.w	$3
		dc.l	$E40E8000,$8000FFF0,$FC0D800C,$8006FFF0
		dc.l	$C098014,$800AFFF0
loc_3076E:
		dc.w	$3
		dc.l	$E40A8800,$8800FFF6,$FC0D8009,$8004FFF0
		dc.l	$C098011,$8008FFF8
loc_30788:
		dc.w	$4
		dc.l	$E40A8000,$8000FFEC,$E4038009,$80040004
		dc.l	$EC01800D,$8006000C,$FC0E800F,$8007FFE4
loc_307AA:
		dc.w	$5
		dc.l	$E4098000,$8000FFF4,$EC018006,$8003000C
		dc.l	$F40D8008,$8004FFEC,$40D8010,$8008FFE6
		dc.l	$14008018,$800CFFEE
loc_307D4:
		dc.w	$5
		dc.l	$E4048000,$8000FFFB,$EC0E8002,$8001FFEC
		dc.l	$EC02800E,$8007000C,$4068011,$8008FFE7
		dc.l	$4058017,$800BFFF7
loc_307FE:
		dc.w	$5
		dc.l	$E4048000,$8000FFFC,$EC0F8002,$8001FFEC
		dc.l	$EC028012,$8009000C,$4008015,$800AFFE4
		dc.l	$C058016,$800BFFEA
loc_30828:
		dc.w	$4
		dc.l	$E4058000,$8000FFFC,$EC038004,$8002000C
		dc.l	$F40E8008,$8004FFEC,$C058014,$800AFFEC
loc_3084A:
		dc.w	$5
		dc.l	$E4058000,$8000FFFC,$EC028004,$8002000C
		dc.l	$F40D8007,$8003FFEC,$40D800F,$8007FFE8
		dc.l	$EC008017,$800BFFF4
loc_30874:
		dc.w	$5
		dc.l	$E4098000,$8000FFFB,$F4018006,$8003000E
		dc.l	$F40D8008,$8004FFEE,$40D8010,$8008FFE7
		dc.l	$14008018,$800CFFEF
loc_3089E:
		dc.w	$6
		dc.l	$E4008000,$80000002,$EC0D8001,$8000FFF4
		dc.l	$FC008009,$8004000C,$401800A,$8005FFE4
		dc.l	$FC07800C,$8006FFEC,$FC068014,$800AFFFC
loc_308D0:
		dc.w	$3
		dc.l	$F0068000,$8000FFE8,$8008006,$8003FFF0
		dc.l	$F00F8007,$8003FFF8
loc_308EA:
		dc.w	$3
		dc.l	$F0068000,$8000FFE8,$F1038006,$8003FFF8
		dc.l	$F00B800A,$80050000
loc_30904:
		dc.w	$3
		dc.l	$F1028000,$8000FFE8,$F0028003,$8001FFF0
		dc.l	$F00F8006,$8003FFF8
loc_3091E:
		dc.w	$3
		dc.l	$F8068000,$8000FFE8,$EF038006,$8003FFF8
		dc.l	$F00B800A,$80050000
loc_30938:
		dc.w	$4
		dc.l	$EC078000,$8000FFF0,$C048008,$8004FFF0
		dc.l	$EC078800,$88000000,$C048808,$88040000
loc_3095A:
		dc.w	$4
		dc.l	$EC078000,$8000FFF0,$C048008,$8004FFF0
		dc.l	$EC078800,$88000000,$C048808,$88040000
;------------------------------------------------------------------------------- 
Obj_0x10_Mappings: 
		dc.w	loc_30A12-Obj_0x10_Mappings
		dc.w	loc_30A76-Obj_0x10_Mappings
		dc.w	loc_30ADA-Obj_0x10_Mappings
		dc.w	loc_30A08-Obj_0x10_Mappings
		dc.w	loc_30A6C-Obj_0x10_Mappings
		dc.w	loc_30AD0-Obj_0x10_Mappings
		dc.w	loc_309FE-Obj_0x10_Mappings
		dc.w	loc_30A62-Obj_0x10_Mappings
		dc.w	loc_30AC6-Obj_0x10_Mappings
		dc.w	loc_309F4-Obj_0x10_Mappings
		dc.w	loc_30A58-Obj_0x10_Mappings
		dc.w	loc_30ABC-Obj_0x10_Mappings
		dc.w	loc_309EA-Obj_0x10_Mappings
		dc.w	loc_30A4E-Obj_0x10_Mappings
		dc.w	loc_30AB2-Obj_0x10_Mappings
		dc.w	loc_309E0-Obj_0x10_Mappings
		dc.w	loc_30A44-Obj_0x10_Mappings
		dc.w	loc_30AA8-Obj_0x10_Mappings
		dc.w	loc_309D6-Obj_0x10_Mappings
		dc.w	loc_30A3A-Obj_0x10_Mappings
		dc.w	loc_30A9E-Obj_0x10_Mappings
		dc.w	loc_309CC-Obj_0x10_Mappings
		dc.w	loc_30A30-Obj_0x10_Mappings
		dc.w	loc_30A94-Obj_0x10_Mappings
		dc.w	loc_309C2-Obj_0x10_Mappings
		dc.w	loc_30A26-Obj_0x10_Mappings
		dc.w	loc_30A8A-Obj_0x10_Mappings
		dc.w	loc_309B8-Obj_0x10_Mappings
		dc.w	loc_30A1C-Obj_0x10_Mappings
		dc.w	loc_30A80-Obj_0x10_Mappings
loc_309B8:
		dc.w	$1
		dc.l	$FC008000,$8000FFFC
loc_309C2:
		dc.w	$1
		dc.l	$FC008001,$8000FFFC
loc_309CC:
		dc.w	$1
		dc.l	$FC048002,$8001FFF8
loc_309D6:
		dc.w	$1
		dc.l	$FC048004,$8002FFF8
loc_309E0:
		dc.w	$1
		dc.l	$FC048006,$8003FFF8
loc_309EA:
		dc.w	$1
		dc.l	$FC088008,$8004FFF4
loc_309F4:
		dc.w	$1
		dc.l	$FC08800B,$8005FFF4
loc_309FE:
		dc.w	$1
		dc.l	$F80D800E,$8007FFF0
loc_30A08:
		dc.w	$1
		dc.l	$F80D8016,$800BFFF0
loc_30A12:
		dc.w	$1
		dc.l	$F80D801E,$800FFFF0
loc_30A1C:
		dc.w	$1
		dc.l	$FC008000,$8000FFFC
loc_30A26:
		dc.w	$1
		dc.l	$FC008001,$8000FFFC
loc_30A30:
		dc.w	$1
		dc.l	$FC008002,$8001FFFC
loc_30A3A:
		dc.w	$1
		dc.l	$F8058003,$8001FFF8
loc_30A44:
		dc.w	$1
		dc.l	$F8058007,$8003FFF8
loc_30A4E:
		dc.w	$1
		dc.l	$F405800B,$8005FFFC
loc_30A58:
		dc.w	$1
		dc.l	$F40A800F,$8007FFF4
loc_30A62:
		dc.w	$1
		dc.l	$F40A8018,$800CFFF4
loc_30A6C:
		dc.w	$1
		dc.l	$F00A8021,$8010FFF8
loc_30A76:
		dc.w	$1
		dc.l	$F00F802A,$8015FFF0
loc_30A80:
		dc.w	$1
		dc.l	$FC008000,$8000FFFC
loc_30A8A:
		dc.w	$1
		dc.l	$FC008001,$8000FFFC
loc_30A94:
		dc.w	$1
		dc.l	$F8018002,$8001FFFC
loc_30A9E:
		dc.w	$1
		dc.l	$F8018004,$8002FFFC
loc_30AA8:
		dc.w	$1
		dc.l	$F8018006,$8003FFFC
loc_30AB2:
		dc.w	$1
		dc.l	$F4028008,$8004FFFC
loc_30ABC:
		dc.w	$1
		dc.l	$F402800B,$8005FFFC
loc_30AC6:
		dc.w	$1
		dc.l	$F402800E,$8007FFFC
loc_30AD0:
		dc.w	$1
		dc.l	$F0038011,$8008FFFC
loc_30ADA:
		dc.w	$1
		dc.l	$F0038015,$800AFFFC
loc_30AE4: ; 
		dc.w	loc_30B56-loc_30AE4
		dc.w	loc_30B5E-loc_30AE4
		dc.w	loc_30B66-loc_30AE4
		dc.w	loc_30B6E-loc_30AE4
		dc.w	loc_30B76-loc_30AE4
		dc.w	loc_30B80-loc_30AE4
		dc.w	loc_30B8C-loc_30AE4
		dc.w	loc_30B98-loc_30AE4
		dc.w	loc_30BA4-loc_30AE4
		dc.w	loc_30BAE-loc_30AE4
		dc.w	loc_30BBA-loc_30AE4
		dc.w	loc_30BC6-loc_30AE4
		dc.w	loc_30BD4-loc_30AE4
		dc.w	loc_30BDC-loc_30AE4
		dc.w	loc_30BE4-loc_30AE4
		dc.w	loc_30BEC-loc_30AE4
		dc.w	loc_30BF4-loc_30AE4
		dc.w	loc_30BFA-loc_30AE4
		dc.w	loc_30C00-loc_30AE4
		dc.w	loc_30C08-loc_30AE4
		dc.w	loc_30C12-loc_30AE4
		dc.w	loc_30C1C-loc_30AE4
		dc.w	loc_30C28-loc_30AE4
		dc.w	loc_30C30-loc_30AE4
		dc.w	loc_30C3A-loc_30AE4
		dc.w	loc_30C46-loc_30AE4
		dc.w	loc_30C50-loc_30AE4
		dc.w	loc_30C5A-loc_30AE4
		dc.w	loc_30C66-loc_30AE4
		dc.w	loc_30C72-loc_30AE4
		dc.w	loc_30C7C-loc_30AE4
		dc.w	loc_30C82-loc_30AE4
		dc.w	loc_30C8A-loc_30AE4
		dc.w	loc_30C90-loc_30AE4
		dc.w	loc_30C98-loc_30AE4
		dc.w	loc_30C9C-loc_30AE4
		dc.w	loc_30CA0-loc_30AE4
		dc.w	loc_30CA2-loc_30AE4
		dc.w	loc_30CA4-loc_30AE4
		dc.w	loc_30CA6-loc_30AE4
		dc.w	loc_30CA8-loc_30AE4
		dc.w	loc_30CAA-loc_30AE4
		dc.w	loc_30CAC-loc_30AE4
		dc.w	loc_30CAE-loc_30AE4
		dc.w	loc_30CB0-loc_30AE4
		dc.w	loc_30CB2-loc_30AE4
		dc.w	loc_30CB4-loc_30AE4
		dc.w	loc_30CB6-loc_30AE4
		dc.w	loc_30CB8-loc_30AE4
		dc.w	loc_30CBA-loc_30AE4
		dc.w	loc_30CBC-loc_30AE4
		dc.w	loc_30CBE-loc_30AE4
		dc.w	loc_30CC0-loc_30AE4
		dc.w	loc_30CC2-loc_30AE4
		dc.w	loc_30CC4-loc_30AE4
		dc.w	loc_30CC6-loc_30AE4
		dc.w	loc_30CC8-loc_30AE4
loc_30B56:
		dc.w	$3
		dc.w	$F000,$8100,$1190
loc_30B5E:
		dc.w	$3
		dc.w	$81B0,$7240,$32C0
loc_30B66:
		dc.w	$3
		dc.w	$B300,$73C0,$5440
loc_30B6E:
		dc.w	$3
		dc.w	$81B0,$74A0,$5520
loc_30B76:
		dc.w	$4
		dc.w	$8000,$3090,$10D0,$B0F0
loc_30B80:
		dc.w	$5
		dc.w	$51B0,$1210,$7230,$72B0,$330
loc_30B8C:
		dc.w	$5
		dc.w	$1340,$B360,$2420,$5450,$34B0
loc_30B98:
		dc.w	$5
		dc.w	$14F0,$F510,$2610,$640,$3650
loc_30BA4:
		dc.w	$4
		dc.w	$3690,$36D0,$B710,$37D0
loc_30BAE:
		dc.w	$5
		dc.w	$3810,$2850,$7880,$7900,$980
loc_30BBA:
		dc.w	$5
		dc.w	$5990,$19F0,$7A10,$7A90,$B10
loc_30BC6:
		dc.w	$6
		dc.w	$B20,$7B30,$BB0,$1BC0,$7BE0,$5C60
loc_30BD4:
		dc.w	$3
		dc.w	$5000,$60,$F070
loc_30BDC:
		dc.w	$3
		dc.w	$5170,$31D0,$B210
loc_30BE4:
		dc.w	$3
		dc.w	$22D0,$2300,$F330
loc_30BEC:
		dc.w	$3
		dc.w	$5430,$3490,$B210
loc_30BF4:
		dc.w	$2
		dc.w	$7000,$1080
loc_30BFA:
		dc.w	$2
		dc.w	$70A0,$1080
loc_30C00:
		dc.w	$3
		dc.w	$8000,$5090,$F0
loc_30C08:
		dc.w	$4
		dc.w	$3100,$5140,$31A0,$31E0
loc_30C12:
		dc.w	$4
		dc.w	$3220,$5260,$32C0,$3300
loc_30C1C:
		dc.w	$5
		dc.w	$3100,$5140,$3340,$3380,$3C0
loc_30C28:
		dc.w	$3
		dc.w	$3000,$7040,$70C0
loc_30C30:
		dc.w	$4
		dc.w	$1140,$7160,$81E0,$1270
loc_30C3A:
		dc.w	$5
		dc.w	$290,$22A0,$72D0,$350,$5360
loc_30C46:
		dc.w	$4
		dc.w	$3C0,$F3D0,$4D0,$14E0
loc_30C50:
		dc.w	$4
		dc.w	$3500,$3540,$7580,$5600
loc_30C5A:
		dc.w	$5
		dc.w	$660,$7670,$6F0,$7700,$1780
loc_30C66:
		dc.w	$5
		dc.w	$7A0,$B7B0,$870,$3880,$18C0
loc_30C72:
		dc.w	$4
		dc.w	$8E0,$B8F0,$9B0,$79C0
loc_30C7C:
		dc.w	$2
		dc.w	$8000,$7090
loc_30C82:
		dc.w	$3
		dc.w	$3110,$150,$B160
loc_30C8A:
		dc.w	$2
		dc.w	$1220,$F240
loc_30C90:
		dc.w	$3
		dc.w	$2340,$2370,$B160
loc_30C98:
		dc.w	$1
		dc.w	$7000
loc_30C9C:
		dc.w	$1
		dc.w	$7080
loc_30CA0:
		dc.w	$5000
loc_30CA2:
		dc.w	$8060
loc_30CA4:
		dc.w	$50F0
loc_30CA6:
		dc.w	$5150
loc_30CA8:
		dc.w	$71B0
loc_30CAA:
		dc.w	$8230
loc_30CAC:
		dc.w	$82C0
loc_30CAE:
		dc.w	$8000
loc_30CB0:
		dc.w	$5090
loc_30CB2:
		dc.w	$50F0
loc_30CB4:
		dc.w	$7150
loc_30CB6:
		dc.w	$B1D0
loc_30CB8:
		dc.w	$8290
loc_30CBA:
		dc.w	$8320
loc_30CBC:
		dc.w	$5000
loc_30CBE:
		dc.w	$8060
loc_30CC0:
		dc.w	$50F0
loc_30CC2:
		dc.w	$5150
loc_30CC4:
		dc.w	$71B0
loc_30CC6:
		dc.w	$8230
loc_30CC8:
		dc.w	$82C0
		dc.w	$0 ; Filler
loc_30CCC:
		jmp	DisplaySprite 
loc_30CD2:
		jmp	(loc_7B8A) 
;------------------------------------------------------------------------------- 
Obj_0x10_Miles_In_Special_Stage: 
		include 'objects/obj_0x10.asm'
Obj_0x88: 
		include 'objects/obj_0x88.asm'
;------------------------------------------------------------------------------- 
loc_31318:
		jmp	DisplaySprite 
loc_3131E:
		jmp	AnimateSprite 
;------------------------------------------------------------------------------- 
Obj_0x61_SS_Bomb: 
		include 'objects/obj_0x61.asm'
;------------------------------------------------------------------------------- 
Obj_0x60_SS_Rings: 
		include 'objects/obj_0x60.asm'
;------------------------------------------------------------------------------- 
loc_3185A:
		dc.b	$38,$48,$2A,$56,$1C,$64,$E,$72,$0,$80 
loc_31864:
		dc.b	$40,$30,$50,$20,$60,$10,$70,$0,$80,$0 
Obj_0x5B: 
		include 'objects/obj_0x5B.asm'
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_319A4:
		move.w	loc_319B8(pc,d0),($FFFFFB76).w
		move.w	loc_319BA(pc,d0),($FFFFFB78).w
		move.w	loc_319BC(pc,d0),($FFFFFB7A).w
		rts
;--------------------------------------------------------------------------------
loc_319B8:
		dc.w	$EE
loc_319BA:
		dc.w	$88
loc_319BC:
		dc.w	$44,$EE,$CC,$88 
;------------------------------------------------------------------------------- 
Obj_0x5A_SS_Rings_Check: 
		include 'objects/obj_0x5A.asm'
;===============================================================================
; Sub Routine - loc_31DD6 - Special Stage
; [ Begin ]
;=============================================================================== 
loc_31DD6:
		bsr.w	loc_32776
		bne.s	loc_31E12
		move.b	d0,$1A(a1)
		move.l	#loc_7E76,4(a1)
		move.w	#$41FA,2(a1)
		move.b	#$5A,(a1)
		move.b	#4,$24(a1)
		move.b	#4,1(a1)
		move.b	#1,$18(a1)
		move.w	d1,8(a1)
		move.w	d2,$C(a1)
		move.w	#$3C,$2A(a1)
loc_31E12:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine - loc_31DD6 - Special Stage
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine - loc_31E14 - Special Stage
; [ Begin ]
;=============================================================================== 
loc_31E14:
		lea	loc_31E62(pc),a3
		add.w	0(a3,d0),a3
loc_31E1C: 
		move.b	(a3)+,d0
		bmi.s	loc_31E60
		bsr.w	loc_32776
		bne.s	loc_31E60
		move.b	d0,$1A(a1)
		move.l	#loc_31FF2,4(a1)
		move.w	#$41A2,2(a1)
		move.b	#$5A,(a1)
		move.b	#4,$24(a1)
		move.b	#4,1(a1)
		move.b	#1,$18(a1)
		move.w	d1,8(a1)
		move.w	d2,$C(a1)
		move.w	#$3C,$2A(a1)
		addq.w	#8,d1
		bra.s	loc_31E1C
loc_31E60:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_31E62:
		dc.w	loc_31E84-loc_31E62
		dc.w	loc_31E88-loc_31E62
		dc.w	loc_31E8E-loc_31E62
		dc.w	loc_31E94-loc_31E62
		dc.w	loc_31E98-loc_31E62
		dc.w	loc_31E9F-loc_31E62
		dc.w	loc_31EA6-loc_31E62
		dc.w	loc_31EAB-loc_31E62
		dc.w	loc_31EB1-loc_31E62
		dc.w	loc_31EB7-loc_31E62
		dc.w	loc_31EBD-loc_31E62
		dc.w	loc_31EC1-loc_31E62
		dc.w	loc_31EC5-loc_31E62
		dc.w	loc_31ECB-loc_31E62
		dc.w	loc_31ED0-loc_31E62
		dc.w	loc_31ED2-loc_31E62
		dc.w	loc_31ED6-loc_31E62
loc_31E84:
		dc.b	$0,$1,$2,$FF
loc_31E88:
		dc.b	$3,$4,$5,$0,$6,$FF
loc_31E8E:
		dc.b	$7,$8,$8,$9,$11,$FF
loc_31E94:
		dc.b	$5,$8,$2,$FF
loc_31E98:
		dc.b	$1,$5,$8,$A,$0,$B,$FF
loc_31E9F:
		dc.b	$C,$9,$D,$E,$1,$3,$FF
loc_31EA6:
		dc.b	$F,$8,$6,$2,$FF
loc_31EAB:
		dc.b	$10,$4,$5,$6,$11,$FF
loc_31EB1:
		dc.b	$6,$8,$5,$4,$7,$FF
loc_31EB7:
		dc.b	$F,$4,$9,$1,$6,$FF
loc_31EBD:
		dc.b	$2,$4,$1,$FF
loc_31EC1:
		dc.b	$10,$4,$5,$FF
loc_31EC5:
		dc.b	$2,$10,$4,$7,$1,$FF
loc_31ECB:
		dc.b	$D,$9,$9,$11,$FF
loc_31ED0:
		dc.b	$11,$FF
loc_31ED2:
		dc.b	$12,$12,$12,$FF
loc_31ED6:
		dc.b	$13,$FF 
;===============================================================================
; Sub Routine - loc_31E14 - Special Stage
; [ End ]
;===============================================================================
		 
;===============================================================================
; Sub Routine - loc_31ED8 - Special Stage
; [ Begin ]
;=============================================================================== 
loc_31ED8: ; Called by Special Stage Obj_0x5F
		moveq	#0,d0
		move.w	#$54,d1
		move.w	#$48,d2
		bsr.w	loc_31E14
		bsr.w	loc_3275E
		move.w	d1,d4
		move.w	d2,d5
		move.w	d2,a3
		move.w	#$80,d1
		cmp.w	#2,d2
		beq.s	loc_31EFE
		sub.w	#8,d1
loc_31EFE:
		move.w	#$48,d2
loc_31F02: 
		move.w	d4,d6
		lsr.w	#4,d4
		and.w	#$F,d6
		move.b	d6,d0
		swap.w	d5
		bsr.w	loc_31DD6
		sub.w	#8,d1
		swap.w	d5
		dbra	d5,loc_31F02
		moveq	#2,d0
		lea	(loc_31FBE),a2
		add.w	0(a2,d0),a2
		move.w	#$48,d2
		move.w	#$84,d1
		cmp.w	#2,a3
		bne.s	loc_31F3A
		add.w	#8,d1
loc_31F3A:
		moveq	#0,d0
		move.b	(a2)+,d0
		bmi.s	loc_31F46
		bsr.w	loc_31E14
		bra.s	loc_31F3A
loc_31F46:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine - loc_31ED8 - Special Stage
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine - loc_31F48 - Special Stage
; [ Begin ]
;=============================================================================== 
loc_31F48:
		move.w	#$80,d3
		bsr.w	loc_31CB6
loc_31F50: ; Called by Object 0x59 
		move.w	#$74,d1
		move.w	#$68,d2
		lea	(loc_31FBE),a2
		add.w	0(a2,d0),a2
		cmp.b	#4,d0
		beq.s	loc_31F6C
		move.w	#$5E,d1
loc_31F6C:
		moveq	#0,d0
		move.b	(a2)+,d0
		bmi.s	loc_31F8A
		cmp.b	#2,d0
		bne.s	loc_31F80
		move.w	#$5E,d1
		move.w	#$7E,d2
loc_31F80:
		bsr.w	loc_31E14
		add.w	#8,d1
		bra.s	loc_31F6C
loc_31F8A:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine - loc_31F48 - Special Stage
; [ End ]
;=============================================================================== 
 
;===============================================================================
; Sub Routine - loc_31F8C - Special Stage
; [ Begin ]
;=============================================================================== 
loc_31F8C: ; Called by Special Stage Obj_0x5F 
		move.w	d0,d3
		subq.w	#8,d3
		lsr.w	#1,d3
		moveq	#0,d1
		move.b	loc_31FB8(pc,d3),d1
		move.w	#$48,d2
		lea	(loc_31FBE),a2
		add.w	0(a2,d0),a2
loc_31FA6: 
		moveq	#0,d0
		move.b	(a2)+,d0
		bmi.s	loc_31FB6
		bsr.w	loc_31E14
		add.w	#8,d1
		bra.s	loc_31FA6
loc_31FB6:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_31FB8:
		dc.w	$4444,$5858,$743C
;------------------------------------------------------------------------------- 
loc_31FBE:
		dc.w	loc_31FD2-loc_31FBE
		dc.w	loc_31FD3-loc_31FBE
		dc.w	loc_31FD6-loc_31FBE
		dc.w	loc_31FD8-loc_31FBE
		dc.w	loc_31FDD-loc_31FBE
		dc.w	loc_31FE1-loc_31FBE
		dc.w	loc_31FE5-loc_31FBE
		dc.w	loc_31FE8-loc_31FBE
		dc.w	loc_31FEB-loc_31FBE
		dc.w	loc_31FED-loc_31FBE
loc_31FD2:
		dc.b	$FF
loc_31FD3:
		dc.b	$2,$1C,$FF
loc_31FD6:
		dc.b	$4,$FF
loc_31FD8:
		dc.b	$6,$8,$2,$1E,$FF
loc_31FDD:
		dc.b	$A,$20,$A,$FF
loc_31FE1:
		dc.b	$C,$2,$E,$FF
loc_31FE5:
		dc.b	$10,$E,$FF
loc_31FE8:
		dc.b	$12,$E,$FF
loc_31FEB:
		dc.b	$14,$FF
loc_31FED:
		dc.b	$16,$18,$16,$1A,$FF 
;-------------------------------------------------------------------------------
loc_31FF2:
		dc.w	loc_3201E-loc_31FF2
		dc.w	loc_32028-loc_31FF2
		dc.w	loc_32032-loc_31FF2
		dc.w	loc_3203C-loc_31FF2
		dc.w	loc_32046-loc_31FF2
		dc.w	loc_32050-loc_31FF2
		dc.w	loc_3205A-loc_31FF2
		dc.w	loc_32064-loc_31FF2
		dc.w	loc_3206E-loc_31FF2
		dc.w	loc_32078-loc_31FF2
		dc.w	loc_32082-loc_31FF2
		dc.w	loc_3208C-loc_31FF2
		dc.w	loc_32096-loc_31FF2
		dc.w	loc_320A0-loc_31FF2
		dc.w	loc_320AA-loc_31FF2
		dc.w	loc_320B4-loc_31FF2
		dc.w	loc_320BE-loc_31FF2
		dc.w	loc_320C8-loc_31FF2
		dc.w	loc_320D2-loc_31FF2
		dc.w	loc_320DC-loc_31FF2
		dc.w	loc_320E6-loc_31FF2
		dc.w	loc_32128-loc_31FF2
loc_3201E:
		dc.w	$1
		dc.l	$F8018004,$8002FFFC
loc_32028:
		dc.w	$1
		dc.l	$F8018002,$8001FFFC
loc_32032:
		dc.w	$1
		dc.l	$F8018014,$800AFFFC
loc_3203C:
		dc.w	$1
		dc.l	$F8018010,$8008FFFC
loc_32046:
		dc.w	$1
		dc.l	$F8018008,$8004FFFC
loc_32050:
		dc.w	$1
		dc.l	$F801800C,$8006FFFC
loc_3205A:
		dc.w	$1
		dc.l	$F8018012,$8009FFFC
loc_32064:
		dc.w	$1
		dc.l	$F8018000,$8000FFFC
loc_3206E:
		dc.w	$1
		dc.l	$F801806A,$8035FFFC
loc_32078:
		dc.w	$1
		dc.l	$F801800A,$8005FFFC
loc_32082:
		dc.w	$1
		dc.l	$F8018016,$800BFFFC
loc_3208C:
		dc.w	$1
		dc.l	$F8018006,$8003FFFC
loc_32096:
		dc.w	$1
		dc.l	$F801823D,$811EFFFC
loc_320A0:
		dc.w	$1
		dc.l	$F801823F,$811FFFFC
loc_320AA:
		dc.w	$1
		dc.l	$F8018241,$8120FFFC
loc_320B4:
		dc.w	$1
		dc.l	$F8018243,$8121FFFC
loc_320BE:
		dc.w	$1
		dc.l	$F8018245,$8122FFFC
loc_320C8:
		dc.w	$1
		dc.l	$F8018018,$800CFFFC
loc_320D2:
		dc.w	$1
		dc.l	$F801800E,$8007FFFC
loc_320DC:
		dc.w	$1
		dc.l	$FC048247,$8123FFF8
loc_320E6:
		dc.w	$8
		dc.l	$E403801A,$800DFFD0,$EC0F801E,$800FFFD8
		dc.l	$EC03802E,$8017FFF8,$C0D8032,$8019FFE0
		dc.l	$EC03882E,$88170000,$C0D8832,$88190000
		dc.l	$EC0F881E,$880F0008,$E403881A,$880D0028
loc_32128:
		dc.w	$4
		dc.l	$F00B803A,$801DFFE8,$10088046,$8023FFE8
		dc.l	$A8049,$80240000,$E8068052,$80290000 
;===============================================================================
; Sub Routine - loc_3214A - Special Stage
; [ Begin ]
;=============================================================================== 
loc_3214A: ; Called by Object 0x59
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		move.w	loc_32166(pc,d0),($FFFFFB76).w
		move.w	loc_32168(pc,d0),($FFFFFB78).w
		move.w	loc_3216A(pc,d0),($FFFFFB7A).w
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_32166:
		dc.w	$EA
loc_32168:
		dc.w	$C6
loc_3216A:
		dc.w	$82
;===============================================================================
; Sub Routine - loc_3214A - Special Stage
; [ End ]
;=============================================================================== 
Unk_loc_3216C:
		dc.w	$AEE,$CE,$8A,$A6E,$E,$A,$EAE,$E6E
		dc.w	$E4E,$E6A,$C08,$806,$EE8,$EC0,$E80,$CCC
		dc.w	$AAA,$888
;------------------------------------------------------------------------------- 
Obj_0x59_SS_Emerald_Rings_Check: 
 include 'objects/obj_0x59.asm'
;------------------------------------------------------------------------------- 
loc_3247A:
		dc.w	loc_32490-loc_3247A
		dc.w	loc_32496-loc_3247A
		dc.w	loc_3249C-loc_3247A
		dc.w	loc_324A2-loc_3247A
		dc.w	loc_324A8-loc_3247A
		dc.w	loc_324AE-loc_3247A
		dc.w	loc_324B4-loc_3247A
		dc.w	loc_324BA-loc_3247A
		dc.w	loc_324C0-loc_3247A
		dc.w	loc_324C6-loc_3247A
		dc.w	loc_324CC-loc_3247A
loc_32490:
		dc.b	$5,$0,$A,$14,$A,$FF
loc_32496:
		dc.b	$5,$1,$B,$15,$B,$FF
loc_3249C:
		dc.b	$5,$2,$C,$16,$C,$FF
loc_324A2:
		dc.b	$5,$3,$D,$17,$D,$FF
loc_324A8:
		dc.b	$5,$4,$E,$18,$E,$FF
loc_324AE:
		dc.b	$5,$5,$F,$19,$F,$FF
loc_324B4:
		dc.b	$5,$6,$10,$1A,$10,$FF
loc_324BA:
		dc.b	$5,$7,$11,$1B,$11,$FF
loc_324C0:
		dc.b	$5,$8,$12,$1C,$12,$FF
loc_324C6:
		dc.b	$5,$9,$13,$1D,$13,$FF
loc_324CC:
		dc.b	$1,$1E,$1F,$20,$FF,$0
;-------------------------------------------------------------------------------
loc_324D2:
		dc.w	loc_32514-loc_324D2
		dc.w	loc_3251E-loc_324D2
		dc.w	loc_32528-loc_324D2
		dc.w	loc_32532-loc_324D2
		dc.w	loc_3253C-loc_324D2
		dc.w	loc_32546-loc_324D2
		dc.w	loc_32550-loc_324D2
		dc.w	loc_3255A-loc_324D2
		dc.w	loc_32564-loc_324D2
		dc.w	loc_3256E-loc_324D2
		dc.w	loc_32578-loc_324D2
		dc.w	loc_32582-loc_324D2
		dc.w	loc_3258C-loc_324D2
		dc.w	loc_32596-loc_324D2
		dc.w	loc_325A0-loc_324D2
		dc.w	loc_325AA-loc_324D2
		dc.w	loc_325B4-loc_324D2
		dc.w	loc_325BE-loc_324D2
		dc.w	loc_325C8-loc_324D2
		dc.w	loc_325D2-loc_324D2
		dc.w	loc_325DC-loc_324D2
		dc.w	loc_325E6-loc_324D2
		dc.w	loc_325F0-loc_324D2
		dc.w	loc_325FA-loc_324D2
		dc.w	loc_32604-loc_324D2
		dc.w	loc_3260E-loc_324D2
		dc.w	loc_32618-loc_324D2
		dc.w	loc_32622-loc_324D2
		dc.w	loc_3262C-loc_324D2
		dc.w	loc_32636-loc_324D2
		dc.w	loc_32640-loc_324D2
		dc.w	loc_32652-loc_324D2
		dc.w	loc_32664-loc_324D2
loc_32514:
		dc.w	$1
		dc.l	$FC008000,$8000FFFC
loc_3251E:
		dc.w	$1
		dc.l	$FC008001,$8000FFFC
loc_32528:
		dc.w	$1
		dc.l	$FC008002,$8001FFFC
loc_32532:
		dc.w	$1
		dc.l	$F8058003,$8001FFF8
loc_3253C:
		dc.w	$1
		dc.l	$F8058007,$8003FFF8
loc_32546:
		dc.w	$1
		dc.l	$F805800B,$8005FFF8
loc_32550:
		dc.w	$1
		dc.l	$F805800F,$8007FFF8
loc_3255A:
		dc.w	$1
		dc.l	$F40A8013,$8009FFF4
loc_32564:
		dc.w	$1
		dc.l	$F40A801C,$800EFFF4
loc_3256E:
		dc.w	$1
		dc.l	$F40A8025,$8012FFF4
loc_32578:
		dc.w	$1
		dc.l	$FC00802E,$8017FFFC
loc_32582:
		dc.w	$1
		dc.l	$FC00802F,$8017FFFC
loc_3258C:
		dc.w	$1
		dc.l	$FC008030,$8018FFFC
loc_32596:
		dc.w	$1
		dc.l	$F8018031,$8018FFFC
loc_325A0:
		dc.w	$1
		dc.l	$F8058033,$8019FFF8
loc_325AA:
		dc.w	$1
		dc.l	$F8058037,$801BFFF8
loc_325B4:
		dc.w	$1
		dc.l	$F805803B,$801DFFF8
loc_325BE:
		dc.w	$1
		dc.l	$F406803F,$801FFFF8
loc_325C8:
		dc.w	$1
		dc.l	$F4068045,$8022FFF8
loc_325D2:
		dc.w	$1
		dc.l	$F40A804B,$8025FFF4
loc_325DC:
		dc.w	$1
		dc.l	$FC008054,$802AFFFC
loc_325E6:
		dc.w	$1
		dc.l	$FC008055,$802AFFFC
loc_325F0:
		dc.w	$1
		dc.l	$FC008056,$802BFFFC
loc_325FA:
		dc.w	$1
		dc.l	$F8018057,$802BFFFC
loc_32604:
		dc.w	$1
		dc.l	$F8018059,$802CFFFC
loc_3260E:
		dc.w	$1
		dc.l	$F801805B,$802DFFFC
loc_32618:
		dc.w	$1
		dc.l	$F801805D,$802EFFFC
loc_32622:
		dc.w	$1
		dc.l	$F402805F,$802FFFFC
loc_3262C:
		dc.w	$1
		dc.l	$F4028062,$8031FFFC
loc_32636:
		dc.w	$1
		dc.l	$F4028065,$8032FFFC
loc_32640:
		dc.w	$2
		dc.l	$F0078000,$8000FFF0,$F8058008,$80040000
loc_32652:
		dc.w	$2
		dc.l	$F00E800C,$8006FFF0,$8008018,$800CFFF8
loc_32664:
		dc.w	$2
		dc.l	$F0028019,$800CFFF0,$F80A801C,$800EFFF8 
;------------------------------------------------------------------------------- 
loc_32676:
		dc.w	loc_3268C-loc_32676
		dc.w	loc_3268F-loc_32676
		dc.w	loc_32692-loc_32676
		dc.w	loc_32695-loc_32676
		dc.w	loc_32698-loc_32676
		dc.w	loc_3269B-loc_32676
		dc.w	loc_3269E-loc_32676
		dc.w	loc_326A1-loc_32676
		dc.w	loc_326A4-loc_32676
		dc.w	loc_326A7-loc_32676
		dc.w	loc_326AA-loc_32676
loc_3268C:
		dc.b	$B,$0,$FF
loc_3268F:
		dc.b	$B,$1,$FF
loc_32692:
		dc.b	$B,$2,$FF
loc_32695:
		dc.b	$B,$3,$FF
loc_32698:
		dc.b	$B,$4,$FF
loc_3269B:
		dc.b	$B,$5,$FF
loc_3269E:
		dc.b	$B,$6,$FF
loc_326A1:
		dc.b	$B,$7,$FF
loc_326A4:
		dc.b	$B,$8,$FF
loc_326A7:
		dc.b	$B,$9,$FF
loc_326AA:
		dc.b	$2,$A,$B,$C,$FF,$0
;------------------------------------------------------------------------------- 
loc_326B0:
		dc.w	loc_326CA-loc_326B0
		dc.w	loc_326D4-loc_326B0
		dc.w	loc_326DE-loc_326B0
		dc.w	loc_326E8-loc_326B0
		dc.w	loc_326F2-loc_326B0
		dc.w	loc_326FC-loc_326B0
		dc.w	loc_32706-loc_326B0
		dc.w	loc_32710-loc_326B0
		dc.w	loc_3271A-loc_326B0
		dc.w	loc_32724-loc_326B0
		dc.w	loc_3272E-loc_326B0
		dc.w	loc_32738-loc_326B0
		dc.w	loc_32742-loc_326B0
loc_326CA:
		dc.w	$1
		dc.l	$FC008000,$8000FFFC
loc_326D4:
		dc.w	$1
		dc.l	$FC008001,$8000FFFC
loc_326DE:
		dc.w	$1
		dc.l	$F8058002,$8001FFF8
loc_326E8:
		dc.w	$1
		dc.l	$F8058006,$8003FFF8
loc_326F2:
		dc.w	$1
		dc.l	$F805800A,$8005FFF8
loc_326FC:
		dc.w	$1
		dc.l	$F40A800E,$8007FFF4
loc_32706:
		dc.w	$1
		dc.l	$F40A8017,$800BFFF4
loc_32710:
		dc.w	$1
		dc.l	$F00F8020,$8010FFF0
loc_3271A:
		dc.w	$1
		dc.l	$F00F8030,$8018FFF0
loc_32724:
		dc.w	$1
		dc.l	$F00F8040,$8020FFF0
loc_3272E:
		dc.w	$1
		dc.l	$F00F8000,$8000FFF0
loc_32738:
		dc.w	$1
		dc.l	$F00F8010,$8008FFF0
loc_32742:
		dc.w	$1
		dc.l	$F00F8020,$8010FFF0 
;------------------------------------------------------------------------------- 
loc_3274C:
		jmp	DisplaySprite 
loc_32752:
		jmp	DeleteObject 
loc_32758:
		jmp	AnimateSprite 
loc_3275E:
		jmp	(loc_8248)
loc_32764:
		jmp	CalcAngle 
loc_3276A:
		jmp	CalcSine 
loc_32770:
		jmp	ObjectFall 
loc_32776:
		jmp	(loc_7BA0)
loc_3277C:
		jmp	(loc_7B8A)
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
		
;===============================================================================
; Sub Routine - loc_31F8C - Special Stage
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine - Enemy Settings
; [ Begin ]
;=============================================================================== 
EnemySettings: 
		moveq	#0,d0
		move.b	$28(a0),d0
EnemySettings_01: 
		move.w	loc_327B8(pc,d0),d0
		lea	loc_327B8(pc,d0),a1
EnemySettings_02: 
		move.l	(a1)+,4(a0)
		move.w	(a1)+,2(a0)
		jsr	ModifySpriteAttr_2P 
		move.b	(a1)+,d0
		or.b	d0,1(a0)
		move.b	(a1)+,$18(a0)
		move.b	(a1)+,$19(a0)
		move.b	(a1),$20(a0)
		addq.b	#2,$24(a0)
		rts
;--------------------------------------------------------------------------------
loc_327B8:
		dc.w	Obj_0x8C_Ptr-loc_327B8 
		dc.w	Obj_0x8E_Ptr-loc_327B8 
		dc.w	Obj_0x8F_Ptr-loc_327B8 
		dc.w	Obj_0x90_Ptr-loc_327B8 
		dc.w	Obj_0x91_Ptr-loc_327B8 
		dc.w	Obj_0x92_Ptr-loc_327B8 
		dc.w	Obj_0x96_Rexon_Body-loc_327B8 
		dc.w	Obj_0x96_Ptr-loc_327B8 
		dc.w	Obj_0x97_Rexon_Fireball-loc_327B8 
		dc.w	Obj_0x99_Ptr-loc_327B8 
		dc.w	Obj_0x98_Nebula_Spikeball-loc_327B8 
		dc.w	Obj_0x9A_Ptr-loc_327B8 
		dc.w	Obj_0x9B_Ptr-loc_327B8 
		dc.w	Obj_0x9C_Ptr-loc_327B8 
		dc.w	Obj_0x98_Turtloid_Bullet-loc_327B8 
		dc.w	Obj_0x9D_Ptr-loc_327B8 
		dc.w	Obj_0x98_Coconuts_Coconut_Ptr-loc_327B8 
		dc.w	Obj_0x9E_Ptr-loc_327B8 
		dc.w	Obj_0x9F_Ptr-loc_327B8 
		dc.w	Obj_0xA0_Ptr-loc_327B8 
		dc.w	Obj_0xA1_Ptr-loc_327B8 
		dc.w	Obj_0xA2_Ptr-loc_327B8 
		dc.w	Obj_0xA3_Ptr-loc_327B8 
		dc.w	Obj_0xA4_Ptr-loc_327B8 
		dc.w	Obj_0x98_Asteron_Spikes_Ptr-loc_327B8 
		dc.w	Obj_0xA5_Ptr-loc_327B8 
		dc.w	Obj_0x98_Lander_Bomb_Ptr-loc_327B8 
		dc.w	Obj_0xA7_Ptr-loc_327B8 
		dc.w	Obj_0xA8_Ptr-loc_327B8 
		dc.w	Obj_0xA9_Ptr-loc_327B8 
		dc.w	Obj_0xAA_Ptr-loc_327B8 
		dc.w	Obj_0x98_Grabber_Unk_Ptr-loc_327B8 
		dc.w	Obj_0xAC_Ptr-loc_327B8 
		dc.w	Obj_0xAD_Ptr-loc_327B8 
		dc.w	Obj_0xAE_Ptr-loc_327B8 
		dc.w	Obj_0x98_Clucker_Eggs_Ptr-loc_327B8 
		dc.w	Obj_0xAF_Ptr-loc_327B8 
		dc.w	Obj_0xAF_Metal_Sonic_Spikes_Ptr-loc_327B8 
		dc.w	Obj_0xB0_Ptr-loc_327B8 
		dc.w	Obj_0xB1_Ptr-loc_327B8 
		dc.w	Obj_0xB2_Ptr-loc_327B8 
		dc.w	Obj_0xB2_Ptr-loc_327B8 
		dc.w	Obj_0xB2_Ptr-loc_327B8 
		dc.w	Obj_0xBC_Ptr-loc_327B8 
		dc.w	Obj_0xBC_Ptr-loc_327B8 
		dc.w	Obj_0xB3_Ptr-loc_327B8 
		dc.w	Obj_0xB2_01_Ptr-loc_327B8 
		dc.w	Obj_0xB3_Ptr-loc_327B8 
		dc.w	Obj_0xB3_Ptr-loc_327B8 
		dc.w	Obj_0xB3_Ptr-loc_327B8 
		dc.w	Obj_0xB4_Ptr-loc_327B8 
		dc.w	Obj_0xB5_Ptr-loc_327B8 
		dc.w	Obj_0xB5_Ptr-loc_327B8 
		dc.w	Obj_0xB6_Ptr-loc_327B8 
		dc.w	Obj_0xB6_Ptr-loc_327B8 
		dc.w	Obj_0xB6_Ptr-loc_327B8 
		dc.w	Obj_0xB6_Ptr-loc_327B8 
		dc.w	Obj_0xB7_Ptr-loc_327B8 
		dc.w	Obj_0xB8_Ptr-loc_327B8 
		dc.w	Obj_0xB9_Ptr-loc_327B8 
		dc.w	Obj_0xBA_Ptr-loc_327B8 
		dc.w	Obj_0xBB_Ptr-loc_327B8 
		dc.w	Obj_0xBC_Ptr-loc_327B8 
		dc.w	Obj_0xBD_Ptr-loc_327B8 
		dc.w	Obj_0xBD_Ptr-loc_327B8 
		dc.w	Obj_0xBE_Ptr-loc_327B8 
		dc.w	Obj_0xBF_Ptr-loc_327B8 
		dc.w	Obj_0xC0_Ptr-loc_327B8 
		dc.w	Obj_0xC1_Ptr-loc_327B8 
		dc.w	Obj_0xC2_Ptr-loc_327B8 
		dc.w	Obj_0xC3-loc_327B8 
		dc.w	Obj_0x98_Canon_Fireball_Ptr-loc_327B8 
		dc.w	Obj_0xC3_Ptr-loc_327B8 
		dc.w	Obj_0xC5_Ptr-loc_327B8 
		dc.w	Obj_0xC5_01_Ptr-loc_327B8 
		dc.w	Obj_0xC5_02_Ptr-loc_327B8 
		dc.w	Obj_0xC5_02_Ptr-loc_327B8 
		dc.w	Obj_0xC5_02_Ptr-loc_327B8 
		dc.w	Obj_0xC5_02_Ptr-loc_327B8 
		dc.w	Obj_0xC5_02_Ptr-loc_327B8 
		dc.w	Obj_0xC5_03_Ptr-loc_327B8 
		dc.w	Obj_0xC5_04_Ptr-loc_327B8 
		dc.w	Obj_0xAF_01_Ptr-loc_327B8 
		dc.w	loc_38F96-loc_327B8
		dc.w	loc_38FA0-loc_327B8
		dc.w	loc_38FAA-loc_327B8
		dc.w	Obj_0xC8_Ptr-loc_327B8 
;------------------------------------------------------------------------------- 
loc_32866:
		moveq	#0,d0
		moveq	#0,d1
		lea	(Object_RAM).w,a1
		move.w	8(a0),d2
		sub.w	8(a1),d2
		move.w	d2,d4
		bpl.s	loc_3287C
		neg.w	d4
loc_3287C:
		lea	($FFFFB040).w,a2
		move.w	8(a0),d3
		sub.w	8(a2),d3
		move.w	d3,d5
		bpl.s	loc_3288E
		neg.w	d5
loc_3288E:
		cmp.w	d5,d4
		bls.s	loc_32896
		move.l	a2,a1
		move.w	d3,d2
loc_32896:
		tst.w	d2
		bpl.s	loc_3289C
		addq.w	#2,d0
loc_3289C:
		move.w	$C(a0),d3
		sub.w	$C(a1),d3
		bcc.s	loc_328A8
		addq.w	#2,d1
loc_328A8:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_328AA:
		move.w	d4,d5
		add.w	d5,d5
		btst	#0,($FFFFFE0F).w
		bne.s	loc_328EE
		moveq	#0,d0
		moveq	#0,d1
		lea	(Object_RAM).w,a1
		move.w	8(a0),d2
		sub.w	8(a1),d2
		bcc.s	loc_328CA
		addq.w	#2,d0
loc_328CA:
		move.w	$C(a0),d3
		sub.w	$C(a1),d3
		bcc.s	loc_328D6
		addq.w	#2,d1
loc_328D6:
		move.w	d2,d6
		add.w	d4,d2
		cmp.w	d5,d2
		bcc.s	loc_32926
		move.w	d6,d2
		move.w	d3,d6
		add.w	d4,d3
		cmp.w	d5,d3
		bcc.s	loc_32926
		move.w	d6,d3
		bra.w	loc_32922
loc_328EE:
		moveq	#0,d0
		moveq	#0,d1
		lea	($FFFFB040).w,a1
		move.w	8(a0),d2
		sub.w	8(a1),d2
		bcc.s	loc_32902
		addq.w	#2,d0
loc_32902:
		move.w	$C(a0),d3
		sub.w	$C(a1),d3
		bcc.s	loc_3290E
		addq.w	#2,d1
loc_3290E:
		move.w	d2,d6
		add.w	d4,d2
		cmp.w	d5,d2
		bcc.s	loc_32926
		move.w	d6,d2
		move.w	d3,d6
		add.w	d4,d3
		cmp.w	d5,d3
		bcc.s	loc_32926
		move.w	d6,d3
loc_32922:
		moveq	#1,d4
		rts
;--------------------------------------------------------------------------------
loc_32926:
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_3292A:
		move.w	$10(a0),d2
		bpl.s	loc_3293C
		neg.w	d0
		cmp.w	d0,d2
		bcc.s	loc_32942
		move.w	d0,d2
		bra.w	loc_32942
loc_3293C:
		cmp.w	d0,d2
		bls.s	loc_32942
		move.w	d0,d2
loc_32942:
		move.w	$12(a0),d3
		bpl.s	loc_32954
		neg.w	d1
		cmp.w	d1,d3
		bcc.s	loc_3295A
		move.w	d1,d3
		bra.w	loc_3295A
loc_32954:
		cmp.w	d1,d3
		bls.s	loc_3295A
		move.w	d1,d3
loc_3295A:
		move.w	d2,$10(a0)
		move.w	d3,$12(a0)
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_32964: ; Called by Object 0x97 - Rexon Sub Object
		moveq	#0,d0
		move.w	d0,$10(a0)
		move.w	d0,$12(a0)
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_32970:
		bsr.w	loc_3A8B6
		bne.s	loc_32994
		move.w	(a2)+,d0
		move.w	a1,0(a0,d0)
		move.b	(a2)+,0(a1)
		move.b	(a2)+,$28(a1)
		move.w	a0,$2C(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
loc_32994:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_32996: ; Called by Lander 
		move.w	8(a0),d2
		add.w	d0,d2
		move.w	d2,8(a1)
		move.w	$C(a0),d3
		add.w	d1,d3
		move.w	d3,$C(a1)
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_329AC:
		move.w	($FFFFF736).w,d0
		add.w	d0,8(a0)
		move.w	($FFFFF738).w,d0
		add.w	d0,$C(a0)
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_329BE: ; Called by Clouds ( Object 0xB3 )
		tst.w	($FFFFFFD8).w
		beq.s	loc_329C8
		bra.w	loc_3A892
loc_329C8:
		move.w	8(a0),d0
		and.w	#$FF80,d0
		sub.w	($FFFFF7DA).w,d0
		bmi loc_3A898
		bra.w	loc_3A892 
;-------------------------------------------------------------------------------
loc_329DC: ; Called by Grabber Sub 
		move.b	1(a0),d0
		and.b	#$FC,d0
		move.b	$22(a0),d2
		and.b	#$FC,d2
		move.b	1(a1),d1
		and.b	#3,d1
		or.b	d1,d0
		or.b	d1,d2
		move.b	d0,1(a0)
		move.b	d2,$22(a0)
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Unk_loc_32A02:
		bsr.w	loc_32866
		bclr	#0,1(a0)
		bclr	#0,$22(a0)
		tst.w	d0
		beq.s	loc_32A22
		bset	#0,1(a0)
		bset	#0,$22(a0)
loc_32A22:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Enemy_Weapon: 
		moveq	#0,d1
loc_32A26: 
		bsr.w	loc_3A8B6 
		bne.s	loc_32A76
		move.b	#$98,0(a1)
		move.b	d2,$28(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		lea	(SpeedToPos),a3 
		move.l	a3,$2A(a1)
		lea	0(a2,d1),a3
		move.b	(a3)+,d0
		ext.w	d0
		add.w	d0,8(a1)
		move.b	(a3)+,d0
		ext.w	d0
		add.w	d0,$C(a1)
		move.b	(a3)+,$10(a1)
		move.b	(a3)+,$12(a1)
		move.b	(a3)+,$1A(a1)
		move.b	(a3)+,1(a1)
		addq.w	#6,d1
		dbra	d6,loc_32A26
loc_32A76:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_32A78: ; Called by Metal Sonic
		moveq	#0,d0
		move.b	$1C(a0),d0
		cmp.b	$1D(a0),d0
		beq.s	loc_32A94
		move.b	d0,$1D(a0)
		move.b	#0,$1B(a0)
		move.b	#0,$1E(a0)
loc_32A94:
		subq.b	#1,$1E(a0)
		bpl.s	loc_32AB8
		add.w	d0,d0
		add.w	0(a1,d0),a1
		move.b	(a1),$1E(a0)
		moveq	#0,d1
		move.b	$1B(a0),d1
		move.b	1(a1,d1),d0
		bmi.s	loc_32ABC
loc_32AB0: 
		move.b	d0,$1A(a0)
		addq.b	#1,$1B(a0)
loc_32AB8:
		moveq	#0,d0
		rts
;--------------------------------------------------------------------------------
loc_32ABC:
		addq.b	#1,d0
		bne.s	loc_32AD0
		move.b	#0,$1B(a0)
		move.b	1(a1),d0
		bsr.s	loc_32AB0
		moveq	#1,d0
		rts
;--------------------------------------------------------------------------------
loc_32AD0:
		addq.b	#1,d0
		bne.s	loc_32AE6
		addq.b	#2,$24(a0)
		move.b	#0,$1E(a0)
		addq.b	#1,$1B(a0)
		moveq	#1,d0
		rts
;--------------------------------------------------------------------------------
loc_32AE6:
		addq.b	#1,d0
		bne.s	loc_32AF2
		addq.b	#2,$25(a0)
		moveq	#1,d0
		rts
;--------------------------------------------------------------------------------
loc_32AF2:
		addq.b	#1,d0
		bne.s	loc_32AFE
		move.b	#1,$1E(a0)
		moveq	#1,d0
loc_32AFE:
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_32B00:
		tst.w	($FFFFFFD8).w
		beq.s	loc_32B0A
		bra.w	loc_3A892
loc_32B0A:
		move.w	8(a0),d0
		and.w	#$FF80,d0
		sub.w	($FFFFF7DA).w,d0
		cmp.w	#$280,d0
		bhi loc_32B22
		bra.w	loc_3A892
loc_32B22:
		bra.w	loc_3A898 
;------------------------------------------------------------------------------- 
Obj_0x8C_NGHz_Whisp: 
		include 'objects/obj_0x8C.asm'
;===============================================================================
; Object 0x8D -> Hidden Grounder Neo Greo Green Hill
; [ Begin ]
;===============================================================================
Obj_0x8D_Hidden_Grounder: 
		; This object points to Obj_0x8E_Grounder
		; Next Object Is Obj_0x8E_Grounder
;===============================================================================
; Object 0x8D -> Hidden Grounder Neo Greo Green Hill
; [ End ]
;=============================================================================== 
Obj_0x8E_Grounder: 
		include 'objects/obj_0x8E.asm'
;------------------------------------------------------------------------------- 
Obj_0x8F_Wall_Hidden_Grounder: 
		include 'objects/obj_0x8F.asm'
;------------------------------------------------------------------------------- 
Obj_0x90_Rock_Hidden_Grounder: 
		include 'objects/obj_0x90.asm'
;------------------------------------------------------------------------------- 
Obj_0x91_Chop_Chop 
		include 'objects/obj_0x91.asm'
;------------------------------------------------------------------------------- 
Obj_0x92_Spiker: 
		include 'objects/obj_0x92.asm'
;------------------------------------------------------------------------------- 
Obj_0x93_Spiker_Spike_Fired: 
		include 'objects/obj_0x93.asm'
;------------------------------------------------------------------------------- 
Obj_0x95_Sol: 
		include 'objects/obj_0x95.asm'
;------------------------------------------------------------------------------- 

;===============================================================================
; Object 0x94 -> Rexon Body - Hill Top
; [ Begin ]
;===============================================================================
Obj_0x94_Rexon_Body: 
		; This object points to Obj_0x96_Rexon_Body
		; Next Object Is Obj_0x96_Rexon_Body
;===============================================================================
; Object 0x94 -> Rexon Body - Hill Top
; [ End ]
;=============================================================================== 
Obj_0x96_Rexon_Body: 
		include 'objects/obj_0x96.asm'
;------------------------------------------------------------------------------- 
Obj_0x97_Rexon_Head: 
		include 'objects/obj_0x97.asm'
;-------------------------------------------------------------------------------
Obj_0x98_Enemies_Weapons: 
		include 'objects/obj_0x98.asm'
;------------------------------------------------------------------------------- 
loc_338FA: ; Called by Nebula
		bchg	#5,2(a0)
		bra.w	loc_3A8FE
;------------------------------------------------------------------------------- 
loc_33904: ; Called by Turtloid
		bsr.w	loc_3A904
		lea	(loc_33D3A),a1
		bra.w	loc_3A8BC
;------------------------------------------------------------------------------- 
loc_33912:
		add.w	#$20,$12(a0)
		bsr.w	J_SpeedToPos 
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_3391E:
		bsr.w	loc_3A904
		lea	(Clucker_Animate_Data),a1 
		bra.w	loc_3A8BC 
;-------------------------------------------------------------------------------
loc_3392C:
		add.w	#$20,$12(a0)
		bsr.w	loc_3A904
		lea	(Lander_Animate_Data),a1 
		bra.w	loc_3A8BC
;-------------------------------------------------------------------------------
loc_33940:
		bsr.w	loc_3A904
		lea	(SFz_Cannon_Animate_Data),a1 
		bra.w	loc_3A8BC
;-------------------------------------------------------------------------------
Obj_0x97_Rexon_Fireball: 
		dc.l	Rexon_Mappings 
		dc.w	$237E
		dc.b	$84,$4,$4,$98 
Obj_0x98_Nebula_Spikeball: 
		dc.l	Nebula_Mappings 
		dc.w	$A36E
		dc.b	$84,$4,$8,$8B 
Obj_0x98_Turtloid_Bullet: 
		dc.l	Turtloid_Mappings 
		dc.w	$38A
		dc.b	$84,$4,$4,$98 
Obj_0x98_Coconuts_Coconut_Ptr: 
		dc.l	Coconuts_Mappings 
		dc.w	$3EE
		dc.b	$84,$4,$8,$8B 
Obj_0x98_Asteron_Spikes_Ptr: 
		dc.l	asteron_Mappings 
		dc.w	$8368 
		dc.b	$84,$5,$4,$98
Obj_0x98_Lander_Bomb_Ptr: 
		dc.l	Lander_Mappings 
		dc.w	$252D
		dc.b	$84,$5,$4,$98
Obj_0x98_Grabber_Unk_Ptr: 
		dc.l	Grabber_Mappings 
		dc.w	$A500
		dc.b	$84,$4,$4,$98
Obj_0x98_Clucker_Eggs_Ptr: 
		dc.l	Clucker_Mappings 
		dc.w	$379
		dc.b	$84,$5,$4,$98 
Obj_0xAF_Metal_Sonic_Spikes_Ptr: 
		dc.l	Metal_Sonic_Mappings 
		dc.w	$2380
		dc.b	$84,$5,$4,$98
Obj_0x98_Canon_Fireball_Ptr: 
		dc.l	SFz_Cannon_Mappings 
		dc.w	$3AB
		dc.b	$84,$3,$4,$98
;------------------------------------------------------------------------------- 
Obj_0x99_Nebula: 
		include 'objects/obj_0x99.asm'
;------------------------------------------------------------------------------- 
Obj_0x9A_Turtloid: 
		include 'objects/obj_0x9A.asm'
;------------------------------------------------------------------------------- 
Obj_0x9B_Turtloid_Rider: 
		include 'objects/obj_0x9B.asm'
;------------------------------------------------------------------------------- 
Obj_0x9C_Turtloid_Sub: 
		include 'objects/obj_0x9C.asm'
;------------------------------------------------------------------------------- 
Obj_0x9D_Coconuts: 
		include 'objects/obj_0x9D.asm'
;------------------------------------------------------------------------------- 
Obj_0x9E_Crawlton: 
		include 'objects/obj_0x9E.asm'
;------------------------------------------------------------------------------- 
Obj_0x9F_Shellcracker: 
		include 'objects/obj_0x9F.asm'
;------------------------------------------------------------------------------- 
Obj_0xA0_Shellcracker_Sub: 
		include 'objects/obj_0xA0.asm'
;------------------------------------------------------------------------------- 
Obj_0xA1_Slicer 
		include 'objects/obj_0xA1.asm'
;------------------------------------------------------------------------------- 
Obj_0xA2_Slicer_Sub: 
		include 'objects/obj_0xA2.asm'
;------------------------------------------------------------------------------- 
Obj_0xA3_Flasher: 
		include 'objects/obj_0xA3.asm'
;------------------------------------------------------------------------------- 
Obj_0xA4_Asteron: 
		include 'objects/obj_0xA4.asm'
;------------------------------------------------------------------------------- 
Obj_0xA5_Horizontal_Lander: 
		include 'objects/obj_0xA5.asm'
;------------------------------------------------------------------------------- 
Obj_0xA6_Vertical_Lander: 
		include 'objects/obj_0xA6.asm'
;-------------------------------------------------------------------------------
Obj_0xA7_Grabber: 
		include 'objects/obj_0xA7.asm'
Obj_0xA8_Grabber_Sub: 
		include 'objects/obj_0xA8.asm'
Obj_0xA9_Grabber_Sub: 
		include 'objects/obj_0xA9.asm'
Obj_0xAA_Grabber_Sub: 
		include 'objects/obj_0xAA.asm'
Obj_0xAB: 
		include 'objects/obj_0xAB.asm'
;-------------------------------------------------------------------------------
loc_3522E: 
		move.w	$34(a0),a1
		move.w	(a1),d0
		tst.b	$31(a0)
		beq.s	loc_35258
		subq.b	#1,$37(a0)
		beq.s	loc_3526C
		move.b	$36(a0),d1
		and.b	#$C,d0
		beq.s	loc_35256
		cmp.b	d1,d0
		beq.s	loc_35256
		move.b	d0,$36(a0)
		addq.b	#1,$38(a0)
loc_35256:
		rts
;--------------------------------------------------------------------------------
loc_35258:
		and.b	#$C,d0
		beq.s	loc_35256
		nop
		st $31(a0)
		move.b	d0,$36(a0)
		nop
		rts
;--------------------------------------------------------------------------------
loc_3526C:
		cmp.b	#4,$38(a0)
		bcs.s	loc_3529C
		move.b	#$A,$25(a0)
		clr.w	$12(a0)
		clr.b	$20(a0)
		move.w	$32(a0),a2
		move.b	#0,$2A(a2)
		bset	#1,$22(a2)
		move.b	#0,$1C(a2)
		clr.w	$32(a0)
loc_3529C:
		move.b	#$20,$37(a0)
		clr.b	$31(a0)
		clr.b	$38(a0)
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_352AC:
		subq.b	#1,$2A(a0)
		bne.s	loc_352C4
		move.b	$2B(a0),$2A(a0)
		subq.b	#1,$2B(a0)
		beq.s	loc_352C6
		bchg	#5,2(a0)
loc_352C4:
		rts
;--------------------------------------------------------------------------------
loc_352C6:
		move.b	#$27,0(a0)
		move.b	#2,$24(a0)
		bset	#5,2(a0)
		move.w	$32(a0),d0
		beq.s	loc_352F2
		move.w	d0,a2
		move.b	#0,$2A(a2)
		bset	#1,$22(a2)
		move.b	#$B,$20(a0)
loc_352F2:
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
loc_352F4:
		tst.w	($FFFFFFD8).w
		beq.s	loc_352FE
		bra.w	loc_3A892
loc_352FE:
		move.w	8(a0),d0
		and.w	#$FF80,d0
		sub.w	($FFFFF7DA).w,d0
		cmp.w	#$280,d0
		bhi loc_35316
		bra.w	loc_3A892
loc_35316:
		lea	($FFFFFC00).w,a3
		moveq	#0,d0
		move.b	$23(a0),d0
		beq.s	loc_35328
		bclr	#7,2(a3,d0)
loc_35328:
		tst.b	$30(a0)
		beq.s	loc_3533E
		move.w	$32(a0),a3
		move.b	#0,$2A(a3)
		bset	#1,$22(a3)
loc_3533E:
		moveq	#0,d6
		move.b	$2D(a0),d6
loc_35344: 
		move.w	(a2)+,a1
		bsr.w	loc_3A8AA
		dbra	d6,loc_35344
		bra.w	loc_3A898 
;-------------------------------------------------------------------------------
Load_Object_0xA9: 
		dc.w	$3E,$A93A ; Load Object 0xA9
Load_Object_0xA8: 
		dc.w	$3C,$A838 ; Load Object 0xA8
Load_Object_0xAA: 
		dc.w	$3A,$AA3C
;-------------------------------------------------------------------------------
Obj_0xA7_Ptr: 
		dc.l	Grabber_Mappings 
		dc.w	$A500
		dc.b	$4,$4,$10,$B
;------------------------------------------------------------------------------- 
Obj_0xA8_Ptr: 
		dc.l	Grabber_Mappings 
		dc.w	$A500
		dc.b	$4,$1,$10,$D7
;------------------------------------------------------------------------------- 
Obj_0xA9_Ptr: 
		dc.l	Grabber_Mappings 
		dc.w	$A500
		dc.b	$4,$4,$4,$0
;------------------------------------------------------------------------------- 
Obj_0xAA_Ptr: 
		dc.l	loc_3539A
		dc.w	$A500
		dc.b	$4,$5,$4,$0
;-------------------------------------------------------------------------------
loc_35386:
		dc.w	loc_35388-loc_35386
loc_35388:
		dc.b	$7,$0,$1,$FF
;-------------------------------------------------------------------------------
Grabber_Mappings: 
		dc.w	loc_353AC-Grabber_Mappings
		dc.w	loc_353C6-Grabber_Mappings
		dc.w	loc_353E0-Grabber_Mappings
		dc.w	loc_353EA-Grabber_Mappings
		dc.w	loc_353F4-Grabber_Mappings
		dc.w	loc_353FE-Grabber_Mappings
		dc.w	loc_35408-Grabber_Mappings
loc_3539A: 
		dc.w	loc_35412-loc_3539A
		dc.w	loc_3541C-loc_3539A
		dc.w	loc_35426-loc_3539A
		dc.w	loc_35438-loc_3539A
		dc.w	loc_3544A-loc_3539A
		dc.w	loc_3547E-loc_3539A
		dc.w	loc_35464-loc_3539A
		dc.w	loc_354A0-loc_3539A
		dc.w	loc_354A0-loc_3539A
loc_353AC:
		dc.w	$3
		dc.l	$F8010000,$FFE5,$F80D0002,$1FFED
		dc.l	$809001D,$EFFF1
loc_353C6:
		dc.w	$3
		dc.l	$F8010000,$FFE5,$F80D0002,$1FFED
		dc.l	$80D0023,$11FFF1
loc_353E0:
		dc.w	$1
		dc.l	$FC00000A,$5FFFC
loc_353EA:
		dc.w	$1
		dc.l	$F809000F,$7FFF9
loc_353F4:
		dc.w	$1
		dc.l	$F80D0015,$AFFF9
loc_353FE:
		dc.w	$1
		dc.l	$FC00002B,$15FFFC
loc_35408:
		dc.w	$1
		dc.l	$FC00002C,$16FFFC 
loc_35412:
		dc.w	$1
		dc.l	$1000B,$5FFFC
loc_3541C:
		dc.w	$1
		dc.l	$3000B,$5FFFC
loc_35426:
		dc.w	$2
		dc.l	$1000B,$5FFFC,$1003000B,$5FFFC
loc_35438:
		dc.w	$2
		dc.l	$3000B,$5FFFC,$2003000B,$5FFFC
loc_3544A:
		dc.w	$3
		dc.l	$1000B,$5FFFC,$1003000B,$5FFFC
		dc.l	$3003000B,$5FFFC
loc_35464:
		dc.w	$3
		dc.l	$3000B,$5FFFC,$2003000B,$5FFFC
		dc.l	$4003000B,$5FFFC
loc_3547E:
		dc.w	$4
		dc.l	$1000B,$5FFFC,$1003000B,$5FFFC
		dc.l	$3003000B,$5FFFC,$5003000B,$5FFFC
loc_354A0:
		dc.w	$4
		dc.l	$3000B,$5FFFC,$2003000B,$5FFFC
		dc.l	$4003000B,$5FFFC,$6003000B,$5FFFC 
;-------------------------------------------------------------------------------
Unk_Mapping_loc_354C2:
		dc.w	$5
		dc.l	$1000B,$5FFFC,$1003000B,$5FFFC
		dc.l	$3003000B,$5FFFC,$5003000B,$5FFFC
		dc.l	$7003000B,$5FFFC
;-------------------------------------------------------------------------------
Obj_0xAC_Balkiry: 
		include 'objects/obj_0xAC.asm'
;-------------------------------------------------------------------------------
Obj_0xAD_Clucker_Platform: 
		include 'objects/obj_0xAD.asm'
;------------------------------------------------------------------------------- 
Obj_0xAE_Clucker: 
		include 'objects/obj_0xAE.asm'
;-------------------------------------------------------------------------------
Obj_0xAF_Metal_Sonic: 
		include 'objects/obj_0xAF.asm'
;------------------------------------------------------------------------------- 
Obj_0xB0_Sonic_Sega_Logo: 
		include 'objects/obj_0xB0.asm'
Obj_0xB1_Sonic_Sega_Logo: 
		include 'objects/obj_0xB1.asm'

;===============================================================================
; Sub Routine loc_36798
; [ Begin ]
;===============================================================================
loc_36798:
		move.w	($FFFFF662).w,d0
		beq	Null_Sub_01 
		clr.w	($FFFFF662).w
		move.w	loc_367AC-2(pc,d0),d0
		jmp	loc_367AC(pc,d0)
loc_367AC:
		dc.w	loc_367B0-loc_367AC
		dc.w	loc_367E2-loc_367AC
loc_367B0:
		lea	(VDP_control_port),a5
		move.l	#$94169300,(a5)
		move.l	#$96859580,(a5)
		move.w	#$977F,(a5)
		move.w	#$5100,(a5)
		move.w	#$80,(DMA_data_thunk).w
		move.w	(DMA_data_thunk).w,(a5)
		lea	loc_3685A(pc),a1
		move.l	#$49500003,d0
		bra.w	loc_3681E
loc_367E2:
		lea	(VDP_control_port),a5
		move.w	#$8F01,(a5)
		move.l	#$941F93FF,(a5)
		move.w	#$9780,(a5)
		move.l	#$40000083,(a5)
		move.w	#0,(VDP_data_port)
loc_36804: 
		move.w	(a5),d1
		btst	#1,d1
		bne.s	loc_36804
		move.w	#$8F02,(a5)
		lea	loc_3686A(pc),a1
		move.l	#$49A00003,d0
		bra.w	loc_3681E
loc_3681E:
		lea	(VDP_data_port),a6
		move.l	#$1000000,d6
		moveq	#7,d1
		moveq	#9,d2
loc_3682E: 
		move.l	d0,4(a6)
		move.w	d1,d3
		move.l	a1,a2
loc_36836: 
		move.w	(a2)+,d4
		bclr	#$A,d4
		beq.s	loc_36842
		bsr.w	loc_36850
loc_36842:
		move.w	d4,(a6)
		dbra	d3,loc_36836
		add.l	d6,d0
		dbra	d2,loc_3682E
		rts
;--------------------------------------------------------------------------------
loc_36850:
		moveq	#$28,d5
loc_36852: 
		move.w	d4,(a6)
		dbra	d5,loc_36852
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_3685A:
		dc.w	$A080,$A081,$A082,$A083,$A084,$A085,$A086,$A487 
;------------------------------------------------------------------------------- 
loc_3686A:
		dc.w	$A487,$A086,$A085,$A084,$A083,$A082,$A081,$A080 
;------------------------------------------------------------------------------- 
loc_3687A:
		dc.b	$12,$4,$4,$2,$2,$2,$2,$0,$0,$0,$0,$0,$0,$0,$0,$4
		dc.b	$4,$6,$A,$8,$6,$4,$4,$4,$4,$6,$6,$8,$8,$A,$A,$C
		dc.b	$E,$10,$16,$0 
;===============================================================================
; Sub Routine loc_36798
; [ End ]
;=============================================================================== 
Obj_0xB2_Tornado: 
		include 'objects/obj_0xB2.asm'
;------------------------------------------------------------------------------- 
Obj_0xB3_Clouds: 
		include 'objects/obj_0xB3.asm'
;------------------------------------------------------------------------------- 
Obj_0xB4_Vertical_Helix: 
		include 'objects/obj_0xB4.asm'
;------------------------------------------------------------------------------- 
Obj_0xB5_Horizontal_Helix: 
		include 'objects/obj_0xB5.asm'
;------------------------------------------------------------------------------- 
Obj_0xB6_Platform_Helix: 
		include 'objects/obj_0xB6.asm'
;------------------------------------------------------------------------------- 
Obj_0xB7_SFz_Vertical_Large_Laser: 
		include 'objects/obj_0xB7.asm'
;------------------------------------------------------------------------------- 
Obj_0xB8_Cannon: 
		include 'objects/obj_0xB8.asm'
;------------------------------------------------------------------------------- 
Obj_0xB9_Laser: 
		include 'objects/obj_0xB9.asm'
;------------------------------------------------------------------------------- 
Obj_0xBA_Conveyor_Belt_Wheels: 
		include 'objects/obj_0xBA.asm'
;------------------------------------------------------------------------------- 
Obj_0xBB: 
		include 'objects/obj_0xBB.asm'
;------------------------------------------------------------------------------- 
Obj_0xBC_SFz_Rocket_Boost: 
		include 'objects/obj_0xBC.asm'
;------------------------------------------------------------------------------- 
Obj_0xBD_SFz_Elevators: 
		include 'objects/obj_0xBD.asm'
;------------------------------------------------------------------------------- 
Obj_0xBE_Hatchways: 
		include 'objects/obj_0xBE.asm'
;------------------------------------------------------------------------------- 
Obj_0xBF_Engine_Part: 
		include 'objects/obj_0xBF.asm'
;------------------------------------------------------------------------------- 
Obj_0xC0_Speed_Booster: 
		include 'objects/obj_0xC0.asm'
;------------------------------------------------------------------------------- 
Obj_0xC1_SFz_Breakable_Wall: 
		include 'objects/obj_0xC1.asm'
;------------------------------------------------------------------------------- 
Obj_0xC2_SFz_Boss_Access_Switch: 
		include 'objects/obj_0xC2.asm'
;------------------------------------------------------------------------------- 
Obj_0xC3: 
Obj_0xC4: 
		include 'objects/obj_0xC3.asm'
;------------------------------------------------------------------------------- 
Obj_0xC5_SFz_Boss: 
		include 'objects/obj_0xC5.asm'
;------------------------------------------------------------------------------- 
Obj_0xC6_Robotnik_Running: 
		include 'objects/obj_0xC6.asm'
;------------------------------------------------------------------------------- 
Obj_0xC8_Crawl: 
		include 'objects/obj_0xC8.asm'
;------------------------------------------------------------------------------- 
Obj_0xC7_DEz_Final_Boss: 
		include 'objects/obj_0xC7.asm'
;===============================================================================
; Sub Routine - Enemy Settings
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine loc_3A6EE
; [ Begin ]
;===============================================================================
loc_3A6EE:
		move.w	d1,d2
		and.w	#1,d2
		addq.w	#1,d2
		lsl.w	#6,d2
		swap.w	d2
		move.w	d1,d3
		lsr.w	#1,d3
		addq.w	#1,d3
		lsl.w	#6,d3
		swap.w	d3
		bsr.w	loc_3A71A
		btst	#1,d0
		beq	Null_Sub_01 
		btst	#1,d1
		bne.s	loc_3A718
		move.l	a3,a5
loc_3A718:
		move.l	a5,a2
loc_3A71A:
		move.l	a2,a4
		swap.w	d2
		lea	0(a2,d2),a3
		swap.w	d2
		move.w	d1,d5
		and.w	#1,d5
		bsr.w	loc_3A794
		btst	#1,d1
		beq.s	loc_3A756
		swap.w	d2
		move.w	d2,d4
		swap.w	d2
		add.w	d4,d4
		move.w	d0,d3
		and.w	#1,d3
		lsl.w	d3,d4
		add.w	d4,a4
		move.w	d1,d5
		lsr.w	#1,d5
		swap.w	d3
		lea	0(a4,d3),a5
		swap.w	d3
		bsr.w	loc_3A7AC
loc_3A756:
		btst	#0,d0
		bne.s	loc_3A762
		btst	#1,d0
		beq.s	loc_3A792
loc_3A762:
		swap.w	d2
		lea	0(a2,d2),a2
		lea	0(a2,d2),a3
		swap.w	d2
		move.w	d1,d5
		and.w	#1,d5
		bsr.w	loc_3A794
		btst	#1,d1
		beq.s	loc_3A792
		move.w	d1,d5
		lsr.w	#1,d5
		swap.w	d3
		lea	0(a4,d3),a4
		lea	0(a4,d3),a5
		swap.w	d3
		bsr.w	loc_3A7AC
loc_3A792:
		rts
;--------------------------------------------------------------------------------
loc_3A794:
		moveq	#7,d6
loc_3A796: 
		bsr.w	loc_3A7C4
		addq.w	#4,a2
		bsr.w	loc_3A7EE
		addq.w	#4,a3
		dbra	d6,loc_3A796
		dbra	d5,loc_3A794
		rts
;--------------------------------------------------------------------------------
loc_3A7AC:
		moveq	#7,d6
loc_3A7AE: 
		bsr.w	loc_3A818
		addq.w	#4,a4
		bsr.w	loc_3A842
		addq.w	#4,a5
		dbra	d6,loc_3A7AE
		dbra	d5,loc_3A7AC
		rts
;--------------------------------------------------------------------------------
loc_3A7C4:
		bsr.w	loc_3A7C8
loc_3A7C8:
		move.b	(a1)+,d2
		move.b	d2,d3
		and.b	#$F0,d2
		move.b	d2,d4
		lsr.b	#4,d4
		or.b	d2,d4
		move.b	d4,(a2)+
		move.b	d4,3(a2)
		and.b	#$F,d3
		move.b	d3,d4
		lsl.b	#4,d4
		or.b	d3,d4
		move.b	d4,(a2)+
		move.b	d4,3(a2)
		rts
;--------------------------------------------------------------------------------
loc_3A7EE:
		bsr.w	loc_3A7F2
loc_3A7F2:
		move.b	(a1)+,d2
		move.b	d2,d3
		and.b	#$F0,d2
		move.b	d2,d4
		lsr.b	#4,d4
		or.b	d2,d4
		move.b	d4,(a3)+
		move.b	d4,3(a3)
		and.b	#$F,d3
		move.b	d3,d4
		lsl.b	#4,d4
		or.b	d3,d4
		move.b	d4,(a3)+
		move.b	d4,3(a3)
		rts
;--------------------------------------------------------------------------------
loc_3A818:
		bsr.w	loc_3A81C
loc_3A81C:
		move.b	(a1)+,d2
		move.b	d2,d3
		and.b	#$F0,d2
		move.b	d2,d4
		lsr.b	#4,d4
		or.b	d2,d4
		move.b	d4,(a4)+
		move.b	d4,3(a4)
		and.b	#$F,d3
		move.b	d3,d4
		lsl.b	#4,d4
		or.b	d3,d4
		move.b	d4,(a4)+
		move.b	d4,3(a4)
		rts
;--------------------------------------------------------------------------------
loc_3A842:
		bsr.w	loc_3A846
loc_3A846:
		move.b	(a1)+,d2
		move.b	d2,d3
		and.b	#$F0,d2
		move.b	d2,d4
		lsr.b	#4,d4
		or.b	d2,d4
		move.b	d4,(a5)+
		move.b	d4,3(a5)
		and.b	#$F,d3
		move.b	d3,d4
		lsl.b	#4,d4
		or.b	d3,d4
		move.b	d4,(a5)+
		move.b	d4,3(a5)
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Unk_1245678: 
		dc.l	$12345678,$12345678,$12345678,$12345678
		dc.l	$12345678,$12345678,$12345678,$12345678
;------------------------------------------------------------------------------- 
loc_3A88C:
		jmp	DisplaySprite_Param 
J_DisplaySprite_1: ;
loc_3A892:
		jmp	DisplaySprite 
J_DeleteObject_1: ;
loc_3A898:
		jmp	DeleteObject 
J_SingleObjectLoad_1: ;
loc_3A89E:
		jmp	SingleObjectLoad 
J_MarkObjGone_1: ; 
loc_3A8A4:
		jmp	MarkObjGone 
loc_3A8AA:
		jmp	Delete_A1_Object 
J_Play_Sfx_1: ;
loc_3A8B0:
		jmp	Play_Sfx
loc_3A8B6:
		jmp	S1SingleObjectLoad 
loc_3A8BC:
		jmp	AnimateSprite 
J_Play_Sfx_Ex: ;
loc_3A8C2:
		jmp	Play_Sfx_Ex
J_PseudoRandomNumber: ;
loc_3A8C8:
		jmp	PseudoRandomNumber 
loc_3A8CE:
		jmp	(loc_12DB4)
J_Pal_AddColor2: ;
loc_3A8D4:
		jmp	Pal_AddColor2 
J_Load_Miles_Tornado_Dyn_PLC: 
		jmp	Load_Miles_Tornado_Dyn_PLC 
loc_3A8E0:
		jmp	(loc_12D80)
J_ModifySpriteAttr_2P_01: ;
loc_3A8E6:
		jmp	ModifySpriteAttr_2P 
loc_3A8EC:
		jmp	Boss_Defeated 
loc_3A8F2:
		jmp	(loc_15C6A)
loc_3A8F8:
		jmp	SolidObject 
J_ObjectFall_01: ;
loc_3A8FE:
		jmp	ObjectFall 
J_SpeedToPos: ;
loc_3A904:
		jmp	SpeedToPos 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x8A: 
		include 'objects/obj_0x8A.asm'
		nop ; Filler 
loc_3B020:
		jmp	ModifySpriteAttr_2P 
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Obj_0x3E_Egg_Prison: 
		include 'objects/obj_0x3E.asm'
		nop ; Filler
loc_3B38C:
		jmp	DeleteObject 
loc_3B392:
		jmp	SingleObjectLoad 

;===============================================================================
; Sub Routine TouchResponse
; [ Begin ]
;===============================================================================
TouchResponse: 
		nop
		bsr.w	J_TouchRings 
		cmp.b	#$C,($FFFFFE10).w
		bne.s	Touch_Response_Skip_CNz_Triangles 
		bsr.w	J_Touch_Response_Cnz_Triangles 
Touch_Response_Skip_CNz_Triangles: 
		tst.b	($FFFFF7AA).w
		bne.w	loc_3B4A8
		move.w	8(a0),d2
		move.w	$C(a0),d3
		sub.w	#8,d2
		moveq	#0,d5
		move.b	$16(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3
		cmp.b	#$4D,$1A(a0)
		bne.s	loc_3B3D6
		add.w	#$C,d3
		moveq	#$A,d5
loc_3B3D6:
		move.w	#$10,d4
		add.w	d5,d5
		lea	($FFFFB800).w,a1
		move.w	#$5F,d6
loc_3B3E4: 
		move.b	$20(a1),d0
		bne.w	Touch_Height 
loc_3B3EC: 
		lea	$40(a1),a1
		dbra	d6,loc_3B3E4
		moveq	#0,d0
		rts
;--------------------------------------------------------------------------------
Touch_Height: 
		and.w	#$3F,d0
		add.w	d0,d0
		lea	Touch_Sizes(pc,d0),a2 
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	8(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_3B41A
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_3B420
		bra.w	loc_3B3EC
loc_3B41A:
		cmp.w	d4,d0
		bhi loc_3B3EC
loc_3B420:
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	$C(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_3B43A
		add.w	d1,d1
		add.w	d1,d0
		bcs loc_3B534
		bra.w	loc_3B3EC
loc_3B43A:
		cmp.w	d5,d0
		bhi loc_3B3EC
		bra.w	loc_3B534 
Touch_Sizes: 
		dc.b	$4,$4,$14,$14,$C,$14,$14,$C,$4,$10,$C,$12,$10,$10,$6,$6
		dc.b	$18,$C,$C,$10,$10,$8,$8,$8,$14,$10,$14,$8,$E,$E,$18,$18
		dc.b	$28,$10,$10,$18,$8,$10,$20,$70,$40,$20,$80,$20,$20,$20,$8,$8
		dc.b	$4,$4,$20,$8,$C,$C,$8,$4,$18,$4,$28,$4,$4,$8,$4,$18
		dc.b	$4,$28,$4,$10,$18,$18,$C,$18,$48,$8,$18,$28,$10,$4,$20,$2
		dc.b	$4,$40,$18,$80,$20,$10,$10,$20,$10,$30,$10,$40,$10,$50,$10,$2
		dc.b	$10,$1,$2,$8 
loc_3B4A8:
		lea	Touch_Sizes(pc),a3 
		move.w	8(a0),d2
		move.w	$C(a0),d3
		sub.w	#8,d2
		moveq	#0,d5
		move.b	$16(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3
		cmp.b	#$4D,$1A(a0)
		bne.s	loc_3B4D0
		add.w	#$C,d3
		moveq	#$A,d5
loc_3B4D0:
		move.w	#$10,d4
		add.w	d5,d5
		lea	($FFFFB800).w,a1
		move.w	#$5F,d6
loc_3B4DE: 
		move.b	$20(a1),d0
		bne.s	loc_3B4F0
loc_3B4E4: 
		lea	$40(a1),a1
		dbra	d6,loc_3B4DE
		moveq	#0,d0
		rts
;--------------------------------------------------------------------------------
loc_3B4F0:
		bsr.w	loc_3B870
		and.w	#$3F,d0
		beq.s	loc_3B4E4
		add.w	d0,d0
		lea	0(a3,d0),a2
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	8(a1),d0
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_3B516
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_3B51A
		bra.s	loc_3B4E4
loc_3B516:
		cmp.w	d4,d0
		bhi.s	loc_3B4E4
loc_3B51A:
		moveq	#0,d1
		move.b	(a2)+,d1
		move.w	$C(a1),d0
		sub.w	d1,d0
		sub.w	d3,d0
		bcc.s	loc_3B530
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_3B534
		bra.s	loc_3B4E4
loc_3B530:
		cmp.w	d5,d0
		bhi.s	loc_3B4E4
loc_3B534:
		move.b	$20(a1),d1
		and.b	#$C0,d1
		beq	loc_3B5CE
		cmp.b	#$C0,d1
		beq	Touch_Special 
		tst.b	d1
		bmi loc_3B6A4
		move.b	$20(a1),d0
		and.b	#$3F,d0
		cmp.b	#6,d0
		beq.s	loc_3B57E
		move.w	($FFFFB030).w,d0
		tst.w	($FFFFFFD8).w
		beq.s	loc_3B56A
		move.w	$30(a0),d0
loc_3B56A:
		cmp.w	#$5A,d0
		bcc loc_3B57C
		move.b	#4,$24(a1)
		move.w	a0,$3E(a1)
loc_3B57C:
		rts
;--------------------------------------------------------------------------------
loc_3B57E:
		tst.w	$12(a0)
		bpl.s	loc_3B5AA
		move.w	$C(a0),d0
		sub.w	#$10,d0
		cmp.w	$C(a1),d0
		bcs.s	loc_3B5CC
		neg.w	$12(a0)
		move.w	#$FE80,$12(a1)
		tst.b	$25(a1)
		bne.s	loc_3B5CC
		move.b	#4,$25(a1)
		rts
;--------------------------------------------------------------------------------
loc_3B5AA:
		cmp.w	#$B000,a0
		beq.s	loc_3B5B6
		tst.w	($FFFFFFD8).w
		beq.s	loc_3B5CC
loc_3B5B6:
		cmp.b	#2,$1C(a0)
		bne.s	loc_3B5CC
		neg.w	$12(a0)
		move.b	#4,$24(a1)
		move.w	a0,$3E(a1)
loc_3B5CC:
		rts
;--------------------------------------------------------------------------------
loc_3B5CE:
		btst	#1,$2B(a0)
		bne.s	loc_3B5E8
		cmp.b	#9,$1C(a0)
		beq.s	loc_3B5E8
		cmp.b	#2,$1C(a0)
		bne.w	loc_3B6A4
loc_3B5E8:
		btst	#6,1(a1)
		beq.s	loc_3B60A
		tst.b	$32(a1)
		beq.s	loc_3B608
		neg.w	$10(a0)
		neg.w	$12(a0)
		move.b	#0,$20(a1)
		subq.b	#1,$32(a1)
loc_3B608:
		rts
;--------------------------------------------------------------------------------
loc_3B60A:
		tst.b	$21(a1)
		beq.s	Touch_KillEnemy 
		neg.w	$10(a0)
		neg.w	$12(a0)
		move.b	#0,$20(a1)
		subq.b	#1,$21(a1)
		bne.s	loc_3B62A
		bset	#7,$22(a1)
loc_3B62A:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
Touch_KillEnemy: 
		bset	#7,$22(a1)
		moveq	#0,d0
		move.w	($FFFFF7D0).w,d0
		addq.w	#2,($FFFFF7D0).w
		cmp.w	#6,d0
		bcs.s	loc_3B644
		moveq	#6,d0
loc_3B644:
		move.w	d0,$3E(a1)
		move.w	Enemy_Points(pc,d0),d0 
		cmp.w	#$20,($FFFFF7D0).w
		bcs.s	loc_3B65E
		move.w	#$3E8,d0
		move.w	#$A,$3E(a1)
loc_3B65E:
		move.w	a0,a3
		bsr.w	AddPoints_1 
		move.b	#$27,0(a1)
		move.b	#0,$24(a1)
		tst.w	$12(a0)
		bmi.s	loc_3B686
		move.w	$C(a0),d0
		cmp.w	$C(a1),d0
		bcc.s	loc_3B68E
		neg.w	$12(a0)
		rts
;--------------------------------------------------------------------------------
loc_3B686:
		add.w	#$100,$12(a0)
		rts
;--------------------------------------------------------------------------------
loc_3B68E:
		sub.w	#$100,$12(a0)
		rts
;--------------------------------------------------------------------------------
Enemy_Points: 
		dc.w	$A,$14,$32,$64 
loc_3B69E:
		bset	#7,$22(a1)
loc_3B6A4:
		btst	#1,$2B(a0)
		beq.s	Touch_Hurt 
loc_3B6AC: 
		moveq	#$FFFFFFFF,d0
		rts
;--------------------------------------------------------------------------------
;=============================================================================== 
Touch_Hurt: 
		nop
		tst.w	$30(a0)
		bne.s	loc_3B6AC
		move.l	a1,a2
;=============================================================================== 
; Sub Routine Hurt Sonic / Miles
; [ Begin ] 
;=============================================================================== 
Hurt_Player: 
		move.w	(Ring_count).w,d0
		cmp.w	#$B000,a0
		beq.s	loc_3B6CE
		tst.w	($FFFFFFD8).w
		beq.s	loc_3B700
		move.w	($FFFFFED0).w,d0
loc_3B6CE:
		btst	#0,$2B(a0)
		bne.s	HurtShield 
		tst.w	d0
		beq	Kill_Player 
		jsr	SingleObjectLoad 
		bne.s	HurtShield 
		move.b	#$37,0(a1)
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.w	a0,$3E(a1)
HurtShield: 
		bclr	#0,$2B(a0)
loc_3B700:
		move.b	#4,$24(a0)
		bsr.w	loc_3BAF4
		bset	#1,$22(a0)
		move.w	#$FC00,$12(a0)
		move.w	#$FE00,$10(a0)
		btst	#6,$22(a0)
		beq.s	loc_3B730
		move.w	#$FE00,$12(a0)
		move.w	#$FF00,$10(a0)
loc_3B730:
		move.w	8(a0),d0
		cmp.w	8(a2),d0
		bcs.s	loc_3B73E
		neg.w	$10(a0)
loc_3B73E:
		move.w	#0,$14(a0)
		move.b	#$1A,$1C(a0)
		move.w	#$78,$30(a0)
		move.w	#$A3,d0
		cmp.b	#$36,(a2)
		bne.s	loc_3B75E
		move.w	#$A6,d0
loc_3B75E:
		jsr	Play_Sfx
		moveq	#$FFFFFFFF,d0
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_3B398
; [ End ]
;===============================================================================
		 
;===============================================================================
; Sub Routine Kill Sonic / Miles
; [ Begin ]
;===============================================================================
Kill_Player: 
		tst.w	(Debug_placement_mode).w
		bne.s	Kill_NoDeath 
		bclr	#1,$2B(a0)
		move.b	#6,$24(a0)
		bsr.w	loc_3BAF4
		bset	#1,$22(a0)
		move.w	#$F900,$12(a0)
		move.w	#0,$10(a0)
		move.w	#0,$14(a0)
		move.b	#$18,$1C(a0)
		bset	#7,2(a0)
		move.w	#$A3,d0
		cmp.b	#$36,(a2)
		bne.s	loc_3B7B0
		move.w	#$A6,d0
loc_3B7B0:
		jsr	Play_Sfx
Kill_NoDeath: 
		moveq	#$FFFFFFFF,d0
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Kill Sonic / Miles
; [ End ]
;=============================================================================== 
Touch_Special: 
		move.b	$20(a1),d1
		and.b	#$3F,d1
		cmp.b	#6,d1
		beq.s	loc_3B844
		cmp.b	#7,d1
		beq	loc_3B85C
		cmp.b	#$B,d1
		beq.s	loc_3B80E
		cmp.b	#$A,d1
		beq.s	loc_3B844
		cmp.b	#$C,d1
		beq.s	loc_3B812
		cmp.b	#$14,d1
		beq.s	loc_3B844
		cmp.b	#$15,d1
		beq.s	loc_3B844
		cmp.b	#$16,d1
		beq.s	loc_3B844
		cmp.b	#$17,d1
		beq.s	loc_3B844
		cmp.b	#$18,d1
		beq.s	loc_3B844
		cmp.b	#$1A,d1
		beq.s	loc_3B866
		cmp.b	#$21,d1
		beq.s	loc_3B856
		rts
;--------------------------------------------------------------------------------
loc_3B80E:
		bra.w	loc_3B69E
loc_3B812:
		sub.w	d0,d5
		cmp.w	#8,d5
		bcc.s	loc_3B840
		move.w	8(a1),d0
		subq.w	#4,d0
		btst	#0,$22(a1)
		beq.s	loc_3B82C
		sub.w	#$10,d0
loc_3B82C:
		sub.w	d2,d0
		bcc.s	loc_3B838
		add.w	#$18,d0
		bcs.s	loc_3B83C
		bra.s	loc_3B840
loc_3B838:
		cmp.w	d4,d0
		bhi.s	loc_3B840
loc_3B83C:
		bra.w	loc_3B6A4
loc_3B840:
		bra.w	loc_3B5CE
loc_3B844:
		move.w	a0,d1
		sub.w	#$B000,d1
		beq.s	loc_3B850
		addq.b	#1,$21(a1)
loc_3B850:
		addq.b	#1,$21(a1)
		rts
;--------------------------------------------------------------------------------
loc_3B856:
		addq.b	#1,$21(a1)
		rts
;--------------------------------------------------------------------------------
loc_3B85C:
		move.b	#2,$21(a1)
		bra.w	loc_3B5CE
loc_3B866:
		move.b	#$FF,$21(a1)
		bra.w	loc_3B5CE
loc_3B870:
		cmp.b	#$F,d0
		bne.s	loc_3B88A
		moveq	#0,d0
		move.b	($FFFFF7AA).w,d0
		beq.s	loc_3B88A
		subq.w	#1,d0
		add.w	d0,d0
		move.w	loc_3B88C(pc,d0),d0
		jmp	loc_3B88C(pc,d0)
loc_3B88A:
		rts
;--------------------------------------------------------------------------------

loc_3B88C:
		dc.w	loc_3B89E-loc_3B88C
		dc.w	loc_3B89E-loc_3B88C
		dc.w	loc_3B8A4-loc_3B88C
		dc.w	loc_3B90C-loc_3B88C
		dc.w	loc_3B942-loc_3B88C
		dc.w	loc_3B9CE-loc_3B88C
		dc.w	loc_3BA08-loc_3B88C
		dc.w	loc_3BA0E-loc_3B88C
		dc.w	loc_3B8A2-loc_3B88C
loc_3B89E:
		move.b	$20(a1),d0
loc_3B8A2:
		rts
;--------------------------------------------------------------------------------
loc_3B8A4:
		tst.b	($FFFFF73F).w
		bne.s	loc_3B8AC
		rts
;--------------------------------------------------------------------------------
loc_3B8AC:
		move.w	d7,-(sp)
		moveq	#0,d1
		move.b	$15(a1),d1
		subq.b	#2,d1
		cmp.b	#7,d1
		bgt.s	loc_3B8EC
		move.w	d1,d7
		add.w	d7,d7
		move.w	8(a1),d0
		btst	#0,1(a1)
		beq.s	loc_3B8D2
		add.w	loc_3B8F4(pc,d7),d0
		bra.s	loc_3B8D6
loc_3B8D2:
		sub.w	loc_3B8F4(pc,d7),d0
loc_3B8D6:
		move.b	loc_3B904(pc,d1),d1
		or.l	#$40000,d1
		move.w	$C(a1),d7
		sub.w	#$1C,d7
		bsr.w	loc_3BA90
loc_3B8EC:
		move.w	(sp)+,d7
		move.b	$20(a1),d0
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_3B8F4: 
		dc.b	$0,$1C,$0,$20,$0,$28,$0,$34,$0,$3C,$0,$44,$0,$60,$0,$70
loc_3B904:
		dc.b	$4,$4,$8,$C,$14,$1C,$24,$8
;-------------------------------------------------------------------------------
loc_3B90C:
		move.w	d7,-(sp)
		move.w	8(a1),d0
		move.w	$C(a1),d7
		tst.b	($FFFFF73F).w
		beq.s	loc_3B93A
		add.w	#4,d7
		sub.w	#$50,d0
		btst	#0,1(a1)
		beq.s	loc_3B930
		add.w	#$A0,d0
loc_3B930:
		move.l	#$140010,d1
		bsr.w	loc_3BA90
loc_3B93A:
		move.w	(sp)+,d7
		move.b	$20(a1),d0
		rts
;--------------------------------------------------------------------------------
loc_3B942:
		sf $38(a1)
		cmp.b	#1,($FFFFF73F).w
		blt.s	loc_3B98A
		move.w	d7,-(sp)
		move.w	8(a1),d0
		move.w	$C(a1),d7
		add.w	#4,d7
		sub.w	#$30,d0
		btst	#0,1(a1)
		beq.s	loc_3B96C
		add.w	#$60,d0
loc_3B96C:
		move.l	#$40004,d1
		bsr.w	loc_3BA90
		move.w	(sp)+,d7
		move.b	$20(a1),d0
		cmp.w	#$78,$30(a0)
		bne.s	loc_3B988
		st $38(a1)
loc_3B988:
		rts
;--------------------------------------------------------------------------------
loc_3B98A:
		move.w	d7,-(sp)
		move.w	#$14,a5
		move.w	#0,a4
loc_3B994: 
		move.w	8(a1),d0
		move.w	$C(a1),d7
		sub.w	#$20,d7
		add.w	a5,d0
		move.l	#$100004,d1
		bsr.w	loc_3BA90
		move.w	#$FFEC,a5
		add.w	#1,a4
		cmp.w	#1,a4
		beq.s	loc_3B994
		move.w	(sp)+,d7
		move.b	$20(a1),d0
		cmp.w	#$78,$30(a0)
		bne.s	loc_3B9CC
		st $38(a1)
loc_3B9CC:
		rts
;--------------------------------------------------------------------------------
loc_3B9CE:
		tst.b	($FFFFF73F).w
		beq.s	loc_3BA02
		move.w	d7,-(sp)
		move.w	8(a1),d0
		move.w	$C(a1),d7
		add.w	#$28,d7
		move.l	#$80010,d1
		cmp.b	#1,($FFFFF73F).w
		beq.s	loc_3B9FC
		move.w	#$20,d1
		sub.w	#8,d7
		add.w	#4,d0
loc_3B9FC:
		bsr.w	loc_3BA90
		move.w	(sp)+,d7
loc_3BA02:
		move.b	$20(a1),d0
		rts
;--------------------------------------------------------------------------------
loc_3BA08:
		move.b	$20(a1),d0
		rts
;--------------------------------------------------------------------------------
loc_3BA0E:
		cmp.b	#1,($FFFFF73F).w
		blt.s	loc_3BA8A
		beq.s	loc_3BA60
		move.w	d7,-(sp)
		move.w	8(a1),d0
		move.w	$C(a1),d7
		moveq	#0,d1
		move.b	$B(a1),d1
		subq.b	#2,d1
		add.w	d1,d1
		btst	#0,1(a1)
		beq.s	loc_3BA3A
		add.w	loc_3BA54(pc,d1),d0
		bra.s	loc_3BA3E
loc_3BA3A:
		sub.w	loc_3BA54(pc,d1),d0
loc_3BA3E:
		sub.w	loc_3BA56(pc,d1),d7
		move.l	#$60008,d1
		bsr.w	loc_3BA90
		move.w	(sp)+,d7
		move.w	#0,d0
		rts
;--------------------------------------------------------------------------------
loc_3BA54:
		dc.b	$0,$14
loc_3BA56: 
		dc.b	$0,$0,$0,$10,$0,$10,$0,$10,$FF,$F0 
loc_3BA60:
		move.w	d7,-(sp)
		move.w	8(a1),d0
		move.w	$C(a1),d7
		moveq	#$10,d1
		btst	#0,1(a1)
		beq.s	loc_3BA76
		neg.w	d1
loc_3BA76:
		sub.w	d1,d0
		move.l	#$8000C,d1
		bsr.w	loc_3BABE
		move.w	(sp)+,d7
		move.b	#0,d0
		rts
;--------------------------------------------------------------------------------
loc_3BA8A:
		move.b	$20(a1),d0
		rts
;--------------------------------------------------------------------------------
loc_3BA90:
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_3BA9E
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_3BAA2
loc_3BA9C: 
		rts
;--------------------------------------------------------------------------------
loc_3BA9E:
		cmp.w	d4,d0
		bhi.s	loc_3BA9C
loc_3BAA2:
		swap.w	d1
		sub.w	d1,d7
		sub.w	d3,d7
		bcc.s	loc_3BAB4
		add.w	d1,d1
		add.w	d1,d7
		bcs loc_3B6A4
		bra.s	loc_3BA9C
loc_3BAB4:
		cmp.w	d5,d7
		bhi loc_3BA9C
		bra.w	loc_3B6A4
loc_3BABE:
		sub.w	d1,d0
		sub.w	d2,d0
		bcc.s	loc_3BACC
		add.w	d1,d1
		add.w	d1,d0
		bcs.s	loc_3BAD0
loc_3BACA: 
		rts
;--------------------------------------------------------------------------------
loc_3BACC:
		cmp.w	d4,d0
		bhi.s	loc_3BACA
loc_3BAD0:
		swap.w	d1
		sub.w	d1,d7
		sub.w	d3,d7
		bcc.s	loc_3BAE2
		add.w	d1,d1
		add.w	d1,d7
		bcs loc_3BAE8
		bra.s	loc_3BACA
loc_3BAE2:
		cmp.w	d5,d7
		bhi loc_3BACA
loc_3BAE8:
		neg.w	$10(a0)
		neg.w	$12(a0)
		rts
;--------------------------------------------------------------------------------
		nop 
loc_3BAF4:
		jmp	(loc_16F34) 
;===============================================================================
; Sub Routine TouchResponse
; [ End ]
;=============================================================================== 
J_Touch_Response_CNz_Triangles: 
		jmp	Touch_Response_CNz_Triangles 
J_TouchRings: 
		jmp	TouchRings 
		dc.w	$0
;===============================================================================
; Sub Routine Dynamic_Art_Cues
; [ Begin ]
;===============================================================================
Dynamic_Art_Cues: 
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	dynamic_Art_Idx+2(pc,d0),d1 
		lea	Dynamic_Art_Idx(pc,d1),a2 
		move.w	dynamic_Art_Idx(pc,d0),d0 
		jmp	Dynamic_Art_Idx(pc,d0) 
		rts
;--------------------------------------------------------------------------------
Dynamic_Art_Idx: 
		dc.w	dynamic_Normal-dynamic_Art_Idx 
		dc.w	GHz_Animate-dynamic_Art_Idx 
		dc.w	dynamic_Null-dynamic_Art_Idx 
		dc.w	loc_3C044-dynamic_Art_Idx
		dc.w	dynamic_Null-dynamic_Art_Idx 
		dc.w	loc_3C044-dynamic_Art_Idx
		dc.w	dynamic_Null-dynamic_Art_Idx 
		dc.w	loc_3C044-dynamic_Art_Idx
		dc.w	dynamic_Normal-dynamic_Art_Idx 
		dc.w	Mz_Animate-dynamic_Art_Idx 
		dc.w	dynamic_Normal-dynamic_Art_Idx 
		dc.w	Mz_Animate-dynamic_Art_Idx 
		dc.w	dynamic_Null-dynamic_Art_Idx 
		dc.w	loc_3C044-dynamic_Art_Idx
		dc.w	dynamic_HTz-dynamic_Art_Idx 
		dc.w	HTz_Animate-dynamic_Art_Idx 
		dc.w	dynamic_Normal-dynamic_Art_Idx 
		dc.w	HPz_Animate-dynamic_Art_Idx 
		dc.w	dynamic_Null-dynamic_Art_Idx 
		dc.w	loc_3C044-dynamic_Art_Idx
		dc.w	dynamic_Normal-dynamic_Art_Idx 
		dc.w	OOz_Animate-dynamic_Art_Idx 
		dc.w	dynamic_Null-dynamic_Art_Idx 
		dc.w	loc_3C044-dynamic_Art_Idx
		dc.w	dynamic_CNz-dynamic_Art_Idx 
		dc.w	CNz_Animate-dynamic_Art_Idx 
		dc.w	dynamic_Normal-dynamic_Art_Idx 
		dc.w	CPz_Animate-dynamic_Art_Idx 
		dc.w	dynamic_Normal-dynamic_Art_Idx 
		dc.w	dEz_Animate-dynamic_Art_Idx 
		dc.w	loc_3BD68-dynamic_Art_Idx
		dc.w	NGHz_Animate-dynamic_Art_Idx 
		dc.w	dynamic_Null-dynamic_Art_Idx 
		dc.w	loc_3C044-dynamic_Art_Idx 
Dynamic_Null: 
		rts
;--------------------------------------------------------------------------------
Dynamic_HTz: 
		tst.w	($FFFFFFD8).w
		bne.w	Dynamic_Normal 
		lea	($FFFFF7F0).w,a3
		moveq	#0,d0
		move.w	($FFFFEE00).w,d1
		neg.w	d1
		asr.w	#3,d1
		move.w	($FFFFEE00).w,d0
		lsr.w	#4,d0
		add.w	d1,d0
		sub.w	#$10,d0
		divu.w	#$30,d0
		swap.w	d0
		cmp.b	1(a3),d0
		beq.s	loc_3BBDC
		move.b	d0,1(a3)
		move.w	d0,d2
		and.w	#7,d0
		add.w	d0,d0
		add.w	d0,d0
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		and.w	#$38,d2
		lsr.w	#2,d2
		add.w	d2,d0
		lea	HTz_Ram_Dyn_Sprites(pc,d0),a4 
		moveq	#5,d5
		move.w	#$A000,d4
loc_3BBC0: 
		moveq	#$FFFFFFFF,d1
		move.w	(a4)+,d1
		and.l	#$FFFFFF,d1
		move.w	d4,d2
		moveq	#$40,d3
		jsr	DMA_68KtoVRAM 
		add.w	#$80,d4
		dbra	d5,loc_3BBC0
loc_3BBDC:
		bra.w	loc_3BCA0 
		
HTz_Ram_Dyn_Sprites: 
		dc.w	$80,$180,$280,$580,$600,$700,$80,$180
		dc.w	$280,$580,$600,$700,$980,$A80,$B80,$C80
		dc.w	$D00,$D80,$980,$A80,$B80,$C80,$D00,$D80
		dc.w	$E80,$1180,$1200,$1280,$1300,$1380,$E80,$1180
		dc.w	$1200,$1280,$1300,$1380,$1400,$1480,$1500,$1580
		dc.w	$1600,$1900,$1400,$1480,$1500,$1580,$1600,$1900
		dc.w	$1D00,$1D80,$1E00,$1F80,$2400,$2580,$1D00,$1D80
		dc.w	$1E00,$1F80,$2400,$2580,$2600,$2680,$2780,$2B00
		dc.w	$2F00,$3280,$2600,$2680,$2780,$2B00,$2F00,$3280
		dc.w	$3600,$3680,$3780,$3C80,$3D00,$3F00,$3600,$3680
		dc.w	$3780,$3C80,$3D00,$3F00,$3F80,$4080,$4480,$4580
		dc.w	$4880,$4900,$3F80,$4080,$4480,$4580,$4880,$4900 
loc_3BCA0:
		lea	($FFFFA800).w,a1
		move.w	($FFFFEE00).w,d2
		neg.w	d2
		asr.w	#3,d2
		move.l	a2,-(sp)
		lea	(Hill_Top_Background_Unc),a0 
		lea	($FFFF7C00),a2
		moveq	#$F,d1
loc_3BCBC: 
		move.w	(a1)+,d0
		neg.w	d0
		add.w	d2,d0
		and.w	#$1F,d0
		lsr.w	#1,d0
		bcc.s	loc_3BCCE
		add.w	#$200,d0
loc_3BCCE:
		lea	0(a0,d0),a4
		lsr.w	#1,d0
		bcs.s	loc_3BCF8
		move.l	(a4)+,(a2)+
		add.w	#$3C,a2
loc_3BCDC:
		move.l	(a4)+,(a2)+
		add.w	#$3C,a2
		move.l	(a4)+,(a2)+
		add.w	#$3C,a2
		move.l	(a4)+,(a2)+
		sub.w	#$C0,a2
		add.w	#$20,a0
		dbra	d1,loc_3BCBC
		bra.s	loc_3BD30
loc_3BCF8:
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		add.w	#$3C,a2
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		add.w	#$3C,a2
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		add.w	#$3C,a2
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		move.b	(a4)+,(a2)+
		sub.w	#$C0,a2
		add.w	#$20,a0
		dbra	d1,loc_3BCBC
loc_3BD30:
		move.l	#$FF7C00,d1
		move.w	#$A300,d2
		move.w	#$80,d3
		jsr	DMA_68KtoVRAM 
		move.l	(sp)+,a2
		addq.w	#2,a3
		bra.w	loc_3BD74 
Dynamic_CNz: 
		tst.b	($FFFFF7AA).w
		beq.s	loc_3BD54
		rts
;--------------------------------------------------------------------------------
loc_3BD54:
		lea	(CNz_Animate),a2 
		tst.w	($FFFFFFD8).w
		beq.s	Dynamic_Normal 
		lea	(CNz_Animate_2P),a2 
		bra.s	Dynamic_Normal 
loc_3BD68:
		tst.b	($FFFFF7AA).w
		beq.s	Dynamic_Normal 
		rts
;--------------------------------------------------------------------------------
Dynamic_Normal: 
		lea	($FFFFF7F0).w,a3 
loc_3BD74: 
		move.w	(a2)+,d6
Dynamic_Normal_Loop: 
		subq.b	#1,(a3)
		bcc.s	loc_3BDBC
		moveq	#0,d0
		move.b	1(a3),d0
		cmp.b	6(a2),d0
		bcs.s	loc_3BD8C
		moveq	#0,d0
		move.b	d0,1(a3)
loc_3BD8C:
		addq.b	#1,1(a3)
		move.b	(a2),(a3)
		bpl.s	loc_3BD9A
		add.w	d0,d0
		move.b	9(a2,d0),(a3)
loc_3BD9A:
		move.b	8(a2,d0),d0
		lsl.w	#5,d0
		move.w	4(a2),d2
		move.l	(a2),d1
		and.l	#$FFFFFF,d1
		add.l	d0,d1
		moveq	#0,d3
		move.b	7(a2),d3
		lsl.w	#4,d3
		jsr	DMA_68KtoVRAM 
loc_3BDBC:
		move.b	6(a2),d0
		tst.b	(a2)
		bpl.s	loc_3BDC6
		add.b	d0,d0
loc_3BDC6:
		addq.b	#1,d0
		and.w	#$FE,d0
		lea	8(a2,d0),a2
		addq.w	#2,a3
		dbra	d6,dynamic_Normal_Loop 
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; GHz Animate Script
; [ Begin ]
;=============================================================================== 
GHz_Animate: 
		dc.w	$4 ; Total of Animations
		dc.l	($FF<<$18)|Ghz_Flower_1
		dc.w	$7280 ; VRam 
		dc.w	$602 ; Frames/Tiles
		dc.w	$7F,$213,$7,$207,$7,$207 ; Frame Load/Frame Time
		dc.l	($FF<<$18)|Ghz_Flower_2 
		dc.w	$72C0 ; VRam
		dc.w	$802 ; Frames/Tiles
		dc.w	$27F,$B,$20B,$B,$205,$5,$205,$5 ; Frame Load/Frame Time
		dc.l	($7<<$18)|Ghz_Flower_3 
		dc.w	$7300 ; VRam
		dc.w	$202 ; Frames/Tiles
		dc.w	$2 ; Frame Load/Frame Time
		dc.l	($FF<<$18)|Ghz_Flower_4 
		dc.w	$7340 ; VRam
		dc.w	$802 ; Frames/Tiles
		dc.w	$7F,$207,$7,$207,$7,$20B,$B,$20B ; Frame Load/Frame Time
		dc.l	($FF<<$18)|Ghz_Dyn_Wall 
		dc.w	$7380 ; VRam
		dc.w	$602 ; Frames/Tiles
		dc.w	$17,$209,$40B,$617,$40B,$209 ; Frame Load/Frame Time 
;===============================================================================
; GHz Animate Script
; [ End ]
;===============================================================================

;===============================================================================
; Mz Animate Script
; [ Begin ]
;===============================================================================
Mz_Animate: 
		dc.w	$3 ; Total of Animations
		dc.l	Mz_Spinnig_Cylinder 
		dc.w	$6980 ; VRam 
		dc.w	$810 ; Frames/Tiles
		dc.w	$10,$2030,$4050,$6070 ; Frame Load/Frame Time
		dc.l	($D<<$18)|Mz_Lava 
		dc.w	$6800 ; VRam 
		dc.w	$60C ; Frames/Tiles
		dc.w	$C,$1824,$180C ; Frame Load/Frame Time
		dc.l	($FF<<$18)|Mz_Pistons 
		dc.w	$6B80 ; VRam 
		dc.w	$406 ; Frames/Tiles
		dc.w	$13,$607,$C13,$607 ; Frame Load/Frame Time
		dc.l	($FF<<$18)|Mz_Pistons 
		dc.w	$6C40 ; VRam 
		dc.w	$406 ; Frames/Tiles
		dc.w	$C13,$607,$13,$607 ; Frame Load/Frame Time 
;===============================================================================
; Mz Animate Script
; [ End ]
;===============================================================================

;===============================================================================
; HTz Animate Script
; [ Begin ]
;===============================================================================
HTz_Animate: 
		; Hill Top Dynamic Reload Sprites 
		dc.w	$4 ; Total of Animations
		dc.l	($FF<<$18)|Ghz_Flower_1
		dc.w	$7280 ; VRam 
		dc.w	$602 ; Frames/Tiles
		dc.w	$7F,$213,$7,$207,$7,$207 ; Frame Load/Frame Time
		dc.l	($FF<<$18)|Ghz_Flower_2 
		dc.w	$72C0 ; VRam
		dc.w	$802 ; Frames/Tiles
		dc.w	$27F,$B,$20B,$B,$205,$5,$205,$5 ; Frame Load/Frame Time
		dc.l	($7<<$18)|Ghz_Flower_3 
		dc.w	$7300 ; VRam
		dc.w	$202 ; Frames/Tiles
		dc.w	$2 ; Frame Load/Frame Time
		dc.l	($FF<<$18)|Ghz_Flower_4 
		dc.w	$7340 ; VRam
		dc.w	$802 ; Frames/Tiles
		dc.w	$7F,$207,$7,$207,$7,$20B,$B,$20B ; Frame Load/Frame Time
		dc.l	($FF<<$18)|Ghz_Dyn_Wall 
		dc.w	$7380 ; VRam
		dc.w	$602 ; Frames/Tiles
		dc.w	$17,$209,$40B,$617,$40B,$209 ; Frame Load/Frame Time
;===============================================================================
; HTz Animate Script
; [ End ]
;===============================================================================

;===============================================================================
; HPz Animate Script
; [ Begin ]
;===============================================================================
HPz_Animate: 
		dc.w	$2 ; Total of Animations
		dc.l	($8<<$18)|HPz_Orbs 
		dc.w	$5D00 ; VRam
		dc.w	$608 ; Frames/Tiles
		dc.w	$0,$810,$1008 ; Frame Load/Frame Time 
		dc.l	($8<<$18)|HPz_Orbs 
		dc.w	$5E00 ; VRam
		dc.w	$608 ; Frames/Tiles
		dc.w	$810,$1008,$0 ; Frame Load/Frame Time
		dc.l	($8<<$18)|HPz_Orbs 
		dc.w	$5F00 ; VRam
		dc.w	$608 ; Frames/Tiles
		dc.w	$1008,$0,$810 ; Frame Load/Frame Time 
;===============================================================================
; HPz Animate Script
; [ End ]
;===============================================================================

;===============================================================================
; OOz Animate Script
; [ Begin ]
;===============================================================================
OOz_Animate: 
		dc.w	$4 ; Total of Animations
		dc.l	($FF<<$18)|OOz_Red_Balls 
		dc.w	$56C0 ; VRam
		dc.w	$404 ; Frames/Tiles
		dc.w	$B,$405,$809,$403 ; Frame Load/Frame Time 
		dc.l	($6<<$18)|OOz_Rotating_Square_1 
		dc.w	$5740 ; VRam
		dc.w	$404 ; Frames/Tiles
		dc.w	$4,$80C ; Frame Load/Frame Time 
		dc.l	($6<<$18)|OOz_Rotating_Square_2 
		dc.w	$57C0 ; VRam
		dc.w	$404 ; Frames/Tiles
		dc.w	$4,$80C ; Frame Load/Frame Time 
		dc.l	($11<<$18)|OOz_Oil_1 
		dc.w	$5840 ; VRam
		dc.w	$610 ; Frames/Tiles
		dc.w	$10,$2030,$2010 ; Frame Load/Frame Time 
		dc.l	($11<<$18)|OOz_Oil_2 
		dc.w	$5A40 ; VRam
		dc.w	$610 ; Frames/Tiles
		dc.w	$10,$2030,$2010 ; Frame Load/Frame Time
;===============================================================================
; OOz Animate Script
; [ End ]
;=============================================================================== 
		
;===============================================================================
; CNz Animate Script
; [ Begin ]
;===============================================================================
CNz_Animate: 
		dc.w	$1 ; Total of Animations
		dc.l	($FF<<$18)|CNz_Symbols_Spr 
		dc.w	$A800 ; VRam
		dc.w	$1010 ; Frames/Tiles
		dc.w	$C7,$1005,$2005,$3005,$40C7,$5005,$2005,$6005 ; Frame Load/Frame Time 
		dc.w	$5,$1005,$2005,$3005,$4005,$5005,$2005,$6005 ; Frame Load/Frame Time
		dc.l	($FF<<$18)|CNz_Symbols_Spr 
		dc.w	$6600 ; VRam
		dc.w	$1010 ; Frames/Tiles
		dc.w	$7005,$8005,$2005,$9005,$A005,$B005,$2005,$C005 ; Frame Load/Frame Time
		dc.w	$70C7,$8005,$2005,$9005,$A0C7,$B005,$2005,$C005 ; Frame Load/Frame Time
CNz_Animate_2P: 
		dc.w	$1 ; Total of Animations
		dc.l	($FF<<$18)|CNz_Symbols_Spr 
		dc.w	$E800 ; VRam
		dc.w	$1010 ; Frames/Tiles
		dc.w	$C7,$1005,$2005,$3005,$40C7,$5005,$2005,$6005 ; Frame Load/Frame Time 
		dc.w	$5,$1005,$2005,$3005,$4005,$5005,$2005,$6005 ; Frame Load/Frame Time
		dc.l	($FF<<$18)|CNz_Symbols_Spr 
		dc.w	$6600 ; VRam
		dc.w	$1010 ; Frames/Tiles
		dc.w	$7005,$8005,$2005,$9005,$A005,$B005,$2005,$C005 ; Frame Load/Frame Time
		dc.w	$70C7,$8005,$2005,$9005,$A0C7,$B005,$2005,$C005 ; Frame Load/Frame Time
;===============================================================================
; CNz Animate Script
; [ End ]
;===============================================================================

;===============================================================================
; CPz Animate Script
; [ Begin ]
;===============================================================================
CPz_Animate: 
		dc.w	$0 ; Total of Animations
		dc.l	($4<<$18)|CPz_Dyn_Background 
		dc.w	$6E00 ; VRam
		dc.w	$802 ; Frames/Tiles
		dc.w	$2,$406,$80A,$C0E ; Frame Load/Frame Time
;===============================================================================
; CPz Animate Script
; [ End ]
;===============================================================================
		 
;===============================================================================
; Dez Animate Script
; [ Begin ]
;===============================================================================
DEz_Animate: 
		dc.w	$0 ; Total of Animations
		dc.l	($4<<$18)|CPz_Dyn_Background 
		dc.w	$64C0 ; VRam
		dc.w	$802 ; Frames/Tiles
		dc.w	$2,$406,$80A,$C0E ; Frame Load/Frame Time
;===============================================================================
; Dez Animate Script
; [ End ]
;=============================================================================== 

;===============================================================================
; NGHz Animate Script
; [ Begin ]
;=============================================================================== 
NGHz_Animate: 
		dc.w	$3 ; Total of Animations
		dc.l	($5<<$18)|NGHz_Water_Falls_1 
		dc.w	$AAE0 ; VRam
		dc.w	$204 ; Frames/Tiles 
		dc.w	$4 ; Frame Load/Frame Time
		dc.l	($5<<$18)|NGHz_Water_Falls_1 
		dc.w	$8600 ; VRam
		dc.w	$204 ; Frames/Tiles 
		dc.w	$400 ; Frame Load/Frame Time
		dc.l	($5<<$18)|NGHz_Water_Falls_2 
		dc.w	$8580 ; VRam
		dc.w	$204 ; Frames/Tiles 
		dc.w	$4 ; Frame Load/Frame Time
		dc.l	($5<<$18)|NGHz_Water_Falls_3 
		dc.w	$8500 ; VRam
		dc.w	$204 ; Frames/Tiles 
		dc.w	$4 ; Frame Load/Frame Time 
;===============================================================================
; NGHz Animate Script
; [ End ]
;=============================================================================== 
		
;===============================================================================
; Sub Routine Dynamic_Art_Cues
; [ End ]
;=============================================================================== 
loc_3C044:
		cmp.b	#$D,($FFFFFE10).w
		beq.s	loc_3C04E
loc_3C04C 
		rts
;--------------------------------------------------------------------------------
loc_3C04E:
		move.w	($FFFFEE00).w,d0
		cmp.w	#$1940,d0
		bcs.s	loc_3C04C
		cmp.w	#$1F80,d0
		bcc.s	loc_3C04C
		subq.b	#1,($FFFFF72D).w
		bpl.s	loc_3C04C
		move.b	#7,($FFFFF72D).w
		move.b	#1,($FFFFF72C).w
		lea	($FFFF7500),a1
		bsr.s	loc_3C07E
		lea	($FFFF7D00),a1
loc_3C07E:
		move.w	#7,d1
loc_3C082 
		move.w	(a1),d0
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		add.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		add.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	$72(a1),(a1)+
		add.w	#$70,a1
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	2(a1),(a1)+
		move.w	d0,(a1)+
		sub.w	#$180,a1
		dbra	d1,loc_3C082
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Load_16x16_Mappings_For_Dyn_Sprites
; [ Begin ]
;=============================================================================== 
Load_16x16_Mappings_For_Dyn_Sprites: 
		cmp.b	#7,($FFFFFE10).w
		bne.s	loc_3C130
		bsr.w	loc_3C604
		move.b	#$FF,($FFFFF7F1).w
		move.w	#$FFFF,($FFFFA820).w
loc_3C130:
		cmp.b	#$D,($FFFFFE10).w
		bne.s	loc_3C13E
		move.b	#$FF,($FFFFF7F1).w
loc_3C13E:
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
		add.w	d0,d0
		move.w	Map16Delta_Index(pc,d0),d0 
		lea	Map16Delta_Index(pc,d0),a0 
		tst.w	($FFFFFFD8).w
		beq.s	loc_3C162
		cmp.b	#$C,($FFFFFE10).w
		bne.s	loc_3C162
		lea	(Map16Delta_CNz_2P),a0 
loc_3C162:
		tst.w	(a0)
		beq.s	loc_3C17A
		lea	($FFFF9000).w,a1
		add.w	(a0)+,a1
		move.w	(a0)+,d1
		tst.w	($FFFFFFD8).w
		bne.s	loc_3C17C
loc_3C174: 
		move.w	(a0)+,(a1)+
		dbra	d1,loc_3C174
loc_3C17A:
		rts
;--------------------------------------------------------------------------------
loc_3C17C:
		move.w	(a0)+,d0
		move.w	d0,d1
		and.w	#$F800,d0
		and.w	#$7FF,d1
		lsr.w	#1,d1
		or.w	d1,d0
		move.w	d0,(a1)+
		dbra	d1,loc_3C17C
		rts
;--------------------------------------------------------------------------------
Map16Delta_Index: 
		dc.w	Map16Delta_GHz-Map16Delta_Index 
		dc.w	Map16Delta_Null-Map16Delta_Index 
		dc.w	Map16Delta_Null-Map16Delta_Index 
		dc.w	Map16Delta_Null-Map16Delta_Index 
		dc.w	Map16Delta_Mz-Map16Delta_Index 
		dc.w	Map16Delta_Mz-Map16Delta_Index 
		dc.w	Map16Delta_Null-Map16Delta_Index 
		dc.w	Map16Delta_GHz-Map16Delta_Index 
		dc.w	Map16Delta_HPz-Map16Delta_Index 
		dc.w	Map16Delta_Null-Map16Delta_Index 
		dc.w	Map16Delta_OOz-Map16Delta_Index 
		dc.w	Map16Delta_Null-Map16Delta_Index 
		dc.w	Map16Delta_CNz-Map16Delta_Index 
		dc.w	Map16Delta_CPz-Map16Delta_Index 
		dc.w	Map16Delta_DEz-Map16Delta_Index 
		dc.w	Map16Delta_NGHz-Map16Delta_Index 
		dc.w	Map16Delta_Null-Map16Delta_Index 
;===============================================================================
; Green Hill Mappings 16x16 Delta 
; [ Begin ]
;=============================================================================== 
Map16Delta_GHz: 
		dc.w	$1788 ; Ram Address to start loading ($1788+$FFFF9000) -> add.w	(a0)+,a1
		dc.w	$3B ; Number of words to load in Ram Array ($0..$3B) -> move.w	(a0)+,d1 
		dc.w	$4500,$4504,$4501,$4505,$4508,$450C,$4509,$450D
		dc.w	$4510,$4514,$4511,$4515,$4502,$4506,$4503,$4507
		dc.w	$450A,$450E,$450B,$450F,$4512,$4516,$4513,$4517
		dc.w	$6518,$651A,$6519,$651B,$651C,$651E,$651D,$651F
		dc.w	$439C,$4B9C,$439D,$4B9D,$4158,$439C,$4159,$439D
		dc.w	$4B9C,$4958,$4B9D,$4959,$6394,$6B94,$6395,$6B95
		dc.w	$E396,$EB96,$E397,$EB97,$6398,$6B98,$6399,$6B99
		dc.w	$E39A,$EB9A,$E39B,$EB9B
;===============================================================================
; Green Hill Mappings 16x16 Delta 
; [ End ]
;===============================================================================

;===============================================================================
; Metropolis Mappings 16x16 Delta 
; [ Begin ]
;=============================================================================== 
Map16Delta_Mz: 
		dc.w	$1730 ; Ram Address to start loading ($1730+$FFFF9000) -> add.w	(a0)+,a1
		dc.w	$67 ; Number of words to load in Ram Array ($0..$67) -> move.w	(a0)+,d1 
		dc.w	$235C,$2B5C,$235D,$2B5D,$235E,$2B5E,$235F,$2B5F
		dc.w	$635A,$635A,$635B,$635B,$6358,$6358,$6359,$6359
		dc.w	$6356,$6356,$6357,$6357,$6354,$6354,$6355,$6355
		dc.w	$6352,$6352,$6353,$6353,$6350,$6350,$6351,$6351
		dc.w	$634E,$634E,$634F,$634F,$634C,$634C,$634D,$634D
		dc.w	$2360,$2B60,$2361,$2B61,$2362,$2B62,$2363,$2B63
		dc.w	$2364,$2B64,$2365,$2B65,$2366,$2B66,$2367,$2B67
		dc.w	$C000,$C000,$C340,$C341,$C000,$C000,$C342,$C343
		dc.w	$C344,$C345,$C348,$C349,$C346,$C347,$C34A,$C34B
		dc.w	$E35A,$E35A,$E35B,$E35B,$E358,$E358,$E359,$E359
		dc.w	$E356,$E356,$E357,$E357,$E354,$E354,$E355,$E355
		dc.w	$E352,$E352,$E353,$E353,$E350,$E350,$E351,$E351
		dc.w	$E34E,$E34E,$E34F,$E34F,$E34C,$E34C,$E34D,$E34D
;===============================================================================
; Metropolis Mappings 16x16 Delta 
; [ End ]
;=============================================================================== 
 
;===============================================================================
; Hidden Palace Mappings 16x16 Delta 
; [ Begin ]
;=============================================================================== 
Map16Delta_HPz: 
		dc.w	$1710 ; Ram Address to start loading ($1710+$FFFF9000) -> add.w	(a0)+,a1
		dc.w	$77 ; Number of words to load in Ram Array ($0..$77) -> move.w	(a0)+,d1 
		dc.w	$62E8,$62E9,$62EA,$62EB,$62EC,$62ED,$62EE,$62EF
		dc.w	$62F0,$62F1,$62F2,$62F3,$62F4,$62F5,$62F6,$62F7
		dc.w	$62F8,$62F9,$62FA,$62FB,$62FC,$62FD,$62FE,$62FF
		dc.w	$42E8,$42E9,$42EA,$42EB,$42EC,$42ED,$42EE,$42EF
		dc.w	$42F0,$42F1,$42F2,$42F3,$42F4,$42F5,$42F6,$42F7
		dc.w	$42F8,$42F9,$42FA,$42FB,$42FC,$42FD,$42FE,$42FF
		dc.w	$0,$62E8,$0,$62EA,$62E9,$62EC,$62EB,$62EE
		dc.w	$62ED,$0,$62EF,$0,$0,$62F0,$0,$62F2
		dc.w	$62F1,$62F4,$62F3,$62F6,$62F5,$0,$62F7,$0
		dc.w	$0,$62F8,$0,$62FA,$62F9,$62FC,$62FB,$62FE
		dc.w	$62FD,$0,$62FF,$0,$0,$42E8,$0,$42EA
		dc.w	$42E9,$42EC,$42EB,$42EE,$42ED,$0,$42EF,$0
		dc.w	$0,$42F0,$0,$42F2,$42F1,$42F4,$42F3,$42F6
		dc.w	$42F5,$0,$42F7,$0,$0,$42F8,$0,$42FA
		dc.w	$42F9,$42FC,$42FB,$42FE,$42FD,$0,$42FF,$0
;===============================================================================
; Hidden Palace Mappings 16x16 Delta 
; [ End ]
;=============================================================================== 

;===============================================================================
; Oil Ocean Mappings 16x16 Delta 
; [ End ]
;=============================================================================== 
Map16Delta_OOz: 
		dc.w	$17A0 ; Ram Address to start loading ($17A0+$FFFF9000) -> add.w	(a0)+,a1
		dc.w	$2F ; Number of words to load in Ram Array ($0..$2F) -> move.w	(a0)+,d1
		dc.w	$82B6,$82B8,$82B7,$82B9,$E2BA,$E2BB,$E2BC,$E2BD
		dc.w	$0,$62BE,$0,$62C0,$62BF,$0,$62C1,$0
		dc.w	$C2C2,$C2C3,$C2CA,$C2CB,$C2C4,$C2C5,$C2CC,$C2CD
		dc.w	$C2C6,$C2C7,$C2CE,$C2CF,$C2C8,$C2C9,$C2D0,$C2D1
		dc.w	$C2D2,$C2D3,$C2DA,$C2DB,$C2D4,$C2D5,$C2DC,$C2DD
		dc.w	$C2D6,$C2D7,$C2DE,$C2DF,$C2D8,$C2D9,$C2E0,$C2E1
;===============================================================================
; Oil Ocean Mappings 16x16 Delta 
; [ End ]
;=============================================================================== 
 
;===============================================================================
; Casino Night Mappings 16x16 Delta 
; [ Begin ]
;=============================================================================== 
Map16Delta_CNz: 
		dc.w	$1760 ; Ram Address to start loading ($1760+$FFFF9000) -> add.w	(a0)+,a1
		dc.w	$4F ; Number of words to load in Ram Array ($0..$4F) -> move.w	(a0)+,d1
		dc.w	$550,$554,$551,$555,$558,$55C,$559,$55D
		dc.w	$552,$556,$553,$557,$55A,$55E,$55B,$55F
		dc.w	$560,$564,$561,$565,$568,$56C,$569,$56D
		dc.w	$562,$566,$563,$567,$56A,$56E,$56B,$56F
		dc.w	$570,$574,$571,$575,$578,$57C,$579,$57D
		dc.w	$572,$576,$573,$577,$57A,$57E,$57B,$57F
		dc.w	$E540,$E544,$E541,$E545,$E548,$E54C,$E549,$E54D
		dc.w	$E542,$E546,$E543,$E547,$E54A,$E54E,$E54B,$E54F
		dc.w	$E330,$E334,$E331,$E335,$E338,$E33C,$E339,$E33D
		dc.w	$E332,$E336,$E333,$E337,$E33A,$E33E,$E33B,$E33F
;------------------------------------------------------------------------------- 
Map16Delta_CNz_2P: 
		dc.w	$1760 ; Ram Address to start loading ($1760+$FFFF9000) -> add.w	(a0)+,a1
		dc.w	$4F ; Number of words to load in Ram Array ($0..$4F) -> move.w	(a0)+,d1
		dc.w	$750,$754,$751,$755,$758,$75C,$759,$75D
		dc.w	$752,$756,$753,$757,$75A,$75E,$75B,$75F
		dc.w	$760,$764,$761,$765,$768,$76C,$769,$76D
		dc.w	$762,$766,$763,$767,$76A,$76E,$76B,$76F
		dc.w	$770,$774,$771,$775,$778,$77C,$779,$77D
		dc.w	$772,$776,$773,$777,$77A,$77E,$77B,$77F
		dc.w	$E740,$E744,$E741,$E745,$E748,$E74C,$E749,$E74D
		dc.w	$E742,$E746,$E743,$E747,$E74A,$E74E,$E74B,$E74F
		dc.w	$E330,$E334,$E331,$E335,$E338,$E33C,$E339,$E33D
		dc.w	$E332,$E336,$E333,$E337,$E33A,$E33E,$E33B,$E33F
;===============================================================================
; Casino Night Mappings 16x16 Delta 
; [ End ]
;=============================================================================== 

;===============================================================================
; Chemical Plant Mappings 16x16 Delta 
; [ Begin ]
;=============================================================================== 
Map16Delta_CPz: 
		dc.w	$17F8 ; Ram Address to start loading ($17F8+$FFFF9000) -> add.w	(a0)+,a1
		dc.w	$3 ; Number of words to load in Ram Array ($0..$3) -> move.w	(a0)+,d1
		dc.w	$4370,$4371,$4370,$4371
;===============================================================================
; Chemical Plant Mappings 16x16 Delta 
; [ End ]
;=============================================================================== 

;===============================================================================
; Dath Egg Mappings 16x16 Delta 
; [ Begin ]
;=============================================================================== 
Map16Delta_DEz: 
		dc.w	$17F8 ; Ram Address to start loading ($17F8+$FFFF9000) -> add.w	(a0)+,a1
		dc.w	$3 ; Number of words to load in Ram Array ($0..$3) -> move.w	(a0)+,d1
		dc.w	$4326,$4327,$4326,$4327 
;===============================================================================
; Dath Egg Mappings 16x16 Delta 
; [ End ]
;=============================================================================== 

;===============================================================================
; Neo Green Hill Mappings 16x16 Delta 
; [ Begin ]
;=============================================================================== 
Map16Delta_NGHz: 
		dc.w	$17C0 ; Ram Address to start loading ($17C0+$FFFF9000) -> add.w	(a0)+,a1
		dc.w	$1F ; Number of words to load in Ram Array ($0..$1F) -> move.w	(a0)+,d1
		dc.w	$C428,$C429,$C42A,$C42B,$C42C,$C42D,$C42E,$C42F
		dc.w	$C430,$C431,$C432,$C433,$C563,$C564,$C565,$C566
		dc.w	$4428,$4429,$442A,$442B,$442C,$442D,$442E,$442F
		dc.w	$4430,$4431,$4432,$4433,$4563,$4564,$4565,$4566
;===============================================================================
; Null Mappings 16x16 Delta 
; [ Begin ]
;=============================================================================== 
Map16Delta_Null: 
		dc.w	$0 ; Null 
;===============================================================================
; Null Mappings 16x16 Delta 
; [ End ]
;=============================================================================== 
loc_3C604:
		lea	(Hill_Top_Background),a0 
		lea	($FFFFB800).w,a4
		bsr.w	loc_3C640
		lea	($FFFFB800).w,a1
		lea	HTz_Ram_Dyn_Sprites(pc),a4 
		moveq	#0,d2
		moveq	#7,d4
loc_3C61E: 
		moveq	#5,d3
loc_3C620: 
		moveq	#$FFFFFFFF,d0
		move.w	(a4)+,d0
		move.l	d0,a2
		moveq	#$1F,d1
loc_3C628: 
		move.l	(a1),(a2)+
		move.l	d2,(a1)+
		dbra	d1,loc_3C628
		dbra	d3,loc_3C620
		add.w	#$C,a4
		dbra	d4,loc_3C61E
		rts
;--------------------------------------------------------------------------------
		nop
loc_3C640:
		jmp	NemesisDec_ToRAM 
;===============================================================================
; Sub Routine Load_16x16_Mappings_For_Dyn_Sprites
; [ End ]
;=============================================================================== 
		cnop	0,4 ; Filler 
;===============================================================================
; Sub Routine loc_3C648
; [ Begin ]
;===============================================================================
loc_3C648:
		tst.w	(Ring_count).w
		beq.s	loc_3C664
		moveq	#0,d1
		btst	#3,($FFFFFE05).w
		bne.s	loc_3C662
		cmp.b	#9,($FFFFFE23).w
		bne.s	loc_3C662
		addq.w	#2,d1
loc_3C662:
		bra.s	loc_3C67A
loc_3C664:
		moveq	#0,d1
		btst	#3,($FFFFFE05).w
		bne.s	loc_3C67A
		addq.w	#1,d1
		cmp.b	#9,($FFFFFE23).w
		bne.s	loc_3C67A
		addq.w	#2,d1
loc_3C67A:
		move.w	#$90,d3
		move.w	#$108,d2
		lea	(loc_3C89A),a1
		move.w	#$86CA,a3
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bmi.s	loc_3C69C
		bsr.w	loc_3D816
loc_3C69C:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_3C648
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine loc_3C69E
; [ Begin ]
;===============================================================================

loc_3C69E:
		tst.w	(Ring_count).w
		beq.s	loc_3C6BA
		moveq	#0,d1
		btst	#3,($FFFFFE05).w
		bne.s	loc_3C6B8
		cmp.b	#9,($FFFFFE23).w
		bne.s	loc_3C6B8
		addq.w	#2,d1
loc_3C6B8:
		bra.s	loc_3C6D0
loc_3C6BA:
		moveq	#0,d1
		btst	#3,($FFFFFE05).w
		bne.s	loc_3C6D0
		addq.w	#1,d1
		cmp.b	#9,($FFFFFE23).w
		bne.s	loc_3C6D0
		addq.w	#2,d1
loc_3C6D0:
		move.w	#$90,d3
		move.w	#$188,d2
		lea	(loc_3C9EA),a1
		move.w	#$8365,a3
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bsr.w	loc_3D810
		move.w	#$B8,d3
		move.w	#$108,d2
		move.w	#$8371,a3
		moveq	#0,d7
		move.b	($FFFFFE23).w,d7
		bsr.w	loc_3C750
		bsr.w	loc_3C78C
		moveq	#0,d7
		move.b	($FFFFFE24).w,d7
		bsr.w	loc_3C75A
		move.w	#$C0,d3
		move.w	#$118,d2
		move.w	#$8371,a3
		moveq	#0,d7
		move.w	(Ring_count).w,d7
		bsr.w	loc_3C7A6
		moveq	#4,d1
		move.w	#$90,d3
		move.w	#$188,d2
		lea	(loc_3C9EA),a1
		move.w	#$8365,a3
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bsr.w	loc_3D810
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
loc_3C750:
		lea	(loc_3CFB4),a4
		moveq	#0,d6
		bra.s	loc_3C762
loc_3C75A:
		lea	(loc_3CFB0),a4
		moveq	#1,d6
loc_3C762:
		moveq	#0,d1
		move.l	(a4)+,d4
loc_3C766: 
		sub.l	d4,d7
		bcs.s	loc_3C76E
		addq.w	#1,d1
		bra.s	loc_3C766
loc_3C76E:
		add.l	d4,d7
		lea	(loc_3CA82),a1
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bsr.w	loc_3D810
		addq.w	#8,d3
		dbra	d6,loc_3C762
		rts
;--------------------------------------------------------------------------------
loc_3C78C:
		moveq	#$A,d1
		lea	(loc_3CA82),a1
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bsr.w	loc_3D810
		addq.w	#8,d3
		rts
;--------------------------------------------------------------------------------
loc_3C7A6:
		lea	(loc_3CFAC),a4
		moveq	#2,d6
loc_3C7AE: 
		moveq	#0,d1
		move.l	(a4)+,d4
loc_3C7B2: 
		sub.l	d4,d7
		bcs.s	loc_3C7BA
		addq.w	#1,d1
		bra.s	loc_3C7B2
loc_3C7BA:
		add.l	d4,d7
		tst.w	d6
		beq.s	loc_3C7CC
		tst.w	d1
		beq.s	loc_3C7C8
		bset	#$1F,d6
loc_3C7C8:
		tst.l	d6
		bpl.s	loc_3C7E0
loc_3C7CC:
		lea	(loc_3CA82),a1
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bsr.w	loc_3D810
loc_3C7E0:
		addq.w	#8,d3
		dbra	d6,loc_3C7AE
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine loc_3C69E
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine loc_3C7E8
; [ Begin ]
;===============================================================================
loc_3C7E8:
		tst.w	($FFFFFED0).w
		beq.s	loc_3C804
		moveq	#0,d1
		btst	#3,($FFFFFE05).w
		bne.s	loc_3C802
		cmp.b	#9,($FFFFFE23).w
		bne.s	loc_3C802
		addq.w	#2,d1
loc_3C802:
		bra.s	loc_3C81A
loc_3C804:
		moveq	#0,d1
		btst	#3,($FFFFFE05).w
		bne.s	loc_3C81A
		addq.w	#1,d1
		cmp.b	#9,($FFFFFE23).w
		bne.s	loc_3C81A
		addq.w	#2,d1
loc_3C81A:
		move.w	#$90,d3
		move.w	#$268,d2
		lea	(loc_3C9EA),a1
		move.w	#$8365,a3
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bsr.w	loc_3D810
		move.w	#$B8,d3
		move.w	#$1E8,d2
		move.w	#$8371,a3
		moveq	#0,d7
		move.b	($FFFFFED3).w,d7
		bsr.w	loc_3C750
		bsr.w	loc_3C78C
		moveq	#0,d7
		move.b	($FFFFFED4).w,d7
		bsr.w	loc_3C75A
		move.w	#$C0,d3
		move.w	#$1F8,d2
		move.w	#$8371,a3
		moveq	#0,d7
		move.w	($FFFFFED0).w,d7
		bsr.w	loc_3C7A6
		moveq	#5,d1
		move.w	#$90,d3
		move.w	#$268,d2
		lea	(loc_3C9EA),a1
		move.w	#$8340,a3
		add.w	d1,d1
		add.w	0(a1,d1),a1
		move.w	(a1)+,d1
		subq.w	#1,d1
		bsr.w	loc_3D810
		moveq	#0,d4
		rts
;--------------------------------------------------------------------------------
;------------------------------------------------------------------------------- 
loc_3C89A:
		dc.w	loc_3C8A2-loc_3C89A
		dc.w	loc_3C8F4-loc_3C89A
		dc.w	loc_3C946-loc_3C89A
		dc.w	loc_3C998-loc_3C89A
loc_3C8A2:
		dc.w	$A
		dc.l	$800D2000,$20000000,$800D2018,$200C0020
		dc.l	$800D2020,$20100040,$900D2010,$20080000
		dc.l	$900D2028,$20140028,$A00D2008,$20040000
		dc.l	$A0012000,$20000020,$A0092030,$20180030
		dc.l	$4005010A,$850000,$400D210E,$20870010
loc_3C8F4:
		dc.w	$A
		dc.l	$800D2000,$20000000,$800D2018,$200C0020
		dc.l	$800D2020,$20100040,$900D2010,$20080000
		dc.l	$900D2028,$20140028,$A00D0008,$40000
		dc.l	$A0010000,$20,$A0092030,$20180030
		dc.l	$4005010A,$850000,$400D210E,$20870010
loc_3C946:
		dc.w	$A
		dc.l	$800D2000,$20000000,$800D2018,$200C0020
		dc.l	$800D2020,$20100040,$900D0010,$80000
		dc.l	$900D2028,$20140028,$A00D2008,$20040000
		dc.l	$A0012000,$20000020,$A0092030,$20180030
		dc.l	$4005010A,$850000,$400D210E,$20870010
loc_3C998:
		dc.w	$A
		dc.l	$800D2000,$20000000,$800D2018,$200C0020
		dc.l	$800D2020,$20100040,$900D0010,$80000
		dc.l	$900D2028,$20140028,$A00D0008,$40000
		dc.l	$A0010000,$20,$A0092030,$20180030
		dc.l	$4005010A,$850000,$400D210E,$20870010 
;-------------------------------------------------------------------------------
loc_3C9EA:
		dc.w	loc_3C9F6-loc_3C9EA
		dc.w	loc_3CA10-loc_3C9EA
		dc.w	loc_3CA2A-loc_3C9EA
		dc.w	loc_3CA44-loc_3C9EA
		dc.w	loc_3CA5E-loc_3C9EA
		dc.w	loc_3CA70-loc_3C9EA
loc_3C9F6:
		dc.w	$3
		dc.l	$800D2010,$20080000,$900D2008,$20040000
		dc.l	$90012000,$20000020
loc_3CA10:
		dc.w	$3
		dc.l	$800D2010,$20080000,$900D0008,$40000
		dc.l	$90010000,$20
loc_3CA2A:
		dc.w	$3
		dc.l	$800D0010,$80000,$900D2008,$20040000
		dc.l	$90012000,$20000020
loc_3CA44:
		dc.w	$3
		dc.l	$800D0010,$80000,$900D0008,$40000
		dc.l	$90010000,$20
loc_3CA5E:
		dc.w	$2
		dc.l	$4005010A,$850000,$400D210E,$20870010
loc_3CA70:
		dc.w	$2
		dc.l	$4005001C,$E0000,$400D2078,$203C0010
;------------------------------------------------------------------------------- 
loc_3CA82:
		dc.w	loc_3CA98-loc_3CA82
		dc.w	loc_3CAA2-loc_3CA82
		dc.w	loc_3CAAC-loc_3CA82
		dc.w	loc_3CAB6-loc_3CA82
		dc.w	loc_3CAC0-loc_3CA82
		dc.w	loc_3CACA-loc_3CA82
		dc.w	loc_3CAD4-loc_3CA82
		dc.w	loc_3CADE-loc_3CA82
		dc.w	loc_3CAE8-loc_3CA82
		dc.w	loc_3CAF2-loc_3CA82
		dc.w	loc_3CAFC-loc_3CA82
loc_3CA98:
		dc.w	$1
		dc.l	$12000,$20000000
loc_3CAA2:
		dc.w	$1
		dc.l	$12002,$20010000
loc_3CAAC:
		dc.w	$1
		dc.l	$12004,$20020000
loc_3CAB6:
		dc.w	$1
		dc.l	$12006,$20030000
loc_3CAC0:
		dc.w	$1
		dc.l	$12008,$20040000
loc_3CACA:
		dc.w	$1
		dc.l	$1200A,$20050000
loc_3CAD4:
		dc.w	$1
		dc.l	$1200C,$20060000
loc_3CADE:
		dc.w	$1
		dc.l	$1200E,$20070000
loc_3CAE8:
		dc.w	$1
		dc.l	$12010,$20080000
loc_3CAF2:
		dc.w	$1
		dc.l	$12012,$20090000
loc_3CAFC:
		dc.w	$1
		dc.l	$12014,$200A0000 
;===============================================================================
; Sub Routine loc_3C7E8
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine AddPoints
; [ Begin ]
;=============================================================================== 
Add_Points: 
		move.b	#1,($FFFFFE1F).w
		lea	($FFFFFE26).w,a3
		add.l	d0,(a3)
		move.l	#$F423F,d1
		cmp.l	(a3),d1
		bhi.s	loc_3CB1E
		move.l	d1,(a3)
loc_3CB1E:
		move.l	(a3),d0
		cmp.l	($FFFFFFC0).w,d0
		bcs.s	loc_3CB40
		add.l	#$1388,($FFFFFFC0).w
		addq.b	#1,(Life_count).w
		addq.b	#1,($FFFFFE1C).w
		move.w	#$98,d0
		jmp	Play_Music 
loc_3CB40:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine AddPoints
; [ End ]
;=============================================================================== 
		 
;===============================================================================
; Sub Routine AddPoints_1
; [ Begin ]
;===============================================================================
AddPoints_1: 
		tst.w	($FFFFFFD8).w
		beq.s	Add_Points 
		cmp.w	#$B000,a3
		beq.s	Add_Points 
		move.b	#1,($FFFFFECB).w
		lea	($FFFFFED6).w,a3
		add.l	d0,(a3)
		move.l	#$F423F,d1
		cmp.l	(a3),d1
		bhi.s	loc_3CB66
		move.l	d1,(a3)
loc_3CB66:
		move.l	(a3),d0
		cmp.l	($FFFFFFC4).w,d0
		bcs.s	loc_3CB88
		add.l	#$1388,($FFFFFFC4).w
		addq.b	#1,($FFFFFEC6).w
		addq.b	#1,($FFFFFEC8).w
		move.w	#$98,d0
		jmp	Play_Music 
loc_3CB88:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine AddPoints_1
; [ End ]
;===============================================================================

;===============================================================================
; Sub Routine HudUpdate
; [ Begin ]
;===============================================================================
HudUpdate: 
		nop
		lea	(VDP_data_port),a6
		tst.w	($FFFFFFD8).w
		bne.w	loc_3CD3C
		tst.w	($FFFFFFFA).w
		bne.w	loc_3CC90
		tst.b	($FFFFFE1F).w
		beq.s	loc_3CBBA
		clr.b	($FFFFFE1F).w
		move.l	#$5C800003,d0
		move.l	($FFFFFE26).w,d1
		bsr.w	loc_3CEEA
loc_3CBBA:
		tst.b	(Update_HUD_rings).w
		beq.s	loc_3CBDA
		bpl.s	loc_3CBC6
		bsr.w	loc_3CDFE
loc_3CBC6:
		clr.b	(Update_HUD_rings).w
		move.l	#$5F400003,d0
		moveq	#0,d1
		move.w	(Ring_count).w,d1
		bsr.w	loc_3CEE0
loc_3CBDA:
		tst.b	($FFFFFE1E).w
		beq.s	loc_3CC38
		tst.w	(Game_paused).w
		bne.s	loc_3CC38
		lea	($FFFFFE22).w,a1
		cmp.l	#$93B3B,(a1)+
		beq	Time_Over 
		addq.b	#1,-(a1)
		cmp.b	#$3C,(a1)
		bcs.s	loc_3CC38
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmp.b	#$3C,(a1)
		bcs.s	loc_3CC18
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmp.b	#9,(a1)
		bcs.s	loc_3CC18
		move.b	#9,(a1)
loc_3CC18:
		move.l	#$5E400003,d0
		moveq	#0,d1
		move.b	($FFFFFE23).w,d1
		bsr.w	loc_3CFB8
		move.l	#$5EC00003,d0
		moveq	#0,d1
		move.b	($FFFFFE24).w,d1
		bsr.w	loc_3CFC0
loc_3CC38:
		tst.b	($FFFFFE1C).w
		beq.s	loc_3CC46
		clr.b	($FFFFFE1C).w
		bsr.w	loc_3D086
loc_3CC46:
		tst.b	($FFFFF7D6).w
		beq.s	loc_3CC78
		clr.b	($FFFFF7D6).w
		move.l	#$64000002,(VDP_control_port)
		moveq	#0,d1
		move.w	($FFFFFF8E).w,d1
		bsr.w	loc_3D018
		moveq	#0,d1
		move.w	($FFFFF7D2).w,d1
		bsr.w	loc_3D018
		moveq	#0,d1
		move.w	($FFFFF7D4).w,d1
		bsr.w	loc_3D018
loc_3CC78:
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Time Over
; [ Begin ]
;=============================================================================== 
Time_Over: 
		clr.b	($FFFFFE1E).w
		lea	(Object_RAM).w,a0
		move.l	a0,a2
		bsr.w	Kill_Player 
		move.b	#1,($FFFFFE1A).w
		rts
;--------------------------------------------------------------------------------
;===============================================================================
; Sub Routine Time Over
; [ End ]
;=============================================================================== 
loc_3CC90:
		bsr.w	loc_3CE88
		tst.b	(Update_HUD_rings).w
		beq.s	loc_3CCB4
		bpl.s	loc_3CCA0
		bsr.w	loc_3CDFE
loc_3CCA0:
		clr.b	(Update_HUD_rings).w
		move.l	#$5F400003,d0
		moveq	#0,d1
		move.w	(Ring_count).w,d1
		bsr.w	loc_3CEE0
loc_3CCB4:
		move.l	#$5EC00003,d0
		moveq	#0,d1
		move.b	($FFFFF62C).w,d1
		bsr.w	loc_3CFC0
		tst.b	($FFFFFE1C).w
		beq.s	loc_3CCD2
		clr.b	($FFFFFE1C).w
		bsr.w	loc_3D086
loc_3CCD2:
		tst.b	($FFFFF7D6).w
		beq.s	loc_3CD04
		clr.b	($FFFFF7D6).w
		move.l	#$64000002,(VDP_control_port)
		moveq	#0,d1
		move.w	($FFFFFF8E).w,d1
		bsr.w	loc_3D018
		moveq	#0,d1
		move.w	($FFFFF7D2).w,d1
		bsr.w	loc_3D018
		moveq	#0,d1
		move.w	($FFFFF7D4).w,d1
		bsr.w	loc_3D018
loc_3CD04:
		tst.w	(Game_paused).w
		bne.s	loc_3CD3A
		lea	($FFFFFE22).w,a1
		cmp.l	#$93B3B,(a1)+
		nop
		addq.b	#1,-(a1)
		cmp.b	#$3C,(a1)
		bcs.s	loc_3CD3A
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmp.b	#$3C,(a1)
		bcs.s	loc_3CD3A
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmp.b	#9,(a1)
		bcs.s	loc_3CD3A
		move.b	#9,(a1)
loc_3CD3A:
		rts
;--------------------------------------------------------------------------------
loc_3CD3C:
		tst.w	(Game_paused).w
		bne.w	loc_3CDCC
		tst.b	($FFFFFE1E).w
		beq.s	loc_3CD7A
		lea	($FFFFFE22).w,a1
		cmp.l	#$93B3B,(a1)+
		beq.s	loc_3CDCE
		addq.b	#1,-(a1)
		cmp.b	#$3C,(a1)
		bcs.s	loc_3CD7A
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmp.b	#$3C,(a1)
		bcs.s	loc_3CD7A
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmp.b	#9,(a1)
		bcs.s	loc_3CD7A
		move.b	#9,(a1)
loc_3CD7A:
		tst.b	($FFFFFECA).w
		beq.s	loc_3CDB0
		lea	($FFFFFED2).w,a1
		cmp.l	#$93B3B,(a1)+
		beq.s	loc_3CDE8
		addq.b	#1,-(a1)
		cmp.b	#$3C,(a1)
		bcs.s	loc_3CDB0
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmp.b	#$3C,(a1)
		bcs.s	loc_3CDB0
		move.b	#0,(a1)
		addq.b	#1,-(a1)
		cmp.b	#9,(a1)
		bcs.s	loc_3CDB0
		move.b	#9,(a1)
loc_3CDB0:
		tst.b	($FFFFFE1C).w
		beq.s	loc_3CDBE
		clr.b	($FFFFFE1C).w
		bsr.w	loc_3D086
loc_3CDBE:
		tst.b	($FFFFFEC8).w
		beq.s	loc_3CDCC
		clr.b	($FFFFFEC8).w
		bsr.w	loc_3D078
loc_3CDCC:
		rts
;--------------------------------------------------------------------------------
loc_3CDCE:
		clr.b	($FFFFFE1E).w
		lea	(Object_RAM).w,a0
		move.l	a0,a2
		bsr.w	Kill_Player 
		move.b	#1,($FFFFFE1A).w
		tst.b	($FFFFFECA).w
		beq.s	loc_3CDFC
loc_3CDE8:
		clr.b	($FFFFFECA).w
		lea	($FFFFB040).w,a0
		move.l	a0,a2
		bsr.w	Kill_Player 
		move.b	#1,($FFFFFECC).w
loc_3CDFC:
		rts
;--------------------------------------------------------------------------------
loc_3CDFE:
		move.l	#$5F400003,(VDP_control_port)
		lea	loc_3CE84(pc),a2
		move.w	#2,d2
		bra.s	loc_3CE34
Head_Up_Display_Base: 
		lea	(VDP_data_port),a6
		bsr.w	loc_3D086
		tst.w	($FFFFFFD8).w
		bne.s	loc_3CE60
		move.l	#$5C400003,(VDP_control_port)
		lea	loc_3CE78(pc),a2
		move.w	#$E,d2
loc_3CE34:
		lea	HUD_Art_Numbers(pc),a1 
loc_3CE38: 
		move.w	#$F,d1
		move.b	(a2)+,d0
		bmi.s	loc_3CE54
		ext.w	d0
		lsl.w	#5,d0
		lea	0(a1,d0),a3
loc_3CE48: 
		move.l	(a3)+,(a6)
		dbra	d1,loc_3CE48
loc_3CE4E: 
		dbra	d2,loc_3CE38
		rts
;--------------------------------------------------------------------------------
loc_3CE54:
		move.l	#0,(a6)
		dbra	d1,loc_3CE54
		bra.s	loc_3CE4E
loc_3CE60:
		bsr.w	loc_3D078
		move.l	#HUD_Art_Numbers,d1 
		move.w	#$DC40,d2
		move.w	#$160,d3
		jmp	DMA_68KtoVRAM 
loc_3CE78:
		dc.b	$16,$FF,$FF,$FF,$FF,$FF,$FF,$0,$0,$14,$0,$0
loc_3CE84:
		dc.b	$FF,$FF,$0,$0
loc_3CE88:
		move.l	#$5C400003,(VDP_control_port)
		move.w	($FFFFEE00).w,d1
		swap.w	d1
		move.w	($FFFFB008).w,d1
		bsr.s	loc_3CEA8
		move.w	(Camera_Y_pos).w,d1
		swap.w	d1
		move.w	(Object_RAM+y_pos).w,d1
loc_3CEA8:
		moveq	#7,d6
		lea	(HUD_Art_Debug_Numbers),a1 
loc_3CEB0: 
		rol.w	#4,d1
		move.w	d1,d2
		and.w	#$F,d2
		cmp.w	#$A,d2
		bcs.s	loc_3CEC2
		add.w	#7,d2
loc_3CEC2:
		lsl.w	#5,d2
		lea	0(a1,d2),a3
		rept 8
		move.l	(a3)+,(a6)
		endr
		swap.w	d1
		dbra	d6,loc_3CEB0
		rts
;--------------------------------------------------------------------------------
loc_3CEE0:
		lea	(loc_3CFAC),a2
		moveq	#2,d6
		bra.s	loc_3CEF2
loc_3CEEA:
		lea	(loc_3CFA0),a2
		moveq	#5,d6
loc_3CEF2:
		moveq	#0,d4
		lea	HUD_Art_Numbers(pc),a1 
loc_3CEF8: 
		moveq	#0,d2
		move.l	(a2)+,d3
loc_3CEFC: 
		sub.l	d3,d1
		bcs.s	loc_3CF04
		addq.w	#1,d2
		bra.s	loc_3CEFC
loc_3CF04:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_3CF0E
		move.w	#1,d4
loc_3CF0E:
		tst.w	d4
		beq.s	loc_3CF3C
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	0(a1,d2),a3
		rept 16
		move.l	(a3)+,(a6)
		endr
loc_3CF3C:
		add.l	#$400000,d0
		dbra	d6,loc_3CEF8
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Time_Count_Down: 
		move.l	#$5F800003,(VDP_control_port)
		lea	(VDP_data_port),a6
		lea	(loc_3CFB0),a2
		moveq	#1,d6
		moveq	#0,d4
		lea	HUD_Art_Numbers(pc),a1 
loc_3CF66: 
		moveq	#0,d2
		move.l	(a2)+,d3
loc_3CF6A: 
		sub.l	d3,d1
		bcs.s	loc_3CF72
		addq.w	#1,d2
		bra.s	loc_3CF6A
loc_3CF72:
		add.l	d3,d1
		lsl.w	#6,d2
		lea	0(a1,d2),a3
		rept 16
		move.l	(a3)+,(a6)
		endr
		dbra	d6,loc_3CF66
		rts
;--------------------------------------------------------------------------------
loc_3CFA0:
		dc.l	$186A0,$2710
loc_3CFA8: 
		dc.l	$3E8
loc_3CFAC: 
		dc.l	$64
loc_3CFB0: 
		dc.l	$A
loc_3CFB4: 
		dc.l	$1 
loc_3CFB8: 
		lea	loc_3CFB4(pc),a2
		moveq	#0,d6
		bra.s	loc_3CFC6
loc_3CFC0: 
		lea	loc_3CFB0(pc),a2
		moveq	#1,d6
loc_3CFC6:
		moveq	#0,d4
		lea	HUD_Art_Numbers(pc),a1 
loc_3CFCC: 
		moveq	#0,d2
		move.l	(a2)+,d3
loc_3CFD0: 
		sub.l	d3,d1
		bcs.s	loc_3CFD8
		addq.w	#1,d2
		bra.s	loc_3CFD0
loc_3CFD8:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_3CFE2
		move.w	#1,d4
loc_3CFE2:
		lsl.w	#6,d2
		move.l	d0,4(a6)
		lea	0(a1,d2),a3
		rept 16
		move.l	(a3)+,(a6)
		endr
		add.l	#$400000,d0
		dbra	d6,loc_3CFCC
		rts
;--------------------------------------------------------------------------------
loc_3D018:
		lea	loc_3CFA8(pc),a2
		moveq	#3,d6
		moveq	#0,d4
		lea	HUD_Art_Numbers(pc),a1 
loc_3D024: 
		moveq	#0,d2
		move.l	(a2)+,d3
loc_3D028: 
		sub.l	d3,d1
		bcs.s	loc_3D030
		addq.w	#1,d2
		bra.s	loc_3D028
loc_3D030:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_3D03A
		move.w	#1,d4
loc_3D03A:
		tst.w	d4
		beq.s	loc_3D06A
		lsl.w	#6,d2
		lea	0(a1,d2),a3
		rept 16
		move.l	(a3)+,(a6)
		endr
loc_3D064: 
		dbra	d6,loc_3D024
		rts
;--------------------------------------------------------------------------------
loc_3D06A:
		moveq	#$F,d5
loc_3D06C: 
		move.l	#0,(a6)
		dbra	d5,loc_3D06C
		bra.s	loc_3D064

loc_3D078:
		move.l	#$5FA00003,d0
		moveq	#0,d1
		move.b	($FFFFFEC6).w,d1
		bra.s	loc_3D092
loc_3D086:
		move.l	#$7BA00003,d0
		moveq	#0,d1
		move.b	(Life_count).w,d1
loc_3D092:
		lea	loc_3CFB0(pc),a2
		moveq	#1,d6
		moveq	#0,d4
		lea	HUD_Art_Life_Numbers(pc),a1 
loc_3D09E: 
		move.l	d0,4(a6)
		moveq	#0,d2
		move.l	(a2)+,d3
loc_3D0A6: 
		sub.l	d3,d1
		bcs.s	loc_3D0AE
		addq.w	#1,d2
		bra.s	loc_3D0A6
loc_3D0AE:
		add.l	d3,d1
		tst.w	d2
		beq.s	loc_3D0B8
		move.w	#1,d4
loc_3D0B8:
		tst.w	d4
		beq.s	loc_3D0DE
loc_3D0BC: 
		lsl.w	#5,d2
		lea	0(a1,d2),a3
		rept 8
		move.l	(a3)+,(a6)
		endr
loc_3D0D2:
		add.l	#$400000,d0
		dbra	d6,loc_3D09E
		rts
;--------------------------------------------------------------------------------
loc_3D0DE:
		tst.w	d6
		beq.s	loc_3D0BC
		moveq	#7,d5
loc_3D0E4: 
		move.l	#0,(a6)
		dbra	d5,loc_3D0E4
		bra.s	loc_3D0D2 
HUD_Art_Numbers: 
		incbin 'artunc/hud_numb.dat'
HUD_Art_Life_Numbers: 
		incbin 'artunc/hud_num2.dat'
HUD_Art_Debug_Numbers: 
		incbin 'artunc/hud_debg.dat'
loc_3D810:
		jmp	(loc_13716)
loc_3D816:
		jmp	(loc_1317A) 
;===============================================================================
; Sub Routine 
; [ End ]
;=============================================================================== 

;===============================================================================
; Sub Routine Debug_Mode
; [ Begin ]
;=============================================================================== 
Debug_Mode: 
		moveq	#0,d0
		move.b	(Debug_placement_mode).w,d0
		move.w	loc_3D82A(pc,d0),d1
		jmp	loc_3D82A(pc,d1)
loc_3D82A:
		dc.w	loc_3D82E-loc_3D82A
		dc.w	loc_3D8AC-loc_3D82A
loc_3D82E:
		addq.b	#2,(Debug_placement_mode).w
		move.w	(Camera_Min_Y_pos).w,($FFFFFFCC).w
		move.w	(Camera_Max_Y_pos).w,($FFFFFFCE).w
		cmp.b	#$10,($FFFFFE10).w
		bne.s	loc_3D852
		move.w	#0,(Camera_Min_X_pos).w
		move.w	#$3FFF,(Camera_Max_X_pos).w
loc_3D852:
		and.w	#$7FF,(Object_RAM+y_pos).w
		and.w	#$7FF,(Camera_Y_pos).w
		and.w	#$7FF,($FFFFEE0C).w
		move.b	#0,$1A(a0)
		move.b	#0,$1C(a0)
		cmp.b	#$10,(Game_Mode).w
		bne.s	loc_3D87C
		moveq	#6,d0
		bra.s	loc_3D882
loc_3D87C:
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
loc_3D882:
		lea	(Debug_Index),a2 
		add.w	d0,d0
		add.w	0(a2,d0),a2
		move.w	(a2)+,d6
		cmp.b	(Debug_object).w,d6
		bhi.s	loc_3D89C
		move.b	#0,(Debug_object).w
loc_3D89C:
		bsr.w	loc_3DA8C
		move.b	#$C,($FFFFFE0A).w
		move.b	#1,($FFFFFE0B).w
loc_3D8AC:
		moveq	#6,d0
		cmp.b	#$10,(Game_Mode).w
		beq.s	loc_3D8BC
		moveq	#0,d0
		move.b	($FFFFFE10).w,d0
loc_3D8BC:
		lea	(Debug_Index),a2 
		add.w	d0,d0
		add.w	0(a2,d0),a2
		move.w	(a2)+,d6
		bsr.w	loc_3D8D4
		jmp	DisplaySprite 
loc_3D8D4:
		moveq	#0,d4
		move.w	#1,d1
		move.b	(Ctrl_1_Press).w,d4
		and.w	#$F,d4
		bne.s	loc_3D916
		move.b	(Ctrl_1_Held).w,d0
		and.w	#$F,d0
		bne.s	loc_3D8FE
		move.b	#$C,($FFFFFE0A).w
		move.b	#$F,($FFFFFE0B).w
		bra.w	loc_3D97A
loc_3D8FE:
		subq.b	#1,($FFFFFE0A).w
		bne.s	loc_3D91A
		move.b	#1,($FFFFFE0A).w
		addq.b	#1,($FFFFFE0B).w
		bne.s	loc_3D916
		move.b	#$FF,($FFFFFE0B).w
loc_3D916:
		move.b	(Ctrl_1_Held).w,d4
loc_3D91A:
		moveq	#0,d1
		move.b	($FFFFFE0B).w,d1
		addq.w	#1,d1
		swap.w	d1
		asr.l	#4,d1
		move.l	$C(a0),d2
		move.l	8(a0),d3
		btst	#0,d4
		beq.s	loc_3D944
		sub.l	d1,d2
		moveq	#0,d0
		move.w	(Camera_Min_Y_pos).w,d0
		swap.w	d0
		cmp.l	d0,d2
		bge.s	loc_3D944
		move.l	d0,d2
loc_3D944:
		btst	#1,d4
		beq.s	loc_3D95E
		add.l	d1,d2
		moveq	#0,d0
		move.w	(Camera_Max_Y_pos).w,d0
		add.w	#$DF,d0
		swap.w	d0
		cmp.l	d0,d2
		blt.s	loc_3D95E
		move.l	d0,d2
loc_3D95E:
		btst	#2,d4
		beq.s	loc_3D96A
		sub.l	d1,d3
		bcc.s	loc_3D96A
		moveq	#0,d3
loc_3D96A:
		btst	#3,d4
		beq.s	loc_3D972
		add.l	d1,d3
loc_3D972:
		move.l	d2,$C(a0)
		move.l	d3,8(a0)
loc_3D97A:
		btst	#6,(Ctrl_1_Held).w
		beq.s	loc_3D9B2
		btst	#5,(Ctrl_1_Press).w
		beq.s	loc_3D996
		subq.b	#1,(Debug_object).w
		bcc.s	loc_3D9AE
		add.b	d6,(Debug_object).w
		bra.s	loc_3D9AE
loc_3D996:
		btst	#6,(Ctrl_1_Press).w
		beq.s	loc_3D9B2
		addq.b	#1,(Debug_object).w
		cmp.b	(Debug_object).w,d6
		bhi.s	loc_3D9AE
		move.b	#0,(Debug_object).w
loc_3D9AE:
		bra.w	loc_3DA8C
loc_3D9B2:
		btst	#5,(Ctrl_1_Press).w
		beq.s	loc_3D9F6
		jsr	SingleObjectLoad 
		bne.s	loc_3D9F6
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	4(a0),0(a1)
		move.b	1(a0),1(a1)
		move.b	1(a0),$22(a1)
		and.b	#$7F,$22(a1)
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		lsl.w	#3,d0
		move.b	4(a2,d0),$28(a1)
		rts
;--------------------------------------------------------------------------------
loc_3D9F6:
		btst	#4,(Ctrl_1_Press).w
		beq.s	loc_3DA56
		moveq	#0,d0
		move.w	d0,(Debug_placement_mode).w
		lea	(Object_RAM).w,a1
		move.l	#Sonic_Mappings,4(a1) 
		move.w	#$780,2(a1)
		tst.w	($FFFFFFD8).w
		beq.s	loc_3DA22
		move.w	#$3C0,2(a1)
loc_3DA22:
		bsr.s	loc_3DA58
		move.b	#$13,$16(a1)
		move.b	#9,$17(a1)
		move.w	($FFFFFFCC).w,(Camera_Min_Y_pos).w
		move.w	($FFFFFFCE).w,(Camera_Max_Y_pos).w
		cmp.b	#$10,(Game_Mode).w
		bne.s	loc_3DA56
		move.b	#2,(Object_RAM+anim).w
		bset	#2,(Object_RAM+status).w
		bset	#1,(Object_RAM+status).w
loc_3DA56:
		rts
;--------------------------------------------------------------------------------
loc_3DA58:
		move.b	d0,$1C(a1)
		move.w	d0,$A(a1)
		move.w	d0,$E(a1)
		move.b	d0,$2A(a1)
		move.b	d0,$39(a1)
		move.w	d0,$10(a1)
		move.w	d0,$12(a1)
		move.w	d0,$14(a1)
		move.b	#2,$22(a1)
		move.b	#2,$24(a1)
		move.b	#0,$25(a1)
		rts
;--------------------------------------------------------------------------------
loc_3DA8C:
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		lsl.w	#3,d0
		move.l	0(a2,d0),4(a0)
		move.w	6(a2,d0),2(a0)
		move.b	5(a2,d0),$1A(a0)
		bsr.w	loc_3E388
		rts
;--------------------------------------------------------------------------------
Debug_Index: 
		dc.w	debug_GHz-debug_Index 
		dc.w	debug_Null-debug_Index 
		dc.w	debug_Null-debug_Index 
		dc.w	debug_Null-debug_Index 
		dc.w	debug_Mz-debug_Index 
		dc.w	debug_Mz-debug_Index 
		dc.w	debug_SFz-debug_Index 
		dc.w	debug_HTz-debug_Index 
		dc.w	debug_HPz-debug_Index 
		dc.w	debug_Null-debug_Index 
		dc.w	debug_OOz-debug_Index 
		dc.w	debug_DHz-debug_Index 
		dc.w	debug_CNz-debug_Index 
		dc.w	debug_CPz-debug_Index 
		dc.w	debug_Null-debug_Index 
		dc.w	debug_NGHz-debug_Index 
		dc.w	debug_SCz-debug_Index 
;------------------------------------------------------------------------------- 
Debug_Null: 
		dc.w	(((Debug_Null_End-debug_Null-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto 
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0
		dc.w	$26BC 
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680
Debug_Null_End: 
;------------------------------------------------------------------------------- 
Debug_GHz: 
		dc.w	(((Debug_GHz_End-debug_GHz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto 
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C
		dc.l	($3<<$18)|Layer_Switch_Mappings 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($49<<$18)|Waterfall_Mappings 
		dc.b	$0,$0
		dc.w	$239E
		dc.l	($49<<$18)|Waterfall_Mappings 
		dc.b	$2,$3
		dc.w	$239E
		dc.l	($49<<$18)|Waterfall_Mappings 
		dc.b	$4,$5
		dc.w	$239E
		dc.l	($18<<$18)|GHz_Platform_Mappings 
		dc.b	$1,$0
		dc.w	$4000
		dc.l	($18<<$18)|GHz_Platform_Mappings 
		dc.b	$9A,$1
		dc.w	$4000
		dc.l	($36<<$18)|Spikes_Mappings 
		dc.b	$0,$0
		dc.w	$2434
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$81,$0
		dc.w	$45C
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$90,$3
		dc.w	$470
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$A0,$6
		dc.w	$45C
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$30,$7
		dc.w	$43C
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$40,$A
		dc.w	$43C
		dc.l	($4B<<$18)|Buzzer_Mappings 
		dc.b	$0,$0
		dc.w	$3D2
		dc.l	($5C<<$18)|Masher_Mappings 
		dc.b	$0,$0
		dc.w	$414
		dc.l	($9D<<$18)|Coconuts_Mappings 
		dc.b	$1E,$0
		dc.w	$3EE
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680
Debug_GHz_End:
;------------------------------------------------------------------------------- 
Debug_Mz: 
		dc.w	(((Debug_Mz_End-debug_Mz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($3<<$18)|Layer_Switch_Mappings 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($42<<$18)|Steam_Vent_Mappings 
		dc.b	$1,$7
		dc.w	$6000
		dc.l	($64<<$18)|Pistons_Mappings 
		dc.b	$1,$0
		dc.w	$2000
		dc.l	($64<<$18)|Pistons_Mappings 
		dc.b	$11,$1
		dc.w	$2000
		dc.l	($65<<$18)|Mz_Platform_Mappings 
		dc.b	$80,$0
		dc.w	$6000
		dc.l	($65<<$18)|Mz_Platform_Mappings 
		dc.b	$13,$1
		dc.w	$6000
		dc.l	($47<<$18)|Switch_Mappings 
		dc.b	$0,$2
		dc.w	$424
		dc.l	($2D<<$18)|Automatic_Door_Mappings 
		dc.b	$1,$1
		dc.w	$6000
		dc.l	($66<<$18)|Springs_Wall_Mappings 
		dc.b	$1,$0
		dc.w	$8680
		dc.l	($66<<$18)|Springs_Wall_Mappings 
		dc.b	$11,$1
		dc.w	$8680
		dc.l	($68<<$18)|Block_Harpon_Mappings 
		dc.b	$0,$4
		dc.w	$6414
		dc.l	($69<<$18)|Screw_Nut_Mappings 
		dc.b	$4,$0
		dc.w	$2500
		dc.l	($6A<<$18)|Mz_Platform_Mappings 
		dc.b	$0,$1
		dc.w	$6000
		dc.l	($6B<<$18)|Mz_Platform_Mappings 
		dc.b	$7,$1
		dc.w	$6000
		dc.l	($6D<<$18)|Block_Harpon_Mappings 
		dc.b	$0,$0
		dc.w	$241C
		dc.l	($6E<<$18)|Machine_Mappings 
		dc.b	$0,$0
		dc.w	$6000
		dc.l	($6E<<$18)|Machine_Mappings 
		dc.b	$10,$1
		dc.w	$6000
		dc.l	($6E<<$18)|Machine_Mappings 
		dc.b	$20,$2
		dc.w	$6000
		dc.l	($70<<$18)|Rotating_Gears_Mappings 
		dc.b	$10,$0
		dc.w	$E378
		dc.l	($71<<$18)|Mz_Lava_Bubble_Mappings 
		dc.b	$22,$5
		dc.w	$4536
		dc.l	($1C<<$18)|Mz_Misc_Mappings 
		dc.b	$0,$0
		dc.w	$43FD
		dc.l	($1C<<$18)|Mz_Misc_Mappings 
		dc.b	$1,$1
		dc.w	$43FD
		dc.l	($1C<<$18)|Mz_Misc_Mappings 
		dc.b	$3,$2
		dc.w	$23FD
		dc.l	($65<<$18)|Mz_Platform_Mappings 
		dc.b	$B0,$0
		dc.w	$6000 
		dc.l	($9F<<$18)|Shellcracker_Mappings 
		dc.b	$24,$0
		dc.w	$31C
		dc.l	($A4<<$18)|Asteron_Mappings 
		dc.b	$2E,$0
		dc.w	$8368
		dc.l	($A1<<$18)|Slicer_Mappings 
		dc.b	$28,$0
		dc.w	$243C
		dc.l	($31<<$18)|Lava_Attributes_Mappings 
		dc.b	$0,$0
		dc.w	$8680
		dc.l	($31<<$18)|Lava_Attributes_Mappings 
		dc.b	$1,$1
		dc.w	$8680
		dc.l	($31<<$18)|Lava_Attributes_Mappings 
		dc.b	$2,$2
		dc.w	$8680
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680
Debug_Mz_End: 
;------------------------------------------------------------------------------- 
Debug_SFz: 
		dc.w	(((Debug_SFz_End-debug_SFz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC 
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($8B<<$18)|Layer_Switch_Mappings 
		dc.b	$0,$0
		dc.w	$6BC 
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($B3<<$18)|Clouds_Mappings 
		dc.b	$5E,$0
		dc.w	$454F
		dc.l	($B3<<$18)|Clouds_Mappings 
		dc.b	$60,$1
		dc.w	$454F
		dc.l	($B3<<$18)|Clouds_Mappings 
		dc.b	$62,$2
		dc.w	$454F
		dc.l	($B4<<$18)|Vertical_Helix_Mappings 
		dc.b	$64,$0
		dc.w	$A561
		dc.l	($B5<<$18)|Horizontal_Helix_Mappings 
		dc.b	$66,$0
		dc.w	$A3CD
		dc.l	($B5<<$18)|Horizontal_Helix_Mappings 
		dc.b	$68,$0
		dc.w	$A3CD
		dc.l	($AD<<$18)|Clucker_Mappings 
		dc.b	$42,$C
		dc.w	$379
		dc.l	($AE<<$18)|Clucker_Mappings 
		dc.b	$44,$B
		dc.w	$379
		dc.l	($B6<<$18)|Platform_Helix_Mappings 
		dc.b	$6A,$0
		dc.w	$A393
		dc.l	($B6<<$18)|Platform_Helix_Mappings 
		dc.b	$6C,$0
		dc.w	$A393
		dc.l	($B6<<$18)|Platform_Helix_Mappings 
		dc.b	$6E,$0
		dc.w	$A393
		dc.l	($B6<<$18)|Platform_Helix_Mappings 
		dc.b	$70,$0
		dc.w	$A393
		dc.l	($B7<<$18)|Vertical_Large_Laser_Mappings 
		dc.b	$72,$0
		dc.w	$C39F
		dc.l	($B8<<$18)|SFz_Cannon_Mappings 
		dc.b	$74,$0
		dc.w	$3AB
		dc.l	($B9<<$18)|Laser_Mappings 
		dc.b	$76,$0
		dc.w	$C3C3
		dc.l	($BA<<$18)|Conveyor_Belt_Wheels_Mappings 
		dc.b	$78,$0
		dc.w	$C3EA
		dc.l	($BC<<$18)|Ship_Boost_Mappings 
		dc.b	$7C,$0
		dc.w	$4465
		dc.l	($BD<<$18)|SFz_Elevators_Mappings 
		dc.b	$7E,$0
		dc.w	$E40E
		dc.l	($BD<<$18)|SFz_Elevators_Mappings 
		dc.b	$80,$0
		dc.w	$E40E
		dc.l	($BE<<$18)|Hatchway_Mappings 
		dc.b	$82,$0
		dc.w	$E41A
		dc.l	($BF<<$18)|Engine_Part_Mappings 
		dc.b	$84,$0
		dc.w	$E450
		dc.l	($C0<<$18)|Speed_Booster_Mappings 
		dc.b	$8,$0
		dc.w	$A45C
		dc.l	($C1<<$18)|Breakable_Wall_Mappings 
		dc.b	$88,$0
		dc.w	$E48C
		dc.l	($C2<<$18)|SFz_Boss_Access_Switch_Mappings 
		dc.b	$8A,$0
		dc.w	$A461
		dc.l	($19<<$18)|Rotating_Platforms_Mappings 
		dc.b	$38,$3
		dc.w	$A46D
		dc.l	($D9<<$18)|Rings_Mappings 
		dc.b	$0,$0
		dc.w	$26BC
		dc.l	($80<<$18)|Chain_Hook_Mappings 
		dc.b	$0,$0
		dc.w	$23FE
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680
Debug_SFz_End: 
;------------------------------------------------------------------------------- 
Debug_HTz: 
		dc.w	(((Debug_HTz_End-debug_HTz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($84<<$18)|Layer_Switch_Mappings 
		dc.b	$0,$0
		dc.w	$6BC 
		dc.l	($84<<$18)|Layer_Switch_Mappings 
		dc.b	$4,$4
		dc.w	$6BC
		dc.l	($3<<$18)|Layer_Switch_Mappings 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($18<<$18)|GHz_Platform_Mappings 
		dc.b	$1,$0
		dc.w	$4000
		dc.l	($18<<$18)|GHz_Platform_Mappings 
		dc.b	$9A,$1
		dc.w	$4000
		dc.l	($36<<$18)|Spikes_Mappings 
		dc.b	$0,$0
		dc.w	$2434
		dc.l	($14<<$18)|See_Saw_Mappings 
		dc.b	$0,$0
		dc.w	$3C6
		dc.l	($2D<<$18)|Automatic_Door_Mappings 
		dc.b	$0,$0
		dc.w	$2426
		dc.l	($2F<<$18)|Breakable_Floor_Mappings 
		dc.b	$0,$0
		dc.w	$C000
		dc.l	($20<<$18)|Lava_Bubble_Mappings 
		dc.b	$44,$2
		dc.w	$8416 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$81,$0
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$90,$3
		dc.w	$470 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$A0,$6
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$30,$7
		dc.w	$43C 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$40,$A
		dc.w	$43C
		dc.l	($16<<$18)|Teleferics_Mappings 
		dc.b	$0,$0
		dc.w	$43E6
		dc.l	($1C<<$18)|Teleferics_Mappings 
		dc.b	$4,$3
		dc.w	$43E6
		dc.l	($1C<<$18)|Teleferics_Mappings 
		dc.b	$5,$4
		dc.w	$43E6
		dc.l	($1C<<$18)|HTz_Misc_Mappings 
		dc.b	$7,$0
		dc.w	$4000
		dc.l	($1C<<$18)|HTz_Misc_Mappings 
		dc.b	$8,$1
		dc.w	$4000
		dc.l	($32<<$18)|HTz_Rock_Mappings 
		dc.b	$0,$0
		dc.w	$43B2
		dc.l	($31<<$18)|Lava_Attributes_Mappings 
		dc.b	$0,$0
		dc.w	$8680
		dc.l	($31<<$18)|Lava_Attributes_Mappings 
		dc.b	$1,$1
		dc.w	$8680
		dc.l	($31<<$18)|Lava_Attributes_Mappings 
		dc.b	$2,$2
		dc.w	$8680
		dc.l	($96<<$18)|Rexon_Mappings 
		dc.b	$E,$2
		dc.w	$637E
		dc.l	($92<<$18)|Spiker_Mappings 
		dc.b	$A,$0
		dc.w	$0
		dc.l	($95<<$18)|Sol_Mappings 
		dc.b	$0,$0
		dc.w	$0
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680
Debug_HTz_End: 
;------------------------------------------------------------------------------- 
Debug_HPz: 
		dc.w	(((Debug_HPz_End-debug_HPz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($71<<$18)|Hpz_Orbs_Mappings 
		dc.b	$11,$3
		dc.w	$E35A
		dc.l	($13<<$18)|Hpz_Waterfalls_Mappings 
		dc.b	$4,$4
		dc.w	$E315
		dc.l	($1A<<$18)|HPz_Collapsing_Platforms_Mappings 
		dc.b	$0,$0
		dc.w	$434A
		dc.l	($3<<$18)|Layer_Switch_Mappings 
		dc.b	$9,$1
		dc.w	$26BC 
		dc.l	($4F<<$18)|Dinobot_Mappings 
		dc.b	$0,$0
		dc.w	$500
		dc.l	($4C<<$18)|Batbot_Mappings 
		dc.b	$0,$0
		dc.w	$2530
		dc.l	($4D<<$18)|Rhinobot_Mappings 
		dc.b	$0,$0 
		dc.w	$23B2 
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680 
Debug_HPz_End: 
;-------------------------------------------------------------------------------
Debug_OOz: 
		dc.w	(((Debug_OOz_End-debug_OOz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($33<<$18)|Touch_Booster_Mappings 
		dc.b	$1,$0
		dc.w	$632C
		dc.l	($43<<$18)|Giant_Spikeball_Mappings 
		dc.b	$0,$0
		dc.w	$C30C
		dc.l	($19<<$18)|Rotating_Platforms_Mappings 
		dc.b	$23,$2
		dc.w	$62F4
		dc.l	($45<<$18)|Spring_Push_Boost_Mappings 
		dc.b	$2,$0
		dc.w	$43C5
		dc.l	($45<<$18)|Spring_Push_Boost_Mappings 
		dc.b	$12,$A
		dc.w	$43C5
		dc.l	($46<<$18)|Spring_Ball_Mappings 
		dc.b	$0,$1
		dc.w	$6354
		dc.l	($47<<$18)|Switch_Mappings 
		dc.b	$0,$2
		dc.w	$424
		dc.l	($15<<$18)|OOz_Swing_Platforms_Mappings 
		dc.b	$88,$1
		dc.w	$43E3
		dc.l	($3D<<$18)|Break_Boost_Mappings 
		dc.b	$0,$0
		dc.w	$6332
		dc.l	($48<<$18)|Cannon_Mappings 
		dc.b	$80,$0
		dc.w	$6368
		dc.l	($48<<$18)|Cannon_Mappings 
		dc.b	$81,$1
		dc.w	$6368
		dc.l	($48<<$18)|Cannon_Mappings 
		dc.b	$82,$2
		dc.w	$6368
		dc.l	($48<<$18)|Cannon_Mappings 
		dc.b	$83,$3
		dc.w	$6368
		dc.l	($1F<<$18)|OOz_Collapsing_Platforms_Mappings 
		dc.b	$0,$0
		dc.w	$639D
		dc.l	($3F<<$18)|Vertical_Fan_Mappings 
		dc.b	$0,$0
		dc.w	$6403
		dc.l	($3F<<$18)|Horizontal_Fan_Mappings 
		dc.b	$80,$0
		dc.w	$6403
		dc.l	($50<<$18)|Aquis_Mappings 
		dc.b	$0,$0
		dc.w	$2500 
		dc.l	($4A<<$18)|Octus_Mappings 
		dc.b	$0,$0
		dc.w	$2538
		dc.l	($1C<<$18)|OOz_Misc_Mappings 
		dc.b	$A,$0
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings 
		dc.b	$B,$1
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings 
		dc.b	$C,$2
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings 
		dc.b	$D,$3
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings 
		dc.b	$E,$4
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings 
		dc.b	$F,$5
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01 
		dc.b	$10,$0
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01 
		dc.b	$11,$1
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01 
		dc.b	$12,$2
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01 
		dc.b	$13,$3
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01 
		dc.b	$14,$4
		dc.w	$4346
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680 
Debug_OOz_End: 
;-------------------------------------------------------------------------------
Debug_DHz: 
		dc.w	(((Debug_DHz_End-debug_DHz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($15<<$18)|DHz_Swing_Platforms_Mappings 
		dc.b	$48,$2
		dc.w	$0
		dc.l	($1F<<$18)|DHz_Collapsing_Platforms_Mappings 
		dc.b	$0,$0
		dc.w	$63F4 
		dc.l	($73<<$18)|Rotating_Rings_Mappings 
		dc.b	$F5,$0
		dc.w	$26BC 
		dc.l	($6A<<$18)|Rotating_Boxes_Mappings 
		dc.b	$18,$0
		dc.w	$63D4
		dc.l	($2A<<$18)|Up_Down_Pillar_Mappings 
		dc.b	$0,$0
		dc.w	$4000
		dc.l	($36<<$18)|Spikes_Mappings 
		dc.b	$0,$0
		dc.w	$2434 
		dc.l	($36<<$18)|Spikes_Mappings 
		dc.b	$40,$4
		dc.w	$242C 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$81,$0
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$90,$3
		dc.w	$470 
		dc.l	($40<<$18)|Diagonal_Spring_Mappings 
		dc.b	$1,$0
		dc.w	$440
		dc.l	($74<<$18)|Invisible_Block_Mappings 
		dc.b	$11,$0
		dc.w	$8680
		dc.l	($75<<$18)|Spikeball_Chain_Mappings 
		dc.b	$18,$2
		dc.w	$2000
		dc.l	($76<<$18)|Platform_Spikes_Mappings 
		dc.b	$0,$0
		dc.w	$0
		dc.l	($77<<$18)|Dhz_Bridge_Mappings 
		dc.b	$1,$0
		dc.w	$643C
		dc.l	($7F<<$18)|Vines_Switch_Mappings 
		dc.b	$0,$0
		dc.w	$640E
		dc.l	($80<<$18)|Vines_Mappings 
		dc.b	$0,$0
		dc.w	$641E
		dc.l	($81<<$18)|Vertical_Bridge_Mappings 
		dc.b	$0,$1
		dc.w	$643C
		dc.l	($7A<<$18)|DHz_Swing_Platforms_Mappings 
		dc.b	$12,$0
		dc.w	$0
		dc.l	($A3<<$18)|Flasher_Mappings 
		dc.b	$2C,$0
		dc.w	$83A8
		dc.l	($9E<<$18)|Crawlton_Mappings 
		dc.b	$22,$0
		dc.w	$23C0
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680 
Debug_DHz_End: 
;-------------------------------------------------------------------------------
Debug_CNz: 
		dc.w	(((Debug_CNz_End-debug_CNz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($84<<$18)|Layer_Switch_Mappings 
		dc.b	$0,$0
		dc.w	$6BC 
		dc.l	($84<<$18)|Layer_Switch_Mappings 
		dc.b	$4,$4
		dc.w	$6BC 
		dc.l	($3<<$18)|Layer_Switch_Mappings 
		dc.b	$9,$1
		dc.w	$26BC 
		dc.l	($3<<$18)|Layer_Switch_Mappings 
		dc.b	$D,$5
		dc.w	$26BC
		dc.l	($44<<$18)|Red_Ball_Bumper_Mappings 
		dc.b	$0,$0
		dc.w	$439A
		dc.l	($85<<$18)|Diagonal_Pinball_Spring_Mappings 
		dc.b	$0,$0
		dc.w	$422
		dc.l	($85<<$18)|Vertical_Pinball_Spring_Mappings 
		dc.b	$81,$0
		dc.w	$402
		dc.l	($86<<$18)|Flippers_Mappings 
		dc.b	$0,$0
		dc.w	$43B2
		dc.l	($86<<$18)|Flippers_Mappings 
		dc.b	$1,$4
		dc.w	$43B2
		dc.l	($D2<<$18)|Green_Platform_Mappings 
		dc.b	$1,$0
		dc.w	$437C
		dc.l	($D3<<$18)|Spikeball_Mappings 
		dc.b	$0,$0
		dc.w	$380
		dc.l	($D4<<$18)|Blue_Box_Mappings 
		dc.b	$0,$0
		dc.w	$436C
		dc.l	($D4<<$18)|Blue_Box_Mappings 
		dc.b	$2,$0
		dc.w	$436C
		dc.l	($D5<<$18)|CNz_Elevator_Mappings 
		dc.b	$18,$0
		dc.w	$4384
		dc.l	($D6<<$18)|Slot_Machine_Starter_Mappings 
		dc.b	$1,$0
		dc.w	$388
		dc.l	($D7<<$18)|Blue_Bumper_Mappings 
		dc.b	$0,$0
		dc.w	$4394
		dc.l	($D8<<$18)|Green_Bumper_Mappings 
		dc.b	$0,$0
		dc.w	$43E6
		dc.l	($D8<<$18)|Green_Bumper_Mappings 
		dc.b	$40,$1
		dc.w	$43E6
		dc.l	($D8<<$18)|Green_Bumper_Mappings 
		dc.b	$80,$2
		dc.w	$43E6
		dc.l	($C8<<$18)|Crawl_Mappings 
		dc.b	$AC,$0
		dc.w	$8340
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680
Debug_CNz_End: 
;-------------------------------------------------------------------------------
Debug_CPz: 
		dc.w	(((Debug_CPz_End-debug_CPz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($B<<$18)|Open_Close_Platform_Mappings 
		dc.b	$70,$0
		dc.w	$E3B0
		dc.l	($1B<<$18)|CPz_Speed_Booster_Mappings 
		dc.b	$0,$0
		dc.w	$E39C
		dc.l	($1D<<$18)|Worms_Mappings 
		dc.b	$5,$0
		dc.w	$E43C
		dc.l	($19<<$18)|Rotating_Platforms_Mappings 
		dc.b	$6,$0
		dc.w	$63A0
		dc.l	($2D<<$18)|Automatic_Door_Mappings 
		dc.b	$2,$2
		dc.w	$2394
		dc.l	($32<<$18)|CPz_Tunel_Obstacle_Mappings 
		dc.b	$0,$0
		dc.w	$6430
		dc.l	($6B<<$18)|CPz_Block_Mappings 
		dc.b	$10,$0 
		dc.w	$6418
		dc.l	($78<<$18)|CPz_Block_Mappings 
		dc.b	$0,$0
		dc.w	$6418
		dc.l	($7A<<$18)|Platform_Horizontal_Mappings 
		dc.b	$0,$0
		dc.w	$E418
		dc.l	($7B<<$18)|Spring_Tubes_Mappings 
		dc.b	$2,$0
		dc.w	$3E0
		dc.l	($3<<$18)|Layer_Switch_Mappings 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($3<<$18)|Layer_Switch_Mappings 
		dc.b	$D,$5
		dc.w	$26BC
		dc.l	($36<<$18)|Spikes_Mappings 
		dc.b	$0,$0
		dc.w	$2434 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$81,$0
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$90,$3
		dc.w	$470
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$A0,$6
		dc.w	$45C
		dc.l	($40<<$18)|Diagonal_Spring_Mappings 
		dc.b	$1,$0
		dc.w	$440
		dc.l	($A5<<$18)|Lander_Mappings 
		dc.b	$32,$0
		dc.w	$252D
		dc.l	($A6<<$18)|Lander_Mappings 
		dc.b	$32,$3
		dc.w	$252D
		dc.l	($A7<<$18)|Grabber_Mappings 
		dc.b	$36,$0
		dc.w	$A500
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680
Debug_CPz_End:
;-------------------------------------------------------------------------------
Debug_NGHz: 
		dc.w	(((Debug_NGHz_End-debug_NGHz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($15<<$18)|NGHz_Swing_Platforms_Mappings 
		dc.b	$88,$2
		dc.w	$0
		dc.l	($18<<$18)|NGHz_Platform_Mappings 
		dc.b	$1,$0
		dc.w	$4000
		dc.l	($18<<$18)|NGHz_Platform_Mappings 
		dc.b	$9A,$1
		dc.w	$4000
		dc.l	($22<<$18)|Arrow_Shooter_Mappings 
		dc.b	$0,$1
		dc.w	$417
		dc.l	($23<<$18)|Pillar_Mappings 
		dc.b	$0,$0
		dc.w	$2000
		dc.l	($2B<<$18)|Raising_Pillar_Mappings 
		dc.b	$0,$0
		dc.w	$2000
		dc.l	($2C<<$18)|Lava_Attributes_Mappings 
		dc.b	$0,$0
		dc.w	$8680
		dc.l	($2C<<$18)|Lava_Attributes_Mappings 
		dc.b	$1,$1
		dc.w	$8680
		dc.l	($2C<<$18)|Lava_Attributes_Mappings 
		dc.b	$2,$2
		dc.w	$8680
		dc.l	($40<<$18)|Diagonal_Spring_Mappings 
		dc.b	$1,$0
		dc.w	$440
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$81,$0
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$90,$3
		dc.w	$470 
		dc.l	($41<<$18)|Springs_Mappings 
		dc.b	$A0,$6
		dc.w	$45C
		dc.l	($3<<$18)|Layer_Switch_Mappings 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($36<<$18)|Spikes_Mappings 
		dc.b	$0,$0
		dc.w	$2434 
		dc.l	($2D<<$18)|Automatic_Door_Mappings 
		dc.b	$3,$3
		dc.w	$23F8
		dc.l	($1F<<$18)|NGHz_Collapsing_Platforms_Mappings 
		dc.b	$0,$0
		dc.w	$4000
		dc.l	($82<<$18)|Falling_Pillar_Mappings 
		dc.b	$3,$0
		dc.w	$0
		dc.l	($82<<$18)|Falling_Pillar_Mappings 
		dc.b	$11,$1
		dc.w	$0
		dc.l	($83<<$18)|NGHz_Swing_Platforms_Mappings 
		dc.b	$10,$1
		dc.w	$0
		dc.l	($24<<$18)|Sonic_Underwater_Mappings 
		dc.b	$81,$E
		dc.w	$855B
		dc.l	($91<<$18)|Chop_Chop_Mappings 
		dc.b	$8,$0
		dc.w	$253B
		dc.l	($8C<<$18)|Whisp_Mappings 
		dc.b	$0,$0
		dc.w	$A500
		dc.l	($8D<<$18)|Grounder_Mappings 
		dc.b	$2,$0
		dc.w	$A509
		dc.l	($8E<<$18)|Grounder_Mappings 
		dc.b	$2,$0
		dc.w	$A509
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680
Debug_NGHz_End: 
;-------------------------------------------------------------------------------
Debug_SCz: 
		dc.w	(((Debug_SCz_End-debug_SCz-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($8B<<$18)|Layer_Switch_Mappings 
		dc.b	$0,$0
		dc.w	$6BC
		dc.l	($B3<<$18)|Clouds_Mappings 
		dc.b	$5E,$0
		dc.w	$454F
		dc.l	($B3<<$18)|Clouds_Mappings 
		dc.b	$60,$1
		dc.w	$454F
		dc.l	($B3<<$18)|Clouds_Mappings 
		dc.b	$62,$2
		dc.w	$454F
		dc.l	($B4<<$18)|Vertical_Helix_Mappings 
		dc.b	$64,$0
		dc.w	$A561
		dc.l	($B5<<$18)|Horizontal_Helix_Mappings 
		dc.b	$66,$0
		dc.w	$A3CD
		dc.l	($B5<<$18)|Horizontal_Helix_Mappings 
		dc.b	$68,$0
		dc.w	$A3CD
		dc.l	($9A<<$18)|Turtloid_Mappings 
		dc.b	$16,$0
		dc.w	$38A
		dc.l	($AC<<$18)|Balkiry_Mappings 
		dc.b	$40,$0
		dc.w	$565
		dc.l	($99<<$18)|Nebula_Mappings 
		dc.b	$12,$0
		dc.w	$A36E
		dc.l	($3E<<$18)|Egg_Prison_Mappings 
		dc.b	$0,$0
		dc.w	$2680 
Debug_SCz_End: 
;------------------------------------------------------------------------------- 
		nop ; Filler 
loc_3E388:
		jmp	ModifySpriteAttr_2P 
		cnop	0,4 ; Filler 
;===============================================================================
; Sub Routine Debug_Mode
; [ End ]
;=============================================================================== 
TilesMainTable: 
		dc.l	($4<<$18)|Green_Hill_8x8_Tiles 
		dc.l	($5<<$18)|Green_Hill_16x16_Map 
		dc.l	($4<<$18)|Green_Hill_128x128_Map 
		dc.l	($6<<$18)|Green_Hill_8x8_Tiles 
		dc.l	($7<<$18)|Green_Hill_16x16_Map 
		dc.l	($5<<$18)|Green_Hill_128x128_Map 
		dc.l	($8<<$18)|Green_Hill_8x8_Tiles 
		dc.l	($9<<$18)|Green_Hill_16x16_Map 
		dc.l	($6<<$18)|Green_Hill_128x128_Map 
		dc.l	($A<<$18)|Green_Hill_8x8_Tiles 
		dc.l	($B<<$18)|Green_Hill_16x16_Map 
		dc.l	($7<<$18)|Green_Hill_128x128_Map 
		dc.l	($C<<$18)|Metropolis_8x8_Tiles 
		dc.l	($D<<$18)|Metropolis_16x16_Map 
		dc.l	($8<<$18)|Metropolis_128x128_Map 
		dc.l	($C<<$18)|Metropolis_8x8_Tiles 
		dc.l	($D<<$18)|Metropolis_16x16_Map 
		dc.l	($8<<$18)|Metropolis_128x128_Map 
		dc.l	($10<<$18)|Sky_Fortress_8x8_Tiles 
		dc.l	($11<<$18)|Sky_Fortress_16x16_Map 
		dc.l	($A<<$18)|Sky_Fortress_128x128_Map 
		dc.l	($12<<$18)|Green_Hill_8x8_Tiles 
		dc.l	($13<<$18)|Green_Hill_16x16_Map 
		dc.l	($B<<$18)|Green_Hill_128x128_Map 
		dc.l	($14<<$18)|Hidden_Palace_8x8_Tiles 
		dc.l	($15<<$18)|Hidden_Palace_16x16_Map 
		dc.l	($C<<$18)|Hidden_Palace_128x128_Map 
		dc.l	($16<<$18)|Green_Hill_8x8_Tiles 
		dc.l	($17<<$18)|Green_Hill_16x16_Map 
		dc.l	($D<<$18)|Green_Hill_128x128_Map 
		dc.l	($18<<$18)|Oil_Ocean_8x8_Tiles 
		dc.l	($19<<$18)|Oil_Ocean_16x16_Map 
		dc.l	($E<<$18)|Oil_Ocean_128x128_Map 
		dc.l	($1A<<$18)|Dust_Hill_8x8_Tiles 
		dc.l	($1B<<$18)|Dust_Hill_16x16_Map 
		dc.l	($F<<$18)|Dust_Hill_128x128_Map 
		dc.l	($1C<<$18)|Casino_Night_8x8_Tiles 
		dc.l	($1D<<$18)|Casino_Night_16x16_Map 
		dc.l	($10<<$18)|Casino_Night_128x128_Map 
		dc.l	($1E<<$18)|Chemical_Plant_8x8_Tiles 
		dc.l	($1F<<$18)|Chemical_Plant_16x16_Map 
		dc.l	($11<<$18)|Chemical_Plant_128x128_Map 
		dc.l	($20<<$18)|Chemical_Plant_8x8_Tiles 
		dc.l	($21<<$18)|Chemical_Plant_16x16_Map 
		dc.l	($12<<$18)|Chemical_Plant_128x128_Map 
		dc.l	($22<<$18)|Neo_Green_Hill_8x8_Tiles 
		dc.l	($23<<$18)|Neo_Green_Hill_16x16_Map 
		dc.l	($13<<$18)|Neo_Green_Hill_128x128_Map 
		dc.l	($24<<$18)|Sky_Fortress_8x8_Tiles 
		dc.l	($25<<$18)|Sky_Fortress_16x16_Map 
		dc.l	($14<<$18)|Sky_Fortress_128x128_Map 
;===============================================================================
; PLC
; [ Begin ]
;===============================================================================
ArtLoadCues: 
		dc.w	default_Sprs-ArtLoadCues 
		dc.w	default_Level_Sprs-ArtLoadCues 
		dc.w	Enemies_Explosions-ArtLoadCues 
		dc.w	Game_Time_Over_Spr-ArtLoadCues 
		dc.w	GHz_Sprs_0-ArtLoadCues 
		dc.w	GHz_Sprs_1-ArtLoadCues 
		dc.w	Mz_Sprs_0-ArtLoadCues 
		dc.w	Mz_Sprs_0-ArtLoadCues 
		dc.w	Mz_Sprs_0-ArtLoadCues 
		dc.w	Mz_Sprs_0-ArtLoadCues 
		dc.w	Mz_Sprs_0-ArtLoadCues 
		dc.w	Mz_Sprs_0-ArtLoadCues 
		dc.w	Mz_Sprs_0-ArtLoadCues 
		dc.w	Mz_Sprs_1-ArtLoadCues 
		dc.w	SFz_Sprs_0-ArtLoadCues 
		dc.w	SFz_Sprs_0-ArtLoadCues 
		dc.w	SFz_Sprs_0-ArtLoadCues 
		dc.w	SFz_Sprs_1-ArtLoadCues 
		dc.w	HTz_Sprs_0-ArtLoadCues 
		dc.w	HTz_Sprs_1-ArtLoadCues 
		dc.w	HPz_Sprs_0-ArtLoadCues 
		dc.w	HPz_Sprs_1-ArtLoadCues 
		dc.w	OOz_Sprs_0-ArtLoadCues 
		dc.w	OOz_Sprs_0-ArtLoadCues 
		dc.w	OOz_Sprs_0-ArtLoadCues 
		dc.w	OOz_Sprs_1-ArtLoadCues 
		dc.w	dHz_Sprs_0-ArtLoadCues 
		dc.w	dHz_Sprs_1-ArtLoadCues 
		dc.w	CNz_Sprs_0-ArtLoadCues 
		dc.w	CNz_Sprs_1-ArtLoadCues 
		dc.w	CPz_Sprs_0-ArtLoadCues 
		dc.w	CPz_Sprs_1-ArtLoadCues 
		dc.w	dEz_Sprs_0-ArtLoadCues 
		dc.w	dEz_Sprs_1-ArtLoadCues 
		dc.w	NGHz_Sprs_0-ArtLoadCues 
		dc.w	NGHz_Sprs_1-ArtLoadCues 
		dc.w	SCz_Sprs_0-ArtLoadCues 
		dc.w	SCz_Sprs_1-ArtLoadCues 
		dc.w	Level_Results_Sprs-ArtLoadCues 
		dc.w	End_Level_Sprs-ArtLoadCues 
		dc.w	CPz_Boss_Sprs-ArtLoadCues 
		dc.w	GHz_Boss_Sprs-ArtLoadCues 
		dc.w	HTz_Boss_Sprs-ArtLoadCues 
		dc.w	NGHz_Boss_Sprs-ArtLoadCues 
		dc.w	dHz_Boss_Sprs-ArtLoadCues 
		dc.w	CNz_Boss_Sprs-ArtLoadCues 
		dc.w	Mz_Boss_Sprs-ArtLoadCues 
		dc.w	OOz_Boss_Sprs-ArtLoadCues 
		dc.w	dEz_Boss_Spr-ArtLoadCues 
		dc.w	Final_Boss_Spr-ArtLoadCues 
		dc.w	GHz_Flickies_Sprs-ArtLoadCues 
		dc.w	dHz_Flickies_Sprs-ArtLoadCues 
		dc.w	Mz_SFz_HTz_Flickies_Sprs-ArtLoadCues 
		dc.w	dEz_Flickies_Sprs-ArtLoadCues 
		dc.w	HPz_Flickies_Sprs-ArtLoadCues 
		dc.w	OOz_Flickies_Sprs-ArtLoadCues 
		dc.w	SCz_Flickies_Sprs-ArtLoadCues 
		dc.w	CNz_Flickies_Sprs-ArtLoadCues 
		dc.w	CPz_Flickies_Sprs-ArtLoadCues 
		dc.w	NGHz_Flickies_Sprs-ArtLoadCues 
		dc.w	Special_Stage_Sprs_0-ArtLoadCues 
		dc.w	Special_Stage_Sprs_1-ArtLoadCues 
		dc.w	SFz_Boss_Sprs-ArtLoadCues 
		dc.w	SFz_Chase_Sprs-ArtLoadCues 
		dc.w	Egg_Prison_Sprs-ArtLoadCues 
		dc.w	Egg_Prison_Explosions-ArtLoadCues 
		dc.w	SS_Results_Sprs-ArtLoadCues 
;===============================================================================
; Default Sprites - Loaded during Title Screen
; [ Begin ] 
;=============================================================================== 
Default_Sprs: 
PLC_00:
		dc.w	(((PLC_00_End-PLC_00-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Head_up_display_Sprites 
		dc.w	$D940
		dc.l	Head_up_display_Sonic 
		dc.w	$FA80
		dc.l	Rings_Sprites 
		dc.w	$D780
		dc.l	Enemy_Points_Spr 
		dc.w	$9580
		dc.l	Head_up_display_Miles 
		dc.w	$DE80
PLC_00_End:
;===============================================================================
; Default Sprites - Loaded during Title Screen
; [ End ] 
;===============================================================================

;===============================================================================
; Default Sprites - Loaded at begin of Level
; [ Begin ] 
;=============================================================================== 
Default_Level_Sprs: 
PLC_01:
		dc.w	(((PLC_01_End-PLC_01-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Star_Post 
		dc.w	$8F80
		dc.l	Monitors 
		dc.w	$D000
		dc.l	Shield 
		dc.w	$97C0
		dc.l	Invencibility_Stars 
		dc.w	$9BC0
PLC_01_End:
;===============================================================================
; Default Sprites - Loaded at begin of Level
; [ End ] 
;===============================================================================

;===============================================================================
; Enemies / Monitors Explosions - Loaded after Title Cards 
; [ Begin ] 
;===============================================================================
Enemies_Explosions: 
PLC_02: 
		dc.w	(((PLC_02_End-PLC_02-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Explosion 
		dc.w	$B480
		dc.l	Water_Splash 
		dc.w	$BE40
		dc.l	Bubbles 
		dc.w	$BD00
PLC_02_End:
;===============================================================================
; Enemies / Monitors Explosions - Loaded after Title Cards 
; [ End ] 
;===============================================================================

Game_Time_Over_Spr: 
PLC_03: 
		dc.w	(((PLC_03_End-PLC_03-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Game_Time_Over 
		dc.w	$9BC0
PLC_03_End:
;-------------------------------------------------------------------------------
GHz_Sprs_0: 
PLC_04: 
		dc.w	(((PLC_04_End-PLC_04-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	GHz_Waterfall 
		dc.w	$73C0
		dc.l	GHz_Bridge 
		dc.w	$76C0
		dc.l	FireBall 
		dc.w	$77C0
		dc.l	GHz_Buzzer 
		dc.w	$7A40
		dc.l	GHz_Coconuts 
		dc.w	$7DC0
		dc.l	GHz_Masher 
		dc.w	$8280
PLC_04_End:
;-------------------------------------------------------------------------------
GHz_Sprs_1: 
PLC_05: 
		dc.w	(((PLC_05_End-PLC_05-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_05_End: 
;-------------------------------------------------------------------------------
Mz_Sprs_0: 
PLC_0C: 
		dc.w	(((PLC_0C_End-PLC_0C-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Mz_Rotating_Gear 
		dc.w	$6F00
		dc.l	Mz_Gear_Holes 
		dc.w	$7E00
		dc.l	Mz_Elevator 
		dc.w	$7F20
		dc.l	Mz_Miscellaneous 
		dc.w	$7FA0
		dc.l	Mz_Steam 
		dc.w	$80A0
		dc.l	Mz_Harpon_Platform 
		dc.w	$8280
		dc.l	Mz_Harpon 
		dc.w	$8380
		dc.l	Shellcracker 
		dc.w	$6380
		dc.l	asteron 
		dc.w	$6D00
PLC_0C_End:
;------------------------------------------------------------------------------- 
Mz_Sprs_1: 
PLC_0D: 
		dc.w	(((PLC_0D_End-PLC_0D-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto 
		dc.l	Switch 
		dc.w	$8480
		dc.l	Spikes 
		dc.w	$8680
		dc.l	Slicer 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
		dc.l	Mz_Screw_Nut 
		dc.w	$A000
		dc.l	Mz_Lava_Bubble 
		dc.w	$A6C0
		dc.l	Mz_Mini_Gear 
		dc.w	$ABE0
		dc.l	Mz_Teleport_Flash 
		dc.w	$AD60 
PLC_0D_End:
;------------------------------------------------------------------------------- 
SFz_Sprs_0: 
PLC_10: 
		dc.w	(((PLC_10_End-PLC_10-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship_Spr 
		dc.w	$60E0 
		dc.l	Tornado 
		dc.w	$A000
		dc.l	Clouds 
		dc.w	$A9E0
		dc.l	Vertical_Helix_Spr 
		dc.w	$AC20
		dc.l	Horizontal_Helix_Spr 
		dc.w	$79A0
		dc.l	Balkiry 
		dc.w	$ACA0
		dc.l	Breakable_Wall 
		dc.w	$9180
		dc.l	Clucker 
		dc.w	$6F20
		dc.l	Rotating_Helix 
		dc.w	$7260
		dc.l	Tornado 
		dc.w	$A000
		dc.l	Clouds 
		dc.w	$A9E0
PLC_10_End: 
;-------------------------------------------------------------------------------
SFz_Sprs_1: 
PLC_11: 
		dc.w	(((PLC_11_End-PLC_11-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Vertical_Helix_Spr 
		dc.w	$AC20
		dc.l	Horizontal_Helix_Spr 
		dc.w	$79A0
		dc.l	Vertical_Laser 
		dc.w	$73E0
		dc.l	SFz_Cannon 
		dc.w	$7560
		dc.l	Horizontal_Laser 
		dc.w	$7860
		dc.l	Conveyor_Belts_Wheels 
		dc.w	$7D40
		dc.l	Chain_Hook 
		dc.w	$7F40
		dc.l	Rocket_Flame_Spr 
		dc.w	$8CA0
		dc.l	SFz_Elevators 
		dc.w	$81C0
		dc.l	Hatchways 
		dc.w	$8340
		dc.l	Engine_Part 
		dc.w	$8A00
		dc.l	Speed_Boost 
		dc.w	$8B80
		dc.l	Boss_Switch_Spr 
		dc.w	$8C20
		dc.l	SFz_Platform 
		dc.w	$8DA0
PLC_11_End: 
;------------------------------------------------------------------------------- 
HTz_Sprs_0: 
PLC_12: 
		dc.w	(((PLC_12_End-PLC_12-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Hill_Top_8x8_Tiles 
		dc.w	$3F80
		dc.l	FireBall 
		dc.w	$73C0
		dc.l	Htz_Rock 
		dc.w	$7640
		dc.l	Htz_See_saw 
		dc.w	$78C0
		dc.l	Htz_See_saw_badnick 
		dc.w	$7BC0
		dc.l	Rexon 
		dc.w	$6FC0
		dc.l	Spiker 
		dc.w	$A400
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00 
PLC_12_End:
;-------------------------------------------------------------------------------
HTz_Sprs_1: 
PLC_13: 
		dc.w	(((PLC_13_End-PLC_13-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Htz_Teleferic 
		dc.w	$7CC0
		dc.l	Htz_Lava_Bubble 
		dc.w	$82C0
		dc.l	Htz_Automatic_Door 
		dc.w	$84C0
PLC_13_End:
;------------------------------------------------------------------------------- 
HPz_Sprs_0: 
PLC_14: 
		dc.w	(((PLC_14_End-PLC_14-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Hpz_Bridge 
		dc.w	$6000
		dc.l	Hpz_Waterfall 
		dc.w	$62A0
		dc.l	Hpz_Platform 
		dc.w	$6940
		dc.l	Hpz_Orbs_Comp 
		dc.w	$6B40
		dc.l	Hpz_Unknow_Platform 
		dc.w	$6F80
		dc.l	Hpz_Emerald 
		dc.w	$7240
		dc.l	Water_Surface 
		dc.w	$8000
PLC_14_End: 
;-------------------------------------------------------------------------------
HPz_Sprs_1: 
PLC_15: 
		dc.w	(((PLC_15_End-PLC_15-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Hpz_Rhinobot 
		dc.w	$7640
		dc.l	Hpz_Dinobot 
		dc.w	$A000
		dc.l	Hpz_Batbot 
		dc.w	$A600
PLC_15_End: 
;-------------------------------------------------------------------------------
OOz_Sprs_0: 
PLC_18: 
		dc.w	(((PLC_18_End-PLC_18-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	OOz_Fire_Booster 
		dc.w	$5C40
		dc.l	OOz_Elevator 
		dc.w	$5E80
		dc.l	OOz_Giant_Spikeball 
		dc.w	$6180
		dc.l	OOz_Touch_Boost_Up 
		dc.w	$6580
		dc.l	OOz_Break_To_Boost_Horizontal 
		dc.w	$6640
		dc.l	OOz_Oil 
		dc.w	$66C0
		dc.l	OOz_Oil_01 
		dc.w	$68C0
		dc.l	OOz_Ball 
		dc.w	$6A80
		dc.l	OOz_Cannon 
		dc.w	$6D00
PLC_18_End: 
;-------------------------------------------------------------------------------
OOz_Sprs_1: 
PLC_19: 
		dc.w	(((PLC_19_End-PLC_19-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	OOz_Collapsing_Platform 
		dc.w	$73A0
		dc.l	OOz_Spring_Push_Boost 
		dc.w	$78A0
		dc.l	OOz_Swing_Platform 
		dc.w	$7C60
		dc.l	OOz_Break_To_Boost_Vertical 
		dc.w	$7FE0
		dc.l	OOz_Fans 
		dc.w	$8060
		dc.l	Switch 
		dc.w	$8480
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
		dc.l	OOz_Aquis 
		dc.w	$A000
		dc.l	OOz_Octus 
		dc.w	$A700
PLC_19_End: 
;-------------------------------------------------------------------------------
DHz_Sprs_0: 
PLC_1A: 
		dc.w	(((PLC_1A_End-PLC_1A-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	dhz_Box 
		dc.w	$7A80
		dc.l	dhz_Collapsing_Platform 
		dc.w	$7E80
		dc.l	dhz_Vines 
		dc.w	$81C0
		dc.l	dhz_Vines_1 
		dc.w	$83C0
		dc.l	Flasher 
		dc.w	$7500
		dc.l	Crawlton 
		dc.w	$7800
PLC_1A_End: 
;-------------------------------------------------------------------------------
DHz_Sprs_1: 
PLC_1B: 
		dc.w	(((PLC_1B_End-PLC_1B-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	dhz_Horizontal_Spikes 
		dc.w	$8580
		dc.l	Spikes 
		dc.w	$8680
		dc.l	dhz_Bridge 
		dc.w	$8780
		dc.l	diagonal_Spring_1 
		dc.w	$8800
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_1B_End: 
;-------------------------------------------------------------------------------
CNz_Sprs_0: 
PLC_1C: 
		dc.w	(((PLC_1C_End-PLC_1C-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto 
		dc.l	Crawl 
		dc.w	$6800
		dc.l	CNz_Box 
		dc.w	$6D80
		dc.l	CNz_Green_Platforms 
		dc.w	$6F80
		dc.l	CNz_Spikeball_Slot_Machine 
		dc.w	$7000
		dc.l	CNz_Elevator 
		dc.w	$7080
		dc.l	CNz_Slot_Machine_Starter 
		dc.w	$7100
		dc.l	CNz_Blue_Bumper 
		dc.w	$7280
		dc.l	CNz_Bumpers 
		dc.w	$7340
		dc.l	CNz_Flippers 
		dc.w	$7640
		dc.l	CNz_Green_Bumpers 
		dc.w	$7CC0
PLC_1C_End: 
;------------------------------------------------------------------------------- 
CNz_Sprs_1: 
PLC_1D: 
		dc.w	(((PLC_1D_End-PLC_1D-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	CNz_Diagonal_Launcher 
		dc.w	$8040
		dc.l	CNz_Vertical_Launcher 
		dc.w	$8440
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_1D_End: 
;-------------------------------------------------------------------------------
CPz_Sprs_0: 
PLC_1E: 
		dc.w	(((PLC_1E_End-PLC_1E-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	CPz_Metal_Structure 
		dc.w	$6E60
		dc.l	CPz_Automatic_Door 
		dc.w	$7280
		dc.l	CPz_Speed_Booster 
		dc.w	$7380
		dc.l	CPz_Triangle_Platform 
		dc.w	$7400
		dc.l	CPz_Open_Close_Platform 
		dc.w	$7600
		dc.l	CPz_Spring_Tubes 
		dc.w	$7C00
		dc.l	Water_Surface 
		dc.w	$8000
		dc.l	CPz_Platforms 
		dc.w	$8300
		dc.l	CPz_Breakable_Block 
		dc.w	$8600
		dc.l	Grabber 
		dc.w	$A000
		dc.l	Lander 
		dc.w	$A5A0
PLC_1E_End:
;-------------------------------------------------------------------------------
CPz_Sprs_1: 
PLC_1F: 
		dc.w	(((PLC_1F_End-PLC_1F-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Spikes 
		dc.w	$8680
		dc.l	CPz_Worms 
		dc.w	$8780
		dc.l	diagonal_Spring_1 
		dc.w	$8800
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_1F_End:
;-------------------------------------------------------------------------------
DEz_Sprs_0: 
PLC_20: 
		dc.w	(((PLC_20_End-PLC_20-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	CPz_Automatic_Door 
		dc.w	$6500
PLC_20_End:
;-------------------------------------------------------------------------------
DEz_Sprs_1: 
PLC_21: 
		dc.w	(((PLC_21_End-PLC_21-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Metal_Sonic 
		dc.w	$7000
		dc.l	Robotnik_Window 
		dc.w	$6F00
		dc.l	Robotnik 
		dc.w	$A300
		dc.l	Robotnik_Faces 
		dc.w	$A000
		dc.l	Robotnik_Body 
		dc.w	$AC80
PLC_21_End:
;-------------------------------------------------------------------------------
NGHz_Sprs_0: 
PLC_22: 
		dc.w	(((PLC_22_End-PLC_22-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	NGHz_Automatic_Door 
		dc.w	$7F00
		dc.l	NGHz_Water_Surface 
		dc.w	$8000
		dc.l	NGHz_Leaves 
		dc.w	$8200
		dc.l	NGHz_Arrow_Shooter 
		dc.w	$82E0
PLC_22_End:
;-------------------------------------------------------------------------------
NGHz_Sprs_1: 
PLC_23: 
		dc.w	(((PLC_23_End-PLC_23-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Chop_Chop 
		dc.w	$A760
		dc.l	Whisp 
		dc.w	$A000
		dc.l	Grounder 
		dc.w	$A120
		dc.l	Oxygen_Bubbles 
		dc.w	$AB60
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring_1 
		dc.w	$8800
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_23_End:
;-------------------------------------------------------------------------------
SCz_Sprs_0: 
PLC_24: 
		dc.w	(((PLC_24_End-PLC_24-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Tornado 
		dc.w	$A000
PLC_24_End:
;-------------------------------------------------------------------------------
SCz_Sprs_1: 
PLC_25: 
		dc.w	(((PLC_25_End-PLC_25-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Clouds 
		dc.w	$A9E0
		dc.l	Vertical_Helix_Spr 
		dc.w	$AC20
		dc.l	Horizontal_Helix_Spr 
		dc.w	$79A0
		dc.l	Balkiry 
		dc.w	$ACA0
		dc.l	Turtloid 
		dc.w	$7140
		dc.l	Nebula 
		dc.w	$6DC0
PLC_25_End:
;-------------------------------------------------------------------------------
Level_Results_Sprs: 
PLC_26: 
		dc.w	(((PLC_26_End-PLC_26-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Title_Card_ZONE_123 
		dc.w	$B000
		dc.l	Title_Card_Results 
		dc.w	$B600
		dc.l	Mini_Sonic 
		dc.w	$BE80
PLC_26_End: 
;-------------------------------------------------------------------------------
End_Level_Sprs: 
PLC_27: 
		dc.w	(((PLC_27_End-PLC_27-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	End_Panel 
		dc.w	$8680
PLC_27_End:
;-------------------------------------------------------------------------------
CPz_Boss_Sprs: 
PLC_28: 
		dc.w	(((PLC_28_End-PLC_28-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship 
		dc.w	$8400
		dc.l	CPz_Boss 
		dc.w	$A000
		dc.l	Ship_Boost 
		dc.w	$8300
		dc.l	Boss_Smokes 
		dc.w	$AE00
		dc.l	Boss_Explosions 
		dc.w	$B000
PLC_28_End: 
;-------------------------------------------------------------------------------
GHz_Boss_Sprs: 
PLC_29: 
		dc.w	(((PLC_29_End-PLC_29-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship 
		dc.w	$7400
		dc.l	GHz_Boss_Car 
		dc.w	$8000
		dc.l	Ghz_Boss_Blades 
		dc.w	$AD80
		dc.l	Boss_Explosions 
		dc.w	$B000
PLC_29_End:
;-------------------------------------------------------------------------------
HTz_Boss_Sprs: 
PLC_2A: 
		dc.w	(((PLC_2A_End-PLC_2A-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship 
		dc.w	$7820
		dc.l	HTz_Boss_Fire_Cannon 
		dc.w	$8420
		dc.l	Boss_Explosions 
		dc.w	$B000
		dc.l	Boss_Smokes 
		dc.w	$BC80 
PLC_2A_End:
;-------------------------------------------------------------------------------
NGHz_Boss_Sprs: 
PLC_2B: 
		dc.w	(((PLC_2B_End-PLC_2B-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship 
		dc.w	$A000
		dc.l	NGHz_Boss 
		dc.w	$7C00
		dc.l	Boss_Explosions 
		dc.w	$B000
PLC_2B_End:
;-------------------------------------------------------------------------------
DHz_Boss_Sprs: 
PLC_2C: 
		dc.w	(((PLC_2C_End-PLC_2C-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship 
		dc.w	$A000
		dc.l	dHz_Boss 
		dc.w	$7800
		dc.l	Boss_Explosions 
		dc.w	$B000
PLC_2C_End: 
;-------------------------------------------------------------------------------
CNz_Boss_Sprs: 
PLC_2D: 
		dc.w	(((PLC_2D_End-PLC_2D-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship 
		dc.w	$A000
		dc.l	CNz_Boss 
		dc.w	$80E0
		dc.l	Boss_Explosions 
		dc.w	$B000
PLC_2D_End: 
;-------------------------------------------------------------------------------
Mz_Boss_Sprs: 
PLC_2E: 
		dc.w	(((PLC_2E_End-PLC_2E-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship 
		dc.w	$A000 
		dc.l	Mz_Boss_Balls_And_Robotniks_Spr 
		dc.w	$6F80
		dc.l	Ship_Boost 
		dc.w	$AC00
		dc.l	Boss_Explosions 
		dc.w	$B000 
PLC_2E_End:
;-------------------------------------------------------------------------------
OOz_Boss_Sprs: 
PLC_2F: 
		dc.w	(((PLC_2F_End-PLC_2F-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	OOz_Boss 
		dc.w	$7180
		dc.l	Boss_Explosions 
		dc.w	$B000
PLC_2F_End: 
;-------------------------------------------------------------------------------
DEz_Boss_Spr: 
PLC_30: 
		dc.w	(((PLC_30_End-PLC_30-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Boss_Explosions 
		dc.w	$B000
PLC_30_End:
;-------------------------------------------------------------------------------
Final_Boss_Spr: 
PLC_31: 
		dc.w	(((PLC_31_End-PLC_31-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Final 
		dc.w	$6600
PLC_31_End:
;-------------------------------------------------------------------------------
GHz_Flickies_Sprs: 
PLC_32: 
		dc.w	(((PLC_32_End-PLC_32-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Squirrel 
		dc.w	$B000
		dc.l	Blue_Bird 
		dc.w	$B280
PLC_32_End:
;-------------------------------------------------------------------------------
DHz_Flickies_Sprs: 
PLC_33: 
		dc.w	(((PLC_33_End-PLC_33-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Mouse 
		dc.w	$B000
		dc.l	White_Bird 
		dc.w	$B280
PLC_33_End:
;-------------------------------------------------------------------------------
Mz_SFz_HTz_Flickies_Sprs: 
PLC_34: 
		dc.w	(((PLC_34_End-PLC_34-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Monkey 
		dc.w	$B000
		dc.l	Black_Bird 
		dc.w	$B280
PLC_34_End:
;-------------------------------------------------------------------------------
DEz_Flickies_Sprs: 
PLC_35: 
		dc.w	(((PLC_35_End-PLC_35-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Pig 
		dc.w	$B000
		dc.l	White_Bird 
		dc.w	$B280 
PLC_35_End:
;-------------------------------------------------------------------------------
HPz_Flickies_Sprs: 
PLC_36: 
		dc.w	(((PLC_36_End-PLC_36-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Mouse 
		dc.w	$B000
		dc.l	Seal 
		dc.w	$B280
PLC_36_End:
;-------------------------------------------------------------------------------
OOz_Flickies_Sprs: 
PLC_37: 
		dc.w	(((PLC_37_End-PLC_37-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Penguin 
		dc.w	$B000
		dc.l	Seal 
		dc.w	$B280
PLC_37_End:
;-------------------------------------------------------------------------------
SCz_Flickies_Sprs: 
PLC_38: 
		dc.w	(((PLC_38_End-PLC_38-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Turtle 
		dc.w	$B000
		dc.l	White_Bird 
		dc.w	$B280
PLC_38_End:
;-------------------------------------------------------------------------------
CNz_Flickies_Sprs: 
PLC_39: 
		dc.w	(((PLC_39_End-PLC_39-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Bear 
		dc.w	$B000
		dc.l	Blue_Bird 
		dc.w	$B280
PLC_39_End:
;-------------------------------------------------------------------------------
CPz_Flickies_Sprs: 
PLC_3A: 
		dc.w	(((PLC_3A_End-PLC_3A-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Rabbit 
		dc.w	$B000
		dc.l	Black_Bird 
		dc.w	$B280
PLC_3A_End:
;-------------------------------------------------------------------------------
NGHz_Flickies_Sprs: 
PLC_3B: 
		dc.w	(((PLC_3B_End-PLC_3B-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Penguin 
		dc.w	$B000
		dc.l	Blue_Bird 
		dc.w	$B280 
PLC_3B_End:
;-------------------------------------------------------------------------------
Special_Stage_Sprs_0: 
PLC_3C: 
		dc.w	(((PLC_3C_End-PLC_3C-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	SS_Emerald 
		dc.w	$2E80
		dc.l	SS_Wings_Hand 
		dc.w	$3440
		dc.l	SS_HUD_Font 
		dc.w	$3F40
		dc.l	SS_Player_Shadow 
		dc.w	$4780
		dc.l	SS_Player_Diagonal_Shadow 
		dc.w	$4C40
		dc.l	SS_Player_Vertical_Shadow 
		dc.w	$5380
		dc.l	SS_Bomb_Explosion 
		dc.w	$56A0
		dc.l	SS_Rings 
		dc.w	$6440
		dc.l	SS_START 
		dc.w	$7140
		dc.l	SS_PAYMW_vs 
		dc.w	$7BE0
		dc.l	SS_Background_8x8_Tiles 
		dc.w	$E000
		dc.l	SS_Background_Stars 
		dc.w	$EFE0
PLC_3C_End:
;-------------------------------------------------------------------------------
Special_Stage_Sprs_1: 
PLC_3D: 
		dc.w	(((PLC_3D_End-PLC_3D-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	SS_Bombs 
		dc.w	$7140
PLC_3D_End:
;-------------------------------------------------------------------------------
SFz_Boss_Sprs: 
PLC_3E: 
		dc.w	(((PLC_3E_End-PLC_3E-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Spikeball_Laser 
		dc.w	$6F20
		dc.l	Robotnik 
		dc.w	$A300
		dc.l	Robotnik_Faces 
		dc.w	$A000
		dc.l	Robotnik_Body 
		dc.w	$AC80
		dc.l	Boss_Explosions 
		dc.w	$B000
PLC_3E_End:
;-------------------------------------------------------------------------------
SFz_Chase_Sprs: 
PLC_3F: 
		dc.w	(((PLC_3F_End-PLC_3F-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Tornado 
		dc.w	$A000
		dc.l	Tornado_Rocket 
		dc.w	$AC20
		dc.l	Clouds 
		dc.w	$A9E0
PLC_3F_End: 
;-------------------------------------------------------------------------------
Egg_Prison_Sprs: 
PLC_40: 
		dc.w	(((PLC_40_End-PLC_40-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Egg_Prison 
		dc.w	$D000 
PLC_40_End:
;-------------------------------------------------------------------------------
Egg_Prison_Explosions: 
PLC_41: 
		dc.w	(((PLC_41_End-PLC_41-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Explosion 
		dc.w	$B480 
PLC_41_End:
;-------------------------------------------------------------------------------
SS_Results_Sprs: 
PLC_42: 
		dc.w	(((PLC_42_End-PLC_42-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Title_Card_ZONE_123 
		dc.w	$B000
		dc.l	SS_Title_Card_Results 
		dc.w	$B200
		dc.l	SS_Emeralds_Results 
		dc.w	$D600
PLC_42_End: 
;===============================================================================
; PLC
; [ End ]
;===============================================================================

;===============================================================================
; PLC - Left Over 
; [ Begin ]
;=============================================================================== 
		dc.l	SS_Background_8x8_Tiles 
		dc.w	$E000
		dc.l	SS_Background_Stars 
		dc.w	$EFE0 
;------------------------------------------------------------------------------- 
Special_Stage_Sprs_Previous_Build: 
PLC_3D_PB: 
		dc.w	(((PLC_3D_PB_End-PLC_3D_PB-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	SS_Bombs 
		dc.w	$7140
PLC_3D_PB_End: 
;------------------------------------------------------------------------------- 
SFz_Boss_Sprs_Previous_Build: 
PLC_3E_PB: 
		dc.w	(((PLC_3E_PB_End-PLC_3E_PB-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Spikeball_Laser 
		dc.w	$6F20
		dc.l	Robotnik 
		dc.w	$A300
		dc.l	Robotnik_Faces 
		dc.w	$A000
		dc.l	Robotnik_Body 
		dc.w	$AC80
		dc.l	Boss_Explosions 
		dc.w	$B000
PLC_3E_PB_End:
;-------------------------------------------------------------------------------
SFz_Chase_Sprs_Previous_Build: 
PLC_3F_PB: 
		dc.w	(((PLC_3F_PB_End-PLC_3F_PB-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Tornado 
		dc.w	$A000
		dc.l	Tornado_Rocket 
		dc.w	$AC20
		dc.l	Clouds 
		dc.w	$A9E0
PLC_3F_PB_End: 
;------------------------------------------------------------------------------- 
Egg_Prison_Sprs_Previous_Build: 
PLC_40_PB: 
		dc.w	(((PLC_40_PB_End-PLC_40_PB-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Egg_Prison 
		dc.w	$D000 
PLC_40_PB_End:
;-------------------------------------------------------------------------------
Egg_Prison_Explosions_Previous_Build: 
PLC_41_PB: 
		dc.w	(((PLC_41_PB_End-PLC_41_PB-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Explosion 
		dc.w	$B480 
PLC_41_PB_End:
;-------------------------------------------------------------------------------
SS_Results_Sprs_Previous_Build: 
PLC_42_PB: 
		dc.w	(((PLC_42_PB_End-PLC_42_PB-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Title_Card_ZONE_123 
		dc.w	$B000
		dc.l	SS_Title_Card_Results 
		dc.w	$B200
		dc.l	SS_Emeralds_Results 
		dc.w	$D600
PLC_42_PB_End: 
;===============================================================================
; PLC - Left Over 
; [ End ]
;=============================================================================== 

;===============================================================================
; Left Over - Debug Mode 
; [ Begin ]
;=============================================================================== 
		dc.w	$FE06 
		bhi.s	loc_3EBE2
		move.b	#0,(Debug_object).w
loc_3EBE2:
		bra.w	loc_3ECC0
		btst	#5,(Ctrl_1_Press).w
		beq.s	loc_3EC2A
		jsr	SingleObjectLoad+$13C0 
		bne.s	loc_3EC2A
		move.w	8(a0),8(a1)
		move.w	$C(a0),$C(a1)
		move.b	4(a0),0(a1)
		move.b	1(a0),1(a1)
		move.b	1(a0),$22(a1)
		and.b	#$7F,$22(a1)
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		lsl.w	#3,d0
		move.b	4(a2,d0),$28(a1)
		rts
;--------------------------------------------------------------------------------
loc_3EC2A:
		btst	#4,(Ctrl_1_Press).w
		beq.s	loc_3EC8A
		moveq	#0,d0
		move.w	d0,(Debug_placement_mode).w
		lea	(Object_RAM).w,a1
		move.l	#$6FBE0,4(a1)
		move.w	#$780,2(a1)
		tst.w	($FFFFFFD8).w
		beq.s	loc_3EC56
		move.w	#$3C0,2(a1)
loc_3EC56:
		bsr.s	loc_3EC8C
		move.b	#$13,$16(a1)
		move.b	#9,$17(a1)
		move.w	($FFFFFFCC).w,(Camera_Min_Y_pos).w
		move.w	($FFFFFFCE).w,(Camera_Max_Y_pos).w
		cmp.b	#$10,(Game_Mode).w
		bne.s	loc_3EC8A
		move.b	#2,(Object_RAM+anim).w
		bset	#2,(Object_RAM+status).w
		bset	#1,(Object_RAM+status).w
loc_3EC8A:
		rts
;--------------------------------------------------------------------------------
loc_3EC8C:
		move.b	d0,$1C(a1)
		move.w	d0,$A(a1)
		move.w	d0,$E(a1)
		move.b	d0,$2A(a1)
		move.b	d0,$39(a1)
		move.w	d0,$10(a1)
		move.w	d0,$12(a1)
		move.w	d0,$14(a1)
		move.b	#2,$22(a1)
		move.b	#2,$24(a1)
		move.b	#0,$25(a1)
		rts
;--------------------------------------------------------------------------------
loc_3ECC0:
		moveq	#0,d0
		move.b	(Debug_object).w,d0
		lsl.w	#3,d0
		move.l	0(a2,d0),4(a0)
		move.w	6(a2,d0),2(a0)
		move.b	5(a2,d0),$1A(a0)
		bsr.w	loc_3F5BC
		rts
;--------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
Debug_Index_Previous_Build: 
		dc.w	debug_GHz_PB-debug_Index_Previous_Build 
		dc.w	debug_Null_PB-debug_Index_Previous_Build 
		dc.w	debug_Null_PB-debug_Index_Previous_Build 
		dc.w	debug_Null_PB-debug_Index_Previous_Build 
		dc.w	debug_Mz_PB-debug_Index_Previous_Build 
		dc.w	debug_Mz_PB-debug_Index_Previous_Build 
		dc.w	debug_SFz_PB-debug_Index_Previous_Build 
		dc.w	debug_HTz_PB-debug_Index_Previous_Build 
		dc.w	debug_HPz_PB-debug_Index_Previous_Build 
		dc.w	debug_Null_PB-debug_Index_Previous_Build 
		dc.w	debug_OOz_PB-debug_Index_Previous_Build 
		dc.w	debug_DHz_PB-debug_Index_Previous_Build 
		dc.w	debug_CNz_PB-debug_Index_Previous_Build 
		dc.w	debug_CPz_PB-debug_Index_Previous_Build 
		dc.w	debug_Null_PB-debug_Index_Previous_Build 
		dc.w	debug_NGHz_PB-debug_Index_Previous_Build 
		dc.w	debug_SCz_PB-debug_Index_Previous_Build 
;------------------------------------------------------------------------------- 
Debug_Null_PB: 
		dc.w	(((Debug_Null_PB_End-debug_Null_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto 
		dc.l	($25<<$18)|Rings_Mappings+$13B8 
		dc.b	$0,$0
		dc.w	$26BC 
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680
Debug_Null_PB_End: 
;------------------------------------------------------------------------------- 
Debug_GHz_PB: 
		dc.w	(((Debug_GHz_PB_End-debug_GHz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto 
		dc.l	($25<<$18)|Rings_Mappings+$13B8 
		dc.b	$0,$0
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE 
		dc.b	$1,00
		dc.w	$47C
		dc.l	($3<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($49<<$18)|Waterfall_Mappings+$129C 
		dc.b	$0,$0
		dc.w	$239E
		dc.l	($49<<$18)|Waterfall_Mappings+$129C 
		dc.b	$2,$3
		dc.w	$239E
		dc.l	($49<<$18)|Waterfall_Mappings+$129C 
		dc.b	$4,$5
		dc.w	$239E
		dc.l	($18<<$18)|GHz_Platform_Mappings+$13B8
		dc.b	$1,$0
		dc.w	$4000
		dc.l	($18<<$18)|GHz_Platform_Mappings+$13B8
		dc.b	$9A,$1
		dc.w	$4000
		dc.l	($36<<$18)|Spikes_Mappings+$13C8
		dc.b	$0,$0
		dc.w	$2434
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$81,$0
		dc.w	$45C
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$90,$3
		dc.w	$470
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$A0,$6
		dc.w	$45C
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$30,$7
		dc.w	$43C
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$40,$A
		dc.w	$43C
		dc.l	($4B<<$18)|Buzzer_Mappings+$1278
		dc.b	$0,$0
		dc.w	$3D2
		dc.l	($5C<<$18)|Masher_Mappings+$1278 
		dc.b	$0,$0
		dc.w	$414
		dc.l	($9D<<$18)|Coconuts_Mappings+$1220
		dc.b	$1E,$0
		dc.w	$3EE
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680
Debug_GHz_PB_End:
;------------------------------------------------------------------------------- 
Debug_Mz_PB: 
		dc.w	(((Debug_Mz_PB_End-debug_Mz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($3<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($42<<$18)|Steam_Vent_Mappings+$12AC 
		dc.b	$1,$7
		dc.w	$6000
		dc.l	($64<<$18)|Pistons_Mappings+$12AC 
		dc.b	$1,$0
		dc.w	$2000
		dc.l	($64<<$18)|Pistons_Mappings+$12AC 
		dc.b	$11,$1
		dc.w	$2000
		dc.l	($65<<$18)|Mz_Platform_Mappings+$12AE
		dc.b	$80,$0
		dc.w	$6000
		dc.l	($65<<$18)|Mz_Platform_Mappings+$12AE
		dc.b	$13,$1
		dc.w	$6000
		dc.l	($47<<$18)|Switch_Mappings+$12AC 
		dc.b	$0,$2
		dc.w	$424
		dc.l	($2D<<$18)|Automatic_Door_Mappings+$13B8
		dc.b	$1,$1
		dc.w	$6000
		dc.l	($66<<$18)|Springs_Wall_Mappings+$12AC 
		dc.b	$1,$0
		dc.w	$8680
		dc.l	($66<<$18)|Springs_Wall_Mappings+$12AC 
		dc.b	$11,$1
		dc.w	$8680
		dc.l	($68<<$18)|Block_Harpon_Mappings+$12AC 
		dc.b	$0,$4
		dc.w	$6414
		dc.l	($69<<$18)|Screw_Nut_Mappings+$12AC 
		dc.b	$4,$0
		dc.w	$2500
		dc.l	($6A<<$18)|Mz_Platform_Mappings+$12AE
		dc.b	$0,$1
		dc.w	$6000
		dc.l	($6B<<$18)|Mz_Platform_Mappings+$12AE
		dc.b	$7,$1
		dc.w	$6000
		dc.l	($6D<<$18)|Block_Harpon_Mappings+$12AC
		dc.b	$0,$0
		dc.w	$241C
		dc.l	($6E<<$18)|Machine_Mappings+$12AC
		dc.b	$0,$0
		dc.w	$6000
		dc.l	($6E<<$18)|Machine_Mappings+$12AC
		dc.b	$10,$1
		dc.w	$6000
		dc.l	($6E<<$18)|Machine_Mappings+$12AC
		dc.b	$20,$2
		dc.w	$6000
		dc.l	($70<<$18)|Rotating_Gears_Mappings+$12AC 
		dc.b	$10,$0
		dc.w	$E378
		dc.l	($71<<$18)|Mz_Lava_Bubble_Mappings+$13B8
		dc.b	$22,$5
		dc.w	$4536
		dc.l	($1C<<$18)|Mz_Misc_Mappings+$13B8
		dc.b	$0,$0
		dc.w	$43FD
		dc.l	($1C<<$18)|Mz_Misc_Mappings+$13B8
		dc.b	$1,$1
		dc.w	$43FD
		dc.l	($1C<<$18)|Mz_Misc_Mappings+$13B8
		dc.b	$3,$2
		dc.w	$23FD
		dc.l	($65<<$18)|Mz_Platform_Mappings+$12AE 
		dc.b	$B0,$0
		dc.w	$6000 
		dc.l	($9F<<$18)|Shellcracker_Mappings+$1220
		dc.b	$24,$0
		dc.w	$31C
		dc.l	($A4<<$18)|Asteron_Mappings+$1220 
		dc.b	$2E,$0
		dc.w	$8368
		dc.l	($A1<<$18)|Slicer_Mappings+$1220 
		dc.b	$28,$0
		dc.w	$243C
		dc.l	($31<<$18)|Lava_Attributes_Mappings+$129C
		dc.b	$0,$0
		dc.w	$8680
		dc.l	($31<<$18)|Lava_Attributes_Mappings+$129C
		dc.b	$1,$1
		dc.w	$8680
		dc.l	($31<<$18)|Lava_Attributes_Mappings+$129C
		dc.b	$2,$2
		dc.w	$8680
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680
Debug_Mz_PB_End: 
;------------------------------------------------------------------------------- 
Debug_SFz_PB: 
		dc.w	(((Debug_SFz_PB_End-debug_SFz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8 
		dc.b	$0,$0 
		dc.w	$26BC 
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($8B<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$0,$0
		dc.w	$6BC 
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($B3<<$18)|Clouds_Mappings+$1220 
		dc.b	$5E,$0
		dc.w	$454F
		dc.l	($B3<<$18)|Clouds_Mappings+$1220 
		dc.b	$60,$1
		dc.w	$454F
		dc.l	($B3<<$18)|Clouds_Mappings+$1220 
		dc.b	$62,$2
		dc.w	$454F
		dc.l	($B4<<$18)|Vertical_Helix_Mappings+$1220 
		dc.b	$64,$0
		dc.w	$A561
		dc.l	($B5<<$18)|Horizontal_Helix_Mappings+$1220
		dc.b	$66,$0
		dc.w	$A3CD
		dc.l	($B5<<$18)|Horizontal_Helix_Mappings+$1220 
		dc.b	$68,$0
		dc.w	$A3CD
		dc.l	($AD<<$18)|Clucker_Mappings+$1220 
		dc.b	$42,$C
		dc.w	$379
		dc.l	($AE<<$18)|Clucker_Mappings+$1220 
		dc.b	$44,$B
		dc.w	$379
		dc.l	($B6<<$18)|Platform_Helix_Mappings+$1220 
		dc.b	$6A,$0
		dc.w	$A393
		dc.l	($B6<<$18)|Platform_Helix_Mappings+$1220 
		dc.b	$6C,$0
		dc.w	$A393
		dc.l	($B6<<$18)|Platform_Helix_Mappings+$1220 
		dc.b	$6E,$0
		dc.w	$A393
		dc.l	($B6<<$18)|Platform_Helix_Mappings+$1220 
		dc.b	$70,$0
		dc.w	$A393
		dc.l	($B7<<$18)|Vertical_Large_Laser_Mappings+$1220 
		dc.b	$72,$0
		dc.w	$C39F
		dc.l	($B8<<$18)|SFz_Cannon_Mappings+$1220 
		dc.b	$74,$0
		dc.w	$3AB
		dc.l	($B9<<$18)|Laser_Mappings+$1220 
		dc.b	$76,$0
		dc.w	$C3C3
		dc.l	($BA<<$18)|Conveyor_Belt_Wheels_Mappings+$1220
		dc.b	$78,$0
		dc.w	$C3EA
		dc.l	($BC<<$18)|Ship_Boost_Mappings+$1220 
		dc.b	$7C,$0
		dc.w	$4465
		dc.l	($BD<<$18)|SFz_Elevators_Mappings+$1220 
		dc.b	$7E,$0
		dc.w	$E40E
		dc.l	($BD<<$18)|SFz_Elevators_Mappings+$1220 
		dc.b	$80,$0
		dc.w	$E40E
		dc.l	($BE<<$18)|Hatchway_Mappings+$1220 
		dc.b	$82,$0
		dc.w	$E41A
		dc.l	($BF<<$18)|Engine_Part_Mappings+$1220 
		dc.b	$84,$0
		dc.w	$E450
		dc.l	($C0<<$18)|Speed_Booster_Mappings+$1220 
		dc.b	$8,$0
		dc.w	$A45C
		dc.l	($C1<<$18)|Breakable_Wall_Mappings+$1220 
		dc.b	$88,$0
		dc.w	$E48C
		dc.l	($C2<<$18)|SFz_Boss_Access_Switch_Mappings+$121A 
		dc.b	$8A,$0
		dc.w	$A461
		dc.l	($19<<$18)|Rotating_Platforms_Mappings+$12AC 
		dc.b	$38,$3
		dc.w	$A46D
		dc.l	($D9<<$18)|Rings_Mappings+$13B8 
		dc.b	$0,$0
		dc.w	$26BC
		dc.l	($80<<$18)|Chain_Hook_Mappings+$12A2 
		dc.b	$0,$0
		dc.w	$23FE
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680
Debug_SFz_PB_End: 
;------------------------------------------------------------------------------- 
Debug_HTz_PB: 
		dc.w	(((Debug_HTz_PB_End-debug_HTz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($84<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$0,$0
		dc.w	$6BC 
		dc.l	($84<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$4,$4
		dc.w	$6BC
		dc.l	($3<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($18<<$18)|GHz_Platform_Mappings+$13B8
		dc.b	$1,$0
		dc.w	$4000
		dc.l	($18<<$18)|GHz_Platform_Mappings+$13B8 
		dc.b	$9A,$1
		dc.w	$4000
		dc.l	($36<<$18)|Spikes_Mappings+$13C8
		dc.b	$0,$0
		dc.w	$2434
		dc.l	($14<<$18)|See_Saw_Mappings+$12B0 
		dc.b	$0,$0
		dc.w	$3C6
		dc.l	($2D<<$18)|Automatic_Door_Mappings+$13B8
		dc.b	$0,$0
		dc.w	$2426
		dc.l	($2F<<$18)|Breakable_Floor_Mappings+$12AC
		dc.b	$0,$0
		dc.w	$C000
		dc.l	($20<<$18)|Lava_Bubble_Mappings+$12AC 
		dc.b	$44,$2
		dc.w	$8416 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$81,$0
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$90,$3
		dc.w	$470 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$A0,$6
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$30,$7
		dc.w	$43C 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$40,$A
		dc.w	$43C
		dc.l	($16<<$18)|Teleferics_Mappings+$12B0 
		dc.b	$0,$0
		dc.w	$43E6
		dc.l	($1C<<$18)|Teleferics_Mappings+$12B0 
		dc.b	$4,$3
		dc.w	$43E6
		dc.l	($1C<<$18)|Teleferics_Mappings+$12B0 
		dc.b	$5,$4
		dc.w	$43E6
		dc.l	($1C<<$18)|HTz_Misc_Mappings+$13B8 
		dc.b	$7,$0
		dc.w	$4000
		dc.l	($1C<<$18)|HTz_Misc_Mappings+$13B8 
		dc.b	$8,$1
		dc.w	$4000
		dc.l	($32<<$18)|HTz_Rock_Mappings+$12AC
		dc.b	$0,$0
		dc.w	$43B2
		dc.l	($31<<$18)|Lava_Attributes_Mappings+$129C
		dc.b	$0,$0
		dc.w	$8680
		dc.l	($31<<$18)|Lava_Attributes_Mappings+$129C
		dc.b	$1,$1
		dc.w	$8680
		dc.l	($31<<$18)|Lava_Attributes_Mappings+$129C 
		dc.b	$2,$2
		dc.w	$8680
		dc.l	($96<<$18)|Rexon_Mappings+$1220
		dc.b	$E,$2
		dc.w	$637E
		dc.l	($92<<$18)|Spiker_Mappings+$1220 
		dc.b	$A,$0
		dc.w	$0
		dc.l	($95<<$18)|Sol_Mappings+$1220 
		dc.b	$0,$0
		dc.w	$0
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680
Debug_HTz_PB_End: 
;------------------------------------------------------------------------------- 
Debug_HPz_PB: 
		dc.w	(((Debug_HPz_PB_End-debug_HPz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($71<<$18)|Hpz_Orbs_Mappings+$13B8 
		dc.b	$11,$3
		dc.w	$E35A
		dc.l	($13<<$18)|Hpz_Waterfalls_Mappings+$129C 
		dc.b	$4,$4
		dc.w	$E315
		dc.l	($1A<<$18)|HPz_Collapsing_Platforms_Mappings+$13B8
		dc.b	$0,$0
		dc.w	$434A
		dc.l	($3<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$9,$1
		dc.w	$26BC 
		dc.l	($4F<<$18)|Dinobot_Mappings+$1278
		dc.b	$0,$0
		dc.w	$500
		dc.l	($4C<<$18)|Batbot_Mappings+$1278 
		dc.b	$0,$0
		dc.w	$2530
		dc.l	($4D<<$18)|Rhinobot_Mappings+$1278 
		dc.b	$0,$0 
		dc.w	$23B2 
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680 
Debug_HPz_PB_End: 
;-------------------------------------------------------------------------------
Debug_OOz_PB: 
		dc.w	(((Debug_OOz_PB_End-debug_OOz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8 
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($33<<$18)|Touch_Booster_Mappings+$12AC 
		dc.b	$1,$0
		dc.w	$632C
		dc.l	($43<<$18)|Giant_Spikeball_Mappings+$12AC 
		dc.b	$0,$0
		dc.w	$C30C
		dc.l	($19<<$18)|Rotating_Platforms_Mappings+$12AC 
		dc.b	$23,$2
		dc.w	$62F4
		dc.l	($45<<$18)|Spring_Push_Boost_Mappings+$12AC 
		dc.b	$2,$0
		dc.w	$43C5
		dc.l	($45<<$18)|Spring_Push_Boost_Mappings+$12AC 
		dc.b	$12,$A
		dc.w	$43C5
		dc.l	($46<<$18)|Spring_Ball_Mappings+$12AC 
		dc.b	$0,$1
		dc.w	$6354
		dc.l	($47<<$18)|Switch_Mappings+$12AC 
		dc.b	$0,$2
		dc.w	$424
		dc.l	($15<<$18)|OOz_Swing_Platforms_Mappings+$13B8
		dc.b	$88,$1
		dc.w	$43E3
		dc.l	($3D<<$18)|Break_Boost_Mappings+$12AC 
		dc.b	$0,$0
		dc.w	$6332
		dc.l	($48<<$18)|Cannon_Mappings+$12AC 
		dc.b	$80,$0
		dc.w	$6368
		dc.l	($48<<$18)|Cannon_Mappings+$12AC 
		dc.b	$81,$1
		dc.w	$6368
		dc.l	($48<<$18)|Cannon_Mappings+$12AC 
		dc.b	$82,$2
		dc.w	$6368
		dc.l	($48<<$18)|Cannon_Mappings+$12AC 
		dc.b	$83,$3
		dc.w	$6368
		dc.l	($1F<<$18)|OOz_Collapsing_Platforms_Mappings+$13B8
		dc.b	$0,$0
		dc.w	$639D
		dc.l	($3F<<$18)|Vertical_Fan_Mappings+$12A0 
		dc.b	$0,$0
		dc.w	$6403
		dc.l	($3F<<$18)|Horizontal_Fan_Mappings+$12A0 
		dc.b	$80,$0
		dc.w	$6403
		dc.l	($50<<$18)|Aquis_Mappings+$1278
		dc.b	$0,$0
		dc.w	$2500 
		dc.l	($4A<<$18)|Octus_Mappings+$1278 
		dc.b	$0,$0
		dc.w	$2538
		dc.l	($1C<<$18)|OOz_Misc_Mappings+$13B8 
		dc.b	$A,$0
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings+$13B8 
		dc.b	$B,$1
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings+$13B8 
		dc.b	$C,$2
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings+$13B8 
		dc.b	$D,$3
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings+$13B8 
		dc.b	$E,$4
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings+$13B8 
		dc.b	$F,$5
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01+$13B8 
		dc.b	$10,$0
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01+$13B8 
		dc.b	$11,$1
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01+$13B8 
		dc.b	$12,$2
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01+$13B8 
		dc.b	$13,$3
		dc.w	$4346
		dc.l	($1C<<$18)|OOz_Misc_Mappings_01+$13B8 
		dc.b	$14,$4
		dc.w	$4346
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680 
Debug_OOz_PB_End: 
;-------------------------------------------------------------------------------
Debug_DHz_PB: 
		dc.w	(((Debug_DHz_PB_End-debug_DHz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($15<<$18)|DHz_Swing_Platforms_Mappings+$13B8
		dc.b	$48,$2
		dc.w	$0
		dc.l	($1F<<$18)|DHz_Collapsing_Platforms_Mappings+$13B8
		dc.b	$0,$0
		dc.w	$63F4 
		dc.l	($73<<$18)|Rotating_Rings_Mappings+$12AC 
		dc.b	$F5,$0
		dc.w	$26BC 
		dc.l	($6A<<$18)|Rotating_Boxes_Mappings+$12AC 
		dc.b	$18,$0
		dc.w	$63D4
		dc.l	($2A<<$18)|Up_Down_Pillar_Mappings+$13B8
		dc.b	$0,$0
		dc.w	$4000
		dc.l	($36<<$18)|Spikes_Mappings+$13C8
		dc.b	$0,$0
		dc.w	$2434 
		dc.l	($36<<$18)|Spikes_Mappings+$13C8
		dc.b	$40,$4
		dc.w	$242C 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$81,$0
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$90,$3
		dc.w	$470 
		dc.l	($40<<$18)|Diagonal_Spring_Mappings+$12AC 
		dc.b	$1,$0
		dc.w	$440
		dc.l	($74<<$18)|Invisible_Block_Mappings+$129C
		dc.b	$11,$0
		dc.w	$8680
		dc.l	($75<<$18)|Spikeball_Chain_Mappings+$12AC 
		dc.b	$18,$2
		dc.w	$2000
		dc.l	($76<<$18)|Platform_Spikes_Mappings+$12AC 
		dc.b	$0,$0
		dc.w	$0
		dc.l	($77<<$18)|Dhz_Bridge_Mappings+$12AC 
		dc.b	$1,$0
		dc.w	$643C
		dc.l	($7F<<$18)|Vines_Switch_Mappings+$12AC 
		dc.b	$0,$0
		dc.w	$640E
		dc.l	($80<<$18)|Vines_Mappings+$12A2 
		dc.b	$0,$0
		dc.w	$641E
		dc.l	($81<<$18)|Vertical_Bridge_Mappings+$12A0 
		dc.b	$0,$1
		dc.w	$643C
		dc.l	($7A<<$18)|DHz_Swing_Platforms_Mappings+$13B8
		dc.b	$12,$0
		dc.w	$0
		dc.l	($A3<<$18)|Flasher_Mappings+$1220 
		dc.b	$2C,$0
		dc.w	$83A8
		dc.l	($9E<<$18)|Crawlton_Mappings+$1220 
		dc.b	$22,$0
		dc.w	$23C0
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680 
Debug_DHz_PB_End: 
;-------------------------------------------------------------------------------
Debug_CNz_PB: 
		dc.w	(((Debug_CNz_PB_End-debug_CNz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE 
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($84<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$0,$0
		dc.w	$6BC 
		dc.l	($84<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$4,$4
		dc.w	$6BC 
		dc.l	($3<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$9,$1
		dc.w	$26BC 
		dc.l	($3<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$D,$5
		dc.w	$26BC
		dc.l	($44<<$18)|Red_Ball_Bumper_Mappings+$1274
		dc.b	$0,$0
		dc.w	$439A
		dc.l	($85<<$18)|Diagonal_Pinball_Spring_Mappings+$129C 
		dc.b	$0,$0
		dc.w	$422
		dc.l	($85<<$18)|Vertical_Pinball_Spring_Mappings+$129C 
		dc.b	$81,$0
		dc.w	$402
		dc.l	($86<<$18)|Flippers_Mappings+$1294 
		dc.b	$0,$0
		dc.w	$43B2
		dc.l	($86<<$18)|Flippers_Mappings+$1294 
		dc.b	$1,$4
		dc.w	$43B2
		dc.l	($D2<<$18)|Green_Platform_Mappings+$1294 
		dc.b	$1,$0
		dc.w	$437C
		dc.l	($D3<<$18)|Spikeball_Mappings+$1294 
		dc.b	$0,$0
		dc.w	$380
		dc.l	($D4<<$18)|Blue_Box_Mappings+$1294 
		dc.b	$0,$0
		dc.w	$436C
		dc.l	($D4<<$18)|Blue_Box_Mappings+$1294 
		dc.b	$2,$0
		dc.w	$436C
		dc.l	($D5<<$18)|CNz_Elevator_Mappings+$1294 
		dc.b	$18,$0
		dc.w	$4384
		dc.l	($D6<<$18)|Slot_Machine_Starter_Mappings+$1276 
		dc.b	$1,$0
		dc.w	$388
		dc.l	($D7<<$18)|Blue_Bumper_Mappings+$1278 
		dc.b	$0,$0
		dc.w	$4394
		dc.l	($D8<<$18)|Green_Bumper_Mappings+$1278 
		dc.b	$0,$0
		dc.w	$43E6
		dc.l	($D8<<$18)|Green_Bumper_Mappings+$1278 
		dc.b	$40,$1
		dc.w	$43E6
		dc.l	($D8<<$18)|Green_Bumper_Mappings+$1278 
		dc.b	$80,$2
		dc.w	$43E6
		dc.l	($C8<<$18)|Crawl_Mappings+$121A 
		dc.b	$AC,$0
		dc.w	$8340
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680
Debug_CNz_PB_End: 
;-------------------------------------------------------------------------------
Debug_CPz_PB: 
		dc.w	(((Debug_CPz_PB_End-debug_CPz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($B<<$18)|Open_Close_Platform_Mappings+$129C 
		dc.b	$70,$0
		dc.w	$E3B0
		dc.l	($1B<<$18)|CPz_Speed_Booster_Mappings+$12AC
		dc.b	$0,$0
		dc.w	$E39C
		dc.l	($1D<<$18)|Worms_Mappings+$12AC 
		dc.b	$5,$0
		dc.w	$E43C
		dc.l	($19<<$18)|Rotating_Platforms_Mappings+$12AC 
		dc.b	$6,$0
		dc.w	$63A0
		dc.l	($2D<<$18)|Automatic_Door_Mappings+$13B8
		dc.b	$2,$2
		dc.w	$2394
		dc.l	($32<<$18)|CPz_Tunel_Obstacle_Mappings+$12AC 
		dc.b	$0,$0
		dc.w	$6430
		dc.l	($6B<<$18)|CPz_Block_Mappings+$12AC 
		dc.b	$10,$0 
		dc.w	$6418
		dc.l	($78<<$18)|CPz_Block_Mappings+$12AC 
		dc.b	$0,$0
		dc.w	$6418
		dc.l	($7A<<$18)|Platform_Horizontal_Mappings+$12AC 
		dc.b	$0,$0
		dc.w	$E418
		dc.l	($7B<<$18)|Spring_Tubes_Mappings+$12AC 
		dc.b	$2,$0
		dc.w	$3E0
		dc.l	($3<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($3<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$D,$5
		dc.w	$26BC
		dc.l	($36<<$18)|Spikes_Mappings+$13C8
		dc.b	$0,$0
		dc.w	$2434 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$81,$0
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$90,$3
		dc.w	$470
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$A0,$6
		dc.w	$45C
		dc.l	($40<<$18)|Diagonal_Spring_Mappings+$12AC
		dc.b	$1,$0
		dc.w	$440
		dc.l	($A5<<$18)|Lander_Mappings+$1220 
		dc.b	$32,$0
		dc.w	$252D
		dc.l	($A6<<$18)|Lander_Mappings+$1220 
		dc.b	$32,$3
		dc.w	$252D
		dc.l	($A7<<$18)|Grabber_Mappings+$1220 
		dc.b	$36,$0
		dc.w	$A500
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680
Debug_CPz_PB_End:
;-------------------------------------------------------------------------------
Debug_NGHz_PB: 
		dc.w	(((Debug_NGHz_PB_End-debug_NGHz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($79<<$18)|Star_Post_Mappings+$13BE
		dc.b	$1,00
		dc.w	$47C 
		dc.l	($15<<$18)|NGHz_Swing_Platforms_Mappings+$13B8 
		dc.b	$88,$2
		dc.w	$0
		dc.l	($18<<$18)|NGHz_Platform_Mappings+$13B8 
		dc.b	$1,$0
		dc.w	$4000
		dc.l	($18<<$18)|NGHz_Platform_Mappings+$13B8 
		dc.b	$9A,$1
		dc.w	$4000
		dc.l	($22<<$18)|Arrow_Shooter_Mappings+$12AC
		dc.b	$0,$1
		dc.w	$417
		dc.l	($23<<$18)|Pillar_Mappings+$12AC 
		dc.b	$0,$0
		dc.w	$2000
		dc.l	($2B<<$18)|Raising_Pillar_Mappings+$12AC 
		dc.b	$0,$0
		dc.w	$2000
		dc.l	($2C<<$18)|Lava_Attributes_Mappings+$129C
		dc.b	$0,$0
		dc.w	$8680
		dc.l	($2C<<$18)|Lava_Attributes_Mappings+$129C
		dc.b	$1,$1
		dc.w	$8680
		dc.l	($2C<<$18)|Lava_Attributes_Mappings+$129C
		dc.b	$2,$2
		dc.w	$8680
		dc.l	($40<<$18)|Diagonal_Spring_Mappings+$12AC
		dc.b	$1,$0
		dc.w	$440
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$81,$0
		dc.w	$45C 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$90,$3
		dc.w	$470 
		dc.l	($41<<$18)|Springs_Mappings+$13C0 
		dc.b	$A0,$6
		dc.w	$45C
		dc.l	($3<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$9,$1
		dc.w	$26BC
		dc.l	($36<<$18)|Spikes_Mappings+$13C8
		dc.b	$0,$0
		dc.w	$2434 
		dc.l	($2D<<$18)|Automatic_Door_Mappings+$13B8
		dc.b	$3,$3
		dc.w	$23F8
		dc.l	($1F<<$18)|NGHz_Collapsing_Platforms_Mappings+$13B8 
		dc.b	$0,$0
		dc.w	$4000
		dc.l	($82<<$18)|Falling_Pillar_Mappings+$12A0 
		dc.b	$3,$0
		dc.w	$0
		dc.l	($82<<$18)|Falling_Pillar_Mappings+$12A0 
		dc.b	$11,$1
		dc.w	$0
		dc.l	($83<<$18)|NGHz_Swing_Platforms_Mappings+$13B8 
		dc.b	$10,$1
		dc.w	$0
		dc.l	($24<<$18)|Sonic_Underwater_Mappings+$1274
		dc.b	$81,$E
		dc.w	$855B
		dc.l	($91<<$18)|Chop_Chop_Mappings+$1220 
		dc.b	$8,$0
		dc.w	$253B
		dc.l	($8C<<$18)|Whisp_Mappings+$1220 
		dc.b	$0,$0
		dc.w	$A500
		dc.l	($8D<<$18)|Grounder_Mappings+$1220 
		dc.b	$2,$0
		dc.w	$A509
		dc.l	($8E<<$18)|Grounder_Mappings+$1220 
		dc.b	$2,$0
		dc.w	$A509
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680
Debug_NGHz_PB_End: 
;-------------------------------------------------------------------------------
Debug_SCz_PB: 
		dc.w	(((Debug_SCz_PB_End-debug_SCz_PB-$2)/$8)) ; Auto Detect Number of Objects Esrael L. G. Neto
		dc.l	($25<<$18)|Rings_Mappings+$13B8
		dc.b	$0,$0 
		dc.w	$26BC
		dc.l	($26<<$18)|Monitors_Mappings+$13B2 
		dc.b	$8,$0
		dc.w	$680 
		dc.l	($8B<<$18)|Layer_Switch_Mappings+$1298 
		dc.b	$0,$0
		dc.w	$6BC
		dc.l	($B3<<$18)|Clouds_Mappings+$1220 
		dc.b	$5E,$0
		dc.w	$454F
		dc.l	($B3<<$18)|Clouds_Mappings+$1220 
		dc.b	$60,$1
		dc.w	$454F
		dc.l	($B3<<$18)|Clouds_Mappings+$1220 
		dc.b	$62,$2
		dc.w	$454F
		dc.l	($B4<<$18)|Vertical_Helix_Mappings+$1220 
		dc.b	$64,$0
		dc.w	$A561
		dc.l	($B5<<$18)|Horizontal_Helix_Mappings+$1220
		dc.b	$66,$0
		dc.w	$A3CD
		dc.l	($B5<<$18)|Horizontal_Helix_Mappings+$1220
		dc.b	$68,$0
		dc.w	$A3CD
		dc.l	($9A<<$18)|Turtloid_Mappings+$1220 
		dc.b	$16,$0
		dc.w	$38A
		dc.l	($AC<<$18)|Balkiry_Mappings+$1220 
		dc.b	$40,$0
		dc.w	$565
		dc.l	($99<<$18)|Nebula_Mappings+$1220 
		dc.b	$12,$0
		dc.w	$A36E
		dc.l	($3E<<$18)|Egg_Prison_Mappings+$1218 
		dc.b	$0,$0
		dc.w	$2680 
Debug_SCz_PB_End: 
		nop ; Filler
loc_3F5BC:
		jmp	ModifySpriteAttr_2P+$13C0 
		cnop	0,4 ; Filler 
;===============================================================================
; Left Over - Debug Mode
; [ End ]
;=============================================================================== 
		
;===============================================================================
; Left Over - Tiles Main Table
; [ Begin ]
;=============================================================================== 
TilesMainTable_Previous_Build: 
		dc.l	($4<<$18)|Green_Hill_8x8_Tiles-$14CA 
		dc.l	($5<<$18)|Green_Hill_16x16_Map-$14CA 
		dc.l	($4<<$18)|Green_Hill_128x128_Map-$14CA 
		dc.l	($6<<$18)|Green_Hill_8x8_Tiles-$14CA 
		dc.l	($7<<$18)|Green_Hill_16x16_Map-$14CA 
		dc.l	($5<<$18)|Green_Hill_128x128_Map-$14CA 
		dc.l	($8<<$18)|Green_Hill_8x8_Tiles-$14CA 
		dc.l	($9<<$18)|Green_Hill_16x16_Map-$14CA 
		dc.l	($6<<$18)|Green_Hill_128x128_Map-$14CA 
		dc.l	($A<<$18)|Green_Hill_8x8_Tiles-$14CA 
		dc.l	($B<<$18)|Green_Hill_16x16_Map-$14CA 
		dc.l	($7<<$18)|Green_Hill_128x128_Map-$14CA 
		dc.l	($C<<$18)|Metropolis_8x8_Tiles-$14CA 
		dc.l	($D<<$18)|Metropolis_16x16_Map-$14CA 
		dc.l	($8<<$18)|Metropolis_128x128_Map-$14CA 
		dc.l	($C<<$18)|Metropolis_8x8_Tiles-$14CA 
		dc.l	($D<<$18)|Metropolis_16x16_Map-$14CA 
		dc.l	($8<<$18)|Metropolis_128x128_Map-$14CA 
		dc.l	($10<<$18)|Sky_Fortress_8x8_Tiles-$149A 
		dc.l	($11<<$18)|Sky_Fortress_16x16_Map-$149A 
		dc.l	($A<<$18)|Sky_Fortress_128x128_Map-$149A 
		dc.l	($12<<$18)|Green_Hill_8x8_Tiles-$14CA 
		dc.l	($13<<$18)|Green_Hill_16x16_Map-$14CA 
		dc.l	($B<<$18)|Green_Hill_128x128_Map-$14CA 
		dc.l	($14<<$18)|Hidden_Palace_8x8_Tiles-$14CA 
		dc.l	($15<<$18)|Hidden_Palace_16x16_Map-$14CA 
		dc.l	($C<<$18)|Hidden_Palace_128x128_Map-$14CA 
		dc.l	($16<<$18)|Green_Hill_8x8_Tiles-$14CA 
		dc.l	($17<<$18)|Green_Hill_16x16_Map-$14CA 
		dc.l	($D<<$18)|Green_Hill_128x128_Map-$14CA 
		dc.l	($18<<$18)|Oil_Ocean_8x8_Tiles-$14CA 
		dc.l	($19<<$18)|Oil_Ocean_16x16_Map-$14CA 
		dc.l	($E<<$18)|Oil_Ocean_128x128_Map-$14CA 
		dc.l	($1A<<$18)|Dust_Hill_8x8_Tiles-$14CA 
		dc.l	($1B<<$18)|Dust_Hill_16x16_Map-$14CA 
		dc.l	($F<<$18)|Dust_Hill_128x128_Map-$14CA 
		dc.l	($1C<<$18)|Casino_Night_8x8_Tiles-$14CA 
		dc.l	($1D<<$18)|Casino_Night_16x16_Map-$14CA 
		dc.l	($10<<$18)|Casino_Night_128x128_Map-$14CA 
		dc.l	($1E<<$18)|Chemical_Plant_8x8_Tiles-$14CA 
		dc.l	($1F<<$18)|Chemical_Plant_16x16_Map-$14CA 
		dc.l	($11<<$18)|Chemical_Plant_128x128_Map-$14CA 
		dc.l	($20<<$18)|Chemical_Plant_8x8_Tiles-$14CA 
		dc.l	($21<<$18)|Chemical_Plant_16x16_Map-$14CA 
		dc.l	($12<<$18)|Chemical_Plant_128x128_Map-$14CA 
		dc.l	($22<<$18)|Neo_Green_Hill_8x8_Tiles-$149A 
		dc.l	($23<<$18)|Neo_Green_Hill_16x16_Map-$149A 
		dc.l	($13<<$18)|Neo_Green_Hill_128x128_Map-$149A 
		dc.l	($24<<$18)|Sky_Fortress_8x8_Tiles-$149A 
		dc.l	($25<<$18)|Sky_Fortress_16x16_Map-$149A 
		dc.l	($14<<$18)|Sky_Fortress_128x128_Map-$149A 
;===============================================================================
; Left Over - Tiles Main Table
; [ End ]
;=============================================================================== 
;===============================================================================
; PLC - Previous Build
; [ Begin ]
;===============================================================================
ArtLoadCues_Previous_Build: 
		dc.w	default_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	default_Level_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	Enemies_Explosions_PB-ArtLoadCues_Previous_Build 
		dc.w	Game_Time_Over_PB_Spr-ArtLoadCues_Previous_Build 
		dc.w	GHz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	GHz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	Mz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	Mz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	Mz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	Mz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	Mz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	Mz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	Mz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	Mz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	SFz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	SFz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	SFz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	SFz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	HTz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	HTz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	HPz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	HPz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	OOz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	OOz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	OOz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	OOz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	dHz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	dHz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	CNz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	CNz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	CPz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	CPz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	dEz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	dEz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	NGHz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	NGHz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	SCz_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	SCz_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	Level_Results_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	End_Level_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	CPz_Boss_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	GHz_Boss_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	HTz_Boss_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	NGHz_Boss_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	dHz_Boss_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	CNz_Boss_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	Mz_Boss_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	OOz_Boss_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	dEz_Boss_PB_Spr-ArtLoadCues_Previous_Build 
		dc.w	Final_Boss_PB_Spr-ArtLoadCues_Previous_Build 
		dc.w	GHz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	dHz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	Mz_SFz_HTz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	dEz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	HPz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	OOz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	SCz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	CNz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	CPz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	NGHz_Flickies_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	Special_Stage_PB_Sprs_0-ArtLoadCues_Previous_Build 
		dc.w	Special_Stage_PB_Sprs_1-ArtLoadCues_Previous_Build 
		dc.w	SFz_Boss_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	SFz_Chase_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	Egg_Prison_PB_Sprs-ArtLoadCues_Previous_Build 
		dc.w	Egg_Prison_Explosions_PB-ArtLoadCues_Previous_Build 
;===============================================================================
; Default Sprites - Loaded during Title Screen
; [ Begin ] 
;=============================================================================== 
Default_PB_Sprs: 
PLC_PB_00:
		dc.w	(((PLC_PB_00_End-PLC_PB_00-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Star_Post 
		dc.w	$8F80
		dc.l	Head_up_display_Sprites 
		dc.w	$D940 
		dc.l	Head_up_display_Sonic 
		dc.w	$FA80 
		dc.l	Rings_Sprites 
		dc.w	$D780
		dc.l	Enemy_Points_Spr 
		dc.w	$9580
		dc.l	Head_up_display_Miles 
		dc.w	$DE80 
PLC_PB_00_End:
;===============================================================================
; Default Sprites - Loaded during Title Screen
; [ End ] 
;===============================================================================

;===============================================================================
; Default Sprites - Loaded at begin of Level
; [ Begin ] 
;=============================================================================== 
Default_Level_PB_Sprs: 
PLC_PB_01:
		dc.w	(((PLC_PB_01_End-PLC_PB_01-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Monitors 
		dc.w	$D000
		dc.l	Shield 
		dc.w	$97C0
		dc.l	Invencibility_Stars 
		dc.w	$9BC0
PLC_PB_01_End:
;===============================================================================
; Default Sprites - Loaded at begin of Level
; [ End ] 
;===============================================================================

;===============================================================================
; Enemies / Monitors Explosions - Loaded after Title Cards 
; [ Begin ] 
;===============================================================================
Enemies_Explosions_PB: 
PLC_PB_02: 
		dc.w	(((PLC_PB_02_End-PLC_PB_02-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Explosion 
		dc.w	$B480
		dc.l	Water_Splash 
		dc.w	$BE40
		dc.l	Bubbles 
		dc.w	$BD00
PLC_PB_02_End: 
;===============================================================================
; Enemies / Monitors Explosions - Loaded after Title Cards 
; [ End ] 
;=============================================================================== 

Game_Time_Over_PB_Spr: 
PLC_PB_03: 
		dc.w	(((PLC_PB_03_End-PLC_PB_03-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Game_Time_Over 
		dc.w	$9BC0 
PLC_PB_03_End:
;-------------------------------------------------------------------------------
GHz_PB_Sprs_0: 
PLC_PB_04: 
		dc.w	(((PLC_PB_04_End-PLC_PB_04-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	GHz_Waterfall 
		dc.w	$73C0
		dc.l	GHz_Bridge 
		dc.w	$76C0
		dc.l	FireBall 
		dc.w	$77C0
		dc.l	GHz_Buzzer-$14CA 
		dc.w	$7A40
		dc.l	GHz_Coconuts-$14CA 
		dc.w	$7DC0
		dc.l	GHz_Masher-$14CA 
		dc.w	$8280
PLC_PB_04_End:
;-------------------------------------------------------------------------------
GHz_PB_Sprs_1: 
PLC_PB_05: 
		dc.w	(((PLC_PB_05_End-PLC_PB_05-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_PB_05_End: 
;-------------------------------------------------------------------------------
Mz_PB_Sprs_0: 
PLC_PB_0C: 
		dc.w	(((PLC_PB_0C_End-PLC_PB_0C-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Mz_Rotating_Gear 
		dc.w	$6F00
		dc.l	Mz_Gear_Holes 
		dc.w	$7E00
		dc.l	Mz_Elevator 
		dc.w	$7F20
		dc.l	Mz_Miscellaneous 
		dc.w	$7FA0
		dc.l	Mz_Steam 
		dc.w	$80A0
		dc.l	Mz_Harpon_Platform 
		dc.w	$8280
		dc.l	Mz_Harpon 
		dc.w	$8380
		dc.l	Shellcracker-$14CA 
		dc.w	$6380
		dc.l	asteron-$14CA 
		dc.w	$6D00
PLC_PB_0C_End:
;------------------------------------------------------------------------------- 
Mz_PB_Sprs_1: 
PLC_PB_0D: 
		dc.w	(((PLC_PB_0D_End-PLC_PB_0D-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto 
		dc.l	Switch 
		dc.w	$8480
		dc.l	Spikes 
		dc.w	$8680
		dc.l	Slicer-$14CA 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
		dc.l	Mz_Screw_Nut 
		dc.w	$A000
		dc.l	Mz_Lava_Bubble 
		dc.w	$A6C0
		dc.l	Mz_Mini_Gear 
		dc.w	$ABE0
		dc.l	Mz_Teleport_Flash 
		dc.w	$AD60 
PLC_PB_0D_End:
;------------------------------------------------------------------------------- 
SFz_PB_Sprs_0: 
PLC_PB_10: 
		dc.w	(((PLC_PB_10_End-PLC_PB_10-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship_Spr-$149A
		dc.w	$60E0 
		dc.l	Tornado-$14CA 
		dc.w	$A000
		dc.l	Clouds-$14CA 
		dc.w	$A9E0
		dc.l	Vertical_Helix_Spr-$14CA 
		dc.w	$AC20
		dc.l	Horizontal_Helix_Spr-$14CA 
		dc.w	$79A0
		dc.l	Balkiry-$14CA 
		dc.w	$ACA0
		dc.l	Breakable_Wall 
		dc.w	$9180
		dc.l	Clucker-$14CA 
		dc.w	$6F20
		dc.l	Rotating_Helix-$14CA 
		dc.w	$7260
		dc.l	Tornado-$14CA 
		dc.w	$A000
		dc.l	Clouds-$14CA 
		dc.w	$A9E0
PLC_PB_10_End: 
;-------------------------------------------------------------------------------
SFz_PB_Sprs_1: 
PLC_PB_11: 
		dc.w	(((PLC_PB_11_End-PLC_PB_11-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Vertical_Helix_Spr-$14CA 
		dc.w	$AC20
		dc.l	Horizontal_Helix_Spr-$14CA 
		dc.w	$79A0
		dc.l	Vertical_Laser-$14CA 
		dc.w	$73E0
		dc.l	SFz_Cannon-$14CA 
		dc.w	$7560
		dc.l	Horizontal_Laser-$14CA 
		dc.w	$7860
		dc.l	Conveyor_Belts_Wheels-$14CA 
		dc.w	$7D40
		dc.l	Chain_Hook-$14CA 
		dc.w	$7F40
		dc.l	Rocket_Flame_Spr-$14CA 
		dc.w	$8CA0
		dc.l	SFz_Elevators-$14CA 
		dc.w	$81C0
		dc.l	Hatchways-$14CA 
		dc.w	$8340
		dc.l	Engine_Part-$14CA 
		dc.w	$8A00
		dc.l	Speed_Boost-$14CA 
		dc.w	$8B80
		dc.l	Boss_Switch_Spr 
		dc.w	$8C20
		dc.l	SFz_Platform-$14CA 
		dc.w	$8DA0 
PLC_PB_11_End: 
;------------------------------------------------------------------------------- 
HTz_PB_Sprs_0: 
PLC_PB_12: 
		dc.w	(((PLC_PB_12_End-PLC_PB_12-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Hill_Top_8x8_Tiles-$14CA 
		dc.w	$3F80
		dc.l	FireBall 
		dc.w	$73C0
		dc.l	Htz_Rock 
		dc.w	$7640
		dc.l	Htz_See_saw 
		dc.w	$78C0
		dc.l	Htz_See_saw_badnick 
		dc.w	$7BC0
		dc.l	Rexon-$14CA 
		dc.w	$6FC0
		dc.l	Spiker-$14CA 
		dc.w	$A400
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00 
PLC_PB_12_End:
;-------------------------------------------------------------------------------
HTz_PB_Sprs_1: 
PLC_PB_13: 
		dc.w	(((PLC_PB_13_End-PLC_PB_13-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Htz_Teleferic 
		dc.w	$7CC0
		dc.l	Htz_Lava_Bubble 
		dc.w	$82C0
		dc.l	Htz_Automatic_Door 
		dc.w	$84C0
PLC_PB_13_End:
;------------------------------------------------------------------------------- 
HPz_PB_Sprs_0: 
PLC_PB_14: 
		dc.w	(((PLC_PB_14_End-PLC_PB_14-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Hpz_Bridge 
		dc.w	$6000
		dc.l	Hpz_Waterfall 
		dc.w	$62A0
		dc.l	Hpz_Platform 
		dc.w	$6940
		dc.l	Hpz_Orbs_Comp 
		dc.w	$6B40
		dc.l	Hpz_Unknow_Platform 
		dc.w	$6F80
		dc.l	Hpz_Emerald 
		dc.w	$7240
		dc.l	Water_Surface 
		dc.w	$8000
PLC_PB_14_End: 
;-------------------------------------------------------------------------------
HPz_PB_Sprs_1: 
PLC_PB_15: 
		dc.w	(((PLC_PB_15_End-PLC_PB_15-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Hpz_Rhinobot-$14CA
		dc.w	$7640
		dc.l	Hpz_Dinobot-$14CA
		dc.w	$A000
		dc.l	Hpz_Batbot-$14CA
		dc.w	$A600
PLC_PB_15_End: 
;-------------------------------------------------------------------------------
OOz_PB_Sprs_0: 
PLC_PB_18: 
		dc.w	(((PLC_PB_18_End-PLC_PB_18-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	OOz_Fire_Booster 
		dc.w	$5C40
		dc.l	OOz_Elevator 
		dc.w	$5E80
		dc.l	OOz_Giant_Spikeball 
		dc.w	$6180
		dc.l	OOz_Touch_Boost_Up 
		dc.w	$6580
		dc.l	OOz_Break_To_Boost_Horizontal 
		dc.w	$6640
		dc.l	OOz_Oil 
		dc.w	$66C0
		dc.l	OOz_Oil_01 
		dc.w	$68C0
		dc.l	OOz_Ball 
		dc.w	$6A80
		dc.l	OOz_Cannon 
		dc.w	$6D00
PLC_PB_18_End: 
;-------------------------------------------------------------------------------
OOz_PB_Sprs_1: 
PLC_PB_19: 
		dc.w	(((PLC_PB_19_End-PLC_PB_19-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	OOz_Collapsing_Platform 
		dc.w	$73A0
		dc.l	OOz_Spring_Push_Boost 
		dc.w	$78A0
		dc.l	OOz_Swing_Platform 
		dc.w	$7C60
		dc.l	OOz_Break_To_Boost_Vertical 
		dc.w	$7FE0
		dc.l	OOz_Fans 
		dc.w	$8060
		dc.l	Switch 
		dc.w	$8480
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
		dc.l	OOz_Aquis-$14CA 
		dc.w	$A000
		dc.l	OOz_Octus-$14CA 
		dc.w	$A700
PLC_PB_19_End: 
;-------------------------------------------------------------------------------
DHz_PB_Sprs_0: 
PLC_PB_1A: 
		dc.w	(((PLC_PB_1A_End-PLC_PB_1A-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	dhz_Box 
		dc.w	$7A80
		dc.l	dhz_Collapsing_Platform 
		dc.w	$7E80
		dc.l	dhz_Vines 
		dc.w	$81C0
		dc.l	dhz_Vines_1 
		dc.w	$83C0
		dc.l	Flasher-$14CA 
		dc.w	$7500
		dc.l	Crawlton-$14CA 
		dc.w	$7800
PLC_PB_1A_End: 
;-------------------------------------------------------------------------------
DHz_PB_Sprs_1: 
PLC_PB_1B: 
		dc.w	(((PLC_PB_1B_End-PLC_PB_1B-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	dhz_Horizontal_Spikes 
		dc.w	$8580
		dc.l	Spikes 
		dc.w	$8680
		dc.l	dhz_Bridge 
		dc.w	$8780
		dc.l	diagonal_Spring_1 
		dc.w	$8800
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_PB_1B_End: 
;-------------------------------------------------------------------------------
CNz_PB_Sprs_0: 
PLC_PB_1C: 
		dc.w	(((PLC_PB_1C_End-PLC_PB_1C-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto 
		dc.l	Crawl-$14CA 
		dc.w	$6800
		dc.l	CNz_Box 
		dc.w	$6D80
		dc.l	CNz_Green_Platforms 
		dc.w	$6F80
		dc.l	CNz_Spikeball_Slot_Machine 
		dc.w	$7000
		dc.l	CNz_Elevator 
		dc.w	$7080
		dc.l	CNz_Slot_Machine_Starter 
		dc.w	$7100
		dc.l	CNz_Blue_Bumper 
		dc.w	$7280
		dc.l	CNz_Bumpers 
		dc.w	$7340
		dc.l	CNz_Flippers 
		dc.w	$7640
		dc.l	CNz_Green_Bumpers 
		dc.w	$7CC0
PLC_PB_1C_End: 
;------------------------------------------------------------------------------- 
CNz_PB_Sprs_1: 
PLC_PB_1D: 
		dc.w	(((PLC_PB_1D_End-PLC_PB_1D-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	CNz_Diagonal_Launcher 
		dc.w	$8040
		dc.l	CNz_Vertical_Launcher 
		dc.w	$8440
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_PB_1D_End: 
;-------------------------------------------------------------------------------
CPz_PB_Sprs_0: 
PLC_PB_1E: 
		dc.w	(((PLC_PB_1E_End-PLC_PB_1E-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	CPz_Metal_Structure 
		dc.w	$6E60
		dc.l	CPz_Automatic_Door 
		dc.w	$7280
		dc.l	CPz_Speed_Booster 
		dc.w	$7380
		dc.l	CPz_Triangle_Platform 
		dc.w	$7400
		dc.l	CPz_Open_Close_Platform 
		dc.w	$7600
		dc.l	CPz_Spring_Tubes 
		dc.w	$7C00
		dc.l	Water_Surface 
		dc.w	$8000
		dc.l	CPz_Platforms 
		dc.w	$8300
		dc.l	CPz_Breakable_Block 
		dc.w	$8600
		dc.l	Grabber-$14CA 
		dc.w	$A000
		dc.l	Lander-$14CA 
		dc.w	$A5A0
PLC_PB_1E_End:
;-------------------------------------------------------------------------------
CPz_PB_Sprs_1: 
PLC_PB_1F: 
		dc.w	(((PLC_PB_1F_End-PLC_PB_1F-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Spikes 
		dc.w	$8680
		dc.l	CPz_Worms 
		dc.w	$8780
		dc.l	diagonal_Spring_1 
		dc.w	$8800
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_PB_1F_End:
;-------------------------------------------------------------------------------
DEz_PB_Sprs_0: 
PLC_PB_20: 
		dc.w	(((PLC_PB_20_End-PLC_PB_20-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	CPz_Automatic_Door 
		dc.w	$6500
PLC_PB_20_End:
;-------------------------------------------------------------------------------
DEz_PB_Sprs_1: 
PLC_PB_21: 
		dc.w	(((PLC_PB_21_End-PLC_PB_21-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Metal_Sonic-$14CA 
		dc.w	$7000
		dc.l	Robotnik_Window-$14CA 
		dc.w	$6F00
		dc.l	Robotnik-$14CA 
		dc.w	$A300
		dc.l	Robotnik_Faces-$14CA 
		dc.w	$A000
		dc.l	Robotnik_Body-$14CA 
		dc.w	$AC80
PLC_PB_21_End:
;-------------------------------------------------------------------------------
NGHz_PB_Sprs_0: 
PLC_PB_22: 
		dc.w	(((PLC_PB_22_End-PLC_PB_22-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	NGHz_Automatic_Door 
		dc.w	$7F00
		dc.l	NGHz_Water_Surface 
		dc.w	$8000
		dc.l	NGHz_Leaves 
		dc.w	$8200
		dc.l	NGHz_Arrow_Shooter 
		dc.w	$82E0
PLC_PB_22_End:
;-------------------------------------------------------------------------------
NGHz_PB_Sprs_1: 
PLC_PB_23: 
		dc.w	(((PLC_PB_23_End-PLC_PB_23-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Chop_Chop-$14CA 
		dc.w	$A760
		dc.l	Whisp-$14CA 
		dc.w	$A000
		dc.l	Grounder-$14CA 
		dc.w	$A120
		dc.l	Oxygen_Bubbles 
		dc.w	$AB60
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring_1 
		dc.w	$8800
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_PB_23_End:
;-------------------------------------------------------------------------------
SCz_PB_Sprs_0: 
PLC_PB_24: 
		dc.w	(((PLC_PB_24_End-PLC_PB_24-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Tornado-$14CA 
		dc.w	$A000
PLC_PB_24_End:
;-------------------------------------------------------------------------------
SCz_PB_Sprs_1: 
PLC_PB_25: 
		dc.w	(((PLC_PB_25_End-PLC_PB_25-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Clouds-$14CA 
		dc.w	$A9E0
		dc.l	Vertical_Helix_Spr-$14CA 
		dc.w	$AC20
		dc.l	Horizontal_Helix_Spr-$14CA 
		dc.w	$79A0
		dc.l	Balkiry-$14CA 
		dc.w	$ACA0
		dc.l	Turtloid-$14CA 
		dc.w	$7140
		dc.l	Nebula-$14CA 
		dc.w	$6DC0
PLC_PB_25_End:
;-------------------------------------------------------------------------------
Level_Results_PB_Sprs: 
PLC_PB_26: 
		dc.w	(((PLC_PB_26_End-PLC_PB_26-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Title_Card_ZONE_123-$86 
		dc.w	$B000
		dc.l	Title_Card_Results-$F60 
		dc.w	$B600
		dc.l	Mini_Sonic 
		dc.w	$A000
PLC_PB_26_End: 
;-------------------------------------------------------------------------------
End_Level_PB_Sprs: 
PLC_PB_27: 
		dc.w	(((PLC_PB_27_End-PLC_PB_27-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	End_Panel 
		dc.w	$8680
PLC_PB_27_End:
;-------------------------------------------------------------------------------
CPz_Boss_PB_Sprs: 
PLC_PB_28: 
		dc.w	(((PLC_PB_28_End-PLC_PB_28-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship-$14CA 
		dc.w	$8400
		dc.l	CPz_Boss-$14CA 
		dc.w	$A000
		dc.l	Ship_Boost-$14CA 
		dc.w	$8300
		dc.l	Boss_Smokes-$14CA 
		dc.w	$AE00
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000
PLC_PB_28_End: 
;-------------------------------------------------------------------------------
GHz_Boss_PB_Sprs: 
PLC_PB_29: 
		dc.w	(((PLC_PB_29_End-PLC_PB_29-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship-$14CA 
		dc.w	$7400
		dc.l	GHz_Boss_Car-$14CA 
		dc.w	$8000
		dc.l	Ghz_Boss_Blades-$14CA 
		dc.w	$AD80
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000
PLC_PB_29_End:
;-------------------------------------------------------------------------------
HTz_Boss_PB_Sprs: 
PLC_PB_2A: 
		dc.w	(((PLC_PB_2A_End-PLC_PB_2A-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship-$14CA 
		dc.w	$7820
		dc.l	HTz_Boss_Fire_Cannon-$14CA 
		dc.w	$8420
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000
		dc.l	Boss_Smokes-$14CA 
		dc.w	$BC80 
PLC_PB_2A_End:
;-------------------------------------------------------------------------------
NGHz_Boss_PB_Sprs: 
PLC_PB_2B: 
		dc.w	(((PLC_PB_2B_End-PLC_PB_2B-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship-$14CA 
		dc.w	$A000
		dc.l	NGHz_Boss-$14CA 
		dc.w	$7C00
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000
PLC_PB_2B_End:
;-------------------------------------------------------------------------------
DHz_Boss_PB_Sprs: 
PLC_PB_2C: 
		dc.w	(((PLC_PB_2C_End-PLC_PB_2C-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship-$14CA 
		dc.w	$A000
		dc.l	dHz_Boss-$14CA 
		dc.w	$7800
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000
PLC_PB_2C_End: 
;-------------------------------------------------------------------------------
CNz_Boss_PB_Sprs: 
PLC_PB_2D: 
		dc.w	(((PLC_PB_2D_End-PLC_PB_2D-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship-$14CA 
		dc.w	$A000
		dc.l	CNz_Boss-$14CA 
		dc.w	$80E0
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000
PLC_PB_2D_End: 
;-------------------------------------------------------------------------------
Mz_Boss_PB_Sprs: 
PLC_PB_2E: 
		dc.w	(((PLC_PB_2E_End-PLC_PB_2E-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship-$14CA 
		dc.w	$A000 
		dc.l	Mz_Boss_Balls_And_Robotniks_Spr-$14CA 
		dc.w	$6F80
		dc.l	Ship_Boost-$14CA 
		dc.w	$AC00
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000 
PLC_PB_2E_End:
;-------------------------------------------------------------------------------
OOz_Boss_PB_Sprs: 
PLC_PB_2F: 
		dc.w	(((PLC_PB_2F_End-PLC_PB_2F-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	OOz_Boss-$14CA 
		dc.w	$7180
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000
PLC_PB_2F_End: 
;-------------------------------------------------------------------------------
DEz_Boss_PB_Spr: 
PLC_PB_30: 
		dc.w	(((PLC_PB_30_End-PLC_PB_30-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000
PLC_PB_30_End:
;-------------------------------------------------------------------------------
Final_Boss_PB_Spr: 
PLC_PB_31: 
		dc.w	(((PLC_PB_31_End-PLC_PB_31-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Final-$14CA 
		dc.w	$6600
PLC_PB_31_End:
;-------------------------------------------------------------------------------
GHz_Flickies_PB_Sprs: 
PLC_PB_32: 
		dc.w	(((PLC_PB_32_End-PLC_PB_32-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Squirrel-$14CA 
		dc.w	$B000
		dc.l	Blue_Bird-$14CA 
		dc.w	$B280
PLC_PB_32_End:
;-------------------------------------------------------------------------------
DHz_Flickies_PB_Sprs: 
PLC_PB_33: 
		dc.w	(((PLC_PB_33_End-PLC_PB_33-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Mouse-$14CA 
		dc.w	$B000
		dc.l	White_Bird-$14CA 
		dc.w	$B280
PLC_PB_33_End:
;-------------------------------------------------------------------------------
Mz_SFz_HTz_Flickies_PB_Sprs: 
PLC_PB_34: 
		dc.w	(((PLC_PB_34_End-PLC_PB_34-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Monkey-$14CA 
		dc.w	$B000
		dc.l	Black_Bird-$14CA 
		dc.w	$B280
PLC_PB_34_End:
;-------------------------------------------------------------------------------
DEz_Flickies_PB_Sprs: 
PLC_PB_35: 
		dc.w	(((PLC_PB_35_End-PLC_PB_35-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Pig-$14CA 
		dc.w	$B000
		dc.l	White_Bird-$14CA 
		dc.w	$B280 
PLC_PB_35_End:
;-------------------------------------------------------------------------------
HPz_Flickies_PB_Sprs: 
PLC_PB_36: 
		dc.w	(((PLC_PB_36_End-PLC_PB_36-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Mouse-$14CA 
		dc.w	$B000
		dc.l	Seal-$14CA 
		dc.w	$B280
PLC_PB_36_End:
;-------------------------------------------------------------------------------
OOz_Flickies_PB_Sprs: 
PLC_PB_37: 
		dc.w	(((PLC_PB_37_End-PLC_PB_37-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Penguin-$14CA 
		dc.w	$B000
		dc.l	Seal-$14CA 
		dc.w	$B280
PLC_PB_37_End:
;-------------------------------------------------------------------------------
SCz_Flickies_PB_Sprs: 
PLC_PB_38: 
		dc.w	(((PLC_PB_38_End-PLC_PB_38-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Turtle-$14CA 
		dc.w	$B000
		dc.l	White_Bird-$14CA 
		dc.w	$B280
PLC_PB_38_End:
;-------------------------------------------------------------------------------
CNz_Flickies_PB_Sprs: 
PLC_PB_39: 
		dc.w	(((PLC_PB_39_End-PLC_PB_39-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Bear-$14CA 
		dc.w	$B000
		dc.l	Blue_Bird-$14CA 
		dc.w	$B280
PLC_PB_39_End:
;-------------------------------------------------------------------------------
CPz_Flickies_PB_Sprs: 
PLC_PB_3A: 
		dc.w	(((PLC_PB_3A_End-PLC_PB_3A-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Rabbit-$14CA 
		dc.w	$B000
		dc.l	Black_Bird-$14CA 
		dc.w	$B280
PLC_PB_3A_End:
;-------------------------------------------------------------------------------
NGHz_Flickies_PB_Sprs: 
PLC_PB_3B: 
		dc.w	(((PLC_PB_3B_End-PLC_PB_3B-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Penguin-$14CA 
		dc.w	$B000
		dc.l	Blue_Bird-$14CA 
		dc.w	$B280 
PLC_PB_3B_End:
;-------------------------------------------------------------------------------
Special_Stage_PB_Sprs_0: 
PLC_PB_3C: 
		dc.w	(((PLC_PB_3C_End-PLC_PB_3C-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	SS_Emerald+$2364 
		dc.w	$2E80
		dc.l	SS_Wings_Hand+$2364 
		dc.w	$3440
		dc.l	SS_HUD_Font+$52A 
		dc.w	$3F40
		dc.l	SS_Player_Shadow+$52A 
		dc.w	$4780
		dc.l	SS_Player_Diagonal_Shadow+$52A
		dc.w	$4C40
		dc.l	SS_Player_Vertical_Shadow+$52A
		dc.w	$5380
		dc.l	SS_Bomb_Explosion+$2364 
		dc.w	$56A0
		dc.l	SS_Rings+$52A 
		dc.w	$6440
		dc.l	SS_START+$52A 
		dc.w	$7140
		dc.l	SS_PAYMW_vs+$52A 
		dc.w	$7BE0
		dc.l	SS_Background_8x8_Tiles+$52A
		dc.w	$E000
		dc.l	SS_Background_Stars+$52A 
		dc.w	$EFE0
PLC_PB_3C_End:
;-------------------------------------------------------------------------------
Special_Stage_PB_Sprs_1: 
PLC_PB_3D: 
		dc.w	(((PLC_PB_3D_End-PLC_PB_3D-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	SS_Bombs+$2364 
		dc.w	$7140
PLC_PB_3D_End:
;-------------------------------------------------------------------------------
SFz_Boss_PB_Sprs: 
PLC_PB_3E: 
		dc.w	(((PLC_PB_3E_End-PLC_PB_3E-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Spikeball_Laser-$14CA 
		dc.w	$6F20
		dc.l	Robotnik-$14CA 
		dc.w	$A300
		dc.l	Robotnik_Faces-$14CA 
		dc.w	$A000
		dc.l	Robotnik_Body-$14CA 
		dc.w	$AC80
		dc.l	Boss_Explosions-$14CA 
		dc.w	$B000
PLC_PB_3E_End:
;-------------------------------------------------------------------------------
SFz_Chase_PB_Sprs: 
PLC_PB_3F: 
		dc.w	(((PLC_PB_3F_End-PLC_PB_3F-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Tornado-$14CA 
		dc.w	$A000
		dc.l	Tornado_Rocket-$14CA 
		dc.w	$AC20
		dc.l	Clouds-$14CA 
		dc.w	$A9E0
PLC_PB_3F_End: 
;-------------------------------------------------------------------------------
Egg_Prison_PB_Sprs: 
PLC_PB_40: 
		dc.w	(((PLC_PB_40_End-PLC_PB_40-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Egg_Prison 
		dc.w	$D000 
PLC_PB_40_End:
;-------------------------------------------------------------------------------
Egg_Prison_Explosions_PB: 
PLC_PB_41: 
		dc.w	(((PLC_PB_41_End-PLC_PB_41-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Explosion 
		dc.w	$B480 
PLC_PB_41_End: 
;===============================================================================
; PLC - Previous Build
; [ End ]
;=============================================================================== 

;===============================================================================
; PLC - Other Previous Build
; [ End ]
;=============================================================================== 
GHz_PB1_Sprs_0: 
PLC_PB1_04: 
		dc.w	(((PLC_PB1_04_End-PLC_PB1_04-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	GHz_Coconuts-$14CA 
		dc.w	$7DC0
PLC_PB1_04_End: 
		dc.l	GHz_Masher-$14CA 
		dc.w	$8280 
;-------------------------------------------------------------------------------
GHz_PB1_Sprs_1: 
PLC_PB1_05: 
		dc.w	(((PLC_PB1_05_End-PLC_PB1_05-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
PLC_PB1_05_End: 
;-------------------------------------------------------------------------------
Mz_PB1_Sprs_0: 
PLC_PB1_0C: 
		dc.w	(((PLC_PB1_0C_End-PLC_PB1_0C-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Mz_Rotating_Gear 
		dc.w	$6F00
		dc.l	Mz_Gear_Holes 
		dc.w	$7E00
		dc.l	Mz_Elevator 
		dc.w	$7F20
		dc.l	Mz_Miscellaneous 
		dc.w	$7FA0
		dc.l	Mz_Steam 
		dc.w	$80A0
		dc.l	Mz_Harpon_Platform 
		dc.w	$8280
		dc.l	Mz_Harpon 
		dc.w	$8380
		dc.l	Shellcracker-$14CA 
		dc.w	$6380
		dc.l	asteron-$14CA 
		dc.w	$6D00
PLC_PB1_0C_End:
;------------------------------------------------------------------------------- 
Mz_PB1_Sprs_1: 
PLC_PB1_0D: 
		dc.w	(((PLC_PB1_0D_End-PLC_PB1_0D-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto 
		dc.l	Switch 
		dc.w	$8480
		dc.l	Spikes 
		dc.w	$8680
		dc.l	Slicer-$14CA 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
		dc.l	Mz_Screw_Nut 
		dc.w	$A000
		dc.l	Mz_Lava_Bubble 
		dc.w	$A6C0
		dc.l	Mz_Mini_Gear 
		dc.w	$ABE0
		dc.l	Mz_Teleport_Flash 
		dc.w	$AD60 
PLC_PB1_0D_End: 
;------------------------------------------------------------------------------- 
SFz_PB1_Sprs_0: 
PLC_PB1_10: 
		dc.w	(((PLC_PB1_10_End-PLC_PB1_10-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Robotnik_Ship_Spr-$149A
		dc.w	$60E0 
		dc.l	Tornado-$14CA 
		dc.w	$A000
		dc.l	Clouds-$14CA 
		dc.w	$A9E0
		dc.l	Vertical_Helix_Spr-$14CA 
		dc.w	$AC20
		dc.l	Horizontal_Helix_Spr-$14CA 
		dc.w	$79A0
		dc.l	Balkiry-$14CA 
		dc.w	$ACA0
		dc.l	Breakable_Wall 
		dc.w	$9180
		dc.l	Clucker-$14CA 
		dc.w	$6F20
		dc.l	Rotating_Helix-$14CA 
		dc.w	$7260
		dc.l	Tornado-$14CA 
		dc.w	$A000
		dc.l	Clouds-$14CA 
		dc.w	$A9E0
PLC_PB1_10_End: 
;-------------------------------------------------------------------------------
SFz_PB1_Sprs_1: 
PLC_PB1_11: 
		dc.w	(((PLC_PB1_11_End-PLC_PB1_11-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Vertical_Helix_Spr-$14CA 
		dc.w	$AC20
		dc.l	Horizontal_Helix_Spr-$14CA 
		dc.w	$79A0
		dc.l	Vertical_Laser-$14CA 
		dc.w	$73E0
		dc.l	SFz_Cannon-$14CA 
		dc.w	$7560
		dc.l	Horizontal_Laser-$14CA 
		dc.w	$7860
		dc.l	Conveyor_Belts_Wheels-$14CA 
		dc.w	$7D40
		dc.l	Chain_Hook-$14CA 
		dc.w	$7F40
		dc.l	Rocket_Flame_Spr-$14CA 
		dc.w	$8CA0
		dc.l	SFz_Elevators-$14CA 
		dc.w	$81C0
		dc.l	Hatchways-$14CA 
		dc.w	$8340
		dc.l	Engine_Part-$14CA 
		dc.w	$8A00
		dc.l	Speed_Boost-$14CA 
		dc.w	$8B80
		dc.l	Boss_Switch_Spr 
		dc.w	$8C20
		dc.l	SFz_Platform-$14CA 
		dc.w	$8DA0 
PLC_PB1_11_End: 
;------------------------------------------------------------------------------- 
HTz_PB1_Sprs_0: 
PLC_PB1_12: 
		dc.w	(((PLC_PB1_12_End-PLC_PB1_12-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Hill_Top_8x8_Tiles-$14CA 
		dc.w	$3F80
		dc.l	FireBall 
		dc.w	$73C0
		dc.l	Htz_Rock 
		dc.w	$7640
		dc.l	Htz_See_saw 
		dc.w	$78C0
		dc.l	Htz_See_saw_badnick 
		dc.w	$7BC0
		dc.l	Rexon-$14CA 
		dc.w	$6FC0
		dc.l	Spiker-$14CA 
		dc.w	$A400
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00 
PLC_PB1_12_End:
;-------------------------------------------------------------------------------
HTz_PB1_Sprs_1: 
PLC_PB1_13: 
		dc.w	(((PLC_PB1_13_End-PLC_PB1_13-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Htz_Teleferic 
		dc.w	$7CC0
		dc.l	Htz_Lava_Bubble 
		dc.w	$82C0
		dc.l	Htz_Automatic_Door 
		dc.w	$84C0
PLC_PB1_13_End:
;------------------------------------------------------------------------------- 
HPz_PB1_Sprs_0: 
PLC_PB1_14: 
		dc.w	(((PLC_PB1_14_End-PLC_PB1_14-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Hpz_Bridge 
		dc.w	$6000
		dc.l	Hpz_Waterfall 
		dc.w	$62A0
		dc.l	Hpz_Platform 
		dc.w	$6940
		dc.l	Hpz_Orbs_Comp 
		dc.w	$6B40
		dc.l	Hpz_Unknow_Platform 
		dc.w	$6F80
		dc.l	Hpz_Emerald 
		dc.w	$7240
		dc.l	Water_Surface 
		dc.w	$8000
PLC_PB1_14_End: 
;-------------------------------------------------------------------------------
HPz_PB1_Sprs_1: 
PLC_PB1_15: 
		dc.w	(((PLC_PB1_15_End-PLC_PB1_15-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	Hpz_Rhinobot-$14CA
		dc.w	$7640
		dc.l	Hpz_Dinobot-$14CA
		dc.w	$A000
		dc.l	Hpz_Batbot-$14CA
		dc.w	$A600
PLC_PB1_15_End: 
;-------------------------------------------------------------------------------
OOz_PB1_Sprs_0: 
PLC_PB1_18: 
		dc.w	(((PLC_PB1_18_End-PLC_PB1_18-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	OOz_Fire_Booster 
		dc.w	$5C40
		dc.l	OOz_Elevator 
		dc.w	$5E80
		dc.l	OOz_Giant_Spikeball 
		dc.w	$6180
		dc.l	OOz_Touch_Boost_Up 
		dc.w	$6580
		dc.l	OOz_Break_To_Boost_Horizontal 
		dc.w	$6640
		dc.l	OOz_Oil 
		dc.w	$66C0
		dc.l	OOz_Oil_01 
		dc.w	$68C0
		dc.l	OOz_Ball 
		dc.w	$6A80
		dc.l	OOz_Cannon 
		dc.w	$6D00
PLC_PB1_18_End: 
;-------------------------------------------------------------------------------
OOz_PB1_Sprs_1: 
PLC_PB1_19: 
		dc.w	(((PLC_PB1_19_End-PLC_PB1_19-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	OOz_Collapsing_Platform
		dc.w	$73A0
		dc.l	OOz_Spring_Push_Boost 
		dc.w	$78A0
		dc.l	OOz_Swing_Platform 
		dc.w	$7C60
		dc.l	OOz_Break_To_Boost_Vertical 
		dc.w	$7FE0
		dc.l	OOz_Fans 
		dc.w	$8060
		dc.l	Switch 
		dc.w	$8480
		dc.l	Spikes 
		dc.w	$8680
		dc.l	diagonal_Spring 
		dc.w	$8780
		dc.l	Vertical_Spring 
		dc.w	$8B80
		dc.l	Horizontal_Spring 
		dc.w	$8E00
		dc.l	OOz_Aquis-$14CA 
		dc.w	$A000
		dc.l	OOz_Octus-$14CA 
		dc.w	$A700
PLC_PB1_19_End: 
;-------------------------------------------------------------------------------
DHz_PB1_Sprs_0: 
PLC_PB1_1A: 
		dc.w	(((PLC_PB1_1A_End-PLC_PB1_1A-$2)/$6)-$1) ; Auto Detect Number of Sprites Esrael L. G. Neto
		dc.l	dhz_Box 
		dc.w	$7A80
		dc.l	dhz_Collapsing_Platform 
		dc.w	$7E80
		dc.l	dhz_Vines 
		dc.w	$81C0
		dc.l	dhz_Vines_1 
		dc.w	$83C0
		dc.l	Flasher-$14CA 
		dc.w	$7500
		dc.l	Crawlton-$14CA 
		dc.w	$7800
PLC_PB1_1A_End: 
;-------------------------------------------------------------------------------
DHz_PB1_Sprs_1: 
PLC_PB1_1B: 
		dc.w	$5
		dc.w	$7 ; Dhz_Horizontal_Spikes 
PLC_PB1_1B_End: 
;-------------------------------------------------------------------------------
;===============================================================================
; PLC - Other Previous Build
; [ End ]
;=============================================================================== 
Ghz_Flower_1: 
		incbin 'data/ghz/flower_1.dat'
Ghz_Flower_2: 
		incbin 'data/ghz/flower_2.dat'
Ghz_Flower_3: 
		incbin 'data/ghz/flower_3.dat'
Ghz_Flower_4: 
		incbin 'data/ghz/flower_4.dat' 
Ghz_Dyn_Wall: 
		incbin 'data/ghz/dyn_wall.dat'
Hill_Top_Background: 
		incbin 'artnem/backgnd.nem'
Hill_Top_Background_Unc: 
		incbin 'data/htz/backgnd.dat'
Mz_Spinnig_Cylinder: 
		incbin 'data/mz/spin_cyl.dat'
Mz_Lava: 
		incbin 'data/mz/lava.dat'
Mz_Pistons: 
		incbin 'data/mz/pistons.dat'
HPz_Dyn_Background: ; Unused - Left over from previous build 
		incbin 'data/hpz/backgnd.dat'
HPz_Orbs: 
		incbin 'data/hpz/orbs.dat'
OOz_Red_Balls: 
		incbin 'data/ooz/red_ball.dat' 
OOz_Rotating_Square_1: 
		incbin 'data/ooz/r_squar1.dat'
OOz_Rotating_Square_2: 
		incbin 'data/ooz/r_squar2.dat' 
OOz_Oil_1: 
		incbin 'data/ooz/oil_1.dat'
OOz_Oil_2: 
		incbin 'data/ooz/oil_2.dat' 
CNz_Symbols_Spr: 
		incbin 'data/cnz/symbols.dat'
CNz_Slot_Machine_Checks: 
		incbin 'data/cnz/sm_check.dat' 
CPz_Dyn_Background: 
		incbin 'data/cpz/backgnd.dat'
NGHz_Water_Falls_1: 
		incbin 'data/nghz/water_f1.dat'
NGHz_Water_Falls_2: 
		incbin 'data/nghz/water_f2.dat'
NGHz_Water_Falls_3: 
		incbin 'data/nghz/water_f3.dat' 
;=============================================================================== 
; Colision Array
; [ Begin ]
;=============================================================================== 
AngleMap: 
		incbin 'misc/anglemap.dat'
Colision_Array_1: 
		incbin 'misc/c_array1.dat'
Colision_Array_2: 
		incbin 'misc/c_array2.dat' 
;=============================================================================== 
; Colision Array
; [ End ]
;===============================================================================

;=============================================================================== 
; Colision Index
; [ Begin ]
;=============================================================================== 
Green_Hill_Colision_1: 
		incbin 'collide/ghz_col1.dat'
;------------------------------------------------------------------------------- 
Green_Hill_Colision_2: 
		incbin 'collide/ghz_col2.dat'
;------------------------------------------------------------------------------- 
Metropolis_Colision: 
		incbin 'collide/mz_col.dat'
;------------------------------------------------------------------------------- 
Hidden_Palace_Colision: 
		incbin 'collide/hpz_col.dat'
;------------------------------------------------------------------------------- 
Oil_Ocean_Colision: 
		incbin 'collide/ooz_col.dat'
;------------------------------------------------------------------------------- 
Dust_Hill_Colision: 
		incbin 'collide/dhz_col.dat'
;------------------------------------------------------------------------------- 
Casino_Night_Colision_1: 
		incbin 'collide/cnz_col1.dat'
Casino_Night_Colision_2: 
		incbin 'collide/cnz_col2.dat'
;------------------------------------------------------------------------------- 
Chemical_Plant_Colision_1: 
		incbin 'collide/cpz_col1.dat'
Chemical_Plant_Colision_2: 
		incbin 'collide/cpz_col2.dat'
;------------------------------------------------------------------------------- 
Neo_Green_Hill_Colision_1: 
		incbin 'collide/nghzcol1.dat'
Neo_Green_Hill_Colision_2: 
		incbin 'collide/nghzcol2.dat'
;------------------------------------------------------------------------------- 
Sky_Fortress_Colision_1: 
		incbin 'collide/sfz_col1.dat'
Sky_Fortress_Colision_2: 
		incbin 'collide/sfz_col2.dat'
;-------------------------------------------------------------------------------
Null_Colision: 
;=============================================================================== 
; Colision Index
; [ End ]
;=============================================================================== 
		 
;=============================================================================== 
; Level Layout
; [ Begin ]
;=============================================================================== 
Level_Layout: 
		dc.w	Ghz_Map_Act1-Level_Layout 
		dc.w	Ghz_Map_Act2-Level_Layout 
		dc.w	Ghz_Map_Act1-Level_Layout 
		dc.w	Ghz_Map_Act1-Level_Layout 
		dc.w	Ghz_Map_Act1-Level_Layout 
		dc.w	Ghz_Map_Act1-Level_Layout 
		dc.w	Ghz_Map_Act1-Level_Layout 
		dc.w	Ghz_Map_Act1-Level_Layout 
		dc.w	Mz_Map_Act1-Level_Layout 
		dc.w	Mz_Map_Act2-Level_Layout 
		dc.w	Mz_Map_Act3-Level_Layout 
		dc.w	Mz_Map_Act4-Level_Layout
		dc.w	SFz_Map_Act1-Level_Layout 
		dc.w	SFz_Map_Act2-Level_Layout 
		dc.w	HTz_Map_Act1-Level_Layout 
		dc.w	HTz_Map_Act2-Level_Layout 
		dc.w	HPz_Map_Act1-Level_Layout 
		dc.w	HPz_Map_Act2-Level_Layout 
		dc.w	Ghz_Map_Act1-Level_Layout 
		dc.w	Ghz_Map_Act1-Level_Layout 
		dc.w	OOz_Map_Act1-Level_Layout 
		dc.w	OOz_Map_Act2-Level_Layout 
		dc.w	dHz_Map_Act1-Level_Layout 
		dc.w	dHz_Map_Act2-Level_Layout 
		dc.w	CNz_Map_Act1-Level_Layout 
		dc.w	CNz_Map_Act2-Level_Layout 
		dc.w	CPz_Map_Act1-Level_Layout 
		dc.w	CPz_Map_Act2-Level_Layout 
		dc.w	dEz_Map_Act1-Level_Layout 
		dc.w	dEz_Map_Act2-Level_Layout 
		dc.w	NGHz_Map_Act1-Level_Layout 
		dc.w	NGHz_Map_Act2-Level_Layout 
		dc.w	SCz_Map_Act1-Level_Layout 
		dc.w	SCz_Map_Act2-Level_Layout 
Ghz_Map_Act1: 
		incbin 'levels/ghz_map1.kos'
		dc.w	$0,$0,$0,$0 ; Filler
Ghz_Map_Act2: 
		incbin 'levels/ghz_map2.kos'
		dc.w	$0,$0,$0,$0 ; Filler
Mz_Map_Act1: 
		incbin 'levels/mz_map1.kos'
		dc.w	$0,$0,$0,$0 ; Filler
Mz_Map_Act2: 
		incbin 'levels/mz_map2.kos'
		dc.w	$0,$0,$0,$0,$0 ; Filler
Mz_Map_Act3: 
Mz_Map_Act4:
		incbin 'levels/mz_map3.kos'
		dc.w	$0,$0,$0,$0,$0 ; Filler
SFz_Map_Act1: 
SFz_Map_Act2:
		incbin 'levels/sfz_map.kos'
HTz_Map_Act1: 
		incbin 'levels/htz_map1.kos'
		dc.w	$0,$0,$0 ; Filler
HTz_Map_Act2: 
		incbin 'levels/htz_map2.kos'
HPz_Map_Act1: 
HPz_Map_Act2:
		incbin 'levels/htz_map2.kos'
OOz_Map_Act1: 
		incbin 'levels/ooz_map1.kos'
		dc.w	$0 ; Filler
OOz_Map_Act2: 
		incbin 'levels/ooz_map2.kos'
		dc.w	$0,$0,$0,$0,$0,$0,$0 ; Filler 
DHz_Map_Act1: 
		incbin 'levels/dhz_map1.kos'
		dc.w	$0,$0,$0,$0,$0 ; Filler 
DHz_Map_Act2: 
		incbin 'levels/dhz_map2.kos'
		dc.w	$0,$0,$0,$0,$0,$0,$0 ; Filler 
CNz_Map_Act1: 
		incbin 'levels/cnz_map1.kos'
		dc.w	$0,$0,$0,$0,$0,$0,$0 ; Filler 
CNz_Map_Act2: 
		incbin 'levels/cnz_map2.kos'
		dc.w	$0,$0,$0,$0,$0,$0 ; Filler
CPz_Map_Act1: 
		incbin 'levels/cpz_map1.kos'
		dc.w	$0,$0 ; Filler
CPz_Map_Act2: 
		incbin 'levels/cpz_map2.kos'
		dc.w	$0,$0,$0,$0,$0,$0,$0 ; Filler 
DEz_Map_Act1: 
DEz_Map_Act2: 
		incbin 'levels/dez_map.kos'
		dc.w	$0 ; Filler
NGHz_Map_Act1: 
		incbin 'levels/nghz_map1.kos'
		dc.w	$0,$0,$0 ; Filler 
NGHz_Map_Act2: 
		incbin 'levels/nghz_map2.kos'
		dc.w	$0,$0 ; Filler 
SCz_Map_Act1: 
SCz_Map_Act2:
		incbin 'levels/scz_map.kos'
;-------------------------------------------------------------------------------
HTz_1_2_Foreground_Previous_Build: 
		incbin 'data/htz/htz_1_2.dat' 
;===============================================================================
; Level Layout
; [ End ]
;=============================================================================== 
Sonic_Sprites: 
		incbin 'artunc/sonic.dat'
Miles_Sprites: 
		incbin 'artunc/miles.dat'
;------------------------------------------------------------------------------- 
Sonic_Mappings: 
		dc.w	loc_6FD8C-Sonic_Mappings
		dc.w	loc_6FD8E-Sonic_Mappings
		dc.w	loc_6FDB0-Sonic_Mappings
		dc.w	loc_6FDC2-Sonic_Mappings
		dc.w	loc_6FDE4-Sonic_Mappings
		dc.w	loc_6FE06-Sonic_Mappings
		dc.w	loc_6FE30-Sonic_Mappings
		dc.w	loc_6FE4A-Sonic_Mappings
		dc.w	loc_6FE5C-Sonic_Mappings
		dc.w	loc_6FE6E-Sonic_Mappings
		dc.w	loc_6FE80-Sonic_Mappings
		dc.w	loc_6FE92-Sonic_Mappings
		dc.w	loc_6FEB4-Sonic_Mappings
		dc.w	loc_6FED6-Sonic_Mappings
		dc.w	loc_6FEF0-Sonic_Mappings
		dc.w	loc_6FF12-Sonic_Mappings
		dc.w	loc_6FF2C-Sonic_Mappings
		dc.w	loc_6FF3E-Sonic_Mappings
		dc.w	loc_6FF58-Sonic_Mappings
		dc.w	loc_6FF7A-Sonic_Mappings
		dc.w	loc_6FF94-Sonic_Mappings
		dc.w	loc_6FFA6-Sonic_Mappings
		dc.w	loc_6FFC8-Sonic_Mappings
		dc.w	loc_6FFF2-Sonic_Mappings
		dc.w	loc_70014-Sonic_Mappings
		dc.w	loc_70036-Sonic_Mappings
		dc.w	loc_70060-Sonic_Mappings
		dc.w	loc_7008A-Sonic_Mappings
		dc.w	loc_700AC-Sonic_Mappings
		dc.w	loc_700D6-Sonic_Mappings
		dc.w	loc_700F0-Sonic_Mappings
		dc.w	loc_7010A-Sonic_Mappings
		dc.w	loc_70124-Sonic_Mappings
		dc.w	loc_70136-Sonic_Mappings
		dc.w	loc_70150-Sonic_Mappings
		dc.w	loc_7016A-Sonic_Mappings
		dc.w	loc_70184-Sonic_Mappings
		dc.w	loc_70196-Sonic_Mappings
		dc.w	loc_701B8-Sonic_Mappings
		dc.w	loc_701E2-Sonic_Mappings
		dc.w	loc_70204-Sonic_Mappings
		dc.w	loc_70226-Sonic_Mappings
		dc.w	loc_70248-Sonic_Mappings
		dc.w	loc_70272-Sonic_Mappings
		dc.w	loc_70294-Sonic_Mappings
		dc.w	loc_702B6-Sonic_Mappings
		dc.w	loc_702C8-Sonic_Mappings
		dc.w	loc_702DA-Sonic_Mappings
		dc.w	loc_702EC-Sonic_Mappings
		dc.w	loc_702FE-Sonic_Mappings
		dc.w	loc_70320-Sonic_Mappings
		dc.w	loc_7033A-Sonic_Mappings
		dc.w	loc_7035C-Sonic_Mappings
		dc.w	loc_70376-Sonic_Mappings
		dc.w	loc_70388-Sonic_Mappings
		dc.w	loc_7039A-Sonic_Mappings
		dc.w	loc_703AC-Sonic_Mappings
		dc.w	loc_703BE-Sonic_Mappings
		dc.w	loc_703D8-Sonic_Mappings
		dc.w	loc_703EA-Sonic_Mappings
		dc.w	loc_70404-Sonic_Mappings
		dc.w	loc_70416-Sonic_Mappings
		dc.w	loc_70420-Sonic_Mappings
		dc.w	loc_7042A-Sonic_Mappings
		dc.w	loc_70434-Sonic_Mappings
		dc.w	loc_7043E-Sonic_Mappings
		dc.w	loc_70448-Sonic_Mappings
		dc.w	loc_70452-Sonic_Mappings
		dc.w	loc_7045C-Sonic_Mappings
		dc.w	loc_70466-Sonic_Mappings
		dc.w	loc_70470-Sonic_Mappings
		dc.w	loc_7047A-Sonic_Mappings
		dc.w	loc_70484-Sonic_Mappings
		dc.w	loc_7049E-Sonic_Mappings
		dc.w	loc_704B8-Sonic_Mappings
		dc.w	loc_704D2-Sonic_Mappings
		dc.w	loc_704EC-Sonic_Mappings
		dc.w	loc_704F6-Sonic_Mappings
		dc.w	loc_70500-Sonic_Mappings
		dc.w	loc_70512-Sonic_Mappings
		dc.w	loc_70524-Sonic_Mappings
		dc.w	loc_7053E-Sonic_Mappings
		dc.w	loc_70558-Sonic_Mappings
		dc.w	loc_7056A-Sonic_Mappings
		dc.w	loc_7057C-Sonic_Mappings
		dc.w	loc_70596-Sonic_Mappings
		dc.w	loc_705B8-Sonic_Mappings
		dc.w	loc_705D2-Sonic_Mappings
		dc.w	loc_705EC-Sonic_Mappings
		dc.w	loc_70606-Sonic_Mappings
		dc.w	loc_70620-Sonic_Mappings
		dc.w	loc_7063A-Sonic_Mappings
		dc.w	loc_7064C-Sonic_Mappings
		dc.w	loc_7066E-Sonic_Mappings
		dc.w	loc_70690-Sonic_Mappings
		dc.w	loc_706AA-Sonic_Mappings
		dc.w	loc_706C4-Sonic_Mappings
		dc.w	loc_706DE-Sonic_Mappings
		dc.w	loc_706F0-Sonic_Mappings
		dc.w	loc_706FA-Sonic_Mappings
		dc.w	loc_7070C-Sonic_Mappings
		dc.w	loc_70726-Sonic_Mappings
		dc.w	loc_70740-Sonic_Mappings
		dc.w	loc_7075A-Sonic_Mappings
		dc.w	loc_7076C-Sonic_Mappings
		dc.w	loc_7077E-Sonic_Mappings
		dc.w	loc_70798-Sonic_Mappings
		dc.w	loc_707AA-Sonic_Mappings
		dc.w	loc_707C4-Sonic_Mappings
		dc.w	loc_707DE-Sonic_Mappings
		dc.w	loc_707E8-Sonic_Mappings
		dc.w	loc_70802-Sonic_Mappings
		dc.w	loc_7081C-Sonic_Mappings
		dc.w	loc_70846-Sonic_Mappings
		dc.w	loc_70870-Sonic_Mappings
		dc.w	loc_70882-Sonic_Mappings
		dc.w	loc_70894-Sonic_Mappings
		dc.w	loc_708A6-Sonic_Mappings
		dc.w	loc_708C0-Sonic_Mappings
		dc.w	loc_708E2-Sonic_Mappings
		dc.w	loc_708FC-Sonic_Mappings
		dc.w	loc_7090E-Sonic_Mappings
		dc.w	loc_70928-Sonic_Mappings
		dc.w	loc_7094A-Sonic_Mappings
		dc.w	loc_70964-Sonic_Mappings
		dc.w	loc_70976-Sonic_Mappings
		dc.w	loc_70998-Sonic_Mappings
		dc.w	loc_709C2-Sonic_Mappings
		dc.w	loc_709EC-Sonic_Mappings
		dc.w	loc_70A16-Sonic_Mappings
		dc.w	loc_70A48-Sonic_Mappings
		dc.w	loc_70A7A-Sonic_Mappings
		dc.w	loc_70AA4-Sonic_Mappings
		dc.w	loc_70ACE-Sonic_Mappings
		dc.w	loc_70AE8-Sonic_Mappings
		dc.w	loc_70B02-Sonic_Mappings
		dc.w	loc_70B1C-Sonic_Mappings
		dc.w	loc_70B2E-Sonic_Mappings
		dc.w	loc_70B48-Sonic_Mappings
		dc.w	loc_70B62-Sonic_Mappings
		dc.w	loc_70B7C-Sonic_Mappings
		dc.w	loc_70B8E-Sonic_Mappings
		dc.w	loc_70BB0-Sonic_Mappings
		dc.w	loc_70BDA-Sonic_Mappings
		dc.w	loc_70BFC-Sonic_Mappings
		dc.w	loc_70C1E-Sonic_Mappings
		dc.w	loc_70C40-Sonic_Mappings
		dc.w	loc_70C6A-Sonic_Mappings
		dc.w	loc_70C8C-Sonic_Mappings
		dc.w	loc_70CAE-Sonic_Mappings
		dc.w	loc_70CC8-Sonic_Mappings
		dc.w	loc_70CEA-Sonic_Mappings
		dc.w	loc_70D04-Sonic_Mappings
		dc.w	loc_70D16-Sonic_Mappings
		dc.w	loc_70D30-Sonic_Mappings
		dc.w	loc_70D52-Sonic_Mappings
		dc.w	loc_70D6C-Sonic_Mappings
		dc.w	loc_70D7E-Sonic_Mappings
		dc.w	loc_70DA8-Sonic_Mappings
		dc.w	loc_70DDA-Sonic_Mappings
		dc.w	loc_70E04-Sonic_Mappings
		dc.w	loc_70E2E-Sonic_Mappings
		dc.w	loc_70E60-Sonic_Mappings
		dc.w	loc_70E92-Sonic_Mappings
		dc.w	loc_70EBC-Sonic_Mappings
		dc.w	loc_70EEE-Sonic_Mappings
		dc.w	loc_70F08-Sonic_Mappings
		dc.w	loc_70F22-Sonic_Mappings
		dc.w	loc_70F3C-Sonic_Mappings
		dc.w	loc_70F4E-Sonic_Mappings
		dc.w	loc_70F68-Sonic_Mappings
		dc.w	loc_70F82-Sonic_Mappings
		dc.w	loc_70F9C-Sonic_Mappings
		dc.w	loc_70FAE-Sonic_Mappings
		dc.w	loc_70FD0-Sonic_Mappings
		dc.w	loc_70FFA-Sonic_Mappings
		dc.w	loc_71024-Sonic_Mappings
		dc.w	loc_71046-Sonic_Mappings
		dc.w	loc_71068-Sonic_Mappings
		dc.w	loc_71092-Sonic_Mappings
		dc.w	loc_710BC-Sonic_Mappings
		dc.w	loc_710E6-Sonic_Mappings
		dc.w	loc_71108-Sonic_Mappings
		dc.w	loc_7112A-Sonic_Mappings
		dc.w	loc_7114C-Sonic_Mappings
		dc.w	loc_71176-Sonic_Mappings
		dc.w	loc_71198-Sonic_Mappings
		dc.w	loc_711BA-Sonic_Mappings
		dc.w	loc_711DC-Sonic_Mappings
		dc.w	loc_71206-Sonic_Mappings
		dc.w	loc_71228-Sonic_Mappings
		dc.w	loc_7124A-Sonic_Mappings
		dc.w	loc_7126C-Sonic_Mappings
		dc.w	loc_7128E-Sonic_Mappings
		dc.w	loc_712A0-Sonic_Mappings
		dc.w	loc_712BA-Sonic_Mappings
		dc.w	loc_712D4-Sonic_Mappings
		dc.w	loc_712EE-Sonic_Mappings
		dc.w	loc_71308-Sonic_Mappings
		dc.w	loc_71322-Sonic_Mappings
		dc.w	loc_7133C-Sonic_Mappings
		dc.w	loc_71356-Sonic_Mappings
		dc.w	loc_71370-Sonic_Mappings
		dc.w	loc_7138A-Sonic_Mappings
		dc.w	loc_713B4-Sonic_Mappings
		dc.w	loc_713D6-Sonic_Mappings
		dc.w	loc_713F8-Sonic_Mappings
		dc.w	loc_7141A-Sonic_Mappings
		dc.w	loc_71434-Sonic_Mappings
		dc.w	loc_7144E-Sonic_Mappings
		dc.w	loc_71468-Sonic_Mappings
		dc.w	loc_7148A-Sonic_Mappings
		dc.w	loc_714AC-Sonic_Mappings
		dc.w	loc_714CE-Sonic_Mappings
loc_6FD8C:
		dc.w	$0
loc_6FD8E:
		dc.w	$4
		dc.l	$E4050000,$FFF8,$EC030004,$2FFF0
		dc.l	$F4090008,$4FFF8,$409000E,$7FFF8
loc_6FDB0:
		dc.w	$2
		dc.l	$EC0B0000,$FFF0,$C09000C,$6FFF8
loc_6FDC2:
		dc.w	$4
		dc.l	$EC030000,$FFF0,$EC050004,$2FFF8
		dc.l	$FC050008,$4FFF8,$C09000C,$6FFF8
loc_6FDE4:
		dc.w	$4
		dc.l	$EC030000,$FFF0,$EC050004,$2FFF8
		dc.l	$FC050008,$4FFF8,$C09000C,$6FFF8
loc_6FE06:
		dc.w	$5
		dc.l	$EC030000,$FFF0,$EC050004,$2FFF8
		dc.l	$FC050008,$4FFF8,$C01000C,$6FFF8
		dc.l	$C05000E,$70000
loc_6FE30:
		dc.w	$3
		dc.l	$EC030000,$FFF0,$EC070004,$2FFF8
		dc.l	$C09000C,$6FFF8
loc_6FE4A:
		dc.w	$2
		dc.l	$F40B0000,$FFF0,$401000C,$60008
loc_6FE5C:
		dc.w	$2
		dc.l	$F40B0000,$FFE8,$405000C,$60000
loc_6FE6E:
		dc.w	$2
		dc.l	$F40B0000,$FFE8,$405000C,$60000
loc_6FE80:
		dc.w	$2
		dc.l	$E40B0000,$FFF0,$40D000C,$6FFF0
loc_6FE92:
		dc.w	$4
		dc.l	$E4050000,$FFF8,$EC030004,$2FFF0
		dc.l	$F4090008,$4FFF8,$409000E,$7FFF8
loc_6FEB4:
		dc.w	$4
		dc.l	$EC030000,$FFF0,$E4050004,$2FFF8
		dc.l	$F4050008,$4FFF8,$409000C,$6FFF8
loc_6FED6:
		dc.w	$3
		dc.l	$EB0D0000,$FFEE,$3010008,$4FFEC
		dc.l	$FB0F000A,$5FFF4
loc_6FEF0:
		dc.w	$4
		dc.l	$EC0D0000,$FFEE,$4010008,$4FFEC
		dc.l	$FC0B000A,$5FFF4,$4010016,$B000C
loc_6FF12:
		dc.w	$3
		dc.l	$ED0D0000,$FFED,$FD090008,$4FFF4
		dc.l	$D05000E,$7FFF7
loc_6FF2C:
		dc.w	$2
		dc.l	$EC090000,$FFF4,$FC0F0006,$3FFEE
loc_6FF3E:
		dc.w	$3
		dc.l	$EB090000,$FFF4,$FB0F0006,$3FFEE
		dc.l	$FB010016,$B000E
loc_6FF58:
		dc.w	$4
		dc.l	$EC090000,$FFF4,$4010006,$3FFEC
		dc.l	$FC0B0008,$4FFF4,$4010014,$A000C
loc_6FF7A:
		dc.w	$3
		dc.l	$ED0D0000,$FFED,$FD090008,$4FFF4
		dc.l	$D05000E,$7FFF7
loc_6FF94:
		dc.w	$2
		dc.l	$EC0D0000,$FFEE,$FC0B0008,$4FFF3
loc_6FFA6:
		dc.w	$4
		dc.l	$EB090000,$FFEA,$FB090006,$3FFEA
		dc.l	$F305000C,$60002,$B010010,$8FFFA
loc_6FFC8:
		dc.w	$5
		dc.l	$EC090000,$FFEB,$EC010006,$30003
		dc.l	$FC0D0008,$4FFEB,$FC050010,$8000B
		dc.l	$C010014,$AFFFB
loc_6FFF2:
		dc.w	$4
		dc.l	$ED070000,$FFEC,$ED030008,$4FFFC
		dc.l	$F501000C,$60004,$505000E,$70004
loc_70014:
		dc.w	$4
		dc.l	$EC090000,$FFEB,$EC010006,$30003
		dc.l	$FC050008,$4FFEB,$FC0B000C,$6FFFB
loc_70036:
		dc.w	$5
		dc.l	$EB090000,$FFEA,$EB010006,$30002
		dc.l	$FB0D0008,$4FFEA,$F3010010,$8000A
		dc.l	$B050012,$9FFF2
loc_70060:
		dc.w	$5
		dc.l	$EC090000,$FFEB,$EC010006,$30003
		dc.l	$FC0D0008,$4FFEB,$FA050010,$8000B
		dc.l	$C010014,$AFFFB
loc_7008A:
		dc.w	$4
		dc.l	$ED070000,$FFEC,$ED030008,$4FFFC
		dc.l	$F501000C,$60004,$505000E,$70004
loc_700AC:
		dc.w	$5
		dc.l	$EC090000,$FFEB,$FC090006,$3FFEB
		dc.l	$F401000C,$60003,$C01000E,$7FFFB
		dc.l	$4050010,$80003
loc_700D6:
		dc.w	$3
		dc.l	$F2070000,$FFEB,$EC0B0008,$4FFFB
		dc.l	$C050014,$A0003
loc_700F0:
		dc.w	$3
		dc.l	$F2070000,$FFEC,$EC0B0008,$4FFFC
		dc.l	$C050014,$A0004
loc_7010A:
		dc.w	$3
		dc.l	$F3070000,$FFED,$F4030008,$4FFFD
		dc.l	$F905000C,$60005
loc_70124:
		dc.w	$2
		dc.l	$F4070000,$FFEC,$F20B0008,$4FFFC
loc_70136:
		dc.w	$3
		dc.l	$F4070000,$FFEB,$E3050008,$4FFFB
		dc.l	$F30B000C,$6FFFB
loc_70150:
		dc.w	$3
		dc.l	$F4070000,$FFEC,$EC0B0008,$4FFFC
		dc.l	$C050014,$A0004
loc_7016A:
		dc.w	$3
		dc.l	$F3070000,$FFED,$F4030008,$4FFFD
		dc.l	$F905000C,$60005
loc_70184:
		dc.w	$2
		dc.l	$F2070000,$FFEC,$F40B0008,$4FFFC
loc_70196:
		dc.w	$4
		dc.l	$EE050000,$FFF3,$FE070004,$2FFEB
		dc.l	$FE0D000C,$6FFFB,$E010014,$AFFFB
loc_701B8:
		dc.w	$5
		dc.l	$DD050000,$FFFC,$ED090004,$2FFF4
		dc.l	$FD07000A,$5FFEC,$FD0D0012,$9FFFC
		dc.l	$D01001A,$DFFFC
loc_701E2:
		dc.w	$4
		dc.l	$EC0D0000,$FFF5,$FC070008,$4FFED
		dc.l	$FC050010,$8FFFD,$C010014,$AFFFD
loc_70204:
		dc.w	$4
		dc.l	$ED0D0000,$FFF4,$FD070008,$4FFEC
		dc.l	$FD090010,$8FFFC,$D010016,$BFFFC
loc_70226:
		dc.w	$4
		dc.l	$EE090000,$FFF3,$FE070006,$3FFEB
		dc.l	$FE0D000E,$7FFFB,$E010016,$BFFFB
loc_70248:
		dc.w	$5
		dc.l	$DD050000,$FFFA,$ED090004,$2FFF4
		dc.l	$FD07000A,$5FFEC,$FD0D0012,$9FFFC
		dc.l	$D01001A,$DFFFC
loc_70272:
		dc.w	$4
		dc.l	$EC0D0000,$FFF5,$FC070008,$4FFED
		dc.l	$FC050010,$8FFFD,$C010014,$AFFFD
loc_70294:
		dc.w	$4
		dc.l	$ED0D0000,$FFF4,$FD070008,$4FFEC
		dc.l	$FD090010,$8FFFC,$D010016,$BFFFC
loc_702B6:
		dc.w	$2
		dc.l	$EE090000,$FFF8,$FE0F0006,$3FFF0
loc_702C8:
		dc.w	$2
		dc.l	$EE090000,$FFF8,$FE0F0006,$3FFF0
loc_702DA:
		dc.w	$2
		dc.l	$EE090000,$FFF8,$FE0F0006,$3FFF0
loc_702EC:
		dc.w	$2
		dc.l	$EE090000,$FFF8,$FE0F0006,$3FFF0
loc_702FE:
		dc.w	$4
		dc.l	$EC090000,$FFED,$EC010006,$30005
		dc.l	$FC0D0008,$4FFF4,$C090010,$8FFFA
loc_70320:
		dc.w	$3
		dc.l	$EC0D0000,$FFED,$FC0D0008,$4FFF5
		dc.l	$C090010,$8FFF8
loc_7033A:
		dc.w	$4
		dc.l	$EC090000,$FFED,$EC010006,$30005
		dc.l	$FC0D0008,$4FFF4,$C090010,$8FFFD
loc_7035C:
		dc.w	$3
		dc.l	$EC0D0000,$FFED,$FC0D0008,$4FFF5
		dc.l	$C090010,$8FFF8
loc_70376:
		dc.w	$2
		dc.l	$F0070000,$FFEE,$F00B0008,$4FFFE
loc_70388:
		dc.w	$2
		dc.l	$F0070000,$FFEE,$F00B0008,$4FFFE
loc_7039A:
		dc.w	$2
		dc.l	$F0070000,$FFEE,$F00B0008,$4FFFE
loc_703AC:
		dc.w	$2
		dc.l	$F0070000,$FFEE,$F00B0008,$4FFFE
loc_703BE:
		dc.w	$3
		dc.l	$E9010000,$FFF4,$F9070002,$1FFEC
		dc.l	$EC0B000A,$5FFFC
loc_703D8:
		dc.w	$2
		dc.l	$F3070000,$FFEC,$EB0B0008,$4FFFC
loc_703EA:
		dc.w	$3
		dc.l	$E9010000,$FFF4,$F9070002,$1FFEC
		dc.l	$EC0B000A,$5FFFC
loc_70404:
		dc.w	$2
		dc.l	$F3070000,$FFEC,$EB0B0008,$4FFFC
loc_70416:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_70420:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_7042A:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_70434:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_7043E:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_70448:
		dc.w	$1
		dc.l	$F80F0000,$FFF4
loc_70452:
		dc.w	$1
		dc.l	$F80F0000,$FFF4
loc_7045C:
		dc.w	$1
		dc.l	$F80F0000,$FFF4
loc_70466:
		dc.w	$1
		dc.l	$F80F0000,$FFF4
loc_70470:
		dc.w	$1
		dc.l	$F80F0000,$FFF4
loc_7047A:
		dc.w	$1
		dc.l	$F80F0000,$FFF4
loc_70484:
		dc.w	$3
		dc.l	$E5090000,$FFF3,$F5090006,$3FFF3
		dc.l	$50D000C,$6FFEB
loc_7049E:
		dc.w	$3
		dc.l	$E4090000,$FFF3,$F4090006,$3FFF3
		dc.l	$409000C,$6FFF3
loc_704B8:
		dc.w	$3
		dc.l	$E5090000,$FFF3,$F5090006,$3FFF3
		dc.l	$50D000C,$6FFEB
loc_704D2:
		dc.w	$3
		dc.l	$E5090000,$FFF3,$F5090006,$3FFF3
		dc.l	$509000C,$6FFF3
loc_704EC:
		dc.w	$1
		dc.l	$F40B0000,$FFF6
loc_704F6:
		dc.w	$1
		dc.l	$F40F0000,$FFF2
loc_70500:
		dc.w	$2
		dc.l	$F8010000,$FFEC,$F00F0002,$1FFF4
loc_70512:
		dc.w	$2
		dc.l	$F0030000,$FFEC,$F00F0004,$2FFF4
loc_70524:
		dc.w	$3
		dc.l	$E80F0000,$FFE8,$E8010010,$80008
		dc.l	$F8050012,$90008
loc_7053E:
		dc.w	$3
		dc.l	$E80F0000,$FFE8,$E8010010,$80008
		dc.l	$F8050012,$90008
loc_70558:
		dc.w	$2
		dc.l	$E80B0000,$FFF4,$809000C,$6FFF4
loc_7056A:
		dc.w	$2
		dc.l	$E80B0000,$FFF4,$809000C,$6FFF4
loc_7057C:
		dc.w	$3
		dc.l	$FC050000,$FFEC,$F40B0004,$2FFFC
		dc.l	$F4010010,$80014
loc_70596:
		dc.w	$4
		dc.l	$F4010000,$FFE8,$F4070002,$1FFF0
		dc.l	$F4070802,$8010000,$F4010800,$8000010
loc_705B8:
		dc.w	$3
		dc.l	$FC050800,$8000004,$F40B0804,$802FFEC
		dc.l	$F4010810,$808FFE4
loc_705D2:
		dc.w	$3
		dc.l	$F4010000,$FFE4,$F40B0002,$1FFEC
		dc.l	$FC01000E,$70004
loc_705EC:
		dc.w	$3
		dc.l	$F4010800,$8000014,$F40B0802,$801FFFC
		dc.l	$FC01080E,$807FFF4
loc_70606:
		dc.w	$3
		dc.l	$FC050000,$FFEC,$F40B0004,$2FFFC
		dc.l	$F4010010,$80014
loc_70620:
		dc.w	$3
		dc.l	$E4090000,$FFF4,$F40F0006,$3FFEC
		dc.l	$4010016,$B000C
loc_7063A:
		dc.w	$2
		dc.l	$E80B0000,$FFF4,$805000C,$6FFFC
loc_7064C:
		dc.w	$4
		dc.l	$EA010000,$FFE8,$EA0B0002,$1FFF0
		dc.l	$EA01000E,$70008,$A0D0010,$8FFF0
loc_7066E:
		dc.w	$4
		dc.l	$EA010000,$FFE8,$EA0B0002,$1FFF0
		dc.l	$EA01000E,$70008,$A0D0010,$8FFF0
loc_70690:
		dc.w	$3
		dc.l	$EA0D0000,$FFE8,$EA010008,$40008
		dc.l	$FA0B000A,$5FFF0
loc_706AA:
		dc.w	$3
		dc.l	$E4090000,$FFF0,$F40B0006,$3FFF0
		dc.l	$F4010012,$90008
loc_706C4:
		dc.w	$3
		dc.l	$E50B0000,$FFF0,$F401000C,$60008
		dc.l	$505000E,$7FFF8
loc_706DE:
		dc.w	$2
		dc.l	$EC0B0000,$FFF1,$FC01000C,$60009
loc_706F0:
		dc.w	$1
		dc.l	$EE0F0000,$FFF0
loc_706FA:
		dc.w	$2
		dc.l	$F20B0000,$FFF0,$FA01000C,$60008
loc_7070C:
		dc.w	$3
		dc.l	$E4010000,$0,$F40B0002,$1FFF0
		dc.l	$F401000E,$70008
loc_70726:
		dc.w	$3
		dc.l	$E5090000,$FFF0,$F50B0006,$3FFF0
		dc.l	$ED030012,$90008
loc_70740:
		dc.w	$3
		dc.l	$E4050000,$FFF8,$F40B0004,$2FFF0
		dc.l	$F4010010,$80008
loc_7075A:
		dc.w	$2
		dc.l	$ED0B0000,$FFF0,$F501000C,$60008
loc_7076C:
		dc.w	$2
		dc.l	$F4010000,$FFF0,$F10B0002,$1FFF8
loc_7077E:
		dc.w	$3
		dc.l	$E4050000,$FFF1,$F40B0004,$2FFF0
		dc.l	$F4010010,$80008
loc_70798:
		dc.w	$2
		dc.l	$E1050000,$FFF0,$F10F0004,$2FFF0
loc_707AA:
		dc.w	$3
		dc.l	$E8070000,$FFF0,$E0030008,$40000
		dc.l	$9000C,$60000
loc_707C4:
		dc.w	$3
		dc.l	$E8070000,$FFF0,$E0030008,$40000
		dc.l	$9000C,$60000
loc_707DE:
		dc.w	$1
		dc.l	$F00B0000,$FFF5
loc_707E8:
		dc.w	$3
		dc.l	$E60B0000,$FFF0,$EE01000C,$60008
		dc.l	$609000E,$7FFF0
loc_70802:
		dc.w	$3
		dc.l	$E40A0000,$FFF0,$FC000009,$40008
		dc.l	$FC0A000A,$5FFF0
loc_7081C:
		dc.w	$5
		dc.l	$E4080000,$FFF0,$EC010003,$1FFF0
		dc.l	$EC050005,$2FFF8,$FC0A0009,$4FFF0
		dc.l	$FD000012,$90008
loc_70846:
		dc.w	$5
		dc.l	$E4080000,$FFF0,$EC010003,$1FFF0
		dc.l	$EC050005,$2FFF8,$FC0A0009,$4FFF0
		dc.l	$FD000012,$90008
loc_70870:
		dc.w	$2
		dc.l	$E70A0000,$FFF1,$FF0A0009,$4FFF3
loc_70882:
		dc.w	$2
		dc.l	$E70A0000,$FFF1,$FF0A0009,$4FFF3
loc_70894:
		dc.w	$2
		dc.l	$E70A0000,$FFF1,$FF0A0009,$4FFF3
loc_708A6:
		dc.w	$3
		dc.l	$E30E0000,$FFEE,$301000C,$6FFEC
		dc.l	$FB0F000E,$7FFF4
loc_708C0:
		dc.w	$4
		dc.l	$E40E0000,$FFEE,$401000C,$6FFEC
		dc.l	$FC0B000E,$7FFF4,$401001A,$D000C
loc_708E2:
		dc.w	$3
		dc.l	$E50E0000,$FFED,$FD09000C,$6FFF4
		dc.l	$D050012,$9FFF7
loc_708FC:
		dc.w	$2
		dc.l	$E40A0000,$FFF4,$FC0F0009,$4FFEE
loc_7090E:
		dc.w	$3
		dc.l	$E30A0000,$FFF4,$FB0F0009,$4FFEE
		dc.l	$FB010019,$C000E
loc_70928:
		dc.w	$4
		dc.l	$E40A0000,$FFF4,$4010009,$4FFEC
		dc.l	$FC0B000B,$5FFF4,$4010017,$B000C
loc_7094A:
		dc.w	$3
		dc.l	$E50E0000,$FFED,$FD09000C,$6FFF4
		dc.l	$D050012,$9FFF7
loc_70964:
		dc.w	$2
		dc.l	$E40E0000,$FFEE,$FC0B000C,$6FFF3
loc_70976:
		dc.w	$4
		dc.l	$EB0D0000,$FFE2,$F3050008,$40002
		dc.l	$FB09000C,$6FFEA,$B010012,$9FFFA
loc_70998:
		dc.w	$5
		dc.l	$EC0D0000,$FFE3,$EC010008,$40003
		dc.l	$FC0D000A,$5FFEB,$FC050012,$9000B
		dc.l	$C010016,$BFFFB
loc_709C2:
		dc.w	$5
		dc.l	$ED0A0000,$FFE4,$ED030009,$4FFFC
		dc.l	$500000D,$6FFF4,$F501000E,$70004
		dc.l	$5050010,$80004
loc_709EC:
		dc.w	$5
		dc.l	$E4000000,$FFF1,$EC0D0001,$FFE3
		dc.l	$EC010009,$40003,$FC05000B,$5FFEB
		dc.l	$FC0B000F,$7FFFB
loc_70A16:
		dc.w	$6
		dc.l	$E3000000,$FFF0,$EB0D0001,$FFE2
		dc.l	$EB010009,$40002,$F301000B,$5000A
		dc.l	$FB0D000D,$6FFEA,$B050015,$AFFF2
loc_70A48:
		dc.w	$6
		dc.l	$E4000000,$FFF1,$EC0D0001,$FFE3
		dc.l	$EC010009,$40003,$FC0D000B,$5FFEB
		dc.l	$FA050013,$9000B,$C010017,$BFFFB
loc_70A7A:
		dc.w	$5
		dc.l	$ED0A0000,$FFE4,$ED030009,$4FFFC
		dc.l	$500000D,$6FFF4,$F501000E,$70004
		dc.l	$5050010,$80004
loc_70AA4:
		dc.w	$5
		dc.l	$EC0D0000,$FFE3,$F4010008,$40003
		dc.l	$FC09000A,$5FFEB,$C000010,$8FFFB
		dc.l	$4050011,$80003
loc_70ACE:
		dc.w	$3
		dc.l	$F20B0000,$FFE3,$EC0B000C,$6FFFB
		dc.l	$C050018,$C0003
loc_70AE8:
		dc.w	$3
		dc.l	$F20B0000,$FFE4,$EC0B000C,$6FFFC
		dc.l	$C050018,$C0004
loc_70B02:
		dc.w	$3
		dc.l	$F30B0000,$FFE5,$F403000C,$6FFFD
		dc.l	$F9050010,$80005
loc_70B1C:
		dc.w	$2
		dc.l	$F40A0000,$FFE4,$F20B0009,$4FFFC
loc_70B2E:
		dc.w	$3
		dc.l	$F40A0000,$FFE3,$E3050009,$4FFFB
		dc.l	$F30B000D,$6FFFB
loc_70B48:
		dc.w	$3
		dc.l	$F40A0000,$FFE4,$EC0B0009,$4FFFC
		dc.l	$C050015,$A0004
loc_70B62:
		dc.w	$3
		dc.l	$F30B0000,$FFE5,$F403000C,$6FFFD
		dc.l	$F9050010,$80005
loc_70B7C:
		dc.w	$2
		dc.l	$F40B0000,$FFE4,$F20B000C,$6FFFC
loc_70B8E:
		dc.w	$4
		dc.l	$EE050000,$FFF3,$FE070004,$2FFEB
		dc.l	$FE0D000C,$6FFFB,$E000014,$AFFFB
loc_70BB0:
		dc.w	$5
		dc.l	$DD050000,$FFFC,$ED090004,$2FFF4
		dc.l	$FD07000A,$5FFEC,$FD0D0012,$9FFFC
		dc.l	$D00001A,$DFFFC
loc_70BDA:
		dc.w	$4
		dc.l	$EC0D0000,$FFF5,$FC070008,$4FFED
		dc.l	$FC050010,$8FFFD,$C010014,$AFFFD
loc_70BFC:
		dc.w	$4
		dc.l	$ED0D0000,$FFF4,$FD0B0008,$4FFE4
		dc.l	$FD090014,$AFFFC,$D00001A,$DFFFC
loc_70C1E:
		dc.w	$4
		dc.l	$EE090000,$FFF3,$FE0B0006,$3FFE3
		dc.l	$FE0D0012,$9FFFB,$E00001A,$DFFFB
loc_70C40:
		dc.w	$5
		dc.l	$DD050000,$FFFA,$ED090004,$2FFF4
		dc.l	$FD0B000A,$5FFE4,$FD0D0016,$BFFFC
		dc.l	$D00001E,$FFFFC
loc_70C6A:
		dc.w	$4
		dc.l	$EC0D0000,$FFF5,$FC070008,$4FFED
		dc.l	$FC050010,$8FFFD,$C010014,$AFFFD
loc_70C8C:
		dc.w	$4
		dc.l	$ED0D0000,$FFF4,$FD070008,$4FFEC
		dc.l	$FD090010,$8FFFC,$D000016,$BFFFC
loc_70CAE:
		dc.w	$3
		dc.l	$E30E0000,$FFEE,$301000C,$6FFEC
		dc.l	$FB0F000E,$7FFF4
loc_70CC8:
		dc.w	$4
		dc.l	$E40E0000,$FFEE,$401000C,$6FFEC
		dc.l	$FC0B000E,$7FFF4,$401001A,$D000C
loc_70CEA:
		dc.w	$3
		dc.l	$E50E0000,$FFED,$FD09000C,$6FFF4
		dc.l	$D050012,$9FFF7
loc_70D04:
		dc.w	$2
		dc.l	$E40A0000,$FFF4,$FC0F0009,$4FFEE
loc_70D16:
		dc.w	$3
		dc.l	$E30A0000,$FFF4,$FB0F0009,$4FFEE
		dc.l	$FB010019,$C000E
loc_70D30:
		dc.w	$4
		dc.l	$E40A0000,$FFF4,$4010009,$4FFEC
		dc.l	$FC0B000B,$5FFF4,$4010017,$B000C
loc_70D52:
		dc.w	$3
		dc.l	$E50E0000,$FFED,$FD09000C,$6FFF4
		dc.l	$D050012,$9FFF7
loc_70D6C:
		dc.w	$2
		dc.l	$E40E0000,$FFEE,$FC0B000C,$6FFF3
loc_70D7E:
		dc.w	$5
		dc.l	$E3040000,$FFEA,$EB0D0002,$1FFE2
		dc.l	$FB09000A,$5FFEA,$F3050010,$80002
		dc.l	$B010014,$AFFFA
loc_70DA8:
		dc.w	$6
		dc.l	$E4040000,$FFEB,$EC0D0002,$1FFE3
		dc.l	$EC01000A,$50003,$FC0D000C,$6FFEB
		dc.l	$FC050014,$A000B,$C010018,$CFFFB
loc_70DDA:
		dc.w	$5
		dc.l	$EB090000,$FFE4,$FB050006,$3FFEC
		dc.l	$ED03000A,$5FFFC,$F501000E,$70004
		dc.l	$5050010,$80004
loc_70E04:
		dc.w	$5
		dc.l	$E4040000,$FFEB,$EC0D0002,$1FFE3
		dc.l	$EC01000A,$50003,$FC05000C,$6FFEB
		dc.l	$FC0B0010,$8FFFB
loc_70E2E:
		dc.w	$6
		dc.l	$E3040000,$FFEA,$EB0D0002,$1FFE2
		dc.l	$EB01000A,$50002,$F301000C,$6000A
		dc.l	$FB0D000E,$7FFEA,$B050016,$BFFF2
loc_70E60:
		dc.w	$6
		dc.l	$E4040000,$FFEB,$EC0D0002,$1FFE3
		dc.l	$EC01000A,$50003,$FC0D000C,$6FFEB
		dc.l	$FA050014,$A000B,$C010018,$CFFFB
loc_70E92:
		dc.w	$5
		dc.l	$EB090000,$FFE4,$FB050006,$3FFEC
		dc.l	$ED03000A,$5FFFC,$F501000E,$70004
		dc.l	$5050010,$80004
loc_70EBC:
		dc.w	$6
		dc.l	$E4040000,$FFEB,$EC0D0002,$1FFE3
		dc.l	$FC09000A,$5FFEB,$F4010010,$80003
		dc.l	$4050012,$90003,$C010016,$BFFFB
loc_70EEE:
		dc.w	$3
		dc.l	$F20B0000,$FFE3,$EC0B000C,$6FFFB
		dc.l	$C050018,$C0003
loc_70F08:
		dc.w	$3
		dc.l	$F20B0000,$FFE4,$EC0B000C,$6FFFC
		dc.l	$C050018,$C0004
loc_70F22:
		dc.w	$3
		dc.l	$F30B0000,$FFE5,$F403000C,$6FFFD
		dc.l	$F9050010,$80005
loc_70F3C:
		dc.w	$2
		dc.l	$F40A0000,$FFE4,$F20B0009,$4FFFC
loc_70F4E:
		dc.w	$3
		dc.l	$F40A0000,$FFE3,$E3050009,$4FFFB
		dc.l	$F30B000D,$6FFFB
loc_70F68:
		dc.w	$3
		dc.l	$F40A0000,$FFE4,$EC0B0009,$4FFFC
		dc.l	$C050015,$A0004
loc_70F82:
		dc.w	$3
		dc.l	$F30B0000,$FFE5,$F403000C,$6FFFD
		dc.l	$F9050010,$80005
loc_70F9C:
		dc.w	$2
		dc.l	$F20B0000,$FFE4,$F40B000C,$6FFFC
loc_70FAE:
		dc.w	$4
		dc.l	$EE050000,$FFF3,$FE0B0004,$2FFE3
		dc.l	$FE0D0010,$8FFFB,$E000018,$CFFFB
loc_70FD0:
		dc.w	$5
		dc.l	$DD050000,$FFFC,$ED090004,$2FFF4
		dc.l	$FD0B000A,$5FFE4,$FD0D0016,$BFFFC
		dc.l	$D00001E,$FFFFC
loc_70FFA:
		dc.w	$5
		dc.l	$EC0D0000,$FFF5,$4010008,$4FFE5
		dc.l	$FC07000A,$5FFED,$FC050012,$9FFFD
		dc.l	$C000016,$BFFFD
loc_71024:
		dc.w	$4
		dc.l	$ED0D0000,$FFF4,$FD0B0008,$4FFE4
		dc.l	$FD090014,$AFFFC,$D00001A,$DFFFC
loc_71046:
		dc.w	$4
		dc.l	$EE090000,$FFF3,$FE0B0006,$3FFE3
		dc.l	$FE0D0012,$9FFFB,$E00001A,$DFFFB
loc_71068:
		dc.w	$5
		dc.l	$DD050000,$FFFA,$ED090004,$2FFF4
		dc.l	$FD0B000A,$5FFE4,$FD0D0016,$BFFFC
		dc.l	$D00001E,$FFFFC
loc_71092:
		dc.w	$5
		dc.l	$EC0D0000,$FFF5,$4010008,$4FFE5
		dc.l	$FC07000A,$5FFED,$FC050012,$9FFFD
		dc.l	$C000016,$BFFFD
loc_710BC:
		dc.w	$5
		dc.l	$ED0D0000,$FFF4,$5010008,$4FFE4
		dc.l	$FD07000A,$5FFEC,$FD090012,$9FFFC
		dc.l	$D000018,$CFFFC
loc_710E6:
		dc.w	$4
		dc.l	$F0080000,$FFFC,$F8000003,$1FFFC
		dc.l	$F8050004,$20004,$90008,$4FFEC
loc_71108:
		dc.w	$4
		dc.l	$E6040000,$FFFA,$EE0B0002,$1FFF2
		dc.l	$EE02000E,$7000A,$E040011,$8FFFA
loc_7112A:
		dc.w	$4
		dc.l	$EC020000,$FFF0,$EC050003,$1FFF8
		dc.l	$FC080007,$3FFF8,$405000A,$50000
loc_7114C:
		dc.w	$5
		dc.l	$EE080000,$FFEE,$F60D0003,$1FFE6
		dc.l	$F605000B,$50006,$604000F,$7FFEE
		dc.l	$6000011,$80006
loc_71176:
		dc.w	$4
		dc.l	$E8090000,$FFFC,$F8000006,$3FFFC
		dc.l	$F8050007,$30004,$9000B,$5FFEC
loc_71198:
		dc.w	$4
		dc.l	$E6040000,$FFFA,$EE0B0002,$1FFF2
		dc.l	$EE02000E,$7000A,$E000011,$8FFFA
loc_711BA:
		dc.w	$4
		dc.l	$EC060000,$FFE8,$EC050006,$3FFF8
		dc.l	$FC00000A,$5FFF8,$FC06000B,$50000
loc_711DC:
		dc.w	$5
		dc.l	$EE080000,$FFEE,$F60D0003,$1FFE6
		dc.l	$F605000B,$50006,$604000F,$7FFEE
		dc.l	$6000011,$80006
loc_71206:
		dc.w	$4
		dc.l	$E5090000,$FFEE,$F5050006,$3FFEB
		dc.l	$F505000A,$5FFFB,$50D000E,$7FFEB
loc_71228:
		dc.w	$4
		dc.l	$E4090000,$FFEE,$F4050006,$3FFEB
		dc.l	$F405000A,$5FFFB,$40D000E,$7FFEB
loc_7124A:
		dc.w	$4
		dc.l	$E5090000,$FFEE,$F5050006,$3FFEB
		dc.l	$F505000A,$5FFFB,$50D000E,$7FFEB
loc_7126C:
		dc.w	$4
		dc.l	$E4090000,$FFEE,$F4050006,$3FFEB
		dc.l	$F405000A,$5FFFB,$40D000E,$7FFEB
loc_7128E:
		dc.w	$2
		dc.l	$FC020000,$FFF0,$F40B0003,$1FFF8
loc_712A0:
		dc.w	$3
		dc.l	$E40A0000,$FFEC,$FC080009,$4FFEC
		dc.l	$405000C,$6FFF1
loc_712BA:
		dc.w	$3
		dc.l	$E40A0000,$FFEC,$FC080009,$4FFEC
		dc.l	$405000C,$6FFF1
loc_712D4:
		dc.w	$3
		dc.l	$E40A0000,$FFEC,$FC080009,$4FFEC
		dc.l	$405000C,$6FFF1
loc_712EE:
		dc.w	$3
		dc.l	$E50A0000,$FFED,$FD080009,$4FFED
		dc.l	$505000C,$6FFF1
loc_71308:
		dc.w	$3
		dc.l	$E50A0000,$FFED,$FD080009,$4FFED
		dc.l	$505000C,$6FFF1
loc_71322:
		dc.w	$3
		dc.l	$E50A0000,$FFED,$FD080009,$4FFED
		dc.l	$505000C,$6FFF1
loc_7133C:
		dc.w	$3
		dc.l	$EC0B0000,$FFF0,$EC03000C,$60008
		dc.l	$C050010,$8FFF1
loc_71356:
		dc.w	$3
		dc.l	$EC0B0000,$FFF0,$EC03000C,$60008
		dc.l	$C050010,$8FFF1
loc_71370:
		dc.w	$3
		dc.l	$EC0B0000,$FFF0,$EC03000C,$60008
		dc.l	$C050010,$8FFF1
loc_7138A:
		dc.w	$5
		dc.l	$EC0B0000,$FFF0,$EC01000C,$60008
		dc.l	$EC01000E,$70010,$FC010010,$80008
		dc.l	$C050012,$9FFF1
loc_713B4:
		dc.w	$4
		dc.l	$EC070000,$FFEB,$EC090008,$4FFFB
		dc.l	$FC05000E,$7FFFB,$C090012,$9FFEE
loc_713D6:
		dc.w	$4
		dc.l	$EC070000,$FFEC,$EC090008,$4FFFC
		dc.l	$FC05000E,$7FFFC,$C090012,$9FFEF
loc_713F8:
		dc.w	$4
		dc.l	$EC070000,$FFEC,$EC090008,$4FFFC
		dc.l	$FC09000E,$7FFFC,$C090014,$AFFF0
loc_7141A:
		dc.w	$3
		dc.l	$F4030000,$FFE8,$EC0B0004,$2FFF0
		dc.l	$C050010,$8FFF0
loc_71434:
		dc.w	$3
		dc.l	$F4030800,$800000C,$EC0B0804,$802FFF4
		dc.l	$C050810,$808FFFC
loc_7144E:
		dc.w	$3
		dc.l	$F4030800,$800000C,$EC0B0804,$802FFF4
		dc.l	$C050810,$808FFFC
loc_71468:
		dc.w	$4
		dc.l	$EC0D0000,$FFED,$FC0D0008,$4FFEF
		dc.l	$FC010010,$8000F,$C050012,$90001
loc_7148A:
		dc.w	$4
		dc.l	$EC0D0000,$FFEE,$FC0D0008,$4FFEF
		dc.l	$FC010010,$8000F,$C050012,$90001
loc_714AC:
		dc.w	$4
		dc.l	$EC0D0000,$FFEF,$FC0D0008,$4FFEF
		dc.l	$FC010010,$8000F,$C050012,$90001
loc_714CE:
		dc.w	$2
		dc.l	$EC090000,$FFF4,$FC0B0006,$3FFF7
;------------------------------------------------------------------------------- 
Sonic_Dyn_Script: 
		dc.w	loc_7168C-Sonic_Dyn_Script
		dc.w	loc_7168E-Sonic_Dyn_Script
		dc.w	loc_71698-Sonic_Dyn_Script
		dc.w	loc_7169E-Sonic_Dyn_Script
		dc.w	loc_716A8-Sonic_Dyn_Script
		dc.w	loc_716B2-Sonic_Dyn_Script
		dc.w	loc_716BE-Sonic_Dyn_Script
		dc.w	loc_716C6-Sonic_Dyn_Script
		dc.w	loc_716CC-Sonic_Dyn_Script
		dc.w	loc_716D2-Sonic_Dyn_Script
		dc.w	loc_716D8-Sonic_Dyn_Script
		dc.w	loc_716DE-Sonic_Dyn_Script
		dc.w	loc_716E8-Sonic_Dyn_Script
		dc.w	loc_716F2-Sonic_Dyn_Script
		dc.w	loc_716FA-Sonic_Dyn_Script
		dc.w	loc_71704-Sonic_Dyn_Script
		dc.w	loc_7170C-Sonic_Dyn_Script
		dc.w	loc_71712-Sonic_Dyn_Script
		dc.w	loc_7171A-Sonic_Dyn_Script
		dc.w	loc_71724-Sonic_Dyn_Script
		dc.w	loc_7172C-Sonic_Dyn_Script
		dc.w	loc_71732-Sonic_Dyn_Script
		dc.w	loc_7173C-Sonic_Dyn_Script
		dc.w	loc_71748-Sonic_Dyn_Script
		dc.w	loc_71752-Sonic_Dyn_Script
		dc.w	loc_7175C-Sonic_Dyn_Script
		dc.w	loc_71768-Sonic_Dyn_Script
		dc.w	loc_71774-Sonic_Dyn_Script
		dc.w	loc_7177E-Sonic_Dyn_Script
		dc.w	loc_7178A-Sonic_Dyn_Script
		dc.w	loc_71792-Sonic_Dyn_Script
		dc.w	loc_7179A-Sonic_Dyn_Script
		dc.w	loc_717A2-Sonic_Dyn_Script
		dc.w	loc_717A8-Sonic_Dyn_Script
		dc.w	loc_717B0-Sonic_Dyn_Script
		dc.w	loc_717B8-Sonic_Dyn_Script
		dc.w	loc_717C0-Sonic_Dyn_Script
		dc.w	loc_717C6-Sonic_Dyn_Script
		dc.w	loc_717D0-Sonic_Dyn_Script
		dc.w	loc_717DC-Sonic_Dyn_Script
		dc.w	loc_717E6-Sonic_Dyn_Script
		dc.w	loc_717F0-Sonic_Dyn_Script
		dc.w	loc_717FA-Sonic_Dyn_Script
		dc.w	loc_71806-Sonic_Dyn_Script
		dc.w	loc_71810-Sonic_Dyn_Script
		dc.w	loc_7181A-Sonic_Dyn_Script
		dc.w	loc_71820-Sonic_Dyn_Script
		dc.w	loc_71826-Sonic_Dyn_Script
		dc.w	loc_7182C-Sonic_Dyn_Script
		dc.w	loc_71832-Sonic_Dyn_Script
		dc.w	loc_7183C-Sonic_Dyn_Script
		dc.w	loc_71844-Sonic_Dyn_Script
		dc.w	loc_7184E-Sonic_Dyn_Script
		dc.w	loc_71856-Sonic_Dyn_Script
		dc.w	loc_7185C-Sonic_Dyn_Script
		dc.w	loc_71862-Sonic_Dyn_Script
		dc.w	loc_71868-Sonic_Dyn_Script
		dc.w	loc_7186E-Sonic_Dyn_Script
		dc.w	loc_71876-Sonic_Dyn_Script
		dc.w	loc_7187C-Sonic_Dyn_Script
		dc.w	loc_71884-Sonic_Dyn_Script
		dc.w	loc_7188A-Sonic_Dyn_Script
		dc.w	loc_7188E-Sonic_Dyn_Script
		dc.w	loc_71892-Sonic_Dyn_Script
		dc.w	loc_71896-Sonic_Dyn_Script
		dc.w	loc_7189A-Sonic_Dyn_Script
		dc.w	loc_7189E-Sonic_Dyn_Script
		dc.w	loc_718A2-Sonic_Dyn_Script
		dc.w	loc_718A6-Sonic_Dyn_Script
		dc.w	loc_718AA-Sonic_Dyn_Script
		dc.w	loc_718AE-Sonic_Dyn_Script
		dc.w	loc_718B2-Sonic_Dyn_Script
		dc.w	loc_718B6-Sonic_Dyn_Script
		dc.w	loc_718BE-Sonic_Dyn_Script
		dc.w	loc_718C6-Sonic_Dyn_Script
		dc.w	loc_718CE-Sonic_Dyn_Script
		dc.w	loc_718D6-Sonic_Dyn_Script
		dc.w	loc_718DA-Sonic_Dyn_Script
		dc.w	loc_718DE-Sonic_Dyn_Script
		dc.w	loc_718E4-Sonic_Dyn_Script
		dc.w	loc_718EA-Sonic_Dyn_Script
		dc.w	loc_718F2-Sonic_Dyn_Script
		dc.w	loc_718FA-Sonic_Dyn_Script
		dc.w	loc_71900-Sonic_Dyn_Script
		dc.w	loc_71906-Sonic_Dyn_Script
		dc.w	loc_7190E-Sonic_Dyn_Script
		dc.w	loc_71906-Sonic_Dyn_Script
		dc.w	loc_71914-Sonic_Dyn_Script
		dc.w	loc_71914-Sonic_Dyn_Script
		dc.w	loc_7191C-Sonic_Dyn_Script
		dc.w	loc_71924-Sonic_Dyn_Script
		dc.w	loc_7192C-Sonic_Dyn_Script
		dc.w	loc_71932-Sonic_Dyn_Script
		dc.w	loc_7193C-Sonic_Dyn_Script
		dc.w	loc_71946-Sonic_Dyn_Script
		dc.w	loc_7194E-Sonic_Dyn_Script
		dc.w	loc_71956-Sonic_Dyn_Script
		dc.w	loc_7195E-Sonic_Dyn_Script
		dc.w	loc_71964-Sonic_Dyn_Script
		dc.w	loc_71968-Sonic_Dyn_Script
		dc.w	loc_7196E-Sonic_Dyn_Script
		dc.w	loc_71976-Sonic_Dyn_Script
		dc.w	loc_7197E-Sonic_Dyn_Script
		dc.w	loc_71986-Sonic_Dyn_Script
		dc.w	loc_7198C-Sonic_Dyn_Script
		dc.w	loc_71992-Sonic_Dyn_Script
		dc.w	loc_7199A-Sonic_Dyn_Script
		dc.w	loc_719A0-Sonic_Dyn_Script
		dc.w	loc_719A8-Sonic_Dyn_Script
		dc.w	loc_719B0-Sonic_Dyn_Script
		dc.w	loc_719B4-Sonic_Dyn_Script
		dc.w	loc_719BC-Sonic_Dyn_Script
		dc.w	loc_719C4-Sonic_Dyn_Script
		dc.w	loc_719D0-Sonic_Dyn_Script
		dc.w	loc_719DC-Sonic_Dyn_Script
		dc.w	loc_719E2-Sonic_Dyn_Script
		dc.w	loc_719E8-Sonic_Dyn_Script
		dc.w	loc_719EE-Sonic_Dyn_Script
		dc.w	loc_719F6-Sonic_Dyn_Script
		dc.w	loc_71A00-Sonic_Dyn_Script
		dc.w	loc_71A08-Sonic_Dyn_Script
		dc.w	loc_71A0E-Sonic_Dyn_Script
		dc.w	loc_71A16-Sonic_Dyn_Script
		dc.w	loc_71A20-Sonic_Dyn_Script
		dc.w	loc_71A28-Sonic_Dyn_Script
		dc.w	loc_71A2E-Sonic_Dyn_Script
		dc.w	loc_71A38-Sonic_Dyn_Script
		dc.w	loc_71A44-Sonic_Dyn_Script
		dc.w	loc_71A50-Sonic_Dyn_Script
		dc.w	loc_71A5C-Sonic_Dyn_Script
		dc.w	loc_71A6A-Sonic_Dyn_Script
		dc.w	loc_71A78-Sonic_Dyn_Script
		dc.w	loc_71A84-Sonic_Dyn_Script
		dc.w	loc_71A90-Sonic_Dyn_Script
		dc.w	loc_71A98-Sonic_Dyn_Script
		dc.w	loc_71AA0-Sonic_Dyn_Script
		dc.w	loc_71AA8-Sonic_Dyn_Script
		dc.w	loc_71AAE-Sonic_Dyn_Script
		dc.w	loc_71AB6-Sonic_Dyn_Script
		dc.w	loc_71ABE-Sonic_Dyn_Script
		dc.w	loc_71AC6-Sonic_Dyn_Script
		dc.w	loc_71ACC-Sonic_Dyn_Script
		dc.w	loc_71AD6-Sonic_Dyn_Script
		dc.w	loc_71AE2-Sonic_Dyn_Script
		dc.w	loc_71AEC-Sonic_Dyn_Script
		dc.w	loc_71AF6-Sonic_Dyn_Script
		dc.w	loc_71B00-Sonic_Dyn_Script
		dc.w	loc_71B0C-Sonic_Dyn_Script
		dc.w	loc_71B16-Sonic_Dyn_Script
		dc.w	loc_71B20-Sonic_Dyn_Script
		dc.w	loc_71B28-Sonic_Dyn_Script
		dc.w	loc_71B32-Sonic_Dyn_Script
		dc.w	loc_71B3A-Sonic_Dyn_Script
		dc.w	loc_71B40-Sonic_Dyn_Script
		dc.w	loc_71B48-Sonic_Dyn_Script
		dc.w	loc_71B52-Sonic_Dyn_Script
		dc.w	loc_71B5A-Sonic_Dyn_Script
		dc.w	loc_71B60-Sonic_Dyn_Script
		dc.w	loc_71B6C-Sonic_Dyn_Script
		dc.w	loc_71B7A-Sonic_Dyn_Script
		dc.w	loc_71B86-Sonic_Dyn_Script
		dc.w	loc_71B92-Sonic_Dyn_Script
		dc.w	loc_71BA0-Sonic_Dyn_Script
		dc.w	loc_71BAE-Sonic_Dyn_Script
		dc.w	loc_71BBA-Sonic_Dyn_Script
		dc.w	loc_71BC8-Sonic_Dyn_Script
		dc.w	loc_71BD0-Sonic_Dyn_Script
		dc.w	loc_71BD8-Sonic_Dyn_Script
		dc.w	loc_71BE0-Sonic_Dyn_Script
		dc.w	loc_71BE6-Sonic_Dyn_Script
		dc.w	loc_71BEE-Sonic_Dyn_Script
		dc.w	loc_71BF6-Sonic_Dyn_Script
		dc.w	loc_71BFE-Sonic_Dyn_Script
		dc.w	loc_71C04-Sonic_Dyn_Script
		dc.w	loc_71C0E-Sonic_Dyn_Script
		dc.w	loc_71C1A-Sonic_Dyn_Script
		dc.w	loc_71C26-Sonic_Dyn_Script
		dc.w	loc_71C30-Sonic_Dyn_Script
		dc.w	loc_71C3A-Sonic_Dyn_Script
		dc.w	loc_71C46-Sonic_Dyn_Script
		dc.w	loc_71C52-Sonic_Dyn_Script
		dc.w	loc_71C5E-Sonic_Dyn_Script
		dc.w	loc_71C68-Sonic_Dyn_Script
		dc.w	loc_71C72-Sonic_Dyn_Script
		dc.w	loc_71C7C-Sonic_Dyn_Script
		dc.w	loc_71C88-Sonic_Dyn_Script
		dc.w	loc_71C92-Sonic_Dyn_Script
		dc.w	loc_71C9C-Sonic_Dyn_Script
		dc.w	loc_71CA6-Sonic_Dyn_Script
		dc.w	loc_71CB2-Sonic_Dyn_Script
		dc.w	loc_71CBC-Sonic_Dyn_Script
		dc.w	loc_71CC6-Sonic_Dyn_Script
		dc.w	loc_71CD0-Sonic_Dyn_Script
		dc.w	loc_71CDA-Sonic_Dyn_Script
		dc.w	loc_71CE0-Sonic_Dyn_Script
		dc.w	loc_71CE8-Sonic_Dyn_Script
		dc.w	loc_71CF0-Sonic_Dyn_Script
		dc.w	loc_71CF8-Sonic_Dyn_Script
		dc.w	loc_71D00-Sonic_Dyn_Script
		dc.w	loc_71D08-Sonic_Dyn_Script
		dc.w	loc_71D10-Sonic_Dyn_Script
		dc.w	loc_71D18-Sonic_Dyn_Script
		dc.w	loc_71D20-Sonic_Dyn_Script
		dc.w	loc_71D28-Sonic_Dyn_Script
		dc.w	loc_71D34-Sonic_Dyn_Script
		dc.w	loc_71D3E-Sonic_Dyn_Script
		dc.w	loc_71D48-Sonic_Dyn_Script
		dc.w	loc_71D52-Sonic_Dyn_Script
		dc.w	loc_71D5A-Sonic_Dyn_Script
		dc.w	loc_71D62-Sonic_Dyn_Script
		dc.w	loc_71D6A-Sonic_Dyn_Script
		dc.w	loc_71D74-Sonic_Dyn_Script
		dc.w	loc_71D7E-Sonic_Dyn_Script
		dc.w	loc_71D88-Sonic_Dyn_Script
loc_7168C:
		dc.w	$0
loc_7168E:
		dc.w	$4
		dc.w	$3000,$3004,$5008,$500E
loc_71698:
		dc.w	$2
		dc.w	$B014,$5020
loc_7169E:
		dc.w	$4
		dc.w	$3026,$302A,$302E,$5032
loc_716A8:
		dc.w	$4
		dc.w	$3026,$3038,$302E,$5032
loc_716B2:
		dc.w	$5
		dc.w	$3026,$3038,$302E,$1032,$303C
loc_716BE:
		dc.w	$3
		dc.w	$3026,$7040,$5032
loc_716C6:
		dc.w	$2
		dc.w	$B048,$1054
loc_716CC:
		dc.w	$2
		dc.w	$B056,$3062
loc_716D2:
		dc.w	$2
		dc.w	$B056,$3066
loc_716D8:
		dc.w	$2
		dc.w	$B06A,$7076
loc_716DE:
		dc.w	$4
		dc.w	$307E,$3082,$5086,$500E
loc_716E8:
		dc.w	$4
		dc.w	$308C,$3090,$3094,$500E
loc_716F2:
		dc.w	$3
		dc.w	$7098,$10A0,$F0A2
loc_716FA:
		dc.w	$4
		dc.w	$7098,$10B2,$B0B4,$10C0
loc_71704:
		dc.w	$3
		dc.w	$70C2,$50CA,$30D0
loc_7170C:
		dc.w	$2
		dc.w	$50D4,$F0DA
loc_71712:
		dc.w	$3
		dc.w	$50D4,$F0EA,$10FA
loc_7171A:
		dc.w	$4
		dc.w	$50D4,$10FC,$B0FE,$110A
loc_71724:
		dc.w	$3
		dc.w	$70C2,$510C,$3112
loc_7172C:
		dc.w	$2
		dc.w	$7098,$B116
loc_71732:
		dc.w	$4
		dc.w	$5122,$5128,$312E,$1132
loc_7173C:
		dc.w	$5
		dc.w	$5122,$1134,$7136,$313E,$1142
loc_71748:
		dc.w	$4
		dc.w	$7144,$314C,$1150,$3152
loc_71752:
		dc.w	$4
		dc.w	$5156,$115C,$315E,$B162
loc_7175C:
		dc.w	$5
		dc.w	$5156,$116E,$7170,$1178,$317A
loc_71768:
		dc.w	$5
		dc.w	$5156,$117E,$7180,$3188,$118C
loc_71774:
		dc.w	$4
		dc.w	$7144,$318E,$1192,$3194
loc_7177E:
		dc.w	$5
		dc.w	$5122,$5198,$119E,$11A0,$31A2
loc_7178A:
		dc.w	$3
		dc.w	$71A6,$B1AE,$31BA
loc_71792:
		dc.w	$3
		dc.w	$71A6,$B1BE,$31CA
loc_7179A:
		dc.w	$3
		dc.w	$71CE,$31D6,$31DA
loc_717A2:
		dc.w	$2
		dc.w	$71DE,$B1E6
loc_717A8:
		dc.w	$3
		dc.w	$71DE,$31F2,$B1F6
loc_717B0:
		dc.w	$3
		dc.w	$71DE,$B202,$320E
loc_717B8:
		dc.w	$3
		dc.w	$71CE,$3212,$3216
loc_717C0:
		dc.w	$2
		dc.w	$71A6,$B21A
loc_717C6:
		dc.w	$4
		dc.w	$3226,$722A,$7232,$123A
loc_717D0:
		dc.w	$5
		dc.w	$323C,$5240,$722A,$7246,$123A
loc_717DC:
		dc.w	$4
		dc.w	$724E,$7256,$325E,$1262
loc_717E6:
		dc.w	$4
		dc.w	$7264,$726C,$5274,$127A
loc_717F0:
		dc.w	$4
		dc.w	$527C,$726C,$7282,$127A
loc_717FA:
		dc.w	$5
		dc.w	$328A,$528E,$726C,$7294,$127A
loc_71806:
		dc.w	$4
		dc.w	$729C,$7256,$32A4,$1262
loc_71810:
		dc.w	$4
		dc.w	$72A8,$722A,$52B0,$123A
loc_7181A:
		dc.w	$2
		dc.w	$52B6,$F2BC
loc_71820:
		dc.w	$2
		dc.w	$52CC,$F2D2
loc_71826:
		dc.w	$2
		dc.w	$52B6,$F2E2
loc_7182C:
		dc.w	$2
		dc.w	$52CC,$F2F2
loc_71832:
		dc.w	$4
		dc.w	$5302,$1308,$730A,$5312
loc_7183C:
		dc.w	$3
		dc.w	$7318,$7320,$5328
loc_71844:
		dc.w	$4
		dc.w	$5302,$132E,$7330,$5338
loc_7184E:
		dc.w	$3
		dc.w	$7318,$733E,$5346
loc_71856:
		dc.w	$2
		dc.w	$734C,$B354
loc_7185C:
		dc.w	$2
		dc.w	$7360,$B368
loc_71862:
		dc.w	$2
		dc.w	$734C,$B374
loc_71868:
		dc.w	$2
		dc.w	$7360,$B380
loc_7186E:
		dc.w	$3
		dc.w	$138C,$738E,$B396
loc_71876:
		dc.w	$2
		dc.w	$73A2,$B3AA
loc_7187C:
		dc.w	$3
		dc.w	$13B6,$738E,$B3C0
loc_71884:
		dc.w	$2
		dc.w	$73A2,$B3CC
loc_7188A:
		dc.w	$1
		dc.w	$F400
loc_7188E:
		dc.w	$1
		dc.w	$F410
loc_71892:
		dc.w	$1
		dc.w	$F420
loc_71896:
		dc.w	$1
		dc.w	$F430
loc_7189A:
		dc.w	$1
		dc.w	$F440
loc_7189E:
		dc.w	$1
		dc.w	$F450
loc_718A2:
		dc.w	$1
		dc.w	$F460
loc_718A6:
		dc.w	$1
		dc.w	$F470
loc_718AA:
		dc.w	$1
		dc.w	$F480
loc_718AE:
		dc.w	$1
		dc.w	$F490
loc_718B2:
		dc.w	$1
		dc.w	$F4A0
loc_718B6:
		dc.w	$3
		dc.w	$53D8,$53DE,$73E4
loc_718BE:
		dc.w	$3
		dc.w	$53D8,$53EC,$53F2
loc_718C6:
		dc.w	$3
		dc.w	$53D8,$53DE,$73B8
loc_718CE:
		dc.w	$3
		dc.w	$53D8,$53EC,$54B0
loc_718D6:
		dc.w	$1
		dc.w	$B4B6
loc_718DA:
		dc.w	$1
		dc.w	$F4C2
loc_718DE:
		dc.w	$2
		dc.w	$14D2,$F4D4
loc_718E4:
		dc.w	$2
		dc.w	$34E4,$F4E8
loc_718EA:
		dc.w	$3
		dc.w	$F4F8,$1508,$350A
loc_718F2:
		dc.w	$3
		dc.w	$F50E,$151E,$3520
loc_718FA:
		dc.w	$2
		dc.w	$B524,$5530
loc_71900:
		dc.w	$2
		dc.w	$B536,$5542
loc_71906:
		dc.w	$3
		dc.w	$3548,$B54C,$1558
loc_7190E:
		dc.w	$2
		dc.w	$155A,$755C
loc_71914:
		dc.w	$3
		dc.w	$1564,$B566,$1572
loc_7191C:
		dc.w	$3
		dc.w	$3574,$B578,$1584
loc_71924:
		dc.w	$3
		dc.w	$5586,$F58C,$159C
loc_7192C:
		dc.w	$2
		dc.w	$B59E,$35AA
loc_71932:
		dc.w	$4
		dc.w	$15AE,$B5B0,$15BC,$75BE
loc_7193C:
		dc.w	$4
		dc.w	$15AE,$B5C6,$15BC,$75BE
loc_71946:
		dc.w	$3
		dc.w	$75D2,$15DA,$B5DC
loc_7194E:
		dc.w	$3
		dc.w	$55E8,$B5EE,$15FA
loc_71956:
		dc.w	$3
		dc.w	$B5FC,$1608,$360A
loc_7195E:
		dc.w	$2
		dc.w	$B60E,$161A
loc_71964:
		dc.w	$1
		dc.w	$F61C
loc_71968:
		dc.w	$2
		dc.w	$B62C,$1638
loc_7196E:
		dc.w	$3
		dc.w	$163A,$B63C,$1648
loc_71976:
		dc.w	$3
		dc.w	$564A,$B650,$365C
loc_7197E:
		dc.w	$3
		dc.w	$3660,$B664,$1670
loc_71986:
		dc.w	$2
		dc.w	$B672,$167E
loc_7198C:
		dc.w	$2
		dc.w	$1680,$B682
loc_71992:
		dc.w	$3
		dc.w	$368E,$B692,$169E
loc_7199A:
		dc.w	$2
		dc.w	$36A0,$F6A4
loc_719A0:
		dc.w	$3
		dc.w	$76B4,$36BC,$56C0
loc_719A8:
		dc.w	$3
		dc.w	$76C6,$36BC,$56CE
loc_719B0:
		dc.w	$1
		dc.w	$B7D6
loc_719B4:
		dc.w	$3
		dc.w	$B7E2,$17EE,$57F0
loc_719BC:
		dc.w	$3
		dc.w	$87F6,$A18,$8800
loc_719C4:
		dc.w	$5
		dc.w	$2809,$180C,$380E,$8812,$81B
loc_719D0:
		dc.w	$5
		dc.w	$281C,$181F,$380E,$8812,$81B
loc_719DC:
		dc.w	$2
		dc.w	$8821,$882A
loc_719E2:
		dc.w	$2
		dc.w	$8833,$882A
loc_719E8:
		dc.w	$2
		dc.w	$883C,$882A
loc_719EE:
		dc.w	$3
		dc.w	$B6D4,$10A0,$F0A2
loc_719F6:
		dc.w	$4
		dc.w	$B6D4,$10B2,$B0B4,$10C0
loc_71A00:
		dc.w	$3
		dc.w	$B6E0,$50CA,$30D0
loc_71A08:
		dc.w	$2
		dc.w	$86EC,$F0DA
loc_71A0E:
		dc.w	$3
		dc.w	$86EC,$F0EA,$10FA
loc_71A16:
		dc.w	$4
		dc.w	$86EC,$10FC,$B0FE,$110A
loc_71A20:
		dc.w	$3
		dc.w	$B6E0,$510C,$3112
loc_71A28:
		dc.w	$2
		dc.w	$B6D4,$B116
loc_71A2E:
		dc.w	$4
		dc.w	$76F5,$312E,$5128,$1132
loc_71A38:
		dc.w	$5
		dc.w	$76F5,$1134,$7136,$313E,$1142
loc_71A44:
		dc.w	$5
		dc.w	$86FD,$314C,$706,$1150,$3152
loc_71A50:
		dc.w	$5
		dc.w	$707,$7708,$115C,$315E,$B162
loc_71A5C:
		dc.w	$6
		dc.w	$707,$7708,$116E,$1178,$7170,$317A
loc_71A6A:
		dc.w	$6
		dc.w	$707,$7708,$117E,$7180,$3188,$118C
loc_71A78:
		dc.w	$5
		dc.w	$86FD,$318E,$706,$1192,$3194
loc_71A84:
		dc.w	$5
		dc.w	$76F5,$119E,$5198,$1A0,$31A2
loc_71A90:
		dc.w	$3
		dc.w	$B710,$B1AE,$31BA
loc_71A98:
		dc.w	$3
		dc.w	$B710,$B1BE,$31CA
loc_71AA0:
		dc.w	$3
		dc.w	$B71C,$31D6,$31DA
loc_71AA8:
		dc.w	$2
		dc.w	$8728,$B1E6
loc_71AAE:
		dc.w	$3
		dc.w	$8728,$31F2,$B1F6
loc_71AB6:
		dc.w	$3
		dc.w	$8728,$B202,$320E
loc_71ABE:
		dc.w	$3
		dc.w	$B71C,$3212,$3216
loc_71AC6:
		dc.w	$2
		dc.w	$B710,$B21A
loc_71ACC:
		dc.w	$4
		dc.w	$3226,$7731,$7232,$739
loc_71AD6:
		dc.w	$5
		dc.w	$323C,$5240,$7731,$7246,$739
loc_71AE2:
		dc.w	$4
		dc.w	$724E,$773A,$325E,$1742
loc_71AEC:
		dc.w	$4
		dc.w	$7264,$B744,$5274,$750
loc_71AF6:
		dc.w	$4
		dc.w	$527C,$B744,$7282,$750
loc_71B00:
		dc.w	$5
		dc.w	$328A,$528E,$B744,$7294,$750
loc_71B0C:
		dc.w	$4
		dc.w	$729C,$773A,$32A4,$1742
loc_71B16:
		dc.w	$4
		dc.w	$72A8,$7731,$52B0,$739
loc_71B20:
		dc.w	$3
		dc.w	$B751,$10A0,$F0A2
loc_71B28:
		dc.w	$4
		dc.w	$B751,$10B2,$B0B4,$10C0
loc_71B32:
		dc.w	$3
		dc.w	$B75D,$50CA,$30D0
loc_71B3A:
		dc.w	$2
		dc.w	$8769,$F0DA
loc_71B40:
		dc.w	$3
		dc.w	$8769,$F0EA,$10FA
loc_71B48:
		dc.w	$4
		dc.w	$8769,$10FC,$B0FE,$110A
loc_71B52:
		dc.w	$3
		dc.w	$B75D,$510C,$3112
loc_71B5A:
		dc.w	$2
		dc.w	$B751,$B116
loc_71B60:
		dc.w	$5
		dc.w	$1772,$7774,$5128,$312E,$1132
loc_71B6C:
		dc.w	$6
		dc.w	$1772,$7774,$1134,$7136,$313E,$1142
loc_71B7A:
		dc.w	$5
		dc.w	$577C,$3782,$314C,$1150,$3152
loc_71B86:
		dc.w	$5
		dc.w	$1786,$7788,$115C,$315E,$B162
loc_71B92:
		dc.w	$6
		dc.w	$1786,$7788,$116E,$1178,$7170,$317A
loc_71BA0:
		dc.w	$6
		dc.w	$1786,$7788,$117E,$7180,$3188,$118C
loc_71BAE:
		dc.w	$5
		dc.w	$577C,$3782,$318E,$1192,$3194
loc_71BBA:
		dc.w	$6
		dc.w	$1772,$7774,$5198,$119E,$31A2,$11A0
loc_71BC8:
		dc.w	$3
		dc.w	$B790,$B1AE,$31BA
loc_71BD0:
		dc.w	$3
		dc.w	$B790,$B1BE,$31CA
loc_71BD8:
		dc.w	$3
		dc.w	$B79C,$31D6,$31DA
loc_71BE0:
		dc.w	$2
		dc.w	$87A8,$B1E6
loc_71BE6:
		dc.w	$3
		dc.w	$87A8,$31F2,$B1F6
loc_71BEE:
		dc.w	$3
		dc.w	$87A8,$B202,$320E
loc_71BF6:
		dc.w	$3
		dc.w	$B79C,$3212,$3216
loc_71BFE:
		dc.w	$2
		dc.w	$B790,$B21A
loc_71C04:
		dc.w	$4
		dc.w	$3226,$B7B1,$7232,$7BD
loc_71C0E:
		dc.w	$5
		dc.w	$323C,$5240,$B7B1,$7246,$7BD
loc_71C1A:
		dc.w	$5
		dc.w	$724E,$17BE,$77C0,$325E,$7C8
loc_71C26:
		dc.w	$4
		dc.w	$7264,$B7C9,$5274,$7D5
loc_71C30:
		dc.w	$4
		dc.w	$527C,$B7C9,$7282,$7D5
loc_71C3A:
		dc.w	$5
		dc.w	$328A,$528E,$B7C9,$7294,$7D5
loc_71C46:
		dc.w	$5
		dc.w	$729C,$17BE,$77C0,$32A4,$7C8
loc_71C52:
		dc.w	$5
		dc.w	$72A8,$17B2,$77B5,$52B0,$7BD
loc_71C5E:
		dc.w	$4
		dc.w	$2845,$848,$3849,$584D
loc_71C68:
		dc.w	$4
		dc.w	$1853,$B855,$2861,$1864
loc_71C72:
		dc.w	$4
		dc.w	$2866,$3869,$286D,$3870
loc_71C7C:
		dc.w	$5
		dc.w	$2874,$7877,$387F,$1883,$885
loc_71C88:
		dc.w	$4
		dc.w	$5886,$88C,$3849,$588D
loc_71C92:
		dc.w	$4
		dc.w	$1893,$B895,$2861,$8A1
loc_71C9C:
		dc.w	$4
		dc.w	$58A2,$3869,$8A8,$58A9
loc_71CA6:
		dc.w	$5
		dc.w	$2874,$78AF,$38B7,$18BB,$885
loc_71CB2:
		dc.w	$4
		dc.w	$58BD,$38C3,$38C7,$78CB
loc_71CBC:
		dc.w	$4
		dc.w	$58D3,$38D9,$38C7,$78DD
loc_71CC6:
		dc.w	$4
		dc.w	$58BD,$38C3,$38C7,$78E5
loc_71CD0:
		dc.w	$4
		dc.w	$58D3,$38D9,$38C7,$78ED
loc_71CDA:
		dc.w	$2
		dc.w	$28F5,$B8F8
loc_71CE0:
		dc.w	$3
		dc.w	$8904,$290D,$3910
loc_71CE8:
		dc.w	$3
		dc.w	$8833,$290D,$3910
loc_71CF0:
		dc.w	$3
		dc.w	$883C,$290D,$3910
loc_71CF8:
		dc.w	$3
		dc.w	$8904,$290D,$3914
loc_71D00:
		dc.w	$3
		dc.w	$8833,$290D,$3914
loc_71D08:
		dc.w	$3
		dc.w	$883C,$290D,$3914
loc_71D10:
		dc.w	$3
		dc.w	$B918,$3924,$3928
loc_71D18:
		dc.w	$3
		dc.w	$B92C,$3938,$3928
loc_71D20:
		dc.w	$3
		dc.w	$B93C,$3948,$3928
loc_71D28:
		dc.w	$5
		dc.w	$B94C,$1924,$1958,$193A,$3928
loc_71D34:
		dc.w	$4
		dc.w	$795A,$5962,$3968,$596C
loc_71D3E:
		dc.w	$4
		dc.w	$7972,$5962,$397A,$597E
loc_71D48:
		dc.w	$4
		dc.w	$7984,$5962,$598C,$5992
loc_71D52:
		dc.w	$3
		dc.w	$3998,$B99C,$39A8
loc_71D5A:
		dc.w	$3
		dc.w	$39AC,$B9B0,$39BC
loc_71D62:
		dc.w	$3
		dc.w	$39C0,$B9C4,$39BC
loc_71D6A:
		dc.w	$4
		dc.w	$79D0,$79D8,$19E0,$39E2
loc_71D74:
		dc.w	$4
		dc.w	$79E6,$79EE,$19E0,$39E2
loc_71D7E:
		dc.w	$4
		dc.w	$79F6,$79FE,$19E0,$39E2
loc_71D88:
		dc.w	$2
		dc.w	$5A06,$BA0C
;-------------------------------------------------------------------------------
Shield: 
		incbin 'artnem/shield.nem'
Invencibility_Stars: 
		incbin 'artnem/invstars.nem' 
Water_Splash_Dust_Spr: 
		IncBin 'artunc/spshdust.dat'
Water_Splash: 
		incbin 'artnem/w_splash.nem' 
;-------------------------------------------------------------------------------
Miles_Mappings: 
		dc.w	loc_73AF8-Miles_Mappings
		dc.w	loc_73AFA-Miles_Mappings
		dc.w	loc_73B0C-Miles_Mappings
		dc.w	loc_73B1E-Miles_Mappings
		dc.w	loc_73B30-Miles_Mappings
		dc.w	loc_73B42-Miles_Mappings
		dc.w	loc_73B4C-Miles_Mappings
		dc.w	loc_73B56-Miles_Mappings
		dc.w	loc_73B68-Miles_Mappings
		dc.w	loc_73B7A-Miles_Mappings
		dc.w	loc_73B84-Miles_Mappings
		dc.w	loc_73B8E-Miles_Mappings
		dc.w	loc_73B98-Miles_Mappings
		dc.w	loc_73BA2-Miles_Mappings
		dc.w	loc_73BAC-Miles_Mappings
		dc.w	loc_73BC6-Miles_Mappings
		dc.w	loc_73BE0-Miles_Mappings
		dc.w	loc_73BFA-Miles_Mappings
		dc.w	loc_73C14-Miles_Mappings
		dc.w	loc_73C2E-Miles_Mappings
		dc.w	loc_73C48-Miles_Mappings
		dc.w	loc_73C62-Miles_Mappings
		dc.w	loc_73C7C-Miles_Mappings
		dc.w	loc_73C96-Miles_Mappings
		dc.w	loc_73CB0-Miles_Mappings
		dc.w	loc_73CCA-Miles_Mappings
		dc.w	loc_73CE4-Miles_Mappings
		dc.w	loc_73CFE-Miles_Mappings
		dc.w	loc_73D18-Miles_Mappings
		dc.w	loc_73D32-Miles_Mappings
		dc.w	loc_73D4C-Miles_Mappings
		dc.w	loc_73D66-Miles_Mappings
		dc.w	loc_73D80-Miles_Mappings
		dc.w	loc_73D9A-Miles_Mappings
		dc.w	loc_73DB4-Miles_Mappings
		dc.w	loc_73DCE-Miles_Mappings
		dc.w	loc_73DE8-Miles_Mappings
		dc.w	loc_73E02-Miles_Mappings
		dc.w	loc_73E1C-Miles_Mappings
		dc.w	loc_73E2E-Miles_Mappings
		dc.w	loc_73E48-Miles_Mappings
		dc.w	loc_73E5A-Miles_Mappings
		dc.w	loc_73E74-Miles_Mappings
		dc.w	loc_73E86-Miles_Mappings
		dc.w	loc_73EA0-Miles_Mappings
		dc.w	loc_73EB2-Miles_Mappings
		dc.w	loc_73ECC-Miles_Mappings
		dc.w	loc_73EDE-Miles_Mappings
		dc.w	loc_73EF0-Miles_Mappings
		dc.w	loc_73F02-Miles_Mappings
		dc.w	loc_73F14-Miles_Mappings
		dc.w	loc_73F26-Miles_Mappings
		dc.w	loc_73F38-Miles_Mappings
		dc.w	loc_73F52-Miles_Mappings
		dc.w	loc_73F6C-Miles_Mappings
		dc.w	loc_73F86-Miles_Mappings
		dc.w	loc_73FA0-Miles_Mappings
		dc.w	loc_73FBA-Miles_Mappings
		dc.w	loc_73FD4-Miles_Mappings
		dc.w	loc_73FEE-Miles_Mappings
		dc.w	loc_74008-Miles_Mappings
		dc.w	loc_73FEE-Miles_Mappings
		dc.w	loc_74022-Miles_Mappings
		dc.w	loc_7403C-Miles_Mappings
		dc.w	loc_74056-Miles_Mappings
		dc.w	loc_74070-Miles_Mappings
		dc.w	loc_7408A-Miles_Mappings
		dc.w	loc_740A4-Miles_Mappings
		dc.w	loc_740BE-Miles_Mappings
		dc.w	loc_740D8-Miles_Mappings
		dc.w	loc_740F2-Miles_Mappings
		dc.w	loc_740FC-Miles_Mappings
		dc.w	loc_74106-Miles_Mappings
		dc.w	loc_74110-Miles_Mappings
		dc.w	loc_7411A-Miles_Mappings
		dc.w	loc_74124-Miles_Mappings
		dc.w	loc_7412E-Miles_Mappings
		dc.w	loc_74138-Miles_Mappings
		dc.w	loc_74142-Miles_Mappings
		dc.w	loc_7414C-Miles_Mappings
		dc.w	loc_74156-Miles_Mappings
		dc.w	loc_74160-Miles_Mappings
		dc.w	loc_7416A-Miles_Mappings
		dc.w	loc_74174-Miles_Mappings
		dc.w	loc_7417E-Miles_Mappings
		dc.w	loc_74188-Miles_Mappings
		dc.w	loc_74192-Miles_Mappings
		dc.w	loc_7419C-Miles_Mappings
		dc.w	loc_741A6-Miles_Mappings
		dc.w	loc_741B0-Miles_Mappings
		dc.w	loc_741C2-Miles_Mappings
		dc.w	loc_741D4-Miles_Mappings
		dc.w	loc_741DE-Miles_Mappings
		dc.w	loc_741E8-Miles_Mappings
		dc.w	loc_741F2-Miles_Mappings
		dc.w	loc_74204-Miles_Mappings
		dc.w	loc_74216-Miles_Mappings
		dc.w	loc_74220-Miles_Mappings
		dc.w	loc_7422A-Miles_Mappings
		dc.w	loc_74234-Miles_Mappings
		dc.w	loc_74246-Miles_Mappings
		dc.w	loc_74258-Miles_Mappings
		dc.w	loc_7426A-Miles_Mappings
		dc.w	loc_7427C-Miles_Mappings
		dc.w	loc_7428E-Miles_Mappings
		dc.w	loc_742A0-Miles_Mappings
		dc.w	loc_742B2-Miles_Mappings
		dc.w	loc_742C4-Miles_Mappings
		dc.w	loc_742CE-Miles_Mappings
		dc.w	loc_742E0-Miles_Mappings
		dc.w	loc_742F2-Miles_Mappings
		dc.w	loc_74304-Miles_Mappings
		dc.w	loc_74316-Miles_Mappings
		dc.w	loc_74328-Miles_Mappings
		dc.w	loc_7433A-Miles_Mappings
		dc.w	loc_7434C-Miles_Mappings
		dc.w	loc_7435E-Miles_Mappings
		dc.w	loc_74368-Miles_Mappings
		dc.w	loc_74372-Miles_Mappings
		dc.w	loc_74384-Miles_Mappings
		dc.w	loc_7438E-Miles_Mappings
		dc.w	loc_74398-Miles_Mappings
		dc.w	loc_743A2-Miles_Mappings
		dc.w	loc_743AC-Miles_Mappings
		dc.w	loc_743B6-Miles_Mappings
		dc.w	loc_743C0-Miles_Mappings
		dc.w	loc_743CA-Miles_Mappings
		dc.w	loc_743D4-Miles_Mappings
		dc.w	loc_743E6-Miles_Mappings
		dc.w	loc_743F8-Miles_Mappings
		dc.w	loc_74402-Miles_Mappings
		dc.w	loc_7440C-Miles_Mappings
		dc.w	loc_74416-Miles_Mappings
		dc.w	loc_74420-Miles_Mappings
		dc.w	loc_74432-Miles_Mappings
		dc.w	loc_74444-Miles_Mappings
		dc.w	loc_7444E-Miles_Mappings
		dc.w	loc_74458-Miles_Mappings
		dc.w	loc_74462-Miles_Mappings
loc_73AF8:
		dc.w	$0
loc_73AFA:
		dc.w	$2
		dc.l	$F0090000,$FFF4,$90006,$3FFF4
loc_73B0C:
		dc.w	$2
		dc.l	$F0090000,$FFF4,$90006,$3FFF4
loc_73B1E:
		dc.w	$2
		dc.l	$F0090000,$FFF4,$90006,$3FFF4
loc_73B30:
		dc.w	$2
		dc.l	$F0090000,$FFF4,$90006,$3FFF4
loc_73B42:
		dc.w	$1
		dc.l	$F00B0000,$FFF4
loc_73B4C:
		dc.w	$1
		dc.l	$F00B0000,$FFF4
loc_73B56:
		dc.w	$2
		dc.l	$F0090000,$FFF4,$90006,$3FFF4
loc_73B68:
		dc.w	$2
		dc.l	$F0090000,$FFF4,$90006,$3FFF4
loc_73B7A:
		dc.w	$1
		dc.l	$F0070000,$FFEC
loc_73B84:
		dc.w	$1
		dc.l	$F00B0000,$FFE4
loc_73B8E:
		dc.w	$1
		dc.l	$F00B0000,$FFE4
loc_73B98:
		dc.w	$1
		dc.l	$90000,$FFE4
loc_73BA2:
		dc.w	$1
		dc.l	$F00B0000,$FFE4
loc_73BAC:
		dc.w	$3
		dc.l	$EC090000,$FFF0,$FC0D0006,$3FFF0
		dc.l	$FC09000E,$7FFE2
loc_73BC6:
		dc.w	$3
		dc.l	$F0090000,$FFF3,$D0006,$3FFF0
		dc.l	$9000E,$7FFE4
loc_73BE0:
		dc.w	$3
		dc.l	$F0090000,$FFF8,$90006,$3FFF3
		dc.l	$FD09000C,$6FFE4
loc_73BFA:
		dc.w	$3
		dc.l	$F0090000,$FFF2,$90006,$3FFF2
		dc.l	$FD09000C,$6FFE6
loc_73C14:
		dc.w	$3
		dc.l	$EC090000,$FFF0,$FC0D0006,$3FFF0
		dc.l	$FC09000E,$7FFE2
loc_73C2E:
		dc.w	$3
		dc.l	$F0090000,$FFF3,$D0006,$3FFF0
		dc.l	$9000E,$7FFE4
loc_73C48:
		dc.w	$3
		dc.l	$F0090000,$FFF8,$90006,$3FFF1
		dc.l	$FD09000C,$6FFE4
loc_73C62:
		dc.w	$3
		dc.l	$F0090000,$FFF2,$90006,$3FFF2
		dc.l	$FD09000C,$6FFE6
loc_73C7C:
		dc.w	$3
		dc.l	$E3010000,$FFF3,$F3030002,$1FFEC
		dc.l	$F30B0006,$3FFF4
loc_73C96:
		dc.w	$3
		dc.l	$E7050000,$FFF6,$F70B0004,$2FFEE
		dc.l	$FE050010,$80006
loc_73CB0:
		dc.w	$3
		dc.l	$E6050000,$FFF8,$F6030004,$2FFEF
		dc.l	$F60B0008,$4FFF7
loc_73CCA:
		dc.w	$3
		dc.l	$E3010000,$FFF7,$F30F0002,$1FFEC
		dc.l	$FB010012,$9000C
loc_73CE4:
		dc.w	$3
		dc.l	$E3010000,$FFF3,$F3030002,$1FFEC
		dc.l	$F30B0006,$3FFF4
loc_73CFE:
		dc.w	$3
		dc.l	$E7050000,$FFF6,$F70B0004,$2FFEE
		dc.l	$FF050010,$80006
loc_73D18:
		dc.w	$3
		dc.l	$E6050000,$FFF8,$F6030004,$2FFEF
		dc.l	$F60B0008,$4FFF7
loc_73D32:
		dc.w	$3
		dc.l	$E3010000,$FFF7,$F30F0002,$1FFEC
		dc.l	$3010012,$9000C
loc_73D4C:
		dc.w	$3
		dc.l	$F0070000,$FFEC,$F0070008,$4FFFC
		dc.l	$6070010,$8FFFC
loc_73D66:
		dc.w	$3
		dc.l	$F0070000,$FFF0,$F0070008,$40000
		dc.l	$4070010,$80000
loc_73D80:
		dc.w	$3
		dc.l	$F0070000,$FFF0,$F0070008,$40000
		dc.l	$4070010,$8FFFD
loc_73D9A:
		dc.w	$3
		dc.l	$F0070000,$FFF0,$F0070008,$40000
		dc.l	$4070010,$8FFFD
loc_73DB4:
		dc.w	$3
		dc.l	$F0070000,$FFEC,$F0070008,$4FFFC
		dc.l	$6070010,$8FFFC
loc_73DCE:
		dc.w	$3
		dc.l	$F0070000,$FFF0,$F0070008,$40000
		dc.l	$4070010,$80000
loc_73DE8:
		dc.w	$3
		dc.l	$F0070000,$FFF0,$F0070008,$40000
		dc.l	$4070010,$8FFFD
loc_73E02:
		dc.w	$3
		dc.l	$F0070000,$FFF0,$F0070008,$40000
		dc.l	$4070010,$8FFFD
loc_73E1C:
		dc.w	$2
		dc.l	$4010000,$FFEB,$F40F0002,$1FFF3
loc_73E2E:
		dc.w	$3
		dc.l	$E2050000,$FFF8,$FA010004,$2FFF0
		dc.l	$F20F0006,$3FFF8
loc_73E48:
		dc.w	$2
		dc.l	$F9010000,$FFEC,$F10F0002,$1FFF4
loc_73E5A:
		dc.w	$3
		dc.l	$FC010000,$FFEF,$E5010002,$1FFFF
		dc.l	$F50F0004,$2FFF7
loc_73E74:
		dc.w	$2
		dc.l	$4010000,$FFEB,$F40F0002,$1FFF3
loc_73E86:
		dc.w	$3
		dc.l	$E2010000,$0,$FA010002,$1FFF0
		dc.l	$F20F0004,$2FFF8
loc_73EA0:
		dc.w	$2
		dc.l	$F9010000,$FFEC,$F10F0002,$1FFF4
loc_73EB2:
		dc.w	$3
		dc.l	$E4010000,$FFFF,$FC010002,$1FFEF
		dc.l	$F40F0004,$2FFF7
loc_73ECC:
		dc.w	$2
		dc.l	$F00F0000,$FFF0,$F0070010,$8FFEA
loc_73EDE:
		dc.w	$2
		dc.l	$F00F0000,$FFF0,$F8050010,$8FFEA
loc_73EF0:
		dc.w	$2
		dc.l	$F00F0000,$FFF0,$F8050010,$8FFEA
loc_73F02:
		dc.w	$2
		dc.l	$F00F0000,$FFF0,$F8051010,$1008FFEA
loc_73F14:
		dc.w	$2
		dc.l	$F00F0000,$FFF0,$F0070010,$8FFEA
loc_73F26:
		dc.w	$2
		dc.l	$F00F0000,$FFF0,$F0071810,$1808FFE8
loc_73F38:
		dc.w	$3
		dc.l	$E4010000,$FFFA,$F40B0002,$1FFF0
		dc.l	$FE0B000E,$7FFE8
loc_73F52:
		dc.w	$3
		dc.l	$E4050000,$FFF8,$F40B0004,$2FFF0
		dc.l	$4050010,$8FFEF
loc_73F6C:
		dc.w	$3
		dc.l	$E4010000,$FFFA,$F40B0002,$1FFF0
		dc.l	$405000E,$7FFEF
loc_73F86:
		dc.w	$3
		dc.l	$E4050000,$FFF8,$F40B0004,$2FFF0
		dc.l	$4050010,$8FFEF
loc_73FA0:
		dc.w	$3
		dc.l	$E4010000,$FFFA,$F40B0002,$1FFF0
		dc.l	$FC0B000E,$7FFEA
loc_73FBA:
		dc.w	$3
		dc.l	$E4050000,$FFF8,$F40B0004,$2FFF0
		dc.l	$F70B1810,$1808FFEA
loc_73FD4:
		dc.w	$3
		dc.l	$F0090000,$FFF0,$D0006,$3FFF0
		dc.l	$60D000E,$7FFF0
loc_73FEE:
		dc.w	$3
		dc.l	$F0090000,$FFF0,$D0006,$3FFF0
		dc.l	$605000E,$7FFF8
loc_74008:
		dc.w	$3
		dc.l	$F0090000,$FFF0,$D0006,$3FFF0
		dc.l	$605000E,$7FFF8
loc_74022:
		dc.w	$3
		dc.l	$F0090000,$FFF0,$D0006,$3FFF0
		dc.l	$60D000E,$7FFF0
loc_7403C:
		dc.w	$3
		dc.l	$F0090000,$FFF0,$D0006,$3FFF0
		dc.l	$80D180E,$1807FFF0
loc_74056:
		dc.w	$3
		dc.l	$F80B0000,$FFEC,$F805000C,$60004
		dc.l	$FE0B0810,$8080000
loc_74070:
		dc.w	$3
		dc.l	$F80B0000,$FFEC,$F805000C,$60004
		dc.l	$1050810,$8080004
loc_7408A:
		dc.w	$3
		dc.l	$F80B0000,$FFEC,$F805000C,$60004
		dc.l	$1050810,$8080004
loc_740A4:
		dc.w	$3
		dc.l	$F80B0000,$FFEC,$F805000C,$60004
		dc.l	$1050810,$8080004
loc_740BE:
		dc.w	$3
		dc.l	$F80B0000,$FFEC,$F805000C,$60004
		dc.l	$FC0B0810,$808FFFE
loc_740D8:
		dc.w	$3
		dc.l	$F80B0000,$FFEC,$F805000C,$60004
		dc.l	$F70B1010,$1008FFFF
loc_740F2:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_740FC:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_74106:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_74110:
		dc.w	$1
		dc.l	$F8090000,$FFDC
loc_7411A:
		dc.w	$1
		dc.l	$F8090000,$FFDC
loc_74124:
		dc.w	$1
		dc.l	$F8090000,$FFDC
loc_7412E:
		dc.w	$1
		dc.l	$F8090000,$FFDC
loc_74138:
		dc.w	$1
		dc.l	$7090000,$FFE1
loc_74142:
		dc.w	$1
		dc.l	$7090000,$FFE1
loc_7414C:
		dc.w	$1
		dc.l	$7090000,$FFE1
loc_74156:
		dc.w	$1
		dc.l	$7090000,$FFE1
loc_74160:
		dc.w	$1
		dc.l	$C070000,$FFF8
loc_7416A:
		dc.w	$1
		dc.l	$C070000,$FFF8
loc_74174:
		dc.w	$1
		dc.l	$C070000,$FFF8
loc_7417E:
		dc.w	$1
		dc.l	$C070000,$FFF8
loc_74188:
		dc.w	$1
		dc.l	$7070000,$7
loc_74192:
		dc.w	$1
		dc.l	$7070000,$7
loc_7419C:
		dc.w	$1
		dc.l	$7070000,$7
loc_741A6:
		dc.w	$1
		dc.l	$7070000,$7
loc_741B0:
		dc.w	$2
		dc.l	$E8050000,$FFF8,$F80B0004,$2FFF0
loc_741C2:
		dc.w	$2
		dc.l	$E8050000,$FFF8,$F80B0004,$2FFF0
loc_741D4:
		dc.w	$1
		dc.l	$F00B0000,$FFF9
loc_741DE:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_741E8:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_741F2:
		dc.w	$2
		dc.l	$F00F0000,$FFF0,$E40D0010,$8FFEA
loc_74204:
		dc.w	$2
		dc.l	$F00F0000,$FFF0,$E40D0810,$808FFEA
loc_74216:
		dc.w	$1
		dc.l	$F40F0000,$FFF0
loc_74220:
		dc.w	$1
		dc.l	$F40F0000,$FFF0
loc_7422A:
		dc.w	$1
		dc.l	$F40F0000,$FFF0
loc_74234:
		dc.w	$2
		dc.l	$F0090000,$FFF8,$D0006,$3FFF0
loc_74246:
		dc.w	$2
		dc.l	$F0090000,$FFF8,$90006,$3FFF8
loc_74258:
		dc.w	$2
		dc.l	$F0090000,$FFF8,$90006,$3FFF8
loc_7426A:
		dc.w	$2
		dc.l	$F0090000,$FFF8,$90006,$3FFF8
loc_7427C:
		dc.w	$2
		dc.l	$F0090000,$FFF0,$D0006,$3FFF0
loc_7428E:
		dc.w	$2
		dc.l	$F0090000,$FFF0,$D0006,$3FFF0
loc_742A0:
		dc.w	$2
		dc.l	$F8010000,$FFE8,$F00B0002,$1FFF0
loc_742B2:
		dc.w	$2
		dc.l	$F0090000,$FFF0,$D0006,$3FFE8
loc_742C4:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_742CE:
		dc.w	$2
		dc.l	$F00F0000,$FFEC,$F0030010,$8000C
loc_742E0:
		dc.w	$2
		dc.l	$F00F0000,$FFEC,$F0030010,$8000C
loc_742F2:
		dc.w	$2
		dc.l	$F8050000,$FFEC,$F00B0004,$2FFFC
loc_74304:
		dc.w	$2
		dc.l	$F0070000,$FFF0,$F0070800,$8000000
loc_74316:
		dc.w	$2
		dc.l	$F8050800,$8000004,$F00B0804,$802FFEC
loc_74328:
		dc.w	$2
		dc.l	$F0070000,$FFF0,$F8050008,$40000
loc_7433A:
		dc.w	$2
		dc.l	$F0070800,$8000000,$F8050808,$804FFF0
loc_7434C:
		dc.w	$2
		dc.l	$F8050000,$FFEC,$F00B0004,$2FFFC
loc_7435E:
		dc.w	$1
		dc.l	$F00F0000,$FFF0
loc_74368:
		dc.w	$1
		dc.l	$F00B0000,$FFF1
loc_74372:
		dc.w	$2
		dc.l	$E4050000,$FFF8,$F40B0004,$2FFF1
loc_74384:
		dc.w	$1
		dc.l	$F20B0000,$FFF2
loc_7438E:
		dc.w	$1
		dc.l	$F40B0000,$FFF0
loc_74398:
		dc.w	$1
		dc.l	$F30B0000,$FFF2
loc_743A2:
		dc.w	$1
		dc.l	$F20B0000,$FFF2
loc_743AC:
		dc.w	$1
		dc.l	$F20B0000,$FFF2
loc_743B6:
		dc.w	$1
		dc.l	$F00B0000,$FFF1
loc_743C0:
		dc.w	$1
		dc.l	$ED0B0000,$FFF0
loc_743CA:
		dc.w	$1
		dc.l	$EC0B0000,$FFF1
loc_743D4:
		dc.w	$2
		dc.l	$F4090000,$FFF3,$4050006,$3FFF3
loc_743E6:
		dc.w	$2
		dc.l	$F2070000,$FFF0,$EC030008,$40000
loc_743F8:
		dc.w	$1
		dc.l	$F8090000,$FFE0
loc_74402:
		dc.w	$1
		dc.l	$F8090000,$FFE0
loc_7440C:
		dc.w	$1
		dc.l	$F8090000,$FFE0
loc_74416:
		dc.w	$1
		dc.l	$F8090000,$FFE0
loc_74420:
		dc.w	$2
		dc.l	$E8090000,$FFF4,$F80D0006,$3FFF4
loc_74432:
		dc.w	$2
		dc.l	$E8090000,$FFF4,$F80D0006,$3FFF4
loc_74444:
		dc.w	$1
		dc.l	$FD090000,$FFE3
loc_7444E:
		dc.w	$1
		dc.l	$FD090000,$FFE3
loc_74458:
		dc.w	$1
		dc.l	$FD090000,$FFE3
loc_74462:
		dc.w	$1
		dc.l	$FD090000,$FFE3 
;------------------------------------------------------------------------------- 
Miles_Dyn_Script: 
		dc.w	loc_74582-Miles_Dyn_Script
		dc.w	loc_74584-Miles_Dyn_Script
		dc.w	loc_7458A-Miles_Dyn_Script
		dc.w	loc_74590-Miles_Dyn_Script
		dc.w	loc_74596-Miles_Dyn_Script
		dc.w	loc_7459C-Miles_Dyn_Script
		dc.w	loc_745A0-Miles_Dyn_Script
		dc.w	loc_745A4-Miles_Dyn_Script
		dc.w	loc_745AA-Miles_Dyn_Script
		dc.w	loc_745B0-Miles_Dyn_Script
		dc.w	loc_745B4-Miles_Dyn_Script
		dc.w	loc_745B8-Miles_Dyn_Script
		dc.w	loc_745BC-Miles_Dyn_Script
		dc.w	loc_745C0-Miles_Dyn_Script
		dc.w	loc_745C4-Miles_Dyn_Script
		dc.w	loc_745CC-Miles_Dyn_Script
		dc.w	loc_745D4-Miles_Dyn_Script
		dc.w	loc_745DC-Miles_Dyn_Script
		dc.w	loc_745E4-Miles_Dyn_Script
		dc.w	loc_745EC-Miles_Dyn_Script
		dc.w	loc_745F4-Miles_Dyn_Script
		dc.w	loc_745FC-Miles_Dyn_Script
		dc.w	loc_74604-Miles_Dyn_Script
		dc.w	loc_7460C-Miles_Dyn_Script
		dc.w	loc_74614-Miles_Dyn_Script
		dc.w	loc_7461C-Miles_Dyn_Script
		dc.w	loc_74624-Miles_Dyn_Script
		dc.w	loc_7462C-Miles_Dyn_Script
		dc.w	loc_74634-Miles_Dyn_Script
		dc.w	loc_7463C-Miles_Dyn_Script
		dc.w	loc_74644-Miles_Dyn_Script
		dc.w	loc_7464C-Miles_Dyn_Script
		dc.w	loc_74654-Miles_Dyn_Script
		dc.w	loc_7465C-Miles_Dyn_Script
		dc.w	loc_74664-Miles_Dyn_Script
		dc.w	loc_7466C-Miles_Dyn_Script
		dc.w	loc_74674-Miles_Dyn_Script
		dc.w	loc_7467C-Miles_Dyn_Script
		dc.w	loc_74684-Miles_Dyn_Script
		dc.w	loc_7468A-Miles_Dyn_Script
		dc.w	loc_74692-Miles_Dyn_Script
		dc.w	loc_74698-Miles_Dyn_Script
		dc.w	loc_746A0-Miles_Dyn_Script
		dc.w	loc_746A6-Miles_Dyn_Script
		dc.w	loc_746AE-Miles_Dyn_Script
		dc.w	loc_746B4-Miles_Dyn_Script
		dc.w	loc_746BC-Miles_Dyn_Script
		dc.w	loc_746C2-Miles_Dyn_Script
		dc.w	loc_746C8-Miles_Dyn_Script
		dc.w	loc_746C2-Miles_Dyn_Script
		dc.w	loc_746CE-Miles_Dyn_Script
		dc.w	loc_746D4-Miles_Dyn_Script
		dc.w	loc_746DA-Miles_Dyn_Script
		dc.w	loc_746E2-Miles_Dyn_Script
		dc.w	loc_746EA-Miles_Dyn_Script
		dc.w	loc_746F2-Miles_Dyn_Script
		dc.w	loc_746FA-Miles_Dyn_Script
		dc.w	loc_74702-Miles_Dyn_Script
		dc.w	loc_7470A-Miles_Dyn_Script
		dc.w	loc_74712-Miles_Dyn_Script
		dc.w	loc_7471A-Miles_Dyn_Script
		dc.w	loc_74712-Miles_Dyn_Script
		dc.w	loc_74722-Miles_Dyn_Script
		dc.w	loc_7472A-Miles_Dyn_Script
		dc.w	loc_74732-Miles_Dyn_Script
		dc.w	loc_7473A-Miles_Dyn_Script
		dc.w	loc_74742-Miles_Dyn_Script
		dc.w	loc_7474A-Miles_Dyn_Script
		dc.w	loc_74752-Miles_Dyn_Script
		dc.w	loc_7475A-Miles_Dyn_Script
		dc.w	loc_74762-Miles_Dyn_Script
		dc.w	loc_74766-Miles_Dyn_Script
		dc.w	loc_7476A-Miles_Dyn_Script
		dc.w	loc_7476E-Miles_Dyn_Script
		dc.w	loc_74772-Miles_Dyn_Script
		dc.w	loc_74776-Miles_Dyn_Script
		dc.w	loc_7477A-Miles_Dyn_Script
		dc.w	loc_7477E-Miles_Dyn_Script
		dc.w	loc_74782-Miles_Dyn_Script
		dc.w	loc_74786-Miles_Dyn_Script
		dc.w	loc_7478A-Miles_Dyn_Script
		dc.w	loc_7478E-Miles_Dyn_Script
		dc.w	loc_74792-Miles_Dyn_Script
		dc.w	loc_74796-Miles_Dyn_Script
		dc.w	loc_7479A-Miles_Dyn_Script
		dc.w	loc_7479E-Miles_Dyn_Script
		dc.w	loc_747A2-Miles_Dyn_Script
		dc.w	loc_747A6-Miles_Dyn_Script
		dc.w	loc_747AA-Miles_Dyn_Script
		dc.w	loc_747AE-Miles_Dyn_Script
		dc.w	loc_747B4-Miles_Dyn_Script
		dc.w	loc_747BA-Miles_Dyn_Script
		dc.w	loc_747BE-Miles_Dyn_Script
		dc.w	loc_747C2-Miles_Dyn_Script
		dc.w	loc_747C6-Miles_Dyn_Script
		dc.w	loc_747C6-Miles_Dyn_Script
		dc.w	loc_747CC-Miles_Dyn_Script
		dc.w	loc_747D0-Miles_Dyn_Script
		dc.w	loc_747D4-Miles_Dyn_Script
		dc.w	loc_747D8-Miles_Dyn_Script
		dc.w	loc_747DE-Miles_Dyn_Script
		dc.w	loc_747E4-Miles_Dyn_Script
		dc.w	loc_747EA-Miles_Dyn_Script
		dc.w	loc_747F0-Miles_Dyn_Script
		dc.w	loc_747F6-Miles_Dyn_Script
		dc.w	loc_747FC-Miles_Dyn_Script
		dc.w	loc_74802-Miles_Dyn_Script
		dc.w	loc_74808-Miles_Dyn_Script
		dc.w	loc_7480C-Miles_Dyn_Script
		dc.w	loc_74812-Miles_Dyn_Script
		dc.w	loc_74818-Miles_Dyn_Script
		dc.w	loc_7481E-Miles_Dyn_Script
		dc.w	loc_74818-Miles_Dyn_Script
		dc.w	loc_74824-Miles_Dyn_Script
		dc.w	loc_74824-Miles_Dyn_Script
		dc.w	loc_7482A-Miles_Dyn_Script
		dc.w	loc_74830-Miles_Dyn_Script
		dc.w	loc_74834-Miles_Dyn_Script
		dc.w	loc_74838-Miles_Dyn_Script
		dc.w	loc_7483E-Miles_Dyn_Script
		dc.w	loc_74842-Miles_Dyn_Script
		dc.w	loc_74846-Miles_Dyn_Script
		dc.w	loc_7484A-Miles_Dyn_Script
		dc.w	loc_7484E-Miles_Dyn_Script
		dc.w	loc_74852-Miles_Dyn_Script
		dc.w	loc_74856-Miles_Dyn_Script
		dc.w	loc_7485A-Miles_Dyn_Script
		dc.w	loc_7485E-Miles_Dyn_Script
		dc.w	loc_74864-Miles_Dyn_Script
		dc.w	loc_7476E-Miles_Dyn_Script
		dc.w	loc_74772-Miles_Dyn_Script
		dc.w	loc_74776-Miles_Dyn_Script
		dc.w	loc_7477A-Miles_Dyn_Script
		dc.w	loc_7486A-Miles_Dyn_Script
		dc.w	loc_74870-Miles_Dyn_Script
		dc.w	loc_7476E-Miles_Dyn_Script
		dc.w	loc_74772-Miles_Dyn_Script
		dc.w	loc_74776-Miles_Dyn_Script
		dc.w	loc_7477A-Miles_Dyn_Script
loc_74582:
		dc.w	$0
loc_74584:
		dc.w	$2
		dc.w	$5000,$5006
loc_7458A:
		dc.w	$2
		dc.w	$500C,$5006
loc_74590:
		dc.w	$2
		dc.w	$5012,$5006
loc_74596:
		dc.w	$2
		dc.w	$5018,$5006
loc_7459C:
		dc.w	$1
		dc.w	$B01E
loc_745A0:
		dc.w	$1
		dc.w	$B02A
loc_745A4:
		dc.w	$2
		dc.w	$5036,$503C
loc_745AA:
		dc.w	$2
		dc.w	$5036,$5042
loc_745B0:
		dc.w	$1
		dc.w	$7048
loc_745B4:
		dc.w	$1
		dc.w	$B050
loc_745B8:
		dc.w	$1
		dc.w	$B05C
loc_745BC:
		dc.w	$1
		dc.w	$5068
loc_745C0:
		dc.w	$1
		dc.w	$B06E
loc_745C4:
		dc.w	$3
		dc.w	$507A,$7080,$50CA
loc_745CC:
		dc.w	$3
		dc.w	$5088,$708E,$50D0
loc_745D4:
		dc.w	$3
		dc.w	$5096,$509C,$50D6
loc_745DC:
		dc.w	$3
		dc.w	$50A2,$50A8,$50DC
loc_745E4:
		dc.w	$3
		dc.w	$507A,$70AE,$50CA
loc_745EC:
		dc.w	$3
		dc.w	$5088,$70B6,$50D0
loc_745F4:
		dc.w	$3
		dc.w	$5096,$50BE,$50D6
loc_745FC:
		dc.w	$3
		dc.w	$50A2,$50C4,$50DC
loc_74604:
		dc.w	$3
		dc.w	$10E2,$30E4,$B0E8
loc_7460C:
		dc.w	$3
		dc.w	$30F4,$B0F8,$3104
loc_74614:
		dc.w	$3
		dc.w	$3108,$310C,$B110
loc_7461C:
		dc.w	$3
		dc.w	$111C,$F11E,$112E
loc_74624:
		dc.w	$3
		dc.w	$10E2,$30E4,$B130
loc_7462C:
		dc.w	$3
		dc.w	$30F4,$B13C,$3148
loc_74634:
		dc.w	$3
		dc.w	$3108,$310C,$B14C
loc_7463C:
		dc.w	$3
		dc.w	$111C,$F158,$1168
loc_74644:
		dc.w	$3
		dc.w	$716A,$7172,$71CA
loc_7464C:
		dc.w	$3
		dc.w	$717A,$7182,$71D2
loc_74654:
		dc.w	$3
		dc.w	$718A,$7192,$71DA
loc_7465C:
		dc.w	$3
		dc.w	$719A,$71A2,$75BE
loc_74664:
		dc.w	$3
		dc.w	$716A,$71AA,$71CA
loc_7466C:
		dc.w	$3
		dc.w	$717A,$71B2,$71D2
loc_74674:
		dc.w	$3
		dc.w	$718A,$71BA,$71DA
loc_7467C:
		dc.w	$3
		dc.w	$719A,$71C2,$75BE
loc_74684:
		dc.w	$2
		dc.w	$11EA,$F1EC
loc_7468A:
		dc.w	$3
		dc.w	$31FC,$1200,$F202
loc_74692:
		dc.w	$2
		dc.w	$1212,$F214
loc_74698:
		dc.w	$3
		dc.w	$1224,$1226,$F228
loc_746A0:
		dc.w	$2
		dc.w	$11EA,$F238
loc_746A6:
		dc.w	$3
		dc.w	$1248,$1200,$F24A
loc_746AE:
		dc.w	$2
		dc.w	$1212,$F25A
loc_746B4:
		dc.w	$3
		dc.w	$126A,$1224,$F26C
loc_746BC:
		dc.w	$2
		dc.w	$F27C,$729C
loc_746C2:
		dc.w	$2
		dc.w	$F28C,$32A4
loc_746C8:
		dc.w	$2
		dc.w	$F27C,$32A8
loc_746CE:
		dc.w	$2
		dc.w	$F27C,$72AC
loc_746D4:
		dc.w	$2
		dc.w	$F28C,$72AC
loc_746DA:
		dc.w	$3
		dc.w	$12B4,$B2B6,$B2D2
loc_746E2:
		dc.w	$3
		dc.w	$32C2,$B2C6,$32DE
loc_746EA:
		dc.w	$3
		dc.w	$12B4,$B2B6,$32E2
loc_746F2:
		dc.w	$3
		dc.w	$32C2,$B2C6,$32E6
loc_746FA:
		dc.w	$3
		dc.w	$12B4,$B2B6,$B2EA
loc_74702:
		dc.w	$3
		dc.w	$32C2,$B2C6,$B2EA
loc_7470A:
		dc.w	$3
		dc.w	$52F6,$72FC,$7312
loc_74712:
		dc.w	$3
		dc.w	$5304,$730A,$331E
loc_7471A:
		dc.w	$3
		dc.w	$52F6,$72FC,$331A
loc_74722:
		dc.w	$3
		dc.w	$52F6,$72FC,$7322
loc_7472A:
		dc.w	$3
		dc.w	$5304,$730A,$7322
loc_74732:
		dc.w	$3
		dc.w	$B32A,$3336,$B2D2
loc_7473A:
		dc.w	$3
		dc.w	$B33A,$3346,$32DE
loc_74742:
		dc.w	$3
		dc.w	$B32A,$3336,$32E2
loc_7474A:
		dc.w	$3
		dc.w	$B33A,$3346,$32E6
loc_74752:
		dc.w	$3
		dc.w	$B32A,$3336,$B2EA
loc_7475A:
		dc.w	$3
		dc.w	$B33A,$3346,$B2EA
loc_74762:
		dc.w	$1
		dc.w	$F34A
loc_74766:
		dc.w	$1
		dc.w	$F35A
loc_7476A:
		dc.w	$1
		dc.w	$F36A
loc_7476E:
		dc.w	$1
		dc.w	$50CA
loc_74772:
		dc.w	$1
		dc.w	$50D0
loc_74776:
		dc.w	$1
		dc.w	$50D6
loc_7477A:
		dc.w	$1
		dc.w	$50DC
loc_7477E:
		dc.w	$1
		dc.w	$537A
loc_74782:
		dc.w	$1
		dc.w	$5380
loc_74786:
		dc.w	$1
		dc.w	$5386
loc_7478A:
		dc.w	$1
		dc.w	$538C
loc_7478E:
		dc.w	$1
		dc.w	$71CA
loc_74792:
		dc.w	$1
		dc.w	$71D2
loc_74796:
		dc.w	$1
		dc.w	$71DA
loc_7479A:
		dc.w	$1
		dc.w	$75BE
loc_7479E:
		dc.w	$1
		dc.w	$7392
loc_747A2:
		dc.w	$1
		dc.w	$739A
loc_747A6:
		dc.w	$1
		dc.w	$73A2
loc_747AA:
		dc.w	$1
		dc.w	$73AA
loc_747AE:
		dc.w	$2
		dc.w	$33B2,$B3B6
loc_747B4:
		dc.w	$2
		dc.w	$33B2,$B3C2
loc_747BA:
		dc.w	$1
		dc.w	$B3CE
loc_747BE:
		dc.w	$1
		dc.w	$F3DA
loc_747C2:
		dc.w	$1
		dc.w	$F3EA
loc_747C6:
		dc.w	$2
		dc.w	$F3FA,$740A
loc_747CC:
		dc.w	$1
		dc.w	$F412
loc_747D0:
		dc.w	$1
		dc.w	$F422
loc_747D4:
		dc.w	$1
		dc.w	$F432
loc_747D8:
		dc.w	$2
		dc.w	$5442,$7448
loc_747DE:
		dc.w	$2
		dc.w	$5442,$5450
loc_747E4:
		dc.w	$2
		dc.w	$5442,$5456
loc_747EA:
		dc.w	$2
		dc.w	$5442,$545C
loc_747F0:
		dc.w	$2
		dc.w	$5462,$7468
loc_747F6:
		dc.w	$2
		dc.w	$5470,$7476
loc_747FC:
		dc.w	$2
		dc.w	$147E,$B480
loc_74802:
		dc.w	$2
		dc.w	$548C,$7492
loc_74808:
		dc.w	$1
		dc.w	$F49A
loc_7480C:
		dc.w	$2
		dc.w	$F4AA,$34BA
loc_74812:
		dc.w	$2
		dc.w	$F4BE,$34CE
loc_74818:
		dc.w	$2
		dc.w	$34D2,$B4D6
loc_7481E:
		dc.w	$2
		dc.w	$74E2,$74E2
loc_74824:
		dc.w	$2
		dc.w	$74EA,$34F2
loc_7482A:
		dc.w	$2
		dc.w	$34F6,$B4FA
loc_74830:
		dc.w	$1
		dc.w	$F506
loc_74834:
		dc.w	$1
		dc.w	$B516
loc_74838:
		dc.w	$2
		dc.w	$3522,$B526
loc_7483E:
		dc.w	$1
		dc.w	$B532
loc_74842:
		dc.w	$1
		dc.w	$B53E
loc_74846:
		dc.w	$1
		dc.w	$B54A
loc_7484A:
		dc.w	$1
		dc.w	$B556
loc_7484E:
		dc.w	$1
		dc.w	$B562
loc_74852:
		dc.w	$1
		dc.w	$B56E
loc_74856:
		dc.w	$1
		dc.w	$B57A
loc_7485A:
		dc.w	$1
		dc.w	$B586
loc_7485E:
		dc.w	$2
		dc.w	$5592,$3598
loc_74864:
		dc.w	$2
		dc.w	$759C,$35A4
loc_7486A:
		dc.w	$2
		dc.w	$55A8,$75AE
loc_74870:
		dc.w	$2
		dc.w	$55A8,$75B6
;------------------------------------------------------------------------------- 
Sega_Spr: 
		incbin 'artnem/sega.nem'
Sega_Blocks_Spr: 
		incbin 'artnem/sega_blk.nem'
Sega_Mappings: 
		incbin 'mapeni/sega.eni'
TS_Wings_Sonic_Mappings: 
		incbin 'mapeni/titlescr.eni'
Title_Screen_Bg_Mappings: 
		incbin 'mapeni/titscrbg.eni'
Title_Screen_R_Bg_Mappings: 
		incbin 'mapeni/titscrb2.eni'
Title_Screen_Bg_Wings: 
		incbin 'artnem/titlescr.nem' ; Title Screen Wings and background
Title_Screen_Sonic_Miles: 
		incbin 'artnem/sncmlscr.nem' ; Sonic And Miles in Title Screen
FireBall: 
		incbin 'artnem/fireball.nem'
GHz_Waterfall: 
		incbin 'artnem/ghzwatrfall.nem'
Htz_Lava_Bubble:
		incbin 'artnem/htzlvbubble.nem'
GHz_Bridge: 
		incbin 'artnem/ghzbridge.nem'
Htz_Teleferic: 
		incbin 'artnem/telefrcs.nem'
Htz_Automatic_Door: 
		incbin 'artnem/htzautodoor.nem'
Htz_See_saw: 
		incbin 'artnem/see-saw.nem'
Unk_Fireball: 
		incbin 'artnem/unk_fball.nem'
Htz_Rock: 
		incbin 'artnem/rock.nem'
Htz_See_saw_badnick: 
		incbin 'artnem/see-sawb.nem'
Mz_Rotating_Gear: 
		incbin 'artnem/gear.nem'
Mz_Gear_Holes: 
		incbin 'artnem/gearhole.nem'
Mz_Harpon_Platform: 
		incbin 'artnem/harp_ptf.nem'
Mz_Steam: 
		incbin 'artnem/steam.nem'
Mz_Harpon: 
		incbin 'artnem/harpoon.nem'
Mz_Screw_Nut: 
		incbin 'artnem/screwnut.nem'
Mz_Lava_Bubble: 
		incbin 'artnem/mzlvbubble.nem'
Mz_Elevator: 
		incbin 'artnem/mzelevator.nem'
Mz_Miscellaneous:
		incbin 'artnem/miscelns.nem'
Mz_Mini_Gear: 
		incbin 'artnem/minigear.nem'
Mz_Teleport_Flash: 
		incbin 'artnem/tlpflash.nem'
Boss_Switch_Spr: 
		incbin 'artnem/b_switch.nem'
Breakable_Wall: 
		incbin 'artnem/brk_wall.nem'
Hpz_Bridge: 
		incbin 'artnem/hpzbridge.nem'
Hpz_Waterfall: 
		incbin 'artnem/hpzwatrfall.nem'
Hpz_Emerald: 
		incbin 'artnem/hpzemerald.nem'
Hpz_Platform: 
		incbin 'artnem/hpzplatform.nem'
Hpz_Orbs_Comp:
		incbin 'artnem/orbs.nem'
Hpz_Unknow_Platform: 
		incbin 'artnem/unkptfm.nem'
OOz_Giant_Spikeball: 
		incbin 'artnem/gspkball.nem'
OOz_Touch_Boost_Up: 
		incbin 'artnem/boost_up.nem'
OOz_Break_To_Boost_Horizontal: 
		incbin 'artnem/brkbst_h.nem'
OOz_Oil: 
		incbin 'artnem/oil.nem'
OOz_Oil_01: 
		incbin 'artnem/oil_01.nem'
OOz_Ball: 
		incbin 'artnem/ball.nem'
OOz_Cannon: 
		incbin 'artnem/oozcannon.nem'
OOz_Collapsing_Platform: 
		incbin 'artnem/oozplatform.nem'
OOz_Spring_Push_Boost: 
		incbin 'artnem/spngpush.nem'
OOz_Swing_Platform: 
		incbin 'artnem/swngptfm.nem'
OOz_Break_To_Boost_Vertical: 
		incbin 'artnem/brkbst_v.nem'
OOz_Elevator: 
		incbin 'artnem/oozelevator.nem'
OOz_Fans: 
		incbin 'artnem/fans.nem'
OOz_Fire_Booster: 
		incbin 'artnem/fire_bst.nem'
Dhz_Box: 
		incbin 'artnem/dhzbox.nem'
Dhz_Collapsing_Platform: 
		incbin 'artnem/clp_ptfm.nem'
Dhz_Vines: 
		incbin 'artnem/vines.nem'
Dhz_Vines_1: 
		incbin 'artnem/vines_1.nem'
Dhz_Bridge: 
		incbin 'artnem/dhzbridge.nem'
CNz_Green_Platforms: 
		incbin 'artnem/greenptf.nem'
CNz_Spikeball_Slot_Machine: 
		incbin 'artnem/spikball.nem'
CNz_Box: 
		incbin 'artnem/cnzbox.nem'
CNz_Elevator: 
		incbin 'artnem/cnzelevator.nem'
CNz_Slot_Machine_Starter:
		incbin 'artnem/slotmach.nem'
CNz_Blue_Bumper: 
		incbin 'artnem/bbumpers.nem'
CNz_Bumpers:
		incbin 'artnem/bumpers.nem'
CNz_Diagonal_Launcher: 
		incbin 'artnem/d_launch.nem'
CNz_Vertical_Launcher: 
		incbin 'artnem/v_launch.nem'
CNz_Green_Bumpers: 
		incbin 'artnem/gbumpers.nem'
CNz_Flippers: 
		incbin 'artnem/flippers.nem'
CPz_Triangle_Platform: 
		incbin 'artnem/tri_ptfm.nem'
Water_Surface: 
		incbin 'artnem/watrsurf.nem'
CPz_Speed_Booster: 
		incbin 'artnem/speedbst.nem'
CPz_Worms: 
		incbin 'artnem/worms.nem'
CPz_Metal_Structure: 
		incbin 'artnem/metal_st.nem'
CPz_Breakable_Block: 
		incbin 'artnem/brkblock.nem'
CPz_Automatic_Door: 
		incbin 'artnem/cpzautodoor.nem'
CPz_Open_Close_Platform: 
		incbin 'artnem/oc_ptfrm.nem'
CPz_Platforms: 
		incbin 'artnem/cpzplatform.nem'
CPz_Spring_Tubes: 
		incbin 'artnem/spgtubes.nem'
NGHz_Water_Surface: 
		incbin 'artnem/nghzwatrsurf.nem'
NGHz_Leaves: 
		incbin 'artnem/leaves.nem'
NGHz_Arrow_Shooter:
		incbin 'artnem/arrow_s.nem'
NGHz_Automatic_Door: 
		incbin 'artnem/nghzautodoor.nem'
Switch: 
		incbin 'artnem/switch.nem' 
Vertical_Spring:
		incbin 'artnem/v_spring.nem' 
Horizontal_Spring: 
		incbin 'artnem/h_spring.nem' 
Diagonal_Spring: 
		incbin 'artnem/d_spring.nem' 
Head_up_display_Sprites: 
		incbin 'artnem/hud.nem'
Head_up_display_Sonic: 
		incbin 'artnem/hudsonic.nem' 
Rings_Sprites: 
		incbin 'artnem/rings.nem'
Monitors: 
		incbin 'artnem/monitors.nem'
Spikes: 
		incbin 'artnem/spikes.nem' 
Enemy_Points_Spr: 
		incbin 'artnem/points.nem' 
Star_Post: 
		incbin 'artnem/starpost.nem'
End_Panel: 
		incbin 'artnem/endpanel.nem' 
End_Panel_Spr: 
		incbin 'artunc/endpanel.dat'
Diagonal_Spring_1: 
		incbin 'artnem/dspring1.nem' 
Dhz_Horizontal_Spikes: 
		incbin 'data/dhz/h_spikes.nem'
Oxygen_Bubbles: 
		incbin 'artnem/oxygen.nem' 
Bubbles: 
		incbin 'artnem/bubbles.nem' 
Oxygen_Numbers_Spr: 
		incbin 'artunc/oxygnumb.dat'
Game_Time_Over: 
		incbin 'artnem/gt_over.nem' 
Explosion: 
		incbin 'artnem/explosn.nem'
Head_up_display_Miles: 
		incbin 'artnem/hudmiles.nem' 
Egg_Prison: 
		incbin 'artnem/eggprisn.nem'
Miles_In_Continue: 
		incbin 'artnem/milescnt.nem'
Mini_Sonic: 
		incbin 'artnem/m_sonic.nem' 
Menu_Font: 
		incbin 'artnem/menufont.nem' 
Versus_Result_Font: 
		incbin 'artnem/vsresfnt.nem' 
Versus_Menu_Bg_Mappings: 
		incbin 'mapeni/vsmenubg.eni'
Sonic_Miles: 
		incbin 'artunc/soncmils.dat'
Title_Card_ZONE_123: 
		incbin 'artnem/tc_zone.nem' 
Title_Card_AY: 
		incbin 'artnem/tc_ay.nem' 
Menu_Frame: 
		incbin 'artnem/menu_frm.nem' 
Level_Icons: 
		incbin 'artnem/levelico.nem' 
Title_Card_Results: 
		incbin 'artnem/tc_res.nem'
SS_Title_Card_Results: 
		incbin 'specialstage/tc_res.nem'
SS_Emeralds_Results: 
		incbin 'specialstage/emeralds.nem'
Blue_Bird: 
		incbin 'artnem/bluebird.nem' 
Squirrel: 
		incbin 'artnem/squirrel.nem'
Mouse: 
		incbin 'artnem/mouse.nem'
White_Bird: 
		incbin 'artnem/wthebird.nem'
Monkey: 
		incbin 'artnem/monkey.nem' 
Black_Bird: 
		incbin 'artnem/blckbird.nem' 
Pig: 
		incbin 'artnem/pig.nem' 
Seal: 
		incbin 'artnem/seal.nem' 
Penguin: 
		incbin 'artnem/penguin.nem'
Turtle: 
		incbin 'artnem/turtle.nem'
Bear: 
		incbin 'artnem/bear.nem' 
Rabbit: 
		incbin 'artnem/rabbit.nem' 
GHz_Buzzer: 
		incbin 'artnem/buzzer.nem'
Hpz_Batbot: 
		incbin 'artnem/batbot.nem'
OOz_Octus: 
		incbin 'artnem/octus.nem'
Hpz_Rhinobot: 
		incbin 'artnem/rhinobot.nem'
Hpz_Dinobot: 
		incbin 'artnem/dinobot.nem'
OOz_Aquis: 
		incbin 'artnem/aquis.nem'
GHz_Masher: 
		incbin 'artnem/masher.nem'
Robotnik_Ship: 
		incbin 'artnem/robotnik.nem'
CPz_Boss: 
		incbin 'artnem/cpzboss.nem'
Boss_Explosions: 
		incbin 'artnem/explosns.nem' 
Ship_Boost 
		incbin 'artnem/shpboost.nem' 
Boss_Smokes: 
		incbin 'artnem/boss_smk.nem'
GHz_Boss_Car: 
		incbin 'artnem/boss_car.nem'
Ghz_Boss_Blades: 
		incbin 'artnem/b_blades.nem'
HTz_Boss_Fire_Cannon: 
		incbin 'artnem/bossfire.nem'
NGHz_Boss: 
		incbin 'artnem/nghzboss.nem'
DHz_Boss: 
		incbin 'artnem/dhzboss.nem'
CNz_Boss: 
		incbin 'artnem/cnzboss.nem'
OOz_Boss: 
		incbin 'artnem/oozboss.nem'
Mz_Boss_Balls_And_Robotniks_Spr:
		incbin 'artnem/bossballs.nem'
DHz_Boss_Rocks: 
		incbin 'artunc/bossrock.dat'
Whisp: 
		incbin 'artnem/whisp.nem'
Grounder: 
		incbin 'artnem/grounder.nem'
Chop_Chop: 
		incbin 'artnem/chopchop.nem'
Rexon: 
		incbin 'artnem/rexon.nem'
Spiker: 
		incbin 'artnem/spiker.nem'
Nebula: 
		incbin 'artnem/nebula.nem'
Turtloid: 
		incbin 'artnem/turtloid.nem'
GHz_Coconuts: 
		incbin 'artnem/coconuts.nem'
Crawlton: 
		incbin 'artnem/crawlton.nem'
Flasher: 
		incbin 'artnem/flasher.nem'
Slicer: 
		incbin 'artnem/slicer.nem'
Shellcracker: 
		incbin 'artnem/shellcrac.nem'
Asteron: 
		incbin 'artnem/asteron.nem'
Lander: 
		incbin 'artnem/lander.nem'
Grabber: 
		incbin 'artnem/grabber.nem'
Clucker: 
		incbin 'artnem/clucker.nem'
Balkiry: 
		incbin 'artnem/balkiry.nem'
Metal_Sonic:
		incbin 'artnem/metal_snc.nem'
Tornado: 
		incbin 'artnem/tornado.nem'
SFz_Cannon: 
		incbin 'artnem/sfzcannon.nem'
Chain_Hook: 
		incbin 'artnem/chainhook.nem'
Hatchways: 
		incbin 'artnem/hatchways.nem'
Conveyor_Belts_Wheels: 
		incbin 'artnem/cb_wheels.nem'
SFz_Platform: 
		incbin 'artnem/sfzplatform.nem'
Vertical_Laser: 
		incbin 'artnem/verlaser.nem'
Clouds: 
		incbin 'artnem/clouds.nem'
Horizontal_Laser: 
		incbin 'artnem/horlaser.nem'
Speed_Boost: 
		incbin 'artnem/spdboost.nem'
SFz_Elevators: 
		incbin 'artnem/sfzelevator.nem'
Engine_Part: 
		incbin 'artnem/engnpart.nem'
Vertical_Helix_Spr: 
		incbin 'artnem/verhelix.nem'
Horizontal_Helix_Spr: 
		incbin 'artnem/horhelix.nem'
Rotating_Helix: 
		incbin 'artnem/rtthelix.nem'
Rocket_Flame_Spr: 
		incbin 'artnem/rktflame.nem'
Spikeball_Laser: 
		incbin 'artnem/spkblasr.nem'
Robotnik_Faces: 
		incbin 'artnem/rbtkface.nem'
Robotnik: 
		incbin 'artnem/sfzrobotnik.nem'
Robotnik_Body: 
		incbin 'artnem/rbtkbody.nem'
Robotnik_Window: 
		incbin 'artnem/robotnkw.nem'
Robotnik_Final: 
		incbin 'artnem/rbtnkfnl.nem'
Crawl: 
		incbin 'artnem/crawl.nem'
Tornado_Rocket 
		incbin 'artnem/t_rocket.nem'
;------------------------------------------------------------------------------- 
Green_Hill_16x16_Map: 
		incbin 'map16/ghz_16.kos' 
		cnop	0,4 ; Filler 
Green_Hill_8x8_Tiles: 
		incbin 'artkos/ghz_8.kos'
		dc.w	$0,$0,$0,$0,$0,$0,$0 ; Filler 
Hill_Top_16x16_Map: 
		incbin 'map16/htz_16.dat'
Hill_Top_8x8_Tiles: 
		incbin 'artnem/htz_8.nem'
Green_Hill_128x128_Map: 
		incbin 'map128/ghz_128.kos' 
		dc.w	$0,$0,$0,$0,$0,$0 ; Filler 
;------------------------------------------------------------------------------- 
Metropolis_16x16_Map: 
		incbin 'map16/mz_16.kos'
		dc.w	$0,$0,$0,$0 ; Filler 
Metropolis_8x8_Tiles: 
		incbin 'artkos/mz_8.kos'
		dc.w	$0,$0,$0,$0 ; Filler 
Metropolis_128x128_Map: 
		incbin 'map128/mz_128.kos'
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Hidden_Palace_16x16_Map: 
Hidden_Palace_8x8_Tiles: 
Hidden_Palace_128x128_Map: 
;------------------------------------------------------------------------------- 
Oil_Ocean_16x16_Map: 
		incbin 'map16/ooz_16.kos'
		dc.w	$0,$0,$0,$0 ; Filler 
Oil_Ocean_8x8_Tiles: 
		incbin 'artkos/ooz_8.kos'
		dc.w	$0,$0,$0,$0,$0,$0,$0 ; Filler 
Oil_Ocean_128x128_Map: 
		incbin 'map128/ooz_128.kos'
;------------------------------------------------------------------------------- 
Dust_Hill_16x16_Map: 
		incbin 'map16/dhz_16.kos'
		dc.w	$0,$0 ; Filler 
Dust_Hill_8x8_Tiles: 
		incbin 'artkos/dhz_8.kos'
		dc.w	$0,$0,$0,$0,$0 ; Filler 
Dust_Hill_128x128_Map: 
		incbin 'map128/dhz_128.kos'
		dc.w	$0,$0 ; Filler 
;------------------------------------------------------------------------------- 
Casino_Night_16x16_Map: 
		incbin 'map16/cnz_16.kos'
		cnop	0,4 ; Filler 
Casino_Night_8x8_Tiles: 
		incbin 'artkos/cnz_8.kos'
		dc.w	$0,$0,$0 ; Filler 
Casino_Night_128x128_Map: 
		incbin 'map128/cnz_128.kos'
		dc.w	$0,$0,$0 ; Filler 
;------------------------------------------------------------------------------- 
Chemical_Plant_16x16_Map: 
		incbin 'map16/cpz_16.kos'
		dc.w	$0,$0,$0,$0,$0 ; Filler 
Chemical_Plant_8x8_Tiles: 
		incbin 'artkos/cpz_8.kos'
		dc.w	$0,$0,$0,$0,$0,$0,$0; Filler 
Chemical_Plant_128x128_Map: 
		incbin 'map128/cpz_128.kos'
		cnop	0,4 ; Filler 
;------------------------------------------------------------------------------- 
Neo_Green_Hill_16x16_Map: 
		incbin 'map16/nghz_16.kos'
		dc.w	$0,$0,$0 ; Filler 
Neo_Green_Hill_8x8_Tiles: 
		incbin 'artkos/nghz_8.kos'
Neo_Green_Hill_128x128_Map 
		incbin 'map128/nghz_128.kos'
		dc.w	$0,$0,$0 ; Filler 
;------------------------------------------------------------------------------- 
Sky_Fortress_16x16_Map: 
		incbin 'map16/sfz_16.kos'
		dc.w	$0,$0,$0,$0 ; Filler 
Sky_Fortress_8x8_Tiles: 
		incbin 'artkos/sfz_8.kos' 
		dc.w	$0,$0,$0,$0,$0,$0 ; Filler 
Robotnik_Ship_Spr:
		incbin 'data/sfz/rbtnkshp.nem' 
Sky_Fortress_128x128_Map: 
		incbin 'map128/sfz_128.kos' 
		dc.w	$0,$0,$0,$0 ; Filler 
;-------------------------------------------------------------------------------
loc_C8310:
		incbin 'specialstage/0x0C8310.dat'
loc_C87B4:
		incbin 'specialstage/0x0C87B4.dat' 
loc_C8D82:
		incbin 'specialstage/0x0C8D82.dat' 
loc_C933A:
		incbin 'specialstage/0x0C933A.dat' 
loc_C999E:
		incbin 'specialstage/0x0C999E.dat' 
loc_C9FCA:
		incbin 'specialstage/0x0C9FCA.dat' 
loc_CA686:
		incbin 'specialstage/0x0CA686.dat' 
loc_CAC8E:
		incbin 'specialstage/0x0CAC8E.dat' 
loc_CB1CC:
		incbin 'specialstage/0x0CB1CC.dat'
loc_CB750:
		incbin 'specialstage/0x0CB750.dat'
loc_CBCCA:
		incbin 'specialstage/0x0CBCCA.dat'
loc_CC1EA:
		incbin 'specialstage/0x0CC1EA.dat'
loc_CC65E:
		incbin 'specialstage/0x0CC65E.dat'
loc_CCAC8:
		incbin 'specialstage/0x0CCAC8.dat'
loc_CCF8C:
		incbin 'specialstage/0x0CCF8C.dat'
loc_CD40C:
		incbin 'specialstage/0x0CD40C.dat'
loc_CD856:
		incbin 'specialstage/0x0CD856.dat'
loc_CDC98:
		incbin 'specialstage/0x0CDC98.dat'
loc_CE316:
		incbin 'specialstage/0x0CE316.dat'
loc_CE8B2:
		incbin 'specialstage/0x0CE8B2.dat'
loc_CEE0C:
		incbin 'specialstage/0x0CEE0C.dat'
loc_CF408:
		incbin 'specialstage/0x0CF408.dat'
loc_CF8B8:
		incbin 'specialstage/0x0CF8B8.dat'
loc_CFDBA:
		incbin 'specialstage/0x0CFDBA.dat'
loc_D01D2:
		incbin 'specialstage/0x0D01D2.dat'
loc_D0620:
		incbin 'specialstage/0x0D0620.dat'
loc_D0A9E:
		incbin 'specialstage/0x0D0A9E.dat'
loc_D0F2E:
		incbin 'specialstage/0x0D0F2E.dat'
loc_D13F8:
		incbin 'specialstage/0x0D13F8.dat'
loc_D1984:
		incbin 'specialstage/0x0D1984.dat'
loc_D206C:
		incbin 'specialstage/0x0D206C.dat'
loc_D27B2:
		incbin 'specialstage/0x0D27B2.dat'
loc_D2E08:
		incbin 'specialstage/0x0D2E08.dat'
loc_D3364:
		incbin 'specialstage/0x0D3364.dat'
loc_D390E:
		incbin 'specialstage/0x0D390E.dat'
loc_D3FA2:
		incbin 'specialstage/0x0D3FA2.dat'
loc_D45B6:
		incbin 'specialstage/0x0D45B6.dat'
loc_D4A3A:
		incbin 'specialstage/0x0D4A3A.dat'
loc_D4EA8:
		incbin 'specialstage/0x0D4EA8.dat'
loc_D531E:
		incbin 'specialstage/0x0D531E.dat'
loc_D57B6:
		incbin 'specialstage/0x0D57B6.dat'
loc_D5C5C:
		incbin 'specialstage/0x0D5C5C.dat'
loc_D6004:
		incbin 'specialstage/0x0D6004.dat'
loc_D63F8:
		incbin 'specialstage/0x0D63F8.dat'
loc_D6830:
		incbin 'specialstage/0x0D6830.dat'
loc_D6CC2:
		incbin 'specialstage/0x0D6CC2.dat'
loc_D7184:
		incbin 'specialstage/0x0D7184.dat'
loc_D758C:
		incbin 'specialstage/0x0D758C.dat'
loc_D7A22:
		incbin 'specialstage/0x0D7A22.dat'
loc_D7EDA:
		incbin 'specialstage/0x0D7EDA.dat'
loc_D852C:
		incbin 'specialstage/0x0D852C.dat'
loc_D8A92:
		incbin 'specialstage/0x0D8A92.dat'
loc_D8FBA:
		incbin 'specialstage/0x0D8FBA.dat'
loc_D956E:
		incbin 'specialstage/0x0D956E.dat'
loc_D9B60:
		incbin 'specialstage/0x0D9B60.dat'
loc_D9FF4: 
		incbin 'specialstage/0x0D9FF4.dat' 
SS_Tiles_8x8_Tiles: 
		incbin 'specialstage/ss_8.kos' 
		dc.w	$0,$0 ; Filler 
SS_Background_8x8_Tiles: 
		incbin 'specialstage/backgnd8.nem'
SS_Mappings_01: 
		incbin 'mapeni/ss_map_1.eni'
SS_Mappings_00: 
		incbin 'mapeni/ss_map_0.eni'
SS_HUD_Font: 
		incbin 'specialstage/hud_font.nem' 
SS_START: 
		incbin 'specialstage/start.nem' 
SS_Background_Stars: 
		incbin 'specialstage/bg_stars.nem' 
SS_PAYMW_vs: 
		incbin 'specialstage/paymw_vs.nem' 
SS_Rings: 
		incbin 'specialstage/rings.nem'
SS_Player_Shadow: 
		incbin 'specialstage/p_shadow.nem' 
SS_Player_Diagonal_Shadow: 
		incbin 'specialstage/d_shadow.nem' 
SS_Player_Vertical_Shadow: 
		incbin 'specialstage/v_shadow.nem' 
SS_Bomb_Explosion: 
		incbin 'specialstage/bomb_exp.nem' 
SS_Bombs: 
		incbin 'specialstage/bombs.nem' 
SS_Emerald: 
		incbin 'specialstage/emerald.nem'
SS_Wings_Hand: 
		incbin 'specialstage/winghand.nem' 
SS_Sonic_Miles: 
		incbin 'specialstage/soncmils.nem'
SS_Mapings_00: 
		incbin 'specialstage/ss_map_0.kos'
		dc.w	$0,$0,$0,$0,$0,$0 ; Filler 
SS_Mapings_01: 
		incbin 'specialstage/ss_map_1.kos' 
		dc.w	$0 ; Filler
SS_Mapings_02: 
		incbin 'specialstage/ss_map_2.kos'
Unk_loc_E16AA:
		incbin 'specialstage/0x0E16AA.dat'
;===============================================================================
; Objects_Layout
; [ Begin ]
;===============================================================================
Objects_Layout: 
		dc.w	GHz_1_Objects_Layout-Objects_Layout
		dc.w	GHz_2_Objects_Layout-Objects_Layout 
		dc.w	Null_Objects_Layout-Objects_Layout 
		dc.w	Null_Objects_Layout-Objects_Layout 
		dc.w	Null_Objects_Layout-Objects_Layout 
		dc.w	Null_Objects_Layout-Objects_Layout 
		dc.w	Null_Objects_Layout-Objects_Layout 
		dc.w	Null_Objects_Layout-Objects_Layout 
		dc.w	Mz_1_Objects_Layout-Objects_Layout 
		dc.w	Mz_2_Objects_Layout-Objects_Layout 
		dc.w	Mz_3_Objects_Layout-Objects_Layout 
		dc.w	Mz_3_Objects_Layout-Objects_Layout 
		dc.w	SFz_1_Objects_Layout-Objects_Layout 
		dc.w	SFz_2_Objects_Layout-Objects_Layout 
		dc.w	HTz_1_Objects_Layout-Objects_Layout 
		dc.w	HTz_2_Objects_Layout-Objects_Layout 
		dc.w	HPz_1_Objects_Layout-Objects_Layout 
		dc.w	HPz_2_Objects_Layout-Objects_Layout 
		dc.w	Null_Objects_Layout-Objects_Layout 
		dc.w	Null_Objects_Layout-Objects_Layout 
		dc.w	OOz_1_Objects_Layout-Objects_Layout 
		dc.w	OOz_2_Objects_Layout-Objects_Layout 
		dc.w	dHz_1_Objects_Layout-Objects_Layout 
		dc.w	dHz_2_Objects_Layout-Objects_Layout 
		dc.w	CNz_1_Objects_Layout-Objects_Layout 
		dc.w	CNz_2_Objects_Layout-Objects_Layout 
		dc.w	CPz_1_Objects_Layout-Objects_Layout 
		dc.w	CPz_2_Objects_Layout-Objects_Layout 
		dc.w	dEz_1_Objects_Layout-Objects_Layout 
		dc.w	dEz_2_Objects_Layout-Objects_Layout 
		dc.w	NGHz_1_Objects_Layout-Objects_Layout 
		dc.w	NGHz_2_Objects_Layout-Objects_Layout 
		dc.w	SCz_1_Objects_Layout-Objects_Layout 
		dc.w	SCz_2_Objects_Layout-Objects_Layout 
		dc.w	$FFFF,$0,$0 ; The Game will crash if these bytes are missing 
GHz_1_Objects_Layout: 
		incbin 'data/ghz/obj_act1.dat'
GHz_2_Objects_Layout:
		incbin 'data/ghz/obj_act2.dat'
Mz_1_Objects_Layout: 
		incbin 'data/mz/obj_act1.dat'
Mz_2_Objects_Layout: 
		incbin 'data/mz/obj_act2.dat'
Mz_3_Objects_Layout: 
Mz_4_Objects_Layout: 
		incbin 'data/mz/obj_act3.dat'
SFz_1_Objects_Layout: 
		incbin 'data/sfz/obj_act.dat'
SFz_2_Objects_Layout: 
		dc.w	$FFFF,$0,$0
HTz_1_Objects_Layout: 
		incbin 'data/htz/obj_act1.dat' 
HTz_2_Objects_Layout: 
		incbin 'data/htz/obj_act2.dat' 
HPz_1_Objects_Layout: 
		incbin 'data/hpz/obj_act.dat'
HPz_2_Objects_Layout: 
		dc.w	$FFFF,$0,$0
; Left Over Unused 
		dc.w	$FFFF,$0,$0
OOz_1_Objects_Layout: 
		incbin 'data/ooz/obj_act1.dat'
OOz_2_Objects_Layout: 
		incbin 'data/ooz/obj_act2.dat' 
DHz_1_Objects_Layout: 
		incbin 'data/dhz/obj_act1.dat' 
DHz_2_Objects_Layout: 
		incbin 'data/dhz/obj_act2.dat' 
CNz_1_Objects_Layout:
		incbin 'objpos/cnz_act1.dat' 
CNz_2_Objects_Layout: 
		incbin 'objpos/cnz_act2.dat'
CPz_1_Objects_Layout:
		incbin 'objpos/cpz_act1.dat'
CPz_2_Objects_Layout:
		incbin 'objpos/cpz_act2.dat'
DEz_1_Objects_Layout: 
		incbin 'data/dez/obj_act.dat'
DEz_2_Objects_Layout: 
		dc.w	$FFFF,$0,$0
NGHz_1_Objects_Layout: 
		incbin 'data/nghz/obj_act1.dat' 
NGHz_2_Objects_Layout: 
		incbin 'data/nghz/obj_act2.dat' 
SCz_1_Objects_Layout: 
		incbin 'data/scz/obj_act.dat' 
SCz_2_Objects_Layout: 
		dc.w	$FFFF,$0,$0
Null_Objects_Layout: 
		dc.w	$FFFF,$0,$0
;===============================================================================
; Objects_Layout
; [ End ]
;===============================================================================

;===============================================================================
; Rings_Layout Previous Build
; [ Begin ]
;===============================================================================
GHz_2_PB_Rings_Layout: 
		incbin 'rings/previousbuild/ghzrng_pb_2.dat'
Null_PB_Rings_Layout: 
		dc.w	$FFFF
Null_1_PB_Rings_Layout: 
		dc.w	$FFFF
Wz_1_PB_Rings_Layout: 
		dc.w	$FFFF
Wz_2_PB_Rings_Layout: 
		dc.w	$FFFF
Null_3_PB_Rings_Layout: 
		dc.w	$FFFF
Null_4_PB_Rings_Layout: 
		dc.w	$FFFF
Mz_1_PB_Rings_Layout: 
		incbin 'rings/previousbuild/mzrng_pb_1.dat'
Mz_2_PB_Rings_Layout:
		incbin 'rings/mzrng_act2.dat'
Mz_3_PB_Rings_Layout:
		incbin 'rings/previousbuild/mzrng_pb_3.dat'
Mz_4_PB_Rings_Layout:
		dc.w	$FFFF
HTz_1_PB_Rings_Layout:
		incbin 'rings/previousbuild/htzrng_pb_1.dat'
HTz_2_PB_Rings_Layout:
		incbin 'rings/previousbuild/htzrng_pb_2.dat'
HPz_1_PB_Rings_Layout:
		incbin 'rings/hpzrng_act.dat'
HPz_2_PB_Rings_Layout:
		dc.w	$FFFF
Null_5_PB_Rings_Layout:
		dc.w	$FFFF
Null_6_PB_Rings_Layout:
		dc.w	$FFFF
OOz_1_PB_Rings_Layout:
		incbin 'rings/oozrng_act1.dat'
OOz_2_PB_Rings_Layout:
		incbin 'rings/previousbuild/oozrng_pb_2.dat'
;===============================================================================
; Rings_Layout Previous Build
; [ End ]
;===============================================================================

;===============================================================================
; Rings_Layout
; [ Begin ]
;===============================================================================
Rings_Layout: 
		dc.w	GHz_1_Rings_Layout-Rings_Layout 
		dc.w	GHz_2_Rings_Layout-Rings_Layout 
		dc.w	Null_Rings_Layout-Rings_Layout 
		dc.w	Null_1_Rings_Layout-Rings_Layout 
		dc.w	Wz_1_Rings_Layout-Rings_Layout 
		dc.w	Wz_2_Rings_Layout-Rings_Layout 
		dc.w	Null_3_Rings_Layout-Rings_Layout 
		dc.w	Null_4_Rings_Layout-Rings_Layout 
		dc.w	Mz_1_Rings_Layout-Rings_Layout 
		dc.w	Mz_2_Rings_Layout-Rings_Layout 
		dc.w	Mz_3_Rings_Layout-Rings_Layout 
		dc.w	Mz_4_Rings_Layout-Rings_Layout 
		dc.w	SFz_1_Rings_Layout-Rings_Layout 
		dc.w	SFz_2_Rings_Layout-Rings_Layout 
		dc.w	HTz_1_Rings_Layout-Rings_Layout 
		dc.w	HTz_2_Rings_Layout-Rings_Layout 
		dc.w	HPz_1_Rings_Layout-Rings_Layout 
		dc.w	HPz_2_Rings_Layout-Rings_Layout
		dc.w	Null_5_Rings_Layout-Rings_Layout 
		dc.w	Null_6_Rings_Layout-Rings_Layout 
		dc.w	OOz_1_Rings_Layout-Rings_Layout 
		dc.w	OOz_2_Rings_Layout-Rings_Layout 
		dc.w	dHz_1_Rings_Layout-Rings_Layout 
		dc.w	dHz_2_Rings_Layout-Rings_Layout 
		dc.w	CNz_1_Rings_Layout-Rings_Layout 
		dc.w	CNz_2_Rings_Layout-Rings_Layout 
		dc.w	CPz_1_Rings_Layout-Rings_Layout 
		dc.w	CPz_2_Rings_Layout-Rings_Layout 
		dc.w	dEz_1_Rings_Layout-Rings_Layout 
		dc.w	dEz_2_Rings_Layout-Rings_Layout 
		dc.w	NGHz_1_Rings_Layout-Rings_Layout 
		dc.w	NGHz_2_Rings_Layout-Rings_Layout 
		dc.w	SCz_1_Rings_Layout-Rings_Layout 
		dc.w	SCz_2_Rings_Layout-Rings_Layout 
GHz_1_Rings_Layout: 
		incbin 'rings/ghzrng_act1.dat'
GHz_2_Rings_Layout:
		incbin 'rings/ghzrng_act2.dat'
Null_Rings_Layout: 
		dc.w	$FFFF
Null_1_Rings_Layout: 
		dc.w	$FFFF
Wz_1_Rings_Layout: 
		dc.w	$FFFF
Wz_2_Rings_Layout: 
		dc.w	$FFFF
Null_3_Rings_Layout: 
		dc.w	$FFFF
Null_4_Rings_Layout: 
		dc.w	$FFFF
Mz_1_Rings_Layout: 
		incbin 'rings/mzrng_act1.dat'
Mz_2_Rings_Layout: 
		incbin 'rings/mzrng_act2.dat'
Mz_3_Rings_Layout: 
		incbin 'rings/mzrng_act3.dat'
Mz_4_Rings_Layout: 
		dc.w	$FFFF
HTz_1_Rings_Layout: 
		incbin 'rings/htzrng_act1.dat'
HTz_2_Rings_Layout: 
		incbin 'rings/htzrng_act2.dat'
HPz_1_Rings_Layout: 
		incbin 'rings/hpzrng_act.dat'
HPz_2_Rings_Layout: 
		dc.w	$FFFF
Null_5_Rings_Layout: 
		dc.w	$FFFF
Null_6_Rings_Layout: 
		dc.w	$FFFF
OOz_1_Rings_Layout: 
		incbin 'rings/oozrng_act1.dat'
OOz_2_Rings_Layout: 
		incbin 'rings/oozrng_act2.dat'
DHz_1_Rings_Layout: 
		incbin 'rings/dhzrng_act1.dat'
DHz_2_Rings_Layout:
		incbin 'rings/dhzrng_act2.dat'
CNz_1_Rings_Layout: 
		incbin 'rings/cnzrng_act1.dat'
CNz_2_Rings_Layout: 
		incbin 'rings/cnzrng_act2.dat'
CPz_1_Rings_Layout: 
		incbin 'rings/cpzrng_act1.dat'
CPz_2_Rings_Layout: 
		incbin 'rings/cpzrng_act2.dat'
DEz_1_Rings_Layout: 
		incbin 'rings/dezrng_act.dat'
DEz_2_Rings_Layout: 
		dc.w	$FFFF
SFz_1_Rings_Layout: 
		incbin 'rings/sfzrng_act.dat'
SFz_2_Rings_Layout: 
		dc.w	$FFFF
NGHz_1_Rings_Layout: 
		incbin 'rings/nghzrng_act1.dat'
NGHz_2_Rings_Layout: 
		incbin 'rings/nghzrng_act2.dat'
SCz_1_Rings_Layout: 
		incbin 'rings/sczrng_act.dat'
SCz_2_Rings_Layout: 
		dc.w	$FFFF
;-------------------------------------------------------------------------------
SCz_1_PB_Rings_Layout: 
		dc.w	$12E0,$3530,$1400,$3580,$F60,$D510,$FFFF
SCz_2_PB_Rings_Layout: 
		dc.w	$FFFF
;===============================================================================
; Rings_Layout
; [ End ]
;===============================================================================
Unk_loc_EB400:
		incbin 'misc/0x0EB400.dat'
;===============================================================================
; Sound Driver
; [ Begin ]
;=============================================================================== 
Sound_Driver: 
		move 	SR,-(sp)
		movem.l	d0-d7/a0-a6,-(sp)
		move	#$2700,sr
		lea	(Z80_Bus_Request),a3
		lea	(Z80_Reset),a2
		moveq	#0,d2
		move.w	#$100,d1
		move.w	d1,(a3)
		move.w	d1,(a2)
loc_EC020:
		btst D2,(a3)
		bne.s	loc_EC020
		jsr	loc_EC04A(pc)
		btst	#0,($C00005)
		sne 	($A00007)
		move.w	d2,(a2)
		move.w	d2,(a3)
		moveq	#$17,d0
loc_EC03C:
		dbra	d0,loc_EC03C
		move.w	d1,(a2)
		movem.l	(sp)+,d0-d7/a0-a6
		move (sp)+,sr
		rts
;--------------------------------------------------------------------------------
loc_EC04A:
		lea	Z80_Driver(pc),a6
		move.w	#$F6B,d7
		moveq	#0,d6
		lea	(Z80_RAM),a5
		moveq	#0,d5
		lea	(Z80_RAM),a4
loc_EC062:
		lsr.w	#1,d6
		btst	#8,d6
		bne.s	loc_EC074
		jsr	loc_EC0DE(pc)
		move.b	d0,d6
		or.w	#$FF00,d6
loc_EC074:
		btst	#0,d6
		beq.s	loc_EC086
		jsr	loc_EC0DE(pc)
		move.b	d0,(a5)+
		addq.w	#1,d5
		bra.w	loc_EC062
loc_EC086:
		jsr	loc_EC0DE(pc)
		moveq	#0,d4
		move.b	d0,d4
		jsr	loc_EC0DE(pc)
		move.b	d0,d3
		and.w	#$F,d3
		addq.w	#2,d3
		and.w	#$F0,d0
		lsl.w	#4,d0
		add.w	d0,d4
		add.w	#$12,d4
		and.w	#$FFF,d4
		move.w	d5,d0
		and.w	#$F000,d0
		add.w	d0,d4
		cmp.w	d4,d5
		bcc.s	loc_EC0CC
		sub.w	#$1000,d4
		bcc.s	loc_EC0CC
		add.w	d3,d5
		addq.w	#1,d5
loc_EC0C0:
		move.b	#0,(a5)+
		dbra	d3,loc_EC0C0
		bra.w	loc_EC062
loc_EC0CC:
		add.w	d3,d5
		addq.w	#1,d5
loc_EC0D0:
		move.b	0(a4,d4),(a5)+
		addq.w	#1,d4
		dbra	d3,loc_EC0D0
		bra.w	loc_EC062
loc_EC0DE:
		move.b	(a6)+,d0
		subq.w	#1,d7
		bne.s	loc_EC0E6
		addq.w	#4,a7
loc_EC0E6:
		rts
;--------------------------------------------------------------------------------
Z80_Driver:
		incbin 'sound/z80.sax'
		even

		cnop $0,$ED100
DAC_Sample_00:
		incbin 'sound/dAC_00.bin'
DAC_Sample_01:
		incbin 'sound/dAC_01.bin'
DAC_Sample_02:
		incbin 'sound/dAC_02.bin'
DAC_Sample_03:
		incbin 'sound/dAC_03.bin'
DAC_Sample_04:
		incbin 'sound/dAC_04.bin'
DAC_Sample_05:
		incbin 'sound/dAC_05.bin'
DAC_Sample_06:
		incbin 'sound/dAC_06.bin'
		even

;-------------------------------------------------------------------------------
		cnop 0,$F0000
Music_9C_Idx:
		dc.w	(((Music_9C_Ptr>>$8)|(Music_9C_Ptr<<$8))&$FFFF)
Music_9C:
		incbin 'sound/cont_9C.sax'
;-------------------------------------------------------------------------------
		cnop 0,$F1E8C
Sega_Snd:
		incbin 'sound/sega.snd'
;-------------------------------------------------------------------------------
		cnop 0,$F8000
Music_81_To_9F: 
		dc.w	(((Music_88_Ptr>>$8)|(Music_88_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_82_Ptr>>$8)|(Music_82_Ptr<<$8))&$FFFF)
		dc.w	(((Music_85_Ptr>>$8)|(Music_85_Ptr<<$8))&$FFFF)
		dc.w	(((Music_89_Ptr>>$8)|(Music_89_Ptr<<$8))&$FFFF)
		dc.w	(((Music_8B_Ptr>>$8)|(Music_8B_Ptr<<$8))&$FFFF)
		dc.w	(((Music_83_Ptr>>$8)|(Music_83_Ptr<<$8))&$FFFF)
		dc.w	(((Music_87_Ptr>>$8)|(Music_87_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_8A_Ptr>>$8)|(Music_8A_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_92_Ptr>>$8)|(Music_92_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_91_Ptr>>$8)|(Music_91_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_95_Ptr>>$8)|(Music_95_Ptr<<$8))&$FFFF)
		dc.w	(((Music_94_Ptr>>$8)|(Music_94_Ptr<<$8))&$FFFF)
		dc.w	(((Music_8E_Ptr>>$8)|(Music_8E_Ptr<<$8))&$FFFF)
		dc.w	(((Music_93_Ptr>>$8)|(Music_93_Ptr<<$8))&$FFFF)
		dc.w	(((Music_8D_Ptr>>$8)|(Music_8D_Ptr<<$8))&$FFFF)
		dc.w	(((Music_84_Ptr>>$8)|(Music_84_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_8F_Ptr>>$8)|(Music_8F_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_8C_Ptr>>$8)|(Music_8C_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_81_Ptr>>$8)|(Music_81_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_96_Ptr>>$8)|(Music_96_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_86_Ptr>>$8)|(Music_86_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_98_Ptr>>$8)|(Music_98_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_99_Ptr>>$8)|(Music_99_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_9A_Ptr>>$8)|(Music_9A_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_9B_Ptr>>$8)|(Music_9B_Ptr<<$8))&$FFFF)
		dc.w	(((Music_97_Ptr>>$8)|(Music_97_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_9D_Ptr>>$8)|(Music_9D_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_90_Ptr>>$8)|(Music_90_Ptr<<$8))&$FFFF) 
		dc.w	(((Music_9F_Ptr>>$8)|(Music_9F_Ptr<<$8))&$FFFF)
		dc.w	(((Music_9E_Ptr>>$8)|(Music_9E_Ptr<<$8))&$FFFF) 
;------------------------------------------------------------------------------- 
Music_90: ; Hidden Palace 
		incbin 'sound/hpz_90.sax' 
Music_9F: ; Panic 
		incbin 'sound/pnc_9F.sax'
Music_97: ; Invencibility 
		incbin 'sound/invcb_97.sax'
Music_88: ; Casino Night Versus Mode 
		incbin 'sound/cnzvs_88.sax'
Music_82: ; Green Hill 
		incbin 'sound/ghz_82.sax'
Music_85: ; Metropolis 
		incbin 'sound/mz_85.sax'
Music_89: ; Casino Night 
		incbin 'sound/cnz_89.sax'
Music_8B: ; Dust Hill 
		incbin 'sound/dhz_8B.sax'
Music_83: ; Dust Hill Versus Mode 
		incbin 'sound/dhzvs_83.sax'
Music_87: ; Neo Green Hill 
		incbin 'sound/nghz_87.sax'
Music_8A: ; Deat Egg 
		incbin 'sound/dez_8A.sax'
Music_92: ; Special Stage 
		incbin 'sound/ss_92.sax'
Music_91: ; Level Select Menu / Vs Mode Menu 
		incbin 'sound/menu_91.sax'
Music_95: ; Ending Sequence 
		incbin 'sound/endsq_95.sax'
Music_94: ; Death Egg Final Boss 
		incbin 'sound/dezfb_94.sax'
Music_8E: ; Chemical Plant 
		incbin 'sound/cpz_8E.sax'
Music_93: ; Level Boss 
		incbin 'sound/boss_93.sax'
Music_8D: ; Sky Chase 
		incbin 'sound/scz_8D.sax'
Music_84: ; Oil Ocean 
		incbin 'sound/ooz_84.sax'
Music_8F: ; Sky Fortress 
		incbin 'sound/sfz_8F.sax'
Music_8C: ; Green Hill Versus Mode
		incbin 'sound/ghzvs_8C.sax'
Music_81: ; Versus Mode Results 
		incbin 'sound/vsres_81.sax'
Music_96: ; Super Sonic 
		incbin 'sound/spsnc_96.sax'
Music_86: ; Hill Top 
		incbin 'sound/htz_86.sax'
Music_99: ; Title Screen 
		incbin 'sound/tscr_99.sax'
Music_9A: ; Results Screen 
		incbin 'sound/rscr_9A.sax'
Music_98: ; +1 Up ( Uncompressed ) 
		incbin 'sound/1up_98.snd'
Music_9B: ; Time Over / Game Over ( Uncompressed ) 
		incbin 'sound/tgovr_9B.snd'
Music_9D: ; Emerald ( Uncompressed ) 
		incbin 'sound/emrld_9D.snd'
Music_9E: ; Credits ( Uncompressed ) 
		incbin 'sound/credt_9E.snd'
;-------------------------------------------------------------------------------
Sfx_A0_To_F9:
		dc.w	(((Sfx_A0_Ptr>>$8)|(Sfx_A0_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_A1_Ptr>>$8)|(Sfx_A1_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_A2_Ptr>>$8)|(Sfx_A2_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_A3_Ptr>>$8)|(Sfx_A3_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_A4_Ptr>>$8)|(Sfx_A4_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_A5_Ptr>>$8)|(Sfx_A5_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_A6_Ptr>>$8)|(Sfx_A6_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_A7_Ptr>>$8)|(Sfx_A7_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_A8_Ptr>>$8)|(Sfx_A8_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_A9_Ptr>>$8)|(Sfx_A9_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_AA_Ptr>>$8)|(Sfx_AA_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_AB_Ptr>>$8)|(Sfx_AB_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_AC_Ptr>>$8)|(Sfx_AC_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_AD_Ptr>>$8)|(Sfx_AD_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_AE_Ptr>>$8)|(Sfx_AE_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_AF_Ptr>>$8)|(Sfx_AF_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_B0_Ptr>>$8)|(Sfx_B0_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_B1_Ptr>>$8)|(Sfx_B1_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_B2_Ptr>>$8)|(Sfx_B2_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_B3_Ptr>>$8)|(Sfx_B3_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_B4_Ptr>>$8)|(Sfx_B4_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_B5_Ptr>>$8)|(Sfx_B5_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_B6_Ptr>>$8)|(Sfx_B6_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_B7_Ptr>>$8)|(Sfx_B7_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_B8_Ptr>>$8)|(Sfx_B8_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_B9_Ptr>>$8)|(Sfx_B9_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_BA_Ptr>>$8)|(Sfx_BA_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_BB_Ptr>>$8)|(Sfx_BB_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_BC_Ptr>>$8)|(Sfx_BC_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_BD_Ptr>>$8)|(Sfx_BD_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_BE_Ptr>>$8)|(Sfx_BE_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_BF_Ptr>>$8)|(Sfx_BF_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_C0_Ptr>>$8)|(Sfx_C0_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_C1_Ptr>>$8)|(Sfx_C1_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_C2_Ptr>>$8)|(Sfx_C2_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_C3_Ptr>>$8)|(Sfx_C3_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_C4_Ptr>>$8)|(Sfx_C4_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_C5_Ptr>>$8)|(Sfx_C5_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_C6_Ptr>>$8)|(Sfx_C6_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_C7_Ptr>>$8)|(Sfx_C7_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_C8_Ptr>>$8)|(Sfx_C8_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_C9_Ptr>>$8)|(Sfx_C9_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_CA_Ptr>>$8)|(Sfx_CA_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_CB_Ptr>>$8)|(Sfx_CB_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_CC_Ptr>>$8)|(Sfx_CC_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_CD_Ptr>>$8)|(Sfx_CD_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_CE_Ptr>>$8)|(Sfx_CE_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_CF_Ptr>>$8)|(Sfx_CF_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_D0_Ptr>>$8)|(Sfx_D0_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_D1_Ptr>>$8)|(Sfx_D1_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_D2_Ptr>>$8)|(Sfx_D2_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_D3_Ptr>>$8)|(Sfx_D3_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_D4_Ptr>>$8)|(Sfx_D4_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_D5_Ptr>>$8)|(Sfx_D5_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_D6_Ptr>>$8)|(Sfx_D6_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_D7_Ptr>>$8)|(Sfx_D7_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_D8_Ptr>>$8)|(Sfx_D8_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_D9_Ptr>>$8)|(Sfx_D9_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_DA_Ptr>>$8)|(Sfx_DA_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_DB_Ptr>>$8)|(Sfx_DB_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_DC_Ptr>>$8)|(Sfx_DC_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_DD_Ptr>>$8)|(Sfx_DD_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_DE_Ptr>>$8)|(Sfx_DE_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_DF_Ptr>>$8)|(Sfx_DF_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_E0_Ptr>>$8)|(Sfx_E0_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_E1_Ptr>>$8)|(Sfx_E1_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_E2_Ptr>>$8)|(Sfx_E2_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_E3_Ptr>>$8)|(Sfx_E3_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_E4_Ptr>>$8)|(Sfx_E4_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_E5_Ptr>>$8)|(Sfx_E5_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_E6_Ptr>>$8)|(Sfx_E6_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_E7_Ptr>>$8)|(Sfx_E7_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_E8_Ptr>>$8)|(Sfx_E8_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_E9_Ptr>>$8)|(Sfx_E9_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_EA_Ptr>>$8)|(Sfx_EA_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_EB_Ptr>>$8)|(Sfx_EB_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_EC_Ptr>>$8)|(Sfx_EC_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_ED_Ptr>>$8)|(Sfx_ED_Ptr<<$8))&$FFFF)
		dc.w	(((Sfx_EE_Ptr>>$8)|(Sfx_EE_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_EF_Ptr>>$8)|(Sfx_EF_Ptr<<$8))&$FFFF) 
		dc.w	(((Sfx_F0_Ptr>>$8)|(Sfx_F0_Ptr<<$8))&$FFFF) 
;-------------------------------------------------------------------------------
Sfx_A0: 
		incbin 'sound/sfx_A0.snd'
Sfx_A1: 
		incbin 'sound/sfx_A1.snd'
Sfx_A2: 
		incbin 'sound/sfx_A2.snd'
Sfx_A3: 
		incbin 'sound/sfx_A3.snd'
Sfx_A4: 
		incbin 'sound/sfx_A4.snd'
Sfx_A5: 
		incbin 'sound/sfx_A5.snd'
Sfx_A6: 
		incbin 'sound/sfx_A6.snd'
Sfx_A7: 
		incbin 'sound/sfx_A7.snd'
Sfx_A8: 
		incbin 'sound/sfx_A8.snd'
Sfx_A9: 
		incbin 'sound/sfx_A9.snd'
Sfx_AA: 
		incbin 'sound/sfx_AA.snd'
Sfx_AB: 
		incbin 'sound/sfx_AB.snd'
Sfx_AC: 
		incbin 'sound/sfx_AC.snd'
Sfx_AD: 
		incbin 'sound/sfx_AD.snd'
Sfx_AE: 
		incbin 'sound/sfx_AE.snd'
Sfx_AF: 
		incbin 'sound/sfx_AF.snd'
Sfx_B0: 
		incbin 'sound/sfx_B0.snd'
Sfx_B1: 
		incbin 'sound/sfx_B1.snd'
Sfx_B2: 
		incbin 'sound/sfx_B2.snd'
Sfx_B3: 
		incbin 'sound/sfx_B3.snd'
Sfx_B4: 
		incbin 'sound/sfx_B4.snd'
Sfx_B5: 
		incbin 'sound/sfx_B5.snd'
Sfx_B6: 
		incbin 'sound/sfx_B6.snd'
Sfx_B7: 
		incbin 'sound/sfx_B7.snd'
Sfx_B8: 
		incbin 'sound/sfx_B8.snd'
Sfx_B9: 
		incbin 'sound/sfx_B9.snd'
Sfx_BA: 
		incbin 'sound/sfx_BA.snd'
Sfx_BB: 
		incbin 'sound/sfx_BB.snd'
Sfx_BC: 
		incbin 'sound/sfx_BC.snd'
Sfx_BD: 
		incbin 'sound/sfx_BD.snd'
Sfx_BE: 
		incbin 'sound/sfx_BE.snd' 
Sfx_BF: 
		incbin 'sound/sfx_BF.snd' 
Sfx_C0: 
		incbin 'sound/sfx_C0.snd' 
Sfx_C1: 
		incbin 'sound/sfx_C1.snd' 
Sfx_C2: 
		incbin 'sound/sfx_C2.snd' 
Sfx_C3: 
		incbin 'sound/sfx_C3.snd' 
Sfx_C4: 
		incbin 'sound/sfx_C4.snd' 
Sfx_C5: 
		incbin 'sound/sfx_C5.snd' 
Sfx_C6: 
		incbin 'sound/sfx_C6.snd'
Sfx_C7: 
		incbin 'sound/sfx_C7.snd' 
Sfx_C8: 
		incbin 'sound/sfx_C8.snd'
Sfx_C9: 
		incbin 'sound/sfx_C9.snd' 
Sfx_CA: 
		incbin 'sound/sfx_CA.snd' 
Sfx_CB: 
		incbin 'sound/sfx_CB.snd' 
Sfx_CC: 
		incbin 'sound/sfx_CC.snd' 
Sfx_CD: 
		incbin 'sound/sfx_CD.snd' 
Sfx_CE: 
		incbin 'sound/sfx_CE.snd' 
Sfx_CF: 
		incbin 'sound/sfx_CF.snd' 
Sfx_D0: 
		incbin 'sound/sfx_D0.snd' 
Sfx_D1: 
		incbin 'sound/sfx_D1.snd'
Sfx_D2: 
		incbin 'sound/sfx_D2.snd'
Sfx_D3: 
		incbin 'sound/sfx_D3.snd'
Sfx_D4: 
		incbin 'sound/sfx_D4.snd'
Sfx_D5: 
		incbin 'sound/sfx_D5.snd'
Sfx_D6: 
		incbin 'sound/sfx_D6.snd'
Sfx_D7: 
		incbin 'sound/sfx_D7.snd'
Sfx_D8: 
		incbin 'sound/sfx_D8.snd'
Sfx_D9: 
		incbin 'sound/sfx_D9.snd'
Sfx_DA: 
		incbin 'sound/sfx_DA.snd'
Sfx_DB: 
		incbin 'sound/sfx_DB.snd'
Sfx_DC: 
		incbin 'sound/sfx_DC.snd'
Sfx_DD: 
		incbin 'sound/sfx_DD.snd'
Sfx_DE: 
		incbin 'sound/sfx_DE.snd'
Sfx_DF: 
		incbin 'sound/sfx_DF.snd'
Sfx_E0: 
		incbin 'sound/sfx_E0.snd'
Sfx_E1: 
		incbin 'sound/sfx_E1.snd'
Sfx_E2: 
		incbin 'sound/sfx_E2.snd'
Sfx_E3: 
		incbin 'sound/sfx_E3.snd'
Sfx_E4: 
		incbin 'sound/sfx_E4.snd'
Sfx_E5: 
		incbin 'sound/sfx_E5.snd'
Sfx_E6: 
		incbin 'sound/sfx_E6.snd'
Sfx_E7: 
		incbin 'sound/sfx_E7.snd'
Sfx_E8: 
		incbin 'sound/sfx_E8.snd'
Sfx_E9: 
		incbin 'sound/sfx_E9.snd' 
Sfx_EA: 
		incbin 'sound/sfx_EA.snd'
Sfx_EB: 
		incbin 'sound/sfx_EB.snd'
Sfx_EC: 
		incbin 'sound/sfx_EC.snd'
Sfx_ED: 
		incbin 'sound/sfx_ED.snd'
Sfx_EE: 
		incbin 'sound/sfx_EE.snd'
Sfx_EF: 
		incbin 'sound/sfx_EF.snd'
Sfx_F0: 
		incbin 'sound/sfx_F0.snd'
;===============================================================================
; Sound Driver
; [ End ]
;=============================================================================== 
		
		 
