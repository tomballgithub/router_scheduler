type
  daytype = (mo,tu,we,th,fr,sa,su,null,null2);
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
