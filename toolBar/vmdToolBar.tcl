package provide toolBar 1.0

# VMD tollBar plugin
#
# Author: Nuno M. F. Sousa A. Cerqueira and Henrique Fernandes
#
# $Id: toolBar.tcl, v1.0 2017/111/10 22:31:39
#
# Implements a toolBar for VMD with basic commands
# 
# usage: toolBar::startGui


###### TODO

# 1. incluir um button para o main (o engine já está)
# 2. incluir um buttton exit (assim n\ao é necessário ter o main aberto)
# 3. incluir uma sphere para center on atom




namespace eval toolBar:: {
	namespace export toolBar

		# global variables of the toolBar
        variable topGui ".toolBar"
		variable buttonOrder "	{open B} {save B} \
								{openVisual B} {saveVisual B} \
								{main C} {representations C} \
								{rotate C} {translate C}\
								{scale C} {query C}\
								{resetView B} {centerAtom C}					
								{bond C} {angle C}\
								{dihedral C} {deleteLabels B}   \
								{render B} "

		variable cmdType	0 ; #variable used to reset buttons
		variable graphicsID ""; #graphics on the toplayer molecules that will be managed by the tollBar
		variable cmd ""; #command that was selected from the toolbar
		variable nColumns 1; # number of columns per row in the toolbar
		variable xoff 0	; # coordinates of window
		variable yoff 0 ; # coordinates of window
		variable version "0.8.2"

		## Packages
		package require Tk
		package require vmdRender 1.0      
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
		return $w
	}

	# Initialize window
	toplevel $toolBar::topGui

	### Hide the Window Decoration
	if {[string first "Windows" $::tcl_platform(os)] == -1} {
		wm overrideredirect $toolBar::topGui true
		wm resizable $toolBar::topGui 0 0
	}
	wm title $toolBar::topGui "ToolBar" ;# titulo da pagina
	wm attribute $toolBar::topGui -topmost

    #############################################################
    #### Styles #################################################
    #############################################################

	# Load the styles of the buttons
    variable images
	array set toolBar::images [toolBar::loadImages [file join [file dirname [info script]] style/icons] *.gif]

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
	grid [frame $toolBar::topGui.frame0] -row 0 -column 0
	grid [ttk::button $toolBar::topGui.frame0.header \
				-style toolBar.button.topmoving \
				-command "toolBar::cmd moving" \
		       ] -in $toolBar::topGui.frame0 -row 0 -column 0 -sticky news

    #### FRAME 1 - Buttons
	#	Button type C - checkbutton
	#	Button Other  - button
	# 	The order of the buttons is done by the global varibale "buttonOrder"

    grid [frame $toolBar::topGui.frame1] -row 1 -column 0  -sticky news

	set row 0; set column 0
	foreach var $toolBar::buttonOrder {
	
		set a [lindex $var 0]
		set opt [lindex $var 1]
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

		update
		if {$column>=$toolBar::nColumns} {set column 0; incr row} else {incr column} 
		
     }

	#### FRAME 2- Text frame
	#grid [frame $toolBar::topGui.frame2] -row 2 -column 0  
	grid [text $toolBar::topGui.frame1.text -width 8 -height 10 \
			-bg {#575756} \
			-fg white \
			-borderwidth 0 \
			-highlightbackground {#575756} \
    	] -in $toolBar::topGui.frame1 -row [expr $row + 1] -column 0 -columnspan 2 -sticky news

	if {[string first "Windows" $::tcl_platform(os)] != -1} {
		wm overrideredirect $toolBar::topGui true
		wm resizable $toolBar::topGui 0 0
	}

    #############################################################
    #### Trace Variables ########################################
    #############################################################

    ## Trace pick atom
    trace variable ::vmd_pick_atom w {toolBar::atomPicked}

	## Draw logFile
	#trace add variable ::vmd_logfile write {toolBar::logfile}
	user add key r {mouse mode rotate; toolBar::cmd rotate}
	user add key s {mouse mode rotate; toolBar::cmd scale}
	user add key t {mouse mode rotate; toolBar::cmd translate}	
	user add key p {mouse mode pick; toolBar::cmd pick}

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
					    set toolBar::cmdType 1 }	

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

			centerAtom 	{set toolBar::button_rotate 1; \
						set toolBar::button_centerAtom 1; \
						set toolBar::cmdType 1; 
						mouse mode center; \
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

            default   {set toolBar::cmdType 0}
    }

	if {$toolBar::cmdType==0} {toolBar::resetToolBar}
}

proc toolBar::resetToolBar {} {


# Reset all the buttons in which the option previousCMD equals to 1.
	foreach var $toolBar::buttonOrder {
		set a [lindex $var 0]
		set opt [lindex $var 1]
		if {$opt=="C" && $a!="representations" && $a!="main"} {set toolBar::button_$a 0}
	}

	mouse mode off
	#toolBar::deleteGraphics all
}

proc toolBar::deleteGraphics {cmd} {
	# Delete all graphics from the toplayer if required
	foreach a $toolBar::graphicsID {draw delete $a}
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

	set clean off
	switch $toolBar::cmd {
             query    	{set color red; set clean on}
			 bond    	{set color blue;	if {[llength $toolBar::graphicsID]==2} {set clean on} }
			 angle    	{set color green;	if {[llength $toolBar::graphicsID]==3} {set clean on} }
			 dihedral	{set color yellow;	if {[llength $toolBar::graphicsID]==4} {set clean on} }
			 default	{}
	}

	# Delete all graphics from the toplayer if required
	if {$clean=="on"} {toolBar::deleteGraphics $toolBar::cmd}

	#Draw a sphere on the selected atom
	set toolBar::graphicsID [lappend toolBar::graphicsID [toolBar::sphere [lindex $::vmd_pick_atom 0] $color]]	
}


proc toolBar::sphere {selection color} {
# Draw sphere in one atom
	set coordinates [[atomselect top "index $selection"] get {x y z}]
	
	# Draw a circle around the coordinate
	draw color $color
	draw material Transparent
	set id [graphics [molinfo top] sphere "[lindex $coordinates 0] [lindex $coordinates 1] [lindex $coordinates 2]" radius 1.0 resolution 25]
	return  "$id"
}

proc toolBar::displayText {text} {
# insert the information text on the toolBar
	$toolBar::topGui.frame1.text delete 1.0 end
	$toolBar::topGui.frame1.text insert 1.0 $text
}


proc toolBar::vmdState {file} {
# Change the vmdState and remove the path from the PDb files

	#TODO - next milestone

}

## START ToolBar
toolBar::startGui
set toolBar::button_main 1