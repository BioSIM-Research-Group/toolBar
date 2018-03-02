package provide selectionManager 1.0

#
# SelectionViewer v1.0
#
# GUI to create atom selection in VMD.
#
# (c) 2017 by Nuno M. F. Sousa A. Cerqueira <nscerqueira@gmail.com> or <nscerque@fc.up.pt> and Henrique S. Fernandes <henrique.fernandes@fc.up.pt> or <henriquefer11@gmail.com>
#
###########################################################################################
#
# create package and namespace and default all namespace global variables.




#### START GUI
proc toolBar::selV {} {
	toplevel $toolBar::selVGui
	
	#### Title of the windows
	wm title $toolBar::selVGui "Tool Bar $toolBar::version" ;# titulo da pagina

    # screen width and height
    set sWidth  [winfo vrootwidth  $toolBar::selVGui]
    set sHeight [expr [winfo vrootheight $toolBar::selVGui] - 200]

    #window wifth and height
    set wWidth  [winfo reqwidth $toolBar::selVGui]
    set wHeight [winfo reqheight $toolBar::selVGui]

    #wm geometry window $VBox::selVGui 40x59 0
    wm geometry $toolBar::selVGui 300x${sHeight}+[expr $sWidth - 310]+25


    #### FRAME 0
    grid [ttk::frame $toolBar::selVGui.frame0 -style frame.TFrame] -row 0 -column 0 -padx 1 -pady 1 -sticky news
       	grid [ttk::label $toolBar::selVGui.frame0.l1 \
           -text "Molecule ID:" \
           ] -in $toolBar::selVGui.frame0 -row 0 -column 0 -sticky nsew 
    grid [ttk::combobox $toolBar::selVGui.frame0.cb1 \
         -values $toolBar::layers \
         -postcommand toolBar::PDBList \
         -state readonly \
         ] -in $toolBar::selVGui.frame0 -row 0 -column 1 -sticky ew

		# label     
		grid [ttk::label $toolBar::selVGui.frame0.lb \
            -text "Selection Tree" \
            -anchor center \
            ] -in $toolBar::selVGui.frame0 -row 1 -column 0 -sticky news -columnspan 2


	#### FRAME 1 - Paned Window

	grid [ttk::panedwindow $toolBar::selVGui.frame1 -orient vertical] -row 1 -column 0 -padx 2 -pady 1 -sticky news


        # ttk::frame
        $toolBar::selVGui.frame1 add [ttk::frame $toolBar::selVGui.frame1.frame10] -weight 2 

            #frame 1
            grid [ttk::frame $toolBar::selVGui.frame1.frame10.f0] -in $toolBar::selVGui.frame1.frame10 -row 0 -column 0 -sticky news



		    #treeView
		    grid [ttk::treeview $toolBar::selVGui.frame1.frame10.f0.tree -show tree -height 18 -yscroll "$toolBar::selVGui.frame1.frame10.f0.vsb set" ] -in $toolBar::selVGui.frame1.frame10.f0 -row 0 -column 0 -sticky news 
		
		
            grid [ttk::scrollbar $toolBar::selVGui.frame1.frame10.f0.vsb -orient vertical -command "$toolBar::selVGui.frame1.frame10.f0.tree yview"] -in $toolBar::selVGui.frame1.frame10.f0 -row 0 -column 1  -sticky ns 
 

            #frame 2
            grid [ttk::frame $toolBar::selVGui.frame1.frame10.f1] -in $toolBar::selVGui.frame1.frame10 -row 1 -column 0 -sticky we 

                # label     
                grid [ttk::label $toolBar::selVGui.frame1.frame10.f1.lb1 -text "Atom Selection"] -in $toolBar::selVGui.frame1.frame10.f1 -row 0 -column 0 -columnspan 3

                # entry
                ttk::style layout entry {
                  Plain.Entry.field -sticky nswe -children {
                      Plain.Entry.padding -sticky nswe -children {
                          Plain.Entry.textarea -sticky nswe
                      }
                  }
                }

                variable customSelection ""
                grid [ttk::entry $toolBar::selVGui.frame1.frame10.f1.en1 -style entry -textvariable toolBar::customSelection -validate all -validatecommand {toolBar::entrySelection %P 0;toolBar::autocomplete %W %d %v %P $toolBar::VMDKeywords}] -in $toolBar::selVGui.frame1.frame10.f1 -row 1 -column 0 -sticky ew  -columnspan 3
            
               

            #button
            grid [ttk::button $toolBar::selVGui.frame1.frame10.f1.bt1 -width 3 -text "Add" -command {toolBar::addSelection}] -in $toolBar::selVGui.frame1.frame10.f1 -row 2 -column 1
            grid [ttk::button $toolBar::selVGui.frame1.frame10.f1.bt2 -width 5 -text "Apply" -command {toolBar::updateSelection} -state disabled] -in $toolBar::selVGui.frame1.frame10.f1 -row 2 -column 2 

            grid columnconfigure $toolBar::selVGui.frame1.frame10.f1                      0 -weight 8


        # frame
        $toolBar::selVGui.frame1 add [ttk::frame $toolBar::selVGui.frame1.frame11] 
            
            # Label
            grid [ttk::label $toolBar::selVGui.frame1.frame11.l1 -text "Representations"] -in $toolBar::selVGui.frame1.frame11 -row 0 -column 0 

		    #LISTBox
		    grid [tablelist::tablelist $toolBar::selVGui.frame1.frame11.lb1 \
			    -showeditcursor true \
			    -columns {0 "#" center 0 "" center 0 "Atom Selections" center} \
			    -stretch 2 \
			    -background white \
			    -yscrollcommand [list $toolBar::selVGui.frame1.frame11.vsb set] \
			    -xscrollcommand [list $toolBar::selVGui.frame1.frame11.hsb set] \
                -editendcommand toolBar::showOrHideRep \
			    -height 14 \
			    -state normal \
			    -borderwidth 0 \
			    -relief flat \
                -selectmode single \
                ]  -in $toolBar::selVGui.frame1.frame11 -row 1 -column 0 -padx 2 -sticky news

            grid [ttk::scrollbar $toolBar::selVGui.frame1.frame11.vsb -orient vertical -command "$toolBar::selVGui.frame1.frame11.lb1 yview"] -in $toolBar::selVGui.frame1.frame11 -row 1 -column 1  -sticky ns 
            grid [ttk::scrollbar $toolBar::selVGui.frame1.frame11.hsb -orient horizontal -command "$toolBar::selVGui.frame1.frame11.lb1 xview"] -in $toolBar::selVGui.frame1.frame11 -row 2 -column 0  -sticky ew 

            $toolBar::selVGui.frame1.frame11.lb1 configcolumns 2 -editable false 0 -foreground black 2 -foreground black 0 -width 1 2 -align left
            $toolBar::selVGui.frame1.frame11.lb1 configcolumns 1 -font {"Lucida Console" -12 bold}

    #### FRAME 3

    #### FRAME 4
    ## Set variables related to the list of option to edit the representantion
    variable colorMethodList {"Name" "Type" "Element" "ResName" "ResType" "ResID" "Chain" "SegName" "Conformation" "Molecule" "Secondary Structure" "Beta" "Occupancy" "Mass" "Charge" "Fragment" "Index" "Backbone" "Throb" "Volume" "ColorID 0 Blue" "ColorID 1 Red" "ColorID 2 Gray" "ColorID 3 Orange" "ColorID 4 Yellow" "ColorID 5 Tan" "ColorID 6 Silver" "ColorID 7 Green" "ColorID 8 White" "ColorID 9 Pink" "ColorID 10 Cyan" "ColorID 11 Purple" "ColorID 12 Lime" "ColorID 13 Mauve" "ColorID 14 Ochre" "ColorID 15 IceBlue" "ColorID 16 Black" "ColorID 17 Yellow2" "ColorID 18 Yellow3" "ColorID 19 Green2" "ColorID 20 Green3" "ColorID 21 Cyan2" "ColorID 22 Cyan3" "ColorID 23 Blue2" "ColorID 24 Blue3" "ColorID 25 Violet" "ColorID 26 Violet2" "ColorID 27 Magenta" "ColorID 28 Magenta2" "ColorID 29 Red2" "ColorID 30 Red3" "ColorID 31 Orange2" "ColorID 32 Orange3"}
    variable materialList [material list]
    variable drawMethodList {"Lines" "Bonds" "DynamicBonds" "HBonds" "Points" "VDW" "CPK" "Licorice" "Polyhedra" "Trace" "Tube" "Ribbons" "NewRibbons" "Cartoon" "NewCartoon" "PaperChain" "Twister" "QuickSurf" "MSMS" "NanoShaper" "Surf" "VolumeSlice" "Isosurface" "FieldLines" "Orbital" "Beads" "Dotted" "Solvent"}

    ## Get selection ID
    variable selectionID [lindex [$toolBar::selVGui.frame1.frame11.lb1 get active] 0]

    #variable selectionEditor [string trim [molinfo top get "{selection $toolBar::selectionID}"] "{}"]
    variable curColor "Name"
    variable curDraw "Lines"
    variable curMaterial "Opaque"



    grid [ttk::frame $toolBar::selVGui.frame4] -row 3 -column 0 -pady 0 -sticky news
    
        ## Selection editor


        ## Change representantion style
        grid [ttk::label $toolBar::selVGui.frame4.title -text "Draw Syle"] -in $toolBar::selVGui.frame4 -row 0 -column 0 -columnspan 2
        
        grid [ttk::label $toolBar::selVGui.frame4.drawMethodLabel -text "Drawing Method: "] -in $toolBar::selVGui.frame4 -row 1 -column 0 -sticky news
        grid [ttk::combobox $toolBar::selVGui.frame4.drawMethod -state readonly -values $toolBar::drawMethodList -textvariable toolBar::curDraw] -in $toolBar::selVGui.frame4 -row 1 -column 1 -sticky ew

        grid [ttk::label $toolBar::selVGui.frame4.coloringMethodLabel -text "Coloring Method: "] -in $toolBar::selVGui.frame4 -row 2 -column 0 -sticky news
        grid [ttk::combobox $toolBar::selVGui.frame4.coloringMethod -state readonly -values $toolBar::colorMethodList -textvariable toolBar::curColor] -in $toolBar::selVGui.frame4 -row 2 -column 1 -sticky news

        #grid [ttk::label $toolBar::selVGui.frame4.materialLabel -text "Material: "] -in $toolBar::selVGui.frame4 -row 3 -column 0 -sticky news
        #grid [ttk::combobox $toolBar::selVGui.frame4.material -state readonly -values $toolBar::materialList -textvariable toolBar::curMaterial] -in $toolBar::selVGui.frame4 -row 3 -column 1 -sticky news

        ##Commands
        bind $toolBar::selVGui.frame4.coloringMethod <<ComboboxSelected>> "toolBar::validateSelectionEditor"
        bind $toolBar::selVGui.frame4.drawMethod <<ComboboxSelected>> "toolBar::validateSelectionEditor"
 


	#### FRAME 5
	grid [ttk::frame $toolBar::selVGui.frame5] -row 4 -column 0 -sticky news

		# Button
    
	    #grid [ttk::menubutton $toolBar::selVGui.frame5.bt1 -text "Tools" -menu $toolBar::selVGui.frame5.bt1.menu] -in $toolBar::selVGui.frame5 -row 0 -column 1
        grid [ttk::button $toolBar::selVGui.frame5.bt2 -text "Help" -command {toolBar::help}] -in $toolBar::selVGui.frame5 -row 0 -column 2
        grid [ttk::button $toolBar::selVGui.frame5.bt3 -text "Options" -width 8 -command {toolBar::optionsWindow}] -in $toolBar::selVGui.frame5 -row 0 -column 3
       # grid [ttk::button $toolBar::selVGui.frame5.bt4 -text "Exit" -width 6 -command {toolBar::exit}] -in $toolBar::selVGui.frame5 -row 0 -column 3

		#menu $toolBar::selVGui.frame5.bt1.menu -tearoff 0
		#$toolBar::selVGui.frame5.bt1.menu add command -label "Reset view" -command {display resetview}
		#$toolBar::selVGui.frame5.bt1.menu add command -label "Center atom" -command {mouse mode center}
		#$toolBar::selVGui.frame5.bt1.menu add command -label "Bond, Angle, Dihedrals" -command {toolBar::badParams}
		#$toolBar::selVGui.frame5.bt1.menu add command -label "Delete all labels" -command {toolBar::deleteAllLabels}
		#$toolBar::selVGui.frame5.bt1.menu add command -label "Delete all graphics" -command {graphics 0 delete all}
        



   	#### GUI weight
  	grid columnconfigure $toolBar::selVGui                      0 -weight 1
    grid columnconfigure $toolBar::selVGui.frame0               1 -weight 1
    grid columnconfigure $toolBar::selVGui.frame1.frame10       0 -weight 1
    grid columnconfigure $toolBar::selVGui.frame1.frame11       0 -weight 1
    grid columnconfigure $toolBar::selVGui.frame4               1 -weight 1
    grid columnconfigure $toolBar::selVGui.frame5               0 -weight 1
    grid columnconfigure $toolBar::selVGui.frame1.frame10.f0    0 -weight 1
    grid columnconfigure $toolBar::selVGui.frame1.frame10.f1    1 -weight 1

    grid rowconfigure $toolBar::selVGui                         1 -weight 1

    grid rowconfigure $toolBar::selVGui.frame1.frame10          0 -weight 1
    grid rowconfigure $toolBar::selVGui.frame1.frame10.f0       0 -weight 1

    grid rowconfigure $toolBar::selVGui.frame1.frame11          1 -weight 2
    grid rowconfigure $toolBar::selVGui.frame4                  0 -weight 3


    ### Create the Menu
    menu $toolBar::selVGui.menu -tearoff 0
        $toolBar::selVGui.menu add command -label "Show/Hide" -command {toolBar::clickListBox double}
        $toolBar::selVGui.menu add command -label "Zoom" -command {toolBar::moveToSelection}
        $toolBar::selVGui.menu add command -label "Number of Atoms" -command {toolBar::numberAtoms}
        $toolBar::selVGui.menu add command -label "Delete" -command {toolBar::deleteSelection}

    #### Bindings
    bind $toolBar::selVGui.frame0.cb1 <<ComboboxSelected>> toolBar::selectPDB
    bind $toolBar::selVGui.frame1.frame10.f0.tree <<TreeviewSelect>> {toolBar::treeSelectItem 0}
    set tableListBody [$toolBar::selVGui.frame1.frame11.lb1 bodytag]
    bind $toolBar::selVGui.frame1.frame11.lb1  <<TablelistSelect>> {toolBar::clickListBox single}
    bind $tableListBody <Button-1> {toolBar::hideShow %x %y}
    #bind $tableListBody <Double-1> {toolBar::hideShow %x %y}
    bind $tableListBody <Button-2> {toolBar::rightClickMenu $toolBar::selVGui.menu %x %y} 
    bind $tableListBody <Button-3> {toolBar::rightClickMenu $toolBar::selVGui.menu %x %y}


    # History System
    bind $toolBar::selVGui.frame1.frame10.f1.en1 <Key-Up> {toolBar::readHistory up}
    bind $toolBar::selVGui.frame1.frame10.f1.en1 <Key-Down> {toolBar::readHistory down}

    # tab on entry to complete the text
    bind all <Tab> {break}
    bind $toolBar::selVGui.frame1.frame10.f1.en1 <Tab> {
            set a [$toolBar::selVGui.frame1.frame10.f1.en1 get]
			$toolBar::selVGui.frame1.frame10.f1.en1 delete 0 end
			if {[string index $a end]!=" "} {$toolBar::selVGui.frame1.frame10.f1.en1 insert end "$a "
			} else {$toolBar::selVGui.frame1.frame10.f1.en1 insert end "$a"}
    }
    
	# Add the enter to apply or add changes
	bind $toolBar::selVGui.frame1.frame10.f1.en1 <Return> {
		if {[lindex [$toolBar::selVGui.frame1.frame10.f1.bt2 state] 0] == "active"} {
            toolBar::updateSelection
        } else {
            toolBar::addSelection
        }
	}


    #### Fill ComboBox with PDBs
    toolBar::PDBList

    #### Fill tree with Values
    if {$toolBar::layers!={} } {toolBar::fillTree}



}


