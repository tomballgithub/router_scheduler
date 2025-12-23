Program Createnewrouteschedule;  {menu, add and delete routes}

{$I main\decl.pas}        {reading in declarations}
{$I main\rdecl.pas}

type
  weektype = set of daytype;

var
  quit : boolean;
  w,x : word;
  a : rectype;              {holds one route}
  d : daytype;              {holds one day of the week}
  j,k,l : real;
  i, dummy : integer;
  f : file of rectype;      {route file}
  g : file;
  max : integer;
  s : word;
  ch : char;

Function Find : word;
  var f : text;
      s : word;
  begin
    assign(f,'data\workfile.dat');
    reset(f);
    readln(f,s);
    close(f);
    write;
    find:='data\' + s;
  end;

Procedure Run(s : word);
  var g : file;
  begin
    s:=s+'.com';
    assign(g,s);
    execute(g);
  end;

Procedure Wait;
  begin
    repeat until keypressed;
  end;

Procedure Waitf;
  begin
    repeat until keypressed; read(kbd,ch);
    if keypressed then read(kbd,ch);
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
      until quit or (ch in ['0'..'9']) or ((ch=#13) and (i=1));
      if (not quit) and (ch<>#13) then begin val(ch,n[i],dummy); write(n[i]); end;
    until (i=digits) or quit or (ch=#13);
    if ch=#13 then begin num:=0 ;write('0'); end
      else
      if not quit then for i:=1 to digits do num:=num+n[i]*ten(digits-i);
  end;

Procedure Getchars(var s : word; digits : integer);
  var
    boo : boolean;
    ch : char;
    num,i  : integer;
  begin
    s:='';
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
    if quit then s[0]:=#0
            else s[0]:=chr(digits);
  end;

Procedure Clear;
  var i : integer;
  begin
    gotoxy(11,19);
    for i:=11 to 67 do write(' ');
    gotoxy(11,19);
  end;

Procedure Mainmenu; forward;  {says the main menu is coming later}

Function Onecase(s : word) : word;
  var
    i : integer;
  begin
    for i:=1 to length(s) do if s[i] in['a'..'z'] then s[i]:=upcase(s[i]);
    onecase:=s;
  end;

Procedure Ask(var s : word);  {finds which route to edit}
  begin
    clear;
    write('Enter route to Edit : ');
    quit:=false;
    getchars(s,6);
    if (s<>'') and not quit then
      begin
        seek(f,0);
        if not eof(f) then
          repeat
            read(f,a);
          until (onecase(a.route)=onecase(s)) or eof(f);
        if onecase(a.route)<>onecase(s) then begin clear; write('Route ',onecase(s),' not found...');
                                        quit:=true; delay(700); end;
        if not eof(f) then seek(f,filepos(f)-1);
      end else quit:=true;
  end;

Function tendec(i : integer) : real;
  var j : integer; sum : real;
  begin
    sum:=1; for j:=1 to i do sum:=sum*10; tendec:=sum;
  end;

Procedure Getdecimal(var num : real; digits : integer; var ret : boolean);
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
                                      end else
                          if (i=1) and (z=0) and (one) then
                            begin write(chr(8),' ',chr(8)); one:=false; end;
        if ch=chr(13) then begin boo:=true; digits:=i-1; end;
      until quit or (((ch in ['0'..'9']) or ((ch='.') and not one)) and (i<=digits)) or boo;
      if not (quit or boo) then begin if ch<>'.' then begin val(ch,n[i],dummy); write(n[i]); end
                                                 else begin write(ch); z:=i-1;i:=i-1; one:=true; end;
                                end;
    until boo or quit;
    if not quit then for i:=1 to digits do num:=num+n[i]*tendec(digits-i);
    if not quit then if one then num:=num/(tendec(digits-z));
    if digits=0 then begin num:=0; ret:=true; end else ret:=false;
  end;

Procedure Showdays(days : weektype; boo : boolean);
  var d : daytype; sum : integer;
  begin
    if boo then                 {shows days routes run on}
      begin
        sum:=0;
        for d:=mo to su do if d in days then sum:=sum+1;
        for i:=1 to 7-sum do write(' ');
      end;
    for d:=mo to su do
      if d in days then      {if a day in is the set of days delivered, it prints the corresponding letter of that day}
        case d of
          mo : write('m'); tu : write('t'); we : write('w');
          th : write('r'); fr : write('f'); sa : write('s');
          su : write('n');
          end;
  end;

Procedure Showfirst;     {show all the routes info}
  begin
    gotoxy(30,11); writeln(a.route:7);
    gotoxy(30,12); writeln(a.work:7:2);
    gotoxy(30,13); writeln(a.drive:7:2);
    gotoxy(30,14); write('':7);
    gotoxy(30,14); showdays(a.days,true);
    gotoxy(30,15); write(a.overdays:7);
  end;


Procedure Edit;
var ret1,ret2 : boolean;
begin
  clrscr;
  writeln;
  writeln;
  writeln('                        ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  writeln('                        ³ Edit a Route''s Information ³');
  writeln('                        ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
  writeln('                        ³   Route''s Entered :        ³');
  writeln('                        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  writeln('       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  writeln('       ³    Original Information     ³ ³      New Information        ³');
  writeln('       ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ´ ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ´');
  writeln('       ³ Route Name        ³         ³ ³ Route Name        ³         ³');
  writeln('       ³ Hours of Dispatch ³         ³ ³ Hours of Dispatch ³         ³');
  writeln('       ³ Driving Hours     ³         ³ ³ Driving Hours     ³         ³');
  writeln('       ³ Days Route Runs   ³         ³ ³ Days Route Runs   ³         ³');
  writeln('       ³ Days Overnight    ³         ³ ³ Days Overnight    ³         ³');
  writeln('       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÙ');
  writeln;
  writeln('       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  writeln('       ³                                                             ³');
  writeln('       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  repeat
    gotoxy(62,11); write('':7); gotoxy(62,12); write('':7);
    gotoxy(62,14); write('':7); gotoxy(62,15); write('':7);
    gotoxy(61,13); write('':7);
    gotoxy(47,6); write(filesize(f));
    ask(s);
    if not quit then
      begin
        showfirst;
        ret1:=false; ret2:=false; quit:=false;
        gotoxy(62,11); getchars(w,6);{reads up to 6 digits for the route name}
        if w<>'' then a.route:=onecase(w)
                 else begin gotoxy(62,11); write(a.route); end;
        if not quit then begin gotoxy(62,12); getdecimal(j,5,ret1); end; {gets working hours, decimal}
        if ret1 then begin gotoxy(62,12); write(a.work:1:2); end;
        if not quit then begin gotoxy(62,13); getdecimal(k,5,ret2); end; {gets driving hours}
        if ret2 then begin gotoxy(62,13); write(a.drive:1:2); end;
        if not quit then begin gotoxy(62,14); getchars(w,7); end; {gets up to 7 characters to represent days of week}
        if not (w='') then a.days:=[];
        if pos('M',onecase(w))<>0 then a.days:=a.days+[mo]; {looks for each character in the above 7 character string }
        if pos('T',onecase(w))<>0 then a.days:=a.days+[tu]; {to see if the route runs on that day, if it does it is}
        if pos('W',onecase(w))<>0 then a.days:=a.days+[we]; {added to the set  (a.days)}
        if pos('H',onecase(w))<>0 then a.days:=a.days+[th];
        if pos('R',onecase(w))<>0 then a.days:=a.days+[th];
        if pos('F',onecase(w))<>0 then a.days:=a.days+[fr];
        if pos('S',onecase(w))<>0 then a.days:=a.days+[sa];
        if pos('N',onecase(w))<>0 then a.days:=a.days+[su];
        if pos('D',onecase(w))<>0 then a.days:=a.days+[su];
        if not quit then begin gotoxy(62,14); showdays(a.days,false); end;
        if not quit then begin gotoxy(62,15); getnumonly(a.overdays,1); end; {gets number of days overnight}
        if not quit then
          begin
            if not ret1 then begin l:=frac(j); a.work:=int(j)+(l/0.6);  end; {if numbers are entered in minutes form}
            if not ret2 then begin l:=frac(k); a.drive:=int(k)+(l/0.6); end; {like .15,.30,.45  They are converted to real}
            a.overnight:=false;                                              {decimal form}
            write(f,a);  {writes updated route to file}
          end;
      end;
    if not quit then showfirst;
    if s<>'' then quit:=false;
  until quit;
  quit:=false;
  end;

Procedure addroute;
  var
    ch : char;
    boo : boolean;
    w,x : word;
    j,k,l : real;
    i,dummy : integer;

begin
  seek(f,filesize(f));
  repeat
    clrscr;
    a.route:='';
    a.work:=0;
    a.drive:=0;
    a.overnight:=false;
    a.days:=[];
    writeln; writeln; writeln; writeln; writeln; writeln;
    writeln('                       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('                       ³     Add Route to List       ³');
    writeln('                       ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ´');
    writeln('                       ³ Route Name        ³         ³');
    writeln('                       ³ Hours of Dispatch ³         ³');
    writeln('                       ³ Driving Hours     ³         ³');
    writeln('                       ³ Days Route Runs   ³         ³');
    writeln('                       ³ Days Overnight    ³         ³');
    writeln('                       ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´');
    writeln('                       ³                             ³');
    writeln('                       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    writeln;
    quit:=false;
    w:='';
    gotoxy(46,10); getchars(w,6); a.route:=onecase(w); {gets name}
    if w='' then quit:=true;
    if not quit then begin gotoxy(46,11); getdecimal(j,5,boo); end; {work hours}
    if not quit then begin gotoxy(46,12); getdecimal(k,5,boo); end; {driving hours}
    if not quit then begin gotoxy(46,13); getchars(w,7); end; {string for days}
    a.days:=[];
    if pos('M',onecase(w))<>0 then a.days:=a.days+[mo]; {checks string for each day}
    if pos('T',onecase(w))<>0 then a.days:=a.days+[tu];
    if pos('W',onecase(w))<>0 then a.days:=a.days+[we];
    if pos('H',onecase(w))<>0 then a.days:=a.days+[th];
    if pos('R',onecase(w))<>0 then a.days:=a.days+[th];
    if pos('F',onecase(w))<>0 then a.days:=a.days+[fr];
    if pos('S',onecase(w))<>0 then a.days:=a.days+[sa];
    if pos('N',onecase(w))<>0 then a.days:=a.days+[su];
    if pos('D',onecase(w))<>0 then a.days:=a.days+[su];
    if not quit then begin gotoxy(46,14); getnumonly(a.overdays,1); end;
    if not quit then
      begin
        l:=frac(j); a.work:=int(j)+(l/0.6);  {converts numbers to real decimal form}
        l:=frac(k); a.drive:=int(k)+(l/0.6);
        gotoxy(26,16); write('Is all information correct?');
        repeat wait; read(kbd,ch); until ch in ['y','Y','n','N'];
        if ch in ['y','Y'] then begin write(f,a); quit:=false; end
                           else quit:=false;
      end;
  until quit;
  quit:=false;
end;

Procedure Getsel(var num : integer);
  begin
    gotoxy(26,15); write('  '); gotoxy(27,15);
    getnumonly(num,1);
  end;

Procedure Pop;   {deletes a route from the file.  starts from route's position and moves}
  begin          {all the routes in front of it back one, then deletes the old last route}
    if filepos(f)<>filesize(f)-1 then
      for i:=filepos(f) to filesize(f)-2 do
        begin seek(f,I+1); read(f,a); seek(f,I); write(f,a); end;
    truncate(f);
  end;

Procedure Delroute;
  var ch : char; i : integer;

Procedure Clear;
  var i:integer;
  begin
    gotoxy(26,16);
    for i:=26 to 52 do write(' ');
    gotoxy(26,16);
  end;

Procedure Ask(var s : word);
  begin
    clear;
    write('Route to delete : ');
    quit:=false;
    getchars(s,6);
    if (s<>'') and not quit then
      begin
        seek(f,0);
        if not eof(f) then
          repeat
            read(f,a);
          until (onecase(a.route)=onecase(s)) or eof(f);
        if onecase(a.route)<>onecase(s) then
          begin
            clear; write('Route ',onecase(s),' not found...');
            delay(700); quit:=true;
          end else seek(f,filepos(f)-1);
      end else quit:=true;
  end;

  begin
    clrscr;
    writeln; writeln; writeln; writeln; writeln; writeln;
    writeln('                       ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('                       ³   Delete Route From List    ³');
    writeln('                       ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ´');
    writeln('                       ³ Route Name        ³         ³');
    writeln('                       ³ Hours of Dispatch ³         ³');
    writeln('                       ³ Driving Hours     ³         ³');
    writeln('                       ³ Days Route Runs   ³         ³');
    writeln('                       ³ Days Overnight    ³         ³');
    writeln('                       ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´');
    writeln('                       ³                             ³');
    writeln('                       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    ask(s);
    if not quit then
        begin
          gotoxy(46,10); writeln(a.route:7); gotoxy(46,11); writeln(a.work:7:2);
          gotoxy(46,12); writeln(a.drive:7:2); gotoxy(46,13); showdays(a.days,true);
          gotoxy(46,14); write(a.overdays:7);
          clear; write('Delete this route? ');
          repeat wait; read(kbd,ch); until ch in ['y','Y','n','N'];
          if ch in ['y','Y'] then begin clear; write('Deleting route...');
                                  pop; delay(500); end;
        end;
    quit:=false;
  end;

Procedure Rshow;
var i,j : integer;
    quit : boolean;

begin
  seek(f,0);
  quit:=false;
  repeat;
    clrscr;
    writeln('  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('  ³              Route Listing - Press any key to continue...             ³');
    writeln('  ÃÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ´');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ÃÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄ´');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ³        ³        ³        ³        ³        ³        ³        ³        ³');
    writeln('  ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÙ');
    for i:=1 to 7 do
      for j:=1 to 8 do
        begin
          if not eof(f) then
            begin
              read(f,a);
              gotoxy(5+(j-1)*9,4+(i-1)*3); write(a.route);
              gotoxy(5+(j-1)*9,5+(i-1)*3); write(a.work:1:2);
            end;
        end;
    ch:=' ';
    waitf;
    if ch=#27 then quit:=true;
  until eof(f) or quit;
end;

Procedure Mainmenu;
  begin
    quit:=false;
    repeat
    clrscr;
    writeln;
    writeln;
    writeln;
    writeln('                         ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('                         ³    Route Information   ³');
    writeln('           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('           ³                                                      ³');
    writeln('           ³  1. Edit a route''s information                       ³');
    writeln('           ³  2. Add new route to list                            ³');
    writeln('           ³  3. Delete route from list                           ³');
    writeln('           ³  4. View all routes in list                          ³');
    writeln('           ³  5. Exit                                             ³');
    writeln('           ³                                                      ³');
    writeln('           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    writeln('           ³  Selection :                                         ³');
    writeln('           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    repeat getsel(i); until (i in [1..5]) or quit;
    if quit then write('Quit');
    case i of
      1 : edit;
      2 : addroute;
      3 : delroute;
      4 : rshow;
      5 : begin quit:=true; write(#8,'Quit'); end;
      end;
  until quit;
end;

begin
  assign(f,find + '.rts');
  reset(f);
  max:=filesize(f);
  mainmenu;
  close(f);
  run('main');
end.
