[org 0x0100]
jmp start


soundd:
	push bp
	mov bp, sp
	push ax

	mov al, 182
	out 0x43, al
	mov ax, [bp + 4]   ; frequency
	out 0x42, al
	mov al, ah
	out 0x42, al
	in al, 0x61
	or al, 0x03
	out 0x61, al
call delay
call delay
call delay
call delay
call delay
call delay
	in al, 0x61

	and al, 0xFC
	out 0x61, al

	pop ax
	pop bp
  ret 2



clearscreen:
    push ax
    push es
    push di
    push cx
    mov ax,0xb800
    mov es,ax
    xor di,di
    mov cx,2000
   mov ah,1011100b
    mov al,0x20
    rep stosw
    pop cx
    pop di
    pop es
    pop ax
    ret

printScoresMoves:

     pusha
 mov ah,0x13
 mov al,1
   mov bh,0
      mov bl,00110001b
   mov dx,0x0c45
   mov cx,5
   push cs
   pop es
   mov bp,scoreMessage
   int 0x10 
    mov ax,0xb800
  mov es,ax
  mov di,2070
  mov ah,00111111b
  mov al,[score]
  mov word[es:di],ax
popa
ret

setDirection:
    pusha
    ; mov word[row2],0
    ; mov word[col2],0
    up:
    cmp word[row1],0
    je down
    cmp byte[direction],0x48
    jne down
    mov bx,[row1]
    sub bx,1
    mov word[row2],bx
    mov bx,[col1]
    mov word[col2],bx
    jmp exitSettingDirection

    down:
    cmp  word[row1],5
    je right
    cmp byte[direction],0x50
    jne  right
    mov bx,[row1]
    add bx,1
    mov word[row2],bx
    mov bx,[col1]
    mov word[col2],bx
    jmp exitSettingDirection
    

    right:
    cmp word[col1],5
    je left
    cmp byte[direction],0x4d
    jne left
    mov bx,[row1]
    mov word[row2],bx
    mov bx,[col1]
    add bx,1
    mov word[col2],bx
    jmp exitSettingDirection


    left:
    cmp word[col1],0
    je exitSettingDirectionSettingValidMoveFalse
    cmp byte[direction],0x4b
    jne exitSettingDirectionSettingValidMoveFalse
    mov bx,[row1]
    mov word[row2],bx
    mov bx,[col1]
    sub bx,1
    mov word[col2],bx
    jmp exitSettingDirection

    exitSettingDirectionSettingValidMoveFalse:
    mov word[validMove],0

    exitSettingDirection:
    popa
ret
printGameInterFace:
   
    call clearscreen
    call printBoundary
    call printBoxes  


ret
printBoundary:
    pusha

    mov ax,0xb800
    mov es,ax
    mov di,0
    mov ah,00011011b
    mov al,0x4
    printBoundaryLoop1:
    mov word[es:di],ax
    add di,2
    cmp di,158
    jne printBoundaryLoop1

    printBoundaryLoop2:
    mov word[es:di],ax
    add di,160
    cmp di,3998
    jne printBoundaryLoop2


    printBoundaryLoop3:
    mov word[es:di],ax
    sub di,2
     cmp di,3840
     jne printBoundaryLoop3

    printBoundaryLoop4:
    mov word[es:di],ax
    sub di,160
    cmp di,0
    jne printBoundaryLoop4
    
    popa
ret
initilizeCandyCrush:
    pusha
    mov di,0
    i1:
    call GenerateRandomNumber
    mov si,dx
    mov ah,0
    mov al,[candies+si]
    call delay
    mov word[gameBoard+di],ax
    add di,2
    cmp di,74
    jne i1



    popa

ret

printBoxes:
call clearscreen
call printBoundary

    pusha
    mov ax,0xb800
    mov es,ax
    mov cx,6
    mov di,220
    mov ah,00111111b
    mov al,48
    loop1:
    
        mov word[es:di],ax
        add al,1
        add di,10
    loop loop1

    mov di,534
