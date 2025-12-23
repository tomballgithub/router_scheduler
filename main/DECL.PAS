type
  offon = (off,on);
  word = string[40];
  line = string[80];
  timetype = string[4];
  creed = (german, american);
  timestore = record
                done : boolean;
                hotel, total, drive : real;
                starttime,endtime : integer;
                overdays : 0..5;
                route     : string[6];
                excuse : string[10];
              end;
  driver = record
             seq    : string[3];
             first,last : string[20];
             id   : integer;
             total,drive,payrate : real;
             citizen: creed;
             week   : array[1..2] of
                        record
                          wtotal,wdrive : real;
                          m : 1..12; d : 1..31;
                          day : array[1..7] of timestore;
                        end;
           end;
  filetype = file of driver;

