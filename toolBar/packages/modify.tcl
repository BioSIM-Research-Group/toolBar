package provide toolBarModify 1.0.0

##############################################################################
#### Initial procedute BondGui
proc toolBar::bondModifInitialProc {} {
    # Remove Trace
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedModify
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedAngle
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedDihed
    
    ## Clear the pickedAtoms variable
	set toolBar::pickedAtoms {}
	## Trace the variable to run a command each time a atom is picked
    trace add variable ::vmd_pick_atom write toolBar::atomPickedModify
	## Activate atom pick
	mouse mode pick
}

#### Initial procedute AngleGui
proc toolBar::angleModifInitialProc {} {
    # Remove Trace
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedModify
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedAngle
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedDihed

    ## Clear the pickedAtoms variable
	set toolBar::pickedAtoms {}
	## Trace the variable to run a command each time a atom is picked
    trace add variable ::vmd_pick_atom write toolBar::atomPickedAngle
	## Activate atom pick
	mouse mode pick
}

#### Initial procedute DihedGui
proc toolBar::dihedModifInitialProc {} {
    # Remove Trace
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedModify
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedAngle
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedDihed

    ## Clear the pickedAtoms variable
	set toolBar::pickedAtoms {}
	## Trace the variable to run a command each time a atom is picked
    trace add variable ::vmd_pick_atom write toolBar::atomPickedDihed
	## Activate atom pick
	mouse mode pick
}
##############################################################################

##############################################################################
#### Initial procedure BondGui
proc toolBar::guiBondModifInitialProc {} {
    ## Get the index of the atoms picked
    set atomSelect [atomselect top "all"]
    variable initialSelection [$atomSelect get index]
    variable initialSelectionX [$atomSelect get {x y z}]

    ## Deactivate the atom pick
    trace remove variable ::vmd_pick_atom write toolBar::atomPicked
    mouse mode rotate
}

#### Initial procedure AngleGui
proc toolBar::guiAngleModifInitialProc {} {
    ## Get the index of the atoms picked
    set atomSelect [atomselect top "all"]
    variable initialSelection [$atomSelect get index]
    variable initialSelectionX [$atomSelect get {x y z}]

    ## Deactivate the atom pick
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedAngle
    mouse mode rotate
}

#### Initial procedure DihedGui
proc toolBar::guiDihedModifInitialProc {} {
    ## Get the index of the atoms picked
    set atomSelect [atomselect top "all"]

    variable initialSelection [$atomSelect get index]
    variable initialSelectionX [$atomSelect get {x y z}]

    ## Deactivate the atom pick
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedDihed
    mouse mode rotate
}
##############################################################################

##############################################################################
#### Revert the initial structure
proc toolBar::revertInitialStructure {} {

    set i 0
    foreach atom $toolBar::initialSelection {
        set sel [atomselect top "index $atom"]
        $sel moveto [lindex $toolBar::initialSelectionX $i]
        $sel delete
        incr i
    }

    set toolBar::initialSelectionX []

}
##############################################################################

##############################################################################
#### Run this everytime an atom is picked - Bond
proc toolBar::atomPickedModify {args} {

    set numberPickedAtoms [llength $toolBar::pickedAtoms]
    set toolBar::BondDistance "0.00"

    if {$numberPickedAtoms == 1 } {

        lappend toolBar::pickedAtoms $::vmd_pick_atom

        set toolBar::atom1BondSel [lindex $toolBar::pickedAtoms 0]
        set toolBar::atom2BondSel [lindex $toolBar::pickedAtoms 1]
        set toolBar::BondDistance [measure bond [list [list $toolBar::atom1BondSel 0] [list $toolBar::atom2BondSel 0]]]
        set toolBar::initialBondDistance $toolBar::BondDistance
        
        set toolBar::pickedAtoms {}


        #### Load the GUI
        toolBar::guiBondModif

        #### Run the initial procedure
        toolBar::guiBondModifInitialProc

    } elseif {$numberPickedAtoms == 0} { 

        lappend toolBar::pickedAtoms $::vmd_pick_atom

    } else {
        set toolBar::pickedAtoms {}
    }

}

#### Run this everytime an atom is picked - Angle
proc toolBar::atomPickedAngle {args} {

    set numberPickedAtoms [llength $toolBar::pickedAtoms]
    variable AngleValue "0.00"

    if {$numberPickedAtoms == 2 } {

        lappend toolBar::pickedAtoms $::vmd_pick_atom

        variable atom1AngleSel [lindex $toolBar::pickedAtoms 0]
        variable atom2AngleSel [lindex $toolBar::pickedAtoms 1]
        variable atom3AngleSel [lindex $toolBar::pickedAtoms 2]
        variable AngleValue [measure angle [list [list $toolBar::atom1AngleSel 0] [list $toolBar::atom2AngleSel 0] [list $toolBar::atom3AngleSel 0]]]
        variable initialAngleValue $toolBar::AngleValue
    
        ## Set the selections for the desired atoms
        set selection1 [atomselect top "index $toolBar::atom1AngleSel"]
        set selection2 [atomselect top "index $toolBar::atom2AngleSel"]
        set selection3 [atomselect top "index $toolBar::atom3AngleSel"]

        ## Get atom coordinates
        variable pos1 [join [$selection1 get {x y z}]]
        variable pos2 [join [$selection2 get {x y z}]]
        variable pos3 [join [$selection3 get {x y z}]]
        $selection1 delete
        $selection2 delete
        $selection3 delete

        ## Set vectors
        set dir1   [vecnorm [vecsub $toolBar::pos1 $toolBar::pos2]]
        set dir2   [vecnorm [vecsub $toolBar::pos2 $toolBar::pos3]]
        variable normvec [vecnorm [veccross $dir1 $dir2]]

        variable initialAngleValue [measure angle [list [list $toolBar::atom1AngleSel 0] [list $toolBar::atom2AngleSel 0] [list $toolBar::atom3AngleSel 0]]]

        #### Load the GUI
        toolBar::guiAngleModif

        #### Run the initial procedure
        toolBar::guiAngleModifInitialProc

        set toolBar::pickedAtoms {}

    } elseif {$numberPickedAtoms < 2 } {
        lappend toolBar::pickedAtoms $::vmd_pick_atom

    } else {
        set toolBar::pickedAtoms {}
    }

}