#proc toolBar::exit {} {
#	wm withdraw $::toolBar::selVGui
#}

proc toolBar::optionsWindow {} {
    #### Check if the window exists
	if {[winfo exists $toolBar::optionsGui]} {wm deiconify $toolBar::optionsGui; return $toolBar::optionsGui}
	toplevel $toolBar::optionsGui
    wm attributes $toolBar::optionsGui -topmost 1

	#### Title of the windows
	wm title $toolBar::optionsGui "Options" ;# titulo da pagina


    #### Change the location of window
    # screen width and height
    set sWidth  [winfo vrootwidth  $toolBar::optionsGui]
    set sHeight [expr [winfo vrootheight $toolBar::optionsGui] - 80]

    #wm geometry window $VBox::selVGui 40x59 0
    #wm geometry $toolBar::optionsGui 250x125+[expr $sWidth /2]+[expr $sHeight /2]

    #### FRAME 0
    grid [ttk::frame $toolBar::optionsGui.frame0] -row 0 -column 0 -padx 0 -pady 0 -sticky ew
        grid [ttk::checkbutton $toolBar::optionsGui.frame0.checkbt0 -variable toolBar::animationOnOff -text "Enable/Disable Zoom Animation"] -in $toolBar::optionsGui.frame0 -column 0 -row 0 -sticky news -columnspan 3
        grid [ttk::label $toolBar::optionsGui.frame0.l0 -text "Animation duration:"] -in $toolBar::optionsGui.frame0 -column 0 -row 1 -sticky news
        grid [ttk::entry $toolBar::optionsGui.frame0.en0 -textvariable toolBar::animationDuration -width 3 -validate key -validatecommand {string is double %P}] -in $toolBar::optionsGui.frame0 -column 1 -row 1 -sticky news
        grid [ttk::label $toolBar::optionsGui.frame0.l1 -text "seconds"] -in $toolBar::optionsGui.frame0 -column 2 -row 1 -sticky news
        grid [ttk::button $toolBar::optionsGui.frame0.bt0 -text "Apply" -command {destroy $toolBar::optionsGui}] -in $toolBar::optionsGui.frame0 -column 3 -row 1 -sticky news


#### FRAME 1
    grid [ttk::frame $toolBar::optionsGui.frame1] -row 1 -column 0 -padx 0 -pady 0 -sticky news

		grid [ttk::label $toolBar::optionsGui.frame1.l0 -text "________________________________________________\n\n Contact: \n"] -in $toolBar::optionsGui.frame1 -column 0 -row 0 -sticky news
		grid [ttk::label $toolBar::optionsGui.frame1.l1 -text " Nuno M. F. Sousa A. Cerqueira (nscerque@fc.up.pt)"] -in $toolBar::optionsGui.frame1 -column 0 -row 1 -sticky news
		grid [ttk::label $toolBar::optionsGui.frame1.l2 -text " Henrique S. Fernandes (henrique.fernandes@fc.up.pt)"] -in $toolBar::optionsGui.frame1 -column 0 -row 2 -sticky news
		
		grid [ttk::label $toolBar::optionsGui.frame1.l3 -text "\n REQUIMTE, University of Porto - Portugal\n"] -in $toolBar::optionsGui.frame1 -column 0 -row 3 -sticky news
    

#### FRAME 1
    grid [ttk::frame $toolBar::optionsGui.frame2] -row 2 -column 0 -padx 0 -pady 0 -sticky news
		
		grid [ttk::button $toolBar::optionsGui.frame2.bt0 -text "Close" -command {if {[winfo exists $toolBar::optionsGui]} {wm withdraw $toolBar::optionsGui }}] -in $toolBar::optionsGui.frame2 -column 0 -row 0 -sticky news




    grid columnconfigure $toolBar::optionsGui                      0 -weight 1
    grid columnconfigure $toolBar::optionsGui.frame0               1 -weight 1
	grid columnconfigure $toolBar::optionsGui.frame2               0 -weight 1

}

