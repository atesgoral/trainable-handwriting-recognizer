const   maxitem=60;
type    box=array [0..15,0..15] of integer;
        str=array [1..maxitem] of char;
        buf=array [1..maxitem] of box;    
var     item,xs,ys,xi,yi,x,y,minx,maxx,miny,maxy,entry,avx,avy,cx,cy:integer;
        tp,tot,act,mte,st,lb,hb:integer;
        per,maxper,r,a,b,c,d,sn,cs,xn,yn,n,ravx,ravy:real;
        new:box;
        list:str;
        mem:buf;
        con:file of integer;
        ch:char;
label   rego,menu,quit,recalc;

procedure       getkey(var ch:char);
        var     ct:char;
        begin
        asm
        move.w  #7,-(a7)
        trap    #1
        addq.l  #2,a7
        move.w  d0,ct
        end;
        ch:=ct;
        end;    {procedure}
        
procedure       cls;
        begin
        asm
        lea     @clear,a0
        pea     (a0)
        move.w  #38,-(a7)
        trap    #14
        addq.l  #6,a7
        bra     @pasc0
@clear: movea.l $44e,a0
        move.w  #7679,d0
@cl:    clr.l   (a0)+
        dbf     d0,@cl
        rts
@pasc0: end;    {routine}
        end;    {procedure}
        
procedure       rescur;
        begin
        asm
        lea     @esc,a0
        pea     (a0)
        move.w  #9,-(a7)
        trap    #1
        addq.l  #6,a7
        bra     @pasc1
@esc:   dc.b    $1b,$59,32+24,32+2,$1b,75,0,0
@pasc1: end;    {routine}
        end;    {procedure}        

procedure       tstpix(x,y:integer;var st:integer);
        var     tt:integer;
        begin
        asm
        dc.w    $a000
        move.l  12(a0),a0
        move.w  x,(a0)+
        move.w  y,(a0)
        dc.w    $a002
        move.w  d0,tt
        end;    {routine}
        st:=tt;  
        end;    {procedure}

procedure       plot(x,y:integer);
        begin
        asm
        dc.w    $a000
        move.l  8(a0),a1
        move.l  12(a0),a0
        move.w  #1,(a1)
        move.w  x,(a0)+
        move.w  y,(a0)
        dc.w    $a001 
        end;    {routine}  
        end;    {procedure}                

procedure       mplot(cb:box;x,y,lb,hb:integer);
        var     cx,cy,val:integer;
        begin
        for cx:=0 to 15 do
                for cy:=0 to 15 do      begin
                                        val:=cb[cy,cx];
                                        if (val>=lb) and (val<=hb) then plot(cx+x,cy+y);
                                        end;
        end;                                        
                                                  
begin   {main}
        lb:=1;hb:=255;
        asm
        dc.w    $a00a
        clr.l   -(a7)
        move.w  #7,-(a7)
        trap    #14
        addq.l  #6,a7
        end;
        cls;
        rescur;write('1/Load 2/New');
        getkey(ch);
        if ch='1' then  begin
                        assign(con,'BRAIN.DMP');
                        reset(con);
                        read(con,entry);
                        for item:=1 to entry do begin
                                                read(con,tp);
                                                list[item]:=chr(tp);                     
                                                end;
                        for item:=1 to entry do
                                for cx:=0 to 15 do
                                        for cy:=0 to 15 do
                                                read(con,mem[item][cx,cy]);
                        close(con);
                        end
        else    begin
                entry:=1;
                for item:=0 to maxitem do
                        for cx:=0 to 15 do
                                for cy:=0 to 15 do
                                        mem[item][cx,cy]:=0;
                end;                               
rego:   cls;
        rescur;write('Draw shape, press right button.');
        minx:=639;maxx:=0;
        miny:=399;maxy:=0;
        asm
        lea     @draw(pc),a0
        pea     (a0)
        move.w  #38,-(a7)
        trap    #14
        addq.l  #6,a7
        bra     @pasc2
@draw:  clr.w   d5
        movea.l $44e,a5
@loop:  move.w  $2740,d3
        move.w  $2742,d4
        cmp.w   #383,d4
        bgt     @loop
        bsr     @poin2
        btst    #0,$e44
        bne     @sx
        btst    #1,$e44
        bne     @plot
        clr.w   d5
        bra     @loop
@plot:  bsr     @point
        bra     @loop
@point: lea     minx,a4
        cmp.w   (a4),d3
        bge     @gex
        move.w  d3,(a4)
@gex:   cmp.w   2(a4),d3
        ble     @lex
        move.w  d3,2(a4)
@lex:   cmp.w   4(a4),d4
        bge     @gey
        move.w  d4,4(a4)
@gey:   cmp.w   6(a4),d4
        ble     @ley
        move.w  d4,6(a4)
@ley:   tst.w   d5
        bne     @nvirg
        move.w  d3,d6
        move.w  d4,d7
@nvirg: dc.w    $a000
        move.w  d6,38(a0)
        move.w  d7,40(a0)
        move.w  d3,42(a0)
        move.w  d4,44(a0)
        move.w  #1,24(a0)
        move.w  #$ffff,34(a0)
        move.w  #$ffff,32(a0)
        move.w  #0,36(a0)
        dc.w    $a003
        move.w  d3,d6
        move.w  d4,d7
        moveq   #1,d5