#### Run this everytime an atom is picked - Dihed
proc toolBar::atomPickedDihed {args} {

    set numberPickedAtoms [llength $toolBar::pickedAtoms]
    variable DihedValue "0.00"

    if {$numberPickedAtoms == 3 } {

        lappend toolBar::pickedAtoms $::vmd_pick_atom

        variable atom1DihedSel [lindex $toolBar::pickedAtoms 0]
        variable atom2DihedSel [lindex $toolBar::pickedAtoms 1]
        variable atom3DihedSel [lindex $toolBar::pickedAtoms 2]
        variable atom4DihedSel [lindex $toolBar::pickedAtoms 3]
        variable DihedValue [measure dihed [list [list $toolBar::atom1DihedSel 0] [list $toolBar::atom2DihedSel 0] [list $toolBar::atom3DihedSel 0] [list $toolBar::atom4DihedSel 0]]]
        variable initialDihedValue $toolBar::DihedValue
    
        ## Set the selections for the desired atoms
        set selection1 [atomselect top "index $toolBar::atom1DihedSel"]
        set selection2 [atomselect top "index $toolBar::atom2DihedSel"]
        set selection3 [atomselect top "index $toolBar::atom3DihedSel"]
        set selection4 [atomselect top "index $toolBar::atom4DihedSel"]

        ## Get atom coordinates
        variable pos1 [join [$selection1 get {x y z}]]
        variable pos2 [join [$selection2 get {x y z}]]
        variable pos3 [join [$selection3 get {x y z}]]
        variable pos4 [join [$selection4 get {x y z}]]
        $selection1 delete
        $selection2 delete
        $selection3 delete
        $selection4 delete

        variable initialDihedValue [measure dihed [list [list $toolBar::atom1DihedSel 0] [list $toolBar::atom2DihedSel 0] [list $toolBar::atom3DihedSel 0] [list $toolBar::atom4DihedSel 0]]]

        #### Load the GUI
        toolBar::guiDihedModif

        #### Run the initial procedure
        toolBar::guiDihedModifInitialProc

        set toolBar::pickedAtoms {}

    } elseif {$numberPickedAtoms < 3} {
        lappend toolBar::pickedAtoms $::vmd_pick_atom

    } else {
        set toolBar::pickedAtoms {}

    }

}
##############################################################################

##############################################################################
#### Procedure to calculate the bond distance and move the bond
proc toolBar::calcBondDistance {bondlength} {

    if {$toolBar::atom2BondSel != ""} {

        if {[catch {atomselect top "$toolBar::customSelection1"}] == 1} {
            set toolBar::customSelection1 "none"
        }

        if {[catch {atomselect top "$toolBar::customSelection2"}] == 1} {
            set toolBar::customSelection2 "none"
        }

        set atomsToBeMoved1 100
        set atomsToBeMoved2 1

        ## Set the selections for the desired atoms
        set selection1 [atomselect top "index $toolBar::atom1BondSel"]
        set selection2 [atomselect top "index $toolBar::atom2BondSel"]

        ## Get atom coordinates
        set pos1 [join [$selection1 get {x y z}]]
        set pos2 [join [$selection2 get {x y z}]]
        $selection1 delete
        $selection2 delete

        ## Set vectors
        set dir    [vecnorm [vecsub $pos1 $pos2]]
        set curval [veclength [vecsub $pos2 $pos1]]
        
        
        if {$toolBar::atom1BondOpt == "Fixed Atom" && $toolBar::atom2BondOpt == "Fixed Atom"} {
            set alert [tk_messageBox -message "At least one atom must be free to move." -type ok -icon error]

        } elseif {$toolBar::atom1BondOpt == "Fixed Atom" && $toolBar::atom2BondOpt == "Move Atom"} {

            set atomsToBeMoved2 1

            ## Atoms to be moved
            #set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1]]
            if {[catch {::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2}] == 0} {
                set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2]]
            } else {
                set indexes2 $toolBar::atom2BondSel
            }
            #set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            #$selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 1*($curval-$bondlength)] $dir]
            #$selection1 delete
            $selection2 delete
            
        } elseif {$toolBar::atom1BondOpt == "Move Atom" && $toolBar::atom2BondOpt == "Fixed Atom"} {

            set atomsToBeMoved1 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1BondSel
            }
            #set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2]]
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            #set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -1*($curval-$bondlength)] $dir]
            #$selection2 moveby [vecscale [expr 1*($curval-$bondlength)] $dir]
            $selection1 delete
            #$selection2 delete
            
        } elseif {$toolBar::atom1BondOpt == "Move Atom" && $toolBar::atom2BondOpt == "Move Atom"} {

            set atomsToBeMoved1 1
            set atomsToBeMoved2 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1BondSel
            }

            if {[catch {::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2}] == 0} {
                set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2]]
            } else {
                set indexes2 $toolBar::atom2BondSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 0.5*($curval-$bondlength)] $dir]
            $selection1 delete
            $selection2 delete
            
        } elseif {$toolBar::atom1BondOpt == "Move Atom" && $toolBar::atom2BondOpt == "Move Atoms"} {

            set atomsToBeMoved1 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1BondSel
            }

            if {[catch {::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel}] == 0} {
                set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel]]
            } else {
                set indexes2 $toolBar::atom2BondSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 0.5*($curval-$bondlength)] $dir]
            $selection1 delete
            $selection2 delete

        } elseif {$toolBar::atom1BondOpt == "Move Atom" && $toolBar::atom2BondOpt == "Custom"} {

            set atomsToBeMoved1 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1BondSel
            }

            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 0.5*($curval-$bondlength)] $dir]
            $selection1 delete
            $selection2 delete
            
        } elseif {$toolBar::atom1BondOpt == "Custom" && $toolBar::atom2BondOpt == "Move Atom"} {

            set atomsToBeMoved2 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2}] == 0} {
                set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2]]
            } else {
                set indexes2 $toolBar::atom2BondSel
            }
            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 0.5*($curval-$bondlength)] $dir]
            $selection1 delete
            $selection2 delete

        } elseif {$toolBar::atom1BondOpt == "Custom" && $toolBar::atom2BondOpt == "Move Atoms"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel}] == 0} {
                set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel]]
            } else {
                set indexes2 $toolBar::atom2BondSel
            }
            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 0.5*($curval-$bondlength)] $dir]
            $selection1 delete
            $selection2 delete

        } elseif {$toolBar::atom1BondOpt == "Move Atoms" && $toolBar::atom2BondOpt == "Custom"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel]]
            } else {
                set indexes1 $toolBar::atom1BondSel
            }

            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 0.5*($curval-$bondlength)] $dir]
            $selection1 delete
            $selection2 delete

        } elseif {$toolBar::atom1BondOpt == "Custom" && $toolBar::atom2BondOpt == "Custom"} {

            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 0.5*($curval-$bondlength)] $dir]
            $selection1 delete
            $selection2 delete

        } elseif {$toolBar::atom1BondOpt == "Fixed Atom" && $toolBar::atom2BondOpt == "Custom"} {

            set selection2 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection2 moveby [vecscale [expr 1*($curval-$bondlength)] $dir]
            $selection2 delete
            
        } elseif {$toolBar::atom1BondOpt == "Custom" && $toolBar::atom2BondOpt == "Fixed Atom"} {

            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom2BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -1*($curval-$bondlength)] $dir]
            $selection1 delete

        } elseif {$toolBar::atom1BondOpt == "Move Atoms" && $toolBar::atom2BondOpt == "Move Atom"} {

            set atomsToBeMoved2 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel]]
            } else {
                set indexes1 $toolBar::atom1BondSel
            }

            if {[catch {::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2}] == 0} {
                set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2]]
            } else {
                set indexes2 $toolBar::atom2BondSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 0.5*($curval-$bondlength)] $dir]
            $selection1 delete
            $selection2 delete
            
        } elseif {$toolBar::atom1BondOpt == "Move Atoms" && $toolBar::atom2BondOpt == "Move Atoms"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel]]
            } else {
                set indexes1 $toolBar::atom1BondSel
            }

            if {[catch {::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel}] == 0} {
                set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel]]
            } else {
                set indexes2 $toolBar::atom2BondSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 0.5*($curval-$bondlength)] $dir]
            $selection1 delete
            $selection2 delete
            
        } elseif {$toolBar::atom1BondOpt == "Fixed Atom" && $toolBar::atom2BondOpt == "Move Atoms"} {

            ## Atoms to be moved
            #set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel -maxdepth $atomsToBeMoved1]]
            if {[catch {::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel}] == 0} {
                set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel]]
            } else {
                set indexes2 $toolBar::atom2BondSel
            }
            #set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            #$selection1 moveby [vecscale [expr -0.5*($curval-$bondlength)] $dir]
            $selection2 moveby [vecscale [expr 1*($curval-$bondlength)] $dir]
            #$selection1 delete
            $selection2 delete
            
        } elseif {$toolBar::atom1BondOpt == "Move Atoms" && $toolBar::atom2BondOpt == "Fixed Atom"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom2BondSel $toolBar::atom1BondSel]]
            } else {
                set indexes1 $toolBar::atom1BondSel
            }
            #set indexes2 [join [::util::bondedsel top $toolBar::atom1BondSel $toolBar::atom2BondSel -maxdepth $atomsToBeMoved2]]
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom2BondSel"]
            #set selection2 [atomselect top "index $indexes2 and not index $toolBar::atom1BondSel"]
            ## Move atoms according to distance
            $selection1 moveby [vecscale [expr -1*($curval-$bondlength)] $dir]
            #$selection2 moveby [vecscale [expr 1*($curval-$bondlength)] $dir]
            $selection1 delete
            #$selection2 delete
            
        } else {
            set alert [tk_messageBox -message "Unkown error. Please contact the developer." -type ok -icon error]
        }


    } else {
        
    }

    set toolBar::initialBondDistance $toolBar::BondDistance

}