proc toolBar::hideShow {x y} {
    $toolBar::selVGui.frame1.frame11.lb1 selection clear top bottom
    set activecolumn [lindex [split [$toolBar::selVGui.frame1.frame11.lb1 containingcell $x $y] ","] 1]
    set activeLine [expr [lindex [split [$toolBar::selVGui.frame1.frame11.lb1 containingcell $x $y] ","] 0] + 1]

    if {$activecolumn == 1 && $activeLine < [$toolBar::selVGui.frame1.frame11.lb1 size]} {
        $toolBar::selVGui.frame1.frame11.lb1 selection set $activeLine
        toolBar::clickListBox double
    } else {}
    $toolBar::selVGui.frame1.frame11.lb1 selection clear top bottom

}

#### DropMenu
proc toolBar::rightClickMenu {menu x y} {
    $toolBar::selVGui.frame1.frame11.lb1 selection clear top bottom
    set activeLine [expr [lindex [split [$toolBar::selVGui.frame1.frame11.lb1 containingcell $x $y] ","] 0] + 1]
    
    $toolBar::selVGui.frame1.frame11.lb1 selection set $activeLine

    set x [winfo pointerx .]
    set y [winfo pointery .]

    tk_popup $menu $x $y
}



#### HELP GUI
 proc toolBar::help {} {
        set help $toolBar::selVGui.about
	    if {[winfo exists $help]} {wm deiconify $help ; raise $help; return}
        toplevel $help
        wm title $help "Selections Manager Help"

        grid [text $help.tx -width 50 -bg yellow -height 25 -bg white \
                -yscrollcommand "$help.roll set" \
                -wrap word -cursor top_left_arrow] \
                -row 0 -column 0 -sticky news
        grid [scrollbar $help.roll -width 12 \
                -command "$help.tx yview"] -row 0 -column 1 -sticky news
        grid [button $help.close -text "Close" -borderwidth 6 \
                -command {if {[winfo exists $toolBar::selVGui.about]} {wm withdraw $toolBar::selVGui.about }}] -row 1 -column 0 \
                -columnspan 2 -sticky news
        grid rowconfigure    $help 0 -weight 1
        grid columnconfigure $help 0 -weight 1



$toolBar::selVGui.about.tx tag configure keyword -font \
    {-family helvetica -size 10 -weight bold} \
	-foreground red

	$toolBar::selVGui.about.tx tag configure title -font \
	    {-family helvetica -weight bold -size 12} \
		-foreground blue


$toolBar::selVGui.about.tx insert end "VMD has a powerful atom selection language!\n"
$toolBar::selVGui.about.tx insert end "\nIt is based around the assumption that every atom has a set of associated values which can be accessed through keywords."


$toolBar::selVGui.about.tx insert end "\n\nThe SelectionManager plug-in was developed to turn the selection of atoms easier and at the same time allow the user to get in touch with these keywords and learn them."

$toolBar::selVGui.about.tx insert end "\n\nThe SelectionManager also includes a new shell that allows:\n"

$toolBar::selVGui.about.tx insert end "\n   - auto-complete keywords (using the TAB key).\n"

$toolBar::selVGui.about.tx insert end "\n   - history of previous commands (using the Up arrow key).\n"

$toolBar::selVGui.about.tx insert end "\n   - automatically recognizes if the selection has errors or not (if it is shown in red or balck color).\n"

$toolBar::selVGui.about.tx insert end "\n\n Below are given some examples of usefull keywords used in VMD and can be used in the selectionManager plug-in."

$toolBar::selVGui.about.tx insert end "\n\n\n # Standard selections\n" title

$toolBar::selVGui.about.tx insert end "\n\nall" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms"

$toolBar::selVGui.about.tx insert end "\n\nprotein" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms present in a protein macromolecule"

$toolBar::selVGui.about.tx insert end "\n\nwater" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the water atoms"

$toolBar::selVGui.about.tx insert end "\n\nbackbone" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms from the backbone of a protein."

$toolBar::selVGui.about.tx insert end "\n\nresname GLU" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms from the GLU (glutamate) amino acid residue."

$toolBar::selVGui.about.tx insert end "\n\nresid 35" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms from the amino acid reside with the ID 35."

$toolBar::selVGui.about.tx insert end "\n\nname CA" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms with the name CA (carbon alpha)"


$toolBar::selVGui.about.tx insert end "\n\n\n # Composed selections\n" title


$toolBar::selVGui.about.tx insert end "\n\n The VMd keywords can also be combined using the words 'and', 'not' and 'or'. Here are some examples."

$toolBar::selVGui.about.tx insert end "\n\nnot protein" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms that do not belong to proteins"

$toolBar::selVGui.about.tx insert end "\n\nall and not water" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms that are not water moelcules"

$toolBar::selVGui.about.tx insert end "\n\nresname GLU and chain A" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms which belong to GLU (glutamates) and that belong to chain A of the protein"


$toolBar::selVGui.about.tx insert end "\n\n\n # Advanced selections\n" title

$toolBar::selVGui.about.tx insert end "\n\nall within 5 of resid 10" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the atoms that are 5 Angstroms away from resid 10"

$toolBar::selVGui.about.tx insert end "\n\nsame resname as (protein within 5 of resid 10)" keyword
$toolBar::selVGui.about.tx insert end "\nSelect all the residues that are 5 Angstroms away from resid 10"

$toolBar::selVGui.about.tx insert end "\n"
$toolBar::selVGui.about.tx insert end "\n"
 }


