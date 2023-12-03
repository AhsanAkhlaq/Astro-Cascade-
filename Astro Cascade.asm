[org 0x0100]
section .data
HEIGHT:dw 24
WIDTH: dw 50

shipx:dw 38
shipy:dw 21

ship:dw 0x01db
enemy:dw 0x0501

score:dw 0

scr_str:db'Score'

moveEnemy:db 0

charge:dd 10
chr_str:db 'Charge (F)'


live:dw 10
live_str:db 'Live'



spawn_score:dw 100
bossx:dw 40
bossy:dw 1
boss:dw 0x05db
boss_fight:dw 0
boss_health: dw 150
boss_dir:db 'l'
special_CD:db 0



name:db'ASTRO CASCADE'  ;13 
develop:db'DEVELOPED BY MUHAMMAD AHSAN AND FARAZ-UL-KHAF' ;45

section .text
    global _start
_start:
mov ax,0xb800
mov es,ax
call cls

mov si, name
mov cx, 13
mov di,1988
call printstr
mov ah,0
int 16h

mov si, develop
mov cx, 45
mov di,2276
call printstr
mov ah,0
int 16h


call clear_board_screen
call Board
push word[ship]
call draw_ship
mov si, scr_str
mov cx, 5
mov di,810
call printstr
mov si, chr_str
mov cx, 10
mov di,936
call printstr
mov si, live_str
mov cx, 4
mov di,2380
call printstr




shhhh:
call movFaE
cmp word[boss_fight],0
je mskip1

	call move_boss
		call boss_atk_1
		call special_atk
		cmp word[boss_health],0
		ja mskip3
			mov word[boss_fight],0
			add word[score],150
			call clear_boss
			mov cx,20
			call delayB
		mskip3:
	jmp mskip2
mskip1:
call genEnemy
mskip2:
mov di, 970
push word[score]
call printnum
call getInput
call print_charge_live

call delay
call check_score
cmp word[live],0
ja shhhh

call cls
mov si, scr_str
mov cx, 5
mov di,1988
call printstr
add di,2
push word[score]
call printnum

mov ah,0
int 16h



mov ax,4c00h
int 21h


special_atk:
	cmp byte[special_CD],5
	jne saexit
	mov byte[special_CD],0
	mov ax,4
	call gen_random
	cmp ax,0
	je saexit
	
	cmp ax,1
	jne saskip1
		call boss_atk_2
		jmp saexit
	saskip1:
	
	cmp ax,2
	jne saskip2
		call boss_atk_3
	saskip2:
	
	cmp ax,3
	jne saskip3
		call boss_atk_3
	saskip3:

saexit:
ret



move_boss:
;32
	cmp word[boss_fight],126
	jne mbexit
	call clear_boss
	
	cmp byte[boss_dir],'l'
	jne mbskip3
		cmp word[bossx],17
		jne mbskip1
			mov word[boss_dir],'r'
		mbskip1:
			dec word[bossx]	
		jmp mbexit
	mbskip3:

		cmp word[bossx],34
		jne mbskip2
			mov word[boss_dir],'l'
		mbskip2:
			inc word[bossx]

mbexit:
	call draw_boss
ret


check_score:
mov ax,[spawn_score]
cmp word[score],ax
jb csexit
	call clear_board_screen
	add word[spawn_score],500
	mov word[boss_health],150    
	mov word[boss_fight],1
	push word[ship]
	call draw_ship
csexit:
ret


boss_atk_3:
	mov ax,80
	mov bx,[bossy]
	add bx,9
	mul bx
	add ax,[bossx]
	shl ax,1
	mov di,ax
	mov ax,[enemy]
	mov al,0xdc
	mov word[es:di+10],ax
	mov word[es:di+24],ax
	mov al,0xdf
	mov word[es:di+14],ax
	mov word[es:di+28],ax
	;dc df

ret



boss_atk_1:
cmp word[boss_fight],1
jne ba1skip1

	mov ax,80
	mul word[bossy]
	add ax,[bossx]
	shl ax,1
	mov di,ax
	add di,1280
	mov ax,[enemy]
	mov word[es:di+18],ax
	mov word[es:di+20],ax
	
ba1skip1:

