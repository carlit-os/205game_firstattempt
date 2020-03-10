; #########################################################################
;
;   blit.asm - Assembly file for CompEng205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA

	;; If you need to, you can place global variables here
	
.CODE

DrawPixel PROC USES edx ecx x:DWORD, y:DWORD, color:DWORD
	;remember its 640 by 480
	cmp x, 0	;look for borders on x
	jl done
	cmp x, 640
	jge done

	;look for borders on y
	cmp y, 0
	jl done
	cmp y, 480
	jge done
	
	mov ecx, color		
	mov eax, y		
	mov edx, 640		 
	mul edx
	add eax, x
	add eax, ScreenBitsPtr  ;640*y + x +ScreenBitsPtr
	mov BYTE PTR[eax], cl   ;colors stored as bytes
done:
	ret 			; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES ebx ecx edx edi  ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
	LOCAL ii:DWORD, transcol:BYTE, x0:DWORD, x1:DWORD, y0:DWORD, y1:DWORD
	
	;initializers
	mov ecx, ptrBitmap  	
	mov ii, 0
	mov bl, (EECS205BITMAP PTR [ecx]).bTransparent
	mov transcol, bl		;bl gets t color
	mov ebx, xcenter
	mov x0, ebx		;store xcenter in x0
	mov x1, ebx		;same for x1
	mov ebx, (EECS205BITMAP PTR[ecx]).dwWidth
	sar ebx, 1  		;half
	sub x0, ebx		;set x 
	add x1, ebx		;add xcenter by half width, get x end point, store in x1
	mov ebx, ycenter	;same for y
	mov y0, ebx
	mov y1, ebx
	mov ebx, (EECS205BITMAP PTR [ecx]).dwHeight
	sar ebx, 1
	sub y0, ebx
	add y1, ebx


xVals:

	mov ebx, x1
	cmp x0, ebx		;check if x0 < x1
	jge yVals		;if x0 >= x1, update y
	mov ebx, (EECS205BITMAP PTR [ecx]).lpBytes
	mov edi, ii
	mov dl, BYTE PTR [ebx + edi]
	mov al, transcol
	cmp dl, al		;compare the color to transparent color
	je incrX		;if equal, break, else, invoke
	invoke DrawPixel, x0, y0, [ebx + edi]

incrX:
	inc ii;
	inc x0			;increment x0, jmp back to xVals for next column
	jmp xVals	
	
yVals:
	inc y0
	mov ebx, y0
	cmp ebx, y1
	jge DONE		;if y0 >= y1, the loop is finished
	mov ebx, (EECS205BITMAP PTR [ecx]).dwWidth	
	sub x0, ebx		;else, reset x0 and start the xVals for this new y0
	jmp xVals

DONE:	 
	ret 			; Don't delete this line!!!	
BasicBlit ENDP

RotateBlit PROC USES ecx edx ebx esi edi  lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	LOCAL xInput:DWORD, yInput:DWORD, transcol:BYTE,deltX:DWORD, deltY:DWORD, dstWidth:DWORD, dstHeight:DWORD, dstX:DWORD, dstY:DWORD, srcX:DWORD, srcY:DWORD, jj:DWORD
	
	
	mov jj, 0
	invoke FixedCos, angle
	mov ecx, eax			;ecx gets cos
	invoke FixedSin, angle	
	mov edi, eax			;edi gets sin
	
	mov esi, lpBmp
	mov bl, (EECS205BITMAP PTR [esi]).bTransparent
	mov transcol, bl		

	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	imul ecx
	mov deltX, eax
	sar deltX, 1			;half
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	imul edi
	sar eax, 1			;half
	sub deltX, eax			
	
	
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	imul ecx
	mov deltY, eax
	sar deltY, 1        ;half
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	imul edi
	sar eax, 1          ;half
	add deltY, eax 
									
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	add eax, (EECS205BITMAP PTR [esi]).dwHeight
	mov dstWidth, eax		
	mov dstHeight, eax
	
	neg eax          ;make negative
	mov dstX, eax		
	mov dstY, eax		
	
	sar deltY, 16		;get out of fixed p
	sar deltX, 16

	jmp checkX
yVals:	
	mov eax, dstX	
	imul ecx
	mov srcX, eax
	mov eax, dstY
	imul edi
	add srcX, eax		;X*cos + Y*sin
	
	mov eax, dstY
	imul ecx
	mov srcY, eax
	mov eax, dstX
	imul edi
	sub srcY, eax		;Y*cos - X*sin
	
	sar srcX, 16		;get out of fixed p
	sar srcY, 16
	
	cmp srcX, 0		
	jl incrY
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	cmp srcX, eax		;srcX < dwWidth
	jge incrY
	
	cmp srcY, 0		
	jl incrY
	
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	cmp srcY, eax		
	jge incrY

	;chekc for x bounds
	mov eax, xcenter
	add eax, dstX
	sub eax, deltX
	cmp eax, 0
	jl incrY		
	mov eax, xcenter
	add eax, dstX
	sub eax, deltX
	cmp eax, 639
	jge incrY		

	;check for y bounds
	mov eax, ycenter
	add eax, dstY
	sub eax, deltY
	cmp eax, 0
	jl incrY		
	mov eax, ycenter
	add eax, dstY
	sub eax, deltY
	cmp eax, 479
	jge incrY		

	mov eax, (EECS205BITMAP PTR [esi]).dwWidth	;grab color
	mov edx, srcY					
	imul edx
	add eax, srcX
	add eax, (EECS205BITMAP PTR [esi]).lpBytes
	mov dl, BYTE PTR [eax]
	cmp dl, transcol					;check for transparen
	je incrY
	
	mov ebx, xcenter				
	add ebx, dstX
	sub ebx, deltX
	mov xInput, ebx
	mov ebx, ycenter
	add ebx, dstY
	sub ebx, deltY
	mov yInput, ebx
	invoke DrawPixel, xInput, yInput, BYTE PTR [eax]
incrY:
	inc dstY

checkY:
	mov eax, dstY
	cmp eax, dstHeight
	jl yVals
	inc dstX

checkX:


        mov eax, dstHeight
	neg eax
        mov dstY, eax	
	mov eax, dstX
	cmp eax, dstWidth
	jl checkY

	ret 			; Don't delete this line!!!		
RotateBlit ENDP




END