mov al,48
mov cx,6
    loop2:
    mov word[es:di],ax
    add al,1
    add di,640
    loop loop2


    mov ah,00011001b
    mov al,0x20
    mov di,378
    mov cx,6
    outerLoop:
        mov dx,6
        innerLoop:
        mov word[es:di],ax
        mov word[es:di+2],ax
        mov word[es:di+4],ax
        mov word[es:di+6],ax
        mov word[es:di+160],ax
        mov word[es:di+162],ax
        mov word[es:di+164],ax
        mov word[es:di+166],ax
        add di,10
        dec dx
        jnz innerLoop

    sub di,60
    add di,640
    dec cx
    jnz outerLoop
        mov ax,0xb800
  mov es,ax
  mov di,540
  mov cx,8
  mov si,0
  mov dx,6
  printOuterLoop:
     mov cx,6
     printInnerLoop:
      mov ax,[gameBoard+si]
      add si,2
      call setAttribute   ; in bh
      mov word[es:di],bx
      add di,10
      sub cx,1
      jnz printInnerLoop
    sub di,60
    add di,640
    dec dx
    jnz printOuterLoop
call printScoresMoves
    popa
ret

validateMove:
    pusha
    mov word[validMove],0
    
    ; here comes the logic to validatee move
   upBound:
   cmp byte[row1],0  ;checking row1 out of bounds
   jl exitValidMoveSettingValidMoveFalse
   jmp downBound

    downBound:
    cmp byte[row1],5
    jg exitValidMoveSettingValidMoveFalse
    jmp rightBound


    rightBound:
   cmp byte[col1],5   ; checking col1 out of bounds
    jg exitValidMoveSettingValidMoveFalse
    jmp leftBound


   leftBound:
   cmp byte[col1],0
   jl exitValidMoveSettingValidMoveFalse
   jmp exitValidateMoveSettingValidMoveTrue


    
    exitValidateMoveSettingValidMoveTrue:
    mov word[validMove],1
    call setDirection
    jmp exit1
    exitValidMoveSettingValidMoveFalse:
    mov word[validMove],0
    jmp exit1
    

    exit1:
    popa

ret
checkPatternOfThreeInRows:
    pusha
    mov word[isPatternFound],0
    cmp ax,cx
    jne exitcheckPatternOfThreeInRows
    cmp ax,dx
    jne exitcheckPatternOfThreeInRows
    call makeSound
    mov byte[patternFoundArray+0],1
    mov word[isPatternFound],1
    add word[score],1
    call GenerateRandomNumber
    mov si,dx
    mov ah,0
    mov al,[candies+si]
    mov word[gameBoard+bx],ax
    call GenerateRandomNumber
    mov si,dx
    mov ah,0
    mov al,[candies+si]
     mov word[gameBoard+bx+2],ax
    call GenerateRandomNumber
    mov si,dx
    mov ah,0
    mov al,[candies+si]
    mov word[gameBoard+bx+4],ax

    exitcheckPatternOfThreeInRows:
    popa

 

ret
removeAllOccurences:
pusha
  mov bx,0
  mov  dx,[recurringElement]

  remove1:
  add si,2
  mov cx,[gameBoard+bx]
  cmp cx,dx
  jne searchForware
  push 2000
  call soundd
  push 3000
  call soundd
  push 500
  call soundd
   push ax
   call GenerateRandomNumber
   
   mov di,dx
   mov ah,0
   mov al,[candies+di]
   mov word[gameBoard+bx],ax
   pop ax

  searchForware:
  cmp di,72
  jne remove1
popa
ret


checkPatternOfThreeInCols:
    pusha
    ;mov bx,0
    mov word[isPatternFound],0
    cmp ax,cx
    jne exitcheckPatternOfThreeInCols
    cmp ax,dx
    jne exitcheckPatternOfThreeInCols
    call makeSound
    mov byte[patternFoundArray+1],1
    mov word[isPatternFound],1
    add word[score],1
     call GenerateRandomNumber
    mov si,dx
    mov ah,0
    mov al,[candies+si]
    mov word[gameBoard+bx],ax
    call GenerateRandomNumber
    mov si,dx
    mov ah,0
    mov al,[candies+si]
    mov word[gameBoard+bx+12],ax
    call GenerateRandomNumber
    mov si,dx
    mov ah,0
    mov al,[candies+si]
    mov word[gameBoard+bx+24],ax



    exitcheckPatternOfThreeInCols:
    popa