inc word[boss_fight]
cmp  word[boss_fight],127
jne ba1exit
	mov  word[boss_fight],1
	inc byte[special_CD]
ba1exit:
ret

getInput:

mov ah,1
int 16h
jz NO_Input
	mov ah,0
	int 16h
	call check_Input
NO_Input:

ret

boss_atk_2:
	mov ax,80
	mov bx ,word[bossy]
	add bx,9
	mul bx
	shl ax,1
	mov di,ax
	add di,32
	push di
	mov ax,[enemy]
	mov cx,[WIDTH]
	sub cx,2
	cld
	rep stosw
	pop di
	add di,160
	mov cx,[WIDTH]
	sub cx,2
	cld
	rep stosw
	 
	
ret

printnum: 
push bp
 mov bp, sp
 push ax
 push bx
 push cx
 push dx
 push di
 mov ax, 0xb800
 mov es, ax 
 mov ax, [bp+4] 
 mov bx, 10 
 mov cx, 0 
nextdigit:
	 mov dx, 0
	 div bx 
	 add dl, 0x30 
	 push dx 
	 inc cx 
	 cmp ax, 0 
 jnz nextdigit 
 

 
 nextpos: 
 pop dx 
 mov dh, 0x70 
 mov [es:di], dx 
 add di, 2 
 loop nextpos 
 pop di
 pop dx
 pop cx
 pop bx
 pop ax
 pop bp
 ret 2


print_charge_live:
push es
push di
push ax
push cx



mov cx,10
mov di,1096
mov ax,0x70b0
cld
rep stosw

mov cx,[charge]
mov di,1096
mov ax,0x70db
cmp cx,10
jne pcskip
	mov ah,0x8f
pcskip:
cld
rep stosw




mov cx,10
mov di,2536
mov ax,0x70b0
cld
rep stosw

mov cx,[live]
cmp cx,0
ja pcskip2
	mov cx,0
pcskip2:
mov di,2536
mov ax,0x7403
cmp cx,10
cld
rep stosw




pop cx
pop ax
pop di
pop es
ret

printstr:
mov ax,0x7020
psloop1:
	lodsb
	stosw	
loop psloop1
ret 


gen_random:
push bx
push dx
mov bx,ax
rdtsc
div  bx
mov ax,dx
pop dx
pop bx
ret 


genEnemy:;cf
pushad


mov ax,30
call gen_random
cmp ax,0
jne geexit

mov ax,3
call gen_random
mov cx,ax
cmp cx,0
je geexit
generateAgain:
	mov ax,[WIDTH]
	sub ax,6
	call gen_random
	add ax,18
	mov di,ax
	shl di,1
	add di,160
	mov ax,[enemy]
	mov word[es:di],ax
loop generateAgain

geexit;
popad
ret

check_Input:
pushad
cmp al,'a'
jne chiskip1
	cmp word[shipx],18
	
	je chiskip1
	mov ax,0x0720
	push ax
	call draw_ship
	dec word[shipx]
	push word[ship]
	call draw_ship
	jmp chiexit
chiskip1:
cmp al,'d'
jne chiskip2
	cmp word[shipx],61
	je chiskip2
	mov ax,0x0720
	push ax
	call draw_ship
	inc word[shipx]
	push word[ship]
	call draw_ship
	jmp chiexit
chiskip2:

cmp al,' '; space
jne chiskip3
	call fire
	jmp chiexit
chiskip3:


cmp al,'f'
jne chiskip4
	cmp byte[charge],10
	jne chiskip4
		mov byte[charge],0
	call charge_fire
	jmp chiexit
chiskip4:


chiexit:
popad
ret 




delay:
push cx
mov cx,0x0fff
dlloop:
loop dlloop
pop cx
ret 


movFaE:
push ax
push di
push cx
push si
push bx
push dx





mov dx,[boss]

