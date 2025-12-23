Program Seqedit;  {adds, merges, and deletes sequences}

{$I main\decl.pas}
{$I main\rdecl.pas}

const
  maxweekdrive = 48.0;
  maxweekwork = 53.5;
  maxdrive = 98.0;
  maxwork = 107.0;

var
  f : file of rows;
  s : word;
  ch : char;
  a,b : rows;
  boo,quit : boolean;
  co : array[1..7] of integer;
  i, num : integer;
  total,dtotal,week1,dweek1,week2,dweek2 : real;

Function Findo : word;
  var f : text;
      s : word;
  begin
    assign(f,'data\workfile.dat');
    reset(f);
    readln(f,s);
    close(f);
    write;
    findo:='data\' + s;
  end;

Function Findo2 : word;
  var f : text;
      s : word;
  begin
    assign(f,'data\workfile.dat');
    reset(f);
    readln(f,s);
    close(f);
    write;
    findo2:=s;
  end;

Procedure Calc;
  var i : integer;
  begin
    dweek1:=0; dweek2:=0;
    week1:=0; week2:=0;
    for i:=1 to 7 do  if a.day[i].route<>'' then begin week1:=week1+a.day[i].work; dweek1:=dweek1+a.day[i].drive; end;
    for i:=8 to 14 do if a.day[i].route<>'' then begin week2:=week2+a.day[i].work; dweek2:=dweek2+a.day[i].drive; end;
    total:=week1 + week2; dtotal:=dweek1+dweek2;
  end;

Procedure Init;
  var i : integer;
  begin
    co[1]:=4; co[2]:=13; co[3]:=24; co[4]:=36; co[5]:=46; co[6]:=56; co[7]:=66;
    with b do
      begin
        id:=0; identifier:='';
        for i:=1 to 14 do
          with day[i] do
            begin
              route:='';
              overnight:=false;
              overdays:=0;
              drive:=0; work:=0; days:=[];
            end;
      end;
  end;

Procedure Find(s : line; var boo : boolean);
  begin
    boo:=false;
    seek(f,0);
    repeat
      read(f,a);
      if a.identifier=s then begin boo:=true; seek(f,filepos(f)-1); end;
    until boo or eof(f);
  end;

Procedure Clear;
  var i : integer;
  begin
    gotoxy(4,20); for i:=1 to 60 do write(' ');
    gotoxy(4,20);
  end;