ret
checkPatternOfFourInRows:
pusha
    mov word[patternDetectedFlag],0
 cmp ax,cx
 jne exitcheckPatternOfFourInRows
 cmp ax,dx
 jne exitcheckPatternOfFourInRows
 cmp ax,di
 jne exitcheckPatternOfFourInRows
 call makeSound
 mov word[recurringElement],ax
 call removeAllOccurences
 mov byte[patternFoundArray+2],1,
 mov word[isPatternFound],1
 add word[score],1
 call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+2],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+4],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+6],ax
 mov word[patternDetectedFlag],1

    exitcheckPatternOfFourInRows:
    popa
ret
checkPatternOfFourInCols:
pusha
 mov word[patternDetectedFlag],0
 cmp ax,cx
 jne exitcheckPatternOfFourInCols
 cmp ax,dx
 jne exitcheckPatternOfFourInCols
 cmp ax,di
 jne exitcheckPatternOfFourInCols
 call makeSound
 mov word[recurringElement],ax
 call removeAllOccurences
 mov byte[patternFoundArray+3],1
 add word[score],1
 call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+12],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+24],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+36],ax
 mov word[patternDetectedFlag],1
 exitcheckPatternOfFourInCols:
 popa
ret
checkPatternOfFiveInRows:
pusha
 mov word[patternDetectedFlag],0
 cmp ax,cx
 jne exitcheckPatternOfFiveInRows
 cmp ax,dx
 jne exitcheckPatternOfFiveInRows
 cmp ax,di
 jne exitcheckPatternOfFiveInRows
 cmp ax,si
 jne exitcheckPatternOfFiveInRows
 call makeSound
 mov byte[patternFoundArray+4],1
 add word[score],1
;  mov word[bombFlag],1
;  mov word[bombActivatorELement],ax
;  call applyBombFunction
 call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+2],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+4],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+6],ax
 mov word[patternDetectedFlag],1
 exitcheckPatternOfFiveInRows:
 popa
ret
checkPatternOfFiveInCols:
    pusha
    mov word[patternDetectedFlag],0
 cmp ax,cx
 jne exitcheckPatternOfFiveInCols
 cmp ax,dx
 jne exitcheckPatternOfFiveInCols
 cmp ax,di
 jne exitcheckPatternOfFiveInCols
 cmp ax,si
 jne exitcheckPatternOfFiveInCols
 call makeSound
 mov byte[patternFoundArray+5],1
 add word[score],1
;  mov word[bombFlag],1
;  mov word[bombActivatorELement],ax
;  call applyBombFunction
 call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+12],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+24],ax
  call GenerateRandomNumber
 mov si,dx
 mov ah,0
 mov al,[candies+si]
 mov word[gameBoard+bx+36],ax
 mov word[patternDetectedFlag],1
 
    exitcheckPatternOfFiveInCols:
    popa


ret
patternInRowsOf3:
    pusha  
    mov bx,0
    firstRow3:
    mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+2]
    mov dx,[gameBoard+bx+4]
    call checkPatternOfThreeInRows
    add bx,2
    cmp bx,8
    jne firstRow3
     mov bx,12
    secondRow3:
     mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+2]
    mov dx,[gameBoard+bx+4]
    call checkPatternOfThreeInRows
    add bx,2
    cmp bx,20
    jne secondRow3

    mov bx,24
    thirdRow3:
    mov ax,[gameBoard+bx]
     mov cx,[gameBoard+bx+2]
     mov dx,[gameBoard+bx+4]
    call checkPatternOfThreeInRows
    add bx,2
    cmp bx,32
    jne thirdRow3
    mov bx,36
    fourthRow3:
    mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+2]
    mov dx,[gameBoard+bx+4]
    call checkPatternOfThreeInRows
    add bx,2
    cmp bx,44
    jne fourthRow3
    mov bx,48
    fifthRow3:
      mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+2]
    mov dx,[gameBoard+bx+4]
    call checkPatternOfThreeInRows
    add bx,2
    cmp bx,56
    jne fifthRow3

    mov bx,60
    sixthRow3:
    mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+2]
    mov dx,[gameBoard+bx+4]
    call checkPatternOfThreeInRows
    add bx,2
    cmp bx,68
    jne sixthRow3

    popa