mov si,3970
mov cx,[HEIGHT]
mov di,32
mfloop1:
	push cx
	push di
	push si
	mov cx,[WIDTH]
	mfloop2:
		mov ax,[enemy]
		cmp word[es:di],0x07b1
		jne mfskip0
			cmp byte[moveEnemy],15
			 jb mfskip0
			mov word[es:di],0x0720
		mfskip0:
		
		;our ship fires moving
		cmp word[es:di],0x06f8
		jne mfskip1
			mov word[es:di],0x0720
			cmp word[es:di-160],0x02cd ;upper screen boundary
			je mfskip1
			cmp word[es:di-160],dx ;boss check
			je mfskip13
			cmp word[es:di-160],ax ; enemy check
			jne mfskip12
				inc word[score]
				mov word[es:di-160],0x07b1
				cmp byte[charge],10
				je mfskip1
					inc byte[charge]
				jmp mfskip1
			mfskip13:
				dec word[boss_health];
				jmp mfskip1
			mfskip12:
			mov word[es:di-160],0x06f8
		mfskip1:
		
		;movement of special charge fire ; animation of charge atk
		cmp word[es:di],0x73b1
		jne mfskip3
			cmp byte[moveEnemy],10
			jb mfskip3
			mov word[es:di],0x07b1
		mfskip3:
		
		;movemont of enemy
		cmp byte[moveEnemy],0
		jne mfskip2
		cmp word[es:si],ax
		jne mfskip2
			mov word[es:si],0x0720
			cmp word[es:si+160],0x01db; my ship body
			je mfskip21
			cmp word[es:si+160],0x049d;my ship 
			je mfskip21
			cmp word[es:si+160],0x02cd ; lower screen boundary
			je mfskip2
			mov word[es:si+160],ax
			jmp mfskip2
			mfskip21:; decreasing ship live
				cmp word[live],0
				je mfskip2
					dec word[live]
		mfskip2:
		
		;movemont of boss_atk_3
		cmp byte[moveEnemy],0
		jne mfskip4
			call mov_boss_atk_3
		mfskip4:
		
		
	
		
		
		sub si,2
		add di,2
	dec cx
	cmp cx,0
	jne temp10
		jmp temp11
	temp10:
		jmp mfloop2
	temp11:
	
	pop si
	pop di
	pop cx	
	add di,160
	sub si,160
dec cx
cmp cx,0
jne temp12 
	jmp temp13
temp12:
	jmp mfloop1
temp13

inc byte[moveEnemy]
cmp byte[moveEnemy],20
jne mfinc
mov byte[moveEnemy],0
mfinc:

pop dx
pop bx
pop si
pop cx
pop di
pop ax
ret

mov_boss_atk_3:

	mov ax,[enemy]
	mov al,0xdc
	cmp word[es:si],ax; left atk movement
	je mbatemmp1
		mbatemmp0:
			jmp mfskip40
		mbatemmp1:
		
		mov word[es:si],0x0720
		cmp word[es:si+156],0x01db; my ship body
		je mfskip41
		cmp word[es:si+156],0x049d;my ship 
		je mfskip41
		cmp word[es:si+156],0x02cd ; lower screen boundary
		je mfskip40
		cmp word[es:si+156],0x02c8 ; lower left corner screen boundary
		je mfskip40
		cmp word[es:si+158],0x02c8 ; lower screen boundary
		je mfskip40
			cmp word[es:si+158],0x02ba;side  screen boundary
			jne mfskip42
				mov al,0xdf
				mov word[es:si+164],ax
			jmp mfskip40
			mfskip42:
			cmp word[es:si+156],0x02ba;side  screen boundary
			jne mfskip43
				mov al,0xdf
				mov word[es:si+164],ax
			jmp mfskip40
			mfskip43:
				mov word[es:si+156],ax
		jmp mfskip40
		mfskip41:; decreasing ship live
			cmp word[live],0
			je mfskip40
				dec word[live]
mfskip40:

	mov al,0xdf
	cmp word[es:si],ax; right atk movement
	je mbatemmp3
		mbatemmp2:
			jmp mfskip50
		mbatemmp3:
	
		mov word[es:si],0x0720
		cmp word[es:si+164],0x01db; my ship body
		je mfskip51
		cmp word[es:si+164],0x049d;my ship 
		je mfskip51
		cmp word[es:si+164],0x02cd ; lower screen boundary
		je mfskip50
		cmp word[es:si+162],0x02bc ; lower screen boundary
		je mfskip50
		cmp word[es:si+164],0x02bc ; lower screen boundary
		je mfskip50
			cmp word[es:si+162],0x02ba;side  screen boundary
			jne mfskip52
				mov al,0xdc
				mov word[es:si+156],ax
			jmp mfskip50
			mfskip52:
			cmp word[es:si+164],0x02ba;side  screen boundary
			jne mfskip53
				mov al,0xdc
				mov word[es:si+156],ax
			jmp mfskip50
			mfskip53:
			
				mov word[es:si+164],ax
		jmp mfskip50
		mfskip51:; decreasing ship live
			cmp word[live],0
			je mfskip50
				dec word[live]
