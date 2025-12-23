Procedure Run(s : word);
  var g : file;
  begin
    s:=s+'.com';
    assign(g,s);
    execute(g);
  end;

Procedure Showdata(a : driver); forward;

Procedure Showfile(s : word);
  var
    f : text;
    l : line;
  begin
    clrscr;
    assign(f,s); reset(f);
    repeat readln(f,l); writeln(l); until eof(f);
    close(f);
  end;

Procedure Idsearch(target : integer; var a : driver; var found : boolean);
  var
    i,hi,lo,mid : integer;
  begin
    num:=filesize(f); hi:=num; lo:=1; found:=false;
    while (not found) and (hi-lo>=0) do
      begin
        mid:=(lo+hi) div 2; seek(f,mid-1); read(f,a); i:=a.id;
        if target<i then hi:=mid-1
                    else if target>i then lo:=mid+1 else found:=true;
      end;
    seek(f,filepos(f)-1);
  end;

Function Stime(t : integer) : timetype;
  var
    i : integer;
    s : timetype;
  begin
    str(t,s); for i:=1 to 4-length(s) do s:='0'+s; stime:=s;
  end;

Procedure Wait;
  var ch : char;
  begin repeat until keypressed; end;

Procedure Waitc;
  begin gotoxy(4,24); wait; end;

Procedure Clear;
  var i : integer;
  begin gotoxy(6,21); for i:=6 to 72 do write(' '); end;

Procedure Clear2;
  var i : integer;
  begin gotoxy(6,23); for i:=6 to 72 do write(' '); end;

Procedure Show(s : line);
  var i : integer;
  begin
    clear; gotoxy(6,21);
    for i:=6 to 39-(length(s) div 2) do write(' '); write(s);
  end;

Function ten(i : integer) : integer;
  var j,sum : integer;
  begin
    sum:=1; for j:=1 to i do sum:=sum*10; ten:=sum;
  end;

Function tendec(i : integer) : real;
  var j : integer; sum : real;
  begin
    sum:=1; for j:=1 to i do sum:=sum*10; tendec:=sum;
  end;

Procedure Getnum(var num : integer; digits : integer);
  var
    boo : boolean;
    ch : char;
    dummy,i  : integer;
    n : array[1..10] of integer;
  begin
    num:=0; i:=0; quit:=false; boo:=false; wait;
    repeat
       i:=i+1;
      repeat
        read(kbd,ch);
        if ch=chr(27) then if not keypressed then quit:=true;
        if ch=chr(8) then if i>1 then begin i:=i-1; write(chr(8),' ',chr(8)); end;
        if ch=chr(13) then begin boo:=true; digits:=i-1; end;
      until quit or ((ch in ['0'..'9']) and (i<=digits)) or boo;
      if not (quit or boo) then begin val(ch,n[i],dummy); write(n[i]); end;
    until boo or quit;
    if not quit then for i:=1 to digits do num:=num+n[i]*ten(digits-i);
  end;

Procedure Getdecimal(var num : real; digits : integer);
  var
    one, boo : boolean;
    ch : char;
    z,dummy,i  : integer;
    n : array[1..10] of integer;
  begin
    one:=false; z:=0; num:=0; i:=0; quit:=false; boo:=false; wait;
    repeat
       i:=i+1;
      repeat
        read(kbd,ch);
        if ch=chr(27) then if not keypressed then quit:=true;
        if ch=chr(8) then if i>1 then begin i:=i-1; write(chr(8),' ',chr(8));
                                      if z=i then begin i:=i+1; z:=0; one:=false; end;
                                      end;
        if ch=chr(13) then begin boo:=true; digits:=i-1; end;
      until quit or (((ch in ['0'..'9']) or ((ch='.') and not one)) and (i<=digits)) or boo;
      if not (quit or boo) then begin if ch<>'.' then begin val(ch,n[i],dummy); write(n[i]); end
                                                 else begin write(ch); z:=i-1;i:=i-1; one:=true; end;
                                end;
    until boo or quit;
    if not quit then for i:=1 to digits do num:=num+n[i]*tendec(digits-i);
    if not quit then if one then num:=num/(tendec(digits-z));
  end;

Procedure Getchars(var s : word; digits : integer);
  var
    boo : boolean;
    ch : char;
    i  : integer;
  begin
    for i:=1 to digits do s[i]:=' ';
    num:=0; i:=0; quit:=false; boo:=false; wait;
    repeat
       i:=i+1;
      repeat
        read(kbd,ch);
        if ch=chr(27) then if not keypressed then quit:=true;
        if ch=chr(8) then if i>1 then begin i:=i-1; write(chr(8),' ',chr(8)); end;
        if ch=chr(13) then begin boo:=true; digits:=i-1; end;
      until quit or ((not (ord(ch) in [0,7,8,9,10,11,12,13,27,28,29,30,31,255]))
            and (i<=digits)) or boo;
      if not (quit or boo) then begin s[i]:=ch; write(s[i]); end;
    until boo or quit;
    s[0]:=chr(digits);
  end;