#### GET PDBs loaded

proc toolBar::PDBList {} {
    # Add items
    set toolBar::layers ""
    if {[llength [molinfo list]]!=0} {

        # delete old item
        if {$toolBar::selection!=""} {
            ## modify representation if it already exists
            set repid [mol repindex top $toolBar::selection] 
            mol delrep $repid top
        }

        foreach mol [molinfo list] {
            set toolBar::layers [lappend toolBar::layers "[molinfo $mol get id]: [molinfo $mol get name]"]
        }
        # update comboBox values
        $toolBar::selVGui.frame0.cb1 configure -values $toolBar::layers

        # Select the toplayer as the value on the comboBox
        $toolBar::selVGui.frame0.cb1 set "[molinfo [molinfo top] get id]: [molinfo [molinfo top] get name]"

        ## fill the data off rep on the lisbbox
        toolBar::fillListbox
    } else {toolBar::cleanGui}


}

#### FILL TREE LIST with the protein Data
proc toolBar::fillTree {} {

    ## Remove tree values
    $toolBar::selVGui.frame1.frame10.f0.tree delete [ $toolBar::selVGui.frame1.frame10.f0.tree  children {}]

    ## How many chain are
    set chains ""
    set sel [atomselect top "all"]
    set data  [$sel get {chain} ]
    $toolBar::selVGui.frame1.frame10.f0.tree insert {} end -id 0 -text "none"

    foreach chain $data {

        if {[lsearch $chains $chain]==-1} {
            ## Selects Chain
            set chains [lappend chains $chain]
			set count 1
			if {$chain!="X"} {
            $toolBar::selVGui.frame1.frame10.f0.tree insert {} end -id [llength $chains] -text "chain $chain"

			set keywords {protein nucleic "not protein and not water and not nucleic" water}
			set keywordsName {protein nucleic other water}
			
			foreach name $keywords namePrint $keywordsName { 


            	## Adds the resname and resid of the protein part
            	set sel [atomselect top "(chain $chain and $name)"]
            	set residList ""
            	set datalist  [$sel get {resname resid residue type} ]
            	set id 1
            	foreach elem $datalist {
                	incr id
                	if {[lsearch $residList [lindex $elem 1]]==-1} {
                  		if {[llength $residList]==0} {$toolBar::selVGui.frame1.frame10.f0.tree insert [llength $chains] end -id [llength $chains].$count -text "$namePrint"}
                  		set residList [lappend residList [lindex $elem 1]]
                  		$toolBar::selVGui.frame1.frame10.f0.tree insert [llength $chains].$count end -id [llength $chains].$count.$id  -text "[lindex $elem 1] : [lindex $elem 0]"
                  		set id2 $id
                	}
                 		$toolBar::selVGui.frame1.frame10.f0.tree insert [llength $chains].$count.$id2 end -id [llength $chains].$count.$id2.$id  -text "- [lindex $elem 3]"

            	}

			incr count
			}

			} else {

						$toolBar::selVGui.frame1.frame10.f0.tree insert {} end -id [llength $chains] -text "Molecule"
							
						## Adds the resname and resid of the protein part
						set sel [atomselect top "all"]
						set datalist  [$sel get {type} ]
						set id 1
						foreach elem $datalist {
							incr id
							$toolBar::selVGui.frame1.frame10.f0.tree insert [llength $chains] end -id [llength $chains].$id  -text "- $elem"
							incr count
						}
	
			}

			
			}

        }


}
  

proc toolBar::selectPDB {} {

    ## turn the comboBox PDB the topmolecule
    set toolBar::selection ""
    foreach mol [molinfo list] {
        set layer [molinfo $mol get name]
        set layersID [molinfo $mol get id]

        if { [lindex [$toolBar::selVGui.frame0.cb1 get] 1]==$layer} {
                ## delete any previous selection representation before the change
                if {$toolBar::selection!=""} {
                    set repid [mol repindex top $toolBar::selection] 
                    mol delrep $repid top
                }
            mol top $layersID
            break
        }

    }


    ## fill the data on the tree
    toolBar::fillTree 

    ## fill the data off rep on the lisbbox
    toolBar::fillListbox

    ## reset view
    #display resetview
}


proc toolBar::addSelection {} {

    if {[llength [molinfo list]]!=0 && $toolBar::selection!=""} {

        if {$toolBar::widget=="tree"} {
            # tree selecttion 
            toolBar::treeSelectItem 1
            mol color colorid 4
            set toolBar::selection ""
            toolBar::fillListbox 
        
		} else {
            if {$toolBar::entrySel!="none"} {
                toolBar::entrySelection $toolBar::entrySel 1
                mol color colorid 4
                set toolBar::selection ""
                toolBar::fillListbox 
            }
           
        }

    } 


     ### Add selection to history
     lappend toolBar::selectionHistory $toolBar::customSelection


    ## Clear selection
    set toolBar::customSelection ""

}

proc toolBar::numberAtoms {} {
    set item [$toolBar::selVGui.frame1.frame11.lb1 curselection]

    set text [string trim [lindex [$toolBar::selVGui.frame1.frame11.lb1 get $item] 2] "{}"]
    set selection [atomselect top "$text"]

    set numAtoms [$selection num]

    tk_messageBox -parent $toolBar::selVGui -icon info -title "Number of Atoms" -type ok -message "Current selection has $numAtoms atom(s)." 
}

proc toolBar::deleteSelection {} {

    ## get item
    set item [$toolBar::selVGui.frame1.frame11.lb1 curselection]
    #set text [$toolBar::selVGui.frame1.frame11.lb1 get $item]
    if {$item!=""} {
        mol delrep $item top
        toolBar::fillListbox
    }
    $toolBar::selVGui.frame1.frame11.lb1 selection set [expr $item -1]


    $toolBar::selVGui.frame1.frame11.lb1 selection clear top bottom
}

proc toolBar::string_diff {str1 str2} {
    for {set i 0} {$i < [string length $str1]} {incr i} {
        if {[string index $str2 $i] ne [string index $str1 $i]} {
            return [string range $str2 $i end]
        }
    }
    return [string range $str2 $i end]
}


