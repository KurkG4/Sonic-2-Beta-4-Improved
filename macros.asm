; ---------------------------------------------------------------------------
; stop the Z80
; ---------------------------------------------------------------------------

stopZ80:	macro
		move.w	#$100,($A11100).l
	.wait:	btst	#0,($A11100).l
		bne.s	.wait
		endm

; ---------------------------------------------------------------------------
; reset the Z80
; ---------------------------------------------------------------------------

resetZ80:	macro
		move.w	#$100,($A11200).l
		endm

resetZ80a:	macro
		move.w	#0,($A11200).l
		endm

; ---------------------------------------------------------------------------
; start the Z80
; ---------------------------------------------------------------------------

startZ80:	macro
		move.w	#0,($A11100).l
		endm
		
; macro for declaring a "main level load block" (MLLB)
levartptrs macro plc1,plc2,palette,art,map16x16,map128x128
	dc.l (plc1<<24)|art
	dc.l (plc2<<24)|map16x16
	dc.l (palette<<24)|map128x128
    endm
    
; macro for a pattern load request
plreq macro toVRAMaddr,fromROMaddr
	dc.l	fromROMaddr
	dc.w	toVRAMaddr
    endm