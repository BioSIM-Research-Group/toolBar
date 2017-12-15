package provide toolBar 1.0

# VMD tollBar plugin
#
# Author: Nuno M. F. Sousa A. Cerqueira and Henrique Fernandes
#
# $Id: toolBar.tcl, v1.0 2017/111/10 22:31:39
#
# Implements a toolBar for VMD
# 
# usage: toolBar::startGui


## TODO

# adicionar o botão das representacoes
# melhorar o codigo quando tem mais de 1 molecula

namespace eval toolBar:: {
	namespace export toolBar

        variable topGui ".toolBar"
		variable buttonOrder "{moving B} {open B} {save B}  {openVisual B} {saveVisual B} {representations B} {rotate C} {translate C} {scale C} {resetView B} {centerAtom C} {query C} {measure C} {deleteLabels B} {render B}"

		variable Layer	0	; #ID of the graphics toplayer
		variable cmdType	0 ; #variable used to reset buttons
		variable graphicsID ""; #graphics on the toplayer molecules
		variable pickedAtoms ""; #atoms picked by VMD
		variable cmd ""; #command that was selected from the toolbar
		variable nColumns 0; # number of columns per row in the toolbar
		variable xoff 0	; # coordinates of window
		variable yoff 0 ; # coordinates of window
		variable version "1.2"


		## Packages
		
		package require Tk
		package require vmdRender 1.0      
}


