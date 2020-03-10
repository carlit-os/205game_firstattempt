; #########################################################################
;
;   lines.asm - Assembly file for CompEng205 Assignment 2
;   
;   Author: Carlos Moran NetID: cam7825
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine PROC USES ebx esi edi ecx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD
	LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, error:DWORD, curr_x:DWORD, curr_y:DWORD, prev_error:DWORD
	;; Place your code here
	 
    ;;initialize the local variables to hold 0 instead of whatver is on the stack
	;;xor eax eax is better than 'mov eax,0' in performance 
	xor eax, eax
	mov delta_x, eax 
	mov delta_y, eax
	mov error, eax
	mov inc_y, eax
	mov inc_x, eax
	mov edi, eax

	mov ebx, x1
	;; x1-x0 stored in ecx (intended for ebx)
	sub ebx, x0
	jns ABSX
	neg ebx
ABSX: ;;after this point ebx holds abs(delta x)
	mov delta_x,ebx


	mov esi, y1
	;;y1-y0 stored in esi
	sub esi, y0
	jns ABSY
	neg esi
ABSY: ;;after this point esi holds abs(delta y)
	mov delta_y,esi

;;sets the inc variables
	mov eax,x0
	cmp eax,x1
	jge ELX
	mov inc_x,1
	jmp CONTX
ELX:
	mov inc_x,-1
CONTX:
    ;;mov ecx, inc_x
    ;;sets the y inc
	mov eax,y0
	cmp eax,y1
	jge ELY
	mov inc_y,1
	jmp CONTY
ELY:
	mov inc_y,-1
CONTY:
	;;mov edi, inc_y

;
;;compares deltas
	mov ecx,delta_x
	cmp ecx, delta_y
	jle LSDLTS
	mov eax, ecx
	sar eax,1
	mov error,eax
	jmp CNTDLT
LSDLTS:
	mov eax, delta_y
	neg eax
	sar eax, 1
	mov error, eax
CNTDLT:
	mov ecx,0 ;;clears ecx	
;;after this point, error is calculated
    
	mov eax, x0
	mov curr_x, eax

	mov eax, y0
	mov curr_y, eax

	INVOKE DrawPixel, curr_x, curr_y, color
	;;eax is now used by invokes
	;;begin while loop
	jmp EVAL
DO:
	INVOKE DrawPixel, curr_x,curr_y,color
	mov edi, error ;;edi = error
	mov prev_error, edi
	
	;;if cond prev_error> - delt_x
	mov ebx, delta_x
	mov esi, delta_y ;;might not be needed
	neg ebx
	;;ebx now holds -delta_x

	cmp prev_error, ebx
	jle PSTDY
	;;if true
	sub error, esi ;;adds to negative
	;;curr_x = curr_x + inc_x
	mov ecx, inc_x
	add curr_x,ecx
PSTDY:

	;;if cond prev_error< delt_y
	mov ebx, delta_y
	mov esi, delta_x ;;might not be needed
	
	cmp prev_error, ebx
	jge PSTDX
	;;if true
	add error, esi ;;error+delt_x
	;;curr_x = curr_x + inc_x
	mov ecx, inc_y
	add curr_y,ecx
PSTDX:


EVAL:
	mov ecx, curr_x
	cmp ecx, x1 
	jne DO
	mov ecx, curr_y
	cmp ecx, y1
	jne DO
	
	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END
