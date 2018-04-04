 ; #########################################################################
      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include bitblt.inc    ; local includes for this file
; #########################################################################

.data

.code
start:
    invoke GetModuleHandle, NULL
    mov hInstance, eax

    invoke GetCommandLine
    mov CommandLine, eax
    
	invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT

    invoke ExitProcess,eax

; #########################################################################


WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

      ;====================
      ; Put LOCALs on stack
      ;====================

      LOCAL win_class			:WNDCLASSEX
      LOCAL msg					:MSG
      LOCAL win_width			:DWORD
      LOCAL win_height			:DWORD
      LOCAL win_coordX			:DWORD
      LOCAL win_coordY			:DWORD

      ;==================================================
      ; Fill WNDCLASSEX structure with required variables
      ;==================================================

	  ;loading icon
      invoke LoadIcon,hInst,500    ;icon id 500 
      mov win_class.hIcon, eax
	  mov win_class.hIconSm, eax

	  ;loading cursor
	  invoke LoadCursor,hInst,101	;cursor id 101
      mov win_class.hCursor,        eax

      szText szClassName,"Project_Class"

	  ;setting properties of win_class
      mov win_class.cbSize,         sizeof WNDCLASSEX
      mov win_class.style,          CS_BYTEALIGNWINDOW
      mov win_class.lpfnWndProc,    offset WndProc
      mov win_class.cbClsExtra,     NULL
      mov win_class.cbWndExtra,     NULL
      m2m win_class.hInstance,      hInst
      mov win_class.hbrBackground,  COLOR_BTNFACE+2			;background color
      mov win_class.lpszMenuName,   NULL
      mov win_class.lpszClassName,  offset szClassName

      invoke RegisterClassEx, ADDR win_class

      ;================================
      ; Centre window at following size
      ;================================

      mov win_width, 750
      mov win_height, 500
	  mov win_coordX, 0
	  mov win_coordY, 0

      invoke GetSystemMetrics,SM_CXSCREEN		;width of the screen of the primary display monitor in pixels
      invoke TopXY,win_width,eax
      mov win_coordX, eax

      invoke GetSystemMetrics,SM_CYSCREEN		;height of the screen of the primary display monitor in pixels
      invoke TopXY,win_height,eax
      mov win_coordY, eax

      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR szClassName,
                            ADDR szDisplayName,
                            WS_OVERLAPPEDWINDOW,
                            win_coordX,win_coordY,win_width,win_height,
                            NULL,NULL,
                            hInst,NULL
      mov   hWnd,eax

      invoke LoadMenu,hInst,600  ; menu ID
      invoke SetMenu,hWnd,eax

      invoke ShowWindow,hWnd,SW_MAXIMIZE
      invoke UpdateWindow,hWnd


      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    .WHILE TRUE 
        invoke GetMessage, addr msg, NULL, 0, 0 
		
        .if(getUserInp!=1)
			call gamePlay
		.endif
		.BREAK .IF (!eax) 
        invoke TranslateMessage, addr msg 
        invoke DispatchMessage, addr msg 
    .ENDW 

    return msg.wParam

WinMain endp

; #########################################################################
StaticImage proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    invoke CreateWindowEx,WS_EX_NOACTIVATE,
            ADDR statClass,lpText,
            WS_CHILD or WS_VISIBLE or SS_BITMAP,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

StaticImage endp

; #########################################################################
moveDown PROC

mov ecx,0
mov esi,99
.WHILE esi>9

.IF (BoardArr[esi]==0 && BoardArr[esi-10]>0)		;non consecutive zeros movedown
mov eax,0
mov al,BoardArr[esi-10]					;swapping
mov BoardArr[esi-10],0
mov BoardArr[esi],al
mov ecx,1

.ELSEIF (BoardArr[esi]==0 && BoardArr[esi-10]==0)	;consecutive zeros movedown
mov eax,esi
again:
sub eax,10
cmp BoardArr[eax],0
jne outJump
cmp eax,10
js outJump
jmp again
outJump:
mov ebx,0
mov bl,BoardArr[eax]					;swapping
mov BoardArr[esi],bl
mov BoardArr[eax],0
mov ecx,1

.ENDIF
dec esi
.ENDW
mov eax,ecx
RET
moveDown ENDP

; ##################################################################################
popPairs PROC

mov esi,0
.WHILE esi < 100		;checking for horizontal pairs

movzx eax,BoardArr[esi]
.IF ((BoardArr[esi+1]==al)&&(BoardArr[esi+2]==al))
.WHILE(BoardArr[esi]==al)
mov ebx,eax
mov ecx,10
mov edx,0
mul ecx
mov BoardArr[esi],al
inc esi

mov eax,esi
div ecx
.IF edx==0
jmp breakloop
.ENDIF 

mov eax,ebx
.ENDW	
.ELSE
inc esi
mov eax,0
mov edx,0
mov ebx,0
mov eax,esi
mov ebx,10
div ebx
.IF(edx>7)
inc eax
mul ebx
mov esi,eax
.ENDIF
breakloop:
.ENDIF
.ENDW