mfskip50:
		
ret
charge_fire:
push bp
mov bp,sp
push di
push bx
push ax
push dx
	mov ax,80
	mul byte[shipy]
	add ax,[shipx]
	shl ax,1
	mov di,ax
	sub di,160
	mov ax,[enemy]
	mov dx,[boss]
	sub di,4
	mov cx,0
	cfaloop2:
		push di
		cfaloop1:
			cmp word[es:di],dx ;boss check
			jne cfaskip2
				cmp word[boss_health],2
				jb  cfaskip5
				sub word[boss_health],2
				jmp cfaskip4
				cfaskip5:
					mov word[boss_health],0
				jmp cfaskip4
			cfaskip2:
			cmp word[es:di],ax ; enemy check
				jne cfaskip1
					inc word[score]
				cfaskip1:
			mov word[es:di],0x73b1
			cfaskip3:
			sub di,160
		cmp di,160
		jg cfaloop1
		cfaskip4:
		pop di
	inc cx
	add di,2
	cmp cx,5
	jne cfaloop2

mov cx,6
call delayB

pop dx
pop ax
pop bx
pop di
pop bp
ret 2

delayB:
	dbloop1:
		push cx
			mov cx,0xffff
			dlBloop2:
			loop dlBloop2
		pop cx
	dec cx
	cmp cx,0
	jne dbloop1
ret


fire:
push ax
push di
push es
;f8


mov ax,80
mul byte[shipy]
add ax,[shipx]
shl ax,1
mov di,ax
sub di,160
mov ax,[enemy]
cmp word[es:di],ax
jne frskip1
	inc word[score]
	mov word[es:di],0x07b1
	jmp frskip2
frskip1:
mov word[es:di],0x06f8
frskip2:

pop es
pop di
pop ax
ret



draw_ship:
push bp
mov bp,sp
push ax
push cx
push di



mov ax,80
mul byte[shipy]
add ax,[shipx]
shl ax,1
mov di,ax
mov ax,[bp+4]


cmp word[es:di],0x0720
je drskip1
cmp word[es:di],0x049d
je drskip1
	dec word[live];
drskip1:
mov word[es:di],0x049d
cmp al,0x20
jne drskip
	mov word[es:di],ax
drskip:


mov cx,5
add di,316
drloop1:
	mov bx,0
	push cx
		drloop2:
			cmp word[es:di +bx],0x0720
			je drskip2
			cmp word[es:di +bx],0x01db
			je drskip2
				dec word[live];
			drskip2:
			mov word[es:di+bx],ax
			add bx,2
		loop drloop2
	pop cx
	sub cx,2
	sub di,158
cmp cx,1
jne drloop1



pop di
pop cx
pop ax
pop bp
ret 2

Board:
push ax
push bx
push cx
push di



mov di,32
mov cx,[WIDTH]
dec cx
mov ax,0x02cd
mov word[es:di-2],0x02c9
cld
rep stosw
mov word[es:di-2],0x02bb

mov di,30
mov bx,[WIDTH]
dec bx
shl bx,1
mov cx,[HEIGHT]
side_board:
	add di,160
	mov word[es:di],0x02ba
	mov word[es:di+bx],0x02ba
loop side_board


mov cx,[WIDTH]
dec cx
mov ax,0x02cd
mov word[es:di],0x02c8
add di,2
cld
rep stosw
mov word[es:di-2],0x02bc

pop di
pop cx
pop bx
pop ax
ret


clear_board_screen:
push ax
push cx
push di
mov di,192
mov cx,[HEIGHT]
dec cx


mov ax,0x0720
cld
cbsloop1:
push cx
	mov cx,[WIDTH]
	sub cx,2
	push di
	rep stosw
	pop di
	add di,160
pop cx
loop cbsloop1
pop di
pop cx
pop ax
ret



