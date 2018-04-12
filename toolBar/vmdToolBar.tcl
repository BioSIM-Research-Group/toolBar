package provide toolBar 1.0

# VMD tollBar plugin
#
# Author: Nuno M. F. Sousa A. Cerqueira and Henrique S. Fernandes
#
# $Id: toolBar.tcl, v1.0 2017/11/10 22:31:39
#
# Implements a toolBar for VMD with basic commands
# 
# usage: toolBar::startGui


###### TODO
# 1. Add selection manager
# 2. Add tkcon button
# 3. incluir uma sphere para center on atom


namespace eval toolBar:: {
	namespace export toolBar

		# global variables of the toolBar
        variable topGui			".toolBar"
		variable selVGui		".toolBar.selV"
		variable optionsGui		".toolBar.selV.options"
		variable buttonOrder "	{open B \"New molecule...\"} {save B \"Save coordinates...\"} \
								{openVisual B \"Load visualization state...\"} {saveVisual B \"Save visualization state...\"} \
								{main C \"Show/Hide VMD Main\"} {rotate C \"Mouse mode: rotate\"} \
								{representations C \"Show/Hide Representations\"} {translate C \"Mouse mode: translate\"} \
								{selV C \"Show/Hide Selection Manager\"} {scale C \"Mouse mode: scale\"}\
								{resetView B \"Reset View\"} {bond C \"Measure Bonds\"} \
								{centerAtom C \"Mouse mode: center\"} {angle C \"Measure Angles\"} \
								{deleteLabels B \"Delete all labels\"} {dihedral C \"Measure Dihedral Angles\"} \
								{render B \"Image render\"} {tkcon C \"Tk Console\"} \
								{query C \"Pick atoms\"} {quit B \"Quit\"}"

		variable cmdType	0 ; #variable used to reset buttons
		variable graphicsID ""; #graphics on the toplayer molecules that will be managed by the tollBar
		variable cmd ""; #command that was selected from the toolbar
		variable nColumns 1; # number of columns per row in the toolbar
		variable xoff 0	; # coordinates of window
		variable yoff 0 ; # coordinates of window
		variable version "0.9.7"

		variable pathImages [file join [file dirname [info script]] style/icons]

		# Sel V
		variable layers         {} ;# values of the combobox
		variable selection      {}
		variable widget         "tree"
		variable entrySel          ""
		variable item           ""
		variable VMDKeywords    {all none backbone sidechain protein nucleic water waters vmd_fast_hydrogen helix alpha_helix helix_3_10 pi_helix sheet betasheet extended_beta bridge_beta turn coil at acidic cyclic acyclic aliphatic alpha amino aromatic basic bonded buried cg charged hetero hydrophobic small medium large neutral polar purine pyrimidine surface lipid lipids ion ions sugar solvent glycan carbon hydrogen nitrogen oxygen sulfur noh heme conformationall conformationA conformationB conformationC conformationD conformationE conformationF drude unparametrized name type backbonetype residuetype index serial atomicnumber element residue resid resname altloc insertion chain segname segif fragment pfrag nfrag numbonds structure pucker user radius mass charge beta occupancy {all within 4 of} {same residue as} and as or to all within}
		variable selectionHistory {}
		variable selectionHistoryID ""
		variable animationOnOff 1
		variable animationDuration 2.0
    
		variable graphicsID ""
		variable pickedAtomsBAD {}


		## Packages
		package require Tk
		package require vmdRender 1.0
		package require balloon 1.0
		package require selectionManager	1.0
}

proc toolBar::moveWindow {x y} {
# moves the window
	set xpos [expr $x - $toolBar::xoff]
	set ypos [expr $y - $toolBar::yoff]
	wm geometry $toolBar::topGui "+$xpos+$ypos"
	toolBar::moveGui
}