#### Procedure to calculate the angle and move the angle
proc toolBar::calcAngleDistance {newangle} {

    if {$toolBar::atom3AngleSel != ""} {

        if {[catch {atomselect top "$toolBar::customSelection1"}] == 1} {
            set toolBar::customSelection1 "none"
        }

        if {[catch {atomselect top "$toolBar::customSelection2"}] == 1} {
            set toolBar::customSelection2 "none"
        }

        set atomsToBeMoved1 100
        set atomsToBeMoved3 1


        ## Set the delta value
        set delta [expr $toolBar::initialAngleValue - $newangle]
        

        if {$toolBar::atom1AngleOpt == "Fixed Atom" && $toolBar::atom3AngleOpt == "Fixed Atom"} {
            set alert [tk_messageBox -message "At least one atom must be free to move." -type ok -icon error]

        } elseif {$toolBar::atom1AngleOpt == "Fixed Atom" && $toolBar::atom3AngleOpt == "Move Atom"} {

            set atomsToBeMoved3 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel -maxdepth $atomsToBeMoved3}] == 0} {
                set indexes3 [join [::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel -maxdepth $atomsToBeMoved3]]
            } else {
                set indexes3 $toolBar::atom3AngleSel
            }
            set selection3 [atomselect top "index $indexes3 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] $delta deg]
            $selection3 delete
            
        } elseif {$toolBar::atom1AngleOpt == "Move Atom" && $toolBar::atom3AngleOpt == "Fixed Atom"} {

            set atomsToBeMoved1 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1AngleSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] $delta deg]
            $selection1 delete
            
        } elseif {$toolBar::atom1AngleOpt == "Move Atom" && $toolBar::atom3AngleOpt == "Move Atom"} {

            set atomsToBeMoved1 1
            set atomsToBeMoved3 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1AngleSel
            }
            if {[catch {::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel -maxdepth $atomsToBeMoved3}] == 0} {
                set indexes3 [join [::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel -maxdepth $atomsToBeMoved3]]
            } else {
                set indexes3 $toolBar::atom3AngleSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            set selection3 [atomselect top "index $indexes3 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * -0.5] deg]
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * 0.5] deg]
            $selection1 delete
            $selection3 delete
            
        } elseif {$toolBar::atom1AngleOpt == "Move Atom" && $toolBar::atom3AngleOpt == "Move Atoms"} {

            set atomsToBeMoved1 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1AngleSel
            }
            if {[catch {::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel}] == 0} {
                set indexes3 [join [::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel]]
            } else {
                set indexes3 $toolBar::atom3AngleSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            set selection3 [atomselect top "index $indexes3 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * -0.5] deg]
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * 0.5] deg]
            $selection1 delete
            $selection3 delete

        } elseif {$toolBar::atom1AngleOpt == "Move Atom" && $toolBar::atom3AngleOpt == "Custom"} {

            set atomsToBeMoved1 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1AngleSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            set selection3 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * -0.5] deg]
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * 0.5] deg]
            $selection1 delete
            $selection3 delete

        } elseif {$toolBar::atom1AngleOpt == "Custom" && $toolBar::atom3AngleOpt == "Move Atom"} {

            set atomsToBeMoved3 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel -maxdepth $atomsToBeMoved3}] == 0} {
                set indexes3 [join [::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel -maxdepth $atomsToBeMoved3]]
            } else {
                set indexes3 $toolBar::atom3AngleSel
            }
            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            set selection3 [atomselect top "index $indexes3 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * -0.5] deg]
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * 0.5] deg]
            $selection1 delete
            $selection3 delete

        } elseif {$toolBar::atom1AngleOpt == "Move Atoms" && $toolBar::atom3AngleOpt == "Custom"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel]]
            } else {
                set indexes1 $toolBar::atom1AngleSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            set selection3 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * -0.5] deg]
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * 0.5] deg]
            $selection1 delete
            $selection3 delete
        
        } elseif {$toolBar::atom1AngleOpt == "Custom" && $toolBar::atom3AngleOpt == "Move Atoms"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel}] == 0} {
                set indexes3 [join [::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel]]
            } else {
                set indexes3 $toolBar::atom3AngleSel
            }
            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            set selection3 [atomselect top "index $indexes3 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * -0.5] deg]
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * 0.5] deg]
            $selection1 delete
            $selection3 delete

        } elseif {$toolBar::atom1AngleOpt == "Fixed Atom" && $toolBar::atom3AngleOpt == "Custom"} {

            set selection3 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] $delta deg]
            $selection3 delete
            
        } elseif {$toolBar::atom1AngleOpt == "Custom" && $toolBar::atom3AngleOpt == "Fixed Atom"} {

            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] $delta deg]
            $selection1 delete

        } elseif {$toolBar::atom1AngleOpt == "Custom" && $toolBar::atom3AngleOpt == "Custom"} {

            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            set selection3 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * -0.5] deg]
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * 0.5] deg]
            $selection1 delete
            $selection3 delete

        } elseif {$toolBar::atom1AngleOpt == "Move Atoms" && $toolBar::atom3AngleOpt == "Move Atom"} {

            set atomsToBeMoved3 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel]]
            } else {
                set indexes1 $toolBar::atom1AngleSel
            }
            if {[catch {::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel -maxdepth $atomsToBeMoved3}] == 0} {
                set indexes3 [join [::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel -maxdepth $atomsToBeMoved3]]
            } else {
                set indexes3 $toolBar::atom3AngleSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            set selection3 [atomselect top "index $indexes3 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * -0.5] deg]
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * 0.5] deg]
            $selection1 delete
            $selection3 delete
            
        } elseif {$toolBar::atom1AngleOpt == "Move Atoms" && $toolBar::atom3AngleOpt == "Move Atoms"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel]]
            } else {
                set indexes1 $toolBar::atom1AngleSel
            }
            if {[catch {::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel}] == 0} {
                set indexes3 [join [::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel]]
            } else {
                set indexes3 $toolBar::atom3AngleSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            set selection3 [atomselect top "index $indexes3 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * -0.5] deg]
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] [expr $delta * 0.5] deg]
            $selection1 delete
            $selection3 delete
            
        } elseif {$toolBar::atom1AngleOpt == "Fixed Atom" && $toolBar::atom3AngleOpt == "Move Atoms"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel}] == 0} {
                set indexes3 [join [::util::bondedsel top $toolBar::atom1AngleSel $toolBar::atom3AngleSel]]
            } else {
                set indexes3 $toolBar::atom3AngleSel
            }
            set selection3 [atomselect top "index $indexes3 and not index $toolBar::atom1AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection3 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] $delta deg]
            $selection3 delete
            
        } elseif {$toolBar::atom1AngleOpt == "Move Atoms" && $toolBar::atom3AngleOpt == "Fixed Atom"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom3AngleSel $toolBar::atom1AngleSel]]
            } else {
                set indexes1 $toolBar::atom1AngleSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3AngleSel $toolBar::atom2AngleSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 [vecadd $toolBar::normvec $toolBar::pos2] $delta deg]
            $selection1 delete
            
        } else {
            set alert [tk_messageBox -message "Unkown error. Please contact the developer." -type ok -icon error]
        }


    } else {
        
    }

    set toolBar::initialAngleValue $toolBar::AngleValue

}

