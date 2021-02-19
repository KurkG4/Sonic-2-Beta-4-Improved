;===============================================================================
; Object 0x7C - Big Ring Flash (Special Stage Access)	
;	Unused - Sonic 1 LeftOver
; [ Begin ]
;===============================================================================	
loc_FFB6:
		moveq	#0,d0
		move.b	routine(a0),d0
		move.w	loc_FFC4(pc,d0),d1
		jmp	loc_FFC4(pc,d1)
loc_FFC4:
		dc.w	loc_FFCA-loc_FFC4
		dc.w	loc_FFF8-loc_FFC4
		dc.w	loc_10068-loc_FFC4
loc_FFCA:
		addq.b	#2,routine(a0)
		move.l	#Big_Ring_Flash_Mappings,4(a0) 
		move.w	#$2462,art_tile(a0)
		bsr	ModifySpriteAttr_2P	
		or.b	#4,render_flags(a0)
		move.b	#0,priority(a0)
		move.b	#$20,width_pixels(a0)
		move.b	#$FF,mapping_frame(a0)
loc_FFF8:
		bsr.s	loc_10012
		move.w	x_pos(a0),d0
		and.w	#$FF80,d0
		sub.w	(Camera_X_pos_coarse).w,d0
		cmp.w	#$280,d0
		bhi.w	deleteObject
		bra.w	displaySprite
loc_10012:
		subq.b	#1,anim_frame_duration(a0)
		bpl.s	loc_10058
		move.b	#1,anim_frame_duration(a0)
		addq.b	#1,mapping_frame(a0)
		cmp.b	#8,mapping_frame(a0)
		bcc.s	loc_1005A
		cmp.b	#3,mapping_frame(a0)
		bne.s	loc_10058
		move.l	objoff_3C(a0),a1
		move.b	#6,routine(a1)
		move.b	#$1C,(MainCharacter+anim).w
		move.b	#1,($FFFFF7CD).w
		lea	(MainCharacter).w,a1
		bclr	#1,$2B(a1)
		bclr	#0,$2B(a1)
loc_10058:
		rts
loc_1005A:
		addq.b	#2,routine(a0)
		move.w	#0,(MainCharacter).w
		addq.l	#4,sp
		rts
loc_10068:
		bra.w	deleteObject	
;=============================================================================== 
; Object 0x7C - Big Ring Flash (Special Stage Access)	
;	Unused - Sonic 1 LeftOver
; [ End ]
;=============================================================================== 