proc toolBar::moveWindow {x y} {
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
	wm overrideredirect $toolBar::topGui true
	wm title $toolBar::topGui "ToolBar" ;# titulo da pagina
	wm resizable $toolBar::topGui 0 0
	wm attribute $toolBar::topGui -topmost


 
    #############################################################
    #### Styles #################################################
    #############################################################

	# Load the styles of the buttons
    variable images
	array set toolBar::images [toolBar::loadImages [file join [file dirname [info script]] style/icons] *.gif]

	foreach var $toolBar::buttonOrder {
		
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


    #############################################################
    #### Buttons ################################################
    #############################################################


    #### FRAME 0 - Rotate, Translate and Zoom
    grid [frame $toolBar::topGui.frame0] -row 0 -column 0  -sticky news

	set row 0; set column 0
	foreach var $toolBar::buttonOrder {
		
		set a [lindex $var 0]
		set opt [lindex $var 1]
		if {$opt=="C"} {		
        	grid [ttk::checkbutton $toolBar::topGui.frame0.$a \
				-style toolBar.button.$a \
				-command "toolBar::cmd [subst $a]" \
				-variable ::toolBar::button_[subst $a] \
           		-onvalue 1 -offvalue 0 \
            	] -in $toolBar::topGui.frame0 -row $row -column $column -sticky news

		} else {
		      grid [ttk::button $toolBar::topGui.frame0.$a \
				-style toolBar.button.$a \
				-command "toolBar::cmd [subst $a]" \
		       ] -in $toolBar::topGui.frame0 -row $row -column $column -sticky news
			
		}

		update
		if {$column>=$toolBar::nColumns} {set column 0; incr row} else {incr column} 
		
     }


    #############################################################
    #### Trace Variables ########################################
    #############################################################

    ## Trace pick atom
    trace variable ::vmd_pick_atom w {toolBar::atomPicked}
    trace add variable ::vmd_initialize_structure write {toolBar::initDisplayText}

	## Draw logFile
	#trace add variable ::vmd_logfile write {toolBar::logfile}
	user add key r {mouse mode rotate; toolBar::cmd rotate}
	user add key s {mouse mode rotate; toolBar::cmd scale}
	user add key t {mouse mode rotate; toolBar::cmd translate}	
	user add key p {mouse mode pick; toolBar::cmd pick}


    #############################################################
    #### Bindings ###############################################
    #############################################################

    bind $toolBar::topGui.frame0.moving <B1-Motion> [list toolBar::moveWindow %X %Y]

	#############################################################
	#### Extra Cmds #############################################
	#############################################################
	

	toolBar::moveGui
 	toolBar::cmd rotate

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
# Applies the commands to the buttons

	set toolBar::cmd $cmd

	# reset all buttons from the toolbar if it is required
	if {$toolBar::cmdType==1} {toolBar::resetToolBar }
	
	
    switch $cmd {
             rotate    {mouse mode rotate;\
						set toolBar::button_rotate 1; \
						set toolBar::cmdType 1 }
						
             translate {mouse mode translate; \
						set toolBar::button_translate 1; \
						set toolBar::cmdType 1}
						
             scale      {mouse mode scale; \
						set toolBar::button_scale 1; \
						set toolBar::cmdType 1}
						
			 query     {set toolBar::button_rotate 1; \
						mouse mode pick; \
					    set toolBar::button_query 1; \
					    set toolBar::cmdType 1 }	

			measure     {set toolBar::button_rotate 1; set toolBar::pickedAtoms ""; \
						 mouse mode pick; \
						 set toolBar::button_measure 1; \
						 set toolBar::cmdType 1
						
						}	

			 centerAtom  	{set toolBar::button_rotate 1; \
							set toolBar::button_centerAtom 1; \
							set toolBar::cmdType 1; 
							mouse mode center; \
							}	

			 resetView	{display resetview;
			
						catch {graphics $toolBar::Layer delete all}
						set toolBar::cmdType 0; 
						toolBar::cmd rotate}
			
			 open      			{set toolBar::cmdType 0; \
								menu files on
								}
			 save      			{set toolBar::cmdType 0; \
								menu save on
								}
								
			 saveVisual     	{set toolBar::cmdType 0; \
								 set fileName [file rootname [file tail [molinfo [molinfo top] get name] ]]
								 set topLayerName $fileName
								 graphics [molinfo top] delete all
						         set types { {{VMD States} {.vmd}     }
								             {{All Files}  *         }}

								 set fileName [tk_getSaveFile -initialfile $fileName  -defaultextension ".vmd" -filetypes $types]
								 save_state $fileName
								}
								
			 openVisual     	{set toolBar::cmdType 0; \
						         set types { {{VMD States} {.vmd}     }
								             {{All Files}  *         }}
								set fileName [tk_getOpenFile -filetypes $types]
								if {$fileName != ""} {
									play $fileName
								}
								}
			 
			 deleteLabels   	{label delete Atoms all ; \
								label delete Bonds all  ; \
								label delete Angles all ; \
								label delete Dihedrals all ; \
								set toolBar::cmdType 0}
								
			 render			   	{vmdRender::gui; set toolBar::cmdType 0}

			 representations 	{menu graphics off ;\
			 					menu graphics on}
			
             default   {set toolBar::cmdType 0}
    }

	if {$toolBar::cmdType==0} {toolBar::resetToolBar}
	#update


}

proc toolBar::resetToolBar {} {
# Reset all the buttons in which the option previousCMD equals to 1.
	foreach var $toolBar::buttonOrder {
		set a [lindex $var 0]
		set opt [lindex $var 1]
		if {$opt=="C"} {set toolBar::button_$a 0}
	}
	toolBar::deleteGraphics $toolBar::Layer	
}

proc toolBar::deleteGraphics {topLayer} {
		# Delete all graphics from the layer if it exists
		
		# See if the toolBarGraphics exit
		set nameLayer ""
		foreach x [molinfo list] {set nameLayer [linsert $nameLayer end [molinfo $x get name]]}
		
		# If it  exists 
		if {[lsearch $nameLayer "toolBar"]!=-1} {
			foreach a $toolBar::graphicsID {graphics [lindex $a 0] delete [lindex $a 1]}
			set toolBar::graphicsID ""
		}
	
}

proc toolBar::atomPicked {args} {
# gives information when an atom is picked

    global ::vmd_pick_atom
    global ::vmd_pick_mol  

	if {[llength $toolBar::pickedAtoms]>=1 && [llength $toolBar::pickedAtoms]<=3} {
		set toolBar::pickedAtoms [lappend toolBar::pickedAtoms $::vmd_pick_atom]
	} else {	
		# Delete all graphics from the toplayer
		toolBar::deleteGraphics [molinfo top]
		
		# Add the first atom	
		set toolBar::pickedAtoms "$::vmd_pick_atom"
	}
	
	
	# Put Values in the correct place
		
	if {[llength $toolBar::pickedAtoms]==1} {
		#Draw a sphere on the selected atom
		set toolBar::graphicsID [lappend toolBar::graphicsID "[toolBar::sphere [lindex $::vmd_pick_atom 0] red]"]		
		# Print the result on the bottom
		set sel [atomselect $::vmd_pick_mol "same residue as index $::vmd_pick_atom"]
		set atom [atomselect $::vmd_pick_mol "index $::vmd_pick_atom"]
		lassign [$atom get {resname resid index}] resname resid
   
		toolBar::displayText "Info) Resname [lindex $resname 0]; Resid [lindex $resname 1]; Index [lindex $resname 2]" 0
		
		
		if {$toolBar::cmd=="query"} {
			toolBar::displayText "Info) Resname [lindex $resname 0]; Resid [lindex $resname 1]; Index [lindex $resname 2]" 0
			set toolBar::pickedAtoms ""
		}
		
		if {$toolBar::cmd=="measure"} {
			toolBar::displayText "Info) Select another atom..." 0
		}
	}
	
	
	if {[llength $toolBar::pickedAtoms]==2 && $toolBar::cmd=="measure"} {
		#Draw a sphere on the selected atom
		
		# calculate distance
		set value [format %7.2f [measure bond  "[lindex $toolBar::pickedAtoms 0] [lindex $toolBar::pickedAtoms 1]"] ]
	 
		# Print the result on the bottom  
		toolBar::displayText "Info) Distance = $value A" 0
		set toolBar::graphicsID [lappend toolBar::graphicsID "[toolBar::sphere [lindex $::vmd_pick_atom 0] yellow]"]
	}
	
	
	if {[llength $toolBar::pickedAtoms]==3 && $toolBar::cmd=="measure"} {
		#Draw a sphere on the selected atom
		set toolBar::graphicsID [lappend toolBar::graphicsID "[toolBar::sphere [lindex $::vmd_pick_atom 0] green]"]
		# calculate distance
		set value [format %7.2f [measure angle "[lindex $toolBar::pickedAtoms 0] [lindex $toolBar::pickedAtoms 1] [lindex $toolBar::pickedAtoms 2]"] ]
		
		# Print the result on the bottom  
		toolBar::displayText "Info) Angle = $value degree" 0
	}


	if {[llength $toolBar::pickedAtoms]==4 && $toolBar::cmd=="measure"} {
		#Draw a sphere on the selected atom
		set toolBar::graphicsID [lappend toolBar::graphicsID "[toolBar::sphere [lindex $::vmd_pick_atom 0] blue]"]		
		# calculate distance
		set value [format %7.2f [measure dihed "[lindex $toolBar::pickedAtoms 0] [lindex $toolBar::pickedAtoms 1] [lindex $toolBar::pickedAtoms 2] [lindex $toolBar::pickedAtoms 3]"] ]
		
		# Print the result on the bottom  
		toolBar::displayText "Info) Dihedral = $value degree" 0
	}
   
}


proc toolBar::displayText {text display_front} {
# Display VMD information	
	
	# Who is the  current topLayer
	set currentLayer [molinfo top]
	
	# See if the toolBarGraphics exit
	set nameLayer ""
	foreach x [molinfo list] {set nameLayer [linsert $nameLayer end [molinfo $x get name]]}
	
	# If it does not exists creates it
	if {[lsearch $nameLayer "toolBar"]==-1} {mol load graphics "toolBar"}
	
	# Get the ID of the graphics layer
	foreach x [molinfo list] { if {[molinfo $x get name]=="toolBar"} {set toolBar::Layer $x}}
	
    # fixe window
    molinfo $toolBar::Layer set fixed 1
	
    # Coordinates of the message
	molinfo $toolBar::Layer  set center_matrix [list [transidentity]]
	molinfo $toolBar::Layer  set rotate_matrix [list [transidentity]]
	molinfo $toolBar::Layer  set global_matrix [list [transidentity]]
	molinfo $toolBar::Layer  set scale_matrix  [molinfo [molinfo top] get scale_matrix]

	set display_height [expr 0.25*[display get height]]
    set display_width [expr $display_height*[lindex [display get size] 0]/[lindex [display get size] 1]]

    #set display_front -0.1

	# Display Message
    graphics $toolBar::Layer delete all
    graphics $toolBar::Layer color black 

	# draw 3 lines in background
	
	for {set i 0.94} {$i<=1.0} {set i [expr $i +0.01]} {
		set value -$i
		graphics $toolBar::Layer  line "[expr -1*$display_width] [expr $value*$display_height] $display_front" "[expr 1*$display_width] [expr ($value*$display_height)] $display_front" width 10
	
	
	}
	
	#graphics $toolBar::Layer cylinder "[expr -1*$display_width] [expr -0.98*$display_height] $display_front" "[expr 1*$display_width] [expr (-0.98*$display_height)] $display_front" radius 0.1 filled yes

	# draw message	
    graphics $toolBar::Layer  color black
    graphics $toolBar::Layer text "[expr -0.99*$display_width] [expr -0.97*$display_height] $display_front" $text size 0.9 thickness 10
	graphics $toolBar::Layer  color white
    graphics $toolBar::Layer text "[expr -0.99*$display_width] [expr -0.97*$display_height] $display_front" $text size 0.9 thickness 2
	#update
	
    # make the previouslayer top
	if  {[molinfo list]!=0} {mol top $currentLayer}
}

proc toolBar::sphere {selection color} {
# Draw sphere in one atom
	set coordinates [[atomselect top "index $selection"] get {x y z}]
	
	# Draw a circle around the coordinate
	draw color $color
	draw material Transparent
	set id [graphics [molinfo top] sphere "[lindex $coordinates 0] [lindex $coordinates 1] [lindex $coordinates 2]" radius 1.0 resolution 25]
	return  "[molinfo top] $id"
}


proc toolBar::initDisplayText {args} {
	toolBar::displayText "Info)" 0
}

## STRAT ToolBar
toolBar::startGui