#### Procedure to calculate the angle and move the angle
proc toolBar::calcDihedDistance {newdihed} {

    if {$toolBar::atom4DihedSel != ""} {

        if {[catch {atomselect top "$toolBar::customSelection1"}] == 1} {
            set toolBar::customSelection1 "none"
        }

        if {[catch {atomselect top "$toolBar::customSelection2"}] == 1} {
            set toolBar::customSelection2 "none"
        }

        set atomsToBeMoved1 100
        set atomsToBeMoved4 1


        ## Set the delta value
        set delta [expr $newdihed - $toolBar::initialDihedValue]
        

        if {$toolBar::atom1DihedOpt == "Fixed Atom" && $toolBar::atom4DihedOpt == "Fixed Atom"} {
            set alert [tk_messageBox -message "At least one atom must be free to move." -type ok -icon error]

        } elseif {$toolBar::atom1DihedOpt == "Fixed Atom" && $toolBar::atom4DihedOpt == "Move Atom"} {

            set atomsToBeMoved4 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel -maxdepth $atomsToBeMoved4}] == 0} {
                set indexes4 [join [::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel -maxdepth $atomsToBeMoved4]]
            } else {
                set indexes4 $toolBar::atom4DihedSel
            }
            set selection4 [atomselect top "index $indexes4 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 $delta deg]
            $selection4 delete
            
        } elseif {$toolBar::atom1DihedOpt == "Fixed Atom" && $toolBar::atom4DihedOpt == "Custom"} {

            set selection4 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 $delta deg]
            $selection4 delete

        } elseif {$toolBar::atom1DihedOpt == "Custom" && $toolBar::atom4DihedOpt == "Fixed Atom"} {

            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 $delta deg]
            $selection1 delete

        } elseif {$toolBar::atom1DihedOpt == "Move Atom" && $toolBar::atom4DihedOpt == "Custom"} {

            set atomsToBeMoved1 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1DihedSel
            }
            
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            set selection4 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * -0.5] deg]
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * 0.5] deg]
            $selection1 delete
            $selection4 delete

        } elseif {$toolBar::atom1DihedOpt == "Custom" && $toolBar::atom4DihedOpt == "Move Atom"} {

            set atomsToBeMoved4 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel -maxdepth $atomsToBeMoved4}] == 0} {
                set indexes4 [join [::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel -maxdepth $atomsToBeMoved4]]
            } else {
                set indexes4 $toolBar::atom4DihedSel
            }
            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            set selection4 [atomselect top "index $indexes4 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * -0.5] deg]
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * 0.5] deg]
            $selection1 delete
            $selection4 delete

        } elseif {$toolBar::atom1DihedOpt == "Move Atoms" && $toolBar::atom4DihedOpt == "Custom"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel]]
            } else {
                set indexes1 $toolBar::atom1DihedSel
            }
            
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            set selection4 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * -0.5] deg]
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * 0.5] deg]
            $selection1 delete
            $selection4 delete

        } elseif {$toolBar::atom1DihedOpt == "Custom" && $toolBar::atom4DihedOpt == "Move Atoms"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel}] == 0} {
                set indexes4 [join [::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel]]
            } else {
                set indexes4 $toolBar::atom4DihedSel
            }
            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            set selection4 [atomselect top "index $indexes4 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * -0.5] deg]
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * 0.5] deg]
            $selection1 delete
            $selection4 delete

        } elseif {$toolBar::atom1DihedOpt == "Custom" && $toolBar::atom4DihedOpt == "Custom"} {

            set selection1 [atomselect top "$toolBar::customSelection1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            set selection4 [atomselect top "$toolBar::customSelection2 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * -0.5] deg]
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * 0.5] deg]
            $selection1 delete
            $selection4 delete

        } elseif {$toolBar::atom1DihedOpt == "Move Atom" && $toolBar::atom4DihedOpt == "Fixed Atom"} {

            set atomsToBeMoved1 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1DihedSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 $delta deg]
            $selection1 delete
            
        } elseif {$toolBar::atom1DihedOpt == "Move Atom" && $toolBar::atom4DihedOpt == "Move Atom"} {

            set atomsToBeMoved1 1
            set atomsToBeMoved4 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1DihedSel
            }
            if {[catch {::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel -maxdepth $atomsToBeMoved4}] == 0} {
                set indexes4 [join [::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel -maxdepth $atomsToBeMoved4]]
            } else {
                set indexes4 $toolBar::atom4DihedSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            set selection4 [atomselect top "index $indexes4 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * -0.5] deg]
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * 0.5] deg]
            $selection1 delete
            $selection4 delete
            
        } elseif {$toolBar::atom1DihedOpt == "Move Atom" && $toolBar::atom4DihedOpt == "Move Atoms"} {

            set atomsToBeMoved1 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel -maxdepth $atomsToBeMoved1}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel -maxdepth $atomsToBeMoved1]]
            } else {
                set indexes1 $toolBar::atom1DihedSel
            }
            if {[catch {::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel}] == 0} {
                set indexes4 [join [::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel]]
            } else {
                set indexes4 $toolBar::atom4DihedSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            set selection4 [atomselect top "index $indexes4 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * -0.5] deg]
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * 0.5] deg]
            $selection1 delete
            $selection4 delete
            
        } elseif {$toolBar::atom1DihedOpt == "Move Atoms" && $toolBar::atom4DihedOpt == "Move Atom"} {

            set atomsToBeMoved4 1

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel]]
            } else {
                set indexes1 $toolBar::atom1DihedSel
            }
            if {[catch {::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel -maxdepth $atomsToBeMoved4}] == 0} {
                set indexes4 [join [::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel -maxdepth $atomsToBeMoved4]]
            } else {
                set indexes4 $toolBar::atom4DihedSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            set selection4 [atomselect top "index $indexes4 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * -0.5] deg]
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * 0.5] deg]
            $selection1 delete
            $selection4 delete
            
        } elseif {$toolBar::atom1DihedOpt == "Move Atoms" && $toolBar::atom4DihedOpt == "Move Atoms"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel]]
            } else {
                set indexes1 $toolBar::atom1DihedSel
            }
            if {[catch {::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel}] == 0} {
                set indexes4 [join [::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel]]
            } else {
                set indexes4 $toolBar::atom4DihedSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            set selection4 [atomselect top "index $indexes4 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * -0.5] deg]
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 [expr $delta * 0.5] deg]
            $selection1 delete
            $selection4 delete
            
        } elseif {$toolBar::atom1DihedOpt == "Fixed Atom" && $toolBar::atom4DihedOpt == "Move Atoms"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom1DihedSel $toolBar::atom4DihedSel}] == 0} {
                set indexes4 [join [::util::bondedsel top $toolBar::atom2DihedSel $toolBar::atom4DihedSel]]
            } else {
                set indexes4 $toolBar::atom4DihedSel
            }
            set selection4 [atomselect top "index $indexes4 and not index $toolBar::atom1DihedSel $toolBar::atom2DihedSel $toolBar::atom3DihedSel"]
            ## Move atoms according to distance
            $selection4 move [trans bond $toolBar::pos2 $toolBar::pos3 $delta deg]
            $selection4 delete
            
        } elseif {$toolBar::atom1DihedOpt == "Move Atoms" && $toolBar::atom4DihedOpt == "Fixed Atom"} {

            ## Atoms to be moved
            if {[catch {::util::bondedsel top $toolBar::atom4DihedSel $toolBar::atom1DihedSel}] == 0} {
                set indexes1 [join [::util::bondedsel top $toolBar::atom3DihedSel $toolBar::atom1DihedSel]]
            } else {
                set indexes1 $toolBar::atom1DihedSel
            }
            set selection1 [atomselect top "index $indexes1 and not index $toolBar::atom3DihedSel $toolBar::atom2DihedSel $toolBar::atom4DihedSel"]
            ## Move atoms according to distance
            $selection1 move [trans bond $toolBar::pos2 $toolBar::pos3 $delta deg]
            $selection1 delete
            
        } else {
            set alert [tk_messageBox -message "Unkown error. Please contact the developer." -type ok -icon error]
        }


    } else {
        
    }

    set toolBar::initialDihedValue $toolBar::DihedValue

}
##############################################################################

