; #########################################################################
;
;   stars.asm - Assembly file for CompEng205 Assignment 1
;   
;   Name:Carlos Moran
;   NetID:cam7825
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here



.CODE

DrawStarField proc

	;; Place your code here

      ;; Each line is one star
      ;; They are put into groups of four
      
      invoke DrawStar, 10, 10                      		
      invoke DrawStar, 20, 20
      invoke DrawStar, 220, 45
      invoke DrawStar, 200, 40
      
     
      invoke DrawStar, 600, 400   
      invoke DrawStar, 555, 345
      invoke DrawStar, 100, 100
      invoke DrawStar, 115, 115

      invoke DrawStar, 400, 301
      invoke DrawStar, 424, 315                      		
      invoke DrawStar, 201, 201
      invoke DrawStar, 175, 180

      invoke DrawStar, 600, 40                      		
      invoke DrawStar, 625, 50
      invoke DrawStar, 505, 408
      invoke DrawStar, 123, 321



      
      
	ret  			; Careful! Don't remove this line
DrawStarField endp



END