mov esi,0
.WHILE esi < 100		;checking for vertical pairs

movzx eax,BoardArr[esi]		;checking already paired values
.IF eax<=Ctype
mov ecx,10
mul ecx
mov ecx,eax
.ELSE
mov ecx,10
div ecx
mov ecx,eax
.ENDIF
movzx eax,BoardArr[esi]

.IF ((BoardArr[esi+10]==al || BoardArr[esi+10]==cl)&&(BoardArr[esi+20]==al || BoardArr[esi+20]==cl))
mov ebx,esi
.WHILE(BoardArr[ebx]==al || BoardArr[ebx]==cl)
push eax
mov edx,10
mul edx
mov BoardArr[ebx],al
add ebx,10
pop eax
.ENDW	
.ENDIF
inc esi
.ENDW

;;;;popping values;;;;
mov esi,0
.WHILE esi < 100
mov ebx,Ctype
.IF(BoardArr[esi]>bl)
mov BoardArr[esi],0
inc score_count
mov eax,1
.ENDIF
inc esi
.ENDW

RET
popPairs ENDP


; #########################################################################
genNewCandies PROC

invoke GetTickCount
invoke nseed,eax

mov esi,0
.WHILE esi<100

.IF (BoardArr[esi]==0)
	invoke nrandom,6
	inc eax
	mov BoardArr[esi],al
.ENDIF

inc esi
.ENDW

RET
genNewCandies ENDP
; ########################################################################
swap PROC

mov eax,0
mov ebx,0
mov ecx,0
mov al,Inp1
mov bl,Inp2
mov dl, BoardArr[eax]
mov cl, BoardArr[ebx]
mov BoardArr[eax],cl
mov BoardArr[ebx],dl

RET
swap ENDP

; ########################################################################
checkPair PROC
mov eax,0
mov ebx,0
mov ecx,0
mov esi,0

call swap			;swapping values

.WHILE esi < 99		;checking for pairs

movzx eax,BoardArr[esi]
.IF ((BoardArr[esi+1]==al) &&(BoardArr[esi+2]==al))
mov eax,0
mov ecx,10
mov edx,0
mov eax,esi
div ecx
cmp edx,7
.IF edx<=7
mov eax,1
jmp found
.ENDIF
;jbe found
inc esi
.ELSEIF ((BoardArr[esi+10]==al) &&(BoardArr[esi+20]==al))
mov eax,1
jmp found
.ELSE
inc esi
.ENDIF
.ENDW
mov eax,0
call swap	;if no pairs found then revert swap
RET
found:		;if found kepp swap
mov eax,1
RET
checkPair ENDP

; ########################################################################
checkMove PROC
mov eax,0
mov al,Inp1
sub al,Inp2

.IF (eax==1 || eax==255)	;checking for horizontal swap
	mov eax,0				;inner check to prevent last col and first col swap
	mov ecx,0
	mov cl,10
	mov al, Inp1
	div cl
	mov bl,al
	mov eax,0
	mov cl,10
	mov al, Inp2
	div cl
	cmp al,bl
	jne endCheckMove		;wrong input end move
	jmp check2				;first check pass

.ELSEIF (eax==10 || eax==246)
	jmp check2			;first check pass

.ELSE
mov eax,0
jmp endCheckMove		;first check failed, wrong input

.ENDIF
 
check2:				;second check, pair check
call checkPair
RET
endCheckMove:
mov eax,0
RET
checkMove ENDP

; ########################################################################
;update_maze PROC hWin:DWORD

;	ret
;update_maze ENDP

;#############################################################################

getInput PROC
	.IF Inp1==100
		invoke Beep, 1000, 300  ;beep for testing
		movzx ecx,btnID
		mov Inp1,cl
		;mov btnID,100
	.ELSEIF Inp2==100
		invoke Beep, 600, 300  ;beep for testing
		movzx ecx,btnID
		mov Inp2,cl
		mov getUserInp,2
	.ENDIF
RET
getInput ENDP

;#############################################################################
gamePlay PROC
	LOCAL retAdd:DWORD
	LOCAL hWin:DWORD
	pop ecx
	mov retAdd,ecx

	.if(getUserInp==2)
		call checkMove
		mov Inp1,100
		mov Inp2,100
		.if(eax==0)
			mov getUserInp,1
		.elseif(eax==1)
			mov getUserInp,0
			dec moves
		.endif
	.endif
		.if(data==0)
			call genNewCandies
			mov data,1
			jmp printNow

		.elseif(data==1)
			call popPairs
			.IF eax!=1
				mov getUserInp,1
			.ENDIF
			mov data,2
			jmp printNow

		.elseif(data==2)
			call moveDown
			mov data,0
			jmp printNow
		.endif
	
		printNow: 
		mov paint,1
		invoke InvalidateRect, hWnd, NULL, FALSE
		invoke UpdateWindow,hWnd
		
		;.IF(eax==0)
		;call getInput
		;	call checkMove
		;.ENDIF

	mov ecx,retAdd
	push ecx
ret
gamePlay ENDP
;#############################################################################


end start