##############################################################################
#### Bond - Apply and Cancel button
proc toolBar::bondGuiCloseSave {} {
    trace remove variable ::vmd_pick_atom write toolBar::atomPicked
    mouse mode rotate
    
    set molExists [mol list]
    if {$molExists == "ERROR) No molecules loaded."} {
    } else {
        mol modselect 9 top "none"
    }

    destroy $::toolBar::bondModif
}


proc toolBar::bondGuiCloseNotSave {} {
    trace remove variable ::vmd_pick_atom write toolBar::atomPicked
    mouse mode rotate
    
    set molExists [mol list]
    if {$molExists == "ERROR) No molecules loaded."} {
    } else {
        mol modselect 9 top "none"
    }

    toolBar::revertInitialStructure
    destroy $::toolBar::bondModif
}


#### Angle - Apply and Cancel button
proc toolBar::angleGuiCloseSave {} {
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedAngle
    mouse mode rotate
    
    set molExists [mol list]
    if {$molExists == "ERROR) No molecules loaded."} {
    } else {
        mol modselect 9 top "none"
    }

    destroy $::toolBar::angleModif
}


proc toolBar::angleGuiCloseNotSave {} {
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedAngle
    mouse mode rotate
    
    set molExists [mol list]
    if {$molExists == "ERROR) No molecules loaded."} {
    } else {
        mol modselect 9 top "none"
    }

    toolBar::revertInitialStructure
    destroy $::toolBar::angleModif
}

#### Dihed - Apply and Cancel button
proc toolBar::dihedGuiCloseSave {} {
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedDihed
    mouse mode rotate
    
    set molExists [mol list]
    if {$molExists == "ERROR) No molecules loaded."} {
    } else {
        mol modselect 9 top "none"
    }

    destroy $::toolBar::dihedModif
}


proc toolBar::dihedGuiCloseNotSave {} {
    trace remove variable ::vmd_pick_atom write toolBar::atomPickedDihed
    mouse mode rotate
    
    set molExists [mol list]
    if {$molExists == "ERROR) No molecules loaded."} {
    } else {
        mol modselect 9 top "none"
    }

    toolBar::revertInitialStructure
    destroy $::toolBar::dihedModif
}
##############################################################################