Procedure Screen;
  begin
    clrscr;
    writeln('                                                   ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('                                                   ³  Work   ³  Drive   ³');
    writeln('                                          ÚÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´');
    writeln('                                          ³ Week 1 :                    ³');
    writeln(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ Week 2 :                    ³');
    writeln(' ³   Sequence       ³ Seq. Entered :      ³ Total  :                    ³');
    gotoxy(38,6); writeln(filesize(f));
    writeln(' ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÁÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ´');
    writeln(' ³ Monday ³ Tuesday ³ Wednesday ³ Thursday ³ Friday ³ Saturday ³ Sunday ³');
    writeln(' ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´');
    writeln(' ³        ³         ³           ³          ³        ³          ³        ³');
    writeln(' ³        ³         ³           ³          ³        ³          ³        ³');
    writeln(' ³        ³         ³           ³          ³        ³          ³        ³');
    writeln(' ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´');
    writeln(' ³        ³         ³           ³          ³        ³          ³        ³');
    writeln(' ³        ³         ³           ³          ³        ³          ³        ³');
    writeln(' ³        ³         ³           ³          ³        ³          ³        ³');
    writeln(' ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÙ');
    writeln;
    writeln(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln(' ³                                                                      ³');
    writeln(' ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end;

Procedure Align(a : rows; i,j : integer);
  var x,y,p : integer;
  begin
    if i<=7 then y:=10 else y:=14;
    if i>7 then p:=i-7 else p:=i;
    x:=co[p];
    if j>0 then
      begin
        gotoxy(x,y); write('':7);
        gotoxy(x,y); write(a.day[i].route);
        gotoxy(x,y+1); write('':7);
        gotoxy(x,y+1); write(a.day[i].work:1:2);
        gotoxy(x,y+2); write('':7);
        gotoxy(x,y+2); write(a.day[i].drive:1:2);
      end
      else
      if j=0 then
      begin
        gotoxy(x,y);   write('<-OVN-');
        gotoxy(x,y+1); write('':6);
        gotoxy(x,y+2); write('':6);
      end
      else
      begin
        gotoxy(x,y);   write('':6);
        gotoxy(x,y+1); write('':6);
        gotoxy(x,y+2); write('':6);
      end;
  end;

Procedure Checkhours;
  var boo : boolean;
  begin
    boo:=false;
    gotoxy(60,6);if total>maxwork then begin write('*'); boo:=true; end else write(' ');
    gotoxy(60,4);if week1>maxweekwork then begin write('*'); boo:=true; end else write(' ');
    gotoxy(60,5);if week2>maxweekwork then begin write('*'); boo:=true; end else write(' ');
    gotoxy(70,6);if dtotal>maxwork then begin write('*'); boo:=true; end else write(' ');
    gotoxy(70,4);if dweek1>maxweekdrive then begin write('*'); boo:=true; end else write(' ');
    gotoxy(70,5);if dweek2>maxweekdrive then begin write('*'); boo:=true; end else write(' ');
    if boo then write(chr(7));
  end;

Procedure Showdata(a : rows);
  var count,i : integer;
  begin
    calc;
    checkhours;
    gotoxy(38,6); write(filesize(f));
    gotoxy(54,4); write(week1:6:2);
    gotoxy(54,5); write(week2:6:2);
    gotoxy(54,6); write(total:6:2);
    gotoxy(64,4); write(dweek1:6:2);
    gotoxy(64,5); write(dweek2:6:2);
    gotoxy(64,6); write(dtotal:6:2);
    boo:=false;
    count:=0;
    for i:=1 to 14 do
      if count>0 then
        begin
          align(a,i,0);
          count:=count-1;
        end
        else
      if (a.day[i].route<>'') then
        begin
          align(a,i,i);
          if a.day[i].overnight then count:=a.day[i].overdays;
        end
      else align(a,i,-1);
  end;

Procedure Pop;
  var i : integer;
  begin
    for i:=filepos(f) to filesize(f)-2 do
    begin seek(f,I+1); read(f,a); seek(f,I); write(f,a); end;
    truncate(f);
  end;

Procedure Wait;
  var ch : char;
  begin repeat until keypressed; end;

Procedure Getchars(var s : word; digits : integer);
  var
    boo : boolean;
    ch : char;
    i  : integer;
  begin
    num:=0; i:=0; quit:=false; boo:=false; wait;
    repeat
       i:=i+1;
      repeat
        read(kbd,ch); if keypressed then read(kbd,ch);
        if ch=#27 then quit:=true;
        if ch=#8 then if i>1 then begin i:=i-1; write(#8,' ',#8); end;
        if ch=#13 then begin boo:=true; digits:=i-1; end;
      until quit or ((not (ord(ch) in [0,7,8,9,10,11,12,13,27,28,29,30,31,255]))
            and (i<=digits)) or boo;
      if not (quit or boo) then begin s[i]:=ch; write(s[i]); end;
    until boo or quit;
    s[0]:=chr(digits);
  end;

Procedure Delseq;  {deletes sequence}
  var boo : boolean;
  begin
    assign(f,findo+'.seq');
    reset(f);
    screen;
    repeat
      clear; write('Sequence to delete : '); getchars(s,3);
      if s='' then quit:=true;
      if not quit then
        begin
          find(s,boo); {looks for it}
          if boo
            then
              begin
                showdata(a);
                clear; write('Are you sure? ');
                repeat
                  wait;
                  read(kbd,ch);
                  if ch=#27 then if keypressed then read(kbd,ch);
                until ch in ['n','N','y','Y',#27];
                if ch in ['y','Y'] then
                  begin
                    clear; write('Deleting Sequence...'); pop;
                  end else boo:=false;
              end
            else begin clear; write('Sequence not found...'); delay(300); end;
        end;
    until quit or boo;
    close(f);
    quit:=false;
  end;

Procedure Seqmenu;
  begin
    clrscr;
    writeln;
    writeln;
    writeln;
    writeln('                            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('                            ³  Sequence Editing  ³');
    writeln('           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('           ³                                                      ³');
    writeln('           ³  1. Edit route sequences                             ³');
    writeln('           ³  2. Add a blank sequence                             ³');
    writeln('           ³  3. Delete a sequence                                ³');
    writeln('           ³  4. Print list of sequences                          ³');
    writeln('           ³  5. Create an optimized route schedule               ³');
    writeln('           ³  6. Merge two sequence files                         ³');
    writeln('           ³  7. Exit                                             ³');
    writeln('           ³                                                      ³');
    writeln('           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    writeln('           ³  Selection :                                         ³');
    writeln('           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end;

Function ten(i : integer) : integer;
  var j,sum : integer;
  begin
    sum:=1; for j:=1 to i do sum:=sum*10; ten:=sum;
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

Procedure Getsel(var num : integer);
  begin
    gotoxy(27,17); write(' '); gotoxy(27,17);
    getnumonly(num,1);
  end;

Procedure Run(s : word);
  var g : file;
  begin
    s:=s+'.com';
    assign(g,s);
    execute(g);
  end;

Procedure Add; {adds a sequence}
  var fpos,num,i : integer;
  begin
    assign(f,findo+'.seq');
    reset(f);
    if filesize(f)=0 then begin num:=1; fpos:=0; end else
      begin
        seek(f,filesize(f)-1);
        read(f,a); val(a.identifier,num,i); {gets number}
        num:=num+1; fpos:=filesize(f); {adds 1}
      end;
    gotoxy(15,17);
    write('Add Sequence ',num,' : Are you sure? ');
    repeat
      wait;
      read(kbd,ch);
    until ch in [#27,'n','N','y','Y'];
    if ch in ['y','Y'] then
      begin
        gotoxy(15,17); for i:=1 to 45 do write(' '); gotoxy(15,17);
        write('Adding Sequence ',num);
        str(num,b.identifier);
        seek(f,fpos); write(f,b);
        delay(500);
      end;
    close(f);
  end;

Procedure Merge;

var
  a,b : rows;
  m,s : file of rows;
  main,sub : word;
  i, num, seq : integer;

Procedure Gettwo;
  begin
    quit:=false;
    gotoxy(43,12); getchars(sub,8);
    if not quit then if sub='' then quit:=true;
  end;

Procedure Merging;
  begin
    assign(m,findo + '.seq');   {opens original file}
    assign(s,'data\' + sub  + '.seq'); {opens new file}
    reset(m); reset(s);
    seek(m,filesize(m)-1);
    read(m,a); val(a.identifier,seq,i);
    i:=0;
    repeat
      i:=i+1;
      read(s,a);        {reads one from new file}
      str(seq+i,a.identifier);  {keeps order of numbers}
      write(m,a);       {writes to workfile}
    until eof(s);
    close(s);
    close(m);
  end;

Procedure Screen;
  begin
    clrscr;
    writeln;
    writeln;
    writeln;
    writeln;
    writeln;
    writeln;
    writeln;
    writeln('                            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('                            ³  Merge Sequences  ³');
    writeln('                        ÚÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄ¿');
    writeln('                        ³ Main File     : ',findo2:8,'  ³');
    writeln('                        ³ File to merge :           ³');
    writeln('                        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end;

begin
  screen;  {shows sceen}
  gettwo;  {gets new workfile name}
  if not quit then merging  {merges}
              else quit:=false;
  writeln;
  writeln;
end;

Procedure Main;
  begin
    init;
    quit:=false;
    repeat;
      seqmenu;
        repeat
          getsel(num);
        until (num in [1..7]) or quit;
        if quit then write('Quit');
        case num of
          1 : run('redit');
          2 : add;
          3 : delseq;
          4 : run('seqprint');
          5 : run('zero');
          6 : merge;
          7 : begin quit:=true; write(chr(8),'Quit'); end;
          end;
    until quit;
    writeln;
  end;

begin
  textcolor(white);
  textbackground(blue);
  main;
  run('main');
end.