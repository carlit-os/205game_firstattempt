; #########################################################################
;
;   trig.asm - Assembly file for CompEng205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943            	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)


	;; If you need to, you can place global variables here
	
.CODE

FixedSin PROC USES edx ecx angle:FXPT
	local negAng:DWORD

	;initializers
	mov negAng, 0
    mov edx, angle   ;edx gets input angle

	;check for lower bound
	cmp edx, 0        
	je Q1
	;otherwise check for out of bounds
underBound:              ;maps angle forward to equiv angle
	cmp edx, 0
	jge overBound
	add edx, TWO_PI
	jmp underBound

overBound:			;maps angle backwards to equiv angle
	cmp edx, TWO_PI
	jl inRange		
	sub edx, TWO_PI 
	jmp overBound
	
inRange:			
	cmp edx, PI     ;maps angle to equiv +y values if needed
	jl topHalf
	sub edx, PI
	xor negAng, 1
	jmp inRange

	
topHalf:			   ;maps angle to equiv +x values if needed
	cmp edx, PI_HALF
	je piOtwo
	cmp edx, PI_HALF
	jl Q1
	mov ecx, PI
	sub ecx, edx
	mov edx, ecx
	jmp topHalf

piOtwo:
	mov eax, 1
	shl eax, 16
	ret

Q1:			
	mov eax, edx
	mov edx, PI_INC_RECIP
	imul edx                ;angle*256/pi
	
	xor eax, eax         ;clean out upper eax
	mov ax, WORD PTR[SINTAB + edx*2]    ;read the sin table
	
	cmp negAng, 0         ;check if mapped from negative angle
	je done
	neg eax
done:	
	ret			; Don't delete this line!!!
FixedSin ENDP 
FixedCos PROC USES edx angle:FXPT
	mov edx, angle		
	add edx, PI_HALF       ;cos (x) = sin (x + Pi/2)
	invoke FixedSin, edx
	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