proc toolBar::treeSelectItem {opt} {


    if {[llength [molinfo list]]!=0} {

            set list [$toolBar::selVGui.frame1.frame10.f0.tree selection]
            
            set optimizedList {}
            foreach element $list {
                set element [split $element "."]
                lappend optimizedList $element
            }
        
            set optSelection ""
            for {set index 0} { $index <= [lindex [lindex $optimizedList end] 0] } { incr index } {
                set a [lsearch -index 0 -all $optimizedList $index]
                
                if {$a != ""} {
                    set [subst list$index] {}
                    foreach b $a {
                        lappend [subst list$index] [lindex $optimizedList $b]
                    }
        
        
                    if {$optSelection != ""} {
                        append optSelection " or "
                    }

                    if {[$toolBar::selVGui.frame1.frame10.f0.tree item $index -text] == "Molecule"} {
                        append optSelection "(all"
                    } else {
                        append optSelection "([$toolBar::selVGui.frame1.frame10.f0.tree item $index -text]"
                    }
        
        
                    if {[llength [lindex $optimizedList [lsearch -index 0 $optimizedList $index]]] > 1} {
                    
                        #### Protein, Other and Water section
                        set listOfIndexes {}
                        foreach element [subst $[subst list$index]] {
                            set subindex [lindex $element 1]
                            if {[lsearch $listOfIndexes $subindex] == -1} {
                                lappend listOfIndexes $subindex
                            }
        
                            lappend [subst sublist$subindex] $element
                        }
        
                        set status 0
                        set statusA 0
                        foreach element $listOfIndexes {
                            if {$element != ""} {
                                if {$status == 0} {
                                    append optSelection " and ("
        
                                    set status 1
                                }
        
                                append optSelection "("
        
                                set text [$toolBar::selVGui.frame1.frame10.f0.tree item $index.$element -text]
                                if {$text == "other" } {
                                    set text "(not protein and not water and not nucleic)"
                                } elseif {[string range $text 0 0] == "-"} {
                                    set text "index [expr $element - 2]"
                                }
                                append optSelection $text
                                
                            if {[llength [lindex $optimizedList [lsearch -index 0 $optimizedList $index]]] > 2} {    
                                #### Residues
                                set residuesTreeIndexes [lsearch -index 1 -all [lsearch -index 0 -all -inline $optimizedList $index] $element]

                                set listOfIndexesResid {}
                                foreach a $residuesTreeIndexes {
                                    set subsubindex [lindex [lindex [lsearch -index 0 -all -inline $optimizedList $index] $a] 2]
        
                                    if {[lsearch $listOfIndexesResid $subsubindex] == -1} {
                                        lappend listOfIndexesResid $subsubindex
                                    }
        
                                    lappend [subst sublist$subsubindex] $subsubindex
                                }
        
                                set statusResid 0
                                set statusResidA 0
                                foreach b $listOfIndexesResid {
                                    if {$b != ""} {
                                        if {$statusResid == 0} {
                                            append optSelection " and ("
        
                                            set statusResid 1
                                        }
        
                                        set text [lindex [split [$toolBar::selVGui.frame1.frame10.f0.tree item $index.$element.$b -text] " : "] 0]
                                        append optSelection "(resid $text"
        
        
        
                                            
                                        if {[llength [lindex $optimizedList [lsearch -index 0 $optimizedList $index]]] > 3} {
                                        
                                            #### Atom
                                            set atomsTreeIndexes [lsearch -index 2 -all [lsearch -index 1 -all -inline [lsearch -index 0 -all -inline $optimizedList $index] $element] $b]
        
                                            set listOfIndexesAtom {}
                                            foreach a $atomsTreeIndexes {
                                                set subsubsubindex [lindex [lindex [lsearch -index 1 -all -inline [lsearch -index 0 -all -inline $optimizedList $index] $element] $a] 3]
        
                                                if {[lsearch $listOfIndexesAtom $subsubsubindex] == -1} {
                                                    lappend listOfIndexesAtom $subsubsubindex
                                                }
        
                                                lappend [subst sublist$subsubsubindex] $subsubsubindex
                                            }
        
                                            set statusAtom 0
                                            set statusAtomA 0
        
                                            foreach c $listOfIndexesAtom {
                                                if {$c != ""} {
                                                    set text [lindex [split [$toolBar::selVGui.frame1.frame10.f0.tree item $index.$element.$b.$c -text] " "] 1]
                                                    
                                                    if {$statusAtom == 0} {
                                                        append optSelection " and ("
        
                                                        set statusAtom 1
                                                        append optSelection "name $text"
                                                    } else {
                                                        append optSelection " $text"
                                                    }
        
                                                    set statusAtomA 1
        
                                                }
                                            }
                                            
                                            if {$statusAtomA == 1} {
                                                append optSelection ")"
                                            }
                                        }
        
                                        append optSelection ")"
        
                                        if {[expr [lsearch $listOfIndexesResid $b] + 1] == [llength $listOfIndexesResid]} {
                                            # Do nothing
                                        } else {
                                            append optSelection " or "
                                        }
        
                                        set statusResidA 1
        
                                    }
                                }
        
                                if {$statusResidA == 1} {
                                    append optSelection ")"
                                }
        
                            }
        
        
        
        
                                append optSelection ")"
        
                                if {[expr [lsearch $listOfIndexes $element] + 1] == [llength $listOfIndexes]} {
                                    # Do nothing
                                } else {
                                    append optSelection " or "
                                }
        
                                set statusA 1
        
                                
        
                            }
        
                        
                        }
        
        
        
                        if {$statusA == 1} {
                            append optSelection ")"
                        }
        
                    }
        
                    append optSelection ")"
        
                }
            }
        
        
            toolBar::changeRepresentation $optSelection $opt
        
            ## Update text shown of the custom selection entry
            set toolBar::customSelection $optSelection
        
        } else {
            toolBar::cleanGui
    }

set toolBar::widget tree

}


proc toolBar::changeRepresentation {selectionTotal opt} {
	
	
	if {$selectionTotal=="(Molecule)" } {set selectionTotal "(all)"}

    ## Change representation

    # delete old item
    if {$toolBar::selection!=""} {
        ## modify representation if it already exists
        set repid [mol repindex top $toolBar::selection] 
        mol delrep $repid top
    }

    # create a new rep
    set atomNum [[atomselect top $selectionTotal] num ]

    mol selection $selectionTotal

    # Change atom representation based on the number of atoms in the selection
    set atomNum [[atomselect top $selectionTotal] num ]

    if {$atomNum>1000} { mol representation Cartoon
    } elseif {$atomNum<4} {mol representation VDW
    } else {mol representation Licorice 0.300000 8.000000 6.000000}

    # change color if is selection or add selection
    if {$opt==1} { mol color Name
    } else {mol color ColorID 4}

    mol addrep top

    # memorize rep details
    set repid [expr [molinfo top get numreps] - 1]
    set repname [mol repname top $repid]
    set toolBar::selection $repname
}



proc toolBar::fillListbox {} {
    ## clean listbox
     $toolBar::selVGui.frame1.frame11.lb1 delete 0 [ $toolBar::selVGui.frame1.frame11.lb1 size]
    
    ## Add items
    set repname ""
    for {set i 0} {$i < [molinfo top get numreps]} {incr i} {
        lassign [molinfo top get "{rep $i} {selection $i} "] a b 

        ## all but not the one equal to the one of the selections
        set repid [expr [molinfo top get numreps] -1]
        set repname [mol repname top $i]
        if {$repname!=$toolBar::selection} {
            if {[mol showrep top $i]==0} {
                $toolBar::selVGui.frame1.frame11.lb1 insert end [list "$i" "| |" "$b"]
                $toolBar::selVGui.frame1.frame11.lb1 rowconfigure $i -foreground red
                } else {
                    $toolBar::selVGui.frame1.frame11.lb1 insert end [list "$i" "|X|" "$b"]
                    $toolBar::selVGui.frame1.frame11.lb1 rowconfigure $i -foreground black
                    }
        }

    }

}

proc toolBar::clickListBox {opt} {

    if {[llength [molinfo list]]!=0} {

        ## get item
        set item [$toolBar::selVGui.frame1.frame11.lb1 curselection]
        set text [$toolBar::selVGui.frame1.frame11.lb1 get $item]

        set toolBar::item $item

        set toolBar::customSelection [string trim [lindex $text 2] "{}"]
        $toolBar::selVGui.frame1.frame10.f1.bt2 configure -state active

        set toolBar::selectionID $item

        set toolBar::curColor [string trim [molinfo top get "{color $item}"] "{}"]
        set toolBar::curDraw [lindex [string trim [molinfo top get "{rep $item}"] "{}"] 0]
        set toolBar::curMaterial "Opaque"

        #ver se o numero de items da listabox não é menor do que o numero de items

        if {$item<=[expr [molinfo top get numreps]-1] } {
            $toolBar::selVGui.frame1.frame11.lb1 selection set $item 
        } else { toolBar::fillListbox; set item [expr [molinfo top get numreps]-1] }

        if {$opt=="double"} {
            if {[mol showrep top $item]==0} {
                mol showrep top $item 1
                $toolBar::selVGui.frame1.frame11.lb1 rowconfigure $item -foreground black
                $toolBar::selVGui.frame1.frame11.lb1 rowconfigure $item -selectforeground black
                $toolBar::selVGui.frame1.frame11.lb1 configcells [subst $item],1 -text "|X|"
            } else {
                mol showrep top $item 0
                $toolBar::selVGui.frame1.frame11.lb1 rowconfigure $item -foreground red  
                $toolBar::selVGui.frame1.frame11.lb1 rowconfigure $item -selectforeground red
                $toolBar::selVGui.frame1.frame11.lb1 configcells [subst $item],1 -text "| |"
            }

            $toolBar::selVGui.frame1.frame11.lb1 selection clear top bottom

        } else {

            if {[mol showrep top $item]==1} {
                $toolBar::selVGui.frame1.frame11.lb1 rowconfigure $item -selectforeground black
            } else {
                $toolBar::selVGui.frame1.frame11.lb1 rowconfigure $item -selectforeground red
            }

            $toolBar::selVGui.frame1.frame11.lb1 selection set $item 

            #set toolBar::customSelection [lindex $text 2]

            # select item no rep
            # modselect rep_number molecule_number select_method
        }

        # See item that was selected
        $toolBar::selVGui.frame1.frame11.lb1 see $item

    } else {toolBar::cleanGui}

    

    
}

proc toolBar::edit {} {
    set item [$toolBar::selVGui.frame1.frame11.lb1 curselection]
    if {$item!=""} {
           if {[menu graphics status]=="off"} {menu graphics on}
    }


}

proc toolBar::updateSelection {} {
    mol modselect $toolBar::item top $toolBar::customSelection

    ## Update list of representantions
    toolBar::fillListbox

     ### Add selection to history
     lappend toolBar::selectionHistory $toolBar::customSelection

    set toolBar::customSelection ""
    $toolBar::selVGui.frame1.frame10.f1.bt2 configure -state disabled
}

