Program Printsequences;   {prints out sequences}
{you will see printdrivers referred to.  It is alsways false and not used}
const
  maxweekdrive = 48.0;         {these are the constants for the maximum hours}
  maxweekwork = 53.5;
  maxdrive = 98.0;
  maxwork = 107.0;
  size    = 14;

{$I main\rdecl.pas}
{$I main\decl.pas}

type
  registers = record        {REGISTERS is something to do with making sure the printer is on}
    case byte of
      1 : (AX,BX,CX,DX,BP,SI,DI,DS,ES,Flags : integer);
      2 : (AL,AH,BL,BH,CL,CH,DL,DH : byte);
    end;
  rec = record
          week : 1..2;
          day : daytype;
          route : string[7];
          drive,work : real;
          overnight : boolean;
          overdays  : integer;
        end;
  choice = (fo,o,nf);
  alldata = array[1..size] of rec;

var
  reg : registers;
  g : file;
  s : word;
  ch : char;
  z : driver;
  row : rows;
  a : rectype;
  f2 : filetype;
  f3 : file of rows;
  all : alldata;
  co : array[1..7] of integer;
  boo,printdrivers,quit : boolean;
  found : array[1..20] of choice;
  start,finish,new,i,j,seq : integer;
  loss,total,swt,dtotal,week1,dweek1,week2,dweek2 : real;

Function Onecase(s : word) : word;
  var
    i : integer;
  begin
    for i:=1 to length(s) do if s[i] in['a'..'z'] then s[i]:=upcase(s[i]);
    onecase:=s;
  end;

Procedure Wait;
  var ch : char;
  begin repeat until keypressed; end;

Procedure Getchars(var s : word; digits : integer);
  var
    boo : boolean;
    ch : char;
    num,i  : integer;
  begin
    num:=0; i:=0; quit:=false; boo:=false; wait;
    repeat
       i:=i+1;
      repeat
        read(kbd,ch);
        if ch=chr(27) then if not keypressed then quit:=true;
        if ch=chr(8) then if i>1 then begin i:=i-1; write(chr(8),' ',chr(8)); end;
        if ch=chr(13) then begin boo:=true; digits:=i-1; if digits=0 then quit:=true; end;
      until quit or ((not (ord(ch) in [0,7,8,9,10,11,12,13,27,28,29,30,31,255]))
            and (i<=digits)) or boo;
      if not (quit or boo) then begin s[i]:=ch; write(s[i]); end;
    until boo or quit;
    s[0]:=chr(digits);
  end;

Function CheckPrinter : boolean;
  {this checks whether or not printer is on...
   true  : on
   false : off}

  begin
    reg.ah:=2;
    Intr($17, Reg);
    CheckPrinter := (Reg.AH and $29) = 0;
  end;

Procedure Calc;
  var i : integer;
  begin
    dweek1:=0; dweek2:=0;
    week1:=0; week2:=0;
    for i:=1 to 7 do  if found[i]=fo then begin week1:=week1+all[i].work; dweek1:=dweek1+all[i].drive; end;
    for i:=8 to 14 do if found[i]=fo then begin week2:=week2+all[i].work; dweek2:=dweek2+all[i].drive; end;
    total:=week1 + week2; dtotal:=dweek1+dweek2;
  end;

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

Procedure Heading;    {prints the heading to the printout}
  var i : integer;
  begin
    writeln(lst,chr(28),chr(73));
    writeln(lst,chr(27),chr(120),chr(0));
    writeln(lst);
    if printdrivers then write(lst,'Driver':18);
    write(lst,'Seq':6);
    for i:=1 to size do write(lst,i:7);
    writeln(lst,'Total':14);
    for i:=1 to 2 do writeln(lst);
  end;

Procedure Align(a : alldata; i,j : integer);
  var x,y,p : integer;
  begin
    if i<=7 then y:=10 else y:=14;
    if i>7 then p:=i-7 else p:=i;
    x:=co[p];
    if j>0 then
      begin
        gotoxy(x,y); write('':7);
        gotoxy(x,y); write(a[i].route);
        gotoxy(x,y+1); write('':7);
        gotoxy(x,y+1); write(a[i].work:1:2);
        gotoxy(x,y+2); write('':7);
        gotoxy(x,y+2); write(a[i].drive:1:2);
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

Procedure Showdata(a : alldata);
  var count,i : integer;
  begin
    calc;
    gotoxy(15,6);
    write(seq,'  ');
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
      if found[i]=fo then
        begin
          align(a,i,i);
          if a[i].overnight then count:=a[i].overdays;
        end
      else align(a,i,-1);
  end;

