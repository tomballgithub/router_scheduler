Program OptimizeRoutes;

{This is by far the most complex program.  It reads in the routes, then it puts into an array an entry for each day it runs}
{for each week.  Therefore a route running M,W,F has 6 entries.  Then it takes all these and randomly puts them into }
{different positions.  Then CHECK runs and checks to see how many hours they total.  It remembers the highest total found so}
{far as it goes.  And after it hasn't found a better combination after 100 cycles it keeps the one that was closest to the }
{goal:  107hrs - deviation hrs.  It does this until every route has been used up.  Then it calls ZERO2 in the last line to}
{try to unrandomly resort the entries from the bottom up so that there are not sequences with only one route at the bottom}
{of the schedule.}

{the 14 days that are being tried are held in the first fourteen slots of all, which holds all the routes}
{a random number is chosen from the rest of the array and that route is change with one of the first 14 routes}


{Found is a array of 20 that holds three possible values in each slot.  nf=not found. fo=found. o=overnight}
{these are kept track of after and route change and are used to figure out the status of each day slot while sorting the}
{routes through the different days.  Only the first 14 slots are used.}


const
  weekdrive = 48;
  weekwork = 53.5;
  maxdrive = 98;
  maxwork = 107;
  timeset      = 2;
  size         = 14;
  save         = true;

{$I main\rdecl.pas}
{$I main\decl.pas}

type
  rec = record
          week : 1..2;           {week of route}
          day : daytype;         {day of route}
          route : string[7];     {name}
          drive,work : real;     {hours}
          overnight : boolean;   {overnight}
          overdays  : integer;   {days overnight}
        end;
  choice = (fo,o,nf);          {what found is made of}
  alldata = array[1..1200] of rec; {all info}

var
  g : file;
  ch : char;
  z : driver;
  row : rows;
  d : daytype;
  a : rectype;
  new : integer;
  r,blank : rec;
  f3 : file of rows;
  all,temp : alldata;   {these hold the data of every route for each week}
  f : file of rectype;
  loss,least,devi : real;
  co : array[1..7] of integer;
  small : array[1..20] of rec;
  once,exit,done,quit : boolean;
  nums,checked,over,overn : set of 1..size;
  tfound,found,tf : array[1..20] of choice;
  w1,w2,offset,i,j,k,seq,num,max,one : integer;
  dtotal,total,week1,dweek1,dweek2,week2,swt,sdt,tw1,td1,sw1,sd1,tw2,td2,sw2,sd2 : real;

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
  var ch : char;
  begin repeat until keypressed; end;

Function tendec(i : integer) : real;
  var j : integer; sum : real;
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
       i:=i+1;
      repeat
        read(kbd,ch);
        if ch=chr(27) then if not keypressed then quit:=true;
        if ch=chr(8) then if i>1 then begin i:=i-1; write(chr(8),' ',chr(8));
                                      if z=i then begin i:=i+1; z:=0; one:=false; end;
                                      end else
                          if (i=1) and (z=0) and one then
                            begin write(chr(8),' ',chr(8)); one:=false; end;
        if ch=chr(13) then begin boo:=true; digits:=i-1; end;
      until quit or (((ch in ['0'..'9']) or ((ch='.') and not one)) and (i<=digits)) or boo;
      if not (quit or boo) then begin if ch<>'.' then begin val(ch,n[i],dummy); write(n[i]); end
                                                 else begin write(ch); z:=i-1;i:=i-1; one:=true; end;
                                end;
    until boo or quit;
    if not quit then for i:=1 to digits do num:=num+n[i]*tendec(digits-i);
    if not quit then if one then num:=num/(tendec(digits-z));
  end;

Procedure Clearline;
  var i : integer;
  begin
    gotoxy(4,20); for i:=1 to 67 do write(' ');
    gotoxy(4,20);
  end;

Procedure Init;  {initializes the variable}
  begin
    new:=0;
    with blank do    {blank is an empty route}
      begin
        route:='';
        day:=su;
        week:=1;
        work:=0;
        drive:=0;
        overnight:=false;
        overdays:=0;
      end;
    seq:=0;
    exit:=false;
    co[1]:=4; co[2]:=13; co[3]:=24; co[4]:=36; co[5]:=46; co[6]:=56; co[7]:=66;
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

Procedure Calc2(a : alldata);
  var i : integer;
  begin
    dweek1:=0; dweek2:=0;
    week1:=0; week2:=0;
    for i:=1 to 7 do  if found[i]=fo then begin week1:=week1+a[i].work; dweek1:=dweek1+a[i].drive; end;
    for i:=8 to 14 do if found[i]=fo then begin week2:=week2+a[i].work; dweek2:=dweek2+a[i].drive; end;
    total:=week1 + week2; dtotal:=dweek1+dweek2;
  end;

Procedure Showdata(a : alldata);
  var boo : boolean;
      count,i : integer;
  begin
    calc2(a);
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

Procedure Clear;
  var x : integer;
  begin
    for x:=1 to size do found[x]:=nf;
  end;

Procedure Choplast(i : integer);
  var y,x : integer;      {when trying different combinations and one route goes over another, this is called}
  begin                   {to deal with the overnights the route it covered might have had.  It makes them nf(not found)}
    overn:=[];
    sd1:=td1; sw1:=tw1;
    found[i]:=nf;
    if all[i].overnight then
      for x:=i to i+all[i].overdays do
        if x in over then
          begin
            if all[x].overnight then for y:=1 to all[x].overdays do
                                              begin
                                                found[x+y]:=o;
                                                overn:=overn+[x+y];
                                             end;
           if not (x in overn) then found[x]:=fo;
         end else found[x]:=nf;
  end;

Procedure Calcweek;
  var i,q : integer;
      sum : real;
  begin
    sw1:=0; sw2:=0; sd1:=0; sd2:=0; swt:=0; sdt:=0;
    for i:=1 to size do
      if found[i]=fo then
        if i>7 then begin sw2:=sw2+all[i].work; sd2:=sd2+all[i].drive; end
               else begin sw1:=sw1+all[i].work; sd1:=sd1+all[i].drive; end;
    swt:=sw1+sw2;
    sdt:=sd1+sd2;
  end;

Procedure Check(yes : boolean);
var q,i,x,y,wk : integer;
    finish : boolean;
  begin
    checked:=[];   {checked is a set to see which days have been given routes}
    if yes then clear
           else
             for i:=1 to size do
               if (found[i]=fo) then
                 begin
                   if i<8 then for x:=1 to 7 do checked:=checked+[x]
                          else for x:=8 to 14 do checked:=checked+[x];
                 end;
    repeat
      over:=[];
      finish:=true;
      repeat
        i:=random(size)+1;  {finds a day that isn't given a route yet}
      until not (i in checked);
      checked:=checked+[i];
      if i>7 then begin q:=i-7; wk:=2; end else begin q:=i; wk:=1; end;
      if all[i].week=wk then
        if (ord(all[i].day)=(q-1)) and (all[i].work<>0) then
          begin
            found[i]:=fo;
            if all[i].overnight then
              for x:=1 to all[i].overdays do
                if found[i+x]=fo then
                  begin
                    if all[i+x].overnight then
                      for y:=i+x+1 to 1+i+x+all[i+x].overdays do found[y]:=nf;
                    checked:=checked+[i+x];
                    over:=over+[i+x];
                    found[i+x]:=o;
                  end else begin found[i+x]:=o; checked:=checked+[i+x]; end;
            tw1:=sw1; td1:=sd1;
            calcweek;
            if (swt>maxwork) or (sdt>maxdrive) then {if the totals go over the max then:}
              begin
                choplast(i); calcweek;  {choplast takes of the last entry tried : that reduces it below max}
                if wk=1 then for x:=1 to 7 do checked:=checked+[x]
                        else for x:=8 to 14 do checked:=checked+[x];
              end;
            if (wk=1) and ((sd1>weekdrive) or (sw1>weekwork)) then {checks first week maxwork}
              begin
                choplast(i); calcweek;
                for x:=1 to 7 do checked:=checked+[x];
              end;
            if (wk=2) and ((sd2>weekdrive) or (sw2>weekwork)) then {checks 2nd week}
              begin
                choplast(i); calcweek;
                for x:=8 to 14 do checked:=checked+[x];
              end;
            loss:=maxwork-swt; {loss is the difference between 107 hours and the highest toal yet}
          end;
      for x:=1 to size do if not (x in checked) then finish:=false; {makes sure every day has been tried before giving up}
    until finish; {if all are tried it stops}
  end;

Procedure showinfo;
  begin
    gotoxy(4,20);
    write('Routes left to add : ',max,'   Press any key to abort...      ');
  end;

Procedure Printout;
  begin
    showinfo;         {status line info}
    showdata(all);    {screen info}
  end;

Procedure Saveit;    {save each sequence as it's found}
  var i : integer;
      s : string[3];

  begin
    row.id:=0;
    str(seq,s);
    row.identifier:=s;
    for i:=1 to size do
      begin
        if found[i]=fo then
          with row.day[i] do
            begin
              days:=[];
              route:=all[i].route;
              overnight:=all[i].overnight;
              overdays:=all[i].overdays;
              drive:=all[i].drive; work:=all[i].work;
            end else
            begin
              with row.day[i] do
                begin
                  days:=[]; route:='';
                  overnight:=false; overdays:=0; drive:=0; work:=0;
                end;
            end;
      end;
   write(f3,row);
  end;

Procedure Switch(yes : boolean); {this switches between a route of the 1st 14 and one past 15}
  var q,x,i,j : integer;
      wk : 1..2;
  begin
    if max>(size+1) then
      begin
        repeat i:=random(max-size)+size+1; until all[i].work<weekwork;
        repeat j:=random(max-size)+size+1; until all[j].work<weekwork;
        r:=all[i];all[i]:=all[j];all[j]:=r;
        repeat
          i:=random(size)+1;
          if not yes and ((found[i]=o) or (found[i]=fo)) then i:=0;
        until i in [1..size];
        repeat j:=random(max-size)+size+1; until all[j].work<weekwork;
        x:=0;
        if i>7 then begin q:=i-7; wk:=2; end else begin q:=i; wk:=1; end;
        repeat
          repeat j:=random(max-size)+size+1; x:=x+1; until all[j].work<weekwork;
        until ((ord(all[j].day)=q-1) and (all[j].week=wk)) or (x>50);
        if x<50 then begin r:=all[i]; all[i]:=all[j]; all[j]:=r; end;
        end else
      begin {the switch is different once it gets below 15 routes left}
        if not once then begin once:=true; for i:=1 to max do small[i]:=all[i];
                                           for x:=1 to size+1 do all[i]:=blank; for i:=1 to max do all[i]:=small[i];
                         end;
        i:=random(size)+1; j:=random(size)+1;
        r:=all[i];all[i]:=all[j];all[j]:=r;
      end;
  end;

Procedure Takeout(i : integer); {removes a route from the list}
  var j : integer;
  begin
    for j:=i-offset to max-1 do all[j]:=all[j+1];
    offset:=offset+1;
    all[max]:=blank;
    max:=max-1;
  end;

Procedure Blankout(i : integer); {makes a slot empty}
 var j : integer;
 begin
   for j:=i-offset to size-1 do all[j]:=all[j+1];
   offset:=offset+1;
   all[size]:=blank;
 end;

Procedure Remove; {this removes the routes of the last sequence found and moves everything else down to fill the slots left}
  var sum,i,j : integer;
      ch : char;
  begin
    sum:=0;
    offset:=0;
    if max>size then
      begin
        for i:=1 to size do if found[i]=fo then sum:=sum+1;
        if sum<>0 then begin
                         seq:=seq+1;
                         max:=max-sum;
                         printout;
                         max:=max+sum;
                         if save then saveit;
                       end;
        for i:=1 to size do if found[i]=fo then takeout(i);
      end else
      begin
        sum:=0;nums:=[];
        for i:=1 to size do if found[i]=fo then sum:=sum+1;
        if sum<>0 then begin
                         seq:=seq+1;
                         max:=max-sum;
                         printout;
                         max:=max+sum;
                         if save then saveit;
                       end;
        for i:=1 to size do if found[i]=fo then
          begin
            j:=0;
            repeat
              j:=j+1;
            until (all[i].route=small[j].route) and (all[i].day=small[j].day)
                  and (all[i].week=small[j].week);
            nums:=nums+[j];
          end
            else all[i]:=blank;
        for i:=1 to size+1 do all[i]:=blank;
        for i:=1 to max do all[i]:=small[i];
        for i:=1 to size do if i in nums then found[i]:=fo else found[i]:=nf;
        for i:=1 to max do if found[i]=fo then blankout(i);
        max:=max-sum;
      end;
    if max<=0 then begin writeln; writeln('All Done..'); end;
    once:=false;
    done:=true;
  end;

Procedure Readdata; {this reads in route data and assigns slots for each route and week}
  var wk : 1..2;
  begin
    assign(f,find + '.rts');
    reset(f);
    num:=0;
    repeat
      read(f,a);
      for d:=mo to su do
        if d in a.days then
          begin
            for wk:=1 to timeset do
              begin
                num:=num+1;
                with all[num] do begin route:=a.route; work:=a.work; drive:=a.drive;
                                       day:=d; overnight:=a.overnight; overdays:=a.overdays; end;
                all[num].week:=wk;
              end;
          end;
    until eof(f);
    close(f);
    max:=num; once:=false;
    with blank do
      begin
        route:='';
        drive:=0; work:=0; day:=mo;
        overnight:=false; overdays:=0;
      end;
    once:=false;
  end;

Procedure Exchange(q : integer);  {switches two routes}
  var temp : rec;
  begin
    temp:=all[ord(all[q].day)+1+7*(all[q].week-1)];
    all[ord(all[q].day)+1+7*(all[q].week-1)]:=all[q];
    all[q]:=temp;
  end;

Procedure Findseq(yes : boolean); {finds a good sequence}
  var a,i,j,k : integer;
      better : boolean;

  begin
    exit:=false;
    loss:=maxwork; least:=maxwork;
    a:=0;
    quit:=false;
    better:=false;
    temp:=all;
    if not yes then tf:=found;
    repeat
      a:=a+1;
      if not quit then
        begin
          if keypressed then exit:=true;
          if yes then clear else found:=tf;
          switch(yes);
          check(yes);
          if loss<least then {if it finds a better one it changes}
            begin
              least:=loss; {least is the least amount of difference}
              tfound:=found; {save the found slots}
              better:=true;
              a:=1;
              temp:=all;   {temp becomes the best one}
              if loss<=devi then quit:=true;
            end;
        end;
    until (a>=1000) or quit or exit; {gives it one thousand tries with no better one found before accepting}
    if better then begin found:=tfound; loss:=least; all:=temp; remove; end
              else writeln('Out of routes!!');
  end;

Procedure Bigworks; {this deals with routes over 53.5 hours because the regular routine would never accept them since they}
  var               {are always over the maximum in one week, it puts each in a week by itself}
    a,i : integer;
  begin
    a:=0;
    repeat
      clear;
      a:=a+1;
      if all[a].work>weekwork then
        begin
          found[ord(all[a].day)+1+7*(all[a].week-1)]:=fo;
          for i:=1 to all[a].overdays do
            found[ord(all[a].day)+1+i+7*(all[a].week-1)]:=o;
          exchange(a);
          findseq(false);
          a:=1;
        end;
    until (a>=max) or exit;
  end;

Procedure Calc;
  var i : integer;
  begin
    if not exit then
      begin
        repeat
          findseq(true);   {search for sequences}
        until (max<=0) or exit;  {until none left}
      end;
    if exit then begin clearline; write('Compilation Aborted...'); end;
  end;

begin
  screen;
  gotoxy(4,20);
  devi:=0.1;
  write('Enter deviation (in hours) from the maximum of 107 per week : ');
  getdecimal(devi,4);
  clearline;
  write('This will erase any previously made sequences. Press ESC to abort');
  wait; read(kbd,ch); if ch=#27 then quit:=true;
  clearline;
  if not quit then
    begin
      if save then
        begin
          assign(f3,find + '.seq');
          rewrite(f3);
        end;
      init;
      readdata;
      bigworks;
      calc;
      writeln;
      writeln;
    end;
  if save and (not quit) then close(f3);
  if not quit then run('zero2') else run('edseq');
end.