#### GUI ############################################################
proc toolBar::guiAngleModif {} {

	#### Check if the window exists
	if {[winfo exists $::toolBar::angleModif]} {wm deiconify $::toolBar::angleModif ;return $::toolBar::angleModif}
	toplevel $::toolBar::angleModif
	wm attributes $::toolBar::angleModif -topmost yes

	#### Title of the windows
	wm title $toolBar::angleModif "Angle Editor" ;# titulo da pagina

	#### Change the location of window
	# screen width and height
	set sWidth [expr [winfo vrootwidth  $::toolBar::angleModif] -0]
	set sHeight [expr [winfo vrootheight $::toolBar::angleModif] -50]

	#### Change the location of window
    wm geometry $::toolBar::angleModif 400x260+[expr $sWidth - 400]+100
	$::toolBar::angleModif configure -background {white}
	wm resizable $::toolBar::angleModif 0 0

	wm protocol $::toolBar::angleModif WM_DELETE_WINDOW {toolBar::bondGuiCloseSave}

	

    #### Information
	pack [ttk::frame $toolBar::angleModif.frame0]
	pack [canvas $toolBar::angleModif.frame0.frame -bg white -width 400 -height 260 -highlightthickness 0] -in $toolBar::angleModif.frame0 
        
    place [label $toolBar::angleModif.frame0.frame.title \
		    -text {Three atoms were selected. You can adjust the angle.} \
		    ] -in $toolBar::angleModif.frame0.frame -x 10 -y 10 -width 380

    place [label $toolBar::angleModif.frame0.frame.atom1 \
		    -text {Atom 1:} \
		    ] -in $toolBar::angleModif.frame0.frame -x 10 -y 30 -width 60       

    place [entry $toolBar::angleModif.frame0.frame.atom1Index \
		        -textvariable {toolBar::atom1AngleSel} \
				-state readonly \
		        ] -in $toolBar::angleModif.frame0.frame -x 60 -y 30 -width 100

    place [label $toolBar::angleModif.frame0.frame.atom1OptionsLabel \
		        -text {Options: } \
		        ] -in $toolBar::angleModif.frame0.frame -x 190 -y 30 -width 50
    
    variable atom1AngleOpt "Fixed Atom"
    place [ttk::combobox $toolBar::angleModif.frame0.frame.atom1Options \
		        -textvariable {toolBar::atom1AngleOpt} \
			    -state readonly \
		        -values "[list "Fixed Atom" "Move Atom" "Move Atoms" "Custom"]"
		        ] -in $toolBar::angleModif.frame0.frame -x 250 -y 30 -width 140

        
    place [label $toolBar::angleModif.frame0.frame.atom2 \
		    -text {Atom 2:} \
		    ] -in $toolBar::angleModif.frame0.frame -x 10 -y 60 -width 60

    place [entry $toolBar::angleModif.frame0.frame.atom2Index \
		        -textvariable {toolBar::atom2AngleSel} \
				-state readonly \
		        ] -in $toolBar::angleModif.frame0.frame -x 60 -y 60 -width 100


    place [label $toolBar::angleModif.frame0.frame.atom3 \
		    -text {Atom 3:} \
		    ] -in $toolBar::angleModif.frame0.frame -x 10 -y 90 -width 60

    place [entry $toolBar::angleModif.frame0.frame.atom3Index \
		        -textvariable {toolBar::atom3AngleSel} \
				-state readonly \
		        ] -in $toolBar::angleModif.frame0.frame -x 60 -y 90 -width 100

    place [label $toolBar::angleModif.frame0.frame.atom3OptionsLabel \
		        -text {Options: } \
		        ] -in $toolBar::angleModif.frame0.frame -x 190 -y 90 -width 50
    
    variable atom3AngleOpt "Move Atom"
    place [ttk::combobox $toolBar::angleModif.frame0.frame.atom3Options \
		        -textvariable {toolBar::atom3AngleOpt} \
			    -state readonly \
		        -values "[list "Fixed Atom" "Move Atom" "Move Atoms" "Custom"]"
		        ] -in $toolBar::angleModif.frame0.frame -x 250 -y 90 -width 140


	place [label $toolBar::angleModif.frame0.frame.customAtom1 \
		    -text "Custom Selection (Atom 1):" \
		    ] -in $toolBar::angleModif.frame0.frame -x 10 -y 120 -width 180

    variable customSelection1 "none"
	place [entry $toolBar::angleModif.frame0.frame.customAtom1Entry \
		        -textvariable {toolBar::customSelection1} \
				-state disabled \
		        ] -in $toolBar::angleModif.frame0.frame -x 200 -y 120 -width 190

	place [label $toolBar::angleModif.frame0.frame.customAtom2 \
		    -text "Custom Selection (Atom 2):" \
		    ] -in $toolBar::angleModif.frame0.frame -x 10 -y 150 -width 180

    variable customSelection2 "none"
	place [entry $toolBar::angleModif.frame0.frame.customAtom2Entry \
		        -textvariable {toolBar::customSelection2} \
				-state disabled \
		        ] -in $toolBar::angleModif.frame0.frame -x 200 -y 150 -width 190

	place [scale $toolBar::angleModif.frame0.frame.scaleBondDistance \
				-length 280 \
				-from {-180.00} \
				-to 180.00 \
				-resolution 0.01 \
				-variable {toolBar::AngleValue} \
				-command {toolBar::calcAngleDistance} \
				-orient horizontal \
				-showvalue 0 \
			] -in $toolBar::angleModif.frame0.frame -x 10 -y 180 -width 380


    place [label $toolBar::angleModif.frame0.frame.distanceLabel \
				-text {Angle (°): } \
		        ] -in $toolBar::angleModif.frame0.frame -x 10 -y 213 -width 60

    place [spinbox $toolBar::angleModif.frame0.frame.distance \
					-from {-180.00} \
					-to {180.00} \
					-increment 0.01 \
					-textvariable {toolBar::AngleValue} \
					-command {toolBar::calcAngleDistance $toolBar::AngleValue} \
                    ] -in $toolBar::angleModif.frame0.frame -x 80 -y 210 -width 100
                
    place [button $toolBar::angleModif.frame0.frame.apply \
		            -text "Apply" \
		            -command {toolBar::angleGuiCloseSave} \
		            ] -in $toolBar::angleModif.frame0.frame -x 230 -y 210 -width 75
				
	place [button $toolBar::angleModif.frame0.frame.cancel \
		            -text "Cancel" \
		            -command {toolBar::angleGuiCloseNotSave} \
		            ] -in $toolBar::angleModif.frame0.frame -x 315 -y 210 -width 75


	bind $toolBar::angleModif.frame0.frame.distance <KeyPress> {toolBar::calcAngleDistance $toolBar::AngleValue}
	bind $toolBar::angleModif.frame0.frame.distance <Leave> {toolBar::calcAngleDistance $toolBar::AngleValue}

	# Custom - Enable Entry
	bind $toolBar::angleModif.frame0.frame.atom1Options <<ComboboxSelected>> {
		if {$toolBar::atom1AngleOpt == "Custom"} {
			$toolBar::angleModif.frame0.frame.customAtom1Entry configure -state normal
		} else {
			$toolBar::angleModif.frame0.frame.customAtom1Entry configure -state disabled
		}
	}
	bind $toolBar::angleModif.frame0.frame.atom3Options <<ComboboxSelected>> {
		if {$toolBar::atom3AngleOpt == "Custom"} {
			$toolBar::angleModif.frame0.frame.customAtom2Entry configure -state normal
		} else {
			$toolBar::angleModif.frame0.frame.customAtom2Entry configure -state disabled
		}
	}
	if {$toolBar::atom1AngleOpt == "Custom"} {
		$toolBar::angleModif.frame0.frame.customAtom1Entry configure -state normal
	} else {
		$toolBar::angleModif.frame0.frame.customAtom1Entry configure -state disabled
		set toolBar::customSelection1 ""
	}

	if {$toolBar::atom3AngleOpt == "Custom"} {
		$toolBar::angleModif.frame0.frame.customAtom2Entry configure -state normal
	} else {
		$toolBar::angleModif.frame0.frame.customAtom2Entry configure -state disabled
		set toolBar::customSelection2 ""
	}

}