Procedure Getnumonly(var num : integer; digits : integer);
  var
    boo : boolean;
    ch : char;
    dummy,i  : integer;
    n : array[1..10] of integer;
  begin
    num:=0; i:=0; quit:=false; boo:=false; wait;
    repeat
       i:=i+1;
      repeat
        read(kbd,ch);
        if ch=chr(27) then if not keypressed then quit:=true
                      else begin read(kbd,ch); if ord(ch)=59 then quit:=true; end;
        if ch=chr(8) then if i>1 then begin i:=i-1; write(chr(8),' ',chr(8)); end;
      until quit or (ch in ['0'..'9']);
      if not quit then begin val(ch,n[i],dummy); write(n[i]); end;
    until (i=digits) or quit;
    if not quit then for i:=1 to digits do num:=num+n[i]*ten(digits-i);
  end;

Procedure Get(s : line; var x : integer; l : integer);
  var n : integer;
  begin
    if l in [1..9] then
      begin
        clear;
        gotoxy(7,21); write(s);
        getnum(n,l);
        x:=n;
      end;
  end;

Procedure Getdec(s : line; var x : real; l : integer);
  begin
    if l in [1..9] then
      begin
        clear;
        gotoxy(7,21); write(s);
        getdecimal(x,l);
      end;
  end;

Procedure Gets(s : line; var t : word; l : integer);
  var u : word;
      i : integer;
  begin
    for i:=1 to l do u[i]:=' ';
    u[0]:=chr(l);
    if l in [1..10] then
      begin
        clear;
        gotoxy(7,21); write(s);
        getchars(u,l);
        if not quit then
          begin
            t:=u;
            for i:=1 to l-length(t) do t[length(t)+i]:=' ';
            t[0]:=chr(l);
          end;
      end;
  end;

Procedure Waitf(var ch:char; var boo: boolean; corner : boolean);
  begin
    boo:=false;
    if corner then waitc else wait; read(kbd,ch);
    if ch=chr(27) then if keypressed then begin read(kbd,ch); boo:=true; end;
  end;

Procedure Waitfnoc(var ch:char; var boo: boolean);
  begin
    boo:=false;
    wait; read(kbd,ch);
    if ch=chr(27) then if keypressed then begin read(kbd,ch); boo:=true; end;
  end;

Procedure Getc(s : line; var ch : char; corner : boolean);
  var boo : boolean;
  begin
    clear;
    gotoxy(7,21); write(s);
    waitf(ch,boo,corner);
  end;

Procedure Calcday(var a : driver; w,d : integer);
  var min,hr : integer;
  begin
    with a.week[w].day[d] do
      begin
        if excuse='' then
          begin
            min:=endtime-starttime;
            hr:=min div 100;
            min:=min-hr*100;
            if (hr<0) or (min<0)  then begin min :=0; hr:=0; starttime:=0; endtime:=0; end;
            total:=hr+(min/60);
            min:=min-45;
            if min<0 then if hr>=1 then begin min:=60+min; hr:=hr-1; end else min:=0;
            if hr<0 then hr:=0;
            drive:=hr+(min/60);
          end else begin total:=0; drive:=0; starttime:=0; endtime:=0; overdays:=0; end;
      end;
  end;

Procedure Calcweek(var a : driver; w : integer);
  var sum,sum2 : real;
        i : integer;
  begin
    sum:=0; sum2:=0;
    with a.week[w] do
      begin
        for i:=1 to 6 do begin sum:=sum+day[i].total; sum2:=sum2+day[i].drive; end;
        wtotal:=sum; wdrive:=sum2;
      end;
  end;

Procedure Calcperiod(var a : driver);
  begin
    a.total:=a.week[1].wtotal+a.week[2].wtotal;
    a.drive:=a.week[1].wdrive+a.week[2].wdrive;
  end;

Procedure Recalc(var a : driver; wk,da : integer);
  begin
    show('Calculating...');
    calcday(a,wk,da);
    calcweek(a,wk);
    calcperiod(a);
    showdata(a);
    clear;
  end;