ret
patternInColsOf3:
    pusha
     mov bx,0
    firstCol3:
     mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+12]
    mov dx,[gameBoard+bx+24]
 
    call checkPatternOfThreeInCols   ; for columns
    add bx,12
    cmp bx,48
    jne firstCol3

    mov bx,2
    secondCol3:
     mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+12]
    mov dx,[gameBoard+bx+24]

    call checkPatternOfThreeInCols
    add bx,12
    cmp bx,50
    jne secondCol3


    mov bx,4
    thirdCol3:
      mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+12]
    mov dx,[gameBoard+bx+24]

    call checkPatternOfThreeInCols
    add bx,12
    cmp bx,52
    jne thirdCol3

    mov bx,6

    fourthCol3:
      mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+12]
    mov dx,[gameBoard+bx+24]

    call checkPatternOfThreeInCols
    add bx,12
    cmp bx,54
    jne fourthCol3

    mov bx,8
    fifthCol3:
      mov ax,[gameBoard+bx]
      mov cx,[gameBoard+bx+12]
    mov dx,[gameBoard+bx+24]
 
    call checkPatternOfThreeInCols
    add bx,12
    cmp bx,56
    jne fifthCol3

    mov bx,10
    sixthCol3:
      mov ax,[gameBoard+bx]
     mov cx,[gameBoard+bx+12]
    mov dx,[gameBoard+bx+24]

     call checkPatternOfThreeInCols
    add bx,12
    cmp bx,58
    jne sixthCol3


    popa
ret
patternInRowsOf4:
    pusha
    mov bx,0
    firstRow4:
 mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 call checkPatternOfFourInRows
 add bx,2
 cmp bx,6
 jne firstRow4

  mov bx,12
    secondRow4:
    mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 call checkPatternOfFourInRows
 add bx,2
 cmp bx,18
 jne secondRow4
    mov bx,24
    thirdRow4:

 
  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 call checkPatternOfFourInRows
 add bx,2
 cmp bx,30
 jne thirdRow4
    mov bx,36
    fourthRow4:
 

  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 call checkPatternOfFourInRows
 add bx,2
 cmp bx,42
 jne fourthRow4
 mov bx,48
    fifthRow4:
    


  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 call checkPatternOfFourInRows
 add bx,2
 cmp bx,54
 jne fifthRow4

    mov bx,60
    sixthRow4:
    mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+2]
    mov dx,[gameBoard+bx+4]
    mov di,[gameBoard+bx+6]
    call checkPatternOfFourInRows
    add bx,2
    cmp bx,66
    jne sixthRow4

    popa
ret
patternInColsOf4:
    pusha
     mov bx,0
    firstCol4:
    
 mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 call checkPatternOfFourInCols   ; for columns
 add bx,12
 cmp bx,36
 jne firstCol4
 mov bx,2
    secondCol4:
    

 

 mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 call checkPatternOfFourInCols
 add bx,12
 cmp bx,38
 jne secondCol4

mov bx,4
    thirdCol4:
    
 

  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 call checkPatternOfFourInCols
 add bx,12
 cmp bx,40
 jne thirdCol4
mov bx,6
    fourthCol4:
    
  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 call checkPatternOfFourInCols
 add bx,12
 cmp bx,42
 jne fourthCol4

 mov bx,8
    fifthCol4:
    


  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 call checkPatternOfFourInCols
 add bx,12
 cmp bx,44
 jne fifthCol4
    mov bx,10
    sixthCol4:


  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 call checkPatternOfFourInCols
 add bx,12
 cmp bx,46
 jne sixthCol4

    popa
ret
patternInRowsOf5:
    pusha 
    mov bx,0
    firstRow5:

 mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 mov si,[gameBoard+bx+8]
 call checkPatternOfFiveInRows  ; for rows
 add bx,2
 cmp bx,8
 jne firstRow5
     mov bx,16
    secondRow5:
 mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 mov si,[gameBoard+bx+8]
 call checkPatternOfFiveInRows
 add bx,2
 cmp bx,24
 jne secondRow5

 mov bx,32
    thirdRow5:
  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 mov si,[gameBoard+bx+8]
 call checkPatternOfFiveInRows
 add bx,2
 cmp bx,40
 jne thirdRow5
     mov bx,48
    fourthRow5:

  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 mov si,[gameBoard+bx+8]
 call checkPatternOfFiveInRows
 add bx,2
 cmp bx,56
 jne fourthRow5 
 mov bx,64
    fifthRow5:
  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+2]
 mov dx,[gameBoard+bx+4]
 mov di,[gameBoard+bx+6]
 mov si,[gameBoard+bx+8]
 call checkPatternOfFiveInRows
 add bx,2
 cmp bx,72
 jne fifthRow5
     mov bx,80
    sixthRow5:
  mov ax,[gameBoard+bx]
   mov cx,[gameBoard+bx+2]
  mov dx,[gameBoard+bx+4]
  mov di,[gameBoard+bx+6]
  mov si,[gameBoard+bx+8]
  call checkPatternOfFiveInRows
 add bx,2
 cmp bx,88
 jne sixthRow5
    popa
