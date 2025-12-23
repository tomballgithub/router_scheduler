Program Zero2;

{this program goes one line at a time from the bottom.  It takes all the routes in that sequence. Then in goes for ten more}
{sequences and tries to find empty slots.  Then it goes to the top and trades the ones from the bottom sequence for a route}
{that will fit in a slot in the 10 others' blanks without going over the max.  This way it gets rid of as many uneccesary}
{routes as possible}

const
  print = false;
  weekdrive = 48;
  weekwork = 53.5;

type
  big = string[40];
  word = string[20];
  line = string[20];
  daytype = (mo,tu,we,th,fr,sa,su,null,null2);
  rec2 = record
              route : string[6];
              overnight : boolean;
              overdays : integer;
              drive,work : real;
              day : integer;
              fp : integer;
            end;
  rectype = record
              route : string[6];
              overnight : boolean;
              overdays : integer;
              drive,work : real;
              days  : set of daytype;
            end;
  rows = record
           day : array[1..14] of rectype;
           id : integer;
           identifier : string[3];
         end;
 choice = (fo,o,nf);

var
  q : word;
  del : boolean;
  unm,uni,empty,attempts : integer;
  try : boolean;
  blank : rectype;
  found : array[1..16] of choice;
  f : file of rows;
  sq,sq2,size2,endpos,endpos2,size,i,j : integer;
  devi,low : real;
  done,quit : boolean;
  ch : char;
  seq,seq2 : word;
  b : rec2;
  r : rectype;
  a : rows;
  all : array[1..50] of rec2;
  new : array[1..50] of rec2;
  hv,n,days : array[1..14] of integer;

Procedure Screen;
  begin
    clrscr;
    writeln;
    writeln;
    writeln;
    writeln;
    writeln('              ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    writeln('              ³   Reorganizing Route Schedule   ³  Pass #     ³');
    writeln('              ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    writeln('              ³                                               ³');
    writeln('              ³             Current Sequence :                ³');
    writeln('              ³          Routes left to move :                ³');
    writeln('              ³      Routes Needed to Insert :                ³');
    writeln('              ³             Unmovable Routes :                ³');
    writeln('              ³            Empty Route Slots :                ³');
    writeln('              ³          Uninsertable Routes :                ³');
    writeln('              ³                                               ³');
    writeln('              ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
    writeln('              ³           ³                                   ³');
    writeln('              ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  end;

Procedure Showdata;
  begin
    gotoxy(58,6); write(attempts);
    gotoxy(48,9);  writeln(seq,' ');
    gotoxy(48,10); write(size,'  ');
    gotoxy(48,11); writeln(size2,'  ');
    gotoxy(48,12); writeln(unm);
    gotoxy(48,13); writeln(empty,'  ');
    gotoxy(48,14); writeln(uni);
    gotoxy(17,17); if del then write('Deleting ')
                          else write('Inserting');
  end;

Procedure Show(s : big);
  var i : integer;
  begin
    gotoxy(29,17);
    for i:=29 to 61 do write(' ');
    gotoxy(29,17);
    write(s);
  end;

Procedure Init;
  begin
    blank.route:=' ';
    blank.route:='';
    blank.work:=0;
    blank.drive:=0;
    blank.overnight:=false;
    blank.overdays:=0;
    blank.days:=[su];
  end;

Procedure Dofind(row : rows);
  var i,j : integer;
  begin
      for i:=1 to 14 do found[i]:=nf;
      i:=0;
            repeat
              i:=i+1;
              if row.day[i].route<>'' then
                begin
                  found[i]:=fo;
                  if row.day[i].overnight then
                    for j:=1 to row.day[i].overdays do
                      found[i+j]:=o;
                end;
            until (i>=14);
  end;

Function Find : word;
  var f : text;
      s : word;
  begin
    assign(f,'data\workfile.dat');
    reset(f); readln(f,s); close(f); write; find:='data\' + s;
  end;

Procedure Readin;
  var i,x : integer;
      y,z : real;
  begin
    seek(f,filesize(f)-1);
    size:=0; size2:=0;
    repeat
      read(f,a);  {reads in one line}
      for i:=1 to 14 do
        if a.day[i].route<>'' then
          with all[size+1] do
            begin
              size:=size+1; fp:=filepos(f)-1;  {stores info about each route in it}
              route:=a.day[i].route; overnight:=a.day[i].overnight; day:=i;
              overdays:=a.day[i].overdays; drive:=a.day[i].drive;
              work:=a.day[i].work; days[i]:=days[i]+1;
            end;
      seek(f,filepos(f)-2);
    until (a.identifier=seq);
    endpos:=filepos(f);
    repeat
      read(f,a);  {reads in 10 more}
      dofind(a);
      y:=0; z:=0;
      for x:=1 to 14 do if found[x]=fo then begin y:=y+a.day[x].work; z:=z+a.day[x].drive; end;
      if (y<=100) and (z<=43) then
        for i:=1 to 14 do {looks at each day, if blank then remembers}
          if (a.day[i].route='') and (found[i]=nf) then begin n[i]:=n[i]+1; empty:=empty+1; end;
      seek(f,filepos(f)-2);
    until (a.identifier=seq2);
    endpos2:=filepos(f);
  end;

Function Needed(i : integer) : boolean;
  begin
    if n[i]>0 then needed:=true else needed:=false;
  end;

Procedure Next(var r : rec2; d : integer);
  var i : integer;
  begin
    i:=0; repeat i:=i+1; until all[i].day=d; r:=all[i];
  end;

Procedure Nexti(var r : rec2; d : integer);
  var i : integer;
  begin
    i:=0; repeat i:=i+1; until new[i].day=d; r:=new[i];
  end;

Procedure Remove(d : integer);
  var i : integer; a : rows;
  begin
    i:=0; repeat i:=i+1; until all[i].day=d;
    seek(f,all[i].fp);
    read(f,a);
    a.day[d]:=blank; a.day[d].route:='';
    seek(f,filepos(f)-1); write(f,a);
    for i:=i to size-1 do all[i]:=all[i+1];
    size:=size-1;
    days[d]:=days[d]-1;
  end;

Procedure Remove2(d : integer);
  var i : integer;
  begin
    i:=0; repeat i:=i+1; until new[i].day=d;
    for i:=i to size2-1 do new[i]:=new[i+1];
    size2:=size2-1;
    hv[d]:=hv[d]-1;
  end;

Function Check(d : integer; a : rows) : boolean;
  var lo,hi,i,j : integer;
      done : boolean;
      sumd,sumw : real;
  begin
    if d<=7 then begin lo:=1; hi:=7; end else begin lo:=8; hi:=14; end;
    i:=lo-1;
    done:=false;
    repeat
      i:=i+1;
      if (a.day[i].route<>'') and needed(i) then
        begin
          sumd:=0; sumw:=0;
          for j:=lo to hi do
            begin
              if a.day[j].route<>'' then
                if i<>j then begin sumd:=sumd+a.day[j].drive; sumw:=sumw+a.day[j].work; end;
            end;
          next(b,d); sumd:=sumd+b.drive; sumw:=sumw+b.work;
          if (sumd<=weekdrive) and (sumw<=weekwork) and
             (sumw>=low) and (a.day[i].overdays=0) then
            begin  {if day can switch without upsetting the max, then it does}
              done:=true;
              str(filepos(f),q);
              show(b.route+' replaces '+a.day[i].route+' at seq#'+q);
              with new[size2+1] do
                begin
                  route:=a.day[i].route; overnight:=a.day[i].overnight; day:=i;
                  overdays:=a.day[i].overdays; drive:=a.day[i].drive;
                  work:=a.day[i].work; n[i]:=n[i]-1; hv[i]:=hv[i]+1;
                end;
              size2:=size2+1;
              showdata;
              with a.day[i] do
                begin
                  route:=''; overnight:=false; days:=[su];
                  overdays:=0; drive:=0;
                  work:=0;
                end;
              with a.day[d] do
                begin
                  route:=b.route; overnight:=b.overnight; days:=[su];
                  overdays:=b.overdays; drive:=b.drive;
                  work:=b.work;
                end;
              seek(f,filepos(f)-1);
              write(f,a);
              seek(f,filepos(f)-2);
              remove(d);
            end;
        end;
    until done or (i>=hi);
    if done then check:=true else check:=false;
  end;

Procedure Findslot(d : integer);
  var i,j : integer;
  begin
    seek(f,0);
    done:=false;
    next(b,d);  {finds the next occurence of route on day D}
    repeat
      read(f,a); {reads a sequence}
      dofind(a); {checks for blank}
      if (a.day[d].route='') and (found[d]=nf) then
        if check(d,a) then done:=true;
    until done or (filepos(f)>=endpos2);
    if not done then begin remove(d); unm:=unm+1; end;
  end;

Function Finished : boolean;
var boo : boolean; i : integer;
begin
  boo:=true; for i:=1 to 14 do if days[i]>0 then boo:=false;
  finished:=boo;
end;

Procedure Ins(d : integer);
  var i,j  :integer;
      sumd,sumw : real;
      lo,hi : integer;
  begin
    nexti(b,d);  {finds next route with day D}
    with a.day[d] do
      begin
        route:=b.route; overnight:=b.overnight; days:=[null];
        overdays:=b.overdays; drive:=b.drive;
        work:=b.work;
      end;
    if d<=7 then begin lo:=1; hi:=7; end else begin lo:=8; hi:=14; end;
    sumd:=0; sumw:=0;
    for j:=lo to hi do
        if a.day[j].route<>'' then
          begin sumd:=sumd+a.day[j].drive; sumw:=sumw+a.day[j].work; end;
    if (sumd<=weekdrive) and (sumw<=weekwork) then
      begin
        empty:=empty-1; {inserts the day into another route of those 10}
        show('Inserting '+a.day[d].route+' in sequence '+a.identifier);
        seek(f,filepos(f)-1);
        if filepos(f)>endpos then uni:=uni+1;
        write(f,a);
        remove2(d);
        showdata;
      end else begin a.day[d]:=blank; a.day[d].route:=''; end;
  end;

Function Used : boolean;
  var i : integer; boo : boolean;
  begin
    boo:=true;
    for i:=1 to 14 do if hv[i]>0 then boo:=false;
    used:=boo;
  end;

Procedure Insert;
  var i,j : integer;
  begin
    del:=false;
    seek(f,endpos2);
    repeat
      read(f,a);
      for i:=1 to 14 do if (hv[i]>0) and (a.day[i].route='') then ins(i);
    until eof(f) or (used);
  end;

Procedure Reduce;
  begin
    repeat
      for i:=1 to 14 do
        if days[i]>0 then findslot(i);
    until finished;
  end;

Procedure Strsq(sq,sq2 : integer);
  begin
    str(sq,seq);
    str(sq2,seq2);
  end;

Procedure Makesq;
  var dummy:integer;
  begin
    assign(f,find+'.seq');
    reset(f);
    seek(f,filesize(f)-1); read(f,a);
    seq:=a.identifier;
    val(seq,sq,dummy);
    sq2:=sq-10;
  end;

Procedure Run(s : word);
  var g : file;
  begin
    s:=s+'.com';
    assign(g,s);
    execute(g);
  end;

begin
  screen;
  low:=46.9;
  attempts:=0;
  try:=false;
  repeat
    makesq;
    strsq(sq,sq2);
    for i:=1 to 14 do days[i]:=0; n:=days; hv:=n;
    uni:=0;unm:=0;empty:=0; del:=true;
    readin;
    attempts:=attempts+1;
    showdata;
    reduce;
    insert;
    sq:=sq-1;
    sq2:=sq-10;
    if (uni=0) and (unm=0) then begin seek(f,filesize(f)-1); truncate(f); end;
    close(f);
    if uni>0 then if not try then begin try:=true; uni:=0; end;
    if (uni=0) and try then try:=false;
    show('');
  until (uni>0) or (unm>0);
  show('Reduction Completed');
  run('edseq');
end.