proc toolBar::entrySelection {selection opt} {
    set error ""
    if {$toolBar::layers!={}} {
        catch {set error [atomselect top "$selection"]} atomselect
        ## see if the text give error or not
    
        if {$error==""} {
            #turn widget red
            ttk::style configure entry -foreground red  -borderwidth 2 -padding 0
            #set toolBar::selection ""
            toolBar::changeRepresentation "none" 0
            set toolBar::entrySel "none"


        } else {
            ttk::style configure entry -foreground black  -borderwidth 2 -padding 0
            ## put the selection in yellow
            set toolBar::entrySel $selection
            toolBar::changeRepresentation $selection $opt
        }

        ## avaliate the text
        # if there is not error turn it in yellow
        # otherwise turn the text red
        set toolBar::widget entry
    }
        return 1

}
proc toolBar::about {} {
    tk_messageBox -icon info -title Help -parent $toolBar::selVGui -type ok -message "Selection Viewer provides an easy GUI to handle molecule selections.\n\nContact: \nNuno Sousa Cerqueira (nscerque@fc.up.pt)\nHenrique S. Fernandes (henrique.fernandes@fc.up.pt) \nFaculty of Sciences - University of Porto - Portugal" 
}


proc toolBar::cleanGui {} {
    $toolBar::selVGui.frame1.frame10.f0.tree delete [ $toolBar::selVGui.frame1.frame10.f0.tree  children {}]
    $toolBar::selVGui.frame1.frame11.lb1 delete 0 end
    set  $toolBar::layers ""
    $toolBar::selVGui.frame0.cb1 configure -values $toolBar::layers
    $toolBar::selVGui.frame0.cb1 set ""
}

proc toolBar::startselV {} {
    #### Check if the window exists
    if {[winfo exists $::toolBar::selVGui]} {
        wm deiconify $::toolBar::selVGui
        update
        return $::toolBar::selVGui
    }

    ##### START GUI
    toolBar::selV

    return $::toolBar::selVGui
}


proc toolBar::validateSelectionEditor {} {
    mol modcolor $toolBar::selectionID top "$toolBar::curColor"
    mol modmaterial $toolBar::selectionID top "$toolBar::curMaterial"
    mol modstyle $toolBar::selectionID top "$toolBar::curDraw"

    toolBar::selectPDB
}


proc toolBar::moveToSelection {} {
    set item [$toolBar::selVGui.frame1.frame11.lb1 curselection]
    set text [string trim [lindex [$toolBar::selVGui.frame1.frame11.lb1 get $item] 2] "{}"]
    set selection [atomselect top "$text"]

    set centerMass [toolBar::massCenter $selection]

    ## Center on selection
    set x [expr [lindex $centerMass 0] * -1]
    set y [expr [lindex $centerMass 1] * -1]
    set z [expr [lindex $centerMass 2] * -1]
    #molinfo top set center_matrix "{{1 0 0 $x} {0 1 0 $y} {0 0 1 $z} {0 0 0 1}}"


    ## Zoom
    if {[$selection num] > 1} {
        set max 0
        foreach atom [$selection get {x y z}] {
            set x2 [lindex $atom 0] 
            set y2 [lindex $atom 1] 
            set z2 [lindex $atom 2] 
    
            set dist [expr (($x2-[lindex $centerMass 0])*($x2-[lindex $centerMass 0]) + ($y2-[lindex $centerMass 1])*($y2-[lindex $centerMass 1]) + ($z2-[lindex $centerMass 2])*($z2-[lindex $centerMass 2]))]
            if {$dist > $max} { 
                set max $dist 
            } 
        }

        set zoom [expr 1 / sqrt($max)]
    } else {
        set zoom 0.5
    }

    #molinfo top set scale_matrix "{{$zoom 0 0 0} {0 $zoom 0 0} {0 0 $zoom 0} {0 0 0 1}}"

    set rotateMatrix [molinfo top get rotate_matrix]

    if {$toolBar::animationOnOff == 1} {
        ::toolBar::moveToViewPoint "{{1 0 0 $x} {0 1 0 $y} {0 0 1 $z} {0 0 0 1}} $rotateMatrix {{$zoom 0 0 0} {0 $zoom 0 0} {0 0 $zoom 0} {0 0 0 1}} {{1 0 0 0} {0 1 0 0} {0 0 1 0} {0 0 0 1}}"
    } else {
        molinfo top set center_matrix "{{1 0 0 $x} {0 1 0 $y} {0 0 1 $z} {0 0 0 1}}"
        molinfo top set scale_matrix "{{$zoom 0 0 0} {0 $zoom 0 0} {0 0 $zoom 0} {0 0 0 1}}"
    }


}

proc toolBar::massCenter {selection} {
        # set the geometrical center to 0
        set gc [veczero]
        # [$selection get {x y z}] returns a list of {x y z} 
        #    values (one per atoms) so get each term one by one
        foreach coord [$selection get {x y z}] {
           # sum up the coordinates
           set gc [vecadd $gc $coord]
        }
        # and scale by the inverse of the number of atoms
        return [vecscale [expr 1.0 /[$selection num]] $gc]
}


##### Viewpoints procs

proc toolBar::getViewPoints {} {

    puts "##### HELP : ######"
	# get viewpoint start
	set viewpointStart [molinfo [molinfo top get id] get {center_matrix rotate_matrix scale_matrix global_matrix}]

	set ::VCR::viewpoints(1,0) "{ [lindex $viewpointStart 1] }"
	set ::VCR::viewpoints(1,1) "{ [lindex $viewpointStart 0] }"
	set ::VCR::viewpoints(1,2) "{ [lindex $viewpointStart 2] }"
	set ::VCR::viewpoints(1,3) "{ [lindex $viewpointStart 3] }"
	set ::VCR::viewpoints(1,4) { 0 }

	set viewpointStart [molinfo [molinfo top get id] get {center_matrix rotate_matrix scale_matrix global_matrix}]
	puts " vmdTutor::setview \"$viewpointStart\""
	puts "\n"
	puts "vmdTutor::movie \"$viewpointStart\""
}


proc toolBar::moveToViewPoint {viewpointsEnd} {

	# do not allow VCR to change representations
	::VCR::disableRepChanges

	# get viewpoint start
	set viewpointStart [molinfo [molinfo top get id] get {center_matrix rotate_matrix scale_matrix global_matrix}]
	set viewpointStart [molinfo [molinfo top get id] get {center_matrix}]

	set ::VCR::viewpoints(1,0) "{ [lindex $viewpointStart 1] }"
	set ::VCR::viewpoints(1,1) "{ [lindex $viewpointStart 0] }"
	set ::VCR::viewpoints(1,2) "{ [lindex $viewpointStart 2] }"
	set ::VCR::viewpoints(1,3) "{ [lindex $viewpointStart 3] }"
	set ::VCR::viewpoints(1,4) { 0 }

	set ::VCR::viewpoints(2,0) "{ [lindex $viewpointsEnd 1] }"
	set ::VCR::viewpoints(2,1) "{ [lindex $viewpointsEnd 0] }"
	set ::VCR::viewpoints(2,2) "{ [lindex $viewpointsEnd 2] }"
	set ::VCR::viewpoints(2,3) "{ [lindex $viewpointsEnd 3] }"
	set ::VCR::viewpoints(2,4) { 0 }

	## Add All Viewpoints to VCR
	set ::vcr_gui::vplist [::VCR::list_vps]

	#move to state num
	::VCR::movetime_vp here 2 $toolBar::animationDuration
}


##### Entry History 
proc toolBar::readHistory {opt} {
    if {$toolBar::selectionHistoryID == ""} {
         set toolBar::selectionHistoryID [llength $toolBar::selectionHistory]
    } else {}

    if {$toolBar::selectionHistoryID > [llength $toolBar::selectionHistory]} {
             set toolBar::selectionHistoryID ""
    } else {
        if {$opt == "up" && $toolBar::selectionHistoryID > 0} {
             set toolBar::selectionHistoryID [expr $toolBar::selectionHistoryID - 1]
             set toolBar::customSelection [lindex $toolBar::selectionHistory $toolBar::selectionHistoryID]
 
        } elseif {$opt == "down"} {
             set toolBar::selectionHistoryID [expr $toolBar::selectionHistoryID + 1]
             set toolBar::customSelection [lindex $toolBar::selectionHistory $toolBar::selectionHistoryID]
        } else {}
    }
}

  


##### AutoComplete

# Autocompletes the words in a entry