ret
patternInColsOf5:
    pusha 
    mov bx,0
    firstCol5:
    mov ax,[gameBoard+bx]
    mov cx,[gameBoard+bx+12]
    mov dx,[gameBoard+bx+24]
    mov di,[gameBoard+bx+36]
    mov si,[gameBoard+bx+48]
    call checkPatternOfFiveInCols   ; for columns
    add bx,12
    cmp bx,24
    jne firstCol5
     mov bx,2
    secondCol5:
 mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 mov si,[gameBoard+bx+48]
  call checkPatternOfFiveInCols
 add bx,12
 cmp bx,26
 jne secondCol5


 mov bx,4
    thirdCol5:

  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 mov si,[gameBoard+bx+48]
 call checkPatternOfFiveInCols
 add bx,12
 cmp bx,28
 jne thirdCol5
 mov bx,6
    fourthCol5:
  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 mov si,[gameBoard+bx+48]
 call checkPatternOfFiveInCols
 add bx,12
 cmp bx,30
 jne fourthCol5

 mov bx,8
    fifthCol5:

  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 mov si,[gameBoard+bx+48]
 call checkPatternOfFiveInCols
 add bx,12
 cmp bx,32
 jne fifthCol5
  mov bx,10
    sixthCol5:
  mov ax,[gameBoard+bx]
 mov cx,[gameBoard+bx+12]
 mov dx,[gameBoard+bx+24]
 mov di,[gameBoard+bx+36]
 mov si,[gameBoard+bx+48]
 call checkPatternOfFiveInCols
 add bx,12
 cmp bx,34
 jne sixthCol5
    popa
ret




detectPattern:
    pusha
    mov word[patternDetectedFlag],0
    call patternInRowsOf3
    cmp word[patternDetectedFlag],1
   je exitDetectPatternBySettingFlagTrue
    call patternInColsOf3
    cmp word[patternDetectedFlag],1
    je exitDetectPatternBySettingFlagTrue
    call patternInRowsOf4
    cmp word[patternDetectedFlag],1
    je exitDetectPatternBySettingFlagTrue
    call patternInColsOf4
    cmp word[patternDetectedFlag],1
    je exitDetectPatternBySettingFlagTrue
    call patternInRowsOf5
    cmp word[patternDetectedFlag],1
    je exitDetectPatternBySettingFlagTrue
    call patternInColsOf5
   
   exitDetectPatternBySettingFlagTrue:
   mov word[patternDetectedFlag],1
   
  
    jmp detectPatternExit
   exitDetectPatternBySettingFlagFalse:
   mov word[patternDetectedFlag],0
   jmp detectPatternExit
    detectPatternExit:
    popa
ret
delay:
    push ax

    mov ax,0xffff
    ll:
    sub ax,1
    cmp ax,0
    jne ll
    pop ax
    ret


setAttribute:
 ;ax mai element hai
 ; bh mai attribute rakhna hai
 s1:
 cmp al,0x40
 jne s2
  mov bh,00011010b   ;green with white background
  mov  bl,0x41
 jmp exitSetAttribute

 ;mov bl,al
 s2:
 cmp al,0x24
 jne s3
 mov bh,00011100b  ; red
 mov  bl,0x42
 ;mov bl,al
 jmp exitSetAttribute
 s3:
 cmp al,0x23
 jne s4
 mov bh,00011110b  ;yellow
 mov  bl,0x43
 ;mov bl,al
 jmp exitSetAttribute
 s4:
 cmp al,0x25
 jne s5
 mov bh,00011111b ; white
  mov  bl,0x44
 ;mov bl,al
 jmp exitSetAttribute
 s5:
 
 mov bh,00011101b  ; unknown
 mov  bl,0x45
 exitSetAttribute:
