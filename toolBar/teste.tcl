
set read "mol new 2nap webpdb last -1 step 1"
set read "mol new /Users/nuno/2nap.pdb pdb last -1 step 1"


set pdbFile [lindex $read 2]
set newFileName [file tail $pdbFile]

# subs the path pelo Nome

set posFile0 [string first $pdbFile $read]
set posFileEnd [expr $pos0 -1 + [string length $pdbFile] ]
set read [string replace $read $posFile0 $posFileENd $newFileName]

# See if the file was uploaded from the PDB
if {[lindex $read 3]=="webpdb"} {
    set posFile0 [string first "webpdb" $read]
    set posFileEnd [expr $pos0 -1 + [string length "webpdb"] ]
    set read [string replace $read $posFile0 $posFileENd "pdb"]
}



set newFileNameList [lappend newFileNameList $newFileName]
