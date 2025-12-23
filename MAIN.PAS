Program Drivers;                {these are all the program variable declarations below}
type                            {the only reason they are here is for the backup part of the program}
  word = string[40];
  line = string[80];
  daytype = (mo,tu,we,th,fr,sa,su,null,null2);   {days of the week}
  rectype = record
              route : string[6];        {route name}
              overnight : boolean;      {whether or not its overnight, true = overnight}
              overdays : integer;       {# of days overnight}
              drive,work : real;        {# of driving, work hours}
              days  : set of daytype;   {set of the days of the week type route runs on}
            end;
  rows = record
           day : array[1..14] of rectype;  {array holding fourteen days info of the above RECTYPE}
           id : integer;                   {not used}
           identifier : string[3];         {sequence #, stored in a string}
         end;


var
  f2,g2 : file of rectype;       {files to backup the route file}
  f3,g3 : file of rows;          {files to backup the sequence files}
  b : rectype;                   {holds one route}
  c : rows;                      {holds one sequencs}
  quit : boolean;
  num : integer;

Procedure Mm;
  begin
    clrscr;
    writeln;
    writeln;
    writeln;
    writeln('                            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('                            ³     Main Menu      ³');
    writeln('           ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('           ³                                                      ³');
    writeln('           ³  1. Route Information                                ³');
    writeln('           ³  2. Sequence Information                             ³');
    writeln('           ³  3. Backup Data                                      ³');
    writeln('           ³  4. Switch Data Files                                ³');
    writeln('           ³  5. Exit                                             ³');
    writeln('           ³                                                      ³');
    writeln('           ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    writeln('           ³  Selection :                                         ³');
    writeln('           ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end;

Procedure Wait;    {waits for a keypress}
  var ch : char;
  begin repeat until keypressed; end;

Function ten(i : integer) : integer;     {find # to the power of 10}
  var j,sum : integer;
  begin
    sum:=1; for j:=1 to i do sum:=sum*10; ten:=sum;
  end;

Procedure Getnumonly(var num : integer; digits : integer);
  var                       {this is just a routine to get a number and not accept garbage characters, only numbers}
    boo : boolean;          {otherwise it might crash if letters are entered..}
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

Procedure Getsel(var num : integer);           {waits for menu selection}
  begin
    gotoxy(27,15); write(' '); gotoxy(27,15);
    getnumonly(num,1);
  end;

Function Find : word;     {finds out what the workfile is}
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

Function Find2 : word;  {almost same as above. see below}
  var f : text;
      s : word;
  begin
    assign(f,'data\workfile.dat');
    reset(f);
    readln(f,s);
    close(f);
    write;
    find2:=s;  {different}
  end;

Procedure Run(s : word);   {runs the next file or menu}
  var g : file;
  begin
    s:=s+'.com';
    assign(g,s);
    execute(g);
  end;

Procedure Clear;     {clears status line}
  var i : integer;
  begin
    gotoxy(15,15);
    for i:=1 to 42 do write(' ');
    gotoxy(15,15);
  end;

Procedure Backup;   {backs up files}
  var ch : char; quit : boolean;
  begin
    clear; write('Insert disk for backup files in Drive A');
    wait; read(kbd,ch);
    if keypressed then read(kbd,ch);
    if ch<>chr(27) then
      begin
        {$I-}
            assign(f2,find+'.rts');
            reset(f2);
            assign(g2,'a:'+find2+'.rts');
            rewrite(g2);
            repeat
              read(f2,b);           {backing up routes.  reads them in}
              write(g2,b);          {writes them to a:}
              quit:=(IOresult = 0);
            until eof(f2) or not quit;
            close(f2); close(g2);
            if not quit then
              begin
                clear;
                write('Not enough room on Drive A',chr(7));
                erase(g2);
              end;
        if quit then
          begin
            assign(f3,find+'.seq');
            reset(f3);
            assign(g3,'a:'+find2+'.seq');
            rewrite(g3);
            repeat                          {same for sequences}
              read(f3,c);
              write(g3,c);
              quit:=(IOresult = 0);
            until eof(f3) or not quit;
            close(f3); close(g3);
            if not quit then
              begin
                clear;
                write('Not enough room on Drive A',chr(7));
                erase(g2); erase(g3);
              end;
          end;
        if quit then
          begin
            clear;
            write('Backup successfully completed');
          end;
        delay(1000); clear; write('Selection : ');
        {$I+}
      end;
  end;



Procedure Main;
  begin
    quit:=false;
    repeat;
      mm;
        repeat
          getsel(num);               {waits for selection}
        until (num in [1,2,3,4,5]) or quit;
        if quit then write('Quit');
        case num of
          1 : run('editrt');            {runs appropriate program}
          2 : run('edseq');
          3 : backup;
          4 : run('newfile');
          5 : begin quit:=true; write(chr(8),'Quit'); end;
          end;
      until quit;
      writeln;
    end;

begin
  textcolor(white);
  textbackground(blue);
  main;
  writeln;
end.