@sx:    rts
@poin2: move.w  d4,d0
        mulu    #80,d0
        move.w  d3,d1
        move.w  d1,d2
        and.w   #$7,d2
        eor.w   #$7,d2
        lsr.w   #3,d1
        add.w   d1,d0
        bchg    d2,0(a5,d0)
        move.w  $464,d1
@vbl:   cmp.w   $464,d1
        beq     @vbl
        bchg    d2,0(a5,d0)
        rts
@pasc2: end;
        rescur;write('Calculating center of gravity...');
        ravx:=0;ravy:=0;n:=0;
        for cx:=minx to maxx do
                for cy:=miny to maxy do
                        begin
                        tstpix(cx,cy,st);
                        if st=1 then    begin                                   
                                        ravx:=ravx+cx;
                                        ravy:=ravy+cy;
                                        n:=n+1;
                                        end;
                        end;
        avx:=trunc(ravx/n+0.5);
        avy:=trunc(ravy/n+0.5);
        a:=0;b:=0;
        for cx:=0 to 15 do
                for cy:=0 to 15 do
                        new[cx,cy]:=0;
        r:=0;
        rescur;write('Calculating radial scaling and orientation factors...');
        for cx:=minx to maxx do
                for cy:=miny to maxy do
                        begin
                        x:=cx-avx;y:=cy-avy;
                        tstpix(cx,cy,st);
                        if st=1 then    begin
                                        ys:=y*y;xs:=x*x;
                                        a:=a+ys-xs;
                                        b:=b+x*y;
                                        r:=r+sqrt(xs+ys);
                                        end;                        
                        end;
        r:=4*n/r;
        c:=sqrt(a*a+4*b*b);
        d:=sqrt(2*c*(a+c));
        sn:=a+c;
        cs:=b+b;
        rescur;write('Correcting scaling and orientation...');
        for cx:=minx to maxx do
                for cy:=miny to maxy do
                        begin
                        x:=cx-avx;y:=cy-avy;
                        tstpix(cx,cy,st);
                        if st=1 then    begin
                                        xn:=(x*cs+y*sn)/d;
                                        yn:=(y*cs-x*sn)/d;
                                        xi:=trunc(xn*r+8.5);
                                        yi:=trunc(yn*r+8.5);
                                        new[xi,yi]:=1;
                                        end;
                        end;
        maxper:=0;mte:=-1;
recalc: cls;
        mplot(new,0,368,1,1);
        rescur;write('Comparing...');
        for item:=1 to entry do begin
                                act:=0;tot:=0;
                                for cx:=0 to 15 do
                                        for cy:=0 to 15 do      begin
                                                                tp:=mem[item][cx,cy];
                                                                if new[cx,cy]=1 then act:=act+tp;
                                                                tot:=tot+tp;
                                                                end;                                
                                if tot<>0 then per:=act/tot*100
                                else per:=0;
                                if per>maxper then      begin
                                                        maxper:=per;
                                                        mte:=item;
                                                        end;
                                end;
        rescur;
        if mte>0 then   begin
                        write(list[mte],' with',per:2:3,'%  ');
                        mplot(mem[mte],24,368,lb,hb);
                        end
        else write('No comment...  ');
menu:   write('1/Add 2/Define 3/Draw new 4/Save 5/Compare 6/Bounds 7/Quit');
        getkey(ch);
        if ch='2' then  begin   {define}
                        rescur;write('Press character key.');
                        getkey(ch);                        
                        mte:=0;
                        for item:=1 to entry do
                                if list[item]=ch then mte:=item;
                        if mte=0 then   begin
                                        entry:=entry+1;
                                        list[entry]:=ch;
                                        mte:=entry;
                                        ch:='1';
                                        end;
                        end;
        if ch='1' then  begin   {add}                              
                        for cx:=0 to 15 do
                                for cy:=0 to 15 do      begin
                                                        tp:=mem[mte][cx,cy];
                                                        if new[cx,cy]=1 then
                                                                if tp<255 then
                                                                        mem[mte][cx,cy]:=tp+1;
                                                        end;
                                    
                        end;
        
        if ch='4' then  begin   {save}
                        rescur;write('Number of characters: ',entry);
                        assign(con,'BRAIN.DMP');
                        rewrite(con);                        
                        write(con,entry);
                        for item:=1 to entry do begin                                                                        
                                                tp:=ord(list[item]);
                                                write(con,tp);
                                                end;
                        item:=1;
                        repeat
                        for cx:=0 to 15 do
                                for cy:=0 to 15 do  
                                        write(con,mem[item][cx,cy]);                                                    
                        item:=item+1;
                        until item>entry;                                                       
                        close(con);
                        end;
        if ch='3' then goto rego;       {resume}
        if ch='7' then goto quit;       {quit}         
        if ch='5' then goto recalc;     {recalculate}
        if ch='6' then  begin
                        rescur;write('Enter boundaries for display (low,high): ');                       
                        readln(lb,hb);
                        cls;
                        end;
        rescur;goto menu;
quit:   asm
        dc.w    $a009
        end;
        cls;
        rescur;writeln('Programming and algorithms by Ates Goral. March 1993.');
end.