Procedure Screen;
  begin
    clrscr;
    writeln('                                                   ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('                                                   ³  Work   ³  Drive   ³');
    writeln('                                          ÚÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´');
    writeln('                                          ³ Week 1 :                    ³');
    writeln(' ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                     ³ Week 2 :                    ³');
    writeln(' ³   Sequence       ³                     ³ Total  :                    ³');
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

Procedure showinfo;  {shows status line}
  begin
    gotoxy(4,20);
    write('Sequences left to print : ',filesize(f3)-seq,'   Press any key to abort...      ');
  end;

Procedure Clearline;
  var i : integer;
  begin
    gotoxy(4,20); for i:=1 to 60 do write(' ');
    gotoxy(4,20);
  end;

Procedure Newpage;   {starts printing on a new page}
  var i : integer;
  begin
    for i:=1 to 3 do writeln(lst);
    heading;
    new:=1;
  end;

Procedure Printout;      {prints out the info}
  var i : integer;
      name : string[80];
  begin
    showdata(all);
    showinfo;
    new:=new+1;
    if new>=20 then newpage;
    name:='';
    write(lst,seq:6);
    for i:=1 to size  do if found[i]=fo then write(lst,all[i].route:7) else
                       if found[i]=o  then write(lst,'<-OVN-':7) else
                       write(lst,'ND':7);
    writeln(lst,loss:14:2);
    write(lst,'':(6+18*ord(printdrivers)));
    for i:=1 to size  do if found[i]=fo then write(lst,all[i].work:7:2) else
                       write(lst,'':7);
    writeln(lst);
    writeln(lst);
end;

Procedure Pon;       {Doesn't start until printer is on}
  begin
    quit:=false;
    repeat
      if not checkprinter then
        begin
          clearline;
          write('Printer is not ready.  Please correct and press any key...');
          repeat until keypressed;
          read(kbd,ch); if keypressed then read(kbd,ch);
          if ch=#27 then quit:=true;
          gotoxy(17,14);
        end;
    until checkprinter or quit;
    clearline;
  end;

Function Fs(s : word; var pos : integer; num : integer) : boolean;
  var i,j : integer;
      boo : boolean;

  begin           {finds positions of the starting and ending sequences}
    boo:=false;
    if not quit then
      if not ((onecase(s)='END') and (num=2)) then
      begin
        seek(f3,0);
        repeat
          read(f3,row);
        until (row.identifier=s) or eof(f3);
        if row.identifier=s then begin boo:=true; pos:=filepos(f3); end;
        if boo then
          begin
            if num=2 then
              if pos<start+1 then
                begin
                  clearline;
                  write('Ending sequence must come AFTER starting sequence...');
                  delay(1000);
                  boo:=false;
                end;
          end else
          begin
            clearline;
            write('Sequence not found. Please try again...');
            delay(1000);
          end;
      end;
    if (not boo) and (num=2) and (onecase(s)='END')
      then begin pos:=filesize(f3); boo:=true; end;
    if boo and (num=1) then pos:=pos-1;
    fs:=boo;
  end;

Procedure Getorder;
  begin
    clearline;
    write('Print (A)ll sequences or (P)artial list of sequences ');
    repeat
      repeat until keypressed;
      read(kbd,ch);
      if ch=#27 then if keypressed then read(kbd,ch);
      if ch=#27 then quit:=true;
    until (ch in ['a','A','p','P']) or quit;
    if not quit then
      begin
        assign(f3,find + '.seq');
        reset(f3);
        if ch in ['a','A']
          then begin start:=0; finish:=filesize(f3); end
          else begin
                 repeat
                   clearline;
                   write('Enter sequence to start printing with : ');
                   getchars(s,3);
                 until quit or fs(s,start,1);
                 clearline;
                 if not quit then
                   begin
                     repeat
                       clearline;
                       write('Enter sequence to end printing with : ');
                       getchars(s,3);
                     until quit or fs(s,finish,2);
                   end;
                 clearline;
               end;
        close(f3);
      end;
  end;

Procedure Init;
  begin
    new:=0;
    clrscr;
    quit:=false;
    screen;
    co[1]:=4; co[2]:=13; co[3]:=24; co[4]:=36; co[5]:=46; co[6]:=56; co[7]:=66;
    getorder;
    clearline;
    printdrivers:=false;
    pon;
    if not quit then
      begin
        write('Align printer and press any key to continue...');
        repeat until keypressed; read(kbd,ch);
        if ch=#27 then if keypressed then read(kbd,ch);
        if ch=#27 then quit:=true;
        if quit then clearline;
      end;
  end;

begin
  init;
  if not quit then
    begin
      assign(f3,find + '.seq');
      reset(f3);
      if filesize(f3)<>0 then
        begin
          seq:=start;
          seek(f3,start);
          heading;
          repeat
            swt:=0;
            for i:=1 to size do found[i]:=nf;
            read(f3,row);               {reads in all info}
            loss:=0;
            i:=0;
            repeat
              i:=i+1;
              if keypressed then quit:=true;
              if row.day[i].route<>'' then
                with all[i] do
                  begin                     {stores it in an array}
                    route:=row.day[i].route;
                    overnight:=row.day[i].overnight;
                    overdays:=row.day[i].overdays;
                    if overnight then for j:=1 to overdays do found[i+j]:=o;
                    drive:=row.day[i].drive; work:=row.day[i].work;
                    loss:=loss+work;
                    found[i]:=fo;
                  end;
            until (i=size) or quit;
            seq:=seq+1;
            printout;
          until eof(f3) or quit or (filepos(f3)=finish);
          writeln(lst,chr(12));
        end;
      close(f3);
    end;
  run('edseq');
end.

