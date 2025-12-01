#!/bin/sh
bindir=$(pwd)
cd /Users/konstantinoskanellopoulos/Downloads/lab06/lab06/
export 

if test "x$1" = "x--debugger"; then
	shift
	if test "x" = "xYES"; then
		echo "r  " > $bindir/gdbscript
		echo "bt" >> $bindir/gdbscript
		GDB_COMMAND-NOTFOUND -batch -command=$bindir/gdbscript  $<TARGET_FILE:lab06> 
	else
		"$<TARGET_FILE:lab06>"  
	fi
else
	"$<TARGET_FILE:lab06>"  
fi
