;===============================================================================
; Object 0x4B - Big Ring (Special Stage Access)	
;	Unused - Sonic 1 LeftOver
; [ Begin ]
;===============================================================================	
loc_FEF2:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	loc_FF00(pc,d0),d1
		jmp	loc_FF00(pc,d1)
loc_FF00:
		dc.w	loc_FF08-loc_FF00
		dc.w	loc_FF56-loc_FF00
		dc.w	loc_FF74-loc_FF00
		dc.w	loc_FFB2-loc_FF00
loc_FF08:
		move.l	#Big_Ring_Mappings,4(a0) 
		move.w	#$2400,art_tile(a0)
		bsr.w	ModifySpriteAttr_2P
		or.b	#4,render_flags(a0)
		move.b	#$40,width_pixels(a0)
		tst.b	render_flags(a0)
		bpl.s	loc_FF56
		cmp.b	#6,(Got_Emerald).w
		beq.w	loc_FFB2
		cmp.w	#50,(Ring_count).w
		bcc.s	loc_FF40
		rts
loc_FF40:
		addq.b	#2,routine(a0)
		move.b	#2,priority(a0)
		move.b	#$52,collision_flags(a0)
		move.w	#$C40,($FFFFF7BE).w
loc_FF56:
		move.b	(Rings_anim_frame).w,$1A(a0)
		move.w	x_pos(a0),d0
		and.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmp.w	#$280,d0
		bhi.w	deleteObject
		bra.w	displaySprite
loc_FF74:
		subq.b	#2,routine(a0)
		move.b	#0,collision_flags(a0)
		bsr.w	SingleObjectLoad
		bne.w	loc_FFA6
		move.w	x_pos(a0),x_pos(a1)
		move.w	y_pos(a0),y_pos(a1)
		move.l	a0,objoff_3C(a1)
		move.w	(Object_RAM+x_pos).w,d0
		cmp.w	x_pos(a0),d0
		bcs.s	loc_FFA6
		bset	#0,render_flags(a1)
loc_FFA6:
		move.w	#$C3,d0
		jsr	Play_Unknow
		bra.s	loc_FF56
loc_FFB2:
		bra.w	deleteObject
;=============================================================================== 
; Object 0x4B - Big Ring (Special Stage Access)	
;	Unused - Sonic 1 LeftOver
; [ End ]
;===============================================================================	