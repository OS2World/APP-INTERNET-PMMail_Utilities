program PMMail_Sent_Status_Changer_1_1;

(* This proggy changes the status of all messages in a PMMail 1.5 message directory to
'sent'.  Useful when rebuilding the index of the Sent Mail folder or migrating it from
PMMail 1.1 where PMMail 1.5 gives the messages the 'read' status.

Copyright 1996-1997 Samuel Audet <guardia@cam.org>   distribute freely! *)

uses strings;

const bagname = 'folder.bag'; (* index filenames *)
      bakname = 'folder.bak';

var bag,tmp_file : text;
    statpos  : pchar;
    temp     : array[0..400] of char;  (* Enlarge if an entry of folder.bag is bigger. *)
    filename,changedir : string;

begin
   Writeln('PMMail 1.5 Utilities 1.1, Sent Status Changer - Copyright 1996-1997 Samuel Audet');
   changedir := paramstr(1);
   if (changedir <> '') and (copy(changedir,length(changedir),1) <> '\')
      then changedir := changedir + '\';  (* command line parameter formatting *)
   assign(bag,changedir + bagname);   (* Renames the original folder.bag to folder.bak, and *)
   {$I-} rename(bag,changedir + bakname); {$I+} (* opens writing to folder.bag. *)
   case ioresult of
      2: if changedir = ''
            then begin writeln('Error: ' + bagname + ' does not exist in the current directory'); halt; end
            else begin writeln('Error: ' + bagname + ' does not exist in ' + changedir); halt; end;
      3: begin writeln('Error: the directory ' + changedir + ' does not exist'); halt; end;
      5: begin
            assign(bag,changedir + bakname);
            erase(bag);
            assign(bag,changedir + bagname);
            rename(bag,changedir + bakname);
         end;
   end;
   assign(tmp_file,changedir + bagname);
   reset(bag);
   rewrite(tmp_file);

   while not eof(bag) do
   begin
      readln(bag,temp);
      statpos := strscan(temp,chr(222));
      if statpos = nil then writeln('Error: bad entry in ' + changedir + bagname) else
         begin
            statpos := statpos - 1;
            statpos^  := '3';           (* change the current message status to 'sent' *)
            writeln(tmp_file,temp);
         end;
   end;

   close(bag);
   close(tmp_file);
   erase(bag);
end.
