Program Editroutedata;

{$I main\decl.pas}          {reads in variable declarations}
{$I main\rdecl.pas}         {"     "      "          "     }

const
  maxweekdrive = 48.0;        {these are constants for maximum hours}
  maxweekwork = 53.5;
  maxdrive = 98.0;
  maxwork = 107.0;

var
  f3 : file of rows;               {sequence file}
  num,i,j : integer;
  g : file;
  s2 : word;                       {string}
  t : line;                        {bigger string}
  indent : array[1..6] of integer;
  a : rows;
  quit2,quit,boo : boolean;        {counters}
  week1, week2, total : real;      {totals for week1}
  dweek1, dweek2, dtotal : real;   {totals for week2}
  co : array[1..7] of integer;

Procedure Calc;                    {calculate the totals of work, driving}
  var i : integer;
  begin
    dweek1:=0; dweek2:=0;
    week1:=0; week2:=0;
    for i:=1 to 7 do  if a.day[i].route<>'' then begin week1:=week1+a.day[i].work; dweek1:=dweek1+a.day[i].drive; end;
    for i:=8 to 14 do if a.day[i].route<>'' then begin week2:=week2+a.day[i].work; dweek2:=dweek2+a.day[i].drive; end;
    total:=week1 + week2; dtotal:=dweek1+dweek2;
  end;

Function Findo : word;   {finds workfile}
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

Procedure Run(s : word);
  var g : file;
  begin
    s:=s+'.com';
    assign(g,s);
    execute(g);
  end;

Function ten(i : integer) : integer;
  var j,sum : integer;
  begin
    sum:=1; for j:=1 to i do sum:=sum*10; ten:=sum;
  end;

Procedure Clear;
  var i : integer;
  begin
    gotoxy(4,20); for i:=1 to 60 do write(' ');
    gotoxy(4,20);
  end;

Procedure Init;   {initialize variable.  the 7 parts of the below array are the x coordinates for the marker of the boxes}
  begin           {as you move around}
    co[1]:=4; co[2]:=13; co[3]:=24; co[4]:=36; co[5]:=46; co[6]:=56; co[7]:=66;
  end;

Procedure Save(a : rows);    {saves edited sequence}
  begin
    clear; write('Saving Sequence...');
    write(f3,a);
    seek(f3,filepos(f3)-1);
    delay(300);
    clear;
  end;

Procedure Check(var boo : boolean);  {doesn't let you quit until you've saved or said NO}
  var ch : char; done:boolean; i : integer;
  begin
    clear;
    write('Save changes before quitting? ');
    repeat
      boo:=true; done:=true;
      repeat until keypressed; read(kbd,ch); if keypressed then read(kbd,ch);
      if ch in ['y','Y'] then save(a) else
      if ch in ['n','N'] then else
      if ch=chr(27) then boo:=false else done:=false;
    until done;
    if boo=false then clear;
  end;

Procedure Wait;
  begin repeat until keypressed; end; {waits}

Procedure Waitc;
  begin gotoxy(2,21); wait; end;      {waits at corner of screen}

Procedure Waitf(var ch:char; var boo: boolean);
  begin
    boo:=false;                       {waits for function key}
    waitc;
    read(kbd,ch);
    if ch=chr(27) then if keypressed then begin read(kbd,ch); boo:=true; end;
  end;

Procedure Getnum(var num : integer; digits : integer);
  var
    boo : boolean;
    ch : char;                        {gets only a number, no characters}
    dummy,i  : integer;
    n : array[1..10] of integer;
  begin
    num:=0; i:=0; quit:=false; boo:=false; wait;
    repeat
       i:=i+1;
      repeat
        read(kbd,ch);
        if ch=chr(27) then if not keypressed then quit:=true;
        if ch=chr(8) then if i>1 then begin i:=i-1; write(chr(8)); end;
        if ch=chr(13) then begin boo:=true; digits:=i-1; end;
      until quit or ((ch in ['0'..'9']) and (i<=digits)) or boo;
      if not (quit or boo) then begin val(ch,n[i],dummy); write(n[i]); end;
    until boo or quit;
    if not quit then for i:=1 to digits do num:=num+n[i]*ten(digits-i);
  end;

Function tendec(i : integer) : real;
  var j : integer; sum : real;  {ten to a power, decimal returned}
  begin
    sum:=1; for j:=1 to i do sum:=sum*10; tendec:=sum;
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
       i:=i+1;                   {gets a decimal, no chars allowed but '.'}
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
       i:=i+1;        {gets a string, looks for escapes while typing}
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

Procedure Gets(s : line; var t : word; l : integer);
  var u : word;
      i : integer;
  begin
    if l in [1..10] then
      begin
        gotoxy(4,20); for j:=1 to 32 do write(' ');
        gotoxy(4,20); write(s);
        getchars(u,l);
        if not quit then t:=u else t:='';
      end;
  end;

Procedure Mark(curr : integer; boo : offon);
  var x,y,j : integer;
  begin                         {this procedure marks each box as you move the cursor while editing}
    x:=0; y:=0;
    j:=curr mod 7; if j=0 then j:=7;
    x:=co[j]-1;
    if curr<8 then y:=10 else y:=14;
    gotoxy(x,y);
    if boo=off then write(' ') else write(chr(16));
  end;

Function Onecase(s : word) : word;
  var
    i : integer;
  begin
    for i:=1 to length(s) do if s[i] in['a'..'z'] then s[i]:=upcase(s[i]);
    onecase:=s;       {makes a string all upper-case}
  end;

