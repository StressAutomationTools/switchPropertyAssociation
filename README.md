# switchPropertyAssociation
perl script to switch out property references in nastran bulk data cards

Currently the file is set up to switch the property cards for CTRIA3 and CQUAD4 cards in short and long field format.
Switching to other card types simply requires switching some matches to the other card types.

how to use:

input in command line:

perl SwitchShellProp.pl fileWithChanges FilesToOperateOn FileNameModification

fileWithChanges:
a text file with two tab seperated columns:
"ID to be replaces"\t"New ID"
for example:
1 123
2 456
would replace every occurance of PID 1 with 123 and PID 2 with 456
so
CQUAD4   1       1       1       2       23      22
would become
CQUAD4   1       123     1       2       23      22

FilesToOperateOn:
either a text file containing a list (one file per line)
or the string "bdfs" or "dats".
If a file list is supplied, only files in the list will be modified.
if "bdfs" is supplied, all files ending .bdf will be modified.
Similarly for "dats".

FileNameModifican:
String that will be prepended to the file name of the file modified
for example, if "MOD_" is supplied, file "file1.bdf" will become "MOD_file1.bdf"
Protections are in place to prevent accidental overwriting of existing files.

If a supplied file does not have any changes the unmodified copy that is temporarily created will be deleted and no new file will remain when the program finishes.