ret

doTheMove:
    pusha
    push word[row1]
    push word[col1]
    call getIndexFromRowsCols
    mov cx,[gameBoard+di]
    push di
    push word[row2]
    push word[col2]
    call getIndexFromRowsCols
    mov dx,[gameBoard+di]
    ;exchanging the dest source
    mov word[gameBoard+di],cx
    pop di
    mov word[gameBoard+di],dx
    call detectPattern
    cmp word[patternDetectedFlag],1
     call printGameInterFace
    
    exitDoTheMove:
    popa

ret
getIndexFromRowsCols:  ; bp+4=col ; bp+6=row
 firstRow:
 push bp
 mov bp,sp
 r00:
 cmp word[bp+6],0
 jne r01
 cmp word[bp+4],0
 jne r01
 mov di,0
 jmp exitGetIndexFromRowsCols
 r01:
  cmp word[bp+6],0
 jne r02
 cmp word[bp+4],1
 jne r02
 mov di,2
 jmp exitGetIndexFromRowsCols
 r02:
   cmp word[bp+6],0
 jne r03
 cmp word[bp+4],2
 jne r03
 mov di,4
 jmp exitGetIndexFromRowsCols
 r03:
   cmp word[bp+6],0
 jne r04
 cmp word[bp+4],3
 jne r04
 mov di,6
 jmp exitGetIndexFromRowsCols
 r04:
 cmp word[bp+6],0
 jne r05
 cmp word[bp+4],4
 jne r05
 mov di,8
 jmp exitGetIndexFromRowsCols
 r05:
  cmp word[bp+6],0
 jne secondRow
 cmp word[bp+4],5
 jne secondRow
 mov di,10
 jmp exitGetIndexFromRowsCols


 secondRow:
 r10:
   cmp word[bp+6],1
 jne r11
 cmp word[bp+4],0
 jne r11
 mov di,12
 jmp exitGetIndexFromRowsCols
 r11:
   cmp word[bp+6],1
 jne r12
 cmp word[bp+4],1
 jne r12
 mov di,14
 jmp exitGetIndexFromRowsCols
 r12:
   cmp word[bp+6],1
 jne r13
 cmp word[bp+4],2
 jne r13
 mov di,16
 jmp exitGetIndexFromRowsCols
 r13:
   cmp word[bp+6],1
 jne r14
 cmp word[bp+4],3
 jne r14
 mov di,18
 jmp exitGetIndexFromRowsCols
 r14:
   cmp word[bp+6],1
 jne r15
 cmp word[bp+4],4
 jne r15
 mov di,20
 jmp exitGetIndexFromRowsCols
 r15:
   cmp word[bp+6],1
 jne row3
 cmp word[bp+4],5
 jne row3
 mov di,22
 jmp exitGetIndexFromRowsCols


 row3:
 r20:
    cmp word[bp+6],2
 jne r21
 cmp word[bp+4],0
 jne r21
 mov di,24
 jmp exitGetIndexFromRowsCols
 r21:
    cmp word[bp+6],2
 jne r22
 cmp word[bp+4],1
 jne r22
 mov di,26
 jmp exitGetIndexFromRowsCols
 r22:
    cmp word[bp+6],2
 jne r23
 cmp word[bp+4],2
 jne r23
 mov di,28
 jmp exitGetIndexFromRowsCols
 r23:
    cmp word[bp+6],2
 jne r24
 cmp word[bp+4],3
 jne r24
 mov di,30
 jmp exitGetIndexFromRowsCols
 r24:
    cmp word[bp+6],2
 jne r25
 cmp word[bp+4],4
 jne r25
 mov di,32
 jmp exitGetIndexFromRowsCols
 r25:
    cmp word[bp+6],2
 jne row4
 cmp word[bp+4],5
 jne row4
 mov di,34
 jmp exitGetIndexFromRowsCols
 
 row4:
 r30:
    cmp word[bp+6],3
 jne r31
 cmp word[bp+4],0
 jne r31
 mov di,36
 jmp exitGetIndexFromRowsCols
 r31:
    cmp word[bp+6],3
 jne r32
 cmp word[bp+4],1
 jne r32
 mov di,38
 jmp exitGetIndexFromRowsCols
 r32:
    cmp word[bp+6],3
 jne r33
 cmp word[bp+4],2
 jne r33
 mov di,40
 jmp exitGetIndexFromRowsCols
 r33:
    cmp word[bp+6],3
 jne r34
 cmp word[bp+4],3
 jne r34
 mov di,42
 jmp exitGetIndexFromRowsCols
 r34:
    cmp word[bp+6],3
 jne r35
 cmp word[bp+4],4
 jne r35
 mov di,44
 jmp exitGetIndexFromRowsCols
 r35:
    cmp word[bp+6],3
 jne row5
 cmp word[bp+4],5
 jne row5
 mov di,46
 jmp exitGetIndexFromRowsCols
 row5:
 r40:
     cmp word[bp+6],4
 jne r41
 cmp word[bp+4],0
 jne r41
 mov di,48
 jmp exitGetIndexFromRowsCols
 
 r41:
     cmp word[bp+6],4
 jne r42
 cmp word[bp+4],1
 jne r42
 mov di,50
 jmp exitGetIndexFromRowsCols
 r42:
     cmp word[bp+6],4
 jne r43
 cmp word[bp+4],2
 jne r43
 mov di,52
 jmp exitGetIndexFromRowsCols
 r43:
     cmp word[bp+6],4
 jne r44
 cmp word[bp+4],3
 jne r44
 mov di,54
 jmp exitGetIndexFromRowsCols
 r44:
     cmp word[bp+6],4
 jne r45
 cmp word[bp+4],4
 jne r45
 mov di,56
 jmp exitGetIndexFromRowsCols
 r45:
     cmp word[bp+6],4
 jne row6
 cmp word[bp+4],5
 jne row6
 mov di,58
 jmp exitGetIndexFromRowsCols
 row6:


 r50:
     cmp word[bp+6],5
 jne r51
 cmp word[bp+4],0
 jne r51
 mov di,60
 jmp exitGetIndexFromRowsCols
 r51:
     cmp word[bp+6],5
 jne r52
 cmp word[bp+4],1
 jne r52
 mov di,62
 jmp exitGetIndexFromRowsCols
 r52:
  cmp word[bp+6],5
 jne r53
 cmp word[bp+4],2
 jne r53
 mov di,64
 jmp exitGetIndexFromRowsCols
 r53:
     cmp word[bp+6],5
 jne r54
 cmp word[bp+4],3
 jne r54
 mov di,66
 jmp exitGetIndexFromRowsCols
 r54:
     cmp word[bp+6],5
 jne r55
 cmp word[bp+4],4
 jne r55
 mov di,68
 jmp exitGetIndexFromRowsCols
 r55:
     cmp word[bp+6],5
 jne exitGetIndexFromRowsCols
 cmp word[bp+4],5
 jne exitGetIndexFromRowsCols
 mov di,70
 jmp exitGetIndexFromRowsCols
 
 exitGetIndexFromRowsCols:
 pop bp