proc toolBar::startGui {} {
# Builds the tooldBar

	# If already initialized, just turn on
	if [winfo exists $toolBar::topGui] {
		wm deiconify $toolBar::topGui
		raise $toolBar::topGui
		return $toolBar::topGui
	}

	# Initialize window
	toplevel $toolBar::topGui

	### Hide the Window Decoration
	#wm overrideredirect $toolBar::topGui true
	wm resizable $toolBar::topGui 0 0

	wm title $toolBar::topGui "ToolBar" ;# titulo da pagina
	wm attribute $toolBar::topGui -topmost

	wm protocol $::toolBar::topGui WM_DELETE_WINDOW {toolBar::quit}

	wm geometry $toolBar::topGui "+0+0"

    #############################################################
    #### Styles #################################################
    #############################################################

	# Load the styles of the buttons
    variable images
	array set toolBar::images [toolBar::loadImages $toolBar::pathImages *.gif]

	foreach var "$toolBar::buttonOrder {moving B}" {
		
			set a [lindex $var 0]
			#create variable
			variable button_$a 0
		    ttk::style element create toolBar.button.$a.button \
		        image [list $toolBar::images($a\-n) \
		                 pressed $toolBar::images($a\-h) \
		                 {selected active} $toolBar::images($a\-h) \
		                 selected $toolBar::images($a\-a) \
		                 active $toolBar::images($a\-h) \
		                 disabled $toolBar::images($a\-n) \
		                ] -width 36 -height 36
		
		    ttk::style layout toolBar.button.$a Button.toolBar.button.$a.button
	}

	#### Top moving button 
	ttk::style element create toolBar.button.topmoving.button \
		        image [list $toolBar::images(moving-n) \
		                 pressed $toolBar::images(moving-h) \
		                 {selected active} $toolBar::images(moving-h) \
		                 selected $toolBar::images(moving-a) \
		                 active $toolBar::images(moving-h) \
		                 disabled $toolBar::images(moving-n) \
		                ] -width 72 -height 18
		
	ttk::style layout toolBar.button.topmoving Button.toolBar.button.topmoving.button

    #############################################################
    #### Buttons ################################################
    #############################################################

    #### FRAME 0 - Header
	grid [ttk::frame $toolBar::topGui.frame0] -row 0 -column 0
	grid [ttk::button $toolBar::topGui.frame0.header \
				-style toolBar.button.topmoving \
				-command "toolBar::cmd moving" \
		       ] -in $toolBar::topGui.frame0 -row 0 -column 0 -sticky news

    #### FRAME 1 - Buttons
	#	Button type C - checkbutton
	#	Button Other  - button
	# 	The order of the buttons is done by the global varibale "buttonOrder"

    grid [ttk::frame $toolBar::topGui.frame1] -row 1 -column 0  -sticky news

	set row 0; set column 0
	foreach var $toolBar::buttonOrder {
	
		set a [lindex $var 0]
		set opt [lindex $var 1]
		set balloon [lindex $var 2]
		if {$opt=="C"} {		
        	grid [ttk::checkbutton $toolBar::topGui.frame1.$a \
				-style toolBar.button.$a \
				-command "toolBar::cmd [subst $a]" \
				-variable ::toolBar::button_[subst $a] \
           		-onvalue 1 -offvalue 0 \
            	] -in $toolBar::topGui.frame1 -row $row -column $column -sticky news

		} else {
		      grid [ttk::button $toolBar::topGui.frame1.$a \
				-style toolBar.button.$a \
				-command "toolBar::cmd [subst $a]" \
		       ] -in $toolBar::topGui.frame1 -row $row -column $column -sticky news
			
		}
		balloon $toolBar::topGui.frame1.$a -text $balloon

		update
		if {$column>=$toolBar::nColumns} {set column 0; incr row} else {incr column} 
		
     }

	#### FRAME 2- Text frame
	grid [text $toolBar::topGui.frame1.text -width 8 -height 10 \
			-bg {#575756} \
			-fg white \
			-borderwidth 0 \
			-highlightbackground {#575756} \
    	] -in $toolBar::topGui.frame1 -row [expr $row + 1] -column 0 -columnspan 2 -sticky news

	update

    #############################################################
    #### Trace Variables ########################################
    #############################################################

    ## Trace pick atom
    trace variable ::vmd_pick_atom w {toolBar::atomPicked}
	trace variable ::vmd_frame w {toolBar::frameChanged}

	## Draw logFile
	user add key r {mouse mode rotate; toolBar::cmd rotate}
	user add key s {mouse mode rotate; toolBar::cmd scale}
	user add key t {mouse mode rotate; toolBar::cmd translate}	
	user add key p {mouse mode pick; toolBar::cmd pick}
	user add key c {mouse mode center; toolBar::cmd centerAtom}

	user add key 0 {mouse mode center; toolBar::cmd centerAtom}
	user add key 1 {mouse mode pick; toolBar::cmd query}
	user add key 2 {mouse mode bond; toolBar::cmd bond}
	user add key 3 {mouse mode angle; toolBar::cmd angle}
	user add key 4 {mouse mode dihedral; toolBar::cmd dihedral}

    #############################################################
    #### Bindings ###############################################
    #############################################################
    bind $toolBar::topGui.frame0.header <B1-Motion> [list toolBar::moveWindow %X %Y]

	#############################################################
	#### Extra Cmds #############################################
	#############################################################
	toolBar::moveGui
 	toolBar::cmd rotate ; # default button


	set toolBar::button_main 1

	menu main move [expr [winfo vrootwidth  $toolBar::topGui] - 500] 50
	menu graphics move [expr [winfo vrootwidth  $toolBar::topGui] - 500] 100

}


proc toolBar::loadImages {imgdir {patterns {*.gif}}} {
# Loads all the images of the toolbar buttons
	foreach pattern $patterns {
    	foreach file [glob -directory $imgdir $pattern] {
        	set img [file tail [file rootname $file]]
        	if {![info exists images($img)]} {
            	set images($img) [image create photo -file $file]
        	}
    	}
	}
    return [array get images]
}


proc toolBar::moveGui {} {
# Deals with the movement of the display windows as a slave to the toolbar Gui

    # window Data
    set windowPosX   [winfo x $toolBar::topGui]
    set windowPosY   [winfo y $toolBar::topGui]
    set windowWidth  [winfo width  $toolBar::topGui]
    set windowHeight [winfo height $toolBar::topGui]
    
    # screen Data
    set screenWidth    [winfo vrootwidth  $toolBar::topGui]
    set screenHeight   [winfo vrootheight  $toolBar::topGui]  
    
    # Move position of the display Window, when the toolbar is moved
    
    # if toolbar window is close to the left of the screen ,it becomes aligned to the left of the screen
    if {$windowPosX<=0} {
        wm geometry $toolBar::topGui ${windowWidth}x${windowHeight}+1+$windowPosY
        display reposition  [expr ${windowPosX} + ${windowWidth}] [expr $screenHeight - $windowPosY-44]
    } else {
        display reposition  [expr ${windowPosX} + ${windowWidth}] [expr $screenHeight - $windowPosY-44]
    }
    display update 
}


proc toolBar::cmd {cmd} {
# Applies the commands to the buttons that are selected on the toolBar

	set toolBar::cmd $cmd

	# reset all buttons from the toolbar if it is required
	if {$toolBar::cmdType==1} {toolBar::resetToolBar }
	
    switch $cmd {
            rotate    	{mouse mode rotate;\
						set toolBar::button_rotate 1; \
						set toolBar::cmdType 1 }
						
            translate 	{mouse mode translate; \
						set toolBar::button_translate 1; \
						set toolBar::cmdType 1}
						
            scale      	{mouse mode scale; \
						set toolBar::button_scale 1; \
						set toolBar::cmdType 1}
						
			query     	{set toolBar::button_rotate 1; \
						mouse mode pick; \
					    set toolBar::button_query 1; \
					    set toolBar::cmdType 1
						}

			centerAtom 	{set toolBar::button_rotate 1; \
						set toolBar::button_centerAtom 1; \
						set toolBar::cmdType 1; 
						mouse mode center; \
						}	


			bond     	{set toolBar::button_rotate 1; \
						 mouse mode labelbond; \
						 set toolBar::button_bond 1; \
						 set toolBar::cmdType 1
						 toolBar::deleteGraphics	all
						}

			angle     	{set toolBar::button_rotate 1;  \
						 mouse mode labelangle; \
						 set toolBar::button_angle 1; \
						 set toolBar::cmdType 1
						toolBar::deleteGraphics	all
						}
						
			dihedral	{set toolBar::button_rotate 1; \
						 mouse mode labeldihedral; \
						 set toolBar::button_dihedral 1; \
						 set toolBar::cmdType 1
						 toolBar::deleteGraphics	all
						}

			resetView	{display resetview;
						catch {graphics [molinfo top] delete all}
						set toolBar::cmdType 0; 
						toolBar::cmd rotate
						}
			
			open      	{set toolBar::cmdType 0; \
						menu files on
						}

			save      	{set toolBar::cmdType 0; \
						menu save on
						}
								
			saveVisual {set toolBar::cmdType 0; \
						 set fileName [file rootname [file tail [molinfo [molinfo top] get name] ]]
						 set topLayerName $fileName
						 graphics [molinfo top] delete all
						 set types { {{VMD States} {.vmd}     }
						           {{All Files}  *         }}

						 set fileName [tk_getSaveFile -initialfile $fileName  -defaultextension ".vmd" -filetypes $types]
						 save_state $fileName
						 toolBar::vmdState $fileName
						}
								
			openVisual {set toolBar::cmdType 0; \
						set types { {{VMD States} {.vmd}     }
						           {{All Files}  *         }}
						set fileName [tk_getOpenFile -filetypes $types]
						if {$fileName != ""} {play $fileName}
						}
			 
			deleteLabels {toolBar::deleteGraphics all; \
						 set toolBar::cmdType 0
						 label delete Atoms all; label delete Bonds all; label delete Angles all; label delete Dihedrals all
						 }
								
			render		{vmdRender::gui; set toolBar::cmdType 0}

			representations 	{
								if {[menu graphics status]=="off"} {
									menu graphics on
									set toolBar::button_representations 1 
									set toolBar::cmdType 1
								} else {menu graphics off} 
								}

			main 		{
						if {[menu main status]=="off"} {
							menu main on
							set toolBar::button_main 1 
							set toolBar::cmdType 1
						} else {menu main off} 
						}			

			tkcon	{
						if {[menu tkcon status]=="off"} {
							menu tkcon on
							set toolBar::button_tkcon 1
							set toolBar::cmdType 1
						} else {menu tkcon off}
						}	

			selV	{
						if {[winfo exists $::toolBar::selVGui]} {
							destroy $::toolBar::selVGui
						} else {
							set toolBar::button_selV 1 
							set toolBar::cmdType 1
							toolBar::startselV
							
						}						 


					
					}

			quit 		{
 						set answer [tk_messageBox -message "Really quit?" -type yesno -icon question]
							switch $answer {
							yes {catch {exit} debug}
							no {}
 							}
						}			

            default   {set toolBar::cmdType 0}
    }

	if {$toolBar::cmdType==0} {toolBar::resetToolBar}
}

proc toolBar::resetToolBar {} {
# Reset all the buttons in which the option previousCMD equals to 1.
	foreach var $toolBar::buttonOrder {
		set a [lindex $var 0]
		set opt [lindex $var 1]
		if {$opt=="C" && $a!="representations" && $a!="main" && $a!="selV"} {set toolBar::button_$a 0}
	}

	mouse mode off
	#toolBar::deleteGraphics all

}

proc toolBar::deleteGraphics {cmd} {
# Delete all graphics from the toplayer if required
	if {$toolBar::graphicsID!=""} {
		foreach a $toolBar::graphicsID {draw delete $a}
	}
	set toolBar::graphicsID ""
	
}

proc toolBar::atomPicked {args} {
# gives information when an atom is picked

    global ::vmd_pick_atom
    global ::vmd_pick_mol  

	# Print the result on the bottom
	set atom [atomselect $::vmd_pick_mol "index $::vmd_pick_atom"]
	set chain [$atom get chain]
	set resname [$atom get resname]
	set resid [$atom get resid]
	set type [$atom get type]
	set index [$atom get index]

	# Show text
	toolBar::displayText "Chain:\n$chain\nResname:\n$resname\nResid:\n$resid\nType:\n$type\nIndex:\n$index"

	set time 1200
	switch $toolBar::cmd {
             query    	{set color red
						label add Atoms [format "%d/%d" [$atom molid] $index]
						 }
			 bond    	{set color blue;	if {[llength $toolBar::graphicsID]<=2} {set time 1200} }
			 angle    	{set color green;	if {[llength $toolBar::graphicsID]<=3} {set time 2000} }
			 dihedral	{set color yellow;	if {[llength $toolBar::graphicsID]<=4} {set time 2500} }
			 default	{}
	}

	#Delete Atom Reference
	if {$toolBar::cmd!="query"} {
		set atomsList [llength [label list Atoms]]
		if {$atomsList!=0} {
			set atomDel [expr [llength [label list Atoms]] -1]
			label delete Atoms $atomDel
		}
	}

	#Draw a sphere on the selected atom
	set toolBar::graphicsID [lappend toolBar::graphicsID [toolBar::sphere [lindex $::vmd_pick_atom 0] $color]]
	after $time {draw delete [lindex $toolBar::graphicsID 0]; set toolBar::graphicsID [lrange $toolBar::graphicsID 1 [llength $toolBar::graphicsID]]}


}





proc toolBar::sphere {selection color} {
# Draw sphere in one atom
	set coordinates [[atomselect top "index $selection"] get {x y z}]
	
	# Draw a circle around the coordinate
	draw color $color
	draw material Transparent
	set id [graphics [molinfo top] sphere "[lindex $coordinates 0] [lindex $coordinates 1] [lindex $coordinates 2]" radius 0.8 resolution 25]

	return  "$id"
}

proc toolBar::displayText {text} {
# insert the information text on the toolBar
	$toolBar::topGui.frame1.text delete 1.0 end
	$toolBar::topGui.frame1.text insert 1.0 $text
}

proc toolBar::frameChanged {args} {
	toolBar::deleteGraphics all
}


proc toolBar::vmdState {file} {
# Change the vmdState and remove the path from the PDb files

	# directory
    set directory [file dirname $file]

	# open read the file and save a new one
	set loadFile [open $file r]
    set saveFile [open "$file.temp" w]
    set newFileName ""
    set newFileNameList ""

    while {![eof $loadFile]} {
        set read [gets $loadFile]

        if {[string first "mol new" $read]!=-1 && [lindex $read 4]!="webpdb"} {
            
			# Look for normal PDB filenames
			set line [lindex $read 2]
            set newFileName [file tail $line]
            set pos0 [string first $line $read]
            set posF [expr $pos0 -1 + [string length $line] ]
            set read [string replace $read $pos0 $posF $newFileName]
            set newFileNameList [lappend newFileNameList $newFileName]

			## Look for the PDB in the toplevel and save in the correct directory
    		foreach a [molinfo list] {
        		set molName [molinfo $a get name]
        		
				if {$molName==$newFileName} {
					set selectAllAtoms [atomselect $a all]
        			$selectAllAtoms writepdb [file rootname $directory/$molName].pdb 
    			}
			
			}

		}

        puts $saveFile $read
    }

    # close files
	close $loadFile; close $saveFile

    #rename newFile
    file rename -force "$file.temp" "$file"

}

proc toolBar::quit {} {
	trace remove variable ::vmd_pick_atom write toolBar::atomPicked
	trace remove variable ::vmd_frame write toolBar::frameChanged
	
	wm withdraw $toolBar::topGui
}