proc toolBar::autocomplete {win action validation value valuelist} {
	
	# only searches the last word if more than one word exists
	set value1 $value; set value0 ""

	if {[llength $value] >=2 && [string index $value end]!=" "} {
		
		set value1 [lindex $value [expr [llength $value]-1]]
		set value0 "[string range $value 0 [expr [string length $value] - [string length " $value1"]-1]] "
		
	} else {set value1 $value}
	
	# change last word according to the valuelist

	if {$action == 1 & $value1!= {} & [set pop [lsearch -inline $valuelist $value1*]] != {}} {
		set value1 "$value1"
		$win delete 0 end;  $win insert end "$value0$pop"
		$win selection range [string length "$value0$value1"] end
		$win icursor [string length "$value0$value1"]
	} else {
		$win selection clear
	}
	after idle [list $win configure -validate $validation]
	return 1
}


#### Delete All Labels
proc toolBar::deleteAllLabels {} {
    label delete Atoms All
    label delete Bonds All
    label delete Angles All
    label delete Dihedrals All
    label delete Springs All
}



proc toolBar::badParams {} {

	#### Check if the window exists
	if {[winfo exists $::toolBar::selVGui.badParams]} {wm deiconify $::toolBar::selVGui.badParams ; toolBar::badPickAtom; return $::toolBar::selVGui.badParams}
	toplevel $::toolBar::selVGui.badParams
	wm attributes $::toolBar::selVGui.badParams -topmost yes

	#### Title of the window
	wm title $::toolBar::selVGui.badParams "Measure Bond, Angle and Dihedral Angles" ;# titulo da pagina
	wm resizable $::toolBar::selVGui.badParams 0 0


    #### GUI

		## Frame 0 - LABELS
		grid [ttk::frame $::toolBar::selVGui.badParams.frame0] -row 1 -column 0 -padx 1 -pady 1 -sticky news
		

			grid [ttk::label $::toolBar::selVGui.badParams.frame0.label0 -text "Click on Atoms of the VMD window to get Bond, Angle and \nDihedral parameters."] \
				-in $::toolBar::selVGui.badParams.frame0 \
				-row 0 -column 0
						

		## Frame 1  - BAD PARABETERS
		grid [ttk::frame $::toolBar::selVGui.badParams.frame1] -row 0 -column 0 -padx 1 -pady 1 -sticky news


			# LABELS
			
			foreach a "Param Atom Index Type Resid Value Units" column "0 1 2 3 4 5 6" {

			grid [ttk::label $::toolBar::selVGui.badParams.frame1.label_$a -text "$a"] \
				-in $::toolBar::selVGui.badParams.frame1 \
				-row 0 -column $column
						
			}
						
			# BAD PARAMETERS	
			
			foreach a "None Bond Angle Dihedral" row "1 2 3 4" {
				
				
				
				# label BOND ANGLE DIHEDRAL
				if {$a=="None"} {
				grid [ttk::label $::toolBar::selVGui.badParams.frame1.label_$a -text ""] \
					-in $::toolBar::selVGui.badParams.frame1 \
					-row $row -column 0
				} else {
				grid [ttk::label $::toolBar::selVGui.badParams.frame1.label_$a -text "$a"] \
									-in $::toolBar::selVGui.badParams.frame1 \
									-row $row -column 0
				}
				
				# entry Label 
				grid [ttk::label $::toolBar::selVGui.badParams.frame1.label1_$a -text $row] \
				-in $::toolBar::selVGui.badParams.frame1 \
				-row $row -column 1		
				
				# entry Index 
				grid [ttk::entry $::toolBar::selVGui.badParams.frame1.entryIndex_$a -width 5 -style selV.TEntry] \
					-in $::toolBar::selVGui.badParams.frame1 \
					-row $row -column 2 -padx 1 -pady 1

				# entry 1 - INDEX SELECTION
				grid [ttk::entry $::toolBar::selVGui.badParams.frame1.entryAtom_$a -width 5 -style selV.TEntry] \
					-in $::toolBar::selVGui.badParams.frame1 \
					-row $row -column 3 -padx 1 -pady 1	
					
					
				# entry 3 - INDEX SELECTION
				grid [ttk::entry $::toolBar::selVGui.badParams.frame1.entryResid_$a -width 5 -style selV.TEntry] \
					-in $::toolBar::selVGui.badParams.frame1 \
					-row $row -column 4 -padx 1 -pady 1	



				if {$row>=2} {
				
					# entry 2 DISTANCE, ANGLE, DIHEDRAL
					grid [ttk::entry $::toolBar::selVGui.badParams.frame1.entryValue_$a -width 10 -style selV.TEntry] \
						-in $::toolBar::selVGui.badParams.frame1 \
						-row $row -column 5 -padx 1 -pady 1	
		
		
					# Units
					if {$row==3 || $row==4} {set text "Degrees"
					} else {set text "Angstroms"}
					
					grid [ttk::label $::toolBar::selVGui.badParams.frame1.units_$a -text $text] \
					-in $::toolBar::selVGui.badParams.frame1 \
					-row $row -column 6 -sticky w
					
				}
				
			}
			
		## Frame 2 - Buttons
		grid [ttk::frame $::toolBar::selVGui.badParams.frame2] -row 2 -column 0 -padx 1 -pady 1 -sticky news
				
				grid [ttk::button $::toolBar::selVGui.badParams.frame2.button_1 -text "Close" \
							-command {mouse mode rotate;trace vdelete ::vmd_pick_atom w toolBar::atomPickedBAD; wm withdraw $::toolBar::selVGui.badParams;
							    if {[winfo exists $::toolBar::selVGui.badParams]} {wm withdraw $::toolBar::selVGui.badParams}} \
                                -style selV.TButton \
                                ] -in $::toolBar::selVGui.badParams.frame2 \
							-row 0 -column 3 -pady 10 -padx 20
							
				grid [ttk::button $::toolBar::selVGui.badParams.frame2.button_2 -text "Assign Atoms" \
					-command {mouse mode pick} \
                    -style selV.TButton \
                    ] -in $::toolBar::selVGui.badParams.frame2 \
					-row 0 -column 1 -pady 10 -padx 20
											
											
				grid [ttk::button $::toolBar::selVGui.badParams.frame2.button_3 -text "Delete Data" \
					-command {toolBar::deleteAll} \
                    -style selV.TButton \
                    ] -in $::toolBar::selVGui.badParams.frame2 \
					-row 0 -column 2 -pady 10 -padx 20
	
	
	
	label textthickness 2
	toolBar::badPickAtom
				
}


proc toolBar::badPickAtom {} {
	
		## Trace the variable to run a command each time a atom is picked
	    trace variable ::vmd_pick_atom w toolBar::atomPickedBAD
		
		## Activate atom pick
		mouse mode pick
}


proc toolBar::deleteAll {} {
	
	
		$::toolBar::selVGui.badParams.frame1.entryIndex_None delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryAtom_None delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryResid_None delete 0 end
		
		$::toolBar::selVGui.badParams.frame1.entryIndex_Bond delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryAtom_Bond delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryResid_Bond delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryValue_Bond delete 0 end
				 
		$::toolBar::selVGui.badParams.frame1.entryIndex_Angle delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryAtom_Angle delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryResid_Angle delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryValue_Angle delete 0 end 
		
		$::toolBar::selVGui.badParams.frame1.entryIndex_Dihedral delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryAtom_Dihedral delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryResid_Dihedral delete 0 end
		$::toolBar::selVGui.badParams.frame1.entryValue_Dihedral delete 0 end
		
		
		# clean graphics
		foreach a $toolBar::graphicsID {
			foreach b $a {
				graphics [molinfo top] delete $b
			}
		} 
		
		#delete labels
		
		label delete Atoms all 
		label delete Bonds all 
		label delete Angles all 
		label delete Dihedrals all 
				
		
		# delete data
		set toolBar::graphicsID ""
		set toolBar::pickedAtomsBAD ""

	
}

