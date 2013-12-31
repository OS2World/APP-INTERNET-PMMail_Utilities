program PMMail_Strip_1_1;

(* This liltle proggy is my first, and what it does is it searches the index file of e-mail
messages of PMMail 1.5 and strips out any attachement's (uucode, base64 or binehex) data from
it, but leaving the filename for future reference.

Copyright 1996-1997 Samuel Audet <guardia@cam.org>  distribute freely! *)

uses strings,dos;

const bagname = 'folder.bag';  (* index filenames *)
      bakname = 'folder.bak';

var bag,tmp_file   : text;
    bagline,dump   : array[0..400] of char; (* Does folder.bag record need any bigger? *)
    statpos,sizepos,filepos : pchar;  (* pointer position for an index record *)
    index          : word;
    filename,size  : array[0..11] of char;
    i              : byte;
    byte_file      : file of byte;
    stripdir       : string;


procedure strip(sup_file : string); (* da file stripper, case mania *)

var temp      : string;    (* <- This stores a line of text of a message, max 255 columns. *)
    unstrip, strip : text; (* It would be difficult to put more :(  *)
    mode      : byte;
    name      : namestr;   (* for 'fsplit' weird huh? *)
    garbage, boundary : string;
    found     : boolean;
    boundpos  : byte;

begin
   assign(unstrip,stripdir + sup_file);       (* renames the original file to *.bak and opens *)
   fsplit(sup_file,garbage,name,garbage);     (* for writing to the original name *)
   {$I-} rename(unstrip,stripdir + name + '.bak'); {$I+}
   case ioresult of
      2: begin writeln('Error: message file not found'); exit; end;
      5: begin
            assign(unstrip,stripdir + name + '.bak');
            erase(unstrip);
            assign(unstrip,stripdir + sup_file);
            rename(unstrip,stripdir + name + '.bak');
         end;
   end;
   assign(strip,stripdir + sup_file);
   reset(unstrip);
   rewrite(strip);

   (* Looks for the boundary string in the message, and also looks for UUcode attachements *)

   found := false;
   mode := 0;
   while not (eof(unstrip) or found) do    (* mode 0 = storing, searching for boundary *)
   begin                                   (* or uucode start *)
      readln(unstrip,temp);          (* mode 2 = no storing, searching end string of uucode *)
      case mode of
         2: if pos('end',temp) = 1 then begin mode := 0; writeln (strip,temp); end;
         0: begin
               boundpos := pos('boundary="',temp) + 10;
               if boundpos > 10 then
               begin
                  boundary := copy(temp, boundpos, sizeof(temp));
                  boundary := copy(boundary, 1, pos('"',boundary) - 1);
                  found := true;
                  writeln(strip,temp);
                  writeln(strip,'');
               end else
                  if pos('begin 6',temp) = 1 then
                  begin
                     mode := 2;
                     writeln(strip,temp);
                     writeln(strip,'');
               end else
                  writeln(strip,temp);
            end;
      end;
   end;

(* Looks for BinHex and MIME BASE64 attachement using the boundary, and also looks for UUcode *)

   mode := 0;
   while not eof(unstrip) do         (* mode 0 = storing, searching attach start string *)
   begin                             (* mode 1 = no storing, searching end boundary (binhex, base64) *)
      readln(unstrip,temp);          (* mode 2 = no storing, searching end string of uucode *)
      case mode of
         1: if pos('--' + boundary,temp) = 1 then begin mode := 0; writeln (strip,temp); end;
         2: if pos('end',temp) = 1 then begin mode := 0; writeln (strip,temp); end;
         0: begin
               if pos('Content-Transfer-Encoding: base64',temp)
                  or pos('Content-Transfer-Encoding: BASE64',temp) = 1 then
               begin
                  mode := 1;
                  writeln(strip,temp);
                  writeln(strip,'');
               end else
               if pos('Content-Disposition: attachment; filename="',temp) = 1 then
               begin
                  mode := 1;
                  writeln(strip,temp);
                  writeln(strip,'');
               end else
               if pos('begin 6',temp) = 1 then
               begin
                  mode := 2;
                  writeln(strip,temp);
                  writeln(strip,'');
               end else
                  writeln(strip,temp);
            end;
      end;
   end;
   close(unstrip);
   close(strip);
   erase(unstrip);         (* clears the backup *)
end;


begin
   Writeln('PMMail 1.5 Utilities 1.1, Attachment Stripper - Copyright 1996-1997 Samuel Audet');
   stripdir := paramstr(1);
   if (stripdir <> '') and (copy(stripdir,length(stripdir),1) <> '\')
      then stripdir := stripdir + '\';   (* command line parameter formatting *)
   assign(bag,stripdir + bagname);             (* Renames the original folder.bag to folder.bak, and *)
   {$I-} rename(bag,stripdir + bakname); {$I+} (* opens writing to folder.bag. *)
   case ioresult of
      2: if stripdir = ''
            then begin writeln('Error: ' + bagname + ' does not exist in the current directory'); halt; end
            else begin writeln('Error: ' + bagname + ' does not exist in ' + stripdir); halt; end;
      3: begin writeln('Error: the directory ' + stripdir + ' does not exist'); halt; end;
      5: begin
            assign(bag,stripdir + bakname);
            erase(bag);
            assign(bag,stripdir + bagname);
            rename(bag,stripdir + bakname);
         end;
   end;
   assign(tmp_file,stripdir + bagname);
   reset(bag);
   rewrite(tmp_file);

(* This part searches the index, folder.bag and will indicate which file has attachements. *)
   while not eof(bag) do begin
      readln(bag, bagline);
      dump := bagline;
      statpos := strscan(bagline, chr(222)) + 1; (* Checks for attachements entry *)

      (* Checks the position of various entries using null-terminated strings and P(ointer)chars *)

      sizepos := strrscan(bagline, chr(222));
      for i := 1 to 2 do begin
         index := 0;
         repeat                   (* Checks the size entry ... *)
            dec(sizepos);
            inc(index);
         until (sizepos^ = chr(222)) or (sizepos <= statpos);
      end;
      if sizepos <= statpos then begin
         writeln ('Error: bad entry in ' + stripdir + bagname);
         sizepos := nil;
      end else strmove(size,sizepos + 1, index - 1);
                                                  (* ... and sees if it already has stripped *)
                                                  (* it if it contains 'KB', see below *)
      if (statpos^ = '1') and (strpos(size,'KB') = nil) then begin
         filepos := strrscan(bagline, chr(222));
         index := 0;
         repeat                   (* Checks the filename entry and stores it in 'filename' *)
            dec(filepos);
            inc(index);
         until (filepos^ = chr(222)) or (filepos <= statpos);
         if filepos <= statpos then begin
            writeln ('Error: bad entry in ' + stripdir + bagname);
            filepos := nil;
         end else begin
            fillchar(filename, sizeof(filename), #0);
            strmove(filename,filepos + 1,index - 1);  (* This copies filename data to an array of *)
            writeln(filename);                        (* chars starting at the position found. *)
            strip(filename);

            assign(byte_file,stripdir + filename);    (* This opens the message file in Byte mode *)
            reset(byte_file);                         (* calculates the size, and writes it to the index *)
            str(round(filesize(byte_file)/1024),size); (* putting KB instead of K, for verification *)
            close(byte_file);
            fillchar(dump, sizeof(dump), #0);
            strmove(dump, bagline, strlen(bagline) - strlen(sizepos + 1));
            strlcat(dump, strcat(size, 'KB'), sizeof(dump));
            strlcat(dump, filepos, sizeof(dump));
         end;
      end;
   writeln(tmp_file,dump);
   end;
   close(bag);
   close(tmp_file);
   erase(bag);
end.