Procedure Find(s : line; var boo : boolean);
  begin
    boo:=false;
    seek(f3,0);
    if not eof(f3) then    {finds a sequence in the file, s is the string of the sequence #}
      repeat
        read(f3,a);
        if a.identifier=s2 then begin boo:=true; seek(f3,filepos(f3)-1); end;
      until boo or eof(f3);
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
    gotoxy(38,6); writeln(filesize(f3));
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
  var x,y,p : integer;          {this prints the info in the chart in the right boxes and makes it look nice}
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
  var boo : boolean;  {makes sure nothing is over the maximum hours}
  begin
    boo:=false;
    gotoxy(60,6);if total>maxwork then begin write('*'); boo:=true; end else write(' ');
    gotoxy(60,4);if week1>maxweekwork then begin write('*'); boo:=true; end else write(' ');
    gotoxy(60,5);if week2>maxweekwork then begin write('*'); boo:=true; end else write(' ');
    gotoxy(70,6);if dtotal>maxdrive then begin write('*'); boo:=true; end else write(' ');
    gotoxy(70,4);if dweek1>maxweekdrive then begin write('*'); boo:=true; end else write(' ');
    gotoxy(70,5);if dweek2>maxweekdrive then begin write('*'); boo:=true; end else write(' ');
    if boo then write(chr(7));
  end;

Procedure Showdata(a : rows);
  var count,i : integer;
  begin
    calc;
    checkhours;
    gotoxy(38,6); write(filesize(f3));  {prints all the total hours in upper-right corner}
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

Procedure Input(curr : integer; var changes : boolean);  {gets info about new routes as you enter info}
  var ch : char; s: word; l : real; x : integer; w,d : real; on : boolean; od : integer;
  begin
    clear; gets('Enter New Route : ',s,6);
    s:=onecase(s);
    if (s='') and (not quit) then
      begin
        quit:=true;
        changes:=true;
        with a.day[curr] do
          begin
            route:=''; work:=0; drive:=0; overnight:=false; overdays:=0;
            showdata(a);
          end;
      end;
    if not quit then
      begin
        clear; write('Enter Total Work Time : '); getdecimal(w,6);
        if not quit then
          begin clear; write('Enter Total Driving Time : '); getdecimal(d,6); end;
        if not quit then
          begin
            clear; write('Overnight? ');
            repeat
              repeat until keypressed; read(kbd,ch);
            until ch in ['y','Y','n','N',#13];
            if ch in ['y','Y'] then
              begin
                on:=true;
                clear; write('How many days overnight? '); getnum(od,1);
              end else begin on:=false; od:=0; end;
          end;
        if not quit then
          begin
            changes:=true;
            with a.day[curr] do
              begin
                route:=s; work:=w; drive:=d; overnight:=on; overdays:=od;
              end;
            l:=frac(a.day[curr].work);
            if (l<>0.25) and (l<>0.75) and (l<>0.5) then a.day[curr].work:=int(a.day[curr].work)+(l/0.6);
            l:=frac(a.day[curr].drive);
            if (l<>0.25) and (l<>0.5) and (l<>0.75) then a.day[curr].drive:=int(a.day[curr].drive)+(l/0.6);
            if on then for j:=1 to od do a.day[curr+j].route:='';
            showdata(a);
          end;
      end;
    clear;
    write('Select Day to Edit');
    quit:=false;
  end;

Procedure Doovernight(i : integer; var changes : boolean);
  var boo : boolean;
  begin
    boo:=true;                  {checks to see if a route is overnight when you delete it from the sequence}
    if i>7 then i:=i-7;         {is has to remove the arrows}
    if i in [1..6] then
      begin
        if a.day[i].overnight then a.day[i].overnight:=false else
          if a.day[i-1].overnight then begin i:=i-1 ; a.day[i].overnight:=false end else
            if i<>6 then
              if not a.day[i+1].overnight then a.day[i].overnight:=true
                else
                  else boo:=false;
        if boo then
          begin
            changes:=true;
            showdata(a);
          end;
      end;
  end;

Procedure Edit;
  var ch : char; curr,last : integer;
      changes, back, func : boolean;
  begin
    back:=false;             {this is the main part of the editor}
    repeat
      changes:=false;
      gotoxy(15,6);
      write(a.identifier,'  ');
      curr:=1; last:=1;
      showdata(a); clear; write('Select Day to Edit');
      repeat
        mark(last,off);
        mark(curr,on);
        waitf(ch,func);
        last:=curr; i:=0;
        if func then
          case ord(ch) of
            59 : if changes then check(quit2) else quit2:=true; {F1, check saving before ending program}
            68 : begin save(a); changes:=false; end;  {save file}
            72 : if curr in [1..7] then i:=7 else i:=-7;
            75 : if curr in [1,8] then i:=6 else i:=-1;
            77 : if curr in [7,14] then i:=-6 else i:=1;
            80 : if curr in [8..14] then i:=-7 else i:=7;
            end
          else
          case ord(ch) of
            13 : begin input(curr,changes); i:=0; end;       {return pressed, get input}
            27 : if changes then check(quit) else quit:=true;   {ESC is pressed, quit after checking about saving}
            end;
       curr:=curr+i;
      until quit or quit2;
    until quit or quit2;
    mark(curr,off);
    quit:=false;
  end;

begin
  quit:=false;
  quit2:=false;
  assign(f3,findo + '.seq');
  reset(f3);
  init;
  repeat;
    clrscr;
    screen;
    repeat
      gotoxy(4,20);
      write('Route sequence to edit : ');
      Gets('Route sequence to edit : ',s2,3);
      clear;
      if quit then begin boo:=true; quit2:=true; quit:=false; end else
      if s2='' then begin boo:=true; quit2:=true; writeln; end
        else
          begin
            find(onecase(s2),boo);
            if boo then
            edit
            else begin clear; write('Can''t find sequence...'); delay(1000); end
          end;
    until boo or quit2;
  until quit2;
  close(f3);
  run('edseq');
end.