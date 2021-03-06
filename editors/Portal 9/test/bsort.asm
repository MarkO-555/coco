* QUICKER BUBBLE SORT
* this bubble sort takes into account that on each pass
* the highest value always sinks to the bottom, so we
* don't need to scan the whole screen each time, but
* rather 1 byte less on each pass

BURNADDR	equ	$FF80
BURNDATA	equ	$FF82
BURNCTRL	equ	$FF83

BUFFSTART	equ	32768
BUFFEND		equ	40960

start		ldx	BUFFSTART
		ldy	#0
loop		lda	,x+
		sty	BURNADDR
		sta	BURNDATA
write_wait	ldb	BURNDATA
		andb	#128
		bne	write_wait
		cmpx	BUFFEND
		blo	loop
		rts
		end
