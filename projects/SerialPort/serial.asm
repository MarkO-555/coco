* Communicates with the serial port on the expansion board.
* See the 6551 documentation for information on the UART.
* 
* Currently, the UART answers on the following ports:
* I/O Register:		FF6C
* Status		FF6D
* Command		FF6E
* Control		FF6F



SER_IO		equ		$FF6C
SER_STA		equ		$FF6D
SER_CMD		equ		$FF6E
SER_CTRL	equ		$FF6F


*--------------------------------------------------------------------------------
* Initalizes UART in standard communication mode.
* Default init is for 1200-N-8  (0001 1000), no interrupts, tx/rx enabled and
* DTR* ready. (0000 1011)
*--------------------------------------------------------------------------------
serial_init		lda		#11			(0000 1011)
				sta		SER_CMD
				lda		#24			(0001 1000)
				sta		SER_CTRL
				rts


*--------------------------------------------------------------------------------
* Writes a character to the serial port.  Waits for rx ready and DTR* from client.
* A register contains the byte to be written to the serial port.
*--------------------------------------------------------------------------------
ser_chr_out		ldb		SER_CMD
				orb		#9		(set tx and DTR ready)
				stb		SER_CMD
_out_wait		ldb		SER_STA
				andb	#48		(see if tx register empty and carrier detected)
				bne		_out_wait
				sta		SER_IO	(send data to serial port)
				rts


*--------------------------------------------------------------------------------
* Receives a character from the serial port.  Waits for the data if it's not
* received yet.  A contains character received.
*--------------------------------------------------------------------------------
ser_chr_in		ldb		SER_CMD
				orb		#9		(set tx and DTR ready)
				stb		SER_CMD
_in_wait		ldb		SER_STA
				andb	#8		(see if receiver ready)
				beq		_in_wait
				lda		SER_IO
				rts


*--------------------------------------------------------------------------------
* Converts the value in the A register from a numerical baud rate, to a binary
* baud rate select for the UART.  For example, to convert from 300 baud, load
* A with a 3.  To convert from 9600 baud, load A with 96.
*--------------------------------------------------------------------------------
_cvrt_tobaud	cmpa	#3
				beq		_300
				cmpa	#12
				beq		_1200
				cmpa	#24
				beq		_2400
				cmpa	#48
				beq		_4800
				cmpa	#96
				beq		_9600
				cmpa	#192
				beq		_19200
				bra		_1200			no matches found, so return default of 1200 baud
_300			lda		#6
				rts
_1200			lda		#8
				rts
_2400			lda		#10
				rts
_4800			lda		#12
				rts
_9600			lda		#14
				rts
_19200			lda		#15
				rts


*--------------------------------------------------------------------------------
* Register Documentation for 6551
*
* - - - - - - - - - - - - - - - - - - - - -
*  Status Register Bits
*	7 - Interupt flag (0 = no interupt)
*	6 - DSR (0 = ready)
*	5 - DCD (0 = detected)
*	4 - Tx reg empty (0 = not empty)
*	3 - Rx reg full (0 = not full)
*	2 - Overrun (0 = none)
*	1 - Framing err (0 = no error)
*	0 - Parity err (0 = no error)
*
* - - - - - - - - - - - - - - - - - - - - -
*  Command Register
*	Bits 7-6	Parity Mode Control
*	 7	6		Parity
*	 0	0		Odd parity tx/rx
*	 0	1		Even parity tx/rx
*	 1	0		Mark parity tx, check disabled
*	 1	1		Space parity bit tx, check disabled
*	
*	Bit 5		Parit Mode Enable
*	  0			Disabled, no parity bit generated, check disabled
*	  1			Parity enabled
*
*	Bit 4		Reciever Echo Mode
*	  0			Normal
*	  1			Echo
*
*	Bits 3-2	Transmitter Interrupt Control
*	 3	2		Mode
*	 0	0		RTS* = high, tx disabled
*	 0	1		RTS* = low, tx interrupt enabled
*	 1	0		RTS* = low, tx interrupt disabled
*	 1	1		RTS* = low, tx interrupt disabled, tx break on TxD
*
*	Bit 1		Receiver Interup Request
*	  0			IRQ* enabled (rx)
*	  1			IRQ* disabled (rx)
*
*	Bit 0		Data Terminal Ready
*	  0			DTR* high (not ready)
*	  1			DTR* low (ready)
*
* - - - - - - - - - - - - - - - - - - - - -
*  Control Register Bits
*	Bit 7		Stop Bit Number
*	  0			1 stop bit
*	  1			2 stop bits
*	  1			1.5 stop bits (for WL = 5 and no parity)
*	  1			1 stop bit (for WL = 8 and parity)
*
*	Bits 6-5	Word Length
*	 6	5		# of bits
*	 0	0		8
*	 0	1		7
*	 1	0		6
*	 1	1		5
*
*	Bit 4		Receiver Clock Source
*	  0			External Clock
*	  1			Programmed baud rate
*
*	Bits 3-0	Baud Rate Select
*	 3210		Baud
*	 0000		16x external clock
*	 0001		50
*	 0010		75
*	 0011		109.92
*	 0100		134.58
*	 0101		150
*	 0110		300
*	 0111		600
*	 1000		1200
*	 1001		1800
*	 1010		2400
*	 1011		3600
*	 1100		4800
*	 1101		7200
*	 1110		9600
*	 1111		19200
*
*--------------------------------------------------------------------------------