Procedure Turn(i : integer; o : offon);
  var w,d : integer;
  begin
    if o=on then textcolor(cyan);
    with a do
      begin
        case i of
          1..6   : begin with week[1].day[i] do begin gotoxy(17,10+i);
                   if excuse='' then begin write(stime(starttime),'-',stime(endtime));
                                   if overdays<>0 then write('*') else write(' '); end
                              else write(excuse); end; end;
          7..12  : begin gotoxy(33,10+i-6); write(week[1].day[i-6].route); end;
          13..18 : begin with week[2].day[i-12] do begin gotoxy(52,10+i-12);
                   if excuse='' then begin write(stime(starttime),'-',stime(endtime));
                                   if overdays<>0 then write('*') else write(' '); end
                              else write(excuse); end; end;
          19..24 : begin gotoxy(68,10+i-18); write(week[2].day[i-18].route); end;
          end;
      end;
    textcolor(yellow);
  end;

Procedure Showdata;
  var i : integer;
  begin
    with a do
    begin
    gotoxy(23,5); write(id);
    gotoxy(47,5); write(first+' '+last); for i:=1 to 25-length(first+' '+last) do write(' ');
    gotoxy(73,5); if citizen=german then write('G') else write('A');
    gotoxy(26,7); write(total:1:2); gotoxy(64,7); write(drive:1:2);
    gotoxy(22,9); write(week[1].m,'/',week[1].d);
    gotoxy(57,9); write(week[2].m,'/',week[2].d);
    for i:=1 to 6 do
      begin
        with week[1].day[i] do
          begin
            gotoxy(17,10+i);
            if excuse='' then write(stime(starttime),'-',stime(endtime))
                       else write(excuse);

            if (excuse='') and (overdays<>0) then write('*') else write(' ');
            gotoxy(28,10+i); write(total:1:1); if total<10 then write(' ');
            gotoxy(33,10+i); write(route);
          end;

        with week[2].day[i] do
          begin
            gotoxy(52,10+i);
            if excuse='' then write(stime(starttime),'-',stime(endtime))
                       else write(excuse);
            if (excuse='') and (overdays<>0) then write('*') else write(' ');;
            gotoxy(63,10+i); write(total:1:1); if total<10 then write(' ');
            gotoxy(68,10+i); write(route);
          end;
      end;
    gotoxy(32,18);write(week[1].wtotal:1:2);if week[1].wtotal<100 then if week[1].wtotal<10 then write('  ') else write(' ');
    gotoxy(67,18);write(week[2].wtotal:1:2);if week[2].wtotal<100 then if week[2].wtotal<10 then write('  ') else write(' ');
    gotoxy(32,19);write(week[1].wdrive:1:2);if week[1].wdrive<100 then if week[1].wdrive<10 then write('  ') else write(' ');
    gotoxy(67,19);write(week[2].wdrive:1:2);if week[2].wdrive<100 then if week[2].wdrive<10 then write('  ') else write(' ');
  end;
end;

Procedure Getsel(var num : integer);
  begin
    gotoxy(27,16); write(' '); gotoxy(27,16);
    getnumonly(num,1);
  end;

Procedure Getid(var id : integer);
  begin
    error:=false; gotoxy(23,5); write('    '); gotoxy(23,5); getnum(num,5);
  end;

Procedure Doid(getkey : offon);
  begin
    repeat
      getid(num);
      if not (error and quit) then idsearch(num,a,boo) else boo:=false;
      if not quit then
        begin
          if boo then if not boo2 then begin showdata(a); options(0);
                                  if getkey=on then begin show('Press any key to continue'); waitc; end; end;

          if not boo then show('Driver Not Found: Please Re-enter Id#.  ESC to quit');
        end;
    until boo or quit;
    boo:=false;
  end;

Procedure Save;
  begin
    show('Saving Data...');
    write(f,a);
    flush(f);
    seek(f,filepos(f)-1);
    delay(300);
    show('Select Field to Edit');
  end;

Procedure Check(var cancel : boolean);
  var ch : char; boo : boolean;
  begin
    cancel:=true;
    repeat
      boo:=true;
      clear;
      getc('Do you want to save the edited data before quitting (y/n)? ',ch,false);
      if ch in ['y','Y'] then begin save; write(ch); end else
      if ch in ['n','N'] then write(ch) else
      if ch=chr(27) then cancel:=false else boo:=false;
    until boo;
    if not cancel then show('Select Field to Edit');
  end;

Procedure Init(b : driver);
  var i,j : integer;
  begin
    b.total:=0;
    b.drive:=0;
    b.payrate:=15.00;
    for i:=1 to 2 do
      begin
        b.week[i].wtotal:=0;
        b.week[i].wdrive:=0;
        b.week[i].m:=5;
        b.week[i].d:=23;
        for j:=1 to 6 do
          with b.week[i].day[j] do
            begin
              done:=false;
              overdays:=0;
              hotel:=0;
              endtime:=0;
              starttime:=0;
              route:='None';
              total:=0;
              drive:=0;
            end;
      end;
   end;