cls:
push cx
push di
push ax

mov cx,2000
mov di,0


mov ax,0x07b0
cld
rep stosw

pop ax
pop di
pop cx
ret

print_boss_health:
push di
push ax
push cx

xor ax,ax
xor bx,bx
xor dx,dx

mov ax,[boss_health]
mov bx,5
div bx
cmp dx,0
je pbhskip1
inc ax
pbhskip1:
xor dx,dx
mov bx,10
div bl

mov dx,ax
mov cx,0
cld 

add di,10
mov bx,di
mov cx,10
mov ax,0x0720
rep stosw

mov di,bx
cmp dl,1
jae pbhskip2
mov cl,dh
mov ax,0x04db
rep stosw
jmp pbhexit 
pbhskip2:
mov cx,10
mov ax,0x04db
rep stosw


mov di,bx

cmp dl,2
jae pbhskip3
mov cl,dh
mov ax,0x06db
rep stosw 
jmp pbhexit
pbhskip3:
mov cx,10
mov ax,0x06db
rep stosw


mov di,bx

cmp dl,3
jne pbhskip4
	mov dh,10
pbhskip4:
mov cl,dh
mov ax,0x02db
rep stosw 
jmp pbhexit



pbhexit:
pop cx
pop ax
pop di
ret

draw_boss:
push ax
push di
mov ax,80
mul word[bossy]
add ax,[bossx]
shl ax,1
mov di,ax
mov ax,[boss]
mov word[es:di+8],ax
call print_boss_health
mov word[es:di+30],ax
add di,160
mov word[es:di+14],ax
mov word[es:di+24],ax
add di,160
mov word[es:di+6],ax
mov word[es:di+8],ax
mov word[es:di+14],ax
mov word[es:di+24],ax
mov word[es:di+30],ax
mov word[es:di+32],ax
add di,160
mov word[es:di+6],ax
mov word[es:di+12],ax
mov word[es:di+14],ax
mov word[es:di+16],ax
mov word[es:di+18],ax
mov word[es:di+20],ax
mov word[es:di+22],ax
mov word[es:di+24],ax
mov word[es:di+26],ax
mov word[es:di+32],ax
add di,160
mov word[es:di+8],ax
mov word[es:di+10],ax
mov word[es:di+12],ax
mov word[es:di+14],0x0720;--
mov word[es:di+16],0x0720 ;--
mov word[es:di+22],0x0720 ;--
mov word[es:di+24],0x0720 ;--
cmp word[boss_fight],63
jb dbskip
mov word[es:di+14],ax ;--
mov word[es:di+16],ax ;--
mov word[es:di+22],ax ;--
mov word[es:di+24],ax ;--
dbskip:


mov word[es:di+18],ax
mov word[es:di+20],ax
mov word[es:di+26],ax
mov word[es:di+28],ax
mov word[es:di+30],ax
add di,160
mov word[es:di+6],ax
mov word[es:di+10],ax
mov word[es:di+12],ax
;mov word[es:di+14],ax
;mov word[es:di+16],ax
mov word[es:di+18],ax
mov word[es:di+20],ax
;mov word[es:di+22],ax
;mov word[es:di+24],ax
mov word[es:di+26],ax
mov word[es:di+28],ax
mov word[es:di+32],ax
add di,160
mov word[es:di+8],ax
mov word[es:di+10],ax
mov word[es:di+12],ax
mov word[es:di+14],ax
mov word[es:di+16],ax
mov word[es:di+18],ax
mov word[es:di+20],ax
mov word[es:di+22],ax
mov word[es:di+24],ax
mov word[es:di+26],ax
mov word[es:di+28],ax
mov word[es:di+30],ax
add di,160
mov word[es:di+14],ax
mov word[es:di+16],ax
mov word[es:di+22],ax
mov word[es:di+24],ax
add di,160
mov word[es:di+12],ax
mov word[es:di+26],ax
pop di
pop ax
ret

clear_boss:
push ax
push di
mov ax,80
mul word[bossy]
add ax,[bossx]
shl ax,1
mov di,ax
mov ax,0x0720
mov cx,9
cld
cbskip1:
push cx
push di
mov cx,18
rep stosw
pop di
pop cx
add di,160
loop cbskip1

pop di
pop ax
ret

