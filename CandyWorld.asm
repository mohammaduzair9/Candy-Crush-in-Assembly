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

end start