#### GUI ############################################################
proc toolBar::guiBondModif {} {

	#### Check if the window exists
	if {[winfo exists $::toolBar::bondModif]} {wm deiconify $::toolBar::bondModif ;return $::toolBar::bondModif}
	toplevel $::toolBar::bondModif
	wm attributes $::toolBar::bondModif -topmost yes

	#### Title of the windows
	wm title $toolBar::bondModif "Bond Editor" ;# titulo da pagina

	#### Change the location of window
	# screen width and height
	set sWidth [expr [winfo vrootwidth  $::toolBar::bondModif] -0]
	set sHeight [expr [winfo vrootheight $::toolBar::bondModif] -50]

	#### Change the location of window
    wm geometry $::toolBar::bondModif 400x220+[expr $sWidth - 400]+100
	$::toolBar::bondModif configure -background {white}
	wm resizable $::toolBar::bondModif 0 0

	wm protocol $::toolBar::bondModif WM_DELETE_WINDOW {toolBar::bondGuiCloseSave}

	

    #### Information
	pack [ttk::frame $toolBar::bondModif.frame0]
	pack [canvas $toolBar::bondModif.frame0.frame -bg white -width 400 -height 220 -highlightthickness 0] -in $toolBar::bondModif.frame0 
        
    place [label $toolBar::bondModif.frame0.frame.title \
		    -text {Two atoms were selected. You can adjust the bond distance.} \
		    ] -in $toolBar::bondModif.frame0.frame -x 10 -y 10 -width 380

    place [label $toolBar::bondModif.frame0.frame.atom1 \
		    -text {Atom 1:} \
		    ] -in $toolBar::bondModif.frame0.frame -x 10 -y 30 -width 60

    place [entry $toolBar::bondModif.frame0.frame.atom1Index \
		        -textvariable {toolBar::atom1BondSel} \
				-state readonly \
		        ] -in $toolBar::bondModif.frame0.frame -x 60 -y 30 -width 100

    place [label $toolBar::bondModif.frame0.frame.atom1OptionsLabel \
		        -text {Options: } \
		        ] -in $toolBar::bondModif.frame0.frame -x 190 -y 30 -width 50
    
    variable atom1BondOpt "Fixed Atom"
    place [ttk::combobox $toolBar::bondModif.frame0.frame.atom1Options \
		        -textvariable {toolBar::atom1BondOpt} \
			    -state readonly \
		        -values "[list "Fixed Atom" "Move Atom" "Move Atoms" "Custom"]"
		        ] -in $toolBar::bondModif.frame0.frame -x 250 -y 30 -width 140

        
    place [label $toolBar::bondModif.frame0.frame.atom2 \
		    -text {Atom 2:} \
		    ] -in $toolBar::bondModif.frame0.frame -x 10 -y 60 -width 60

    place [entry $toolBar::bondModif.frame0.frame.atom2Index \
		        -textvariable {toolBar::atom2BondSel} \
				-state readonly \
		        ] -in $toolBar::bondModif.frame0.frame -x 60 -y 60 -width 100

    place [label $toolBar::bondModif.frame0.frame.atom2OptionsLabel \
		        -text {Options: } \
		        ] -in $toolBar::bondModif.frame0.frame -x 190 -y 60 -width 50
    
    variable atom2BondOpt "Move Atom"
    place [ttk::combobox $toolBar::bondModif.frame0.frame.atom2Options \
		        -textvariable {toolBar::atom2BondOpt} \
			    -state readonly \
		        -values "[list "Fixed Atom" "Move Atom" "Move Atoms" "Custom"]"
		        ] -in $toolBar::bondModif.frame0.frame -x 250 -y 60 -width 140

	place [label $toolBar::bondModif.frame0.frame.customAtom1 \
		    -text "Custom Selection (Atom 1):" \
		    ] -in $toolBar::bondModif.frame0.frame -x 10 -y 90 -width 180

    variable customSelection1 "none"
	place [entry $toolBar::bondModif.frame0.frame.customAtom1Entry \
		        -textvariable {toolBar::customSelection1} \
				-state disabled \
		        ] -in $toolBar::bondModif.frame0.frame -x 200 -y 90 -width 190

	place [label $toolBar::bondModif.frame0.frame.customAtom2 \
		    -text "Custom Selection (Atom 2):" \
		    ] -in $toolBar::bondModif.frame0.frame -x 10 -y 120 -width 180

    variable customSelection2 "none"
	place [entry $toolBar::bondModif.frame0.frame.customAtom2Entry \
		        -textvariable {toolBar::customSelection2} \
				-state disabled \
		        ] -in $toolBar::bondModif.frame0.frame -x 200 -y 120 -width 190

	place [scale $toolBar::bondModif.frame0.frame.scaleBondDistance \
				-length 280 \
				-from 0.01 \
				-to 100.00 \
				-resolution 0.01 \
				-variable {toolBar::BondDistance} \
				-command {toolBar::calcBondDistance} \
				-orient horizontal \
				-showvalue 0 \
			] -in $toolBar::bondModif.frame0.frame -x 10 -y 150 -width 380


    place [label $toolBar::bondModif.frame0.frame.distanceLabel \
				-text {Bond (A): } \
		        ] -in $toolBar::bondModif.frame0.frame -x 10 -y 183 -width 60

    place [spinbox $toolBar::bondModif.frame0.frame.distance \
					-from 0.01 \
					-to 15.00 \
					-increment 0.01 \
					-textvariable {toolBar::BondDistance} \
					-command {toolBar::calcBondDistance $toolBar::BondDistance} \
                ] -in $toolBar::bondModif.frame0.frame -x 80 -y 180 -width 100
                
    place [button $toolBar::bondModif.frame0.frame.apply \
		            -text "Apply" \
		            -command {toolBar::bondGuiCloseSave} \
		            ] -in $toolBar::bondModif.frame0.frame -x 230 -y 180 -width 75
				
	place [button $toolBar::bondModif.frame0.frame.cancel \
		            -text "Cancel" \
		            -command {toolBar::bondGuiCloseNotSave} \
		            ] -in $toolBar::bondModif.frame0.frame -x 315 -y 180 -width 75


	bind $toolBar::bondModif.frame0.frame.distance <KeyPress> {toolBar::calcBondDistance $toolBar::BondDistance}
	bind $toolBar::bondModif.frame0.frame.distance <Leave> {toolBar::calcBondDistance $toolBar::BondDistance}

	# Custom - Enable Entry
	bind $toolBar::bondModif.frame0.frame.atom1Options <<ComboboxSelected>> {
		if {$toolBar::atom1BondOpt == "Custom"} {
			$toolBar::bondModif.frame0.frame.customAtom1Entry configure -state normal
		} else {
			$toolBar::bondModif.frame0.frame.customAtom1Entry configure -state disabled
		}
	}
	bind $toolBar::bondModif.frame0.frame.atom2Options <<ComboboxSelected>> {
		if {$toolBar::atom2BondOpt == "Custom"} {
			$toolBar::bondModif.frame0.frame.customAtom2Entry configure -state normal
		} else {
			$toolBar::bondModif.frame0.frame.customAtom2Entry configure -state disabled
		}
	}
	if {$toolBar::atom1BondOpt == "Custom"} {
		$toolBar::bondModif.frame0.frame.customAtom1Entry configure -state normal
	} else {
		$toolBar::bondModif.frame0.frame.customAtom1Entry configure -state disabled
		set toolBar::customSelection1 ""
	}

	if {$toolBar::atom2BondOpt == "Custom"} {
		$toolBar::bondModif.frame0.frame.customAtom2Entry configure -state normal
	} else {
		$toolBar::bondModif.frame0.frame.customAtom2Entry configure -state disabled
		set toolBar::customSelection2 ""
	}

}

