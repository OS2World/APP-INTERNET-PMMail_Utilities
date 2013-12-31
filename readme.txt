PMMail 1.5 Utilities 1.1
~~~~~~~~~~~~~~~~~~~~~~~~
To use these utilities, you only need to run them in the directory where
you want it to take effect or include the desired directory as the first
parameter on the command line.  Unzip this archive in your PMMAIL directory
for ease of use.  The folders of PMMail 1.5 are stored on your HD under
separate directories, each contaning a FOLDER.BAG which is used and needed
by these proggies.

All files modified are backed out with their extensions modified to .bak
prior to modification.  In case of failure, if you see any .bak files left
in the processed directory, please rename them to their original filenames
to avoid data loss.

To have easy access to Stripping and Sent Status Changer facilites, I
recommend making Program Objects using STRIP.EXE or CHANGE.EXE as 'path and
filename', identified by the title of your PMMail folders, and
containing the directory to these folders in either "parameters" or
"working directory".

STRIP.EXE
~~~~~~~~~
usage: STRIP <folder.bag directory>

       Will use current directory if no parameter is specified.

[X:\]strip x:\internet\southsde\pmmail\guardia1.act\sent_ma1.fld

or

[x:\internet\southsde\pmmail\guardia1.act\sent_ma1.fld] x:\strip


STRIP.EXE will strip all attachment data from the current PMMail folder
directory to save disk space.  It will leave the filename in the messages for
future reference.  It supports MIME Base64, UUCode and BinHex.  STRIP will
also modify the file size in folder.bag to reflect the new file size, will
round the result to the nearest KB and will add a 'KB' at the end instead
of 'K', as PMMail does. (ie.: 2KB instead of 2K) This KB will identify
messages that have already been stripped, and STRIP will not modify them on
a future execution.

A sample REXX Exit script has been included for those who would like some
of their folders to be stripped automatically when exiting PMMail (ie.: the
Sent Mail folder are files you already have on your HD, why keep two
copies?).

CHANGE.EXE
~~~~~~~~~~

usage: CHANGE <folder.bag directory>

       Will use current directory if no parameter is specified.

[X:\]change x:\internet\southsde\pmmail\guardia1.act\sent_ma1.fld

or

[x:\internet\southsde\pmmail\guardia1.act\sent_ma1.fld] x:\change

CHANGE.EXE will change the status of every message in a PMMail folder
directory to "sent".  This is useful when migrating from PMMail 1.1 or when
rebuilding the index (the index _is_ FOLDER.BAG), where PMMail 1.5 puts all
the messages to "read" status, which is incorrect for the "Sent Mail"
folder for example.  Having them set to "read" status does not allow you to
modify those message for future resending.

Notes
~~~~~
Pascal source codes are included and can be modified at will, but leave my
copyrights.

Thanks to Gerry Copple <gercop@infobahnos.com> for correcting this text.

If you have any questions, write me.  Samuel Audet <guardia@cam.org>

Have phun!
