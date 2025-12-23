Program MakeNewDataFile;

{$I main\decl.pas}

type
  daytype = (mo,tu,we,th,fr,sa,su,null,null2);
  rectype = record
              route : string[6];
              overnight : boolean;
              overdays : integer;
              drive,work : real;
              days  : set of daytype;
            end;
  rows = record                            {filetype of sequence}
           day : array[1..14] of rectype;
           id : integer;
           identifier : string[3];
         end;

var
  s,r : word;
  t : text;
  ch : char;
  f : filetype;
  num : integer;
  quit : boolean;
  f3 : file of rows;
  f2 : file of rectype;

Procedure Run(s : word);
  var g : file;
  begin
    s:=s+'.com';
    assign(g,s);
    execute(g);
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
    find:=s;
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
    writeln('                            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('                            ³  Change Work File  ³');
    writeln('                       ÚÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄ¿');
    writeln('                       ³                              ³');
    writeln('                       ³   Current File :             ³');
    writeln('                       ³   New File     :             ³');
    writeln('                       ³                              ³');
    writeln('                       ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    writeln('                       ³                              ³');
    writeln('                       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
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

Function Fileexist(Filename : word) : boolean;
  var
    f : file;
  begin
    assign(f,filename);
    {$I-}
    reset(f);
    {$I+}
    fileexist:= (IOresult=0);
    close(f);
  end;

begin
  quit:=false;
  screen;
  gotoxy(43,12);
  writeln(find);
  gotoxy(43,13);
  getchars(s,8); {gets name of new workfile}
  r:=s;
  gotoxy(27,16);
  if s='' then quit:=true;
  if not quit then
    begin
      if not fileexist('data\'+s+'.rts') then {checks to see if it exists}
        begin
          write('New File. Ok to Create? ');
          repeat
            repeat until keypressed;
            read(kbd,ch);
            if ch=#27 then if keypressed then read(kbd,ch);
          until ch in ['n','N','y','Y'];
          if ch in ['y','Y'] then quit:=false else quit:=true;
          if not quit then
            begin
              s:='data\' + s;  {creates a new file if OK}
              assign(f2,s+'.rts'); rewrite(f2); close(f2);
              assign(f3,s+'.seq'); rewrite(f3); close(f3);
            end;
        end;
      if not quit then
        begin
          assign(t,'data\workfile.dat'); {changes the workfile.dat file}
          rewrite(t);                    {it contains the current workfile's name}
          writeln(t,r);
          close(t);
        end;
    end;
 gotoxy(1,17); writeln; writeln;
 run('main');
end.
