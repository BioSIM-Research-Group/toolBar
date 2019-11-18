package provide vmdPresets 1.0

namespace eval vmdPresets:: {
	namespace export vmdPresets
	
	#### Load Packages				
	package require Tk

    #### Variables
    variable version 1.0
    variable topGui ".gui_vmdPresets"

    variable pathPresets [file join [file dirname [info script]] presets] ;# where the templates are located
    variable colorRef "" ;# ref used to know color that is selected

}

proc vmdPresets::gui {} {

    #### Check if the window exists
	if {[winfo exists $::vmdPresets::topGui]} {wm deiconify $::vmdPresets::topGui ;return $::vmdPresets::topGui}
	
    toplevel $::vmdPresets::topGui

	#### Title of the windows
	wm title $vmdPresets::topGui "toolBar vmdPresets v$vmdPresets::version " ;

    #### Screen Size
    set sWidth [expr [winfo vrootwidth  $::vmdPresets::topGui] -0]
	set sHeight [expr [winfo vrootheight $::vmdPresets::topGui] -100]

    #### Window Size and Position
	wm geometry $::vmdPresets::topGui 530x640+[expr $sWidth / 2 - 500 / 2]+[expr $sHeight / 2 - 400 / 2]
	$::vmdPresets::topGui configure -background {#ececec}

    #### window is no resizable
    wm resizable  $::vmdPresets::topGui 0 0

    grid columnconfigure $vmdPresets::topGui     0   -weight 1
    #grid rowconfigure $vmdPresets::topGui     0   -weight 1

    #### FRAME 1 - Load Template
    set f1 $vmdPresets::topGui.frame1

        grid [ttk::frame $f1] -in $vmdPresets::topGui -sticky news
        grid columnconfigure $f1     1   -weight 1

        grid [ttk::label $f1.templatesLabel \
            -text "VMD Templates:" \
            ] -in $f1 -row 1 -column 0 -sticky news -pady 5 -padx 10



        grid [ttk::combobox $f1.templateComboBox \
            -values "" \
            -state readonly \
            ] -in $f1 -row 1 -column 1 -sticky news -pady 5 -padx 5

        
        #populate combobox
        set fileExtension {*.vmd}
        vmdPresets::populateComboBoxBackgroundTemplates $fileExtension $vmdPresets::topGui.frame1.templateComboBox

        #$f1.templateComboBox set [lindex $files 0]

        grid [ttk::button $f1.templateButton \
            -text "Apply" \
            -command {vmdPresets::applyTemplate} \
            ] -in $f1 -row 1 -column 2 -sticky news -pady 5 -padx 5

############# Label Frame 2 - Background colors
    set lf2 $vmdPresets::topGui.lf2

        grid [ttk::labelframe $lf2 -text "Background Color"] -in $vmdPresets::topGui -sticky news -pady 10 -padx 20
        grid columnconfigure $lf2     1   -weight 1


    #### FRAME 21 - Background colors
    set f2 $vmdPresets::topGui.lf2.frame2

        grid [ttk::frame $f2] -in $vmdPresets::topGui.lf2 -sticky news -pady 10 -padx 10
     #   grid columnconfigure $f2     1   -weight 1


        grid [ttk::label $f2.colorLabel \
            -text "Mode:" \
            ] -in $f2 -row 1 -column 0 -sticky news -pady 5 -padx 10

        variable colorSolidRadioButton 1

        grid [ttk::radiobutton $f2.colorSolidRadioButton \
            -text "Solid" \
            -variable vmdPresets::colorSolidRadioButton \
            -value 1 \
            -command {vmdPresets::controlBackgroundColor solidColor}
            ] -in $f2 -row 1 -column 1 -sticky news -pady 5 -padx 10

        variable colorGradRadioButton 0

        grid [ttk::radiobutton $f2.colorGradRadioButton \
            -text "Gradient" \
            -value 1 \
            -variable vmdPresets::colorGradRadioButton \
            -command {vmdPresets::controlBackgroundColor gradColor}
            ] -in $f2 -row 1 -column 2 -sticky news -pady 5 -padx 10

    

    #### FRAME 21 - Background colors combobox
    set f3 $vmdPresets::topGui.lf2.frame3

        grid [ttk::frame $f3] -in $vmdPresets::topGui.lf2 -sticky news
        grid columnconfigure $f3     1   -weight 1

        grid [ttk::label $f3.templatesLabel \
            -text "Color Schemes:" \
            ] -in $f3 -row 1 -column 0 -sticky news -pady 5 -padx 10

        grid [ttk::combobox $f3.templateComboBox \
            -values "" \
            -state readonly \
            ] -in $f3 -row 1 -column 1 -sticky w -pady 5 -padx 5



    #### FRAME 4 - Background colors canvas
    set f4 $vmdPresets::topGui.lf2.frame4

        grid [ttk::frame $f4] -in $vmdPresets::topGui.lf2 -sticky news -padx 5 
        grid columnconfigure $f4     0   -weight 1   

        grid [canvas $f4.canvas \
            -bg #e5e5e5 \
            -width 440 \
            -height 160 \
            -yscrollcommand "$f4.vscroll set" \
            ] -in $f4 -row 0 -column 0 -sticky ew 

        grid [scrollbar $f4.vscroll \
            -orient vertical \
            -command "$f4.canvas yview"\
             ] -in $f4 -row 0 -column 1 -sticky ns 



   #### FRAME 5 - Background colors canvas selection
    set f5 $vmdPresets::topGui.lf2.frame5

        grid [ttk::frame $f5] -in $vmdPresets::topGui.lf2 -sticky news -padx 10 
        grid columnconfigure $f5     0   -weight 1   

        grid [canvas $f5.canvas \
            -height 40 \
            ] -in $f5 -row 0 -column 0 -sticky ew 

       # grid [ttk::button $f5.custom \
            -text "Custom" \
            -command {set vmdPresets::colorRef [tk_chooseColor -initialcolor [$vmdPresets::topGui.lf2.frame5.canvas itemcget selectedColor -fill]]; \
                    $vmdPresets::topGui.lf2.frame5.canvas itemconfigure selectedColor -fill [lindex $vmdPresets::colorRef 0] -width 1 ; \
                    $vmdPresets::topGui.lf2.frame5.canvas itemconfigure colorRef -text "Custom color : [::tk::Darken [lindex $vmdPresets::colorRef 0] 100] "; }
        #    ] -in $f5 -row 0 -column 1




############# Label Frame 3 - Display options

   set lf3 $vmdPresets::topGui.lf3

        grid [ttk::labelframe $lf3 -text "Display Options"] -in $vmdPresets::topGui -sticky news -pady 10 -padx 20
        grid columnconfigure $lf3     1   -weight 1


    #### FRAME 31 - Background colors
    set f31 $vmdPresets::topGui.lf3.frame2

        grid [ttk::frame $f31] -in $vmdPresets::topGui.lf3 -sticky news -pady 10 -padx 10
     #   grid columnconfigure $f2     1   -weight 1

        grid [ttk::label $f31.viewMode \
            -text "View Mode:" \
            ] -in $f31 -row 1 -column 0 -sticky news -pady 5 -padx 10

        variable perspectiveRadioButton 1

        grid [ttk::radiobutton $f31.perspectiveRadioButton \
            -text "Perspective" \
            -variable vmdPresets::perspectiveRadioButton \
            -value 1 \
            -command {vmdPresets::controlViewMode Perspective} \
            ] -in $f31 -row 1 -column 1 -sticky news -pady 5 -padx 10
 
        #$f31.perspectiveRadioButton invoke

        variable orthographicRadioButton 0

        grid [ttk::radiobutton $f31.orthographicRadioButton \
            -text "Orthographic" \
            -variable vmdPresets::orthographicRadioButton \
            -value 1 \
            -command {vmdPresets::controlViewMode Orthographic} \
            ] -in $f31 -row 1 -column 2 -sticky news -pady 5 -padx 10

        #$f2.colorGradRadioButton invoke

        variable deepCueRadioButton 1

        grid [ttk::checkbutton  $f31.deepCueRadioButton \
            -text "Deep Cueing " \
            -variable vmdPresets::deepCueRadioButton \
            -onvalue 1 \
            -offvalue 0 \
            -command {vmdPresets::controlDeepCue} \
            ] -in $f31 -row 2 -column 1 -sticky news -pady 5 -padx 10

        variable cullingCheckButton 0

        grid [ttk::checkbutton  $f31.cullingCheckButton \
            -text "Culling " \
            -variable vmdPresets::cullingCheckButton \
            -offvalue 0 \
            -onvalue 1 \
            -command {vmdPresets::controlCulling} \
            ] -in $f31 -row 2 -column 2 -sticky news -pady 0 -padx 10


    #### Frame clip
    set f32 $vmdPresets::topGui.lf3.frame3
        grid [ttk::frame $f32] -in $vmdPresets::topGui.lf3 -sticky news -pady 10 -padx 10
     #   grid columnconfigure $f2     1   -weight 1


    #### Clip Label
        grid [ttk::label  $f32.clipLabelClip \
            -text "Clipplane:"\
            ] -in $f32 -row 3 -column 0 -sticky w -pady 0 -padx 10
        

    #### Clip Near

        grid [ttk::label  $f32.clipLabelNear \
            -text "Front:"\
            ] -in $f32 -row 3 -column 1 -sticky w -pady 0 -padx 10
        

        variable clipScaleNear 0.50

        grid [ttk::scale $f32.clipScaleNear \
            -variable vmdPresets::clipScaleNear \
            -from 0 -to 5 \
            -orient horizontal \
            -length 100 \
            -command {vmdPresets::controlclippingScale Near} \
            ] -in $f32 -row 3 -column 2 -sticky news -pady 5 -padx 1


        grid [ttk::label $f32.labelScaleNear1 \
            -textvariable vmdPresets::clipScaleNear \
            ] -in $f32 -row 3 -column 3 -sticky news -pady 5 -padx 5


    #### Clip Far

        grid [ttk::label  $f32.clipLabelFar \
            -text "Back:"\
            ] -in $f32 -row 4 -column 1 -sticky w -pady 0 -padx 10
        

        variable clipScaleFar 5.00

        grid [ttk::scale $f32.clipScaleFar \
            -variable vmdPresets::clipScaleFar \
            -from 0 -to 5 \
            -orient horizontal \
            -length 100 \
            -command {vmdPresets::controlclippingScale Far} \
            ] -in $f32 -row 4 -column 2 -sticky news -pady 5 -padx 1


        grid [ttk::label $f32.labelScaleFar1 \
            -textvariable vmdPresets::clipScaleFar \
            ] -in $f32 -row 4 -column 3 -sticky news -pady 5 -padx 5

        grid [ttk::button $f32.clipButtonReset \
            -text "Reset"\
            -command {set vmdPresets::clipScaleNear 0.50; display nearclip set $vmdPresets::clipScaleNear; set vmdPresets::clipScaleFar 5.0; display nearclip set $vmdPresets::clipScaleFar}
            ] -in $f32 -row 3 -column 4 -sticky ns -pady 0 -padx 10   
     
     #   grid rowconfigure $f32.clipButtonReset     3   -weight 1



#### FRAME 4 - last frame

    set f6 $vmdPresets::topGui.bottomFrame

        grid [ttk::frame $f6] -in $vmdPresets::topGui -sticky e -pady 10 -padx 10
     #   grid columnconfigure $f2     1   -weight 1

     grid [ttk::button $f6.saveTemplate \
            -text "Save Template" \
            -command {vmdPresets::saveTemplate none} \
            ] -in $f6 -row 0 -column 1 -sticky e

     grid [ttk::button $f6.exit \
            -text "Exit" \
            -command {destroy $::vmdPresets::topGui} \
            ] -in $f6 -row 0 -column 2 -sticky e -padx 15



    #### BINDINGS
    #canvas 
    bind $f4.canvas <ButtonPress-1> {vmdPresets::onClick %x %y}
    bind $f4.canvas <MouseWheel> {%W yview scroll [expr {-%D/120}] units}
    
    # combobox bindings
    bind $f1.templateComboBox <<ComboboxSelected>> {vmdPresets::applyTemplate}
    bind $f3.templateComboBox <<ComboboxSelected>>  {if {$vmdPresets::colorGradRadioButton==0} {vmdPresets::addSolidcolors} else {vmdPresets::addGradcolors}}

    # Add mouse wheel scroll to widgets
    bind all <MouseWheel> "+vmdPresets::wheelEvent %X %Y %D"


    #### EXTRA

    # Check the status of the current variables
    vmdPresets:initVariables

    # Select the solid
    vmdPresets::controlBackgroundColor solidColor

    
}

       


proc vmdPresets::addSolidcolors {} {

    # canvas references
    set canvas1 $vmdPresets::topGui.lf2.frame4.canvas
    set canvas2 $vmdPresets::topGui.lf2.frame5.canvas
    
    # Delete Items from canvas
    $canvas1 delete all
    $canvas2 delete all

    # variables to create box with colors
    set outlinecolor black
    set fillText black
    set x 10
    set y 10
    set width 20
    set height $width

    # Load File from combobox
    set comboSelection [$vmdPresets::topGui.lf2.frame3.templateComboBox get]
    set file [open "$vmdPresets::pathPresets/$comboSelection.sc" r]

    while {![eof $file]} {
        set a [gets $file]

        # Add box
        set fill [lindex $a 0];  set text [lindex $a 1]
        set tag [list $a]
        vmdPresets::DrawBoxColor $canvas1 $fill $text $x $y $tag

        # control how the items are displayed in the canvas
        set x [expr $x + 150]
        if {$x>= 400 } {set x 10; set y [expr $y + $width + 5]}
    
        # Select first color
       # if {$a==[lindex $colorList 0] && $a!=""} {
       #     set c1 $vmdPresets::topGui.lf2.frame4.canvas
       #     $c1 itemconfigure $a -outline black -width 3
       #     set vmdPresets::colorRef $a

        #    set c2 $vmdPresets::topGui.lf2.frame5.canvas
        #    $c2 itemconfigure selectedColor -fill $a -width 1
        #    $c2 itemconfigure colorRef -text "$a : [::tk::Darken $a 100] "
        #} 

    }

    close $file

    # select favourites
    $vmdPresets::topGui.lf2.frame3.templateComboBox set Favorites

    # Show all canvas items properly
    $canvas1 configure -scrollregion [concat 0 0 [lrange [$canvas1 bbox all] end-1 end]]

    ## CANVAS 2
    set x 100; set y 10
        
    $canvas2 create text [expr $x-50] [expr $y +10]  -text "Selected Color: " -fill black 
    vmdPresets::DrawBoxColor $canvas2 white "white : #ffffff" $x $y selectedColor

}


proc vmdPresets::addGradcolors {} {

    # canvas references
    set canvas1 $vmdPresets::topGui.lf2.frame4.canvas
    set canvas2 $vmdPresets::topGui.lf2.frame5.canvas
    
    # Delete Items from canvas
    $canvas1 delete all
    $canvas2 delete all

    # CANVAS 1
    
    # variables to create box with colors
    set x 10 ;  set y 10

    # Load File from combobox
    set comboSelection [$vmdPresets::topGui.lf2.frame3.templateComboBox get]
    set file [open "$vmdPresets::pathPresets/$comboSelection.grad" r]

    while {![eof $file]} {

        set a [gets $file]
        set tag [list $a]

        #draw gradient
        set fill_1 [lindex $a 0]; set fill_2 [lindex $a 1];  set text [lindex $a 2]
        vmdPresets::DrawGradient $canvas1 $fill_1 $fill_2 $text $x $y 220 $tag

        # control how the items are displayed in the canvas
        set y [expr $y + 25]
        #set x [expr $x + 220];if {$x>= 400 } {set x 10; set y [expr $y +25]}
    }

    close $file

    # select favourites
    #$vmdPresets::topGui.lf2.frame3.templateComboBox set Favorites

   # Show all canvas items properly
    $canvas1 configure -scrollregion [concat 0 0 [lrange [$canvas1 bbox all] end-1 end]]


    #CANVAS 2
    set x 100; set y 10
    set text "Name of the gradient"
    $canvas2 create text [expr $x-50] [expr $y +10]  -text "Selected Gradient: " -fill black 
    vmdPresets::DrawGradient $canvas2 red blue $text $x $y 100 selectedColor
}




proc vmdPresets::DrawBoxColor {win color text x y tag} {

        $win create rect $x $y [expr $x+ 20] [expr $y+20] \
            -fill $color \
            -outline black \
            -tag $tag \
    
        $win create text [expr $x+35] [expr $y +10] \
            -text $text \
            -fill black \
            -anchor w \
            -tag colorRef

}


proc vmdPresets::DrawGradient {win col1Str col2Str text x0 y0 size tag} {

    set height 20
    set width [expr $x0 + $size]
    
    set color1 [winfo rgb $win $col1Str]
    set color2 [winfo rgb $win $col2Str]

    foreach {r1 g1 b1} $color1 break
    foreach {r2 g2 b2} $color2 break
    set rRange [expr $r2.0 - $r1]
    set gRange [expr $g2.0 - $g1]
    set bRange [expr $b2.0 - $b1]

    set rRatio [expr $rRange / $width]
    set gRatio [expr $gRange / $width]
    set bRatio [expr $bRange / $width]


    # Draw Line
    for {set i $x0} {$i < $width} {incr i} {
        set nR [expr int( $r1 + ($rRatio * $i) )]
        set nG [expr int( $g1 + ($gRatio * $i) )]
        set nB [expr int( $b1 + ($bRatio * $i) )]

        set col [format {%4.4x} $nR]
        append col [format {%4.4x} $nG]
        append col [format {%4.4x} $nB]

        $win create line $i $y0 $i [expr $y0 + $height] -fill #${col} -tag "$tag deleteGrad"
        
    }

    #Draw box
    $win create rect $x0 $y0 $width [expr $y0 + $height] \
        -outline black \
        -tag "$tag"

    #Draw text
    $win create text [expr $width + 20] [expr $y0 + $height/2] \
                -text $text  \
                -anchor w \
                -fill black \
                -tag "colorRef deleteGrad"

    return $win
 }

proc vmdPresets::populateComboBoxBackgroundTemplates {fileExtension combobox} {

        # Populate the combobox with files
        set fileList [glob -dir $vmdPresets::pathPresets $fileExtension]
        set colorSchemes "" 
        foreach a $fileList {set colorSchemes [lappend colorSchemes [file tail [file rootname $a]]]}

        #set combobox $vmdPresets::topGui.lf2.frame3.templateComboBox
        $combobox configure -values $colorSchemes
        $combobox set [lindex $colorSchemes 0]
        update

}



proc vmdPresets::controlBackgroundColor {opt} {

    set f2 $vmdPresets::topGui.lf2.frame2

    # control radiobuttons 
    if {$opt=="gradColor"} {
        set vmdPresets::colorSolidRadioButton 0
        set vmdPresets::colorGradRadioButton 1
       
        #populate combobox
        set fileExtension {*.grad}
        vmdPresets::populateComboBoxBackgroundTemplates $fileExtension $vmdPresets::topGui.lf2.frame3.templateComboBox
        #build canvas
        vmdPresets::addGradcolors

    } elseif {$opt=="solidColor"} {
        set vmdPresets::colorSolidRadioButton 1
        set vmdPresets::colorGradRadioButton 0
        
        #populate combobox
        set fileExtension {*.sc}
        vmdPresets::populateComboBoxBackgroundTemplates $fileExtension $vmdPresets::topGui.lf2.frame3.templateComboBox
        #build canvas
        vmdPresets::addSolidcolors
        
    } else { puts "error"}

update

}


proc vmdPresets::controlViewMode {opt} {

    # control radiobuttons 
    if {$opt=="Orthographic"} {
        set vmdPresets::perspectiveRadioButton 0
        set vmdPresets::orthographicRadioButton 1
        
        #VMD comand
        display projection Orthographic

    } elseif {$opt=="Perspective"}  {
        set vmdPresets::perspectiveRadioButton 1
        set vmdPresets::orthographicRadioButton 0
        
        #VMD comand
        display projection Perspective
    }
}


proc vmdPresets::onClick {x y} {
        set c1 $vmdPresets::topGui.lf2.frame4.canvas
        set c2 $vmdPresets::topGui.lf2.frame5.canvas
        set x [$c1 canvasx $x] ; set y [$c1 canvasy $y]
        set i [$c1 find closest $x $y]
        set t [$c1 gettags $i]


        if {$vmdPresets::colorGradRadioButton==0} {
            set color [lindex [lrange $t 0 end-1] 0]; # remove the current from the tag
        } else {
            set color [lindex $t 0]
        }

        if {$color=="colorRef" || $color=="box"|| $color=="delete" || $color==""} {return}
        #$c1 delete -tag delete 
        #$c1 create text 200 40  -text "$color" -fill red -tag delete
      
        # gather which radio button is selected
        if {$vmdPresets::colorGradRadioButton==0} {
            set fill [lindex $color 0]
            set text [lindex $color 1]

            #Covert color to VMD RGB
            scan $fill "\#%2x%2x%2x" r1 g1 b1

            set r2 [expr double($r1)/256]
            set g2 [expr double($g1)/256]
            set b2 [expr double($b1)/256]

            display backgroundgradient off

            # Change the black color Number 16
            color change rgb 31 $r2 $g2 $b2
            color Display Background 31

        } else {
            set fill [lindex $color 0]
            set fill_2 [lindex $color 1]  
            set text [lindex $color 2]

            #Covert color to VMD RGB
            
            # color 1
            scan $fill "\#%2x%2x%2x" r1 g1 b1
            set rF1 [expr double($r1)/256]
            set gF1 [expr double($g1)/256]
            set bF1 [expr double($b1)/256]

            # color 2
            scan $fill_2 "\#%2x%2x%2x" r2 g2 b2
            set rF2 [expr double($r2)/256]
            set gF2 [expr double($g2)/256]
            set bF2 [expr double($b2)/256]

            # Change colors 
            color change rgb 31 $rF1 $gF1 $bF1
            color change rgb 32 $rF2 $gF2 $bF2
            
            #Show gradient
            display backgroundgradient on

            color Display BackgroundTop 31
            color Display BackgroundBot 32

        }


        # remove the previous mark from the color box 
       # set vmdPresets::colorRef $color

        # create a mark on the color box
        if {$color!="" && $vmdPresets::colorGradRadioButton==0} {
        
            # remove previous marker
            $c1 itemconfigure $vmdPresets::colorRef  -width 1
        
            # add marker
            set vmdPresets::colorRef  $color
            $c1 itemconfigure $color -width 3
            $c2 itemconfigure selectedColor -fill $fill -width 1
            $c2 itemconfigure colorRef -text "$text : [::tk::Darken $fill 100] "


        } elseif {$color!="" && $vmdPresets::colorGradRadioButton==1} {
                
                # remove previous marker
                $c1 itemconfigure $vmdPresets::colorRef  -width 1

                # add marker
                set vmdPresets::colorRef $color
                $c1 itemconfigure $color -width 3
                
                #delete grad and draw again
                $c2 delete -tag deleteGrad
                
                set x 100; set y 10
                set text "[::tk::Darken $fill 100] > [::tk::Darken $fill_2 100]"
                $c2 create text [expr $x-50] [expr $y +10]  -text "Selected Gradient: " -fill black 
                vmdPresets::DrawGradient $c2 $fill $fill_2 $text $x $y 100 selectedColor

        }
        

}


proc vmdPresets::applyTemplate {} {

    # get file from combobox
    set comboSelection [ $vmdPresets::topGui.frame1.templateComboBox get]
    set file "$vmdPresets::pathPresets/$comboSelection.vmd"

    # run vmdState
    play $file

    # check variables
    vmdPresets:initVariables
}


proc vmdPresets::saveTemplate {file} {
  global representations
  global viewpoints
  save_viewpoint
  save_reps

  set file "$vmdPresets::pathPresets/example.vmd"


    set title "Enter filename to save current VMD state:"
    set filetypes [list {{VMD files} {.vmd}} {{All files} {*}}]
    if { [info commands tk_getSaveFile] != "" } {
      set file [tk_getSaveFile -defaultextension ".vmd" -initialdir $vmdPresets::pathPresets -initialfile example.vmd \
        -title $title -filetypes $filetypes]
    } else {
      puts "Enter filename to save current VMD state:"
      set file [gets stdin]
    }
  
  if { ![string compare $file ""] } {
    return
  }

  set fildes [open $file w]
  puts $fildes "\#!/usr/local/bin/vmd"
  puts $fildes "\# VMD script written by save_state \$Revision: 1.47 $"

  set vmdversion [vmdinfo version]
  puts $fildes "\# VMD version: $vmdversion"


  # Remove all representations
  puts $fildes ""
  puts $fildes "# Delete all representations. The stored will be added."
  puts $fildes ""
  puts $fildes "set srcmol \[molinfo top\]"
  puts $fildes "foreach mol \[molinfo list\] \{"
  puts $fildes " set numreps \[molinfo \$mol get numreps\]"
  puts $fildes " for \{set i 0\} \{\$i < \$numreps\} \{incr i\} \{mol delrep 0 \$mol\}"
  puts $fildes "\}"


  # Add gradient
  puts $fildes ""
  puts $fildes "# Gradient option"
  puts $fildes ""

  set a "yes"
  if {$a=="yes" } {
    puts $fildes "display backgroundgradient on"
  } else {
    puts $fildes "display backgroundgradient off"
  }

  puts $fildes ""
  puts $fildes "##### Standard vmdstate"
  puts $fildes ""

  puts $fildes "set viewplist {}"
  puts $fildes "set fixedlist {}"
  save_materials     $fildes
  save_atomselmacros $fildes
  save_display       $fildes

  foreach mol [molinfo list] {
    set files [lindex [molinfo $mol get filename] 0]
    set specs [lindex [molinfo $mol get filespec] 0]
    set types [lindex [molinfo $mol get filetype] 0]
    set nfiles [llength $files]
    if { $nfiles >= 1 } {
      #set filecmd [list mol new [lindex $files 0] type [lindex $types 0]]
      #set specstr [join [list [lindex $specs 0] waitfor all]]
      #puts $fildes "$filecmd $specstr"
    } else {
      #puts $fildes "mol new"
    }
    for { set i 1 } { $i < $nfiles } { incr i } {
      #set filecmd [list mol addfile [lindex $files $i] type [lindex $types $i]]
      #set specstr [join [list [lindex $specs $i] waitfor all]]
      #puts $fildes "$filecmd $specstr"
    }
    foreach g [graphics $mol list] {
      puts $fildes "graphics top [graphics $mol info $g]"
    }
    puts $fildes "mol delrep 0 top"
    if [info exists representations($mol)] {
      set i 0
      foreach rep $representations($mol) {
        foreach {r s c m pbc numpbc on selupd colupd colminmax smooth framespec cplist} $rep { break }
        puts $fildes "mol representation $r"
        puts $fildes "mol color $c"
        puts $fildes "mol selection {$s}"
        puts $fildes "mol material $m"
        puts $fildes "mol addrep top"
        if {[string length $pbc]} {
          puts $fildes "mol showperiodic top $i $pbc"
          puts $fildes "mol numperiodic top $i $numpbc"
        }
        puts $fildes "mol selupdate $i top $selupd"
        puts $fildes "mol colupdate $i top $colupd"
        puts $fildes "mol scaleminmax top $i $colminmax"
        puts $fildes "mol smoothrep top $i $smooth"
        puts $fildes "mol drawframes top $i {$framespec}"
        
        # restore per-representation clipping planes...
        set cpnum 0
        foreach cp $cplist {
          foreach { center color normal status } $cp { break }
          puts $fildes "mol clipplane center $cpnum $i top {$center}"
          puts $fildes "mol clipplane color  $cpnum $i top {$color }"
          puts $fildes "mol clipplane normal $cpnum $i top {$normal}"
          puts $fildes "mol clipplane status $cpnum $i top {$status}"
          incr cpnum
        }

        if { !$on } {
          puts $fildes "mol showrep top $i 0"
        }
        incr i
      } 
    }
    puts $fildes [list mol rename top [lindex [molinfo $mol get name] 0]]
    if {[molinfo $mol get drawn] == 0} {
      puts $fildes "molinfo top set drawn 0"
    }
    if {[molinfo $mol get active] == 0} {
      puts $fildes "molinfo top set active 0"
    }
    if {[molinfo $mol get fixed] == 1} {
      puts $fildes "lappend fixedlist \[molinfo top\]"
    }

    #puts $fildes "set viewpoints(\[molinfo top\]) [list $viewpoints($mol)]"
    #puts $fildes "lappend viewplist \[molinfo top\]"
    if {$mol == [molinfo top]} {
      #puts $fildes "set topmol \[molinfo top\]"
    }
    #puts $fildes "\# done with molecule $mol"
  } 
  #puts $fildes "foreach v \$viewplist \{"
  #puts $fildes "  molinfo \$v set {center_matrix rotate_matrix scale_matrix global_matrix} \$viewpoints(\$v)"
  #puts $fildes "\}"
  #puts $fildes "foreach v \$fixedlist \{"
  #puts $fildes "  molinfo \$v set fixed 1"
  #puts $fildes "\}"
  #puts $fildes "unset viewplist"
  #puts $fildes "unset fixedlist"
  if {[llength [molinfo list]] > 0} {
    #puts $fildes "mol top \$topmol"
    #puts $fildes "unset topmol"
  }
  save_colors $fildes
  save_labels $fildes
    
    # close File
    close $fildes
}



proc vmdPresets:initVariables {} {

    # check the current status of the View mode
    if {[display get projection]=="Orthographic"} {
        set vmdPresets::orthographicRadioButton 1
        set vmdPresets::perspectiveRadioButton 0
    } else {
        set vmdPresets::orthographicRadioButton 0
        set vmdPresets::perspectiveRadioButton 1
    }


    # check the depthcue status

    #if {[display get depthcue]=="off"} {
    #        set vmdPresets::deepCueRadioButton 0
    #} else {set vmdPresets::deepCueRadioButton 1}


    #check culling
    #if {[display get culling]=="off"} {
    #        set vmdPresets::cullingCheckButton 1
    #} else {set vmdPresets::cullingCheckButton 0}

 vmdPresets::controlDeepCue
  vmdPresets::controlCulling

}


proc vmdPresets::wheelEvent { x y delta } {

    # Find out what's the widget we're on
    set act 0
    set widget [winfo containing $x $y]

    if {$widget != ""} {
        # Make sure we've got a vertical scrollbar for this widget
        if {[catch "$widget cget -yscrollcommand" cmd]} return

        if {$cmd != ""} {
            # Find out the scrollbar widget we're using
            set scroller [lindex $cmd 0]

            # Make sure we act
            set act 1
        }
    }

    if {$act == 1} {
        # Now we know we have to process the wheel mouse event
        set xy [$widget yview]
        set factor [expr [lindex $xy 1]-[lindex $xy 0]]

        # Make sure we activate the scrollbar's command
        set cmd "[$scroller cget -command] scroll [expr -int($delta/(120*$factor))] units"
        eval $cmd
    }
}

proc vmdPresets::controlDeepCue {} {

    # control radiobuttons 
    if {[display get depthcue]=="off"} {
        set vmdPresets::deepCueRadioButton 1
        #VMD comand
        display depthcue on

    } else {
        set vmdPresets::deepCueRadioButton 0
        #VMD comand
        display depthcue off
    }

}


proc vmdPresets::controlCulling {} {

    # control radiobuttons 
    if {[display get culling]=="off"} {
        set vmdPresets::cullingCheckButton 1
        #VMD comand
         display culling on

    } else {
        set vmdPresets::cullingCheckButton 0
        #VMD comand
        display culling off
    }
   
}

proc vmdPresets::controlclippingScale {which x} { 

    # format x
    set x [format %2.2f $x]

    #turn perspective on
    vmdPresets::controlViewMode "Perspective" 

    if {$which=="Near" } {
        display nearclip set $x
        set vmdPresets::clipScaleNear $x
    } 

    if {$which=="Far" } {
        display farclip set $x
        set vmdPresets::clipScaleFar $x
    } 

    if {[display get Nearclip] > $x} {
        set vmdPresets::clipScaleNear $x
    } 
    

    if {[display get Farclip] < $x} {
        set vmdPresets::clipScaleFar $x
    } 
    



}

#### Start
#vmdPresets::gui

