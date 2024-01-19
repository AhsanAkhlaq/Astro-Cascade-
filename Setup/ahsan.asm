[org 0x100]

jmp start

s:db "ahsan is you",0

s1: db "is",0

start:

mov cx,0
mov bx,0


mov di,s1
mov si,s
push ds
pop es
mov cx,2
mov ax,12

cld
next:
    repe cmpsb
    jcxz ok
    dec ax
    dec si
    mov di,s1
    mov cx,2
cmp ax,1
jne next

push s1
push word 320
call print


ok:
push s
push word 360
call print

mov ax, 4c00h
int 21h


scrolldown: push bp
mov bp,sp
push ax
push cx
push si
push di
push es
push ds
mov ax, 80 ; load chars per row in ax
mul byte [bp+4] ; calculate source position
push ax ; save position for later use
mov cx, 2000 ; number of screen locations
sub cx, ax ; count of words to move
shl ax, 1 ; convert to byte offset
mov si, 3998 ; last location on the screen
sub si, ax ; load source position in si

mov ax, 0xb800
mov es, ax ; point es to video base
mov ds, ax ; point ds to video base
mov di, 3998 ; point di to lower right column
std ; set auto decrement mode
rep movsw ; scroll up
mov ax, 0x0720 ; space in normal attribute
pop cx ; count of positions to clear
rep stosw ; clear the scrolled space
pop ds
pop es
pop di
pop si
pop cx
pop ax
pop bp
ret 2




; push string 
;push location where to print 
print:
push bp
mov bp,sp
pushad
push es

mov si,[bp+6]
mov ax ,0xb800
mov es,ax
mov di ,[bp+4]
mov ax,0x0720
nextp:
lodsb 
cmp al,0
je done
stosw
jmp nextp
done:

pop es
popad
pop bp
ret 4