ret 4



makeSound:
pusha
push 1000
call soundd
push 2000
call soundd
push 3000
call soundd
popa
ret
takeInput:

 pusha

  call printMessage1
  ;input row1
  mov ah,0
  int 0x16
  cmp ah,11
  jne nextComparison
    mov ah,1

  nextComparison:
  sub ah,1
  mov byte[row1],ah
  call printMessage2
  ;input col1f
  mov ah,0
  int 0x16
  cmp ah,11
    jne nextComparison2
    mov ah,1
    nextComparison2
  sub ah,1
  mov byte[col1],ah
  call printMessage3
  ;input direction
  mov ah,0
  int 0x16
  mov byte[direction],ah
  ;mov word[validMove],1
  call validateMove

  cmp word[validMove],1
  jne exitTakeInput
 call doTheMove
 call detectPattern
 ;call checkUndoCondition
  exitTakeInput:
  mov bx,0
 l1:mov byte[patternFoundArray+bx],0
 add bx,1
 cmp bx,6
 jne l1
 popa


ret
checkUndoCondition:
pusha
 mov ax,0
 mov bx,0
 l2:
   mov ax,[patternFoundArray+bx]
   cmp ax,1
   je exitCheckUndoCondition
   add bx,1
   cmp bx,6
   jne l2
   
    push word[row2]
    push word[col2]
    call getIndexFromRowsCols
    mov cx,[gameBoard+di]
    push di
    push word[row1]
    push word[col1]
    call getIndexFromRowsCols
    mov dx,[gameBoard+di]
    ;exchanging the dest source
    mov word[gameBoard+di],cx
    pop di
    mov word[gameBoard+di],dx
    ;call detectPattern
    call invalidMoveMessage
    jmp e2

   exitCheckUndoCondition:
   push 1000
   call soundd
   push 3000
   call soundd