#### GUI ############################################################
proc toolBar::guiDihedModif {} {

	#### Check if the window exists
	if {[winfo exists $::toolBar::dihedModif]} {wm deiconify $::toolBar::dihedModif ;return $::toolBar::dihedModif}
	toplevel $::toolBar::dihedModif
	wm attributes $::toolBar::dihedModif -topmost yes

	#### Title of the windows
	wm title $toolBar::dihedModif "Dihedral Angle Editor" ;# titulo da pagina

	#### Change the location of window
	# screen width and height
	set sWidth [expr [winfo vrootwidth  $::toolBar::dihedModif] -0]
	set sHeight [expr [winfo vrootheight $::toolBar::dihedModif] -50]

	#### Change the location of window
    wm geometry $::toolBar::dihedModif 400x260+[expr $sWidth - 400]+100
	$::toolBar::dihedModif configure -background {white}
	wm resizable $::toolBar::dihedModif 0 0

	wm protocol $::toolBar::dihedModif WM_DELETE_WINDOW {toolBar::bondGuiCloseSave}

	

    #### Information
    pack [ttk::frame $toolBar::dihedModif.frame0]
	pack [canvas $toolBar::dihedModif.frame0.frame -bg white -width 400 -height 260 -highlightthickness 0] -in $toolBar::dihedModif.frame0 
        
    place [label $toolBar::dihedModif.frame0.frame.title \
		    -text {Four atoms were selected.} \
		    ] -in $toolBar::dihedModif.frame0.frame -x 10 -y 10 -width 380

    place [label $toolBar::dihedModif.frame0.frame.atom1 \
		    -text {Atom 1:} \
		    ] -in $toolBar::dihedModif.frame0.frame -x 10 -y 30 -width 60 

    place [entry $toolBar::dihedModif.frame0.frame.atom1Index \
		        -textvariable {toolBar::atom1DihedSel} \
				-state readonly \
		        ] -in $toolBar::dihedModif.frame0.frame -x 60 -y 30 -width 100

    place [label $toolBar::dihedModif.frame0.frame.atom1OptionsLabel \
		        -text {Options: } \
		        ] -in $toolBar::dihedModif.frame0.frame -x 190 -y 30 -width 50
    
    variable atom1DihedOpt "Fixed Atom"
    place [ttk::combobox $toolBar::dihedModif.frame0.frame.atom1Options \
		        -textvariable {toolBar::atom1DihedOpt} \
			    -state readonly \
		        -values "[list "Fixed Atom" "Move Atom" "Move Atoms" "Custom"]"
		        ] -in $toolBar::dihedModif.frame0.frame -x 250 -y 30 -width 140

        
    place [label $toolBar::dihedModif.frame0.frame.atom2 \
		    -text {Bond between atom} \
		    ] -in $toolBar::dihedModif.frame0.frame -x 10 -y 60 -width 110

    place [entry $toolBar::dihedModif.frame0.frame.atom2Index \
		        -textvariable {toolBar::atom2DihedSel} \
				-state readonly \
		        ] -in $toolBar::dihedModif.frame0.frame -x 130 -y 60 -width 100

	place [label $toolBar::dihedModif.frame0.frame.andLabel \
		    -text {and} \
		    ] -in $toolBar::dihedModif.frame0.frame -x 240 -y 60 -width 40

    place [entry $toolBar::dihedModif.frame0.frame.atom3Index \
		        -textvariable {toolBar::atom3DihedSel} \
				-state readonly \
		        ] -in $toolBar::dihedModif.frame0.frame -x 290 -y 60 -width 100


    place [label $toolBar::dihedModif.frame0.frame.atom4 \
		    -text {Atom 4:} \
		    ] -in $toolBar::dihedModif.frame0.frame -x 10 -y 90 -width 60

    place [entry $toolBar::dihedModif.frame0.frame.atom4Index \
		        -textvariable {toolBar::atom4DihedSel} \
				-state readonly \
		        ] -in $toolBar::dihedModif.frame0.frame -x 60 -y 90 -width 100

    place [label $toolBar::dihedModif.frame0.frame.atom4OptionsLabel \
		        -text {Options: } \
		        ] -in $toolBar::dihedModif.frame0.frame -x 190 -y 90 -width 50

    variable atom4DihedOpt "Move Atom"
    place [ttk::combobox $toolBar::dihedModif.frame0.frame.atom4Options \
		        -textvariable {toolBar::atom4DihedOpt} \
			    -state readonly \
		        -values "[list "Fixed Atom" "Move Atom" "Move Atoms" "Custom"]"
		        ] -in $toolBar::dihedModif.frame0.frame -x 250 -y 90 -width 140

	place [label $toolBar::dihedModif.frame0.frame.customAtom1 \
		    -text "Custom Selection (Atom 1):" \
		    ] -in $toolBar::dihedModif.frame0.frame -x 10 -y 120 -width 180

    variable customSelection1 "none"
	place [entry $toolBar::dihedModif.frame0.frame.customAtom1Entry \
		        -textvariable {toolBar::customSelection1} \
				-state disabled \
		        ] -in $toolBar::dihedModif.frame0.frame -x 200 -y 120 -width 190

	place [label $toolBar::dihedModif.frame0.frame.customAtom2 \
		    -text "Custom Selection (Atom 2):" \
		    ] -in $toolBar::dihedModif.frame0.frame -x 10 -y 150 -width 180

    variable customSelection2 "none"
	place [entry $toolBar::dihedModif.frame0.frame.customAtom2Entry \
		        -textvariable {toolBar::customSelection2} \
				-state disabled \
		        ] -in $toolBar::dihedModif.frame0.frame -x 200 -y 150 -width 190

	place [scale $toolBar::dihedModif.frame0.frame.scaleBondDistance \
				-length 280 \
				-from {-180.00} \
				-to 180.00 \
				-resolution 0.01 \
				-variable {toolBar::DihedValue} \
				-command {toolBar::calcDihedDistance} \
				-orient horizontal \
				-showvalue 0 \
			] -in $toolBar::dihedModif.frame0.frame -x 10 -y 180 -width 380


    place [label $toolBar::dihedModif.frame0.frame.distanceLabel \
				-text {Dihedral (°): } \
		        ] -in $toolBar::dihedModif.frame0.frame -x 10 -y 213 -width 60

    place [spinbox $toolBar::dihedModif.frame0.frame.distance \
					-from {-180.00} \
					-to {180.00} \
					-increment 0.01 \
					-textvariable {toolBar::DihedValue} \
					-command {toolBar::calcDihedDistance $toolBar::DihedValue} \
                    ] -in $toolBar::dihedModif.frame0.frame -x 80 -y 210 -width 100
                
    place [button $toolBar::dihedModif.frame0.frame.apply \
		            -text "Apply" \
		            -command {toolBar::dihedGuiCloseSave} \
		            ] -in $toolBar::dihedModif.frame0.frame -x 230 -y 210 -width 75
				
	place [button $toolBar::dihedModif.frame0.frame.cancel \
		            -text "Cancel" \
		            -command {toolBar::dihedGuiCloseNotSave} \
		            ] -in $toolBar::dihedModif.frame0.frame -x 315 -y 210 -width 75


	bind $toolBar::dihedModif.frame0.frame.distance <KeyPress> {toolBar::calcDihedDistance $toolBar::DihedValue}
	bind $toolBar::dihedModif.frame0.frame.distance <Leave> {toolBar::calcDihedDistance $toolBar::DihedValue}

	# Custom - Enable Entry
	bind $toolBar::dihedModif.frame0.frame.atom1Options <<ComboboxSelected>> {
		if {$toolBar::atom1DihedOpt == "Custom"} {
			$toolBar::dihedModif.frame0.frame.customAtom1Entry configure -state normal
		} else {
			$toolBar::dihedModif.frame0.frame.customAtom1Entry configure -state disabled
		}
	}
	bind $toolBar::dihedModif.frame0.frame.atom4Options <<ComboboxSelected>> {
		if {$toolBar::atom4DihedOpt == "Custom"} {
			$toolBar::dihedModif.frame0.frame.customAtom2Entry configure -state normal
		} else {
			$toolBar::dihedModif.frame0.frame.customAtom2Entry configure -state disabled
		}
	}
	if {$toolBar::atom1DihedOpt == "Custom"} {
		$toolBar::dihedModif.frame0.frame.customAtom1Entry configure -state normal
	} else {
		$toolBar::dihedModif.frame0.frame.customAtom1Entry configure -state disabled
		set toolBar::customSelection1 ""
	}

	if {$toolBar::atom4DihedOpt == "Custom"} {
		$toolBar::dihedModif.frame0.frame.customAtom2Entry configure -state normal
	} else {
		$toolBar::dihedModif.frame0.frame.customAtom2Entry configure -state disabled
		set toolBar::customSelection2 ""
	}

}