proc toolBar::atomPickedBAD {args} {
	
	
	if {[lsearch $toolBar::pickedAtomsBAD $::vmd_pick_atom]==-1} {


		if {[llength $toolBar::pickedAtomsBAD]>=4 || [llength $toolBar::pickedAtomsBAD]==0} {
		
		
		#Delete Index Atom Resid Param Value Check
		toolBar::deleteAll
	
		# Add the first atom	
		set toolBar::pickedAtomsBAD $::vmd_pick_atom
	
	
	} else {lappend toolBar::pickedAtomsBAD $::vmd_pick_atom}
	
	
	# Put Values in the correct place
	
	if {[llength $toolBar::pickedAtomsBAD]==1} {
		
		# First Atom
		$::toolBar::selVGui.badParams.frame1.entryIndex_None insert 0 "[lindex $toolBar::pickedAtomsBAD 0]"
		set sel [atomselect top "index [lindex $toolBar::pickedAtomsBAD 0]"] 
		$::toolBar::selVGui.badParams.frame1.entryAtom_None insert 0 "[$sel get name]"
		$::toolBar::selVGui.badParams.frame1.entryResid_None insert 0 "[$sel get resid]"	
		# Draw
			set mem [toolBar::sphere [lindex $toolBar::pickedAtomsBAD 0] red]
		
		set toolBar::graphicsID [lappend toolBar::graphicsID "$mem"]

				


	} elseif {[llength $toolBar::pickedAtomsBAD]==2} {
		
		
		#BOND
		$::toolBar::selVGui.badParams.frame1.entryIndex_Bond insert 0 "[lindex $toolBar::pickedAtomsBAD 1]"
		set sel [atomselect top "index [lindex $toolBar::pickedAtomsBAD 1]"] 
		$::toolBar::selVGui.badParams.frame1.entryAtom_Bond insert 0 "[$sel get name]"
		$::toolBar::selVGui.badParams.frame1.entryResid_Bond insert 0 "[$sel get resid]"
	
		# Value
		set value [strictformat %7.2f [measure bond  "[lindex $toolBar::pickedAtomsBAD 0] [lindex $toolBar::pickedAtomsBAD 1]"] ]
		$::toolBar::selVGui.badParams.frame1.entryValue_Bond insert 0 "$value"
		label add Bonds [molinfo top]/[lindex $toolBar::pickedAtomsBAD 0] [molinfo top]/[lindex $toolBar::pickedAtomsBAD 1]


		# Draw
		set mem [toolBar::sphere [lindex $toolBar::pickedAtomsBAD 1] white]
		set mem1 [toolBar::line [lindex $toolBar::pickedAtomsBAD 0] [lindex $toolBar::pickedAtomsBAD 1] white]
		
		
		set toolBar::graphicsID [lappend toolBar::graphicsID "$mem $mem1"]

	

	} elseif {[llength $toolBar::pickedAtomsBAD]==3} {
		
		#ANGLE
		
		$::toolBar::selVGui.badParams.frame1.entryIndex_Angle insert 0 "[lindex $toolBar::pickedAtomsBAD 2]"
		
		set sel [atomselect top "index [lindex $toolBar::pickedAtomsBAD 2]"] 
		$::toolBar::selVGui.badParams.frame1.entryAtom_Angle insert 0 "[$sel get name]"
		$::toolBar::selVGui.badParams.frame1.entryResid_Angle insert 0 "[$sel get resid]"
		
		# Value
		set value [strictformat %7.2f [measure angle "[lindex $toolBar::pickedAtomsBAD 0] [lindex $toolBar::pickedAtomsBAD 1] [lindex $toolBar::pickedAtomsBAD 2]"] ]
		$::toolBar::selVGui.badParams.frame1.entryValue_Angle insert 0 "$value"
		
		label add Angles [molinfo top]/[lindex $toolBar::pickedAtomsBAD 0] [molinfo top]/[lindex $toolBar::pickedAtomsBAD 1] [molinfo top]/[lindex $toolBar::pickedAtomsBAD 2]

		
		# Draw
		
		set mem [toolBar::sphere [lindex $toolBar::pickedAtomsBAD 2] yellow]
		set mem1 [toolBar::triangle [lindex $toolBar::pickedAtomsBAD 0] [lindex $toolBar::pickedAtomsBAD 1] [lindex $toolBar::pickedAtomsBAD 2] yellow]
		
		
		set toolBar::graphicsID [lappend toolBar::graphicsID "$mem $mem1"]
		
	} elseif {[llength $toolBar::pickedAtomsBAD]==4} {
		
		#DIHEDRAL
		
		$::toolBar::selVGui.badParams.frame1.entryIndex_Dihedral insert 0 "[lindex $toolBar::pickedAtomsBAD 3]"
		
		set sel [atomselect top "index [lindex $toolBar::pickedAtomsBAD 3]"] 
		$::toolBar::selVGui.badParams.frame1.entryAtom_Dihedral insert 0 "[$sel get name]"
		$::toolBar::selVGui.badParams.frame1.entryResid_Dihedral insert 0 "[$sel get resid]"
	
	
		# value
		set value [strictformat %7.2f [measure dihed "[lindex $toolBar::pickedAtomsBAD 0] [lindex $toolBar::pickedAtomsBAD 1] [lindex $toolBar::pickedAtomsBAD 2] [lindex $toolBar::pickedAtomsBAD 3]"] ]
		$::toolBar::selVGui.badParams.frame1.entryValue_Dihedral insert 0 "$value"
		
		label add Dihedrals [molinfo top]/[lindex $toolBar::pickedAtomsBAD 0] [molinfo top]/[lindex $toolBar::pickedAtomsBAD 1] [molinfo top]/[lindex $toolBar::pickedAtomsBAD 2]  [molinfo top]/[lindex $toolBar::pickedAtomsBAD 3]
		
		# Draw
		set mem [toolBar::sphere [lindex $toolBar::pickedAtomsBAD 3] cyan]
		#set mem1 [toolBar::triangle [lindex $toolBar::pickedAtomsBAD 1] [lindex $toolBar::pickedAtomsBAD 2] [lindex $toolBar::pickedAtomsBAD 3] cyan]
		set mem2 [toolBar::cylinder [lindex $toolBar::pickedAtomsBAD 1] [lindex $toolBar::pickedAtomsBAD 2] cyan]
		
		
		set toolBar::graphicsID [lappend toolBar::graphicsID "$mem $mem2"]
	}
	
	
	
	}
}



proc toolBar::strictformat {fmt value} {
    set f [format $fmt $value]
    regexp {%(\d+)} $fmt -> maxwidth
    if {[string length $f] > $maxwidth} {
        return [string repeat * $maxwidth]
    } else {
        return $f
    }
}


proc toolBar::sphere {selection color} {	
	set coordinates [[atomselect top "index $selection"] get {x y z}]
	
	# Draw a circle around the coordinate
	draw color $color
	draw material Transparent
	set a [graphics [molinfo top] sphere "[lindex $coordinates 0] [lindex $coordinates 1] [lindex $coordinates 2]" radius 0.9 resolution 25]
	
	return  $a
	
}


proc toolBar::line {selection0 selection1 color } {

	set coordinates0 [[atomselect top "index $selection0"] get {x y z}]
	set coordinates1 [[atomselect top "index $selection1"] get {x y z}]
	
	# Draw line
	draw color $color
	set a [graphics [molinfo top] line "[lindex $coordinates0 0] [lindex $coordinates0 1] [lindex $coordinates0 2]" "[lindex $coordinates1 0] [lindex $coordinates1 1] [lindex $coordinates1 2]" width 5 style dashed]
	
	# Add text
	#set b [graphics 0 text "[lindex $coordinates0 0] [lindex $coordinates0 1] [lindex $coordinates0 2]" "$value Angstroms"]
	
	return  "$a"


}


proc toolBar::triangle {selection0 selection1 selection2 color } {
	set coordinates0 [[atomselect top "index $selection0"] get {x y z}]
	set coordinates1 [[atomselect top "index $selection1"] get {x y z}]
	set coordinates2 [[atomselect top "index $selection2"] get {x y z}]

	
	# Draw line
	
	draw color $color
	set a [graphics [molinfo top] triangle "[lindex $coordinates0 0] [lindex $coordinates0 1] [lindex $coordinates0 2]" "[lindex $coordinates1 0] [lindex $coordinates1 1] [lindex $coordinates1 2]" "[lindex $coordinates2 0] [lindex $coordinates2 1] [lindex $coordinates2 2]"]
	
	# Add text
	#set b [graphics [molinfo top] text "[lindex $coordinates1 0] [lindex $coordinates1 1] [lindex $coordinates1 2]" "$value degrees"]
	
	return  "$a"
}


proc toolBar::cylinder {selection0 selection1 color} {
	set coordinates0 [[atomselect top "index $selection0"] get {x y z}]
	set coordinates1 [[atomselect top "index $selection1"] get {x y z}]

	# Draw
	
	draw color $color
	set a [graphics [molinfo top] cylinder "[lindex $coordinates0 0] [lindex $coordinates0 1] [lindex $coordinates0 2]" "[lindex $coordinates1 0] [lindex $coordinates1 1] [lindex $coordinates1 2]"  radius 0.5 resolution 50]
	
	# Add graphics that will be deleted
	return  $a
	
}