e2:
popa
ret
invalidMoveMessage:
pusha
 mov ah,0x13
 mov al,1
   mov bh,0
      mov bl,00110001b
   mov dx,0x1646
   mov cx,8
   push cs
   pop es
   mov bp,invalidMoveMessage1
   int 0x10

popa
ret
GenerateRandomNumber:
    call delay
    push bp
    mov bp,sp;
    push cx
    push ax


    MOV AH, 00h ; interrupts to get system time
    INT 1AH ; CX:DX now hold number of clock ticks since midnight
    mov ax, dx
    xor dx, dx
    mov cx, 5;
    div cx ; here dx contains the remainder of the division - from 0 to 9

    ;add dl, '0' ; to ascii from '0' to '9'




    pop cx;
    pop ax
    pop bp;
ret



printMessage1:
 ; prints the messages for input from user
 pusha
 mov ah,0x13
 mov al,1
   mov bh,0
      mov bl,00110001b
   mov dx,0x0303
   mov cx,12
   push cs
   pop es
   mov bp,row1Message
   int 0x10
popa
ret
printMessage2:
pusha
 ; prints the messages for input from user
    mov ah,0x13
   mov al,1
   mov bh,0
   mov bl,00110001b
   mov dx,0x0503
   mov cx,12
   push cs
   pop es
   mov bp,col1Message
   int 0x10
   popa
ret
printMessage3:
 ; prints the messages for input from user
 pusha
    mov ah,0x13
   mov al,1
   mov bh,0
   mov bl,00110001b
   mov dx,0x0703
   mov cx,16
   push cs
   pop es
   mov bp,directionMessage
   int 0x10
   popa
ret; printMessage4:
;  ; prints the messages for input from user
;     mov ah,0x13
;    mov al,1
;    mov bh,0
;    mov bl,00011100b
;    mov dx,0x0504
;    mov cx,11
;    push cs
;    pop es
;    mov bp,message1
;    int 0x10
; ret

; initilizeCandyCrush:
;     pusha
;     mov di,0
;     i1:
;     call GenerateRandomNumber
;     mov si,dx
;     mov ah,0
;     mov al,[candies+si]
;     call delay
;     mov word[gameBoard+di],ax
;     add di,2
;     cmp di,74
;     jne i1



;     popa

; ret
printGameInterface:
pusha

call printBoxes
popa
ret
startNewGame:
    call initilizeCandyCrush
    call printGameInterface



ret
subroutines:
start:
mov ax,gameBoard
call startNewGame
mov word[movesRemaining],20
s:
call printGameInterface
call takeInput
call printScoresMoves
dec word[movesRemaining]
jnz s
 call printGameInterface
















mov ax,0x4c00
int 0x21
row1Message: db 'Enter Row 1:'  ;12
col1Message: db 'Enter Col 1:'  ;12
directionMessage: db 'Enter Direction Using Arrow Keys:'  ; 33
row1: dw 0
col1: dw 0
row2: dw 0
col2: dw 0
direction: db 0
patternDetectedFlag: dw  0
score: dw 48
validMove: dw 0   ; to validate whether a move is valid or not
candies: db 64,35,37,36,38 
movesRemaining: dw 20
isPatternFound: dw 0
scoreMessage: db 'Score' 
invalidMoveMessage1: db 'Invalid!'
recurringElement: dw 0
patternFoundArray: db 1,0,1,1,0,0
gameBoard: 
dw 0,0,0,0,0,0
dw 0,0,0,0,0,0
dw 0,0,0,0,0,0
dw 0,0,0,0,0,0
dw 0,0,0,0,0,0
dw 0,0,0,0,0,0