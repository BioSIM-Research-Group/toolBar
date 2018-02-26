	set file "/Users/nuno/teste.vmd"
    puts "File: $file"

	#open file
	set loadFile [open $file r+]

    while {![eof $loadFile]} {
        set read [gets $loadFile]


        if {[string first "mol new" $read]!=-1} {
            set file [lindex $read 2]
            set newFileName [file tail $file]


puts "new File: $newFileName"
            exit

        }


    }


    # close file
	close $file